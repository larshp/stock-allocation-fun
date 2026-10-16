CLASS zcl_alloc_return_stock_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ages_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS age_days
      IMPORTING
        iv_received    TYPE d
        iv_check       TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS bucket
      IMPORTING
        iv_age_days      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

    METHODS oldest
      IMPORTING
        it_ages        TYPE ty_ages_tt
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_stock_age IMPLEMENTATION.

  METHOD age_days.
    " The stock age is the number of days between receipt and the check day. A
    " missing date or a future receipt reads as no age.
    IF iv_received IS INITIAL OR iv_check IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_check < iv_received.
      RETURN.
    ENDIF.

    rv_days = iv_check - iv_received.
  ENDMETHOD.

  METHOD bucket.
    " An age is placed in the first band it fits.
    IF iv_age_days <= 30.
      rv_bucket = '0-30'.
    ELSEIF iv_age_days <= 60.
      rv_bucket = '31-60'.
    ELSEIF iv_age_days <= 90.
      rv_bucket = '61-90'.
    ELSE.
      rv_bucket = '90+'.
    ENDIF.
  ENDMETHOD.

  METHOD oldest.
    LOOP AT it_ages INTO DATA(lv_age).
      IF lv_age > rv_days.
        rv_days = lv_age.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
