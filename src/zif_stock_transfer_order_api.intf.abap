INTERFACE zif_stock_transfer_order_api PUBLIC.

  TYPES ty_document_type TYPE c LENGTH 4.
  TYPES ty_company_code TYPE c LENGTH 4.
  TYPES ty_purchasing_group TYPE c LENGTH 3.
  TYPES ty_purchasing_org TYPE c LENGTH 4.
  TYPES:
    BEGIN OF ty_item,
      item_number           TYPE c LENGTH 5,
      source_request_id     TYPE c LENGTH 30,
      material              TYPE mard-matnr,
      batch                 TYPE mchb-charg,
      supplying_plant       TYPE mard-werks,
      supplying_storage_loc TYPE mard-lgort,
      receiving_plant       TYPE mard-werks,
      receiving_storage_loc TYPE mard-lgort,
      quantity              TYPE mard-labst,
      unit                  TYPE mara-meins,
      delivery_date         TYPE d,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES ty_item_number TYPE c LENGTH 5.
  TYPES ty_item_numbers TYPE STANDARD TABLE OF ty_item_number
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_request,
      document_type    TYPE ty_document_type,
      company_code     TYPE ty_company_code,
      purchasing_org   TYPE ty_purchasing_org,
      purchasing_group TYPE ty_purchasing_group,
      is_test_run      TYPE abap_bool,
      items            TYPE ty_items,
    END OF ty_request.
  TYPES:
    BEGIN OF ty_message,
      type              TYPE bapiret2-type,
      id                TYPE bapiret2-id,
      number            TYPE bapiret2-number,
      message           TYPE bapiret2-message,
      message_v1        TYPE bapiret2-message_v1,
      message_v2        TYPE bapiret2-message_v2,
      message_v3        TYPE bapiret2-message_v3,
      message_v4        TYPE bapiret2-message_v4,
      parameter         TYPE bapiret2-parameter,
      row               TYPE bapiret2-row,
      field             TYPE bapiret2-field,
      item_number       TYPE c LENGTH 5,
      source_request_id TYPE c LENGTH 30,
      system            TYPE bapiret2-system,
      log_no            TYPE bapiret2-log_no,
      log_msg_no        TYPE bapiret2-log_msg_no,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_result,
      purchase_order_number TYPE eord-ebeln,
      submitted_items       TYPE ty_items,
      messages              TYPE ty_messages,
      is_successful         TYPE abap_bool,
      is_test_run           TYPE abap_bool,
      bapi_was_called       TYPE abap_bool,
      is_committed          TYPE abap_bool,
    END OF ty_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.
  TYPES:
    BEGIN OF ty_change_result,
      messages      TYPE ty_messages,
      is_successful TYPE abap_bool,
    END OF ty_change_result.

  METHODS create_order
    IMPORTING
      is_request       TYPE ty_request
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS mark_items_for_deletion
    IMPORTING
      iv_purchase_order TYPE eord-ebeln
      it_item_numbers   TYPE ty_item_numbers
    RETURNING
      VALUE(rs_result)  TYPE ty_change_result.

  METHODS mark_items_delivery_complete
    IMPORTING
      iv_purchase_order TYPE eord-ebeln
      it_item_numbers   TYPE ty_item_numbers
    RETURNING
      VALUE(rs_result)  TYPE ty_change_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
