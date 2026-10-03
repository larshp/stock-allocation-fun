CLASS zcl_bapi_stock_xfer_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_transfer_order_api.
ENDCLASS.

CLASS zcl_bapi_stock_xfer_api IMPLEMENTATION.

  METHOD zif_stock_transfer_order_api~create_order.
    DATA ls_header TYPE bapimepoheader.
    DATA ls_headerx TYPE bapimepoheaderx.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_itemx TYPE bapimepoitemx.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapimepoitemx WITH DEFAULT KEY.
    DATA ls_schedule TYPE bapimeposchedule.
    DATA lt_schedules TYPE STANDARD TABLE OF bapimeposchedule
      WITH DEFAULT KEY.
    DATA ls_schedulex TYPE bapimeposchedulx.
    DATA lt_schedulesx TYPE STANDARD TABLE OF bapimeposchedulx
      WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    ls_header-doc_type = is_request-document_type.
    ls_header-comp_code = is_request-company_code.
    ls_header-purch_org = is_request-purchasing_org.
    ls_header-pur_group = is_request-purchasing_group.
    ls_headerx-doc_type = abap_true.
    ls_headerx-comp_code = abap_true.
    ls_headerx-purch_org = abap_true.
    ls_headerx-pur_group = abap_true.

    LOOP AT is_request-items INTO DATA(ls_request_item).
      CLEAR: ls_item, ls_itemx, ls_schedule, ls_schedulex.
      ls_item-po_item = ls_request_item-item_number.
      ls_item-material = ls_request_item-material.
      ls_item-batch = ls_request_item-batch.
      ls_item-plant = ls_request_item-receiving_plant.
      ls_item-stge_loc = ls_request_item-receiving_storage_loc.
      ls_item-suppl_stloc = ls_request_item-supplying_storage_loc.
      ls_item-item_cat = zcl_stock_xfer_order_svc=>c_item_category.
      ls_item-suppl_plnt = ls_request_item-supplying_plant.
      ls_item-quantity = ls_request_item-quantity.
      ls_item-po_unit = ls_request_item-unit.
      ls_itemx-po_item = ls_request_item-item_number.
      ls_itemx-po_itemx = abap_true.
      ls_itemx-material = abap_true.
      IF ls_request_item-batch IS NOT INITIAL.
        ls_itemx-batch = abap_true.
      ENDIF.
      ls_itemx-plant = abap_true.
      IF ls_request_item-receiving_storage_loc IS NOT INITIAL.
        ls_itemx-stge_loc = abap_true.
      ENDIF.
      IF ls_request_item-supplying_storage_loc IS NOT INITIAL.
        ls_itemx-suppl_stloc = abap_true.
      ENDIF.
      ls_itemx-item_cat = abap_true.
      ls_itemx-suppl_plnt = abap_true.
      ls_itemx-quantity = abap_true.
      ls_itemx-po_unit = abap_true.

      ls_schedule-po_item = ls_request_item-item_number.
      ls_schedule-sched_line = '0001'.
      ls_schedule-delivery_date = ls_request_item-delivery_date.
      ls_schedule-quantity = ls_request_item-quantity.
      ls_schedulex-po_item = ls_request_item-item_number.
      ls_schedulex-po_itemx = abap_true.
      ls_schedulex-sched_line = '0001'.
      ls_schedulex-sched_linex = abap_true.
      ls_schedulex-delivery_date = abap_true.
      ls_schedulex-quantity = abap_true.

      APPEND ls_item TO lt_items.
      APPEND ls_itemx TO lt_itemsx.
      APPEND ls_schedule TO lt_schedules.
      APPEND ls_schedulex TO lt_schedulesx.
    ENDLOOP.

    IF is_request-is_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    CALL FUNCTION 'BAPI_PO_CREATE1'
      EXPORTING
        poheader         = ls_header
        poheaderx        = ls_headerx
        testrun          = lv_test_run
      IMPORTING
        exppurchaseorder = rs_result-purchase_order_number
      TABLES
        return           = lt_return
        poitem           = lt_items
        poitemx          = lt_itemsx
        poschedule       = lt_schedules
        poschedulex      = lt_schedulesx.

    rs_result-is_successful = abap_true.
    LOOP AT lt_return INTO ls_return.
      APPEND VALUE #(
        type       = ls_return-type
        id         = ls_return-id
        number     = ls_return-number
        message    = ls_return-message
        message_v1 = ls_return-message_v1
        message_v2 = ls_return-message_v2
        message_v3 = ls_return-message_v3
        message_v4 = ls_return-message_v4
        parameter  = ls_return-parameter
        row        = ls_return-row
        field      = ls_return-field
        system     = ls_return-system
        log_no     = ls_return-log_no
        log_msg_no = ls_return-log_msg_no ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~mark_items_for_deletion.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_itemx TYPE bapimepoitemx.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapimepoitemx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      CLEAR: ls_item, ls_itemx.
      ls_item-po_item = lv_item_number.
      ls_item-delete_ind = abap_true.
      ls_itemx-po_item = lv_item_number.
      ls_itemx-po_itemx = abap_true.
      ls_itemx-delete_ind = abap_true.
      APPEND ls_item TO lt_items.
      APPEND ls_itemx TO lt_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = iv_purchase_order
      TABLES
        return        = lt_return
        poitem        = lt_items
        poitemx       = lt_itemsx.

    rs_result-is_successful = abap_true.
    LOOP AT lt_return INTO ls_return.
      APPEND VALUE #(
        type       = ls_return-type
        id         = ls_return-id
        number     = ls_return-number
        message    = ls_return-message
        message_v1 = ls_return-message_v1
        message_v2 = ls_return-message_v2
        message_v3 = ls_return-message_v3
        message_v4 = ls_return-message_v4
        parameter  = ls_return-parameter
        row        = ls_return-row
        field      = ls_return-field
        system     = ls_return-system
        log_no     = ls_return-log_no
        log_msg_no = ls_return-log_msg_no ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~mark_items_delivery_complete.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_itemx TYPE bapimepoitemx.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapimepoitemx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      CLEAR: ls_item, ls_itemx.
      ls_item-po_item = lv_item_number.
      ls_item-no_more_gr = abap_true.
      ls_itemx-po_item = lv_item_number.
      ls_itemx-po_itemx = abap_true.
      ls_itemx-no_more_gr = abap_true.
      APPEND ls_item TO lt_items.
      APPEND ls_itemx TO lt_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = iv_purchase_order
      TABLES
        return        = lt_return
        poitem        = lt_items
        poitemx       = lt_itemsx.

    rs_result-is_successful = abap_true.
    LOOP AT lt_return INTO ls_return.
      APPEND VALUE #(
        type       = ls_return-type
        id         = ls_return-id
        number     = ls_return-number
        message    = ls_return-message
        message_v1 = ls_return-message_v1
        message_v2 = ls_return-message_v2
        message_v3 = ls_return-message_v3
        message_v4 = ls_return-message_v4
        parameter  = ls_return-parameter
        row        = ls_return-row
        field      = ls_return-field
        system     = ls_return-system
        log_no     = ls_return-log_no
        log_msg_no = ls_return-log_msg_no ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    rs_result-message-type = ls_return-type.
    rs_result-message-id = ls_return-id.
    rs_result-message-number = ls_return-number.
    rs_result-message-message = ls_return-message.
    rs_result-message-message_v1 = ls_return-message_v1.
    rs_result-message-message_v2 = ls_return-message_v2.
    rs_result-message-message_v3 = ls_return-message_v3.
    rs_result-message-message_v4 = ls_return-message_v4.
    rs_result-message-parameter = ls_return-parameter.
    rs_result-message-row = ls_return-row.
    rs_result-message-field = ls_return-field.
    rs_result-message-system = ls_return-system.
    rs_result-message-log_no = ls_return-log_no.
    rs_result-message-log_msg_no = ls_return-log_msg_no.
    rs_result-is_successful = abap_true.
    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_transfer_order_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
