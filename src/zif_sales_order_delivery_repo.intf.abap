INTERFACE zif_sales_order_delivery_repo PUBLIC.

  TYPES:
    BEGIN OF ty_item,
      item_number        TYPE vbap-posnr,
      schedule_line      TYPE vbep-etenr,
      requested_date     TYPE vbep-edatu,
      has_schedule_line  TYPE abap_bool,
      ordered_quantity   TYPE mard-labst,
      confirmed_quantity TYPE vbep-bmeng,
      delivered_quantity TYPE mard-labst,
      delivery_status    TYPE vbup-lfsta,
      has_status         TYPE abap_bool,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

  METHODS get_order_items
    IMPORTING
      iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
    RETURNING
      VALUE(rt_items)   TYPE ty_items.

ENDINTERFACE.
