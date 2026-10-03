CLASS zcl_bapi_preq_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_purchase_requisition_api.
ENDCLASS.

CLASS zcl_bapi_preq_api IMPLEMENTATION.

  METHOD zif_purchase_requisition_api~create_requisition.
    DATA ls_header TYPE bapimereqheader.
    DATA ls_headerx TYPE bapimereqheaderx.
    DATA lt_items TYPE zcl_bapi_preq_item_mapper=>ty_bapi_items.
    DATA lt_itemsx TYPE zcl_bapi_preq_item_mapper=>ty_bapi_item_flags.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    ls_header-pr_type = is_request-requisition_type.
    ls_headerx-pr_type = abap_true.

    zcl_bapi_preq_item_mapper=>map_items(
      EXPORTING
        it_items      = is_request-items
      IMPORTING
        et_items      = lt_items
        et_item_flags = lt_itemsx ).

    IF is_request-is_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
    rs_result-submitted_items = is_request-items.

    CALL FUNCTION 'BAPI_PR_CREATE'
      EXPORTING
        prheader  = ls_header
        prheaderx = ls_headerx
        testrun   = lv_test_run
      IMPORTING
        number    = rs_result-requisition_number
      TABLES
        return    = lt_return
        pritem    = lt_items
        pritemx   = lt_itemsx.

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

  METHOD zif_purchase_requisition_api~commit.
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

  METHOD zif_purchase_requisition_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
