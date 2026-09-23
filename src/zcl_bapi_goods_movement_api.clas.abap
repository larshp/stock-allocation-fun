CLASS zcl_bapi_goods_movement_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_goods_movement_api.
ENDCLASS.

CLASS zcl_bapi_goods_movement_api IMPLEMENTATION.

  METHOD zif_goods_movement_api~create_movement.
    DATA ls_header TYPE bapi2017_gm_head_01.
    DATA ls_head_return TYPE bapi2017_gm_head_ret.
    DATA ls_item TYPE bapi2017_gm_item_create.
    DATA lt_items TYPE STANDARD TABLE OF bapi2017_gm_item_create
      WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    ls_header-pstng_date = is_header-posting_date.
    ls_header-doc_date = is_header-document_date.
    ls_header-ref_doc_no = is_header-reference_document.
    ls_header-header_txt = is_header-header_text.

    LOOP AT it_items INTO DATA(ls_movement_item).
      CLEAR ls_item.
      ls_item-material = ls_movement_item-material.
      ls_item-plant = ls_movement_item-plant.
      ls_item-stge_loc = ls_movement_item-storage_location.
      ls_item-move_type = ls_movement_item-movement_type.
      ls_item-entry_qnt = ls_movement_item-quantity.
      ls_item-entry_uom = ls_movement_item-entry_unit.
      ls_item-entry_uom_iso = ls_movement_item-entry_unit_iso.
      ls_item-move_plant = ls_movement_item-receiving_plant.
      ls_item-move_stloc = ls_movement_item-receiving_storage_location.
      ls_item-costcenter = ls_movement_item-cost_center.
      ls_item-orderid = ls_movement_item-order_id.
      ls_item-val_sales_ord = ls_movement_item-sales_order.
      ls_item-val_s_ord_item = ls_movement_item-sales_order_item.
      ls_item-reserv_no = ls_movement_item-reservation_number.
      ls_item-res_item = ls_movement_item-reservation_item.
      ls_item-res_type = ls_movement_item-reservation_record_type.
      ls_item-mvt_ind = ls_movement_item-movement_indicator.
      ls_item-batch = ls_movement_item-batch.
      ls_item-po_number = ls_movement_item-purchase_order.
      ls_item-po_item = ls_movement_item-purchase_order_item.
      APPEND ls_item TO lt_items.
    ENDLOOP.

    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = ls_header
        goodsmvt_code    = iv_gm_code
        testrun          = lv_test_run
      IMPORTING
        goodsmvt_headret = ls_head_return
      TABLES
        goodsmvt_item    = lt_items
        return           = lt_return.

    rs_result-material_document = ls_head_return-mat_doc.
    rs_result-fiscal_year = ls_head_return-doc_year.
    rs_result-is_successful = abap_true.

    LOOP AT lt_return INTO ls_return.
      APPEND VALUE #(
        type    = ls_return-type
        message = ls_return-message ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_goods_movement_api~cancel_movement.
    DATA ls_head_return TYPE bapi2017_gm_head_ret.
    DATA ls_item TYPE bapi2017_gm_item_04.
    DATA lt_items TYPE STANDARD TABLE OF bapi2017_gm_item_04
      WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      CLEAR ls_item.
      ls_item-matdoc_item = lv_item_number.
      APPEND ls_item TO lt_items.
    ENDLOOP.

    CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
      EXPORTING
        materialdocument    = iv_material_document
        matdocumentyear     = iv_fiscal_year
        goodsmvt_pstng_date = iv_posting_date
      IMPORTING
        goodsmvt_headret    = ls_head_return
      TABLES
        goodsmvt_matdocitem = lt_items
        return              = lt_return.

    rs_result-material_document = ls_head_return-mat_doc.
    rs_result-fiscal_year = ls_head_return-doc_year.
    rs_result-is_successful = abap_true.

    LOOP AT lt_return INTO ls_return.
      APPEND VALUE #(
        type    = ls_return-type
        message = ls_return-message ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_goods_movement_api~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.

    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_goods_movement_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
