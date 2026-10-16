CLASS zcl_alloc_fill_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_delivered   TYPE i
        iv_demanded    TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS rate_percent
      IMPORTING
        iv_delivered      TYPE i
        iv_demanded       TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_met
      IMPORTING
        iv_rate_percent TYPE i
        iv_target       TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_fill_rate IMPLEMENTATION.

  METHOD rate.
    " The rate is the delivered share of the demand in per mille.
    IF iv_demanded <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_delivered * 1000 DIV iv_demanded.
  ENDMETHOD.

  METHOD rate_percent.
    " The percentage rate is the delivered share of the demand.
    IF iv_demanded <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_delivered * 100 DIV iv_demanded.
  ENDMETHOD.

  METHOD is_met.
    " The fill rate is met once it reaches the target.
    rv_ok = xsdbool( iv_rate_percent >= iv_target ).
  ENDMETHOD.

ENDCLASS.
