CLASS zcl_alloc_ma_recalc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS recalc
      IMPORTING
        iv_old_price    TYPE i
        iv_old_qty      TYPE i
        iv_new_price    TYPE i
        iv_new_qty      TYPE i
      RETURNING
        VALUE(rv_price) TYPE i.

    METHODS is_rise
      IMPORTING
        iv_old_price TYPE i
        iv_new_price TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_old_price    TYPE i
        iv_new_price    TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_ma_recalc IMPLEMENTATION.

  METHOD recalc.
    DATA lv_total_value TYPE i.
    DATA lv_total_qty   TYPE i.

    " The moving average spreads the old and the new stock value over all of it.
    lv_total_qty = iv_old_qty + iv_new_qty.
    IF lv_total_qty <= 0.
      RETURN.
    ENDIF.

    lv_total_value = iv_old_price * iv_old_qty + iv_new_price * iv_new_qty.
    rv_price = lv_total_value DIV lv_total_qty.
  ENDMETHOD.

  METHOD is_rise.
    " The price rises once the new one sits above the old one.
    rv_ok = xsdbool( iv_new_price > iv_old_price ).
  ENDMETHOD.

  METHOD delta.
    rv_delta = iv_new_price - iv_old_price.
  ENDMETHOD.

ENDCLASS.
