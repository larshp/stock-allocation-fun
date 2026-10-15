CLASS zcl_alloc_truck_lot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS lots
      IMPORTING
        iv_quantity    TYPE i
        iv_lot_size    TYPE i
      RETURNING
        VALUE(rv_lots) TYPE i.

    METHODS fill_percent
      IMPORTING
        iv_quantity       TYPE i
        iv_lot_size       TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_efficient
      IMPORTING
        iv_fill_percent TYPE i
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_truck_lot IMPLEMENTATION.

  METHOD lots.
    " The quantity fills whole transport lots, the last one possibly partial.
    IF iv_lot_size <= 0.
      RETURN.
    ENDIF.

    rv_lots = ( iv_quantity + iv_lot_size - 1 ) DIV iv_lot_size.
  ENDMETHOD.

  METHOD fill_percent.
    DATA lv_capacity TYPE i.
    DATA lv_lots TYPE i.

    " The fill relates the quantity to the capacity of the lots it needs.
    IF iv_lot_size <= 0.
      RETURN.
    ENDIF.

    lv_lots = lots( iv_quantity = iv_quantity iv_lot_size = iv_lot_size ).
    lv_capacity = lv_lots * iv_lot_size.
    IF lv_capacity <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_quantity * 100 DIV lv_capacity.
  ENDMETHOD.

  METHOD is_efficient.
    " A transport is efficient once its fill reaches the threshold.
    rv_ok = xsdbool( iv_fill_percent >= iv_threshold ).
  ENDMETHOD.

ENDCLASS.
