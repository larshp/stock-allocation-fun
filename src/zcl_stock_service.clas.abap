CLASS zcl_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_stock_status_request TYPE
      zif_stock_repository=>ty_stock_status_request.
    TYPES ty_stock_status_requests TYPE
      zif_stock_repository=>ty_stock_status_requests.
    TYPES ty_stock_status_result TYPE
      zif_stock_repository=>ty_stock_status_result.
    TYPES ty_stock_status_results TYPE
      zif_stock_repository=>ty_stock_status_results.
    TYPES ty_stock_location_bulk_result TYPE
      zif_stock_repository=>ty_stock_location_bulk_result.
    TYPES ty_stock_location_bulk_results TYPE
      zif_stock_repository=>ty_stock_location_bulk_results.
    TYPES ty_batch_status_bulk_result TYPE
      zif_stock_repository=>ty_batch_status_bulk_result.
    TYPES ty_batch_status_bulk_results TYPE
      zif_stock_repository=>ty_batch_status_bulk_results.
    TYPES:
      BEGIN OF ty_projected_receipt_in_unit,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        base_unit            TYPE mara-meins,
        unit                 TYPE mara-meins,
        receipt_date         TYPE d,
        quantity             TYPE mard-labst,
        source_type          TYPE c LENGTH 16,
        source_document      TYPE c LENGTH 35,
        source_item          TYPE c LENGTH 10,
        source_plant         TYPE eban-reswk,
        source_schedule_line TYPE eket-etenr,
      END OF ty_projected_receipt_in_unit.
    TYPES ty_projected_receipts_in_unit TYPE STANDARD TABLE OF
      ty_projected_receipt_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_receipt_request,
        request_id   TYPE c LENGTH 30,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_projected_receipt_request.
    TYPES ty_projected_receipt_requests TYPE STANDARD TABLE OF
      ty_projected_receipt_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_receipt_bulk_result,
        request_id   TYPE c LENGTH 30,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        receipts     TYPE zif_stock_repository=>ty_projected_receipts,
      END OF ty_projected_receipt_bulk_result.
    TYPES ty_projected_receipt_bulk_results TYPE STANDARD TABLE OF
      ty_projected_receipt_bulk_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_receipt_source_options,
        include_po_receipts         TYPE abap_bool,
        include_po_confirmations    TYPE abap_bool,
        include_sto_in_transit      TYPE abap_bool,
        include_unissued_sto        TYPE abap_bool,
        include_prod_receipts       TYPE abap_bool,
        include_pr_receipts         TYPE abap_bool,
        include_sto_pr_receipts     TYPE abap_bool,
        include_planned_receipts    TYPE abap_bool,
        include_fixed_planned       TYPE abap_bool,
        include_sched_agmt_receipts TYPE abap_bool,
      END OF ty_projected_receipt_source_options.
    TYPES:
      BEGIN OF ty_projected_receipt_option_request,
        request_id   TYPE c LENGTH 30,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        options      TYPE ty_projected_receipt_source_options,
      END OF ty_projected_receipt_option_request.
    TYPES ty_projected_receipt_option_requests TYPE STANDARD TABLE OF
      ty_projected_receipt_option_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_proj_receipt_uom_request,
        request_id   TYPE c LENGTH 30,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        unit         TYPE mara-meins,
      END OF ty_proj_receipt_uom_request.
    TYPES ty_proj_receipt_uom_requests TYPE STANDARD TABLE OF
      ty_proj_receipt_uom_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_proj_receipt_opt_uom_request,
        request_id   TYPE c LENGTH 30,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        unit         TYPE mara-meins,
        options      TYPE ty_projected_receipt_source_options,
      END OF ty_proj_receipt_opt_uom_request.
    TYPES ty_proj_receipt_opt_uom_requests TYPE STANDARD TABLE OF
      ty_proj_receipt_opt_uom_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_proj_receipt_uom_result,
        request_id   TYPE c LENGTH 30,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        base_unit    TYPE mara-meins,
        unit         TYPE mara-meins,
        receipts     TYPE ty_projected_receipts_in_unit,
      END OF ty_proj_receipt_uom_result.
    TYPES ty_proj_receipt_uom_results TYPE STANDARD TABLE OF
      ty_proj_receipt_uom_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_batch_status_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        as_of_date TYPE d,
        min_days   TYPE i,
      END OF ty_fefo_batch_status_request.
    TYPES ty_fefo_batch_status_requests TYPE STANDARD TABLE OF
      ty_fefo_batch_status_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_batch_status_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        as_of_date TYPE d,
        min_days   TYPE i,
        batches    TYPE zif_stock_repository=>ty_batch_stock_statuses,
      END OF ty_fefo_batch_status_result.
    TYPES ty_fefo_batch_status_results TYPE STANDARD TABLE OF
      ty_fefo_batch_status_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
      END OF ty_demand,
      ty_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY,
      ty_storage_locations TYPE STANDARD TABLE OF mard-lgort WITH EMPTY KEY,
      BEGIN OF ty_plant_source_location,
        request_id       TYPE c LENGTH 30,
        source_plant     TYPE mard-werks,
        storage_location TYPE mard-lgort,
      END OF ty_plant_source_location,
      ty_plant_source_locations TYPE STANDARD TABLE OF
        ty_plant_source_location WITH EMPTY KEY,
      ty_plant_source_location_set TYPE SORTED TABLE OF
        ty_plant_source_location WITH UNIQUE KEY
          request_id source_plant storage_location,
      BEGIN OF ty_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_allocation.
    TYPES:
      BEGIN OF ty_dated_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
      END OF ty_dated_demand.
    TYPES ty_dated_demands TYPE STANDARD TABLE OF ty_dated_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_dated_allocation.
    TYPES ty_dated_allocations TYPE STANDARD TABLE OF ty_dated_allocation
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_unit_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
        requested_unit     TYPE mara-meins,
      END OF ty_date_unit_demand.
    TYPES ty_date_unit_demands TYPE STANDARD TABLE OF ty_date_unit_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_unit_allocation,
        allocation                TYPE ty_dated_allocation,
        source_quantity           TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_quantity             TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
        shortfall_source_quantity TYPE mard-labst,
      END OF ty_date_unit_allocation.
    TYPES ty_date_unit_allocations TYPE STANDARD TABLE OF
      ty_date_unit_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_atp_allocation,
        local_estimate            TYPE ty_dated_allocation,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_dated_atp_allocation.
    TYPES:
      BEGIN OF ty_atp_confirmation_split,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
      END OF ty_atp_confirmation_split.
    TYPES:
      BEGIN OF ty_date_unit_atp_allocation,
        local_estimate            TYPE ty_date_unit_allocation,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_date_unit_atp_allocation.
    TYPES ty_date_unit_atp_allocations TYPE STANDARD TABLE OF
      ty_date_unit_atp_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        requested_quantity TYPE mard-labst,
      END OF ty_plant_demand.
    TYPES ty_plant_demands TYPE STANDARD TABLE OF ty_plant_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_source,
        request_id   TYPE c LENGTH 30,
        source_plant TYPE mard-werks,
      END OF ty_plant_source.
    TYPES ty_plant_sources TYPE STANDARD TABLE OF ty_plant_source
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
      END OF ty_date_plant_demand.
    TYPES ty_date_plant_demands TYPE STANDARD TABLE OF ty_date_plant_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_demand_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_date_plant_demand_allocation.
    TYPES ty_date_plant_demand_allocations TYPE STANDARD TABLE OF
      ty_date_plant_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_source_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_date_plant_source_allocation.
    TYPES ty_date_plant_source_allocations TYPE STANDARD TABLE OF
      ty_date_plant_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_allocation_result,
        allocations       TYPE ty_date_plant_demand_allocations,
        plant_allocations TYPE ty_date_plant_source_allocations,
      END OF ty_date_plant_allocation_result.
    TYPES:
      BEGIN OF ty_unit_date_plant_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
        requested_unit     TYPE mara-meins,
      END OF ty_unit_date_plant_demand.
    TYPES ty_unit_date_plant_demands TYPE STANDARD TABLE OF
      ty_unit_date_plant_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_demand_allocation,
        allocation                TYPE ty_date_plant_demand_allocation,
        source_quantity           TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_quantity             TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
        shortfall_source_quantity TYPE mard-labst,
      END OF ty_unit_date_plant_demand_allocation.
    TYPES ty_unit_date_plant_demand_allocs TYPE STANDARD TABLE OF
      ty_unit_date_plant_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_source_allocation,
        allocation                TYPE ty_date_plant_source_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_date_plant_source_allocation.
    TYPES ty_unit_date_plant_source_allocs TYPE STANDARD TABLE OF
      ty_unit_date_plant_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_result,
        allocations       TYPE ty_unit_date_plant_demand_allocs,
        plant_allocations TYPE ty_unit_date_plant_source_allocs,
      END OF ty_unit_date_plant_result.
    TYPES:
      BEGIN OF ty_plant_atp_check,
        material                  TYPE mard-matnr,
        source_plant              TYPE mard-werks,
        check_date                TYPE d,
        base_unit                 TYPE mara-meins,
        allocated_base_quantity   TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_plant_atp_check.
    TYPES ty_plant_atp_checks TYPE STANDARD TABLE OF ty_plant_atp_check
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_date_atp_check,
        request_id                TYPE c LENGTH 30,
        material                  TYPE mard-matnr,
        target_plant              TYPE mard-werks,
        source_plant              TYPE mard-werks,
        required_date             TYPE resb-bdter,
        base_unit                 TYPE mara-meins,
        allocated_base_quantity   TYPE mard-labst,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_plant_date_atp_check.
    TYPES ty_plant_date_atp_checks TYPE STANDARD TABLE OF
      ty_plant_date_atp_check WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_date_atp_result,
        local_estimate TYPE ty_unit_date_plant_result,
        atp_checks     TYPE ty_plant_date_atp_checks,
      END OF ty_plant_date_atp_result.
    TYPES:
      BEGIN OF ty_plant_demand_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_plant_demand_allocation.
    TYPES ty_plant_demand_allocations TYPE STANDARD TABLE OF
      ty_plant_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_source_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_plant_source_allocation.
    TYPES ty_plant_source_allocations TYPE STANDARD TABLE OF
      ty_plant_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_location_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_plant_location_allocation.
    TYPES ty_plant_location_allocations TYPE STANDARD TABLE OF
      ty_plant_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_allocation_result,
        allocations          TYPE ty_plant_demand_allocations,
        plant_allocations    TYPE ty_plant_source_allocations,
        location_allocations TYPE ty_plant_location_allocations,
      END OF ty_plant_allocation_result.
    TYPES:
      BEGIN OF ty_unit_plant_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        requested_quantity TYPE mard-labst,
        requested_unit     TYPE mara-meins,
      END OF ty_unit_plant_demand.
    TYPES:
      BEGIN OF ty_plant_batch_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        batch              TYPE mchb-charg,
        requested_quantity TYPE mard-labst,
      END OF ty_plant_batch_demand.
    TYPES ty_plant_batch_demands TYPE STANDARD TABLE OF
      ty_plant_batch_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_batch_demand_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        batch              TYPE mchb-charg,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_plant_batch_demand_allocation.
    TYPES ty_plant_batch_demand_allocations TYPE STANDARD TABLE OF
      ty_plant_batch_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_batch_source_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        batch              TYPE mchb-charg,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_plant_batch_source_allocation.
    TYPES ty_plant_batch_source_allocations TYPE STANDARD TABLE OF
      ty_plant_batch_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_batch_location_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_plant_batch_location_allocation.
    TYPES ty_plant_batch_location_allocations TYPE STANDARD TABLE OF
      ty_plant_batch_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_batch_allocation_result,
        allocations          TYPE ty_plant_batch_demand_allocations,
        plant_allocations    TYPE ty_plant_batch_source_allocations,
        location_allocations TYPE ty_plant_batch_location_allocations,
      END OF ty_plant_batch_allocation_result.
    TYPES:
      BEGIN OF ty_date_plant_batch_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        batch              TYPE mchb-charg,
        requested_quantity TYPE mard-labst,
      END OF ty_date_plant_batch_demand.
    TYPES ty_date_plant_batch_demands TYPE STANDARD TABLE OF
      ty_date_plant_batch_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_batch_demand_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        batch              TYPE mchb-charg,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_date_plant_batch_demand_allocation.
    TYPES ty_date_plant_batch_demand_allocations TYPE STANDARD TABLE OF
      ty_date_plant_batch_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_batch_source_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        batch              TYPE mchb-charg,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_date_plant_batch_source_allocation.
    TYPES ty_date_plant_batch_source_allocations TYPE STANDARD TABLE OF
      ty_date_plant_batch_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_batch_location_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_date_plant_batch_location_allocation.
    TYPES ty_date_plant_batch_location_allocs TYPE STANDARD TABLE OF
      ty_date_plant_batch_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_batch_allocation_result,
        allocations          TYPE ty_date_plant_batch_demand_allocations,
        plant_allocations    TYPE ty_date_plant_batch_source_allocations,
        location_allocations TYPE ty_date_plant_batch_location_allocs,
      END OF ty_date_plant_batch_allocation_result.
    TYPES:
      BEGIN OF ty_unit_date_plant_batch_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        batch              TYPE mchb-charg,
        requested_quantity TYPE mard-labst,
        requested_unit     TYPE mara-meins,
      END OF ty_unit_date_plant_batch_demand.
    TYPES ty_unit_date_plant_batch_demands TYPE STANDARD TABLE OF
      ty_unit_date_plant_batch_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_batch_demand_alloc,
        allocation                TYPE ty_date_plant_batch_demand_allocation,
        source_quantity           TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_quantity             TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
        shortfall_source_quantity TYPE mard-labst,
      END OF ty_unit_date_plant_batch_demand_alloc.
    TYPES ty_unit_date_plant_batch_dem_allocs TYPE STANDARD TABLE OF
      ty_unit_date_plant_batch_demand_alloc WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_batch_source_alloc,
        allocation                TYPE ty_date_plant_batch_source_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_date_plant_batch_source_alloc.
    TYPES ty_unit_date_plant_batch_source_allocs TYPE STANDARD TABLE OF
      ty_unit_date_plant_batch_source_alloc WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_batch_location,
        allocation                TYPE ty_date_plant_batch_location_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_date_plant_batch_location.
    TYPES ty_unit_date_plant_batch_locations TYPE STANDARD TABLE OF
      ty_unit_date_plant_batch_location WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_batch_result,
        allocations          TYPE ty_unit_date_plant_batch_dem_allocs,
        plant_allocations    TYPE ty_unit_date_plant_batch_source_allocs,
        location_allocations TYPE ty_unit_date_plant_batch_locations,
      END OF ty_unit_date_plant_batch_result.
    TYPES:
      BEGIN OF ty_plant_date_batch_atp_check,
        material                  TYPE mard-matnr,
        source_plant              TYPE mard-werks,
        check_date                TYPE resb-bdter,
        base_unit                 TYPE mara-meins,
        allocated_base_quantity   TYPE mard-labst,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_plant_date_batch_atp_check.
    TYPES ty_plant_date_batch_atp_checks TYPE STANDARD TABLE OF
      ty_plant_date_batch_atp_check WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_date_batch_atp_result,
        local_estimate TYPE ty_unit_date_plant_batch_result,
        atp_checks     TYPE ty_plant_date_batch_atp_checks,
      END OF ty_plant_date_batch_atp_result.
    TYPES:
      BEGIN OF ty_plant_fefo_allocation_result,
        allocations       TYPE ty_plant_demand_allocations,
        plant_allocations TYPE ty_plant_source_allocations,
        batch_allocations TYPE ty_plant_batch_location_allocations,
      END OF ty_plant_fefo_allocation_result.
    TYPES:
      BEGIN OF ty_date_plant_fefo_batch_allocation,
        required_date TYPE resb-bdter,
        priority      TYPE i,
        allocation    TYPE ty_plant_batch_location_allocation,
      END OF ty_date_plant_fefo_batch_allocation.
    TYPES ty_date_plant_fefo_batch_allocations TYPE STANDARD TABLE OF
      ty_date_plant_fefo_batch_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_fefo_allocation_result,
        allocations       TYPE ty_date_plant_demand_allocations,
        plant_allocations TYPE ty_date_plant_source_allocations,
        batch_allocations TYPE ty_date_plant_fefo_batch_allocations,
      END OF ty_date_plant_fefo_allocation_result.
    TYPES:
      BEGIN OF ty_unit_plant_batch_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        batch              TYPE mchb-charg,
        requested_quantity TYPE mard-labst,
        requested_unit     TYPE mara-meins,
      END OF ty_unit_plant_batch_demand.
    TYPES ty_unit_plant_batch_demands TYPE STANDARD TABLE OF
      ty_unit_plant_batch_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_batch_demand_allocation,
        allocation                TYPE ty_plant_batch_demand_allocation,
        source_quantity           TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_quantity             TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
        shortfall_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_batch_demand_allocation.
    TYPES ty_unit_plant_batch_demand_allocations TYPE STANDARD TABLE OF
      ty_unit_plant_batch_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_batch_source_allocation,
        allocation                TYPE ty_plant_batch_source_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_batch_source_allocation.
    TYPES ty_unit_plant_batch_source_allocs TYPE STANDARD TABLE OF
      ty_unit_plant_batch_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_batch_location_allocation,
        allocation                TYPE ty_plant_batch_location_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_batch_location_allocation.
    TYPES ty_unit_plant_batch_location_allocs TYPE STANDARD TABLE OF
      ty_unit_plant_batch_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_batch_result,
        allocations          TYPE ty_unit_plant_batch_demand_allocations,
        plant_allocations    TYPE ty_unit_plant_batch_source_allocs,
        location_allocations TYPE ty_unit_plant_batch_location_allocs,
      END OF ty_unit_plant_batch_result.
    TYPES ty_unit_plant_demands TYPE STANDARD TABLE OF ty_unit_plant_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_demand_allocation,
        allocation                TYPE ty_plant_demand_allocation,
        source_quantity           TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_quantity             TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
        shortfall_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_demand_allocation.
    TYPES ty_unit_plant_demand_allocations TYPE STANDARD TABLE OF
      ty_unit_plant_demand_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_source_allocation,
        allocation                TYPE ty_plant_source_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_source_allocation.
    TYPES ty_unit_plant_source_allocations TYPE STANDARD TABLE OF
      ty_unit_plant_source_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_location_allocation,
        allocation                TYPE ty_plant_location_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_location_allocation.
    TYPES ty_unit_plant_location_allocations TYPE STANDARD TABLE OF
      ty_unit_plant_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_allocation_result,
        allocations          TYPE ty_unit_plant_demand_allocations,
        plant_allocations    TYPE ty_unit_plant_source_allocations,
        location_allocations TYPE ty_unit_plant_location_allocations,
      END OF ty_unit_plant_allocation_result.
    TYPES:
      BEGIN OF ty_plant_atp_allocation_result,
        local_estimate TYPE ty_unit_plant_allocation_result,
        atp_checks     TYPE ty_plant_atp_checks,
      END OF ty_plant_atp_allocation_result.
    TYPES:
      BEGIN OF ty_plant_batch_atp_allocation_result,
        local_estimate TYPE ty_unit_plant_batch_result,
        atp_checks     TYPE ty_plant_atp_checks,
      END OF ty_plant_batch_atp_allocation_result.
    TYPES:
      BEGIN OF ty_unit_plant_fefo_split,
        allocation                TYPE ty_plant_batch_location_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_plant_fefo_split.
    TYPES ty_unit_plant_fefo_splits TYPE STANDARD TABLE OF
      ty_unit_plant_fefo_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_plant_fefo_result,
        allocations       TYPE ty_unit_plant_demand_allocations,
        plant_allocations TYPE ty_unit_plant_source_allocations,
        batch_allocations TYPE ty_unit_plant_fefo_splits,
      END OF ty_unit_plant_fefo_result.
    TYPES:
      BEGIN OF ty_plant_fefo_atp_allocation_result,
        local_estimate TYPE ty_unit_plant_fefo_result,
        atp_checks     TYPE ty_plant_atp_checks,
      END OF ty_plant_fefo_atp_allocation_result.
    TYPES:
      BEGIN OF ty_unit_date_plant_fefo_batch_split,
        allocation                TYPE ty_date_plant_fefo_batch_allocation,
        source_unit               TYPE mara-meins,
        base_unit                 TYPE mara-meins,
        available_source_quantity TYPE mard-labst,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_date_plant_fefo_batch_split.
    TYPES ty_unit_date_plant_fefo_batch_splits TYPE STANDARD TABLE OF
      ty_unit_date_plant_fefo_batch_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_date_plant_fefo_result,
        allocations       TYPE ty_unit_date_plant_demand_allocs,
        plant_allocations TYPE ty_unit_date_plant_source_allocs,
        batch_allocations TYPE ty_unit_date_plant_fefo_batch_splits,
      END OF ty_unit_date_plant_fefo_result.
    TYPES:
      BEGIN OF ty_plant_fefo_date_atp_result,
        local_estimate TYPE ty_unit_date_plant_fefo_result,
        atp_checks     TYPE ty_plant_date_atp_checks,
      END OF ty_plant_fefo_date_atp_result.
    TYPES:
      BEGIN OF ty_unit_allocation,
        allocation      TYPE ty_allocation,
        source_quantity TYPE mard-labst,
        source_unit     TYPE mara-meins,
        base_quantity   TYPE mard-labst,
        base_unit       TYPE mara-meins,
      END OF ty_unit_allocation.
    TYPES:
      BEGIN OF ty_unit_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        requested_quantity TYPE mard-labst,
        requested_unit     TYPE mara-meins,
      END OF ty_unit_demand.
    TYPES ty_unit_demands TYPE STANDARD TABLE OF ty_unit_demand WITH EMPTY KEY.
    TYPES ty_unit_allocations TYPE STANDARD TABLE OF ty_unit_allocation
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_stock_status_in_unit,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        base_unit                   TYPE mara-meins,
        unit                        TYPE mara-meins,
        unrestricted_quantity       TYPE mard-labst,
        reserved_quantity           TYPE mard-labst,
        available_unrestricted_qty  TYPE mard-labst,
        safety_stock_quantity       TYPE mard-labst,
        available_after_safety_qty  TYPE mard-labst,
        quality_inspection_quantity TYPE mard-labst,
        blocked_quantity            TYPE mard-labst,
      END OF ty_stock_status_in_unit.
    TYPES:
      BEGIN OF ty_stock_status_unit_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        unit       TYPE mara-meins,
      END OF ty_stock_status_unit_request.
    TYPES ty_stock_status_unit_requests TYPE STANDARD TABLE OF
      ty_stock_status_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_stock_status_unit_result,
        request_id TYPE c LENGTH 30,
        status     TYPE ty_stock_status_in_unit,
      END OF ty_stock_status_unit_result.
    TYPES ty_stock_status_unit_results TYPE STANDARD TABLE OF
      ty_stock_status_unit_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_stock_status_location_in_unit,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        base_unit                   TYPE mara-meins,
        unit                        TYPE mara-meins,
        unrestricted_quantity       TYPE mard-labst,
        available_unrestricted_qty  TYPE mard-labst,
        quality_inspection_quantity TYPE mard-labst,
        blocked_quantity            TYPE mard-labst,
      END OF ty_stock_status_location_in_unit.
    TYPES ty_stock_status_locations_in_unit TYPE STANDARD TABLE OF
      ty_stock_status_location_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_stock_uom_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        unit       TYPE mara-meins,
      END OF ty_location_stock_uom_request.
    TYPES ty_location_stock_uom_requests TYPE STANDARD TABLE OF
      ty_location_stock_uom_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_stock_uom_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        base_unit  TYPE mara-meins,
        unit       TYPE mara-meins,
        locations  TYPE ty_stock_status_locations_in_unit,
      END OF ty_location_stock_uom_result.
    TYPES ty_location_stock_uom_results TYPE STANDARD TABLE OF
      ty_location_stock_uom_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_stock_status_in_unit,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        storage_location      TYPE mard-lgort,
        batch                 TYPE mchb-charg,
        expiration_date       TYPE mcha-vfdat,
        base_unit             TYPE mara-meins,
        unit                  TYPE mara-meins,
        unrestricted_quantity TYPE mard-labst,
        available_quantity    TYPE mard-labst,
      END OF ty_batch_stock_status_in_unit.
    TYPES ty_batch_stock_statuses_in_unit TYPE STANDARD TABLE OF
      ty_batch_stock_status_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_stock_uom_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        unit       TYPE mara-meins,
      END OF ty_batch_stock_uom_request.
    TYPES ty_batch_stock_uom_requests TYPE STANDARD TABLE OF
      ty_batch_stock_uom_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_stock_uom_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        base_unit  TYPE mara-meins,
        unit       TYPE mara-meins,
        batches    TYPE ty_batch_stock_statuses_in_unit,
      END OF ty_batch_stock_uom_result.
    TYPES ty_batch_stock_uom_results TYPE STANDARD TABLE OF
      ty_batch_stock_uom_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_res_uom_request,
        request_id     TYPE c LENGTH 30,
        sales_document TYPE resb-kdauf,
        material       TYPE resb-matnr,
        plant          TYPE resb-werks,
        unit           TYPE mara-meins,
      END OF ty_order_res_uom_request.
    TYPES ty_order_res_uom_requests TYPE STANDARD TABLE OF
      ty_order_res_uom_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_reservation_in_unit,
        sales_document   TYPE resb-kdauf,
        material         TYPE resb-matnr,
        plant            TYPE resb-werks,
        item_number      TYPE resb-kdpos,
        schedule_line    TYPE resb-kdein,
        requirement_date TYPE resb-bdter,
        open_quantity    TYPE resb-bdmng,
      END OF ty_order_reservation_in_unit.
    TYPES ty_order_reservations_in_unit TYPE STANDARD TABLE OF
      ty_order_reservation_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_res_uom_result,
        request_id     TYPE c LENGTH 30,
        sales_document TYPE resb-kdauf,
        material       TYPE resb-matnr,
        plant          TYPE resb-werks,
        base_unit      TYPE mara-meins,
        unit           TYPE mara-meins,
        reservations   TYPE ty_order_reservations_in_unit,
      END OF ty_order_res_uom_result.
    TYPES ty_order_res_uom_results TYPE STANDARD TABLE OF
      ty_order_res_uom_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_batch_unit_request,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        as_of_date TYPE d,
        min_days   TYPE i,
        unit       TYPE mara-meins,
      END OF ty_fefo_batch_unit_request.
    TYPES ty_fefo_batch_unit_requests TYPE STANDARD TABLE OF
      ty_fefo_batch_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_batch_unit_result,
        request_id TYPE c LENGTH 30,
        material   TYPE mard-matnr,
        plant      TYPE mard-werks,
        as_of_date TYPE d,
        min_days   TYPE i,
        base_unit  TYPE mara-meins,
        unit       TYPE mara-meins,
        batches    TYPE ty_batch_stock_statuses_in_unit,
      END OF ty_fefo_batch_unit_result.
    TYPES ty_fefo_batch_unit_results TYPE STANDARD TABLE OF
      ty_fefo_batch_unit_result WITH EMPTY KEY.
    TYPES ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_storage_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        allocated_quantity TYPE mard-labst,
      END OF ty_storage_allocation.
    TYPES ty_storage_allocations TYPE STANDARD TABLE OF ty_storage_allocation
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_result,
        allocations         TYPE ty_allocations,
        storage_allocations TYPE ty_storage_allocations,
      END OF ty_location_result.
    TYPES:
      BEGIN OF ty_unit_location_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        requested_unit              TYPE mara-meins,
      END OF ty_unit_location_demand.
    TYPES ty_unit_location_demands TYPE STANDARD TABLE OF
      ty_unit_location_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_allocation_summary,
        allocation                TYPE ty_allocation,
        source_quantity           TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_quantity             TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        allocated_source_quantity TYPE mard-labst,
        shortfall_source_quantity TYPE mard-labst,
      END OF ty_unit_allocation_summary.
    TYPES ty_unit_allocation_summaries TYPE STANDARD TABLE OF
      ty_unit_allocation_summary WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_storage_split,
        storage_allocation        TYPE ty_storage_allocation,
        base_unit                 TYPE mara-meins,
        source_unit               TYPE mara-meins,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_storage_split.
    TYPES ty_unit_storage_splits TYPE STANDARD TABLE OF
      ty_unit_storage_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_location_result,
        allocations         TYPE ty_unit_allocation_summaries,
        storage_allocations TYPE ty_unit_storage_splits,
      END OF ty_unit_location_result.
    TYPES:
      BEGIN OF ty_batch_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        batch                       TYPE mchb-charg,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
      END OF ty_batch_demand,
      ty_batch_demands TYPE STANDARD TABLE OF ty_batch_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
      END OF ty_fefo_demand.
    TYPES ty_fefo_demands TYPE STANDARD TABLE OF ty_fefo_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_fefo_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        requested_unit              TYPE mara-meins,
      END OF ty_unit_fefo_demand.
    TYPES ty_unit_fefo_demands TYPE STANDARD TABLE OF ty_unit_fefo_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_batch_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        batch                       TYPE mchb-charg,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        requested_unit              TYPE mara-meins,
      END OF ty_unit_batch_demand.
    TYPES ty_unit_batch_demands TYPE STANDARD TABLE OF ty_unit_batch_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        allocated_quantity TYPE mard-labst,
      END OF ty_batch_allocation.
    TYPES ty_batch_allocations TYPE STANDARD TABLE OF ty_batch_allocation
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_result,
        allocations       TYPE ty_allocations,
        batch_allocations TYPE ty_batch_allocations,
      END OF ty_batch_result.
    TYPES:
      BEGIN OF ty_unit_batch_split,
        batch_allocation          TYPE ty_batch_allocation,
        base_unit                 TYPE mara-meins,
        source_unit               TYPE mara-meins,
        allocated_source_quantity TYPE mard-labst,
      END OF ty_unit_batch_split.
    TYPES ty_unit_batch_splits TYPE STANDARD TABLE OF
      ty_unit_batch_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_batch_result,
        allocations       TYPE ty_unit_allocation_summaries,
        batch_allocations TYPE ty_unit_batch_splits,
      END OF ty_unit_batch_result.

    METHODS constructor
      IMPORTING
        io_stock_repository          TYPE REF TO zif_stock_repository
        io_uom_converter             TYPE REF TO zif_material_uom_converter
          OPTIONAL
        io_material_availability_api TYPE REF TO zif_material_availability_api
          OPTIONAL.

    METHODS get_projected_receipts
      IMPORTING
        iv_material                    TYPE mard-matnr
        iv_plant                       TYPE mard-werks
        iv_through_date                TYPE d
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
        VALUE(rt_receipts)             TYPE zif_stock_repository=>ty_projected_receipts
      RAISING
        zcx_invalid_stock_request.

    METHODS get_po_confirmed_receipts
      IMPORTING
        iv_material        TYPE mard-matnr
        iv_plant           TYPE mard-werks
        iv_through_date    TYPE d
      RETURNING
        VALUE(rt_receipts) TYPE zif_stock_repository=>ty_projected_receipts
      RAISING
        zcx_invalid_stock_request.

    METHODS get_po_conf_receipts_in_unit
      IMPORTING
        iv_material        TYPE mard-matnr
        iv_plant           TYPE mard-werks
        iv_through_date    TYPE d
        iv_unit            TYPE mara-meins
      RETURNING
        VALUE(rt_receipts) TYPE ty_projected_receipts_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_po_conf_receipts_bulk
      IMPORTING
        it_requests       TYPE ty_projected_receipt_requests
      RETURNING
        VALUE(rt_results) TYPE ty_projected_receipt_bulk_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_po_conf_receipts_bulk_uom
      IMPORTING
        it_requests       TYPE ty_proj_receipt_uom_requests
      RETURNING
        VALUE(rt_results) TYPE ty_proj_receipt_uom_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_projected_receipts_in_unit
      IMPORTING
        iv_material                    TYPE mard-matnr
        iv_plant                       TYPE mard-werks
        iv_through_date                TYPE d
        iv_unit                        TYPE mara-meins
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
        VALUE(rt_receipts)             TYPE ty_projected_receipts_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_projected_receipts_bulk
      IMPORTING
        it_requests                    TYPE ty_projected_receipt_requests
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

    METHODS get_proj_receipts_opts_bulk
      IMPORTING
        it_requests       TYPE ty_projected_receipt_option_requests
      RETURNING
        VALUE(rt_results) TYPE ty_projected_receipt_bulk_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_proj_receipts_bulk_uom
      IMPORTING
        it_requests                    TYPE ty_proj_receipt_uom_requests
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
        VALUE(rt_results)              TYPE ty_proj_receipt_uom_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_proj_receipts_opts_uom
      IMPORTING
        it_requests       TYPE ty_proj_receipt_opt_uom_requests
      RETURNING
        VALUE(rt_results) TYPE ty_proj_receipt_uom_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_unrestricted_stock
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_quantity)      TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_status
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
      RETURNING
        VALUE(rs_status) TYPE zif_stock_repository=>ty_stock_status
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_status_bulk
      IMPORTING
        it_requests      TYPE ty_stock_status_requests
      RETURNING
        VALUE(rt_status) TYPE ty_stock_status_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_status_in_unit
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
        iv_unit          TYPE mara-meins
      RETURNING
        VALUE(rs_status) TYPE ty_stock_status_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_status_bulk_in_unit
      IMPORTING
        it_requests      TYPE ty_stock_status_unit_requests
      RETURNING
        VALUE(rt_status) TYPE ty_stock_status_unit_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_by_location_in_unit
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
        iv_unit          TYPE mara-meins
      RETURNING
        VALUE(rt_status) TYPE ty_stock_status_locations_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_by_batch_in_unit
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
        iv_unit          TYPE mara-meins
      RETURNING
        VALUE(rt_status) TYPE ty_batch_stock_statuses_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_fefo_batch_status_in_unit
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
        iv_unit          TYPE mara-meins
        iv_as_of_date    TYPE d DEFAULT sy-datum
        iv_min_days      TYPE i DEFAULT 0
      RETURNING
        VALUE(rt_status) TYPE ty_batch_stock_statuses_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_status_by_location
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
      RETURNING
        VALUE(rt_status) TYPE zif_stock_repository=>ty_stock_status_locations
      RAISING
        zcx_invalid_stock_request.

    METHODS get_location_stock_status_bulk
      IMPORTING
        it_requests      TYPE ty_stock_status_requests
      RETURNING
        VALUE(rt_status) TYPE ty_stock_location_bulk_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_location_stock_bulk_uom
      IMPORTING
        it_requests      TYPE ty_location_stock_uom_requests
      RETURNING
        VALUE(rt_status) TYPE ty_location_stock_uom_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_stock_status_by_batch
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
      RETURNING
        VALUE(rt_status) TYPE zif_stock_repository=>ty_batch_stock_statuses
      RAISING
        zcx_invalid_stock_request.

    METHODS get_batch_stock_status_bulk
      IMPORTING
        it_requests      TYPE ty_stock_status_requests
      RETURNING
        VALUE(rt_status) TYPE ty_batch_status_bulk_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_batch_stock_bulk_uom
      IMPORTING
        it_requests      TYPE ty_batch_stock_uom_requests
      RETURNING
        VALUE(rt_status) TYPE ty_batch_stock_uom_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_fefo_batch_status
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
        iv_as_of_date    TYPE d DEFAULT sy-datum
        iv_min_days      TYPE i DEFAULT 0
      RETURNING
        VALUE(rt_status) TYPE zif_stock_repository=>ty_batch_stock_statuses
      RAISING
        zcx_invalid_stock_request.

    METHODS get_fefo_batch_status_bulk
      IMPORTING
        it_requests      TYPE ty_fefo_batch_status_requests
      RETURNING
        VALUE(rt_status) TYPE ty_fefo_batch_status_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_fefo_batch_status_bulk_uom
      IMPORTING
        it_requests      TYPE ty_fefo_batch_unit_requests
      RETURNING
        VALUE(rt_status) TYPE ty_fefo_batch_unit_results
      RAISING
        zcx_invalid_stock_request.

    METHODS get_sales_order_reservations
      IMPORTING
        iv_sales_document      TYPE resb-kdauf
      RETURNING
        VALUE(rt_reservations) TYPE zif_stock_repository=>ty_sales_order_reservations
      RAISING
        zcx_invalid_stock_request.

    METHODS get_order_reservations_bulk
      IMPORTING
        it_sales_documents     TYPE zif_stock_repository=>ty_sales_order_documents
      RETURNING
        VALUE(rt_reservations) TYPE zif_stock_repository=>ty_sales_order_reservations
      RAISING
        zcx_invalid_stock_request.

    METHODS get_order_res_bulk_uom
      IMPORTING
        it_requests       TYPE ty_order_res_uom_requests
      RETURNING
        VALUE(rt_results) TYPE ty_order_res_uom_results
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_request
      IMPORTING
        iv_material              TYPE mard-matnr
        iv_plant                 TYPE mard-werks
        iv_requested_quantity    TYPE mard-labst
        iv_protect_safety_stock  TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_allocation)     TYPE ty_allocation
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_request_by_date
      IMPORTING
        iv_material                    TYPE mard-matnr
        iv_plant                       TYPE mard-werks
        iv_required_date               TYPE resb-bdter
        iv_requested_quantity          TYPE mard-labst
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_allocation)           TYPE ty_dated_allocation
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_demands_by_date
      IMPORTING
        it_demands                     TYPE ty_dated_demands
        it_excluded_reservations       TYPE zif_stock_repository=>ty_reservation_keys
          OPTIONAL
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)          TYPE ty_dated_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_date_demands_in_units
      IMPORTING
        it_demands                     TYPE ty_date_unit_demands
        it_excluded_reservations       TYPE zif_stock_repository=>ty_reservation_keys
          OPTIONAL
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)          TYPE ty_date_unit_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_date_demands_atp
      IMPORTING
        it_demands                     TYPE ty_date_unit_demands
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)          TYPE ty_date_unit_atp_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_request_date_atp
      IMPORTING
        iv_material                    TYPE mard-matnr
        iv_plant                       TYPE mard-werks
        iv_unit                        TYPE mara-meins
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_required_date               TYPE resb-bdter
        iv_requested_quantity          TYPE mard-labst
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_atp_allocation
      RAISING
        zcx_invalid_stock_request.

    METHODS check_atp_request
      IMPORTING
        is_request       TYPE zif_material_availability_api=>ty_request
      RETURNING
        VALUE(rs_result) TYPE zif_material_availability_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS get_atp_confirmation_split
      IMPORTING
        iv_requested_base_quantity TYPE mard-labst
        iv_numerator               TYPE marm-umrez DEFAULT 1
        iv_denominator             TYPE marm-umren DEFAULT 1
        iv_required_date           TYPE resb-bdter OPTIONAL
        is_atp_result              TYPE zif_material_availability_api=>ty_result
      RETURNING
        VALUE(rs_quantities)       TYPE ty_atp_confirmation_split
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_request_in_unit
      IMPORTING
        iv_material              TYPE mard-matnr
        iv_plant                 TYPE mard-werks
        iv_requested_quantity    TYPE mard-labst
        iv_requested_unit        TYPE mara-meins
        iv_protect_safety_stock  TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE ty_unit_allocation
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_demands_in_units
      IMPORTING
        it_demands               TYPE ty_unit_demands
        iv_protect_safety_stock  TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)    TYPE ty_unit_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_demands
      IMPORTING
        it_demands               TYPE ty_demands
        iv_protect_safety_stock  TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)    TYPE ty_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_across_plants
      IMPORTING
        it_demands                   TYPE ty_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_by_date
      IMPORTING
        it_demands                     TYPE ty_date_plant_demands
        it_sources                     TYPE ty_plant_sources
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_date_plant_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_date_units
      IMPORTING
        it_demands                     TYPE ty_unit_date_plant_demands
        it_sources                     TYPE ty_plant_sources
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_unit_date_plant_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_date_atp
      IMPORTING
        it_demands                     TYPE ty_unit_date_plant_demands
        it_sources                     TYPE ty_plant_sources
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_include_po_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_po_confirmations    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit      TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto        TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto       TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts       TYPE abap_bool DEFAULT abap_false
        iv_include_pr_receipts         TYPE abap_bool DEFAULT abap_false
        iv_include_sto_pr_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_planned_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_fixed_planned       TYPE abap_bool DEFAULT abap_false
        iv_include_sched_agmt_receipts TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_plant_date_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_atp
      IMPORTING
        it_demands                   TYPE ty_unit_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_check_rule                TYPE zif_material_availability_api=>ty_check_rule
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_atp_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_batch_atp
      IMPORTING
        it_demands                   TYPE ty_unit_plant_batch_demands
        it_sources                   TYPE ty_plant_sources
        iv_check_rule                TYPE zif_material_availability_api=>ty_check_rule
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_batch_atp_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_fefo_atp
      IMPORTING
        it_demands                   TYPE ty_unit_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_check_rule                TYPE zif_material_availability_api=>ty_check_rule
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_fefo_atp_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_by_expiry
      IMPORTING
        it_demands                   TYPE ty_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_fefo_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_fefo_by_date
      IMPORTING
        it_demands                   TYPE ty_date_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_date_plant_fefo_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_fefo_date_uom
      IMPORTING
        it_demands                   TYPE ty_unit_date_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_date_plant_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_fefo_date_atp
      IMPORTING
        it_demands                   TYPE ty_unit_date_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_check_rule                TYPE zif_material_availability_api=>ty_check_rule
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_fefo_date_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_by_batch
      IMPORTING
        it_demands                   TYPE ty_plant_batch_demands
        it_sources                   TYPE ty_plant_sources
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_batch_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_batch_by_date
      IMPORTING
        it_demands                   TYPE ty_date_plant_batch_demands
        it_sources                   TYPE ty_plant_sources
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_date_plant_batch_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_date_batch_uom
      IMPORTING
        it_demands                   TYPE ty_unit_date_plant_batch_demands
        it_sources                   TYPE ty_plant_sources
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_date_plant_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_date_batch_atp
      IMPORTING
        it_demands                   TYPE ty_unit_date_plant_batch_demands
        it_sources                   TYPE ty_plant_sources
        iv_check_rule                TYPE zif_material_availability_api=>ty_check_rule
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_plant_date_batch_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_batch_in_units
      IMPORTING
        it_demands                   TYPE ty_unit_plant_batch_demands
        it_sources                   TYPE ty_plant_sources
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_plant_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_in_units
      IMPORTING
        it_demands                   TYPE ty_unit_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_plant_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_fefo_in_units
      IMPORTING
        it_demands                   TYPE ty_unit_plant_demands
        it_sources                   TYPE ty_plant_sources
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_source_locations          TYPE ty_plant_source_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_plant_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_storage_location
      IMPORTING
        it_demands                   TYPE ty_demands
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_location_in_units
      IMPORTING
        it_demands                   TYPE ty_unit_location_demands
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_batch
      IMPORTING
        it_demands                   TYPE ty_batch_demands
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_batch_in_units
      IMPORTING
        it_demands                   TYPE ty_unit_batch_demands
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_expiry
      IMPORTING
        it_demands                   TYPE ty_fefo_demands
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_expiry_in_units
      IMPORTING
        it_demands                   TYPE ty_unit_fefo_demands
        it_storage_location_priority TYPE ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE ty_storage_locations OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_min_days                  TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_unit_batch_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_stock_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        remaining_quantity TYPE mard-labst,
      END OF ty_stock_balance.
    TYPES ty_stock_balances TYPE HASHED TABLE OF ty_stock_balance
      WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_dated_demand_index,
        source_index       TYPE i,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
      END OF ty_dated_demand_index.
    TYPES ty_dated_demand_indexes TYPE STANDARD TABLE OF
      ty_dated_demand_index WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_stock_cache,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        required_date      TYPE resb-bdter,
        available_quantity TYPE mard-labst,
      END OF ty_dated_stock_cache.
    TYPES ty_dated_stock_caches TYPE HASHED TABLE OF ty_dated_stock_cache
      WITH UNIQUE KEY material plant required_date.
    TYPES:
      BEGIN OF ty_dated_allocated_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        allocated_quantity TYPE mard-labst,
      END OF ty_dated_allocated_balance.
    TYPES ty_dated_allocated_balances TYPE HASHED TABLE OF
      ty_dated_allocated_balance WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_dated_atp_day,
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        base_unit           TYPE mara-meins,
        required_date       TYPE resb-bdter,
        demand_quantity     TYPE mard-labst,
        cumulative_quantity TYPE mard-labst,
        atp_result          TYPE zif_material_availability_api=>ty_result,
      END OF ty_dated_atp_day.
    TYPES ty_dated_atp_days TYPE SORTED TABLE OF ty_dated_atp_day
      WITH UNIQUE KEY material plant base_unit required_date.
    TYPES:
      BEGIN OF ty_indexed_dated_allocation,
        source_index TYPE i,
        allocation   TYPE ty_dated_allocation,
      END OF ty_indexed_dated_allocation.
    TYPES ty_indexed_dated_allocations TYPE STANDARD TABLE OF
      ty_indexed_dated_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_demand_idx,
        source_index       TYPE i,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        required_date      TYPE resb-bdter,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
      END OF ty_date_plant_demand_idx.
    TYPES ty_date_plant_demand_idxs TYPE STANDARD TABLE OF
      ty_date_plant_demand_idx WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_summary_idx,
        source_index TYPE i,
        allocation   TYPE ty_date_plant_demand_allocation,
      END OF ty_date_plant_summary_idx.
    TYPES ty_date_plant_summary_idxs TYPE STANDARD TABLE OF
      ty_date_plant_summary_idx WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_source_idx,
        source_index TYPE i,
        source_order TYPE i,
        allocation   TYPE ty_date_plant_source_allocation,
      END OF ty_date_plant_source_idx.
    TYPES ty_date_plant_source_idxs TYPE STANDARD TABLE OF
      ty_date_plant_source_idx WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_date_plant_fefo_batch_idx,
        source_index TYPE i,
        source_order TYPE i,
        batch_order  TYPE i,
        allocation   TYPE ty_date_plant_fefo_batch_allocation,
      END OF ty_date_plant_fefo_batch_idx.
    TYPES ty_date_plant_fefo_batch_idxs TYPE STANDARD TABLE OF
      ty_date_plant_fefo_batch_idx WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_demand_source_balance,
        source_plant       TYPE mard-werks,
        source_order       TYPE i,
        available_quantity TYPE mard-labst,
      END OF ty_demand_source_balance.
    TYPES ty_demand_source_balances TYPE STANDARD TABLE OF
      ty_demand_source_balance WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_safety_cache_row,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        safety_stock TYPE marc-eisbe,
      END OF ty_safety_cache_row.
    TYPES ty_safety_cache TYPE HASHED TABLE OF ty_safety_cache_row
      WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_plant_request_id,
        request_id TYPE c LENGTH 30,
      END OF ty_plant_request_id.
    TYPES ty_plant_request_ids TYPE HASHED TABLE OF ty_plant_request_id
      WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_plant_source_key,
        request_id   TYPE c LENGTH 30,
        source_plant TYPE mard-werks,
      END OF ty_plant_source_key.
    TYPES ty_plant_source_keys TYPE HASHED TABLE OF ty_plant_source_key
      WITH UNIQUE KEY request_id source_plant.
    TYPES:
      BEGIN OF ty_location_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        remaining_quantity TYPE mard-labst,
      END OF ty_location_balance.
    TYPES ty_location_balances TYPE SORTED TABLE OF ty_location_balance
      WITH UNIQUE KEY material plant storage_location.
    TYPES:
      BEGIN OF ty_batch_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        remaining_quantity TYPE mchb-clabs,
      END OF ty_batch_balance.
    TYPES ty_batch_balances TYPE SORTED TABLE OF ty_batch_balance
      WITH UNIQUE KEY material plant storage_location batch.
    TYPES:
      BEGIN OF ty_fefo_balance,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        storage_location     TYPE mard-lgort,
        location_priority    TYPE i,
        batch                TYPE mchb-charg,
        expiration_date      TYPE mcha-vfdat,
        sort_expiration_date TYPE d,
        remaining_quantity   TYPE mchb-clabs,
      END OF ty_fefo_balance.
    TYPES ty_fefo_balances TYPE STANDARD TABLE OF ty_fefo_balance
      WITH EMPTY KEY.
    TYPES ty_storage_location_set TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_loaded_stock_key,
        material TYPE mard-matnr,
        plant    TYPE mard-werks,
      END OF ty_loaded_stock_key.
    TYPES ty_loaded_stock_keys TYPE HASHED TABLE OF ty_loaded_stock_key
      WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_uom_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        result   TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_uom_cache.
    TYPES ty_uom_cache_table TYPE HASHED TABLE OF ty_uom_cache
      WITH UNIQUE KEY material unit.
    TYPES:
      BEGIN OF ty_plant_unit_context,
        request_id      TYPE c LENGTH 30,
        source_quantity TYPE mard-labst,
        source_unit     TYPE mara-meins,
        base_quantity   TYPE mard-labst,
        ratio           TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_plant_unit_context.
    TYPES ty_plant_unit_contexts TYPE STANDARD TABLE OF
      ty_plant_unit_context WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_allocation_context,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        source_quantity     TYPE mard-labst,
        source_unit         TYPE mara-meins,
        base_quantity       TYPE mard-labst,
        ratio               TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_unit_allocation_context.
    TYPES ty_unit_allocation_contexts TYPE HASHED TABLE OF
      ty_unit_allocation_context WITH UNIQUE KEY internal_request_id.

    DATA mo_stock_repository TYPE REF TO zif_stock_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
    DATA mo_material_availability_api TYPE REF TO
      zif_material_availability_api.

    METHODS convert_stock_quantity
      IMPORTING
        iv_base_quantity   TYPE mard-labst
        iv_numerator       TYPE marm-umrez
        iv_denominator     TYPE marm-umren
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst.

    METHODS get_stock_unit_ratio
      IMPORTING
        iv_material     TYPE mard-matnr
        iv_unit         TYPE mara-meins
      RETURNING
        VALUE(rs_ratio) TYPE zif_material_uom_converter=>ty_unit_ratio
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_location_order
      IMPORTING
        it_storage_location_priority TYPE ty_storage_locations
      RAISING
        zcx_invalid_stock_request.

    METHODS build_allowed_location_set
      IMPORTING
        it_allowed_storage_locations TYPE ty_storage_locations
      RETURNING
        VALUE(rt_locations)          TYPE ty_storage_location_set
      RAISING
        zcx_invalid_stock_request.

    METHODS build_source_location_set
      IMPORTING
        it_sources          TYPE ty_plant_sources
        it_source_locations TYPE ty_plant_source_locations
      RETURNING
        VALUE(rt_locations) TYPE ty_plant_source_location_set
      RAISING
        zcx_invalid_stock_request.

