CLASS zcl_alloc_ean_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS check_digit
      IMPORTING
        iv_code         TYPE string
      RETURNING
        VALUE(rv_digit) TYPE i.

    METHODS is_valid
      IMPORTING
        iv_code      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS complete
      IMPORTING
        iv_code       TYPE string
      RETURNING
        VALUE(rv_ean) TYPE string.

  PRIVATE SECTION.
    METHODS digit_at
      IMPORTING
        iv_code         TYPE string
        iv_index        TYPE i
      RETURNING
        VALUE(rv_digit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_ean_check IMPLEMENTATION.

  METHOD digit_at.
    IF iv_index < 0 OR iv_index >= strlen( iv_code ).
      RETURN.
    ENDIF.

    rv_digit = substring( val = iv_code off = iv_index len = 1 ).
  ENDMETHOD.

  METHOD check_digit.
    DATA lv_pos    TYPE i.
    DATA lv_sum    TYPE i.
    DATA lv_weight TYPE i.

    IF strlen( iv_code ) = 0.
      RETURN.
    ENDIF.

    " The digits are weighted 3, 1, 3, 1 from the right, which is the EAN / GTIN
    " rule, and the check digit repairs the sum to the next multiple of ten.
    lv_weight = 3.
    lv_pos = strlen( iv_code ) - 1.

    WHILE lv_pos >= 0.
      lv_sum = lv_sum + digit_at( iv_code = iv_code iv_index = lv_pos ) * lv_weight.

      IF lv_weight = 3.
        lv_weight = 1.
      ELSE.
        lv_weight = 3.
      ENDIF.

      lv_pos = lv_pos - 1.
    ENDWHILE.

    rv_digit = ( 10 - lv_sum MOD 10 ) MOD 10.
  ENDMETHOD.

  METHOD is_valid.
    DATA lv_len      TYPE i.
    DATA lv_expected TYPE i.

    lv_len = strlen( iv_code ).
    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_expected = check_digit(
      substring( val = iv_code off = 0 len = lv_len - 1 ) ).

    rv_ok = xsdbool( digit_at( iv_code  = iv_code
                               iv_index = lv_len - 1 ) = lv_expected ).
  ENDMETHOD.

  METHOD complete.
    DATA lv_digit TYPE i.
    DATA lv_text  TYPE string.

    lv_digit = check_digit( iv_code ).
    lv_text = |{ lv_digit }|.
    rv_ean = iv_code && lv_text.
  ENDMETHOD.

ENDCLASS.
