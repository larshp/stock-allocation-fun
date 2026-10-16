CLASS zcl_alloc_interco_arms DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_arms_length
      IMPORTING
        iv_transfer_price    TYPE i
        iv_market_price      TYPE i
        iv_tolerance_percent TYPE i
      RETURNING
        VALUE(rv_ok)         TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_transfer_price TYPE i
        iv_market_price   TYPE i
      RETURNING
        VALUE(rv_gap)     TYPE i.

    METHODS direction
      IMPORTING
        iv_transfer_price TYPE i
        iv_market_price   TYPE i
      RETURNING
        VALUE(rv_dir)     TYPE string.

ENDCLASS.


CLASS zcl_alloc_interco_arms IMPLEMENTATION.

  METHOD gap.
    " The gap is the size of the move away from the market price.
    rv_gap = iv_transfer_price - iv_market_price.
    IF rv_gap < 0.
      rv_gap = -1 * rv_gap.
    ENDIF.
  ENDMETHOD.

  METHOD is_arms_length.
    DATA lv_diff  TYPE i.
    DATA lv_limit TYPE i.

    " The price is at arm's length while it stays inside the tolerance band.
    IF iv_market_price = 0.
      rv_ok = xsdbool( iv_transfer_price = 0 ).
      RETURN.
    ENDIF.

    lv_diff = gap( iv_transfer_price = iv_transfer_price
                   iv_market_price   = iv_market_price ).
    lv_limit = iv_market_price * iv_tolerance_percent DIV 100.
    rv_ok = xsdbool( lv_diff <= lv_limit ).
  ENDMETHOD.

  METHOD direction.
    " The direction tells whether the price sits above or below the market.
    IF iv_transfer_price > iv_market_price.
      rv_dir = 'ABOVE'.
    ELSEIF iv_transfer_price < iv_market_price.
      rv_dir = 'BELOW'.
    ELSE.
      rv_dir = 'EQUAL'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
