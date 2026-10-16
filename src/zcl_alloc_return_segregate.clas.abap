CLASS zcl_alloc_return_segregate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
             sellable TYPE abap_bool,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS separate
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_sellable     TYPE abap_bool
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS blocked
      IMPORTING
        it_items      TYPE ty_item_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS sellable
      IMPORTING
        it_items      TYPE ty_item_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_segregate IMPLEMENTATION.

  METHOD separate.
    " The stock is split into the sellable and the blocked part by the flag.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0 OR ls_item-sellable <> iv_sellable.
        CONTINUE.
      ENDIF.

      APPEND ls_item TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD blocked.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity > 0 AND ls_item-sellable = abap_false.
        rv_qty = rv_qty + ls_item-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sellable.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity > 0 AND ls_item-sellable = abap_true.
        rv_qty = rv_qty + ls_item-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
