CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_allocation.

ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.

  METHOD zif_stock_allocation~allocate.
* Allocate available stock to demands in order, until stock runs out.
    DATA lv_remaining TYPE labst.
    DATA ls_alloc     LIKE LINE OF rt_alloc.

    lv_remaining = iv_available.

    LOOP AT it_demand INTO DATA(ls_demand).
      IF lv_remaining <= 0.
        EXIT.
      ENDIF.

      ls_alloc-material = ls_demand-material.
      ls_alloc-plant    = ls_demand-plant.
      IF ls_demand-quantity <= lv_remaining.
        ls_alloc-quantity = ls_demand-quantity.
        lv_remaining = lv_remaining - ls_demand-quantity.
      ELSE.
        ls_alloc-quantity = lv_remaining.
        lv_remaining = 0.
      ENDIF.
      APPEND ls_alloc TO rt_alloc.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.