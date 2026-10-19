CLASS zcl_bapi_preq_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_purchase_requisition_api.

    CLASS-METHODS ensure_create_preq_number
      IMPORTING
        iv_test_run TYPE abap_bool
      CHANGING
        cs_result   TYPE zif_purchase_requisition_api=>ty_result.
ENDCLASS.

CLASS zcl_bapi_preq_api IMPLEMENTATION.

  METHOD zif_purchase_requisition_api~read_items.
    DATA lt_items TYPE STANDARD TABLE OF bapimereqitem WITH DEFAULT KEY.
    DATA lt_accounts TYPE STANDARD TABLE OF bapimereqaccount
      WITH DEFAULT KEY.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.

    rs_result-requisition_number = iv_requisition_number.
    rs_result-bapi_was_called = abap_true.

    CALL FUNCTION 'BAPI_PR_GETDETAIL'
      EXPORTING
        number    = iv_requisition_number
      TABLES
        return    = lt_return
        pritem    = lt_items
        praccount = lt_accounts.

    rs_result-is_successful = abap_true.
    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE lt_accounts INTO DATA(ls_account)
        WITH KEY preq_item = ls_item-preq_item.
      IF sy-subrc <> 0.
        CLEAR ls_account.
      ENDIF.
      APPEND VALUE #(
        item_number                 = ls_item-preq_item
        short_text                  = ls_item-short_text
        material                    = ls_item-material
        plant                       = ls_item-plant
        storage_location            = ls_item-store_loc
        quantity                    = ls_item-quantity
        unit                        = ls_item-unit
        delivery_date               = ls_item-deliv_date
        purchasing_group            = ls_item-pur_group
        purchasing_org              = ls_item-purch_org
        source_vendor               = ls_item-fixed_vend
        source_info_record          = ls_item-info_rec
        source_agreement            = ls_item-agreement
        source_agreement_item       = ls_item-agmt_item
        account_assignment_category = ls_item-acctasscat
        deletion_indicator          = ls_item-delete_ind
        processing_status           = ls_item-proc_stat
        release_indicator           = ls_item-rel_ind
        release_status              = ls_item-rel_status
        ordered_quantity            = ls_item-ordered
        po_number                   = ls_item-po_number
        po_item                     = ls_item-po_item
        is_fixed                    = xsdbool( ls_item-fixed = abap_true )
        is_closed                   = xsdbool( ls_item-closed = abap_true )
        wbs_element                 = ls_account-wbs_element )
        TO rs_result-requisition_items.
    ENDLOOP.

    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_purchase_requisition_api~create_requisition.
    DATA ls_header TYPE bapimereqheader.
    DATA ls_headerx TYPE bapimereqheaderx.
    DATA lt_items TYPE zcl_bapi_preq_item_mapper=>ty_bapi_items.
    DATA lt_itemsx TYPE zcl_bapi_preq_item_mapper=>ty_bapi_item_flags.
    DATA lt_accounts TYPE zcl_bapi_preq_item_mapper=>ty_bapi_accounts.
    DATA lt_accountsx TYPE zcl_bapi_preq_item_mapper=>ty_bapi_account_flags.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    ls_header-pr_type = is_request-requisition_type.
    ls_headerx-pr_type = abap_true.

    zcl_bapi_preq_item_mapper=>map_items(
      EXPORTING
        it_items         = is_request-items
      IMPORTING
        et_items         = lt_items
        et_item_flags    = lt_itemsx
        et_accounts      = lt_accounts
        et_account_flags = lt_accountsx ).

    IF is_request-is_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
    rs_result-submitted_items = is_request-items.

    CALL FUNCTION 'BAPI_PR_CREATE'
      EXPORTING
        prheader   = ls_header
        prheaderx  = ls_headerx
        testrun    = lv_test_run
      IMPORTING
        number     = rs_result-requisition_number
      TABLES
        return     = lt_return
        pritem     = lt_items
        pritemx    = lt_itemsx
        praccount  = lt_accounts
        praccountx = lt_accountsx.

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

    ensure_create_preq_number(
      EXPORTING
        iv_test_run = is_request-is_test_run
      CHANGING
        cs_result   = rs_result ).
  ENDMETHOD.

  METHOD ensure_create_preq_number.
    IF iv_test_run = abap_true
        OR cs_result-is_successful <> abap_true
        OR cs_result-requisition_number IS NOT INITIAL.
      RETURN.
    ENDIF.

    cs_result-is_successful = abap_false.
    APPEND VALUE #(
      type    = 'E'
      message = 'BAPI_PR_CREATE returned no requisition number' )
      TO cs_result-messages.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~mark_items_deleted.
    DATA lt_items TYPE zcl_bapi_preq_item_mapper=>ty_bapi_items.
    DATA lt_itemsx TYPE zcl_bapi_preq_item_mapper=>ty_bapi_item_flags.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-requisition_number = iv_requisition_number.
    rs_result-submitted_item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    rs_result-bapi_was_called = abap_true.
    zcl_bapi_preq_item_mapper=>map_deleted_items(
      EXPORTING
        it_item_numbers = it_item_numbers
      IMPORTING
        et_items        = lt_items
        et_item_flags   = lt_itemsx ).

    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        number  = iv_requisition_number
        testrun = lv_test_run
      TABLES
        return  = lt_return
        pritem  = lt_items
        pritemx = lt_itemsx.

    rs_result-is_successful = abap_true.
    LOOP AT lt_return INTO DATA(ls_return).
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

  METHOD zif_purchase_requisition_api~change_items.
    DATA lt_items TYPE zcl_bapi_preq_item_mapper=>ty_bapi_items.
    DATA lt_itemsx TYPE zcl_bapi_preq_item_mapper=>ty_bapi_item_flags.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-requisition_number = iv_requisition_number.
    rs_result-submitted_item_updates = it_item_updates.
    rs_result-is_test_run = iv_test_run.
    rs_result-bapi_was_called = abap_true.
    zcl_bapi_preq_item_mapper=>map_item_updates(
      EXPORTING
        it_item_updates = it_item_updates
      IMPORTING
        et_items        = lt_items
        et_item_flags   = lt_itemsx ).

    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.
    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        number  = iv_requisition_number
        testrun = lv_test_run
      TABLES
        return  = lt_return
        pritem  = lt_items
        pritemx = lt_itemsx.

    rs_result-is_successful = abap_true.
    LOOP AT lt_return INTO DATA(ls_return).
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
