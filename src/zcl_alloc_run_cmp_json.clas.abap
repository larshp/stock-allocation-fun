CLASS zcl_alloc_run_cmp_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_run_compare=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_run_cmp_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_change).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"run_id":"{ ls_change-run_id }",|.
      lv_item = lv_item && |"matnr":"{ ls_change-matnr }",|.
      lv_item = lv_item && |"change_type":"{ ls_change-change_type }",|.
      lv_item = lv_item && |"old_coverage":{ ls_change-old_coverage },|.
      lv_item = lv_item && |"new_coverage":{ ls_change-new_coverage }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
