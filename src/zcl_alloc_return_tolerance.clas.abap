CLASS zcl_alloc_return_tolerance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS deviation_percent
      IMPORTING
        iv_authorised TYPE i
        iv_received   TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS within_tolerance
      IMPORTING
        iv_authorised    TYPE i
        iv_received      TYPE i
        iv_under_percent TYPE i
        iv_over_percent  TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS credit_quantity
      IMPORTING
        iv_authorised    TYPE i
        iv_received      TYPE i
      RETURNING
        VALUE(rv_credit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_tolerance IMPLEMENTATION.

  METHOD deviation_percent.
    IF iv_authorised <= 0.
      RETURN.
    ENDIF.

    " Signed and rounded towards zero, like the delivery tolerance check.
    rv_pct = ( iv_received - iv_authorised ) * 100 DIV iv_authorised.
  ENDMETHOD.

  METHOD within_tolerance.
    DATA lv_dev TYPE i.

    IF iv_authorised <= 0 OR iv_under_percent < 0 OR iv_over_percent < 0.
      RETURN.
    ENDIF.

    lv_dev = deviation_percent( iv_authorised = iv_authorised
                                iv_received   = iv_received ).

    IF lv_dev < 0.
      rv_ok = xsdbool( 0 - lv_dev <= iv_under_percent ).
    ELSEIF lv_dev > 0.
      rv_ok = xsdbool( lv_dev <= iv_over_percent ).
    ELSE.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD credit_quantity.
    " A customer is never credited more than was authorised, even when more came
    " back; a negative receipt credits nothing.
    IF iv_authorised <= 0 OR iv_received <= 0.
      RETURN.
    ENDIF.

    IF iv_received > iv_authorised.
      rv_credit = iv_authorised.
    ELSE.
      rv_credit = iv_received.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
