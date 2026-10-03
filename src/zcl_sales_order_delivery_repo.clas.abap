CLASS zcl_sales_order_delivery_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_sales_order_delivery_repo.
ENDCLASS.

CLASS zcl_sales_order_delivery_repo IMPLEMENTATION.

  METHOD zif_sales_order_delivery_repo~get_order_items.
    DATA lt_order_items TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    DATA lt_statuses TYPE STANDARD TABLE OF vbup WITH EMPTY KEY.
    DATA lt_schedules TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.
    DATA ls_status TYPE vbup.
    DATA lv_has_status TYPE abap_bool.

    SELECT posnr, kwmeng, vsmng
      FROM vbap
      WHERE vbeln = @iv_sales_document
      ORDER BY posnr
      INTO CORRESPONDING FIELDS OF TABLE @lt_order_items.

    SELECT posnr, lfsta
      FROM vbup
      WHERE vbeln = @iv_sales_document
      INTO CORRESPONDING FIELDS OF TABLE @lt_statuses.

    SELECT posnr, etenr, edatu, wmeng, bmeng, vsmng
      FROM vbep
      WHERE vbeln = @iv_sales_document
      ORDER BY posnr, edatu, etenr
      INTO CORRESPONDING FIELDS OF TABLE @lt_schedules.

    LOOP AT lt_order_items INTO DATA(ls_order_item).
      CLEAR: ls_status, lv_has_status.
      READ TABLE lt_statuses INTO ls_status
        WITH KEY posnr = ls_order_item-posnr.
      lv_has_status = xsdbool( sy-subrc = 0 ).

      DATA(lv_schedule_count) = 0.
      LOOP AT lt_schedules INTO DATA(ls_schedule)
        WHERE posnr = ls_order_item-posnr.
        ADD 1 TO lv_schedule_count.
        APPEND VALUE #(
          item_number        = ls_order_item-posnr
          schedule_line      = ls_schedule-etenr
          requested_date     = ls_schedule-edatu
          has_schedule_line  = abap_true
          ordered_quantity   = ls_schedule-wmeng
          confirmed_quantity = ls_schedule-bmeng
          delivered_quantity = ls_schedule-vsmng
          delivery_status    = ls_status-lfsta
          has_status         = lv_has_status )
          TO rt_items.
      ENDLOOP.

      IF lv_schedule_count = 0.
        APPEND VALUE #(
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
