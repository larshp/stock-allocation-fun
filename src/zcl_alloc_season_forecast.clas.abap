CLASS zcl_alloc_season_forecast DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS forecast
      IMPORTING
        it_series          TYPE zcl_alloc_seasonal=>ty_series_tt
        it_index           TYPE zcl_alloc_seasonal=>ty_index_tt
        iv_next_season     TYPE i
      RETURNING
        VALUE(rv_forecast) TYPE menge_d.

    METHODS baseline_of
      IMPORTING
        it_series      TYPE zcl_alloc_seasonal=>ty_series_tt
        it_index       TYPE zcl_alloc_seasonal=>ty_index_tt
      RETURNING
        VALUE(rv_base) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_season_forecast IMPLEMENTATION.

  METHOD baseline_of.
    DATA lv_period  TYPE i.
    DATA lv_count   TYPE i.
    DATA lv_pos     TYPE i.
    DATA lv_from    TYPE i.
    DATA lv_season  TYPE i.
    DATA lv_index   TYPE i.
    DATA lv_sum     TYPE menge_d.
    DATA lv_hits    TYPE i.

    lv_period = lines( it_index ).
    lv_count = lines( it_series ).

    IF lv_period <= 0 OR lv_count = 0.
      RETURN.
    ENDIF.

    lv_from = lv_count - lv_period + 1.
    IF lv_from < 1.
      lv_from = 1.
    ENDIF.

    lv_pos = 0.
    LOOP AT it_series INTO DATA(lv_value).
      lv_pos = lv_pos + 1.
      IF lv_pos < lv_from.
        CONTINUE.
      ENDIF.

      lv_season = ( lv_pos - 1 ) MOD lv_period + 1.
      READ TABLE it_index INTO lv_index INDEX lv_season.

      IF sy-subrc = 0 AND lv_index > 0.
        lv_sum = lv_sum + lv_value * 100 DIV lv_index.
      ELSE.
        lv_sum = lv_sum + lv_value.
      ENDIF.

      lv_hits = lv_hits + 1.
    ENDLOOP.

    IF lv_hits > 0.
      rv_base = lv_sum DIV lv_hits.
    ENDIF.
  ENDMETHOD.

  METHOD forecast.
    DATA lv_base   TYPE menge_d.
    DATA lv_index  TYPE i.

    rv_forecast = 0.

    READ TABLE it_index INTO lv_index INDEX iv_next_season.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_base = baseline_of( it_series = it_series
                           it_index  = it_index ).
    IF lv_base <= 0.
      RETURN.
    ENDIF.

    rv_forecast = lv_base * lv_index DIV 100.
  ENDMETHOD.

ENDCLASS.