ENDCLASS.

CLASS zcl_stock_service IMPLEMENTATION.

  METHOD constructor.
    IF io_uom_converter IS BOUND.
      mo_uom_converter = io_uom_converter.
    ELSE.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.
    mo_stock_repository = io_stock_repository.
    IF io_material_availability_api IS BOUND.
      mo_material_availability_api = io_material_availability_api.
    ELSE.
      mo_material_availability_api =
        NEW zcl_bapi_mat_avail_api( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_projected_receipts.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_through_date IS INITIAL
        OR ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_include_prod_receipts <> abap_true
          AND iv_include_prod_receipts <> abap_false )
        OR ( iv_include_pr_receipts <> abap_true
          AND iv_include_pr_receipts <> abap_false )
        OR ( iv_include_sto_pr_receipts <> abap_true
          AND iv_include_sto_pr_receipts <> abap_false )
        OR ( iv_include_planned_receipts <> abap_true
          AND iv_include_planned_receipts <> abap_false )
        OR ( iv_include_fixed_planned <> abap_true
          AND iv_include_fixed_planned <> abap_false )
        OR ( iv_include_sched_agmt_receipts <> abap_true
          AND iv_include_sched_agmt_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_receipts = mo_stock_repository->get_projected_receipts(
      iv_material                    = iv_material
      iv_plant                       = iv_plant
      iv_through_date                = iv_through_date
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       =
        iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

    IF iv_include_po_confirmations = abap_true.
      DATA(lt_confirmation_receipts) = get_po_confirmed_receipts(
        iv_material     = iv_material
        iv_plant        = iv_plant
        iv_through_date = iv_through_date ).
      APPEND LINES OF lt_confirmation_receipts TO rt_receipts.
    ENDIF.
  ENDMETHOD.

  METHOD get_po_confirmed_receipts.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_through_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_receipts = mo_stock_repository->get_po_confirmed_receipts(
        iv_material     = iv_material
        iv_plant        = iv_plant
        iv_through_date = iv_through_date ).
  ENDMETHOD.

  METHOD get_po_conf_receipts_in_unit.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_through_date IS INITIAL
        OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_base_receipts) = get_po_confirmed_receipts(
      iv_material     = iv_material
      iv_plant        = iv_plant
      iv_through_date = iv_through_date ).

    LOOP AT lt_base_receipts INTO DATA(ls_base_receipt).
      DATA(ls_receipt_in_unit) =
        CORRESPONDING ty_projected_receipt_in_unit( ls_base_receipt ).
      ls_receipt_in_unit-base_unit = ls_ratio-base_unit.
      ls_receipt_in_unit-unit = iv_unit.
      ls_receipt_in_unit-quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_receipt-quantity
        iv_numerator     = ls_ratio-numerator
        iv_denominator   = ls_ratio-denominator ).
      APPEND ls_receipt_in_unit TO rt_receipts.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_po_conf_receipts_bulk.
    TYPES:
      BEGIN OF ty_receipt_cache,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        receipts     TYPE zif_stock_repository=>ty_projected_receipts,
      END OF ty_receipt_cache.
    TYPES ty_receipt_caches TYPE HASHED TABLE OF ty_receipt_cache
      WITH UNIQUE KEY material plant.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_receipt_caches TYPE ty_receipt_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA ls_result TYPE ty_projected_receipt_bulk_result.
    FIELD-SYMBOLS <ls_receipt_cache> TYPE ty_receipt_cache.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-through_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_receipt_caches ASSIGNING <ls_receipt_cache>
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          INTO TABLE lt_receipt_caches.
      ELSEIF <ls_receipt_cache>-through_date < ls_request-through_date.
        <ls_receipt_cache>-through_date = ls_request-through_date.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_receipt_caches ASSIGNING <ls_receipt_cache>.
      <ls_receipt_cache>-receipts = get_po_confirmed_receipts(
        iv_material     = <ls_receipt_cache>-material
        iv_plant        = <ls_receipt_cache>-plant
        iv_through_date = <ls_receipt_cache>-through_date ).
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_receipt_caches INTO DATA(ls_receipt_cache)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      LOOP AT ls_receipt_cache-receipts INTO DATA(ls_receipt).
        IF ls_receipt-receipt_date <= ls_request-through_date.
          APPEND ls_receipt TO ls_result-receipts.
        ENDIF.
      ENDLOOP.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_po_conf_receipts_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_caches TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_base_requests TYPE ty_projected_receipt_requests.
    DATA lt_base_results TYPE ty_projected_receipt_bulk_results.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_proj_receipt_uom_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-through_date IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date )
        TO lt_base_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_caches INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio )
          INTO TABLE lt_ratio_caches.
      ENDIF.
    ENDLOOP.

    lt_base_results = get_po_conf_receipts_bulk(
      it_requests = lt_base_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_results INTO DATA(ls_base_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_base_result-material <> ls_request-material
          OR ls_base_result-plant <> ls_request-plant
          OR ls_base_result-through_date <> ls_request-through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_caches INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT ls_base_result-receipts INTO DATA(ls_base_receipt).
        DATA(ls_receipt_in_unit) =
          CORRESPONDING ty_projected_receipt_in_unit( ls_base_receipt ).
        ls_receipt_in_unit-base_unit = ls_result-base_unit.
        ls_receipt_in_unit-unit = ls_request-unit.
        ls_receipt_in_unit-quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_receipt-quantity
          iv_numerator     = ls_ratio_cache-ratio-numerator
          iv_denominator   = ls_ratio_cache-ratio-denominator ).
        APPEND ls_receipt_in_unit TO ls_result-receipts.
      ENDLOOP.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_projected_receipts_in_unit.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_through_date IS INITIAL
        OR iv_unit IS INITIAL
        OR ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_include_prod_receipts <> abap_true
          AND iv_include_prod_receipts <> abap_false )
        OR ( iv_include_pr_receipts <> abap_true
          AND iv_include_pr_receipts <> abap_false )
        OR ( iv_include_sto_pr_receipts <> abap_true
          AND iv_include_sto_pr_receipts <> abap_false )
        OR ( iv_include_planned_receipts <> abap_true
          AND iv_include_planned_receipts <> abap_false )
        OR ( iv_include_fixed_planned <> abap_true
          AND iv_include_fixed_planned <> abap_false )
        OR ( iv_include_sched_agmt_receipts <> abap_true
          AND iv_include_sched_agmt_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_base_receipts) = get_projected_receipts(
      iv_material                    = iv_material
      iv_plant                       = iv_plant
      iv_through_date                = iv_through_date
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       = iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

    LOOP AT lt_base_receipts INTO DATA(ls_base_receipt).
      DATA(ls_receipt_in_unit) =
        CORRESPONDING ty_projected_receipt_in_unit( ls_base_receipt ).
      ls_receipt_in_unit-base_unit = ls_ratio-base_unit.
      ls_receipt_in_unit-unit = iv_unit.
      ls_receipt_in_unit-quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_receipt-quantity
        iv_numerator     = ls_ratio-numerator
        iv_denominator   = ls_ratio-denominator ).
      APPEND ls_receipt_in_unit TO rt_receipts.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_projected_receipts_bulk.
    TYPES:
      BEGIN OF ty_projection_cache,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
        receipts     TYPE zif_stock_repository=>ty_projected_receipts,
      END OF ty_projection_cache.
    TYPES ty_projection_caches TYPE HASHED TABLE OF ty_projection_cache
      WITH UNIQUE KEY material plant.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_projection_cache TYPE ty_projection_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA ls_result TYPE ty_projected_receipt_bulk_result.
    FIELD-SYMBOLS <ls_projection_cache> TYPE ty_projection_cache.

    IF ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_include_prod_receipts <> abap_true
          AND iv_include_prod_receipts <> abap_false )
        OR ( iv_include_pr_receipts <> abap_true
          AND iv_include_pr_receipts <> abap_false )
        OR ( iv_include_sto_pr_receipts <> abap_true
          AND iv_include_sto_pr_receipts <> abap_false )
        OR ( iv_include_planned_receipts <> abap_true
          AND iv_include_planned_receipts <> abap_false )
        OR ( iv_include_fixed_planned <> abap_true
          AND iv_include_fixed_planned <> abap_false )
        OR ( iv_include_sched_agmt_receipts <> abap_true
          AND iv_include_sched_agmt_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-through_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_projection_cache ASSIGNING <ls_projection_cache>
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          INTO TABLE lt_projection_cache.
      ELSEIF <ls_projection_cache>-through_date < ls_request-through_date.
        <ls_projection_cache>-through_date = ls_request-through_date.
      ENDIF.
    ENDLOOP.

    IF iv_include_po_receipts = abap_false
        AND iv_include_po_confirmations = abap_false
        AND iv_include_sto_in_transit = abap_false
        AND iv_include_unissued_sto = abap_false
        AND iv_include_prod_receipts = abap_false
        AND iv_include_pr_receipts = abap_false
        AND iv_include_sto_pr_receipts = abap_false
        AND iv_include_planned_receipts = abap_false
        AND iv_include_fixed_planned = abap_false
        AND iv_include_sched_agmt_receipts = abap_false.
      LOOP AT it_requests INTO ls_request.
        APPEND VALUE #(
          request_id   = ls_request-request_id
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          TO rt_results.
      ENDLOOP.
      RETURN.
    ENDIF.

    LOOP AT lt_projection_cache ASSIGNING <ls_projection_cache>.
      <ls_projection_cache>-receipts = get_projected_receipts(
        iv_material                    = <ls_projection_cache>-material
        iv_plant                       = <ls_projection_cache>-plant
        iv_through_date                = <ls_projection_cache>-through_date
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_po_confirmations    = iv_include_po_confirmations
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       = iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_projection_cache INTO DATA(ls_projection_cache)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      LOOP AT ls_projection_cache-receipts INTO DATA(ls_receipt).
        IF ls_receipt-receipt_date <= ls_request-through_date.
          APPEND ls_receipt TO ls_result-receipts.
        ENDIF.
      ENDLOOP.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_proj_receipts_opts_bulk.
    TYPES:
      BEGIN OF ty_projection_cache,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        through_date          TYPE d,
        source_options        TYPE ty_projected_receipt_source_options,
        receipts              TYPE zif_stock_repository=>ty_projected_receipts,
        confirmation_receipts TYPE zif_stock_repository=>ty_projected_receipts,
      END OF ty_projection_cache.
    TYPES ty_projection_caches TYPE HASHED TABLE OF ty_projection_cache
      WITH UNIQUE KEY material plant.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_projection_cache TYPE ty_projection_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA ls_result TYPE ty_projected_receipt_bulk_result.
    DATA lv_any_source_enabled TYPE abap_bool.
    DATA lv_include_receipt TYPE abap_bool.
    FIELD-SYMBOLS <ls_projection_cache> TYPE ty_projection_cache.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-through_date IS INITIAL
          OR ( ls_request-options-include_po_receipts <> abap_true
            AND ls_request-options-include_po_receipts <> abap_false )
          OR ( ls_request-options-include_po_confirmations <> abap_true
            AND ls_request-options-include_po_confirmations <> abap_false )
          OR ( ls_request-options-include_po_receipts = abap_true
            AND ls_request-options-include_po_confirmations = abap_true )
          OR ( ls_request-options-include_sto_in_transit <> abap_true
            AND ls_request-options-include_sto_in_transit <> abap_false )
          OR ( ls_request-options-include_unissued_sto <> abap_true
            AND ls_request-options-include_unissued_sto <> abap_false )
          OR ( ls_request-options-include_prod_receipts <> abap_true
            AND ls_request-options-include_prod_receipts <> abap_false )
          OR ( ls_request-options-include_pr_receipts <> abap_true
            AND ls_request-options-include_pr_receipts <> abap_false )
          OR ( ls_request-options-include_sto_pr_receipts <> abap_true
            AND ls_request-options-include_sto_pr_receipts <> abap_false )
          OR ( ls_request-options-include_planned_receipts <> abap_true
            AND ls_request-options-include_planned_receipts <> abap_false )
          OR ( ls_request-options-include_fixed_planned <> abap_true
            AND ls_request-options-include_fixed_planned <> abap_false )
          OR ( ls_request-options-include_sched_agmt_receipts <> abap_true
            AND ls_request-options-include_sched_agmt_receipts <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF ls_request-options-include_po_receipts = abap_true
          OR ls_request-options-include_po_confirmations = abap_true
          OR ls_request-options-include_sto_in_transit = abap_true
          OR ls_request-options-include_unissued_sto = abap_true
          OR ls_request-options-include_prod_receipts = abap_true
          OR ls_request-options-include_pr_receipts = abap_true
          OR ls_request-options-include_sto_pr_receipts = abap_true
          OR ls_request-options-include_planned_receipts = abap_true
          OR ls_request-options-include_fixed_planned = abap_true
          OR ls_request-options-include_sched_agmt_receipts = abap_true.
        lv_any_source_enabled = abap_true.
      ENDIF.

      READ TABLE lt_projection_cache ASSIGNING <ls_projection_cache>
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          INTO TABLE lt_projection_cache.
        READ TABLE lt_projection_cache ASSIGNING <ls_projection_cache>
          WITH TABLE KEY material = ls_request-material
                         plant = ls_request-plant.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ELSEIF <ls_projection_cache>-through_date < ls_request-through_date.
        <ls_projection_cache>-through_date = ls_request-through_date.
      ENDIF.

      IF ls_request-options-include_po_receipts = abap_true.
        <ls_projection_cache>-source_options-include_po_receipts = abap_true.
      ENDIF.
      IF ls_request-options-include_po_confirmations = abap_true.
        <ls_projection_cache>-source_options-include_po_confirmations =
          abap_true.
      ENDIF.
      IF ls_request-options-include_sto_in_transit = abap_true.
        <ls_projection_cache>-source_options-include_sto_in_transit =
          abap_true.
      ENDIF.
      IF ls_request-options-include_unissued_sto = abap_true.
        <ls_projection_cache>-source_options-include_unissued_sto =
          abap_true.
      ENDIF.
      IF ls_request-options-include_prod_receipts = abap_true.
        <ls_projection_cache>-source_options-include_prod_receipts =
          abap_true.
      ENDIF.
      IF ls_request-options-include_pr_receipts = abap_true.
        <ls_projection_cache>-source_options-include_pr_receipts = abap_true.
      ENDIF.
      IF ls_request-options-include_sto_pr_receipts = abap_true.
        <ls_projection_cache>-source_options-include_sto_pr_receipts =
          abap_true.
      ENDIF.
      IF ls_request-options-include_planned_receipts = abap_true.
        <ls_projection_cache>-source_options-include_planned_receipts =
          abap_true.
      ENDIF.
      IF ls_request-options-include_fixed_planned = abap_true.
        <ls_projection_cache>-source_options-include_fixed_planned =
          abap_true.
      ENDIF.
      IF ls_request-options-include_sched_agmt_receipts = abap_true.
        <ls_projection_cache>-source_options-include_sched_agmt_receipts =
          abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_any_source_enabled <> abap_true.
      LOOP AT it_requests INTO ls_request.
        APPEND VALUE #(
          request_id   = ls_request-request_id
          material     = ls_request-material
          plant        = ls_request-plant
          through_date = ls_request-through_date )
          TO rt_results.
      ENDLOOP.
      RETURN.
    ENDIF.

    LOOP AT lt_projection_cache ASSIGNING <ls_projection_cache>.
      IF <ls_projection_cache>-source_options-include_po_confirmations =
          abap_true.
        <ls_projection_cache>-confirmation_receipts =
          get_po_confirmed_receipts(
            iv_material     = <ls_projection_cache>-material
            iv_plant        = <ls_projection_cache>-plant
            iv_through_date = <ls_projection_cache>-through_date ).
      ENDIF.
      IF <ls_projection_cache>-source_options-include_po_receipts =
          abap_false
          AND <ls_projection_cache>-source_options-include_sto_in_transit =
          abap_false
          AND <ls_projection_cache>-source_options-include_unissued_sto =
          abap_false
          AND <ls_projection_cache>-source_options-include_prod_receipts =
          abap_false
          AND <ls_projection_cache>-source_options-include_pr_receipts =
          abap_false
          AND <ls_projection_cache>-source_options-include_sto_pr_receipts =
          abap_false
          AND <ls_projection_cache>-source_options-include_planned_receipts =
          abap_false
          AND <ls_projection_cache>-source_options-include_fixed_planned =
          abap_false
          AND <ls_projection_cache>-source_options-include_sched_agmt_receipts =
          abap_false.
        CONTINUE.
      ENDIF.
      <ls_projection_cache>-receipts = get_projected_receipts(
        iv_material                    = <ls_projection_cache>-material
        iv_plant                       = <ls_projection_cache>-plant
        iv_through_date                = <ls_projection_cache>-through_date
        iv_include_po_receipts         =
          <ls_projection_cache>-source_options-include_po_receipts
        iv_include_sto_in_transit      =
          <ls_projection_cache>-source_options-include_sto_in_transit
        iv_include_unissued_sto        =
          <ls_projection_cache>-source_options-include_unissued_sto
        iv_include_prod_receipts       =
          <ls_projection_cache>-source_options-include_prod_receipts
        iv_include_pr_receipts         =
          <ls_projection_cache>-source_options-include_pr_receipts
        iv_include_sto_pr_receipts     =
          <ls_projection_cache>-source_options-include_sto_pr_receipts
        iv_include_planned_receipts    =
          <ls_projection_cache>-source_options-include_planned_receipts
        iv_include_fixed_planned       =
          <ls_projection_cache>-source_options-include_fixed_planned
        iv_include_sched_agmt_receipts =
          <ls_projection_cache>-source_options-include_sched_agmt_receipts ).
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_projection_cache INTO DATA(ls_projection_cache)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      LOOP AT ls_projection_cache-receipts INTO DATA(ls_receipt).
        IF ls_receipt-receipt_date > ls_request-through_date.
          CONTINUE.
        ENDIF.
        CLEAR lv_include_receipt.
        CASE ls_receipt-source_type.
          WHEN 'PO'.
            lv_include_receipt = ls_request-options-include_po_receipts.
          WHEN 'PO_CONFIRMATION'.
            lv_include_receipt =
              ls_request-options-include_po_confirmations.
          WHEN 'STO_IN_TRANSIT'.
            lv_include_receipt =
              ls_request-options-include_sto_in_transit.
          WHEN 'STO_UNISSUED'.
            lv_include_receipt = ls_request-options-include_unissued_sto.
          WHEN 'PRODUCTION' OR 'PROCESS_ORDER'.
            lv_include_receipt = ls_request-options-include_prod_receipts.
          WHEN 'PR'.
            lv_include_receipt = ls_request-options-include_pr_receipts.
          WHEN 'STO_PR'.
            lv_include_receipt = ls_request-options-include_sto_pr_receipts.
          WHEN 'PLANNED_ORDER'.
            lv_include_receipt = ls_request-options-include_planned_receipts.
          WHEN 'FIXED_PLAN_ORDER'.
            lv_include_receipt = ls_request-options-include_fixed_planned.
          WHEN 'SCHED_AGREEMENT'.
            lv_include_receipt =
              ls_request-options-include_sched_agmt_receipts.
        ENDCASE.
        IF lv_include_receipt = abap_true.
          APPEND ls_receipt TO ls_result-receipts.
        ENDIF.
      ENDLOOP.
      IF ls_request-options-include_po_confirmations = abap_true.
        LOOP AT ls_projection_cache-confirmation_receipts
            INTO DATA(ls_confirmation_receipt).
          IF ls_confirmation_receipt-receipt_date <=
              ls_request-through_date.
            APPEND ls_confirmation_receipt TO ls_result-receipts.
          ENDIF.
        ENDLOOP.
      ENDIF.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_proj_receipts_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_base_requests TYPE ty_projected_receipt_requests.
    DATA lt_base_results TYPE ty_projected_receipt_bulk_results.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_proj_receipt_uom_result.

    IF ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_include_prod_receipts <> abap_true
          AND iv_include_prod_receipts <> abap_false )
        OR ( iv_include_pr_receipts <> abap_true
          AND iv_include_pr_receipts <> abap_false )
        OR ( iv_include_sto_pr_receipts <> abap_true
          AND iv_include_sto_pr_receipts <> abap_false )
        OR ( iv_include_planned_receipts <> abap_true
          AND iv_include_planned_receipts <> abap_false )
        OR ( iv_include_fixed_planned <> abap_true
          AND iv_include_fixed_planned <> abap_false )
        OR ( iv_include_sched_agmt_receipts <> abap_true
          AND iv_include_sched_agmt_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-through_date IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date )
        TO lt_base_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    lt_base_results = get_projected_receipts_bulk(
      it_requests                    = lt_base_requests
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       = iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_results INTO DATA(ls_base_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_base_result-material <> ls_request-material
          OR ls_base_result-plant <> ls_request-plant
          OR ls_base_result-through_date <> ls_request-through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT ls_base_result-receipts INTO DATA(ls_base_receipt).
        DATA(ls_receipt_in_unit) =
          CORRESPONDING ty_projected_receipt_in_unit( ls_base_receipt ).
        ls_receipt_in_unit-base_unit = ls_ratio_cache-ratio-base_unit.
        ls_receipt_in_unit-unit = ls_request-unit.
        ls_receipt_in_unit-quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_receipt-quantity
          iv_numerator     = ls_ratio_cache-ratio-numerator
          iv_denominator   = ls_ratio_cache-ratio-denominator ).
        APPEND ls_receipt_in_unit TO ls_result-receipts.
      ENDLOOP.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_proj_receipts_opts_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_base_requests TYPE ty_projected_receipt_option_requests.
    DATA lt_base_results TYPE ty_projected_receipt_bulk_results.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_proj_receipt_uom_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-through_date IS INITIAL
          OR ls_request-unit IS INITIAL
          OR ( ls_request-options-include_po_receipts <> abap_true
            AND ls_request-options-include_po_receipts <> abap_false )
          OR ( ls_request-options-include_po_confirmations <> abap_true
            AND ls_request-options-include_po_confirmations <> abap_false )
          OR ( ls_request-options-include_po_receipts = abap_true
            AND ls_request-options-include_po_confirmations = abap_true )
          OR ( ls_request-options-include_sto_in_transit <> abap_true
            AND ls_request-options-include_sto_in_transit <> abap_false )
          OR ( ls_request-options-include_unissued_sto <> abap_true
            AND ls_request-options-include_unissued_sto <> abap_false )
          OR ( ls_request-options-include_prod_receipts <> abap_true
            AND ls_request-options-include_prod_receipts <> abap_false )
          OR ( ls_request-options-include_pr_receipts <> abap_true
            AND ls_request-options-include_pr_receipts <> abap_false )
          OR ( ls_request-options-include_sto_pr_receipts <> abap_true
            AND ls_request-options-include_sto_pr_receipts <> abap_false )
          OR ( ls_request-options-include_planned_receipts <> abap_true
            AND ls_request-options-include_planned_receipts <> abap_false )
          OR ( ls_request-options-include_fixed_planned <> abap_true
            AND ls_request-options-include_fixed_planned <> abap_false )
          OR ( ls_request-options-include_sched_agmt_receipts <> abap_true
            AND ls_request-options-include_sched_agmt_receipts <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        through_date = ls_request-through_date
        options      = ls_request-options )
        TO lt_base_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    lt_base_results = get_proj_receipts_opts_bulk(
      it_requests = lt_base_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_results INTO DATA(ls_base_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_base_result-material <> ls_request-material
          OR ls_base_result-plant <> ls_request-plant
          OR ls_base_result-through_date <> ls_request-through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-through_date = ls_request-through_date.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT ls_base_result-receipts INTO DATA(ls_base_receipt).
        DATA(ls_receipt_in_unit) =
          CORRESPONDING ty_projected_receipt_in_unit( ls_base_receipt ).
        ls_receipt_in_unit-base_unit = ls_ratio_cache-ratio-base_unit.
        ls_receipt_in_unit-unit = ls_request-unit.
        ls_receipt_in_unit-quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_receipt-quantity
          iv_numerator     = ls_ratio_cache-ratio-numerator
          iv_denominator   = ls_ratio_cache-ratio-denominator ).
        APPEND ls_receipt_in_unit TO ls_result-receipts.
      ENDLOOP.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_unrestricted_stock.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rv_quantity = mo_stock_repository->get_unrestricted_stock(
      iv_material = iv_material
      iv_plant    = iv_plant ).
    IF iv_protect_safety_stock = abap_true.
      DATA(lv_safety_stock) = mo_stock_repository->get_safety_stock(
        iv_material = iv_material
        iv_plant    = iv_plant ).
      rv_quantity = NEW zcl_stock_avail_qty_calc( )->calculate_with_safety_stock(
        iv_available_quantity    = rv_quantity
        iv_safety_stock_quantity = lv_safety_stock ).
    ENDIF.
  ENDMETHOD.

  METHOD get_stock_status.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_status = mo_stock_repository->get_stock_status(
      iv_material = iv_material
      iv_plant    = iv_plant ).
  ENDMETHOD.

  METHOD get_stock_status_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_repository_status) =
      mo_stock_repository->get_stock_status_bulk(
        it_requests = it_requests ).
    IF lines( lt_repository_status ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_repository_status INTO DATA(ls_repository_status)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_repository_status-material <> ls_request-material
          OR ls_repository_status-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id   = ls_request-request_id
        material     = ls_request-material
        plant        = ls_request-plant
        stock_status = ls_repository_status-stock_status )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_status_in_unit.
    IF iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).

    DATA(ls_base_status) = mo_stock_repository->get_stock_status(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    rs_status-material = iv_material.
    rs_status-plant = iv_plant.
    rs_status-base_unit = ls_ratio-base_unit.
    rs_status-unit = iv_unit.
    rs_status-unrestricted_quantity = convert_stock_quantity(
      iv_base_quantity = ls_base_status-unrestricted_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_status-reserved_quantity = convert_stock_quantity(
      iv_base_quantity = ls_base_status-reserved_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_status-available_unrestricted_qty = convert_stock_quantity(
      iv_base_quantity = ls_base_status-available_unrestricted_qty
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_status-safety_stock_quantity = convert_stock_quantity(
      iv_base_quantity = ls_base_status-safety_stock_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_status-available_after_safety_qty = convert_stock_quantity(
      iv_base_quantity = ls_base_status-available_after_safety_qty
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_status-quality_inspection_quantity = convert_stock_quantity(
      iv_base_quantity = ls_base_status-quality_inspection_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
    rs_status-blocked_quantity = convert_stock_quantity(
      iv_base_quantity = ls_base_status-blocked_quantity
      iv_numerator     = ls_ratio-numerator
      iv_denominator   = ls_ratio-denominator ).
  ENDMETHOD.

  METHOD get_stock_status_bulk_in_unit.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_stock_requests TYPE ty_stock_status_requests.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_stock_status_unit_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO lt_stock_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    DATA(lt_base_statuses) = get_stock_status_bulk(
      it_requests = lt_stock_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_statuses INTO DATA(ls_base_status_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_base_status_result-material <> ls_request-material
          OR ls_base_status_result-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-status-material = ls_request-material.
      ls_result-status-plant = ls_request-plant.
      ls_result-status-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-status-unit = ls_request-unit.
      ls_result-status-unrestricted_quantity = convert_stock_quantity(
        iv_base_quantity =
          ls_base_status_result-stock_status-unrestricted_quantity
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      ls_result-status-reserved_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_status_result-stock_status-reserved_quantity
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      ls_result-status-available_unrestricted_qty = convert_stock_quantity(
        iv_base_quantity =
          ls_base_status_result-stock_status-available_unrestricted_qty
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      ls_result-status-safety_stock_quantity = convert_stock_quantity(
        iv_base_quantity =
          ls_base_status_result-stock_status-safety_stock_quantity
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      ls_result-status-available_after_safety_qty = convert_stock_quantity(
        iv_base_quantity =
          ls_base_status_result-stock_status-available_after_safety_qty
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      ls_result-status-quality_inspection_quantity = convert_stock_quantity(
        iv_base_quantity =
          ls_base_status_result-stock_status-quality_inspection_quantity
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      ls_result-status-blocked_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_status_result-stock_status-blocked_quantity
        iv_numerator     = ls_ratio_cache-ratio-numerator
        iv_denominator   = ls_ratio_cache-ratio-denominator ).
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_by_location_in_unit.
    IF iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_base_status) = mo_stock_repository->get_stock_status_by_location(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_base_status INTO DATA(ls_base_status).
      APPEND VALUE #(
        material                    = iv_material
        plant                       = iv_plant
        storage_location            = ls_base_status-storage_location
        base_unit                   = ls_ratio-base_unit
        unit                        = iv_unit
        unrestricted_quantity       = convert_stock_quantity(
          iv_base_quantity = ls_base_status-unrestricted_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator )
        available_unrestricted_qty  = convert_stock_quantity(
          iv_base_quantity = ls_base_status-available_unrestricted_qty
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator )
        quality_inspection_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_status-quality_inspection_qty
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator )
        blocked_quantity            = convert_stock_quantity(
          iv_base_quantity = ls_base_status-blocked_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator ) )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_by_batch_in_unit.
    IF iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_base_status) = mo_stock_repository->get_stock_status_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    LOOP AT lt_base_status INTO DATA(ls_base_status).
      APPEND VALUE #(
        material              = iv_material
        plant                 = iv_plant
        storage_location      = ls_base_status-storage_location
        batch                 = ls_base_status-batch
        expiration_date       = ls_base_status-expiration_date
        base_unit             = ls_ratio-base_unit
        unit                  = iv_unit
        unrestricted_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_status-unrestricted_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator )
        available_quantity    = convert_stock_quantity(
          iv_base_quantity = ls_base_status-available_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator ) )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_fefo_batch_status_in_unit.
    IF iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lt_base_status) = get_fefo_batch_status(
      iv_material   = iv_material
      iv_plant      = iv_plant
      iv_as_of_date = iv_as_of_date
      iv_min_days   = iv_min_days ).

    LOOP AT lt_base_status INTO DATA(ls_base_status).
      APPEND VALUE #(
        material              = iv_material
        plant                 = iv_plant
        storage_location      = ls_base_status-storage_location
        batch                 = ls_base_status-batch
        expiration_date       = ls_base_status-expiration_date
        base_unit             = ls_ratio-base_unit
        unit                  = iv_unit
        unrestricted_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_status-unrestricted_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator )
        available_quantity    = convert_stock_quantity(
          iv_base_quantity = ls_base_status-available_quantity
          iv_numerator     = ls_ratio-numerator
          iv_denominator   = ls_ratio-denominator ) )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_unit_ratio.
    IF iv_material IS INITIAL OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_ratio = mo_uom_converter->get_material_unit_ratio(
      iv_material         = iv_material
      iv_alternative_unit = iv_unit ).
    IF rs_ratio-is_successful <> abap_true
        OR rs_ratio-base_unit IS INITIAL
        OR rs_ratio-numerator <= 0
        OR rs_ratio-denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD get_atp_confirmation_split.
    DATA lv_requested_source_quantity TYPE decfloat34.
    DATA lv_source_confirmed_quantity TYPE decfloat34.
    DATA lv_confirmed_base_quantity TYPE decfloat34.

    IF iv_requested_base_quantity < 0
        OR iv_numerator <= 0
        OR iv_denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_requested_base_quantity = 0
        OR is_atp_result-is_check_relevant <> abap_true.
      RETURN.
    ENDIF.

    IF is_atp_result-is_fully_available = abap_true.
      rs_quantities-confirmed_base_quantity = iv_requested_base_quantity.
    ELSEIF is_atp_result-confirmation_lines IS NOT INITIAL.
      lv_requested_source_quantity =
        CONV decfloat34( iv_requested_base_quantity )
        * CONV decfloat34( iv_denominator )
        / CONV decfloat34( iv_numerator ).
      LOOP AT is_atp_result-confirmation_lines
          ASSIGNING FIELD-SYMBOL(<ls_confirmation_line>).
        IF <ls_confirmation_line>-confirmed_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF iv_required_date IS NOT INITIAL
            AND ( <ls_confirmation_line>-confirmed_date IS INITIAL
              OR <ls_confirmation_line>-confirmed_date >
                iv_required_date ).
          CONTINUE.
        ENDIF.

        lv_source_confirmed_quantity += CONV decfloat34(
          <ls_confirmation_line>-confirmed_quantity ).
        IF lv_source_confirmed_quantity >= lv_requested_source_quantity.
          lv_source_confirmed_quantity = lv_requested_source_quantity.
          EXIT.
        ENDIF.
      ENDLOOP.
      lv_confirmed_base_quantity =
        lv_source_confirmed_quantity
        * CONV decfloat34( iv_numerator )
        / CONV decfloat34( iv_denominator ).
      IF lv_confirmed_base_quantity >
          CONV decfloat34( iv_requested_base_quantity ).
        lv_confirmed_base_quantity =
          CONV decfloat34( iv_requested_base_quantity ).
      ENDIF.
      rs_quantities-confirmed_base_quantity = CONV mard-labst(
        lv_confirmed_base_quantity ).
    ELSEIF is_atp_result-confirmed_quantity > 0.
      IF iv_required_date IS NOT INITIAL
          AND ( is_atp_result-confirmed_date IS INITIAL
            OR is_atp_result-confirmed_date > iv_required_date ).
        rs_quantities-unconfirmed_base_quantity =
          iv_requested_base_quantity.
        RETURN.
      ENDIF.
      lv_confirmed_base_quantity =
        CONV decfloat34( is_atp_result-confirmed_quantity )
        * CONV decfloat34( iv_numerator )
        / CONV decfloat34( iv_denominator ).
      IF lv_confirmed_base_quantity >
          CONV decfloat34( iv_requested_base_quantity ).
        lv_confirmed_base_quantity =
          CONV decfloat34( iv_requested_base_quantity ).
      ENDIF.
      rs_quantities-confirmed_base_quantity = CONV mard-labst(
        lv_confirmed_base_quantity ).
    ENDIF.

    rs_quantities-unconfirmed_base_quantity =
      iv_requested_base_quantity - rs_quantities-confirmed_base_quantity.
  ENDMETHOD.

  METHOD convert_stock_quantity.
    rv_quantity = CONV mard-labst(
      CONV decfloat34( iv_base_quantity )
      * CONV decfloat34( iv_denominator )
      / CONV decfloat34( iv_numerator ) ).
  ENDMETHOD.

  METHOD get_stock_status_by_location.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_status = mo_stock_repository->get_stock_status_by_location(
      iv_material = iv_material
      iv_plant    = iv_plant ).
  ENDMETHOD.

  METHOD get_location_stock_status_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_repository_status) =
      mo_stock_repository->get_location_stock_status_bulk(
        it_requests = it_requests ).
    IF lines( lt_repository_status ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_repository_status INTO DATA(ls_repository_status)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_repository_status-material <> ls_request-material
          OR ls_repository_status-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        locations  = ls_repository_status-locations )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_location_stock_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_stock_requests TYPE ty_stock_status_requests.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_location_stock_uom_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO lt_stock_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    DATA(lt_base_statuses) = get_location_stock_status_bulk(
      it_requests = lt_stock_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_statuses INTO DATA(ls_base_status_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_base_status_result-material <> ls_request-material
          OR ls_base_status_result-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT ls_base_status_result-locations INTO DATA(ls_base_location).
        APPEND VALUE #(
          material                    = ls_request-material
          plant                       = ls_request-plant
          storage_location            = ls_base_location-storage_location
          base_unit                   = ls_ratio_cache-ratio-base_unit
          unit                        = ls_request-unit
          unrestricted_quantity       = convert_stock_quantity(
            iv_base_quantity = ls_base_location-unrestricted_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator )
          available_unrestricted_qty  = convert_stock_quantity(
            iv_base_quantity = ls_base_location-available_unrestricted_qty
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator )
          quality_inspection_quantity = convert_stock_quantity(
            iv_base_quantity = ls_base_location-quality_inspection_qty
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator )
          blocked_quantity            = convert_stock_quantity(
            iv_base_quantity = ls_base_location-blocked_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator ) )
          TO ls_result-locations.
      ENDLOOP.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_stock_status_by_batch.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_status = mo_stock_repository->get_stock_status_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).
  ENDMETHOD.

  METHOD get_batch_stock_status_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_repository_status) =
      mo_stock_repository->get_batch_stock_status_bulk(
        it_requests = it_requests ).
    IF lines( lt_repository_status ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_repository_status INTO DATA(ls_repository_status)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_repository_status-material <> ls_request-material
          OR ls_repository_status-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        batches    = ls_repository_status-batches )
        TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_batch_stock_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_stock_requests TYPE ty_stock_status_requests.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_batch_stock_uom_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO lt_stock_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    DATA(lt_base_statuses) = get_batch_stock_status_bulk(
      it_requests = lt_stock_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_statuses INTO DATA(ls_base_status)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_base_status-material <> ls_request-material
          OR ls_base_status-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT ls_base_status-batches INTO DATA(ls_batch_status).
        APPEND VALUE #(
          material              = ls_request-material
          plant                 = ls_request-plant
          storage_location      = ls_batch_status-storage_location
          batch                 = ls_batch_status-batch
          expiration_date       = ls_batch_status-expiration_date
          base_unit             = ls_ratio_cache-ratio-base_unit
          unit                  = ls_request-unit
          unrestricted_quantity = convert_stock_quantity(
            iv_base_quantity = ls_batch_status-unrestricted_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator )
          available_quantity    = convert_stock_quantity(
            iv_base_quantity = ls_batch_status-available_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator ) )
          TO ls_result-batches.
      ENDLOOP.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_fefo_batch_status.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_as_of_date IS INITIAL
        OR iv_min_days < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lt_batch_status) = mo_stock_repository->get_stock_status_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).
    DATA(lo_eligibility) = NEW zcl_stock_batch_eligibility( ).
    DATA lt_dated_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    DATA lt_undated_status TYPE zif_stock_repository=>ty_batch_stock_statuses.

    LOOP AT lt_batch_status INTO DATA(ls_batch_status).
      IF lo_eligibility->is_eligible(
          iv_expiration_date = ls_batch_status-expiration_date
          iv_as_of_date      = iv_as_of_date
          iv_min_days        = iv_min_days ) = abap_true.
        IF ls_batch_status-expiration_date IS INITIAL.
          APPEND ls_batch_status TO lt_undated_status.
        ELSE.
          APPEND ls_batch_status TO lt_dated_status.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SORT lt_dated_status BY expiration_date batch storage_location.
    SORT lt_undated_status BY batch storage_location.
    APPEND LINES OF lt_dated_status TO rt_status.
    APPEND LINES OF lt_undated_status TO rt_status.
  ENDMETHOD.

  METHOD get_fefo_batch_status_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_stock_requests TYPE ty_stock_status_requests.
    DATA lt_dated_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    DATA lt_undated_status TYPE zif_stock_repository=>ty_batch_stock_statuses.
    DATA ls_result TYPE ty_fefo_batch_status_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-as_of_date IS INITIAL
          OR ls_request-min_days < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant )
        TO lt_stock_requests.
    ENDLOOP.

    DATA(lt_batch_statuses) = get_batch_stock_status_bulk(
      it_requests = lt_stock_requests ).
    DATA(lo_eligibility) = NEW zcl_stock_batch_eligibility( ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_batch_statuses INTO DATA(ls_batch_status_result)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_batch_status_result-material <> ls_request-material
          OR ls_batch_status_result-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR: lt_dated_status, lt_undated_status, ls_result.
      LOOP AT ls_batch_status_result-batches INTO DATA(ls_batch_status).
        IF lo_eligibility->is_eligible(
            iv_expiration_date = ls_batch_status-expiration_date
            iv_as_of_date      = ls_request-as_of_date
            iv_min_days        = ls_request-min_days ) = abap_true.
          IF ls_batch_status-expiration_date IS INITIAL.
            APPEND ls_batch_status TO lt_undated_status.
          ELSE.
            APPEND ls_batch_status TO lt_dated_status.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SORT lt_dated_status BY expiration_date batch storage_location.
      SORT lt_undated_status BY batch storage_location.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-as_of_date = ls_request-as_of_date.
      ls_result-min_days = ls_request-min_days.
      APPEND LINES OF lt_dated_status TO ls_result-batches.
      APPEND LINES OF lt_undated_status TO ls_result-batches.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_fefo_batch_status_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_fefo_requests TYPE ty_fefo_batch_status_requests.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_fefo_batch_unit_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-as_of_date IS INITIAL
          OR ls_request-min_days < 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_request-request_id
        material   = ls_request-material
        plant      = ls_request-plant
        as_of_date = ls_request-as_of_date
        min_days   = ls_request-min_days )
        TO lt_fefo_requests.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    DATA(lt_fefo_statuses) = get_fefo_batch_status_bulk(
      it_requests = lt_fefo_requests ).

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_fefo_statuses INTO DATA(ls_fefo_status)
        WITH KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0
          OR ls_fefo_status-material <> ls_request-material
          OR ls_fefo_status-plant <> ls_request-plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-as_of_date = ls_request-as_of_date.
      ls_result-min_days = ls_request-min_days.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT ls_fefo_status-batches INTO DATA(ls_batch_status).
        APPEND VALUE #(
          material              = ls_request-material
          plant                 = ls_request-plant
          storage_location      = ls_batch_status-storage_location
          batch                 = ls_batch_status-batch
          expiration_date       = ls_batch_status-expiration_date
          base_unit             = ls_ratio_cache-ratio-base_unit
          unit                  = ls_request-unit
          unrestricted_quantity = convert_stock_quantity(
            iv_base_quantity = ls_batch_status-unrestricted_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator )
          available_quantity    = convert_stock_quantity(
            iv_base_quantity = ls_batch_status-available_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator ) )
          TO ls_result-batches.
      ENDLOOP.
      APPEND ls_result TO rt_status.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_sales_order_reservations.
    IF iv_sales_document IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_reservations = mo_stock_repository->get_sales_order_reservations(
      iv_sales_document = iv_sales_document ).
  ENDMETHOD.

  METHOD get_order_reservations_bulk.
    IF it_sales_documents IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_sales_documents INTO DATA(lv_sales_document).
      IF lv_sales_document IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rt_reservations = mo_stock_repository->get_order_reservations_bulk(
      it_sales_documents = it_sales_documents ).
  ENDMETHOD.

  METHOD get_order_res_bulk_uom.
    TYPES:
      BEGIN OF ty_ratio_cache,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        ratio    TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_ratio_cache.
    TYPES ty_ratio_caches TYPE HASHED TABLE OF ty_ratio_cache
      WITH UNIQUE KEY material unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_sales_document TYPE resb-kdauf.
    DATA lt_ratio_cache TYPE ty_ratio_caches.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_sales_documents TYPE zif_stock_repository=>ty_sales_order_documents.
    DATA lt_unique_documents TYPE HASHED TABLE OF ty_sales_document
      WITH UNIQUE KEY table_line.
    DATA ls_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_ratio_cache TYPE ty_ratio_cache.
    DATA ls_result TYPE ty_order_res_uom_result.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-sales_document IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-sales_document INTO TABLE lt_unique_documents.
      IF sy-subrc = 0.
        APPEND ls_request-sales_document TO lt_sales_documents.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        ls_ratio = get_stock_unit_ratio(
          iv_material = ls_request-material
          iv_unit     = ls_request-unit ).
        INSERT VALUE #(
          material = ls_request-material
          unit     = ls_request-unit
          ratio    = ls_ratio ) INTO TABLE lt_ratio_cache.
      ENDIF.
    ENDLOOP.

    DATA(lt_base_reservations) = get_order_reservations_bulk(
      it_sales_documents = lt_sales_documents ).
    LOOP AT lt_base_reservations INTO DATA(ls_base_reservation).
      IF ls_base_reservation-sales_document IS INITIAL
          OR ls_base_reservation-material IS INITIAL
          OR ls_base_reservation-plant IS INITIAL
          OR ls_base_reservation-open_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_unique_documents TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line = ls_base_reservation-sales_document.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_ratio_cache INTO ls_ratio_cache
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_result.
      ls_result-request_id = ls_request-request_id.
      ls_result-sales_document = ls_request-sales_document.
      ls_result-material = ls_request-material.
      ls_result-plant = ls_request-plant.
      ls_result-base_unit = ls_ratio_cache-ratio-base_unit.
      ls_result-unit = ls_request-unit.
      LOOP AT lt_base_reservations INTO ls_base_reservation
          WHERE sales_document = ls_request-sales_document
            AND material = ls_request-material
            AND plant = ls_request-plant.
        APPEND VALUE #(
          sales_document   = ls_base_reservation-sales_document
          material         = ls_base_reservation-material
          plant            = ls_base_reservation-plant
          item_number      = ls_base_reservation-item_number
          schedule_line    = ls_base_reservation-schedule_line
          requirement_date = ls_base_reservation-requirement_date
          open_quantity    = convert_stock_quantity(
            iv_base_quantity = ls_base_reservation-open_quantity
            iv_numerator     = ls_ratio_cache-ratio-numerator
            iv_denominator   = ls_ratio_cache-ratio-denominator ) )
          TO ls_result-reservations.
      ENDLOOP.
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_request.
    DATA(lt_demands) = VALUE ty_demands(
      ( material           = iv_material
        plant              = iv_plant
        requested_quantity = iv_requested_quantity ) ).
    DATA(lt_allocations) = allocate_demands(
      it_demands               = lt_demands
      iv_protect_safety_stock  = iv_protect_safety_stock
      iv_require_full_quantity = iv_require_full_quantity ).

    READ TABLE lt_allocations INDEX 1 INTO rs_allocation.
  ENDMETHOD.

  METHOD allocate_request_by_date.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_required_date IS INITIAL
        OR iv_requested_quantity < 0
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_allocation-material = iv_material.
    rs_allocation-plant = iv_plant.
    rs_allocation-required_date = iv_required_date.
    rs_allocation-requested_quantity = iv_requested_quantity.
    rs_allocation-available_quantity =
      mo_stock_repository->get_available_stock_by_date(
        iv_material                    = iv_material
        iv_plant                       = iv_plant
        iv_required_date               = iv_required_date
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_subtract_unissued_sto       = iv_subtract_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       =
          iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

    IF iv_include_po_confirmations = abap_true.
      DATA(lt_po_confirmation_receipts) = get_po_confirmed_receipts(
        iv_material     = iv_material
        iv_plant        = iv_plant
        iv_through_date = iv_required_date ).
      LOOP AT lt_po_confirmation_receipts INTO DATA(ls_po_receipt).
        rs_allocation-available_quantity =
          rs_allocation-available_quantity + ls_po_receipt-quantity.
      ENDLOOP.
    ENDIF.

    IF iv_protect_safety_stock = abap_true.
      DATA(lv_safety_stock) = mo_stock_repository->get_safety_stock(
        iv_material = iv_material
        iv_plant    = iv_plant ).
      rs_allocation-available_quantity =
        NEW zcl_stock_avail_qty_calc( )->calculate_with_safety_stock(
          iv_available_quantity    = rs_allocation-available_quantity
          iv_safety_stock_quantity = lv_safety_stock ).
    ENDIF.

    IF iv_require_full_quantity = abap_true
        AND iv_requested_quantity > rs_allocation-available_quantity.
      rs_allocation-shortfall_quantity = iv_requested_quantity.
    ELSEIF iv_requested_quantity < rs_allocation-available_quantity.
      rs_allocation-allocated_quantity = iv_requested_quantity.
    ELSE.
      rs_allocation-allocated_quantity =
        rs_allocation-available_quantity.
      rs_allocation-shortfall_quantity = iv_requested_quantity
        - rs_allocation-allocated_quantity.
    ENDIF.
  ENDMETHOD.

  METHOD allocate_demands_by_date.
    TYPES:
      BEGIN OF ty_po_conf_cache,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_po_conf_cache.
    TYPES ty_po_conf_caches TYPE HASHED TABLE OF ty_po_conf_cache
      WITH UNIQUE KEY material plant.
    TYPES ty_po_conf_request_id TYPE c LENGTH 30.
    DATA lt_demand_indexes TYPE ty_dated_demand_indexes.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_stock_cache TYPE ty_dated_stock_caches.
    DATA lt_allocated_balances TYPE ty_dated_allocated_balances.
    DATA lt_indexed_allocations TYPE ty_indexed_dated_allocations.
    DATA lt_excluded_reservation_keys TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_po_conf_cache TYPE ty_po_conf_caches.
    DATA lt_po_conf_requests TYPE ty_projected_receipt_requests.
    DATA lt_po_conf_results TYPE ty_projected_receipt_bulk_results.
    DATA lv_po_conf_request_id TYPE ty_po_conf_request_id.
    DATA lv_po_conf_request_number TYPE i.
    DATA lv_available_quantity TYPE mard-labst.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lv_safety_material TYPE mard-matnr.
    DATA lv_safety_plant TYPE mard-werks.
    DATA lv_safety_loaded TYPE abap_bool.
    FIELD-SYMBOLS <ls_allocated_balance> TYPE ty_dated_allocated_balance.
    FIELD-SYMBOLS <ls_po_conf_cache> TYPE ty_po_conf_cache.

    IF ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_dated_input).
      DATA(lv_source_index) = sy-tabix.
      IF ls_dated_input-request_id IS INITIAL
          OR ls_dated_input-material IS INITIAL
          OR ls_dated_input-plant IS INITIAL
          OR ls_dated_input-required_date IS INITIAL
          OR ls_dated_input-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_dated_input-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_dated_input-request_id )
        INTO TABLE lt_request_ids.

      APPEND VALUE #(
        source_index       = lv_source_index
        request_id         = ls_dated_input-request_id
        material           = ls_dated_input-material
        plant              = ls_dated_input-plant
        required_date      = ls_dated_input-required_date
        priority           = ls_dated_input-priority
        requested_quantity = ls_dated_input-requested_quantity )
        TO lt_demand_indexes.

      IF iv_include_po_confirmations = abap_true.
        READ TABLE lt_po_conf_cache ASSIGNING <ls_po_conf_cache>
          WITH TABLE KEY material = ls_dated_input-material
                         plant = ls_dated_input-plant.
        IF sy-subrc = 0.
          IF <ls_po_conf_cache>-through_date <
              ls_dated_input-required_date.
            <ls_po_conf_cache>-through_date =
              ls_dated_input-required_date.
          ENDIF.
        ELSE.
          INSERT VALUE #(
            material     = ls_dated_input-material
            plant        = ls_dated_input-plant
            through_date = ls_dated_input-required_date )
            INTO TABLE lt_po_conf_cache.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_excluded_reservations INTO DATA(ls_excluded_reservation).
      IF ls_excluded_reservation-reservation_number IS INITIAL
          OR ls_excluded_reservation-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_excluded_reservation INTO TABLE
        lt_excluded_reservation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF iv_include_po_confirmations = abap_true.
      LOOP AT lt_po_conf_cache INTO DATA(ls_po_conf_cache).
        ADD 1 TO lv_po_conf_request_number.
        lv_po_conf_request_id = lv_po_conf_request_number.
        APPEND VALUE #(
          request_id   = lv_po_conf_request_id
          material     = ls_po_conf_cache-material
          plant        = ls_po_conf_cache-plant
          through_date = ls_po_conf_cache-through_date )
          TO lt_po_conf_requests.
      ENDLOOP.
      lt_po_conf_results = get_po_conf_receipts_bulk(
        it_requests = lt_po_conf_requests ).
    ENDIF.

    SORT lt_demand_indexes BY material plant required_date
      priority DESCENDING source_index ASCENDING.
    LOOP AT lt_demand_indexes INTO DATA(ls_dated_demand).
      READ TABLE lt_stock_cache INTO DATA(ls_cached_stock)
        WITH TABLE KEY material = ls_dated_demand-material
                       plant = ls_dated_demand-plant
                       required_date = ls_dated_demand-required_date.
      IF sy-subrc = 0.
        lv_available_quantity = ls_cached_stock-available_quantity.
      ELSE.
        lv_available_quantity =
          mo_stock_repository->get_available_stock_by_date(
            iv_material                    = ls_dated_demand-material
            iv_plant                       = ls_dated_demand-plant
            iv_required_date               = ls_dated_demand-required_date
            it_excluded_reservations       = it_excluded_reservations
            iv_include_po_receipts         = iv_include_po_receipts
            iv_include_sto_in_transit      = iv_include_sto_in_transit
            iv_include_unissued_sto        = iv_include_unissued_sto
            iv_subtract_unissued_sto       = iv_subtract_unissued_sto
            iv_include_prod_receipts       = iv_include_prod_receipts
            iv_include_pr_receipts         = iv_include_pr_receipts
            iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
            iv_include_planned_receipts    = iv_include_planned_receipts
            iv_include_fixed_planned       =
              iv_include_fixed_planned
            iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

        IF iv_include_po_confirmations = abap_true.
          READ TABLE lt_po_conf_results INTO DATA(ls_po_conf_result)
            WITH KEY material = ls_dated_demand-material
                     plant = ls_dated_demand-plant.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          LOOP AT ls_po_conf_result-receipts INTO DATA(ls_po_conf_receipt).
            IF ls_po_conf_receipt-receipt_date <=
                ls_dated_demand-required_date.
              lv_available_quantity = lv_available_quantity
                + ls_po_conf_receipt-quantity.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF iv_protect_safety_stock = abap_true.
          IF lv_safety_loaded <> abap_true
              OR lv_safety_material <> ls_dated_demand-material
              OR lv_safety_plant <> ls_dated_demand-plant.
            lv_safety_stock = mo_stock_repository->get_safety_stock(
              iv_material = ls_dated_demand-material
              iv_plant    = ls_dated_demand-plant ).
            lv_safety_material = ls_dated_demand-material.
            lv_safety_plant = ls_dated_demand-plant.
            lv_safety_loaded = abap_true.
          ENDIF.
          lv_available_quantity =
            NEW zcl_stock_avail_qty_calc( )->calculate_with_safety_stock(
              iv_available_quantity    = lv_available_quantity
              iv_safety_stock_quantity = lv_safety_stock ).
        ENDIF.

        INSERT VALUE #(
          material           = ls_dated_demand-material
          plant              = ls_dated_demand-plant
          required_date      = ls_dated_demand-required_date
          available_quantity = lv_available_quantity )
          INTO TABLE lt_stock_cache.
      ENDIF.

      READ TABLE lt_allocated_balances ASSIGNING <ls_allocated_balance>
        WITH TABLE KEY material = ls_dated_demand-material
                       plant = ls_dated_demand-plant.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material = ls_dated_demand-material
          plant    = ls_dated_demand-plant ) INTO TABLE lt_allocated_balances.
        READ TABLE lt_allocated_balances ASSIGNING <ls_allocated_balance>
          WITH TABLE KEY material = ls_dated_demand-material
                         plant = ls_dated_demand-plant.
      ENDIF.

      lv_remaining_quantity = NEW zcl_stock_avail_qty_calc( )->calculate(
        iv_unrestricted_quantity = lv_available_quantity
        iv_reserved_quantity     = <ls_allocated_balance>-allocated_quantity ).
      DATA(lv_allocated_quantity) = COND mard-labst(
        WHEN iv_require_full_quantity = abap_true
          AND ls_dated_demand-requested_quantity > lv_remaining_quantity
        THEN 0
        WHEN ls_dated_demand-requested_quantity < lv_remaining_quantity
        THEN ls_dated_demand-requested_quantity
        ELSE lv_remaining_quantity ).
      APPEND VALUE #(
        source_index = ls_dated_demand-source_index
        allocation   = VALUE #(
          request_id         = ls_dated_demand-request_id
          material           = ls_dated_demand-material
          plant              = ls_dated_demand-plant
          required_date      = ls_dated_demand-required_date
          priority           = ls_dated_demand-priority
          requested_quantity = ls_dated_demand-requested_quantity
          available_quantity = lv_remaining_quantity
          allocated_quantity = lv_allocated_quantity
          shortfall_quantity = ls_dated_demand-requested_quantity
            - lv_allocated_quantity ) ) TO lt_indexed_allocations.
      <ls_allocated_balance>-allocated_quantity =
        <ls_allocated_balance>-allocated_quantity + lv_allocated_quantity.
    ENDLOOP.

    SORT lt_indexed_allocations BY source_index.
    LOOP AT lt_indexed_allocations INTO DATA(ls_indexed_allocation).
      APPEND ls_indexed_allocation-allocation TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_date_demands_in_units.
    DATA lt_base_demands TYPE ty_dated_demands.
    DATA lt_base_allocations TYPE ty_dated_allocations.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_excluded_reservation_keys TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.

    IF ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_input).
      IF ls_input-request_id IS INITIAL
          OR ls_input-material IS INITIAL
          OR ls_input-plant IS INITIAL
          OR ls_input-required_date IS INITIAL
          OR ls_input-requested_unit IS INITIAL
          OR ls_input-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_input-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_input-request_id )
        INTO TABLE lt_request_ids.
    ENDLOOP.

    LOOP AT it_excluded_reservations INTO DATA(ls_excluded_reservation).
      IF ls_excluded_reservation-reservation_number IS INITIAL
          OR ls_excluded_reservation-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_excluded_reservation INTO TABLE
        lt_excluded_reservation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_input.
      READ TABLE lt_uom_cache INTO DATA(ls_cached_ratio)
        WITH TABLE KEY material = ls_input-material
                       unit = ls_input-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_ratio-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_input-material
          iv_unit     = ls_input-requested_unit ).
        INSERT VALUE #(
          material = ls_input-material
          unit     = ls_input-requested_unit
          result   = ls_unit_ratio )
          INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_input-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).
      APPEND VALUE #(
        request_id         = ls_input-request_id
        material           = ls_input-material
        plant              = ls_input-plant
        required_date      = ls_input-required_date
        priority           = ls_input-priority
        requested_quantity = lv_base_quantity )
        TO lt_base_demands.
    ENDLOOP.

    lt_base_allocations = allocate_demands_by_date(
      it_demands                     = lt_base_demands
      it_excluded_reservations       = it_excluded_reservations
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       =
        iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_quantity ).

    LOOP AT it_demands INTO ls_input.
      READ TABLE lt_base_allocations INTO DATA(ls_base_allocation)
        INDEX sy-tabix.
      READ TABLE lt_uom_cache INTO ls_cached_ratio
        WITH TABLE KEY material = ls_input-material
                       unit = ls_input-requested_unit.
      ls_unit_ratio = ls_cached_ratio-result.

      APPEND VALUE #(
        allocation                = ls_base_allocation
        source_quantity           = ls_input-requested_quantity
        source_unit               = ls_input-requested_unit
        base_quantity             = ls_base_allocation-requested_quantity
        base_unit                 = ls_unit_ratio-base_unit
        available_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-available_quantity
          iv_numerator     = ls_unit_ratio-numerator
          iv_denominator   = ls_unit_ratio-denominator )
        allocated_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-allocated_quantity
          iv_numerator     = ls_unit_ratio-numerator
          iv_denominator   = ls_unit_ratio-denominator )
        shortfall_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-shortfall_quantity
          iv_numerator     = ls_unit_ratio-numerator
          iv_denominator   = ls_unit_ratio-denominator ) )
        TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_date_demands_atp.
    DATA lt_local_allocations TYPE ty_date_unit_allocations.
    DATA lt_atp_days TYPE ty_dated_atp_days.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    FIELD-SYMBOLS <ls_atp_day> TYPE ty_dated_atp_day.

    IF iv_check_rule IS INITIAL
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    lt_local_allocations = allocate_date_demands_in_units(
      it_demands                     = it_demands
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       =
        iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_quantity ).

    LOOP AT lt_local_allocations INTO DATA(ls_local_allocation).
      READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
        WITH KEY material = ls_local_allocation-allocation-material
                 plant = ls_local_allocation-allocation-plant
                 base_unit = ls_local_allocation-base_unit
                 required_date =
                   ls_local_allocation-allocation-required_date.
      IF sy-subrc = 0.
        <ls_atp_day>-demand_quantity = <ls_atp_day>-demand_quantity
          + ls_local_allocation-base_quantity.
      ELSE.
        INSERT VALUE #(
          material        = ls_local_allocation-allocation-material
          plant           = ls_local_allocation-allocation-plant
          base_unit       = ls_local_allocation-base_unit
          required_date   = ls_local_allocation-allocation-required_date
          demand_quantity = ls_local_allocation-base_quantity )
          INTO TABLE lt_atp_days.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      IF sy-tabix = 1
          OR <ls_atp_day>-material <> lv_previous_material
          OR <ls_atp_day>-plant <> lv_previous_plant
          OR <ls_atp_day>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      lv_cumulative_quantity = lv_cumulative_quantity
        + <ls_atp_day>-demand_quantity.
      <ls_atp_day>-cumulative_quantity = lv_cumulative_quantity.

      IF lv_cumulative_quantity > 0.
        <ls_atp_day>-atp_result = check_atp_request(
          is_request = VALUE #(
            material           = <ls_atp_day>-material
            plant              = <ls_atp_day>-plant
            unit               = <ls_atp_day>-base_unit
            check_rule         = iv_check_rule
            required_date      = <ls_atp_day>-required_date
            requested_quantity = lv_cumulative_quantity ) ).
      ENDIF.

      lv_previous_material = <ls_atp_day>-material.
      lv_previous_plant = <ls_atp_day>-plant.
      lv_previous_unit = <ls_atp_day>-base_unit.
    ENDLOOP.

    LOOP AT lt_local_allocations INTO ls_local_allocation.
      READ TABLE lt_atp_days INTO DATA(ls_atp_day)
        WITH KEY material = ls_local_allocation-allocation-material
                 plant = ls_local_allocation-allocation-plant
                 base_unit = ls_local_allocation-base_unit
                 required_date =
                   ls_local_allocation-allocation-required_date.
      DATA(ls_confirmation_quantities) = get_atp_confirmation_split(
        iv_requested_base_quantity = ls_atp_day-cumulative_quantity
        iv_required_date           = ls_atp_day-required_date
        is_atp_result              = ls_atp_day-atp_result ).
      APPEND VALUE #(
        local_estimate            = ls_local_allocation
        cumulative_base_quantity  = ls_atp_day-cumulative_quantity
        confirmed_base_quantity   =
          ls_confirmation_quantities-confirmed_base_quantity
        unconfirmed_base_quantity =
          ls_confirmation_quantities-unconfirmed_base_quantity
        atp_result                = ls_atp_day-atp_result ) TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_request_date_atp.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_unit IS INITIAL
        OR iv_check_rule IS INITIAL
        OR iv_required_date IS INITIAL
        OR iv_requested_quantity < 0
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_unit_ratio) = get_stock_unit_ratio(
      iv_material = iv_material
      iv_unit     = iv_unit ).
    DATA(lv_base_quantity) = CONV mard-labst(
      CONV decfloat34( iv_requested_quantity )
      * CONV decfloat34( ls_unit_ratio-numerator )
      / CONV decfloat34( ls_unit_ratio-denominator ) ).

    rs_result-local_estimate = allocate_request_by_date(
      iv_material                    = iv_material
      iv_plant                       = iv_plant
      iv_required_date               = iv_required_date
      iv_requested_quantity          = lv_base_quantity
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       =
        iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_quantity ).

    rs_result-atp_result = check_atp_request(
      is_request = VALUE #(
        material           = iv_material
        plant              = iv_plant
        unit               = iv_unit
        check_rule         = iv_check_rule
        required_date      = iv_required_date
        requested_quantity = iv_requested_quantity ) ).
    DATA(ls_confirmation_quantities) = get_atp_confirmation_split(
      iv_requested_base_quantity = lv_base_quantity
      iv_numerator               = ls_unit_ratio-numerator
      iv_denominator             = ls_unit_ratio-denominator
      iv_required_date           = iv_required_date
      is_atp_result              = rs_result-atp_result ).
    rs_result-confirmed_base_quantity =
      ls_confirmation_quantities-confirmed_base_quantity.
    rs_result-unconfirmed_base_quantity =
      ls_confirmation_quantities-unconfirmed_base_quantity.
  ENDMETHOD.

  METHOD check_atp_request.
    IF is_request-material IS INITIAL
        OR is_request-plant IS INITIAL
        OR is_request-unit IS INITIAL
        OR is_request-check_rule IS INITIAL
        OR is_request-required_date IS INITIAL
        OR is_request-requested_quantity < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result = mo_material_availability_api->check_availability(
      is_request = is_request ).
  ENDMETHOD.

  METHOD allocate_request_in_unit.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL
        OR iv_requested_unit IS INITIAL
        OR iv_requested_quantity < 0
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
      iv_material    = iv_material
      iv_quantity    = iv_requested_quantity
      iv_source_unit = iv_requested_unit ).

    IF ls_conversion-is_successful <> abap_true
        OR ls_conversion-base_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-allocation = allocate_request(
      iv_material              = iv_material
      iv_plant                 = iv_plant
      iv_requested_quantity    = ls_conversion-base_quantity
      iv_protect_safety_stock  = iv_protect_safety_stock
      iv_require_full_quantity = iv_require_full_quantity ).
    rs_result-source_quantity = iv_requested_quantity.
    rs_result-source_unit = iv_requested_unit.
    rs_result-base_quantity = ls_conversion-base_quantity.
    rs_result-base_unit = ls_conversion-base_unit.
  ENDMETHOD.

  METHOD allocate_demands_in_units.
    DATA lt_base_demands TYPE ty_demands.
    DATA lt_unit_allocations TYPE ty_unit_allocations.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit     = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = mo_uom_converter->get_material_unit_ratio(
          iv_material         = ls_demand-material
          iv_alternative_unit = ls_demand-requested_unit ).
        IF ls_unit_ratio-is_successful <> abap_true
            OR ls_unit_ratio-base_unit IS INITIAL
            OR ls_unit_ratio-numerator <= 0
            OR ls_unit_ratio-denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio )
          INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        plant              = ls_demand-plant
        requested_quantity = lv_base_quantity )
        TO lt_base_demands.
      APPEND VALUE #(
        allocation      = VALUE #(
          request_id         = ls_demand-request_id
          material           = ls_demand-material
          plant              = ls_demand-plant
          requested_quantity = lv_base_quantity )
        source_quantity = ls_demand-requested_quantity
        source_unit     = ls_demand-requested_unit
        base_quantity   = lv_base_quantity
        base_unit       = ls_unit_ratio-base_unit )
        TO lt_unit_allocations.
    ENDLOOP.

    DATA(lt_allocations) = allocate_demands(
      it_demands               = lt_base_demands
      iv_protect_safety_stock  = iv_protect_safety_stock
      iv_require_full_quantity = iv_require_full_quantity ).
    LOOP AT lt_unit_allocations ASSIGNING FIELD-SYMBOL(<ls_unit_allocation>).
      READ TABLE lt_allocations INTO <ls_unit_allocation>-allocation
        INDEX sy-tabix.
    ENDLOOP.
    rt_allocations = lt_unit_allocations.
  ENDMETHOD.

  METHOD allocate_demands.
    DATA lt_stock_balances TYPE ty_stock_balances.
    DATA ls_stock_balance TYPE ty_stock_balance.
    DATA ls_allocation TYPE ty_allocation.
    FIELD-SYMBOLS <ls_stock_balance> TYPE ty_stock_balance.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_stock_balances ASSIGNING <ls_stock_balance>
        WITH TABLE KEY material = ls_demand-material
                       plant = ls_demand-plant.
      IF sy-subrc <> 0.
        CLEAR ls_stock_balance.
        ls_stock_balance-material = ls_demand-material.
        ls_stock_balance-plant = ls_demand-plant.
        ls_stock_balance-remaining_quantity = get_unrestricted_stock(
          iv_material             = ls_demand-material
          iv_plant                = ls_demand-plant
          iv_protect_safety_stock = iv_protect_safety_stock ).
        IF ls_stock_balance-remaining_quantity < 0.
          CLEAR ls_stock_balance-remaining_quantity.
        ENDIF.
        INSERT ls_stock_balance INTO TABLE lt_stock_balances.

        READ TABLE lt_stock_balances ASSIGNING <ls_stock_balance>
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_demand-plant.
      ENDIF.

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-plant = ls_demand-plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.
      ls_allocation-available_quantity = <ls_stock_balance>-remaining_quantity.

      IF iv_require_full_quantity = abap_true
          AND ls_demand-requested_quantity >
            <ls_stock_balance>-remaining_quantity.
        ls_allocation-shortfall_quantity = ls_demand-requested_quantity.
      ELSE.
        IF ls_demand-requested_quantity <
            <ls_stock_balance>-remaining_quantity.
          ls_allocation-allocated_quantity = ls_demand-requested_quantity.
        ELSE.
          ls_allocation-allocated_quantity =
            <ls_stock_balance>-remaining_quantity.
        ENDIF.

        ls_allocation-shortfall_quantity = ls_demand-requested_quantity
          - ls_allocation-allocated_quantity.
        <ls_stock_balance>-remaining_quantity =
          <ls_stock_balance>-remaining_quantity
          - ls_allocation-allocated_quantity.
      ENDIF.
      APPEND ls_allocation TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_across_plants.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_location_balances TYPE ty_location_balances.
    DATA lt_location_sequence TYPE ty_storage_locations.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA ls_location_balance TYPE ty_location_balance.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_allocation TYPE ty_plant_demand_allocation.
    DATA ls_source_allocation TYPE ty_plant_source_allocation.
    DATA ls_location_allocation TYPE ty_plant_location_allocation.
    DATA lv_available_quantity TYPE mard-labst.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_allocated_quantity TYPE mard-labst.
    DATA lv_plant_available_quantity TYPE mard-labst.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lv_priority_location TYPE mard-lgort.
    DATA lv_storage_location TYPE mard-lgort.
    DATA lt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    FIELD-SYMBOLS <ls_location_balance> TYPE ty_location_balance.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
    ENDLOOP.

    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-request_id IS INITIAL
          OR ls_source-source_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_source_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id
                       source_plant = ls_source-source_plant.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id   = ls_source-request_id
        source_plant = ls_source-source_plant ) INTO TABLE lt_source_keys.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE it_sources TRANSPORTING NO FIELDS
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-target_plant = ls_demand-target_plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.
      lv_available_quantity = 0.
      lv_remaining_quantity = ls_demand-requested_quantity.

      LOOP AT it_sources INTO ls_source
        WHERE request_id = ls_demand-request_id.
        READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_source-source_plant.
        IF sy-subrc <> 0.
          lt_location_stock = mo_stock_repository->get_stock_by_location(
            iv_material = ls_demand-material
            iv_plant    = ls_source-source_plant ).
          LOOP AT lt_location_stock INTO DATA(ls_location_stock).
            CLEAR ls_location_balance.
            ls_location_balance-material = ls_demand-material.
            ls_location_balance-plant = ls_source-source_plant.
            ls_location_balance-storage_location =
              ls_location_stock-storage_location.
            ls_location_balance-remaining_quantity =
              ls_location_stock-available_quantity.
            IF ls_location_balance-remaining_quantity < 0.
              CLEAR ls_location_balance-remaining_quantity.
            ENDIF.
            INSERT ls_location_balance INTO TABLE lt_location_balances.
          ENDLOOP.

          IF iv_protect_safety_stock = abap_true.
            lv_safety_stock = mo_stock_repository->get_safety_stock(
              iv_material = ls_demand-material
              iv_plant    = ls_source-source_plant ).
            LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
              WHERE material = ls_demand-material
                AND plant = ls_source-source_plant.
              IF lv_safety_stock <= 0.
                EXIT.
              ENDIF.
              IF <ls_location_balance>-remaining_quantity <= 0.
                CONTINUE.
              ENDIF.
              IF lv_safety_stock <
                  <ls_location_balance>-remaining_quantity.
                <ls_location_balance>-remaining_quantity =
                  <ls_location_balance>-remaining_quantity - lv_safety_stock.
                CLEAR lv_safety_stock.
              ELSE.
                lv_safety_stock = lv_safety_stock
                  - <ls_location_balance>-remaining_quantity.
                CLEAR <ls_location_balance>-remaining_quantity.
              ENDIF.
            ENDLOOP.
          ENDIF.

          ls_loaded_stock_key-material = ls_demand-material.
          ls_loaded_stock_key-plant = ls_source-source_plant.
          INSERT ls_loaded_stock_key INTO TABLE lt_loaded_stock_keys.
        ENDIF.
        LOOP AT lt_location_balances INTO ls_location_balance
          WHERE material = ls_demand-material
            AND plant = ls_source-source_plant.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = ls_location_balance-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lt_source_location_set IS NOT INITIAL
              AND NOT line_exists( lt_source_location_set[
                request_id = ls_demand-request_id
                source_plant = ls_source-source_plant
                storage_location = ls_location_balance-storage_location ] ).
            CONTINUE.
          ENDIF.
          lv_available_quantity = lv_available_quantity
            + ls_location_balance-remaining_quantity.
        ENDLOOP.
      ENDLOOP.

      IF ls_demand-requested_quantity > 0
          AND ( iv_require_full_quantity = abap_false
            OR ls_demand-requested_quantity <= lv_available_quantity ).
        LOOP AT it_sources INTO ls_source
          WHERE request_id = ls_demand-request_id.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.

          CLEAR ls_source_allocation.
          ls_source_allocation-request_id = ls_demand-request_id.
          ls_source_allocation-material = ls_demand-material.
          ls_source_allocation-target_plant = ls_demand-target_plant.
          ls_source_allocation-source_plant = ls_source-source_plant.
          lv_plant_available_quantity = 0.
          LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = <ls_location_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location =
                    <ls_location_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            lv_plant_available_quantity = lv_plant_available_quantity
              + <ls_location_balance>-remaining_quantity.
          ENDLOOP.
          ls_source_allocation-available_quantity =
            lv_plant_available_quantity.

          CLEAR lt_location_sequence.
          LOOP AT it_storage_location_priority INTO lv_priority_location.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = lv_priority_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location = lv_priority_location ] ).
              CONTINUE.
            ENDIF.
            READ TABLE lt_location_balances TRANSPORTING NO FIELDS
              WITH TABLE KEY material = ls_demand-material
                             plant = ls_source-source_plant
                             storage_location = lv_priority_location.
            IF sy-subrc = 0.
              APPEND lv_priority_location TO lt_location_sequence.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_location_balances INTO ls_location_balance
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = ls_location_balance-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location = ls_location_balance-storage_location ] ).
              CONTINUE.
            ENDIF.
            READ TABLE lt_location_sequence TRANSPORTING NO FIELDS
              WITH KEY table_line = ls_location_balance-storage_location.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
            APPEND ls_location_balance-storage_location
              TO lt_location_sequence.
          ENDLOOP.

          LOOP AT lt_location_sequence INTO lv_storage_location.
            IF lv_remaining_quantity <= 0.
              EXIT.
            ENDIF.
            READ TABLE lt_location_balances ASSIGNING <ls_location_balance>
              WITH TABLE KEY material = ls_demand-material
                             plant = ls_source-source_plant
                             storage_location = lv_storage_location.
            IF sy-subrc <> 0
                OR <ls_location_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.

            IF lv_remaining_quantity <
                <ls_location_balance>-remaining_quantity.
              lv_allocated_quantity = lv_remaining_quantity.
            ELSE.
              lv_allocated_quantity =
                <ls_location_balance>-remaining_quantity.
            ENDIF.

            CLEAR ls_location_allocation.
            ls_location_allocation-request_id = ls_demand-request_id.
            ls_location_allocation-material = ls_demand-material.
            ls_location_allocation-target_plant = ls_demand-target_plant.
            ls_location_allocation-source_plant = ls_source-source_plant.
            ls_location_allocation-storage_location = lv_storage_location.
            ls_location_allocation-available_quantity =
              <ls_location_balance>-remaining_quantity.
            ls_location_allocation-allocated_quantity =
              lv_allocated_quantity.
            APPEND ls_location_allocation
              TO rs_result-location_allocations.

            <ls_location_balance>-remaining_quantity =
              <ls_location_balance>-remaining_quantity
              - lv_allocated_quantity.
            lv_remaining_quantity = lv_remaining_quantity
              - lv_allocated_quantity.
            ls_source_allocation-allocated_quantity =
              ls_source_allocation-allocated_quantity
              + lv_allocated_quantity.
          ENDLOOP.

          IF ls_source_allocation-allocated_quantity > 0.
            APPEND ls_source_allocation TO rs_result-plant_allocations.
          ENDIF.
        ENDLOOP.
      ENDIF.

      ls_allocation-available_quantity = lv_available_quantity.
      ls_allocation-allocated_quantity = ls_demand-requested_quantity
        - lv_remaining_quantity.
      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_by_date.
    TYPES:
      BEGIN OF ty_po_conf_cache,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_po_conf_cache.
    TYPES ty_po_conf_caches TYPE HASHED TABLE OF ty_po_conf_cache
      WITH UNIQUE KEY material plant.
    TYPES ty_po_conf_request_id TYPE c LENGTH 30.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_demand_indexes TYPE ty_date_plant_demand_idxs.
    DATA lt_stock_cache TYPE ty_dated_stock_caches.
    DATA lt_allocated_balances TYPE ty_dated_allocated_balances.
    DATA lt_safety_cache TYPE ty_safety_cache.
    DATA lt_demand_source_balances TYPE ty_demand_source_balances.
    DATA lt_indexed_allocations TYPE ty_date_plant_summary_idxs.
    DATA lt_indexed_source_allocations TYPE ty_date_plant_source_idxs.
    DATA lt_po_conf_cache TYPE ty_po_conf_caches.
    DATA lt_po_conf_requests TYPE ty_projected_receipt_requests.
    DATA lt_po_conf_results TYPE ty_projected_receipt_bulk_results.
    DATA lv_po_conf_request_id TYPE ty_po_conf_request_id.
    DATA lv_po_conf_request_number TYPE i.
    DATA lv_available_quantity TYPE mard-labst.
    DATA lv_source_available TYPE mard-labst.
    DATA lv_source_remaining TYPE mard-labst.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_allocated_quantity TYPE mard-labst.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lv_source_order TYPE i.
    FIELD-SYMBOLS <ls_allocated_balance> TYPE ty_dated_allocated_balance.
    FIELD-SYMBOLS <ls_po_conf_cache> TYPE ty_po_conf_cache.

    IF ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      DATA(lv_source_index) = sy-tabix.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
      APPEND VALUE #(
        source_index       = lv_source_index
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        required_date      = ls_demand-required_date
        priority           = ls_demand-priority
        requested_quantity = ls_demand-requested_quantity )
        TO lt_demand_indexes.
    ENDLOOP.

    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-request_id IS INITIAL
          OR ls_source-source_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_source_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id
                       source_plant = ls_source-source_plant.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id   = ls_source-request_id
        source_plant = ls_source-source_plant ) INTO TABLE lt_source_keys.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE it_sources TRANSPORTING NO FIELDS
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF iv_include_po_confirmations = abap_true.
      LOOP AT lt_demand_indexes INTO DATA(ls_po_conf_demand).
        LOOP AT it_sources INTO DATA(ls_po_conf_source)
            WHERE request_id = ls_po_conf_demand-request_id.
          READ TABLE lt_po_conf_cache ASSIGNING <ls_po_conf_cache>
            WITH TABLE KEY material = ls_po_conf_demand-material
                           plant = ls_po_conf_source-source_plant.
          IF sy-subrc = 0.
            IF <ls_po_conf_cache>-through_date <
                ls_po_conf_demand-required_date.
              <ls_po_conf_cache>-through_date =
                ls_po_conf_demand-required_date.
            ENDIF.
          ELSE.
            INSERT VALUE #(
              material     = ls_po_conf_demand-material
              plant        = ls_po_conf_source-source_plant
              through_date = ls_po_conf_demand-required_date )
              INTO TABLE lt_po_conf_cache.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_po_conf_cache INTO DATA(ls_po_conf_cache).
        ADD 1 TO lv_po_conf_request_number.
        lv_po_conf_request_id = lv_po_conf_request_number.
        APPEND VALUE #(
          request_id   = lv_po_conf_request_id
          material     = ls_po_conf_cache-material
          plant        = ls_po_conf_cache-plant
          through_date = ls_po_conf_cache-through_date )
          TO lt_po_conf_requests.
      ENDLOOP.
      lt_po_conf_results = get_po_conf_receipts_bulk(
        it_requests = lt_po_conf_requests ).
    ENDIF.

    SORT lt_demand_indexes BY required_date priority DESCENDING
      source_index ASCENDING.
    LOOP AT lt_demand_indexes INTO DATA(ls_demand_index).
      CLEAR lt_demand_source_balances.
      CLEAR lv_available_quantity.

      LOOP AT it_sources INTO DATA(ls_demand_source)
        WHERE request_id = ls_demand_index-request_id.
        lv_source_order = sy-tabix.
        READ TABLE lt_stock_cache INTO DATA(ls_cached_stock)
          WITH TABLE KEY material = ls_demand_index-material
                         plant = ls_demand_source-source_plant
                         required_date = ls_demand_index-required_date.
        IF sy-subrc = 0.
          lv_source_available = ls_cached_stock-available_quantity.
        ELSE.
          lv_source_available =
            mo_stock_repository->get_available_stock_by_date(
              iv_material                    = ls_demand_index-material
              iv_plant                       = ls_demand_source-source_plant
              iv_required_date               = ls_demand_index-required_date
              iv_include_po_receipts         = iv_include_po_receipts
              iv_include_sto_in_transit      = iv_include_sto_in_transit
              iv_include_unissued_sto        = iv_include_unissued_sto
              iv_subtract_unissued_sto       = iv_subtract_unissued_sto
              iv_include_prod_receipts       = iv_include_prod_receipts
              iv_include_pr_receipts         = iv_include_pr_receipts
              iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
              iv_include_planned_receipts    = iv_include_planned_receipts
              iv_include_fixed_planned       =
                iv_include_fixed_planned
              iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).

          IF iv_include_po_confirmations = abap_true.
            READ TABLE lt_po_conf_results INTO DATA(ls_po_conf_result)
              WITH KEY material = ls_demand_index-material
                       plant = ls_demand_source-source_plant.
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            LOOP AT ls_po_conf_result-receipts INTO
                DATA(ls_po_conf_receipt).
              IF ls_po_conf_receipt-receipt_date <=
                  ls_demand_index-required_date.
                lv_source_available = lv_source_available
                  + ls_po_conf_receipt-quantity.
              ENDIF.
            ENDLOOP.
          ENDIF.

          IF iv_protect_safety_stock = abap_true.
            READ TABLE lt_safety_cache INTO DATA(ls_safety_cache)
              WITH TABLE KEY material = ls_demand_index-material
                             plant = ls_demand_source-source_plant.
            IF sy-subrc = 0.
              lv_safety_stock = ls_safety_cache-safety_stock.
            ELSE.
              lv_safety_stock = mo_stock_repository->get_safety_stock(
                iv_material = ls_demand_index-material
                iv_plant    = ls_demand_source-source_plant ).
              INSERT VALUE #(
                material     = ls_demand_index-material
                plant        = ls_demand_source-source_plant
                safety_stock = lv_safety_stock ) INTO TABLE lt_safety_cache.
            ENDIF.
            lv_source_available =
              NEW zcl_stock_avail_qty_calc( )->calculate_with_safety_stock(
                iv_available_quantity    = lv_source_available
                iv_safety_stock_quantity = lv_safety_stock ).
          ENDIF.

          INSERT VALUE #(
            material           = ls_demand_index-material
            plant              = ls_demand_source-source_plant
            required_date      = ls_demand_index-required_date
            available_quantity = lv_source_available ) INTO TABLE lt_stock_cache.
        ENDIF.

        READ TABLE lt_allocated_balances INTO DATA(ls_allocated_balance)
          WITH TABLE KEY material = ls_demand_index-material
                         plant = ls_demand_source-source_plant.
        IF sy-subrc <> 0.
          INSERT VALUE #(
            material = ls_demand_index-material
            plant    = ls_demand_source-source_plant )
            INTO TABLE lt_allocated_balances.
          READ TABLE lt_allocated_balances INTO ls_allocated_balance
            WITH TABLE KEY material = ls_demand_index-material
                           plant = ls_demand_source-source_plant.
        ENDIF.

        lv_source_remaining = NEW zcl_stock_avail_qty_calc( )->calculate(
          iv_unrestricted_quantity = lv_source_available
          iv_reserved_quantity     =
            ls_allocated_balance-allocated_quantity ).
        APPEND VALUE #(
          source_plant       = ls_demand_source-source_plant
          source_order       = lv_source_order
          available_quantity = lv_source_remaining )
          TO lt_demand_source_balances.
        lv_available_quantity = lv_available_quantity + lv_source_remaining.
      ENDLOOP.

      lv_remaining_quantity = ls_demand_index-requested_quantity.
      IF ls_demand_index-requested_quantity > 0
          AND ( iv_require_full_quantity = abap_false
            OR ls_demand_index-requested_quantity <= lv_available_quantity ).
        LOOP AT lt_demand_source_balances INTO DATA(ls_source_balance).
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.
          IF ls_source_balance-available_quantity <= 0.
            CONTINUE.
          ENDIF.

          IF lv_remaining_quantity < ls_source_balance-available_quantity.
            lv_allocated_quantity = lv_remaining_quantity.
          ELSE.
            lv_allocated_quantity = ls_source_balance-available_quantity.
          ENDIF.

          READ TABLE lt_allocated_balances ASSIGNING <ls_allocated_balance>
            WITH TABLE KEY material = ls_demand_index-material
                           plant = ls_source_balance-source_plant.
          <ls_allocated_balance>-allocated_quantity =
            <ls_allocated_balance>-allocated_quantity + lv_allocated_quantity.
          APPEND VALUE #(
            source_index = ls_demand_index-source_index
            source_order = ls_source_balance-source_order
            allocation   = VALUE #(
              request_id         = ls_demand_index-request_id
              material           = ls_demand_index-material
              target_plant       = ls_demand_index-target_plant
              source_plant       = ls_source_balance-source_plant
              required_date      = ls_demand_index-required_date
              priority           = ls_demand_index-priority
              available_quantity = ls_source_balance-available_quantity
              allocated_quantity = lv_allocated_quantity ) )
            TO lt_indexed_source_allocations.
          lv_remaining_quantity = lv_remaining_quantity
            - lv_allocated_quantity.
        ENDLOOP.
      ENDIF.

      APPEND VALUE #(
        source_index = ls_demand_index-source_index
        allocation   = VALUE #(
          request_id         = ls_demand_index-request_id
          material           = ls_demand_index-material
          target_plant       = ls_demand_index-target_plant
          required_date      = ls_demand_index-required_date
          priority           = ls_demand_index-priority
          requested_quantity = ls_demand_index-requested_quantity
          available_quantity = lv_available_quantity
          allocated_quantity = ls_demand_index-requested_quantity
            - lv_remaining_quantity
          shortfall_quantity = lv_remaining_quantity ) )
        TO lt_indexed_allocations.
    ENDLOOP.

    SORT lt_indexed_allocations BY source_index.
    LOOP AT lt_indexed_allocations INTO DATA(ls_indexed_allocation).
      APPEND ls_indexed_allocation-allocation TO rs_result-allocations.
    ENDLOOP.
    SORT lt_indexed_source_allocations BY source_index source_order.
    LOOP AT lt_indexed_source_allocations INTO DATA(ls_indexed_source).
      APPEND ls_indexed_source-allocation TO rs_result-plant_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_date_units.
    DATA lt_base_demands TYPE ty_date_plant_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_date_plant_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_date_plant_source_allocation.

    IF ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio )
          INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).
      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        required_date      = ls_demand-required_date
        priority           = ls_demand-priority
        requested_quantity = lv_base_quantity ) TO lt_base_demands.

      CLEAR ls_context.
      ls_context-request_id = ls_demand-request_id.
      ls_context-source_quantity = ls_demand-requested_quantity.
      ls_context-source_unit = ls_demand-requested_unit.
      ls_context-base_quantity = lv_base_quantity.
      ls_context-ratio = ls_unit_ratio.
      APPEND ls_context TO lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_plants_by_date(
      it_demands                     = lt_base_demands
      it_sources                     = it_sources
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       =
        iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_allocation-request_id.
      CLEAR ls_unit_allocation.
      ls_unit_allocation-allocation = ls_base_allocation.
      ls_unit_allocation-source_quantity = ls_context-source_quantity.
      ls_unit_allocation-source_unit = ls_context-source_unit.
      ls_unit_allocation-base_quantity = ls_context-base_quantity.
      ls_unit_allocation-base_unit = ls_context-ratio-base_unit.
      ls_unit_allocation-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-shortfall_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-shortfall_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations
      INTO DATA(ls_base_source_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_source_allocation-request_id.
      CLEAR ls_unit_source.
      ls_unit_source-allocation = ls_base_source_allocation.
      ls_unit_source-source_unit = ls_context-source_unit.
      ls_unit_source-base_unit = ls_context-ratio-base_unit.
      ls_unit_source-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_source-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_source TO rs_result-plant_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_date_atp.
    DATA lt_atp_days TYPE ty_dated_atp_days.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    DATA ls_atp_day TYPE ty_dated_atp_day.
    FIELD-SYMBOLS <ls_atp_day> TYPE ty_dated_atp_day.

    IF iv_check_rule IS INITIAL
        OR ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = allocate_plants_date_units(
      it_demands                     = it_demands
      it_sources                     = it_sources
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       =
        iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_quantity ).

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          plant = ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      IF sy-subrc = 0.
        <ls_atp_day>-demand_quantity = <ls_atp_day>-demand_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          material        = ls_source_allocation-allocation-material
          plant           = ls_source_allocation-allocation-source_plant
          base_unit       = ls_source_allocation-base_unit
          required_date   =
            ls_source_allocation-allocation-required_date
          demand_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_atp_days.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      IF sy-tabix = 1
          OR <ls_atp_day>-material <> lv_previous_material
          OR <ls_atp_day>-plant <> lv_previous_plant
          OR <ls_atp_day>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      lv_cumulative_quantity = lv_cumulative_quantity
        + <ls_atp_day>-demand_quantity.
      <ls_atp_day>-cumulative_quantity = lv_cumulative_quantity.
      <ls_atp_day>-atp_result = check_atp_request(
        is_request = VALUE #(
          material           = <ls_atp_day>-material
          plant              = <ls_atp_day>-plant
          unit               = <ls_atp_day>-base_unit
          check_rule         = iv_check_rule
          required_date      = <ls_atp_day>-required_date
          requested_quantity = lv_cumulative_quantity ) ).
      lv_previous_material = <ls_atp_day>-material.
      lv_previous_plant = <ls_atp_day>-plant.
      lv_previous_unit = <ls_atp_day>-base_unit.
    ENDLOOP.

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO ls_source_allocation.
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_days INTO ls_atp_day
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          plant = ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      DATA(ls_confirmation_quantities) = get_atp_confirmation_split(
        iv_requested_base_quantity = ls_atp_day-cumulative_quantity
        iv_required_date           =
          ls_source_allocation-allocation-required_date
        is_atp_result              = ls_atp_day-atp_result ).
      APPEND VALUE #(
        request_id                =
          ls_source_allocation-allocation-request_id
        material                  =
          ls_source_allocation-allocation-material
        target_plant              =
          ls_source_allocation-allocation-target_plant
        source_plant              =
          ls_source_allocation-allocation-source_plant
        required_date             =
          ls_source_allocation-allocation-required_date
        base_unit                 = ls_source_allocation-base_unit
        allocated_base_quantity   =
          ls_source_allocation-allocation-allocated_quantity
        cumulative_base_quantity  = ls_atp_day-cumulative_quantity
        confirmed_base_quantity   =
          ls_confirmation_quantities-confirmed_base_quantity
        unconfirmed_base_quantity =
          ls_confirmation_quantities-unconfirmed_base_quantity
        atp_result                = ls_atp_day-atp_result )
        TO rs_result-atp_checks.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_by_expiry.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_fefo_balances TYPE ty_fefo_balances.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA ls_fefo_balance TYPE ty_fefo_balance.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_allocation TYPE ty_plant_demand_allocation.
    DATA ls_source_allocation TYPE ty_plant_source_allocation.
    DATA ls_batch_allocation TYPE ty_plant_batch_location_allocation.
    DATA lt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA lo_eligibility TYPE REF TO zcl_stock_batch_eligibility.
    DATA lv_available_quantity TYPE mard-labst.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_allocated_quantity TYPE mard-labst.
    DATA lv_plant_available_quantity TYPE mard-labst.
    DATA lv_safety_stock TYPE marc-eisbe.
    FIELD-SYMBOLS <ls_fefo_balance> TYPE ty_fefo_balance.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).
    IF iv_as_of_date IS INITIAL OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lo_eligibility = NEW zcl_stock_batch_eligibility( ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
    ENDLOOP.

    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-request_id IS INITIAL
          OR ls_source-source_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_source_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id
                       source_plant = ls_source-source_plant.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id   = ls_source-request_id
        source_plant = ls_source-source_plant ) INTO TABLE lt_source_keys.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE it_sources TRANSPORTING NO FIELDS
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-target_plant = ls_demand-target_plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.
      lv_available_quantity = 0.
      lv_remaining_quantity = ls_demand-requested_quantity.

      LOOP AT it_sources INTO ls_source
        WHERE request_id = ls_demand-request_id.
        READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_source-source_plant.
        IF sy-subrc <> 0.
          lt_batch_stock = mo_stock_repository->get_stock_by_batch(
            iv_material = ls_demand-material
            iv_plant    = ls_source-source_plant ).
          LOOP AT lt_batch_stock INTO DATA(ls_batch_stock).
            CLEAR ls_fefo_balance.
            ls_fefo_balance-material = ls_demand-material.
            ls_fefo_balance-plant = ls_source-source_plant.
            ls_fefo_balance-storage_location =
              ls_batch_stock-storage_location.
            READ TABLE it_storage_location_priority TRANSPORTING NO FIELDS
              WITH KEY table_line = ls_batch_stock-storage_location.
            IF sy-subrc = 0.
              ls_fefo_balance-location_priority = sy-tabix.
            ELSE.
              ls_fefo_balance-location_priority =
                lines( it_storage_location_priority ) + 1.
            ENDIF.
            ls_fefo_balance-batch = ls_batch_stock-batch.
            ls_fefo_balance-expiration_date =
              ls_batch_stock-expiration_date.
            ls_fefo_balance-sort_expiration_date =
              ls_batch_stock-expiration_date.
            IF ls_fefo_balance-sort_expiration_date IS INITIAL.
              ls_fefo_balance-sort_expiration_date = '99991231'.
            ENDIF.
            ls_fefo_balance-remaining_quantity =
              ls_batch_stock-available_quantity.
            IF ls_fefo_balance-remaining_quantity < 0.
              CLEAR ls_fefo_balance-remaining_quantity.
            ENDIF.
            APPEND ls_fefo_balance TO lt_fefo_balances.
          ENDLOOP.

          ls_loaded_stock_key-material = ls_demand-material.
          ls_loaded_stock_key-plant = ls_source-source_plant.
          INSERT ls_loaded_stock_key INTO TABLE lt_loaded_stock_keys.
          SORT lt_fefo_balances BY material plant sort_expiration_date
            batch location_priority storage_location.

          IF iv_protect_safety_stock = abap_true.
            lv_safety_stock = mo_stock_repository->get_safety_stock(
              iv_material = ls_demand-material
              iv_plant    = ls_source-source_plant ).
            SORT lt_fefo_balances BY material plant
              sort_expiration_date DESCENDING batch storage_location.
            LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
              WHERE material = ls_demand-material
                AND plant = ls_source-source_plant.
              IF lv_safety_stock <= 0.
                EXIT.
              ENDIF.
              IF lo_eligibility->is_eligible(
                  iv_expiration_date         = <ls_fefo_balance>-expiration_date
                  iv_as_of_date              = iv_as_of_date
                  iv_min_days                = iv_min_days
                  iv_include_undated_batches =
                    iv_include_undated_batches ) = abap_false.
                CONTINUE.
              ENDIF.
              IF <ls_fefo_balance>-remaining_quantity <= 0.
                CONTINUE.
              ENDIF.
              IF lv_safety_stock <
                  <ls_fefo_balance>-remaining_quantity.
                <ls_fefo_balance>-remaining_quantity =
                  <ls_fefo_balance>-remaining_quantity - lv_safety_stock.
                CLEAR lv_safety_stock.
              ELSE.
                lv_safety_stock = lv_safety_stock
                  - <ls_fefo_balance>-remaining_quantity.
                CLEAR <ls_fefo_balance>-remaining_quantity.
              ENDIF.
            ENDLOOP.
            SORT lt_fefo_balances BY material plant sort_expiration_date
              batch location_priority storage_location.
          ENDIF.
        ENDIF.

        LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
          WHERE material = ls_demand-material
            AND plant = ls_source-source_plant.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = <ls_fefo_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lt_source_location_set IS NOT INITIAL
              AND NOT line_exists( lt_source_location_set[
                request_id = ls_demand-request_id
                source_plant = ls_source-source_plant
                storage_location =
                  <ls_fefo_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lo_eligibility->is_eligible(
              iv_expiration_date         = <ls_fefo_balance>-expiration_date
              iv_as_of_date              = iv_as_of_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) = abap_true.
            lv_available_quantity = lv_available_quantity
              + <ls_fefo_balance>-remaining_quantity.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF ls_demand-requested_quantity > 0
          AND ( iv_require_full_quantity = abap_false
            OR ls_demand-requested_quantity <= lv_available_quantity ).
        LOOP AT it_sources INTO ls_source
          WHERE request_id = ls_demand-request_id.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.

          CLEAR ls_source_allocation.
          ls_source_allocation-request_id = ls_demand-request_id.
          ls_source_allocation-material = ls_demand-material.
          ls_source_allocation-target_plant = ls_demand-target_plant.
          ls_source_allocation-source_plant = ls_source-source_plant.
          lv_plant_available_quantity = 0.
          LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = <ls_fefo_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location =
                    <ls_fefo_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lo_eligibility->is_eligible(
                iv_expiration_date         = <ls_fefo_balance>-expiration_date
                iv_as_of_date              = iv_as_of_date
                iv_min_days                = iv_min_days
                iv_include_undated_batches =
                  iv_include_undated_batches ) = abap_true.
              lv_plant_available_quantity = lv_plant_available_quantity
                + <ls_fefo_balance>-remaining_quantity.
            ENDIF.
          ENDLOOP.
          ls_source_allocation-available_quantity =
            lv_plant_available_quantity.

          LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant.
            IF lv_remaining_quantity <= 0.
              EXIT.
            ENDIF.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = <ls_fefo_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location =
                    <ls_fefo_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lo_eligibility->is_eligible(
                iv_expiration_date         = <ls_fefo_balance>-expiration_date
                iv_as_of_date              = iv_as_of_date
                iv_min_days                = iv_min_days
                iv_include_undated_batches =
                  iv_include_undated_batches ) = abap_false
                OR <ls_fefo_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.

            IF lv_remaining_quantity <
                <ls_fefo_balance>-remaining_quantity.
              lv_allocated_quantity = lv_remaining_quantity.
            ELSE.
              lv_allocated_quantity =
                <ls_fefo_balance>-remaining_quantity.
            ENDIF.

            CLEAR ls_batch_allocation.
            ls_batch_allocation-request_id = ls_demand-request_id.
            ls_batch_allocation-material = ls_demand-material.
            ls_batch_allocation-target_plant = ls_demand-target_plant.
            ls_batch_allocation-source_plant = ls_source-source_plant.
            ls_batch_allocation-storage_location =
              <ls_fefo_balance>-storage_location.
            ls_batch_allocation-batch = <ls_fefo_balance>-batch.
            ls_batch_allocation-expiration_date =
              <ls_fefo_balance>-expiration_date.
            ls_batch_allocation-available_quantity =
              <ls_fefo_balance>-remaining_quantity.
            ls_batch_allocation-allocated_quantity =
              lv_allocated_quantity.
            APPEND ls_batch_allocation TO rs_result-batch_allocations.

            <ls_fefo_balance>-remaining_quantity =
              <ls_fefo_balance>-remaining_quantity
              - lv_allocated_quantity.
            lv_remaining_quantity = lv_remaining_quantity
              - lv_allocated_quantity.
            ls_source_allocation-allocated_quantity =
              ls_source_allocation-allocated_quantity
              + lv_allocated_quantity.
          ENDLOOP.

          IF ls_source_allocation-allocated_quantity > 0.
            APPEND ls_source_allocation TO rs_result-plant_allocations.
          ENDIF.
        ENDLOOP.
      ENDIF.

      ls_allocation-available_quantity = lv_available_quantity.
      ls_allocation-allocated_quantity = ls_demand-requested_quantity
        - lv_remaining_quantity.
      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_fefo_by_date.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_demand_indexes TYPE ty_date_plant_demand_idxs.
    DATA lt_fefo_balances TYPE ty_fefo_balances.
    DATA lt_allowed_storage_locations TYPE SORTED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    DATA lt_source_locations TYPE ty_plant_source_location_set.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA lt_indexed_allocations TYPE ty_date_plant_summary_idxs.
    DATA lt_indexed_source_allocations TYPE ty_date_plant_source_idxs.
    DATA lt_indexed_batch_allocations TYPE ty_date_plant_fefo_batch_idxs.
    DATA lt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA ls_demand TYPE ty_date_plant_demand.
    DATA ls_safety_demand TYPE ty_date_plant_demand.
    DATA ls_source TYPE ty_plant_source.
    DATA ls_fefo_balance TYPE ty_fefo_balance.
    DATA ls_allocation TYPE ty_date_plant_demand_allocation.
    DATA ls_source_allocation TYPE ty_date_plant_source_allocation.
    DATA ls_batch_allocation TYPE ty_plant_batch_location_allocation.
    DATA ls_date_batch_allocation TYPE ty_date_plant_fefo_batch_allocation.
    DATA lv_available_quantity TYPE mard-labst.
    DATA lv_source_available_quantity TYPE mard-labst.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_allocated_quantity TYPE mard-labst.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lv_earliest_required_date TYPE resb-bdter.
    DATA lv_source_index TYPE i.
    DATA lv_source_order TYPE i.
    DATA lv_batch_order TYPE i.
    DATA lo_eligibility TYPE REF TO zcl_stock_batch_eligibility.
    FIELD-SYMBOLS <ls_fefo_balance> TYPE ty_fefo_balance.

    IF it_demands IS INITIAL
        OR it_sources IS INITIAL
        OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).

    LOOP AT it_allowed_storage_locations
      INTO DATA(lv_allowed_storage_location).
      IF lv_allowed_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_allowed_storage_location
        INTO TABLE lt_allowed_storage_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      lv_source_index = sy-tabix.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        source_index       = lv_source_index
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        required_date      = ls_demand-required_date
        priority           = ls_demand-priority
        requested_quantity = ls_demand-requested_quantity )
        TO lt_demand_indexes.
    ENDLOOP.

    LOOP AT it_sources INTO ls_source.
      IF ls_source-request_id IS INITIAL
          OR ls_source-source_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id   = ls_source-request_id
        source_plant = ls_source-source_plant )
        INTO TABLE lt_source_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE it_sources TRANSPORTING NO FIELDS
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    lt_source_locations = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).

    SORT lt_demand_indexes BY material required_date
      priority DESCENDING source_index ASCENDING.
    lo_eligibility = NEW zcl_stock_batch_eligibility( ).

    LOOP AT it_sources INTO ls_source.
      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY material = ls_demand-material
                       plant    = ls_source-source_plant.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      lt_batch_stock = mo_stock_repository->get_stock_by_batch(
        iv_material = ls_demand-material
        iv_plant    = ls_source-source_plant ).
      LOOP AT lt_batch_stock INTO DATA(ls_batch_stock).
        IF it_allowed_storage_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_storage_locations[
              table_line = ls_batch_stock-storage_location ] ).
          CONTINUE.
        ENDIF.
        CLEAR ls_fefo_balance.
        ls_fefo_balance-material = ls_demand-material.
        ls_fefo_balance-plant = ls_source-source_plant.
        ls_fefo_balance-storage_location =
          ls_batch_stock-storage_location.
        READ TABLE it_storage_location_priority TRANSPORTING NO FIELDS
          WITH KEY table_line = ls_batch_stock-storage_location.
        IF sy-subrc = 0.
          ls_fefo_balance-location_priority = sy-tabix.
        ELSE.
          ls_fefo_balance-location_priority =
            lines( it_storage_location_priority ) + 1.
        ENDIF.
        ls_fefo_balance-batch = ls_batch_stock-batch.
        ls_fefo_balance-expiration_date = ls_batch_stock-expiration_date.
        ls_fefo_balance-sort_expiration_date =
          ls_batch_stock-expiration_date.
        IF ls_fefo_balance-sort_expiration_date IS INITIAL.
          ls_fefo_balance-sort_expiration_date = '99991231'.
        ENDIF.
        ls_fefo_balance-remaining_quantity =
          ls_batch_stock-available_quantity.
        IF ls_fefo_balance-remaining_quantity < 0.
          CLEAR ls_fefo_balance-remaining_quantity.
        ENDIF.
        APPEND ls_fefo_balance TO lt_fefo_balances.
      ENDLOOP.

      INSERT VALUE #(
        material = ls_demand-material
        plant    = ls_source-source_plant )
        INTO TABLE lt_loaded_stock_keys.

      IF iv_protect_safety_stock = abap_true.
        lv_safety_stock = mo_stock_repository->get_safety_stock(
          iv_material = ls_demand-material
          iv_plant    = ls_source-source_plant ).
        CLEAR lv_earliest_required_date.
        LOOP AT it_demands INTO ls_safety_demand
          WHERE material = ls_demand-material.
          READ TABLE it_sources TRANSPORTING NO FIELDS
            WITH KEY request_id = ls_safety_demand-request_id
                     source_plant = ls_source-source_plant.
          IF sy-subrc = 0
              AND ( lv_earliest_required_date IS INITIAL
                OR ls_safety_demand-required_date
                  < lv_earliest_required_date ).
            lv_earliest_required_date = ls_safety_demand-required_date.
          ENDIF.
        ENDLOOP.

        IF lv_safety_stock > 0
            AND lv_earliest_required_date IS NOT INITIAL.
          SORT lt_fefo_balances BY material plant
            sort_expiration_date DESCENDING batch storage_location.
          LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant.
            IF lv_safety_stock <= 0.
              EXIT.
            ENDIF.
            IF lo_eligibility->is_eligible(
                iv_expiration_date         = <ls_fefo_balance>-expiration_date
                iv_as_of_date              = lv_earliest_required_date
                iv_min_days                = iv_min_days
                iv_include_undated_batches =
                  iv_include_undated_batches ) = abap_false
                OR <ls_fefo_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.
            IF lv_safety_stock < <ls_fefo_balance>-remaining_quantity.
              <ls_fefo_balance>-remaining_quantity =
                <ls_fefo_balance>-remaining_quantity - lv_safety_stock.
              CLEAR lv_safety_stock.
            ELSE.
              lv_safety_stock = lv_safety_stock
                - <ls_fefo_balance>-remaining_quantity.
              CLEAR <ls_fefo_balance>-remaining_quantity.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
      SORT lt_fefo_balances BY material plant sort_expiration_date
        batch location_priority storage_location.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_demand_index).
      CLEAR lv_available_quantity.
      LOOP AT it_sources INTO ls_source
        WHERE request_id = ls_demand_index-request_id.
        LOOP AT lt_fefo_balances INTO ls_fefo_balance
          WHERE material = ls_demand_index-material
            AND plant = ls_source-source_plant.
          IF it_source_locations IS NOT INITIAL
              AND NOT line_exists( lt_source_locations[
                request_id = ls_demand_index-request_id
                source_plant = ls_source-source_plant
                storage_location = ls_fefo_balance-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lo_eligibility->is_eligible(
              iv_expiration_date         = ls_fefo_balance-expiration_date
              iv_as_of_date              = ls_demand_index-required_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) = abap_true.
            lv_available_quantity = lv_available_quantity
              + ls_fefo_balance-remaining_quantity.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      lv_remaining_quantity = ls_demand_index-requested_quantity.
      LOOP AT it_sources INTO ls_source
        WHERE request_id = ls_demand_index-request_id.
        IF iv_require_full_quantity = abap_true
            AND ls_demand_index-requested_quantity > lv_available_quantity.
          EXIT.
        ENDIF.
        lv_source_order = sy-tabix.
        CLEAR ls_source_allocation.
        ls_source_allocation-request_id = ls_demand_index-request_id.
        ls_source_allocation-material = ls_demand_index-material.
        ls_source_allocation-target_plant = ls_demand_index-target_plant.
        ls_source_allocation-source_plant = ls_source-source_plant.
        ls_source_allocation-required_date = ls_demand_index-required_date.
        ls_source_allocation-priority = ls_demand_index-priority.
        CLEAR lv_source_available_quantity.
        LOOP AT lt_fefo_balances INTO ls_fefo_balance
          WHERE material = ls_demand_index-material
            AND plant = ls_source-source_plant.
          IF it_source_locations IS NOT INITIAL
              AND NOT line_exists( lt_source_locations[
                request_id = ls_demand_index-request_id
                source_plant = ls_source-source_plant
                storage_location = ls_fefo_balance-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lo_eligibility->is_eligible(
              iv_expiration_date         = ls_fefo_balance-expiration_date
              iv_as_of_date              = ls_demand_index-required_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) = abap_true.
            lv_source_available_quantity = lv_source_available_quantity
              + ls_fefo_balance-remaining_quantity.
          ENDIF.
        ENDLOOP.
        ls_source_allocation-available_quantity =
          lv_source_available_quantity.

        CLEAR lv_batch_order.
        LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
          WHERE material = ls_demand_index-material
            AND plant = ls_source-source_plant.
          IF it_source_locations IS NOT INITIAL
              AND NOT line_exists( lt_source_locations[
                request_id = ls_demand_index-request_id
                source_plant = ls_source-source_plant
                storage_location = <ls_fefo_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.
          IF lo_eligibility->is_eligible(
              iv_expiration_date         = <ls_fefo_balance>-expiration_date
              iv_as_of_date              = ls_demand_index-required_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) = abap_false
              OR <ls_fefo_balance>-remaining_quantity <= 0.
            CONTINUE.
          ENDIF.

          lv_allocated_quantity = COND #(
            WHEN lv_remaining_quantity
              < <ls_fefo_balance>-remaining_quantity
            THEN lv_remaining_quantity
            ELSE <ls_fefo_balance>-remaining_quantity ).
          CLEAR ls_batch_allocation.
          ls_batch_allocation-request_id = ls_demand_index-request_id.
          ls_batch_allocation-material = ls_demand_index-material.
          ls_batch_allocation-target_plant = ls_demand_index-target_plant.
          ls_batch_allocation-source_plant = ls_source-source_plant.
          ls_batch_allocation-storage_location =
            <ls_fefo_balance>-storage_location.
          ls_batch_allocation-batch = <ls_fefo_balance>-batch.
          ls_batch_allocation-expiration_date =
            <ls_fefo_balance>-expiration_date.
          ls_batch_allocation-available_quantity =
            <ls_fefo_balance>-remaining_quantity.
          ls_batch_allocation-allocated_quantity = lv_allocated_quantity.
          ls_date_batch_allocation-required_date =
            ls_demand_index-required_date.
          ls_date_batch_allocation-priority = ls_demand_index-priority.
          ls_date_batch_allocation-allocation = ls_batch_allocation.
          lv_batch_order = lv_batch_order + 1.
          APPEND VALUE #(
            source_index = ls_demand_index-source_index
            source_order = lv_source_order
            batch_order  = lv_batch_order
            allocation   = ls_date_batch_allocation )
            TO lt_indexed_batch_allocations.

          <ls_fefo_balance>-remaining_quantity =
            <ls_fefo_balance>-remaining_quantity - lv_allocated_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - lv_allocated_quantity.
          ls_source_allocation-allocated_quantity =
            ls_source_allocation-allocated_quantity + lv_allocated_quantity.
        ENDLOOP.

        IF ls_source_allocation-allocated_quantity > 0.
          APPEND VALUE #(
            source_index = ls_demand_index-source_index
            source_order = lv_source_order
            allocation   = ls_source_allocation )
            TO lt_indexed_source_allocations.
        ENDIF.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.
      ENDLOOP.

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand_index-request_id.
      ls_allocation-material = ls_demand_index-material.
      ls_allocation-target_plant = ls_demand_index-target_plant.
      ls_allocation-required_date = ls_demand_index-required_date.
      ls_allocation-priority = ls_demand_index-priority.
      ls_allocation-requested_quantity =
        ls_demand_index-requested_quantity.
      ls_allocation-available_quantity = lv_available_quantity.
      ls_allocation-allocated_quantity =
        ls_demand_index-requested_quantity - lv_remaining_quantity.
      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND VALUE #(
        source_index = ls_demand_index-source_index
        allocation   = ls_allocation ) TO lt_indexed_allocations.
    ENDLOOP.

    SORT lt_indexed_allocations BY source_index.
    LOOP AT lt_indexed_allocations INTO DATA(ls_indexed_allocation).
      APPEND ls_indexed_allocation-allocation TO rs_result-allocations.
    ENDLOOP.
    SORT lt_indexed_source_allocations BY source_index source_order.
    LOOP AT lt_indexed_source_allocations INTO DATA(ls_indexed_source).
      APPEND ls_indexed_source-allocation TO rs_result-plant_allocations.
    ENDLOOP.
    SORT lt_indexed_batch_allocations BY source_index source_order batch_order.
    LOOP AT lt_indexed_batch_allocations INTO DATA(ls_indexed_batch).
      APPEND ls_indexed_batch-allocation TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_fefo_date_uom.
    DATA lt_base_demands TYPE ty_date_plant_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_date_plant_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_date_plant_source_allocation.
    DATA ls_unit_batch TYPE ty_unit_date_plant_fefo_batch_split.

    IF it_demands IS INITIAL
        OR it_sources IS INITIAL
        OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit     = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio ) INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).
      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        required_date      = ls_demand-required_date
        priority           = ls_demand-priority
        requested_quantity = lv_base_quantity ) TO lt_base_demands.

      CLEAR ls_context.
      ls_context-request_id = ls_demand-request_id.
      ls_context-source_quantity = ls_demand-requested_quantity.
      ls_context-source_unit = ls_demand-requested_unit.
      ls_context-base_quantity = lv_base_quantity.
      ls_context-ratio = ls_unit_ratio.
      APPEND ls_context TO lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_plants_fefo_by_date(
      it_demands                   = lt_base_demands
      it_sources                   = it_sources
      iv_min_days                  = iv_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_allocation.
      ls_unit_allocation-allocation = ls_base_allocation.
      ls_unit_allocation-source_quantity = ls_context-source_quantity.
      ls_unit_allocation-source_unit = ls_context-source_unit.
      ls_unit_allocation-base_quantity = ls_context-base_quantity.
      ls_unit_allocation-base_unit = ls_context-ratio-base_unit.
      ls_unit_allocation-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-shortfall_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-shortfall_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations
      INTO DATA(ls_base_source_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_source_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_source.
      ls_unit_source-allocation = ls_base_source_allocation.
      ls_unit_source-source_unit = ls_context-source_unit.
      ls_unit_source-base_unit = ls_context-ratio-base_unit.
      ls_unit_source-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_source-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_source TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT ls_base_result-batch_allocations INTO DATA(ls_base_batch).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_batch-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_batch.
      ls_unit_batch-allocation = ls_base_batch.
      ls_unit_batch-source_unit = ls_context-source_unit.
      ls_unit_batch-base_unit = ls_context-ratio-base_unit.
      ls_unit_batch-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_batch-allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_batch-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_batch-allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_batch TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_fefo_date_atp.
    DATA lt_atp_days TYPE ty_dated_atp_days.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    FIELD-SYMBOLS <ls_atp_day> TYPE ty_dated_atp_day.

    IF iv_check_rule IS INITIAL
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = allocate_plants_fefo_date_uom(
      it_demands                   = it_demands
      it_sources                   = it_sources
      iv_min_days                  = iv_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          plant = ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      IF sy-subrc = 0.
        <ls_atp_day>-demand_quantity = <ls_atp_day>-demand_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          material        = ls_source_allocation-allocation-material
          plant           = ls_source_allocation-allocation-source_plant
          base_unit       = ls_source_allocation-base_unit
          required_date   =
            ls_source_allocation-allocation-required_date
          demand_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_atp_days.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      IF sy-tabix = 1
          OR <ls_atp_day>-material <> lv_previous_material
          OR <ls_atp_day>-plant <> lv_previous_plant
          OR <ls_atp_day>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      lv_cumulative_quantity = lv_cumulative_quantity
        + <ls_atp_day>-demand_quantity.
      <ls_atp_day>-cumulative_quantity = lv_cumulative_quantity.
      <ls_atp_day>-atp_result = check_atp_request(
        is_request = VALUE #(
          material           = <ls_atp_day>-material
          plant              = <ls_atp_day>-plant
          unit               = <ls_atp_day>-base_unit
          check_rule         = iv_check_rule
          required_date      = <ls_atp_day>-required_date
          requested_quantity = lv_cumulative_quantity ) ).
      lv_previous_material = <ls_atp_day>-material.
      lv_previous_plant = <ls_atp_day>-plant.
      lv_previous_unit = <ls_atp_day>-base_unit.
    ENDLOOP.

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO ls_source_allocation.
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_days INTO DATA(ls_atp_day)
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          plant = ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      DATA(ls_confirmation_quantities) = get_atp_confirmation_split(
        iv_requested_base_quantity = ls_atp_day-cumulative_quantity
        iv_required_date           =
          ls_source_allocation-allocation-required_date
        is_atp_result              = ls_atp_day-atp_result ).
      APPEND VALUE #(
        request_id                = ls_source_allocation-allocation-request_id
        material                  = ls_source_allocation-allocation-material
        target_plant              = ls_source_allocation-allocation-target_plant
        source_plant              = ls_source_allocation-allocation-source_plant
        required_date             =
          ls_source_allocation-allocation-required_date
        base_unit                 = ls_source_allocation-base_unit
        allocated_base_quantity   =
          ls_source_allocation-allocation-allocated_quantity
        cumulative_base_quantity  = ls_atp_day-cumulative_quantity
        confirmed_base_quantity   =
          ls_confirmation_quantities-confirmed_base_quantity
        unconfirmed_base_quantity =
          ls_confirmation_quantities-unconfirmed_base_quantity
        atp_result                = ls_atp_day-atp_result )
        TO rs_result-atp_checks.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_by_batch.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_batch_balances TYPE ty_batch_balances.
    DATA lt_location_sequence TYPE ty_storage_locations.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_batch_balance TYPE ty_batch_balance.
    DATA ls_allocation TYPE ty_plant_batch_demand_allocation.
    DATA ls_source_allocation TYPE ty_plant_batch_source_allocation.
    DATA ls_location_allocation TYPE ty_plant_batch_location_allocation.
    DATA lt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA lv_available_quantity TYPE mard-labst.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_allocated_quantity TYPE mard-labst.
    DATA lv_plant_available_quantity TYPE mard-labst.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lv_priority_location TYPE mard-lgort.
    DATA lv_storage_location TYPE mard-lgort.
    FIELD-SYMBOLS <ls_batch_balance> TYPE ty_batch_balance.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-batch IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.
    ENDLOOP.

    LOOP AT it_sources INTO DATA(ls_source).
      IF ls_source-request_id IS INITIAL
          OR ls_source-source_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_source_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id
                       source_plant = ls_source-source_plant.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id   = ls_source-request_id
        source_plant = ls_source-source_plant ) INTO TABLE lt_source_keys.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE it_sources TRANSPORTING NO FIELDS
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-target_plant = ls_demand-target_plant.
      ls_allocation-batch = ls_demand-batch.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.
      lv_available_quantity = 0.
      lv_remaining_quantity = ls_demand-requested_quantity.

      LOOP AT it_sources INTO ls_source
        WHERE request_id = ls_demand-request_id.
        READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_source-source_plant.
        IF sy-subrc <> 0.
          lt_batch_stock = mo_stock_repository->get_stock_by_batch(
            iv_material = ls_demand-material
            iv_plant    = ls_source-source_plant ).
          LOOP AT lt_batch_stock INTO DATA(ls_batch_stock).
            CLEAR ls_batch_balance.
            ls_batch_balance-material = ls_demand-material.
            ls_batch_balance-plant = ls_source-source_plant.
            ls_batch_balance-storage_location =
              ls_batch_stock-storage_location.
            ls_batch_balance-batch = ls_batch_stock-batch.
            ls_batch_balance-expiration_date =
              ls_batch_stock-expiration_date.
            ls_batch_balance-remaining_quantity =
              ls_batch_stock-available_quantity.
            IF ls_batch_balance-remaining_quantity < 0.
              CLEAR ls_batch_balance-remaining_quantity.
            ENDIF.
            INSERT ls_batch_balance INTO TABLE lt_batch_balances.
          ENDLOOP.

          IF iv_protect_safety_stock = abap_true.
            lv_safety_stock = mo_stock_repository->get_safety_stock(
              iv_material = ls_demand-material
              iv_plant    = ls_source-source_plant ).
            LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
              WHERE material = ls_demand-material
                AND plant = ls_source-source_plant.
              IF lv_safety_stock <= 0.
                EXIT.
              ENDIF.
              IF <ls_batch_balance>-remaining_quantity <= 0.
                CONTINUE.
              ENDIF.
              IF lv_safety_stock <
                  <ls_batch_balance>-remaining_quantity.
                <ls_batch_balance>-remaining_quantity =
                  <ls_batch_balance>-remaining_quantity - lv_safety_stock.
                CLEAR lv_safety_stock.
              ELSE.
                lv_safety_stock = lv_safety_stock
                  - <ls_batch_balance>-remaining_quantity.
                CLEAR <ls_batch_balance>-remaining_quantity.
              ENDIF.
            ENDLOOP.
          ENDIF.

          ls_loaded_stock_key-material = ls_demand-material.
          ls_loaded_stock_key-plant = ls_source-source_plant.
          INSERT ls_loaded_stock_key INTO TABLE lt_loaded_stock_keys.
        ENDIF.

        LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
          WHERE material = ls_demand-material
            AND plant = ls_source-source_plant
            AND batch = ls_demand-batch.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = <ls_batch_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lt_source_location_set IS NOT INITIAL
              AND NOT line_exists( lt_source_location_set[
                request_id = ls_demand-request_id
                source_plant = ls_source-source_plant
                storage_location =
                  <ls_batch_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          lv_available_quantity = lv_available_quantity
            + <ls_batch_balance>-remaining_quantity.
        ENDLOOP.
      ENDLOOP.

      IF ls_demand-requested_quantity > 0
          AND ( iv_require_full_quantity = abap_false
            OR ls_demand-requested_quantity <= lv_available_quantity ).
        LOOP AT it_sources INTO ls_source
          WHERE request_id = ls_demand-request_id.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.

          CLEAR ls_source_allocation.
          ls_source_allocation-request_id = ls_demand-request_id.
          ls_source_allocation-material = ls_demand-material.
          ls_source_allocation-target_plant = ls_demand-target_plant.
          ls_source_allocation-source_plant = ls_source-source_plant.
          ls_source_allocation-batch = ls_demand-batch.
          lv_plant_available_quantity = 0.

          LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant
              AND batch = ls_demand-batch.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = <ls_batch_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location =
                    <ls_batch_balance>-storage_location ] ).
              CONTINUE.
            ENDIF.
            lv_plant_available_quantity = lv_plant_available_quantity
              + <ls_batch_balance>-remaining_quantity.
          ENDLOOP.
          ls_source_allocation-available_quantity =
            lv_plant_available_quantity.

          CLEAR lt_location_sequence.
          LOOP AT it_storage_location_priority INTO lv_priority_location.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = lv_priority_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location = lv_priority_location ] ).
              CONTINUE.
            ENDIF.
            READ TABLE lt_batch_balances TRANSPORTING NO FIELDS
              WITH TABLE KEY material = ls_demand-material
                             plant = ls_source-source_plant
                             storage_location = lv_priority_location
                             batch = ls_demand-batch.
            IF sy-subrc = 0.
              APPEND lv_priority_location TO lt_location_sequence.
            ENDIF.
          ENDLOOP.
          LOOP AT lt_batch_balances INTO ls_batch_balance
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant
              AND batch = ls_demand-batch.
            IF lt_allowed_location_set IS NOT INITIAL
                AND NOT line_exists( lt_allowed_location_set[
                  table_line = ls_batch_balance-storage_location ] ).
              CONTINUE.
            ENDIF.
            IF lt_source_location_set IS NOT INITIAL
                AND NOT line_exists( lt_source_location_set[
                  request_id = ls_demand-request_id
                  source_plant = ls_source-source_plant
                  storage_location = ls_batch_balance-storage_location ] ).
              CONTINUE.
            ENDIF.
            READ TABLE lt_location_sequence TRANSPORTING NO FIELDS
              WITH KEY table_line = ls_batch_balance-storage_location.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
            APPEND ls_batch_balance-storage_location TO lt_location_sequence.
          ENDLOOP.

          LOOP AT lt_location_sequence INTO lv_storage_location.
            IF lv_remaining_quantity <= 0.
              EXIT.
            ENDIF.
            READ TABLE lt_batch_balances ASSIGNING <ls_batch_balance>
              WITH TABLE KEY material = ls_demand-material
                             plant = ls_source-source_plant
                             storage_location = lv_storage_location
                             batch = ls_demand-batch.
            IF sy-subrc <> 0
                OR <ls_batch_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.

            IF lv_remaining_quantity <
                <ls_batch_balance>-remaining_quantity.
              lv_allocated_quantity = lv_remaining_quantity.
            ELSE.
              lv_allocated_quantity =
                <ls_batch_balance>-remaining_quantity.
            ENDIF.

            CLEAR ls_location_allocation.
            ls_location_allocation-request_id = ls_demand-request_id.
            ls_location_allocation-material = ls_demand-material.
            ls_location_allocation-target_plant = ls_demand-target_plant.
            ls_location_allocation-source_plant = ls_source-source_plant.
            ls_location_allocation-storage_location = lv_storage_location.
            ls_location_allocation-batch = <ls_batch_balance>-batch.
            ls_location_allocation-expiration_date =
              <ls_batch_balance>-expiration_date.
            ls_location_allocation-available_quantity =
              <ls_batch_balance>-remaining_quantity.
            ls_location_allocation-allocated_quantity =
              lv_allocated_quantity.
            APPEND ls_location_allocation
              TO rs_result-location_allocations.

            <ls_batch_balance>-remaining_quantity =
              <ls_batch_balance>-remaining_quantity
              - lv_allocated_quantity.
            lv_remaining_quantity = lv_remaining_quantity
              - lv_allocated_quantity.
            ls_source_allocation-allocated_quantity =
              ls_source_allocation-allocated_quantity
              + lv_allocated_quantity.
          ENDLOOP.

          IF ls_source_allocation-allocated_quantity > 0.
            APPEND ls_source_allocation TO rs_result-plant_allocations.
          ENDIF.
        ENDLOOP.
      ENDIF.

      ls_allocation-available_quantity = lv_available_quantity.
      ls_allocation-allocated_quantity = ls_demand-requested_quantity
        - lv_remaining_quantity.
      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_batch_by_date.
    TYPES:
      BEGIN OF ty_sorted_batch_demand,
        required_date TYPE resb-bdter,
        priority      TYPE i,
        input_index   TYPE i,
        demand        TYPE ty_plant_batch_demand,
      END OF ty_sorted_batch_demand.
    DATA lt_sorted_demands TYPE STANDARD TABLE OF ty_sorted_batch_demand
      WITH EMPTY KEY.
    DATA lt_base_demands TYPE ty_plant_batch_demands.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA ls_demand TYPE ty_date_plant_batch_demand.
    DATA ls_base_allocation TYPE ty_plant_batch_demand_allocation.
    DATA ls_base_source TYPE ty_plant_batch_source_allocation.
    DATA ls_base_location TYPE ty_plant_batch_location_allocation.
    DATA ls_date_demand_allocation TYPE
      ty_date_plant_batch_demand_allocation.
    DATA ls_date_source_allocation TYPE
      ty_date_plant_batch_source_allocation.
    DATA ls_date_location_allocation TYPE
      ty_date_plant_batch_location_allocation.
    DATA lv_input_index TYPE i.

    IF ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).

    LOOP AT it_demands INTO ls_demand.
      lv_input_index = sy-tabix.
      IF ls_demand-required_date IS INITIAL
          OR ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-batch IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.

      APPEND VALUE #(
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        input_index   = lv_input_index
        demand        = VALUE #(
          request_id         = ls_demand-request_id
          material           = ls_demand-material
          target_plant       = ls_demand-target_plant
          batch              = ls_demand-batch
          requested_quantity = ls_demand-requested_quantity ) )
        TO lt_sorted_demands.
    ENDLOOP.

    SORT lt_sorted_demands BY required_date ASCENDING
                              priority DESCENDING
                              input_index ASCENDING.
    LOOP AT lt_sorted_demands INTO DATA(ls_sorted_demand).
      APPEND ls_sorted_demand-demand TO lt_base_demands.
    ENDLOOP.

    DATA(ls_base_result) = allocate_plants_by_batch(
      it_demands                   = lt_base_demands
      it_sources                   = it_sources
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_base_result-allocations INTO ls_base_allocation
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR ls_date_demand_allocation.
      ls_date_demand_allocation-request_id = ls_base_allocation-request_id.
      ls_date_demand_allocation-material = ls_base_allocation-material.
      ls_date_demand_allocation-target_plant =
        ls_base_allocation-target_plant.
      ls_date_demand_allocation-required_date = ls_demand-required_date.
      ls_date_demand_allocation-priority = ls_demand-priority.
      ls_date_demand_allocation-batch = ls_base_allocation-batch.
      ls_date_demand_allocation-requested_quantity =
        ls_base_allocation-requested_quantity.
      ls_date_demand_allocation-available_quantity =
        ls_base_allocation-available_quantity.
      ls_date_demand_allocation-allocated_quantity =
        ls_base_allocation-allocated_quantity.
      ls_date_demand_allocation-shortfall_quantity =
        ls_base_allocation-shortfall_quantity.
      APPEND ls_date_demand_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations INTO ls_base_source.
      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_base_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR ls_date_source_allocation.
      ls_date_source_allocation-request_id = ls_base_source-request_id.
      ls_date_source_allocation-material = ls_base_source-material.
      ls_date_source_allocation-target_plant = ls_base_source-target_plant.
      ls_date_source_allocation-source_plant = ls_base_source-source_plant.
      ls_date_source_allocation-required_date = ls_demand-required_date.
      ls_date_source_allocation-priority = ls_demand-priority.
      ls_date_source_allocation-batch = ls_base_source-batch.
      ls_date_source_allocation-available_quantity =
        ls_base_source-available_quantity.
      ls_date_source_allocation-allocated_quantity =
        ls_base_source-allocated_quantity.
      APPEND ls_date_source_allocation TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT ls_base_result-location_allocations INTO ls_base_location.
      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_base_location-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR ls_date_location_allocation.
      ls_date_location_allocation-request_id = ls_base_location-request_id.
      ls_date_location_allocation-material = ls_base_location-material.
      ls_date_location_allocation-target_plant =
        ls_base_location-target_plant.
      ls_date_location_allocation-source_plant =
        ls_base_location-source_plant.
      ls_date_location_allocation-storage_location =
        ls_base_location-storage_location.
      ls_date_location_allocation-required_date = ls_demand-required_date.
      ls_date_location_allocation-priority = ls_demand-priority.
      ls_date_location_allocation-batch = ls_base_location-batch.
      ls_date_location_allocation-expiration_date =
        ls_base_location-expiration_date.
      ls_date_location_allocation-available_quantity =
        ls_base_location-available_quantity.
      ls_date_location_allocation-allocated_quantity =
        ls_base_location-allocated_quantity.
      APPEND ls_date_location_allocation TO rs_result-location_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_date_batch_uom.
    DATA lt_base_demands TYPE ty_date_plant_batch_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_demand TYPE ty_unit_date_plant_batch_demand_alloc.
    DATA ls_unit_source TYPE ty_unit_date_plant_batch_source_alloc.
    DATA ls_unit_location TYPE ty_unit_date_plant_batch_location.

    IF ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-batch IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio ) INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).
      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        required_date      = ls_demand-required_date
        priority           = ls_demand-priority
        batch              = ls_demand-batch
        requested_quantity = lv_base_quantity ) TO lt_base_demands.

      CLEAR ls_context.
      ls_context-request_id = ls_demand-request_id.
      ls_context-source_quantity = ls_demand-requested_quantity.
      ls_context-source_unit = ls_demand-requested_unit.
      ls_context-base_quantity = lv_base_quantity.
      ls_context-ratio = ls_unit_ratio.
      APPEND ls_context TO lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_plants_batch_by_date(
      it_demands                   = lt_base_demands
      it_sources                   = it_sources
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_demand).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR ls_unit_demand.
      ls_unit_demand-allocation = ls_base_demand.
      ls_unit_demand-source_quantity = ls_context-source_quantity.
      ls_unit_demand-source_unit = ls_context-source_unit.
      ls_unit_demand-base_quantity = ls_context-base_quantity.
      ls_unit_demand-base_unit = ls_context-ratio-base_unit.
      ls_unit_demand-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_demand-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_demand-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_demand-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_demand-shortfall_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_demand-shortfall_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_demand TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations INTO DATA(ls_base_source).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_source-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR ls_unit_source.
      ls_unit_source-allocation = ls_base_source.
      ls_unit_source-source_unit = ls_context-source_unit.
      ls_unit_source-base_unit = ls_context-ratio-base_unit.
      ls_unit_source-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_source-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_source TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT ls_base_result-location_allocations INTO DATA(ls_base_location).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_location-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR ls_unit_location.
      ls_unit_location-allocation = ls_base_location.
      ls_unit_location-source_unit = ls_context-source_unit.
      ls_unit_location-base_unit = ls_context-ratio-base_unit.
      ls_unit_location-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_location-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_location-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_location-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_location TO rs_result-location_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_date_batch_atp.
    DATA lt_atp_days TYPE ty_dated_atp_days.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    DATA ls_atp_day TYPE ty_dated_atp_day.
    FIELD-SYMBOLS <ls_atp_day> TYPE ty_dated_atp_day.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = allocate_plants_date_batch_uom(
      it_demands                   = it_demands
      it_sources                   = it_sources
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          plant = ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      IF sy-subrc = 0.
        <ls_atp_day>-demand_quantity = <ls_atp_day>-demand_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          material        = ls_source_allocation-allocation-material
          plant           = ls_source_allocation-allocation-source_plant
          base_unit       = ls_source_allocation-base_unit
          required_date   =
            ls_source_allocation-allocation-required_date
          demand_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_atp_days.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      IF sy-tabix = 1
          OR <ls_atp_day>-material <> lv_previous_material
          OR <ls_atp_day>-plant <> lv_previous_plant
          OR <ls_atp_day>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      lv_cumulative_quantity = lv_cumulative_quantity
        + <ls_atp_day>-demand_quantity.
      <ls_atp_day>-cumulative_quantity = lv_cumulative_quantity.
      <ls_atp_day>-atp_result = check_atp_request(
        is_request = VALUE #(
          material           = <ls_atp_day>-material
          plant              = <ls_atp_day>-plant
          unit               = <ls_atp_day>-base_unit
          check_rule         = iv_check_rule
          required_date      = <ls_atp_day>-required_date
          requested_quantity = lv_cumulative_quantity ) ).
      lv_previous_material = <ls_atp_day>-material.
      lv_previous_plant = <ls_atp_day>-plant.
      lv_previous_unit = <ls_atp_day>-base_unit.
    ENDLOOP.

    LOOP AT lt_atp_days INTO ls_atp_day.
      DATA(ls_confirmation_split) = get_atp_confirmation_split(
        iv_requested_base_quantity = ls_atp_day-cumulative_quantity
        iv_required_date           = ls_atp_day-required_date
        is_atp_result              = ls_atp_day-atp_result ).
      APPEND VALUE #(
        material                  = ls_atp_day-material
        source_plant              = ls_atp_day-plant
        check_date                = ls_atp_day-required_date
        base_unit                 = ls_atp_day-base_unit
        allocated_base_quantity   = ls_atp_day-demand_quantity
        cumulative_base_quantity  = ls_atp_day-cumulative_quantity
        confirmed_base_quantity   =
          ls_confirmation_split-confirmed_base_quantity
        unconfirmed_base_quantity =
          ls_confirmation_split-unconfirmed_base_quantity
        atp_result                = ls_atp_day-atp_result )
        TO rs_result-atp_checks.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_batch_in_units.
    DATA lt_base_demands TYPE ty_plant_batch_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_plant_batch_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_plant_batch_source_allocation.
    DATA ls_unit_location TYPE ty_unit_plant_batch_location_allocation.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).

    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-batch IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio ) INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        batch              = ls_demand-batch
        requested_quantity = lv_base_quantity ) TO lt_base_demands.
      CLEAR ls_context.
      ls_context-request_id = ls_demand-request_id.
      ls_context-source_quantity = ls_demand-requested_quantity.
      ls_context-source_unit = ls_demand-requested_unit.
      ls_context-base_quantity = lv_base_quantity.
      ls_context-ratio = ls_unit_ratio.
      APPEND ls_context TO lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_plants_by_batch(
      it_demands                   = lt_base_demands
      it_sources                   = it_sources
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_protect_safety_stock      = iv_protect_safety_stock
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations
      INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_allocation.
      ls_unit_allocation-allocation = ls_base_allocation.
      ls_unit_allocation-source_quantity = ls_context-source_quantity.
      ls_unit_allocation-source_unit = ls_context-source_unit.
      ls_unit_allocation-base_quantity = ls_context-base_quantity.
      ls_unit_allocation-base_unit = ls_context-ratio-base_unit.
      ls_unit_allocation-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-shortfall_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-shortfall_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations
      INTO DATA(ls_base_source_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_source_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_source.
      ls_unit_source-allocation = ls_base_source_allocation.
      ls_unit_source-source_unit = ls_context-source_unit.
      ls_unit_source-base_unit = ls_context-ratio-base_unit.
      ls_unit_source-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_source-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_source TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT ls_base_result-location_allocations
      INTO DATA(ls_base_location_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_location_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_location.
      ls_unit_location-allocation = ls_base_location_allocation.
      ls_unit_location-source_unit = ls_context-source_unit.
      ls_unit_location-base_unit = ls_context-ratio-base_unit.
      ls_unit_location-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_location_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_location-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_location_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_location TO rs_result-location_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_in_units.
    DATA lt_base_demands TYPE ty_plant_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_plant_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_plant_source_allocation.
    DATA ls_unit_location TYPE ty_unit_plant_location_allocation.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).

    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio ) INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        requested_quantity = lv_base_quantity ) TO lt_base_demands.
      CLEAR ls_context.
      ls_context-request_id = ls_demand-request_id.
      ls_context-source_quantity = ls_demand-requested_quantity.
      ls_context-source_unit = ls_demand-requested_unit.
      ls_context-base_quantity = lv_base_quantity.
      ls_context-ratio = ls_unit_ratio.
      APPEND ls_context TO lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_across_plants(
      it_demands                   = lt_base_demands
      it_sources                   = it_sources
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_protect_safety_stock      = iv_protect_safety_stock
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_contexts INTO ls_context INDEX sy-tabix.
      READ TABLE ls_base_result-allocations
        INTO DATA(ls_base_allocation) INDEX sy-tabix.

      CLEAR ls_unit_allocation.
      ls_unit_allocation-allocation = ls_base_allocation.
      ls_unit_allocation-source_quantity = ls_context-source_quantity.
      ls_unit_allocation-source_unit = ls_context-source_unit.
      ls_unit_allocation-base_quantity = ls_context-base_quantity.
      ls_unit_allocation-base_unit = ls_context-ratio-base_unit.
      ls_unit_allocation-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-shortfall_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-shortfall_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations
      INTO DATA(ls_base_source_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_source_allocation-request_id.
      CLEAR ls_unit_source.
      ls_unit_source-allocation = ls_base_source_allocation.
      ls_unit_source-source_unit = ls_context-source_unit.
      ls_unit_source-base_unit = ls_context-ratio-base_unit.
      ls_unit_source-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_source-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_source TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT ls_base_result-location_allocations
      INTO DATA(ls_base_location_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_location_allocation-request_id.
      CLEAR ls_unit_location.
      ls_unit_location-allocation = ls_base_location_allocation.
      ls_unit_location-source_unit = ls_context-source_unit.
      ls_unit_location-base_unit = ls_context-ratio-base_unit.
      ls_unit_location-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_location_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_location-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_location_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_location TO rs_result-location_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_plants_atp.
    DATA lt_atp_checks TYPE ty_plant_atp_checks.
    FIELD-SYMBOLS <ls_atp_check> TYPE ty_plant_atp_check.

    IF iv_check_rule IS INITIAL
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = allocate_plants_in_units(
      it_demands                   = it_demands
      it_sources                   = it_sources
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_checks ASSIGNING <ls_atp_check>
        WITH KEY material = ls_source_allocation-allocation-material
                 source_plant =
                   ls_source_allocation-allocation-source_plant
                 base_unit = ls_source_allocation-base_unit.
      IF sy-subrc = 0.
        <ls_atp_check>-allocated_base_quantity =
          <ls_atp_check>-allocated_base_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        APPEND VALUE #(
          material                =
            ls_source_allocation-allocation-material
          source_plant            =
            ls_source_allocation-allocation-source_plant
          check_date              = sy-datum
          base_unit               = ls_source_allocation-base_unit
          allocated_base_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          TO lt_atp_checks.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_checks ASSIGNING <ls_atp_check>.
      <ls_atp_check>-atp_result = check_atp_request(
        is_request = VALUE #(
          material           = <ls_atp_check>-material
          plant              = <ls_atp_check>-source_plant
          unit               = <ls_atp_check>-base_unit
          check_rule         = iv_check_rule
          required_date      = <ls_atp_check>-check_date
          requested_quantity = <ls_atp_check>-allocated_base_quantity ) ).
      DATA(ls_confirmation_split) = get_atp_confirmation_split(
        iv_requested_base_quantity =
          <ls_atp_check>-allocated_base_quantity
        iv_required_date           = <ls_atp_check>-check_date
        is_atp_result              = <ls_atp_check>-atp_result ).
      <ls_atp_check>-confirmed_base_quantity =
        ls_confirmation_split-confirmed_base_quantity.
      <ls_atp_check>-unconfirmed_base_quantity =
        ls_confirmation_split-unconfirmed_base_quantity.
    ENDLOOP.
    rs_result-atp_checks = lt_atp_checks.
  ENDMETHOD.

  METHOD allocate_plants_batch_atp.
    DATA lt_atp_checks TYPE ty_plant_atp_checks.
    FIELD-SYMBOLS <ls_atp_check> TYPE ty_plant_atp_check.

    IF iv_check_rule IS INITIAL
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = allocate_plants_batch_in_units(
      it_demands                   = it_demands
      it_sources                   = it_sources
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT rs_result-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_checks ASSIGNING <ls_atp_check>
        WITH KEY material = ls_source_allocation-allocation-material
                 source_plant =
                   ls_source_allocation-allocation-source_plant
                 base_unit = ls_source_allocation-base_unit.
      IF sy-subrc = 0.
        <ls_atp_check>-allocated_base_quantity =
          <ls_atp_check>-allocated_base_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        APPEND VALUE #(
          material                =
            ls_source_allocation-allocation-material
          source_plant            =
            ls_source_allocation-allocation-source_plant
          check_date              = sy-datum
          base_unit               = ls_source_allocation-base_unit
          allocated_base_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          TO lt_atp_checks.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_checks ASSIGNING <ls_atp_check>.
      <ls_atp_check>-atp_result = check_atp_request(
        is_request = VALUE #(
          material           = <ls_atp_check>-material
          plant              = <ls_atp_check>-source_plant
          unit               = <ls_atp_check>-base_unit
          check_rule         = iv_check_rule
          required_date      = <ls_atp_check>-check_date
          requested_quantity = <ls_atp_check>-allocated_base_quantity ) ).
      DATA(ls_confirmation_split) = get_atp_confirmation_split(
        iv_requested_base_quantity =
          <ls_atp_check>-allocated_base_quantity
        iv_required_date           = <ls_atp_check>-check_date
        is_atp_result              = <ls_atp_check>-atp_result ).
      <ls_atp_check>-confirmed_base_quantity =
        ls_confirmation_split-confirmed_base_quantity.
      <ls_atp_check>-unconfirmed_base_quantity =
        ls_confirmation_split-unconfirmed_base_quantity.
    ENDLOOP.
    rs_result-atp_checks = lt_atp_checks.
  ENDMETHOD.

  METHOD allocate_plants_fefo_atp.
    DATA lt_atp_checks TYPE ty_plant_atp_checks.
    FIELD-SYMBOLS <ls_atp_check> TYPE ty_plant_atp_check.

    IF iv_check_rule IS INITIAL
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = allocate_plants_fefo_in_units(
      it_demands                   = it_demands
      it_sources                   = it_sources
      iv_as_of_date                = iv_as_of_date
      iv_min_days                  = iv_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT rs_result-local_estimate-plant_allocations
      INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_atp_checks ASSIGNING <ls_atp_check>
        WITH KEY material = ls_source_allocation-allocation-material
                 source_plant =
                   ls_source_allocation-allocation-source_plant
                 base_unit = ls_source_allocation-base_unit.
      IF sy-subrc = 0.
        <ls_atp_check>-allocated_base_quantity =
          <ls_atp_check>-allocated_base_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        APPEND VALUE #(
          material                =
            ls_source_allocation-allocation-material
          source_plant            =
            ls_source_allocation-allocation-source_plant
          check_date              = sy-datum
          base_unit               = ls_source_allocation-base_unit
          allocated_base_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          TO lt_atp_checks.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_atp_checks ASSIGNING <ls_atp_check>.
      <ls_atp_check>-atp_result = check_atp_request(
        is_request = VALUE #(
          material           = <ls_atp_check>-material
          plant              = <ls_atp_check>-source_plant
          unit               = <ls_atp_check>-base_unit
          check_rule         = iv_check_rule
          required_date      = <ls_atp_check>-check_date
          requested_quantity = <ls_atp_check>-allocated_base_quantity ) ).
      DATA(ls_confirmation_split) = get_atp_confirmation_split(
        iv_requested_base_quantity =
          <ls_atp_check>-allocated_base_quantity
        iv_required_date           = <ls_atp_check>-check_date
        is_atp_result              = <ls_atp_check>-atp_result ).
      <ls_atp_check>-confirmed_base_quantity =
        ls_confirmation_split-confirmed_base_quantity.
      <ls_atp_check>-unconfirmed_base_quantity =
        ls_confirmation_split-unconfirmed_base_quantity.
    ENDLOOP.
    rs_result-atp_checks = lt_atp_checks.
  ENDMETHOD.

  METHOD allocate_plants_fefo_in_units.
    DATA lt_base_demands TYPE ty_plant_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lt_source_location_set TYPE ty_plant_source_location_set.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_plant_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_plant_source_allocation.
    DATA ls_unit_split TYPE ty_unit_plant_fefo_split.

    IF iv_as_of_date IS INITIAL OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lt_source_location_set = build_source_location_set(
      it_sources          = it_sources
      it_source_locations = it_source_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_request_ids.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio ) INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        target_plant       = ls_demand-target_plant
        requested_quantity = lv_base_quantity ) TO lt_base_demands.
      CLEAR ls_context.
      ls_context-request_id = ls_demand-request_id.
      ls_context-source_quantity = ls_demand-requested_quantity.
      ls_context-source_unit = ls_demand-requested_unit.
      ls_context-base_quantity = lv_base_quantity.
      ls_context-ratio = ls_unit_ratio.
      APPEND ls_context TO lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_plants_by_expiry(
      it_demands                   = lt_base_demands
      it_sources                   = it_sources
      iv_as_of_date                = iv_as_of_date
      iv_min_days                  = iv_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      it_allowed_storage_locations = it_allowed_storage_locations
      it_storage_location_priority = it_storage_location_priority
      it_source_locations          = it_source_locations
      iv_protect_safety_stock      = iv_protect_safety_stock
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_allocation.
      ls_unit_allocation-allocation = ls_base_allocation.
      ls_unit_allocation-source_quantity = ls_context-source_quantity.
      ls_unit_allocation-source_unit = ls_context-source_unit.
      ls_unit_allocation-base_quantity = ls_context-base_quantity.
      ls_unit_allocation-base_unit = ls_context-ratio-base_unit.
      ls_unit_allocation-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_allocation-shortfall_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_allocation-shortfall_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-plant_allocations
      INTO DATA(ls_base_source_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_source_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_source.
      ls_unit_source-allocation = ls_base_source_allocation.
      ls_unit_source-source_unit = ls_context-source_unit.
      ls_unit_source-base_unit = ls_context-ratio-base_unit.
      ls_unit_source-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_source-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_source_allocation-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_source TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT ls_base_result-batch_allocations
      INTO DATA(ls_base_split).
      READ TABLE lt_contexts INTO ls_context
        WITH KEY request_id = ls_base_split-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_unit_split.
      ls_unit_split-allocation = ls_base_split.
      ls_unit_split-source_unit = ls_context-source_unit.
      ls_unit_split-base_unit = ls_context-ratio-base_unit.
      ls_unit_split-available_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_split-available_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      ls_unit_split-allocated_source_quantity = convert_stock_quantity(
        iv_base_quantity = ls_base_split-allocated_quantity
        iv_numerator     = ls_context-ratio-numerator
        iv_denominator   = ls_context-ratio-denominator ).
      APPEND ls_unit_split TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_storage_location.
    DATA lt_location_balances TYPE ty_location_balances.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA lt_location_sequence TYPE ty_storage_locations.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA ls_location_balance TYPE ty_location_balance.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_allocation TYPE ty_allocation.
    DATA ls_storage_allocation TYPE ty_storage_allocation.
    DATA lv_storage_location TYPE mard-lgort.
    DATA lv_priority_location TYPE mard-lgort.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    FIELD-SYMBOLS <ls_location_balance> TYPE ty_location_balance.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-storage_location IS NOT INITIAL
          AND lt_allowed_location_set IS NOT INITIAL
          AND NOT line_exists( lt_allowed_location_set[
            table_line = ls_demand-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY material = ls_demand-material
                       plant = ls_demand-plant.
      IF sy-subrc <> 0.
        lt_location_stock = mo_stock_repository->get_stock_by_location(
          iv_material = ls_demand-material
          iv_plant    = ls_demand-plant ).
        LOOP AT lt_location_stock INTO DATA(ls_location_stock).
          CLEAR ls_location_balance.
          ls_location_balance-material = ls_demand-material.
          ls_location_balance-plant = ls_demand-plant.
          ls_location_balance-storage_location =
            ls_location_stock-storage_location.
          ls_location_balance-remaining_quantity =
            ls_location_stock-available_quantity.
          IF ls_location_balance-remaining_quantity < 0.
            CLEAR ls_location_balance-remaining_quantity.
          ENDIF.
          INSERT ls_location_balance INTO TABLE lt_location_balances.
        ENDLOOP.

        IF iv_protect_safety_stock = abap_true.
          lv_safety_stock = mo_stock_repository->get_safety_stock(
            iv_material = ls_demand-material
            iv_plant    = ls_demand-plant ).
          LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
            WHERE material = ls_demand-material
              AND plant = ls_demand-plant.
            IF lv_safety_stock <= 0.
              EXIT.
            ENDIF.
            IF <ls_location_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.
            IF lv_safety_stock <
                <ls_location_balance>-remaining_quantity.
              <ls_location_balance>-remaining_quantity =
                <ls_location_balance>-remaining_quantity - lv_safety_stock.
              CLEAR lv_safety_stock.
            ELSE.
              lv_safety_stock = lv_safety_stock
                - <ls_location_balance>-remaining_quantity.
              CLEAR <ls_location_balance>-remaining_quantity.
            ENDIF.
          ENDLOOP.
        ENDIF.

        ls_loaded_stock_key-material = ls_demand-material.
        ls_loaded_stock_key-plant = ls_demand-plant.
        INSERT ls_loaded_stock_key INTO TABLE lt_loaded_stock_keys.
      ENDIF.

      CLEAR lt_location_sequence.
      IF ls_demand-storage_location IS NOT INITIAL.
        APPEND ls_demand-storage_location TO lt_location_sequence.
      ENDIF.

      IF ls_demand-storage_location IS INITIAL
          OR ls_demand-fallback_to_other_locations = abap_true.
        LOOP AT it_storage_location_priority INTO lv_priority_location.
          IF lv_priority_location = ls_demand-storage_location.
            CONTINUE.
          ENDIF.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = lv_priority_location ] ).
            CONTINUE.
          ENDIF.
          READ TABLE lt_location_balances TRANSPORTING NO FIELDS
            WITH TABLE KEY material = ls_demand-material
                           plant = ls_demand-plant
                           storage_location = lv_priority_location.
          IF sy-subrc = 0.
            APPEND lv_priority_location TO lt_location_sequence.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_location_balances INTO ls_location_balance
            WHERE material = ls_demand-material
              AND plant = ls_demand-plant.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = ls_location_balance-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF ls_location_balance-storage_location =
              ls_demand-storage_location.
            CONTINUE.
          ENDIF.
          READ TABLE lt_location_sequence TRANSPORTING NO FIELDS
            WITH KEY table_line = ls_location_balance-storage_location.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
          APPEND ls_location_balance-storage_location
            TO lt_location_sequence.
        ENDLOOP.
      ENDIF.

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-plant = ls_demand-plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.

      LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
        WHERE material = ls_demand-material
          AND plant = ls_demand-plant.
        IF lt_allowed_location_set IS NOT INITIAL
            AND NOT line_exists( lt_allowed_location_set[
              table_line = <ls_location_balance>-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF ls_demand-storage_location IS NOT INITIAL
            AND ls_demand-fallback_to_other_locations = abap_false
            AND <ls_location_balance>-storage_location
              <> ls_demand-storage_location.
          CONTINUE.
        ENDIF.
        ls_allocation-available_quantity =
          ls_allocation-available_quantity
          + <ls_location_balance>-remaining_quantity.
      ENDLOOP.

      DATA(lv_remaining_quantity) = ls_demand-requested_quantity.
      LOOP AT lt_location_sequence INTO lv_storage_location.
        IF iv_require_full_quantity = abap_true
            AND ls_demand-requested_quantity >
              ls_allocation-available_quantity.
          EXIT.
        ENDIF.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.

        READ TABLE lt_location_balances ASSIGNING <ls_location_balance>
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_demand-plant
                         storage_location = lv_storage_location.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_storage_allocation.
        ls_storage_allocation-request_id = ls_demand-request_id.
        ls_storage_allocation-material = ls_demand-material.
        ls_storage_allocation-plant = ls_demand-plant.
        ls_storage_allocation-storage_location = lv_storage_location.
        IF lv_remaining_quantity <
            <ls_location_balance>-remaining_quantity.
          ls_storage_allocation-allocated_quantity = lv_remaining_quantity.
        ELSE.
          ls_storage_allocation-allocated_quantity =
            <ls_location_balance>-remaining_quantity.
        ENDIF.

        IF ls_storage_allocation-allocated_quantity > 0.
          APPEND ls_storage_allocation TO rs_result-storage_allocations.
          lv_remaining_quantity = lv_remaining_quantity
            - ls_storage_allocation-allocated_quantity.
          <ls_location_balance>-remaining_quantity =
            <ls_location_balance>-remaining_quantity
            - ls_storage_allocation-allocated_quantity.
          ls_allocation-allocated_quantity =
            ls_allocation-allocated_quantity
            + ls_storage_allocation-allocated_quantity.
        ENDIF.
      ENDLOOP.

      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_location_order.
    DATA lt_locations TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.

    LOOP AT it_storage_location_priority INTO DATA(lv_storage_location).
      IF lv_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_storage_location INTO TABLE lt_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_allowed_location_set.
    LOOP AT it_allowed_storage_locations INTO DATA(lv_storage_location).
      IF lv_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_storage_location INTO TABLE rt_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_source_location_set.
    LOOP AT it_source_locations INTO DATA(ls_source_location).
      IF ls_source_location-request_id IS INITIAL
          OR ls_source_location-source_plant IS INITIAL
          OR ls_source_location-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE it_sources TRANSPORTING NO FIELDS
        WITH KEY request_id = ls_source_location-request_id
                 source_plant = ls_source_location-source_plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_source_location INTO TABLE rt_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_source_locations IS INITIAL.
      RETURN.
    ENDIF.
    LOOP AT it_sources INTO DATA(ls_source).
      READ TABLE rt_locations TRANSPORTING NO FIELDS
        WITH TABLE KEY request_id = ls_source-request_id
                       source_plant = ls_source-source_plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_location_in_units.
    DATA lt_base_demands TYPE ty_demands.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_contexts TYPE ty_unit_allocation_contexts.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_unit_allocation_context.
    DATA lv_demand_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-storage_location IS NOT INITIAL
          AND lt_allowed_location_set IS NOT INITIAL
          AND NOT line_exists( lt_allowed_location_set[
            table_line = ls_demand-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit     = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio )
          INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      ADD 1 TO lv_demand_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_demand_index.
      APPEND VALUE #(
        request_id                  = lv_internal_request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations = ls_demand-fallback_to_other_locations
        requested_quantity          = lv_base_quantity )
        TO lt_base_demands.
      INSERT VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        source_quantity     = ls_demand-requested_quantity
        source_unit         = ls_demand-requested_unit
        base_quantity       = lv_base_quantity
        ratio               = ls_unit_ratio )
        INTO TABLE lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_by_storage_location(
      it_demands                   = lt_base_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_protect_safety_stock      = iv_protect_safety_stock
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH TABLE KEY internal_request_id = ls_base_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unit_allocation) = VALUE ty_unit_allocation_summary(
        allocation                = ls_base_allocation
        source_quantity           = ls_context-source_quantity
        source_unit               = ls_context-source_unit
        base_quantity             = ls_context-base_quantity
        base_unit                 = ls_context-ratio-base_unit
        allocated_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-allocated_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator )
        shortfall_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-shortfall_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator ) ).
      ls_unit_allocation-allocation-request_id = ls_context-request_id.
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-storage_allocations
      INTO DATA(ls_base_storage_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH TABLE KEY internal_request_id =
          ls_base_storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unit_storage_split) = VALUE ty_unit_storage_split(
        storage_allocation        = ls_base_storage_allocation
        base_unit                 = ls_context-ratio-base_unit
        source_unit               = ls_context-source_unit
        allocated_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_storage_allocation-allocated_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator ) ).
      ls_unit_storage_split-storage_allocation-request_id =
        ls_context-request_id.
      APPEND ls_unit_storage_split TO rs_result-storage_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_batch.
    DATA lt_batch_balances TYPE ty_batch_balances.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_batch_balance TYPE ty_batch_balance.
    DATA ls_allocation TYPE ty_allocation.
    DATA ls_batch_allocation TYPE ty_batch_allocation.
    DATA lt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA lt_location_sequence TYPE ty_storage_locations.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lv_storage_location TYPE mard-lgort.
    DATA lv_priority_location TYPE mard-lgort.
    DATA lv_safety_stock TYPE marc-eisbe.
    FIELD-SYMBOLS <ls_batch_balance> TYPE ty_batch_balance.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-batch IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-storage_location IS NOT INITIAL
          AND lt_allowed_location_set IS NOT INITIAL
          AND NOT line_exists( lt_allowed_location_set[
            table_line = ls_demand-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY material = ls_demand-material
                       plant = ls_demand-plant.
      IF sy-subrc <> 0.
        lt_batch_stock = mo_stock_repository->get_stock_by_batch(
          iv_material = ls_demand-material
          iv_plant    = ls_demand-plant ).
        LOOP AT lt_batch_stock INTO DATA(ls_batch_stock).
          CLEAR ls_batch_balance.
          ls_batch_balance-material = ls_demand-material.
          ls_batch_balance-plant = ls_demand-plant.
          ls_batch_balance-storage_location =
            ls_batch_stock-storage_location.
          ls_batch_balance-batch = ls_batch_stock-batch.
          ls_batch_balance-expiration_date =
            ls_batch_stock-expiration_date.
          ls_batch_balance-remaining_quantity =
            ls_batch_stock-available_quantity.
          IF ls_batch_balance-remaining_quantity < 0.
            CLEAR ls_batch_balance-remaining_quantity.
          ENDIF.
          INSERT ls_batch_balance INTO TABLE lt_batch_balances.
        ENDLOOP.

        IF iv_protect_safety_stock = abap_true.
          lv_safety_stock = mo_stock_repository->get_safety_stock(
            iv_material = ls_demand-material
            iv_plant    = ls_demand-plant ).
          LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
            WHERE material = ls_demand-material
              AND plant = ls_demand-plant.
            IF lv_safety_stock <= 0.
              EXIT.
            ENDIF.
            IF <ls_batch_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.
            IF lv_safety_stock <
                <ls_batch_balance>-remaining_quantity.
              <ls_batch_balance>-remaining_quantity =
                <ls_batch_balance>-remaining_quantity - lv_safety_stock.
              CLEAR lv_safety_stock.
            ELSE.
              lv_safety_stock = lv_safety_stock
                - <ls_batch_balance>-remaining_quantity.
              CLEAR <ls_batch_balance>-remaining_quantity.
            ENDIF.
          ENDLOOP.
        ENDIF.

        ls_loaded_stock_key-material = ls_demand-material.
        ls_loaded_stock_key-plant = ls_demand-plant.
        INSERT ls_loaded_stock_key INTO TABLE lt_loaded_stock_keys.
      ENDIF.

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-plant = ls_demand-plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.

      CLEAR lt_location_sequence.
      IF ls_demand-storage_location IS NOT INITIAL.
        APPEND ls_demand-storage_location TO lt_location_sequence.
      ENDIF.
      IF ls_demand-storage_location IS INITIAL
          OR ls_demand-fallback_to_other_locations = abap_true.
        LOOP AT it_storage_location_priority INTO lv_priority_location.
          IF lv_priority_location = ls_demand-storage_location.
            CONTINUE.
          ENDIF.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = lv_priority_location ] ).
            CONTINUE.
          ENDIF.
          READ TABLE lt_batch_balances TRANSPORTING NO FIELDS
            WITH TABLE KEY material = ls_demand-material
                           plant = ls_demand-plant
                           storage_location = lv_priority_location
                           batch = ls_demand-batch.
          IF sy-subrc = 0.
            APPEND lv_priority_location TO lt_location_sequence.
          ENDIF.
        ENDLOOP.
        LOOP AT lt_batch_balances INTO ls_batch_balance
            WHERE material = ls_demand-material
              AND plant = ls_demand-plant
              AND batch = ls_demand-batch.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = ls_batch_balance-storage_location ] ).
            CONTINUE.
          ENDIF.
          READ TABLE lt_location_sequence TRANSPORTING NO FIELDS
            WITH KEY table_line = ls_batch_balance-storage_location.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.
          APPEND ls_batch_balance-storage_location
            TO lt_location_sequence.
        ENDLOOP.
      ENDIF.

      LOOP AT lt_location_sequence INTO lv_storage_location.
        READ TABLE lt_batch_balances ASSIGNING <ls_batch_balance>
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_demand-plant
                         storage_location = lv_storage_location
                         batch = ls_demand-batch.
        IF sy-subrc = 0.
          ls_allocation-available_quantity =
            ls_allocation-available_quantity
            + <ls_batch_balance>-remaining_quantity.
        ENDIF.
      ENDLOOP.

      DATA(lv_remaining_quantity) = ls_demand-requested_quantity.
      LOOP AT lt_location_sequence INTO lv_storage_location.
        IF iv_require_full_quantity = abap_true
            AND ls_demand-requested_quantity >
              ls_allocation-available_quantity.
          EXIT.
        ENDIF.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.
        READ TABLE lt_batch_balances ASSIGNING <ls_batch_balance>
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_demand-plant
                         storage_location = lv_storage_location
                         batch = ls_demand-batch.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_batch_allocation.
        ls_batch_allocation-request_id = ls_demand-request_id.
        ls_batch_allocation-material = ls_demand-material.
        ls_batch_allocation-plant = ls_demand-plant.
        ls_batch_allocation-storage_location = lv_storage_location.
        ls_batch_allocation-batch = <ls_batch_balance>-batch.
        ls_batch_allocation-expiration_date =
          <ls_batch_balance>-expiration_date.
        IF lv_remaining_quantity < <ls_batch_balance>-remaining_quantity.
          ls_batch_allocation-allocated_quantity = lv_remaining_quantity.
        ELSE.
          ls_batch_allocation-allocated_quantity =
            <ls_batch_balance>-remaining_quantity.
        ENDIF.

        IF ls_batch_allocation-allocated_quantity > 0.
          APPEND ls_batch_allocation TO rs_result-batch_allocations.
          lv_remaining_quantity = lv_remaining_quantity
            - ls_batch_allocation-allocated_quantity.
          <ls_batch_balance>-remaining_quantity =
            <ls_batch_balance>-remaining_quantity
            - ls_batch_allocation-allocated_quantity.
          ls_allocation-allocated_quantity =
            ls_allocation-allocated_quantity
            + ls_batch_allocation-allocated_quantity.
        ENDIF.
      ENDLOOP.

      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_batch_in_units.
    DATA lt_base_demands TYPE ty_batch_demands.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_contexts TYPE ty_unit_allocation_contexts.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_unit_allocation_context.
    DATA lv_demand_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-batch IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-storage_location IS NOT INITIAL
          AND lt_allowed_location_set IS NOT INITIAL
          AND NOT line_exists( lt_allowed_location_set[
            table_line = ls_demand-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit     = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio )
          INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      ADD 1 TO lv_demand_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_demand_index.
      APPEND VALUE #(
        request_id                  = lv_internal_request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        batch                       = ls_demand-batch
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations = ls_demand-fallback_to_other_locations
        requested_quantity          = lv_base_quantity )
        TO lt_base_demands.
      INSERT VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        source_quantity     = ls_demand-requested_quantity
        source_unit         = ls_demand-requested_unit
        base_quantity       = lv_base_quantity
        ratio               = ls_unit_ratio )
        INTO TABLE lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_by_batch(
      it_demands                   = lt_base_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_protect_safety_stock      = iv_protect_safety_stock
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH TABLE KEY internal_request_id = ls_base_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unit_allocation) = VALUE ty_unit_allocation_summary(
        allocation                = ls_base_allocation
        source_quantity           = ls_context-source_quantity
        source_unit               = ls_context-source_unit
        base_quantity             = ls_context-base_quantity
        base_unit                 = ls_context-ratio-base_unit
        allocated_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-allocated_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator )
        shortfall_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-shortfall_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator ) ).
      ls_unit_allocation-allocation-request_id = ls_context-request_id.
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-batch_allocations INTO DATA(ls_base_batch_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH TABLE KEY internal_request_id =
          ls_base_batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unit_batch_allocation) = VALUE
        ty_unit_batch_split(
          batch_allocation          = ls_base_batch_allocation
          base_unit                 = ls_context-ratio-base_unit
          source_unit               = ls_context-source_unit
          allocated_source_quantity = convert_stock_quantity(
            iv_base_quantity = ls_base_batch_allocation-allocated_quantity
            iv_numerator     = ls_context-ratio-numerator
            iv_denominator   = ls_context-ratio-denominator ) ).
      ls_unit_batch_allocation-batch_allocation-request_id =
        ls_context-request_id.
      APPEND ls_unit_batch_allocation TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_expiry.
    DATA lt_fefo_balances TYPE ty_fefo_balances.
    DATA lt_loaded_stock_keys TYPE ty_loaded_stock_keys.
    DATA lt_batch_stock TYPE zif_stock_repository=>ty_batch_stocks.
    DATA ls_fefo_balance TYPE ty_fefo_balance.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_allocation TYPE ty_allocation.
    DATA ls_batch_allocation TYPE ty_batch_allocation.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA lo_eligibility TYPE REF TO zcl_stock_batch_eligibility.
    DATA lv_location_pass TYPE i.
    DATA lv_location_pass_count TYPE i.
    DATA lv_safety_stock TYPE marc-eisbe.
    FIELD-SYMBOLS <ls_fefo_balance> TYPE ty_fefo_balance.

    IF iv_as_of_date IS INITIAL
        OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).
    lo_eligibility = NEW zcl_stock_batch_eligibility( ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-storage_location IS NOT INITIAL
          AND lt_allowed_location_set IS NOT INITIAL
          AND NOT line_exists( lt_allowed_location_set[
            table_line = ls_demand-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_loaded_stock_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY material = ls_demand-material
                       plant = ls_demand-plant.
      IF sy-subrc <> 0.
        lt_batch_stock = mo_stock_repository->get_stock_by_batch(
          iv_material = ls_demand-material
          iv_plant    = ls_demand-plant ).
        LOOP AT lt_batch_stock INTO DATA(ls_batch_stock).
          CLEAR ls_fefo_balance.
          ls_fefo_balance-material = ls_demand-material.
          ls_fefo_balance-plant = ls_demand-plant.
          ls_fefo_balance-storage_location =
            ls_batch_stock-storage_location.
          READ TABLE it_storage_location_priority TRANSPORTING NO FIELDS
            WITH KEY table_line = ls_batch_stock-storage_location.
          IF sy-subrc = 0.
            ls_fefo_balance-location_priority = sy-tabix.
          ELSE.
            ls_fefo_balance-location_priority =
              lines( it_storage_location_priority ) + 1.
          ENDIF.
          ls_fefo_balance-batch = ls_batch_stock-batch.
          ls_fefo_balance-expiration_date =
            ls_batch_stock-expiration_date.
          ls_fefo_balance-sort_expiration_date =
            ls_batch_stock-expiration_date.
          IF ls_fefo_balance-sort_expiration_date IS INITIAL.
            ls_fefo_balance-sort_expiration_date = '99991231'.
          ENDIF.
          ls_fefo_balance-remaining_quantity =
            ls_batch_stock-available_quantity.
          IF ls_fefo_balance-remaining_quantity < 0.
            CLEAR ls_fefo_balance-remaining_quantity.
          ENDIF.
          APPEND ls_fefo_balance TO lt_fefo_balances.
        ENDLOOP.

        ls_loaded_stock_key-material = ls_demand-material.
        ls_loaded_stock_key-plant = ls_demand-plant.
        INSERT ls_loaded_stock_key INTO TABLE lt_loaded_stock_keys.
        SORT lt_fefo_balances BY material plant sort_expiration_date
          batch location_priority storage_location.
        IF iv_protect_safety_stock = abap_true.
          lv_safety_stock = mo_stock_repository->get_safety_stock(
            iv_material = ls_demand-material
            iv_plant    = ls_demand-plant ).
          SORT lt_fefo_balances BY material plant
            sort_expiration_date DESCENDING batch storage_location.
          LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
            WHERE material = ls_demand-material
              AND plant = ls_demand-plant.
            IF lv_safety_stock <= 0.
              EXIT.
            ENDIF.
            IF lo_eligibility->is_eligible(
                iv_expiration_date         = <ls_fefo_balance>-expiration_date
                iv_as_of_date              = iv_as_of_date
                iv_min_days                = iv_min_days
                iv_include_undated_batches =
                  iv_include_undated_batches ) = abap_false.
              CONTINUE.
            ENDIF.
            IF <ls_fefo_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.
            IF lv_safety_stock <
                <ls_fefo_balance>-remaining_quantity.
              <ls_fefo_balance>-remaining_quantity =
                <ls_fefo_balance>-remaining_quantity - lv_safety_stock.
              CLEAR lv_safety_stock.
            ELSE.
              lv_safety_stock = lv_safety_stock
                - <ls_fefo_balance>-remaining_quantity.
              CLEAR <ls_fefo_balance>-remaining_quantity.
            ENDIF.
          ENDLOOP.
          SORT lt_fefo_balances BY material plant sort_expiration_date
            batch location_priority storage_location.
        ENDIF.
      ENDIF.

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-plant = ls_demand-plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.

      lv_location_pass_count = 1.
      IF ls_demand-storage_location IS NOT INITIAL
          AND ls_demand-fallback_to_other_locations = abap_true.
        lv_location_pass_count = 2.
      ENDIF.

      DO lv_location_pass_count TIMES.
        lv_location_pass = sy-index.
        LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
          WHERE material = ls_demand-material
            AND plant = ls_demand-plant.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = <ls_fefo_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF ls_demand-storage_location IS NOT INITIAL.
            IF ls_demand-fallback_to_other_locations = abap_true.
              IF lv_location_pass = 1
                  AND <ls_fefo_balance>-storage_location
                    <> ls_demand-storage_location.
                CONTINUE.
              ELSEIF lv_location_pass = 2
                  AND <ls_fefo_balance>-storage_location
                    = ls_demand-storage_location.
                CONTINUE.
              ENDIF.
            ELSEIF <ls_fefo_balance>-storage_location
                <> ls_demand-storage_location.
              CONTINUE.
            ENDIF.
          ENDIF.
          IF lo_eligibility->is_eligible(
              iv_expiration_date         = <ls_fefo_balance>-expiration_date
              iv_as_of_date              = iv_as_of_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) = abap_false.
            CONTINUE.
          ENDIF.
          ls_allocation-available_quantity =
            ls_allocation-available_quantity
            + <ls_fefo_balance>-remaining_quantity.
        ENDLOOP.
      ENDDO.

      DATA(lv_remaining_quantity) = ls_demand-requested_quantity.
      DO lv_location_pass_count TIMES.
        IF iv_require_full_quantity = abap_true
            AND ls_demand-requested_quantity >
              ls_allocation-available_quantity.
          EXIT.
        ENDIF.
        lv_location_pass = sy-index.
        LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
          WHERE material = ls_demand-material
            AND plant = ls_demand-plant.
          IF lt_allowed_location_set IS NOT INITIAL
              AND NOT line_exists( lt_allowed_location_set[
                table_line = <ls_fefo_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF ls_demand-storage_location IS NOT INITIAL.
            IF ls_demand-fallback_to_other_locations = abap_true.
              IF lv_location_pass = 1
                  AND <ls_fefo_balance>-storage_location
                    <> ls_demand-storage_location.
                CONTINUE.
              ELSEIF lv_location_pass = 2
                  AND <ls_fefo_balance>-storage_location
                    = ls_demand-storage_location.
                CONTINUE.
              ENDIF.
            ELSEIF <ls_fefo_balance>-storage_location
                <> ls_demand-storage_location.
              CONTINUE.
            ENDIF.
          ENDIF.
          IF lo_eligibility->is_eligible(
              iv_expiration_date         = <ls_fefo_balance>-expiration_date
              iv_as_of_date              = iv_as_of_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) = abap_false.
            CONTINUE.
          ENDIF.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.

          CLEAR ls_batch_allocation.
          ls_batch_allocation-request_id = ls_demand-request_id.
          ls_batch_allocation-material = ls_demand-material.
          ls_batch_allocation-plant = ls_demand-plant.
          ls_batch_allocation-storage_location =
            <ls_fefo_balance>-storage_location.
          ls_batch_allocation-batch = <ls_fefo_balance>-batch.
          ls_batch_allocation-expiration_date =
            <ls_fefo_balance>-expiration_date.
          IF lv_remaining_quantity <
              <ls_fefo_balance>-remaining_quantity.
            ls_batch_allocation-allocated_quantity = lv_remaining_quantity.
          ELSE.
            ls_batch_allocation-allocated_quantity =
              <ls_fefo_balance>-remaining_quantity.
          ENDIF.

          IF ls_batch_allocation-allocated_quantity > 0.
            APPEND ls_batch_allocation TO rs_result-batch_allocations.
            lv_remaining_quantity = lv_remaining_quantity
              - ls_batch_allocation-allocated_quantity.
            <ls_fefo_balance>-remaining_quantity =
              <ls_fefo_balance>-remaining_quantity
              - ls_batch_allocation-allocated_quantity.
            ls_allocation-allocated_quantity =
              ls_allocation-allocated_quantity
              + ls_batch_allocation-allocated_quantity.
          ENDIF.
        ENDLOOP.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.
      ENDDO.

      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_expiry_in_units.
    DATA lt_base_demands TYPE ty_fefo_demands.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_contexts TYPE ty_unit_allocation_contexts.
    DATA lt_allowed_location_set TYPE ty_storage_location_set.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_unit_allocation_context.
    DATA lv_demand_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF iv_as_of_date IS INITIAL OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_location_order(
      it_storage_location_priority = it_storage_location_priority ).
    lt_allowed_location_set = build_allowed_location_set(
      it_allowed_storage_locations = it_allowed_storage_locations ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_unit IS INITIAL
          OR ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-storage_location IS NOT INITIAL
          AND lt_allowed_location_set IS NOT INITIAL
          AND NOT line_exists( lt_allowed_location_set[
            table_line = ls_demand-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_uom_cache INTO DATA(ls_cached_conversion)
        WITH TABLE KEY material = ls_demand-material
                       unit     = ls_demand-requested_unit.
      IF sy-subrc = 0.
        ls_unit_ratio = ls_cached_conversion-result.
      ELSE.
        ls_unit_ratio = get_stock_unit_ratio(
          iv_material = ls_demand-material
          iv_unit     = ls_demand-requested_unit ).
        INSERT VALUE #(
          material = ls_demand-material
          unit     = ls_demand-requested_unit
          result   = ls_unit_ratio )
          INTO TABLE lt_uom_cache.
      ENDIF.

      DATA(lv_base_quantity) = CONV mard-labst(
        CONV decfloat34( ls_demand-requested_quantity )
        * CONV decfloat34( ls_unit_ratio-numerator )
        / CONV decfloat34( ls_unit_ratio-denominator ) ).

      ADD 1 TO lv_demand_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_demand_index.
      APPEND VALUE #(
        request_id                  = lv_internal_request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations = ls_demand-fallback_to_other_locations
        requested_quantity          = lv_base_quantity )
        TO lt_base_demands.
      INSERT VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        source_quantity     = ls_demand-requested_quantity
        source_unit         = ls_demand-requested_unit
        base_quantity       = lv_base_quantity
        ratio               = ls_unit_ratio )
        INTO TABLE lt_contexts.
    ENDLOOP.

    DATA(ls_base_result) = allocate_by_expiry(
      it_demands                   = lt_base_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_min_days                  = iv_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_protect_safety_stock      = iv_protect_safety_stock
      iv_require_full_quantity     = iv_require_full_quantity ).

    LOOP AT ls_base_result-allocations INTO DATA(ls_base_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH TABLE KEY internal_request_id = ls_base_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unit_allocation) = VALUE ty_unit_allocation_summary(
        allocation                = ls_base_allocation
        source_quantity           = ls_context-source_quantity
        source_unit               = ls_context-source_unit
        base_quantity             = ls_context-base_quantity
        base_unit                 = ls_context-ratio-base_unit
        allocated_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-allocated_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator )
        shortfall_source_quantity = convert_stock_quantity(
          iv_base_quantity = ls_base_allocation-shortfall_quantity
          iv_numerator     = ls_context-ratio-numerator
          iv_denominator   = ls_context-ratio-denominator ) ).
      ls_unit_allocation-allocation-request_id = ls_context-request_id.
      APPEND ls_unit_allocation TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_base_result-batch_allocations INTO DATA(ls_base_batch_allocation).
      READ TABLE lt_contexts INTO ls_context
        WITH TABLE KEY internal_request_id =
          ls_base_batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unit_batch_allocation) = VALUE
        ty_unit_batch_split(
          batch_allocation          = ls_base_batch_allocation
          base_unit                 = ls_context-ratio-base_unit
          source_unit               = ls_context-source_unit
          allocated_source_quantity = convert_stock_quantity(
            iv_base_quantity = ls_base_batch_allocation-allocated_quantity
            iv_numerator     = ls_context-ratio-numerator
            iv_denominator   = ls_context-ratio-denominator ) ).
      ls_unit_batch_allocation-batch_allocation-request_id =
        ls_context-request_id.
      APPEND ls_unit_batch_allocation TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
