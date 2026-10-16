CLASS zcl_alloc_scorecard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_metric,
             metric_id    TYPE string,
             target_value TYPE menge_d,
             actual_value TYPE menge_d,
             weight       TYPE i,
           END OF ty_metric.
    TYPES ty_metric_tt TYPE STANDARD TABLE OF ty_metric WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             metric_id    TYPE string,
             target_value TYPE menge_d,
             actual_value TYPE menge_d,
             weight       TYPE i,
             met          TYPE abap_bool,
             gap          TYPE menge_d,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_metrics     TYPE ty_metric_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS met_count
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_scorecard IMPLEMENTATION.

  METHOD build.
    DATA ls_row TYPE ty_row.

    LOOP AT it_metrics INTO DATA(ls_metric).
      CLEAR ls_row.
      ls_row-metric_id = ls_metric-metric_id.
      ls_row-target_value = ls_metric-target_value.
      ls_row-actual_value = ls_metric-actual_value.
      ls_row-weight = ls_metric-weight.
      ls_row-gap = ls_metric-actual_value - ls_metric-target_value.

      " Higher is better, and reaching the target exactly counts as met.
      IF ls_metric-actual_value >= ls_metric-target_value.
        ls_row-met = abap_true.
      ENDIF.

      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD met_count.
    LOOP AT it_rows INTO DATA(ls_row).
      IF ls_row-met = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
