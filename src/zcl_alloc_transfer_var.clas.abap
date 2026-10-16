CLASS zcl_alloc_transfer_var DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS variance
      IMPORTING
        iv_transfer_price  TYPE i
        iv_market_price    TYPE i
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS is_over
      IMPORTING
        iv_transfer_price TYPE i
        iv_market_price   TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS percent
      IMPORTING
        iv_transfer_price TYPE i
        iv_market_price   TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_transfer_var IMPLEMENTATION.

  METHOD variance.
    " The variance is the transfer price against the market price.
    rv_variance = iv_transfer_price - iv_market_price.
  ENDMETHOD.

  METHOD is_over.
    " The transfer price is high once it sits above the market.
    rv_ok = xsdbool( iv_transfer_price > iv_market_price ).
  ENDMETHOD.

  METHOD percent.
    DATA lv_variance TYPE i.

    " The move is related to the market price it was measured against.
    IF iv_market_price = 0.
      RETURN.
    ENDIF.

    lv_variance = iv_transfer_price - iv_market_price.
    rv_percent = lv_variance * 100 DIV iv_market_price.
  ENDMETHOD.

ENDCLASS.
