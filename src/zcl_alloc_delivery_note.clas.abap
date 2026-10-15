CLASS zcl_alloc_delivery_note DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE string,
             quantity TYPE i,
             uom      TYPE string,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        iv_delivery_no  TYPE string
        iv_customer     TYPE string
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_text_tt.

ENDCLASS.


CLASS zcl_alloc_delivery_note IMPLEMENTATION.

  METHOD build.
    DATA lv_line TYPE string.

    " Every value is already text, and the quantity goes through a string
    " template so it is formatted rather than kept as a number.
    lv_line = |Delivery: { iv_delivery_no }|.
    APPEND lv_line TO rt_lines.

    lv_line = |Customer: { iv_customer }|.
    APPEND lv_line TO rt_lines.

    LOOP AT it_items INTO DATA(ls_item).
      lv_line = |  { ls_item-material } { ls_item-quantity } { ls_item-uom }|.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
