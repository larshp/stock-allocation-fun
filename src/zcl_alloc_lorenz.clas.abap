CLASS zcl_alloc_lorenz DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_point,
             rank      TYPE i,
             cumul_pop TYPE i,
             cumul_val TYPE i,
           END OF ty_point.
    TYPES ty_point_tt TYPE STANDARD TABLE OF ty_point WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_values        TYPE ty_series_tt
      RETURNING
        VALUE(rt_points) TYPE ty_point_tt.

    METHODS gap_of
      IMPORTING
        it_points     TYPE ty_point_tt
      RETURNING
        VALUE(rv_gap) TYPE i.

ENDCLASS.


CLASS zcl_alloc_lorenz IMPLEMENTATION.

  METHOD build.
    DATA lt_values TYPE ty_series_tt.
    DATA ls_point  TYPE ty_point.
    DATA lv_count  TYPE i.
    DATA lv_rank   TYPE i.
    DATA lv_sum    TYPE menge_d.
    DATA lv_cumul  TYPE menge_d.

    lt_values = it_values.
    SORT lt_values ASCENDING.

    lv_count = lines( lt_values ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT lt_values INTO DATA(lv_value).
      lv_sum = lv_sum + lv_value.
    ENDLOOP.

    IF lv_sum <= 0.
      RETURN.
    ENDIF.

    LOOP AT lt_values INTO lv_value.
      lv_rank = lv_rank + 1.
      lv_cumul = lv_cumul + lv_value.

      CLEAR ls_point.
      ls_point-rank = lv_rank.
      ls_point-cumul_pop = lv_rank * 100 DIV lv_count.
      ls_point-cumul_val = lv_cumul * 100 DIV lv_sum.
      APPEND ls_point TO rt_points.
    ENDLOOP.
  ENDMETHOD.

  METHOD gap_of.
    DATA lv_diff TYPE i.

    LOOP AT it_points INTO DATA(ls_point).
      lv_diff = ls_point-cumul_pop - ls_point-cumul_val.
      IF lv_diff < 0.
        lv_diff = 0 - lv_diff.
      ENDIF.

      IF lv_diff > rv_gap.
        rv_gap = lv_diff.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
