CLASS zcl_alloc_trend_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_trend       TYPE zcl_alloc_trend=>ty_trend
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_trend_json IMPLEMENTATION.

  METHOD build.
    rv_json = '{'.
    rv_json = rv_json && |"count":{ is_trend-count },|.
    rv_json = rv_json && |"first_qty":{ is_trend-first_qty },|.
    rv_json = rv_json && |"last_qty":{ is_trend-last_qty },|.
    rv_json = rv_json && |"change_pct":{ is_trend-change_pct },|.
    rv_json = rv_json && |"direction":"{ is_trend-direction }"|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
