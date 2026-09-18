CLASS zcl_alloc_plant_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_plant_report=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_plant_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_plant).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"werks":"{ ls_plant-werks }",|.
      lv_item = lv_item && |"lines":{ ls_plant-lines },|.
      lv_item = lv_item && |"requested_qty":{ ls_plant-requested_qty },|.
      lv_item = lv_item && |"allocated_qty":{ ls_plant-allocated_qty },|.
      lv_item = lv_item && |"shortage_qty":{ ls_plant-shortage_qty },|.
      lv_item = lv_item && |"coverage_pct":{ ls_plant-coverage_pct }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
