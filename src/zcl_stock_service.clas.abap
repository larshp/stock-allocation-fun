CLASS zcl_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
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
      BEGIN OF ty_plant_fefo_allocation_result,
        allocations       TYPE ty_plant_demand_allocations,
        plant_allocations TYPE ty_plant_source_allocations,
        batch_allocations TYPE ty_plant_batch_location_allocations,
      END OF ty_plant_fefo_allocation_result.
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
        io_stock_repository TYPE REF TO zif_stock_repository
        io_uom_converter    TYPE REF TO zif_material_uom_converter OPTIONAL.

    METHODS get_unrestricted_stock
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_quantity)      TYPE mard-labst.

    METHODS get_stock_status
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
      RETURNING
        VALUE(rs_status) TYPE zif_stock_repository=>ty_stock_status.

    METHODS get_stock_status_in_unit
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
        iv_unit          TYPE mara-meins
      RETURNING
        VALUE(rs_status) TYPE ty_stock_status_in_unit
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
        VALUE(rt_status) TYPE zif_stock_repository=>ty_stock_status_locations.

    METHODS get_stock_status_by_batch
      IMPORTING
        iv_material      TYPE mard-matnr
        iv_plant         TYPE mard-werks
      RETURNING
        VALUE(rt_status) TYPE zif_stock_repository=>ty_batch_stock_statuses.

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

    METHODS get_sales_order_reservations
      IMPORTING
        iv_sales_document      TYPE resb-kdauf
      RETURNING
        VALUE(rt_reservations) TYPE zif_stock_repository=>ty_sales_order_reservations.

    METHODS allocate_request
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_requested_quantity   TYPE mard-labst
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_allocation)    TYPE ty_allocation
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_request_in_unit
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_requested_quantity   TYPE mard-labst
        iv_requested_unit       TYPE mara-meins
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_allocation
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_demands_in_units
      IMPORTING
        it_demands              TYPE ty_unit_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)   TYPE ty_unit_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_demands
      IMPORTING
        it_demands              TYPE ty_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations)   TYPE ty_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_across_plants
      IMPORTING
        it_demands              TYPE ty_plant_demands
        it_sources              TYPE ty_plant_sources
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_plant_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_by_expiry
      IMPORTING
        it_demands              TYPE ty_plant_demands
        it_sources              TYPE ty_plant_sources
        iv_as_of_date           TYPE d DEFAULT sy-datum
        iv_min_days             TYPE i DEFAULT 0
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_plant_fefo_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_by_batch
      IMPORTING
        it_demands              TYPE ty_plant_batch_demands
        it_sources              TYPE ty_plant_sources
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_plant_batch_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_batch_in_units
      IMPORTING
        it_demands              TYPE ty_unit_plant_batch_demands
        it_sources              TYPE ty_plant_sources
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_plant_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_in_units
      IMPORTING
        it_demands              TYPE ty_unit_plant_demands
        it_sources              TYPE ty_plant_sources
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_plant_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_plants_fefo_in_units
      IMPORTING
        it_demands              TYPE ty_unit_plant_demands
        it_sources              TYPE ty_plant_sources
        iv_as_of_date           TYPE d DEFAULT sy-datum
        iv_min_days             TYPE i DEFAULT 0
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_plant_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_storage_location
      IMPORTING
        it_demands              TYPE ty_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_location_in_units
      IMPORTING
        it_demands              TYPE ty_unit_location_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_batch
      IMPORTING
        it_demands              TYPE ty_batch_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_batch_in_units
      IMPORTING
        it_demands              TYPE ty_unit_batch_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_expiry
      IMPORTING
        it_demands              TYPE ty_fefo_demands
        iv_as_of_date           TYPE d DEFAULT sy-datum
        iv_min_days             TYPE i DEFAULT 0
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS allocate_by_expiry_in_units
      IMPORTING
        it_demands              TYPE ty_unit_fefo_demands
        iv_as_of_date           TYPE d DEFAULT sy-datum
        iv_min_days             TYPE i DEFAULT 0
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_unit_batch_result
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
        batch                TYPE mchb-charg,
        expiration_date      TYPE mcha-vfdat,
        sort_expiration_date TYPE d,
        remaining_quantity   TYPE mchb-clabs,
      END OF ty_fefo_balance.
    TYPES ty_fefo_balances TYPE STANDARD TABLE OF ty_fefo_balance
      WITH EMPTY KEY.
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
  ENDMETHOD.

  METHOD get_unrestricted_stock.
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
    rs_status = mo_stock_repository->get_stock_status(
      iv_material = iv_material
      iv_plant    = iv_plant ).
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

  METHOD convert_stock_quantity.
    rv_quantity = CONV mard-labst(
      CONV decfloat34( iv_base_quantity )
      * CONV decfloat34( iv_denominator )
      / CONV decfloat34( iv_numerator ) ).
  ENDMETHOD.

  METHOD get_stock_status_by_location.
    rt_status = mo_stock_repository->get_stock_status_by_location(
      iv_material = iv_material
      iv_plant    = iv_plant ).
  ENDMETHOD.

  METHOD get_stock_status_by_batch.
    rt_status = mo_stock_repository->get_stock_status_by_batch(
      iv_material = iv_material
      iv_plant    = iv_plant ).
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

  METHOD get_sales_order_reservations.
    rt_reservations = mo_stock_repository->get_sales_order_reservations(
      iv_sales_document = iv_sales_document ).
  ENDMETHOD.

  METHOD allocate_request.
    DATA(lt_demands) = VALUE ty_demands(
      ( material           = iv_material
        plant              = iv_plant
        requested_quantity = iv_requested_quantity ) ).
    DATA(lt_allocations) = allocate_demands(
      it_demands              = lt_demands
      iv_protect_safety_stock = iv_protect_safety_stock ).

    READ TABLE lt_allocations INDEX 1 INTO rs_allocation.
  ENDMETHOD.

  METHOD allocate_request_in_unit.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL
        OR iv_requested_unit IS INITIAL
        OR iv_requested_quantity < 0.
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
      iv_material             = iv_material
      iv_plant                = iv_plant
      iv_requested_quantity   = ls_conversion-base_quantity
      iv_protect_safety_stock = iv_protect_safety_stock ).
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
      it_demands              = lt_base_demands
      iv_protect_safety_stock = iv_protect_safety_stock ).
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

      IF ls_demand-requested_quantity < <ls_stock_balance>-remaining_quantity.
        ls_allocation-allocated_quantity = ls_demand-requested_quantity.
      ELSE.
        ls_allocation-allocated_quantity = <ls_stock_balance>-remaining_quantity.
      ENDIF.

      ls_allocation-shortfall_quantity = ls_demand-requested_quantity
        - ls_allocation-allocated_quantity.
      <ls_stock_balance>-remaining_quantity = <ls_stock_balance>-remaining_quantity
        - ls_allocation-allocated_quantity.
      APPEND ls_allocation TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_across_plants.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_location_balances TYPE ty_location_balances.
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
    DATA lt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    FIELD-SYMBOLS <ls_location_balance> TYPE ty_location_balance.

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
          lv_available_quantity = lv_available_quantity
            + ls_location_balance-remaining_quantity.
        ENDLOOP.
      ENDLOOP.

      IF ls_demand-requested_quantity > 0.
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
            lv_plant_available_quantity = lv_plant_available_quantity
              + <ls_location_balance>-remaining_quantity.
          ENDLOOP.
          ls_source_allocation-available_quantity =
            lv_plant_available_quantity.

          LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant.
            IF lv_remaining_quantity <= 0.
              EXIT.
            ENDIF.
            IF <ls_location_balance>-remaining_quantity <= 0.
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
            ls_location_allocation-storage_location =
              <ls_location_balance>-storage_location.
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

  METHOD allocate_plants_by_expiry.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_fefo_balances TYPE ty_fefo_balances.
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

    IF iv_as_of_date IS INITIAL OR iv_min_days < 0.
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
            batch storage_location.

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
                  iv_expiration_date = <ls_fefo_balance>-expiration_date
                  iv_as_of_date      = iv_as_of_date
                  iv_min_days        = iv_min_days ) = abap_false.
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
              batch storage_location.
          ENDIF.
        ENDIF.

        LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
          WHERE material = ls_demand-material
            AND plant = ls_source-source_plant.
          IF lo_eligibility->is_eligible(
              iv_expiration_date = <ls_fefo_balance>-expiration_date
              iv_as_of_date      = iv_as_of_date
              iv_min_days        = iv_min_days ) = abap_true.
            lv_available_quantity = lv_available_quantity
              + <ls_fefo_balance>-remaining_quantity.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      IF ls_demand-requested_quantity > 0.
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
            IF lo_eligibility->is_eligible(
                iv_expiration_date = <ls_fefo_balance>-expiration_date
                iv_as_of_date      = iv_as_of_date
                iv_min_days        = iv_min_days ) = abap_true.
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
            IF lo_eligibility->is_eligible(
                iv_expiration_date = <ls_fefo_balance>-expiration_date
                iv_as_of_date      = iv_as_of_date
                iv_min_days        = iv_min_days ) = abap_false
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

  METHOD allocate_plants_by_batch.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA lt_source_keys TYPE ty_plant_source_keys.
    DATA lt_batch_balances TYPE ty_batch_balances.
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
    FIELD-SYMBOLS <ls_batch_balance> TYPE ty_batch_balance.

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
          lv_available_quantity = lv_available_quantity
            + <ls_batch_balance>-remaining_quantity.
        ENDLOOP.
      ENDLOOP.

      IF ls_demand-requested_quantity > 0.
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
            lv_plant_available_quantity = lv_plant_available_quantity
              + <ls_batch_balance>-remaining_quantity.
          ENDLOOP.
          ls_source_allocation-available_quantity =
            lv_plant_available_quantity.

          LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
            WHERE material = ls_demand-material
              AND plant = ls_source-source_plant
              AND batch = ls_demand-batch.
            IF lv_remaining_quantity <= 0.
              EXIT.
            ENDIF.
            IF <ls_batch_balance>-remaining_quantity <= 0.
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
            ls_location_allocation-storage_location =
              <ls_batch_balance>-storage_location.
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

  METHOD allocate_plants_batch_in_units.
    DATA lt_base_demands TYPE ty_plant_batch_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_plant_batch_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_plant_batch_source_allocation.
    DATA ls_unit_location TYPE ty_unit_plant_batch_location_allocation.

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
      it_demands              = lt_base_demands
      it_sources              = it_sources
      iv_protect_safety_stock = iv_protect_safety_stock ).

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
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_plant_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_plant_source_allocation.
    DATA ls_unit_location TYPE ty_unit_plant_location_allocation.

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
      it_demands              = lt_base_demands
      it_sources              = it_sources
      iv_protect_safety_stock = iv_protect_safety_stock ).

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

  METHOD allocate_plants_fefo_in_units.
    DATA lt_base_demands TYPE ty_plant_demands.
    DATA lt_contexts TYPE ty_plant_unit_contexts.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_request_ids TYPE ty_plant_request_ids.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_plant_unit_context.
    DATA ls_unit_allocation TYPE ty_unit_plant_demand_allocation.
    DATA ls_unit_source TYPE ty_unit_plant_source_allocation.
    DATA ls_unit_split TYPE ty_unit_plant_fefo_split.

    IF iv_as_of_date IS INITIAL OR iv_min_days < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

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
      it_demands              = lt_base_demands
      it_sources              = it_sources
      iv_as_of_date           = iv_as_of_date
      iv_min_days             = iv_min_days
      iv_protect_safety_stock = iv_protect_safety_stock ).

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
    DATA ls_location_balance TYPE ty_location_balance.
    DATA ls_loaded_stock_key TYPE ty_loaded_stock_key.
    DATA ls_allocation TYPE ty_allocation.
    DATA ls_storage_allocation TYPE ty_storage_allocation.
    DATA lv_location_pass TYPE i.
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lt_location_stock TYPE zif_stock_repository=>ty_location_stocks.
    FIELD-SYMBOLS <ls_location_balance> TYPE ty_location_balance.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-requested_quantity < 0.
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

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-plant = ls_demand-plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.

      LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
        WHERE material = ls_demand-material
          AND plant = ls_demand-plant.
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
      lv_location_pass = 1.
      DO 2 TIMES.
        LOOP AT lt_location_balances ASSIGNING <ls_location_balance>
          WHERE material = ls_demand-material
            AND plant = ls_demand-plant.
          IF ls_demand-storage_location IS NOT INITIAL.
            IF lv_location_pass = 1
                AND <ls_location_balance>-storage_location
                  <> ls_demand-storage_location.
              CONTINUE.
            ELSEIF lv_location_pass = 2
                AND <ls_location_balance>-storage_location
                  = ls_demand-storage_location.
              CONTINUE.
            ENDIF.
          ENDIF.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.

          CLEAR ls_storage_allocation.
          ls_storage_allocation-request_id = ls_demand-request_id.
          ls_storage_allocation-material = ls_demand-material.
          ls_storage_allocation-plant = ls_demand-plant.
          ls_storage_allocation-storage_location =
            <ls_location_balance>-storage_location.
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

        IF lv_remaining_quantity <= 0
            OR ls_demand-storage_location IS INITIAL
            OR ls_demand-fallback_to_other_locations = abap_false.
          EXIT.
        ENDIF.
        ADD 1 TO lv_location_pass.
      ENDDO.

      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_location_in_units.
    DATA lt_base_demands TYPE ty_demands.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_contexts TYPE ty_unit_allocation_contexts.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_unit_allocation_context.
    DATA lv_demand_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

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
      it_demands              = lt_base_demands
      iv_protect_safety_stock = iv_protect_safety_stock ).

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
    DATA lv_safety_stock TYPE marc-eisbe.
    DATA lv_location_pass TYPE i.
    DATA lv_location_pass_count TYPE i.
    FIELD-SYMBOLS <ls_batch_balance> TYPE ty_batch_balance.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-batch IS INITIAL
          OR ls_demand-requested_quantity < 0.
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

      lv_location_pass_count = 1.
      IF ls_demand-storage_location IS NOT INITIAL
          AND ls_demand-fallback_to_other_locations = abap_true.
        lv_location_pass_count = 2.
      ENDIF.

      LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
        WHERE material = ls_demand-material
          AND plant = ls_demand-plant
          AND batch = ls_demand-batch.
        IF ls_demand-storage_location IS NOT INITIAL
            AND ls_demand-fallback_to_other_locations = abap_false
            AND <ls_batch_balance>-storage_location
              <> ls_demand-storage_location.
          CONTINUE.
        ENDIF.
        ls_allocation-available_quantity =
          ls_allocation-available_quantity
          + <ls_batch_balance>-remaining_quantity.
      ENDLOOP.

      DATA(lv_remaining_quantity) = ls_demand-requested_quantity.
      DO lv_location_pass_count TIMES.
        lv_location_pass = sy-index.
        LOOP AT lt_batch_balances ASSIGNING <ls_batch_balance>
          WHERE material = ls_demand-material
            AND plant = ls_demand-plant
            AND batch = ls_demand-batch.
          IF ls_demand-storage_location IS NOT INITIAL.
            IF ls_demand-fallback_to_other_locations = abap_true.
              IF lv_location_pass = 1
                  AND <ls_batch_balance>-storage_location
                    <> ls_demand-storage_location.
                CONTINUE.
              ELSEIF lv_location_pass = 2
                  AND <ls_batch_balance>-storage_location
                    = ls_demand-storage_location.
                CONTINUE.
              ENDIF.
            ELSEIF <ls_batch_balance>-storage_location
                <> ls_demand-storage_location.
              CONTINUE.
            ENDIF.
          ENDIF.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.

          CLEAR ls_batch_allocation.
          ls_batch_allocation-request_id = ls_demand-request_id.
          ls_batch_allocation-material = ls_demand-material.
          ls_batch_allocation-plant = ls_demand-plant.
          ls_batch_allocation-storage_location =
            <ls_batch_balance>-storage_location.
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

      IF lv_remaining_quantity <= 0.
        EXIT.
      ENDIF.
    ENDDO.

      ls_allocation-shortfall_quantity = lv_remaining_quantity.
      APPEND ls_allocation TO rs_result-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_by_batch_in_units.
    DATA lt_base_demands TYPE ty_batch_demands.
    DATA lt_uom_cache TYPE ty_uom_cache_table.
    DATA lt_contexts TYPE ty_unit_allocation_contexts.
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_unit_allocation_context.
    DATA lv_demand_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-batch IS INITIAL
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
      it_demands              = lt_base_demands
      iv_protect_safety_stock = iv_protect_safety_stock ).

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
    DATA lo_eligibility TYPE REF TO zcl_stock_batch_eligibility.
    DATA lv_location_pass TYPE i.
    DATA lv_location_pass_count TYPE i.
    DATA lv_safety_stock TYPE marc-eisbe.
    FIELD-SYMBOLS <ls_fefo_balance> TYPE ty_fefo_balance.

    IF iv_as_of_date IS INITIAL
        OR iv_min_days < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lo_eligibility = NEW zcl_stock_batch_eligibility( ).

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_quantity < 0.
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
          batch storage_location.
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
                iv_expiration_date = <ls_fefo_balance>-expiration_date
                iv_as_of_date      = iv_as_of_date
                iv_min_days        = iv_min_days ) = abap_false.
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
            batch storage_location.
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
              iv_expiration_date = <ls_fefo_balance>-expiration_date
              iv_as_of_date      = iv_as_of_date
              iv_min_days        = iv_min_days ) = abap_false.
            CONTINUE.
          ENDIF.
          ls_allocation-available_quantity =
            ls_allocation-available_quantity
            + <ls_fefo_balance>-remaining_quantity.
        ENDLOOP.
      ENDDO.

      DATA(lv_remaining_quantity) = ls_demand-requested_quantity.
      DO lv_location_pass_count TIMES.
        lv_location_pass = sy-index.
        LOOP AT lt_fefo_balances ASSIGNING <ls_fefo_balance>
          WHERE material = ls_demand-material
            AND plant = ls_demand-plant.
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
          IF <ls_fefo_balance>-expiration_date IS NOT INITIAL
              AND ( <ls_fefo_balance>-expiration_date < iv_as_of_date
                OR <ls_fefo_balance>-expiration_date - iv_as_of_date
                  < iv_min_days ).
            CONTINUE.
          ENDIF.
          IF <ls_fefo_balance>-expiration_date IS INITIAL
              AND iv_min_days > 0.
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
    DATA ls_unit_ratio TYPE zif_material_uom_converter=>ty_unit_ratio.
    DATA ls_context TYPE ty_unit_allocation_context.
    DATA lv_demand_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF iv_as_of_date IS INITIAL OR iv_min_days < 0.
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
      it_demands              = lt_base_demands
      iv_as_of_date           = iv_as_of_date
      iv_min_days             = iv_min_days
      iv_protect_safety_stock = iv_protect_safety_stock ).

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
