CLASS zcl_goods_movement_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_transfer_destination,
        request_id                 TYPE c LENGTH 30,
        receiving_storage_location TYPE mard-lgort,
      END OF ty_transfer_destination.
    TYPES ty_transfer_destinations TYPE STANDARD TABLE OF
      ty_transfer_destination WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_material_unit,
        material      TYPE mard-matnr,
        base_unit     TYPE mara-meins,
        base_unit_iso TYPE c LENGTH 3,
      END OF ty_transfer_material_unit.
    TYPES ty_transfer_material_units TYPE STANDARD TABLE OF
      ty_transfer_material_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_iso_mapping,
        unit     TYPE mara-meins,
        iso_code TYPE c LENGTH 3,
      END OF ty_unit_iso_mapping.
    TYPES ty_unit_iso_mappings TYPE STANDARD TABLE OF
      ty_unit_iso_mapping WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_issue_item,
        purchase_order_item        TYPE c LENGTH 5,
        material                   TYPE mard-matnr,
        supplying_plant            TYPE mard-werks,
        supplying_storage_location TYPE mard-lgort,
        batch                      TYPE bapi2093_res_item_detail-batch,
        quantity                   TYPE mard-labst,
        entry_unit                 TYPE mara-meins,
        entry_unit_iso             TYPE c LENGTH 3,
      END OF ty_sto_issue_item.
    TYPES ty_sto_issue_items TYPE STANDARD TABLE OF
      ty_sto_issue_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_receipt_item,
        purchase_order_item        TYPE c LENGTH 5,
        material                   TYPE mard-matnr,
        receiving_plant            TYPE mard-werks,
        receiving_storage_location TYPE mard-lgort,
        batch                      TYPE bapi2093_res_item_detail-batch,
        quantity                   TYPE mard-labst,
        entry_unit                 TYPE mara-meins,
        entry_unit_iso             TYPE c LENGTH 3,
      END OF ty_sto_receipt_item.
    TYPES ty_sto_receipt_items TYPE STANDARD TABLE OF
      ty_sto_receipt_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_issue_pair_result,
        supplying_plant    TYPE mard-werks,
        receiving_plant    TYPE mard-werks,
        order_result       TYPE zif_stock_transfer_order_api=>ty_result,
        goods_issue_result TYPE zif_goods_movement_api=>ty_result,
        is_issue_attempted TYPE abap_bool,
        is_in_transit      TYPE abap_bool,
      END OF ty_sto_issue_pair_result.
    TYPES ty_sto_issue_pair_results TYPE STANDARD TABLE OF
      ty_sto_issue_pair_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_issue_pairs_result,
        orders        TYPE ty_sto_issue_pair_results,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
      END OF ty_sto_issue_pairs_result.
    TYPES:
      BEGIN OF ty_sto_receipt_pair_result,
        supplying_plant      TYPE mard-werks,
        receiving_plant      TYPE mard-werks,
        order_result         TYPE zif_stock_transfer_order_api=>ty_result,
        goods_issue_result   TYPE zif_goods_movement_api=>ty_result,
        goods_receipt_result TYPE zif_goods_movement_api=>ty_result,
        is_receipt_attempted TYPE abap_bool,
        is_in_transit        TYPE abap_bool,
        is_received          TYPE abap_bool,
      END OF ty_sto_receipt_pair_result.
    TYPES ty_sto_receipt_pair_results TYPE STANDARD TABLE OF
      ty_sto_receipt_pair_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_receipt_pairs_result,
        orders        TYPE ty_sto_receipt_pair_results,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
      END OF ty_sto_receipt_pairs_result.
    TYPES:
      BEGIN OF ty_sto_cancel_pair_result,
        supplying_plant     TYPE mard-werks,
        receiving_plant     TYPE mard-werks,
        order_result        TYPE zif_stock_transfer_order_api=>ty_result,
        goods_issue_result  TYPE zif_goods_movement_api=>ty_result,
        reversal_result     TYPE zif_goods_movement_api=>ty_result,
        is_cancel_attempted TYPE abap_bool,
        is_in_transit       TYPE abap_bool,
        is_cancelled        TYPE abap_bool,
      END OF ty_sto_cancel_pair_result.
    TYPES ty_sto_cancel_pair_results TYPE STANDARD TABLE OF
      ty_sto_cancel_pair_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_cancel_pairs_result,
        orders        TYPE ty_sto_cancel_pair_results,
        is_successful TYPE abap_bool,
      END OF ty_sto_cancel_pairs_result.
    TYPES:
      BEGIN OF ty_sto_receipt_cancel_pair_result,
        supplying_plant             TYPE mard-werks,
        receiving_plant             TYPE mard-werks,
        order_result                TYPE zif_stock_transfer_order_api=>ty_result,
        goods_issue_result          TYPE zif_goods_movement_api=>ty_result,
        goods_issue_reversal_result TYPE
          zif_goods_movement_api=>ty_result,
        goods_receipt_result        TYPE zif_goods_movement_api=>ty_result,
        reversal_result             TYPE zif_goods_movement_api=>ty_result,
        is_cancel_attempted         TYPE abap_bool,
        is_issue_cancel_attempted   TYPE abap_bool,
        is_issue_cancelled          TYPE abap_bool,
        is_in_transit               TYPE abap_bool,
        is_received                 TYPE abap_bool,
        is_cancelled                TYPE abap_bool,
        is_fully_cancelled          TYPE abap_bool,
      END OF ty_sto_receipt_cancel_pair_result.
    TYPES ty_sto_receipt_cancel_pair_results TYPE STANDARD TABLE OF
      ty_sto_receipt_cancel_pair_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_receipt_cancel_pairs_result,
        orders        TYPE ty_sto_receipt_cancel_pair_results,
        is_successful TYPE abap_bool,
      END OF ty_sto_receipt_cancel_pairs_result.
    TYPES:
      BEGIN OF ty_two_step_transfer_result,
        removal_result  TYPE zif_goods_movement_api=>ty_result,
        putaway_result  TYPE zif_goods_movement_api=>ty_result,
        reversal_result TYPE zif_goods_movement_api=>ty_result,
        putaway_items   TYPE zif_goods_movement_api=>ty_items,
        is_successful   TYPE abap_bool,
        is_in_transit   TYPE abap_bool,
        is_cancelled    TYPE abap_bool,
      END OF ty_two_step_transfer_result.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_goods_movement_api.

    METHODS execute
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        iv_gm_code       TYPE zif_goods_movement_api=>ty_gm_code
        it_items         TYPE zif_goods_movement_api=>ty_items
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_stock_transport_order
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        iv_purchase_order TYPE eord-ebeln
        it_items          TYPE ty_sto_issue_items
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_created_sto
      IMPORTING
        is_order_result      TYPE zif_stock_transfer_order_api=>ty_result
        is_header            TYPE zif_goods_movement_api=>ty_header
        it_unit_iso_mappings TYPE ty_unit_iso_mappings
        iv_test_run          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_created_sto_pairs
      IMPORTING
        is_orders            TYPE zcl_stock_xfer_order_svc=>ty_plant_pairs_result
        is_header            TYPE zif_goods_movement_api=>ty_header
        it_unit_iso_mappings TYPE ty_unit_iso_mappings
        iv_test_run          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE ty_sto_issue_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_issued_sto
      IMPORTING
        is_issue             TYPE ty_sto_issue_pair_result
        is_header            TYPE zif_goods_movement_api=>ty_header
        it_unit_iso_mappings TYPE ty_unit_iso_mappings
        iv_test_run          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE ty_sto_receipt_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_issued_sto_pairs
      IMPORTING
        is_issues            TYPE ty_sto_issue_pairs_result
        is_header            TYPE zif_goods_movement_api=>ty_header
        it_unit_iso_mappings TYPE ty_unit_iso_mappings
        iv_test_run          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE ty_sto_receipt_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_issued_sto
      IMPORTING
        is_issue         TYPE ty_sto_issue_pair_result
        iv_posting_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result) TYPE ty_sto_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_issued_sto_pairs
      IMPORTING
        is_issues        TYPE ty_sto_issue_pairs_result
        iv_posting_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result) TYPE ty_sto_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_received_sto
      IMPORTING
        is_receipt       TYPE ty_sto_receipt_pair_result
        iv_posting_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_received_sto_pairs
      IMPORTING
        is_receipts      TYPE ty_sto_receipt_pairs_result
        iv_posting_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_sto_receipt_chain
      IMPORTING
        is_receipt       TYPE ty_sto_receipt_pair_result
        iv_posting_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_sto_receipt_chain_pairs
      IMPORTING
        is_receipts      TYPE ty_sto_receipt_pairs_result
        iv_posting_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_stock_transport_order
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        iv_purchase_order TYPE eord-ebeln
        it_items          TYPE ty_sto_receipt_items
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_batch_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_fefo_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_fefo_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_fefo_date_uom_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_2step_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_batch_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_loc_batch_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_fefo_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_loc_fefo_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_2step_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_units_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_batch_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_fefo_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_fefo_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_batch_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_batch_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_fefo_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_units_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_fefo_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_fefo_date_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel
      IMPORTING
        iv_material_document TYPE zif_goods_movement_api=>ty_material_document
        iv_fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year
        iv_posting_date      TYPE d OPTIONAL
        it_item_numbers      TYPE zif_goods_movement_api=>ty_material_document_items OPTIONAL
      RETURNING
        VALUE(rs_result)     TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_transfer_putaway
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        is_transfer_result TYPE ty_two_step_transfer_result
        iv_test_run        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_transfer_in_transit
      IMPORTING
        is_transfer_result TYPE ty_two_step_transfer_result
        iv_posting_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)   TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES ty_movement_type TYPE c LENGTH 3.
    TYPES:
      BEGIN OF ty_prepared_sto_issue,
        result_index   TYPE i,
        purchase_order TYPE eord-ebeln,
        items          TYPE ty_sto_issue_items,
      END OF ty_prepared_sto_issue.
    TYPES ty_prepared_sto_issues TYPE STANDARD TABLE OF
      ty_prepared_sto_issue WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_sto_receipt,
        result_index   TYPE i,
        purchase_order TYPE eord-ebeln,
        items          TYPE ty_sto_receipt_items,
      END OF ty_prepared_sto_receipt.
    TYPES ty_prepared_sto_receipts TYPE STANDARD TABLE OF
      ty_prepared_sto_receipt WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_sto_cancel,
        result_index      TYPE i,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_prepared_sto_cancel.
    TYPES ty_prepared_sto_cancels TYPE STANDARD TABLE OF
      ty_prepared_sto_cancel WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_transfer_request_key.
    TYPES ty_transfer_request_keys TYPE HASHED TABLE OF
      ty_transfer_request_key WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_transfer_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        batch              TYPE mchb-charg,
        base_unit          TYPE mara-meins,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_transfer_demand.
    TYPES ty_transfer_demands TYPE STANDARD TABLE OF ty_transfer_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_split,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        base_unit          TYPE mara-meins,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_transfer_split.
    TYPES ty_transfer_splits TYPE STANDARD TABLE OF ty_transfer_split
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_material_key,
        material TYPE mard-matnr,
      END OF ty_transfer_material_key.
    TYPES ty_transfer_material_keys TYPE HASHED TABLE OF
      ty_transfer_material_key WITH UNIQUE KEY material.
    TYPES:
      BEGIN OF ty_transfer_split_key,
        request_id       TYPE c LENGTH 30,
        source_plant     TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_transfer_split_key.
    TYPES ty_transfer_split_keys TYPE HASHED TABLE OF
      ty_transfer_split_key WITH UNIQUE KEY request_id source_plant
        storage_location batch.
    TYPES:
      BEGIN OF ty_transfer_quantity,
        request_id TYPE c LENGTH 30,
        quantity   TYPE mard-labst,
      END OF ty_transfer_quantity.
    TYPES ty_transfer_quantities TYPE HASHED TABLE OF
      ty_transfer_quantity WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_transfer_batch_quantity,
        request_id TYPE c LENGTH 30,
        batch      TYPE mchb-charg,
        quantity   TYPE mard-labst,
      END OF ty_transfer_batch_quantity.
    TYPES ty_transfer_batch_quantities TYPE STANDARD TABLE OF
      ty_transfer_batch_quantity WITH EMPTY KEY.

    METHODS build_sto_issue_items
      IMPORTING
        is_order_result       TYPE zif_stock_transfer_order_api=>ty_result
        it_unit_iso_mappings  TYPE ty_unit_iso_mappings
      RETURNING
        VALUE(rt_issue_items) TYPE ty_sto_issue_items
      RAISING
        zcx_invalid_goods_movement.

    METHODS build_sto_receipt_items
      IMPORTING
        is_order_result         TYPE zif_stock_transfer_order_api=>ty_result
        it_unit_iso_mappings    TYPE ty_unit_iso_mappings
      RETURNING
        VALUE(rt_receipt_items) TYPE ty_sto_receipt_items
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_splits
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_demands                 TYPE ty_transfer_demands
        it_splits                  TYPE ty_transfer_splits
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
        iv_require_batch           TYPE abap_bool
        iv_movement_type           TYPE ty_movement_type DEFAULT '301'
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_two_step_splits
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_demands                 TYPE ty_transfer_demands
        it_splits                  TYPE ty_transfer_splits
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
        iv_require_batch           TYPE abap_bool
        iv_allow_multiple_batches  TYPE abap_bool
        iv_removal_movement_type   TYPE ty_movement_type
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS to_plant_fefo_uom
      IMPORTING
        is_allocation    TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
      RETURNING
        VALUE(rs_result) TYPE zcl_stock_service=>ty_unit_plant_fefo_result.

    DATA mo_api TYPE REF TO zif_goods_movement_api.
