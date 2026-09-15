CLASS zcl_alloc_mplant_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_result      TYPE zcl_alloc_multi_plant=>ty_result
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_mplant_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '{'.
    rv_json = rv_json && '"plants":['.

    lv_first = abap_true.

    LOOP AT is_result-lines INTO DATA(ls_line).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"werks":"{ ls_line-werks }",|.
      lv_item = lv_item && |"quantity":{ ls_line-quantity }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && '],'.
    rv_json = rv_json && |"total":{ is_result-total },|.
    rv_json = rv_json && |"plant_count":{ is_result-plants }|.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
