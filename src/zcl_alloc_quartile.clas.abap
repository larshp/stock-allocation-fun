CLASS zcl_alloc_quartile DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             minimum TYPE menge_d,
             q1      TYPE menge_d,
             median  TYPE menge_d,
             q3      TYPE menge_d,
             maximum TYPE menge_d,
             iqr     TYPE menge_d,
             points  TYPE i,
           END OF ty_result.

    METHODS calculate
      IMPORTING
        it_values        TYPE zcl_alloc_percentile=>ty_series_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_quartile IMPLEMENTATION.

  METHOD calculate.
    DATA lo_pct    TYPE REF TO zcl_alloc_percentile.
    DATA lt_values TYPE zcl_alloc_percentile=>ty_series_tt.
    DATA lv_min    TYPE menge_d.
    DATA lv_max    TYPE menge_d.

    lt_values = it_values.
    SORT lt_values ASCENDING.

    rs_result-points = lines( lt_values ).
    IF rs_result-points = 0.
      RETURN.
    ENDIF.

    READ TABLE lt_values INTO lv_min INDEX 1.
    READ TABLE lt_values INTO lv_max INDEX rs_result-points.
    rs_result-minimum = lv_min.
    rs_result-maximum = lv_max.

    lo_pct = NEW zcl_alloc_percentile( ).
    rs_result-q1 = lo_pct->value( it_values = lt_values iv_pct = 25 ).
    rs_result-median = lo_pct->value( it_values = lt_values iv_pct = 50 ).
    rs_result-q3 = lo_pct->value( it_values = lt_values iv_pct = 75 ).
    rs_result-iqr = rs_result-q3 - rs_result-q1.
  ENDMETHOD.

ENDCLASS.
