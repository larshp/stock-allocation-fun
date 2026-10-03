CLASS zcl_bapi_sales_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_unit_converter      TYPE REF TO zif_material_uom_converter OPTIONAL
        io_delivery_repository TYPE REF TO zif_sales_order_delivery_repo
          OPTIONAL.

    INTERFACES zif_sales_order_api.

  PRIVATE SECTION.
    DATA mo_unit_converter TYPE REF TO zif_material_uom_converter.
    DATA mo_delivery_repository TYPE REF TO zif_sales_order_delivery_repo.
ENDCLASS.

CLASS zcl_bapi_sales_order_api IMPLEMENTATION.

  METHOD constructor.
    IF io_unit_converter IS BOUND.
      mo_unit_converter = io_unit_converter.
    ELSE.
      mo_unit_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.

    IF io_delivery_repository IS BOUND.
      mo_delivery_repository = io_delivery_repository.
    ELSE.
      mo_delivery_repository = NEW zcl_sales_order_delivery_repo( ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~read_order.
    DATA ls_view TYPE bapisdview.
    DATA ls_sales_document TYPE bapivbeln.
    DATA lt_sales_documents TYPE STANDARD TABLE OF bapivbeln
      WITH DEFAULT KEY.
    DATA ls_bapi_item TYPE bapisdit.
    DATA lt_bapi_items TYPE STANDARD TABLE OF bapisdit
      WITH DEFAULT KEY.
    DATA lt_delivery_items TYPE zif_sales_order_delivery_repo=>ty_items.
    DATA lo_quantity_calculator TYPE REF TO zcl_sales_order_qty_calc.

    ls_view-item = abap_true.
    ls_sales_document-vbeln = iv_sales_document.
    APPEND ls_sales_document TO lt_sales_documents.

    lt_delivery_items = mo_delivery_repository->get_order_items(
      iv_sales_document = iv_sales_document ).
    lo_quantity_calculator = NEW zcl_sales_order_qty_calc( ).

    CALL FUNCTION 'BAPISDORDER_GETDETAILEDLIST'
      EXPORTING
        i_bapi_view     = ls_view
      TABLES
        sales_documents = lt_sales_documents
        order_items_out = lt_bapi_items.

    rs_result-order-sales_document = iv_sales_document.
    rs_result-is_successful = abap_true.
    LOOP AT lt_bapi_items INTO ls_bapi_item.
      IF ls_bapi_item-doc_number <> iv_sales_document
          OR ls_bapi_item-reason_rej IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_delivery_item_count) = 0.
      LOOP AT lt_delivery_items INTO DATA(ls_delivery_item)
        WHERE item_number = ls_bapi_item-itm_number.
        ADD 1 TO lv_delivery_item_count.
        IF ls_delivery_item-has_status = abap_false.
          rs_result-is_successful = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Cannot read sales order delivery quantities and status' )
            TO rs_result-messages.
        ENDIF.

        DATA(ls_item) = VALUE zif_sales_order_api=>ty_item(
          item_number            = ls_bapi_item-itm_number
          schedule_line          = ls_delivery_item-schedule_line
          has_confirmed_quantity = ls_delivery_item-has_schedule_line
          requested_date         = ls_delivery_item-requested_date
          material               = ls_bapi_item-material
          plant                  = ls_bapi_item-plant
          entry_unit             = ls_bapi_item-sales_unit
          sales_unit_numerator   = ls_bapi_item-sales_qty1
          sales_unit_denominator = ls_bapi_item-sales_qty2 ).

        IF ls_delivery_item-has_schedule_line = abap_true
            AND ls_delivery_item-requested_date IS INITIAL.
          rs_result-is_successful = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Sales order schedule line has no requested date' )
            TO rs_result-messages.
        ENDIF.

        IF ls_delivery_item-has_schedule_line = abap_true.
          ls_item-quantity = ls_delivery_item-ordered_quantity.
          ls_item-confirmed_quantity =
            ls_delivery_item-confirmed_quantity.
          ls_item-delivered_quantity = ls_delivery_item-delivered_quantity.
        ELSE.
          ls_item-quantity = ls_delivery_item-ordered_quantity.
          ls_item-delivered_quantity = ls_delivery_item-delivered_quantity.
        ENDIF.

        DATA(ls_open_quantity) =
          lo_quantity_calculator->calculate_open_quantity(
            iv_ordered_quantity   = ls_item-quantity
            iv_delivered_quantity = ls_item-delivered_quantity
            iv_delivery_status    = ls_delivery_item-delivery_status ).
        IF ls_open_quantity-is_successful = abap_true.
          ls_item-open_quantity = ls_open_quantity-open_quantity.
        ELSE.
          rs_result-is_successful = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Cannot calculate open sales order quantity' )
            TO rs_result-messages.
        ENDIF.

        IF ls_delivery_item-has_schedule_line = abap_true.
          DATA(ls_open_confirmed_quantity) =
            lo_quantity_calculator->calculate_open_quantity(
              iv_ordered_quantity   = ls_item-confirmed_quantity
              iv_delivered_quantity = ls_item-delivered_quantity
              iv_delivery_status    = ls_delivery_item-delivery_status ).
          IF ls_open_confirmed_quantity-is_successful = abap_true.
            ls_item-open_confirmed_quantity =
              ls_open_confirmed_quantity-open_quantity.
          ELSE.
            rs_result-is_successful = abap_false.
            APPEND VALUE #(
              type    = 'E'
              message = 'Cannot calculate open confirmed sales order quantity' )
              TO rs_result-messages.
          ENDIF.
        ENDIF.

        DATA(ls_conversion) = mo_unit_converter->convert_to_base(
          iv_material    = ls_item-material
          iv_quantity    = ls_item-quantity
          iv_source_unit = ls_item-entry_unit
          iv_numerator   = ls_bapi_item-sales_qty1
          iv_denominator = ls_bapi_item-sales_qty2 ).
        IF ls_conversion-is_successful = abap_true.
          ls_item-base_quantity = ls_conversion-base_quantity.
          ls_item-base_unit = ls_conversion-base_unit.

          DATA(ls_open_conversion) = mo_unit_converter->convert_to_base(
            iv_material    = ls_item-material
            iv_quantity    = ls_item-open_quantity
            iv_source_unit = ls_item-entry_unit
            iv_numerator   = ls_bapi_item-sales_qty1
            iv_denominator = ls_bapi_item-sales_qty2 ).
          IF ls_open_conversion-is_successful = abap_true.
            ls_item-open_base_quantity = ls_open_conversion-base_quantity.
          ELSE.
            rs_result-is_successful = abap_false.
            APPEND VALUE #(
              type    = 'E'
              message = 'Cannot convert open quantity to material base unit' )
              TO rs_result-messages.
          ENDIF.

          IF ls_delivery_item-has_schedule_line = abap_true.
            DATA(ls_confirmed_conversion) = mo_unit_converter->convert_to_base(
              iv_material    = ls_item-material
              iv_quantity    = ls_item-confirmed_quantity
              iv_source_unit = ls_item-entry_unit
              iv_numerator   = ls_bapi_item-sales_qty1
              iv_denominator = ls_bapi_item-sales_qty2 ).
            IF ls_confirmed_conversion-is_successful = abap_true.
              ls_item-confirmed_base_quantity =
                ls_confirmed_conversion-base_quantity.
            ELSE.
              rs_result-is_successful = abap_false.
              APPEND VALUE #(
                type    = 'E'
                message = 'Cannot convert confirmed quantity to material base unit' )
                TO rs_result-messages.
            ENDIF.

            DATA(ls_open_confirmed_conversion) =
              mo_unit_converter->convert_to_base(
                iv_material    = ls_item-material
                iv_quantity    = ls_item-open_confirmed_quantity
                iv_source_unit = ls_item-entry_unit
                iv_numerator   = ls_bapi_item-sales_qty1
                iv_denominator = ls_bapi_item-sales_qty2 ).
            IF ls_open_confirmed_conversion-is_successful = abap_true.
              ls_item-open_confirmed_base_quantity =
                ls_open_confirmed_conversion-base_quantity.
            ELSE.
              rs_result-is_successful = abap_false.
              APPEND VALUE #(
                type    = 'E'
                message = 'Cannot convert open confirmed quantity to material base unit' )
                TO rs_result-messages.
            ENDIF.
          ENDIF.
        ELSE.
          rs_result-is_successful = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Cannot convert sales quantity to material base unit' )
            TO rs_result-messages.
        ENDIF.
        APPEND ls_item TO rs_result-order-items.
      ENDLOOP.

      IF lv_delivery_item_count = 0.
        rs_result-is_successful = abap_false.
        APPEND VALUE #(
          type    = 'E'
          message = 'Cannot read sales order schedule lines' )
          TO rs_result-messages.
      ENDIF.
    ENDLOOP.

    IF rs_result-order-items IS INITIAL.
      rs_result-is_successful = abap_false.
      APPEND VALUE #(
        type    = 'W'
        message = 'Sales order returned no active item details' )
        TO rs_result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD zif_sales_order_api~create_order.
    DATA ls_header TYPE bapisdhd1.
    DATA ls_headerx TYPE bapisdhd1x.
    DATA ls_item TYPE bapisditm.
    DATA ls_itemx TYPE bapisditmx.
    DATA lt_items TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapisditmx WITH DEFAULT KEY.
    DATA ls_partner TYPE bapiparnr.
    DATA lt_partners TYPE STANDARD TABLE OF bapiparnr WITH DEFAULT KEY.
    DATA ls_schedule TYPE bapischdl.
    DATA ls_schedulex TYPE bapischdlx.
    DATA lt_schedules TYPE STANDARD TABLE OF bapischdl WITH DEFAULT KEY.
    DATA lt_schedulesx TYPE STANDARD TABLE OF bapischdlx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    ls_header-doc_type = is_order-order_type.
    ls_header-sales_org = is_order-sales_organization.
    ls_header-distr_chan = is_order-distribution_channel.
    ls_header-division = is_order-division.
    ls_header-purch_no_c = is_order-customer_purchase_order.
    ls_header-doc_date = is_order-document_date.

    ls_headerx-updateflag = 'I'.
    ls_headerx-doc_type = abap_true.
    ls_headerx-sales_org = abap_true.
    ls_headerx-distr_chan = abap_true.
    ls_headerx-division = abap_true.
    ls_headerx-purch_no_c = abap_true.
    ls_headerx-doc_date = abap_true.

    LOOP AT is_order-items INTO DATA(ls_order_item).
      CLEAR: ls_item, ls_itemx, ls_schedule, ls_schedulex.
      ls_item-itm_number = ls_order_item-item_number.
      ls_item-material = ls_order_item-material.
      ls_item-plant = ls_order_item-plant.
      ls_item-target_qty = ls_order_item-quantity.
      ls_item-sales_unit = ls_order_item-entry_unit.
      APPEND ls_item TO lt_items.

      ls_itemx-itm_number = ls_order_item-item_number.
      ls_itemx-updateflag = 'I'.
      ls_itemx-material = abap_true.
      ls_itemx-plant = abap_true.
      ls_itemx-target_qty = abap_true.
      ls_itemx-sales_unit = abap_true.
      APPEND ls_itemx TO lt_itemsx.

      ls_schedule-itm_number = ls_order_item-item_number.
      ls_schedule-sched_line = ls_order_item-schedule_line.
      ls_schedule-req_qty = ls_order_item-quantity.
      ls_schedule-req_date = ls_order_item-requested_date.
      APPEND ls_schedule TO lt_schedules.

      ls_schedulex-itm_number = ls_order_item-item_number.
      ls_schedulex-sched_line = ls_order_item-schedule_line.
      ls_schedulex-updateflag = 'I'.
      ls_schedulex-req_qty = abap_true.
      ls_schedulex-req_date = abap_true.
      APPEND ls_schedulex TO lt_schedulesx.
    ENDLOOP.

    ls_partner-partn_role = 'AG'.
    ls_partner-partn_numb = is_order-sold_to_party.
    APPEND ls_partner TO lt_partners.

    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in     = ls_header
        order_header_inx    = ls_headerx
        testrun             = lv_test_run
      IMPORTING
        salesdocument       = rs_result-sales_document
      TABLES
        return              = lt_return
        order_items_in      = lt_items
        order_items_inx     = lt_itemsx
        order_partners      = lt_partners
        order_schedules_in  = lt_schedules
        order_schedules_inx = lt_schedulesx.

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

  METHOD zif_sales_order_api~change_order.
    DATA ls_item TYPE bapisditm.
    DATA ls_itemx TYPE bapisditmx.
    DATA lt_items TYPE STANDARD TABLE OF bapisditm WITH DEFAULT KEY.
    DATA lt_itemsx TYPE STANDARD TABLE OF bapisditmx WITH DEFAULT KEY.
    DATA ls_schedule TYPE bapischdl.
    DATA ls_schedulex TYPE bapischdlx.
    DATA lt_schedules TYPE STANDARD TABLE OF bapischdl WITH DEFAULT KEY.
    DATA lt_schedulesx TYPE STANDARD TABLE OF bapischdlx WITH DEFAULT KEY.
    DATA ls_return TYPE bapiret2.
    DATA lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
    DATA lv_test_run TYPE c LENGTH 1.

    rs_result-sales_document = iv_sales_document.

    LOOP AT it_items INTO DATA(ls_order_item).
      CLEAR: ls_item, ls_itemx, ls_schedule, ls_schedulex.
      ls_item-itm_number = ls_order_item-item_number.
      ls_item-material = ls_order_item-material.
      ls_item-plant = ls_order_item-plant.
      ls_item-target_qty = ls_order_item-quantity.
      ls_item-sales_unit = ls_order_item-entry_unit.
      APPEND ls_item TO lt_items.

      ls_itemx-itm_number = ls_order_item-item_number.
      ls_itemx-updateflag = 'U'.
      ls_itemx-material = abap_true.
      ls_itemx-plant = abap_true.
      ls_itemx-target_qty = abap_true.
      ls_itemx-sales_unit = abap_true.
      APPEND ls_itemx TO lt_itemsx.

      ls_schedule-itm_number = ls_order_item-item_number.
      ls_schedule-sched_line = ls_order_item-schedule_line.
      ls_schedule-req_qty = ls_order_item-quantity.
      ls_schedule-req_date = ls_order_item-requested_date.
      APPEND ls_schedule TO lt_schedules.

      ls_schedulex-itm_number = ls_order_item-item_number.
      ls_schedulex-sched_line = ls_order_item-schedule_line.
      ls_schedulex-updateflag = 'U'.
      ls_schedulex-req_qty = abap_true.
      ls_schedulex-req_date = abap_true.
      APPEND ls_schedulex TO lt_schedulesx.
    ENDLOOP.

    IF iv_test_run = abap_true.
      lv_test_run = abap_true.
    ENDIF.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument   = iv_sales_document
        simulation      = lv_test_run
      TABLES
        return          = lt_return
        order_item_in   = lt_items
        order_item_inx  = lt_itemsx
        schedule_lines  = lt_schedules
        schedule_linesx = lt_schedulesx.

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

  METHOD zif_sales_order_api~commit.
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

  METHOD zif_sales_order_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
