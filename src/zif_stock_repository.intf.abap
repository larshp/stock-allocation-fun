INTERFACE zif_stock_repository PUBLIC.

  TYPES:
    BEGIN OF ty_location_stock,
      storage_location   TYPE mard-lgort,
      available_quantity TYPE mard-labst,
    END OF ty_location_stock.
  TYPES ty_location_stocks TYPE STANDARD TABLE OF ty_location_stock
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_stock_status,
        unrestricted_quantity       TYPE mard-labst,
        reserved_quantity           TYPE resb-bdmng,
        available_unrestricted_qty  TYPE mard-labst,
        safety_stock_quantity       TYPE marc-eisbe,
        available_after_safety_qty  TYPE mard-labst,
        quality_inspection_quantity TYPE mard-insme,
        blocked_quantity            TYPE mard-speme,
    END OF ty_stock_status.
  TYPES:
    BEGIN OF ty_stock_status_location,
      storage_location           TYPE mard-lgort,
      unrestricted_quantity      TYPE mard-labst,
      available_unrestricted_qty TYPE mard-labst,
      quality_inspection_qty     TYPE mard-insme,
      blocked_quantity           TYPE mard-speme,
    END OF ty_stock_status_location.
  TYPES ty_stock_status_locations TYPE STANDARD TABLE OF
    ty_stock_status_location WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_sales_order_reservation,
      sales_document   TYPE resb-kdauf,
      material         TYPE resb-matnr,
      plant            TYPE resb-werks,
      item_number      TYPE resb-kdpos,
      schedule_line    TYPE resb-kdein,
      requirement_date TYPE resb-bdter,
      open_quantity    TYPE resb-bdmng,
    END OF ty_sales_order_reservation.
  TYPES ty_sales_order_reservations TYPE STANDARD TABLE OF
    ty_sales_order_reservation WITH EMPTY KEY.
  TYPES ty_sales_order_documents TYPE STANDARD TABLE OF resb-kdauf
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_stock,
      storage_location   TYPE mard-lgort,
      batch              TYPE mchb-charg,
      expiration_date    TYPE mcha-vfdat,
      available_quantity TYPE mchb-clabs,
    END OF ty_batch_stock.
  TYPES ty_batch_stocks TYPE STANDARD TABLE OF ty_batch_stock
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_stock_status,
      storage_location      TYPE mard-lgort,
      batch                 TYPE mchb-charg,
      expiration_date       TYPE mcha-vfdat,
      unrestricted_quantity TYPE mchb-clabs,
      available_quantity    TYPE mchb-clabs,
    END OF ty_batch_stock_status.
  TYPES ty_batch_stock_statuses TYPE STANDARD TABLE OF
    ty_batch_stock_status WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_projected_receipt,
      material             TYPE mard-matnr,
      plant                TYPE mard-werks,
      base_unit            TYPE mara-meins,
      receipt_date         TYPE d,
      quantity             TYPE mard-labst,
      source_type          TYPE c LENGTH 16,
      source_document      TYPE c LENGTH 35,
      source_item          TYPE c LENGTH 10,
      source_plant         TYPE eban-reswk,
      source_schedule_line TYPE eket-etenr,
    END OF ty_projected_receipt.
  TYPES ty_projected_receipts TYPE STANDARD TABLE OF
    ty_projected_receipt WITH EMPTY KEY.

  METHODS get_unrestricted_stock
    IMPORTING
      iv_material        TYPE mard-matnr
      iv_plant           TYPE mard-werks
    RETURNING
      VALUE(rv_quantity) TYPE mard-labst.

  METHODS get_available_stock_by_date
    IMPORTING
      iv_material                 TYPE mard-matnr
      iv_plant                    TYPE mard-werks
      iv_required_date            TYPE resb-bdter
      iv_include_po_receipts      TYPE abap_bool DEFAULT abap_false
      iv_include_sto_in_transit   TYPE abap_bool DEFAULT abap_false
      iv_include_unissued_sto     TYPE abap_bool DEFAULT abap_false
      iv_subtract_unissued_sto    TYPE abap_bool DEFAULT abap_false
      iv_include_prod_receipts    TYPE abap_bool DEFAULT abap_false
      iv_include_pr_receipts      TYPE abap_bool DEFAULT abap_false
      iv_include_sto_pr_receipts  TYPE abap_bool DEFAULT abap_false
      iv_include_planned_receipts TYPE abap_bool DEFAULT abap_false
      RETURNING
      VALUE(rv_quantity)          TYPE mard-labst.

  METHODS get_projected_receipts
    IMPORTING
      iv_material                 TYPE mard-matnr
      iv_plant                    TYPE mard-werks
      iv_through_date             TYPE d
      iv_include_po_receipts      TYPE abap_bool DEFAULT abap_false
      iv_include_sto_in_transit   TYPE abap_bool DEFAULT abap_false
      iv_include_unissued_sto     TYPE abap_bool DEFAULT abap_false
      iv_include_prod_receipts    TYPE abap_bool DEFAULT abap_false
      iv_include_pr_receipts      TYPE abap_bool DEFAULT abap_false
      iv_include_sto_pr_receipts  TYPE abap_bool DEFAULT abap_false
      iv_include_planned_receipts TYPE abap_bool DEFAULT abap_false
      RETURNING
      VALUE(rt_receipts)          TYPE ty_projected_receipts
    RAISING
      zcx_invalid_stock_request.

  METHODS get_safety_stock
    IMPORTING
      iv_material        TYPE mard-matnr
      iv_plant           TYPE mard-werks
    RETURNING
      VALUE(rv_quantity) TYPE marc-eisbe.

  METHODS get_sales_order_reservations
    IMPORTING
      iv_sales_document      TYPE resb-kdauf
    RETURNING
      VALUE(rt_reservations) TYPE ty_sales_order_reservations.

  METHODS get_order_reservations_bulk
    IMPORTING
      it_sales_documents     TYPE ty_sales_order_documents
    RETURNING
      VALUE(rt_reservations) TYPE ty_sales_order_reservations.

  METHODS get_stock_status
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_plant         TYPE mard-werks
    RETURNING
      VALUE(rs_status) TYPE ty_stock_status.

  METHODS get_stock_status_by_location
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_plant         TYPE mard-werks
    RETURNING
      VALUE(rt_status) TYPE ty_stock_status_locations.

  METHODS get_stock_status_by_batch
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_plant         TYPE mard-werks
    RETURNING
      VALUE(rt_status) TYPE ty_batch_stock_statuses.

  METHODS get_stock_by_location
    IMPORTING
      iv_material     TYPE mard-matnr
      iv_plant        TYPE mard-werks
    RETURNING
      VALUE(rt_stock) TYPE ty_location_stocks.

  METHODS get_stock_by_batch
    IMPORTING
      iv_material     TYPE mard-matnr
      iv_plant        TYPE mard-werks
    RETURNING
      VALUE(rt_stock) TYPE ty_batch_stocks.

ENDINTERFACE.
