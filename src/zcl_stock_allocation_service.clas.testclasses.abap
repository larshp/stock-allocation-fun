CLASS lcl_stock_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
    DATA mt_stock TYPE zcl_stock_allocator=>ty_stock_balances.
    DATA ms_result TYPE zif_stock_reader=>ty_result.
    DATA mt_requests TYPE zcl_stock_allocator=>ty_requests.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_stock_reader IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    mv_calls = mv_calls + 1.
    mt_requests = it_requests.
    rs_result = ms_result.
    rs_result-stock = mt_stock.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_idempotency_store DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_idempotency_store.
    DATA mt_records TYPE zif_idempotency_store=>ty_records.
    DATA ms_lookup_result TYPE zif_idempotency_store=>ty_lookup_result.
    DATA mt_find_request_ids TYPE zif_idempotency_store=>ty_request_ids.
    DATA mv_find_calls TYPE i.
    DATA mv_return_all TYPE abap_bool.
ENDCLASS.

CLASS lcl_idempotency_store IMPLEMENTATION.
  METHOD zif_idempotency_store~find.
    mv_find_calls = mv_find_calls + 1.
    READ TABLE mt_records INTO rs_record
      WITH TABLE KEY request_id = iv_request_id.
  ENDMETHOD.

  METHOD zif_idempotency_store~find_many.
    mv_find_calls = mv_find_calls + 1.
    mt_find_request_ids = it_request_ids.
    rs_result = ms_lookup_result.
    IF mv_return_all = abap_true.
      rs_result-records = mt_records.
      RETURN.
    ENDIF.
    LOOP AT it_request_ids INTO DATA(lv_request_id).
      READ TABLE mt_records INTO DATA(ls_record)
        WITH TABLE KEY request_id = lv_request_id.
      IF sy-subrc = 0.
        INSERT ls_record INTO TABLE rs_result-records.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_idempotency_store~claim.
    rv_acquired = abap_true.
  ENDMETHOD.

  METHOD zif_idempotency_store~set_document.
    rv_updated = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.
    DATA mv_denied_plant TYPE zcl_stock_allocator=>ty_plant.
    DATA mv_invalid_result TYPE abap_bool.
    DATA mt_checked_plants TYPE STANDARD TABLE OF
      zcl_stock_allocator=>ty_plant WITH EMPTY KEY.
ENDCLASS.

