CLASS zcl_alloc_rout_eff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS efficiency_percent
      IMPORTING
        iv_standard       TYPE i
        iv_actual         TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_efficient
      IMPORTING
        iv_standard  TYPE i
        iv_actual    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS variance
      IMPORTING
        iv_actual          TYPE i
        iv_standard        TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_eff IMPLEMENTATION.

  METHOD efficiency_percent.
    " Efficiency is the standard time against the time actually taken.
    IF iv_actual = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_standard * 100 DIV iv_actual.
  ENDMETHOD.

  METHOD is_efficient.
    " The operation is efficient while it stays within the standard time.
    rv_ok = xsdbool( iv_standard >= iv_actual ).
  ENDMETHOD.

  METHOD variance.
    " A positive variance is time taken above the standard.
    rv_variance = iv_actual - iv_standard.
  ENDMETHOD.

ENDCLASS.
