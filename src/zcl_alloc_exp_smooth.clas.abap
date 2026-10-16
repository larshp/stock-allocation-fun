CLASS zcl_alloc_exp_smooth DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             smoothed TYPE ty_series_tt,
             forecast TYPE menge_d,
           END OF ty_result.

    METHODS forecast
      IMPORTING
        it_series        TYPE ty_series_tt
        iv_alpha         TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_exp_smooth IMPLEMENTATION.

  METHOD forecast.
    DATA lv_alpha TYPE i.
    DATA lv_first TYPE abap_bool.
    DATA lv_prev  TYPE menge_d.
    DATA lv_next  TYPE menge_d.
    DATA lv_sum   TYPE menge_d.

    lv_alpha = iv_alpha.
    IF lv_alpha < 0.
      lv_alpha = 0.
    ENDIF.
    IF lv_alpha > 100.
      lv_alpha = 100.
    ENDIF.

    lv_first = abap_true.

    LOOP AT it_series INTO DATA(lv_value).
      IF lv_first = abap_true.
        lv_next = lv_value.
        lv_first = abap_false.
      ELSE.
        lv_sum = lv_alpha * lv_value + ( 100 - lv_alpha ) * lv_prev.
        lv_next = lv_sum DIV 100.
      ENDIF.

      APPEND lv_next TO rs_result-smoothed.
      lv_prev = lv_next.
    ENDLOOP.

    rs_result-forecast = lv_prev.
  ENDMETHOD.

ENDCLASS.
