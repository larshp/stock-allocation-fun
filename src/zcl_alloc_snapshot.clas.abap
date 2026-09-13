CLASS zcl_alloc_snapshot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             allocated_qty  TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_snapshot,
             lines TYPE ty_line_tt,
           END OF ty_snapshot.

    TYPES: BEGIN OF ty_diff,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             before_qty     TYPE menge_d,
             after_qty      TYPE menge_d,
             delta_qty      TYPE menge_d,
           END OF ty_diff.
    TYPES ty_diff_tt TYPE STANDARD TABLE OF ty_diff WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             before TYPE ty_snapshot,
             after  TYPE zcl_stock_allocator=>ty_result_tt,
           END OF ty_input.

    METHODS take
      IMPORTING
        it_result          TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_snapshot) TYPE ty_snapshot.

    METHODS compare
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_diff_tt.

ENDCLASS.


CLASS zcl_alloc_snapshot IMPLEMENTATION.

  METHOD take.
    LOOP AT it_result INTO DATA(ls_result).
      APPEND VALUE #( requirement_id = ls_result-requirement_id
                      allocated_qty  = ls_result-allocated_qty )
        TO rs_snapshot-lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD compare.
    DATA ls_line      TYPE ty_diff.
    DATA lv_before    TYPE menge_d.

    LOOP AT is_input-after INTO DATA(ls_after).
      READ TABLE is_input-before-lines INTO DATA(ls_before)
        WITH KEY requirement_id = ls_after-requirement_id.
      IF sy-subrc = 0.
        lv_before = ls_before-allocated_qty.
      ELSE.
        lv_before = 0.
      ENDIF.

      IF lv_before = ls_after-allocated_qty.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_after-requirement_id.
      ls_line-before_qty = lv_before.
      ls_line-after_qty = ls_after-allocated_qty.
      ls_line-delta_qty = ls_after-allocated_qty - lv_before.
      APPEND ls_line TO rt_lines.
    ENDLOOP.

    LOOP AT is_input-before-lines INTO DATA(ls_gone).
      READ TABLE is_input-after INTO DATA(ls_present)
        WITH KEY requirement_id = ls_gone-requirement_id.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_gone-requirement_id.
      ls_line-before_qty = ls_gone-allocated_qty.
      ls_line-after_qty = 0.
      ls_line-delta_qty = 0 - ls_gone-allocated_qty.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
