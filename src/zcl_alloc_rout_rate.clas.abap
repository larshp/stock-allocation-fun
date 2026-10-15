CLASS zcl_alloc_rout_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_cost        TYPE i
        iv_time        TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS from_cost
      IMPORTING
        iv_rate        TYPE i
        iv_time        TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_rate      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_rout_rate IMPLEMENTATION.

  METHOD rate.
    " The operation rate spreads the cost over the time it takes.
    IF iv_time <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_cost DIV iv_time.
  ENDMETHOD.

  METHOD from_cost.
    " The rate over the time gives back the cost.
    rv_cost = iv_rate * iv_time.
  ENDMETHOD.

  METHOD is_zero.
    " A rate at zero carries no cost.
    rv_ok = xsdbool( iv_rate = 0 ).
  ENDMETHOD.

ENDCLASS.
