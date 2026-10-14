CLASS zcl_goods_movement_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_wbs_element TYPE c LENGTH 24.
    TYPES ty_special_stock TYPE c LENGTH 1.
    TYPES:
      BEGIN OF ty_transfer_destination,
        request_id                 TYPE c LENGTH 30,
        receiving_storage_location TYPE mard-lgort,
      END OF ty_transfer_destination.
    TYPES ty_transfer_destinations TYPE STANDARD TABLE OF
      ty_transfer_destination WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_cc_issue_line,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        entry_unit       TYPE mara-meins,
        entry_unit_iso   TYPE c LENGTH 3,
      END OF ty_cc_issue_line.
    TYPES ty_cc_issue_lines TYPE STANDARD TABLE OF ty_cc_issue_line
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_cc_issue_line_in_unit,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        unit             TYPE mara-meins,
      END OF ty_cc_issue_line_in_unit.
    TYPES ty_cc_issue_lines_in_unit TYPE STANDARD TABLE OF
      ty_cc_issue_line_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_material_unit_mapping,
        material      TYPE mard-matnr,
        base_unit     TYPE mara-meins,
        base_unit_iso TYPE c LENGTH 3,
      END OF ty_material_unit_mapping.
    TYPES ty_material_unit_mappings TYPE STANDARD TABLE OF
      ty_material_unit_mapping WITH EMPTY KEY.
    TYPES ty_cc_issue_unit_mapping TYPE ty_material_unit_mapping.
    TYPES ty_cc_issue_unit_mappings TYPE STANDARD TABLE OF
      ty_material_unit_mapping WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sales_issue_line,
        sales_order_item TYPE c LENGTH 6,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        entry_unit       TYPE mara-meins,
        entry_unit_iso   TYPE c LENGTH 3,
      END OF ty_sales_issue_line.
    TYPES ty_sales_issue_lines TYPE STANDARD TABLE OF ty_sales_issue_line
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sales_issue_line_in_unit,
        sales_order_item TYPE c LENGTH 6,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        unit             TYPE mara-meins,
      END OF ty_sales_issue_line_in_unit.
    TYPES ty_sales_issue_lines_in_unit TYPE STANDARD TABLE OF
      ty_sales_issue_line_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_issue_line,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        entry_unit       TYPE mara-meins,
        entry_unit_iso   TYPE c LENGTH 3,
      END OF ty_project_issue_line.
    TYPES ty_project_issue_lines TYPE STANDARD TABLE OF
      ty_project_issue_line WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_issue_request,
        wbs_element   TYPE ty_wbs_element,
        special_stock TYPE ty_special_stock,
        items         TYPE ty_project_issue_lines,
      END OF ty_project_wbs_issue_request.
    TYPES ty_project_wbs_issue_requests TYPE STANDARD TABLE OF
      ty_project_wbs_issue_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_return_request,
        wbs_element   TYPE ty_wbs_element,
        special_stock TYPE ty_special_stock,
        items         TYPE ty_project_issue_lines,
      END OF ty_project_wbs_return_request.
    TYPES ty_project_wbs_return_requests TYPE STANDARD TABLE OF
      ty_project_wbs_return_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_issue_row_result,
        request_index TYPE i,
        wbs_element   TYPE ty_wbs_element,
        issue_result  TYPE zif_goods_movement_api=>ty_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_project_wbs_issue_row_result.
    TYPES ty_project_wbs_issue_row_results TYPE STANDARD TABLE OF
      ty_project_wbs_issue_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_return_row_result,
        request_index TYPE i,
        wbs_element   TYPE ty_wbs_element,
        return_result TYPE zif_goods_movement_api=>ty_result,
        is_attempted  TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_project_wbs_return_row_result.
    TYPES ty_project_wbs_return_row_results TYPE STANDARD TABLE OF
      ty_project_wbs_return_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_issues_bulk_result,
        issues           TYPE ty_project_wbs_issue_row_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_test_run      TYPE abap_bool,
      END OF ty_project_wbs_issues_bulk_result.
    TYPES:
      BEGIN OF ty_project_wbs_returns_bulk_result,
        returns          TYPE ty_project_wbs_return_row_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_test_run      TYPE abap_bool,
      END OF ty_project_wbs_returns_bulk_result.
    TYPES:
      BEGIN OF ty_project_wbs_atomic_row_result,
        request_index   TYPE i,
        wbs_element     TYPE ty_wbs_element,
        movement_result TYPE zif_goods_movement_api=>ty_result,
        is_attempted    TYPE abap_bool,
        is_committed    TYPE abap_bool,
      END OF ty_project_wbs_atomic_row_result.
    TYPES ty_project_wbs_atomic_row_results TYPE STANDARD TABLE OF
      ty_project_wbs_atomic_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_atomic_result,
        movements      TYPE ty_project_wbs_atomic_row_results,
        commit_result  TYPE zif_goods_movement_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
        is_test_run    TYPE abap_bool,
      END OF ty_project_wbs_atomic_result.
    TYPES:
      BEGIN OF ty_project_issue_line_in_unit,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        unit             TYPE mara-meins,
      END OF ty_project_issue_line_in_unit.
    TYPES ty_project_issue_lines_in_unit TYPE STANDARD TABLE OF
      ty_project_issue_line_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_issue_request_in_unit,
        wbs_element   TYPE ty_wbs_element,
        special_stock TYPE ty_special_stock,
        items         TYPE ty_project_issue_lines_in_unit,
      END OF ty_project_wbs_issue_request_in_unit.
    TYPES ty_project_wbs_issue_requests_in_unit TYPE STANDARD TABLE OF
      ty_project_wbs_issue_request_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_return_request_in_unit,
        wbs_element   TYPE ty_wbs_element,
        special_stock TYPE ty_special_stock,
        items         TYPE ty_project_issue_lines_in_unit,
      END OF ty_project_wbs_return_request_in_unit.
    TYPES ty_project_wbs_return_requests_in_unit TYPE STANDARD TABLE OF
      ty_project_wbs_return_request_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_transfer_line,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        expiration_date         TYPE mcha-vfdat,
        quantity                TYPE mard-labst,
        unit                    TYPE mara-meins,
      END OF ty_project_wbs_transfer_line.
    TYPES ty_project_wbs_transfer_lines TYPE STANDARD TABLE OF
      ty_project_wbs_transfer_line WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_project_wbs_transfer_assignment,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
      END OF ty_project_wbs_transfer_assignment.
    TYPES ty_project_wbs_transfer_assignments TYPE STANDARD TABLE OF
      ty_project_wbs_transfer_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_wbs_fefo_xfer_result,
        preview  TYPE zcl_project_stock_service=>ty_transfer_result,
        movement TYPE zif_goods_movement_api=>ty_result,
      END OF ty_wbs_fefo_xfer_result,
      BEGIN OF ty_wbs_dated_fefo_xfer_result,
        preview  TYPE zcl_project_stock_service=>ty_dated_transfer_result,
        movement TYPE zif_goods_movement_api=>ty_result,
      END OF ty_wbs_dated_fefo_xfer_result,
      BEGIN OF ty_wbs_loc_xfer_result,
        preview  TYPE zcl_project_stock_service=>ty_transfer_location_result,
        movement TYPE zif_goods_movement_api=>ty_result,
      END OF ty_wbs_loc_xfer_result.
    TYPES:
      BEGIN OF ty_wbs_dated_loc_xfer_result,
        preview  TYPE
          zcl_project_stock_service=>ty_dated_location_transfer_result,
        movement TYPE zif_goods_movement_api=>ty_result,
      END OF ty_wbs_dated_loc_xfer_result.
    TYPES:
      BEGIN OF ty_project_wbs_assignment,
        request_id  TYPE c LENGTH 30,
        wbs_element TYPE ty_wbs_element,
      END OF ty_project_wbs_assignment.
    TYPES ty_project_wbs_assignments TYPE STANDARD TABLE OF
      ty_project_wbs_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_issue_line,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        entry_unit       TYPE mara-meins,
        entry_unit_iso   TYPE c LENGTH 3,
      END OF ty_prod_issue_line.
    TYPES ty_prod_issue_lines TYPE STANDARD TABLE OF ty_prod_issue_line
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_issue_line_in_unit,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE mard-labst,
        unit             TYPE mara-meins,
      END OF ty_prod_issue_line_in_unit.
    TYPES ty_prod_issue_lines_in_unit TYPE STANDARD TABLE OF
      ty_prod_issue_line_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_issue_request,
        production_order TYPE zif_prod_order_api=>ty_order_number,
        items            TYPE ty_prod_issue_lines,
      END OF ty_prod_issue_request.
    TYPES ty_prod_issue_requests TYPE STANDARD TABLE OF
      ty_prod_issue_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_issue_row_result,
        request_index    TYPE i,
        production_order TYPE zif_prod_order_api=>ty_order_number,
        issue_result     TYPE zif_goods_movement_api=>ty_result,
        is_attempted     TYPE abap_bool,
        is_committed     TYPE abap_bool,
      END OF ty_prod_issue_row_result.
    TYPES ty_prod_issue_row_results TYPE STANDARD TABLE OF
      ty_prod_issue_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_issues_bulk_result,
        issues           TYPE ty_prod_issue_row_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_test_run      TYPE abap_bool,
      END OF ty_prod_issues_bulk_result.
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
    TYPES:
      BEGIN OF ty_cancel_document_request,
        request_id        TYPE c LENGTH 30,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
        posting_date      TYPE d,
        item_numbers      TYPE zif_goods_movement_api=>ty_material_document_items,
      END OF ty_cancel_document_request.
    TYPES ty_cancel_document_requests TYPE STANDARD TABLE OF
      ty_cancel_document_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_receipt_line,
        purchase_order_item TYPE c LENGTH 5,
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        storage_location    TYPE mard-lgort,
        batch               TYPE bapi2093_res_item_detail-batch,
        quantity            TYPE mard-labst,
        entry_unit          TYPE c LENGTH 3,
        entry_unit_iso      TYPE c LENGTH 3,
      END OF ty_po_receipt_line.
    TYPES ty_po_receipt_lines TYPE STANDARD TABLE OF ty_po_receipt_line
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_receipt_request,
        purchase_order_number TYPE eord-ebeln,
        items                 TYPE ty_po_receipt_lines,
      END OF ty_po_receipt_request.
    TYPES ty_po_receipt_requests TYPE STANDARD TABLE OF
      ty_po_receipt_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_receipt_row_result,
        request_index         TYPE i,
        purchase_order_number TYPE eord-ebeln,
        receipt_result        TYPE zif_goods_movement_api=>ty_result,
        is_attempted          TYPE abap_bool,
        is_committed          TYPE abap_bool,
      END OF ty_po_receipt_row_result.
    TYPES ty_po_receipt_row_results TYPE STANDARD TABLE OF
      ty_po_receipt_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_po_receipts_bulk_result,
        receipts         TYPE ty_po_receipt_row_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_test_run      TYPE abap_bool,
      END OF ty_po_receipts_bulk_result.
    TYPES:
      BEGIN OF ty_po_receipts_atomic_result,
        receipts       TYPE ty_po_receipt_row_results,
        commit_result  TYPE zif_goods_movement_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
        is_test_run    TYPE abap_bool,
      END OF ty_po_receipts_atomic_result.
    TYPES:
      BEGIN OF ty_prod_receipt_line,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE bapi2093_res_item_detail-batch,
        quantity         TYPE mard-labst,
        entry_unit       TYPE c LENGTH 3,
        entry_unit_iso   TYPE c LENGTH 3,
      END OF ty_prod_receipt_line.
    TYPES ty_prod_receipt_lines TYPE STANDARD TABLE OF
      ty_prod_receipt_line WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_receipt_request,
        production_order TYPE zif_prod_order_api=>ty_order_number,
        items            TYPE ty_prod_receipt_lines,
      END OF ty_prod_receipt_request.
    TYPES ty_prod_receipt_requests TYPE STANDARD TABLE OF
      ty_prod_receipt_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_receipt_row_result,
        request_index    TYPE i,
        production_order TYPE zif_prod_order_api=>ty_order_number,
        receipt_result   TYPE zif_goods_movement_api=>ty_result,
        is_attempted     TYPE abap_bool,
        is_committed     TYPE abap_bool,
      END OF ty_prod_receipt_row_result.
    TYPES ty_prod_receipt_row_results TYPE STANDARD TABLE OF
      ty_prod_receipt_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prod_receipts_bulk_result,
        receipts         TYPE ty_prod_receipt_row_results,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_test_run      TYPE abap_bool,
      END OF ty_prod_receipts_bulk_result.
    TYPES:
      BEGIN OF ty_prod_receipts_atomic_result,
        receipts       TYPE ty_prod_receipt_row_results,
        commit_result  TYPE zif_goods_movement_api=>ty_commit_result,
        is_successful  TYPE abap_bool,
        is_committed   TYPE abap_bool,
        is_rolled_back TYPE abap_bool,
        is_test_run    TYPE abap_bool,
      END OF ty_prod_receipts_atomic_result.
    TYPES:
      BEGIN OF ty_cancel_document_row_result,
        request_id        TYPE c LENGTH 30,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
        reversal_result   TYPE zif_goods_movement_api=>ty_result,
        is_attempted      TYPE abap_bool,
        is_cancelled      TYPE abap_bool,
      END OF ty_cancel_document_row_result.
    TYPES ty_cancel_document_row_results TYPE STANDARD TABLE OF
      ty_cancel_document_row_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_cancel_documents_result,
        documents     TYPE ty_cancel_document_row_results,
        is_successful TYPE abap_bool,
        is_atomic     TYPE abap_bool,
      END OF ty_cancel_documents_result.

    METHODS constructor
      IMPORTING
        io_api            TYPE REF TO zif_goods_movement_api
        io_uom_repository TYPE REF TO zif_material_uom_repository
          OPTIONAL.

    METHODS issue_to_cost_center
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_items         TYPE ty_cc_issue_lines
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_to_cost_center_in_unit
      IMPORTING
        iv_cost_center    TYPE rkpf-kostl
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_cc_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS reverse_to_cost_center
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_items         TYPE ty_cc_issue_lines
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS reverse_to_cost_center_uom
      IMPORTING
        iv_cost_center    TYPE rkpf-kostl
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_cc_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_cost_center_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_cc_reservation_service=>ty_result
        is_material_unit           TYPE ty_material_unit_mapping
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_cost_center_locations
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_previews                TYPE zcl_cc_reservation_service=>ty_location_demand_previews
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_cost_center_batches
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_previews                TYPE zcl_cc_reservation_service=>ty_batch_demand_previews
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_cost_center_fefo
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_previews                TYPE zcl_cc_reservation_service=>ty_fefo_demand_previews
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_to_sales_order
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_sales_issue_lines
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_to_sales_order_in_unit
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_sales_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_from_sales_order
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_sales_issue_lines
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_from_sales_order_uom
      IMPORTING
        iv_sales_document TYPE zif_sales_order_api=>ty_sales_document
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_sales_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_to_project_wbs
      IMPORTING
        iv_wbs_element   TYPE ty_wbs_element
        iv_special_stock TYPE ty_special_stock DEFAULT space
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_items         TYPE ty_project_issue_lines
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_project_wbs_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_project_wbs_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_project_wbs_issues_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_project_wbs_bulk_uom
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_project_wbs_issue_requests_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_project_wbs_issues_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_project_wbs_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_project_wbs_return_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_project_wbs_returns_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_project_wbs_bulk_uom
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_project_wbs_return_requests_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_project_wbs_returns_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_project_wbs_bulk_atomic
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_project_wbs_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_project_wbs_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_project_wbs_bulk_atomic
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_project_wbs_return_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_project_wbs_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_project_wbs_atomic_uom
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_project_wbs_issue_requests_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_project_wbs_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_project_wbs_atomic_uom
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_project_wbs_return_requests_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_project_wbs_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_to_project_wbs_uom
      IMPORTING
        iv_wbs_element    TYPE ty_wbs_element
        iv_special_stock  TYPE ty_special_stock DEFAULT space
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_project_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_from_project_wbs
      IMPORTING
        iv_wbs_element   TYPE ty_wbs_element
        iv_special_stock TYPE ty_special_stock DEFAULT space
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_items         TYPE ty_project_issue_lines
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_from_project_wbs_uom
      IMPORTING
        iv_wbs_element    TYPE ty_wbs_element
        iv_special_stock  TYPE ty_special_stock DEFAULT space
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_project_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_project_wbs_stock
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_project_wbs_transfer_lines
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_wbs_batch_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_transfer_assignments    TYPE ty_project_wbs_transfer_assignments
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_wbs_location_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_location_result
        it_transfer_assignments    TYPE ty_project_wbs_transfer_assignments
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_wbs_fefo
      IMPORTING
        io_stock_service             TYPE REF TO zcl_project_stock_service
        is_header                    TYPE zif_goods_movement_api=>ty_header
        it_demands                   TYPE
          zcl_project_stock_service=>ty_transfer_demands
        it_material_units            TYPE ty_material_unit_mappings
        it_storage_location_priority TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days   TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date  TYPE d OPTIONAL
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_wbs_fefo_xfer_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS transfer_wbs_fefo_by_date
      IMPORTING
        io_stock_service             TYPE REF TO zcl_project_stock_service
        is_header                    TYPE zif_goods_movement_api=>ty_header
        it_demands                   TYPE
          zcl_project_stock_service=>ty_dated_transfer_demands
        it_material_units            TYPE ty_material_unit_mappings
        it_storage_location_priority TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days   TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date  TYPE d OPTIONAL
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_wbs_dated_fefo_xfer_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS transfer_wbs_by_location
      IMPORTING
        io_stock_service             TYPE REF TO zcl_project_stock_service
        is_header                    TYPE zif_goods_movement_api=>ty_header
        it_demands                   TYPE
          zcl_project_stock_service=>ty_transfer_demands
        it_material_units            TYPE ty_material_unit_mappings
        it_storage_location_priority TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date  TYPE d OPTIONAL
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_wbs_loc_xfer_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS transfer_wbs_by_location_date
      IMPORTING
        io_stock_service             TYPE REF TO zcl_project_stock_service
        is_header                    TYPE zif_goods_movement_api=>ty_header
        it_demands                   TYPE
          zcl_project_stock_service=>ty_dated_location_transfer_demands
        it_material_units            TYPE ty_material_unit_mappings
        it_storage_location_priority TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date  TYPE d OPTIONAL
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_wbs_dated_loc_xfer_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS issue_project_wbs_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_location_result
        it_wbs_assignments         TYPE ty_project_wbs_assignments
        it_material_units          TYPE ty_material_unit_mappings
        iv_special_stock           TYPE ty_special_stock DEFAULT space
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_project_wbs_batch_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_wbs_assignments         TYPE ty_project_wbs_assignments
        it_material_units          TYPE ty_material_unit_mappings
        iv_special_stock           TYPE ty_special_stock DEFAULT space
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_sales_order_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_sales_order_alloc_service=>ty_result
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_unplanned_prod_order
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_items            TYPE ty_prod_issue_lines
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_unplanned_prod_order_uom
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_items            TYPE ty_prod_issue_lines_in_unit
        it_material_units   TYPE ty_material_unit_mappings
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_to_production_order
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_items            TYPE ty_prod_issue_lines
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS return_to_production_order_uom
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_items            TYPE ty_prod_issue_lines_in_unit
        it_material_units   TYPE ty_material_unit_mappings
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_unplanned_prod_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_prod_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_prod_issues_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS execute
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        iv_gm_code       TYPE zif_goods_movement_api=>ty_gm_code
        it_items         TYPE zif_goods_movement_api=>ty_items
        iv_test_run      TYPE abap_bool DEFAULT abap_false
        iv_defer_commit  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_purchase_order
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        is_request       TYPE ty_po_receipt_request
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_purchase_orders_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_po_receipt_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_po_receipts_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_purchase_orders_atomic
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_po_receipt_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_po_receipts_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_prod_order
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        is_request       TYPE ty_prod_receipt_request
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_prod_orders_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_prod_receipt_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_prod_receipts_bulk_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS receive_prod_orders_atomic
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_prod_receipt_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_prod_receipts_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_stock_transport_order
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        iv_purchase_order TYPE eord-ebeln
        it_items          TYPE ty_sto_issue_items
        iv_test_run       TYPE abap_bool DEFAULT abap_false
        iv_defer_commit   TYPE abap_bool DEFAULT abap_false
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
        iv_atomic            TYPE abap_bool DEFAULT abap_false
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
        iv_atomic            TYPE abap_bool DEFAULT abap_false
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
        iv_atomic        TYPE abap_bool DEFAULT abap_false
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
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_sto_receipt_chain
      IMPORTING
        is_receipt       TYPE ty_sto_receipt_pair_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_sto_receipt_chain_pairs
      IMPORTING
        is_receipts      TYPE ty_sto_receipt_pairs_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_sto_chain_issue
      IMPORTING
        is_pair          TYPE ty_sto_receipt_cancel_pair_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_sto_chain_issue_pairs
      IMPORTING
        is_result        TYPE ty_sto_receipt_cancel_pairs_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_sto_chain_receipt
      IMPORTING
        is_pair          TYPE ty_sto_receipt_cancel_pair_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_sto_chain_receipt_pairs
      IMPORTING
        is_result        TYPE ty_sto_receipt_cancel_pairs_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_sto_chain
      IMPORTING
        is_pair          TYPE ty_sto_receipt_cancel_pair_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_receipt_cancel_pairs_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS retry_sto_chain_pairs
      IMPORTING
        is_result        TYPE ty_sto_receipt_cancel_pairs_result
        iv_posting_date  TYPE d OPTIONAL
        iv_atomic        TYPE abap_bool DEFAULT abap_false
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
        iv_defer_commit   TYPE abap_bool DEFAULT abap_false
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

    METHODS transfer_plant_date_loc_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_date_plant_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_date_loc_uom_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_date_plant_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_date_loc_atp
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_date_loc_atp_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_date_loc_atp_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_date_loc_atp_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_fefo_date_atp
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_fefo_date_atp_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_fefo_date_atp_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_fefo_date_atp_result
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
        iv_defer_commit      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)     TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_material_documents_bulk
      IMPORTING
        it_requests      TYPE ty_cancel_document_requests
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_cancel_documents_result
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

    METHODS to_plant_location_uom
      IMPORTING
        is_allocation    TYPE zcl_stock_service=>ty_unit_date_plant_location_result
      RETURNING
        VALUE(rs_result) TYPE zcl_stock_service=>ty_unit_plant_allocation_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_date_loc_atp
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_plant_date_loc_atp_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_fefo_date_atp
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_plant_fefo_date_atp_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_fefo_date_metadata
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS prepare_wbs_requests_uom
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_project_wbs_issue_requests_in_unit
        it_material_units  TYPE ty_material_unit_mappings
        iv_test_run        TYPE abap_bool
      RETURNING
        VALUE(rt_requests) TYPE ty_project_wbs_issue_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_project_wbs
      IMPORTING
        iv_wbs_element   TYPE ty_wbs_element
        iv_special_stock TYPE ty_special_stock
        iv_movement_type TYPE ty_movement_type
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_items         TYPE ty_project_issue_lines
        iv_test_run      TYPE abap_bool
        iv_defer_commit  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_project_wbs_bulk_atomic
      IMPORTING
        iv_movement_type TYPE ty_movement_type
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_project_wbs_issue_requests
        iv_test_run      TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE ty_project_wbs_atomic_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_project_wbs_in_unit
      IMPORTING
        iv_wbs_element    TYPE ty_wbs_element
        iv_special_stock  TYPE ty_special_stock
        iv_movement_type  TYPE ty_movement_type
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_items          TYPE ty_project_issue_lines_in_unit
        it_material_units TYPE ty_material_unit_mappings
        iv_test_run       TYPE abap_bool
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.
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
    TYPES:
      BEGIN OF ty_cc_batch_issue_preview,
        request_id        TYPE c LENGTH 30,
        cost_center       TYPE rkpf-kostl,
        selected_batch    TYPE mchb-charg,
        allocation        TYPE zcl_stock_service=>ty_unit_allocation_summary,
        batch_allocations TYPE zcl_stock_service=>ty_unit_batch_splits,
      END OF ty_cc_batch_issue_preview.
    TYPES ty_cc_batch_issue_previews TYPE STANDARD TABLE OF
      ty_cc_batch_issue_preview WITH EMPTY KEY.

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

    METHODS validate_po_receipts
      IMPORTING
        is_header   TYPE zif_goods_movement_api=>ty_header
        it_requests TYPE ty_po_receipt_requests
        iv_test_run TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_header_dates
      IMPORTING
        is_header TYPE zif_goods_movement_api=>ty_header
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_optional_post_date
      IMPORTING
        iv_date TYPE d
      RAISING
        zcx_invalid_goods_movement.

    METHODS build_po_receipt_items
      IMPORTING
        is_request      TYPE ty_po_receipt_request
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.

    METHODS validate_prod_receipts
      IMPORTING
        is_header   TYPE zif_goods_movement_api=>ty_header
        it_requests TYPE ty_prod_receipt_requests
        iv_test_run TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_unplanned_prod_issues
      IMPORTING
        is_header   TYPE zif_goods_movement_api=>ty_header
        it_requests TYPE ty_prod_issue_requests
        iv_test_run TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.

    METHODS issue_cc_batch_previews
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_previews                TYPE ty_cc_batch_issue_previews
        it_material_units          TYPE ty_material_unit_mappings
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS build_prod_receipt_items
      IMPORTING
        is_request      TYPE ty_prod_receipt_request
      RETURNING
        VALUE(rt_items) TYPE zif_goods_movement_api=>ty_items.

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
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.

    METHODS same_wbs_xfer_lines
      IMPORTING
        it_first       TYPE ty_project_wbs_transfer_lines
        it_second      TYPE ty_project_wbs_transfer_lines
      RETURNING
        VALUE(rv_same) TYPE abap_bool.
