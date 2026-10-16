CLASS zcl_alloc_uplift DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             uplift_pct TYPE i,
             uplift_abs TYPE menge_d,
           END OF ty_input.

    METHODS apply
      IMPORTING
        is_input         TYPE ty_input
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS total_of
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_uplift IMPLEMENTATION.

  METHOD apply.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.
    DATA lv_new    TYPE menge_d.

    LOOP AT it_result INTO DATA(ls_base).
      ls_result = ls_base.

      lv_new = ls_base-allocated_qty * ( 100 + is_input-uplift_pct ) DIV 100.
      lv_new = lv_new + is_input-uplift_abs.

      IF lv_new < 0.
        lv_new = 0.
      ENDIF.

      ls_result-allocated_qty = lv_new.
      APPEND ls_result TO rt_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_of.
    LOOP AT it_result INTO DATA(ls_line).
      rv_total = rv_total + ls_line-allocated_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
