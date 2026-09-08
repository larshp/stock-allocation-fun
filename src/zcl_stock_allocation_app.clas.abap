CLASS zcl_stock_allocation_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_summary,
        submitted_requests        TYPE i,
        returned_results          TYPE i,
        total_requests            TYPE i,
        fully_allocated           TYPE i,
        partially_allocated       TYPE i,
        rejected                  TYPE i,
        invalid                   TYPE i,
        deferred                  TYPE i,
        aborted                   TYPE i,
        configuration_errors      TYPE i,
        unknown_allocation_status TYPE i,
        posting_pending           TYPE i,
        posted                    TYPE i,
        posting_failed            TYPE i,
        simulated                 TYPE i,
        posting_not_required      TYPE i,
        unknown_posting_status    TYPE i,
        availability_evaluated    TYPE i,
        reservation_documents     TYPE i,
        idempotent_replays        TYPE i,
        new_reservations          TYPE i,
        replacement_attempts      TYPE i,
        replacement_posted        TYPE i,
      END OF ty_summary.
    TYPES:
      BEGIN OF ty_result,
        allocations          TYPE zcl_stock_allocator=>ty_allocations,
        summary              TYPE ty_summary,
        run_id               TYPE zif_allocation_logger=>ty_run_id,
        service_result_valid TYPE abap_bool,
        log_saved            TYPE abap_bool,
        message              TYPE string,
      END OF ty_result.

    METHODS constructor
      IMPORTING
        io_service TYPE REF TO zif_stock_allocation_service
        io_logger  TYPE REF TO zif_allocation_logger.

    METHODS run
      IMPORTING
        it_requests           TYPE zcl_stock_allocator=>ty_requests
        iv_simulation         TYPE abap_bool DEFAULT abap_false
        iv_horizon_date       TYPE d OPTIONAL
        iv_require_full_batch TYPE abap_bool DEFAULT abap_false
        iv_strategy           TYPE zcl_stock_allocator=>ty_strategy
          DEFAULT zcl_stock_allocator=>gc_strategy_priority_due
      RETURNING
        VALUE(rs_result)      TYPE ty_result.

    CLASS-METHODS create_sap
      RETURNING
        VALUE(ro_app) TYPE REF TO zcl_stock_allocation_app.

    CLASS-METHODS summarize
      IMPORTING
        it_allocations    TYPE zcl_stock_allocator=>ty_allocations
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

  PRIVATE SECTION.
    DATA mo_service TYPE REF TO zif_stock_allocation_service.
    DATA mo_logger TYPE REF TO zif_allocation_logger.

    METHODS service_response_is_valid
      IMPORTING
        it_requests           TYPE zcl_stock_allocator=>ty_requests
        it_allocations        TYPE zcl_stock_allocator=>ty_allocations
        iv_simulation         TYPE abap_bool
        iv_strategy           TYPE zcl_stock_allocator=>ty_strategy
        iv_horizon_date       TYPE d OPTIONAL
        iv_require_full_batch TYPE abap_bool
      RETURNING
        VALUE(rv_valid)       TYPE abap_bool.

ENDCLASS.

