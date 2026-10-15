CLASS zcl_alloc_interco_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_transfer_price TYPE i
        iv_cost           TYPE i
      RETURNING
        VALUE(rv_rate)    TYPE i.

    METHODS applied
      IMPORTING
        iv_cost         TYPE i
        iv_rate_percent TYPE i
      RETURNING
        VALUE(rv_price) TYPE i.

    METHODS is_reasonable
      IMPORTING
        iv_rate_percent TYPE i
        iv_max_percent  TYPE i
      RETURNING
        VALUE(rv_ok)    TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_interco_rate IMPLEMENTATION.

  METHOD rate.
    " The intercompany rate is the mark-up related to the cost.
    IF iv_cost = 0.
      RETURN.
    ENDIF.

    rv_rate = ( iv_transfer_price - iv_cost ) * 100 DIV iv_cost.
  ENDMETHOD.

  METHOD applied.
    " The rate is applied to the cost to price the transfer.
    rv_price = iv_cost * ( 100 + iv_rate_percent ) DIV 100.
  ENDMETHOD.

  METHOD is_reasonable.
    " A reasonable rate stays within the agreed band above zero.
    rv_ok = xsdbool( iv_rate_percent >= 0 AND iv_rate_percent <= iv_max_percent ).
  ENDMETHOD.

ENDCLASS.
