CLASS zcl_alloc_turnover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS turns
      IMPORTING
        iv_annual_demand TYPE i
        iv_average_stock TYPE i
      RETURNING
        VALUE(rv_turns)  TYPE i.

    METHODS days_of_supply
      IMPORTING
        iv_average_stock TYPE i
        iv_annual_demand TYPE i
      RETURNING
        VALUE(rv_days)   TYPE i.

    METHODS is_healthy
      IMPORTING
        iv_turns     TYPE i
        iv_min_turns TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_turnover IMPLEMENTATION.

  METHOD turns.
    " The turnover spreads the annual demand over the average stock.
    IF iv_average_stock <= 0.
      RETURN.
    ENDIF.

    rv_turns = iv_annual_demand DIV iv_average_stock.
  ENDMETHOD.

  METHOD days_of_supply.
    " The days of supply spread the average stock over a year of demand.
    IF iv_annual_demand <= 0.
      RETURN.
    ENDIF.

    rv_days = iv_average_stock * 365 DIV iv_annual_demand.
  ENDMETHOD.

  METHOD is_healthy.
    " The turnover is healthy once it reaches the minimum.
    rv_ok = xsdbool( iv_turns >= iv_min_turns ).
  ENDMETHOD.

ENDCLASS.
