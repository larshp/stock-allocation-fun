CLASS zcl_alloc_replenish_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS total
      IMPORTING
        iv_ordering     TYPE i
        iv_holding      TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS ordering_share
      IMPORTING
        iv_ordering     TYPE i
        iv_holding      TYPE i
      RETURNING
        VALUE(rv_share) TYPE i.

    METHODS holding_share
      IMPORTING
        iv_ordering     TYPE i
        iv_holding      TYPE i
      RETURNING
        VALUE(rv_share) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_cost IMPLEMENTATION.

  METHOD total.
    " The total replenishment cost adds the ordering and the holding part.
    IF iv_ordering > 0.
      rv_total = rv_total + iv_ordering.
    ENDIF.

    IF iv_holding > 0.
      rv_total = rv_total + iv_holding.
    ENDIF.
  ENDMETHOD.

  METHOD ordering_share.
    DATA lv_total TYPE i.

    lv_total = total( iv_ordering = iv_ordering iv_holding = iv_holding ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    rv_share = iv_ordering * 100 DIV lv_total.
  ENDMETHOD.

  METHOD holding_share.
    DATA lv_total TYPE i.

    lv_total = total( iv_ordering = iv_ordering iv_holding = iv_holding ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    rv_share = iv_holding * 100 DIV lv_total.
  ENDMETHOD.

ENDCLASS.
