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
        io_allocation_writer TYPE REF TO zif_allocation_writer.

  PRIVATE SECTION.
    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
    DATA mo_allocation_writer TYPE REF TO zif_allocation_writer.
    DATA mo_allocator TYPE REF TO zcl_stock_allocator.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_reader = io_stock_reader.
    mo_allocation_writer = io_allocation_writer.
    mo_allocator = NEW #( ).
  ENDMETHOD.

  METHOD zif_stock_allocation_service~execute.
    DATA(lt_stock) = mo_stock_reader->read_stock( it_requests ).
    rt_allocations = mo_allocator->allocate(
      it_requests       = it_requests
      it_stock_balances = lt_stock
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
      WHERE allocated_qty > 0.
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
