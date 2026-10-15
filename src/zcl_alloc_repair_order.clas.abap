CLASS zcl_alloc_repair_order DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             line_no  TYPE i,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_repair_order IMPLEMENTATION.

  METHOD build.
    DATA ls_line TYPE ty_line.
    DATA lv_no   TYPE i.

    " The kept lines are renumbered from one, so a skipped item never leaves a
    " gap in the repair order.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      lv_no = lv_no + 1.
      ls_line-line_no = lv_no.
      ls_line-material = ls_item-material.
      ls_line-quantity = ls_item-quantity.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
