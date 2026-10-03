INTERFACE zif_sales_order_api PUBLIC.

  TYPES:
    BEGIN OF ty_item,
      item_number                  TYPE c LENGTH 6,
      schedule_line                TYPE c LENGTH 4,
      has_confirmed_quantity       TYPE abap_bool,
      material                     TYPE mard-matnr,
      plant                        TYPE mard-werks,
      quantity                     TYPE mard-labst,
      entry_unit                   TYPE c LENGTH 3,
      sales_unit_numerator         TYPE bapisdit-sales_qty1,
      sales_unit_denominator       TYPE bapisdit-sales_qty2,
      delivered_quantity           TYPE mard-labst,
      open_quantity                TYPE mard-labst,
      base_quantity                TYPE mard-labst,
      open_base_quantity           TYPE mard-labst,
      confirmed_quantity           TYPE mard-labst,
      open_confirmed_quantity      TYPE mard-labst,
      confirmed_base_quantity      TYPE mard-labst,
      open_confirmed_base_quantity TYPE mard-labst,
      base_unit                    TYPE mara-meins,
      requested_date               TYPE d,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES ty_sales_document TYPE c LENGTH 10.

  TYPES:
    BEGIN OF ty_order,
      sales_document          TYPE ty_sales_document,
      order_type              TYPE c LENGTH 4,
      sales_organization      TYPE c LENGTH 4,
      distribution_channel    TYPE c LENGTH 2,
      division                TYPE c LENGTH 2,
      sold_to_party           TYPE c LENGTH 10,
      customer_purchase_order TYPE c LENGTH 20,
      document_date           TYPE d,
      items                   TYPE ty_items,
    END OF ty_order.

  TYPES:
    BEGIN OF ty_message,
      type    TYPE c LENGTH 1,
      message TYPE c LENGTH 220,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_read_result,
      order         TYPE ty_order,
      messages      TYPE ty_messages,
      is_successful TYPE abap_bool,
    END OF ty_read_result.
  TYPES:
    BEGIN OF ty_write_result,
      sales_document TYPE ty_sales_document,
      messages       TYPE ty_messages,
      is_successful  TYPE abap_bool,
    END OF ty_write_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.

  METHODS read_order
    IMPORTING
      iv_sales_document TYPE ty_sales_document
    RETURNING
      VALUE(rs_result)  TYPE ty_read_result.

  METHODS create_order
    IMPORTING
      is_order         TYPE ty_order
      iv_test_run      TYPE abap_bool
    RETURNING
      VALUE(rs_result) TYPE ty_write_result.

  METHODS change_order
    IMPORTING
      iv_sales_document TYPE ty_sales_document
      it_items          TYPE ty_items
      iv_test_run       TYPE abap_bool
    RETURNING
      VALUE(rs_result)  TYPE ty_write_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
