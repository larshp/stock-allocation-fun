CLASS zcl_alloc_outlier DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_hit,
             rank       TYPE i,
             value      TYPE menge_d,
             score_x100 TYPE i,
           END OF ty_hit.
    TYPES ty_hit_tt TYPE STANDARD TABLE OF ty_hit WITH DEFAULT KEY.

    METHODS find
      IMPORTING
        it_series      TYPE ty_series_tt
        iv_threshold   TYPE i
      RETURNING
        VALUE(rt_hits) TYPE ty_hit_tt.

    METHODS mean_of
      IMPORTING
        it_series      TYPE ty_series_tt
      RETURNING
        VALUE(rv_mean) TYPE menge_d.

    METHODS sd_of
      IMPORTING
        it_series    TYPE ty_series_tt
      RETURNING
        VALUE(rv_sd) TYPE i.

ENDCLASS.


CLASS zcl_alloc_outlier IMPLEMENTATION.

  METHOD mean_of.
    DATA lv_count TYPE i.

    lv_count = lines( it_series ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT it_series INTO DATA(lv_value).
      rv_mean = rv_mean + lv_value.
    ENDLOOP.

    rv_mean = rv_mean DIV lv_count.
  ENDMETHOD.

  METHOD sd_of.
    DATA lo_root   TYPE REF TO zcl_alloc_safety_level.
    DATA lv_count  TYPE i.
    DATA lv_mean   TYPE menge_d.
    DATA lv_dev    TYPE menge_d.
    DATA lv_var    TYPE menge_d.
    DATA lv_var_i  TYPE i.

    lv_count = lines( it_series ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    lv_mean = mean_of( it_series ).

    LOOP AT it_series INTO DATA(lv_value).
      lv_dev = lv_value - lv_mean.
      lv_var = lv_var + lv_dev * lv_dev.
    ENDLOOP.

    lv_var = lv_var DIV lv_count.
    lv_var_i = lv_var.

    lo_root = NEW zcl_alloc_safety_level( ).
    rv_sd = lo_root->sqrt_of( iv_value = lv_var_i ).
  ENDMETHOD.

  METHOD find.
    DATA lv_mean  TYPE menge_d.
    DATA lv_sd    TYPE i.
    DATA lv_rank  TYPE i.
    DATA lv_diff  TYPE menge_d.
    DATA lv_score TYPE i.
    DATA ls_hit   TYPE ty_hit.

    lv_sd = sd_of( it_series ).
    IF lv_sd <= 0.
      RETURN.
    ENDIF.

    lv_mean = mean_of( it_series ).

    LOOP AT it_series INTO DATA(lv_value).
      lv_rank = lv_rank + 1.

      lv_diff = lv_value - lv_mean.
      lv_score = lv_diff * 100 DIV lv_sd.

      IF lv_score <= iv_threshold AND lv_score >= 0 - iv_threshold.
        CONTINUE.
      ENDIF.

      CLEAR ls_hit.
      ls_hit-rank = lv_rank.
      ls_hit-value = lv_value.
      ls_hit-score_x100 = lv_score.
      APPEND ls_hit TO rt_hits.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
