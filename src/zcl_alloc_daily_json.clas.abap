CLASS zcl_alloc_daily_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_daily_report=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_daily_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_day).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"run_date":"{ ls_day-run_date }",|.
      lv_item = lv_item && |"lines":{ ls_day-lines },|.
      lv_item = lv_item && |"requested_qty":{ ls_day-requested_qty },|.
      lv_item = lv_item && |"allocated_qty":{ ls_day-allocated_qty },|.
      lv_item = lv_item && |"coverage_pct":{ ls_day-coverage_pct }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
