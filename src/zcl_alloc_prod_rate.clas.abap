CLASS zcl_alloc_prod_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_cost        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS applied
      IMPORTING
        iv_rate        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_rate      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prod_rate IMPLEMENTATION.

  METHOD rate.
    " The rate spreads the cost over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_cost DIV iv_qty.
  ENDMETHOD.

  METHOD applied.
    " The applied cost is the rate at its quantity.
    rv_cost = iv_rate * iv_qty.
  ENDMETHOD.

  METHOD is_zero.
    " A rate at zero carries no cost.
    rv_ok = xsdbool( iv_rate = 0 ).
  ENDMETHOD.

ENDCLASS.
