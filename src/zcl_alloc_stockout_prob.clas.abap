CLASS zcl_alloc_stockout_prob DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS probability
      IMPORTING
        iv_stockouts          TYPE i
        iv_periods            TYPE i
      RETURNING
        VALUE(rv_probability) TYPE i.

    METHODS is_likely
      IMPORTING
        iv_probability TYPE i
        iv_threshold   TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS bucket
      IMPORTING
        iv_probability   TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

ENDCLASS.


CLASS zcl_alloc_stockout_prob IMPLEMENTATION.

  METHOD probability.
    " The probability is the share of periods that stocked out.
    IF iv_periods <= 0.
      RETURN.
    ENDIF.

    rv_probability = iv_stockouts * 100 DIV iv_periods.
  ENDMETHOD.

  METHOD is_likely.
    " A stockout is likely once its probability reaches the threshold.
    rv_ok = xsdbool( iv_probability >= iv_threshold ).
  ENDMETHOD.

  METHOD bucket.
    " The probability is folded into three bands.
    IF iv_probability >= 50.
      rv_bucket = 'HIGH'.
    ELSEIF iv_probability >= 10.
      rv_bucket = 'MEDIUM'.
    ELSE.
      rv_bucket = 'LOW'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
