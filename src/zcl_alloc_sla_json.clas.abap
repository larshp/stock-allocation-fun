CLASS zcl_alloc_sla_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_result      TYPE zcl_alloc_sla=>ty_result
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_sla_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.
    DATA lv_flag  TYPE string.

    rv_json = '{'.
    rv_json = rv_json && |"total":{ is_result-total },|.
    rv_json = rv_json && |"on_time":{ is_result-on_time },|.
    rv_json = rv_json && |"breached":{ is_result-breached },|.
    rv_json = rv_json && |"compliance_pct":{ is_result-compliance_pct },|.
    rv_json = rv_json && '"lines":['.

    lv_first = abap_true.

    LOOP AT is_result-lines INTO DATA(ls_line).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      lv_flag = 'false'.
      IF ls_line-on_time = abap_true.
        lv_flag = 'true'.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"requirement_id":"{ ls_line-requirement_id }",|.
      lv_item = lv_item && |"lead_days":{ ls_line-lead_days },|.
      lv_item = lv_item && |"target_days":{ ls_line-target_days },|.
      lv_item = lv_item && |"on_time":{ lv_flag }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']}'.
  ENDMETHOD.

ENDCLASS.
