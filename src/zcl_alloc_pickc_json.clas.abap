CLASS zcl_alloc_pickc_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_pick_confirm=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_pickc_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.
    DATA lv_flag  TYPE string.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_pick).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      lv_flag = 'false'.
      IF ls_pick-complete = abap_true.
        lv_flag = 'true'.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"index":{ ls_pick-index },|.
      lv_item = lv_item && |"planned":{ ls_pick-planned },|.
      lv_item = lv_item && |"confirmed":{ ls_pick-confirmed },|.
      lv_item = lv_item && |"difference":{ ls_pick-difference },|.
      lv_item = lv_item && |"complete":{ lv_flag }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
