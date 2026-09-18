CLASS zcl_alloc_holt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             levels   TYPE ty_series_tt,
             trends   TYPE ty_series_tt,
             forecast TYPE menge_d,
           END OF ty_result.

    METHODS forecast
      IMPORTING
        it_series        TYPE ty_series_tt
        iv_alpha         TYPE i
        iv_beta          TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS clamp_pct
      IMPORTING
        iv_value      TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_holt IMPLEMENTATION.

  METHOD clamp_pct.
    rv_pct = iv_value.

    IF rv_pct < 0.
      rv_pct = 0.
    ENDIF.
    IF rv_pct > 100.
      rv_pct = 100.
    ENDIF.
  ENDMETHOD.

  METHOD forecast.
    DATA lv_alpha   TYPE i.
    DATA lv_beta    TYPE i.
    DATA lv_first   TYPE abap_bool.
    DATA lv_prev    TYPE menge_d.
    DATA lv_level   TYPE menge_d.
    DATA lv_trend   TYPE menge_d.
    DATA lv_sum     TYPE menge_d.
    DATA lv_diff    TYPE menge_d.

    lv_alpha = clamp_pct( iv_alpha ).
    lv_beta = clamp_pct( iv_beta ).

    lv_first = abap_true.

    LOOP AT it_series INTO DATA(lv_value).
      IF lv_first = abap_true.
        lv_level = lv_value.
        lv_trend = 0.
        lv_prev = lv_value.
        lv_first = abap_false.

        APPEND lv_level TO rs_result-levels.
        APPEND lv_trend TO rs_result-trends.
        CONTINUE.
      ENDIF.

      lv_sum = lv_alpha * lv_value + ( 100 - lv_alpha ) * ( lv_prev + lv_trend ).
      lv_level = lv_sum DIV 100.

      lv_diff = lv_level - lv_prev.
      lv_sum = lv_beta * lv_diff + ( 100 - lv_beta ) * lv_trend.
      lv_trend = lv_sum DIV 100.

      lv_prev = lv_level.

      APPEND lv_level TO rs_result-levels.
      APPEND lv_trend TO rs_result-trends.
    ENDLOOP.

    rs_result-forecast = lv_level + lv_trend.
  ENDMETHOD.

ENDCLASS.
