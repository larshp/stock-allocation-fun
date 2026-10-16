CLASS zcl_alloc_reconcile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             item_key TYPE string,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             item_key  TYPE string,
             left_qty  TYPE menge_d,
             right_qty TYPE menge_d,
             delta_qty TYPE menge_d,
             status    TYPE string,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS compare
      IMPORTING
        it_left         TYPE ty_item_tt
        it_right        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_balanced
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rv_balanced) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_reconcile IMPLEMENTATION.

  METHOD compare.
    DATA ls_line  TYPE ty_line.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_left INTO DATA(ls_left).
      READ TABLE it_right INTO DATA(ls_right)
        WITH KEY item_key = ls_left-item_key.
      IF sy-subrc = 0.
        lv_found = abap_true.
      ELSE.
        lv_found = abap_false.
      ENDIF.

      CLEAR ls_line.
      ls_line-item_key = ls_left-item_key.
      ls_line-left_qty = ls_left-quantity.

      IF lv_found = abap_true.
        ls_line-right_qty = ls_right-quantity.
        ls_line-delta_qty = ls_left-quantity - ls_right-quantity.
        IF ls_line-delta_qty = 0.
          ls_line-status = 'matched'.
        ELSE.
          ls_line-status = 'differs'.
        ENDIF.
      ELSE.
        ls_line-delta_qty = ls_left-quantity.
        ls_line-status = 'missing'.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.

    LOOP AT it_right INTO DATA(ls_extra).
      READ TABLE it_left INTO DATA(ls_known)
        WITH KEY item_key = ls_extra-item_key.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-item_key = ls_extra-item_key.
      ls_line-right_qty = ls_extra-quantity.
      ls_line-delta_qty = 0 - ls_extra-quantity.
      ls_line-status = 'extra'.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_balanced.
    rv_balanced = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-status <> 'matched'.
        rv_balanced = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
