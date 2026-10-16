CLASS zcl_alloc_control_chart DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_hit,
             rank  TYPE i,
             value TYPE menge_d,
             above TYPE abap_bool,
           END OF ty_hit.
    TYPES ty_hit_tt TYPE STANDARD TABLE OF ty_hit WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             centre TYPE menge_d,
             avg_mr TYPE menge_d,
             ucl    TYPE menge_d,
             lcl    TYPE menge_d,
             mr_ucl TYPE menge_d,
             points TYPE i,
           END OF ty_result.

    METHODS build
      IMPORTING
        it_values        TYPE ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS out_of_control
      IMPORTING
        it_values      TYPE ty_series_tt
        is_result      TYPE ty_result
      RETURNING
        VALUE(rt_hits) TYPE ty_hit_tt.

ENDCLASS.


CLASS zcl_alloc_control_chart IMPLEMENTATION.

  METHOD build.
    DATA lv_count TYPE i.
    DATA lv_sum   TYPE menge_d.
    DATA lv_mr    TYPE menge_d.
    DATA lv_prev  TYPE menge_d.
    DATA lv_diff  TYPE menge_d.
    DATA lv_first TYPE abap_bool.
    DATA lv_span  TYPE menge_d.

    lv_first = abap_true.
    lv_count = lines( it_values ).
    rs_result-points = lv_count.

    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT it_values INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.

      IF lv_first = abap_true.
        lv_first = abap_false.
      ELSE.
        lv_diff = lv_value - lv_prev.
        IF lv_diff < 0.
          lv_diff = 0 - lv_diff.
        ENDIF.
        lv_mr = lv_mr + lv_diff.
      ENDIF.

      lv_prev = lv_value.
    ENDLOOP.

    rs_result-centre = lv_sum DIV lv_count.

    IF lv_count > 1.
      rs_result-avg_mr = lv_mr DIV ( lv_count - 1 ).
    ENDIF.

    " The X limits sit 2.660 average moving ranges from the centre, the moving
    " range limit 3.267. Both factors are applied in thousandths.
    lv_span = 2660 * rs_result-avg_mr DIV 1000.
    rs_result-ucl = rs_result-centre + lv_span.
    rs_result-lcl = rs_result-centre - lv_span.
    rs_result-mr_ucl = 3267 * rs_result-avg_mr DIV 1000.
  ENDMETHOD.

  METHOD out_of_control.
    DATA lv_rank TYPE i.
    DATA ls_hit  TYPE ty_hit.

    LOOP AT it_values INTO DATA(lv_value).
      lv_rank = lv_rank + 1.

      IF lv_value <= is_result-ucl AND lv_value >= is_result-lcl.
        CONTINUE.
      ENDIF.

      CLEAR ls_hit.
      ls_hit-rank = lv_rank.
      ls_hit-value = lv_value.

      IF lv_value > is_result-ucl.
        ls_hit-above = abap_true.
      ENDIF.

      APPEND ls_hit TO rt_hits.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
