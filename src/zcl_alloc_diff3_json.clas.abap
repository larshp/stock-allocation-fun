CLASS zcl_alloc_diff3_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_diff3=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_diff3_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"id":"{ ls_line-id }",|.
      lv_item = lv_item && |"base_qty":{ ls_line-base_qty },|.
      lv_item = lv_item && |"left_qty":{ ls_line-left_qty },|.
      lv_item = lv_item && |"right_qty":{ ls_line-right_qty },|.
      lv_item = lv_item && |"status":"{ ls_line-status }"|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
