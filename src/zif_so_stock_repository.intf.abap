INTERFACE zif_so_stock_repository PUBLIC.

  TYPES:
    BEGIN OF ty_request,
      request_id               TYPE c LENGTH 30,
      sales_document           TYPE vbap-vbeln,
      item_number              TYPE vbap-posnr,
      material                 TYPE mara-matnr,
      plant                    TYPE marc-werks,
      reservation_through_date TYPE d,
    END OF ty_request.
  TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_item_request,
      request_id               TYPE c LENGTH 30,
      sales_document           TYPE vbap-vbeln,
      item_number              TYPE vbap-posnr,
      reservation_through_date TYPE d,
    END OF ty_item_request.
  TYPES ty_item_requests TYPE STANDARD TABLE OF ty_item_request
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_order_item,
      sales_document TYPE vbap-vbeln,
      item_number    TYPE vbap-posnr,
      material       TYPE mara-matnr,
      plant          TYPE marc-werks,
    END OF ty_order_item.
  TYPES ty_order_items TYPE STANDARD TABLE OF ty_order_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_material_unit,
      material  TYPE mara-matnr,
      base_unit TYPE mara-meins,
    END OF ty_material_unit.
  TYPES ty_material_units TYPE STANDARD TABLE OF ty_material_unit
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_stock_row,
      sales_document   TYPE vbap-vbeln,
      item_number      TYPE vbap-posnr,
      material         TYPE mara-matnr,
      plant            TYPE marc-werks,
      storage_location TYPE mard-lgort,
      batch            TYPE mchb-charg,
      expiration_date  TYPE mcha-vfdat,
      base_unit        TYPE mara-meins,
      quantity         TYPE mska-kalab,
    END OF ty_stock_row.
  TYPES ty_stock_rows TYPE STANDARD TABLE OF ty_stock_row WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_reservation_row,
      sales_document     TYPE vbap-vbeln,
      item_number        TYPE vbap-posnr,
      material           TYPE mara-matnr,
      plant              TYPE marc-werks,
      storage_location   TYPE resb-lgort,
      batch              TYPE resb-charg,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      required_date      TYPE resb-bdter,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      open_quantity      TYPE resb-bdmng,
      base_unit          TYPE resb-meins,
    END OF ty_reservation_row.
  TYPES ty_reservation_rows TYPE STANDARD TABLE OF ty_reservation_row
    WITH EMPTY KEY.

  METHODS read_base_units_bulk
    IMPORTING
      it_requests     TYPE ty_requests
    RETURNING
      VALUE(rt_units) TYPE ty_material_units.

  METHODS read_order_items_bulk
    IMPORTING
      it_item_requests TYPE ty_item_requests
    RETURNING
      VALUE(rt_items)  TYPE ty_order_items.

  METHODS read_stock_bulk
    IMPORTING
      it_requests    TYPE ty_requests
    RETURNING
      VALUE(rt_rows) TYPE ty_stock_rows.

  METHODS read_reservations_bulk
    IMPORTING
      it_requests    TYPE ty_requests
    RETURNING
      VALUE(rt_rows) TYPE ty_reservation_rows.

ENDINTERFACE.
