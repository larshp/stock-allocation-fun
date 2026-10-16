CLASS zcl_alloc_avg_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             quantity TYPE menge_d,
             price    TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS calculate
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_price) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_avg_price IMPLEMENTATION.

  METHOD calculate.
    DATA lv_value TYPE menge_d.
    DATA lv_qty   TYPE menge_d.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_value = lv_value + ls_item-quantity * ls_item-price.
      lv_qty = lv_qty + ls_item-quantity.
    ENDLOOP.

    IF lv_qty > 0.
      rv_price = lv_value / lv_qty.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
