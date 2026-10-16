CLASS zcl_alloc_var_sign DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS apply_sign
      IMPORTING
        iv_amount        TYPE i
        iv_is_adverse    TYPE abap_bool
      RETURNING
        VALUE(rv_signed) TYPE i.

    METHODS to_standard
      IMPORTING
        iv_signed         TYPE i
        iv_standard_total TYPE i
      RETURNING
        VALUE(rv_actual)  TYPE i.

    METHODS magnitude
      IMPORTING
        iv_signed           TYPE i
      RETURNING
        VALUE(rv_magnitude) TYPE i.

ENDCLASS.


CLASS zcl_alloc_var_sign IMPLEMENTATION.

  METHOD apply_sign.
    " An adverse variance is positive, a favourable one is negative.
    IF iv_is_adverse = abap_true.
      rv_signed = iv_amount.
    ELSE.
      rv_signed = -1 * iv_amount.
    ENDIF.
  ENDMETHOD.

  METHOD to_standard.
    " The standard cost plus the signed variance gives the actual cost.
    rv_actual = iv_standard_total + iv_signed.
  ENDMETHOD.

  METHOD magnitude.
    " The size of a variance ignores its direction.
    IF iv_signed < 0.
      rv_magnitude = -1 * iv_signed.
    ELSE.
      rv_magnitude = iv_signed.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
