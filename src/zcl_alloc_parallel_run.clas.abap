CLASS zcl_alloc_parallel_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             old_qty        TYPE menge_d,
             new_qty        TYPE menge_d,
             delta_qty      TYPE menge_d,
             within_tol     TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS compare
      IMPORTING
        it_old          TYPE zcl_stock_allocator=>ty_result_tt
        it_new          TYPE zcl_stock_allocator=>ty_result_tt
        iv_tolerance    TYPE menge_d
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS mismatch_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_parallel_run IMPLEMENTATION.

  METHOD compare.
    DATA ls_line  TYPE ty_line.
    DATA lv_found TYPE abap_bool.
    DATA lv_abs   TYPE menge_d.

    LOOP AT it_new INTO DATA(ls_new).
      READ TABLE it_old INTO DATA(ls_old)
        WITH KEY requirement_id = ls_new-requirement_id.
      IF sy-subrc = 0.
        lv_found = abap_true.
      ELSE.
        lv_found = abap_false.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_new-requirement_id.
      ls_line-new_qty = ls_new-allocated_qty.

      IF lv_found = abap_true.
        ls_line-old_qty = ls_old-allocated_qty.
      ENDIF.

      ls_line-delta_qty = ls_line-new_qty - ls_line-old_qty.

      lv_abs = ls_line-delta_qty.
      IF lv_abs < 0.
        lv_abs = 0 - lv_abs.
      ENDIF.

      IF lv_abs <= iv_tolerance.
        ls_line-within_tol = abap_true.
      ELSE.
        ls_line-within_tol = abap_false.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.

    LOOP AT it_old INTO DATA(ls_gone).
      READ TABLE it_new INTO DATA(ls_present)
        WITH KEY requirement_id = ls_gone-requirement_id.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_gone-requirement_id.
      ls_line-old_qty = ls_gone-allocated_qty.
      ls_line-delta_qty = 0 - ls_gone-allocated_qty.

      lv_abs = ls_line-delta_qty.
      IF lv_abs < 0.
        lv_abs = 0 - lv_abs.
      ENDIF.

      IF lv_abs <= iv_tolerance.
        ls_line-within_tol = abap_true.
      ELSE.
        ls_line-within_tol = abap_false.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD mismatch_count.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-within_tol = abap_false.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
