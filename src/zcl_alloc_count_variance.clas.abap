CLASS zcl_alloc_count_variance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_book        TYPE i
        iv_counted     TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

    METHODS variance_percent
      IMPORTING
        iv_book       TYPE i
        iv_counted    TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS within_tolerance
      IMPORTING
        iv_book          TYPE i
        iv_counted       TYPE i
        iv_tolerance_pct TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS value_impact
      IMPORTING
        iv_book         TYPE i
        iv_counted      TYPE i
        iv_price_cents  TYPE i
      RETURNING
        VALUE(rv_cents) TYPE i.

  PRIVATE SECTION.
    METHODS absolute
      IMPORTING
        iv_value      TYPE i
      RETURNING
        VALUE(rv_abs) TYPE i.

ENDCLASS.


CLASS zcl_alloc_count_variance IMPLEMENTATION.

  METHOD absolute.
    rv_abs = iv_value.
    IF rv_abs < 0.
      rv_abs = 0 - rv_abs.
    ENDIF.
  ENDMETHOD.

  METHOD variance.
    " Positive means more was found than the book said.
    rv_diff = iv_counted - iv_book.
  ENDMETHOD.

  METHOD variance_percent.
    IF iv_book <= 0.
      RETURN.
    ENDIF.

    rv_pct = absolute( iv_counted - iv_book ) * 100 DIV iv_book.
  ENDMETHOD.

  METHOD within_tolerance.
    rv_ok = xsdbool( iv_tolerance_pct >= 0
                     AND variance_percent( iv_book    = iv_book
                                           iv_counted = iv_counted ) <= iv_tolerance_pct ).
  ENDMETHOD.

  METHOD value_impact.
    DATA lv_lost TYPE i.

    " The impact is signed like the variance, so a shortage of 10 pieces at 50
    " cents each is -500.
    lv_lost = iv_counted - iv_book.
    rv_cents = lv_lost * iv_price_cents.
  ENDMETHOD.

ENDCLASS.
