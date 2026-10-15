CLASS zcl_alloc_val_wavg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             quantity TYPE i,
             price    TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

    METHODS unit_cost
      IMPORTING
        it_layers      TYPE ty_layer_tt
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS value
      IMPORTING
        it_layers       TYPE ty_layer_tt
        iv_quantity     TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS is_zero
      IMPORTING
        it_layers    TYPE ty_layer_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_val_wavg IMPLEMENTATION.

  METHOD unit_cost.
    DATA lv_value TYPE i.
    DATA lv_qty   TYPE i.

    " The weighted average spreads the stock value over its quantity.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_value = lv_value + ls_layer-quantity * ls_layer-price.
      lv_qty = lv_qty + ls_layer-quantity.
    ENDLOOP.

    IF lv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = lv_value DIV lv_qty.
  ENDMETHOD.

  METHOD value.
    DATA lv_unit TYPE i.

    " The value of a quantity is that quantity at the weighted average cost.
    lv_unit = unit_cost( it_layers ).
    rv_value = lv_unit * iv_quantity.
  ENDMETHOD.

  METHOD is_zero.
    DATA lv_unit TYPE i.

    " Stock valued at a zero average carries no value.
    lv_unit = unit_cost( it_layers ).
    rv_ok = xsdbool( lv_unit = 0 ).
  ENDMETHOD.

ENDCLASS.
