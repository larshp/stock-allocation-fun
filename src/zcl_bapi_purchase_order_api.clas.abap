CLASS zcl_bapi_purchase_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_purchase_order_api.
ENDCLASS.

CLASS zcl_bapi_purchase_order_api IMPLEMENTATION.

  METHOD zif_purchase_order_api~create_order.
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

    rs_result-submitted_items = is_request-items.
    ls_header-doc_type = is_request-document_type.
    ls_header-comp_code = is_request-company_code.
    ls_header-purch_org = is_request-purchasing_org.
    ls_header-pur_group = is_request-purchasing_group.
    ls_header-vendor = is_request-vendor.
    ls_header-doc_date = is_request-document_date.
    ls_headerx-doc_type = abap_true.
    ls_headerx-comp_code = abap_true.
    ls_headerx-purch_org = abap_true.
    ls_headerx-pur_group = abap_true.
    ls_headerx-vendor = abap_true.
    ls_headerx-doc_date = abap_true.

    LOOP AT is_request-items INTO DATA(ls_request_item).
      CLEAR: ls_item, ls_itemx, ls_schedule, ls_schedulex.
      ls_item-po_item = ls_request_item-item_number.
      ls_item-material = ls_request_item-material.
      ls_item-plant = ls_request_item-plant.
      ls_item-stge_loc = ls_request_item-storage_location.
      ls_item-quantity = ls_request_item-quantity.
      ls_item-po_unit = ls_request_item-unit.
      ls_item-info_rec = ls_request_item-source_info_record.
      ls_item-agreement = ls_request_item-source_agreement.
      ls_item-agmt_item = ls_request_item-source_agreement_item.
      ls_item-preq_no = ls_request_item-purchase_requisition.
      ls_item-preq_item = ls_request_item-requisition_item.

      ls_itemx-po_item = ls_request_item-item_number.
      ls_itemx-po_itemx = abap_true.
      ls_itemx-material = abap_true.
      ls_itemx-plant = abap_true.
      ls_itemx-quantity = abap_true.
      ls_itemx-po_unit = abap_true.
      IF ls_request_item-storage_location IS NOT INITIAL.
        ls_itemx-stge_loc = abap_true.
      ENDIF.
      IF ls_request_item-source_info_record IS NOT INITIAL.
        ls_itemx-info_rec = abap_true.
      ENDIF.
      IF ls_request_item-source_agreement IS NOT INITIAL.
        ls_itemx-agreement = abap_true.
        ls_itemx-agmt_item = abap_true.
      ENDIF.
      IF ls_request_item-purchase_requisition IS NOT INITIAL.
        ls_itemx-preq_no = abap_true.
        ls_itemx-preq_item = abap_true.
      ENDIF.

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
      DATA(ls_message) = VALUE zif_purchase_order_api=>ty_message(
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
        system     = ls_return-system ).
      IF ls_return-row > 0.
        READ TABLE is_request-items INDEX ls_return-row
          INTO DATA(ls_message_item).
        IF sy-subrc = 0.
          ls_message-item_number = ls_message_item-item_number.
          ls_message-source_request_id =
            ls_message_item-source_request_id.
        ENDIF.
      ENDIF.
      APPEND ls_message TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_purchase_order_api~read_order.
    DATA ls_header TYPE bapimepoheader.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_schedule TYPE bapimeposchedule.
    DATA lt_schedules TYPE STANDARD TABLE OF bapimeposchedule
      WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
      EXPORTING
        purchaseorder = iv_purchase_order_number
      IMPORTING
        poheader      = ls_header
      TABLES
        return        = lt_return
        poitem        = lt_items
        poschedule    = lt_schedules.

    DATA(lv_returned_purchase_order) = ls_header-po_number.
    IF lv_returned_purchase_order IS INITIAL.
      lv_returned_purchase_order = iv_purchase_order_number.
    ENDIF.
    rs_result-purchase_order_number = lv_returned_purchase_order.
    rs_result-header = VALUE #(
      purchase_order_number = lv_returned_purchase_order
      document_type         = ls_header-doc_type
      company_code          = ls_header-comp_code
      purchasing_org        = ls_header-purch_org
      purchasing_group      = ls_header-pur_group
      vendor                = ls_header-vendor
      document_date         = ls_header-doc_date ).

    LOOP AT lt_items INTO ls_item.
      APPEND VALUE #(
        item_number       = ls_item-po_item
        material          = ls_item-material
        plant             = ls_item-plant
        storage_location  = ls_item-stge_loc
        ordered_quantity  = ls_item-quantity
        unit              = ls_item-po_unit
        is_deleted        = xsdbool( ls_item-delete_ind = abap_true )
        delivery_complete = xsdbool( ls_item-no_more_gr = abap_true ) )
        TO rs_result-items.
    ENDLOOP.

    LOOP AT lt_schedules INTO ls_schedule.
      APPEND VALUE #(
        item_number   = ls_schedule-po_item
        schedule_line = ls_schedule-sched_line
        delivery_date = ls_schedule-delivery_date
        quantity      = ls_schedule-quantity ) TO rs_result-schedules.
    ENDLOOP.

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
        system     = ls_return-system ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_purchase_order_api~mark_items_for_deletion.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_itemx TYPE bapimepoitemx.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapimepoitemx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-purchase_order_number = iv_purchase_order_number.
    rs_result-submitted_item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
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
        purchaseorder = iv_purchase_order_number
        testrun       = lv_test_run
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
        system     = ls_return-system ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_purchase_order_api~mark_items_delivery_complete.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_itemx TYPE bapimepoitemx.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapimepoitemx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-purchase_order_number = iv_purchase_order_number.
    rs_result-submitted_item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
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
        purchaseorder = iv_purchase_order_number
        testrun       = lv_test_run
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
        system     = ls_return-system ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_purchase_order_api~change_schedules.
    DATA ls_schedule TYPE bapimeposchedule.
    DATA lt_schedules TYPE STANDARD TABLE OF bapimeposchedule
      WITH DEFAULT KEY.
    DATA ls_schedulex TYPE bapimeposchedulx.
    DATA lt_schedulesx TYPE STANDARD TABLE OF bapimeposchedulx
      WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-purchase_order_number = iv_purchase_order_number.
    rs_result-submitted_schedules = it_schedule_changes.
    rs_result-is_test_run = iv_test_run.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
    LOOP AT it_schedule_changes INTO DATA(ls_change).
      CLEAR: ls_schedule, ls_schedulex.
      ls_schedule-po_item = ls_change-item_number.
      ls_schedule-sched_line = ls_change-schedule_line.
      ls_schedulex-po_item = ls_change-item_number.
      ls_schedulex-po_itemx = abap_true.
      ls_schedulex-sched_line = ls_change-schedule_line.
      ls_schedulex-sched_linex = abap_true.
      IF ls_change-change_quantity = abap_true.
        ls_schedule-quantity = ls_change-quantity.
        ls_schedulex-quantity = abap_true.
      ENDIF.
      IF ls_change-change_delivery_date = abap_true.
        ls_schedule-delivery_date = ls_change-delivery_date.
        ls_schedulex-delivery_date = abap_true.
      ENDIF.
      APPEND ls_schedule TO lt_schedules.
      APPEND ls_schedulex TO lt_schedulesx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = iv_purchase_order_number
        testrun       = lv_test_run
      TABLES
        return        = lt_return
        poschedule    = lt_schedules
        poschedulex   = lt_schedulesx.

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
        system     = ls_return-system ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_purchase_order_api~change_item_quantities.
    DATA ls_item TYPE bapimepoitem.
    DATA lt_items TYPE STANDARD TABLE OF bapimepoitem WITH DEFAULT KEY.
    DATA ls_itemx TYPE bapimepoitemx.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapimepoitemx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-purchase_order_number = iv_purchase_order_number.
    rs_result-submitted_item_quantities = it_item_changes.
    rs_result-is_test_run = iv_test_run.
    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
    LOOP AT it_item_changes INTO DATA(ls_change).
      CLEAR: ls_item, ls_itemx.
      ls_item-po_item = ls_change-item_number.
      ls_item-quantity = ls_change-quantity.
      ls_itemx-po_item = ls_change-item_number.
      ls_itemx-po_itemx = abap_true.
      ls_itemx-quantity = abap_true.
      APPEND ls_item TO lt_items.
      APPEND ls_itemx TO lt_itemsx.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        purchaseorder = iv_purchase_order_number
        testrun       = lv_test_run
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
        system     = ls_return-system ) TO rs_result-messages.
      IF ls_return-type = 'A'
          OR ls_return-type = 'E'
          OR ls_return-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_purchase_order_api~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    rs_result-is_successful = abap_true.
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
    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_purchase_order_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
