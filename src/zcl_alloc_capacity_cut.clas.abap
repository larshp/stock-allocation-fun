CLASS zcl_alloc_capacity_cut DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             capacity TYPE menge_d,
             max_line TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             lines        TYPE zcl_stock_allocator=>ty_result_tt,
             total_before TYPE menge_d,
             total_after  TYPE menge_d,
             reduced      TYPE abap_bool,
           END OF ty_result.

    METHODS apply
      IMPORTING
        is_input         TYPE ty_input
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS total_of
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_capacity_cut IMPLEMENTATION.

  METHOD apply.
    DATA ls_line  TYPE zcl_stock_allocator=>ty_result.
    DATA lv_ratio TYPE abap_bool.
    DATA lv_new   TYPE menge_d.

    rs_result-total_before = total_of( it_result ).

    IF is_input-capacity > 0
       AND rs_result-total_before > is_input-capacity.
      lv_ratio = abap_true.
    ENDIF.

    LOOP AT it_result INTO DATA(ls_base).
      ls_line = ls_base.
      lv_new = ls_base-allocated_qty.

      IF lv_ratio = abap_true.
        lv_new = lv_new * is_input-capacity DIV rs_result-total_before.
      ENDIF.

      IF is_input-max_line > 0 AND lv_new > is_input-max_line.
        lv_new = is_input-max_line.
      ENDIF.

      IF lv_new < 0.
        lv_new = 0.
      ENDIF.

      ls_line-allocated_qty = lv_new.
      APPEND ls_line TO rs_result-lines.
      rs_result-total_after = rs_result-total_after + lv_new.
    ENDLOOP.

    IF rs_result-total_after < rs_result-total_before.
      rs_result-reduced = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD total_of.
    LOOP AT it_result INTO DATA(ls_line).
      rv_total = rv_total + ls_line-allocated_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
