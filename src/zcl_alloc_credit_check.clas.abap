CLASS zcl_alloc_credit_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_valid
      IMPORTING
        iv_credit    TYPE i
        iv_expected  TYPE i
        iv_tolerance TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_credit        TYPE i
        iv_expected      TYPE i
        iv_tolerance     TYPE i
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS difference
      IMPORTING
        iv_credit      TYPE i
        iv_expected    TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

ENDCLASS.


CLASS zcl_alloc_credit_check IMPLEMENTATION.

  METHOD difference.
    rv_diff = iv_credit - iv_expected.
  ENDMETHOD.

  METHOD is_valid.
    DATA lv_diff TYPE i.
    DATA lv_abs  TYPE i.

    IF iv_tolerance < 0.
      RETURN.
    ENDIF.

    lv_diff = difference( iv_credit   = iv_credit
                          iv_expected = iv_expected ).

    " The absolute deviation is measured without the ABS built-in.
    lv_abs = lv_diff.
    IF lv_abs < 0.
      lv_abs = 0 - lv_abs.
    ENDIF.

    rv_ok = xsdbool( lv_abs <= iv_tolerance ).
  ENDMETHOD.

  METHOD reason.
    DATA lv_diff TYPE i.

    IF iv_tolerance < 0.
      rv_reason = 'BAD_TOLERANCE'.
      RETURN.
    ENDIF.

    IF is_valid( iv_credit    = iv_credit
                 iv_expected  = iv_expected
                 iv_tolerance = iv_tolerance ) = abap_true.
      rv_reason = 'OK'.
      RETURN.
    ENDIF.

    lv_diff = difference( iv_credit   = iv_credit
                          iv_expected = iv_expected ).

    IF lv_diff > 0.
      rv_reason = 'OVER_CREDIT'.
    ELSE.
      rv_reason = 'UNDER_CREDIT'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
