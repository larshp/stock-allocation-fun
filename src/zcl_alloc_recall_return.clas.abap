CLASS zcl_alloc_recall_return DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_lot,
             material TYPE matnr,
             batch    TYPE string,
             quantity TYPE i,
           END OF ty_lot.
    TYPES ty_lot_tt TYPE STANDARD TABLE OF ty_lot WITH DEFAULT KEY.

    TYPES ty_hit_tt TYPE STANDARD TABLE OF ty_lot WITH DEFAULT KEY.

    METHODS scope
      IMPORTING
        it_lots        TYPE ty_lot_tt
        iv_material    TYPE matnr
      RETURNING
        VALUE(rt_hits) TYPE ty_hit_tt.

    METHODS affected_quantity
      IMPORTING
        it_lots       TYPE ty_lot_tt
        iv_material   TYPE matnr
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS is_affected
      IMPORTING
        is_lot       TYPE ty_lot
        iv_material  TYPE matnr
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_recall_return IMPLEMENTATION.

  METHOD scope.
    " Every lot of the recalled material with stock on hand is in scope.
    LOOP AT it_lots INTO DATA(ls_lot).
      IF is_affected( is_lot      = ls_lot
                      iv_material = iv_material ) = abap_true.
        APPEND ls_lot TO rt_hits.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD affected_quantity.
    DATA lt_hits TYPE ty_hit_tt.

    lt_hits = scope( it_lots     = it_lots
                     iv_material = iv_material ).

    LOOP AT lt_hits INTO DATA(ls_hit).
      rv_qty = rv_qty + ls_hit-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_affected.
    rv_ok = xsdbool( is_lot-material = iv_material
                     AND is_lot-quantity > 0 ).
  ENDMETHOD.

ENDCLASS.
