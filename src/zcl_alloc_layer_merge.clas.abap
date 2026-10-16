CLASS zcl_alloc_layer_merge DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             quantity TYPE i,
             price    TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

    METHODS merge
      IMPORTING
        it_layers        TYPE ty_layer_tt
      RETURNING
        VALUE(rt_layers) TYPE ty_layer_tt.

    METHODS group_count
      IMPORTING
        it_layers       TYPE ty_layer_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS largest
      IMPORTING
        it_layers     TYPE ty_layer_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_group,
             price    TYPE i,
             quantity TYPE i,
           END OF ty_group.

ENDCLASS.


CLASS zcl_alloc_layer_merge IMPLEMENTATION.

  METHOD merge.
    DATA lt_group TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY price.
    DATA ls_new   TYPE ty_group.
    DATA ls_group TYPE ty_group.
    DATA ls_out   TYPE ty_layer.

    " Layers of the same price are merged into one, keyed by the price.
    LOOP AT it_layers INTO DATA(ls_layer).
      READ TABLE lt_group ASSIGNING FIELD-SYMBOL(<ls_group>)
        WITH KEY price = ls_layer-price.
      IF sy-subrc = 0.
        <ls_group>-quantity = <ls_group>-quantity + ls_layer-quantity.
      ELSE.
        CLEAR ls_new.
        ls_new-price = ls_layer-price.
        ls_new-quantity = ls_layer-quantity.
        INSERT ls_new INTO TABLE lt_group.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_group INTO ls_group.
      ls_out-price = ls_group-price.
      ls_out-quantity = ls_group-quantity.
      APPEND ls_out TO rt_layers.
    ENDLOOP.
  ENDMETHOD.

  METHOD group_count.
    DATA lt_merged TYPE ty_layer_tt.

    " The groups are the distinct prices that remain after merging.
    lt_merged = merge( it_layers ).
    rv_count = lines( lt_merged ).
  ENDMETHOD.

  METHOD largest.
    DATA lt_merged TYPE ty_layer_tt.

    " The largest group carries the biggest quantity.
    lt_merged = merge( it_layers ).

    LOOP AT lt_merged INTO DATA(ls_layer).
      IF ls_layer-quantity > rv_qty.
        rv_qty = ls_layer-quantity.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
