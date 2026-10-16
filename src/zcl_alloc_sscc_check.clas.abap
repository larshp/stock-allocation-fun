CLASS zcl_alloc_sscc_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_digit_string
      IMPORTING
        iv_text      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS has_length
      IMPORTING
        iv_sscc      TYPE string
        iv_length    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS check_digit_ok
      IMPORTING
        iv_sscc      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_valid
      IMPORTING
        iv_sscc      TYPE string
        iv_length    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_sscc_check IMPLEMENTATION.

  METHOD is_digit_string.
    DATA lv_len  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.

    lv_len = strlen( iv_text ).
    IF lv_len = 0.
      RETURN.
    ENDIF.

    " A single character compared against '0' and '9' is an ordinal check, which
    " is exactly what digit testing needs.
    WHILE lv_off < lv_len.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char < '0' OR lv_char > '9'.
        RETURN.
      ENDIF.

      lv_off = lv_off + 1.
    ENDWHILE.

    rv_ok = abap_true.
  ENDMETHOD.

  METHOD has_length.
    rv_ok = xsdbool( iv_length > 0 AND strlen( iv_sscc ) = iv_length ).
  ENDMETHOD.

  METHOD check_digit_ok.
    DATA lo_ean TYPE REF TO zcl_alloc_ean_check.

    " Without digits the check digit would be computed from noise, so the shape is
    " verified first.
    IF is_digit_string( iv_sscc ) = abap_false OR strlen( iv_sscc ) < 2.
      RETURN.
    ENDIF.

    lo_ean = NEW zcl_alloc_ean_check( ).
    rv_ok = lo_ean->is_valid( iv_sscc ).
  ENDMETHOD.

  METHOD is_valid.
    rv_ok = xsdbool( has_length( iv_sscc   = iv_sscc
                                 iv_length = iv_length ) = abap_true
                     AND is_digit_string( iv_sscc ) = abap_true
                     AND check_digit_ok( iv_sscc ) = abap_true ).
  ENDMETHOD.

ENDCLASS.
