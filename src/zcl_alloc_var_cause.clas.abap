CLASS zcl_alloc_var_cause DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cause
      IMPORTING
        iv_price_variance TYPE i
        iv_qty_variance   TYPE i
      RETURNING
        VALUE(rv_cause)   TYPE string.

    METHODS is_price
      IMPORTING
        iv_price_variance TYPE i
        iv_qty_variance   TYPE i
      RETURNING
        VALUE(rv_ok)      TYPE abap_bool.

    METHODS share
      IMPORTING
        iv_part           TYPE i
        iv_whole          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_var_cause IMPLEMENTATION.

  METHOD cause.
    DATA lv_price TYPE i.
    DATA lv_qty   TYPE i.

    " The cause is whichever component moves the total the most.
    IF iv_price_variance = 0 AND iv_qty_variance = 0.
      rv_cause = 'NONE'.
      RETURN.
    ENDIF.

    lv_price = iv_price_variance.
    IF lv_price < 0.
      lv_price = -1 * lv_price.
    ENDIF.

    lv_qty = iv_qty_variance.
    IF lv_qty < 0.
      lv_qty = -1 * lv_qty.
    ENDIF.

    IF lv_price >= lv_qty.
      rv_cause = 'PRICE'.
    ELSE.
      rv_cause = 'QUANTITY'.
    ENDIF.
  ENDMETHOD.

  METHOD is_price.
    DATA lv_cause TYPE string.

    " The price is the cause when it dominates the move.
    lv_cause = cause( iv_price_variance = iv_price_variance
                      iv_qty_variance   = iv_qty_variance ).
    rv_ok = xsdbool( lv_cause = 'PRICE' ).
  ENDMETHOD.

  METHOD share.
    " The share relates one component to the whole move.
    IF iv_whole = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part * 100 DIV iv_whole.
  ENDMETHOD.

ENDCLASS.
