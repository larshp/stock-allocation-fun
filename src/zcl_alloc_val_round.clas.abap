CLASS zcl_alloc_val_round DEFINITION
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

    METHODS nearest
      IMPORTING
        iv_value          TYPE i
        iv_nearest        TYPE i
      RETURNING
        VALUE(rv_nearest) TYPE i.

    METHODS difference
      IMPORTING
        iv_value       TYPE i
        iv_nearest     TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_round IMPLEMENTATION.

  METHOD round.
    " The value is carried to the nearest multiple of the rounding step.
    IF iv_nearest <= 0.
      rv_value = iv_value.
      RETURN.
    ENDIF.

    rv_value = ( iv_value + iv_nearest DIV 2 ) DIV iv_nearest * iv_nearest.
  ENDMETHOD.

  METHOD nearest.
    " The valuation is carried up to the next multiple of the step.
    IF iv_nearest <= 0.
      rv_nearest = iv_value.
      RETURN.
    ENDIF.

    rv_nearest = ( iv_value + iv_nearest - 1 ) DIV iv_nearest * iv_nearest.
  ENDMETHOD.

  METHOD difference.
    DATA lv_nearest TYPE i.

    " The difference is the gap up to the next multiple.
    lv_nearest = nearest( iv_value = iv_value iv_nearest = iv_nearest ).
    rv_diff = lv_nearest - iv_value.
  ENDMETHOD.

ENDCLASS.
