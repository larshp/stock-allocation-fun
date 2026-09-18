CLASS zcl_alloc_lot_fixed DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS lots_of
      IMPORTING
        iv_requirement TYPE menge_d
        iv_lot_size    TYPE menge_d
      RETURNING
        VALUE(rv_lots) TYPE i.

    METHODS size
      IMPORTING
        iv_requirement TYPE menge_d
        iv_lot_size    TYPE menge_d
      RETURNING
        VALUE(rv_lot)  TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_lot_fixed IMPLEMENTATION.

  METHOD lots_of.
    IF iv_requirement <= 0 OR iv_lot_size <= 0.
      RETURN.
    ENDIF.

    rv_lots = iv_requirement DIV iv_lot_size.
    IF iv_requirement MOD iv_lot_size > 0.
      rv_lots = rv_lots + 1.
    ENDIF.
  ENDMETHOD.

  METHOD size.
    DATA lv_lots TYPE i.

    IF iv_requirement <= 0.
      RETURN.
    ENDIF.

    IF iv_lot_size <= 0.
      rv_lot = iv_requirement.
      RETURN.
    ENDIF.

    lv_lots = lots_of( iv_requirement = iv_requirement
                       iv_lot_size    = iv_lot_size ).
    rv_lot = lv_lots * iv_lot_size.
  ENDMETHOD.

ENDCLASS.
