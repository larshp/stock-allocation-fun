CLASS zcl_alloc_margin_target DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS meets
      IMPORTING
        iv_margin_percent TYPE i
        iv_target_percent TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS shortfall
      IMPORTING
        iv_margin_percent TYPE i
        iv_target_percent TYPE i
      RETURNING
        VALUE(rv_short)   TYPE i.

    METHODS price_for_target
      IMPORTING
        iv_cost           TYPE i
        iv_target_percent TYPE i
      RETURNING
        VALUE(rv_price)   TYPE i.

ENDCLASS.


CLASS zcl_alloc_margin_target IMPLEMENTATION.

  METHOD meets.
    " The margin meets the target once it reaches it.
    rv_ok = xsdbool( iv_margin_percent >= iv_target_percent ).
  ENDMETHOD.

  METHOD shortfall.
    " The shortfall is what the margin still owes the target.
    IF iv_margin_percent >= iv_target_percent.
      RETURN.
    ENDIF.

    rv_short = iv_target_percent - iv_margin_percent.
  ENDMETHOD.

  METHOD price_for_target.
    " A target rate is a share of the price, so the cost fills the rest.
    IF iv_target_percent >= 100.
      RETURN.
    ENDIF.

    rv_price = iv_cost * 100 DIV ( 100 - iv_target_percent ).
  ENDMETHOD.

ENDCLASS.