ENDCLASS.

CLASS zcl_goods_movement_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
    DATA(lo_uom_repository) = io_uom_repository.
    IF lo_uom_repository IS NOT BOUND.
      lo_uom_repository = NEW zcl_material_uom_repository( ).
    ENDIF.
    mo_uom_converter = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
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
          AND iv_test_run <> abap_false )
        OR ( iv_defer_commit <> abap_true
          AND iv_defer_commit <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

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
            OR ls_item-wbs_element IS NOT INITIAL
            OR ls_item-valuation_wbs_element IS NOT INITIAL
            OR ls_item-special_stock IS NOT INITIAL
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
              OR ls_item-wbs_element IS NOT INITIAL
              OR ls_item-valuation_wbs_element IS NOT INITIAL
              OR ls_item-special_stock IS NOT INITIAL
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
            OR ls_item-wbs_element IS NOT INITIAL
            OR ls_item-valuation_wbs_element IS NOT INITIAL
            OR ls_item-special_stock IS NOT INITIAL
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
            OR ls_item-wbs_element IS NOT INITIAL
            OR ls_item-valuation_wbs_element IS NOT INITIAL
            OR ls_item-special_stock IS NOT INITIAL
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

      IF ls_item-movement_type <> '415'
          AND ( ls_item-receiving_material IS NOT INITIAL
            OR ls_item-receiving_batch IS NOT INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_item-movement_type = '415'.
        IF iv_gm_code <> '04'
            OR ls_item-special_stock <> 'Q'
            OR ls_item-wbs_element IS INITIAL
            OR ls_item-valuation_wbs_element IS INITIAL
            OR ls_item-wbs_element = ls_item-valuation_wbs_element
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-receiving_material <> ls_item-material
            OR ls_item-receiving_plant <> ls_item-plant
            OR ls_item-receiving_storage_location
              <> ls_item-storage_location
            OR ls_item-receiving_batch <> ls_item-batch
            OR ls_item-movement_indicator IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_item-movement_type = '221'
          OR ls_item-movement_type = '222'.
        IF iv_gm_code <> '03'
            OR ls_item-wbs_element IS INITIAL
            OR ls_item-valuation_wbs_element IS NOT INITIAL
            OR ( ls_item-special_stock IS NOT INITIAL
              AND ls_item-special_stock <> 'Q' )
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL
            OR ls_item-movement_indicator IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ELSEIF ls_item-wbs_element IS NOT INITIAL
          OR ls_item-valuation_wbs_element IS NOT INITIAL
          OR ls_item-special_stock IS NOT INITIAL.
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

    IF iv_defer_commit = abap_true.
      rs_result-is_successful = abap_true.
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

  METHOD issue_to_cost_center.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_cost_center IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = '201'
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        cost_center      = iv_cost_center
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_to_cost_center_in_unit.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_cost_center IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = '201'
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        cost_center      = iv_cost_center
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD reverse_to_cost_center.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_cost_center IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = '202'
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        cost_center      = iv_cost_center
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD reverse_to_cost_center_uom.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_cost_center IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = '202'
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        cost_center      = iv_cost_center
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_cost_center_allocation.
    TYPES:
      BEGIN OF ty_split_key,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_split_key.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_split_key
      WITH UNIQUE KEY storage_location batch.
    DATA lt_issue_lines TYPE ty_cc_issue_lines.
    DATA lv_split_quantity TYPE mard-labst.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR is_allocation-is_successful <> abap_true
        OR is_allocation-reservation_number IS NOT INITIAL
        OR is_allocation-material IS INITIAL
        OR is_allocation-plant IS INITIAL
        OR is_allocation-cost_center IS INITIAL
        OR is_allocation-source_unit IS INITIAL
        OR is_allocation-base_unit IS INITIAL
        OR is_allocation-requested_quantity <= 0
        OR is_allocation-base_requested_quantity <= 0
        OR is_allocation-available_quantity < 0
        OR is_allocation-allocated_quantity < 0
        OR is_allocation-shortfall_quantity < 0
        OR is_allocation-allocated_quantity
          + is_allocation-shortfall_quantity
          <> is_allocation-base_requested_quantity
        OR is_allocation-allocated_quantity
          > is_allocation-available_quantity
        OR is_material_unit-material <> is_allocation-material
        OR is_material_unit-base_unit <> is_allocation-base_unit
        OR is_material_unit-base_unit_iso IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF is_allocation-batch_allocations IS NOT INITIAL
        AND is_allocation-storage_allocations IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF is_allocation-batch IS NOT INITIAL
        AND is_allocation-storage_allocations IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF iv_require_full_allocation = abap_true
        AND is_allocation-shortfall_quantity > 0.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF is_allocation-batch_allocations IS NOT INITIAL.
      LOOP AT is_allocation-batch_allocations
        INTO DATA(ls_batch_split).
        IF ls_batch_split-material <> is_allocation-material
            OR ls_batch_split-plant <> is_allocation-plant
            OR ls_batch_split-storage_location IS INITIAL
            OR ls_batch_split-batch IS INITIAL
            OR ( is_allocation-batch IS NOT INITIAL
              AND ls_batch_split-batch <> is_allocation-batch )
            OR ls_batch_split-allocated_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          storage_location = ls_batch_split-storage_location
          batch            = ls_batch_split-batch )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_batch_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          material         = is_allocation-material
          plant            = is_allocation-plant
          storage_location = ls_batch_split-storage_location
          batch            = ls_batch_split-batch
          quantity         = ls_batch_split-allocated_quantity
          entry_unit       = is_material_unit-base_unit
          entry_unit_iso   = is_material_unit-base_unit_iso )
          TO lt_issue_lines.
      ENDLOOP.
    ELSE.
      LOOP AT is_allocation-storage_allocations
        INTO DATA(ls_storage_split).
        IF ls_storage_split-material <> is_allocation-material
            OR ls_storage_split-plant <> is_allocation-plant
            OR ls_storage_split-storage_location IS INITIAL
            OR ls_storage_split-allocated_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          storage_location = ls_storage_split-storage_location )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_storage_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          material         = is_allocation-material
          plant            = is_allocation-plant
          storage_location = ls_storage_split-storage_location
          quantity         = ls_storage_split-allocated_quantity
          entry_unit       = is_material_unit-base_unit
          entry_unit_iso   = is_material_unit-base_unit_iso )
          TO lt_issue_lines.
      ENDLOOP.
    ENDIF.

    IF lv_split_quantity <> is_allocation-allocated_quantity.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF lt_issue_lines IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated cost-center quantity to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = issue_to_cost_center(
      iv_cost_center = is_allocation-cost_center
      is_header      = is_header
      it_items       = lt_issue_lines
      iv_test_run    = iv_test_run ).
  ENDMETHOD.

  METHOD issue_cost_center_locations.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_split_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
      END OF ty_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_split_key
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_previews INTO DATA(ls_preview).
      DATA(ls_allocation) = ls_preview-allocation-allocation.
      IF ls_preview-request_id IS INITIAL
          OR ls_preview-cost_center IS INITIAL
          OR ls_allocation-request_id <> ls_preview-request_id
          OR ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR ls_preview-allocation-source_quantity <= 0
          OR ls_preview-allocation-source_unit IS INITIAL
          OR ls_preview-allocation-base_quantity <= 0
          OR ls_preview-allocation-base_unit IS INITIAL
          OR ls_preview-allocation-base_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-available_quantity < 0
          OR ls_allocation-allocated_quantity < 0
          OR ls_allocation-shortfall_quantity < 0
          OR ls_allocation-allocated_quantity
            + ls_allocation-shortfall_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-allocated_quantity
            > ls_allocation-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_preview-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit
            <> ls_preview-allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_allocation-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      LOOP AT ls_preview-storage_allocations
        INTO DATA(ls_storage_split).
        DATA(ls_raw_split) = ls_storage_split-storage_allocation.
        IF ls_raw_split-request_id <> ls_preview-request_id
            OR ls_raw_split-material <> ls_allocation-material
            OR ls_raw_split-plant <> ls_allocation-plant
            OR ls_raw_split-storage_location IS INITIAL
            OR ls_raw_split-allocated_quantity <= 0
            OR ls_storage_split-base_unit
              <> ls_preview-allocation-base_unit
            OR ls_storage_split-source_unit
              <> ls_preview-allocation-source_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          request_id       = ls_raw_split-request_id
          storage_location = ls_raw_split-storage_location )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_raw_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          material         = ls_allocation-material
          plant            = ls_allocation-plant
          storage_location = ls_raw_split-storage_location
          movement_type    = '201'
          quantity         = ls_raw_split-allocated_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso
          cost_center      = ls_preview-cost_center )
          TO lt_movement_items.
      ENDLOOP.

      IF lv_split_quantity <> ls_allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lt_movement_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated cost-center quantities to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_cost_center_batches.
    DATA lt_previews TYPE ty_cc_batch_issue_previews.

    LOOP AT it_previews INTO DATA(ls_preview).
      IF ls_preview-selected_batch IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        request_id        = ls_preview-request_id
        cost_center       = ls_preview-cost_center
        selected_batch    = ls_preview-selected_batch
        allocation        = ls_preview-allocation
        batch_allocations = ls_preview-batch_allocations )
        TO lt_previews.
    ENDLOOP.

    rs_result = issue_cc_batch_previews(
      is_header                  = is_header
      it_previews                = lt_previews
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD issue_cost_center_fefo.
    DATA lt_previews TYPE ty_cc_batch_issue_previews.

    LOOP AT it_previews INTO DATA(ls_preview).
      APPEND VALUE #(
        request_id        = ls_preview-request_id
        cost_center       = ls_preview-cost_center
        allocation        = ls_preview-allocation
        batch_allocations = ls_preview-batch_allocations )
        TO lt_previews.
    ENDLOOP.

    rs_result = issue_cc_batch_previews(
      is_header                  = is_header
      it_previews                = lt_previews
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD issue_cc_batch_previews.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_split_key,
        request_id       TYPE c LENGTH 30,
        batch            TYPE mchb-charg,
        storage_location TYPE mard-lgort,
      END OF ty_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_split_key
      WITH UNIQUE KEY request_id batch storage_location.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_previews INTO DATA(ls_preview).
      DATA(ls_allocation) = ls_preview-allocation-allocation.
      IF ls_preview-request_id IS INITIAL
          OR ls_preview-cost_center IS INITIAL
          OR ls_allocation-request_id <> ls_preview-request_id
          OR ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR ls_preview-allocation-source_quantity <= 0
          OR ls_preview-allocation-source_unit IS INITIAL
          OR ls_preview-allocation-base_quantity <= 0
          OR ls_preview-allocation-base_unit IS INITIAL
          OR ls_preview-allocation-base_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-available_quantity < 0
          OR ls_allocation-allocated_quantity < 0
          OR ls_allocation-shortfall_quantity < 0
          OR ls_allocation-allocated_quantity
            + ls_allocation-shortfall_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-allocated_quantity
            > ls_allocation-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_preview-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit
            <> ls_preview-allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_allocation-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      LOOP AT ls_preview-batch_allocations
        INTO DATA(ls_batch_split).
        DATA(ls_raw_split) = ls_batch_split-batch_allocation.
        IF ls_raw_split-request_id <> ls_preview-request_id
            OR ls_raw_split-material <> ls_allocation-material
            OR ls_raw_split-plant <> ls_allocation-plant
            OR ls_raw_split-batch IS INITIAL
            OR ls_raw_split-storage_location IS INITIAL
            OR ls_raw_split-allocated_quantity <= 0
            OR ( ls_preview-selected_batch IS NOT INITIAL
              AND ls_raw_split-batch <> ls_preview-selected_batch )
            OR ls_batch_split-base_unit
              <> ls_preview-allocation-base_unit
            OR ls_batch_split-source_unit
              <> ls_preview-allocation-source_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          request_id       = ls_raw_split-request_id
          batch            = ls_raw_split-batch
          storage_location = ls_raw_split-storage_location )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_raw_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          material         = ls_allocation-material
          plant            = ls_allocation-plant
          storage_location = ls_raw_split-storage_location
          batch            = ls_raw_split-batch
          movement_type    = '201'
          quantity         = ls_raw_split-allocated_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso
          cost_center      = ls_preview-cost_center )
          TO lt_movement_items.
      ENDLOOP.

      IF lv_split_quantity <> ls_allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lt_movement_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated cost-center batch quantities to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_to_sales_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_sales_document IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-sales_order_item IS INITIAL
          OR ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        sales_order      = iv_sales_document
        sales_order_item = ls_item-sales_order_item
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = '231'
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_to_sales_order_in_unit.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_sales_document IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-sales_order_item IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        sales_order      = iv_sales_document
        sales_order_item = ls_request-sales_order_item
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = '231'
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_from_sales_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_sales_document IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-sales_order_item IS INITIAL
          OR ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        sales_order      = iv_sales_document
        sales_order_item = ls_item-sales_order_item
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = '232'
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_from_sales_order_uom.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_sales_document IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-sales_order_item IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        sales_order      = iv_sales_document
        sales_order_item = ls_request-sales_order_item
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = '232'
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_to_project_wbs.
    rs_result = post_project_wbs(
      iv_wbs_element   = iv_wbs_element
      iv_special_stock = iv_special_stock
      iv_movement_type = '221'
      is_header        = is_header
      it_items         = it_items
      iv_test_run      = iv_test_run ).
  ENDMETHOD.

  METHOD issue_project_wbs_bulk.
    FIELD-SYMBOLS <ls_issue> TYPE ty_project_wbs_issue_row_result.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-items IS INITIAL
          OR ( ls_request-special_stock IS NOT INITIAL
            AND ls_request-special_stock <> 'Q' ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_request-items INTO DATA(ls_item).
        IF ls_item-material IS INITIAL
            OR ls_item-plant IS INITIAL
            OR ls_item-storage_location IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-entry_unit IS INITIAL
            OR ls_item-entry_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #(
        request_index = lv_request_index
        wbs_element   = ls_request-wbs_element )
        TO rs_result-issues.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-issues ASSIGNING <ls_issue>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_issue>-is_attempted = abap_true.
      <ls_issue>-issue_result = issue_to_project_wbs(
        iv_wbs_element   = ls_request-wbs_element
        iv_special_stock = ls_request-special_stock
        is_header        = is_header
        it_items         = ls_request-items
        iv_test_run      = iv_test_run ).
      IF <ls_issue>-issue_result-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        <ls_issue>-is_committed = xsdbool(
          iv_test_run = abap_false ).
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD issue_project_wbs_bulk_uom.
    DATA(lt_base_requests) = prepare_wbs_requests_uom(
      is_header         = is_header
      it_requests       = it_requests
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
    rs_result = issue_project_wbs_bulk(
      is_header   = is_header
      it_requests = lt_base_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_project_wbs_bulk.
    FIELD-SYMBOLS <ls_return> TYPE ty_project_wbs_return_row_result.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-items IS INITIAL
          OR ( ls_request-special_stock IS NOT INITIAL
            AND ls_request-special_stock <> 'Q' ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_request-items INTO DATA(ls_item).
        IF ls_item-material IS INITIAL
            OR ls_item-plant IS INITIAL
            OR ls_item-storage_location IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-entry_unit IS INITIAL
            OR ls_item-entry_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #(
        request_index = lv_request_index
        wbs_element   = ls_request-wbs_element )
        TO rs_result-returns.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-returns ASSIGNING <ls_return>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_return>-is_attempted = abap_true.
      <ls_return>-return_result = return_from_project_wbs(
        iv_wbs_element   = ls_request-wbs_element
        iv_special_stock = ls_request-special_stock
        is_header        = is_header
        it_items         = ls_request-items
        iv_test_run      = iv_test_run ).
      IF <ls_return>-return_result-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        <ls_return>-is_committed = xsdbool(
          iv_test_run = abap_false ).
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD return_project_wbs_bulk_uom.
    DATA lt_unit_requests TYPE ty_project_wbs_issue_requests_in_unit.
    DATA lt_return_requests TYPE ty_project_wbs_return_requests.

    LOOP AT it_requests INTO DATA(ls_unit_request).
      APPEND VALUE #(
        wbs_element   = ls_unit_request-wbs_element
        special_stock = ls_unit_request-special_stock
        items         = ls_unit_request-items )
        TO lt_unit_requests.
    ENDLOOP.

    DATA(lt_base_requests) = prepare_wbs_requests_uom(
      is_header         = is_header
      it_requests       = lt_unit_requests
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
    LOOP AT lt_base_requests INTO DATA(ls_base_request).
      APPEND VALUE #(
        wbs_element   = ls_base_request-wbs_element
        special_stock = ls_base_request-special_stock
        items         = ls_base_request-items )
        TO lt_return_requests.
    ENDLOOP.
    rs_result = return_project_wbs_bulk(
      is_header   = is_header
      it_requests = lt_return_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_project_wbs_bulk_atomic.
    rs_result = post_project_wbs_bulk_atomic(
      iv_movement_type = '221'
      is_header        = is_header
      it_requests      = it_requests
      iv_test_run      = iv_test_run ).
  ENDMETHOD.

  METHOD return_project_wbs_bulk_atomic.
    DATA lt_requests TYPE ty_project_wbs_issue_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        wbs_element   = ls_request-wbs_element
        special_stock = ls_request-special_stock
        items         = ls_request-items )
        TO lt_requests.
    ENDLOOP.

    rs_result = post_project_wbs_bulk_atomic(
      iv_movement_type = '222'
      is_header        = is_header
      it_requests      = lt_requests
      iv_test_run      = iv_test_run ).
  ENDMETHOD.

  METHOD issue_project_wbs_atomic_uom.
    DATA(lt_base_requests) = prepare_wbs_requests_uom(
      is_header         = is_header
      it_requests       = it_requests
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
    rs_result = post_project_wbs_bulk_atomic(
      iv_movement_type = '221'
      is_header        = is_header
      it_requests      = lt_base_requests
      iv_test_run      = iv_test_run ).
  ENDMETHOD.

  METHOD return_project_wbs_atomic_uom.
    DATA lt_unit_requests TYPE ty_project_wbs_issue_requests_in_unit.
    DATA lt_return_requests TYPE ty_project_wbs_return_requests.

    LOOP AT it_requests INTO DATA(ls_unit_request).
      APPEND VALUE #(
        wbs_element   = ls_unit_request-wbs_element
        special_stock = ls_unit_request-special_stock
        items         = ls_unit_request-items )
        TO lt_unit_requests.
    ENDLOOP.

    DATA(lt_base_requests) = prepare_wbs_requests_uom(
      is_header         = is_header
      it_requests       = lt_unit_requests
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
    LOOP AT lt_base_requests INTO DATA(ls_base_request).
      APPEND VALUE #(
        wbs_element   = ls_base_request-wbs_element
        special_stock = ls_base_request-special_stock
        items         = ls_base_request-items )
        TO lt_return_requests.
    ENDLOOP.
    rs_result = return_project_wbs_bulk_atomic(
      is_header   = is_header
      it_requests = lt_return_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_to_project_wbs_uom.
    rs_result = post_project_wbs_in_unit(
      iv_wbs_element    = iv_wbs_element
      iv_special_stock  = iv_special_stock
      iv_movement_type  = '221'
      is_header         = is_header
      it_items          = it_items
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
  ENDMETHOD.

  METHOD return_from_project_wbs.
    rs_result = post_project_wbs(
      iv_wbs_element   = iv_wbs_element
      iv_special_stock = iv_special_stock
      iv_movement_type = '222'
      is_header        = is_header
      it_items         = it_items
      iv_test_run      = iv_test_run ).
  ENDMETHOD.

  METHOD return_from_project_wbs_uom.
    rs_result = post_project_wbs_in_unit(
      iv_wbs_element    = iv_wbs_element
      iv_special_stock  = iv_special_stock
      iv_movement_type  = '222'
      is_header         = is_header
      it_items          = it_items
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
  ENDMETHOD.

  METHOD transfer_project_wbs_stock.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF it_items IS INITIAL OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-source_wbs_element IS INITIAL
          OR ls_request-destination_wbs_element IS INITIAL
          OR ls_request-source_wbs_element
            = ls_request-destination_wbs_element
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material                   = ls_request-material
        plant                      = ls_request-plant
        storage_location           = ls_request-storage_location
        movement_type              = '415'
        quantity                   = ls_conversion-base_quantity
        entry_unit                 = ls_material_unit-base_unit
        entry_unit_iso             = ls_material_unit-base_unit_iso
        receiving_material         = ls_request-material
        receiving_plant            = ls_request-plant
        receiving_storage_location = ls_request-storage_location
        receiving_batch            = ls_request-batch
        wbs_element                = ls_request-destination_wbs_element
        valuation_wbs_element      = ls_request-source_wbs_element
        special_stock              = 'Q'
        batch                      = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD post_project_wbs.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_wbs_element IS INITIAL
        OR it_items IS INITIAL
        OR ( iv_special_stock IS NOT INITIAL
          AND iv_special_stock <> 'Q' )
        OR ( iv_movement_type <> '221'
          AND iv_movement_type <> '222' ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        wbs_element      = iv_wbs_element
        special_stock    = iv_special_stock
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = iv_movement_type
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header       = is_header
      iv_gm_code      = '03'
      it_items        = lt_movement_items
      iv_test_run     = iv_test_run
      iv_defer_commit = iv_defer_commit ).
  ENDMETHOD.

  METHOD prepare_wbs_requests_uom.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-items IS INITIAL
          OR ( ls_request-special_stock IS NOT INITIAL
            AND ls_request-special_stock <> 'Q' ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_base_request) = VALUE ty_project_wbs_issue_request(
        wbs_element   = ls_request-wbs_element
        special_stock = ls_request-special_stock ).
      LOOP AT ls_request-items INTO DATA(ls_item).
        IF ls_item-material IS INITIAL
            OR ls_item-plant IS INITIAL
            OR ls_item-storage_location IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        READ TABLE it_material_units INTO ls_material_unit
          WITH KEY material = ls_item-material.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
          iv_material    = ls_item-material
          iv_quantity    = ls_item-quantity
          iv_source_unit = ls_item-unit ).
        IF ls_conversion-is_successful <> abap_true
            OR ls_conversion-base_unit <> ls_material_unit-base_unit
            OR ls_conversion-base_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        APPEND VALUE #(
          material         = ls_item-material
          plant            = ls_item-plant
          storage_location = ls_item-storage_location
          batch            = ls_item-batch
          quantity         = ls_conversion-base_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso )
          TO ls_base_request-items.
      ENDLOOP.
      APPEND ls_base_request TO rt_requests.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_project_wbs_bulk_atomic.
    FIELD-SYMBOLS <ls_movement> TYPE ty_project_wbs_atomic_row_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_movement_type <> '221'
          AND iv_movement_type <> '222' ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_request_index) = sy-tabix.
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-items IS INITIAL
          OR ( ls_request-special_stock IS NOT INITIAL
            AND ls_request-special_stock <> 'Q' ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_request-items INTO DATA(ls_item).
        IF ls_item-material IS INITIAL
            OR ls_item-plant IS INITIAL
            OR ls_item-storage_location IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-entry_unit IS INITIAL
            OR ls_item-entry_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #(
        request_index = lv_request_index
        wbs_element   = ls_request-wbs_element )
        TO rs_result-movements.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-movements ASSIGNING <ls_movement>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_movement>-is_attempted = abap_true.
      <ls_movement>-movement_result = post_project_wbs(
        iv_wbs_element   = ls_request-wbs_element
        iv_special_stock = ls_request-special_stock
        iv_movement_type = iv_movement_type
        is_header        = is_header
        it_items         = ls_request-items
        iv_test_run      = iv_test_run
        iv_defer_commit  = abap_true ).
      IF <ls_movement>-movement_result-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      rs_result-is_successful = abap_false.
      IF iv_test_run = abap_false.
        rs_result-is_rolled_back = abap_true.
      ENDIF.
      LOOP AT rs_result-movements ASSIGNING <ls_movement>.
        <ls_movement>-movement_result-is_successful = abap_false.
        CLEAR: <ls_movement>-movement_result-material_document,
          <ls_movement>-movement_result-fiscal_year,
          <ls_movement>-is_committed.
      ENDLOOP.
      RETURN.
    ENDLOOP.

    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-is_successful = abap_true.
      rs_result-is_committed = abap_true.
      LOOP AT rs_result-movements ASSIGNING <ls_movement>.
        <ls_movement>-is_committed = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    mo_api->rollback( ).
    rs_result-is_successful = abap_false.
    rs_result-is_rolled_back = abap_true.
    LOOP AT rs_result-movements ASSIGNING <ls_movement>.
      <ls_movement>-movement_result-is_successful = abap_false.
      CLEAR: <ls_movement>-movement_result-material_document,
        <ls_movement>-movement_result-fiscal_year,
        <ls_movement>-is_committed.
    ENDLOOP.
    READ TABLE rs_result-movements ASSIGNING <ls_movement>
      INDEX lines( rs_result-movements ).
    IF sy-subrc = 0 AND rs_result-commit_result-message IS NOT INITIAL.
      APPEND rs_result-commit_result-message
        TO <ls_movement>-movement_result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD post_project_wbs_in_unit.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_wbs_element IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL
        OR ( iv_special_stock IS NOT INITIAL
          AND iv_special_stock <> 'Q' )
        OR ( iv_movement_type <> '221'
          AND iv_movement_type <> '222' ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        wbs_element      = iv_wbs_element
        special_stock    = iv_special_stock
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = iv_movement_type
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_project_wbs_allocation.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_split_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
      END OF ty_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_assignments TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_split_key
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR ( iv_special_stock IS NOT INITIAL
          AND iv_special_stock <> 'Q' )
        OR lines( it_wbs_assignments )
          <> lines( is_allocation-allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_wbs_assignments INTO DATA(ls_assignment).
      IF ls_assignment-request_id IS INITIAL
          OR ls_assignment-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_assignment-request_id )
        INTO TABLE lt_seen_assignments.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      DATA(ls_allocation) = ls_unit_allocation-allocation.
      IF ls_allocation-request_id IS INITIAL
          OR ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR ls_unit_allocation-source_quantity <= 0
          OR ls_unit_allocation-source_unit IS INITIAL
          OR ls_unit_allocation-base_quantity <= 0
          OR ls_unit_allocation-base_unit IS INITIAL
          OR ls_unit_allocation-base_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-available_quantity < 0
          OR ls_allocation-allocated_quantity < 0
          OR ls_allocation-shortfall_quantity < 0
          OR ls_allocation-allocated_quantity
            + ls_allocation-shortfall_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-allocated_quantity
            > ls_allocation-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_allocation-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_wbs_assignments INTO ls_assignment
        WITH KEY request_id = ls_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_allocation-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      LOOP AT is_allocation-storage_allocations
        INTO DATA(ls_storage_split).
        DATA(ls_raw_split) = ls_storage_split-storage_allocation.
        IF ls_raw_split-request_id <> ls_allocation-request_id.
          CONTINUE.
        ENDIF.
        IF ls_raw_split-material <> ls_allocation-material
            OR ls_raw_split-plant <> ls_allocation-plant
            OR ls_raw_split-storage_location IS INITIAL
            OR ls_raw_split-allocated_quantity <= 0
            OR ls_storage_split-base_unit <> ls_unit_allocation-base_unit
            OR ls_storage_split-source_unit
              <> ls_unit_allocation-source_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          request_id       = ls_raw_split-request_id
          storage_location = ls_raw_split-storage_location )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_raw_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          wbs_element      = ls_assignment-wbs_element
          material         = ls_allocation-material
          plant            = ls_allocation-plant
          storage_location = ls_raw_split-storage_location
          movement_type    = '221'
          special_stock    = iv_special_stock
          quantity         = ls_raw_split-allocated_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso )
          TO lt_movement_items.
      ENDLOOP.

      IF lv_split_quantity <> ls_allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lines( lt_seen_splits )
        <> lines( is_allocation-storage_allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF lt_movement_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated project WBS quantities to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_project_wbs_batch_alloc.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_batch_split_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_batch_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_assignments TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_batch_split_key
      WITH UNIQUE KEY request_id storage_location batch.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR ( iv_special_stock IS NOT INITIAL
          AND iv_special_stock <> 'Q' )
        OR lines( it_wbs_assignments )
          <> lines( is_allocation-allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_wbs_assignments INTO DATA(ls_assignment).
      IF ls_assignment-request_id IS INITIAL
          OR ls_assignment-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_assignment-request_id )
        INTO TABLE lt_seen_assignments.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      DATA(ls_allocation) = ls_unit_allocation-allocation.
      IF ls_allocation-request_id IS INITIAL
          OR ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR ls_unit_allocation-source_quantity <= 0
          OR ls_unit_allocation-source_unit IS INITIAL
          OR ls_unit_allocation-base_quantity <= 0
          OR ls_unit_allocation-base_unit IS INITIAL
          OR ls_unit_allocation-base_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-available_quantity < 0
          OR ls_allocation-allocated_quantity < 0
          OR ls_allocation-shortfall_quantity < 0
          OR ls_allocation-allocated_quantity
            + ls_allocation-shortfall_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-allocated_quantity
            > ls_allocation-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_allocation-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_wbs_assignments INTO ls_assignment
        WITH KEY request_id = ls_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_allocation-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_split).
        DATA(ls_raw_split) = ls_batch_split-batch_allocation.
        IF ls_raw_split-request_id <> ls_allocation-request_id.
          CONTINUE.
        ENDIF.
        IF ls_raw_split-material <> ls_allocation-material
            OR ls_raw_split-plant <> ls_allocation-plant
            OR ls_raw_split-storage_location IS INITIAL
            OR ls_raw_split-batch IS INITIAL
            OR ls_raw_split-allocated_quantity <= 0
            OR ls_batch_split-base_unit <> ls_unit_allocation-base_unit
            OR ls_batch_split-source_unit
              <> ls_unit_allocation-source_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          request_id       = ls_raw_split-request_id
          storage_location = ls_raw_split-storage_location
          batch            = ls_raw_split-batch )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_raw_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          wbs_element      = ls_assignment-wbs_element
          material         = ls_allocation-material
          plant            = ls_allocation-plant
          storage_location = ls_raw_split-storage_location
          batch            = ls_raw_split-batch
          movement_type    = '221'
          special_stock    = iv_special_stock
          quantity         = ls_raw_split-allocated_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso )
          TO lt_movement_items.
      ENDLOOP.

      IF lv_split_quantity <> ls_allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lines( lt_seen_splits ) <> lines( is_allocation-batch_allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF lt_movement_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated project WBS batch quantities to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD transfer_wbs_batch_alloc.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_batch_split_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_batch_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_assignments TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_batch_split_key
      WITH UNIQUE KEY request_id storage_location batch.
    DATA lt_transfer_lines TYPE ty_project_wbs_transfer_lines.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR lines( it_transfer_assignments )
          <> lines( is_allocation-allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_transfer_assignments INTO DATA(ls_transfer_assignment).
      IF ls_transfer_assignment-request_id IS INITIAL
          OR ls_transfer_assignment-source_wbs_element IS INITIAL
          OR ls_transfer_assignment-destination_wbs_element IS INITIAL
          OR ls_transfer_assignment-source_wbs_element
            = ls_transfer_assignment-destination_wbs_element.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_transfer_assignment-request_id )
        INTO TABLE lt_seen_assignments.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      DATA(ls_allocation) = ls_unit_allocation-allocation.
      IF ls_allocation-request_id IS INITIAL
          OR ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR ls_unit_allocation-source_quantity <= 0
          OR ls_unit_allocation-source_unit IS INITIAL
          OR ls_unit_allocation-base_quantity <= 0
          OR ls_unit_allocation-base_unit IS INITIAL
          OR ls_unit_allocation-base_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-available_quantity < 0
          OR ls_allocation-allocated_quantity < 0
          OR ls_allocation-shortfall_quantity < 0
          OR ls_allocation-allocated_quantity
            + ls_allocation-shortfall_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-allocated_quantity
            > ls_allocation-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_allocation-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_transfer_assignments INTO ls_transfer_assignment
        WITH KEY request_id = ls_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_allocation-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_split).
        DATA(ls_raw_split) = ls_batch_split-batch_allocation.
        IF ls_raw_split-request_id <> ls_allocation-request_id.
          CONTINUE.
        ENDIF.
        IF ls_raw_split-material <> ls_allocation-material
            OR ls_raw_split-plant <> ls_allocation-plant
            OR ls_raw_split-storage_location IS INITIAL
            OR ls_raw_split-batch IS INITIAL
            OR ls_raw_split-allocated_quantity <= 0
            OR ls_batch_split-base_unit <> ls_unit_allocation-base_unit
            OR ls_batch_split-source_unit
              <> ls_unit_allocation-source_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          request_id       = ls_raw_split-request_id
          storage_location = ls_raw_split-storage_location
          batch            = ls_raw_split-batch )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_raw_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          source_wbs_element      =
            ls_transfer_assignment-source_wbs_element
          destination_wbs_element =
            ls_transfer_assignment-destination_wbs_element
          material                = ls_allocation-material
          plant                   = ls_allocation-plant
          storage_location        = ls_raw_split-storage_location
          batch                   = ls_raw_split-batch
          expiration_date         = ls_raw_split-expiration_date
          quantity                = ls_raw_split-allocated_quantity
          unit                    = ls_unit_allocation-base_unit )
          TO lt_transfer_lines.
      ENDLOOP.

      IF lv_split_quantity <> ls_allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lines( lt_seen_splits ) <> lines( is_allocation-batch_allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF lt_transfer_lines IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated project WBS batch quantities to transfer' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = transfer_project_wbs_stock(
      is_header         = is_header
      it_items          = lt_transfer_lines
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
  ENDMETHOD.

  METHOD transfer_wbs_location_alloc.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_location_split_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
      END OF ty_location_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_assignments TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_location_split_key
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_transfer_lines TYPE ty_project_wbs_transfer_lines.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR lines( it_transfer_assignments )
          <> lines( is_allocation-allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_transfer_assignments INTO DATA(ls_transfer_assignment).
      IF ls_transfer_assignment-request_id IS INITIAL
          OR ls_transfer_assignment-source_wbs_element IS INITIAL
          OR ls_transfer_assignment-destination_wbs_element IS INITIAL
          OR ls_transfer_assignment-source_wbs_element
            = ls_transfer_assignment-destination_wbs_element.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_transfer_assignment-request_id )
        INTO TABLE lt_seen_assignments.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      DATA(ls_allocation) = ls_unit_allocation-allocation.
      IF ls_allocation-request_id IS INITIAL
          OR ls_allocation-material IS INITIAL
          OR ls_allocation-plant IS INITIAL
          OR ls_unit_allocation-source_quantity <= 0
          OR ls_unit_allocation-source_unit IS INITIAL
          OR ls_unit_allocation-base_quantity <= 0
          OR ls_unit_allocation-base_unit IS INITIAL
          OR ls_unit_allocation-base_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-available_quantity < 0
          OR ls_allocation-allocated_quantity < 0
          OR ls_allocation-shortfall_quantity < 0
          OR ls_allocation-allocated_quantity
            + ls_allocation-shortfall_quantity
            <> ls_allocation-requested_quantity
          OR ls_allocation-allocated_quantity
            > ls_allocation-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_allocation-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_transfer_assignments INTO ls_transfer_assignment
        WITH KEY request_id = ls_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_allocation-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      LOOP AT is_allocation-storage_allocations
        INTO DATA(ls_storage_split).
        DATA(ls_raw_split) = ls_storage_split-storage_allocation.
        IF ls_raw_split-request_id <> ls_allocation-request_id.
          CONTINUE.
        ENDIF.
        IF ls_raw_split-material <> ls_allocation-material
            OR ls_raw_split-plant <> ls_allocation-plant
            OR ls_raw_split-storage_location IS INITIAL
            OR ls_raw_split-allocated_quantity <= 0
            OR ls_storage_split-base_unit <> ls_unit_allocation-base_unit
            OR ls_storage_split-source_unit
              <> ls_unit_allocation-source_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          request_id       = ls_raw_split-request_id
          storage_location = ls_raw_split-storage_location )
          INTO TABLE lt_seen_splits.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        ADD ls_raw_split-allocated_quantity TO lv_split_quantity.
        APPEND VALUE #(
          source_wbs_element      =
            ls_transfer_assignment-source_wbs_element
          destination_wbs_element =
            ls_transfer_assignment-destination_wbs_element
          material                = ls_allocation-material
          plant                   = ls_allocation-plant
          storage_location        = ls_raw_split-storage_location
          quantity                = ls_raw_split-allocated_quantity
          unit                    = ls_unit_allocation-base_unit )
          TO lt_transfer_lines.
      ENDLOOP.

      IF lv_split_quantity <> ls_allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lines( lt_seen_splits ) <> lines( is_allocation-storage_allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF lt_transfer_lines IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated project WBS location quantities to transfer' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = transfer_project_wbs_stock(
      is_header         = is_header
      it_items          = lt_transfer_lines
      it_material_units = it_material_units
      iv_test_run       = iv_test_run ).
  ENDMETHOD.

  METHOD transfer_wbs_fefo.
    DATA lt_first_lines TYPE ty_project_wbs_transfer_lines.
    DATA lt_rechecked_lines TYPE ty_project_wbs_transfer_lines.

    IF io_stock_service IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-preview = io_stock_service->preview_transfer_fefo(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    DATA(ls_rechecked_preview) = io_stock_service->preview_transfer_fefo(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).

    LOOP AT rs_result-preview-allocation-batch_allocations
      INTO DATA(ls_first_batch).
      READ TABLE rs_result-preview-transfer_assignments
        INTO DATA(ls_first_assignment)
        WITH KEY request_id =
          ls_first_batch-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      = ls_first_assignment-source_wbs_element
        destination_wbs_element =
          ls_first_assignment-destination_wbs_element
        material                = ls_first_batch-batch_allocation-material
        plant                   = ls_first_batch-batch_allocation-plant
        storage_location        =
          ls_first_batch-batch_allocation-storage_location
        batch                   = ls_first_batch-batch_allocation-batch
        expiration_date         =
          ls_first_batch-batch_allocation-expiration_date
        quantity                =
          ls_first_batch-batch_allocation-allocated_quantity
        unit                    = ls_first_batch-base_unit )
        TO lt_first_lines.
    ENDLOOP.
    LOOP AT ls_rechecked_preview-allocation-batch_allocations
      INTO DATA(ls_rechecked_batch).
      READ TABLE ls_rechecked_preview-transfer_assignments
        INTO DATA(ls_rechecked_assignment)
        WITH KEY request_id =
          ls_rechecked_batch-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      = ls_rechecked_assignment-source_wbs_element
        destination_wbs_element =
          ls_rechecked_assignment-destination_wbs_element
        material                =
          ls_rechecked_batch-batch_allocation-material
        plant                   = ls_rechecked_batch-batch_allocation-plant
        storage_location        =
          ls_rechecked_batch-batch_allocation-storage_location
        batch                   = ls_rechecked_batch-batch_allocation-batch
        expiration_date         =
          ls_rechecked_batch-batch_allocation-expiration_date
        quantity                =
          ls_rechecked_batch-batch_allocation-allocated_quantity
        unit                    = ls_rechecked_batch-base_unit )
        TO lt_rechecked_lines.
    ENDLOOP.

    IF same_wbs_xfer_lines(
        it_first  = lt_first_lines
        it_second = lt_rechecked_lines ) <> abap_true.
      rs_result-movement-is_successful = abap_false.
      APPEND VALUE #(
        type    = 'E'
        message = 'WBS transfer FEFO allocation changed; no movement was posted' )
        TO rs_result-movement-messages.
      RETURN.
    ENDIF.

    rs_result-movement = transfer_wbs_batch_alloc(
      is_header                  = is_header
      is_allocation              = rs_result-preview-allocation
      it_transfer_assignments    =
        rs_result-preview-transfer_assignments
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity ).
  ENDMETHOD.

  METHOD transfer_wbs_fefo_by_date.
    DATA lt_first_lines TYPE ty_project_wbs_transfer_lines.
    DATA lt_rechecked_lines TYPE ty_project_wbs_transfer_lines.
    DATA ls_allocation TYPE zcl_stock_service=>ty_unit_batch_result.
    DATA lt_transfer_assignments TYPE ty_project_wbs_transfer_assignments.

    IF io_stock_service IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-preview = io_stock_service->preview_transfer_fefo_by_date(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    DATA(ls_rechecked_preview) = io_stock_service->preview_transfer_fefo_by_date(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).

    LOOP AT rs_result-preview-allocations INTO DATA(ls_dated_allocation).
      APPEND ls_dated_allocation-allocation TO ls_allocation-allocations.
    ENDLOOP.
    LOOP AT rs_result-preview-batch_allocations INTO DATA(ls_dated_split).
      APPEND ls_dated_split-split TO ls_allocation-batch_allocations.
      READ TABLE rs_result-preview-transfer_assignments
        INTO DATA(ls_first_assignment)
        WITH KEY request_id =
          ls_dated_split-split-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      = ls_first_assignment-source_wbs_element
        destination_wbs_element =
          ls_first_assignment-destination_wbs_element
        material                =
          ls_dated_split-split-batch_allocation-material
        plant                   = ls_dated_split-split-batch_allocation-plant
        storage_location        =
          ls_dated_split-split-batch_allocation-storage_location
        batch                   = ls_dated_split-split-batch_allocation-batch
        expiration_date         =
          ls_dated_split-split-batch_allocation-expiration_date
        quantity                =
          ls_dated_split-split-batch_allocation-allocated_quantity
        unit                    = ls_dated_split-split-base_unit )
        TO lt_first_lines.
    ENDLOOP.
    LOOP AT rs_result-preview-transfer_assignments
        INTO DATA(ls_dated_assignment).
      APPEND VALUE #(
        request_id              = ls_dated_assignment-request_id
        source_wbs_element      = ls_dated_assignment-source_wbs_element
        destination_wbs_element =
          ls_dated_assignment-destination_wbs_element )
        TO lt_transfer_assignments.
    ENDLOOP.

    LOOP AT ls_rechecked_preview-batch_allocations
        INTO DATA(ls_rechecked_split).
      READ TABLE ls_rechecked_preview-transfer_assignments
        INTO DATA(ls_rechecked_assignment)
        WITH KEY request_id =
          ls_rechecked_split-split-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      =
          ls_rechecked_assignment-source_wbs_element
        destination_wbs_element =
          ls_rechecked_assignment-destination_wbs_element
        material                =
          ls_rechecked_split-split-batch_allocation-material
        plant                   =
          ls_rechecked_split-split-batch_allocation-plant
        storage_location        =
          ls_rechecked_split-split-batch_allocation-storage_location
        batch                   =
          ls_rechecked_split-split-batch_allocation-batch
        expiration_date         =
          ls_rechecked_split-split-batch_allocation-expiration_date
        quantity                =
          ls_rechecked_split-split-batch_allocation-allocated_quantity
        unit                    = ls_rechecked_split-split-base_unit )
        TO lt_rechecked_lines.
    ENDLOOP.

    IF same_wbs_xfer_lines(
        it_first  = lt_first_lines
        it_second = lt_rechecked_lines ) <> abap_true.
      rs_result-movement-is_successful = abap_false.
      APPEND VALUE #(
        type    = 'E'
        message = 'Dated WBS transfer FEFO allocation changed; no movement was posted' )
        TO rs_result-movement-messages.
      RETURN.
    ENDIF.

    rs_result-movement = transfer_wbs_batch_alloc(
      is_header                  = is_header
      is_allocation              = ls_allocation
      it_transfer_assignments    = lt_transfer_assignments
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity ).
  ENDMETHOD.

  METHOD transfer_wbs_by_location.
    DATA lt_first_lines TYPE ty_project_wbs_transfer_lines.
    DATA lt_rechecked_lines TYPE ty_project_wbs_transfer_lines.

    IF io_stock_service IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-preview = io_stock_service->preview_transfer_by_location(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    DATA(ls_rechecked_preview) =
      io_stock_service->preview_transfer_by_location(
        it_demands                   = it_demands
        it_storage_location_priority = it_storage_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_require_full_quantity     = iv_require_full_quantity
        iv_reservation_through_date  = iv_reservation_through_date ).

    LOOP AT rs_result-preview-allocation-storage_allocations
      INTO DATA(ls_first_location).
      READ TABLE rs_result-preview-transfer_assignments
        INTO DATA(ls_first_location_assignment)
        WITH KEY request_id =
          ls_first_location-storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      =
          ls_first_location_assignment-source_wbs_element
        destination_wbs_element =
          ls_first_location_assignment-destination_wbs_element
        material                =
          ls_first_location-storage_allocation-material
        plant                   = ls_first_location-storage_allocation-plant
        storage_location        =
          ls_first_location-storage_allocation-storage_location
        quantity                =
          ls_first_location-storage_allocation-allocated_quantity
        unit                    = ls_first_location-base_unit )
        TO lt_first_lines.
    ENDLOOP.
    LOOP AT ls_rechecked_preview-allocation-storage_allocations
      INTO DATA(ls_rechecked_location).
      READ TABLE ls_rechecked_preview-transfer_assignments
        INTO DATA(ls_recheck_loc_assign)
        WITH KEY request_id =
          ls_rechecked_location-storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      =
          ls_recheck_loc_assign-source_wbs_element
        destination_wbs_element =
          ls_recheck_loc_assign-destination_wbs_element
        material                =
          ls_rechecked_location-storage_allocation-material
        plant                   =
          ls_rechecked_location-storage_allocation-plant
        storage_location        =
          ls_rechecked_location-storage_allocation-storage_location
        quantity                =
          ls_rechecked_location-storage_allocation-allocated_quantity
        unit                    = ls_rechecked_location-base_unit )
        TO lt_rechecked_lines.
    ENDLOOP.

    IF same_wbs_xfer_lines(
        it_first  = lt_first_lines
        it_second = lt_rechecked_lines ) <> abap_true.
      rs_result-movement-is_successful = abap_false.
      APPEND VALUE #(
        type    = 'E'
        message = 'WBS transfer location allocation changed; no movement was posted' )
        TO rs_result-movement-messages.
      RETURN.
    ENDIF.

    rs_result-movement = transfer_wbs_location_alloc(
      is_header                  = is_header
      is_allocation              = rs_result-preview-allocation
      it_transfer_assignments    =
        rs_result-preview-transfer_assignments
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity ).
  ENDMETHOD.

  METHOD transfer_wbs_by_location_date.
    DATA lt_first_lines TYPE ty_project_wbs_transfer_lines.
    DATA lt_rechecked_lines TYPE ty_project_wbs_transfer_lines.
    DATA ls_allocation TYPE zcl_stock_service=>ty_unit_location_result.
    DATA lt_transfer_assignments TYPE ty_project_wbs_transfer_assignments.

    IF io_stock_service IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-preview = io_stock_service->preview_transfer_location_date(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    DATA(ls_rechecked_preview) =
      io_stock_service->preview_transfer_location_date(
        it_demands                   = it_demands
        it_storage_location_priority = it_storage_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_require_full_quantity     = iv_require_full_quantity
        iv_reservation_through_date  = iv_reservation_through_date ).

    LOOP AT rs_result-preview-allocations INTO DATA(ls_dated_allocation).
      APPEND ls_dated_allocation-allocation TO ls_allocation-allocations.
    ENDLOOP.
    LOOP AT rs_result-preview-storage_allocations INTO DATA(ls_dated_split).
      APPEND ls_dated_split-split TO ls_allocation-storage_allocations.
      READ TABLE rs_result-preview-transfer_assignments
        INTO DATA(ls_first_assignment)
        WITH KEY request_id =
          ls_dated_split-split-storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      = ls_first_assignment-source_wbs_element
        destination_wbs_element =
          ls_first_assignment-destination_wbs_element
        material                =
          ls_dated_split-split-storage_allocation-material
        plant                   =
          ls_dated_split-split-storage_allocation-plant
        storage_location        =
          ls_dated_split-split-storage_allocation-storage_location
        quantity                =
          ls_dated_split-split-storage_allocation-allocated_quantity
        unit                    = ls_dated_split-split-base_unit )
        TO lt_first_lines.
    ENDLOOP.
    LOOP AT rs_result-preview-transfer_assignments
        INTO DATA(ls_dated_assignment).
      APPEND VALUE #(
        request_id              = ls_dated_assignment-request_id
        source_wbs_element      = ls_dated_assignment-source_wbs_element
        destination_wbs_element =
          ls_dated_assignment-destination_wbs_element )
        TO lt_transfer_assignments.
    ENDLOOP.

    LOOP AT ls_rechecked_preview-storage_allocations
        INTO DATA(ls_rechecked_split).
      READ TABLE ls_rechecked_preview-transfer_assignments
        INTO DATA(ls_rechecked_assignment)
        WITH KEY request_id =
          ls_rechecked_split-split-storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        source_wbs_element      =
          ls_rechecked_assignment-source_wbs_element
        destination_wbs_element =
          ls_rechecked_assignment-destination_wbs_element
        material                =
          ls_rechecked_split-split-storage_allocation-material
        plant                   =
          ls_rechecked_split-split-storage_allocation-plant
        storage_location        =
          ls_rechecked_split-split-storage_allocation-storage_location
        quantity                =
          ls_rechecked_split-split-storage_allocation-allocated_quantity
        unit                    = ls_rechecked_split-split-base_unit )
        TO lt_rechecked_lines.
    ENDLOOP.

    IF same_wbs_xfer_lines(
        it_first  = lt_first_lines
        it_second = lt_rechecked_lines ) <> abap_true.
      rs_result-movement-is_successful = abap_false.
      APPEND VALUE #(
        type    = 'E'
        message = 'Dated WBS transfer location allocation changed; no movement was posted' )
        TO rs_result-movement-messages.
      RETURN.
    ENDIF.

    rs_result-movement = transfer_wbs_location_alloc(
      is_header                  = is_header
      is_allocation              = ls_allocation
      it_transfer_assignments    = lt_transfer_assignments
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity ).
  ENDMETHOD.

  METHOD same_wbs_xfer_lines.
    DATA lt_first TYPE ty_project_wbs_transfer_lines.
    DATA lt_second TYPE ty_project_wbs_transfer_lines.

    rv_same = abap_false.
    IF lines( it_first ) <> lines( it_second ).
      RETURN.
    ENDIF.

    lt_first = it_first.
    lt_second = it_second.
    SORT lt_first BY source_wbs_element destination_wbs_element material
      plant storage_location batch expiration_date quantity unit.
    SORT lt_second BY source_wbs_element destination_wbs_element material
      plant storage_location batch expiration_date quantity unit.

    LOOP AT lt_first INTO DATA(ls_first).
      READ TABLE lt_second INDEX sy-tabix INTO DATA(ls_second).
      IF sy-subrc <> 0
          OR ls_first-source_wbs_element <> ls_second-source_wbs_element
          OR ls_first-destination_wbs_element
            <> ls_second-destination_wbs_element
          OR ls_first-material <> ls_second-material
          OR ls_first-plant <> ls_second-plant
          OR ls_first-storage_location <> ls_second-storage_location
          OR ls_first-batch <> ls_second-batch
          OR ls_first-expiration_date <> ls_second-expiration_date
          OR ls_first-quantity <> ls_second-quantity
          OR ls_first-unit <> ls_second-unit.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_same = abap_true.
  ENDMETHOD.

  METHOD issue_sales_order_allocation.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      BEGIN OF ty_split_key,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_split_key.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_allocation_requests TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY request_id.
    DATA lt_seen_materials TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_seen_splits TYPE HASHED TABLE OF ty_split_key
      WITH UNIQUE KEY request_id storage_location batch.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.
    DATA lv_processed_split_count TYPE i.
    DATA lv_expected_request_id TYPE c LENGTH 30.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR is_allocation-is_successful <> abap_true
        OR is_allocation-sales_document IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF is_allocation-batch_allocations IS NOT INITIAL
        AND is_allocation-storage_allocations IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF lines( is_allocation-allocations )
        <> lines( is_allocation-sales_unit_allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-allocations INTO DATA(ls_raw_allocation).
      IF ls_raw_allocation-request_id IS INITIAL
          OR ls_raw_allocation-material IS INITIAL
          OR ls_raw_allocation-plant IS INITIAL
          OR ls_raw_allocation-requested_quantity <= 0
          OR ls_raw_allocation-available_quantity < 0
          OR ls_raw_allocation-allocated_quantity < 0
          OR ls_raw_allocation-shortfall_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_raw_allocation-request_id )
        INTO TABLE lt_seen_allocation_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-sales_unit_allocations
      INTO DATA(ls_sales_allocation).
      CLEAR lv_expected_request_id.
      IF ls_sales_allocation-schedule_line IS INITIAL.
        CONCATENATE ls_sales_allocation-sales_document
          ls_sales_allocation-item_number
          INTO lv_expected_request_id SEPARATED BY '/'.
      ELSE.
        CONCATENATE ls_sales_allocation-sales_document
          ls_sales_allocation-item_number
          ls_sales_allocation-schedule_line
          INTO lv_expected_request_id SEPARATED BY '/'.
      ENDIF.
      IF ls_sales_allocation-request_id IS INITIAL
          OR ls_sales_allocation-sales_document
            <> is_allocation-sales_document
          OR ls_sales_allocation-request_id <> lv_expected_request_id
          OR ls_sales_allocation-item_number IS INITIAL
          OR ls_sales_allocation-material IS INITIAL
          OR ls_sales_allocation-plant IS INITIAL
          OR ls_sales_allocation-base_unit IS INITIAL
          OR ls_sales_allocation-requested_base_quantity <= 0
          OR ls_sales_allocation-available_base_quantity < 0
          OR ls_sales_allocation-allocated_base_quantity < 0
          OR ls_sales_allocation-shortfall_base_quantity < 0
          OR ls_sales_allocation-allocated_base_quantity
            + ls_sales_allocation-shortfall_base_quantity
            <> ls_sales_allocation-requested_base_quantity
          OR ls_sales_allocation-allocated_base_quantity
            > ls_sales_allocation-available_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_sales_allocation-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE is_allocation-allocations INTO ls_raw_allocation
        WITH KEY request_id = ls_sales_allocation-request_id.
      IF sy-subrc <> 0
          OR ls_raw_allocation-material <> ls_sales_allocation-material
          OR ls_raw_allocation-plant <> ls_sales_allocation-plant
          OR ls_raw_allocation-requested_quantity
            <> ls_sales_allocation-requested_base_quantity
          OR ls_raw_allocation-available_quantity
            <> ls_sales_allocation-available_base_quantity
          OR ls_raw_allocation-allocated_quantity
            <> ls_sales_allocation-allocated_base_quantity
          OR ls_raw_allocation-shortfall_quantity
            <> ls_sales_allocation-shortfall_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_sales_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_sales_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_sales_allocation-shortfall_base_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_split_quantity TYPE mard-labst.
      CLEAR lv_split_quantity.
      IF is_allocation-batch_allocations IS NOT INITIAL.
        LOOP AT is_allocation-batch_allocations
          INTO DATA(ls_batch_split)
          WHERE request_id = ls_sales_allocation-request_id.
          IF ls_batch_split-material <> ls_sales_allocation-material
              OR ls_batch_split-plant <> ls_sales_allocation-plant
              OR ls_batch_split-storage_location IS INITIAL
              OR ls_batch_split-batch IS INITIAL
              OR ls_batch_split-allocated_quantity <= 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          INSERT VALUE #(
            request_id       = ls_batch_split-request_id
            storage_location = ls_batch_split-storage_location
            batch            = ls_batch_split-batch )
            INTO TABLE lt_seen_splits.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          ADD ls_batch_split-allocated_quantity TO lv_split_quantity.
          ADD 1 TO lv_processed_split_count.
          APPEND VALUE #(
            sales_order      = is_allocation-sales_document
            sales_order_item = ls_sales_allocation-item_number
            material         = ls_sales_allocation-material
            plant            = ls_sales_allocation-plant
            storage_location = ls_batch_split-storage_location
            movement_type    = '231'
            quantity         = ls_batch_split-allocated_quantity
            entry_unit       = ls_material_unit-base_unit
            entry_unit_iso   = ls_material_unit-base_unit_iso
            batch            = ls_batch_split-batch )
            TO lt_movement_items.
        ENDLOOP.
      ELSE.
        LOOP AT is_allocation-storage_allocations
          INTO DATA(ls_storage_split)
          WHERE request_id = ls_sales_allocation-request_id.
          IF ls_storage_split-material <> ls_sales_allocation-material
              OR ls_storage_split-plant <> ls_sales_allocation-plant
              OR ls_storage_split-storage_location IS INITIAL
              OR ls_storage_split-allocated_quantity <= 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          INSERT VALUE #(
            request_id       = ls_storage_split-request_id
            storage_location = ls_storage_split-storage_location )
            INTO TABLE lt_seen_splits.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          ADD ls_storage_split-allocated_quantity TO lv_split_quantity.
          ADD 1 TO lv_processed_split_count.
          APPEND VALUE #(
            sales_order      = is_allocation-sales_document
            sales_order_item = ls_sales_allocation-item_number
            material         = ls_sales_allocation-material
            plant            = ls_sales_allocation-plant
            storage_location = ls_storage_split-storage_location
            movement_type    = '231'
            quantity         = ls_storage_split-allocated_quantity
            entry_unit       = ls_material_unit-base_unit
            entry_unit_iso   = ls_material_unit-base_unit_iso )
            TO lt_movement_items.
        ENDLOOP.
      ENDIF.

      IF lv_split_quantity
          <> ls_sales_allocation-allocated_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF is_allocation-batch_allocations IS NOT INITIAL.
      IF lv_processed_split_count
          <> lines( is_allocation-batch_allocations ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ELSEIF lv_processed_split_count
        <> lines( is_allocation-storage_allocations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF lt_movement_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated sales-order quantity to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_unplanned_prod_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_production_order IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        order_id         = iv_production_order
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = '261'
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_unplanned_prod_order_uom.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_production_order IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        order_id         = iv_production_order
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = '261'
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_to_production_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_production_order IS INITIAL OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-storage_location IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        order_id         = iv_production_order
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        movement_type    = '262'
        quantity         = ls_item-quantity
        entry_unit       = ls_item-entry_unit
        entry_unit_iso   = ls_item-entry_unit_iso
        batch            = ls_item-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_to_production_order_uom.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key.
    DATA lt_seen_mappings TYPE HASHED TABLE OF ty_material_key
      WITH UNIQUE KEY material.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_production_order IS INITIAL
        OR it_items IS INITIAL
        OR it_material_units IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_mappings.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_items INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_material_unit-base_unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        order_id         = iv_production_order
        material         = ls_request-material
        plant            = ls_request-plant
        storage_location = ls_request-storage_location
        movement_type    = '262'
        quantity         = ls_conversion-base_quantity
        entry_unit       = ls_material_unit-base_unit
        entry_unit_iso   = ls_material_unit-base_unit_iso
        batch            = ls_request-batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_unplanned_prod_bulk.
    FIELD-SYMBOLS <ls_issue> TYPE ty_prod_issue_row_result.

    validate_unplanned_prod_issues(
      is_header   = is_header
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_index    = sy-tabix
        production_order = ls_request-production_order )
        TO rs_result-issues.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-issues ASSIGNING <ls_issue>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_issue>-is_attempted = abap_true.
      <ls_issue>-issue_result = issue_unplanned_prod_order(
        iv_production_order = ls_request-production_order
        is_header           = is_header
        it_items            = ls_request-items
        iv_test_run         = iv_test_run ).
      IF <ls_issue>-issue_result-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        <ls_issue>-is_committed = xsdbool(
          iv_test_run = abap_false ).
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD receive_purchase_order.
    DATA lt_requests TYPE ty_po_receipt_requests.

    APPEND is_request TO lt_requests.
    validate_po_receipts(
      is_header   = is_header
      it_requests = lt_requests
      iv_test_run = iv_test_run ).

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '01'
      it_items    = build_po_receipt_items( is_request )
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD receive_purchase_orders_bulk.
    FIELD-SYMBOLS <ls_receipt> TYPE ty_po_receipt_row_result.

    validate_po_receipts(
      is_header   = is_header
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_index         = sy-tabix
        purchase_order_number = ls_request-purchase_order_number )
        TO rs_result-receipts.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-receipts ASSIGNING <ls_receipt>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_receipt>-is_attempted = abap_true.
      <ls_receipt>-receipt_result = receive_purchase_order(
        is_header   = is_header
        is_request  = ls_request
        iv_test_run = iv_test_run ).
      IF <ls_receipt>-receipt_result-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        <ls_receipt>-is_committed = xsdbool(
          iv_test_run = abap_false ).
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD receive_purchase_orders_atomic.
    FIELD-SYMBOLS <ls_receipt> TYPE ty_po_receipt_row_result.

    validate_po_receipts(
      is_header   = is_header
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_index         = sy-tabix
        purchase_order_number = ls_request-purchase_order_number )
        TO rs_result-receipts.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-receipts ASSIGNING <ls_receipt>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_receipt>-is_attempted = abap_true.
      <ls_receipt>-receipt_result = execute(
        is_header       = is_header
        iv_gm_code      = '01'
        it_items        = build_po_receipt_items( ls_request )
        iv_test_run     = iv_test_run
        iv_defer_commit = abap_true ).
      IF <ls_receipt>-receipt_result-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      rs_result-is_successful = abap_false.
      LOOP AT rs_result-receipts ASSIGNING <ls_receipt>.
        <ls_receipt>-receipt_result-is_successful = abap_false.
        CLEAR: <ls_receipt>-receipt_result-material_document,
          <ls_receipt>-receipt_result-fiscal_year,
          <ls_receipt>-is_committed.
      ENDLOOP.
      IF iv_test_run = abap_false.
        rs_result-is_rolled_back = abap_true.
      ENDIF.
      RETURN.
    ENDLOOP.

    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-is_successful = abap_true.
      rs_result-is_committed = abap_true.
      LOOP AT rs_result-receipts ASSIGNING <ls_receipt>.
        <ls_receipt>-is_committed = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    mo_api->rollback( ).
    rs_result-is_successful = abap_false.
    rs_result-is_rolled_back = abap_true.
    LOOP AT rs_result-receipts ASSIGNING <ls_receipt>.
      <ls_receipt>-receipt_result-is_successful = abap_false.
      CLEAR: <ls_receipt>-receipt_result-material_document,
        <ls_receipt>-receipt_result-fiscal_year,
        <ls_receipt>-is_committed.
    ENDLOOP.
    READ TABLE rs_result-receipts ASSIGNING <ls_receipt>
      INDEX lines( rs_result-receipts ).
    IF sy-subrc = 0 AND rs_result-commit_result-message IS NOT INITIAL.
      APPEND rs_result-commit_result-message
        TO <ls_receipt>-receipt_result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD validate_header_dates.
    IF zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_header-posting_date ) <> abap_true
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_header-document_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD validate_optional_post_date.
    IF iv_date IS NOT INITIAL
        AND zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD validate_po_receipts.
    TYPES ty_purchase_order_number TYPE eord-ebeln.
    TYPES ty_item_number TYPE c LENGTH 5.
    DATA lt_purchase_orders TYPE HASHED TABLE OF
      ty_purchase_order_number WITH UNIQUE KEY table_line.
    DATA lt_item_numbers TYPE HASHED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-purchase_order_number IS INITIAL
          OR ls_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-purchase_order_number INTO TABLE lt_purchase_orders.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      CLEAR lt_item_numbers.
      LOOP AT ls_request-items INTO DATA(ls_line).
        INSERT ls_line-purchase_order_item INTO TABLE lt_item_numbers.
        IF ls_line-purchase_order_item IS INITIAL
            OR sy-subrc <> 0
            OR ls_line-quantity <= 0
            OR ls_line-entry_unit IS INITIAL
            OR ls_line-entry_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_po_receipt_items.
    LOOP AT is_request-items INTO DATA(ls_line).
      APPEND VALUE #(
        material            = ls_line-material
        plant               = ls_line-plant
        storage_location    = ls_line-storage_location
        movement_type       = '101'
        quantity            = ls_line-quantity
        entry_unit          = ls_line-entry_unit
        entry_unit_iso      = ls_line-entry_unit_iso
        movement_indicator  = 'B'
        batch               = ls_line-batch
        purchase_order      = is_request-purchase_order_number
        purchase_order_item = ls_line-purchase_order_item )
        TO rt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD receive_prod_order.
    DATA lt_requests TYPE ty_prod_receipt_requests.

    APPEND is_request TO lt_requests.
    validate_prod_receipts(
      is_header   = is_header
      it_requests = lt_requests
      iv_test_run = iv_test_run ).

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '02'
      it_items    = build_prod_receipt_items( is_request )
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD receive_prod_orders_bulk.
    FIELD-SYMBOLS <ls_receipt> TYPE ty_prod_receipt_row_result.

    validate_prod_receipts(
      is_header   = is_header
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_index    = sy-tabix
        production_order = ls_request-production_order )
        TO rs_result-receipts.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-receipts ASSIGNING <ls_receipt>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_receipt>-is_attempted = abap_true.
      <ls_receipt>-receipt_result = receive_prod_order(
        is_header   = is_header
        is_request  = ls_request
        iv_test_run = iv_test_run ).
      IF <ls_receipt>-receipt_result-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        <ls_receipt>-is_committed = xsdbool(
          iv_test_run = abap_false ).
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD receive_prod_orders_atomic.
    FIELD-SYMBOLS <ls_receipt> TYPE ty_prod_receipt_row_result.

    validate_prod_receipts(
      is_header   = is_header
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_index    = sy-tabix
        production_order = ls_request-production_order )
        TO rs_result-receipts.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-receipts ASSIGNING <ls_receipt>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      <ls_receipt>-is_attempted = abap_true.
      <ls_receipt>-receipt_result = execute(
        is_header       = is_header
        iv_gm_code      = '02'
        it_items        = build_prod_receipt_items( ls_request )
        iv_test_run     = iv_test_run
        iv_defer_commit = abap_true ).
      IF <ls_receipt>-receipt_result-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      rs_result-is_successful = abap_false.
      LOOP AT rs_result-receipts ASSIGNING <ls_receipt>.
        <ls_receipt>-receipt_result-is_successful = abap_false.
        CLEAR: <ls_receipt>-receipt_result-material_document,
          <ls_receipt>-receipt_result-fiscal_year,
          <ls_receipt>-is_committed.
      ENDLOOP.
      IF iv_test_run = abap_false.
        rs_result-is_rolled_back = abap_true.
      ENDIF.
      RETURN.
    ENDLOOP.

    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    IF rs_result-commit_result-is_successful = abap_true.
      rs_result-is_committed = abap_true.
      LOOP AT rs_result-receipts ASSIGNING <ls_receipt>.
        <ls_receipt>-is_committed = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    mo_api->rollback( ).
    rs_result-is_successful = abap_false.
    rs_result-is_rolled_back = abap_true.
    LOOP AT rs_result-receipts ASSIGNING <ls_receipt>.
      <ls_receipt>-receipt_result-is_successful = abap_false.
      CLEAR: <ls_receipt>-receipt_result-material_document,
        <ls_receipt>-receipt_result-fiscal_year,
        <ls_receipt>-is_committed.
    ENDLOOP.
    READ TABLE rs_result-receipts ASSIGNING <ls_receipt>
      INDEX lines( rs_result-receipts ).
    IF sy-subrc = 0 AND rs_result-commit_result-message IS NOT INITIAL.
      APPEND rs_result-commit_result-message
        TO <ls_receipt>-receipt_result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD validate_prod_receipts.
    TYPES ty_order_number TYPE zif_prod_order_api=>ty_order_number.
    DATA lt_order_numbers TYPE HASHED TABLE OF ty_order_number
      WITH UNIQUE KEY table_line.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL
          OR ls_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-production_order INTO TABLE lt_order_numbers.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_request-items INTO DATA(ls_line).
        IF ls_line-quantity <= 0
            OR ls_line-entry_unit IS INITIAL
            OR ls_line-entry_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_unplanned_prod_issues.
    TYPES ty_order_number TYPE zif_prod_order_api=>ty_order_number.
    DATA lt_order_numbers TYPE HASHED TABLE OF ty_order_number
      WITH UNIQUE KEY table_line.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL
          OR ls_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-production_order INTO TABLE lt_order_numbers.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_request-items INTO DATA(ls_line).
        IF ls_line-material IS INITIAL
            OR ls_line-plant IS INITIAL
            OR ls_line-storage_location IS INITIAL
            OR ls_line-quantity <= 0
            OR ls_line-entry_unit IS INITIAL
            OR ls_line-entry_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_prod_receipt_items.
    LOOP AT is_request-items INTO DATA(ls_line).
      APPEND VALUE #(
        material           = ls_line-material
        plant              = ls_line-plant
        storage_location   = ls_line-storage_location
        movement_type      = '101'
        quantity           = ls_line-quantity
        entry_unit         = ls_line-entry_unit
        entry_unit_iso     = ls_line-entry_unit_iso
        movement_indicator = 'F'
        batch              = ls_line-batch
        order_id           = is_request-production_order )
        TO rt_items.
    ENDLOOP.
  ENDMETHOD.

  METHOD issue_stock_transport_order.
    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.

    IF iv_purchase_order IS INITIAL
        OR it_items IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_defer_commit <> abap_true
          AND iv_defer_commit <> abap_false ).
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
      is_header       = is_header
      iv_gm_code      = '04'
      it_items        = lt_movement_items
      iv_test_run     = iv_test_run
      iv_defer_commit = iv_defer_commit ).
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
    TYPES ty_seen_po TYPE eord-ebeln.
    DATA lt_seen_pos TYPE SORTED TABLE OF ty_seen_po
      WITH UNIQUE KEY table_line.
    DATA lt_prepared_issues TYPE ty_prepared_sto_issues.

    IF is_orders-orders IS INITIAL
        OR is_orders-is_test_run <> abap_false
        OR ( is_orders-is_successful <> abap_true
          AND is_orders-is_successful <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

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

      IF iv_atomic = abap_true.
        INSERT ls_pair_order-result-purchase_order_number INTO TABLE
          lt_seen_pos.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.

      DATA(lt_issue_items) = build_sto_issue_items(
        is_order_result      = ls_pair_order-result
        it_unit_iso_mappings = it_unit_iso_mappings ).
      APPEND VALUE #(
        result_index   = lines( rs_result-orders )
        purchase_order = ls_pair_order-result-purchase_order_number
        items          = lt_issue_items ) TO lt_prepared_issues.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_issues INTO DATA(ls_prepared_issue).
      DATA(ls_issue_result) = issue_stock_transport_order(
        is_header         = is_header
        iv_purchase_order = ls_prepared_issue-purchase_order
        it_items          = ls_prepared_issue-items
        iv_test_run       = iv_test_run
        iv_defer_commit   = iv_atomic ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_pair_result>)
        INDEX ls_prepared_issue-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_pair_result>-goods_issue_result = ls_issue_result.
      <ls_pair_result>-is_issue_attempted = abap_true.
      <ls_pair_result>-is_in_transit = xsdbool(
        ls_issue_result-is_successful = abap_true
        AND iv_atomic = abap_false
        AND iv_test_run = abap_false ).
      IF ls_issue_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_atomic = abap_true.
          LOOP AT rs_result-orders ASSIGNING <ls_pair_result>.
            <ls_pair_result>-goods_issue_result-is_successful =
              abap_false.
            CLEAR: <ls_pair_result>-goods_issue_result-material_document,
              <ls_pair_result>-goods_issue_result-fiscal_year.
            <ls_pair_result>-is_in_transit = abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful = abap_true
        AND iv_test_run = abap_false.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_pair_result>.
          <ls_pair_result>-is_in_transit = abap_true.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_pair_result>.
          <ls_pair_result>-goods_issue_result-is_successful = abap_false.
          CLEAR: <ls_pair_result>-goods_issue_result-material_document,
            <ls_pair_result>-goods_issue_result-fiscal_year.
          <ls_pair_result>-is_in_transit = abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_pair_result>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0 AND ls_commit_result-message IS NOT INITIAL.
          APPEND ls_commit_result-message
            TO <ls_pair_result>-goods_issue_result-messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
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
    TYPES ty_seen_po TYPE eord-ebeln.
    DATA lt_seen_pos TYPE SORTED TABLE OF ty_seen_po
      WITH UNIQUE KEY table_line.
    DATA lt_prepared_receipts TYPE ty_prepared_sto_receipts.

    IF is_issues-orders IS INITIAL
        OR is_issues-is_test_run <> abap_false
        OR ( is_issues-is_successful <> abap_true
          AND is_issues-is_successful <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_header_dates( is_header = is_header ).

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

      IF iv_atomic = abap_true.
        INSERT ls_issue_pair-order_result-purchase_order_number INTO TABLE
          lt_seen_pos.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.

      DATA(lt_receipt_items) = build_sto_receipt_items(
        is_order_result      = ls_issue_pair-order_result
        it_unit_iso_mappings = it_unit_iso_mappings ).
      APPEND VALUE #(
        result_index   = lines( rs_result-orders )
        purchase_order = ls_issue_pair-order_result-purchase_order_number
        items          = lt_receipt_items ) TO lt_prepared_receipts.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_receipts INTO DATA(ls_prepared_receipt).
      DATA(ls_receipt_result) = receive_stock_transport_order(
        is_header         = is_header
        iv_purchase_order = ls_prepared_receipt-purchase_order
        it_items          = ls_prepared_receipt-items
        iv_test_run       = iv_test_run
        iv_defer_commit   = iv_atomic ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_receipt_pair>)
        INDEX ls_prepared_receipt-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_receipt_pair>-goods_receipt_result = ls_receipt_result.
      <ls_receipt_pair>-is_receipt_attempted = abap_true.
      <ls_receipt_pair>-is_received = xsdbool(
        ls_receipt_result-is_successful = abap_true
        AND iv_atomic = abap_false
        AND iv_test_run = abap_false ).
      IF <ls_receipt_pair>-is_received = abap_true.
        <ls_receipt_pair>-is_in_transit = abap_false.
      ELSEIF ls_receipt_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
      ENDIF.
      IF iv_atomic = abap_true
          AND ls_receipt_result-is_successful <> abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_receipt_pair>.
          <ls_receipt_pair>-goods_receipt_result-is_successful =
            abap_false.
          CLEAR: <ls_receipt_pair>-goods_receipt_result-material_document,
            <ls_receipt_pair>-goods_receipt_result-fiscal_year.
          <ls_receipt_pair>-is_received = abap_false.
        ENDLOOP.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful = abap_true
        AND iv_test_run = abap_false.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_receipt_pair>.
          <ls_receipt_pair>-is_received = abap_true.
          <ls_receipt_pair>-is_in_transit = abap_false.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_receipt_pair>.
          <ls_receipt_pair>-goods_receipt_result-is_successful =
            abap_false.
          CLEAR: <ls_receipt_pair>-goods_receipt_result-material_document,
            <ls_receipt_pair>-goods_receipt_result-fiscal_year.
          <ls_receipt_pair>-is_received = abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_receipt_pair>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0 AND ls_commit_result-message IS NOT INITIAL.
          APPEND ls_commit_result-message
            TO <ls_receipt_pair>-goods_receipt_result-messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
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
          AND is_issues-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
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

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_cancels INTO DATA(ls_prepared_cancel).
      DATA(ls_reversal_result) = cancel(
        iv_material_document = ls_prepared_cancel-material_document
        iv_fiscal_year       = ls_prepared_cancel-fiscal_year
        iv_posting_date      = iv_posting_date
        iv_defer_commit      = iv_atomic ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_cancel_pair>)
        INDEX ls_prepared_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_cancel_pair>-reversal_result = ls_reversal_result.
      <ls_cancel_pair>-is_cancel_attempted = abap_true.
      <ls_cancel_pair>-is_cancelled = xsdbool(
        ls_reversal_result-is_successful = abap_true
        AND iv_atomic = abap_false ).
      IF <ls_cancel_pair>-is_cancelled = abap_true.
        <ls_cancel_pair>-is_in_transit = abap_false.
      ELSE.
        IF ls_reversal_result-is_successful <> abap_true.
          rs_result-is_successful = abap_false.
        ENDIF.
        IF iv_atomic = abap_true
            AND ls_reversal_result-is_successful <> abap_true.
          LOOP AT rs_result-orders ASSIGNING <ls_cancel_pair>.
            <ls_cancel_pair>-reversal_result-is_successful = abap_false.
            CLEAR: <ls_cancel_pair>-reversal_result-material_document,
              <ls_cancel_pair>-reversal_result-fiscal_year.
            <ls_cancel_pair>-is_cancelled = abap_false.
            <ls_cancel_pair>-is_in_transit = abap_true.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful = abap_true.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_cancel_pair>.
          <ls_cancel_pair>-is_cancelled = abap_true.
          <ls_cancel_pair>-is_in_transit = abap_false.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_cancel_pair>.
          <ls_cancel_pair>-reversal_result-is_successful = abap_false.
          CLEAR: <ls_cancel_pair>-reversal_result-material_document,
            <ls_cancel_pair>-reversal_result-fiscal_year.
          <ls_cancel_pair>-is_cancelled = abap_false.
          <ls_cancel_pair>-is_in_transit = abap_true.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_cancel_pair>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0 AND ls_commit_result-message IS NOT INITIAL.
          APPEND ls_commit_result-message
            TO <ls_cancel_pair>-reversal_result-messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
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
          AND is_receipts-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
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

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_cancels INTO DATA(ls_prepared_cancel).
      DATA(ls_reversal_result) = cancel(
        iv_material_document = ls_prepared_cancel-material_document
        iv_fiscal_year       = ls_prepared_cancel-fiscal_year
        iv_posting_date      = iv_posting_date
        iv_defer_commit      = iv_atomic ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_cancel_pair>)
        INDEX ls_prepared_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_cancel_pair>-reversal_result = ls_reversal_result.
      <ls_cancel_pair>-is_cancel_attempted = abap_true.
      <ls_cancel_pair>-is_cancelled = xsdbool(
        ls_reversal_result-is_successful = abap_true
        AND iv_atomic = abap_false ).
      IF <ls_cancel_pair>-is_cancelled = abap_true.
        <ls_cancel_pair>-is_received = abap_false.
        <ls_cancel_pair>-is_in_transit = abap_true.
      ELSE.
        IF ls_reversal_result-is_successful <> abap_true.
          rs_result-is_successful = abap_false.
        ENDIF.
        IF iv_atomic = abap_true
            AND ls_reversal_result-is_successful <> abap_true.
          LOOP AT rs_result-orders ASSIGNING <ls_cancel_pair>.
            <ls_cancel_pair>-reversal_result-is_successful = abap_false.
            CLEAR: <ls_cancel_pair>-reversal_result-material_document,
              <ls_cancel_pair>-reversal_result-fiscal_year.
            <ls_cancel_pair>-is_cancelled = abap_false.
            <ls_cancel_pair>-is_received = abap_true.
            <ls_cancel_pair>-is_in_transit = abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful = abap_true.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_cancel_pair>.
          <ls_cancel_pair>-is_cancelled = abap_true.
          <ls_cancel_pair>-is_received = abap_false.
          <ls_cancel_pair>-is_in_transit = abap_true.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_cancel_pair>.
          <ls_cancel_pair>-reversal_result-is_successful = abap_false.
          CLEAR: <ls_cancel_pair>-reversal_result-material_document,
            <ls_cancel_pair>-reversal_result-fiscal_year.
          <ls_cancel_pair>-is_cancelled = abap_false.
          <ls_cancel_pair>-is_received = abap_true.
          <ls_cancel_pair>-is_in_transit = abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_cancel_pair>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0 AND ls_commit_result-message IS NOT INITIAL.
          APPEND ls_commit_result-message
            TO <ls_cancel_pair>-reversal_result-messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD cancel_sto_receipt_chain.
    DATA(ls_receipts) = VALUE ty_sto_receipt_pairs_result(
      is_successful = abap_true
      is_test_run   = abap_false
      orders        = VALUE #( ( is_receipt ) ) ).

    rs_result = cancel_sto_receipt_chain_pairs(
      is_receipts     = ls_receipts
      iv_posting_date = iv_posting_date
      iv_atomic       = iv_atomic ).
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
          AND is_receipts-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
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

    IF iv_atomic = abap_true.
      rs_result-is_successful = is_receipts-is_successful.
      LOOP AT is_receipts-orders INTO ls_receipt_pair.
        APPEND CORRESPONDING #( ls_receipt_pair )
          TO rs_result-orders.
        IF ls_receipt_pair-is_received <> abap_true.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDLOOP.

      IF rs_result-is_successful <> abap_true.
        RETURN.
      ENDIF.

      LOOP AT is_receipts-orders INTO ls_receipt_pair.
        DATA(lv_atomic_result_index) = sy-tabix.
        DATA(ls_atomic_receipt_reversal) = cancel(
          iv_material_document =
            ls_receipt_pair-goods_receipt_result-material_document
          iv_fiscal_year       =
            ls_receipt_pair-goods_receipt_result-fiscal_year
          iv_posting_date      = iv_posting_date
          iv_defer_commit      = abap_true ).
        READ TABLE rs_result-orders
          ASSIGNING FIELD-SYMBOL(<ls_atomic_chain_pair>)
          INDEX lv_atomic_result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        <ls_atomic_chain_pair>-reversal_result =
          ls_atomic_receipt_reversal.
        <ls_atomic_chain_pair>-is_cancel_attempted = abap_true.
        IF ls_atomic_receipt_reversal-is_successful <> abap_true.
          rs_result-is_successful = abap_false.
        ELSE.
          DATA(ls_atomic_issue_reversal) = cancel(
            iv_material_document =
              ls_receipt_pair-goods_issue_result-material_document
            iv_fiscal_year       =
              ls_receipt_pair-goods_issue_result-fiscal_year
            iv_posting_date      = iv_posting_date
            iv_defer_commit      = abap_true ).
          <ls_atomic_chain_pair>-goods_issue_reversal_result =
            ls_atomic_issue_reversal.
          <ls_atomic_chain_pair>-is_issue_cancel_attempted = abap_true.
          IF ls_atomic_issue_reversal-is_successful <> abap_true.
            rs_result-is_successful = abap_false.
          ENDIF.
        ENDIF.

        IF rs_result-is_successful <> abap_true.
          LOOP AT rs_result-orders
            ASSIGNING <ls_atomic_chain_pair>.
            <ls_atomic_chain_pair>-reversal_result-is_successful =
              abap_false.
            <ls_atomic_chain_pair>-goods_issue_reversal_result-is_successful =
              abap_false.
            CLEAR:
              <ls_atomic_chain_pair>-reversal_result-material_document,
              <ls_atomic_chain_pair>-reversal_result-fiscal_year,
              <ls_atomic_chain_pair>-goods_issue_reversal_result-material_document,
              <ls_atomic_chain_pair>-goods_issue_reversal_result-fiscal_year.
            <ls_atomic_chain_pair>-is_cancelled = abap_false.
            <ls_atomic_chain_pair>-is_issue_cancelled = abap_false.
            <ls_atomic_chain_pair>-is_fully_cancelled = abap_false.
            <ls_atomic_chain_pair>-is_received = abap_true.
            <ls_atomic_chain_pair>-is_in_transit = abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF rs_result-is_successful = abap_true.
        DATA(ls_chain_commit) = mo_api->commit( ).
        IF ls_chain_commit-is_successful = abap_true.
          LOOP AT rs_result-orders
            ASSIGNING <ls_atomic_chain_pair>.
            <ls_atomic_chain_pair>-is_cancelled = abap_true.
            <ls_atomic_chain_pair>-is_issue_cancelled = abap_true.
            <ls_atomic_chain_pair>-is_fully_cancelled = abap_true.
            <ls_atomic_chain_pair>-is_received = abap_false.
            <ls_atomic_chain_pair>-is_in_transit = abap_false.
          ENDLOOP.
        ELSE.
          mo_api->rollback( ).
          LOOP AT rs_result-orders
            ASSIGNING <ls_atomic_chain_pair>.
            <ls_atomic_chain_pair>-reversal_result-is_successful =
              abap_false.
            <ls_atomic_chain_pair>-goods_issue_reversal_result-is_successful =
              abap_false.
            CLEAR:
              <ls_atomic_chain_pair>-reversal_result-material_document,
              <ls_atomic_chain_pair>-reversal_result-fiscal_year,
              <ls_atomic_chain_pair>-goods_issue_reversal_result-material_document,
              <ls_atomic_chain_pair>-goods_issue_reversal_result-fiscal_year.
            <ls_atomic_chain_pair>-is_cancelled = abap_false.
            <ls_atomic_chain_pair>-is_issue_cancelled = abap_false.
            <ls_atomic_chain_pair>-is_fully_cancelled = abap_false.
            <ls_atomic_chain_pair>-is_received = abap_true.
            <ls_atomic_chain_pair>-is_in_transit = abap_false.
          ENDLOOP.
          READ TABLE rs_result-orders
            ASSIGNING <ls_atomic_chain_pair>
            INDEX lines( rs_result-orders ).
          IF sy-subrc = 0 AND ls_chain_commit-message IS NOT INITIAL.
            APPEND ls_chain_commit-message
              TO <ls_atomic_chain_pair>-goods_issue_reversal_result-messages.
          ENDIF.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDIF.
      RETURN.
    ENDIF.

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

  METHOD retry_sto_chain_issue.
    DATA(ls_input) = VALUE ty_sto_receipt_cancel_pairs_result(
      is_successful = abap_true
      orders        = VALUE #( ( is_pair ) ) ).

    rs_result = retry_sto_chain_issue_pairs(
      is_result       = ls_input
      iv_posting_date = iv_posting_date
      iv_atomic       = iv_atomic ).
  ENDMETHOD.

  METHOD retry_sto_chain_issue_pairs.
    TYPES:
      BEGIN OF ty_cancel_key,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_cancel_key.
    DATA lt_cancel_keys TYPE HASHED TABLE OF ty_cancel_key
      WITH UNIQUE KEY material_document fiscal_year.
    DATA lt_prepared_cancels TYPE ty_prepared_sto_cancels.

    IF is_result-orders IS INITIAL
        OR ( is_result-is_successful <> abap_true
          AND is_result-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = abap_true.
    LOOP AT is_result-orders INTO DATA(ls_pair).
      IF ( ls_pair-is_cancel_attempted <> abap_true
          AND ls_pair-is_cancel_attempted <> abap_false )
          OR ( ls_pair-is_issue_cancel_attempted <> abap_true
            AND ls_pair-is_issue_cancel_attempted <> abap_false )
          OR ( ls_pair-is_issue_cancelled <> abap_true
            AND ls_pair-is_issue_cancelled <> abap_false )
          OR ( ls_pair-is_in_transit <> abap_true
            AND ls_pair-is_in_transit <> abap_false )
          OR ( ls_pair-is_received <> abap_true
            AND ls_pair-is_received <> abap_false )
          OR ( ls_pair-is_cancelled <> abap_true
            AND ls_pair-is_cancelled <> abap_false )
          OR ( ls_pair-is_fully_cancelled <> abap_true
            AND ls_pair-is_fully_cancelled <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND CORRESPONDING #( ls_pair ) TO rs_result-orders.
      IF ls_pair-is_fully_cancelled = abap_true.
        IF ls_pair-is_cancel_attempted <> abap_true
            OR ls_pair-is_issue_cancel_attempted <> abap_true
            OR ls_pair-is_cancelled <> abap_true
            OR ls_pair-is_issue_cancelled <> abap_true
            OR ls_pair-is_received <> abap_false
            OR ls_pair-is_in_transit <> abap_false
            OR ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_receipt_result-is_successful <> abap_true
            OR ls_pair-goods_receipt_result-material_document IS INITIAL
            OR ls_pair-goods_receipt_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL
            OR ls_pair-reversal_result-is_successful <> abap_true
            OR ls_pair-reversal_result-material_document IS INITIAL
            OR ls_pair-reversal_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_reversal_result-is_successful
              <> abap_true
            OR ls_pair-goods_issue_reversal_result-material_document
              IS INITIAL
            OR ls_pair-goods_issue_reversal_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_pair-is_cancelled = abap_true
          AND ls_pair-is_received = abap_false
          AND ls_pair-is_in_transit = abap_true
          AND ls_pair-is_issue_cancelled = abap_false
          AND ls_pair-is_fully_cancelled = abap_false.
        IF ls_pair-is_cancel_attempted <> abap_true
            OR ls_pair-reversal_result-is_successful <> abap_true
            OR ls_pair-reversal_result-material_document IS INITIAL
            OR ls_pair-reversal_result-fiscal_year IS INITIAL
            OR ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_receipt_result-is_successful <> abap_true
            OR ls_pair-goods_receipt_result-material_document IS INITIAL
            OR ls_pair-goods_receipt_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          material_document =
            ls_pair-goods_issue_result-material_document
          fiscal_year       = ls_pair-goods_issue_result-fiscal_year )
          INTO TABLE lt_cancel_keys.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          result_index      = lines( rs_result-orders )
          material_document =
            ls_pair-goods_issue_result-material_document
          fiscal_year       = ls_pair-goods_issue_result-fiscal_year )
          TO lt_prepared_cancels.
      ELSEIF ls_pair-is_cancelled = abap_false
          AND ls_pair-is_received = abap_true
          AND ls_pair-is_in_transit = abap_false
          AND ls_pair-is_issue_cancelled = abap_false.
        rs_result-is_successful = abap_false.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_cancels INTO DATA(ls_prepared_cancel).
      DATA(ls_issue_reversal) = cancel(
        iv_material_document = ls_prepared_cancel-material_document
        iv_fiscal_year       = ls_prepared_cancel-fiscal_year
        iv_posting_date      = iv_posting_date
        iv_defer_commit      = iv_atomic ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_retry_pair>)
        INDEX ls_prepared_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_retry_pair>-goods_issue_reversal_result = ls_issue_reversal.
      <ls_retry_pair>-is_issue_cancel_attempted = abap_true.
      IF ls_issue_reversal-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_atomic = abap_true.
          LOOP AT lt_prepared_cancels INTO DATA(ls_failed_group_item).
            READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
              INDEX ls_failed_group_item-result_index.
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
            ENDIF.
            <ls_retry_pair>-goods_issue_reversal_result-is_successful =
              abap_false.
            CLEAR:
              <ls_retry_pair>-goods_issue_reversal_result-material_document,
              <ls_retry_pair>-goods_issue_reversal_result-fiscal_year.
            <ls_retry_pair>-is_issue_cancelled = abap_false.
            <ls_retry_pair>-is_fully_cancelled = abap_false.
            <ls_retry_pair>-is_in_transit = abap_true.
          ENDLOOP.
          RETURN.
        ENDIF.
      ELSEIF iv_atomic = abap_false.
        <ls_retry_pair>-is_issue_cancelled = abap_true.
        <ls_retry_pair>-is_fully_cancelled = abap_true.
        <ls_retry_pair>-is_in_transit = abap_false.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true AND lt_prepared_cancels IS NOT INITIAL.
      DATA(ls_retry_commit) = mo_api->commit( ).
      IF ls_retry_commit-is_successful = abap_true.
        LOOP AT lt_prepared_cancels INTO ls_prepared_cancel.
          READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
            INDEX ls_prepared_cancel-result_index.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          <ls_retry_pair>-is_issue_cancelled = abap_true.
          <ls_retry_pair>-is_fully_cancelled = abap_true.
          <ls_retry_pair>-is_in_transit = abap_false.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT lt_prepared_cancels INTO ls_prepared_cancel.
          READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
            INDEX ls_prepared_cancel-result_index.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          <ls_retry_pair>-goods_issue_reversal_result-is_successful =
            abap_false.
          CLEAR:
            <ls_retry_pair>-goods_issue_reversal_result-material_document,
            <ls_retry_pair>-goods_issue_reversal_result-fiscal_year.
          <ls_retry_pair>-is_issue_cancelled = abap_false.
          <ls_retry_pair>-is_fully_cancelled = abap_false.
          <ls_retry_pair>-is_in_transit = abap_true.
        ENDLOOP.
        READ TABLE lt_prepared_cancels INTO ls_prepared_cancel
          INDEX lines( lt_prepared_cancels ).
        IF sy-subrc = 0 AND ls_retry_commit-message IS NOT INITIAL.
          READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
            INDEX ls_prepared_cancel-result_index.
          IF sy-subrc = 0.
            APPEND ls_retry_commit-message
              TO <ls_retry_pair>-goods_issue_reversal_result-messages.
          ENDIF.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD retry_sto_chain_receipt.
    DATA(ls_input) = VALUE ty_sto_receipt_cancel_pairs_result(
      is_successful = abap_true
      orders        = VALUE #( ( is_pair ) ) ).

    rs_result = retry_sto_chain_receipt_pairs(
      is_result       = ls_input
      iv_posting_date = iv_posting_date
      iv_atomic       = iv_atomic ).
  ENDMETHOD.

  METHOD retry_sto_chain_receipt_pairs.
    TYPES:
      BEGIN OF ty_retry_index,
        result_index TYPE i,
        retry_index  TYPE i,
      END OF ty_retry_index.
    DATA lt_retry_indices TYPE STANDARD TABLE OF ty_retry_index
      WITH EMPTY KEY.
    DATA ls_receipt_retries TYPE ty_sto_receipt_pairs_result.
    DATA ls_retry_result TYPE ty_sto_receipt_cancel_pairs_result.

    IF is_result-orders IS INITIAL
        OR ( is_result-is_successful <> abap_true
          AND is_result-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    ls_receipt_retries-is_successful = abap_true.
    ls_receipt_retries-is_test_run = abap_false.
    LOOP AT is_result-orders INTO DATA(ls_pair).
      IF ( ls_pair-is_cancel_attempted <> abap_true
          AND ls_pair-is_cancel_attempted <> abap_false )
          OR ( ls_pair-is_issue_cancel_attempted <> abap_true
            AND ls_pair-is_issue_cancel_attempted <> abap_false )
          OR ( ls_pair-is_issue_cancelled <> abap_true
            AND ls_pair-is_issue_cancelled <> abap_false )
          OR ( ls_pair-is_in_transit <> abap_true
            AND ls_pair-is_in_transit <> abap_false )
          OR ( ls_pair-is_received <> abap_true
            AND ls_pair-is_received <> abap_false )
          OR ( ls_pair-is_cancelled <> abap_true
            AND ls_pair-is_cancelled <> abap_false )
          OR ( ls_pair-is_fully_cancelled <> abap_true
            AND ls_pair-is_fully_cancelled <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND CORRESPONDING #( ls_pair ) TO rs_result-orders.
      IF ls_pair-is_fully_cancelled = abap_true.
        IF ls_pair-is_cancel_attempted <> abap_true
            OR ls_pair-is_issue_cancel_attempted <> abap_true
            OR ls_pair-is_cancelled <> abap_true
            OR ls_pair-is_issue_cancelled <> abap_true
            OR ls_pair-is_received <> abap_false
            OR ls_pair-is_in_transit <> abap_false
            OR ls_pair-reversal_result-is_successful <> abap_true
            OR ls_pair-reversal_result-material_document IS INITIAL
            OR ls_pair-reversal_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_reversal_result-is_successful
              <> abap_true
            OR ls_pair-goods_issue_reversal_result-material_document
              IS INITIAL
            OR ls_pair-goods_issue_reversal_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_pair-is_received = abap_true
          AND ls_pair-is_cancelled = abap_false
          AND ls_pair-is_in_transit = abap_false
          AND ls_pair-is_issue_cancelled = abap_false
          AND ls_pair-is_fully_cancelled = abap_false.
        IF ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL
            OR ls_pair-goods_receipt_result-is_successful <> abap_true
            OR ls_pair-goods_receipt_result-material_document IS INITIAL
            OR ls_pair-goods_receipt_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          supplying_plant      = ls_pair-supplying_plant
          receiving_plant      = ls_pair-receiving_plant
          order_result         = ls_pair-order_result
          goods_issue_result   = ls_pair-goods_issue_result
          goods_receipt_result = ls_pair-goods_receipt_result
          is_receipt_attempted = abap_true
          is_in_transit        = abap_false
          is_received          = abap_true )
          TO ls_receipt_retries-orders.
        APPEND VALUE #(
          result_index = lines( rs_result-orders )
          retry_index  = lines( ls_receipt_retries-orders ) )
          TO lt_retry_indices.
      ELSEIF ls_pair-is_cancelled = abap_true
          AND ls_pair-is_received = abap_false
          AND ls_pair-is_in_transit = abap_true
          AND ls_pair-is_issue_cancelled = abap_false
          AND ls_pair-is_fully_cancelled = abap_false.
        IF ls_pair-is_cancel_attempted <> abap_true
            OR ls_pair-reversal_result-is_successful <> abap_true
            OR ls_pair-reversal_result-material_document IS INITIAL
            OR ls_pair-reversal_result-fiscal_year IS INITIAL
            OR ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF ls_receipt_retries-orders IS NOT INITIAL.
      ls_retry_result = cancel_received_sto_pairs(
        is_receipts     = ls_receipt_retries
        iv_posting_date = iv_posting_date
        iv_atomic       = iv_atomic ).
      LOOP AT lt_retry_indices INTO DATA(ls_retry_index).
        READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_retry_pair>)
          INDEX ls_retry_index-result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        READ TABLE ls_retry_result-orders INTO DATA(ls_cancelled_pair)
          INDEX ls_retry_index-retry_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        <ls_retry_pair>-reversal_result = ls_cancelled_pair-reversal_result.
        <ls_retry_pair>-is_cancel_attempted =
          ls_cancelled_pair-is_cancel_attempted.
        <ls_retry_pair>-is_cancelled = ls_cancelled_pair-is_cancelled.
        <ls_retry_pair>-is_received = ls_cancelled_pair-is_received.
        <ls_retry_pair>-is_in_transit = ls_cancelled_pair-is_in_transit.
      ENDLOOP.
    ENDIF.

    rs_result-is_successful = abap_true.
    LOOP AT rs_result-orders INTO DATA(ls_result_pair).
      IF ls_result_pair-is_fully_cancelled <> abap_true.
        rs_result-is_successful = abap_false.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD retry_sto_chain.
    DATA(ls_input) = VALUE ty_sto_receipt_cancel_pairs_result(
      is_successful = abap_true
      orders        = VALUE #( ( is_pair ) ) ).

    rs_result = retry_sto_chain_pairs(
      is_result       = ls_input
      iv_posting_date = iv_posting_date
      iv_atomic       = iv_atomic ).
  ENDMETHOD.

  METHOD retry_sto_chain_pairs.
    TYPES:
      BEGIN OF ty_cancel_key,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_cancel_key,
      BEGIN OF ty_pending_cancel,
        result_index      TYPE i,
        stage             TYPE c LENGTH 1,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_pending_cancel.
    DATA lt_cancel_keys TYPE HASHED TABLE OF ty_cancel_key
      WITH UNIQUE KEY material_document fiscal_year.
    DATA lt_pending_cancels TYPE STANDARD TABLE OF ty_pending_cancel
      WITH EMPTY KEY.
    DATA lt_attempted_cancels TYPE STANDARD TABLE OF ty_pending_cancel
      WITH EMPTY KEY.

    IF is_result-orders IS INITIAL
        OR ( is_result-is_successful <> abap_true
          AND is_result-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT is_result-orders INTO DATA(ls_pair).
      DATA(lv_pair_index) = sy-tabix.
      IF ( ls_pair-is_cancel_attempted <> abap_true
          AND ls_pair-is_cancel_attempted <> abap_false )
          OR ( ls_pair-is_issue_cancel_attempted <> abap_true
            AND ls_pair-is_issue_cancel_attempted <> abap_false )
          OR ( ls_pair-is_issue_cancelled <> abap_true
            AND ls_pair-is_issue_cancelled <> abap_false )
          OR ( ls_pair-is_in_transit <> abap_true
            AND ls_pair-is_in_transit <> abap_false )
          OR ( ls_pair-is_received <> abap_true
            AND ls_pair-is_received <> abap_false )
          OR ( ls_pair-is_cancelled <> abap_true
            AND ls_pair-is_cancelled <> abap_false )
          OR ( ls_pair-is_fully_cancelled <> abap_true
            AND ls_pair-is_fully_cancelled <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_pair-is_fully_cancelled = abap_true.
        IF ls_pair-is_cancel_attempted <> abap_true
            OR ls_pair-is_issue_cancel_attempted <> abap_true
            OR ls_pair-is_cancelled <> abap_true
            OR ls_pair-is_issue_cancelled <> abap_true
            OR ls_pair-is_received <> abap_false
            OR ls_pair-is_in_transit <> abap_false
            OR ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_receipt_result-is_successful <> abap_true
            OR ls_pair-goods_receipt_result-material_document IS INITIAL
            OR ls_pair-goods_receipt_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL
            OR ls_pair-reversal_result-is_successful <> abap_true
            OR ls_pair-reversal_result-material_document IS INITIAL
            OR ls_pair-reversal_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_reversal_result-is_successful
              <> abap_true
            OR ls_pair-goods_issue_reversal_result-material_document
              IS INITIAL
            OR ls_pair-goods_issue_reversal_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_pair-is_received = abap_true
          AND ls_pair-is_cancelled = abap_false
          AND ls_pair-is_in_transit = abap_false
          AND ls_pair-is_issue_cancelled = abap_false.
        IF ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_receipt_result-is_successful <> abap_true
            OR ls_pair-goods_receipt_result-material_document IS INITIAL
            OR ls_pair-goods_receipt_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        INSERT VALUE #(
          material_document =
            ls_pair-goods_receipt_result-material_document
          fiscal_year       =
            ls_pair-goods_receipt_result-fiscal_year )
          INTO TABLE lt_cancel_keys.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          result_index      = lv_pair_index
          stage             = 'R'
          material_document =
            ls_pair-goods_receipt_result-material_document
          fiscal_year       =
            ls_pair-goods_receipt_result-fiscal_year )
          TO lt_pending_cancels.

        INSERT VALUE #(
          material_document = ls_pair-goods_issue_result-material_document
          fiscal_year       = ls_pair-goods_issue_result-fiscal_year )
          INTO TABLE lt_cancel_keys.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          result_index      = lv_pair_index
          stage             = 'I'
          material_document = ls_pair-goods_issue_result-material_document
          fiscal_year       = ls_pair-goods_issue_result-fiscal_year )
          TO lt_pending_cancels.
      ELSEIF ls_pair-is_cancelled = abap_true
          AND ls_pair-is_received = abap_false
          AND ls_pair-is_in_transit = abap_true
          AND ls_pair-is_issue_cancelled = abap_false.
        IF ls_pair-is_cancel_attempted <> abap_true
            OR ls_pair-reversal_result-is_successful <> abap_true
            OR ls_pair-reversal_result-material_document IS INITIAL
            OR ls_pair-reversal_result-fiscal_year IS INITIAL
            OR ls_pair-order_result-is_successful <> abap_true
            OR ls_pair-order_result-is_committed <> abap_true
            OR ls_pair-order_result-is_test_run <> abap_false
            OR ls_pair-goods_receipt_result-is_successful <> abap_true
            OR ls_pair-goods_receipt_result-material_document IS INITIAL
            OR ls_pair-goods_receipt_result-fiscal_year IS INITIAL
            OR ls_pair-goods_issue_result-is_successful <> abap_true
            OR ls_pair-goods_issue_result-material_document IS INITIAL
            OR ls_pair-goods_issue_result-fiscal_year IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        INSERT VALUE #(
          material_document = ls_pair-goods_issue_result-material_document
          fiscal_year       = ls_pair-goods_issue_result-fiscal_year )
          INTO TABLE lt_cancel_keys.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          result_index      = lv_pair_index
          stage             = 'I'
          material_document = ls_pair-goods_issue_result-material_document
          fiscal_year       = ls_pair-goods_issue_result-fiscal_year )
          TO lt_pending_cancels.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    rs_result = is_result.
    IF iv_atomic = abap_false.
      LOOP AT lt_pending_cancels INTO DATA(ls_pending_cancel)
          WHERE stage = 'R'.
        READ TABLE rs_result-orders INTO DATA(ls_retry_pair)
          INDEX ls_pending_cancel-result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        DATA(ls_receipt_retry) = retry_sto_chain_receipt(
          is_pair         = ls_retry_pair
          iv_posting_date = iv_posting_date ).
        READ TABLE ls_receipt_retry-orders INTO ls_retry_pair INDEX 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_retry_pair>)
          INDEX ls_pending_cancel-result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        <ls_retry_pair> = ls_retry_pair.
      ENDLOOP.

      LOOP AT lt_pending_cancels INTO ls_pending_cancel
          WHERE stage = 'I'.
        READ TABLE rs_result-orders INTO ls_retry_pair
          INDEX ls_pending_cancel-result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        IF ls_retry_pair-is_received = abap_true
            OR ls_retry_pair-is_in_transit <> abap_true.
          CONTINUE.
        ENDIF.
        DATA(ls_issue_retry) = retry_sto_chain_issue(
          is_pair         = ls_retry_pair
          iv_posting_date = iv_posting_date ).
        READ TABLE ls_issue_retry-orders INTO ls_retry_pair INDEX 1.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
          INDEX ls_pending_cancel-result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        <ls_retry_pair> = ls_retry_pair.
      ENDLOOP.

      rs_result-is_successful = abap_true.
      LOOP AT rs_result-orders INTO ls_retry_pair.
        IF ls_retry_pair-is_fully_cancelled <> abap_true.
          rs_result-is_successful = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA lv_failed TYPE abap_bool VALUE abap_false.
    LOOP AT lt_pending_cancels INTO ls_pending_cancel.
      DATA(ls_cancel_result) = cancel(
        iv_material_document = ls_pending_cancel-material_document
        iv_fiscal_year       = ls_pending_cancel-fiscal_year
        iv_posting_date      = iv_posting_date
        iv_defer_commit      = abap_true ).
      APPEND ls_pending_cancel TO lt_attempted_cancels.
      READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
        INDEX ls_pending_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_pending_cancel-stage = 'R'.
        <ls_retry_pair>-reversal_result = ls_cancel_result.
        <ls_retry_pair>-is_cancel_attempted = abap_true.
      ELSE.
        <ls_retry_pair>-goods_issue_reversal_result = ls_cancel_result.
        <ls_retry_pair>-is_issue_cancel_attempted = abap_true.
      ENDIF.
      IF ls_cancel_result-is_successful <> abap_true.
        lv_failed = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_failed = abap_true.
      LOOP AT lt_attempted_cancels INTO DATA(ls_attempted_cancel).
        READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
          INDEX ls_attempted_cancel-result_index.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        IF ls_attempted_cancel-stage = 'R'.
          <ls_retry_pair>-reversal_result-is_successful = abap_false.
          CLEAR:
            <ls_retry_pair>-reversal_result-material_document,
            <ls_retry_pair>-reversal_result-fiscal_year.
        ELSE.
          <ls_retry_pair>-goods_issue_reversal_result-is_successful =
            abap_false.
          CLEAR:
            <ls_retry_pair>-goods_issue_reversal_result-material_document,
            <ls_retry_pair>-goods_issue_reversal_result-fiscal_year.
        ENDIF.
      ENDLOOP.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF lt_pending_cancels IS NOT INITIAL.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful <> abap_true.
        mo_api->rollback( ).
        LOOP AT lt_attempted_cancels INTO ls_attempted_cancel.
          READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
            INDEX ls_attempted_cancel-result_index.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
          ENDIF.
          IF ls_attempted_cancel-stage = 'R'.
            <ls_retry_pair>-reversal_result-is_successful = abap_false.
            CLEAR:
              <ls_retry_pair>-reversal_result-material_document,
              <ls_retry_pair>-reversal_result-fiscal_year.
          ELSE.
            <ls_retry_pair>-goods_issue_reversal_result-is_successful =
              abap_false.
            CLEAR:
              <ls_retry_pair>-goods_issue_reversal_result-material_document,
              <ls_retry_pair>-goods_issue_reversal_result-fiscal_year.
          ENDIF.
        ENDLOOP.
        READ TABLE lt_attempted_cancels INTO ls_attempted_cancel
          INDEX lines( lt_attempted_cancels ).
        IF sy-subrc = 0 AND ls_commit_result-message IS NOT INITIAL.
          READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
            INDEX ls_attempted_cancel-result_index.
          IF sy-subrc = 0.
            IF ls_attempted_cancel-stage = 'R'.
              APPEND ls_commit_result-message
                TO <ls_retry_pair>-reversal_result-messages.
            ELSE.
              APPEND ls_commit_result-message
                TO <ls_retry_pair>-goods_issue_reversal_result-messages.
            ENDIF.
          ENDIF.
        ENDIF.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT lt_pending_cancels INTO ls_pending_cancel.
      READ TABLE rs_result-orders ASSIGNING <ls_retry_pair>
        INDEX ls_pending_cancel-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_pending_cancel-stage = 'R'.
        <ls_retry_pair>-is_cancelled = abap_true.
        <ls_retry_pair>-is_received = abap_false.
        <ls_retry_pair>-is_in_transit = abap_true.
      ELSE.
        <ls_retry_pair>-is_issue_cancelled = abap_true.
        <ls_retry_pair>-is_in_transit = abap_false.
        <ls_retry_pair>-is_fully_cancelled = abap_true.
      ENDIF.
    ENDLOOP.
    rs_result-is_successful = abap_true.
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
          AND iv_test_run <> abap_false )
        OR ( iv_defer_commit <> abap_true
          AND iv_defer_commit <> abap_false ).
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
      is_header       = is_header
      iv_gm_code      = '01'
      it_items        = lt_movement_items
      iv_test_run     = iv_test_run
      iv_defer_commit = iv_defer_commit ).
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
    validate_fefo_date_metadata( is_allocation = is_allocation ).
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

  METHOD transfer_plant_date_loc_uom.
    DATA(ls_unit_allocation) = to_plant_location_uom(
      is_allocation = is_allocation ).

    rs_result = transfer_plant_units_alloc(
      is_header                  = is_header
      is_allocation              = ls_unit_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_date_loc_uom_2step.
    DATA(ls_unit_allocation) = to_plant_location_uom(
      is_allocation = is_allocation ).

    rs_result = transfer_plant_2step_units(
      is_header                  = is_header
      is_allocation              = ls_unit_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_date_loc_atp.
    validate_date_loc_atp( is_allocation = is_allocation ).

    rs_result = transfer_plant_date_loc_uom(
      is_header                  = is_header
      is_allocation              = is_allocation-local_estimate
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_date_loc_atp_2step.
    validate_date_loc_atp( is_allocation = is_allocation ).

    rs_result = transfer_date_loc_uom_2step(
      is_header                  = is_header
      is_allocation              = is_allocation-local_estimate
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_fefo_date_atp.
    validate_fefo_date_atp( is_allocation = is_allocation ).

    rs_result = transfer_fefo_date_uom(
      is_header                  = is_header
      is_allocation              = is_allocation-local_estimate
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_fefo_date_atp_2step.
    validate_fefo_date_atp( is_allocation = is_allocation ).

    rs_result = transfer_fefo_date_uom_2step(
      is_header                  = is_header
      is_allocation              = is_allocation-local_estimate
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

  METHOD validate_date_loc_atp.
    TYPES:
      BEGIN OF ty_source_location_total,
        request_id        TYPE c LENGTH 30,
        material          TYPE mard-matnr,
        target_plant      TYPE mard-werks,
        source_plant      TYPE mard-werks,
        required_date     TYPE resb-bdter,
        priority          TYPE i,
        base_unit         TYPE mara-meins,
        plant_quantity    TYPE mard-labst,
        location_quantity TYPE mard-labst,
      END OF ty_source_location_total.
    TYPES ty_source_location_totals TYPE SORTED TABLE OF
      ty_source_location_total WITH UNIQUE KEY request_id source_plant.
    DATA lv_match_count TYPE i.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_plant_date_atp_check.
    DATA lt_source_totals TYPE ty_source_location_totals.
    FIELD-SYMBOLS <ls_source_total> TYPE ty_source_location_total.

    IF is_allocation-atp_checks IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity < 0
          OR ls_source_allocation-allocation-available_quantity <
            ls_source_allocation-allocation-allocated_quantity
          OR ls_source_allocation-allocation-request_id IS INITIAL
          OR ls_source_allocation-allocation-material IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-target_plant =
            ls_source_allocation-allocation-source_plant.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_source_allocation-allocation-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_source_allocation-base_unit IS INITIAL
          OR ls_source_allocation-allocation-required_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        request_id        = ls_source_allocation-allocation-request_id
        material          = ls_source_allocation-allocation-material
        target_plant      = ls_source_allocation-allocation-target_plant
        source_plant      = ls_source_allocation-allocation-source_plant
        required_date     = ls_source_allocation-allocation-required_date
        priority          = ls_source_allocation-allocation-priority
        base_unit         = ls_source_allocation-base_unit
        plant_quantity    =
          ls_source_allocation-allocation-allocated_quantity
        location_quantity = 0 ) INTO TABLE lt_source_totals.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      CLEAR: lv_match_count, ls_atp_check.
      LOOP AT is_allocation-atp_checks INTO DATA(ls_candidate_check).
        IF ls_candidate_check-request_id =
              ls_source_allocation-allocation-request_id
            AND ls_candidate_check-material =
              ls_source_allocation-allocation-material
            AND ls_candidate_check-target_plant =
              ls_source_allocation-allocation-target_plant
            AND ls_candidate_check-source_plant =
              ls_source_allocation-allocation-source_plant
            AND ls_candidate_check-required_date =
              ls_source_allocation-allocation-required_date.
          ADD 1 TO lv_match_count.
          ls_atp_check = ls_candidate_check.
        ENDIF.
      ENDLOOP.

      IF lv_match_count <> 1
          OR ls_atp_check-base_unit <> ls_source_allocation-base_unit
          OR ls_atp_check-allocated_base_quantity <>
            ls_source_allocation-allocation-allocated_quantity
          OR ls_atp_check-cumulative_base_quantity <
            ls_atp_check-allocated_base_quantity
          OR ls_atp_check-atp_result-material <>
            ls_atp_check-material
          OR ls_atp_check-atp_result-plant <>
            ls_atp_check-source_plant
          OR ls_atp_check-atp_result-unit <> ls_atp_check-base_unit
          OR ls_atp_check-atp_result-required_date <>
            ls_atp_check-required_date
          OR ls_atp_check-atp_result-requested_quantity <>
            ls_atp_check-cumulative_base_quantity
          OR ls_atp_check-atp_result-check_rule IS INITIAL
          OR ls_atp_check-atp_result-is_check_relevant <> abap_true
          OR ls_atp_check-confirmed_base_quantity <
            ls_atp_check-cumulative_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-local_estimate-location_allocations
        INTO DATA(ls_location_allocation).
      IF ls_location_allocation-allocation-allocation-allocated_quantity < 0
          OR ls_location_allocation-allocation-allocation-available_quantity <
            ls_location_allocation-allocation-allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_location_allocation-allocation-allocation-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_location_allocation-base_unit IS INITIAL
          OR ls_location_allocation-allocation-required_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE lt_source_totals ASSIGNING <ls_source_total>
        WITH TABLE KEY
          request_id =
            ls_location_allocation-allocation-allocation-request_id
          source_plant =
            ls_location_allocation-allocation-allocation-source_plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_source_total>-material <>
            ls_location_allocation-allocation-allocation-material
          OR <ls_source_total>-target_plant <>
            ls_location_allocation-allocation-allocation-target_plant
          OR <ls_source_total>-required_date <>
            ls_location_allocation-allocation-required_date
          OR <ls_source_total>-priority <>
            ls_location_allocation-allocation-priority
          OR <ls_source_total>-base_unit <>
            ls_location_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_source_total>-location_quantity =
        <ls_source_total>-location_quantity
          + ls_location_allocation-allocation-allocation-allocated_quantity.
    ENDLOOP.

    LOOP AT lt_source_totals INTO DATA(ls_source_total).
      IF ls_source_total-location_quantity <> ls_source_total-plant_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_fefo_date_atp.
    TYPES:
      BEGIN OF ty_fefo_demand_total,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        base_unit          TYPE mara-meins,
        allocated_quantity TYPE mard-labst,
        source_quantity    TYPE mard-labst,
      END OF ty_fefo_demand_total.
    TYPES ty_fefo_demand_totals TYPE SORTED TABLE OF
      ty_fefo_demand_total WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_source_fefo_total,
        request_id     TYPE c LENGTH 30,
        material       TYPE mard-matnr,
        target_plant   TYPE mard-werks,
        source_plant   TYPE mard-werks,
        required_date  TYPE resb-bdter,
        priority       TYPE i,
        base_unit      TYPE mara-meins,
        plant_quantity TYPE mard-labst,
        split_quantity TYPE mard-labst,
      END OF ty_source_fefo_total.
    TYPES ty_source_fefo_totals TYPE SORTED TABLE OF
      ty_source_fefo_total WITH UNIQUE KEY
        request_id source_plant required_date.
    DATA lv_match_count TYPE i.
    DATA lv_raw_confirmed_quantity TYPE decfloat34.
    DATA lv_expected_confirmed_quantity TYPE mard-labst.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_plant_date_atp_check.
    DATA lt_demand_totals TYPE ty_fefo_demand_totals.
    DATA lt_source_totals TYPE ty_source_fefo_totals.
    FIELD-SYMBOLS <ls_fefo_demand> TYPE ty_fefo_demand_total.
    FIELD-SYMBOLS <ls_source_total> TYPE ty_source_fefo_total.

    validate_fefo_date_metadata(
      is_allocation = is_allocation-local_estimate ).

    IF is_allocation-atp_checks IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT is_allocation-local_estimate-allocations
        INTO DATA(ls_fefo_demand).
      IF ls_fefo_demand-allocation-request_id IS INITIAL
          OR ls_fefo_demand-allocation-material IS INITIAL
          OR ls_fefo_demand-allocation-target_plant IS INITIAL
          OR ls_fefo_demand-allocation-required_date IS INITIAL
          OR ls_fefo_demand-base_unit IS INITIAL
          OR ls_fefo_demand-allocation-requested_quantity < 0
          OR ls_fefo_demand-allocation-available_quantity < 0
          OR ls_fefo_demand-allocation-allocated_quantity < 0
          OR ls_fefo_demand-allocation-shortfall_quantity < 0
          OR ls_fefo_demand-allocation-allocated_quantity >
            ls_fefo_demand-allocation-requested_quantity
          OR ls_fefo_demand-allocation-allocated_quantity >
            ls_fefo_demand-allocation-available_quantity
          OR ls_fefo_demand-allocation-allocated_quantity
              + ls_fefo_demand-allocation-shortfall_quantity <>
            ls_fefo_demand-allocation-requested_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id         = ls_fefo_demand-allocation-request_id
        material           = ls_fefo_demand-allocation-material
        target_plant       = ls_fefo_demand-allocation-target_plant
        required_date      = ls_fefo_demand-allocation-required_date
        priority           = ls_fefo_demand-allocation-priority
        base_unit          = ls_fefo_demand-base_unit
        allocated_quantity =
          ls_fefo_demand-allocation-allocated_quantity
        source_quantity    = 0 ) INTO TABLE lt_demand_totals.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity < 0
          OR ls_source_allocation-allocation-available_quantity <
            ls_source_allocation-allocation-allocated_quantity
          OR ls_source_allocation-allocation-request_id IS INITIAL
          OR ls_source_allocation-allocation-material IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-target_plant =
            ls_source_allocation-allocation-source_plant.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_source_allocation-allocation-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_source_allocation-base_unit IS INITIAL
          OR ls_source_allocation-allocation-required_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE lt_demand_totals ASSIGNING <ls_fefo_demand>
        WITH TABLE KEY
          request_id = ls_source_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_fefo_demand>-material <>
            ls_source_allocation-allocation-material
          OR <ls_fefo_demand>-target_plant <>
            ls_source_allocation-allocation-target_plant
          OR <ls_fefo_demand>-required_date <>
            ls_source_allocation-allocation-required_date
          OR <ls_fefo_demand>-priority <>
            ls_source_allocation-allocation-priority
          OR ls_fefo_demand-base_unit <>
            ls_source_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_fefo_demand>-source_quantity =
        <ls_fefo_demand>-source_quantity
          + ls_source_allocation-allocation-allocated_quantity.

      INSERT VALUE #(
        request_id     = ls_source_allocation-allocation-request_id
        material       = ls_source_allocation-allocation-material
        target_plant   = ls_source_allocation-allocation-target_plant
        source_plant   = ls_source_allocation-allocation-source_plant
        required_date  = ls_source_allocation-allocation-required_date
        priority       = ls_source_allocation-allocation-priority
        base_unit      = ls_source_allocation-base_unit
        plant_quantity =
          ls_source_allocation-allocation-allocated_quantity
        split_quantity = 0 ) INTO TABLE lt_source_totals.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      CLEAR: lv_match_count, ls_atp_check.
      LOOP AT is_allocation-atp_checks INTO DATA(ls_candidate_check).
        IF ls_candidate_check-request_id =
              ls_source_allocation-allocation-request_id
            AND ls_candidate_check-material =
              ls_source_allocation-allocation-material
            AND ls_candidate_check-target_plant =
              ls_source_allocation-allocation-target_plant
            AND ls_candidate_check-source_plant =
              ls_source_allocation-allocation-source_plant
            AND ls_candidate_check-required_date =
              ls_source_allocation-allocation-required_date.
          ADD 1 TO lv_match_count.
          ls_atp_check = ls_candidate_check.
        ENDIF.
      ENDLOOP.

      IF lv_match_count <> 1
          OR ls_atp_check-base_unit <> ls_source_allocation-base_unit
          OR ls_atp_check-allocated_base_quantity <>
            ls_source_allocation-allocation-allocated_quantity
          OR ls_atp_check-cumulative_base_quantity <
            ls_atp_check-allocated_base_quantity
          OR ls_atp_check-atp_result-material <>
            ls_atp_check-material
          OR ls_atp_check-atp_result-plant <> ls_atp_check-source_plant
          OR ls_atp_check-atp_result-unit <> ls_atp_check-base_unit
          OR ls_atp_check-atp_result-required_date <>
            ls_atp_check-required_date
          OR ls_atp_check-atp_result-requested_quantity <>
            ls_atp_check-cumulative_base_quantity
          OR ls_atp_check-atp_result-check_rule IS INITIAL
          OR ls_atp_check-atp_result-is_check_relevant <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      CLEAR lv_raw_confirmed_quantity.
      IF ls_atp_check-atp_result-is_fully_available = abap_true.
        lv_raw_confirmed_quantity = CONV decfloat34(
          ls_atp_check-cumulative_base_quantity ).
      ELSEIF ls_atp_check-atp_result-confirmation_lines IS NOT INITIAL.
        LOOP AT ls_atp_check-atp_result-confirmation_lines
            INTO DATA(ls_confirmation_line).
          IF ls_confirmation_line-confirmed_quantity <= 0
              OR ls_confirmation_line-confirmed_date IS INITIAL
              OR ls_confirmation_line-confirmed_date >
                ls_atp_check-required_date.
            CONTINUE.
          ENDIF.
          lv_raw_confirmed_quantity = lv_raw_confirmed_quantity
            + CONV decfloat34( ls_confirmation_line-confirmed_quantity ).
          IF lv_raw_confirmed_quantity >=
              CONV decfloat34( ls_atp_check-cumulative_base_quantity ).
            lv_raw_confirmed_quantity = CONV decfloat34(
              ls_atp_check-cumulative_base_quantity ).
            EXIT.
          ENDIF.
        ENDLOOP.
      ELSEIF ls_atp_check-atp_result-confirmed_quantity > 0
          AND ls_atp_check-atp_result-confirmed_date IS NOT INITIAL
          AND ls_atp_check-atp_result-confirmed_date <=
            ls_atp_check-required_date.
        lv_raw_confirmed_quantity = CONV decfloat34(
          ls_atp_check-atp_result-confirmed_quantity ).
        IF lv_raw_confirmed_quantity >
            CONV decfloat34( ls_atp_check-cumulative_base_quantity ).
          lv_raw_confirmed_quantity = CONV decfloat34(
            ls_atp_check-cumulative_base_quantity ).
        ENDIF.
      ENDIF.
      lv_expected_confirmed_quantity = CONV mard-labst(
        lv_raw_confirmed_quantity ).

      IF ls_atp_check-confirmed_base_quantity <>
            lv_expected_confirmed_quantity
          OR ls_atp_check-unconfirmed_base_quantity <>
            ls_atp_check-cumulative_base_quantity
              - lv_expected_confirmed_quantity
          OR ls_atp_check-confirmed_base_quantity <
            ls_atp_check-cumulative_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_totals INTO DATA(ls_fefo_demand_total).
      IF ls_fefo_demand_total-source_quantity <>
          ls_fefo_demand_total-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-atp_checks INTO DATA(ls_atp_check_row).
      READ TABLE lt_source_totals ASSIGNING <ls_source_total>
        WITH TABLE KEY
          request_id = ls_atp_check_row-request_id
          source_plant = ls_atp_check_row-source_plant
          required_date = ls_atp_check_row-required_date.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_source_total>-material <> ls_atp_check_row-material
          OR <ls_source_total>-target_plant <> ls_atp_check_row-target_plant
          OR <ls_source_total>-base_unit <> ls_atp_check_row-base_unit
          OR <ls_source_total>-plant_quantity <>
            ls_atp_check_row-allocated_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-local_estimate-batch_allocations
        INTO DATA(ls_batch_allocation).
      DATA(ls_batch_source) = ls_batch_allocation-allocation-allocation.
      IF ls_batch_source-request_id IS INITIAL
          OR ls_batch_source-material IS INITIAL
          OR ls_batch_source-target_plant IS INITIAL
          OR ls_batch_source-source_plant IS INITIAL
          OR ls_batch_source-target_plant = ls_batch_source-source_plant
          OR ls_batch_source-storage_location IS INITIAL
          OR ls_batch_source-batch IS INITIAL
          OR ls_batch_source-allocated_quantity < 0
          OR ls_batch_source-available_quantity <
            ls_batch_source-allocated_quantity
          OR ls_batch_allocation-allocation-required_date IS INITIAL
          OR ls_batch_allocation-base_unit IS INITIAL
          OR ls_batch_allocation-allocated_source_quantity < 0
          OR ls_batch_allocation-available_source_quantity <
            ls_batch_allocation-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_batch_source-allocated_quantity = 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_source_totals ASSIGNING <ls_source_total>
        WITH TABLE KEY
          request_id = ls_batch_source-request_id
          source_plant = ls_batch_source-source_plant
          required_date = ls_batch_allocation-allocation-required_date.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_source_total>-material <> ls_batch_source-material
          OR <ls_source_total>-target_plant <> ls_batch_source-target_plant
          OR <ls_source_total>-priority <>
            ls_batch_allocation-allocation-priority
          OR <ls_source_total>-base_unit <>
            ls_batch_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_source_total>-split_quantity =
        <ls_source_total>-split_quantity
          + ls_batch_source-allocated_quantity.
    ENDLOOP.

    LOOP AT lt_source_totals INTO DATA(ls_source_total).
      IF ls_source_total-split_quantity <> ls_source_total-plant_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_fefo_date_metadata.
    DATA lv_source_match_count TYPE i.
    DATA ls_source_allocation TYPE
      zcl_stock_service=>ty_unit_date_plant_source_allocation.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_plant_allocation).
      IF ls_plant_allocation-allocation-allocated_quantity < 0
          OR ls_plant_allocation-allocation-available_quantity <
            ls_plant_allocation-allocation-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_plant_allocation-allocation-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_plant_allocation-allocation-request_id IS INITIAL
          OR ls_plant_allocation-allocation-material IS INITIAL
          OR ls_plant_allocation-allocation-target_plant IS INITIAL
          OR ls_plant_allocation-allocation-source_plant IS INITIAL
          OR ls_plant_allocation-allocation-target_plant =
            ls_plant_allocation-allocation-source_plant
          OR ls_plant_allocation-allocation-required_date IS INITIAL
          OR ls_plant_allocation-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE is_allocation-allocations INTO DATA(ls_demand_allocation)
        WITH KEY allocation-request_id =
          ls_plant_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_demand_allocation-allocation-material <>
            ls_plant_allocation-allocation-material
          OR ls_demand_allocation-allocation-target_plant <>
            ls_plant_allocation-allocation-target_plant
          OR ls_demand_allocation-allocation-required_date <>
            ls_plant_allocation-allocation-required_date
          OR ls_demand_allocation-allocation-priority <>
            ls_plant_allocation-allocation-priority
          OR ls_demand_allocation-base_unit <>
            ls_plant_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_split).
      DATA(ls_batch_source) = ls_batch_split-allocation-allocation.
      IF ls_batch_source-allocated_quantity < 0
          OR ls_batch_source-available_quantity <
            ls_batch_source-allocated_quantity
          OR ls_batch_split-allocated_source_quantity < 0
          OR ls_batch_split-available_source_quantity <
            ls_batch_split-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_batch_source-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_batch_source-request_id IS INITIAL
          OR ls_batch_source-material IS INITIAL
          OR ls_batch_source-target_plant IS INITIAL
          OR ls_batch_source-source_plant IS INITIAL
          OR ls_batch_source-target_plant = ls_batch_source-source_plant
          OR ls_batch_source-storage_location IS INITIAL
          OR ls_batch_source-batch IS INITIAL
          OR ls_batch_split-allocation-required_date IS INITIAL
          OR ls_batch_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      CLEAR: lv_source_match_count, ls_source_allocation.
      LOOP AT is_allocation-plant_allocations
          INTO DATA(ls_candidate_source).
        IF ls_candidate_source-allocation-request_id =
              ls_batch_source-request_id
            AND ls_candidate_source-allocation-source_plant =
              ls_batch_source-source_plant.
          ADD 1 TO lv_source_match_count.
          ls_source_allocation = ls_candidate_source.
        ENDIF.
      ENDLOOP.
      IF lv_source_match_count <> 1
          OR ls_source_allocation-allocation-material <>
            ls_batch_source-material
          OR ls_source_allocation-allocation-target_plant <>
            ls_batch_source-target_plant
          OR ls_source_allocation-allocation-required_date <>
            ls_batch_split-allocation-required_date
          OR ls_source_allocation-allocation-priority <>
            ls_batch_split-allocation-priority
          OR ls_source_allocation-base_unit <> ls_batch_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD to_plant_location_uom.
    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-allocation-required_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        allocation                = CORRESPONDING #(
          ls_unit_demand-allocation )
        source_quantity           = ls_unit_demand-source_quantity
        source_unit               = ls_unit_demand-source_unit
        base_quantity             = ls_unit_demand-base_quantity
        base_unit                 = ls_unit_demand-base_unit
        available_source_quantity =
          ls_unit_demand-available_source_quantity
        allocated_source_quantity =
          ls_unit_demand-allocated_source_quantity
        shortfall_source_quantity =
          ls_unit_demand-shortfall_source_quantity )
        TO rs_result-allocations.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations INTO DATA(ls_unit_source).
      APPEND VALUE #(
        allocation                = CORRESPONDING #(
          ls_unit_source-allocation )
        source_unit               = ls_unit_source-source_unit
        base_unit                 = ls_unit_source-base_unit
        available_source_quantity =
          ls_unit_source-available_source_quantity
        allocated_source_quantity =
          ls_unit_source-allocated_source_quantity )
        TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations
        INTO DATA(ls_unit_split).
      IF ls_unit_split-allocation-required_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE is_allocation-allocations INTO ls_unit_demand
        WITH KEY allocation-request_id =
          ls_unit_split-allocation-allocation-request_id.
      IF sy-subrc <> 0
          OR ls_unit_demand-allocation-material
            <> ls_unit_split-allocation-allocation-material
          OR ls_unit_demand-allocation-target_plant
            <> ls_unit_split-allocation-allocation-target_plant
          OR ls_unit_demand-allocation-required_date
            <> ls_unit_split-allocation-required_date
          OR ls_unit_demand-allocation-priority
            <> ls_unit_split-allocation-priority.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        allocation                = CORRESPONDING #(
          ls_unit_split-allocation-allocation )
        source_unit               = ls_unit_split-source_unit
        base_unit                 = ls_unit_split-base_unit
        available_source_quantity =
          ls_unit_split-available_source_quantity
        allocated_source_quantity =
          ls_unit_split-allocated_source_quantity )
        TO rs_result-location_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD transfer_fefo_date_uom.
    validate_fefo_date_metadata( is_allocation = is_allocation ).
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
        OR iv_fiscal_year IS INITIAL
        OR ( iv_defer_commit <> abap_true
          AND iv_defer_commit <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    validate_optional_post_date( iv_date = iv_posting_date ).

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

    IF iv_defer_commit = abap_true.
      rs_result-is_successful = abap_true.
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

  METHOD cancel_material_documents_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_cancel_key,
        material_document TYPE zif_goods_movement_api=>ty_material_document,
        fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year,
      END OF ty_cancel_key.
    TYPES ty_item_number TYPE
      zif_goods_movement_api=>ty_material_document_item.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_cancel_keys TYPE HASHED TABLE OF ty_cancel_key
      WITH UNIQUE KEY material_document fiscal_year.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_document> TYPE ty_cancel_document_row_result.

    IF iv_atomic <> abap_true AND iv_atomic <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_atomic = iv_atomic.
    rs_result-is_successful = abap_true.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material_document IS INITIAL
          OR ls_request-fiscal_year IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      validate_optional_post_date( iv_date = ls_request-posting_date ).
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        material_document = ls_request-material_document
        fiscal_year       = ls_request-fiscal_year )
        INTO TABLE lt_cancel_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      CLEAR lt_seen_item_numbers.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_item_numbers.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDLOOP.
      APPEND VALUE #(
        request_id        = ls_request-request_id
        material_document = ls_request-material_document
        fiscal_year       = ls_request-fiscal_year )
        TO rs_result-documents.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-documents ASSIGNING <ls_document>
        INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_document>-is_attempted = abap_true.
      <ls_document>-reversal_result = cancel(
        iv_material_document = ls_request-material_document
        iv_fiscal_year       = ls_request-fiscal_year
        iv_posting_date      = ls_request-posting_date
        it_item_numbers      = ls_request-item_numbers
        iv_defer_commit      = iv_atomic ).
      IF <ls_document>-reversal_result-is_successful = abap_true.
        IF iv_atomic = abap_false.
          <ls_document>-is_cancelled = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.

      rs_result-is_successful = abap_false.
      IF iv_atomic = abap_true.
        LOOP AT rs_result-documents ASSIGNING <ls_document>.
          <ls_document>-reversal_result-is_successful = abap_false.
          CLEAR: <ls_document>-reversal_result-material_document,
            <ls_document>-reversal_result-fiscal_year.
          <ls_document>-is_cancelled = abap_false.
        ENDLOOP.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true AND rs_result-is_successful = abap_true.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-documents ASSIGNING <ls_document>.
          <ls_document>-is_cancelled = abap_true.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        LOOP AT rs_result-documents ASSIGNING <ls_document>.
          <ls_document>-reversal_result-is_successful = abap_false.
          CLEAR: <ls_document>-reversal_result-material_document,
            <ls_document>-reversal_result-fiscal_year.
          <ls_document>-is_cancelled = abap_false.
        ENDLOOP.
        READ TABLE rs_result-documents ASSIGNING <ls_document>
          INDEX lines( rs_result-documents ).
        IF sy-subrc = 0 AND ls_commit_result-message IS NOT INITIAL.
          APPEND ls_commit_result-message
            TO <ls_document>-reversal_result-messages.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
