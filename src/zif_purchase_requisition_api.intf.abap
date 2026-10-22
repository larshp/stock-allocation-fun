INTERFACE zif_purchase_requisition_api PUBLIC.

  TYPES ty_requisition_type TYPE c LENGTH 4.
  TYPES ty_requisition_number TYPE c LENGTH 10.
  TYPES ty_requisition_numbers TYPE STANDARD TABLE OF
    ty_requisition_number WITH EMPTY KEY.
  TYPES ty_purchasing_group TYPE c LENGTH 3.
  TYPES ty_purchasing_org TYPE c LENGTH 4.
  TYPES ty_requisition_item_number TYPE c LENGTH 5.
  TYPES ty_requisition_item_numbers TYPE STANDARD TABLE OF
    ty_requisition_item_number WITH EMPTY KEY.
  TYPES ty_account_assignment_category TYPE c LENGTH 1.
  TYPES:
    BEGIN OF ty_item,
      item_number                 TYPE c LENGTH 5,
      source_suggestion_index     TYPE i,
      material                    TYPE mard-matnr,
      plant                       TYPE mard-werks,
      quantity                    TYPE mard-labst,
      unit                        TYPE mara-meins,
      delivery_date               TYPE d,
      purchasing_group            TYPE ty_purchasing_group,
      purchasing_org              TYPE ty_purchasing_org,
      source_vendor               TYPE eina-lifnr,
      source_info_record          TYPE eina-infnr,
      source_agreement            TYPE eord-ebeln,
      source_agreement_item       TYPE eord-ebelp,
      account_assignment_category TYPE ty_account_assignment_category,
      wbs_element                 TYPE c LENGTH 24,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_requisition_item,
      item_number                 TYPE ty_requisition_item_number,
      short_text                  TYPE c LENGTH 40,
      material                    TYPE mard-matnr,
      plant                       TYPE mard-werks,
      storage_location            TYPE mard-lgort,
      quantity                    TYPE mard-labst,
      unit                        TYPE mara-meins,
      delivery_date               TYPE d,
      purchasing_group            TYPE ty_purchasing_group,
      purchasing_org              TYPE ty_purchasing_org,
      source_vendor               TYPE eina-lifnr,
      source_info_record          TYPE eina-infnr,
      source_agreement            TYPE eord-ebeln,
      source_agreement_item       TYPE eord-ebelp,
      account_assignment_category TYPE ty_account_assignment_category,
      wbs_element                 TYPE c LENGTH 24,
      deletion_indicator          TYPE c LENGTH 1,
      processing_status           TYPE c LENGTH 2,
      release_indicator           TYPE c LENGTH 1,
      release_status              TYPE c LENGTH 8,
      ordered_quantity            TYPE mard-labst,
      po_number                   TYPE eord-ebeln,
      po_item                     TYPE eord-ebelp,
      is_fixed                    TYPE abap_bool,
      is_closed                   TYPE abap_bool,
    END OF ty_requisition_item.
  TYPES ty_requisition_items TYPE STANDARD TABLE OF
    ty_requisition_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_item_update,
      item_number                  TYPE ty_requisition_item_number,
      change_quantity              TYPE abap_bool,
      quantity                     TYPE mard-labst,
      change_delivery_date         TYPE abap_bool,
      delivery_date                TYPE d,
      change_purchasing_group      TYPE abap_bool,
      purchasing_group             TYPE ty_purchasing_group,
      change_purchasing_org        TYPE abap_bool,
      purchasing_org               TYPE ty_purchasing_org,
      change_source_vendor         TYPE abap_bool,
      source_vendor                TYPE eina-lifnr,
      change_source_info_record    TYPE abap_bool,
      source_info_record           TYPE eina-infnr,
      change_source_agreement      TYPE abap_bool,
      source_agreement             TYPE eord-ebeln,
      change_source_agreement_item TYPE abap_bool,
      source_agreement_item        TYPE eord-ebelp,
    END OF ty_item_update.
  TYPES ty_item_updates TYPE STANDARD TABLE OF ty_item_update WITH EMPTY KEY.
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
      requisition_number     TYPE ty_requisition_number,
      submitted_items        TYPE ty_items,
      submitted_item_numbers TYPE ty_requisition_item_numbers,
      submitted_item_updates TYPE ty_item_updates,
      requisition_items      TYPE ty_requisition_items,
      messages               TYPE ty_messages,
      is_successful          TYPE abap_bool,
      is_test_run            TYPE abap_bool,
      is_skipped             TYPE abap_bool,
      bapi_was_called        TYPE abap_bool,
      is_committed           TYPE abap_bool,
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

  METHODS read_items
    IMPORTING
      iv_requisition_number TYPE ty_requisition_number
    RETURNING
      VALUE(rs_result)      TYPE ty_result.

  METHODS mark_items_deleted
    IMPORTING
      iv_requisition_number TYPE ty_requisition_number
      it_item_numbers       TYPE ty_requisition_item_numbers
      iv_test_run           TYPE abap_bool
    RETURNING
      VALUE(rs_result)      TYPE ty_result.

  METHODS change_items
    IMPORTING
      iv_requisition_number TYPE ty_requisition_number
      it_item_updates       TYPE ty_item_updates
      iv_test_run           TYPE abap_bool
    RETURNING
      VALUE(rs_result)      TYPE ty_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
