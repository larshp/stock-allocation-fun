CLASS zcl_alloc_kpi_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             first     TYPE menge_d,
             last      TYPE menge_d,
             delta     TYPE menge_d,
             direction TYPE string,
             minimum   TYPE menge_d,
             maximum   TYPE menge_d,
             average   TYPE menge_d,
             points    TYPE i,
           END OF ty_result.

    METHODS analyze
      IMPORTING
        it_series        TYPE ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_kpi_trend IMPLEMENTATION.

  METHOD analyze.
    DATA lv_sum TYPE menge_d.

    rs_result-points = lines( it_series ).

    IF rs_result-points = 0.
      rs_result-direction = 'empty'.
      RETURN.
    ENDIF.

    READ TABLE it_series INTO rs_result-first INDEX 1.
    READ TABLE it_series INTO rs_result-last INDEX rs_result-points.

    rs_result-minimum = rs_result-first.
    rs_result-maximum = rs_result-first.

    LOOP AT it_series INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.

      IF lv_value < rs_result-minimum.
        rs_result-minimum = lv_value.
      ENDIF.
      IF lv_value > rs_result-maximum.
        rs_result-maximum = lv_value.
      ENDIF.
    ENDLOOP.

    rs_result-average = lv_sum DIV rs_result-points.
    rs_result-delta = rs_result-last - rs_result-first.

    IF rs_result-delta > 0.
      rs_result-direction = 'up'.
    ELSEIF rs_result-delta < 0.
      rs_result-direction = 'down'.
    ELSE.
      rs_result-direction = 'flat'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
