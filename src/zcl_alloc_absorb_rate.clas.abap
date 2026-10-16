CLASS zcl_alloc_absorb_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_overhead    TYPE i
        iv_base        TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS overhead
      IMPORTING
        iv_rate            TYPE i
        iv_base            TYPE i
      RETURNING
        VALUE(rv_overhead) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_rate      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_absorb_rate IMPLEMENTATION.

  METHOD rate.
    " The absorption rate spreads the overhead over the base.
    IF iv_base <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_overhead DIV iv_base.
  ENDMETHOD.

  METHOD overhead.
    " The rate over the base gives back the absorbed overhead.
    rv_overhead = iv_rate * iv_base.
  ENDMETHOD.

  METHOD is_zero.
    " A rate at zero absorbs no overhead.
    rv_ok = xsdbool( iv_rate = 0 ).
  ENDMETHOD.

ENDCLASS.
