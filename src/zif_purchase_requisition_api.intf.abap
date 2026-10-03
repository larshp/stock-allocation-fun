INTERFACE zif_purchase_requisition_api PUBLIC.

  TYPES ty_requisition_type TYPE c LENGTH 4.
  TYPES ty_purchasing_group TYPE c LENGTH 3.
  TYPES ty_purchasing_org TYPE c LENGTH 4.
  TYPES:
    BEGIN OF ty_item,
      item_number             TYPE c LENGTH 5,
      source_suggestion_index TYPE i,
      material                TYPE mard-matnr,
      plant                   TYPE mard-werks,
      quantity                TYPE mard-labst,
      unit                    TYPE mara-meins,
      delivery_date           TYPE d,
      purchasing_group        TYPE ty_purchasing_group,
      purchasing_org          TYPE ty_purchasing_org,
      source_vendor           TYPE eina-lifnr,
      source_info_record      TYPE eina-infnr,
      source_agreement        TYPE eord-ebeln,
      source_agreement_item   TYPE eord-ebelp,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_request,
      requisition_type TYPE ty_requisition_type,
      is_test_run      TYPE abap_bool,
      items            TYPE ty_items,
    END OF ty_request.
  TYPES:
    BEGIN OF ty_message,
      type                    TYPE bapiret2-type,
      id                      TYPE bapiret2-id,
      number                  TYPE bapiret2-number,
      message                 TYPE bapiret2-message,
      message_v1              TYPE bapiret2-message_v1,
      message_v2              TYPE bapiret2-message_v2,
      message_v3              TYPE bapiret2-message_v3,
      message_v4              TYPE bapiret2-message_v4,
      parameter               TYPE bapiret2-parameter,
      row                     TYPE bapiret2-row,
      field                   TYPE bapiret2-field,
      item_number             TYPE c LENGTH 5,
      source_suggestion_index TYPE i,
      system                  TYPE bapiret2-system,
      log_no                  TYPE bapiret2-log_no,
      log_msg_no              TYPE bapiret2-log_msg_no,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_result,
      requisition_number TYPE c LENGTH 10,
      submitted_items    TYPE ty_items,
      messages           TYPE ty_messages,
      is_successful      TYPE abap_bool,
      is_test_run        TYPE abap_bool,
      bapi_was_called    TYPE abap_bool,
      is_committed       TYPE abap_bool,
    END OF ty_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.

  METHODS create_requisition
    IMPORTING
      is_request       TYPE ty_request
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
