CLASS zcl_alloc_export_alloc_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_result      TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_export_alloc_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.

    LOOP AT it_result INTO DATA(ls_result).
      IF sy-tabix > 1.
        rv_json = rv_json && ','.
      ENDIF.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"requirement_id":"{ ls_result-requirement_id }",|.
      lv_item = lv_item && '"allocations":['.

      lv_first = abap_true.

      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        IF lv_first = abap_false.
          lv_item = lv_item && ','.
        ENDIF.
        lv_first = abap_false.

        lv_item = lv_item && '{'.
        lv_item = lv_item && |"matnr":"{ ls_allocation-matnr }",|.
        lv_item = lv_item && |"lgort":"{ ls_allocation-lgort }",|.
        lv_item = lv_item && |"charg":"{ ls_allocation-charg }",|.
        lv_item = lv_item && |"quantity":{ ls_allocation-quantity }|.
        lv_item = lv_item && '}'.
      ENDLOOP.

      lv_item = lv_item && ']}'.
      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
