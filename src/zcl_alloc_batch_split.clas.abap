CLASS zcl_alloc_batch_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             batch    TYPE i,
             matnr    TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             items     TYPE ty_item_tt,
             max_batch TYPE menge_d,
           END OF ty_input.

    METHODS split
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_batch_split IMPLEMENTATION.

  METHOD split.
    DATA ls_line    TYPE ty_line.
    DATA lv_batch   TYPE i.
    DATA lv_current TYPE menge_d.

    lv_batch = 1.

    LOOP AT is_input-items INTO DATA(ls_item).
      IF is_input-max_batch > 0
          AND lv_current > 0
          AND lv_current + ls_item-quantity > is_input-max_batch.
        lv_batch = lv_batch + 1.
        CLEAR lv_current.
      ENDIF.

      CLEAR ls_line.
      ls_line-batch = lv_batch.
      ls_line-matnr = ls_item-matnr.
      ls_line-quantity = ls_item-quantity.
      APPEND ls_line TO rt_lines.

      lv_current = lv_current + ls_item-quantity.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
