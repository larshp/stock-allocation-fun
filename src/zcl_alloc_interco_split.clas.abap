CLASS zcl_alloc_interco_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS split
      IMPORTING
        iv_total_profit   TYPE i
        iv_seller_percent TYPE i
      RETURNING
        VALUE(rv_seller)  TYPE i.

    METHODS seller_share
      IMPORTING
        iv_total_profit  TYPE i
        iv_buyer_share   TYPE i
      RETURNING
        VALUE(rv_seller) TYPE i.

    METHODS buyer_share
      IMPORTING
        iv_total_profit   TYPE i
        iv_seller_percent TYPE i
      RETURNING
        VALUE(rv_buyer)   TYPE i.

ENDCLASS.


CLASS zcl_alloc_interco_split IMPLEMENTATION.

  METHOD split.
    " The seller keeps its share of the intercompany profit.
    rv_seller = iv_total_profit * iv_seller_percent DIV 100.
  ENDMETHOD.

  METHOD seller_share.
    " What the buyer does not take is left to the seller.
    rv_seller = iv_total_profit - iv_buyer_share.
  ENDMETHOD.

  METHOD buyer_share.
    " The buyer takes whatever is left after the seller's share.
    rv_buyer = iv_total_profit - iv_total_profit * iv_seller_percent DIV 100.
  ENDMETHOD.

ENDCLASS.
