CLASS zcl_sales_order_delivery_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_sales_order_delivery_repo.
ENDCLASS.

CLASS zcl_sales_order_delivery_repo IMPLEMENTATION.

  METHOD zif_sales_order_delivery_repo~get_order_items.
    DATA(lt_items) = zif_sales_order_delivery_repo~get_orders_items(
      VALUE zif_sales_order_delivery_repo=>ty_sales_documents(
        ( iv_sales_document ) ) ).

    LOOP AT lt_items INTO DATA(ls_item).
      APPEND CORRESPONDING #( ls_item ) TO rt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_sales_order_delivery_repo~get_orders_items.
    DATA lt_order_items TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    DATA lt_statuses TYPE STANDARD TABLE OF vbup WITH EMPTY KEY.
    DATA lt_schedules TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.
    DATA ls_status TYPE vbup.
    DATA lv_has_status TYPE abap_bool.

    IF it_sales_documents IS INITIAL.
      RETURN.
    ENDIF.

    SELECT vbeln, posnr, kwmeng, vsmng
      FROM vbap
      FOR ALL ENTRIES IN @it_sales_documents
      WHERE vbeln = @it_sales_documents-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_order_items.
    SORT lt_order_items BY vbeln posnr.

    SELECT vbeln, posnr, lfsta
      FROM vbup
      FOR ALL ENTRIES IN @it_sales_documents
      WHERE vbeln = @it_sales_documents-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_statuses.

    SELECT vbeln, posnr, etenr, edatu, mbdat, wmeng, bmeng, vsmng
      FROM vbep
      FOR ALL ENTRIES IN @it_sales_documents
      WHERE vbeln = @it_sales_documents-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_schedules.
    SORT lt_schedules BY vbeln posnr edatu etenr.

    LOOP AT lt_order_items INTO DATA(ls_order_item).
      CLEAR: ls_status, lv_has_status.
      READ TABLE lt_statuses INTO ls_status
        WITH KEY vbeln = ls_order_item-vbeln
                 posnr = ls_order_item-posnr.
      lv_has_status = xsdbool( sy-subrc = 0 ).

      DATA(lv_schedule_count) = 0.
      LOOP AT lt_schedules INTO DATA(ls_schedule)
        WHERE vbeln = ls_order_item-vbeln
          AND posnr = ls_order_item-posnr.
        ADD 1 TO lv_schedule_count.
        APPEND VALUE #(
          sales_document             = ls_order_item-vbeln
          item_number                = ls_order_item-posnr
          schedule_line              = ls_schedule-etenr
          requested_date             = ls_schedule-edatu
          material_availability_date = ls_schedule-mbdat
          has_schedule_line          = abap_true
          ordered_quantity           = ls_schedule-wmeng
          confirmed_quantity         = ls_schedule-bmeng
          delivered_quantity         = ls_schedule-vsmng
          delivery_status            = ls_status-lfsta
          has_status                 = lv_has_status )
          TO rt_items.
      ENDLOOP.

      IF lv_schedule_count = 0.
        APPEND VALUE #(
          sales_document     = ls_order_item-vbeln
          item_number        = ls_order_item-posnr
          ordered_quantity   = ls_order_item-kwmeng
          delivered_quantity = ls_order_item-vsmng
          delivery_status    = ls_status-lfsta
          has_status         = lv_has_status )
          TO rt_items.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
