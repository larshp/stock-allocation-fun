CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_service.
    ALIASES execute FOR zif_stock_allocation_service~execute.

    METHODS constructor
      IMPORTING
        io_stock_reader      TYPE REF TO zif_stock_reader
        io_allocation_writer TYPE REF TO zif_allocation_writer
        io_unit_converter    TYPE REF TO zif_unit_converter
        io_idempotency_store TYPE REF TO zif_idempotency_store.

  PRIVATE SECTION.
    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
    DATA mo_allocation_writer TYPE REF TO zif_allocation_writer.
    DATA mo_idempotency_store TYPE REF TO zif_idempotency_store.
    DATA mo_allocator TYPE REF TO zcl_stock_allocator.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_reader = io_stock_reader.
    mo_allocation_writer = io_allocation_writer.
    mo_idempotency_store = io_idempotency_store.
    mo_allocator = NEW #( io_unit_converter ).
  ENDMETHOD.

  METHOD zif_stock_allocation_service~execute.
    DATA lt_replays TYPE zcl_stock_allocator=>ty_replays.
    DATA(lt_stock_requests) = it_requests.
    IF iv_simulation = abap_false.
      LOOP AT it_requests INTO DATA(ls_request).
        DATA(ls_record) = mo_idempotency_store->find( ls_request-request_id ).
        IF ls_record-is_found = abap_true.
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
            document_id            = ls_record-document_id )
            INTO TABLE lt_replays.
          DELETE lt_stock_requests
            WHERE request_id = ls_request-request_id.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA(lt_stock) = mo_stock_reader->read_stock( lt_stock_requests ).
    rt_allocations = mo_allocator->allocate(
      it_requests       = it_requests
      it_stock_balances = lt_stock
      it_replays        = lt_replays
      iv_strategy       = iv_strategy ).

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
ENDCLASS.
