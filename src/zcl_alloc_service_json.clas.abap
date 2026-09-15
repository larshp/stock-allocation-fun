CLASS zcl_alloc_service_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_levels      TYPE zcl_alloc_service_level=>ty_level_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_service_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_levels INTO DATA(ls_level).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"matnr":"{ ls_level-matnr }",|.
      lv_item = lv_item && |"requested_qty":{ ls_level-requested_qty },|.
      lv_item = lv_item && |"allocated_qty":{ ls_level-allocated_qty },|.
      lv_item = lv_item && |"shortage_qty":{ ls_level-shortage_qty },|.
      lv_item = lv_item && |"fill_rate_pct":{ ls_level-fill_rate_pct },|.
      lv_item = lv_item && |"lines":{ ls_level-lines }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
