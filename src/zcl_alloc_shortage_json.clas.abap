CLASS zcl_alloc_shortage_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_report      TYPE zcl_alloc_shortage_report=>ty_report
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    METHODS bool_json
      IMPORTING
        iv_flag        TYPE abap_bool
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_shortage_json IMPLEMENTATION.

  METHOD bool_json.
    IF iv_flag = abap_true.
      rv_text = 'true'.
    ELSE.
      rv_text = 'false'.
    ENDIF.
  ENDMETHOD.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_flag  TYPE string.

    rv_json = '{"summary":'.

    CLEAR lv_item.
    lv_item = '{'.
    lv_item = lv_item && |"requested_qty":{ is_report-summary-requested_qty },|.
    lv_item = lv_item && |"allocated_qty":{ is_report-summary-allocated_qty },|.
    lv_item = lv_item && |"shortage_qty":{ is_report-summary-shortage_qty },|.
    lv_item = lv_item && |"coverage_pct":{ is_report-summary-coverage_pct },|.
    lv_item = lv_item && |"lines":{ is_report-summary-lines },|.
    lv_item = lv_item && |"short_lines":{ is_report-summary-short_lines },|.
    lv_item = lv_item && |"covered_lines":{ is_report-summary-covered_lines }|.
    lv_item = lv_item && '}'.

    rv_json = rv_json && lv_item.
    rv_json = rv_json && ',"lines":['.

    LOOP AT is_report-lines INTO DATA(ls_line).
      IF sy-tabix > 1.
        rv_json = rv_json && ','.
      ENDIF.

      lv_flag = bool_json( ls_line-covered ).

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"requirement_id":"{ ls_line-requirement_id }",|.
      lv_item = lv_item && |"requested_qty":{ ls_line-requested_qty },|.
      lv_item = lv_item && |"allocated_qty":{ ls_line-allocated_qty },|.
      lv_item = lv_item && |"shortage_qty":{ ls_line-shortage_qty },|.
      lv_item = lv_item && |"coverage_pct":{ ls_line-coverage_pct },|.
      lv_item = lv_item && |"covered":{ lv_flag }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']}'.
  ENDMETHOD.

ENDCLASS.
