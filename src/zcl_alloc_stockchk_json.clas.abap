CLASS zcl_alloc_stockchk_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_issues      TYPE zcl_alloc_stock_check=>ty_issue_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_stockchk_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_issues INTO DATA(ls_issue).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"matnr":"{ ls_issue-matnr }",|.
      lv_item = lv_item && |"lgort":"{ ls_issue-lgort }",|.
      lv_item = lv_item && |"message":"{ ls_issue-message }"|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
