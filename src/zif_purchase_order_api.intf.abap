INTERFACE zif_purchase_order_api PUBLIC.

  TYPES ty_document_type TYPE c LENGTH 4.
  TYPES ty_company_code TYPE c LENGTH 4.
  TYPES ty_purchasing_group TYPE c LENGTH 3.
  TYPES ty_purchasing_org TYPE c LENGTH 4.
  TYPES ty_vendor TYPE eina-lifnr.
  TYPES ty_purchase_order_number TYPE eord-ebeln.
  TYPES ty_item_number TYPE c LENGTH 5.
  TYPES ty_item_numbers TYPE STANDARD TABLE OF ty_item_number WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_item,
      item_number           TYPE ty_item_number,
      source_request_id     TYPE c LENGTH 30,
      purchase_requisition  TYPE eban-banfn,
      requisition_item      TYPE eban-bnfpo,
      material              TYPE mard-matnr,
      plant                 TYPE mard-werks,
      storage_location      TYPE mard-lgort,
      quantity              TYPE mard-labst,
      unit                  TYPE mara-meins,
      delivery_date         TYPE d,
      source_info_record    TYPE eina-infnr,
      source_agreement      TYPE eord-ebeln,
      source_agreement_item TYPE eord-ebelp,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES ty_schedule_line_number TYPE c LENGTH 4.
  TYPES:
    BEGIN OF ty_item_quantity_change,
      item_number TYPE ty_item_number,
      quantity    TYPE mard-labst,
    END OF ty_item_quantity_change.
  TYPES ty_item_quantity_changes TYPE STANDARD TABLE OF
    ty_item_quantity_change WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_schedule_change,
      item_number          TYPE ty_item_number,
      schedule_line        TYPE ty_schedule_line_number,
      change_quantity      TYPE abap_bool,
      quantity             TYPE mard-labst,
      change_delivery_date TYPE abap_bool,
      delivery_date        TYPE d,
    END OF ty_schedule_change.
  TYPES ty_schedule_changes TYPE STANDARD TABLE OF ty_schedule_change
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_request,
      document_type    TYPE ty_document_type,
      company_code     TYPE ty_company_code,
      purchasing_org   TYPE ty_purchasing_org,
      purchasing_group TYPE ty_purchasing_group,
      vendor           TYPE ty_vendor,
      document_date    TYPE d,
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
      item_number       TYPE ty_item_number,
      source_request_id TYPE c LENGTH 30,
      system            TYPE bapiret2-system,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_read_header,
      purchase_order_number TYPE ty_purchase_order_number,
      document_type         TYPE ty_document_type,
      company_code          TYPE ty_company_code,
      purchasing_org        TYPE ty_purchasing_org,
      purchasing_group      TYPE ty_purchasing_group,
      vendor                TYPE ty_vendor,
      document_date         TYPE d,
    END OF ty_read_header.
  TYPES:
    BEGIN OF ty_read_item,
      item_number       TYPE ty_item_number,
      material          TYPE mard-matnr,
      plant             TYPE mard-werks,
      storage_location  TYPE mard-lgort,
      ordered_quantity  TYPE mard-labst,
      unit              TYPE mara-meins,
      is_deleted        TYPE abap_bool,
      delivery_complete TYPE abap_bool,
    END OF ty_read_item.
  TYPES ty_read_items TYPE STANDARD TABLE OF ty_read_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_read_schedule,
      item_number   TYPE ty_item_number,
      schedule_line TYPE c LENGTH 4,
      delivery_date TYPE d,
      quantity      TYPE mard-labst,
    END OF ty_read_schedule.
  TYPES ty_read_schedules TYPE STANDARD TABLE OF ty_read_schedule
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_read_result,
      purchase_order_number TYPE ty_purchase_order_number,
      header                TYPE ty_read_header,
      items                 TYPE ty_read_items,
      schedules             TYPE ty_read_schedules,
      messages              TYPE ty_messages,
      is_successful         TYPE abap_bool,
    END OF ty_read_result.
  TYPES ty_purchase_order_numbers TYPE STANDARD TABLE OF
    ty_purchase_order_number WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_write_result,
      purchase_order_number     TYPE ty_purchase_order_number,
      submitted_items           TYPE ty_items,
      submitted_schedules       TYPE ty_schedule_changes,
      submitted_item_numbers    TYPE ty_item_numbers,
      submitted_item_quantities TYPE ty_item_quantity_changes,
      messages                  TYPE ty_messages,
      is_successful             TYPE abap_bool,
      is_test_run               TYPE abap_bool,
      is_committed              TYPE abap_bool,
    END OF ty_write_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.

  METHODS create_order
    IMPORTING
      is_request       TYPE ty_request
    RETURNING
      VALUE(rs_result) TYPE ty_write_result.

  METHODS read_order
    IMPORTING
      iv_purchase_order_number TYPE ty_purchase_order_number
    RETURNING
      VALUE(rs_result)         TYPE ty_read_result.

  METHODS mark_items_for_deletion
    IMPORTING
      iv_purchase_order_number TYPE ty_purchase_order_number
      it_item_numbers          TYPE ty_item_numbers
      iv_test_run              TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rs_result)         TYPE ty_write_result.

  METHODS mark_items_delivery_complete
    IMPORTING
      iv_purchase_order_number TYPE ty_purchase_order_number
      it_item_numbers          TYPE ty_item_numbers
      iv_test_run              TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rs_result)         TYPE ty_write_result.

  METHODS change_schedules
    IMPORTING
      iv_purchase_order_number TYPE ty_purchase_order_number
      it_schedule_changes      TYPE ty_schedule_changes
      iv_test_run              TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rs_result)         TYPE ty_write_result.

  METHODS change_item_quantities
    IMPORTING
      iv_purchase_order_number TYPE ty_purchase_order_number
      it_item_changes          TYPE ty_item_quantity_changes
      iv_test_run              TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rs_result)         TYPE ty_write_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
