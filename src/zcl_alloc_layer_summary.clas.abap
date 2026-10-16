CLASS zcl_alloc_layer_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             price    TYPE i,
             quantity TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             layer_count TYPE i,
             total_qty   TYPE i,
             total_value TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_layers         TYPE ty_layer_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS total_qty
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS total_value
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_summary IMPLEMENTATION.

  METHOD total_qty.
    " The quantity is the sum of every layer.
    LOOP AT it_layers INTO DATA(ls_layer).
      rv_total = rv_total + ls_layer-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_value.
    DATA lv_value TYPE i.

    " The value is the sum of every layer at its own price.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_value = ls_layer-quantity * ls_layer-price.
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary carries the layer count, the quantity and the value.
    rs_summary-layer_count = lines( it_layers ).
    rs_summary-total_qty = total_qty( it_layers ).
    rs_summary-total_value = total_value( it_layers ).
  ENDMETHOD.

ENDCLASS.
