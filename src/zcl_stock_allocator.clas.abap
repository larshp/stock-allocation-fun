CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD zif_stock_allocation~allocate.
    DATA lt_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    IF iv_available < 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    LOOP AT ct_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_id IS INITIAL OR <ls_demand>-requested < 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
      INSERT <ls_demand>-order_id INTO TABLE lt_order_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
    ENDLOOP.

    SORT ct_demands BY priority DESCENDING requested_on ASCENDING order_id ASCENDING.
    rv_remaining = iv_available.
    LOOP AT ct_demands ASSIGNING <ls_demand>.
      CLEAR: <ls_demand>-allocated, <ls_demand>-shortage.
      IF <ls_demand>-requested <= rv_remaining.
        <ls_demand>-allocated = <ls_demand>-requested.
      ELSE.
        <ls_demand>-allocated = rv_remaining.
      ENDIF.
      rv_remaining = rv_remaining - <ls_demand>-allocated.
      <ls_demand>-shortage = <ls_demand>-requested - <ls_demand>-allocated.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
