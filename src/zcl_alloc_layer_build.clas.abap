CLASS zcl_alloc_layer_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             receipt_day TYPE d,
             quantity    TYPE i,
             price       TYPE i,
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

    METHODS layer_count
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_qty
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_build IMPLEMENTATION.

  METHOD layer_count.
    rv_count = lines( it_layers ).
  ENDMETHOD.

  METHOD total_qty.
    " The total is the sum of every layer's quantity.
    LOOP AT it_layers INTO DATA(ls_layer).
      rv_total = rv_total + ls_layer-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA lv_value TYPE i.

    " The summary counts the layers and totals their quantity and value.
    rs_summary-layer_count = layer_count( it_layers ).
    rs_summary-total_qty = total_qty( it_layers ).

    LOOP AT it_layers INTO DATA(ls_layer).
      lv_value = ls_layer-quantity * ls_layer-price.
      rs_summary-total_value = rs_summary-total_value + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
