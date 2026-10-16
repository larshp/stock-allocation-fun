CLASS zcl_alloc_benchmark DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             measured TYPE menge_d,
             best     TYPE menge_d,
             median   TYPE menge_d,
             average  TYPE menge_d,
             behind   TYPE menge_d,
             ahead    TYPE abap_bool,
           END OF ty_result.

    METHODS compare
      IMPORTING
        it_values        TYPE zcl_alloc_percentile=>ty_series_tt
        iv_measured      TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_benchmark IMPLEMENTATION.

  METHOD compare.
    DATA lo_pct    TYPE REF TO zcl_alloc_percentile.
    DATA lt_values TYPE zcl_alloc_percentile=>ty_series_tt.
    DATA lv_best   TYPE menge_d.
    DATA lv_sum    TYPE menge_d.
    DATA lv_count  TYPE i.

    rs_result-measured = iv_measured.

    lt_values = it_values.
    SORT lt_values ASCENDING.

    lv_count = lines( lt_values ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    " Lower is better, so the best value is the smallest one.
    READ TABLE lt_values INTO lv_best INDEX 1.
    rs_result-best = lv_best.

    LOOP AT lt_values INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.
    ENDLOOP.
    rs_result-average = lv_sum DIV lv_count.

    lo_pct = NEW zcl_alloc_percentile( ).
    rs_result-median = lo_pct->value( it_values = lt_values iv_pct = 50 ).

    rs_result-behind = iv_measured - rs_result-best.

    IF iv_measured <= rs_result-average.
      rs_result-ahead = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
