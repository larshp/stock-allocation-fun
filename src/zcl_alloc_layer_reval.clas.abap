CLASS zcl_alloc_layer_reval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             quantity TYPE i,
             price    TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

    METHODS revalue
      IMPORTING
        it_layers        TYPE ty_layer_tt
        iv_new_price     TYPE i
      RETURNING
        VALUE(rt_layers) TYPE ty_layer_tt.

    METHODS delta_value
      IMPORTING
        it_layers       TYPE ty_layer_tt
        iv_new_price    TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

    METHODS is_up
      IMPORTING
        it_layers    TYPE ty_layer_tt
        iv_new_price TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_layer_reval IMPLEMENTATION.

  METHOD revalue.
    DATA ls_out TYPE ty_layer.

    " Every layer is carried over at the new price.
    LOOP AT it_layers INTO DATA(ls_layer).
      ls_out = ls_layer.
      ls_out-price = iv_new_price.
      APPEND ls_out TO rt_layers.
    ENDLOOP.
  ENDMETHOD.

  METHOD delta_value.
    DATA lv_old TYPE i.
    DATA lv_new TYPE i.

    " The revaluation gain is the new value less the old value.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_old = lv_old + ls_layer-quantity * ls_layer-price.
      lv_new = lv_new + ls_layer-quantity * iv_new_price.
    ENDLOOP.

    rv_delta = lv_new - lv_old.
  ENDMETHOD.

  METHOD is_up.
    DATA lv_delta TYPE i.

    " The stock is written up once the new value is the higher one.
    lv_delta = delta_value( it_layers = it_layers iv_new_price = iv_new_price ).
    rv_ok = xsdbool( lv_delta > 0 ).
  ENDMETHOD.

ENDCLASS.
