CLASS zcl_alloc_layer_value DEFINITION
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
        iv_quantity     TYPE i
        iv_price        TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS layer_value
      IMPORTING
        it_layers       TYPE ty_layer_tt
        iv_index        TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS total_value
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_value IMPLEMENTATION.

  METHOD value.
    " A layer is worth its quantity at its price.
    rv_value = iv_quantity * iv_price.
  ENDMETHOD.

  METHOD layer_value.
    DATA ls_layer TYPE ty_layer.

    " The value of one layer is read by its position.
    IF iv_index < 1.
      RETURN.
    ENDIF.

    READ TABLE it_layers INTO ls_layer INDEX iv_index.
    IF sy-subrc = 0.
      rv_value = ls_layer-quantity * ls_layer-price.
    ENDIF.
  ENDMETHOD.

  METHOD total_value.
    DATA lv_value TYPE i.

    " The stock is worth the sum of its layers.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_value = ls_layer-quantity * ls_layer-price.
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
