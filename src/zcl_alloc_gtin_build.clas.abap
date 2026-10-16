CLASS zcl_alloc_gtin_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        iv_body        TYPE string
        iv_length      TYPE i
      RETURNING
        VALUE(rv_gtin) TYPE string.

    METHODS pad_body
      IMPORTING
        iv_body          TYPE string
        iv_length        TYPE i
      RETURNING
        VALUE(rv_padded) TYPE string.

ENDCLASS.


CLASS zcl_alloc_gtin_build IMPLEMENTATION.

  METHOD pad_body.
    DATA lv_pad TYPE i.

    " The body is left padded with zeros to the given length. A body that is
    " already longer is returned unchanged.
    rv_padded = iv_body.
    IF iv_length <= 0.
      RETURN.
    ENDIF.

    lv_pad = iv_length - strlen( rv_padded ).
    WHILE lv_pad > 0.
      rv_padded = '0' && rv_padded.
      lv_pad = lv_pad - 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD build.
    DATA lv_body TYPE string.

    IF iv_length < 2.
      RETURN.
    ENDIF.

    " The check digit occupies the last place, so the body is padded one place
    " short of the total length.
    lv_body = pad_body( iv_body   = iv_body
                        iv_length = iv_length - 1 ).

    DATA(lo_ean) = NEW zcl_alloc_ean_check( ).
    rv_gtin = lo_ean->complete( lv_body ).
  ENDMETHOD.

ENDCLASS.
