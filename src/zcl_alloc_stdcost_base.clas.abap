CLASS zcl_alloc_stdcost_base DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS standard_cost
      IMPORTING
        iv_qty         TYPE i
        iv_unit_cost   TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_base IMPLEMENTATION.

  METHOD standard_cost.
    " The standard cost is the quantity at its unit cost.
    rv_cost = iv_qty * iv_unit_cost.
  ENDMETHOD.

  METHOD is_zero.
    " The standard cost is nil at zero.
    rv_ok = xsdbool( iv_cost = 0 ).
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the standard cost over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cost DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
