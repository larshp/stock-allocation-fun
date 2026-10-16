CLASS zcl_alloc_pallet_pattern DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS per_pallet
      IMPORTING
        iv_per_layer    TYPE i
        iv_layers       TYPE i
      RETURNING
        VALUE(rv_units) TYPE i.

    METHODS layers_for
      IMPORTING
        iv_quantity      TYPE i
        iv_per_layer     TYPE i
      RETURNING
        VALUE(rv_layers) TYPE i.

    METHODS pallets_for
      IMPORTING
        iv_quantity       TYPE i
        iv_per_layer      TYPE i
        iv_layers         TYPE i
      RETURNING
        VALUE(rv_pallets) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pallet_pattern IMPLEMENTATION.

  METHOD per_pallet.
    IF iv_per_layer <= 0 OR iv_layers <= 0.
      RETURN.
    ENDIF.

    rv_units = iv_per_layer * iv_layers.
  ENDMETHOD.

  METHOD layers_for.
    IF iv_quantity <= 0 OR iv_per_layer <= 0.
      RETURN.
    ENDIF.

    rv_layers = ( iv_quantity + iv_per_layer - 1 ) DIV iv_per_layer.
  ENDMETHOD.

  METHOD pallets_for.
    DATA lv_per_pallet TYPE i.

    lv_per_pallet = per_pallet( iv_per_layer = iv_per_layer
                                iv_layers    = iv_layers ).

    IF iv_quantity <= 0 OR lv_per_pallet <= 0.
      RETURN.
    ENDIF.

    rv_pallets = ( iv_quantity + lv_per_pallet - 1 ) DIV lv_per_pallet.
  ENDMETHOD.

ENDCLASS.
