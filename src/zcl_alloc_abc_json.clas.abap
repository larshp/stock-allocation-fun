CLASS zcl_alloc_abc_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_abc=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_abc_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_class).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"matnr":"{ ls_class-matnr }",|.
      lv_item = lv_item && |"quantity":{ ls_class-quantity },|.
      lv_item = lv_item && |"share_pct":{ ls_class-share_pct },|.
      lv_item = lv_item && |"cum_pct":{ ls_class-cum_pct },|.
      lv_item = lv_item && |"class":"{ ls_class-class }"|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
