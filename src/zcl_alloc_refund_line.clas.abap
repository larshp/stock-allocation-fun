CLASS zcl_alloc_refund_line DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material   TYPE matnr,
             quantity   TYPE i,
             unit_price TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             line_no  TYPE i,
             material TYPE matnr,
             quantity TYPE i,
             value    TYPE i,
             running  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_refund_line IMPLEMENTATION.

  METHOD build.
    DATA ls_line    TYPE ty_line.
    DATA lv_no      TYPE i.
    DATA lv_running TYPE i.

    " Each kept line carries its value and the refund accumulated so far, so a
    " caller can show a running refund without summing again.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0 OR ls_item-unit_price <= 0.
        CONTINUE.
      ENDIF.

      lv_no = lv_no + 1.

      CLEAR ls_line.
      ls_line-line_no = lv_no.
      ls_line-material = ls_item-material.
      ls_line-quantity = ls_item-quantity.
      ls_line-value = ls_item-quantity * ls_item-unit_price.

      lv_running = lv_running + ls_line-value.
      ls_line-running = lv_running.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total.
    " The last line carries the whole running refund.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = ls_line-running.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
