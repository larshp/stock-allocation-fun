CLASS zcl_alloc_act_efficiency DEFINITION
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
        iv_standard        TYPE i
        iv_actual          TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_act_efficiency IMPLEMENTATION.

  METHOD efficiency_percent.
    " Efficiency is the standard quantity as a share of the actual one.
    IF iv_actual <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_standard * 100 DIV iv_actual.
  ENDMETHOD.

  METHOD is_efficient.
    " The activity is efficient once it stays within the standard.
    rv_ok = xsdbool( iv_actual <= iv_standard ).
  ENDMETHOD.

  METHOD variance.
    " A positive variance is quantity saved, a negative one is overspent.
    rv_variance = iv_standard - iv_actual.
  ENDMETHOD.

ENDCLASS.