CLASS zcl_stock_allocation_app IMPLEMENTATION.
  METHOD constructor.
    mo_service = io_service.
    mo_logger = io_logger.
  ENDMETHOD.

  METHOD run.
    DATA(lv_run_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    rs_result-run_id = |{ lv_run_uuid }|.
    rs_result-summary-submitted_requests = lines( it_requests ).
    IF mo_service IS NOT BOUND.
      rs_result-message = 'Allocation service is required'.
      RETURN.
    ENDIF.

    rs_result-allocations = mo_service->execute(
      it_requests           = it_requests
      iv_simulation         = iv_simulation
      iv_horizon_date       = iv_horizon_date
      iv_require_full_batch = iv_require_full_batch
      iv_strategy           = iv_strategy ).
    rs_result-summary = summarize( rs_result-allocations ).
    rs_result-summary-submitted_requests = lines( it_requests ).
    IF service_response_is_valid(
        it_requests           = it_requests
        it_allocations        = rs_result-allocations
        iv_simulation         = iv_simulation
        iv_strategy           = iv_strategy
        iv_horizon_date       = iv_horizon_date
        iv_require_full_batch = iv_require_full_batch ) = abap_false.
      rs_result-message = 'Allocation service returned invalid result'.
      RETURN.
    ENDIF.
    rs_result-service_result_valid = abap_true.
    IF mo_logger IS NOT BOUND.
      rs_result-message = 'Allocation logger is required'.
      RETURN.
    ENDIF.

    DATA(lv_log_saved) = mo_logger->write(
      it_allocations        = rs_result-allocations
      iv_simulation         = iv_simulation
      iv_run_id             = rs_result-run_id
      iv_strategy           = iv_strategy
      iv_horizon_date       = iv_horizon_date
      iv_require_full_batch = iv_require_full_batch ).
    rs_result-log_saved = xsdbool( lv_log_saved = abap_true ).
    IF lv_log_saved = abap_false.
      rs_result-message = 'Allocation log could not be saved'.
    ELSEIF lv_log_saved <> abap_true.
      rs_result-message = 'Allocation logger returned invalid state'.
    ENDIF.
  ENDMETHOD.

  METHOD create_sap.
    DATA(lo_stock_reader) = NEW zcl_stock_reader_sap( ).
    DATA(lo_factor_reader) = NEW zcl_unit_factor_reader_sap( ).
    DATA(lo_unit_converter) = NEW zcl_unit_converter( lo_factor_reader ).
    DATA(lo_stock_rechecker) = NEW zcl_stock_rechecker_sap( lo_stock_reader ).
    DATA(lo_lock_gateway) = NEW zcl_stock_lock_gateway_sap( ).
    DATA(lo_stock_lock) = NEW zcl_stock_lock_sap( lo_lock_gateway ).
    DATA(lo_gateway) = NEW zcl_reservation_gateway_sap( ).
    DATA(lo_idempotency_store) = NEW zcl_idempotency_store_sap( ).
    DATA(lo_authority) = NEW zcl_allocation_authority_sap( ).
    DATA(lo_reservation_status) = NEW zcl_reservation_status_sap( ).
    DATA(lo_writer) = NEW zcl_allocation_writer_sap(
      io_gateway           = lo_gateway
      io_idempotency_store = lo_idempotency_store
      io_stock_rechecker   = lo_stock_rechecker
      io_stock_lock        = lo_stock_lock ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_reader       = lo_stock_reader
      io_allocation_writer  = lo_writer
      io_unit_converter     = lo_unit_converter
      io_idempotency_store  = lo_idempotency_store
      io_authority          = lo_authority
      io_reservation_status = lo_reservation_status ).
    DATA(lo_log_store) = NEW zcl_allocation_log_store_sap( ).
    DATA(lo_logger) = NEW zcl_allocation_logger_sap( lo_log_store ).

    ro_app = NEW #(
      io_service = lo_service
      io_logger  = lo_logger ).
  ENDMETHOD.

  METHOD summarize.
    rs_summary-returned_results = lines( it_allocations ).
    rs_summary-total_requests = lines( it_allocations ).
    LOOP AT it_allocations INTO DATA(ls_allocation).
      CASE ls_allocation-status.
        WHEN zcl_stock_allocator=>gc_status_allocated.
          rs_summary-fully_allocated = rs_summary-fully_allocated + 1.
        WHEN zcl_stock_allocator=>gc_status_partial.
          rs_summary-partially_allocated =
            rs_summary-partially_allocated + 1.
        WHEN zcl_stock_allocator=>gc_status_rejected.
          rs_summary-rejected = rs_summary-rejected + 1.
        WHEN zcl_stock_allocator=>gc_status_invalid.
          rs_summary-invalid = rs_summary-invalid + 1.
        WHEN zcl_stock_allocator=>gc_status_deferred.
          rs_summary-deferred = rs_summary-deferred + 1.
        WHEN zcl_stock_allocator=>gc_status_aborted.
          rs_summary-aborted = rs_summary-aborted + 1.
        WHEN zcl_stock_allocator=>gc_status_config_error.
          rs_summary-configuration_errors =
            rs_summary-configuration_errors + 1.
        WHEN OTHERS.
          rs_summary-unknown_allocation_status =
            rs_summary-unknown_allocation_status + 1.
      ENDCASE.

      CASE ls_allocation-posting_status.
        WHEN zcl_stock_allocator=>gc_posting_pending.
          rs_summary-posting_pending = rs_summary-posting_pending + 1.
        WHEN zcl_stock_allocator=>gc_posting_posted.
          rs_summary-posted = rs_summary-posted + 1.
        WHEN zcl_stock_allocator=>gc_posting_failed.
          rs_summary-posting_failed = rs_summary-posting_failed + 1.
        WHEN zcl_stock_allocator=>gc_posting_simulated.
          rs_summary-simulated = rs_summary-simulated + 1.
        WHEN zcl_stock_allocator=>gc_posting_not_required.
          rs_summary-posting_not_required =
            rs_summary-posting_not_required + 1.
        WHEN OTHERS.
          rs_summary-unknown_posting_status =
            rs_summary-unknown_posting_status + 1.
      ENDCASE.

      IF ls_allocation-availability_checked = abap_true.
        rs_summary-availability_evaluated =
          rs_summary-availability_evaluated + 1.
      ENDIF.
      IF ls_allocation-document_id IS NOT INITIAL.
        rs_summary-reservation_documents =
          rs_summary-reservation_documents + 1.
      ENDIF.
      IF ls_allocation-decision_code =
          zcl_stock_allocator=>gc_decision_replayed.
        rs_summary-idempotent_replays =
          rs_summary-idempotent_replays + 1.
      ELSEIF ls_allocation-posting_status =
          zcl_stock_allocator=>gc_posting_posted.
        rs_summary-new_reservations = rs_summary-new_reservations + 1.
      ENDIF.
      IF ls_allocation-replaced_document_id IS NOT INITIAL.
        rs_summary-replacement_attempts =
          rs_summary-replacement_attempts + 1.
        IF ls_allocation-posting_status =
            zcl_stock_allocator=>gc_posting_posted.
          rs_summary-replacement_posted =
            rs_summary-replacement_posted + 1.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD service_response_is_valid.
    IF lines( it_requests ) <> lines( it_allocations ).
      RETURN.
    ENDIF.

    DATA(lt_requests) = it_requests.
    SORT lt_requests BY request_id material plant storage_location
      movement_type cost_center order_id wbs_element sales_order
      sales_order_item asset_number asset_subnumber network_id
      network_activity unit_of_measure requirement_date requested_qty
      minimum_fill_pct priority allow_partial.
    DATA(lt_allocations) = it_allocations.
    SORT lt_allocations BY request_id material plant storage_location
      movement_type cost_center order_id wbs_element sales_order
      sales_order_item asset_number asset_subnumber network_id
      network_activity source_unit_of_measure requirement_date
      source_requested_qty minimum_fill_pct priority allow_partial.

    LOOP AT lt_requests INTO DATA(ls_request).
      DATA(lv_index) = sy-tabix.
      READ TABLE lt_allocations INDEX lv_index INTO DATA(ls_allocation).
      IF sy-subrc <> 0
          OR ls_allocation-request_id <> ls_request-request_id
          OR ls_allocation-material <> ls_request-material
          OR ls_allocation-plant <> ls_request-plant
          OR ls_allocation-storage_location <> ls_request-storage_location
          OR ls_allocation-movement_type <> ls_request-movement_type
          OR ls_allocation-cost_center <> ls_request-cost_center
          OR ls_allocation-order_id <> ls_request-order_id
          OR ls_allocation-wbs_element <> ls_request-wbs_element
          OR ls_allocation-sales_order <> ls_request-sales_order
          OR ls_allocation-sales_order_item <> ls_request-sales_order_item
          OR ls_allocation-asset_number <> ls_request-asset_number
          OR ls_allocation-asset_subnumber <> ls_request-asset_subnumber
          OR ls_allocation-network_id <> ls_request-network_id
          OR ls_allocation-network_activity <> ls_request-network_activity
          OR ls_allocation-source_unit_of_measure <>
            ls_request-unit_of_measure
          OR ls_allocation-requirement_date <> ls_request-requirement_date
          OR ls_allocation-source_requested_qty <> ls_request-requested_qty
          OR ls_allocation-minimum_fill_pct <> ls_request-minimum_fill_pct
          OR ls_allocation-priority <> ls_request-priority
          OR ls_allocation-allow_partial <> ls_request-allow_partial.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF zcl_allocation_result_check=>batch_is_valid(
        it_allocations ) = abap_false
        OR zcl_allocation_result_check=>run_context_is_valid(
          it_allocations        = it_allocations
          iv_simulation         = iv_simulation
          iv_strategy           = iv_strategy
          iv_horizon_date       = iv_horizon_date
          iv_require_full_batch = iv_require_full_batch ) = abap_false.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

ENDCLASS.
