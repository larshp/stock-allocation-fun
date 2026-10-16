CLASS zcl_alloc_stdcost_var DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_standard        TYPE i
        iv_actual          TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_over
      IMPORTING
        iv_actual    TYPE i
        iv_standard  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_variance       TYPE i
        iv_standard       TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_var IMPLEMENTATION.

  METHOD variance.
    " A positive variance is cost above the standard.
    rv_variance = iv_actual - iv_standard.
  ENDMETHOD.

  METHOD is_over.
    " The cost is over once the actual passes the standard.
    rv_ok = xsdbool( iv_actual > iv_standard ).
  ENDMETHOD.

  METHOD percent.
    " The variance as a share of the standard cost.
    IF iv_standard = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_variance * 100 DIV iv_standard.
  ENDMETHOD.

ENDCLASS.
