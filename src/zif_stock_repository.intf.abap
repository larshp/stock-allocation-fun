INTERFACE zif_stock_repository PUBLIC.
  CONSTANTS c_expiry_source_plant  TYPE c LENGTH 1 VALUE 'P'.
  CONSTANTS c_expiry_source_global TYPE c LENGTH 1 VALUE 'G'.
  CONSTANTS c_allocation_pass_match TYPE c LENGTH 1 VALUE 'M'.
  CONSTANTS c_allocation_pass_fallback TYPE c LENGTH 1 VALUE 'F'.
  CONSTANTS c_allocation_outcome_full TYPE c LENGTH 1 VALUE 'F'.
  CONSTANTS c_allocation_outcome_partial TYPE c LENGTH 1 VALUE 'P'.
  CONSTANTS c_allocation_outcome_none TYPE c LENGTH 1 VALUE 'U'.


  TYPES:
    BEGIN OF ty_reservation_key,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
    END OF ty_reservation_key.
  TYPES ty_reservation_keys TYPE STANDARD TABLE OF
    ty_reservation_key WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_uncovered_reservation,
      reservation_number      TYPE resb-rsnum,
      reservation_item        TYPE resb-rspos,
      allocation_sequence     TYPE i,
      required_date           TYPE resb-bdter,
      storage_location        TYPE resb-lgort,
      batch                   TYPE resb-charg,
      valuation_type          TYPE resb-bwtar,
      required_quantity       TYPE resb-bdmng,
      withdrawn_quantity      TYPE resb-enmng,
      open_quantity           TYPE resb-bdmng,
      allocated_quantity      TYPE resb-bdmng,
      matched_quantity        TYPE resb-bdmng,
      fallback_quantity       TYPE resb-bdmng,
      uncovered_quantity      TYPE resb-bdmng,
      allocation_coverage_pct TYPE p LENGTH 5 DECIMALS 2,
      allocation_shortage_pct TYPE p LENGTH 5 DECIMALS 2,
      matched_share_pct       TYPE p LENGTH 5 DECIMALS 2,
      fallback_share_pct      TYPE p LENGTH 5 DECIMALS 2,
    END OF ty_uncovered_reservation.
  TYPES ty_uncovered_reservations TYPE STANDARD TABLE OF
    ty_uncovered_reservation WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_reservation_allocation_summary,
      reservation_number         TYPE resb-rsnum,
      reservation_item           TYPE resb-rspos,
      allocation_sequence        TYPE i,
      required_date              TYPE resb-bdter,
      days_until_required        TYPE i,
      requested_storage_location TYPE resb-lgort,
      requested_batch            TYPE resb-charg,
      requested_valuation_type   TYPE resb-bwtar,
      required_quantity          TYPE resb-bdmng,
      withdrawn_quantity         TYPE resb-enmng,
      open_quantity              TYPE resb-bdmng,
      allocated_quantity         TYPE resb-bdmng,
      matched_quantity           TYPE resb-bdmng,
      fallback_quantity          TYPE resb-bdmng,
      uncovered_quantity         TYPE resb-bdmng,
      allocation_outcome         TYPE c LENGTH 1,
      allocation_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      allocation_shortage_pct    TYPE p LENGTH 5 DECIMALS 2,
      matched_share_pct          TYPE p LENGTH 5 DECIMALS 2,
      fallback_share_pct         TYPE p LENGTH 5 DECIMALS 2,
    END OF ty_reservation_allocation_summary.
  TYPES ty_reservation_allocation_summaries TYPE STANDARD TABLE OF
    ty_reservation_allocation_summary WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_allocation_detail,
      reservation_number         TYPE resb-rsnum,
      reservation_item           TYPE resb-rspos,
      allocation_sequence        TYPE i,
      required_date              TYPE resb-bdter,
      days_until_required        TYPE i,
      allocation_pass            TYPE c LENGTH 1,
      requested_storage_location TYPE resb-lgort,
      requested_batch            TYPE resb-charg,
      requested_valuation_type   TYPE resb-bwtar,
      storage_location           TYPE mard-lgort,
      batch                      TYPE mchb-charg,
      valuation_type             TYPE mcha-bwtar,
      expiration_date            TYPE mcha-vfdat,
      days_to_expiration         TYPE i,
      expiration_date_source     TYPE c LENGTH 1,
      expiry_due_relation        TYPE c LENGTH 1,
      days_required_after_expiry TYPE i,
      expiry_due_gap_band        TYPE c LENGTH 2,
      quantity                   TYPE mchb-clabs,
    END OF ty_batch_allocation_detail.
  TYPES ty_batch_allocation_details TYPE STANDARD TABLE OF
    ty_batch_allocation_detail WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_stock_allocation_reservation,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      required_date      TYPE resb-bdter,
      storage_location   TYPE resb-lgort,
      batch              TYPE resb-charg,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      open_quantity      TYPE resb-bdmng,
    END OF ty_stock_allocation_reservation.
  TYPES ty_stock_allocation_reservations TYPE STANDARD TABLE OF
    ty_stock_allocation_reservation WITH EMPTY KEY.

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
    BEGIN OF ty_stock_status_request,
      request_id TYPE c LENGTH 30,
      material   TYPE mard-matnr,
      plant      TYPE mard-werks,
    END OF ty_stock_status_request.
  TYPES ty_stock_status_requests TYPE STANDARD TABLE OF
    ty_stock_status_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_stock_reservation_bulk_result,
      request_id   TYPE c LENGTH 30,
      material     TYPE mard-matnr,
      plant        TYPE mard-werks,
      reservations TYPE ty_stock_allocation_reservations,
    END OF ty_stock_reservation_bulk_result.
  TYPES ty_stock_reservation_bulk_results TYPE STANDARD TABLE OF
    ty_stock_reservation_bulk_result WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_safety_stock_bulk_result,
      request_id TYPE c LENGTH 30,
      material   TYPE mard-matnr,
      plant      TYPE mard-werks,
      quantity   TYPE marc-eisbe,
    END OF ty_safety_stock_bulk_result.
  TYPES ty_safety_stock_bulk_results TYPE STANDARD TABLE OF
    ty_safety_stock_bulk_result WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_stock_status_result,
      request_id   TYPE c LENGTH 30,
      material     TYPE mard-matnr,
      plant        TYPE mard-werks,
      stock_status TYPE ty_stock_status,
    END OF ty_stock_status_result.
  TYPES ty_stock_status_results TYPE STANDARD TABLE OF
    ty_stock_status_result WITH EMPTY KEY.
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
    BEGIN OF ty_stock_location_bulk_result,
      request_id TYPE c LENGTH 30,
      material   TYPE mard-matnr,
      plant      TYPE mard-werks,
      locations  TYPE ty_stock_status_locations,
    END OF ty_stock_location_bulk_result.
  TYPES ty_stock_location_bulk_results TYPE STANDARD TABLE OF
    ty_stock_location_bulk_result WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_sales_order_reservation,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      sales_document     TYPE resb-kdauf,
      material           TYPE resb-matnr,
      plant              TYPE resb-werks,
      item_number        TYPE resb-kdpos,
      schedule_line      TYPE resb-kdein,
      requirement_date   TYPE resb-bdter,
      storage_location   TYPE resb-lgort,
      batch              TYPE resb-charg,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      open_quantity      TYPE resb-bdmng,
    END OF ty_sales_order_reservation.
  TYPES ty_sales_order_reservations TYPE STANDARD TABLE OF
    ty_sales_order_reservation WITH EMPTY KEY.
  TYPES ty_sales_order_documents TYPE STANDARD TABLE OF resb-kdauf
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_stock,
      storage_location   TYPE mard-lgort,
      batch              TYPE mchb-charg,
      valuation_type     TYPE mcha-bwtar,
      expiration_date    TYPE mcha-vfdat,
      expiry_source      TYPE c LENGTH 1,
      available_quantity TYPE mchb-clabs,
    END OF ty_batch_stock.
  TYPES ty_batch_stocks TYPE STANDARD TABLE OF ty_batch_stock
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_stock_status,
      storage_location            TYPE mard-lgort,
      batch                       TYPE mchb-charg,
      valuation_type              TYPE mcha-bwtar,
      batch_managed               TYPE marc-xchar,
      expiration_date             TYPE mcha-vfdat,
      expiration_date_source      TYPE c LENGTH 1,
      unrestricted_quantity       TYPE mchb-clabs,
      available_quantity          TYPE mchb-clabs,
      quality_inspection_quantity TYPE mchb-cinsm,
      blocked_quantity            TYPE mchb-cspem,
    END OF ty_batch_stock_status.
  TYPES ty_batch_stock_statuses TYPE STANDARD TABLE OF
    ty_batch_stock_status WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_batch_status_bulk_result,
      request_id                     TYPE c LENGTH 30,
      material                       TYPE mard-matnr,
      plant                          TYPE mard-werks,
      snapshot_timestamp             TYPE timestampl,
      open_reservation_quantity      TYPE resb-bdmng,
      excluded_open_resv_quantity    TYPE resb-bdmng,
      matched_allocation_quantity    TYPE resb-bdmng,
      fallback_allocation_quantity   TYPE resb-bdmng,
      matched_allocation_row_count   TYPE i,
      fallback_allocation_row_count  TYPE i,
      fully_allocated_resv_count     TYPE i,
      partially_allocated_resv_count TYPE i,
      unallocated_resv_count         TYPE i,
      fully_alloc_resv_open_qty      TYPE resb-bdmng,
      part_alloc_resv_open_qty       TYPE resb-bdmng,
      unalloc_resv_open_qty          TYPE resb-bdmng,
      uncovered_open_resv_quantity   TYPE resb-bdmng,
      uncovered_open_resv_row_count  TYPE i,
      first_uncovered_required_date  TYPE resb-bdter,
      first_uncovered_resv_number    TYPE resb-rsnum,
      first_uncovered_resv_item      TYPE resb-rspos,
      uncovered_open_resv_keys       TYPE ty_reservation_keys,
      uncovered_open_reservations    TYPE ty_uncovered_reservations,
      resv_allocation_summaries      TYPE ty_reservation_allocation_summaries,
      allocation_details             TYPE ty_batch_allocation_details,
      open_reservation_row_count     TYPE i,
      excluded_open_resv_row_count   TYPE i,
      unmatched_open_resv_excl_count TYPE i,
      unmatched_excl_reservations    TYPE ty_reservation_keys,
      batches                        TYPE ty_batch_stock_statuses,
    END OF ty_batch_status_bulk_result.
  TYPES ty_batch_status_bulk_results TYPE STANDARD TABLE OF
    ty_batch_status_bulk_result WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_projected_receipt,
      material             TYPE mard-matnr,
      plant                TYPE mard-werks,
      base_unit            TYPE mara-meins,
      storage_location     TYPE ekpo-lgort,
      batch                TYPE eket-charg,
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
  TYPES:
    BEGIN OF ty_projected_receipt_bulk_request,
      request_id   TYPE c LENGTH 30,
      material     TYPE mard-matnr,
      plant        TYPE mard-werks,
      through_date TYPE d,
    END OF ty_projected_receipt_bulk_request.
  TYPES ty_projected_receipt_bulk_requests TYPE STANDARD TABLE OF
    ty_projected_receipt_bulk_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_projected_receipt_bulk_result,
      request_id   TYPE c LENGTH 30,
      material     TYPE mard-matnr,
      plant        TYPE mard-werks,
      through_date TYPE d,
      receipts     TYPE ty_projected_receipts,
    END OF ty_projected_receipt_bulk_result.
  TYPES ty_projected_receipt_bulk_results TYPE STANDARD TABLE OF
    ty_projected_receipt_bulk_result WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_available_stock_date_request,
      request_id    TYPE c LENGTH 30,
      material      TYPE mard-matnr,
      plant         TYPE mard-werks,
      required_date TYPE resb-bdter,
    END OF ty_available_stock_date_request.
  TYPES ty_available_stock_date_requests TYPE STANDARD TABLE OF
    ty_available_stock_date_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_available_stock_date_result,
      request_id         TYPE c LENGTH 30,
      material           TYPE mard-matnr,
      plant              TYPE mard-werks,
      required_date      TYPE resb-bdter,
      available_quantity TYPE mard-labst,
    END OF ty_available_stock_date_result.
  TYPES ty_available_stock_date_results TYPE STANDARD TABLE OF
    ty_available_stock_date_result WITH EMPTY KEY.

  METHODS get_unrestricted_stock
    IMPORTING
      iv_material              TYPE mard-matnr
      iv_plant                 TYPE mard-werks
      it_excluded_reservations TYPE ty_reservation_keys OPTIONAL
    RETURNING
      VALUE(rv_quantity)       TYPE mard-labst
    RAISING
      zcx_invalid_stock_request.

  METHODS get_available_stock_by_date
    IMPORTING
      iv_material                    TYPE mard-matnr
      iv_plant                       TYPE mard-werks
      iv_required_date               TYPE resb-bdter
      it_excluded_reservations       TYPE ty_reservation_keys OPTIONAL
      iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
      iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
      iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
      iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
      iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
      iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
      iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
      iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
      RETURNING
      VALUE(rv_quantity)             TYPE mard-labst
    RAISING
      zcx_invalid_stock_request.

  METHODS get_available_stock_date_bulk
    IMPORTING
      it_requests                    TYPE ty_available_stock_date_requests
      it_excluded_reservations       TYPE ty_reservation_keys OPTIONAL
      iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
      iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
      iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
      iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
      iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
      iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
      iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
      iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rt_results)              TYPE ty_available_stock_date_results
    RAISING
      zcx_invalid_stock_request.

  METHODS get_projected_receipts
    IMPORTING
      iv_material                    TYPE mard-matnr
      iv_plant                       TYPE mard-werks
      iv_through_date                TYPE d
      iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
      iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
      iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
      iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
      iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
      iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
      iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
      RETURNING
      VALUE(rt_receipts)             TYPE ty_projected_receipts
    RAISING
      zcx_invalid_stock_request.

  METHODS get_projected_receipts_bulk
    IMPORTING
      it_requests                    TYPE ty_projected_receipt_bulk_requests
      iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
      iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
      iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
      iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
      iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
      iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
      iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
      iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
      iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rt_results)              TYPE ty_projected_receipt_bulk_results
    RAISING
      zcx_invalid_stock_request.

  METHODS get_po_confirmed_receipts
    IMPORTING
      iv_material        TYPE mard-matnr
      iv_plant           TYPE mard-werks
      iv_through_date    TYPE d
    RETURNING
      VALUE(rt_receipts) TYPE ty_projected_receipts
    RAISING
      zcx_invalid_stock_request.

  METHODS get_po_confirmed_receipts_bulk
    IMPORTING
      it_requests       TYPE ty_projected_receipt_bulk_requests
    RETURNING
      VALUE(rt_results) TYPE ty_projected_receipt_bulk_results
    RAISING
      zcx_invalid_stock_request.

  METHODS get_safety_stock
    IMPORTING
      iv_material        TYPE mard-matnr
      iv_plant           TYPE mard-werks
    RETURNING
      VALUE(rv_quantity) TYPE marc-eisbe.

  METHODS get_safety_stock_bulk
    IMPORTING
      it_requests      TYPE ty_stock_status_requests
    RETURNING
      VALUE(rt_status) TYPE ty_safety_stock_bulk_results.

  METHODS get_sales_order_reservations
    IMPORTING
      iv_sales_document        TYPE resb-kdauf
      iv_required_through_date TYPE resb-bdter OPTIONAL
    RETURNING
      VALUE(rt_reservations)   TYPE ty_sales_order_reservations.

  " Each positive open RESB row is returned separately.
  METHODS get_order_reservations_bulk
    IMPORTING
      it_sales_documents       TYPE ty_sales_order_documents
      iv_required_through_date TYPE resb-bdter OPTIONAL
    RETURNING
      VALUE(rt_reservations)   TYPE ty_sales_order_reservations.

  METHODS get_stock_status
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_plant         TYPE mard-werks
    RETURNING
      VALUE(rs_status) TYPE ty_stock_status
    RAISING
      zcx_invalid_stock_request.

  METHODS get_stock_status_bulk
    IMPORTING
      it_requests      TYPE ty_stock_status_requests
    RETURNING
      VALUE(rt_status) TYPE ty_stock_status_results
    RAISING
      zcx_invalid_stock_request.

  METHODS get_stock_status_by_location
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_plant         TYPE mard-werks
    RETURNING
      VALUE(rt_status) TYPE ty_stock_status_locations.

  METHODS get_location_stock_status_bulk
    IMPORTING
      it_requests              TYPE ty_stock_status_requests
      it_excluded_reservations TYPE ty_reservation_keys OPTIONAL
    RETURNING
      VALUE(rt_status)         TYPE ty_stock_location_bulk_results.

  METHODS get_stock_status_by_batch
    IMPORTING
      iv_material      TYPE mard-matnr
      iv_plant         TYPE mard-werks
    RETURNING
      VALUE(rt_status) TYPE ty_batch_stock_statuses.

  METHODS get_open_stock_reservations
    IMPORTING
      iv_material              TYPE mard-matnr
      iv_plant                 TYPE mard-werks
      iv_required_through_date TYPE resb-bdter OPTIONAL
    RETURNING
      VALUE(rt_reservations)   TYPE ty_stock_allocation_reservations.

  METHODS get_open_stock_res_bulk
    IMPORTING
      it_requests              TYPE ty_stock_status_requests
      iv_required_through_date TYPE resb-bdter OPTIONAL
    RETURNING
      VALUE(rt_status)         TYPE ty_stock_reservation_bulk_results.

  METHODS get_batch_stock_status_bulk
    IMPORTING
      it_requests              TYPE ty_stock_status_requests
      it_excluded_reservations TYPE ty_reservation_keys OPTIONAL
    RETURNING
      VALUE(rt_status)         TYPE ty_batch_status_bulk_results.

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
