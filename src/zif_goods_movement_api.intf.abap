INTERFACE zif_goods_movement_api PUBLIC.

  TYPES:
    BEGIN OF ty_header,
      posting_date       TYPE d,
      document_date      TYPE d,
      reference_document TYPE c LENGTH 16,
      header_text        TYPE c LENGTH 25,
    END OF ty_header.
  TYPES:
    BEGIN OF ty_item,
      material                   TYPE mard-matnr,
      plant                      TYPE mard-werks,
      storage_location           TYPE mard-lgort,
      movement_type              TYPE c LENGTH 3,
      quantity                   TYPE mard-labst,
      entry_unit                 TYPE c LENGTH 3,
      entry_unit_iso             TYPE c LENGTH 3,
      receiving_plant            TYPE c LENGTH 4,
      receiving_storage_location TYPE c LENGTH 4,
      cost_center                TYPE c LENGTH 10,
      order_id                   TYPE c LENGTH 12,
      sales_order                TYPE c LENGTH 10,
      sales_order_item           TYPE c LENGTH 6,
      reservation_number         TYPE bapi2093_res_key-reserv_no,
      reservation_item           TYPE bapi2093_res_item_detail-res_item,
      reservation_record_type    TYPE bapi2093_res_item_detail-res_type,
      movement_indicator         TYPE c LENGTH 1,
      batch                      TYPE bapi2093_res_item_detail-batch,
      purchase_order             TYPE c LENGTH 10,
      purchase_order_item        TYPE c LENGTH 5,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_message,
      type    TYPE c LENGTH 1,
      message TYPE c LENGTH 220,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.
  TYPES ty_gm_code TYPE c LENGTH 2.
  TYPES ty_material_document TYPE c LENGTH 10.
  TYPES ty_fiscal_year TYPE c LENGTH 4.
  TYPES ty_material_document_item TYPE n LENGTH 4.
  TYPES ty_material_document_items TYPE STANDARD TABLE OF
    ty_material_document_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_result,
      material_document TYPE c LENGTH 10,
      fiscal_year       TYPE c LENGTH 4,
      messages          TYPE ty_messages,
      is_successful     TYPE abap_bool,
    END OF ty_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.

  METHODS create_movement
    IMPORTING
      is_header        TYPE ty_header
      iv_gm_code       TYPE ty_gm_code
      it_items         TYPE ty_items
      iv_test_run      TYPE abap_bool
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS cancel_movement
    IMPORTING
      iv_material_document TYPE ty_material_document
      iv_fiscal_year       TYPE ty_fiscal_year
      iv_posting_date      TYPE d OPTIONAL
      it_item_numbers      TYPE ty_material_document_items OPTIONAL
    RETURNING
      VALUE(rs_result)     TYPE ty_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
