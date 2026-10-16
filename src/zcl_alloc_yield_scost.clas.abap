CLASS zcl_alloc_yield_scost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS scrap_cost
      IMPORTING
        iv_scrap_qty   TYPE i
        iv_unit_cost   TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_costly
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_scost IMPLEMENTATION.

  METHOD scrap_cost.
    " The scrap cost is the scrapped quantity at its unit cost.
    rv_cost = iv_scrap_qty * iv_unit_cost.
  ENDMETHOD.

  METHOD is_costly.
    " The scrap is costly once it passes the limit.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the scrap cost over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cost DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
