CLASS zcl_alloc_prod_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cost
      IMPORTING
        iv_qty         TYPE i
        iv_unit_cost   TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prod_cost IMPLEMENTATION.

  METHOD cost.
    " The order cost is the quantity at its unit cost.
    rv_cost = iv_qty * iv_unit_cost.
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the order cost over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cost DIV iv_qty.
  ENDMETHOD.

  METHOD is_zero.
    " The order cost is nil at zero.
    rv_ok = xsdbool( iv_cost = 0 ).
  ENDMETHOD.

ENDCLASS.
