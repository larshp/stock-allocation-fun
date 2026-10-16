CLASS zcl_alloc_margin_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_margin      TYPE i
        iv_revenue     TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS price
      IMPORTING
        iv_cost         TYPE i
        iv_rate_percent TYPE i
      RETURNING
        VALUE(rv_price) TYPE i.

    METHODS is_healthy
      IMPORTING
        iv_rate      TYPE i
        iv_min_rate  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_margin_rate IMPLEMENTATION.

  METHOD rate.
    " The margin rate is the margin related to the revenue.
    IF iv_revenue = 0.
      RETURN.
    ENDIF.

    rv_rate = iv_margin * 100 DIV iv_revenue.
  ENDMETHOD.

  METHOD price.
    " A margin rate is a share of the price, so the cost fills the rest.
    IF iv_rate_percent >= 100.
      RETURN.
    ENDIF.

    rv_price = iv_cost * 100 DIV ( 100 - iv_rate_percent ).
  ENDMETHOD.

  METHOD is_healthy.
    " A rate at or above the minimum is a healthy margin.
    rv_ok = xsdbool( iv_rate >= iv_min_rate ).
  ENDMETHOD.

ENDCLASS.
