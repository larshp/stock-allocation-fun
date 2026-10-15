CLASS zcl_alloc_disposal_lot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_lot,
             lot      TYPE string,
             quantity TYPE i,
           END OF ty_lot.
    TYPES ty_lot_tt TYPE STANDARD TABLE OF ty_lot WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        it_lots        TYPE ty_lot_tt
        iv_lot         TYPE string
        iv_quantity    TYPE i
      RETURNING
        VALUE(rt_lots) TYPE ty_lot_tt.

    METHODS total
      IMPORTING
        it_lots       TYPE ty_lot_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS lot_count
      IMPORTING
        it_lots         TYPE ty_lot_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_disposal_lot IMPLEMENTATION.

  METHOD add.
    DATA ls_lot TYPE ty_lot.

    " A named lot with a real quantity joins the disposal set; anything else
    " leaves it unchanged.
    rt_lots = it_lots.

    IF iv_lot IS INITIAL OR iv_quantity <= 0.
      RETURN.
    ENDIF.

    ls_lot-lot = iv_lot.
    ls_lot-quantity = iv_quantity.
    APPEND ls_lot TO rt_lots.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_lots INTO DATA(ls_lot).
      rv_qty = rv_qty + ls_lot-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD lot_count.
    rv_count = lines( it_lots ).
  ENDMETHOD.

ENDCLASS.
