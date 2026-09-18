CLASS zcl_alloc_diff_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_result      TYPE zcl_alloc_diff=>ty_result
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_diff_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item TYPE string.

    rv_json = '{"lines":['.

    LOOP AT is_result-lines INTO DATA(ls_line).
      IF sy-tabix > 1.
        rv_json = rv_json && ','.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"requirement_id":"{ ls_line-requirement_id }",|.
      lv_item = lv_item && |"old_qty":{ ls_line-old_qty },|.
      lv_item = lv_item && |"new_qty":{ ls_line-new_qty },|.
      lv_item = lv_item && |"delta_qty":{ ls_line-delta_qty },|.
      lv_item = lv_item && |"change_type":"{ ls_line-change_type }"|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && '],"summary":'.

    CLEAR lv_item.
    lv_item = '{'.
    lv_item = lv_item && |"added":{ is_result-summary-added },|.
    lv_item = lv_item && |"removed":{ is_result-summary-removed },|.
    lv_item = lv_item && |"changed":{ is_result-summary-changed },|.
    lv_item = lv_item && |"unchanged":{ is_result-summary-unchanged },|.
    lv_item = lv_item && |"old_total":{ is_result-summary-old_total },|.
    lv_item = lv_item && |"new_total":{ is_result-summary-new_total },|.
    lv_item = lv_item && |"delta_total":{ is_result-summary-delta_total }|.
    lv_item = lv_item && '}'.

    rv_json = rv_json && lv_item.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
