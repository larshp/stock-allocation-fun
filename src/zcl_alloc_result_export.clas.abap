"! Run result export - serializes an allocation result to a JSON string
"! so it can be handed to external systems or stored as a log.
CLASS zcl_alloc_result_export DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    "! Serialize allocations to a simple JSON array string
    CLASS-METHODS to_json
      IMPORTING
        it_allocations TYPE zcl_stock_allocator=>tt_allocations
      RETURNING
        VALUE(rv_json) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_alloc_result_export IMPLEMENTATION.


  METHOD to_json.
    DATA lv_first TYPE abap_bool.
    DATA lv_row TYPE string.
    DATA lv_qty_req_s TYPE string.
    DATA lv_qty_alloc_s TYPE string.

    rv_json = '['.
    LOOP AT it_allocations INTO DATA(ls_alloc).
      IF lv_first = abap_true.
        rv_json = rv_json && ','.
      ENDIF.
      lv_first = abap_true.

      " escape double quotes in text fields (defensive; vbeln/matnr are
      " alphanumeric but never contain quotes in practice)
      lv_qty_req_s = |{ ls_alloc-qty_req }|.
      lv_qty_alloc_s = |{ ls_alloc-qty_alloc }|.
      CONCATENATE '"vbeln": "' ls_alloc-vbeln
        '", "posnr": "' ls_alloc-posnr
        '", "matnr": "' ls_alloc-matnr
        '", "werks": "' ls_alloc-werks
        '", "lgort": "' ls_alloc-lgort
        '", "qty_req": ' lv_qty_req_s
        ', "qty_alloc": ' lv_qty_alloc_s ' }'
        INTO lv_row.
      rv_json = rv_json && '{ ' && lv_row.
    ENDLOOP.
    rv_json = rv_json && ']'.
  ENDMETHOD.


ENDCLASS.
