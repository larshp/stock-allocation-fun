CLASS zcl_alloc_ship_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_lines       TYPE zcl_alloc_shipment=>ty_line_tt
      RETURNING
        VALUE(rv_json) TYPE string.

ENDCLASS.


CLASS zcl_alloc_ship_json IMPLEMENTATION.

  METHOD build.
    DATA lv_item  TYPE string.
    DATA lv_first TYPE abap_bool.

    rv_json = '['.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_ship).
      IF lv_first = abap_false.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_false.

      CLEAR lv_item.
      lv_item = '{'.
      lv_item = lv_item && |"shipment":{ ls_ship-shipment },|.
      lv_item = lv_item && |"lgort":"{ ls_ship-lgort }",|.
      lv_item = lv_item && |"positions":{ ls_ship-positions },|.
      lv_item = lv_item && |"quantity":{ ls_ship-quantity }|.
      lv_item = lv_item && '}'.

      rv_json = rv_json && lv_item.
    ENDLOOP.

    rv_json = rv_json && ']'.
  ENDMETHOD.

ENDCLASS.
