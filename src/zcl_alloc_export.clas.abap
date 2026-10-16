CLASS zcl_alloc_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS run_overview_json
      IMPORTING
        it_overview    TYPE zcl_alloc_run_report=>ty_overview_tt
      RETURNING
        VALUE(rv_json) TYPE string.

    METHODS material_overview_json
      IMPORTING
        it_overview    TYPE zcl_alloc_material_report=>ty_material_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_export IMPLEMENTATION.

  METHOD run_overview_json.
    DATA lv_item TYPE string.

    rv_json = '['.

    LOOP AT it_overview INTO DATA(ls_overview).
      IF sy-tabix > 1.
        rv_json = rv_json && ','.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"run_id":"{ ls_overview-run_id }",|.
      lv_item = lv_item && |"matnr":"{ ls_overview-matnr }",|.
      lv_item = lv_item && |"werks":"{ ls_overview-werks }",|.
      lv_item = lv_item && |"status":"{ ls_overview-status }",|.
      lv_item = lv_item && |"item_count":{ ls_overview-item_count },|.
      lv_item = lv_item && |"requested_qty":{ ls_overview-requested_qty },|.
      lv_item = lv_item && |"allocated_qty":{ ls_overview-allocated_qty },|.
      lv_item = lv_item && |"shortage_qty":{ ls_overview-shortage_qty },|.
      lv_item = lv_item && |"coverage_pct":{ ls_overview-coverage_pct }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

  METHOD material_overview_json.
    DATA lv_item TYPE string.

    rv_json = '['.

    LOOP AT it_overview INTO DATA(ls_overview).
      IF sy-tabix > 1.
        rv_json = rv_json && ','.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"matnr":"{ ls_overview-matnr }",|.
      lv_item = lv_item && |"werks":"{ ls_overview-werks }",|.
      lv_item = lv_item && |"run_count":{ ls_overview-run_count },|.
      lv_item = lv_item && |"item_count":{ ls_overview-item_count },|.
      lv_item = lv_item && |"positions":{ ls_overview-positions },|.
      lv_item = lv_item && |"requested_qty":{ ls_overview-requested_qty },|.
      lv_item = lv_item && |"allocated_qty":{ ls_overview-allocated_qty },|.
      lv_item = lv_item && |"shortage_qty":{ ls_overview-shortage_qty },|.
      lv_item = lv_item && |"coverage_pct":{ ls_overview-coverage_pct }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
