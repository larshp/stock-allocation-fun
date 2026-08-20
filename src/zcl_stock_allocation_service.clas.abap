CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_service.
    ALIASES execute FOR zif_stock_allocation_service~execute.

    METHODS constructor
      IMPORTING
        io_stock_reader       TYPE REF TO zif_stock_reader
        io_allocation_writer  TYPE REF TO zif_allocation_writer
        io_unit_converter     TYPE REF TO zif_unit_converter
        io_idempotency_store  TYPE REF TO zif_idempotency_store
        io_authority          TYPE REF TO zif_allocation_authority
        io_reservation_status TYPE REF TO zif_reservation_status.

  PRIVATE SECTION.
    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
    DATA mo_allocation_writer TYPE REF TO zif_allocation_writer.
    DATA mo_idempotency_store TYPE REF TO zif_idempotency_store.
    DATA mo_authority TYPE REF TO zif_allocation_authority.
    DATA mo_reservation_status TYPE REF TO zif_reservation_status.
    DATA mo_allocator TYPE REF TO zcl_stock_allocator.

    TYPES ty_plants TYPE SORTED TABLE OF zcl_stock_allocator=>ty_plant
      WITH UNIQUE KEY table_line.

    METHODS reject_batch
      IMPORTING
        it_requests           TYPE zcl_stock_allocator=>ty_requests
        iv_status             TYPE zcl_stock_allocator=>ty_status
        iv_decision_code      TYPE zcl_stock_allocator=>ty_decision_code
        iv_message            TYPE string
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.

    METHODS apply_full_batch_policy
      CHANGING
        ct_allocations TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_reader = io_stock_reader.
    mo_allocation_writer = io_allocation_writer.
    mo_idempotency_store = io_idempotency_store.
    mo_authority = io_authority.
    mo_reservation_status = io_reservation_status.
    mo_allocator = NEW #( io_unit_converter ).
  ENDMETHOD.

  METHOD zif_stock_allocation_service~execute.
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      rt_allocations = reject_batch(
        it_requests      = it_requests
        iv_status        = zcl_stock_allocator=>gc_status_config_error
        iv_decision_code = zcl_stock_allocator=>gc_decision_run_policy_invalid
        iv_message       = 'Simulation flag must be X or blank' ).
      RETURN.
    ENDIF.
    IF iv_require_full_batch <> abap_false
        AND iv_require_full_batch <> abap_true.
      rt_allocations = reject_batch(
        it_requests      = it_requests
        iv_status        = zcl_stock_allocator=>gc_status_config_error
        iv_decision_code = zcl_stock_allocator=>gc_decision_run_policy_invalid
        iv_message       = 'Full-batch flag must be X or blank' ).
      RETURN.
    ENDIF.
    IF iv_strategy <> zcl_stock_allocator=>gc_strategy_priority_due
        AND iv_strategy <> zcl_stock_allocator=>gc_strategy_due_priority
        AND iv_strategy <> zcl_stock_allocator=>gc_strategy_priority_id.
      rt_allocations = reject_batch(
        it_requests      = it_requests
        iv_status        = zcl_stock_allocator=>gc_status_config_error
        iv_decision_code = zcl_stock_allocator=>gc_decision_bad_strategy
        iv_message       = 'Unsupported allocation strategy' ).
      RETURN.
    ENDIF.

    DATA lt_dependency_requests TYPE zcl_stock_allocator=>ty_requests.
    LOOP AT it_requests INTO DATA(ls_dependency_request).
      DATA(ls_validation) =
        mo_allocator->validate_request( ls_dependency_request ).
      IF ls_validation-is_valid = abap_false.
        CONTINUE.
      ENDIF.
      APPEND ls_dependency_request TO lt_dependency_requests.
    ENDLOOP.

    DATA lt_plants TYPE ty_plants.
    LOOP AT lt_dependency_requests INTO DATA(ls_plant_request)
      WHERE plant IS NOT INITIAL.
      INSERT ls_plant_request-plant INTO TABLE lt_plants.
    ENDLOOP.
    LOOP AT lt_plants INTO DATA(lv_plant).
      DATA(lv_authorized) = mo_authority->is_authorized( lv_plant ).
      IF lv_authorized <> abap_false AND lv_authorized <> abap_true.
        rt_allocations = reject_batch(
          it_requests      = it_requests
          iv_status        = zcl_stock_allocator=>gc_status_config_error
          iv_decision_code = zcl_stock_allocator=>gc_decision_authority_invalid
          iv_message       =
            |Authorization check returned invalid state for plant { lv_plant }| ).
        RETURN.
      ENDIF.
      IF lv_authorized = abap_false.
        rt_allocations = reject_batch(
          it_requests      = it_requests
          iv_status        = zcl_stock_allocator=>gc_status_invalid
          iv_decision_code = zcl_stock_allocator=>gc_decision_plant_unauthorized
          iv_message       = |Not authorized to allocate plant { lv_plant }| ).
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA lt_replays TYPE zcl_stock_allocator=>ty_replays.
    DATA lt_replay_request_ids TYPE zif_idempotency_store=>ty_request_ids.
    DATA lt_processed_request_ids TYPE zif_idempotency_store=>ty_request_ids.
    DATA lt_replay_records TYPE zif_idempotency_store=>ty_records.
    DATA lt_replay_document_ids TYPE zif_reservation_status=>ty_document_ids.
    DATA lt_cancelled_document_ids
      TYPE zif_reservation_status=>ty_document_ids.
    DATA(lt_stock_requests) = lt_dependency_requests.
    DATA lv_document_cancelled TYPE abap_bool.
    IF iv_simulation = abap_false.
      LOOP AT lt_dependency_requests INTO DATA(ls_request).
        INSERT ls_request-request_id INTO TABLE lt_replay_request_ids.
      ENDLOOP.
      IF lt_replay_request_ids IS NOT INITIAL.
        lt_replay_records = mo_idempotency_store->find_many(
          lt_replay_request_ids ).
      ENDIF.
      LOOP AT lt_replay_records ASSIGNING FIELD-SYMBOL(<ls_lookup_record>).
        IF <ls_lookup_record>-is_found <> abap_false
            AND <ls_lookup_record>-is_found <> abap_true.
          rt_allocations = reject_batch(
            it_requests      = it_requests
            iv_status        = zcl_stock_allocator=>gc_status_config_error
            iv_decision_code = zcl_stock_allocator=>gc_decision_replay_lookup
            iv_message       =
              |Idempotency lookup returned invalid state for request { <ls_lookup_record>-request_id }| ).
          RETURN.
        ENDIF.
        IF NOT line_exists( lt_replay_request_ids[
          table_line = <ls_lookup_record>-request_id ] ).
          rt_allocations = reject_batch(
            it_requests      = it_requests
            iv_status        = zcl_stock_allocator=>gc_status_config_error
            iv_decision_code = zcl_stock_allocator=>gc_decision_replay_lookup
            iv_message       =
              |Idempotency lookup returned unexpected request { <ls_lookup_record>-request_id }| ).
          RETURN.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_replay_records INTO DATA(ls_replay_record)
        WHERE is_found = abap_true
          AND document_id IS NOT INITIAL.
        INSERT ls_replay_record-document_id
          INTO TABLE lt_replay_document_ids.
      ENDLOOP.
      IF lt_replay_document_ids IS NOT INITIAL.
        lt_cancelled_document_ids =
          mo_reservation_status->find_cancelled(
            lt_replay_document_ids ).
      ENDIF.

      LOOP AT lt_dependency_requests INTO ls_request.
        INSERT ls_request-request_id INTO TABLE lt_processed_request_ids.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        CLEAR lv_document_cancelled.
        READ TABLE lt_replay_records INTO DATA(ls_record)
          WITH TABLE KEY request_id = ls_request-request_id.
        IF sy-subrc = 0 AND ls_record-is_found = abap_true.
          IF ls_record-document_id IS NOT INITIAL
              AND line_exists( lt_cancelled_document_ids[
                table_line = ls_record-document_id ] ).
            lv_document_cancelled = abap_true.
          ENDIF.
          INSERT VALUE #(
            payload_version        = ls_record-payload_version
            request_id             = ls_record-request_id
            material               = ls_record-material
            plant                  = ls_record-plant
            storage_location       = ls_record-storage_location
            movement_type          = ls_record-movement_type
            cost_center            = ls_record-cost_center
            order_id               = ls_record-order_id
            wbs_element            = ls_record-wbs_element
            sales_order            = ls_record-sales_order
            sales_order_item       = ls_record-sales_order_item
            asset_number           = ls_record-asset_number
            asset_subnumber        = ls_record-asset_subnumber
            network_id             = ls_record-network_id
            network_activity       = ls_record-network_activity
            requirement_date       = ls_record-requirement_date
            source_requested_qty   = ls_record-source_requested_qty
            source_unit_of_measure = ls_record-source_unit
            minimum_fill_pct       = ls_record-minimum_fill_pct
            priority               = ls_record-priority
            allow_partial          = ls_record-allow_partial
            requested_qty          = ls_record-requested_qty
            allocated_qty          = ls_record-allocated_qty
            unit_of_measure        = ls_record-unit_of_measure
            document_id            = ls_record-document_id
            document_cancelled     = lv_document_cancelled )
            INTO TABLE lt_replays.
          IF lv_document_cancelled = abap_false.
            DELETE lt_stock_requests
              WHERE request_id = ls_request-request_id.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_horizon_date IS NOT INITIAL.
      DELETE lt_stock_requests
        WHERE requirement_date > iv_horizon_date.
    ENDIF.

    DATA lt_stock TYPE zcl_stock_allocator=>ty_stock_balances.
    IF lt_stock_requests IS NOT INITIAL.
      lt_stock = mo_stock_reader->read_stock( lt_stock_requests ).
    ENDIF.
    rt_allocations = mo_allocator->allocate(
      it_requests       = it_requests
      it_stock_balances = lt_stock
      it_replays        = lt_replays
      iv_horizon_date   = iv_horizon_date
      iv_strategy       = iv_strategy ).

    IF iv_require_full_batch = abap_true.
      apply_full_batch_policy(
        CHANGING
          ct_allocations = rt_allocations ).
    ENDIF.

    IF iv_simulation = abap_true.
      LOOP AT rt_allocations ASSIGNING FIELD-SYMBOL(<ls_simulated>)
        WHERE allocated_qty > 0.
        <ls_simulated>-posting_status =
          zcl_stock_allocator=>gc_posting_simulated.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA lt_committed_allocations TYPE zcl_stock_allocator=>ty_allocations.
    LOOP AT rt_allocations INTO DATA(ls_allocation)
      WHERE allocated_qty > 0
        AND posting_status = zcl_stock_allocator=>gc_posting_pending.
      APPEND ls_allocation TO lt_committed_allocations.
    ENDLOOP.

    IF lt_committed_allocations IS NOT INITIAL.
      mo_allocation_writer->save_allocations(
        CHANGING
          ct_allocations = lt_committed_allocations ).

      LOOP AT lt_committed_allocations INTO DATA(ls_committed_allocation).
        READ TABLE rt_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
          WITH KEY request_id = ls_committed_allocation-request_id.
        IF sy-subrc = 0.
          <ls_allocation>-posting_status =
            ls_committed_allocation-posting_status.
          <ls_allocation>-document_id =
            ls_committed_allocation-document_id.
          <ls_allocation>-posting_message =
            ls_committed_allocation-posting_message.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD reject_batch.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id             = ls_request-request_id
        material               = ls_request-material
        plant                  = ls_request-plant
        storage_location       = ls_request-storage_location
        movement_type          = ls_request-movement_type
        cost_center            = ls_request-cost_center
        order_id               = ls_request-order_id
        wbs_element            = ls_request-wbs_element
        sales_order            = ls_request-sales_order
        sales_order_item       = ls_request-sales_order_item
        asset_number           = ls_request-asset_number
        asset_subnumber        = ls_request-asset_subnumber
        network_id             = ls_request-network_id
        network_activity       = ls_request-network_activity
        unit_of_measure        = ls_request-unit_of_measure
        requirement_date       = ls_request-requirement_date
        requested_qty          = ls_request-requested_qty
        source_requested_qty   = ls_request-requested_qty
        source_unit_of_measure = ls_request-unit_of_measure
        minimum_fill_pct       = ls_request-minimum_fill_pct
        priority               = ls_request-priority
        allow_partial          = ls_request-allow_partial
        shortfall_qty          = ls_request-requested_qty
        status                 = iv_status
        decision_code          = iv_decision_code
        posting_status         = zcl_stock_allocator=>gc_posting_not_required
        posting_message        = iv_message )
        TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_full_batch_policy.
    DATA lv_incomplete TYPE abap_bool.
    LOOP AT ct_allocations TRANSPORTING NO FIELDS
      WHERE posting_status <> zcl_stock_allocator=>gc_posting_posted
        AND status <> zcl_stock_allocator=>gc_status_allocated.
      lv_incomplete = abap_true.
      EXIT.
    ENDLOOP.
    IF lv_incomplete = abap_false.
      RETURN.
    ENDIF.

    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      WHERE posting_status = zcl_stock_allocator=>gc_posting_pending.
      CLEAR <ls_allocation>-allocated_qty.
      <ls_allocation>-shortfall_qty = <ls_allocation>-requested_qty.
      CLEAR <ls_allocation>-fill_pct.
      <ls_allocation>-status = zcl_stock_allocator=>gc_status_aborted.
      <ls_allocation>-decision_code =
        zcl_stock_allocator=>gc_decision_full_batch_aborted.
      <ls_allocation>-posting_status =
        zcl_stock_allocator=>gc_posting_not_required.
      <ls_allocation>-posting_message =
        'Full batch requirement was not met'.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
