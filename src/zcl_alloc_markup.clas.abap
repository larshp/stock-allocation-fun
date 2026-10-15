CLASS zcl_alloc_markup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS markup
      IMPORTING
        iv_cost          TYPE i
        iv_price         TYPE i
      RETURNING
        VALUE(rv_markup) TYPE i.

    METHODS price_from_cost
      IMPORTING
        iv_cost           TYPE i
        iv_markup_percent TYPE i
      RETURNING
        VALUE(rv_price)   TYPE i.

    METHODS percent
      IMPORTING
        iv_cost           TYPE i
        iv_price          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_markup IMPLEMENTATION.

  METHOD markup.
    " The mark-up is what the price adds on top of the cost.
    rv_markup = iv_price - iv_cost.
  ENDMETHOD.

  METHOD price_from_cost.
    " A price built from cost carries the mark-up on top of it.
    rv_price = iv_cost * ( 100 + iv_markup_percent ) DIV 100.
  ENDMETHOD.

  METHOD percent.
    DATA lv_markup TYPE i.

    " The mark-up is related to the cost it was put on.
    IF iv_cost = 0.
      RETURN.
    ENDIF.

    lv_markup = iv_price - iv_cost.
    rv_percent = lv_markup * 100 DIV iv_cost.
  ENDMETHOD.

ENDCLASS.
