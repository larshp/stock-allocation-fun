CLASS zcl_alloc_cost_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_result      TYPE zcl_alloc_cost=>ty_result
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_cost_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '{'.
    rv_json = rv_json && '"lines":['.

    lv_first = abap_true.

    LOOP AT is_result-lines INTO DATA(ls_line).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"werks":"{ ls_line-werks }",|.
      lv_item = lv_item && |"taken":{ ls_line-taken },|.
      lv_item = lv_item && |"cost":{ ls_line-cost }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && '],'.
    rv_json = rv_json && |"total_cost":{ is_result-total_cost },|.
    rv_json = rv_json && |"remaining":{ is_result-remaining }|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