ENDCLASS.

CLASS zcl_goods_movement_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD execute.
    DATA lv_mode_known TYPE abap_bool.
    DATA lv_reservation_issue TYPE abap_bool.
    DATA lv_purchase_order_receipt TYPE abap_bool.
    DATA lv_production_order_receipt TYPE abap_bool.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR iv_gm_code IS INITIAL
        OR it_items IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      DATA(lv_item_uses_reservation) = xsdbool(
        ls_item-reservation_number IS NOT INITIAL ).
      DATA(lv_item_uses_purchase_order) = xsdbool(
        ls_item-purchase_order IS NOT INITIAL
        OR ls_item-purchase_order_item IS NOT INITIAL ).
      IF ls_item-is_reversal <> abap_true
          AND ls_item-is_reversal <> abap_false.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(lv_uses_prod_receipt) = xsdbool(
        iv_gm_code = '02'
        OR ( ls_item-order_id IS NOT INITIAL
          AND ls_item-movement_type = '101' ) ).
      IF lv_mode_known = abap_false.
        lv_reservation_issue = lv_item_uses_reservation.
        lv_purchase_order_receipt = lv_item_uses_purchase_order.
        lv_production_order_receipt =
          lv_uses_prod_receipt.
        lv_mode_known = abap_true.
      ELSEIF lv_reservation_issue <> lv_item_uses_reservation
          OR lv_purchase_order_receipt <> lv_item_uses_purchase_order
          OR lv_production_order_receipt
            <> lv_uses_prod_receipt.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF lv_item_uses_reservation = abap_true.
        DATA(lv_valid_reservation_movement) = xsdbool(
          ( iv_gm_code = '03'
            AND ls_item-is_reversal = abap_false )
          OR ( iv_gm_code = '06'
            AND ls_item-is_reversal = abap_true ) ).
        IF lv_valid_reservation_movement <> abap_true
            OR ls_item-reservation_item IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-entry_unit IS INITIAL
            OR ls_item-entry_unit_iso IS INITIAL
            OR ls_item-material IS NOT INITIAL
            OR ls_item-plant IS NOT INITIAL
            OR ls_item-movement_type IS NOT INITIAL
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-purchase_order IS NOT INITIAL
            OR ls_item-purchase_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL
            OR ls_item-movement_indicator IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_item-reservation_item IS NOT INITIAL
          OR ls_item-reservation_record_type IS NOT INITIAL
          OR ls_item-is_reversal <> abap_false
          OR ( ls_item-movement_indicator IS NOT INITIAL
            AND lv_item_uses_purchase_order = abap_false
            AND lv_uses_prod_receipt = abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( lv_item_uses_purchase_order = abap_false
            AND lv_uses_prod_receipt = abap_false
            AND ( ls_item-material IS INITIAL
              OR ls_item-plant IS INITIAL
              OR ls_item-storage_location IS INITIAL ) )
          OR ls_item-movement_type IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF lv_item_uses_purchase_order = abap_true.
        IF ls_item-movement_type = '351'.
          IF iv_gm_code <> '04'
              OR ls_item-purchase_order IS INITIAL
              OR ls_item-purchase_order_item IS INITIAL
              OR ls_item-material IS INITIAL
              OR ls_item-plant IS INITIAL
              OR ls_item-storage_location IS INITIAL
              OR ls_item-movement_indicator IS NOT INITIAL
              OR ls_item-cost_center IS NOT INITIAL
              OR ls_item-order_id IS NOT INITIAL
              OR ls_item-sales_order IS NOT INITIAL
              OR ls_item-sales_order_item IS NOT INITIAL
              OR ls_item-receiving_plant IS NOT INITIAL
              OR ls_item-receiving_storage_location IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
        ELSEIF iv_gm_code <> '01'
            OR ( ls_item-movement_type <> '101'
              AND ls_item-movement_type <> '122' )
            OR ls_item-purchase_order IS INITIAL
            OR ls_item-purchase_order_item IS INITIAL
            OR ls_item-movement_indicator <> 'B'
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_uses_prod_receipt = abap_true.
        IF iv_gm_code <> '02'
            OR ls_item-movement_type <> '101'
            OR ls_item-order_id IS INITIAL
            OR ls_item-movement_indicator <> 'F'
            OR ls_item-purchase_order IS NOT INITIAL
            OR ls_item-purchase_order_item IS NOT INITIAL
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_item-purchase_order_item IS NOT INITIAL
          OR ls_item-purchase_order IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_item-movement_type = '303'
          OR ls_item-movement_type = '305'
          OR ls_item-movement_type = '313'
          OR ls_item-movement_type = '315'.
        IF iv_gm_code <> '04'
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ( ls_item-movement_type = '303'
              AND ( ls_item-receiving_plant IS INITIAL
                OR ls_item-receiving_plant = ls_item-plant
                OR ls_item-receiving_storage_location IS NOT INITIAL ) )
            OR ( ls_item-movement_type = '305'
              AND ( ls_item-receiving_plant IS NOT INITIAL
                OR ls_item-receiving_storage_location IS NOT INITIAL ) )
            OR ( ls_item-movement_type = '313'
              AND ( ls_item-receiving_plant IS NOT INITIAL
                OR ls_item-receiving_storage_location IS INITIAL
                OR ls_item-receiving_storage_location
                  = ls_item-storage_location ) )
            OR ( ls_item-movement_type = '315'
              AND ( ls_item-receiving_plant IS NOT INITIAL
                OR ls_item-receiving_storage_location IS NOT INITIAL ) ).
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ( ls_item-movement_type = '201'
          OR ls_item-movement_type = '202' )
          AND ls_item-cost_center IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '261'
          OR ls_item-movement_type = '262' )
          AND ls_item-order_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '231'
          OR ls_item-movement_type = '232' )
          AND ( ls_item-sales_order IS INITIAL
            OR ls_item-sales_order_item IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '301'
          OR ls_item-movement_type = '302' )
          AND ( ls_item-receiving_plant IS INITIAL
            OR ls_item-receiving_storage_location IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '311'
          OR ls_item-movement_type = '312' )
          AND ls_item-receiving_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    rs_result = mo_api->create_movement(
      is_header   = is_header
      iv_gm_code  = iv_gm_code
      it_items    = it_items
      iv_test_run = iv_test_run ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-material_document IS INITIAL
        OR rs_result-fiscal_year IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Goods movement did not return a material document' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD issue_stock_transport_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_purchase_order IS INITIAL
        OR it_items IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_sto_item).
      IF ls_sto_item-purchase_order_item IS INITIAL
          OR ls_sto_item-material IS INITIAL
          OR ls_sto_item-supplying_plant IS INITIAL
          OR ls_sto_item-supplying_storage_location IS INITIAL
          OR ls_sto_item-quantity <= 0
          OR ls_sto_item-entry_unit IS INITIAL
          OR ls_sto_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material            = ls_sto_item-material
        plant               = ls_sto_item-supplying_plant
        storage_location    =
          ls_sto_item-supplying_storage_location
        movement_type       = '351'
        quantity            = ls_sto_item-quantity
        entry_unit          = ls_sto_item-entry_unit
        entry_unit_iso      = ls_sto_item-entry_unit_iso
        batch               = ls_sto_item-batch
        purchase_order      = iv_purchase_order
        purchase_order_item = ls_sto_item-purchase_order_item )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_created_sto.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_issue_items) = build_sto_issue_items(
      is_order_result      = is_order_result
      it_unit_iso_mappings = it_unit_iso_mappings ).

    rs_result = issue_stock_transport_order(
      is_header         = is_header
      iv_purchase_order = is_order_result-purchase_order_number
      it_items          = lt_issue_items
      iv_test_run       = iv_test_run ).
  ENDMETHOD.

  METHOD issue_created_sto_pairs.
    DATA lt_prepared_issues TYPE ty_prepared_sto_issues.

    IF is_orders-orders IS INITIAL
        OR is_orders-is_test_run <> abap_false
        OR ( is_orders-is_successful <> abap_true
          AND is_orders-is_successful <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = is_orders-is_successful.
    rs_result-is_test_run = iv_test_run.
    LOOP AT is_orders-orders INTO DATA(ls_pair_order).
      APPEND VALUE #(
        supplying_plant = ls_pair_order-supplying_plant
        receiving_plant = ls_pair_order-receiving_plant
        order_result    = ls_pair_order-result ) TO rs_result-orders.

      IF ls_pair_order-result-is_successful <> abap_true
          OR ls_pair_order-result-is_committed <> abap_true
          OR ls_pair_order-result-is_test_run <> abap_false
          OR ls_pair_order-result-purchase_order_number IS INITIAL.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.

      DATA(lt_issue_items) = build_sto_issue_items(
        is_order_result      = ls_pair_order-result
        it_unit_iso_mappings = it_unit_iso_mappings ).
      APPEND VALUE #(
        result_index   = lines( rs_result-orders )
        purchase_order = ls_pair_order-result-purchase_order_number
        items          = lt_issue_items ) TO lt_prepared_issues.
    ENDLOOP.

    LOOP AT lt_prepared_issues INTO DATA(ls_prepared_issue).
      DATA(ls_issue_result) = issue_stock_transport_order(
        is_header         = is_header
        iv_purchase_order = ls_prepared_issue-purchase_order
        it_items          = ls_prepared_issue-items
        iv_test_run       = iv_test_run ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_pair_result>)
        INDEX ls_prepared_issue-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_pair_result>-goods_issue_result = ls_issue_result.
      <ls_pair_result>-is_issue_attempted = abap_true.
      <ls_pair_result>-is_in_transit = xsdbool(
        ls_issue_result-is_successful = abap_true
        AND iv_test_run = abap_false ).
      IF ls_issue_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD receive_issued_sto.
    DATA(ls_issues) = VALUE ty_sto_issue_pairs_result(
      is_successful = abap_true
      orders        = VALUE #( ( is_issue ) ) ).

    rs_result = receive_issued_sto_pairs(
      is_issues            = ls_issues
      is_header            = is_header
      it_unit_iso_mappings = it_unit_iso_mappings
      iv_test_run          = iv_test_run ).
  ENDMETHOD.

  METHOD receive_issued_sto_pairs.
    DATA lt_prepared_receipts TYPE ty_prepared_sto_receipts.

    IF is_issues-orders IS INITIAL
        OR is_issues-is_test_run <> abap_false
        OR ( is_issues-is_successful <> abap_true
          AND is_issues-is_successful <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = is_issues-is_successful.
    rs_result-is_test_run = iv_test_run.
    LOOP AT is_issues-orders INTO DATA(ls_issue_pair).
      IF ( ls_issue_pair-is_issue_attempted <> abap_true
          AND ls_issue_pair-is_issue_attempted <> abap_false )
          OR ( ls_issue_pair-is_in_transit <> abap_true
            AND ls_issue_pair-is_in_transit <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        supplying_plant    = ls_issue_pair-supplying_plant
        receiving_plant    = ls_issue_pair-receiving_plant
        order_result       = ls_issue_pair-order_result
        goods_issue_result = ls_issue_pair-goods_issue_result
        is_in_transit      = ls_issue_pair-is_in_transit )
        TO rs_result-orders.

      IF ls_issue_pair-is_in_transit <> abap_true.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.
      IF ls_issue_pair-is_issue_attempted <> abap_true
          OR ls_issue_pair-order_result-is_successful <> abap_true
          OR ls_issue_pair-order_result-is_committed <> abap_true
          OR ls_issue_pair-order_result-is_test_run <> abap_false
          OR ls_issue_pair-goods_issue_result-is_successful <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(lt_receipt_items) = build_sto_receipt_items(
        is_order_result      = ls_issue_pair-order_result
        it_unit_iso_mappings = it_unit_iso_mappings ).
      APPEND VALUE #(
        result_index   = lines( rs_result-orders )
        purchase_order = ls_issue_pair-order_result-purchase_order_number
        items          = lt_receipt_items ) TO lt_prepared_receipts.
    ENDLOOP.

    LOOP AT lt_prepared_receipts INTO DATA(ls_prepared_receipt).
      DATA(ls_receipt_result) = receive_stock_transport_order(
        is_header         = is_header
        iv_purchase_order = ls_prepared_receipt-purchase_order
        it_items          = ls_prepared_receipt-items
        iv_test_run       = iv_test_run ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_receipt_pair>)
        INDEX ls_prepared_receipt-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_receipt_pair>-goods_receipt_result = ls_receipt_result.
      <ls_receipt_pair>-is_receipt_attempted = abap_true.
      <ls_receipt_pair>-is_received = xsdbool(
        ls_receipt_result-is_successful = abap_true
        AND iv_test_run = abap_false ).
      IF <ls_receipt_pair>-is_received = abap_true.
        <ls_receipt_pair>-is_in_transit = abap_false.
      ELSEIF ls_receipt_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cancel_issued_sto.
    DATA(ls_issues) = VALUE ty_sto_issue_pairs_result(
      is_successful = abap_true
      orders        = VALUE #( ( is_issue ) ) ).

    rs_result = cancel_issued_sto_pairs(
      is_issues       = ls_issues
      iv_posting_date = iv_posting_date ).
  ENDMETHOD.

  METHOD cancel_issued_sto_pairs.
    TYPES:
      BEGIN OF ty_cancel_key,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_cancel_key.
    DATA lt_prepared_cancels TYPE ty_prepared_sto_cancels.
    DATA lt_cancel_keys TYPE HASHED TABLE OF ty_cancel_key
      WITH UNIQUE KEY material_document fiscal_year.

    IF is_issues-orders IS INITIAL
        OR is_issues-is_test_run <> abap_false
        OR ( is_issues-is_successful <> abap_true
          AND is_issues-is_successful <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = is_issues-is_successful.
    LOOP AT is_issues-orders INTO DATA(ls_issue_pair).
      IF ( ls_issue_pair-is_issue_attempted <> abap_true
          AND ls_issue_pair-is_issue_attempted <> abap_false )
          OR ( ls_issue_pair-is_in_transit <> abap_true
            AND ls_issue_pair-is_in_transit <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        supplying_plant    = ls_issue_pair-supplying_plant
        receiving_plant    = ls_issue_pair-receiving_plant
        order_result       = ls_issue_pair-order_result
        goods_issue_result = ls_issue_pair-goods_issue_result
        is_in_transit      = ls_issue_pair-is_in_transit )
        TO rs_result-orders.

      IF ls_issue_pair-is_in_transit <> abap_true.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.
      IF ls_issue_pair-is_issue_attempted <> abap_true
          OR ls_issue_pair-order_result-is_successful <> abap_true
          OR ls_issue_pair-order_result-is_committed <> abap_true
          OR ls_issue_pair-order_result-is_test_run <> abap_false
          OR ls_issue_pair-goods_issue_result-is_successful <> abap_true
          OR ls_issue_pair-goods_issue_result-material_document IS INITIAL
          OR ls_issue_pair-goods_issue_result-fiscal_year IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        material_document =
          ls_issue_pair-goods_issue_result-material_document
        fiscal_year       = ls_issue_pair-goods_issue_result-fiscal_year )
        INTO TABLE lt_cancel_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        result_index      = lines( rs_result-orders )
        material_document =
          ls_issue_pair-goods_issue_result-material_document
        fiscal_year       = ls_issue_pair-goods_issue_result-fiscal_year )
        TO lt_prepared_cancels.
    ENDLOOP.

    LOOP AT lt_prepared_cancels INTO DATA(ls_prepared_cancel).
      DATA(ls_reversal_result) = cancel(
        iv_material_document = ls_prepared_cancel-material_document
        iv_fiscal_year       = ls_prepared_cancel-fiscal_year
        iv_posting_date      = iv_posting_date ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_cancel_pair>)
        INDEX ls_prepared_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_cancel_pair>-reversal_result = ls_reversal_result.
      <ls_cancel_pair>-is_cancel_attempted = abap_true.
      <ls_cancel_pair>-is_cancelled =
        ls_reversal_result-is_successful.
      IF <ls_cancel_pair>-is_cancelled = abap_true.
        <ls_cancel_pair>-is_in_transit = abap_false.
      ELSE.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cancel_received_sto.
    DATA(ls_receipts) = VALUE ty_sto_receipt_pairs_result(
      is_successful = abap_true
      is_test_run   = abap_false
      orders        = VALUE #( ( is_receipt ) ) ).

    rs_result = cancel_received_sto_pairs(
      is_receipts     = ls_receipts
      iv_posting_date = iv_posting_date ).
  ENDMETHOD.

  METHOD cancel_received_sto_pairs.
    TYPES:
      BEGIN OF ty_cancel_key,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_cancel_key.
    DATA lt_prepared_cancels TYPE ty_prepared_sto_cancels.
    DATA lt_cancel_keys TYPE HASHED TABLE OF ty_cancel_key
      WITH UNIQUE KEY material_document fiscal_year.

    IF is_receipts-orders IS INITIAL
        OR is_receipts-is_test_run <> abap_false
        OR ( is_receipts-is_successful <> abap_true
          AND is_receipts-is_successful <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = is_receipts-is_successful.
    LOOP AT is_receipts-orders INTO DATA(ls_receipt_pair).
      IF ( ls_receipt_pair-is_receipt_attempted <> abap_true
          AND ls_receipt_pair-is_receipt_attempted <> abap_false )
          OR ( ls_receipt_pair-is_in_transit <> abap_true
            AND ls_receipt_pair-is_in_transit <> abap_false )
          OR ( ls_receipt_pair-is_received <> abap_true
            AND ls_receipt_pair-is_received <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        supplying_plant      = ls_receipt_pair-supplying_plant
        receiving_plant      = ls_receipt_pair-receiving_plant
        order_result         = ls_receipt_pair-order_result
        goods_issue_result   = ls_receipt_pair-goods_issue_result
        goods_receipt_result = ls_receipt_pair-goods_receipt_result
        is_in_transit        = ls_receipt_pair-is_in_transit
        is_received          = ls_receipt_pair-is_received )
        TO rs_result-orders.

      IF ls_receipt_pair-is_received <> abap_true.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.
      IF ls_receipt_pair-is_receipt_attempted <> abap_true
          OR ls_receipt_pair-is_in_transit <> abap_false
          OR ls_receipt_pair-order_result-is_successful <> abap_true
          OR ls_receipt_pair-order_result-is_committed <> abap_true
          OR ls_receipt_pair-order_result-is_test_run <> abap_false
          OR ls_receipt_pair-goods_issue_result-is_successful <> abap_true
          OR ls_receipt_pair-goods_receipt_result-is_successful
            <> abap_true
          OR ls_receipt_pair-goods_receipt_result-material_document
            IS INITIAL
          OR ls_receipt_pair-goods_receipt_result-fiscal_year IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        material_document =
          ls_receipt_pair-goods_receipt_result-material_document
        fiscal_year       =
          ls_receipt_pair-goods_receipt_result-fiscal_year )
        INTO TABLE lt_cancel_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        result_index      = lines( rs_result-orders )
        material_document =
          ls_receipt_pair-goods_receipt_result-material_document
        fiscal_year       =
          ls_receipt_pair-goods_receipt_result-fiscal_year )
        TO lt_prepared_cancels.
    ENDLOOP.

    LOOP AT lt_prepared_cancels INTO DATA(ls_prepared_cancel).
      DATA(ls_reversal_result) = cancel(
        iv_material_document = ls_prepared_cancel-material_document
        iv_fiscal_year       = ls_prepared_cancel-fiscal_year
        iv_posting_date      = iv_posting_date ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_cancel_pair>)
        INDEX ls_prepared_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_cancel_pair>-reversal_result = ls_reversal_result.
      <ls_cancel_pair>-is_cancel_attempted = abap_true.
      <ls_cancel_pair>-is_cancelled = ls_reversal_result-is_successful.
      IF <ls_cancel_pair>-is_cancelled = abap_true.
        <ls_cancel_pair>-is_received = abap_false.
        <ls_cancel_pair>-is_in_transit = abap_true.
      ELSE.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cancel_sto_receipt_chain.
    DATA(ls_receipts) = VALUE ty_sto_receipt_pairs_result(
      is_successful = abap_true
      is_test_run   = abap_false
      orders        = VALUE #( ( is_receipt ) ) ).

    rs_result = cancel_sto_receipt_chain_pairs(
      is_receipts     = ls_receipts
      iv_posting_date = iv_posting_date ).
  ENDMETHOD.

  METHOD cancel_sto_receipt_chain_pairs.
    TYPES:
      BEGIN OF ty_cancel_key,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_cancel_key.
    DATA lt_cancel_keys TYPE HASHED TABLE OF ty_cancel_key
      WITH UNIQUE KEY material_document fiscal_year.

    IF is_receipts-orders IS INITIAL
        OR is_receipts-is_test_run <> abap_false
        OR ( is_receipts-is_successful <> abap_true
          AND is_receipts-is_successful <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT is_receipts-orders INTO DATA(ls_receipt_pair).
      IF ( ls_receipt_pair-is_receipt_attempted <> abap_true
          AND ls_receipt_pair-is_receipt_attempted <> abap_false )
          OR ( ls_receipt_pair-is_in_transit <> abap_true
            AND ls_receipt_pair-is_in_transit <> abap_false )
          OR ( ls_receipt_pair-is_received <> abap_true
            AND ls_receipt_pair-is_received <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_receipt_pair-is_received <> abap_true.
        CONTINUE.
      ENDIF.
      IF ls_receipt_pair-is_receipt_attempted <> abap_true
          OR ls_receipt_pair-is_in_transit <> abap_false
          OR ls_receipt_pair-order_result-is_successful <> abap_true
          OR ls_receipt_pair-order_result-is_committed <> abap_true
          OR ls_receipt_pair-order_result-is_test_run <> abap_false
          OR ls_receipt_pair-goods_issue_result-is_successful <> abap_true
          OR ls_receipt_pair-goods_issue_result-material_document
            IS INITIAL
          OR ls_receipt_pair-goods_issue_result-fiscal_year IS INITIAL
          OR ls_receipt_pair-goods_receipt_result-is_successful
            <> abap_true
          OR ls_receipt_pair-goods_receipt_result-material_document
            IS INITIAL
          OR ls_receipt_pair-goods_receipt_result-fiscal_year IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        material_document =
          ls_receipt_pair-goods_receipt_result-material_document
        fiscal_year       =
          ls_receipt_pair-goods_receipt_result-fiscal_year )
        INTO TABLE lt_cancel_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        material_document =
          ls_receipt_pair-goods_issue_result-material_document
        fiscal_year       =
          ls_receipt_pair-goods_issue_result-fiscal_year )
        INTO TABLE lt_cancel_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = is_receipts-is_successful.
    LOOP AT is_receipts-orders INTO ls_receipt_pair.
      APPEND CORRESPONDING #( ls_receipt_pair )
        TO rs_result-orders.
      IF ls_receipt_pair-is_received <> abap_true.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.

      DATA(lv_result_index) = lines( rs_result-orders ).
      DATA(ls_receipt_reversal) = cancel(
        iv_material_document =
          ls_receipt_pair-goods_receipt_result-material_document
        iv_fiscal_year       =
          ls_receipt_pair-goods_receipt_result-fiscal_year
        iv_posting_date      = iv_posting_date ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_chain_pair>)
        INDEX lv_result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_chain_pair>-reversal_result = ls_receipt_reversal.
      <ls_chain_pair>-is_cancel_attempted = abap_true.
      <ls_chain_pair>-is_cancelled = ls_receipt_reversal-is_successful.
      IF ls_receipt_reversal-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.
      <ls_chain_pair>-is_received = abap_false.
      <ls_chain_pair>-is_in_transit = abap_true.

      DATA(ls_issue_reversal) = cancel(
        iv_material_document =
          ls_receipt_pair-goods_issue_result-material_document
        iv_fiscal_year       =
          ls_receipt_pair-goods_issue_result-fiscal_year
        iv_posting_date      = iv_posting_date ).
      <ls_chain_pair>-goods_issue_reversal_result = ls_issue_reversal.
      <ls_chain_pair>-is_issue_cancel_attempted = abap_true.
      <ls_chain_pair>-is_issue_cancelled = ls_issue_reversal-is_successful.
      IF ls_issue_reversal-is_successful = abap_true.
        <ls_chain_pair>-is_in_transit = abap_false.
        <ls_chain_pair>-is_fully_cancelled = abap_true.
      ELSE.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_sto_issue_items.
    TYPES ty_item_number TYPE c LENGTH 5.
    DATA lt_units TYPE SORTED TABLE OF mara-meins
      WITH UNIQUE KEY table_line.
    DATA lt_item_numbers TYPE SORTED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.

    IF is_order_result-purchase_order_number IS INITIAL
        OR is_order_result-is_successful <> abap_true
        OR is_order_result-is_committed <> abap_true
        OR is_order_result-is_test_run <> abap_false
        OR is_order_result-submitted_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_unit_iso_mappings INTO DATA(ls_unit_iso_mapping).
      IF ls_unit_iso_mapping-unit IS INITIAL
          OR ls_unit_iso_mapping-iso_code IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_unit_iso_mapping-unit INTO TABLE lt_units.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_order_result-submitted_items INTO DATA(ls_order_item).
      IF ls_order_item-item_number IS INITIAL
          OR ls_order_item-material IS INITIAL
          OR ls_order_item-supplying_plant IS INITIAL
          OR ls_order_item-supplying_storage_loc IS INITIAL
          OR ls_order_item-quantity <= 0
          OR ls_order_item-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_order_item-item_number INTO TABLE lt_item_numbers.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_unit_iso_mappings INTO ls_unit_iso_mapping
        WITH KEY unit = ls_order_item-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        purchase_order_item        = ls_order_item-item_number
        material                   = ls_order_item-material
        supplying_plant            = ls_order_item-supplying_plant
        supplying_storage_location = ls_order_item-supplying_storage_loc
        batch                      = ls_order_item-batch
        quantity                   = ls_order_item-quantity
        entry_unit                 = ls_order_item-unit
        entry_unit_iso             = ls_unit_iso_mapping-iso_code )
        TO rt_issue_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_sto_receipt_items.
    TYPES ty_item_number TYPE c LENGTH 5.
    DATA lt_units TYPE SORTED TABLE OF mara-meins
      WITH UNIQUE KEY table_line.
    DATA lt_item_numbers TYPE SORTED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.

    IF is_order_result-purchase_order_number IS INITIAL
        OR is_order_result-is_successful <> abap_true
        OR is_order_result-is_committed <> abap_true
        OR is_order_result-is_test_run <> abap_false
        OR is_order_result-submitted_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_unit_iso_mappings INTO DATA(ls_unit_iso_mapping).
      IF ls_unit_iso_mapping-unit IS INITIAL
          OR ls_unit_iso_mapping-iso_code IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_unit_iso_mapping-unit INTO TABLE lt_units.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_order_result-submitted_items INTO DATA(ls_order_item).
      IF ls_order_item-item_number IS INITIAL
          OR ls_order_item-material IS INITIAL
          OR ls_order_item-receiving_plant IS INITIAL
          OR ls_order_item-quantity <= 0
          OR ls_order_item-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_order_item-item_number INTO TABLE lt_item_numbers.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_unit_iso_mappings INTO ls_unit_iso_mapping
        WITH KEY unit = ls_order_item-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        purchase_order_item        = ls_order_item-item_number
        material                   = ls_order_item-material
        receiving_plant            = ls_order_item-receiving_plant
        receiving_storage_location =
          ls_order_item-receiving_storage_loc
        batch                      = ls_order_item-batch
        quantity                   = ls_order_item-quantity
        entry_unit                 = ls_order_item-unit
        entry_unit_iso             = ls_unit_iso_mapping-iso_code )
        TO rt_receipt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD receive_stock_transport_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_purchase_order IS INITIAL
        OR it_items IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_sto_item).
      IF ls_sto_item-purchase_order_item IS INITIAL
          OR ls_sto_item-quantity <= 0
          OR ls_sto_item-entry_unit IS INITIAL
          OR ls_sto_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material            = ls_sto_item-material
        plant               = ls_sto_item-receiving_plant
        storage_location    =
          ls_sto_item-receiving_storage_location
        movement_type       = '101'
        quantity            = ls_sto_item-quantity
        entry_unit          = ls_sto_item-entry_unit
        entry_unit_iso      = ls_sto_item-entry_unit_iso
        movement_indicator  = 'B'
        batch               = ls_sto_item-batch
        purchase_order      = iv_purchase_order
        purchase_order_item = ls_sto_item-purchase_order_item )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '01'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD transfer_plant_allocation.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations
        INTO DATA(ls_location_allocation).
      APPEND VALUE #(
        request_id         = ls_location_allocation-request_id
        material           = ls_location_allocation-material
        target_plant       = ls_location_allocation-target_plant
        source_plant       = ls_location_allocation-source_plant
        storage_location   = ls_location_allocation-storage_location
        available_quantity = ls_location_allocation-available_quantity
        allocated_quantity = ls_location_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false ).
  ENDMETHOD.

  METHOD transfer_location_allocation.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations
      INTO DATA(ls_storage_allocation).
      APPEND VALUE #(
        request_id         = ls_storage_allocation-request_id
        material           = ls_storage_allocation-material
        target_plant       = ls_storage_allocation-plant
        source_plant       = ls_storage_allocation-plant
        storage_location   = ls_storage_allocation-storage_location
        available_quantity = ls_storage_allocation-allocated_quantity
        allocated_quantity = ls_storage_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations
      INTO DATA(ls_storage_allocation).
      APPEND VALUE #(
        request_id         = ls_storage_allocation-request_id
        material           = ls_storage_allocation-material
        target_plant       = ls_storage_allocation-plant
        source_plant       = ls_storage_allocation-plant
        storage_location   = ls_storage_allocation-storage_location
        available_quantity = ls_storage_allocation-allocated_quantity
        allocated_quantity = ls_storage_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '313' ).
  ENDMETHOD.

  METHOD transfer_location_fefo_2step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_true
      iv_removal_movement_type   = '313' ).
  ENDMETHOD.

  METHOD transfer_location_batch_2step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.

      READ TABLE lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY request_id = ls_batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_demand>-batch IS NOT INITIAL
          AND <ls_demand>-batch <> ls_batch_allocation-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_demand>-batch = ls_batch_allocation-batch.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '313' ).
  ENDMETHOD.

  METHOD transfer_loc_batch_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-batch_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-batch_allocation
        TO ls_base_allocation-batch_allocations.
    ENDLOOP.

    rs_result = transfer_location_batch_2step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_loc_fefo_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-batch_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-batch_allocation
        TO ls_base_allocation-batch_allocations.
    ENDLOOP.

    rs_result = transfer_location_fefo_2step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations
      INTO DATA(ls_location_allocation).
      APPEND VALUE #(
        request_id         = ls_location_allocation-request_id
        material           = ls_location_allocation-material
        target_plant       = ls_location_allocation-target_plant
        source_plant       = ls_location_allocation-source_plant
        storage_location   = ls_location_allocation-storage_location
        available_quantity = ls_location_allocation-available_quantity
        allocated_quantity = ls_location_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '303' ).
  ENDMETHOD.

  METHOD transfer_plant_batch_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        batch              = ls_allocation-batch
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_location).
      APPEND VALUE #(
        request_id         = ls_location-request_id
        material           = ls_location-material
        target_plant       = ls_location-target_plant
        source_plant       = ls_location-source_plant
        storage_location   = ls_location-storage_location
        batch              = ls_location-batch
        available_quantity = ls_location-available_quantity
        allocated_quantity = ls_location-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '303' ).
  ENDMETHOD.

  METHOD transfer_plant_batch_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_plant_batch_allocation_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-allocation
        TO ls_base_allocation-location_allocations.
    ENDLOOP.

    rs_result = transfer_plant_batch_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-target_plant
        source_plant       = ls_batch_allocation-source_plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-available_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_true
      iv_removal_movement_type   = '303' ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_plant_fefo_allocation_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-allocation
        TO ls_base_allocation-batch_allocations.
    ENDLOOP.

    rs_result = transfer_plant_fefo_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_fefo_date_uom_2step.
    DATA(ls_fefo_allocation) = to_plant_fefo_uom(
      is_allocation = is_allocation ).
    rs_result = transfer_plant_fefo_2step_uom(
      is_header                  = is_header
      is_allocation              = ls_fefo_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_2step_units.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_plant_allocation_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-allocation
        TO ls_base_allocation-location_allocations.
    ENDLOOP.

    rs_result = transfer_plant_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_two_step_splits.
    DATA lv_putaway_movement_type TYPE ty_movement_type.
    DATA lt_seen_requests TYPE ty_transfer_request_keys.
    DATA lt_seen_destinations TYPE ty_transfer_request_keys.
    DATA lt_seen_material_units TYPE ty_transfer_material_keys.
    DATA lt_seen_splits TYPE ty_transfer_split_keys.
    DATA lt_transfer_quantities TYPE ty_transfer_quantities.
    DATA lt_transfer_batch_quantities TYPE ty_transfer_batch_quantities.
    DATA lt_removal_items TYPE zif_goods_movement_api=>ty_items.
    DATA lt_putaway_items TYPE zif_goods_movement_api=>ty_items.
    DATA ls_demand TYPE ty_transfer_demand.
    DATA ls_split TYPE ty_transfer_split.
    DATA ls_destination TYPE ty_transfer_destination.
    DATA ls_material_unit TYPE ty_transfer_material_unit.
    DATA ls_transfer_quantity TYPE ty_transfer_quantity.
    DATA ls_transfer_batch_quantity TYPE ty_transfer_batch_quantity.
    FIELD-SYMBOLS <ls_transfer_quantity> TYPE ty_transfer_quantity.
    FIELD-SYMBOLS <ls_transfer_batch_quantity>
      TYPE ty_transfer_batch_quantity.

    IF it_demands IS INITIAL
        OR ( iv_removal_movement_type <> '303'
          AND iv_removal_movement_type <> '313' )
        OR ( iv_require_batch <> abap_true
          AND iv_require_batch <> abap_false )
        OR ( iv_allow_multiple_batches <> abap_true
          AND iv_allow_multiple_batches <> abap_false )
        OR ( iv_require_batch = abap_true
          AND iv_allow_multiple_batches = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    lv_putaway_movement_type = COND #(
      WHEN iv_removal_movement_type = '303' THEN '305'
      ELSE '315' ).

    LOOP AT it_demands INTO ls_demand.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ( iv_require_batch = abap_true
            AND ls_demand-batch IS INITIAL )
          OR ( iv_require_batch = abap_false
            AND ls_demand-batch IS NOT INITIAL )
          OR ls_demand-requested_quantity < 0
          OR ls_demand-available_quantity < 0
          OR ls_demand-allocated_quantity < 0
          OR ls_demand-shortfall_quantity < 0
          OR ls_demand-allocated_quantity > ls_demand-requested_quantity
          OR ls_demand-allocated_quantity > ls_demand-available_quantity
          OR ls_demand-allocated_quantity + ls_demand-shortfall_quantity
            <> ls_demand-requested_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_demand-request_id
        quantity   = 0 ) INTO TABLE lt_transfer_quantities.

      IF ls_demand-base_unit IS NOT INITIAL.
        READ TABLE it_material_units INTO ls_material_unit
          WITH KEY material = ls_demand-material.
        IF sy-subrc <> 0
            OR ls_demand-base_unit <> ls_material_unit-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_demand-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_destinations INTO ls_destination.
      IF ls_destination-request_id IS INITIAL
          OR ls_destination-receiving_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_destination-request_id )
        INTO TABLE lt_seen_destinations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_destination-request_id.
      IF sy-subrc <> 0 OR ls_demand-allocated_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO ls_material_unit.
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_material_units.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_splits INTO ls_split.
      IF ls_split-allocated_quantity < 0
          OR ls_split-available_quantity < 0
          OR ls_split-allocated_quantity > ls_split-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_split-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_split-request_id IS INITIAL
          OR ls_split-material IS INITIAL
          OR ls_split-target_plant IS INITIAL
          OR ls_split-source_plant IS INITIAL
          OR ls_split-storage_location IS INITIAL
          OR ( iv_require_batch = abap_true
            AND ls_split-batch IS INITIAL )
          OR ( iv_require_batch = abap_false
            AND iv_allow_multiple_batches = abap_false
            AND ls_split-batch IS NOT INITIAL )
          OR ( iv_allow_multiple_batches = abap_true
            AND ls_split-batch IS INITIAL )
          OR ( iv_removal_movement_type = '303'
            AND ls_split-source_plant = ls_split-target_plant )
          OR ( iv_removal_movement_type = '313'
            AND ls_split-source_plant <> ls_split-target_plant ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ls_demand-material <> ls_split-material
          OR ls_demand-target_plant <> ls_split-target_plant
          OR ( iv_require_batch = abap_true
            AND ls_demand-batch <> ls_split-batch ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_destinations INTO ls_destination
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ( iv_removal_movement_type = '313'
            AND ls_destination-receiving_storage_location
              = ls_split-storage_location ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id       = ls_split-request_id
        source_plant     = ls_split-source_plant
        storage_location = ls_split-storage_location
        batch            = ls_split-batch )
        INTO TABLE lt_seen_splits.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_split-material.
      IF sy-subrc <> 0
          OR ( ls_split-base_unit IS NOT INITIAL
            AND ls_split-base_unit <> ls_material_unit-base_unit ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material                   = ls_split-material
        plant                      = ls_split-source_plant
        storage_location           = ls_split-storage_location
        movement_type              = iv_removal_movement_type
        batch                      = ls_split-batch
        quantity                   = ls_split-allocated_quantity
        entry_unit                 = ls_material_unit-base_unit
        entry_unit_iso             = ls_material_unit-base_unit_iso
        receiving_plant            = COND #(
          WHEN iv_removal_movement_type = '303'
            THEN ls_split-target_plant )
        receiving_storage_location = COND #(
          WHEN iv_removal_movement_type = '313'
            THEN ls_destination-receiving_storage_location ) )
        TO lt_removal_items.

      READ TABLE lt_transfer_quantities ASSIGNING <ls_transfer_quantity>
        WITH TABLE KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_transfer_quantity>-quantity = <ls_transfer_quantity>-quantity
        + ls_split-allocated_quantity.
      IF iv_allow_multiple_batches = abap_true.
        READ TABLE lt_transfer_batch_quantities
          ASSIGNING <ls_transfer_batch_quantity>
          WITH KEY request_id = ls_split-request_id
                   batch      = ls_split-batch.
        IF sy-subrc = 0.
          <ls_transfer_batch_quantity>-quantity =
            <ls_transfer_batch_quantity>-quantity
              + ls_split-allocated_quantity.
        ELSE.
          APPEND VALUE #(
            request_id = ls_split-request_id
            batch      = ls_split-batch
            quantity   = ls_split-allocated_quantity )
            TO lt_transfer_batch_quantities.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_transfer_quantities INTO ls_transfer_quantity
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_transfer_quantity-quantity <> ls_demand-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_demand-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      READ TABLE it_destinations INTO ls_destination
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_demand-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_allow_multiple_batches = abap_true.
        LOOP AT lt_transfer_batch_quantities INTO ls_transfer_batch_quantity
          WHERE request_id = ls_demand-request_id.
          APPEND VALUE #(
            material         = ls_demand-material
            plant            = ls_demand-target_plant
            storage_location = ls_destination-receiving_storage_location
            movement_type    = lv_putaway_movement_type
            batch            = ls_transfer_batch_quantity-batch
            quantity         = ls_transfer_batch_quantity-quantity
            entry_unit       = ls_material_unit-base_unit
            entry_unit_iso   = ls_material_unit-base_unit_iso )
            TO lt_putaway_items.
        ENDLOOP.
      ELSE.
        APPEND VALUE #(
          material         = ls_demand-material
          plant            = ls_demand-target_plant
          storage_location = ls_destination-receiving_storage_location
          movement_type    = lv_putaway_movement_type
          batch            = ls_demand-batch
          quantity         = ls_demand-allocated_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso )
          TO lt_putaway_items.
      ENDIF.
    ENDLOOP.

    rs_result-putaway_items = lt_putaway_items.
    IF lt_removal_items IS INITIAL OR lt_putaway_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated quantity to transfer' )
        TO rs_result-removal_result-messages.
      RETURN.
    ENDIF.

    rs_result-removal_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_removal_items
      iv_test_run = iv_test_run ).
    IF rs_result-removal_result-is_successful = abap_false.
      RETURN.
    ENDIF.
    IF iv_test_run = abap_false.
      rs_result-is_in_transit = abap_true.
    ENDIF.

    rs_result-putaway_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_putaway_items
      iv_test_run = iv_test_run ).
    IF rs_result-putaway_result-is_successful = abap_true.
      rs_result-is_successful = abap_true.
      rs_result-is_in_transit = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD retry_transfer_putaway.
    DATA lv_movement_type TYPE ty_movement_type.

    IF is_transfer_result-is_in_transit <> abap_true
        OR is_transfer_result-is_successful = abap_true
        OR is_transfer_result-removal_result-is_successful <> abap_true
        OR is_transfer_result-putaway_items IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT is_transfer_result-putaway_items INTO DATA(ls_item).
      IF ls_item-movement_type <> '305'
          AND ls_item-movement_type <> '315'.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF lv_movement_type IS INITIAL.
        lv_movement_type = ls_item-movement_type.
      ELSEIF lv_movement_type <> ls_item-movement_type.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    rs_result = is_transfer_result.
    rs_result-putaway_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = is_transfer_result-putaway_items
      iv_test_run = iv_test_run ).
    rs_result-is_successful = abap_false.
    rs_result-is_in_transit = abap_true.
    IF iv_test_run = abap_false
        AND rs_result-putaway_result-is_successful = abap_true.
      rs_result-is_successful = abap_true.
      rs_result-is_in_transit = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD cancel_transfer_in_transit.
    IF is_transfer_result-is_in_transit <> abap_true
        OR is_transfer_result-is_successful = abap_true
        OR is_transfer_result-is_cancelled = abap_true
        OR is_transfer_result-removal_result-is_successful <> abap_true
        OR is_transfer_result-removal_result-material_document IS INITIAL
        OR is_transfer_result-removal_result-fiscal_year IS INITIAL
        OR is_transfer_result-putaway_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result = is_transfer_result.
    rs_result-reversal_result = cancel(
      iv_material_document = is_transfer_result-removal_result-material_document
      iv_fiscal_year       = is_transfer_result-removal_result-fiscal_year
      iv_posting_date      = iv_posting_date ).
    rs_result-is_successful = abap_false.
    rs_result-is_cancelled = abap_false.
    rs_result-is_in_transit = abap_true.

    IF rs_result-reversal_result-is_successful = abap_true.
      rs_result-is_successful = abap_true.
      rs_result-is_cancelled = abap_true.
      rs_result-is_in_transit = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD transfer_location_2step_units.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_location_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      IF ls_unit_allocation-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_allocation-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_allocation-allocation
        TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-storage_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-storage_allocation
        TO ls_base_allocation-storage_allocations.
    ENDLOOP.

    rs_result = transfer_location_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_location_units_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-allocation-request_id
        material           = ls_allocation-allocation-material
        target_plant       = ls_allocation-allocation-plant
        base_unit          = ls_allocation-base_unit
        requested_quantity =
          ls_allocation-allocation-requested_quantity
        available_quantity =
          ls_allocation-allocation-available_quantity
        allocated_quantity =
          ls_allocation-allocation-allocated_quantity
        shortfall_quantity =
          ls_allocation-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations
      INTO DATA(ls_storage_allocation).
      APPEND VALUE #(
        request_id         =
          ls_storage_allocation-storage_allocation-request_id
        material           =
          ls_storage_allocation-storage_allocation-material
        target_plant       =
          ls_storage_allocation-storage_allocation-plant
        source_plant       =
          ls_storage_allocation-storage_allocation-plant
        storage_location   =
          ls_storage_allocation-storage_allocation-storage_location
        base_unit          = ls_storage_allocation-base_unit
        available_quantity =
          ls_storage_allocation-storage_allocation-allocated_quantity
        allocated_quantity =
          ls_storage_allocation-storage_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_batch_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.

      READ TABLE lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY request_id = ls_batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_demand>-batch IS NOT INITIAL
          AND <ls_demand>-batch <> ls_batch_allocation-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_demand>-batch = ls_batch_allocation-batch.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_fefo_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_fefo_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      APPEND VALUE #(
        request_id         = ls_unit_allocation-allocation-request_id
        material           = ls_unit_allocation-allocation-material
        target_plant       = ls_unit_allocation-allocation-plant
        base_unit          = ls_unit_allocation-base_unit
        requested_quantity =
          ls_unit_allocation-allocation-requested_quantity
        available_quantity =
          ls_unit_allocation-allocation-available_quantity
        allocated_quantity =
          ls_unit_allocation-allocation-allocated_quantity
        shortfall_quantity =
          ls_unit_allocation-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-batch_allocation-request_id
        material           = ls_unit_split-batch_allocation-material
        target_plant       = ls_unit_split-batch_allocation-plant
        source_plant       = ls_unit_split-batch_allocation-plant
        storage_location   =
          ls_unit_split-batch_allocation-storage_location
        batch              = ls_unit_split-batch_allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity =
          ls_unit_split-batch_allocation-allocated_quantity
        allocated_quantity =
          ls_unit_split-batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_batch_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      APPEND VALUE #(
        request_id         = ls_unit_allocation-allocation-request_id
        material           = ls_unit_allocation-allocation-material
        target_plant       = ls_unit_allocation-allocation-plant
        base_unit          = ls_unit_allocation-base_unit
        requested_quantity =
          ls_unit_allocation-allocation-requested_quantity
        available_quantity =
          ls_unit_allocation-allocation-available_quantity
        allocated_quantity =
          ls_unit_allocation-allocation-allocated_quantity
        shortfall_quantity =
          ls_unit_allocation-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-batch_allocation-request_id
        material           = ls_unit_split-batch_allocation-material
        target_plant       = ls_unit_split-batch_allocation-plant
        source_plant       = ls_unit_split-batch_allocation-plant
        storage_location   =
          ls_unit_split-batch_allocation-storage_location
        batch              = ls_unit_split-batch_allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity =
          ls_unit_split-batch_allocation-allocated_quantity
        allocated_quantity =
          ls_unit_split-batch_allocation-allocated_quantity )
        TO lt_splits.

      READ TABLE lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY request_id = ls_unit_split-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_demand>-batch IS NOT INITIAL
          AND <ls_demand>-batch <> ls_unit_split-batch_allocation-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_demand>-batch = ls_unit_split-batch_allocation-batch.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_plant_batch_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        batch              = ls_allocation-batch
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_location).
      APPEND VALUE #(
        request_id         = ls_location-request_id
        material           = ls_location-material
        target_plant       = ls_location-target_plant
        source_plant       = ls_location-source_plant
        storage_location   = ls_location-storage_location
        batch              = ls_location-batch
        available_quantity = ls_location-available_quantity
        allocated_quantity = ls_location-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_location).
      APPEND VALUE #(
        request_id         = ls_batch_location-request_id
        material           = ls_batch_location-material
        target_plant       = ls_batch_location-target_plant
        source_plant       = ls_batch_location-source_plant
        storage_location   = ls_batch_location-storage_location
        batch              = ls_batch_location-batch
        available_quantity = ls_batch_location-available_quantity
        allocated_quantity = ls_batch_location-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_units_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      APPEND VALUE #(
        request_id         = ls_unit_demand-allocation-request_id
        material           = ls_unit_demand-allocation-material
        target_plant       = ls_unit_demand-allocation-target_plant
        base_unit          = ls_unit_demand-base_unit
        requested_quantity = ls_unit_demand-allocation-requested_quantity
        available_quantity = ls_unit_demand-allocation-available_quantity
        allocated_quantity = ls_unit_demand-allocation-allocated_quantity
        shortfall_quantity = ls_unit_demand-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-allocation-request_id
        material           = ls_unit_split-allocation-material
        target_plant       = ls_unit_split-allocation-target_plant
        source_plant       = ls_unit_split-allocation-source_plant
        storage_location   = ls_unit_split-allocation-storage_location
        base_unit          = ls_unit_split-base_unit
        available_quantity = ls_unit_split-allocation-available_quantity
        allocated_quantity = ls_unit_split-allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false ).
  ENDMETHOD.

  METHOD transfer_plant_batch_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      APPEND VALUE #(
        request_id         = ls_unit_demand-allocation-request_id
        material           = ls_unit_demand-allocation-material
        target_plant       = ls_unit_demand-allocation-target_plant
        batch              = ls_unit_demand-allocation-batch
        base_unit          = ls_unit_demand-base_unit
        requested_quantity = ls_unit_demand-allocation-requested_quantity
        available_quantity = ls_unit_demand-allocation-available_quantity
        allocated_quantity = ls_unit_demand-allocation-allocated_quantity
        shortfall_quantity = ls_unit_demand-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-allocation-request_id
        material           = ls_unit_split-allocation-material
        target_plant       = ls_unit_split-allocation-target_plant
        source_plant       = ls_unit_split-allocation-source_plant
        storage_location   = ls_unit_split-allocation-storage_location
        batch              = ls_unit_split-allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity = ls_unit_split-allocation-available_quantity
        allocated_quantity = ls_unit_split-allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      APPEND VALUE #(
        request_id         = ls_unit_demand-allocation-request_id
        material           = ls_unit_demand-allocation-material
        target_plant       = ls_unit_demand-allocation-target_plant
        base_unit          = ls_unit_demand-base_unit
        requested_quantity = ls_unit_demand-allocation-requested_quantity
        available_quantity = ls_unit_demand-allocation-available_quantity
        allocated_quantity = ls_unit_demand-allocation-allocated_quantity
        shortfall_quantity = ls_unit_demand-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-allocation-request_id
        material           = ls_unit_split-allocation-material
        target_plant       = ls_unit_split-allocation-target_plant
        source_plant       = ls_unit_split-allocation-source_plant
        storage_location   = ls_unit_split-allocation-storage_location
        batch              = ls_unit_split-allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity = ls_unit_split-allocation-available_quantity
        allocated_quantity = ls_unit_split-allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD to_plant_fefo_uom.
    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      APPEND VALUE #(
        allocation                = VALUE #(
          request_id         = ls_unit_allocation-allocation-request_id
          material           = ls_unit_allocation-allocation-material
          target_plant       = ls_unit_allocation-allocation-target_plant
          requested_quantity = ls_unit_allocation-allocation-requested_quantity
          available_quantity = ls_unit_allocation-allocation-available_quantity
          allocated_quantity = ls_unit_allocation-allocation-allocated_quantity
          shortfall_quantity = ls_unit_allocation-allocation-shortfall_quantity )
        source_quantity           = ls_unit_allocation-source_quantity
        source_unit               = ls_unit_allocation-source_unit
        base_quantity             = ls_unit_allocation-base_quantity
        base_unit                 = ls_unit_allocation-base_unit
        available_source_quantity =
          ls_unit_allocation-available_source_quantity
        allocated_source_quantity =
          ls_unit_allocation-allocated_source_quantity
        shortfall_source_quantity =
          ls_unit_allocation-shortfall_source_quantity )
        TO rs_result-allocations.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations INTO DATA(ls_unit_source).
      APPEND VALUE #(
        allocation                = VALUE #(
          request_id         = ls_unit_source-allocation-request_id
          material           = ls_unit_source-allocation-material
          target_plant       = ls_unit_source-allocation-target_plant
          source_plant       = ls_unit_source-allocation-source_plant
          available_quantity = ls_unit_source-allocation-available_quantity
          allocated_quantity = ls_unit_source-allocation-allocated_quantity )
        source_unit               = ls_unit_source-source_unit
        base_unit                 = ls_unit_source-base_unit
        available_source_quantity =
          ls_unit_source-available_source_quantity
        allocated_source_quantity =
          ls_unit_source-allocated_source_quantity )
        TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_batch).
      APPEND VALUE #(
        allocation                = ls_unit_batch-allocation-allocation
        source_unit               = ls_unit_batch-source_unit
        base_unit                 = ls_unit_batch-base_unit
        available_source_quantity =
          ls_unit_batch-available_source_quantity
        allocated_source_quantity =
          ls_unit_batch-allocated_source_quantity )
        TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD transfer_fefo_date_uom.
    DATA(ls_fefo_allocation) = to_plant_fefo_uom(
      is_allocation = is_allocation ).
    rs_result = transfer_plant_fefo_units(
      is_header                  = is_header
      is_allocation              = ls_fefo_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_splits.
    DATA lt_seen_requests TYPE ty_transfer_request_keys.
    DATA lt_seen_destinations TYPE ty_transfer_request_keys.
    DATA lt_seen_material_units TYPE ty_transfer_material_keys.
    DATA lt_seen_splits TYPE ty_transfer_split_keys.
    DATA lt_transfer_quantities TYPE ty_transfer_quantities.
    DATA lt_items TYPE zif_goods_movement_api=>ty_items.
    DATA ls_demand TYPE ty_transfer_demand.
    DATA ls_split TYPE ty_transfer_split.
    DATA ls_destination TYPE ty_transfer_destination.
    DATA ls_material_unit TYPE ty_transfer_material_unit.
    DATA ls_transfer_quantity TYPE ty_transfer_quantity.
    FIELD-SYMBOLS <ls_transfer_quantity> TYPE ty_transfer_quantity.

    IF it_demands IS INITIAL
        OR ( iv_movement_type <> '301'
          AND iv_movement_type <> '311' ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-requested_quantity < 0
          OR ls_demand-available_quantity < 0
          OR ls_demand-allocated_quantity < 0
          OR ls_demand-shortfall_quantity < 0
          OR ls_demand-allocated_quantity > ls_demand-requested_quantity
          OR ls_demand-allocated_quantity > ls_demand-available_quantity
          OR ls_demand-allocated_quantity + ls_demand-shortfall_quantity
            <> ls_demand-requested_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_demand-base_unit IS NOT INITIAL.
        READ TABLE it_material_units INTO ls_material_unit
          WITH KEY material = ls_demand-material.
        IF sy-subrc <> 0
            OR ls_demand-base_unit <> ls_material_unit-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.

      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_demand-request_id
        quantity   = 0 ) INTO TABLE lt_transfer_quantities.

      IF iv_require_full_allocation = abap_true
          AND ls_demand-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_destinations INTO ls_destination.
      IF ls_destination-request_id IS INITIAL
          OR ls_destination-receiving_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_destination-request_id )
        INTO TABLE lt_seen_destinations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_destination-request_id.
      IF sy-subrc <> 0 OR ls_demand-allocated_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO ls_material_unit.
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_material_units.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_splits INTO ls_split.
      IF ls_split-allocated_quantity < 0
          OR ls_split-available_quantity < 0
          OR ls_split-allocated_quantity > ls_split-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_split-allocated_quantity = 0.
        CONTINUE.
      ENDIF.

      IF ls_split-request_id IS INITIAL
          OR ls_split-material IS INITIAL
          OR ls_split-target_plant IS INITIAL
          OR ls_split-source_plant IS INITIAL
          OR ( iv_movement_type = '301'
            AND ls_split-source_plant = ls_split-target_plant )
          OR ( iv_movement_type = '311'
            AND ls_split-source_plant <> ls_split-target_plant )
          OR ls_split-storage_location IS INITIAL
          OR ( iv_require_batch = abap_true AND ls_split-batch IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ls_demand-material <> ls_split-material
          OR ls_demand-target_plant <> ls_split-target_plant
          OR ( ls_demand-batch IS NOT INITIAL
            AND ls_demand-batch <> ls_split-batch ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        request_id       = ls_split-request_id
        source_plant     = ls_split-source_plant
        storage_location = ls_split-storage_location
        batch            = ls_split-batch )
        INTO TABLE lt_seen_splits.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_destinations INTO ls_destination
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ( iv_movement_type = '311'
            AND ls_destination-receiving_storage_location
              = ls_split-storage_location ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_split-material.
      IF sy-subrc <> 0
          OR ( ls_split-base_unit IS NOT INITIAL
            AND ls_split-base_unit <> ls_material_unit-base_unit ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material                   = ls_split-material
        plant                      = ls_split-source_plant
        storage_location           = ls_split-storage_location
        batch                      = ls_split-batch
        movement_type              = iv_movement_type
        quantity                   = ls_split-allocated_quantity
        entry_unit                 = ls_material_unit-base_unit
        entry_unit_iso             = ls_material_unit-base_unit_iso
        receiving_plant            = COND #(
          WHEN iv_movement_type = '301' THEN ls_split-target_plant )
        receiving_storage_location =
          ls_destination-receiving_storage_location ) TO lt_items.

      READ TABLE lt_transfer_quantities ASSIGNING <ls_transfer_quantity>
        WITH TABLE KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_transfer_quantity>-quantity = <ls_transfer_quantity>-quantity
        + ls_split-allocated_quantity.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_transfer_quantities INTO ls_transfer_quantity
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_transfer_quantity-quantity <> ls_demand-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lt_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated quantity to transfer' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD cancel.
    DATA lt_seen_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.

    IF iv_material_document IS INITIAL
        OR iv_fiscal_year IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      IF lv_item_number IS INITIAL
          OR line_exists( lt_seen_item_numbers[
            table_line = lv_item_number ] ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND lv_item_number TO lt_seen_item_numbers.
    ENDLOOP.

    rs_result = mo_api->cancel_movement(
      iv_material_document = iv_material_document
      iv_fiscal_year       = iv_fiscal_year
      iv_posting_date      = iv_posting_date
      it_item_numbers      = it_item_numbers ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      RETURN.
    ENDIF.

    IF rs_result-material_document IS INITIAL
        OR rs_result-fiscal_year IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Cancellation did not return a material document' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

ENDCLASS.
