CLASS zcl_stock_allocator_fifo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_allocator_fifo IMPLEMENTATION.
  METHOD zif_stock_allocation~allocate.
    DATA lt_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    IF iv_available < 0.
      raise_error( iv_message = 'Available stock is invalid' ).
    ENDIF.

    LOOP AT ct_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_id IS INITIAL OR <ls_demand>-requested <= 0.
        raise_error( iv_message = 'Allocation demand is invalid' ).
      ENDIF.
      INSERT <ls_demand>-order_id INTO TABLE lt_order_ids.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Allocation demand keys are duplicated' ).
      ENDIF.
    ENDLOOP.

    SORT ct_demands BY requested_on ASCENDING priority DESCENDING
                       order_id ASCENDING.
    rv_remaining = iv_available.
    LOOP AT ct_demands ASSIGNING <ls_demand>.
      CLEAR: <ls_demand>-allocated,
             <ls_demand>-shortage,
             <ls_demand>-allocation_status,
             <ls_demand>-reservation_id,
             <ls_demand>-reservation_date,
             <ls_demand>-reservation_movement_type,
             <ls_demand>-reservation_unit.
      IF <ls_demand>-requested <= rv_remaining.
        <ls_demand>-allocated = <ls_demand>-requested.
      ELSE.
        <ls_demand>-allocated = rv_remaining.
      ENDIF.
      rv_remaining = rv_remaining - <ls_demand>-allocated.
      <ls_demand>-shortage = <ls_demand>-requested - <ls_demand>-allocated.
      IF <ls_demand>-allocated = <ls_demand>-requested
          AND <ls_demand>-requested > 0.
        <ls_demand>-allocation_status = 'F'.
      ELSEIF <ls_demand>-allocated > 0.
        <ls_demand>-allocation_status = 'P'.
      ELSE.
        <ls_demand>-allocation_status = 'U'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
