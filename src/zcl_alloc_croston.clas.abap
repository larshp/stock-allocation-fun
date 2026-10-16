CLASS zcl_alloc_croston DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             forecast TYPE menge_d,
             size     TYPE menge_d,
             interval TYPE menge_d,
           END OF ty_result.

    METHODS forecast
      IMPORTING
        it_series        TYPE ty_series_tt
        iv_alpha         TYPE i
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    METHODS clamp_pct
      IMPORTING
        iv_value      TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_croston IMPLEMENTATION.

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
    DATA lv_alpha    TYPE i.
    DATA lv_seen     TYPE abap_bool.
    DATA lv_gap      TYPE i.
    DATA lv_size     TYPE menge_d.
    DATA lv_interval TYPE menge_d.
    DATA lv_sum      TYPE menge_d.

    lv_alpha = clamp_pct( iv_alpha ).

    LOOP AT it_series INTO DATA(lv_value).
      lv_gap = lv_gap + 1.

      IF lv_value <= 0.
        CONTINUE.
      ENDIF.

      IF lv_seen = abap_false.
        lv_size = lv_value.
        lv_interval = lv_gap.
        lv_seen = abap_true.
        lv_gap = 0.
        CONTINUE.
      ENDIF.

      lv_sum = lv_alpha * lv_value + ( 100 - lv_alpha ) * lv_size.
      lv_size = lv_sum DIV 100.

      lv_sum = lv_alpha * lv_gap + ( 100 - lv_alpha ) * lv_interval.
      lv_interval = lv_sum DIV 100.

      lv_gap = 0.
    ENDLOOP.

    IF lv_seen = abap_false OR lv_interval <= 0.
      RETURN.
    ENDIF.

    rs_result-size = lv_size.
    rs_result-interval = lv_interval.
    rs_result-forecast = lv_size DIV lv_interval.
  ENDMETHOD.

ENDCLASS.
