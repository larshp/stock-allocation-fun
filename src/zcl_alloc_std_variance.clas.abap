CLASS zcl_alloc_std_variance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_actual          TYPE i
        iv_standard        TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_favourable
      IMPORTING
        iv_actual    TYPE i
        iv_standard  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_actual         TYPE i
        iv_standard       TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_std_variance IMPLEMENTATION.

  METHOD variance.
    " The variance is the gap between the actual and the standard cost.
    rv_variance = iv_actual - iv_standard.
  ENDMETHOD.

  METHOD is_favourable.
    " Spending at or below the standard cost is favourable.
    rv_ok = xsdbool( iv_actual <= iv_standard ).
  ENDMETHOD.

  METHOD percent.
    " The gap is related to the standard cost it was measured against.
    IF iv_standard = 0.
      RETURN.
    ENDIF.

    rv_percent = ( iv_actual - iv_standard ) * 100 DIV iv_standard.
  ENDMETHOD.

ENDCLASS.
