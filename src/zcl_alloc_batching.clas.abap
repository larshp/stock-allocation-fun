CLASS zcl_alloc_batching DEFINITION
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

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_batching IMPLEMENTATION.

  METHOD build.
    DATA ls_line TYPE ty_line.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_line-batch = 0 OR ls_line-matnr <> ls_item-matnr.
        IF ls_line-batch > 0.
          APPEND ls_line TO rt_lines.
        ENDIF.
        CLEAR ls_line.
        ls_line-batch = lines( rt_lines ) + 1.
        ls_line-matnr = ls_item-matnr.
      ENDIF.

      ls_line-quantity = ls_line-quantity + ls_item-quantity.
    ENDLOOP.

    IF ls_line-batch > 0.
      APPEND ls_line TO rt_lines.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
