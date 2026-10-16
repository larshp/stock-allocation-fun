CLASS zcl_alloc_snap_heavy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             allocated_qty  TYPE menge_d,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             previous_qty   TYPE menge_d,
             current_qty    TYPE menge_d,
             delta_qty      TYPE menge_d,
             changed        TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS take
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_entry_tt.

    METHODS compare
      IMPORTING
        it_before       TYPE ty_entry_tt
        it_after        TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_snap_heavy IMPLEMENTATION.

  METHOD take.
    LOOP AT it_result INTO DATA(ls_result).
      APPEND VALUE #( requirement_id = ls_result-requirement_id
                      allocated_qty  = ls_result-allocated_qty )
        TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD compare.
    DATA ls_line  TYPE ty_line.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_after INTO DATA(ls_after).
      READ TABLE it_before INTO DATA(ls_before)
        WITH KEY requirement_id = ls_after-requirement_id.
      IF sy-subrc = 0.
        lv_found = abap_true.
      ELSE.
        lv_found = abap_false.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_after-requirement_id.
      ls_line-current_qty = ls_after-allocated_qty.

      IF lv_found = abap_true.
        ls_line-previous_qty = ls_before-allocated_qty.
      ENDIF.

      ls_line-delta_qty = ls_line-current_qty - ls_line-previous_qty.

      IF ls_line-delta_qty = 0.
        ls_line-changed = abap_false.
      ELSE.
        ls_line-changed = abap_true.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.

    LOOP AT it_before INTO DATA(ls_gone).
      READ TABLE it_after INTO DATA(ls_present)
        WITH KEY requirement_id = ls_gone-requirement_id.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_gone-requirement_id.
      ls_line-previous_qty = ls_gone-allocated_qty.
      ls_line-delta_qty = 0 - ls_gone-allocated_qty.

      IF ls_gone-allocated_qty = 0.
        ls_line-changed = abap_false.
      ELSE.
        ls_line-changed = abap_true.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
