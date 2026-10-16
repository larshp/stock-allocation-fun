CLASS zcl_alloc_transfer_price DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS price
      IMPORTING
        iv_cost           TYPE i
        iv_markup_percent TYPE i
      RETURNING
        VALUE(rv_price)   TYPE i.

    METHODS from_cost
      IMPORTING
        iv_price          TYPE i
        iv_markup_percent TYPE i
      RETURNING
        VALUE(rv_cost)    TYPE i.

    METHODS is_at_cost
      IMPORTING
        iv_markup_percent TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_transfer_price IMPLEMENTATION.

  METHOD price.
    " The transfer price carries the mark-up on top of the cost.
    rv_price = iv_cost * ( 100 + iv_markup_percent ) DIV 100.
  ENDMETHOD.

  METHOD from_cost.
    " The cost behind a transfer price is the price stripped of the mark-up.
    IF iv_markup_percent <= -100.
      RETURN.
    ENDIF.

    rv_cost = iv_price * 100 DIV ( 100 + iv_markup_percent ).
  ENDMETHOD.

  METHOD is_at_cost.
    " A transfer price on cost carries no mark-up.
    rv_ok = xsdbool( iv_markup_percent = 0 ).
  ENDMETHOD.

ENDCLASS.
