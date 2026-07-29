CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS allocate
      IMPORTING
        iv_available          TYPE zif_stock_allocation=>ty_quantity
        it_demands            TYPE zif_stock_allocation=>tt_demands
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    lv_remaining = iv_available.
    IF lv_remaining < 0.
      CLEAR lv_remaining.
    ENDIF.

    lt_demands = it_demands.
    DELETE lt_demands WHERE requested_qty <= 0.
    SORT lt_demands BY delivery_date ASCENDING
                       sales_order ASCENDING
                       sales_item ASCENDING
                       schedule_line ASCENDING.

    LOOP AT lt_demands INTO DATA(ls_demand).
      DATA(ls_allocation) = VALUE zif_stock_allocation=>ty_allocation(
        sales_order = ls_demand-sales_order
        sales_item = ls_demand-sales_item
        schedule_line = ls_demand-schedule_line
        delivery_date = ls_demand-delivery_date
        requested_qty = ls_demand-requested_qty ).

      IF lv_remaining >= ls_demand-requested_qty.
        ls_allocation-allocated_qty = ls_demand-requested_qty.
        ls_allocation-status = zif_stock_allocation=>c_status_full.
      ELSEIF lv_remaining > 0.
        ls_allocation-allocated_qty = lv_remaining.
        ls_allocation-status = zif_stock_allocation=>c_status_partial.
      ELSE.
        ls_allocation-status = zif_stock_allocation=>c_status_none.
      ENDIF.

      ls_allocation-shortage_qty = ls_allocation-requested_qty
                                 - ls_allocation-allocated_qty.
      lv_remaining = lv_remaining - ls_allocation-allocated_qty.
      APPEND ls_allocation TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
