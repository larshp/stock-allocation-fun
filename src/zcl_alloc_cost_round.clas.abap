CLASS zcl_alloc_cost_round DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS round
      IMPORTING
        iv_value        TYPE i
        iv_nearest      TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS is_rounded
      IMPORTING
        iv_value     TYPE i
        iv_nearest   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS difference
      IMPORTING
        iv_value       TYPE i
        iv_rounded     TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cost_round IMPLEMENTATION.

  METHOD round.
    " The value is carried to the nearest multiple of the rounding step.
    IF iv_nearest <= 0.
      rv_value = iv_value.
      RETURN.
    ENDIF.

    rv_value = ( iv_value + iv_nearest DIV 2 ) DIV iv_nearest * iv_nearest.
  ENDMETHOD.

  METHOD is_rounded.
    " A value is already rounded while it divides by the step without a rest.
    IF iv_nearest <= 0.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_value MOD iv_nearest = 0 ).
  ENDMETHOD.

  METHOD difference.
    " The rounding difference is the gap the rounding introduced.
    rv_diff = iv_rounded - iv_value.
  ENDMETHOD.

ENDCLASS.
