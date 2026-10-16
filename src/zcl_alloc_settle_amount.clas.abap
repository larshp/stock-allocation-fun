CLASS zcl_alloc_settle_amount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS amount
      IMPORTING
        iv_qty           TYPE i
        iv_unit_cost     TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_amount    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS per_unit
      IMPORTING
        iv_amount      TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_settle_amount IMPLEMENTATION.

  METHOD amount.
    " The settlement amount is the quantity at its unit cost.
    rv_amount = iv_qty * iv_unit_cost.
  ENDMETHOD.

  METHOD is_zero.
    " The settlement amount is nil at zero.
    rv_ok = xsdbool( iv_amount = 0 ).
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the settlement amount over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_amount DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
