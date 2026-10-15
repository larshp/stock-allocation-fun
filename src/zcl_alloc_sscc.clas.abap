CLASS zcl_alloc_sscc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        iv_body        TYPE string
        iv_length      TYPE i
      RETURNING
        VALUE(rv_sscc) TYPE string.

    METHODS body
      IMPORTING
        iv_sscc        TYPE string
      RETURNING
        VALUE(rv_body) TYPE string.

    METHODS is_valid
      IMPORTING
        iv_sscc      TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_sscc IMPLEMENTATION.

  METHOD build.
    DATA lv_body TYPE string.
    DATA lo_pad  TYPE REF TO zcl_alloc_gtin_build.
    DATA lo_ean  TYPE REF TO zcl_alloc_ean_check.

    IF iv_length < 2.
      RETURN.
    ENDIF.

    " The serial reference is left padded by the GTIN builder's rule and the check
    " digit is the same mod-10 digit EAN and GTIN use, so both are reused.
    lo_pad = NEW zcl_alloc_gtin_build( ).
    lv_body = lo_pad->pad_body( iv_body   = iv_body
                                iv_length = iv_length - 1 ).

    lo_ean = NEW zcl_alloc_ean_check( ).
    rv_sscc = lo_ean->complete( lv_body ).
  ENDMETHOD.

  METHOD body.
    DATA lv_len TYPE i.

    lv_len = strlen( iv_sscc ).
    IF lv_len < 2.
      RETURN.
    ENDIF.

    rv_body = substring( val = iv_sscc off = 0 len = lv_len - 1 ).
  ENDMETHOD.

  METHOD is_valid.
    DATA lo_ean TYPE REF TO zcl_alloc_ean_check.

    lo_ean = NEW zcl_alloc_ean_check( ).
    rv_ok = lo_ean->is_valid( iv_sscc ).
  ENDMETHOD.

ENDCLASS.
