CLASS zcl_alloc_replen_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_result      TYPE zcl_alloc_replenishment=>ty_result
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_replen_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item TYPE string.

    rv_json = '{"proposals":['.

    LOOP AT it_result-proposals INTO DATA(ls_proposal).
      IF sy-tabix > 1.
        rv_json = rv_json && ','.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"matnr":"{ ls_proposal-matnr }",|.
      lv_item = lv_item && |"requirement_id":"{ ls_proposal-requirement_id }",|.
      lv_item = lv_item && |"shortage_qty":{ ls_proposal-shortage_qty },|.
      lv_item = lv_item && |"order_qty":{ ls_proposal-order_qty }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && '],"summary":'.

    CLEAR lv_item.
    lv_item = '{'.
    lv_item = lv_item && |"proposals":{ it_result-summary-proposals },|.
    lv_item = lv_item && |"shortage_qty":{ it_result-summary-shortage_qty },|.
    lv_item = lv_item && |"order_qty":{ it_result-summary-order_qty }|.
    lv_item = lv_item && '}'.

    rv_json = rv_json && lv_item.
    rv_json = rv_json && '}'.
  ENDMETHOD.

ENDCLASS.
