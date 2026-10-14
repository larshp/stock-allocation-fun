CLASS zcl_project_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_wbs_element TYPE zif_project_stock_repository=>ty_wbs_element.
    TYPES:
      BEGIN OF ty_demand,
        request_id              TYPE c LENGTH 30,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
      END OF ty_demand.
    TYPES ty_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_demand,
        request_id              TYPE c LENGTH 30,
        required_date           TYPE d,
        priority                TYPE i,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
      END OF ty_dated_fefo_demand.
    TYPES ty_dated_fefo_demands TYPE STANDARD TABLE OF
      ty_dated_fefo_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_demand,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
      END OF ty_transfer_demand.
    TYPES ty_transfer_demands TYPE STANDARD TABLE OF
      ty_transfer_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_transfer_demand,
        request_id              TYPE c LENGTH 30,
        required_date           TYPE d,
        priority                TYPE i,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
      END OF ty_dated_transfer_demand.
    TYPES ty_dated_transfer_demands TYPE STANDARD TABLE OF
      ty_dated_transfer_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_wbs_assignment,
        request_id  TYPE c LENGTH 30,
        wbs_element TYPE ty_wbs_element,
      END OF ty_wbs_assignment.
    TYPES ty_wbs_assignments TYPE STANDARD TABLE OF
      ty_wbs_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_assignment,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
      END OF ty_transfer_assignment.
    TYPES ty_transfer_assignments TYPE STANDARD TABLE OF
      ty_transfer_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result,
        allocation      TYPE zcl_stock_service=>ty_unit_batch_result,
        wbs_assignments TYPE ty_wbs_assignments,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_dated_fefo_allocation,
        allocation    TYPE zcl_stock_service=>ty_unit_allocation_summary,
        required_date TYPE d,
        priority      TYPE i,
      END OF ty_dated_fefo_allocation.
    TYPES ty_dated_fefo_allocations TYPE STANDARD TABLE OF
      ty_dated_fefo_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_batch_split,
        split         TYPE zcl_stock_service=>ty_unit_batch_split,
        required_date TYPE d,
        priority      TYPE i,
      END OF ty_dated_fefo_batch_split.
    TYPES ty_dated_fefo_batch_splits TYPE STANDARD TABLE OF
      ty_dated_fefo_batch_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_wbs_assignment,
        request_id    TYPE c LENGTH 30,
        wbs_element   TYPE ty_wbs_element,
        required_date TYPE d,
        priority      TYPE i,
      END OF ty_dated_wbs_assignment.
    TYPES ty_dated_wbs_assignments TYPE STANDARD TABLE OF
      ty_dated_wbs_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_result,
        allocations       TYPE ty_dated_fefo_allocations,
        batch_allocations TYPE ty_dated_fefo_batch_splits,
        wbs_assignments   TYPE ty_dated_wbs_assignments,
      END OF ty_dated_fefo_result.
    TYPES:
      BEGIN OF ty_dated_location_demand,
        request_id         TYPE c LENGTH 30,
        required_date      TYPE d,
        priority           TYPE i,
        wbs_element        TYPE ty_wbs_element,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        requested_quantity TYPE mard-labst,
        unit               TYPE mara-meins,
      END OF ty_dated_location_demand.
    TYPES ty_dated_location_demands TYPE STANDARD TABLE OF
      ty_dated_location_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_transfer_demand,
        request_id              TYPE c LENGTH 30,
        required_date           TYPE d,
        priority                TYPE i,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        requested_quantity      TYPE mard-labst,
        unit                    TYPE mara-meins,
      END OF ty_dated_location_transfer_demand.
    TYPES ty_dated_location_transfer_demands TYPE STANDARD TABLE OF
      ty_dated_location_transfer_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_allocation,
        allocation    TYPE zcl_stock_service=>ty_unit_allocation_summary,
        required_date TYPE d,
        priority      TYPE i,
      END OF ty_dated_location_allocation.
    TYPES ty_dated_location_allocations TYPE STANDARD TABLE OF
      ty_dated_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_split,
        split         TYPE zcl_stock_service=>ty_unit_storage_split,
        required_date TYPE d,
        priority      TYPE i,
      END OF ty_dated_location_split.
    TYPES ty_dated_location_splits TYPE STANDARD TABLE OF
      ty_dated_location_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_result,
        allocations         TYPE ty_dated_location_allocations,
        storage_allocations TYPE ty_dated_location_splits,
        wbs_assignments     TYPE ty_dated_wbs_assignments,
      END OF ty_dated_location_result.
    TYPES:
      BEGIN OF ty_location_result,
        allocation      TYPE zcl_stock_service=>ty_unit_location_result,
        wbs_assignments TYPE ty_wbs_assignments,
      END OF ty_location_result.
    TYPES:
      BEGIN OF ty_transfer_result,
        allocation           TYPE zcl_stock_service=>ty_unit_batch_result,
        transfer_assignments TYPE ty_transfer_assignments,
      END OF ty_transfer_result.
    TYPES:
      BEGIN OF ty_dated_transfer_assignment,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        required_date           TYPE d,
        priority                TYPE i,
      END OF ty_dated_transfer_assignment.
    TYPES ty_dated_transfer_assignments TYPE STANDARD TABLE OF
      ty_dated_transfer_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_transfer_result,
        allocations          TYPE ty_dated_fefo_allocations,
        batch_allocations    TYPE ty_dated_fefo_batch_splits,
        transfer_assignments TYPE ty_dated_transfer_assignments,
      END OF ty_dated_transfer_result.
    TYPES:
      BEGIN OF ty_dated_location_transfer_result,
        allocations          TYPE ty_dated_location_allocations,
        storage_allocations  TYPE ty_dated_location_splits,
        transfer_assignments TYPE ty_dated_transfer_assignments,
      END OF ty_dated_location_transfer_result.
    TYPES:
      BEGIN OF ty_transfer_location_result,
        allocation           TYPE zcl_stock_service=>ty_unit_location_result,
        transfer_assignments TYPE ty_transfer_assignments,
      END OF ty_transfer_location_result.
    TYPES:
      BEGIN OF ty_available_stock,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        available_quantity TYPE mspr-prlab,
        base_unit          TYPE mara-meins,
      END OF ty_available_stock.
    TYPES ty_available_stocks TYPE STANDARD TABLE OF
      ty_available_stock WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_available_stock_request,
        request_id               TYPE c LENGTH 30,
        material                 TYPE mard-matnr,
        plant                    TYPE mard-werks,
        wbs_element              TYPE ty_wbs_element,
        reservation_through_date TYPE d,
      END OF ty_available_stock_request.
    TYPES ty_available_stock_requests TYPE STANDARD TABLE OF
      ty_available_stock_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_available_stock_bulk_item,
        request_id               TYPE c LENGTH 30,
        material                 TYPE mard-matnr,
        plant                    TYPE mard-werks,
        wbs_element              TYPE ty_wbs_element,
        reservation_through_date TYPE d,
        stocks                   TYPE ty_available_stocks,
      END OF ty_available_stock_bulk_item.
    TYPES ty_available_stock_bulk_items TYPE STANDARD TABLE OF
      ty_available_stock_bulk_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_available_stock_in_unit,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        available_quantity TYPE mspr-prlab,
        unit               TYPE mara-meins,
        base_quantity      TYPE mspr-prlab,
        base_unit          TYPE mara-meins,
      END OF ty_available_stock_in_unit.
    TYPES ty_available_stocks_in_unit TYPE STANDARD TABLE OF
      ty_available_stock_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_available_stock_unit_request,
        request_id               TYPE c LENGTH 30,
        material                 TYPE mard-matnr,
        plant                    TYPE mard-werks,
        wbs_element              TYPE ty_wbs_element,
        requested_unit           TYPE mara-meins,
        reservation_through_date TYPE d,
      END OF ty_available_stock_unit_request.
    TYPES ty_available_stock_unit_requests TYPE STANDARD TABLE OF
      ty_available_stock_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_available_stock_bulk_unit_item,
        request_id               TYPE c LENGTH 30,
        material                 TYPE mard-matnr,
        plant                    TYPE mard-werks,
        wbs_element              TYPE ty_wbs_element,
        requested_unit           TYPE mara-meins,
        reservation_through_date TYPE d,
        stocks                   TYPE ty_available_stocks_in_unit,
      END OF ty_available_stock_bulk_unit_item.
    TYPES ty_available_stock_bulk_unit_items TYPE STANDARD TABLE OF
      ty_available_stock_bulk_unit_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_open_reservation,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        required_date      TYPE resb-bdter,
        unit               TYPE resb-meins,
        entry_unit         TYPE resb-erfme,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
        open_quantity      TYPE resb-bdmng,
      END OF ty_open_reservation.
    TYPES ty_open_reservations TYPE STANDARD TABLE OF
      ty_open_reservation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_open_reservation_request,
        request_id            TYPE c LENGTH 30,
        wbs_element           TYPE ty_wbs_element,
        required_through_date TYPE d,
      END OF ty_open_reservation_request.
    TYPES ty_open_reservation_requests TYPE STANDARD TABLE OF
      ty_open_reservation_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_open_reservation_bulk_item,
        request_id            TYPE c LENGTH 30,
        wbs_element           TYPE ty_wbs_element,
        required_through_date TYPE d,
        reservations          TYPE ty_open_reservations,
      END OF ty_open_reservation_bulk_item.
    TYPES ty_open_reservation_bulk_items TYPE STANDARD TABLE OF
      ty_open_reservation_bulk_item WITH EMPTY KEY.
    TYPES ty_reservation_items TYPE
      zif_project_stock_repository=>ty_reservations.
    TYPES:
      BEGIN OF ty_reservation_items_request,
        request_id  TYPE c LENGTH 30,
        wbs_element TYPE ty_wbs_element,
      END OF ty_reservation_items_request.
    TYPES ty_reservation_items_requests TYPE STANDARD TABLE OF
      ty_reservation_items_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_items_bulk_item,
        request_id   TYPE c LENGTH 30,
        wbs_element  TYPE ty_wbs_element,
        reservations TYPE ty_reservation_items,
      END OF ty_reservation_items_bulk_item.
    TYPES ty_reservation_items_bulk_items TYPE STANDARD TABLE OF
      ty_reservation_items_bulk_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_coverage,
        material               TYPE mard-matnr,
        plant                  TYPE mard-werks,
        wbs_element            TYPE ty_wbs_element,
        base_unit              TYPE mara-meins,
        project_stock_quantity TYPE mspr-prlab,
        reserved_quantity      TYPE mspr-prlab,
        available_quantity     TYPE mspr-prlab,
        shortfall_quantity     TYPE mspr-prlab,
        open_reservation_items TYPE i,
        is_fully_covered       TYPE abap_bool,
      END OF ty_reservation_coverage.
    TYPES ty_reservation_coverages TYPE STANDARD TABLE OF
      ty_reservation_coverage WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_coverage_in_unit,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        wbs_element                 TYPE ty_wbs_element,
        unit                        TYPE mara-meins,
        base_unit                   TYPE mara-meins,
        project_stock_quantity      TYPE mspr-prlab,
        reserved_quantity           TYPE mspr-prlab,
        available_quantity          TYPE mspr-prlab,
        shortfall_quantity          TYPE mspr-prlab,
        base_project_stock_quantity TYPE mspr-prlab,
        base_reserved_quantity      TYPE mspr-prlab,
        base_available_quantity     TYPE mspr-prlab,
        base_shortfall_quantity     TYPE mspr-prlab,
        open_reservation_items      TYPE i,
        is_fully_covered            TYPE abap_bool,
      END OF ty_reservation_coverage_in_unit.
    TYPES:
      BEGIN OF ty_coverage_request,
        request_id            TYPE c LENGTH 30,
        wbs_element           TYPE ty_wbs_element,
        required_through_date TYPE d,
      END OF ty_coverage_request.
    TYPES ty_coverage_requests TYPE STANDARD TABLE OF
      ty_coverage_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_coverage_unit_request,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        wbs_element           TYPE ty_wbs_element,
        requested_unit        TYPE mara-meins,
        required_through_date TYPE d,
      END OF ty_coverage_unit_request.
    TYPES ty_coverage_unit_requests TYPE STANDARD TABLE OF
      ty_coverage_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_coverage_unit_bulk_item,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        wbs_element           TYPE ty_wbs_element,
        requested_unit        TYPE mara-meins,
        required_through_date TYPE d,
        coverage              TYPE ty_reservation_coverage_in_unit,
      END OF ty_coverage_unit_bulk_item.
    TYPES ty_coverage_unit_bulk_items TYPE STANDARD TABLE OF
      ty_coverage_unit_bulk_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_coverage_bulk_item,
        request_id            TYPE c LENGTH 30,
        wbs_element           TYPE ty_wbs_element,
        required_through_date TYPE d,
        coverage              TYPE ty_reservation_coverages,
      END OF ty_coverage_bulk_item.
    TYPES ty_coverage_bulk_items TYPE STANDARD TABLE OF
      ty_coverage_bulk_item WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_repository     TYPE REF TO zif_project_stock_repository OPTIONAL
        io_uom_converter  TYPE REF TO zif_material_uom_converter OPTIONAL
        io_uom_repository TYPE REF TO zif_material_uom_repository OPTIONAL.

    METHODS read_available_stock
      IMPORTING
        it_keys                     TYPE zif_project_stock_repository=>ty_keys
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_stocks)            TYPE ty_available_stocks
      RAISING
        zcx_invalid_stock_request.

    METHODS read_available_stock_bulk
      IMPORTING
        it_requests       TYPE ty_available_stock_requests
      RETURNING
        VALUE(rt_results) TYPE ty_available_stock_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_available_stock_in_unit
      IMPORTING
        iv_material                 TYPE mard-matnr
        iv_plant                    TYPE mard-werks
        iv_wbs_element              TYPE ty_wbs_element
        iv_unit                     TYPE mara-meins
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_stocks)            TYPE ty_available_stocks_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS read_available_stock_bulk_uom
      IMPORTING
        it_requests       TYPE ty_available_stock_unit_requests
      RETURNING
        VALUE(rt_results) TYPE ty_available_stock_bulk_unit_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_open_reservations
      IMPORTING
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_reservations)   TYPE ty_open_reservations
      RAISING
        zcx_invalid_stock_request.

    METHODS read_open_reservations_bulk
      IMPORTING
        it_requests       TYPE ty_open_reservation_requests
      RETURNING
        VALUE(rt_results) TYPE ty_open_reservation_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_items
      IMPORTING
        it_wbs_elements        TYPE zif_project_stock_repository=>ty_wbs_elements
      RETURNING
        VALUE(rt_reservations) TYPE ty_reservation_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_items_bulk
      IMPORTING
        it_requests       TYPE ty_reservation_items_requests
      RETURNING
        VALUE(rt_results) TYPE ty_reservation_items_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage
      IMPORTING
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_coverage)       TYPE ty_reservation_coverages
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage_uom
      IMPORTING
        iv_material              TYPE mard-matnr
        iv_plant                 TYPE mard-werks
        iv_wbs_element           TYPE ty_wbs_element
        iv_unit                  TYPE mara-meins
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rs_coverage)       TYPE ty_reservation_coverage_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS read_resv_coverage_bulk_uom
      IMPORTING
        it_requests       TYPE ty_coverage_unit_requests
      RETURNING
        VALUE(rt_results) TYPE ty_coverage_unit_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage_bulk
      IMPORTING
        it_requests       TYPE ty_coverage_requests
      RETURNING
        VALUE(rt_results) TYPE ty_coverage_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo
      IMPORTING
        it_demands                   TYPE ty_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days   TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo_by_date
      IMPORTING
        it_demands                   TYPE ty_dated_fefo_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days   TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_dated_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location
      IMPORTING
        it_demands                   TYPE ty_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location_date
      IMPORTING
        it_demands                   TYPE ty_dated_location_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_dated_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo
      IMPORTING
        it_demands                   TYPE ty_transfer_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days   TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_transfer_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo_by_date
      IMPORTING
        it_demands                   TYPE ty_dated_transfer_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days   TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_dated_transfer_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_by_location
      IMPORTING
        it_demands                   TYPE ty_transfer_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_transfer_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_location_date
      IMPORTING
        it_demands                   TYPE ty_dated_location_transfer_demands
        it_storage_location_priority TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date  TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_dated_location_transfer_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_request_key,
      ty_request_keys TYPE HASHED TABLE OF ty_request_key
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_storage_location_key,
        storage_location TYPE mard-lgort,
      END OF ty_storage_location_key,
      ty_storage_location_set TYPE HASHED TABLE OF
        ty_storage_location_key WITH UNIQUE KEY storage_location,
      BEGIN OF ty_stock_key,
        material    TYPE mard-matnr,
        plant       TYPE mard-werks,
        wbs_element TYPE ty_wbs_element,
      END OF ty_stock_key,
      ty_stock_key_set TYPE HASHED TABLE OF ty_stock_key
        WITH UNIQUE KEY material plant wbs_element,
      BEGIN OF ty_material_base_unit,
        material  TYPE mard-matnr,
        base_unit TYPE mara-meins,
      END OF ty_material_base_unit,
      ty_material_base_units TYPE HASHED TABLE OF ty_material_base_unit
        WITH UNIQUE KEY material,
      BEGIN OF ty_stock_unit_ratio,
        material TYPE mard-matnr,
        unit     TYPE mara-meins,
        result   TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_stock_unit_ratio,
      ty_stock_unit_ratios TYPE HASHED TABLE OF ty_stock_unit_ratio
        WITH UNIQUE KEY material unit,
      BEGIN OF ty_prepared_demand,
        request_id              TYPE c LENGTH 30,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        unit                    TYPE mara-meins,
        base_quantity           TYPE mard-labst,
        base_unit               TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
      END OF ty_prepared_demand,
      ty_prepared_demands TYPE STANDARD TABLE OF
        ty_prepared_demand WITH EMPTY KEY,
      BEGIN OF ty_dated_fefo_work,
        input_index   TYPE i,
        required_date TYPE d,
        priority      TYPE i,
        demand        TYPE ty_dated_fefo_demand,
      END OF ty_dated_fefo_work,
      ty_dated_fefo_works TYPE STANDARD TABLE OF
        ty_dated_fefo_work WITH EMPTY KEY,
      BEGIN OF ty_dated_fefo_index,
        request_id    TYPE c LENGTH 30,
        input_index   TYPE i,
        required_date TYPE d,
        priority      TYPE i,
      END OF ty_dated_fefo_index,
      ty_dated_fefo_indexes TYPE HASHED TABLE OF ty_dated_fefo_index
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_dated_allocation_order,
        input_index TYPE i,
        result      TYPE ty_dated_fefo_allocation,
      END OF ty_dated_allocation_order,
      ty_dated_allocation_orders TYPE STANDARD TABLE OF
        ty_dated_allocation_order WITH EMPTY KEY,
      BEGIN OF ty_dated_split_order,
        input_index TYPE i,
        split_index TYPE i,
        result      TYPE ty_dated_fefo_batch_split,
      END OF ty_dated_split_order,
      ty_dated_split_orders TYPE STANDARD TABLE OF
        ty_dated_split_order WITH EMPTY KEY,
      BEGIN OF ty_dated_location_work,
        input_index   TYPE i,
        required_date TYPE d,
        priority      TYPE i,
        demand        TYPE ty_dated_location_demand,
      END OF ty_dated_location_work,
      ty_dated_location_works TYPE STANDARD TABLE OF
        ty_dated_location_work WITH EMPTY KEY,
      BEGIN OF ty_dated_location_allocation_order,
        input_index TYPE i,
        result      TYPE ty_dated_location_allocation,
      END OF ty_dated_location_allocation_order,
      ty_dated_location_allocation_orders TYPE STANDARD TABLE OF
        ty_dated_location_allocation_order WITH EMPTY KEY,
      BEGIN OF ty_dated_location_split_order,
        input_index TYPE i,
        split_index TYPE i,
        result      TYPE ty_dated_location_split,
      END OF ty_dated_location_split_order,
      ty_dated_location_split_orders TYPE STANDARD TABLE OF
        ty_dated_location_split_order WITH EMPTY KEY,
      BEGIN OF ty_dated_transfer_work,
        input_index   TYPE i,
        required_date TYPE d,
        priority      TYPE i,
        demand        TYPE ty_dated_transfer_demand,
      END OF ty_dated_transfer_work,
      ty_dated_transfer_works TYPE STANDARD TABLE OF
        ty_dated_transfer_work WITH EMPTY KEY,
      BEGIN OF ty_dated_location_transfer_work,
        input_index   TYPE i,
        required_date TYPE d,
        priority      TYPE i,
        demand        TYPE ty_dated_location_transfer_demand,
      END OF ty_dated_location_transfer_work,
      ty_dated_location_transfer_works TYPE STANDARD TABLE OF
        ty_dated_location_transfer_work WITH EMPTY KEY,
      BEGIN OF ty_stock_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        expiration_date    TYPE mcha-vfdat,
        remaining_quantity TYPE mspr-prlab,
      END OF ty_stock_balance,
      ty_stock_balances TYPE HASHED TABLE OF ty_stock_balance
        WITH UNIQUE KEY material plant wbs_element storage_location batch,
      BEGIN OF ty_candidate,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        wbs_element          TYPE ty_wbs_element,
        storage_location     TYPE mard-lgort,
        batch                TYPE mchb-charg,
        expiration_date      TYPE mcha-vfdat,
        sort_expiration_date TYPE d,
        location_priority    TYPE i,
      END OF ty_candidate,
      ty_candidates TYPE STANDARD TABLE OF ty_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        storage_location   TYPE mard-lgort,
        remaining_quantity TYPE mspr-prlab,
      END OF ty_location_balance,
      ty_location_balances TYPE HASHED TABLE OF ty_location_balance
        WITH UNIQUE KEY material plant wbs_element storage_location,
      BEGIN OF ty_location_candidate,
        material          TYPE mard-matnr,
        plant             TYPE mard-werks,
        wbs_element       TYPE ty_wbs_element,
        storage_location  TYPE mard-lgort,
        location_priority TYPE i,
      END OF ty_location_candidate,
      ty_location_candidates TYPE STANDARD TABLE OF
        ty_location_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_work,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        wbs_element          TYPE ty_wbs_element,
        storage_location     TYPE mard-lgort,
        batch                TYPE mchb-charg,
        specificity          TYPE i,
        outstanding_quantity TYPE resb-bdmng,
      END OF ty_reservation_work,
      ty_reservation_worklist TYPE STANDARD TABLE OF
        ty_reservation_work WITH EMPTY KEY.

    DATA mo_repository TYPE REF TO zif_project_stock_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
    DATA mo_uom_repository TYPE REF TO zif_material_uom_repository.

    METHODS validate_optional_date
      IMPORTING
        iv_date TYPE d
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_required_date
      IMPORTING
        iv_date TYPE d
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_coverage_to_unit
      IMPORTING
        is_coverage        TYPE ty_reservation_coverage
        iv_unit            TYPE mara-meins
        is_unit_ratio      TYPE zif_material_uom_converter=>ty_unit_ratio
      RETURNING
        VALUE(rs_coverage) TYPE ty_reservation_coverage_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS subtract_project_reservations
      IMPORTING
        it_stocks                   TYPE zif_project_stock_repository=>ty_stocks
        it_reservations             TYPE zif_project_stock_repository=>ty_reservations
        iv_batch_only               TYPE abap_bool
        iv_all_stock_types          TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_stocks)            TYPE zif_project_stock_repository=>ty_stocks
      RAISING
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_project_stock_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    IF mo_repository IS NOT BOUND.
      mo_repository = NEW zcl_project_stock_repository( ).
    ENDIF.

    mo_uom_repository = io_uom_repository.
    IF mo_uom_repository IS NOT BOUND.
      mo_uom_repository = NEW zcl_material_uom_repository( ).
    ENDIF.

    mo_uom_converter = io_uom_converter.
    IF mo_uom_converter IS NOT BOUND.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = mo_uom_repository ).
    ENDIF.
  ENDMETHOD.

  METHOD read_available_stock.
    DATA lt_seen_keys TYPE ty_stock_key_set.
    DATA lt_material_units TYPE ty_material_base_units.
    DATA lt_requested_stocks TYPE zif_project_stock_repository=>ty_stocks.

    validate_optional_date( iv_date = iv_reservation_through_date ).
    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_keys INTO DATA(ls_key).
      IF ls_key-material IS INITIAL
          OR ls_key-plant IS INITIAL
          OR ls_key-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        material    = ls_key-material
        plant       = ls_key-plant
        wbs_element = ls_key-wbs_element ) INTO TABLE lt_seen_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_raw_stocks) = mo_repository->read_project_stocks(
      it_keys = it_keys ).
    DATA(lt_reservations) = mo_repository->read_project_reservations(
      it_keys = it_keys ).
    LOOP AT lt_raw_stocks INTO DATA(ls_raw_stock).
      IF line_exists( lt_seen_keys[
        material = ls_raw_stock-material
        plant = ls_raw_stock-plant
        wbs_element = ls_raw_stock-wbs_element ] ).
        APPEND ls_raw_stock TO lt_requested_stocks.
      ENDIF.
    ENDLOOP.
    DATA(lt_available_stocks) = subtract_project_reservations(
      it_stocks                   = lt_requested_stocks
      it_reservations             = lt_reservations
      iv_batch_only               = abap_false
      iv_all_stock_types          = abap_true
      iv_reservation_through_date = iv_reservation_through_date ).
    SORT lt_available_stocks BY material plant wbs_element
      storage_location batch.

    LOOP AT lt_available_stocks INTO DATA(ls_stock).
      IF ls_stock-material IS INITIAL
          OR ls_stock-plant IS INITIAL
          OR ls_stock-wbs_element IS INITIAL
          OR ls_stock-storage_location IS INITIAL
          OR ls_stock-unrestricted_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_material_units
        WITH TABLE KEY material = ls_stock-material
        INTO DATA(ls_material_unit).
      IF sy-subrc <> 0.
        ls_material_unit = VALUE #(
          material  = ls_stock-material
          base_unit = mo_uom_repository->get_base_unit(
            iv_material = ls_stock-material ) ).
        IF ls_material_unit-base_unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_material_unit INTO TABLE lt_material_units.
      ENDIF.

      APPEND VALUE #(
        material           = ls_stock-material
        plant              = ls_stock-plant
        wbs_element        = ls_stock-wbs_element
        storage_location   = ls_stock-storage_location
        batch              = ls_stock-batch
        expiration_date    = ls_stock-expiration_date
        available_quantity = ls_stock-unrestricted_quantity
        base_unit          = ls_material_unit-base_unit ) TO rt_stocks.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_available_stock_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_reservation_date TYPE d.
    TYPES ty_reservation_dates TYPE HASHED TABLE OF ty_reservation_date
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_dated_stock,
        reservation_through_date TYPE d,
        stock                    TYPE ty_available_stock,
      END OF ty_dated_stock.
    TYPES ty_dated_stocks TYPE STANDARD TABLE OF ty_dated_stock
      WITH EMPTY KEY.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_dates TYPE ty_reservation_dates.
    DATA lt_dated_stocks TYPE ty_dated_stocks.
    DATA lt_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_seen_keys TYPE ty_stock_key_set.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date(
        iv_date = ls_request-reservation_through_date ).
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-reservation_through_date INTO TABLE lt_dates.
    ENDLOOP.

    LOOP AT lt_dates INTO DATA(lv_reservation_through_date).
      CLEAR: lt_keys, lt_seen_keys.
      LOOP AT it_requests INTO ls_request
        WHERE reservation_through_date = lv_reservation_through_date.
        INSERT VALUE #(
          material    = ls_request-material
          plant       = ls_request-plant
          wbs_element = ls_request-wbs_element ) INTO TABLE lt_seen_keys.
        IF sy-subrc = 0.
          APPEND VALUE #(
            material    = ls_request-material
            plant       = ls_request-plant
            wbs_element = ls_request-wbs_element ) TO lt_keys.
        ENDIF.
      ENDLOOP.

      DATA(lt_stocks) = read_available_stock(
        it_keys                     = lt_keys
        iv_reservation_through_date = lv_reservation_through_date ).
      LOOP AT lt_stocks INTO DATA(ls_stock).
        APPEND VALUE #(
          reservation_through_date = lv_reservation_through_date
          stock                    = ls_stock ) TO lt_dated_stocks.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results
        ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-material = ls_request-material.
      <ls_result>-plant = ls_request-plant.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_through_date =
        ls_request-reservation_through_date.
      LOOP AT lt_dated_stocks INTO DATA(ls_dated_stock)
        WHERE reservation_through_date =
          ls_request-reservation_through_date
          AND stock-material = ls_request-material
          AND stock-plant = ls_request-plant
          AND stock-wbs_element = ls_request-wbs_element.
        APPEND ls_dated_stock-stock TO <ls_result>-stocks.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_available_stock_in_unit.
    DATA(lt_results) = read_available_stock_bulk_uom(
      it_requests = VALUE #(
        ( request_id               = 'SINGLE'
          material                 = iv_material
          plant                    = iv_plant
          wbs_element              = iv_wbs_element
          requested_unit           = iv_unit
          reservation_through_date = iv_reservation_through_date ) ) ).
    IF lines( lt_results ) <> 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    rt_stocks = lt_results[ 1 ]-stocks.
  ENDMETHOD.

  METHOD read_available_stock_bulk_uom.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_unit_ratios TYPE ty_stock_unit_ratios.
    DATA lt_base_requests TYPE ty_available_stock_requests.
    DATA lt_base_results TYPE ty_available_stock_bulk_items.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-wbs_element IS INITIAL
          OR ls_request-requested_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date(
        iv_date = ls_request-reservation_through_date ).
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_unit_ratios INTO DATA(ls_unit_ratio)
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-requested_unit.
      IF sy-subrc <> 0.
        ls_unit_ratio = VALUE #(
          material = ls_request-material
          unit     = ls_request-requested_unit
          result   = mo_uom_converter->get_material_unit_ratio(
            iv_material         = ls_request-material
            iv_alternative_unit = ls_request-requested_unit ) ).
        IF ls_unit_ratio-result-is_successful <> abap_true
            OR ls_unit_ratio-result-base_unit IS INITIAL
            OR ls_unit_ratio-result-numerator <= 0
            OR ls_unit_ratio-result-denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_unit_ratio INTO TABLE lt_unit_ratios.
      ENDIF.
      APPEND VALUE #(
        request_id               = ls_request-request_id
        material                 = ls_request-material
        plant                    = ls_request-plant
        wbs_element              = ls_request-wbs_element
        reservation_through_date =
          ls_request-reservation_through_date )
        TO lt_base_requests.
    ENDLOOP.

    lt_base_results = read_available_stock_bulk(
      it_requests = lt_base_requests ).
    IF lines( lt_base_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_base_results INTO DATA(ls_base_result).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE it_requests INTO ls_request INDEX lv_request_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_unit_ratios INTO ls_unit_ratio
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-requested_unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_results
        ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-request_id = ls_base_result-request_id.
      <ls_result>-material = ls_base_result-material.
      <ls_result>-plant = ls_base_result-plant.
      <ls_result>-wbs_element = ls_base_result-wbs_element.
      <ls_result>-requested_unit = ls_request-requested_unit.
      <ls_result>-reservation_through_date =
        ls_base_result-reservation_through_date.

      LOOP AT ls_base_result-stocks INTO DATA(ls_base_stock).
        IF ls_base_stock-base_unit <> ls_unit_ratio-result-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          material           = ls_base_stock-material
          plant              = ls_base_stock-plant
          wbs_element        = ls_base_stock-wbs_element
          storage_location   = ls_base_stock-storage_location
          batch              = ls_base_stock-batch
          expiration_date    = ls_base_stock-expiration_date
          available_quantity = CONV mspr-prlab(
            CONV decfloat34( ls_base_stock-available_quantity )
            * CONV decfloat34( ls_unit_ratio-result-denominator )
            / CONV decfloat34( ls_unit_ratio-result-numerator ) )
          unit               = ls_request-requested_unit
          base_quantity      = ls_base_stock-available_quantity
          base_unit          = ls_base_stock-base_unit )
          TO <ls_result>-stocks.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_open_reservations.
    TYPES:
      BEGIN OF ty_reservation_identity,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_reservation_identity.
    TYPES ty_reservation_identities TYPE HASHED TABLE OF
      ty_reservation_identity WITH UNIQUE KEY reservation_number
        reservation_item.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_seen_reservations TYPE ty_reservation_identities.

    validate_optional_date( iv_date = iv_required_through_date ).
    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_wbs_elements INTO DATA(lv_wbs_element).
      IF lv_wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_rows) = mo_repository->read_project_reservations_wbs(
      it_wbs_elements = it_wbs_elements ).
    LOOP AT lt_rows INTO DATA(ls_row).
      IF NOT line_exists( lt_seen_wbs_elements[
        table_line = ls_row-wbs_element ] ).
        CONTINUE.
      ENDIF.
      IF iv_required_through_date IS NOT INITIAL
          AND ls_row-required_date IS NOT INITIAL
          AND ls_row-required_date > iv_required_through_date.
        CONTINUE.
      ENDIF.
      IF ls_row-reservation_number IS INITIAL
          OR ls_row-reservation_item IS INITIAL
          OR ls_row-material IS INITIAL
          OR ls_row-plant IS INITIAL
          OR ls_row-wbs_element IS INITIAL
          OR ls_row-unit IS INITIAL
          OR ls_row-required_quantity <= ls_row-withdrawn_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_row-reservation_number
        reservation_item   = ls_row-reservation_item )
        INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        reservation_number = ls_row-reservation_number
        reservation_item   = ls_row-reservation_item
        material           = ls_row-material
        plant              = ls_row-plant
        wbs_element        = ls_row-wbs_element
        storage_location   = ls_row-storage_location
        batch              = ls_row-batch
        required_date      = ls_row-required_date
        unit               = ls_row-unit
        entry_unit         = ls_row-entry_unit
        required_quantity  = ls_row-required_quantity
        withdrawn_quantity = ls_row-withdrawn_quantity
        open_quantity      = ls_row-required_quantity
          - ls_row-withdrawn_quantity ) TO rt_reservations.
    ENDLOOP.

    SORT rt_reservations BY required_date reservation_number
      reservation_item.
  ENDMETHOD.

  METHOD read_open_reservations_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_reservation_date TYPE d.
    TYPES ty_reservation_dates TYPE HASHED TABLE OF ty_reservation_date
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_dated_reservation,
        required_through_date TYPE d,
        reservation           TYPE ty_open_reservation,
      END OF ty_dated_reservation.
    TYPES ty_dated_reservations TYPE STANDARD TABLE OF
      ty_dated_reservation WITH EMPTY KEY.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_dates TYPE ty_reservation_dates.
    DATA lt_dated_reservations TYPE ty_dated_reservations.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date( iv_date = ls_request-required_through_date ).
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-required_through_date INTO TABLE lt_dates.
    ENDLOOP.

    LOOP AT lt_dates INTO DATA(lv_required_through_date).
      CLEAR lt_wbs_elements.
      LOOP AT it_requests INTO ls_request
        WHERE required_through_date = lv_required_through_date.
        IF NOT line_exists( lt_wbs_elements[
          table_line = ls_request-wbs_element ] ).
          APPEND ls_request-wbs_element TO lt_wbs_elements.
        ENDIF.
      ENDLOOP.

      DATA(lt_reservations) = read_open_reservations(
        it_wbs_elements          = lt_wbs_elements
        iv_required_through_date = lv_required_through_date ).
      LOOP AT lt_reservations INTO DATA(ls_reservation).
        APPEND VALUE #(
          required_through_date = lv_required_through_date
          reservation           = ls_reservation )
          TO lt_dated_reservations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results
        ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-required_through_date =
        ls_request-required_through_date.
      LOOP AT lt_dated_reservations INTO DATA(ls_dated_reservation)
        WHERE required_through_date = ls_request-required_through_date
          AND reservation-wbs_element = ls_request-wbs_element.
        APPEND ls_dated_reservation-reservation
          TO <ls_result>-reservations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_reservation_items.
    TYPES:
      BEGIN OF ty_reservation_identity,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_reservation_identity.
    TYPES ty_reservation_identities TYPE HASHED TABLE OF
      ty_reservation_identity WITH UNIQUE KEY reservation_number
        reservation_item.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_seen_reservations TYPE ty_reservation_identities.

    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_wbs_elements INTO DATA(lv_wbs_element).
      IF lv_wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lt_rows) = mo_repository->read_project_resv_items_wbs(
      it_wbs_elements = it_wbs_elements ).
    LOOP AT lt_rows INTO DATA(ls_row).
      IF NOT line_exists( lt_seen_wbs_elements[
        table_line = ls_row-wbs_element ] ).
        CONTINUE.
      ENDIF.
      IF ls_row-reservation_number IS INITIAL
          OR ls_row-reservation_item IS INITIAL
          OR ls_row-material IS INITIAL
          OR ls_row-plant IS INITIAL
          OR ls_row-wbs_element IS INITIAL
          OR ls_row-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_row-reservation_number
        reservation_item   = ls_row-reservation_item )
        INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(ls_reservation) = ls_row.
      ls_reservation-open_quantity =
        ls_reservation-required_quantity
        - ls_reservation-withdrawn_quantity.
      APPEND ls_reservation TO rt_reservations.
    ENDLOOP.

    SORT rt_reservations BY wbs_element reservation_number
      reservation_item.
  ENDMETHOD.

  METHOD read_reservation_items_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF NOT line_exists( lt_wbs_elements[
        table_line = ls_request-wbs_element ] ).
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.
    ENDLOOP.

    DATA(lt_reservations) = read_reservation_items(
      it_wbs_elements = lt_wbs_elements ).
    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results
        ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-wbs_element = ls_request-wbs_element.
      LOOP AT lt_reservations INTO DATA(ls_reservation)
        WHERE wbs_element = ls_request-wbs_element.
        APPEND ls_reservation TO <ls_result>-reservations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
  METHOD read_reservation_coverage.
    TYPES:
      BEGIN OF ty_coverage_balance,
        material               TYPE mard-matnr,
        plant                  TYPE mard-werks,
        wbs_element            TYPE ty_wbs_element,
        base_unit              TYPE mara-meins,
        project_stock_quantity TYPE mspr-prlab,
        reserved_quantity      TYPE mspr-prlab,
        available_quantity     TYPE mspr-prlab,
        open_reservation_items TYPE i,
      END OF ty_coverage_balance.
    TYPES ty_coverage_balances TYPE HASHED TABLE OF ty_coverage_balance
      WITH UNIQUE KEY material plant wbs_element.
    TYPES ty_seen_wbs_element TYPE ty_wbs_element.
    DATA lt_balances TYPE ty_coverage_balances.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF ty_seen_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_eligible_stocks TYPE zif_project_stock_repository=>ty_stocks.
    DATA lt_reservation_deductions TYPE
      zif_project_stock_repository=>ty_reservations.

    DATA(lt_open_reservations) = read_open_reservations(
      it_wbs_elements          = it_wbs_elements
      iv_required_through_date = iv_required_through_date ).
    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_wbs_elements INTO DATA(lv_wbs_element).
      INSERT lv_wbs_element INTO TABLE lt_seen_wbs_elements.
    ENDLOOP.

    DATA(lt_project_stocks) = mo_repository->read_project_stocks_wbs(
      it_wbs_elements = it_wbs_elements ).
    LOOP AT lt_project_stocks INTO DATA(ls_project_stock).
      IF NOT line_exists( lt_seen_wbs_elements[
        table_line = ls_project_stock-wbs_element ] ).
        CONTINUE.
      ENDIF.
      IF ls_project_stock-material IS INITIAL
          OR ls_project_stock-plant IS INITIAL
          OR ls_project_stock-wbs_element IS INITIAL
          OR ls_project_stock-storage_location IS INITIAL
          OR ls_project_stock-unrestricted_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_balances ASSIGNING FIELD-SYMBOL(<ls_balance>)
        WITH TABLE KEY material = ls_project_stock-material
                       plant = ls_project_stock-plant
                       wbs_element = ls_project_stock-wbs_element.
      IF sy-subrc <> 0.
        DATA(lv_base_unit) = mo_uom_repository->get_base_unit(
          iv_material = ls_project_stock-material ).
        IF lv_base_unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          material    = ls_project_stock-material
          plant       = ls_project_stock-plant
          wbs_element = ls_project_stock-wbs_element
          base_unit   = lv_base_unit ) INTO TABLE lt_balances.
        READ TABLE lt_balances ASSIGNING <ls_balance>
          WITH TABLE KEY material = ls_project_stock-material
                         plant = ls_project_stock-plant
                         wbs_element = ls_project_stock-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      ADD ls_project_stock-unrestricted_quantity
        TO <ls_balance>-project_stock_quantity.
      APPEND ls_project_stock TO lt_eligible_stocks.
    ENDLOOP.

    LOOP AT lt_open_reservations INTO DATA(ls_open_reservation).
      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_open_reservation-material
        iv_quantity    = ls_open_reservation-open_quantity
        iv_source_unit = ls_open_reservation-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit IS INITIAL
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_balances ASSIGNING <ls_balance>
        WITH TABLE KEY material = ls_open_reservation-material
                       plant = ls_open_reservation-plant
                       wbs_element = ls_open_reservation-wbs_element.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material    = ls_open_reservation-material
          plant       = ls_open_reservation-plant
          wbs_element = ls_open_reservation-wbs_element
          base_unit   = ls_conversion-base_unit ) INTO TABLE lt_balances.
        READ TABLE lt_balances ASSIGNING <ls_balance>
          WITH TABLE KEY material = ls_open_reservation-material
                         plant = ls_open_reservation-plant
                         wbs_element = ls_open_reservation-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ELSEIF <ls_balance>-base_unit <> ls_conversion-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ADD ls_conversion-base_quantity TO <ls_balance>-reserved_quantity.
      <ls_balance>-open_reservation_items =
        <ls_balance>-open_reservation_items + 1.
      APPEND VALUE #(
        reservation_number = ls_open_reservation-reservation_number
        reservation_item   = ls_open_reservation-reservation_item
        material           = ls_open_reservation-material
        plant              = ls_open_reservation-plant
        wbs_element        = ls_open_reservation-wbs_element
        storage_location   = ls_open_reservation-storage_location
        batch              = ls_open_reservation-batch
        required_date      = ls_open_reservation-required_date
        unit               = ls_conversion-base_unit
        required_quantity  = ls_conversion-base_quantity )
        TO lt_reservation_deductions.
    ENDLOOP.

    DATA(lt_available_stocks) = subtract_project_reservations(
      it_stocks          = lt_eligible_stocks
      it_reservations    = lt_reservation_deductions
      iv_batch_only      = abap_false
      iv_all_stock_types = abap_true ).
    LOOP AT lt_available_stocks INTO DATA(ls_available_stock).
      READ TABLE lt_balances ASSIGNING <ls_balance>
        WITH TABLE KEY material = ls_available_stock-material
                       plant = ls_available_stock-plant
                       wbs_element = ls_available_stock-wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ADD ls_available_stock-unrestricted_quantity
        TO <ls_balance>-available_quantity.
    ENDLOOP.

    LOOP AT lt_balances INTO DATA(ls_balance).
      DATA(lv_shortfall) = ls_balance-reserved_quantity
        - ls_balance-project_stock_quantity.
      IF lv_shortfall < 0.
        CLEAR lv_shortfall.
      ENDIF.
      APPEND VALUE #(
        material               = ls_balance-material
        plant                  = ls_balance-plant
        wbs_element            = ls_balance-wbs_element
        base_unit              = ls_balance-base_unit
        project_stock_quantity = ls_balance-project_stock_quantity
        reserved_quantity      = ls_balance-reserved_quantity
        available_quantity     = ls_balance-available_quantity
        shortfall_quantity     = lv_shortfall
        open_reservation_items = ls_balance-open_reservation_items
        is_fully_covered       = xsdbool( lv_shortfall = 0 ) )
        TO rt_coverage.
    ENDLOOP.
    SORT rt_coverage BY wbs_element material plant.
  ENDMETHOD.

  METHOD read_reservation_coverage_uom.
    DATA ls_coverage TYPE ty_reservation_coverage.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_wbs_element IS INITIAL
        OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_optional_date( iv_date = iv_required_through_date ).

    DATA(ls_unit_ratio) = mo_uom_converter->get_material_unit_ratio(
      iv_material         = iv_material
      iv_alternative_unit = iv_unit ).
    IF ls_unit_ratio-is_successful <> abap_true
        OR ls_unit_ratio-base_unit IS INITIAL
        OR ls_unit_ratio-numerator <= 0
        OR ls_unit_ratio-denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    ls_coverage = VALUE #(
      material    = iv_material
      plant       = iv_plant
      wbs_element = iv_wbs_element
      base_unit   = ls_unit_ratio-base_unit ).

    DATA(lt_coverage) = read_reservation_coverage(
      it_wbs_elements          = VALUE #(
        ( iv_wbs_element ) )
      iv_required_through_date = iv_required_through_date ).
    READ TABLE lt_coverage INTO DATA(ls_found_coverage)
      WITH KEY material = iv_material
               plant = iv_plant
               wbs_element = iv_wbs_element.
    IF sy-subrc = 0.
      ls_coverage = ls_found_coverage.
    ENDIF.
    rs_coverage = convert_coverage_to_unit(
      is_coverage   = ls_coverage
      iv_unit       = iv_unit
      is_unit_ratio = ls_unit_ratio ).
  ENDMETHOD.

  METHOD read_resv_coverage_bulk_uom.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_unit_ratios TYPE ty_stock_unit_ratios.
    DATA lt_base_requests TYPE ty_coverage_requests.
    DATA lt_base_results TYPE ty_coverage_bulk_items.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-wbs_element IS INITIAL
          OR ls_request-requested_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date(
        iv_date = ls_request-required_through_date ).
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_unit_ratios INTO DATA(ls_unit_ratio)
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-requested_unit.
      IF sy-subrc <> 0.
        ls_unit_ratio = VALUE #(
          material = ls_request-material
          unit     = ls_request-requested_unit
          result   = mo_uom_converter->get_material_unit_ratio(
            iv_material         = ls_request-material
            iv_alternative_unit = ls_request-requested_unit ) ).
        IF ls_unit_ratio-result-is_successful <> abap_true
            OR ls_unit_ratio-result-base_unit IS INITIAL
            OR ls_unit_ratio-result-numerator <= 0
            OR ls_unit_ratio-result-denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_unit_ratio INTO TABLE lt_unit_ratios.
      ENDIF.
      APPEND VALUE #(
        request_id            = ls_request-request_id
        wbs_element           = ls_request-wbs_element
        required_through_date = ls_request-required_through_date )
        TO lt_base_requests.
    ENDLOOP.

    lt_base_results = read_reservation_coverage_bulk(
      it_requests = lt_base_requests ).
    IF lines( lt_base_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_base_results INTO DATA(ls_base_result).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE it_requests INTO ls_request INDEX lv_request_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_unit_ratios INTO ls_unit_ratio
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-requested_unit.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_base_coverage) = VALUE ty_reservation_coverage(
        material    = ls_request-material
        plant       = ls_request-plant
        wbs_element = ls_request-wbs_element
        base_unit   = ls_unit_ratio-result-base_unit ).
      READ TABLE ls_base_result-coverage INTO DATA(ls_found_coverage)
        WITH KEY material = ls_request-material
                 plant = ls_request-plant
                 wbs_element = ls_request-wbs_element.
      IF sy-subrc = 0.
        ls_base_coverage = ls_found_coverage.
      ENDIF.

      APPEND VALUE #(
        request_id            = ls_base_result-request_id
        material              = ls_request-material
        plant                 = ls_request-plant
        wbs_element           = ls_request-wbs_element
        requested_unit        = ls_request-requested_unit
        required_through_date = ls_base_result-required_through_date
        coverage              = convert_coverage_to_unit(
          is_coverage   = ls_base_coverage
          iv_unit       = ls_request-requested_unit
          is_unit_ratio = ls_unit_ratio-result ) ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.
  METHOD read_reservation_coverage_bulk.
    TYPES ty_seen_request_id TYPE c LENGTH 30.
    TYPES ty_coverage_date TYPE d.
    TYPES ty_coverage_dates TYPE HASHED TABLE OF ty_coverage_date
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_dated_coverage,
        required_through_date TYPE d,
        coverage              TYPE ty_reservation_coverage,
      END OF ty_dated_coverage.
    TYPES ty_dated_coverages TYPE STANDARD TABLE OF
      ty_dated_coverage WITH EMPTY KEY.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_seen_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_dates TYPE ty_coverage_dates.
    DATA lt_dated_coverage TYPE ty_dated_coverages.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    FIELD-SYMBOLS <ls_result> TYPE ty_coverage_bulk_item.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date( iv_date = ls_request-required_through_date ).
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-required_through_date INTO TABLE lt_dates.
    ENDLOOP.

    LOOP AT lt_dates INTO DATA(lv_required_through_date).
      CLEAR lt_wbs_elements.
      LOOP AT it_requests INTO ls_request
        WHERE required_through_date = lv_required_through_date.
        IF NOT line_exists( lt_wbs_elements[
          table_line = ls_request-wbs_element ] ).
          APPEND ls_request-wbs_element TO lt_wbs_elements.
        ENDIF.
      ENDLOOP.

      DATA(lt_coverage) = read_reservation_coverage(
        it_wbs_elements          = lt_wbs_elements
        iv_required_through_date = lv_required_through_date ).
      LOOP AT lt_coverage INTO DATA(ls_coverage).
        APPEND VALUE #(
          required_through_date = lv_required_through_date
          coverage              = ls_coverage ) TO lt_dated_coverage.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results ASSIGNING <ls_result>.
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-required_through_date =
        ls_request-required_through_date.
      LOOP AT lt_dated_coverage INTO DATA(ls_dated_coverage)
        WHERE required_through_date = ls_request-required_through_date
          AND coverage-wbs_element = ls_request-wbs_element.
        APPEND ls_dated_coverage-coverage
          TO <ls_result>-coverage.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_fefo.
    DATA lt_seen_requests TYPE ty_request_keys.
    DATA lt_seen_locations TYPE ty_storage_location_set.
    DATA lt_allowed_locations TYPE ty_storage_location_set.
    DATA lt_prepared_demands TYPE ty_prepared_demands.
    DATA lt_stock_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_stock_balances TYPE ty_stock_balances.
    DATA lt_candidates TYPE ty_candidates.
    DATA lv_demand_as_of_date TYPE d.
    DATA lv_demand_minimum_shelf_life TYPE i.
    DATA lv_remaining_shelf_life_days TYPE i.

    validate_required_date( iv_date = iv_as_of_date ).
    validate_optional_date( iv_date = iv_reservation_through_date ).
    IF iv_minimum_shelf_life_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_storage_location_priority INTO DATA(lv_priority_location).
      IF lv_priority_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( storage_location = lv_priority_location )
        INTO TABLE lt_seen_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_allowed_storage_locations INTO DATA(lv_allowed_location).
      IF lv_allowed_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( storage_location = lv_allowed_location )
        INTO TABLE lt_allowed_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_demands IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-wbs_element IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-minimum_shelf_life_days < 0
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_demand-storage_location ] ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date( iv_date = ls_demand-fefo_as_of_date ).
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_demand-material
        iv_quantity    = ls_demand-requested_quantity
        iv_source_unit = ls_demand-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit IS INITIAL
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        material    = ls_demand-material
        plant       = ls_demand-plant
        wbs_element = ls_demand-wbs_element )
        TO lt_stock_keys.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        unit                    = ls_demand-unit
        base_quantity           = ls_conversion-base_quantity
        base_unit               = ls_conversion-base_unit
        fefo_as_of_date         = ls_demand-fefo_as_of_date
        minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days )
        TO lt_prepared_demands.
      APPEND VALUE #(
        request_id  = ls_demand-request_id
        wbs_element = ls_demand-wbs_element )
        TO rs_result-wbs_assignments.
    ENDLOOP.

    DATA(lt_raw_project_stocks) = mo_repository->read_project_stocks(
      it_keys = lt_stock_keys ).
    DATA(lt_project_reservations) =
      mo_repository->read_project_reservations(
        it_keys = lt_stock_keys ).
    DATA(lt_project_stocks) = subtract_project_reservations(
      it_stocks                   = lt_raw_project_stocks
      it_reservations             = lt_project_reservations
      iv_batch_only               = abap_true
      iv_reservation_through_date = iv_reservation_through_date ).
    LOOP AT lt_project_stocks INTO DATA(ls_project_stock).
      IF ls_project_stock-material IS INITIAL
          OR ls_project_stock-plant IS INITIAL
          OR ls_project_stock-wbs_element IS INITIAL
          OR ls_project_stock-storage_location IS INITIAL
          OR ls_project_stock-batch IS INITIAL
          OR ls_project_stock-unrestricted_quantity <= 0.
        CONTINUE.
      ENDIF.
      validate_optional_date( iv_date = ls_project_stock-expiration_date ).
      INSERT VALUE #(
        material           = ls_project_stock-material
        plant              = ls_project_stock-plant
        wbs_element        = ls_project_stock-wbs_element
        storage_location   = ls_project_stock-storage_location
        batch              = ls_project_stock-batch
        expiration_date    = ls_project_stock-expiration_date
        remaining_quantity = ls_project_stock-unrestricted_quantity )
        INTO TABLE lt_stock_balances.
      IF sy-subrc <> 0.
        READ TABLE lt_stock_balances ASSIGNING FIELD-SYMBOL(<ls_existing_balance>)
          WITH TABLE KEY material = ls_project_stock-material
                         plant = ls_project_stock-plant
                         wbs_element = ls_project_stock-wbs_element
                         storage_location = ls_project_stock-storage_location
                         batch = ls_project_stock-batch.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF <ls_existing_balance>-expiration_date
            <> ls_project_stock-expiration_date.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ADD ls_project_stock-unrestricted_quantity
          TO <ls_existing_balance>-remaining_quantity.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_prepared_demands INTO DATA(ls_prepared_demand).
      lv_demand_as_of_date = iv_as_of_date.
      IF ls_prepared_demand-fefo_as_of_date > lv_demand_as_of_date.
        lv_demand_as_of_date = ls_prepared_demand-fefo_as_of_date.
      ENDIF.
      lv_demand_minimum_shelf_life = iv_minimum_shelf_life_days.
      IF ls_prepared_demand-minimum_shelf_life_days
          > lv_demand_minimum_shelf_life.
        lv_demand_minimum_shelf_life =
          ls_prepared_demand-minimum_shelf_life_days.
      ENDIF.
      CLEAR lt_candidates.
      LOOP AT lt_stock_balances INTO DATA(ls_balance)
        WHERE material = ls_prepared_demand-material
          AND plant = ls_prepared_demand-plant
          AND wbs_element = ls_prepared_demand-wbs_element.
        IF ls_prepared_demand-storage_location IS NOT INITIAL
            AND ls_balance-storage_location
              <> ls_prepared_demand-storage_location.
          CONTINUE.
        ENDIF.
        IF ls_prepared_demand-batch IS NOT INITIAL
            AND ls_balance-batch <> ls_prepared_demand-batch.
          CONTINUE.
        ENDIF.
        IF lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_balance-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF ls_balance-expiration_date IS INITIAL.
          IF iv_include_undated_batches = abap_false
              OR lv_demand_minimum_shelf_life > 0.
            CONTINUE.
          ENDIF.
        ELSEIF ls_balance-expiration_date < lv_demand_as_of_date.
          CONTINUE.
        ELSE.
          lv_remaining_shelf_life_days =
            ls_balance-expiration_date - lv_demand_as_of_date.
          IF lv_remaining_shelf_life_days
              < lv_demand_minimum_shelf_life.
            CONTINUE.
          ENDIF.
        ENDIF.

        DATA(lv_location_priority) = lines(
          it_storage_location_priority ) + 1.
        READ TABLE it_storage_location_priority
          TRANSPORTING NO FIELDS
          WITH KEY table_line = ls_balance-storage_location.
        IF sy-subrc = 0.
          lv_location_priority = sy-tabix.
        ENDIF.
        DATA(lv_sort_expiration_date) = ls_balance-expiration_date.
        IF lv_sort_expiration_date IS INITIAL.
          lv_sort_expiration_date = '99991231'.
        ENDIF.
        APPEND VALUE #(
          material             = ls_balance-material
          plant                = ls_balance-plant
          wbs_element          = ls_balance-wbs_element
          storage_location     = ls_balance-storage_location
          batch                = ls_balance-batch
          expiration_date      = ls_balance-expiration_date
          sort_expiration_date = lv_sort_expiration_date
          location_priority    = lv_location_priority )
          TO lt_candidates.
      ENDLOOP.
      SORT lt_candidates BY sort_expiration_date ASCENDING
                            location_priority ASCENDING
                            storage_location ASCENDING
                            batch ASCENDING.

      DATA(ls_allocation) = VALUE zcl_stock_service=>ty_allocation(
        request_id         = ls_prepared_demand-request_id
        material           = ls_prepared_demand-material
        plant              = ls_prepared_demand-plant
        requested_quantity = ls_prepared_demand-base_quantity ).
      LOOP AT lt_candidates INTO DATA(ls_candidate).
        READ TABLE lt_stock_balances ASSIGNING FIELD-SYMBOL(<ls_balance>)
          WITH TABLE KEY material = ls_candidate-material
                         plant = ls_candidate-plant
                         wbs_element = ls_candidate-wbs_element
                         storage_location = ls_candidate-storage_location
                         batch = ls_candidate-batch.
        IF sy-subrc = 0.
          ls_allocation-available_quantity =
            ls_allocation-available_quantity
            + <ls_balance>-remaining_quantity.
        ENDIF.
      ENDLOOP.

      DATA lv_remaining_quantity TYPE mard-labst.
      DATA lv_allocated_quantity TYPE mard-labst.
      lv_remaining_quantity = ls_prepared_demand-base_quantity.
      CLEAR lv_allocated_quantity.
      IF iv_require_full_quantity = abap_true
          AND ls_prepared_demand-base_quantity
            > ls_allocation-available_quantity.
        ls_allocation-shortfall_quantity =
          ls_prepared_demand-base_quantity.
      ELSE.
        LOOP AT lt_candidates INTO ls_candidate.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.
          READ TABLE lt_stock_balances ASSIGNING <ls_balance>
            WITH TABLE KEY material = ls_candidate-material
                           plant = ls_candidate-plant
                           wbs_element = ls_candidate-wbs_element
                           storage_location = ls_candidate-storage_location
                           batch = ls_candidate-batch.
          IF sy-subrc <> 0 OR <ls_balance>-remaining_quantity <= 0.
            CONTINUE.
          ENDIF.

          DATA(lv_split_quantity) = lv_remaining_quantity.
          IF <ls_balance>-remaining_quantity < lv_split_quantity.
            lv_split_quantity = <ls_balance>-remaining_quantity.
          ENDIF.
          DATA(ls_source_split) = mo_uom_converter->convert_from_base(
            iv_material      = ls_prepared_demand-material
            iv_base_quantity = lv_split_quantity
            iv_target_unit   = ls_prepared_demand-unit ).
          IF ls_source_split-is_successful <> abap_true
              OR ls_source_split-alternative_unit
                <> ls_prepared_demand-unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.

          APPEND VALUE #(
            batch_allocation          = VALUE #(
              request_id              = ls_prepared_demand-request_id
              material                = ls_prepared_demand-material
              plant                   = ls_prepared_demand-plant
              storage_location        = ls_candidate-storage_location
              batch                   = ls_candidate-batch
              expiration_date         = ls_candidate-expiration_date
              as_of_date              = lv_demand_as_of_date
              minimum_shelf_life_days =
                lv_demand_minimum_shelf_life
              allocated_quantity      = lv_split_quantity )
            base_unit                 = ls_prepared_demand-base_unit
            source_unit               = ls_prepared_demand-unit
            allocated_source_quantity =
              ls_source_split-alternative_quantity )
            TO rs_result-allocation-batch_allocations.
          SUBTRACT lv_split_quantity FROM <ls_balance>-remaining_quantity.
          SUBTRACT lv_split_quantity FROM lv_remaining_quantity.
          ADD lv_split_quantity TO lv_allocated_quantity.
        ENDLOOP.
        ls_allocation-allocated_quantity = lv_allocated_quantity.
        ls_allocation-shortfall_quantity = lv_remaining_quantity.
      ENDIF.

      DATA lv_allocated_source_quantity TYPE mard-labst.
      DATA lv_shortfall_source_quantity TYPE mard-labst.
      CLEAR: lv_allocated_source_quantity, lv_shortfall_source_quantity.
      IF lv_allocated_quantity > 0.
        DATA(ls_allocated_source) = mo_uom_converter->convert_from_base(
          iv_material      = ls_prepared_demand-material
          iv_base_quantity = lv_allocated_quantity
          iv_target_unit   = ls_prepared_demand-unit ).
        IF ls_allocated_source-is_successful <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_allocated_source_quantity =
          ls_allocated_source-alternative_quantity.
      ENDIF.
      IF ls_allocation-shortfall_quantity > 0.
        DATA(ls_shortfall_source) = mo_uom_converter->convert_from_base(
          iv_material      = ls_prepared_demand-material
          iv_base_quantity = ls_allocation-shortfall_quantity
          iv_target_unit   = ls_prepared_demand-unit ).
        IF ls_shortfall_source-is_successful <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_shortfall_source_quantity =
          ls_shortfall_source-alternative_quantity.
      ENDIF.

      APPEND VALUE #(
        allocation                = ls_allocation
        source_quantity           = ls_prepared_demand-requested_quantity
        source_unit               = ls_prepared_demand-unit
        base_quantity             = ls_prepared_demand-base_quantity
        base_unit                 = ls_prepared_demand-base_unit
        allocated_source_quantity = lv_allocated_source_quantity
        shortfall_source_quantity = lv_shortfall_source_quantity )
        TO rs_result-allocation-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_fefo_by_date.
    DATA lt_work TYPE ty_dated_fefo_works.
    DATA lt_sorted_demands TYPE ty_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_allocation_order TYPE ty_dated_allocation_orders.
    DATA lt_split_order TYPE ty_dated_split_orders.
    DATA lv_input_index TYPE i.

    LOOP AT it_demands INTO DATA(ls_demand).
      ADD 1 TO lv_input_index.
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date( iv_date = ls_demand-required_date ).
      validate_optional_date( iv_date = ls_demand-fefo_as_of_date ).
      INSERT VALUE #(
        request_id    = ls_demand-request_id
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_demand ) TO lt_work.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      DATA(lv_fefo_as_of_date) = ls_work-demand-fefo_as_of_date.
      IF lv_fefo_as_of_date < ls_work-required_date.
        lv_fefo_as_of_date = ls_work-required_date.
      ENDIF.
      APPEND VALUE #(
        request_id              = ls_work-demand-request_id
        wbs_element             = ls_work-demand-wbs_element
        material                = ls_work-demand-material
        plant                   = ls_work-demand-plant
        storage_location        = ls_work-demand-storage_location
        batch                   = ls_work-demand-batch
        requested_quantity      = ls_work-demand-requested_quantity
        unit                    = ls_work-demand-unit
        fefo_as_of_date         = lv_fefo_as_of_date
        minimum_shelf_life_days =
          ls_work-demand-minimum_shelf_life_days )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_fefo(
      it_demands                   = lt_sorted_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).

    IF lines( ls_local_result-allocation-allocations )
        <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT ls_local_result-allocation-allocations
        INTO DATA(ls_local_allocation).
      READ TABLE lt_demand_indexes INTO DATA(ls_allocation_index)
        WITH TABLE KEY request_id =
          ls_local_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_demand ) TO lt_work.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation    = ls_local_allocation
          required_date = ls_allocation_index-required_date
          priority      = ls_allocation_index-priority ) )
        TO lt_allocation_order.
    ENDLOOP.
    SORT lt_allocation_order BY input_index ASCENDING.
    LOOP AT lt_allocation_order INTO DATA(ls_allocation_order).
      APPEND ls_allocation_order-result TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_local_result-allocation-batch_allocations
        INTO DATA(ls_local_split).
      DATA(lv_split_index) = sy-tabix.
      READ TABLE lt_demand_indexes INTO DATA(ls_split_index)
        WITH TABLE KEY request_id =
          ls_local_split-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split         = ls_local_split
          required_date = ls_split_index-required_date
          priority      = ls_split_index-priority ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-batch_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      APPEND VALUE #(
        request_id    = ls_demand-request_id
        wbs_element   = ls_demand-wbs_element
        required_date = ls_demand-required_date
        priority      = ls_demand-priority )
        TO rs_result-wbs_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_by_location.
    DATA lt_seen_requests TYPE ty_request_keys.
    DATA lt_seen_priority TYPE ty_storage_location_set.
    DATA lt_allowed_locations TYPE ty_storage_location_set.
    DATA lt_prepared_demands TYPE ty_prepared_demands.
    DATA lt_stock_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_location_balances TYPE ty_location_balances.
    DATA lt_candidates TYPE ty_location_candidates.

    validate_optional_date( iv_date = iv_reservation_through_date ).
    IF iv_require_full_quantity <> abap_true
        AND iv_require_full_quantity <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_storage_location_priority INTO DATA(lv_priority_location).
      IF lv_priority_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( storage_location = lv_priority_location )
        INTO TABLE lt_seen_priority.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_allowed_storage_locations INTO DATA(lv_allowed_location).
      IF lv_allowed_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( storage_location = lv_allowed_location )
        INTO TABLE lt_allowed_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_demands IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-wbs_element IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-batch IS NOT INITIAL
          OR ls_demand-fefo_as_of_date IS NOT INITIAL
          OR ls_demand-minimum_shelf_life_days <> 0
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_demand-storage_location ] ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_demand-material
        iv_quantity    = ls_demand-requested_quantity
        iv_source_unit = ls_demand-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit IS INITIAL
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        material    = ls_demand-material
        plant       = ls_demand-plant
        wbs_element = ls_demand-wbs_element )
        TO lt_stock_keys.
      APPEND VALUE #(
        request_id         = ls_demand-request_id
        wbs_element        = ls_demand-wbs_element
        material           = ls_demand-material
        plant              = ls_demand-plant
        storage_location   = ls_demand-storage_location
        requested_quantity = ls_demand-requested_quantity
        unit               = ls_demand-unit
        base_quantity      = ls_conversion-base_quantity
        base_unit          = ls_conversion-base_unit )
        TO lt_prepared_demands.
      APPEND VALUE #(
        request_id  = ls_demand-request_id
        wbs_element = ls_demand-wbs_element )
        TO rs_result-wbs_assignments.
    ENDLOOP.

    DATA(lt_raw_project_stocks) = mo_repository->read_project_stocks(
      it_keys = lt_stock_keys ).
    DATA(lt_project_reservations) =
      mo_repository->read_project_reservations(
        it_keys = lt_stock_keys ).
    DATA(lt_project_stocks) = subtract_project_reservations(
      it_stocks                   = lt_raw_project_stocks
      it_reservations             = lt_project_reservations
      iv_batch_only               = abap_false
      iv_reservation_through_date = iv_reservation_through_date ).
    LOOP AT lt_project_stocks INTO DATA(ls_project_stock).
      IF ls_project_stock-material IS INITIAL
          OR ls_project_stock-plant IS INITIAL
          OR ls_project_stock-wbs_element IS INITIAL
          OR ls_project_stock-storage_location IS INITIAL
          OR ls_project_stock-batch IS NOT INITIAL
          OR ls_project_stock-unrestricted_quantity <= 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        material           = ls_project_stock-material
        plant              = ls_project_stock-plant
        wbs_element        = ls_project_stock-wbs_element
        storage_location   = ls_project_stock-storage_location
        remaining_quantity = ls_project_stock-unrestricted_quantity )
        INTO TABLE lt_location_balances.
      IF sy-subrc <> 0.
        READ TABLE lt_location_balances
          ASSIGNING FIELD-SYMBOL(<ls_location_balance>)
          WITH TABLE KEY material = ls_project_stock-material
                         plant = ls_project_stock-plant
                         wbs_element = ls_project_stock-wbs_element
                         storage_location = ls_project_stock-storage_location.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ADD ls_project_stock-unrestricted_quantity
          TO <ls_location_balance>-remaining_quantity.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_prepared_demands INTO DATA(ls_prepared_demand).
      CLEAR lt_candidates.
      LOOP AT lt_location_balances INTO DATA(ls_balance)
        WHERE material = ls_prepared_demand-material
          AND plant = ls_prepared_demand-plant
          AND wbs_element = ls_prepared_demand-wbs_element.
        IF ls_prepared_demand-storage_location IS NOT INITIAL
            AND ls_balance-storage_location
              <> ls_prepared_demand-storage_location.
          CONTINUE.
        ENDIF.
        IF lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_balance-storage_location ] ).
          CONTINUE.
        ENDIF.

        DATA(lv_location_priority) = lines(
          it_storage_location_priority ) + 1.
        READ TABLE it_storage_location_priority
          TRANSPORTING NO FIELDS
          WITH KEY table_line = ls_balance-storage_location.
        IF sy-subrc = 0.
          lv_location_priority = sy-tabix.
        ENDIF.
        APPEND VALUE #(
          material          = ls_balance-material
          plant             = ls_balance-plant
          wbs_element       = ls_balance-wbs_element
          storage_location  = ls_balance-storage_location
          location_priority = lv_location_priority )
          TO lt_candidates.
      ENDLOOP.
      SORT lt_candidates BY location_priority ASCENDING
                            storage_location ASCENDING.

      DATA(ls_allocation) = VALUE zcl_stock_service=>ty_allocation(
        request_id         = ls_prepared_demand-request_id
        material           = ls_prepared_demand-material
        plant              = ls_prepared_demand-plant
        requested_quantity = ls_prepared_demand-base_quantity ).
      LOOP AT lt_candidates INTO DATA(ls_candidate).
        READ TABLE lt_location_balances INTO DATA(ls_available_balance)
          WITH TABLE KEY material = ls_candidate-material
                         plant = ls_candidate-plant
                         wbs_element = ls_candidate-wbs_element
                         storage_location = ls_candidate-storage_location.
        IF sy-subrc = 0.
          ls_allocation-available_quantity =
            ls_allocation-available_quantity
            + ls_available_balance-remaining_quantity.
        ENDIF.
      ENDLOOP.

      DATA lv_remaining_quantity TYPE mard-labst.
      DATA lv_allocated_quantity TYPE mard-labst.
      lv_remaining_quantity = ls_prepared_demand-base_quantity.
      CLEAR lv_allocated_quantity.
      IF iv_require_full_quantity = abap_true
          AND ls_prepared_demand-base_quantity
            > ls_allocation-available_quantity.
        ls_allocation-shortfall_quantity =
          ls_prepared_demand-base_quantity.
      ELSE.
        LOOP AT lt_candidates INTO ls_candidate.
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.
          READ TABLE lt_location_balances
            ASSIGNING FIELD-SYMBOL(<ls_alloc_balance>)
            WITH TABLE KEY material = ls_candidate-material
                           plant = ls_candidate-plant
                           wbs_element = ls_candidate-wbs_element
                           storage_location = ls_candidate-storage_location.
          IF sy-subrc <> 0
              OR <ls_alloc_balance>-remaining_quantity <= 0.
            CONTINUE.
          ENDIF.

          DATA(lv_split_quantity) = lv_remaining_quantity.
          IF <ls_alloc_balance>-remaining_quantity
              < lv_split_quantity.
            lv_split_quantity =
              <ls_alloc_balance>-remaining_quantity.
          ENDIF.
          DATA(ls_source_split) = mo_uom_converter->convert_from_base(
            iv_material      = ls_prepared_demand-material
            iv_base_quantity = lv_split_quantity
            iv_target_unit   = ls_prepared_demand-unit ).
          IF ls_source_split-is_successful <> abap_true
              OR ls_source_split-alternative_unit
                <> ls_prepared_demand-unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.

          APPEND VALUE #(
            storage_allocation        = VALUE #(
              request_id         = ls_prepared_demand-request_id
              material           = ls_prepared_demand-material
              plant              = ls_prepared_demand-plant
              storage_location   = ls_candidate-storage_location
              allocated_quantity = lv_split_quantity )
            base_unit                 = ls_prepared_demand-base_unit
            source_unit               = ls_prepared_demand-unit
            allocated_source_quantity =
              ls_source_split-alternative_quantity )
            TO rs_result-allocation-storage_allocations.
          SUBTRACT lv_split_quantity
            FROM <ls_alloc_balance>-remaining_quantity.
          SUBTRACT lv_split_quantity FROM lv_remaining_quantity.
          ADD lv_split_quantity TO lv_allocated_quantity.
        ENDLOOP.
        ls_allocation-allocated_quantity = lv_allocated_quantity.
        ls_allocation-shortfall_quantity = lv_remaining_quantity.
      ENDIF.

      DATA lv_allocated_source_quantity TYPE mard-labst.
      DATA lv_shortfall_source_quantity TYPE mard-labst.
      CLEAR: lv_allocated_source_quantity, lv_shortfall_source_quantity.
      IF lv_allocated_quantity > 0.
        DATA(ls_allocated_source) = mo_uom_converter->convert_from_base(
          iv_material      = ls_prepared_demand-material
          iv_base_quantity = lv_allocated_quantity
          iv_target_unit   = ls_prepared_demand-unit ).
        IF ls_allocated_source-is_successful <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_allocated_source_quantity =
          ls_allocated_source-alternative_quantity.
      ENDIF.
      IF ls_allocation-shortfall_quantity > 0.
        DATA(ls_shortfall_source) = mo_uom_converter->convert_from_base(
          iv_material      = ls_prepared_demand-material
          iv_base_quantity = ls_allocation-shortfall_quantity
          iv_target_unit   = ls_prepared_demand-unit ).
        IF ls_shortfall_source-is_successful <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_shortfall_source_quantity =
          ls_shortfall_source-alternative_quantity.
      ENDIF.

      APPEND VALUE #(
        allocation                = ls_allocation
        source_quantity           = ls_prepared_demand-requested_quantity
        source_unit               = ls_prepared_demand-unit
        base_quantity             = ls_prepared_demand-base_quantity
        base_unit                 = ls_prepared_demand-base_unit
        allocated_source_quantity = lv_allocated_source_quantity
        shortfall_source_quantity = lv_shortfall_source_quantity )
        TO rs_result-allocation-allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_by_location_date.
    DATA lt_work TYPE ty_dated_location_works.
    DATA lt_sorted_demands TYPE ty_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_allocation_order TYPE ty_dated_location_allocation_orders.
    DATA lt_split_order TYPE ty_dated_location_split_orders.
    DATA lv_input_index TYPE i.

    LOOP AT it_demands INTO DATA(ls_demand).
      ADD 1 TO lv_input_index.
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date( iv_date = ls_demand-required_date ).
      INSERT VALUE #(
        request_id    = ls_demand-request_id
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_demand ) TO lt_work.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      APPEND VALUE #(
        request_id         = ls_work-demand-request_id
        wbs_element        = ls_work-demand-wbs_element
        material           = ls_work-demand-material
        plant              = ls_work-demand-plant
        storage_location   = ls_work-demand-storage_location
        requested_quantity = ls_work-demand-requested_quantity
        unit               = ls_work-demand-unit )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_by_location(
      it_demands                   = lt_sorted_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).

    IF lines( ls_local_result-allocation-allocations )
        <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT ls_local_result-allocation-allocations
        INTO DATA(ls_local_allocation).
      READ TABLE lt_demand_indexes INTO DATA(ls_allocation_index)
        WITH TABLE KEY request_id =
          ls_local_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation    = ls_local_allocation
          required_date = ls_allocation_index-required_date
          priority      = ls_allocation_index-priority ) )
        TO lt_allocation_order.
    ENDLOOP.
    SORT lt_allocation_order BY input_index ASCENDING.
    LOOP AT lt_allocation_order INTO DATA(ls_allocation_order).
      APPEND ls_allocation_order-result TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_local_result-allocation-storage_allocations
        INTO DATA(ls_local_split).
      DATA(lv_split_index) = sy-tabix.
      READ TABLE lt_demand_indexes INTO DATA(ls_split_index)
        WITH TABLE KEY request_id =
          ls_local_split-storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split         = ls_local_split
          required_date = ls_split_index-required_date
          priority      = ls_split_index-priority ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-storage_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      APPEND VALUE #(
        request_id    = ls_demand-request_id
        wbs_element   = ls_demand-wbs_element
        required_date = ls_demand-required_date
        priority      = ls_demand-priority )
        TO rs_result-wbs_assignments.
    ENDLOOP.
  ENDMETHOD.
  METHOD preview_transfer_fefo.
    DATA lt_stock_demands TYPE ty_demands.

    validate_required_date( iv_date = iv_as_of_date ).
    validate_optional_date( iv_date = iv_reservation_through_date ).
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-source_wbs_element IS INITIAL
          OR ls_demand-destination_wbs_element IS INITIAL
          OR ls_demand-source_wbs_element
            = ls_demand-destination_wbs_element.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        request_id              = ls_demand-request_id
        wbs_element             = ls_demand-source_wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        unit                    = ls_demand-unit
        fefo_as_of_date         = ls_demand-fefo_as_of_date
        minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days )
        TO lt_stock_demands.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element = ls_demand-destination_wbs_element )
        TO rs_result-transfer_assignments.
    ENDLOOP.

    DATA(ls_stock_preview) = preview_fefo(
      it_demands                   = lt_stock_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    rs_result-allocation = ls_stock_preview-allocation.
  ENDMETHOD.

  METHOD preview_transfer_fefo_by_date.
    DATA lt_work TYPE ty_dated_transfer_works.
    DATA lt_sorted_demands TYPE ty_transfer_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_allocation_order TYPE ty_dated_allocation_orders.
    DATA lt_split_order TYPE ty_dated_split_orders.
    DATA lv_input_index TYPE i.

    LOOP AT it_demands INTO DATA(ls_demand).
      ADD 1 TO lv_input_index.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-source_wbs_element IS INITIAL
          OR ls_demand-destination_wbs_element IS INITIAL
          OR ls_demand-source_wbs_element
            = ls_demand-destination_wbs_element.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date( iv_date = ls_demand-required_date ).
      validate_optional_date( iv_date = ls_demand-fefo_as_of_date ).
      INSERT VALUE #(
        request_id    = ls_demand-request_id
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_demand ) TO lt_work.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      DATA(lv_fefo_as_of_date) = ls_work-demand-fefo_as_of_date.
      IF lv_fefo_as_of_date < ls_work-required_date.
        lv_fefo_as_of_date = ls_work-required_date.
      ENDIF.
      APPEND VALUE #(
        request_id              = ls_work-demand-request_id
        source_wbs_element      = ls_work-demand-source_wbs_element
        destination_wbs_element =
          ls_work-demand-destination_wbs_element
        material                = ls_work-demand-material
        plant                   = ls_work-demand-plant
        storage_location        = ls_work-demand-storage_location
        batch                   = ls_work-demand-batch
        requested_quantity      = ls_work-demand-requested_quantity
        unit                    = ls_work-demand-unit
        fefo_as_of_date         = lv_fefo_as_of_date
        minimum_shelf_life_days =
          ls_work-demand-minimum_shelf_life_days )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_transfer_fefo(
      it_demands                   = lt_sorted_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_minimum_shelf_life_days   = iv_minimum_shelf_life_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    IF lines( ls_local_result-allocation-allocations )
        <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT ls_local_result-allocation-allocations
        INTO DATA(ls_local_allocation).
      READ TABLE lt_demand_indexes INTO DATA(ls_allocation_index)
        WITH TABLE KEY request_id =
          ls_local_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation    = ls_local_allocation
          required_date = ls_allocation_index-required_date
          priority      = ls_allocation_index-priority ) )
        TO lt_allocation_order.
    ENDLOOP.
    SORT lt_allocation_order BY input_index ASCENDING.
    LOOP AT lt_allocation_order INTO DATA(ls_allocation_order).
      APPEND ls_allocation_order-result TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_local_result-allocation-batch_allocations
        INTO DATA(ls_local_split).
      DATA(lv_split_index) = sy-tabix.
      READ TABLE lt_demand_indexes INTO DATA(ls_split_index)
        WITH TABLE KEY request_id =
          ls_local_split-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split         = ls_local_split
          required_date = ls_split_index-required_date
          priority      = ls_split_index-priority ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-batch_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element = ls_demand-destination_wbs_element
        required_date           = ls_demand-required_date
        priority                = ls_demand-priority )
        TO rs_result-transfer_assignments.
    ENDLOOP.
  ENDMETHOD.
  METHOD preview_transfer_by_location.
    DATA lt_stock_demands TYPE ty_demands.

    validate_optional_date( iv_date = iv_reservation_through_date ).
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-source_wbs_element IS INITIAL
          OR ls_demand-destination_wbs_element IS INITIAL
          OR ls_demand-source_wbs_element
            = ls_demand-destination_wbs_element
          OR ls_demand-fefo_as_of_date IS NOT INITIAL
          OR ls_demand-minimum_shelf_life_days <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        request_id         = ls_demand-request_id
        wbs_element        = ls_demand-source_wbs_element
        material           = ls_demand-material
        plant              = ls_demand-plant
        storage_location   = ls_demand-storage_location
        batch              = ls_demand-batch
        requested_quantity = ls_demand-requested_quantity
        unit               = ls_demand-unit )
        TO lt_stock_demands.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element = ls_demand-destination_wbs_element )
        TO rs_result-transfer_assignments.
    ENDLOOP.

    DATA(ls_stock_preview) = preview_by_location(
      it_demands                   = lt_stock_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    rs_result-allocation = ls_stock_preview-allocation.
  ENDMETHOD.

  METHOD preview_transfer_location_date.
    DATA lt_work TYPE ty_dated_location_transfer_works.
    DATA lt_sorted_demands TYPE ty_transfer_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_allocation_order TYPE ty_dated_location_allocation_orders.
    DATA lt_split_order TYPE ty_dated_location_split_orders.
    DATA lv_input_index TYPE i.

    validate_optional_date( iv_date = iv_reservation_through_date ).
    LOOP AT it_demands INTO DATA(ls_demand).
      ADD 1 TO lv_input_index.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-source_wbs_element IS INITIAL
          OR ls_demand-destination_wbs_element IS INITIAL
          OR ls_demand-source_wbs_element
            = ls_demand-destination_wbs_element.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date( iv_date = ls_demand-required_date ).
      INSERT VALUE #(
        request_id    = ls_demand-request_id
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_demand ) TO lt_work.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      APPEND VALUE #(
        request_id              = ls_work-demand-request_id
        source_wbs_element      = ls_work-demand-source_wbs_element
        destination_wbs_element =
          ls_work-demand-destination_wbs_element
        material                = ls_work-demand-material
        plant                   = ls_work-demand-plant
        storage_location        = ls_work-demand-storage_location
        requested_quantity      = ls_work-demand-requested_quantity
        unit                    = ls_work-demand-unit )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_transfer_by_location(
      it_demands                   = lt_sorted_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).
    IF lines( ls_local_result-allocation-allocations )
        <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT ls_local_result-allocation-allocations
        INTO DATA(ls_local_allocation).
      READ TABLE lt_demand_indexes INTO DATA(ls_allocation_index)
        WITH TABLE KEY request_id =
          ls_local_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation    = ls_local_allocation
          required_date = ls_allocation_index-required_date
          priority      = ls_allocation_index-priority ) )
        TO lt_allocation_order.
    ENDLOOP.
    SORT lt_allocation_order BY input_index ASCENDING.
    LOOP AT lt_allocation_order INTO DATA(ls_allocation_order).
      APPEND ls_allocation_order-result TO rs_result-allocations.
    ENDLOOP.

    LOOP AT ls_local_result-allocation-storage_allocations
        INTO DATA(ls_local_split).
      DATA(lv_split_index) = sy-tabix.
      READ TABLE lt_demand_indexes INTO DATA(ls_split_index)
        WITH TABLE KEY request_id =
          ls_local_split-storage_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split         = ls_local_split
          required_date = ls_split_index-required_date
          priority      = ls_split_index-priority ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-storage_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element =
          ls_demand-destination_wbs_element
        required_date           = ls_demand-required_date
        priority                = ls_demand-priority )
        TO rs_result-transfer_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD subtract_project_reservations.
    DATA lt_reservation_worklist TYPE ty_reservation_worklist.
    IF ( iv_batch_only <> abap_true AND iv_batch_only <> abap_false )
        OR ( iv_all_stock_types <> abap_true
          AND iv_all_stock_types <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_stocks = it_stocks.
    DELETE rt_stocks WHERE storage_location IS INITIAL.
    IF iv_all_stock_types = abap_true.
      " Keep both stock types for a single combined reservation deduction.
    ELSEIF iv_batch_only = abap_true.
      DELETE rt_stocks WHERE batch IS INITIAL.
    ELSE.
      DELETE rt_stocks WHERE batch IS NOT INITIAL.
    ENDIF.
    SORT rt_stocks BY material plant wbs_element storage_location batch.

    LOOP AT it_reservations INTO DATA(ls_reservation).
      IF ls_reservation-material IS INITIAL
          OR ls_reservation-plant IS INITIAL
          OR ls_reservation-wbs_element IS INITIAL
          OR ls_reservation-required_quantity
            <= ls_reservation-withdrawn_quantity.
        CONTINUE.
      ENDIF.
      IF iv_reservation_through_date IS NOT INITIAL
          AND ls_reservation-required_date IS NOT INITIAL
          AND ls_reservation-required_date > iv_reservation_through_date.
        CONTINUE.
      ENDIF.
      IF iv_all_stock_types = abap_false
          AND iv_batch_only = abap_false
          AND ls_reservation-batch IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_specificity) = 2.
      IF ls_reservation-storage_location IS NOT INITIAL
          AND ls_reservation-batch IS NOT INITIAL.
        lv_specificity = 1.
      ELSEIF ls_reservation-storage_location IS INITIAL
          AND ls_reservation-batch IS INITIAL.
        lv_specificity = 3.
      ENDIF.
      APPEND VALUE #(
        material             = ls_reservation-material
        plant                = ls_reservation-plant
        wbs_element          = ls_reservation-wbs_element
        storage_location     = ls_reservation-storage_location
        batch                = ls_reservation-batch
        specificity          = lv_specificity
        outstanding_quantity = ls_reservation-required_quantity
          - ls_reservation-withdrawn_quantity )
        TO lt_reservation_worklist.
    ENDLOOP.

    SORT lt_reservation_worklist BY material plant wbs_element
      specificity storage_location batch.
    LOOP AT lt_reservation_worklist INTO DATA(ls_reservation_work).
      DATA(lv_remaining_quantity) =
        ls_reservation_work-outstanding_quantity.
      LOOP AT rt_stocks ASSIGNING FIELD-SYMBOL(<ls_stock>)
        WHERE material = ls_reservation_work-material
          AND plant = ls_reservation_work-plant
          AND wbs_element = ls_reservation_work-wbs_element.
        IF ( ls_reservation_work-storage_location IS NOT INITIAL
            AND <ls_stock>-storage_location
              <> ls_reservation_work-storage_location )
            OR ( ls_reservation_work-batch IS NOT INITIAL
              AND <ls_stock>-batch <> ls_reservation_work-batch )
            OR <ls_stock>-unrestricted_quantity <= 0.
          CONTINUE.
        ENDIF.

        DATA(lv_deduction) = CONV mspr-prlab( lv_remaining_quantity ).
        IF <ls_stock>-unrestricted_quantity < lv_deduction.
          lv_deduction = <ls_stock>-unrestricted_quantity.
        ENDIF.
        <ls_stock>-unrestricted_quantity =
          <ls_stock>-unrestricted_quantity - lv_deduction.
        lv_remaining_quantity = lv_remaining_quantity - lv_deduction.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_remaining_quantity <= 0.
        CONTINUE.
      ENDIF.

      LOOP AT rt_stocks ASSIGNING <ls_stock>
        WHERE material = ls_reservation_work-material
          AND plant = ls_reservation_work-plant
          AND wbs_element = ls_reservation_work-wbs_element.
        IF <ls_stock>-unrestricted_quantity <= 0.
          CONTINUE.
        ENDIF.

        lv_deduction = CONV mspr-prlab( lv_remaining_quantity ).
        IF <ls_stock>-unrestricted_quantity < lv_deduction.
          lv_deduction = <ls_stock>-unrestricted_quantity.
        ENDIF.
        <ls_stock>-unrestricted_quantity =
          <ls_stock>-unrestricted_quantity - lv_deduction.
        lv_remaining_quantity = lv_remaining_quantity - lv_deduction.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_coverage_to_unit.
    IF is_unit_ratio-is_successful <> abap_true
        OR is_unit_ratio-base_unit IS INITIAL
        OR is_unit_ratio-numerator <= 0
        OR is_unit_ratio-denominator <= 0
        OR is_coverage-base_unit <> is_unit_ratio-base_unit.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_coverage-material = is_coverage-material.
    rs_coverage-plant = is_coverage-plant.
    rs_coverage-wbs_element = is_coverage-wbs_element.
    rs_coverage-unit = iv_unit.
    rs_coverage-base_unit = is_coverage-base_unit.
    rs_coverage-base_project_stock_quantity =
      is_coverage-project_stock_quantity.
    rs_coverage-base_reserved_quantity = is_coverage-reserved_quantity.
    rs_coverage-base_available_quantity = is_coverage-available_quantity.
    rs_coverage-base_shortfall_quantity = is_coverage-shortfall_quantity.
    rs_coverage-project_stock_quantity = CONV mspr-prlab(
      CONV decfloat34( is_coverage-project_stock_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ) ).
    rs_coverage-reserved_quantity = CONV mspr-prlab(
      CONV decfloat34( is_coverage-reserved_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ) ).
    rs_coverage-available_quantity = CONV mspr-prlab(
      CONV decfloat34( is_coverage-available_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ) ).
    rs_coverage-shortfall_quantity = CONV mspr-prlab(
      CONV decfloat34( is_coverage-shortfall_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ) ).
    rs_coverage-open_reservation_items =
      is_coverage-open_reservation_items.
    rs_coverage-is_fully_covered = is_coverage-is_fully_covered.
  ENDMETHOD.
  METHOD validate_optional_date.
    IF iv_date IS INITIAL.
      RETURN.
    ENDIF.
    validate_required_date( iv_date = iv_date ).
  ENDMETHOD.

  METHOD validate_required_date.
    IF zcl_date_validation=>is_valid_gregorian_date(
      iv_date = iv_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
