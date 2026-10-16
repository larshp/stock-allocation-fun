CLASS zcl_alloc_val_std DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             quantity TYPE i,
             price    TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

    METHODS value
      IMPORTING
        iv_quantity       TYPE i
        iv_standard_price TYPE i
      RETURNING
        VALUE(rv_value)   TYPE i.

    METHODS unit_cost
      IMPORTING
        it_layers      TYPE ty_layer_tt
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS variance
      IMPORTING
        it_layers          TYPE ty_layer_tt
        iv_standard_price  TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_std IMPLEMENTATION.

  METHOD value.
    " Standard valuation prices the quantity at the standard cost.
    rv_value = iv_quantity * iv_standard_price.
  ENDMETHOD.

  METHOD unit_cost.
    DATA lv_value TYPE i.
    DATA lv_qty   TYPE i.

    " The actual average spreads the layer value over the quantity.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_value = lv_value + ls_layer-quantity * ls_layer-price.
      lv_qty = lv_qty + ls_layer-quantity.
    ENDLOOP.

    IF lv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = lv_value DIV lv_qty.
  ENDMETHOD.

  METHOD variance.
    DATA lv_actual   TYPE i.
    DATA lv_standard TYPE i.

    " The variance is the actual stock value less its standard value.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_actual = lv_actual + ls_layer-quantity * ls_layer-price.
      lv_standard = lv_standard + ls_layer-quantity * iv_standard_price.
    ENDLOOP.

    rv_variance = lv_actual - lv_standard.
  ENDMETHOD.

ENDCLASS.