CLASS lcl_allocation_authority IMPLEMENTATION.
  METHOD zif_allocation_authority~is_authorized.
    APPEND iv_plant TO mt_checked_plants.
    IF mv_invalid_result = abap_true.
      rv_authorized = 'Y'.
      RETURN.
    ENDIF.
    rv_authorized = xsdbool( iv_plant <> mv_denied_plant ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_reservation_status DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_reservation_status.
    DATA mv_is_cancelled TYPE abap_bool.
    DATA mt_document_ids TYPE zif_reservation_status=>ty_document_ids.
    DATA ms_result TYPE zif_reservation_status=>ty_result.
    DATA mv_find_calls TYPE i.
ENDCLASS.

CLASS lcl_reservation_status IMPLEMENTATION.
  METHOD zif_reservation_status~is_cancelled.
    mv_find_calls = mv_find_calls + 1.
    INSERT iv_document_id INTO TABLE mt_document_ids.
    rv_is_cancelled = mv_is_cancelled.
  ENDMETHOD.

  METHOD zif_reservation_status~find_cancelled.
    mv_find_calls = mv_find_calls + 1.
    mt_document_ids = it_document_ids.
    rs_result = ms_result.
    IF mv_is_cancelled = abap_true
        AND rs_result-is_success = abap_true.
      rs_result-cancelled_ids = it_document_ids.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_unit_converter DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_converter.
    DATA ms_result TYPE zif_unit_converter=>ty_result.
    DATA mv_use_result TYPE abap_bool.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_unit_converter IMPLEMENTATION.
  METHOD zif_unit_converter~to_base.
    mv_calls = mv_calls + 1.
    IF mv_use_result = abap_true.
      rs_result = ms_result.
    ELSE.
      rs_result-is_success = abap_true.
      rs_result-quantity = iv_quantity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_writer DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_writer.
    DATA mt_saved TYPE zcl_stock_allocator=>ty_allocations.
    DATA mv_call_count TYPE i.
    DATA mv_fail TYPE abap_bool.
    DATA mv_response_mode TYPE c LENGTH 1.
ENDCLASS.

CLASS lcl_allocation_writer IMPLEMENTATION.
  METHOD zif_allocation_writer~save_allocations.
    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>).
      IF mv_fail = abap_true.
        <ls_allocation>-posting_status = zcl_stock_allocator=>gc_posting_failed.
        <ls_allocation>-posting_message = 'Posting failed'.
      ELSE.
        <ls_allocation>-posting_status = zcl_stock_allocator=>gc_posting_posted.
        <ls_allocation>-document_id = '0000000042'.
      ENDIF.
    ENDLOOP.
    mt_saved = ct_allocations.
    mv_call_count = mv_call_count + 1.
    CASE mv_response_mode.
      WHEN 'D'.
        DELETE ct_allocations INDEX 1.
      WHEN 'M'.
        ct_allocations[ 1 ]-material = 'CHANGED'.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_stock_reader.
    DATA mo_writer TYPE REF TO lcl_allocation_writer.
    DATA mo_converter TYPE REF TO lcl_unit_converter.
    DATA mo_store TYPE REF TO lcl_idempotency_store.
    DATA mo_authority TYPE REF TO lcl_allocation_authority.
    DATA mo_reservation_status TYPE REF TO lcl_reservation_status.
    DATA mo_cut TYPE REF TO zcl_stock_allocation_service.

    METHODS setup.
    METHODS simulation_does_not_write FOR TESTING.
    METHODS rejects_invalid_simulation FOR TESTING.
    METHODS rejects_invalid_full_batch FOR TESTING.
    METHODS rejects_strategy_before_reads FOR TESTING.
    METHODS skips_invalid_dependencies FOR TESTING.
    METHODS skips_all_invalid_reads FOR TESTING.
    METHODS skips_unpersistable_numeric FOR TESTING.
    METHODS rejects_failed_stock_read FOR TESTING.
    METHODS rejects_invalid_stock_state FOR TESTING.
    METHODS rejects_invalid_snapshot FOR TESTING.
    METHODS deduplicates_replay_lookups FOR TESTING.
    METHODS batches_replay_lookups FOR TESTING.
    METHODS rejects_invalid_replay_state FOR TESTING.
    METHODS rejects_failed_replay_lookup FOR TESTING.
    METHODS rejects_malformed_lookup FOR TESTING.
    METHODS rejects_unexpected_replay_id FOR TESTING.
    METHODS ignores_not_found_document FOR TESTING.
    METHODS batches_status_lookups FOR TESTING.
    METHODS rejects_failed_status_lookup FOR TESTING.
    METHODS rejects_invalid_status_state FOR TESTING.
    METHODS rejects_unexpected_status_id FOR TESTING.
    METHODS writes_successful_allocations FOR TESTING.
    METHODS returns_posting_failure FOR TESTING.
    METHODS rejects_dropped_writer_row FOR TESTING.
    METHODS rejects_mutated_writer_row FOR TESTING.
    METHODS skips_empty_write FOR TESTING.
    METHODS converts_before_write FOR TESTING.
    METHODS rejects_missing_converter FOR TESTING.
    METHODS rejects_missing_authority FOR TESTING.
    METHODS rejects_missing_store FOR TESTING.
    METHODS rejects_missing_status_reader FOR TESTING.
    METHODS rejects_missing_stock_reader FOR TESTING.
    METHODS rejects_missing_writer FOR TESTING.
    METHODS simulation_skips_prod_deps FOR TESTING.
    METHODS deferred_skips_runtime_deps FOR TESTING.
    METHODS invalid_skips_all_deps FOR TESTING.
    METHODS replays_completed_request FOR TESTING.
    METHODS rejects_incomplete_replay FOR TESTING.
    METHODS rejects_invalid_replay_outcome FOR TESTING.
    METHODS rejects_bad_replay_document FOR TESTING.
    METHODS rejects_reused_replay_document FOR TESTING.
    METHODS replay_does_not_reduce_stock FOR TESTING.
    METHODS rejects_reused_id_changes FOR TESTING.
    METHODS rejects_reused_assignment FOR TESTING.
    METHODS rejects_reused_sales_order FOR TESTING.
    METHODS rejects_legacy_replay FOR TESTING.
    METHODS simulation_ignores_replay FOR TESTING.
    METHODS denies_before_replay_or_stock FOR TESTING.
    METHODS rejects_invalid_authority FOR TESTING.
    METHODS checks_each_plant_once FOR TESTING.
    METHODS defers_without_stock_read FOR TESTING.
    METHODS reopens_cancelled_reservation FOR TESTING.
    METHODS aborts_incomplete_full_batch FOR TESTING.
    METHODS posts_complete_full_batch FOR TESTING.
    METHODS aborts_full_batch_simulation FOR TESTING.

    METHODS requests
      IMPORTING
        iv_quantity        TYPE zcl_stock_allocator=>ty_quantity
        iv_allow_partial   TYPE abap_bool DEFAULT abap_false
        iv_unit_of_measure TYPE zcl_stock_allocator=>ty_unit DEFAULT 'EA'
      RETURNING
        VALUE(rt_requests) TYPE zcl_stock_allocator=>ty_requests.

    METHODS completed_record
      RETURNING
        VALUE(rs_record) TYPE zif_idempotency_store=>ty_record.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_reader->ms_result-is_success = abap_true.
    mo_writer = NEW #( ).
    mo_converter = NEW #( ).
    mo_store = NEW #( ).
    mo_store->ms_lookup_result-is_success = abap_true.
    mo_authority = NEW #( ).
    mo_reservation_status = NEW #( ).
    mo_reservation_status->ms_result-is_success = abap_true.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 10 ) ).
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = mo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = mo_store
      io_authority          = mo_authority
      io_reservation_status = mo_reservation_status ).
  ENDMETHOD.

  METHOD simulation_does_not_write.
    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_simulated ).
  ENDMETHOD.

  METHOD writes_successful_allocations.
    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-allocated_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-document_id
      exp = '0000000042' ).
  ENDMETHOD.

  METHOD skips_empty_write.
    DATA(lt_result) = mo_cut->execute( requests( 11 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD returns_posting_failure.
    mo_writer->mv_fail = abap_true.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Posting failed' ).
  ENDMETHOD.

  METHOD rejects_dropped_writer_row.
    mo_writer->mv_response_mode = 'D'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Allocation writer returned invalid response' ).
    cl_abap_unit_assert=>assert_initial( lt_result[ 1 ]-document_id ).
  ENDMETHOD.

  METHOD rejects_mutated_writer_row.
    mo_writer->mv_response_mode = 'M'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Allocation writer returned invalid response' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_initial( lt_result[ 1 ]-document_id ).
  ENDMETHOD.

  METHOD converts_before_write.
    mo_converter->mv_use_result = abap_true.
    mo_converter->ms_result = VALUE #(
      is_success = abap_true
      quantity   = 10 ).

    DATA(lt_result) = mo_cut->execute(
      requests(
        iv_quantity        = 2
        iv_unit_of_measure = 'BOX' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-allocated_qty
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-source_requested_qty
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_missing_converter.
    DATA lo_converter TYPE REF TO zif_unit_converter.
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = mo_writer
      io_unit_converter     = lo_converter
      io_idempotency_store  = mo_store
      io_authority          = mo_authority
      io_reservation_status = mo_reservation_status ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_conversion_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Unit converter is required' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_authority.
    DATA lo_authority TYPE REF TO zif_allocation_authority.
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = mo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = mo_store
      io_authority          = lo_authority
      io_reservation_status = mo_reservation_status ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_authority_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Allocation authority is required' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_store.
    DATA lo_store TYPE REF TO zif_idempotency_store.
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = mo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = lo_store
      io_authority          = mo_authority
      io_reservation_status = mo_reservation_status ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Idempotency store is required' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_status_reader.
    INSERT completed_record( ) INTO TABLE mo_store->mt_records.
    DATA lo_status TYPE REF TO zif_reservation_status.
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = mo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = mo_store
      io_authority          = mo_authority
      io_reservation_status = lo_status ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_cancel_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Reservation status reader is required' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_stock_reader.
    DATA lo_reader TYPE REF TO zif_stock_reader.
    mo_cut = NEW #(
      io_stock_reader       = lo_reader
      io_allocation_writer  = mo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = mo_store
      io_authority          = mo_authority
      io_reservation_status = mo_reservation_status ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_stock_read ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stock reader is required' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_writer.
    DATA lo_writer TYPE REF TO zif_allocation_writer.
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = lo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = mo_store
      io_authority          = mo_authority
      io_reservation_status = mo_reservation_status ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_fully_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Allocation writer is required' ).
    cl_abap_unit_assert=>assert_initial( lt_result[ 1 ]-document_id ).
  ENDMETHOD.

  METHOD simulation_skips_prod_deps.
    DATA lo_writer TYPE REF TO zif_allocation_writer.
    DATA lo_store TYPE REF TO zif_idempotency_store.
    DATA lo_status TYPE REF TO zif_reservation_status.
    mo_cut = NEW #(
      io_stock_reader       = mo_reader
      io_allocation_writer  = lo_writer
      io_unit_converter     = mo_converter
      io_idempotency_store  = lo_store
      io_authority          = mo_authority
      io_reservation_status = lo_status ).

    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_simulated ).
  ENDMETHOD.

  METHOD deferred_skips_runtime_deps.
    DATA lo_reader TYPE REF TO zif_stock_reader.
    DATA lo_writer TYPE REF TO zif_allocation_writer.
    DATA lo_converter TYPE REF TO zif_unit_converter.
    DATA lo_store TYPE REF TO zif_idempotency_store.
    DATA lo_status TYPE REF TO zif_reservation_status.
    mo_cut = NEW #(
      io_stock_reader       = lo_reader
      io_allocation_writer  = lo_writer
      io_unit_converter     = lo_converter
      io_idempotency_store  = lo_store
      io_authority          = mo_authority
      io_reservation_status = lo_status ).

    DATA(lt_result) = mo_cut->execute(
      it_requests     = requests( 5 )
      iv_simulation   = abap_true
      iv_horizon_date = '20260817' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_deferred ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_outside_horizon ).
  ENDMETHOD.

  METHOD invalid_skips_all_deps.
    DATA lo_reader TYPE REF TO zif_stock_reader.
    DATA lo_writer TYPE REF TO zif_allocation_writer.
    DATA lo_converter TYPE REF TO zif_unit_converter.
    DATA lo_store TYPE REF TO zif_idempotency_store.
    DATA lo_authority TYPE REF TO zif_allocation_authority.
    DATA lo_status TYPE REF TO zif_reservation_status.
    mo_cut = NEW #(
      io_stock_reader       = lo_reader
      io_allocation_writer  = lo_writer
      io_unit_converter     = lo_converter
      io_idempotency_store  = lo_store
      io_authority          = lo_authority
      io_reservation_status = lo_status ).

    DATA(lt_result) = mo_cut->execute( requests( 0 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_invalid_request ).
  ENDMETHOD.

  METHOD replays_completed_request.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        minimum_fill_pct     = 0
        priority             = 100
        allow_partial        = abap_false
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute(
      it_requests     = requests( 5 )
      iv_horizon_date = '20260817' ).

    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-document_id
      exp = '0000000042' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Existing reservation reused' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replayed ).
    cl_abap_unit_assert=>assert_initial(
      lt_result[ 1 ]-shortfall_qty ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-fill_pct
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mt_document_ids[ 1 ]
      exp = '0000000042' ).
  ENDMETHOD.

  METHOD rejects_invalid_simulation.
    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = 'Y' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_run_policy_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Simulation flag must be X or blank' ).
    cl_abap_unit_assert=>assert_initial( mo_authority->mt_checked_plants ).
    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_full_batch.
    DATA(lt_result) = mo_cut->execute(
      it_requests           = requests( 5 )
      iv_require_full_batch = 'Y' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_run_policy_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Full-batch flag must be X or blank' ).
    cl_abap_unit_assert=>assert_initial( mo_authority->mt_checked_plants ).
    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_strategy_before_reads.
    DATA(lt_result) = mo_cut->execute(
      it_requests = requests( 5 )
      iv_strategy = 'UNSUPPORTED' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_bad_strategy ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Unsupported allocation strategy' ).
    cl_abap_unit_assert=>assert_initial( mo_authority->mt_checked_plants ).
    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD skips_invalid_dependencies.
    DATA(lt_requests) = requests( 5 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '2000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 0
      priority         = 200 ) TO lt_requests.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_posted ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-2' ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_authority->mt_checked_plants )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->mt_checked_plants[ 1 ]
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mt_requests[ 1 ]-request_id
      exp = 'REQUEST-1' ).
  ENDMETHOD.

  METHOD skips_all_invalid_reads.
    DATA(lt_result) = mo_cut->execute( requests( 0 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_initial( mo_authority->mt_checked_plants ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD skips_unpersistable_numeric.
    DATA(lt_result) = mo_cut->execute(
      requests( CONV decfloat34( '1.2345' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_invalid_request ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Requested quantity supports at most three decimals' ).
    cl_abap_unit_assert=>assert_initial( mo_authority->mt_checked_plants ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_failed_stock_read.
    mo_reader->ms_result-is_success = abap_false.
    mo_reader->ms_result-message = 'Stock backend unavailable'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_stock_read ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stock backend unavailable' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_stock_state.
    mo_reader->ms_result-is_success = 'Y'.
    mo_reader->ms_result-message = 'Misleading success'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_stock_read ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stock reader returned invalid state' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_snapshot.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-2'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5 ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_stock_snapshot ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stock snapshot contains an unrequested domain' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD deduplicates_replay_lookups.
    DATA(lt_requests) = requests( 5 ).
    DATA(ls_duplicate) = lt_requests[ 1 ].
    ls_duplicate-plant = '2000'.
    ls_duplicate-priority = 200.
    APPEND ls_duplicate TO lt_requests.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_posted ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_duplicate_request ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_find_request_ids )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mt_requests[ 2 ]-plant
      exp = '2000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 1 ).
  ENDMETHOD.

  METHOD batches_replay_lookups.
    DATA(lt_requests) = requests( 5 ).
    DATA(ls_second) = lt_requests[ 1 ].
    ls_second-request_id = 'REQUEST-2'.
    ls_second-requested_qty = 3.
    ls_second-priority = 200.
    APPEND ls_second TO lt_requests.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_find_request_ids )
      exp = 2 ).
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists(
        mo_store->mt_find_request_ids[ table_line = 'REQUEST-1' ] ) ) ).
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists(
        mo_store->mt_find_request_ids[ table_line = 'REQUEST-2' ] ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_invalid_replay_state.
    mo_store->mt_records = VALUE #(
      ( is_found    = 'Y'
        request_id  = 'REQUEST-1'
        document_id = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Idempotency lookup returned invalid state for request REQUEST-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_failed_replay_lookup.
    mo_store->ms_lookup_result-is_success = abap_false.
    mo_store->ms_lookup_result-message = 'Idempotency backend unavailable'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Idempotency backend unavailable' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_malformed_lookup.
    mo_store->ms_lookup_result-is_success = 'Y'.
    mo_store->ms_lookup_result-message = 'Misleading success'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Idempotency lookup returned invalid state' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_unexpected_replay_id.
    mo_store->mv_return_all = abap_true.
    mo_store->mt_records = VALUE #(
      ( is_found    = abap_true
        request_id  = 'REQUEST-2'
        document_id = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Idempotency lookup returned unexpected request REQUEST-2' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD ignores_not_found_document.
    mo_store->mt_records = VALUE #(
      ( is_found    = abap_false
        request_id  = 'REQUEST-1'
        document_id = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 1 ).
  ENDMETHOD.

  METHOD batches_status_lookups.
    DATA(lt_requests) = requests( 5 ).
    DATA(ls_second) = lt_requests[ 1 ].
    ls_second-request_id = 'REQUEST-2'.
    ls_second-requested_qty = 3.
    ls_second-priority = 200.
    APPEND ls_second TO lt_requests.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000041' )
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-2'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 3
        source_unit          = 'EA'
        priority             = 200
        requested_qty        = 3
        allocated_qty        = 3
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reservation_status->mt_document_ids )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replayed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-2' ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replayed ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_failed_status_lookup.
    INSERT completed_record( ) INTO TABLE mo_store->mt_records.
    mo_reservation_status->ms_result-is_success = abap_false.
    mo_reservation_status->ms_result-message = 'Status lookup failed'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_cancel_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Status lookup failed' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_status_state.
    INSERT completed_record( ) INTO TABLE mo_store->mt_records.
    mo_reservation_status->ms_result-is_success = 'Y'.
    mo_reservation_status->ms_result-message = 'Misleading success'.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_cancel_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Reservation status lookup returned invalid state' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_unexpected_status_id.
    INSERT completed_record( ) INTO TABLE mo_store->mt_records.
    mo_reservation_status->ms_result-cancelled_ids = VALUE #(
      ( '0000000099' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_cancel_lookup ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Reservation status returned unexpected document 0000000099' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_incomplete_replay.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_missing ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_replay_outcome.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 6
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_outcome ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stored allocation outcome is invalid' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_initial(
      lt_result[ 1 ]-fill_pct ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_bad_replay_document.
    DATA(ls_record) = completed_record( ).
    ls_record-document_id = 'BAD-DOC-ID'.
    INSERT ls_record INTO TABLE mo_store->mt_records.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_outcome ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stored reservation document ID is invalid' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_reused_replay_document.
    DATA(lt_requests) = requests( 5 ).
    DATA(ls_second_request) = lt_requests[ 1 ].
    ls_second_request-request_id = 'REQUEST-2'.
    APPEND ls_second_request TO lt_requests.
    DATA(ls_first_record) = completed_record( ).
    INSERT ls_first_record INTO TABLE mo_store->mt_records.
    DATA(ls_second_record) = ls_first_record.
    ls_second_record-request_id = 'REQUEST-2'.
    INSERT ls_second_record INTO TABLE mo_store->mt_records.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_outcome ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stored reservation document ID is reused' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation_status->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD replay_does_not_reduce_stock.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000041' ) ).
    DATA(lt_requests) = requests( 5 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 10
      priority         = 200 ) TO lt_requests.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-2' ]-allocated_qty
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_writer->mt_saved )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-request_id
      exp = 'REQUEST-2' ).
  ENDMETHOD.

  METHOD rejects_reused_id_changes.
    mo_reservation_status->mv_is_cancelled = abap_true.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 6 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Request ID was already used with different input' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_conflict ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_reused_assignment.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC9999'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Request ID was already used with different input' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_reused_sales_order.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '231'
        sales_order          = '0000123456'
        sales_order_item     = '000010'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).
    DATA(lt_requests) = requests( 5 ).
    lt_requests[ 1 ]-movement_type = '231'.
    CLEAR lt_requests[ 1 ]-cost_center.
    lt_requests[ 1 ]-sales_order = '0000123456'.
    lt_requests[ 1 ]-sales_order_item = '000020'.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Request ID was already used with different input' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_legacy_replay.
    mo_store->mt_records = VALUE #(
      ( is_found   = abap_true
        request_id = 'REQUEST-1' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_not_required ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stored request payload version is unsupported' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_replay_version ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD simulation_ignores_replay.
    mo_store->mt_records = VALUE #(
      ( is_found    = abap_true
        request_id  = 'REQUEST-1'
        document_id = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_simulated ).
  ENDMETHOD.

  METHOD denies_before_replay_or_stock.
    mo_authority->mv_denied_plant = '1000'.
    mo_store->mt_records = VALUE #(
      ( is_found    = abap_true
        request_id  = 'REQUEST-1'
        document_id = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute(
      it_requests     = requests( 5 )
      iv_horizon_date = '20260817' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Not authorized to allocate plant 1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_plant_unauthorized ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_authority.
    mo_authority->mv_invalid_result = abap_true.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_authority_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Authorization check returned invalid state for plant 1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mv_find_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD checks_each_plant_once.
    DATA(lt_requests) = requests( 5 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 5
      priority         = 200 ) TO lt_requests.

    mo_cut->execute(
      it_requests   = lt_requests
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_authority->mt_checked_plants )
      exp = 1 ).
  ENDMETHOD.

  METHOD defers_without_stock_read.
    DATA(lt_result) = mo_cut->execute(
      it_requests     = requests( 5 )
      iv_horizon_date = '20260817' ).

    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_deferred ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD reopens_cancelled_reservation.
    mo_reservation_status->mv_is_cancelled = abap_true.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000041' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-replaced_document_id
      exp = '0000000041' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-document_id
      exp = '0000000042' ).
  ENDMETHOD.

  METHOD aborts_incomplete_full_batch.
    DATA(lt_requests) = requests( 6 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 6
      priority         = 200 ) TO lt_requests.

    DATA(lt_result) = mo_cut->execute(
      it_requests           = lt_requests
      iv_require_full_batch = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-status
      exp = zcl_stock_allocator=>gc_status_aborted ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_full_batch_aborted ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-shortfall_qty
      exp = 6 ).
    cl_abap_unit_assert=>assert_initial(
      lt_result[ request_id = 'REQUEST-1' ]-fill_pct ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-2' ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD posts_complete_full_batch.
    DATA(lt_requests) = requests( 5 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 5
      priority         = 200 ) TO lt_requests.

    DATA(lt_result) = mo_cut->execute(
      it_requests           = lt_requests
      iv_require_full_batch = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_writer->mt_saved )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-2' ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_posted ).
  ENDMETHOD.

  METHOD aborts_full_batch_simulation.
    DATA(lt_requests) = requests( 6 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 6
      priority         = 200 ) TO lt_requests.

    DATA(lt_result) = mo_cut->execute(
      it_requests           = lt_requests
      iv_simulation         = abap_true
      iv_require_full_batch = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_not_required ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-1' ]-allocated_qty
      exp = 0 ).
  ENDMETHOD.

  METHOD requests.
    rt_requests = VALUE #(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        cost_center      = 'CC1000'
        unit_of_measure  = iv_unit_of_measure
        requirement_date = '20260818'
        requested_qty    = iv_quantity
        priority         = 100
        allow_partial    = iv_allow_partial ) ).
  ENDMETHOD.

  METHOD completed_record.
    rs_record = VALUE #(
      is_found             = abap_true
      payload_version      = zcl_stock_allocator=>gc_payload_version
      request_id           = 'REQUEST-1'
      material             = 'MAT-1'
      plant                = '1000'
      storage_location     = '0001'
      movement_type        = '201'
      cost_center          = 'CC1000'
      requirement_date     = '20260818'
      source_requested_qty = 5
      source_unit          = 'EA'
      priority             = 100
      requested_qty        = 5
      allocated_qty        = 5
      unit_of_measure      = 'EA'
      document_id          = '0000000041' ).
  ENDMETHOD.
ENDCLASS.
