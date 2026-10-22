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
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        location_as_of_date     TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_demand.
    TYPES ty_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_batch_receipt,
        wbs_element      TYPE ty_wbs_element,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        expiration_date  TYPE mcha-vfdat,
        receipt_date     TYPE d,
        base_quantity    TYPE mspr-prlab,
      END OF ty_projected_batch_receipt.
    TYPES ty_projected_batch_receipts TYPE STANDARD TABLE OF
      ty_projected_batch_receipt WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_location_receipt,
        wbs_element      TYPE ty_wbs_element,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        receipt_date     TYPE d,
        base_quantity    TYPE mspr-prlab,
      END OF ty_projected_location_receipt.
    TYPES ty_projected_location_receipts TYPE STANDARD TABLE OF
      ty_projected_location_receipt WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_fefo_demand,
        request_id              TYPE c LENGTH 30,
        priority                TYPE i,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_priority_fefo_demand.
    TYPES ty_priority_fefo_demands TYPE STANDARD TABLE OF
      ty_priority_fefo_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_location_demand,
        request_id              TYPE c LENGTH 30,
        priority                TYPE i,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        allow_location_fallback TYPE abap_bool,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        location_as_of_date     TYPE d,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_priority_location_demand.
    TYPES ty_priority_location_demands TYPE STANDARD TABLE OF
      ty_priority_location_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_demand,
        request_id              TYPE c LENGTH 30,
        required_date           TYPE d,
        priority                TYPE i,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
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
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        location_as_of_date     TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_transfer_demand.
    TYPES ty_transfer_demands TYPE STANDARD TABLE OF
      ty_transfer_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_transfer_fefo_demand,
        request_id              TYPE c LENGTH 30,
        priority                TYPE i,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_priority_transfer_fefo_demand.
    TYPES ty_priority_transfer_fefo_demands TYPE STANDARD TABLE OF
      ty_priority_transfer_fefo_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_location_transfer_demand,
        request_id              TYPE c LENGTH 30,
        priority                TYPE i,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        allow_location_fallback TYPE abap_bool,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        location_as_of_date     TYPE d,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_priority_location_transfer_demand.
    TYPES ty_priority_location_transfer_demands TYPE STANDARD TABLE OF
      ty_priority_location_transfer_demand WITH EMPTY KEY.
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
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_dated_transfer_demand.
    TYPES ty_dated_transfer_demands TYPE STANDARD TABLE OF
      ty_dated_transfer_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_wbs_assignment,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE ty_wbs_element,
        allocation_sequence TYPE i,
      END OF ty_wbs_assignment.
    TYPES ty_wbs_assignments TYPE STANDARD TABLE OF
      ty_wbs_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_assignment,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        allocation_sequence     TYPE i,
      END OF ty_transfer_assignment.
    TYPES ty_transfer_assignments TYPE STANDARD TABLE OF
      ty_transfer_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_transfer_assignment,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        priority                TYPE i,
        allocation_sequence     TYPE i,
      END OF ty_priority_transfer_assignment.
    TYPES ty_priority_transfer_assignments TYPE STANDARD TABLE OF
      ty_priority_transfer_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_request_location,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
      END OF ty_request_location.
    TYPES ty_request_locations TYPE STANDARD TABLE OF
      ty_request_location WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result,
        allocation        TYPE zcl_stock_service=>ty_unit_batch_result,
        wbs_assignments   TYPE ty_wbs_assignments,
        request_locations TYPE ty_request_locations,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_fefo_atp_result,
        local_estimate TYPE ty_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_fefo_atp_result.
    TYPES:
      BEGIN OF ty_priority_fefo_allocation,
        allocation          TYPE zcl_stock_service=>ty_unit_allocation_summary,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_priority_fefo_allocation.
    TYPES ty_priority_fefo_allocations TYPE STANDARD TABLE OF
      ty_priority_fefo_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_fefo_batch_split,
        split               TYPE zcl_stock_service=>ty_unit_batch_split,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_priority_fefo_batch_split.
    TYPES ty_priority_fefo_batch_splits TYPE STANDARD TABLE OF
      ty_priority_fefo_batch_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_wbs_assignment,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE ty_wbs_element,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_priority_wbs_assignment.
    TYPES ty_priority_wbs_assignments TYPE STANDARD TABLE OF
      ty_priority_wbs_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_fefo_result,
        allocations       TYPE ty_priority_fefo_allocations,
        batch_allocations TYPE ty_priority_fefo_batch_splits,
        wbs_assignments   TYPE ty_priority_wbs_assignments,
        request_locations TYPE ty_request_locations,
      END OF ty_priority_fefo_result.
    TYPES:
      BEGIN OF ty_priority_fefo_atp_result,
        local_estimate TYPE ty_priority_fefo_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_priority_fefo_atp_result.
    TYPES:
      BEGIN OF ty_priority_location_allocation,
        allocation          TYPE zcl_stock_service=>ty_unit_allocation_summary,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_priority_location_allocation.
    TYPES ty_priority_location_allocations TYPE STANDARD TABLE OF
      ty_priority_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_location_split,
        split               TYPE zcl_stock_service=>ty_unit_storage_split,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_priority_location_split.
    TYPES ty_priority_location_splits TYPE STANDARD TABLE OF
      ty_priority_location_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_priority_location_result,
        allocations         TYPE ty_priority_location_allocations,
        storage_allocations TYPE ty_priority_location_splits,
        wbs_assignments     TYPE ty_priority_wbs_assignments,
        request_locations   TYPE ty_request_locations,
      END OF ty_priority_location_result.
    TYPES:
      BEGIN OF ty_priority_loc_atp_result,
        local_estimate TYPE ty_priority_location_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_priority_loc_atp_result.
    TYPES:
      BEGIN OF ty_dated_fefo_allocation,
        allocation          TYPE zcl_stock_service=>ty_unit_allocation_summary,
        required_date       TYPE d,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_dated_fefo_allocation.
    TYPES ty_dated_fefo_allocations TYPE STANDARD TABLE OF
      ty_dated_fefo_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_batch_split,
        split               TYPE zcl_stock_service=>ty_unit_batch_split,
        required_date       TYPE d,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_dated_fefo_batch_split.
    TYPES ty_dated_fefo_batch_splits TYPE STANDARD TABLE OF
      ty_dated_fefo_batch_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_wbs_assignment,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE ty_wbs_element,
        required_date       TYPE d,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_dated_wbs_assignment.
    TYPES ty_dated_wbs_assignments TYPE STANDARD TABLE OF
      ty_dated_wbs_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_result,
        allocations       TYPE ty_dated_fefo_allocations,
        batch_allocations TYPE ty_dated_fefo_batch_splits,
        wbs_assignments   TYPE ty_dated_wbs_assignments,
        request_locations TYPE ty_request_locations,
      END OF ty_dated_fefo_result.
    TYPES:
      BEGIN OF ty_dated_fefo_atp_result,
        local_estimate TYPE ty_dated_fefo_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_dated_fefo_atp_result.
    TYPES:
      BEGIN OF ty_dated_location_demand,
        request_id              TYPE c LENGTH 30,
        required_date           TYPE d,
        priority                TYPE i,
        wbs_element             TYPE ty_wbs_element,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        allow_location_fallback TYPE abap_bool,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
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
        allow_location_fallback TYPE abap_bool,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_dated_location_transfer_demand.
    TYPES ty_dated_location_transfer_demands TYPE STANDARD TABLE OF
      ty_dated_location_transfer_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_allocation,
        allocation          TYPE zcl_stock_service=>ty_unit_allocation_summary,
        required_date       TYPE d,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_dated_location_allocation.
    TYPES ty_dated_location_allocations TYPE STANDARD TABLE OF
      ty_dated_location_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_split,
        split               TYPE zcl_stock_service=>ty_unit_storage_split,
        required_date       TYPE d,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_dated_location_split.
    TYPES ty_dated_location_splits TYPE STANDARD TABLE OF
      ty_dated_location_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_result,
        allocations         TYPE ty_dated_location_allocations,
        storage_allocations TYPE ty_dated_location_splits,
        wbs_assignments     TYPE ty_dated_wbs_assignments,
        request_locations   TYPE ty_request_locations,
      END OF ty_dated_location_result.
    TYPES:
      BEGIN OF ty_dated_location_atp_result,
        local_estimate TYPE ty_dated_location_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_dated_location_atp_result.
    TYPES:
      BEGIN OF ty_location_result,
        allocation        TYPE zcl_stock_service=>ty_unit_location_result,
        wbs_assignments   TYPE ty_wbs_assignments,
        request_locations TYPE ty_request_locations,
      END OF ty_location_result.
    TYPES:
      BEGIN OF ty_location_atp_result,
        local_estimate TYPE ty_location_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_location_atp_result.
    TYPES:
      BEGIN OF ty_transfer_result,
        allocation           TYPE zcl_stock_service=>ty_unit_batch_result,
        transfer_assignments TYPE ty_transfer_assignments,
        request_locations    TYPE ty_request_locations,
      END OF ty_transfer_result.
    TYPES:
      BEGIN OF ty_transfer_atp_result,
        local_estimate TYPE ty_transfer_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_transfer_atp_result.
    TYPES:
      BEGIN OF ty_dated_transfer_assignment,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        required_date           TYPE d,
        priority                TYPE i,
        allocation_sequence     TYPE i,
      END OF ty_dated_transfer_assignment.
    TYPES ty_dated_transfer_assignments TYPE STANDARD TABLE OF
      ty_dated_transfer_assignment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_transfer_result,
        allocations          TYPE ty_dated_fefo_allocations,
        batch_allocations    TYPE ty_dated_fefo_batch_splits,
        transfer_assignments TYPE ty_dated_transfer_assignments,
        request_locations    TYPE ty_request_locations,
      END OF ty_dated_transfer_result.
    TYPES:
      BEGIN OF ty_dated_transfer_atp_result,
        local_estimate TYPE ty_dated_transfer_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_dated_transfer_atp_result.
    TYPES:
      BEGIN OF ty_priority_transfer_fefo_result,
        allocations          TYPE ty_priority_fefo_allocations,
        batch_allocations    TYPE ty_priority_fefo_batch_splits,
        transfer_assignments TYPE ty_priority_transfer_assignments,
        request_locations    TYPE ty_request_locations,
      END OF ty_priority_transfer_fefo_result.
    TYPES:
      BEGIN OF ty_priority_transfer_fefo_atp_result,
        local_estimate TYPE ty_priority_transfer_fefo_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_priority_transfer_fefo_atp_result.
    TYPES:
      BEGIN OF ty_dated_location_transfer_result,
        allocations          TYPE ty_dated_location_allocations,
        storage_allocations  TYPE ty_dated_location_splits,
        transfer_assignments TYPE ty_dated_transfer_assignments,
        request_locations    TYPE ty_request_locations,
      END OF ty_dated_location_transfer_result.
    TYPES:
      BEGIN OF ty_dated_location_transfer_atp_result,
        local_estimate TYPE ty_dated_location_transfer_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_dated_location_transfer_atp_result.
    TYPES:
      BEGIN OF ty_priority_location_transfer_result,
        allocations          TYPE ty_priority_location_allocations,
        storage_allocations  TYPE ty_priority_location_splits,
        transfer_assignments TYPE ty_priority_transfer_assignments,
        request_locations    TYPE ty_request_locations,
      END OF ty_priority_location_transfer_result.
    TYPES:
      BEGIN OF ty_priority_transfer_loc_atp_result,
        local_estimate TYPE ty_priority_location_transfer_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_priority_transfer_loc_atp_result.
    TYPES:
      BEGIN OF ty_transfer_location_result,
        allocation           TYPE zcl_stock_service=>ty_unit_location_result,
        transfer_assignments TYPE ty_transfer_assignments,
        request_locations    TYPE ty_request_locations,
      END OF ty_transfer_location_result.
    TYPES:
      BEGIN OF ty_transfer_loc_atp_result,
        local_estimate TYPE ty_transfer_location_result,
        atp_checks     TYPE zcl_stock_service=>ty_local_atp_checks,
      END OF ty_transfer_loc_atp_result.
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
      BEGIN OF ty_open_reservation_in_unit,
        source_reservation      TYPE ty_open_reservation,
        requested_unit          TYPE mara-meins,
        base_unit               TYPE mara-meins,
        required_quantity       TYPE mspr-prlab,
        withdrawn_quantity      TYPE mspr-prlab,
        open_quantity           TYPE mspr-prlab,
        base_required_quantity  TYPE resb-bdmng,
        base_withdrawn_quantity TYPE resb-enmng,
        base_open_quantity      TYPE resb-bdmng,
      END OF ty_open_reservation_in_unit.
    TYPES ty_open_reservations_in_unit TYPE STANDARD TABLE OF
      ty_open_reservation_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_open_reservation_unit_request,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        wbs_element           TYPE ty_wbs_element,
        requested_unit        TYPE mara-meins,
        required_through_date TYPE d,
      END OF ty_open_reservation_unit_request.
    TYPES ty_open_reservation_unit_requests TYPE STANDARD TABLE OF
      ty_open_reservation_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_open_reservation_bulk_unit_item,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        wbs_element           TYPE ty_wbs_element,
        requested_unit        TYPE mara-meins,
        base_unit             TYPE mara-meins,
        required_through_date TYPE d,
        reservations          TYPE ty_open_reservations_in_unit,
      END OF ty_open_reservation_bulk_unit_item.
    TYPES ty_open_reservation_bulk_unit_items TYPE STANDARD TABLE OF
      ty_open_reservation_bulk_unit_item WITH EMPTY KEY.
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
      BEGIN OF ty_reservation_item_in_unit,
        source_reservation      TYPE
          zif_project_stock_repository=>ty_reservation,
        requested_unit          TYPE mara-meins,
        base_unit               TYPE mara-meins,
        required_quantity       TYPE mspr-prlab,
        withdrawn_quantity      TYPE mspr-prlab,
        open_quantity           TYPE mspr-prlab,
        base_required_quantity  TYPE resb-bdmng,
        base_withdrawn_quantity TYPE resb-enmng,
        base_open_quantity      TYPE resb-bdmng,
      END OF ty_reservation_item_in_unit.
    TYPES ty_reservation_items_in_unit TYPE STANDARD TABLE OF
      ty_reservation_item_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_item_unit_request,
        request_id     TYPE c LENGTH 30,
        material       TYPE mard-matnr,
        wbs_element    TYPE ty_wbs_element,
        requested_unit TYPE mara-meins,
      END OF ty_reservation_item_unit_request.
    TYPES ty_reservation_item_unit_requests TYPE STANDARD TABLE OF
      ty_reservation_item_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_items_bulk_unit_item,
        request_id     TYPE c LENGTH 30,
        material       TYPE mard-matnr,
        wbs_element    TYPE ty_wbs_element,
        requested_unit TYPE mara-meins,
        base_unit      TYPE mara-meins,
        reservations   TYPE ty_reservation_items_in_unit,
      END OF ty_reservation_items_bulk_unit_item.
    TYPES ty_reservation_items_bulk_unit_items TYPE STANDARD TABLE OF
      ty_reservation_items_bulk_unit_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_coverage_reservation,
        reservation_number        TYPE resb-rsnum,
        reservation_item          TYPE resb-rspos,
        reserved_quantity         TYPE mspr-prlab,
        covered_quantity          TYPE mspr-prlab,
        uncovered_quantity        TYPE mspr-prlab,
        unit                      TYPE mara-meins,
        base_reserved_quantity    TYPE mspr-prlab,
        base_covered_quantity     TYPE mspr-prlab,
        base_uncovered_quantity   TYPE mspr-prlab,
        base_unit                 TYPE mara-meins,
        source_open_quantity      TYPE resb-bdmng,
        source_required_quantity  TYPE resb-bdmng,
        source_withdrawn_quantity TYPE resb-enmng,
        source_unit               TYPE resb-meins,
        source_entry_unit         TYPE resb-erfme,
        required_date             TYPE resb-bdter,
        storage_location          TYPE mard-lgort,
        batch                     TYPE mchb-charg,
      END OF ty_coverage_reservation.
    TYPES ty_coverage_reservations TYPE STANDARD TABLE OF
      ty_coverage_reservation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_cov_stock_deduction,
        material               TYPE mard-matnr,
        plant                  TYPE mard-werks,
        wbs_element            TYPE ty_wbs_element,
        storage_location       TYPE mard-lgort,
        batch                  TYPE mchb-charg,
        reservation_number     TYPE resb-rsnum,
        reservation_item       TYPE resb-rspos,
        reserved_quantity      TYPE mspr-prlab,
        unit                   TYPE mara-meins,
        base_reserved_quantity TYPE mspr-prlab,
        base_unit              TYPE mara-meins,
      END OF ty_cov_stock_deduction.
    TYPES ty_cov_stock_deductions TYPE STANDARD TABLE OF
      ty_cov_stock_deduction WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_coverage_stock,
        storage_location            TYPE mard-lgort,
        batch                       TYPE mchb-charg,
        unit                        TYPE mara-meins,
        base_unit                   TYPE mara-meins,
        project_stock_quantity      TYPE mspr-prlab,
        reserved_quantity           TYPE mspr-prlab,
        available_quantity          TYPE mspr-prlab,
        base_project_stock_quantity TYPE mspr-prlab,
        base_reserved_quantity      TYPE mspr-prlab,
        base_available_quantity     TYPE mspr-prlab,
      END OF ty_reservation_coverage_stock.
    TYPES ty_reservation_coverage_stocks TYPE STANDARD TABLE OF
      ty_reservation_coverage_stock WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_coverage,
        material                     TYPE mard-matnr,
        plant                        TYPE mard-werks,
        wbs_element                  TYPE ty_wbs_element,
        base_unit                    TYPE mara-meins,
        project_stock_quantity       TYPE mspr-prlab,
        reserved_quantity            TYPE mspr-prlab,
        available_quantity           TYPE mspr-prlab,
        shortfall_quantity           TYPE mspr-prlab,
        open_reservation_items       TYPE i,
        open_reservation_keys        TYPE
          zif_stock_repository=>ty_reservation_keys,
        open_reservations            TYPE ty_coverage_reservations,
        stock_details                TYPE ty_reservation_coverage_stocks,
        stock_reservation_deductions TYPE
          ty_cov_stock_deductions,
        excluded_open_reservations   TYPE ty_open_reservations,
        excluded_open_resv_items     TYPE i,
        excluded_reservations        TYPE
          zif_stock_repository=>ty_reservation_keys,
        is_fully_covered             TYPE abap_bool,
      END OF ty_reservation_coverage.
    TYPES ty_reservation_coverages TYPE STANDARD TABLE OF
      ty_reservation_coverage WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_coverage_in_unit,
        material                     TYPE mard-matnr,
        plant                        TYPE mard-werks,
        wbs_element                  TYPE ty_wbs_element,
        unit                         TYPE mara-meins,
        base_unit                    TYPE mara-meins,
        project_stock_quantity       TYPE mspr-prlab,
        reserved_quantity            TYPE mspr-prlab,
        available_quantity           TYPE mspr-prlab,
        shortfall_quantity           TYPE mspr-prlab,
        base_project_stock_quantity  TYPE mspr-prlab,
        base_reserved_quantity       TYPE mspr-prlab,
        base_available_quantity      TYPE mspr-prlab,
        base_shortfall_quantity      TYPE mspr-prlab,
        open_reservation_items       TYPE i,
        open_reservation_keys        TYPE
          zif_stock_repository=>ty_reservation_keys,
        open_reservations            TYPE ty_coverage_reservations,
        stock_details                TYPE ty_reservation_coverage_stocks,
        stock_reservation_deductions TYPE
          ty_cov_stock_deductions,
        excluded_open_reservations   TYPE ty_open_reservations,
        excluded_open_resv_items     TYPE i,
        excluded_reservations        TYPE
          zif_stock_repository=>ty_reservation_keys,
        is_fully_covered             TYPE abap_bool,
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
      BEGIN OF ty_coverage_key_request,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        wbs_element           TYPE ty_wbs_element,
        required_through_date TYPE d,
      END OF ty_coverage_key_request.
    TYPES ty_coverage_key_requests TYPE STANDARD TABLE OF
      ty_coverage_key_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_coverage_key_bulk_item,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        wbs_element           TYPE ty_wbs_element,
        required_through_date TYPE d,
        coverage              TYPE ty_reservation_coverage,
      END OF ty_coverage_key_bulk_item.
    TYPES ty_coverage_key_bulk_items TYPE STANDARD TABLE OF
      ty_coverage_key_bulk_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_request_reservation_exclusion,
        request_id         TYPE c LENGTH 30,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_request_reservation_exclusion.
    TYPES ty_request_reservation_exclusions TYPE STANDARD TABLE OF
      ty_request_reservation_exclusion WITH EMPTY KEY.
    TYPES ty_coverage_request_exclusion TYPE
      ty_request_reservation_exclusion.
    TYPES ty_coverage_request_exclusions TYPE
      ty_request_reservation_exclusions.
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
        io_repository                TYPE REF TO zif_project_stock_repository OPTIONAL
        io_uom_converter             TYPE REF TO zif_material_uom_converter OPTIONAL
        io_uom_repository            TYPE REF TO zif_material_uom_repository OPTIONAL
        io_material_availability_api TYPE REF TO
          zif_material_availability_api OPTIONAL.

    METHODS read_available_stock
      IMPORTING
        it_keys                     TYPE zif_project_stock_repository=>ty_keys
        it_excluded_reservations    TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_stocks)            TYPE ty_available_stocks
      RAISING
        zcx_invalid_stock_request.

    METHODS read_available_stock_bulk
      IMPORTING
        it_requests                  TYPE ty_available_stock_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_request_reservation_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_available_stock_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_available_stock_in_unit
      IMPORTING
        iv_material                 TYPE mard-matnr
        it_excluded_reservations    TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
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
        it_requests                  TYPE ty_available_stock_unit_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_request_reservation_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_available_stock_bulk_unit_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_open_reservations
      IMPORTING
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_reservations)   TYPE ty_open_reservations
      RAISING
        zcx_invalid_stock_request.

    METHODS read_open_reservations_bulk
      IMPORTING
        it_requests                  TYPE ty_open_reservation_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_request_reservation_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_open_reservation_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_open_reservations_uom
      IMPORTING
        iv_material              TYPE mard-matnr
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_unit                  TYPE mara-meins
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_reservations)   TYPE ty_open_reservations_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS read_open_resv_bulk_uom
      IMPORTING
        it_requests                  TYPE ty_open_reservation_unit_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_request_reservation_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_open_reservation_bulk_unit_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_items
      IMPORTING
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
      RETURNING
        VALUE(rt_reservations)   TYPE ty_reservation_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_items_bulk
      IMPORTING
        it_requests                  TYPE ty_reservation_items_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_request_reservation_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_reservation_items_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_items_uom
      IMPORTING
        iv_material              TYPE mard-matnr
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_unit                  TYPE mara-meins
      RETURNING
        VALUE(rt_reservations)   TYPE ty_reservation_items_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS read_resv_items_bulk_uom
      IMPORTING
        it_requests                  TYPE ty_reservation_item_unit_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_request_reservation_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_reservation_items_bulk_unit_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage
      IMPORTING
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_coverage)       TYPE ty_reservation_coverages
      RAISING
        zcx_invalid_stock_request.

    METHODS read_resv_coverage_for_key
      IMPORTING
        iv_material              TYPE mard-matnr
        iv_plant                 TYPE mard-werks
        iv_wbs_element           TYPE ty_wbs_element
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rs_coverage)       TYPE ty_reservation_coverage
      RAISING
        zcx_invalid_stock_request.

    METHODS read_resv_coverage_keys_bulk
      IMPORTING
        it_requests                  TYPE ty_coverage_key_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_coverage_request_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_coverage_key_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage_uom
      IMPORTING
        iv_material              TYPE mard-matnr
        iv_plant                 TYPE mard-werks
        iv_wbs_element           TYPE ty_wbs_element
        iv_unit                  TYPE mara-meins
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rs_coverage)       TYPE ty_reservation_coverage_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS read_resv_coverage_bulk_uom
      IMPORTING
        it_requests                  TYPE ty_coverage_unit_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_coverage_request_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_coverage_unit_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage_bulk
      IMPORTING
        it_requests                  TYPE ty_coverage_requests
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_coverage_request_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_coverage_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo
      IMPORTING
        it_demands                     TYPE ty_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo_atp
      IMPORTING
        it_demands                     TYPE ty_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_fefo_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo_priority
      IMPORTING
        it_demands                     TYPE ty_priority_fefo_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo_priority_atp
      IMPORTING
        it_demands                     TYPE ty_priority_fefo_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_fefo_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo_by_date
      IMPORTING
        it_demands                     TYPE ty_dated_fefo_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_fefo_by_date_atp
      IMPORTING
        it_demands                     TYPE ty_dated_fefo_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_fefo_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location
      IMPORTING
        it_demands                     TYPE ty_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location_atp
      IMPORTING
        it_demands                     TYPE ty_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_location_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location_priority
      IMPORTING
        it_demands                     TYPE ty_priority_location_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_location_priority_atp
      IMPORTING
        it_demands                     TYPE ty_priority_location_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_loc_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location_date
      IMPORTING
        it_demands                     TYPE ty_dated_location_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_by_location_date_atp
      IMPORTING
        it_demands                     TYPE ty_dated_location_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations
          OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_location_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo
      IMPORTING
        it_demands                     TYPE ty_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_transfer_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo_atp
      IMPORTING
        it_demands                     TYPE ty_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_transfer_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo_priority
      IMPORTING
        it_demands                     TYPE ty_priority_transfer_fefo_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_transfer_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo_prio_atp
      IMPORTING
        it_demands                     TYPE ty_priority_transfer_fefo_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_transfer_fefo_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo_by_date
      IMPORTING
        it_demands                     TYPE ty_dated_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_transfer_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_fefo_date_atp
      IMPORTING
        it_demands                     TYPE ty_dated_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_batch_receipts    TYPE ty_projected_batch_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_transfer_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_by_location
      IMPORTING
        it_demands                     TYPE ty_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_transfer_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_loc_atp
      IMPORTING
        it_demands                     TYPE ty_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_transfer_loc_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_loc_priority
      IMPORTING
        it_demands                     TYPE ty_priority_location_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_location_transfer_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_loc_prio_atp
      IMPORTING
        it_demands                     TYPE ty_priority_location_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_atp_check_date              TYPE d OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_priority_transfer_loc_atp_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_location_date
      IMPORTING
        it_demands                     TYPE ty_dated_location_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_location_transfer_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_transfer_loc_date_atp
      IMPORTING
        it_demands                     TYPE ty_dated_location_transfer_demands
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE ty_request_locations OPTIONAL
        it_projected_location_receipts TYPE ty_projected_location_receipts
          OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date    TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_location_transfer_atp_result
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
        allow_location_fallback TYPE abap_bool,
        batch                   TYPE mchb-charg,
        requested_quantity      TYPE mard-labst,
        require_full_quantity   TYPE abap_bool,
        unit                    TYPE mara-meins,
        base_quantity           TYPE mard-labst,
        base_unit               TYPE mara-meins,
        fefo_as_of_date         TYPE d,
        location_as_of_date     TYPE d,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        minimum_coverage_pct    TYPE p LENGTH 5 DECIMALS 2,
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
        request_id          TYPE c LENGTH 30,
        caller_request_id   TYPE c LENGTH 30,
        input_index         TYPE i,
        required_date       TYPE d,
        priority            TYPE i,
        allocation_sequence TYPE i,
      END OF ty_dated_fefo_index,
      ty_dated_fefo_indexes TYPE HASHED TABLE OF ty_dated_fefo_index
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_project_atp_demand,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        base_unit          TYPE mara-meins,
        required_date      TYPE d,
        allocated_quantity TYPE mard-labst,
      END OF ty_project_atp_demand,
      ty_project_atp_demands TYPE STANDARD TABLE OF
        ty_project_atp_demand WITH EMPTY KEY,
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
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        wbs_element         TYPE ty_wbs_element,
        storage_location    TYPE mard-lgort,
        batch               TYPE mchb-charg,
        expiration_date     TYPE mcha-vfdat,
        available_from_date TYPE d,
        remaining_quantity  TYPE mspr-prlab,
      END OF ty_stock_balance,
      ty_stock_balances TYPE HASHED TABLE OF ty_stock_balance
        WITH UNIQUE KEY material plant wbs_element storage_location batch
          available_from_date,
      BEGIN OF ty_candidate,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        wbs_element          TYPE ty_wbs_element,
        storage_location     TYPE mard-lgort,
        batch                TYPE mchb-charg,
        expiration_date      TYPE mcha-vfdat,
        sort_expiration_date TYPE d,
        available_from_date  TYPE d,
        preferred_location   TYPE abap_bool,
        request_ranked       TYPE abap_bool,
        location_priority    TYPE i,
      END OF ty_candidate,
      ty_candidates TYPE STANDARD TABLE OF ty_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_balance,
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        wbs_element         TYPE ty_wbs_element,
        storage_location    TYPE mard-lgort,
        available_from_date TYPE d,
        remaining_quantity  TYPE mspr-prlab,
      END OF ty_location_balance,
      ty_location_balances TYPE HASHED TABLE OF ty_location_balance
        WITH UNIQUE KEY material plant wbs_element storage_location
          available_from_date,
      BEGIN OF ty_location_candidate,
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        wbs_element         TYPE ty_wbs_element,
        storage_location    TYPE mard-lgort,
        available_from_date TYPE d,
        preferred_location  TYPE abap_bool,
        request_ranked      TYPE abap_bool,
        location_priority   TYPE i,
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
        reservation_number   TYPE resb-rsnum,
        reservation_item     TYPE resb-rspos,
        specificity          TYPE i,
        outstanding_quantity TYPE resb-bdmng,
      END OF ty_reservation_work,
      ty_reservation_worklist TYPE STANDARD TABLE OF
        ty_reservation_work WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_subtraction,
        stocks                       TYPE
          zif_project_stock_repository=>ty_stocks,
        stock_reservation_deductions TYPE ty_cov_stock_deductions,
      END OF ty_reservation_subtraction.

    DATA mo_repository TYPE REF TO zif_project_stock_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
    DATA mo_uom_repository TYPE REF TO zif_material_uom_repository.
    DATA mo_material_availability_api TYPE REF TO
      zif_material_availability_api.

    METHODS checked_stock_quantity
      IMPORTING
        iv_quantity        TYPE decfloat34
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS get_project_atp_checks
      IMPORTING
        it_demands       TYPE ty_project_atp_demands
        iv_check_rule    TYPE zif_material_availability_api=>ty_check_rule
      RETURNING
        VALUE(rt_checks) TYPE zcl_stock_service=>ty_local_atp_checks
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_excluded_reservations
      IMPORTING
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys
      RAISING
        zcx_invalid_stock_request.

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

    METHODS read_resv_cov_keys_bulk_core
      IMPORTING
        it_requests                  TYPE ty_coverage_key_requests
        it_base_units                TYPE ty_material_base_units OPTIONAL
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_coverage_request_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_coverage_key_bulk_items
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_coverage_core
      IMPORTING
        it_wbs_elements          TYPE zif_project_stock_repository=>ty_wbs_elements
        it_keys                  TYPE zif_project_stock_repository=>ty_keys OPTIONAL
        it_base_units            TYPE ty_material_base_units OPTIONAL
        it_excluded_reservations TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_required_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rt_coverage)       TYPE ty_reservation_coverages
      RAISING
        zcx_invalid_stock_request.

    METHODS read_reservation_cov_bulk_core
      IMPORTING
        it_requests                  TYPE ty_coverage_requests
        it_key_requests              TYPE ty_coverage_key_requests OPTIONAL
        it_base_units                TYPE ty_material_base_units OPTIONAL
        it_excluded_reservations     TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_request_excl_reservations TYPE
          ty_coverage_request_exclusions OPTIONAL
      RETURNING
        VALUE(rt_results)            TYPE ty_coverage_bulk_items
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

    METHODS convert_open_resv_to_unit
      IMPORTING
        is_reservation        TYPE ty_open_reservation
        iv_unit               TYPE mara-meins
        is_unit_ratio         TYPE zif_material_uom_converter=>ty_unit_ratio
      RETURNING
        VALUE(rs_reservation) TYPE ty_open_reservation_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_resv_item_to_unit
      IMPORTING
        is_reservation        TYPE
          zif_project_stock_repository=>ty_reservation
        iv_unit               TYPE mara-meins
        is_unit_ratio         TYPE zif_material_uom_converter=>ty_unit_ratio
      RETURNING
        VALUE(rs_reservation) TYPE ty_reservation_item_in_unit
      RAISING
        zcx_invalid_stock_request.

    METHODS subtract_project_reservations
      IMPORTING
        it_stocks                   TYPE zif_project_stock_repository=>ty_stocks
        it_reservations             TYPE zif_project_stock_repository=>ty_reservations
        it_excluded_reservations    TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_batch_only               TYPE abap_bool
        iv_all_stock_types          TYPE abap_bool DEFAULT abap_false
        iv_reservation_through_date TYPE d OPTIONAL
        iv_collect_deductions       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_subtraction)       TYPE ty_reservation_subtraction
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

    mo_material_availability_api = io_material_availability_api.
    IF mo_material_availability_api IS NOT BOUND.
      mo_material_availability_api = NEW zcl_bapi_mat_avail_api( ).
    ENDIF.
  ENDMETHOD.

  METHOD read_available_stock.
    DATA lt_seen_keys TYPE ty_stock_key_set.
    DATA lt_material_units TYPE ty_material_base_units.
    DATA lt_requested_stocks TYPE zif_project_stock_repository=>ty_stocks.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
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
      it_keys                  = it_keys
      iv_required_through_date = iv_reservation_through_date ).
    LOOP AT lt_raw_stocks INTO DATA(ls_raw_stock).
      IF line_exists( lt_seen_keys[
        material = ls_raw_stock-material
        plant = ls_raw_stock-plant
        wbs_element = ls_raw_stock-wbs_element ] ).
        APPEND ls_raw_stock TO lt_requested_stocks.
      ENDIF.
    ENDLOOP.
    DATA(ls_subtraction) = subtract_project_reservations(
      it_excluded_reservations    = it_excluded_reservations
      it_stocks                   = lt_requested_stocks
      it_reservations             = lt_reservations
      iv_batch_only               = abap_false
      iv_all_stock_types          = abap_true
      iv_reservation_through_date = iv_reservation_through_date ).
    DATA(lt_available_stocks) = ls_subtraction-stocks.
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
    TYPES ty_request_group_id TYPE i.
    TYPES ty_request_group_ids TYPE SORTED TABLE OF ty_request_group_id
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_request_group,
        request_id TYPE c LENGTH 30,
        group_id   TYPE i,
      END OF ty_request_group,
      ty_request_group_map TYPE HASHED TABLE OF ty_request_group
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_group_reservation_key,
        group_id           TYPE i,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_group_reservation_key,
      ty_group_reservation_keys TYPE STANDARD TABLE OF
        ty_group_reservation_key WITH EMPTY KEY,
      BEGIN OF ty_dated_stock,
        reservation_through_date TYPE d,
        group_id                 TYPE i,
        stock                    TYPE ty_available_stock,
      END OF ty_dated_stock,
      ty_dated_stocks TYPE STANDARD TABLE OF ty_dated_stock WITH EMPTY KEY.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_request_reservation_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_dates TYPE ty_reservation_dates.
    DATA lt_group_ids TYPE ty_request_group_ids.
    DATA lt_group_reservations TYPE ty_group_reservation_keys.
    DATA lt_request_groups TYPE ty_request_group_map.
    DATA lt_request_keys TYPE zif_stock_repository=>ty_reservation_keys.
    DATA lt_effective_exclusions TYPE zif_stock_repository=>ty_reservation_keys.
    DATA lt_dated_stocks TYPE ty_dated_stocks.
    DATA lt_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_seen_keys TYPE ty_stock_key_set.
    DATA lv_next_group_id TYPE i.
    DATA lv_group_key_count TYPE i.
    DATA lv_candidate_group_id TYPE i.
    DATA lv_request_group_id TYPE i.
    DATA lv_same_group TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_available_stock_bulk_item.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).

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

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      CLEAR lt_request_keys.
      LOOP AT it_request_excl_reservations
          INTO ls_request_exclusion
          WHERE request_id = ls_request-request_id.
        APPEND VALUE #(
          reservation_number = ls_request_exclusion-reservation_number
          reservation_item   = ls_request_exclusion-reservation_item )
          TO lt_request_keys.
      ENDLOOP.
      SORT lt_request_keys BY reservation_number reservation_item.

      CLEAR lv_request_group_id.
      LOOP AT lt_group_ids INTO lv_candidate_group_id.
        CLEAR lv_group_key_count.
        LOOP AT lt_group_reservations TRANSPORTING NO FIELDS
            WHERE group_id = lv_candidate_group_id.
          lv_group_key_count += 1.
        ENDLOOP.
        IF lv_group_key_count <> lines( lt_request_keys ).
          CONTINUE.
        ENDIF.

        lv_same_group = abap_true.
        LOOP AT lt_request_keys INTO DATA(ls_request_key).
          IF NOT line_exists( lt_group_reservations[
            group_id = lv_candidate_group_id
            reservation_number = ls_request_key-reservation_number
            reservation_item = ls_request_key-reservation_item ] ).
            lv_same_group = abap_false.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_same_group = abap_true.
          lv_request_group_id = lv_candidate_group_id.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_request_group_id IS INITIAL.
        lv_next_group_id += 1.
        lv_request_group_id = lv_next_group_id.
        INSERT lv_request_group_id INTO TABLE lt_group_ids.
        LOOP AT lt_request_keys INTO DATA(ls_new_group_key).
          APPEND VALUE #(
            group_id           = lv_request_group_id
            reservation_number = ls_new_group_key-reservation_number
            reservation_item   = ls_new_group_key-reservation_item )
            TO lt_group_reservations.
        ENDLOOP.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_request-request_id
        group_id   = lv_request_group_id ) INTO TABLE lt_request_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_dates INTO DATA(lv_reservation_through_date).
      LOOP AT lt_group_ids INTO DATA(lv_group_id).
        CLEAR: lt_keys, lt_seen_keys.
        LOOP AT it_requests INTO ls_request
          WHERE reservation_through_date = lv_reservation_through_date.
          READ TABLE lt_request_groups INTO DATA(ls_request_group)
            WITH TABLE KEY request_id = ls_request-request_id.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          IF ls_request_group-group_id <> lv_group_id.
            CONTINUE.
          ENDIF.
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
        IF lt_keys IS INITIAL.
          CONTINUE.
        ENDIF.

        lt_effective_exclusions = it_excluded_reservations.
        LOOP AT lt_group_reservations INTO DATA(ls_group_reservation)
            WHERE group_id = lv_group_id.
          IF NOT line_exists( lt_effective_exclusions[
            reservation_number = ls_group_reservation-reservation_number
            reservation_item = ls_group_reservation-reservation_item ] ).
            APPEND VALUE #(
              reservation_number = ls_group_reservation-reservation_number
              reservation_item   = ls_group_reservation-reservation_item )
              TO lt_effective_exclusions.
          ENDIF.
        ENDLOOP.

        DATA(lt_stocks) = read_available_stock(
          it_keys                     = lt_keys
          it_excluded_reservations    = lt_effective_exclusions
          iv_reservation_through_date = lv_reservation_through_date ).
        LOOP AT lt_stocks INTO DATA(ls_stock).
          APPEND VALUE #(
            reservation_through_date = lv_reservation_through_date
            group_id                 = lv_group_id
            stock                    = ls_stock ) TO lt_dated_stocks.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results ASSIGNING <ls_result>.
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-material = ls_request-material.
      <ls_result>-plant = ls_request-plant.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_through_date =
        ls_request-reservation_through_date.
      READ TABLE lt_request_groups INTO DATA(ls_result_group)
        WITH TABLE KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      LOOP AT lt_dated_stocks INTO DATA(ls_dated_stock).
        IF ls_dated_stock-reservation_through_date
              <> ls_request-reservation_through_date
            OR ls_dated_stock-group_id <> ls_result_group-group_id
            OR ls_dated_stock-stock-material <> ls_request-material
            OR ls_dated_stock-stock-plant <> ls_request-plant
            OR ls_dated_stock-stock-wbs_element <> ls_request-wbs_element.
          CONTINUE.
        ENDIF.
        APPEND ls_dated_stock-stock TO <ls_result>-stocks.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_available_stock_in_unit.
    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    DATA(lt_results) = read_available_stock_bulk_uom(
      it_excluded_reservations = it_excluded_reservations
      it_requests              = VALUE #(
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
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_request_reservation_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_unit_ratios TYPE ty_stock_unit_ratios.
    DATA lt_base_requests TYPE ty_available_stock_requests.
    DATA lt_base_results TYPE ty_available_stock_bulk_items.
    DATA lv_available_as_unit TYPE decfloat34.
    DATA lv_converted_quantity TYPE mspr-prlab.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
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

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

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
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations =
        it_request_excl_reservations
      it_requests                  = lt_base_requests ).
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
        lv_available_as_unit = CONV decfloat34(
          ls_base_stock-available_quantity )
          * CONV decfloat34( ls_unit_ratio-result-denominator )
          / CONV decfloat34( ls_unit_ratio-result-numerator ).
        TRY.
            lv_converted_quantity = CONV mspr-prlab(
              lv_available_as_unit ).
          CATCH cx_sy_conversion_overflow.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDTRY.
        IF ls_base_stock-available_quantity <> 0
            AND lv_converted_quantity IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          material           = ls_base_stock-material
          plant              = ls_base_stock-plant
          wbs_element        = ls_base_stock-wbs_element
          storage_location   = ls_base_stock-storage_location
          batch              = ls_base_stock-batch
          expiration_date    = ls_base_stock-expiration_date
          available_quantity = lv_converted_quantity
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

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
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
      it_wbs_elements          = it_wbs_elements
      iv_required_through_date = iv_required_through_date ).
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
      IF line_exists( it_excluded_reservations[
        reservation_number = ls_row-reservation_number
        reservation_item = ls_row-reservation_item ] ).
        CONTINUE.
      ENDIF.
      DATA(lv_open_quantity) =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_row-required_quantity
          iv_withdrawn_quantity = ls_row-withdrawn_quantity ).
      IF lv_open_quantity <= 0.
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
        open_quantity      = lv_open_quantity ) TO rt_reservations.
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
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_request_reservation_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_dates TYPE ty_reservation_dates.
    DATA lt_dated_reservations TYPE ty_dated_reservations.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).

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

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

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
        it_excluded_reservations = it_excluded_reservations
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
        IF line_exists( it_request_excl_reservations[
          request_id = ls_request-request_id
          reservation_number =
            ls_dated_reservation-reservation-reservation_number
          reservation_item =
            ls_dated_reservation-reservation-reservation_item ] ).
          CONTINUE.
        ENDIF.
        APPEND ls_dated_reservation-reservation
          TO <ls_result>-reservations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_open_reservations_uom.
    TYPES ty_seen_wbs_element TYPE ty_wbs_element.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF ty_seen_wbs_element
      WITH UNIQUE KEY table_line.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    IF iv_material IS INITIAL OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
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

    DATA(ls_unit_ratio) = mo_uom_converter->get_material_unit_ratio(
      iv_material         = iv_material
      iv_alternative_unit = iv_unit ).
    IF ls_unit_ratio-is_successful <> abap_true
        OR ls_unit_ratio-base_unit IS INITIAL
        OR ls_unit_ratio-numerator <= 0
        OR ls_unit_ratio-denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lt_source_reservations) = read_open_reservations(
      it_wbs_elements          = it_wbs_elements
      it_excluded_reservations = it_excluded_reservations
      iv_required_through_date = iv_required_through_date ).
    LOOP AT lt_source_reservations INTO DATA(ls_source_reservation)
      WHERE material = iv_material.
      APPEND convert_open_resv_to_unit(
        is_reservation = ls_source_reservation
        iv_unit        = iv_unit
        is_unit_ratio  = ls_unit_ratio ) TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_open_resv_bulk_uom.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_request_reservation_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_unit_ratios TYPE ty_stock_unit_ratios.
    DATA lt_base_requests TYPE ty_open_reservation_requests.
    DATA lt_base_results TYPE ty_open_reservation_bulk_items.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
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

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

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

    lt_base_results = read_open_reservations_bulk(
      it_requests                  = lt_base_requests
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations =
        it_request_excl_reservations ).
    IF lines( lt_base_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_base_results INTO DATA(ls_base_result).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE it_requests INTO ls_request INDEX lv_request_index.
      IF sy-subrc <> 0
          OR ls_base_result-request_id <> ls_request-request_id.
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
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-material = ls_request-material.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-requested_unit = ls_request-requested_unit.
      <ls_result>-base_unit = ls_unit_ratio-result-base_unit.
      <ls_result>-required_through_date =
        ls_request-required_through_date.
      LOOP AT ls_base_result-reservations
          INTO DATA(ls_base_reservation)
          WHERE material = ls_request-material.
        APPEND convert_open_resv_to_unit(
          is_reservation = ls_base_reservation
          iv_unit        = ls_request-requested_unit
          is_unit_ratio  = ls_unit_ratio-result )
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

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
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
      IF line_exists( it_excluded_reservations[
        reservation_number = ls_row-reservation_number
        reservation_item = ls_row-reservation_item ] ).
        CONTINUE.
      ENDIF.
      DATA(ls_reservation) = ls_row.
      ls_reservation-open_quantity =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_reservation-required_quantity
          iv_withdrawn_quantity = ls_reservation-withdrawn_quantity ).
      APPEND ls_reservation TO rt_reservations.
    ENDLOOP.

    SORT rt_reservations BY wbs_element reservation_number
      reservation_item.
  ENDMETHOD.

  METHOD read_reservation_items_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_request_reservation_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).

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

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_reservations) = read_reservation_items(
      it_wbs_elements          = lt_wbs_elements
      it_excluded_reservations = it_excluded_reservations ).
    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results
        ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-wbs_element = ls_request-wbs_element.
      LOOP AT lt_reservations INTO DATA(ls_reservation)
        WHERE wbs_element = ls_request-wbs_element.
        IF line_exists( it_request_excl_reservations[
          request_id = ls_request-request_id
          reservation_number = ls_reservation-reservation_number
          reservation_item = ls_reservation-reservation_item ] ).
          CONTINUE.
        ENDIF.
        APPEND ls_reservation TO <ls_result>-reservations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
  METHOD read_reservation_items_uom.
    TYPES ty_seen_wbs_element TYPE ty_wbs_element.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF ty_seen_wbs_element
      WITH UNIQUE KEY table_line.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    IF iv_material IS INITIAL OR iv_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
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

    DATA(ls_unit_ratio) = mo_uom_converter->get_material_unit_ratio(
      iv_material         = iv_material
      iv_alternative_unit = iv_unit ).
    IF ls_unit_ratio-is_successful <> abap_true
        OR ls_unit_ratio-base_unit IS INITIAL
        OR ls_unit_ratio-numerator <= 0
        OR ls_unit_ratio-denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lt_source_reservations) = read_reservation_items(
      it_wbs_elements          = it_wbs_elements
      it_excluded_reservations = it_excluded_reservations ).
    LOOP AT lt_source_reservations INTO DATA(ls_source_reservation)
      WHERE material = iv_material.
      APPEND convert_resv_item_to_unit(
        is_reservation = ls_source_reservation
        iv_unit        = iv_unit
        is_unit_ratio  = ls_unit_ratio ) TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_resv_items_bulk_uom.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_request_reservation_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_unit_ratios TYPE ty_stock_unit_ratios.
    DATA lt_base_requests TYPE ty_reservation_items_requests.
    DATA lt_base_results TYPE ty_reservation_items_bulk_items.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-wbs_element IS INITIAL
          OR ls_request-requested_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

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
        request_id  = ls_request-request_id
        wbs_element = ls_request-wbs_element )
        TO lt_base_requests.
    ENDLOOP.

    lt_base_results = read_reservation_items_bulk(
      it_requests                  = lt_base_requests
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations =
        it_request_excl_reservations ).
    IF lines( lt_base_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_base_results INTO DATA(ls_base_result).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE it_requests INTO ls_request INDEX lv_request_index.
      IF sy-subrc <> 0
          OR ls_base_result-request_id <> ls_request-request_id.
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
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-material = ls_request-material.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-requested_unit = ls_request-requested_unit.
      <ls_result>-base_unit = ls_unit_ratio-result-base_unit.
      LOOP AT ls_base_result-reservations
          INTO DATA(ls_base_reservation)
          WHERE material = ls_request-material.
        APPEND convert_resv_item_to_unit(
          is_reservation = ls_base_reservation
          iv_unit        = ls_request-requested_unit
          is_unit_ratio  = ls_unit_ratio-result )
          TO <ls_result>-reservations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_reservation_coverage.
    rt_coverage = read_reservation_coverage_core(
      it_wbs_elements          = it_wbs_elements
      it_excluded_reservations = it_excluded_reservations
      iv_required_through_date = iv_required_through_date ).
  ENDMETHOD.

  METHOD read_reservation_coverage_core.
    TYPES:
      BEGIN OF ty_coverage_balance,
        material                   TYPE mard-matnr,
        plant                      TYPE mard-werks,
        wbs_element                TYPE ty_wbs_element,
        base_unit                  TYPE mara-meins,
        project_stock_quantity     TYPE decfloat34,
        reserved_quantity          TYPE decfloat34,
        available_quantity         TYPE decfloat34,
        open_reservation_items     TYPE i,
        open_reservation_keys      TYPE
          zif_stock_repository=>ty_reservation_keys,
        open_reservations          TYPE ty_coverage_reservations,
        excluded_open_reservations TYPE ty_open_reservations,
        excluded_open_resv_items   TYPE i,
        excluded_reservations      TYPE
          zif_stock_repository=>ty_reservation_keys,
      END OF ty_coverage_balance.
    TYPES ty_coverage_balances TYPE HASHED TABLE OF ty_coverage_balance
      WITH UNIQUE KEY material plant wbs_element.
    TYPES:
      BEGIN OF ty_coverage_stock_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        project_stock_qty  TYPE decfloat34,
        available_quantity TYPE decfloat34,
      END OF ty_coverage_stock_balance.
    TYPES ty_coverage_stock_balances TYPE HASHED TABLE OF
      ty_coverage_stock_balance WITH UNIQUE KEY material plant
        wbs_element storage_location batch.
    TYPES:
      BEGIN OF ty_cov_applied_reservation,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        wbs_element        TYPE ty_wbs_element,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        applied_quantity   TYPE decfloat34,
      END OF ty_cov_applied_reservation.
    TYPES ty_cov_applied_reservations TYPE HASHED TABLE OF
      ty_cov_applied_reservation WITH UNIQUE KEY material plant
        wbs_element reservation_number reservation_item.
    TYPES ty_seen_wbs_element TYPE ty_wbs_element.
    TYPES:
      BEGIN OF ty_seen_reservation,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_seen_reservation,
      ty_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
        WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_balances TYPE ty_coverage_balances.
    DATA lt_stock_balances TYPE ty_coverage_stock_balances.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF ty_seen_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_seen_stock_keys TYPE ty_stock_key_set.
    DATA lt_effective_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_seen_reservations TYPE ty_seen_reservations.
    DATA lt_open_reservations TYPE ty_open_reservations.
    DATA lt_project_stocks TYPE zif_project_stock_repository=>ty_stocks.
    DATA lt_key_reservations TYPE
      zif_project_stock_repository=>ty_reservations.
    DATA lt_eligible_stocks TYPE zif_project_stock_repository=>ty_stocks.
    DATA lt_reservation_deductions TYPE
      zif_project_stock_repository=>ty_reservations.
    DATA lt_stock_deductions TYPE
      ty_cov_stock_deductions.
    DATA lt_applied_reservations TYPE ty_cov_applied_reservations.
    DATA lt_base_units TYPE ty_material_base_units.
    DATA lv_base_unit TYPE mara-meins.

    lt_base_units = it_base_units.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    validate_optional_date( iv_date = iv_required_through_date ).

    IF it_keys IS INITIAL.
      lt_open_reservations = read_open_reservations(
        it_wbs_elements          = it_wbs_elements
        iv_required_through_date = iv_required_through_date ).
      IF it_wbs_elements IS INITIAL.
        RETURN.
      ENDIF.

      LOOP AT it_wbs_elements INTO DATA(lv_wbs_element).
        INSERT lv_wbs_element INTO TABLE lt_seen_wbs_elements.
      ENDLOOP.
      lt_project_stocks = mo_repository->read_project_stocks_wbs(
        it_wbs_elements = it_wbs_elements ).
    ELSE.
      IF it_wbs_elements IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      LOOP AT it_keys INTO DATA(ls_requested_key).
        IF ls_requested_key-material IS INITIAL
            OR ls_requested_key-plant IS INITIAL
            OR ls_requested_key-wbs_element IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          material    = ls_requested_key-material
          plant       = ls_requested_key-plant
          wbs_element = ls_requested_key-wbs_element )
          INTO TABLE lt_seen_stock_keys.
        IF sy-subrc = 0.
          APPEND ls_requested_key TO lt_effective_keys.
        ENDIF.
        INSERT ls_requested_key-wbs_element INTO TABLE lt_seen_wbs_elements.
      ENDLOOP.
      IF lt_effective_keys IS INITIAL.
        RETURN.
      ENDIF.

      lt_key_reservations = mo_repository->read_project_reservations(
        it_keys                  = lt_effective_keys
        iv_required_through_date = iv_required_through_date ).
      LOOP AT lt_key_reservations INTO DATA(ls_key_reservation).
        IF NOT line_exists( lt_seen_stock_keys[
          material = ls_key_reservation-material
          plant = ls_key_reservation-plant
          wbs_element = ls_key_reservation-wbs_element ] ).
          CONTINUE.
        ENDIF.
        IF iv_required_through_date IS NOT INITIAL
            AND ls_key_reservation-required_date IS NOT INITIAL
            AND ls_key_reservation-required_date
              > iv_required_through_date.
          CONTINUE.
        ENDIF.
        IF ls_key_reservation-reservation_number IS INITIAL
            OR ls_key_reservation-reservation_item IS INITIAL
            OR ls_key_reservation-material IS INITIAL
            OR ls_key_reservation-plant IS INITIAL
            OR ls_key_reservation-wbs_element IS INITIAL
            OR ls_key_reservation-unit IS INITIAL
            OR ls_key_reservation-required_quantity
              <= ls_key_reservation-withdrawn_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          reservation_number = ls_key_reservation-reservation_number
          reservation_item   = ls_key_reservation-reservation_item )
          INTO TABLE lt_seen_reservations.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        DATA(lv_key_open_quantity) =
          zcl_stock_avail_qty_calc=>calculate_open_res_qty(
            iv_required_quantity  =
              ls_key_reservation-required_quantity
            iv_withdrawn_quantity =
              ls_key_reservation-withdrawn_quantity ).
        IF lv_key_open_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          reservation_number = ls_key_reservation-reservation_number
          reservation_item   = ls_key_reservation-reservation_item
          material           = ls_key_reservation-material
          plant              = ls_key_reservation-plant
          wbs_element        = ls_key_reservation-wbs_element
          storage_location   = ls_key_reservation-storage_location
          batch              = ls_key_reservation-batch
          required_date      = ls_key_reservation-required_date
          unit               = ls_key_reservation-unit
          entry_unit         = ls_key_reservation-entry_unit
          required_quantity  = ls_key_reservation-required_quantity
          withdrawn_quantity = ls_key_reservation-withdrawn_quantity
          open_quantity      = lv_key_open_quantity )
          TO lt_open_reservations.
      ENDLOOP.
      lt_project_stocks = mo_repository->read_project_stocks(
        it_keys = lt_effective_keys ).
    ENDIF.
    LOOP AT lt_project_stocks INTO DATA(ls_project_stock).
      IF NOT line_exists( lt_seen_wbs_elements[
        table_line = ls_project_stock-wbs_element ] ).
        CONTINUE.
      ENDIF.
      IF it_keys IS NOT INITIAL
          AND NOT line_exists( lt_seen_stock_keys[
            material = ls_project_stock-material
            plant = ls_project_stock-plant
            wbs_element = ls_project_stock-wbs_element ] ).
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
        READ TABLE lt_base_units INTO DATA(ls_material_base_unit)
          WITH TABLE KEY material = ls_project_stock-material.
        IF sy-subrc = 0.
          lv_base_unit = ls_material_base_unit-base_unit.
        ELSE.
          lv_base_unit = mo_uom_repository->get_base_unit(
            iv_material = ls_project_stock-material ).
          IF lv_base_unit IS INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          INSERT VALUE #(
            material  = ls_project_stock-material
            base_unit = lv_base_unit ) INTO TABLE lt_base_units.
        ENDIF.
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
      <ls_balance>-project_stock_quantity += CONV decfloat34(
        ls_project_stock-unrestricted_quantity ).
      APPEND ls_project_stock TO lt_eligible_stocks.

      READ TABLE lt_stock_balances ASSIGNING
        FIELD-SYMBOL(<ls_stock_balance>)
        WITH TABLE KEY material = ls_project_stock-material
                       plant = ls_project_stock-plant
                       wbs_element = ls_project_stock-wbs_element
                       storage_location =
                         ls_project_stock-storage_location
                       batch = ls_project_stock-batch.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material         = ls_project_stock-material
          plant            = ls_project_stock-plant
          wbs_element      = ls_project_stock-wbs_element
          storage_location = ls_project_stock-storage_location
          batch            = ls_project_stock-batch )
          INTO TABLE lt_stock_balances.
        READ TABLE lt_stock_balances ASSIGNING <ls_stock_balance>
          WITH TABLE KEY material = ls_project_stock-material
                         plant = ls_project_stock-plant
                         wbs_element = ls_project_stock-wbs_element
                         storage_location =
                           ls_project_stock-storage_location
                         batch = ls_project_stock-batch.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      <ls_stock_balance>-project_stock_qty += CONV decfloat34(
        ls_project_stock-unrestricted_quantity ).
    ENDLOOP.

    LOOP AT lt_open_reservations INTO DATA(ls_open_reservation).
      IF line_exists( it_excluded_reservations[
        reservation_number = ls_open_reservation-reservation_number
        reservation_item = ls_open_reservation-reservation_item ] ).
        READ TABLE lt_balances ASSIGNING <ls_balance>
          WITH TABLE KEY material = ls_open_reservation-material
                         plant = ls_open_reservation-plant
                         wbs_element = ls_open_reservation-wbs_element.
        IF sy-subrc <> 0.
          READ TABLE lt_base_units INTO ls_material_base_unit
            WITH TABLE KEY material = ls_open_reservation-material.
          IF sy-subrc = 0.
            lv_base_unit = ls_material_base_unit-base_unit.
          ELSE.
            lv_base_unit = mo_uom_repository->get_base_unit(
              iv_material = ls_open_reservation-material ).
            IF lv_base_unit IS INITIAL.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            INSERT VALUE #(
              material  = ls_open_reservation-material
              base_unit = lv_base_unit ) INTO TABLE lt_base_units.
          ENDIF.
          IF lv_base_unit IS INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          INSERT VALUE #(
            material    = ls_open_reservation-material
            plant       = ls_open_reservation-plant
            wbs_element = ls_open_reservation-wbs_element
            base_unit   = lv_base_unit ) INTO TABLE lt_balances.
          READ TABLE lt_balances ASSIGNING <ls_balance>
            WITH TABLE KEY material = ls_open_reservation-material
                           plant = ls_open_reservation-plant
                           wbs_element = ls_open_reservation-wbs_element.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ENDIF.
        <ls_balance>-excluded_open_resv_items =
          <ls_balance>-excluded_open_resv_items + 1.
        APPEND VALUE #(
          reservation_number = ls_open_reservation-reservation_number
          reservation_item   = ls_open_reservation-reservation_item )
          TO <ls_balance>-excluded_reservations.
        APPEND ls_open_reservation
          TO <ls_balance>-excluded_open_reservations.
        CONTINUE.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_open_reservation-material
        iv_quantity    = ls_open_reservation-open_quantity
        iv_source_unit = ls_open_reservation-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit IS INITIAL
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_base_units INTO ls_material_base_unit
        WITH TABLE KEY material = ls_open_reservation-material.
      IF sy-subrc = 0.
        IF ls_material_base_unit-base_unit <> ls_conversion-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material  = ls_open_reservation-material
          base_unit = ls_conversion-base_unit ) INTO TABLE lt_base_units.
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

      <ls_balance>-reserved_quantity += CONV decfloat34(
        ls_conversion-base_quantity ).
      <ls_balance>-open_reservation_items =
        <ls_balance>-open_reservation_items + 1.
      APPEND VALUE #(
        reservation_number = ls_open_reservation-reservation_number
        reservation_item   = ls_open_reservation-reservation_item )
        TO <ls_balance>-open_reservation_keys.
      APPEND VALUE #(
        reservation_number        = ls_open_reservation-reservation_number
        reservation_item          = ls_open_reservation-reservation_item
        reserved_quantity         = ls_conversion-base_quantity
        unit                      = ls_conversion-base_unit
        base_reserved_quantity    = ls_conversion-base_quantity
        base_unit                 = ls_conversion-base_unit
        source_open_quantity      = ls_open_reservation-open_quantity
        source_required_quantity  = ls_open_reservation-required_quantity
        source_withdrawn_quantity = ls_open_reservation-withdrawn_quantity
        source_unit               = ls_open_reservation-unit
        source_entry_unit         = ls_open_reservation-entry_unit
        required_date             = ls_open_reservation-required_date
        storage_location          = ls_open_reservation-storage_location
        batch                     = ls_open_reservation-batch )
        TO <ls_balance>-open_reservations.
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

    DATA(ls_subtraction) = subtract_project_reservations(
      it_stocks             = lt_eligible_stocks
      it_reservations       = lt_reservation_deductions
      iv_batch_only         = abap_false
      iv_all_stock_types    = abap_true
      iv_collect_deductions = abap_true ).
    DATA(lt_available_stocks) = ls_subtraction-stocks.
    lt_stock_deductions = ls_subtraction-stock_reservation_deductions.
    LOOP AT lt_stock_deductions
        ASSIGNING FIELD-SYMBOL(<ls_stock_deduction>).
      IF <ls_stock_deduction>-reserved_quantity <= 0
          OR <ls_stock_deduction>-base_reserved_quantity
            <> <ls_stock_deduction>-reserved_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_balances ASSIGNING <ls_balance>
        WITH TABLE KEY
          material = <ls_stock_deduction>-material
          plant = <ls_stock_deduction>-plant
          wbs_element = <ls_stock_deduction>-wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_stock_deduction>-unit = <ls_balance>-base_unit.
      <ls_stock_deduction>-base_unit = <ls_balance>-base_unit.
    ENDLOOP.
    LOOP AT lt_stock_deductions
        INTO DATA(ls_applied_stock_deduction).
      READ TABLE lt_applied_reservations ASSIGNING
        FIELD-SYMBOL(<ls_applied_reservation>)
        WITH TABLE KEY
          material = ls_applied_stock_deduction-material
          plant = ls_applied_stock_deduction-plant
          wbs_element = ls_applied_stock_deduction-wbs_element
          reservation_number =
            ls_applied_stock_deduction-reservation_number
          reservation_item = ls_applied_stock_deduction-reservation_item.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material           = ls_applied_stock_deduction-material
          plant              = ls_applied_stock_deduction-plant
          wbs_element        = ls_applied_stock_deduction-wbs_element
          reservation_number =
            ls_applied_stock_deduction-reservation_number
          reservation_item   = ls_applied_stock_deduction-reservation_item )
          INTO TABLE lt_applied_reservations.
        READ TABLE lt_applied_reservations ASSIGNING
          <ls_applied_reservation>
          WITH TABLE KEY
            material = ls_applied_stock_deduction-material
            plant = ls_applied_stock_deduction-plant
            wbs_element = ls_applied_stock_deduction-wbs_element
            reservation_number =
              ls_applied_stock_deduction-reservation_number
            reservation_item = ls_applied_stock_deduction-reservation_item.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      <ls_applied_reservation>-applied_quantity += CONV decfloat34(
        ls_applied_stock_deduction-base_reserved_quantity ).
    ENDLOOP.
    LOOP AT lt_available_stocks INTO DATA(ls_available_stock).
      READ TABLE lt_balances ASSIGNING <ls_balance>
        WITH TABLE KEY material = ls_available_stock-material
                       plant = ls_available_stock-plant
                       wbs_element = ls_available_stock-wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_balance>-available_quantity += CONV decfloat34(
        ls_available_stock-unrestricted_quantity ).

      READ TABLE lt_stock_balances ASSIGNING <ls_stock_balance>
        WITH TABLE KEY material = ls_available_stock-material
                       plant = ls_available_stock-plant
                       wbs_element = ls_available_stock-wbs_element
                       storage_location =
                         ls_available_stock-storage_location
                       batch = ls_available_stock-batch.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_stock_balance>-available_quantity += CONV decfloat34(
        ls_available_stock-unrestricted_quantity ).
    ENDLOOP.

    DATA lv_balance_uncovered TYPE decfloat34.
    DATA lv_reservation_applied TYPE decfloat34.
    DATA lv_uncovered_quantity TYPE decfloat34.
    LOOP AT lt_balances ASSIGNING <ls_balance>.
      CLEAR lv_balance_uncovered.
      LOOP AT <ls_balance>-open_reservations
          ASSIGNING FIELD-SYMBOL(<ls_coverage_reservation>).
        CLEAR lv_reservation_applied.
        READ TABLE lt_applied_reservations
            INTO DATA(ls_applied_reservation)
            WITH TABLE KEY
              material = <ls_balance>-material
              plant = <ls_balance>-plant
              wbs_element = <ls_balance>-wbs_element
              reservation_number =
                <ls_coverage_reservation>-reservation_number
              reservation_item =
                <ls_coverage_reservation>-reservation_item.
        IF sy-subrc = 0.
          lv_reservation_applied = ls_applied_reservation-applied_quantity.
        ENDIF.
        lv_uncovered_quantity = CONV decfloat34(
          <ls_coverage_reservation>-base_reserved_quantity )
          - lv_reservation_applied.
        IF lv_uncovered_quantity < 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        TRY.
            <ls_coverage_reservation>-covered_quantity =
              CONV mspr-prlab( lv_reservation_applied ).
            <ls_coverage_reservation>-base_covered_quantity =
              <ls_coverage_reservation>-covered_quantity.
            <ls_coverage_reservation>-uncovered_quantity =
              CONV mspr-prlab( lv_uncovered_quantity ).
            <ls_coverage_reservation>-base_uncovered_quantity =
              <ls_coverage_reservation>-uncovered_quantity.
          CATCH cx_sy_conversion_overflow.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDTRY.
        IF CONV decfloat34(
            <ls_coverage_reservation>-base_covered_quantity )
            + CONV decfloat34(
              <ls_coverage_reservation>-base_uncovered_quantity )
            <> CONV decfloat34(
              <ls_coverage_reservation>-base_reserved_quantity ).
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_balance_uncovered += lv_uncovered_quantity.
      ENDLOOP.

      DATA(lv_expected_shortfall) = <ls_balance>-reserved_quantity
        - <ls_balance>-project_stock_quantity.
      IF lv_expected_shortfall < 0.
        CLEAR lv_expected_shortfall.
      ENDIF.
      IF lv_balance_uncovered <> lv_expected_shortfall.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_balances INTO DATA(ls_balance).
      DATA lv_shortfall TYPE decfloat34.
      DATA lv_stock_deduction_total TYPE decfloat34.
      DATA lt_balance_deductions TYPE
        ty_cov_stock_deductions.
      lv_shortfall = ls_balance-reserved_quantity
        - ls_balance-project_stock_quantity.
      IF lv_shortfall < 0.
        CLEAR lv_shortfall.
      ENDIF.
      DATA lt_stock_details TYPE ty_reservation_coverage_stocks.
      CLEAR lt_balance_deductions.
      TRY.
          LOOP AT lt_stock_balances INTO DATA(ls_stock_balance)
            WHERE material = ls_balance-material
              AND plant = ls_balance-plant
              AND wbs_element = ls_balance-wbs_element.
            DATA(lv_stock_reserved) = ls_stock_balance-project_stock_qty
              - ls_stock_balance-available_quantity.
            IF lv_stock_reserved < 0.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            APPEND VALUE #(
              storage_location            = ls_stock_balance-storage_location
              batch                       = ls_stock_balance-batch
              unit                        = ls_balance-base_unit
              base_unit                   = ls_balance-base_unit
              project_stock_quantity      = CONV mspr-prlab(
                ls_stock_balance-project_stock_qty )
              reserved_quantity           = CONV mspr-prlab( lv_stock_reserved )
              available_quantity          = CONV mspr-prlab(
                ls_stock_balance-available_quantity )
              base_project_stock_quantity = CONV mspr-prlab(
                ls_stock_balance-project_stock_qty )
              base_reserved_quantity      = CONV mspr-prlab(
                lv_stock_reserved )
              base_available_quantity     = CONV mspr-prlab(
                ls_stock_balance-available_quantity ) )
              TO lt_stock_details.

            CLEAR lv_stock_deduction_total.
            LOOP AT lt_stock_deductions
                INTO DATA(ls_stock_deduction)
                WHERE material = ls_balance-material
                  AND plant = ls_balance-plant
                  AND wbs_element = ls_balance-wbs_element
                  AND storage_location =
                    ls_stock_balance-storage_location
                  AND batch = ls_stock_balance-batch.
              lv_stock_deduction_total += CONV decfloat34(
                ls_stock_deduction-base_reserved_quantity ).
              APPEND ls_stock_deduction
                TO lt_balance_deductions.
            ENDLOOP.
            IF lv_stock_deduction_total <> lv_stock_reserved.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
          ENDLOOP.
          SORT lt_stock_details BY storage_location batch.
          SORT lt_balance_deductions BY
            storage_location batch reservation_number reservation_item.
          APPEND VALUE #(
            material                     = ls_balance-material
            plant                        = ls_balance-plant
            wbs_element                  = ls_balance-wbs_element
            base_unit                    = ls_balance-base_unit
            project_stock_quantity       = CONV mspr-prlab(
              ls_balance-project_stock_quantity )
            reserved_quantity            = CONV mspr-prlab(
              ls_balance-reserved_quantity )
            available_quantity           = CONV mspr-prlab(
              ls_balance-available_quantity )
            shortfall_quantity           = CONV mspr-prlab( lv_shortfall )
            open_reservation_items       = ls_balance-open_reservation_items
            open_reservation_keys        = ls_balance-open_reservation_keys
            open_reservations            = ls_balance-open_reservations
            stock_details                = lt_stock_details
            stock_reservation_deductions =
              lt_balance_deductions
            excluded_open_reservations   =
              ls_balance-excluded_open_reservations
            excluded_open_resv_items     =
              ls_balance-excluded_open_resv_items
            excluded_reservations        = ls_balance-excluded_reservations
            is_fully_covered             = xsdbool( lv_shortfall = 0 ) )
            TO rt_coverage.
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
    ENDLOOP.
    SORT rt_coverage BY wbs_element material plant.
  ENDMETHOD.

  METHOD read_resv_coverage_for_key.
    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_wbs_element IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_optional_date( iv_date = iv_required_through_date ).

    DATA(lv_base_unit) = mo_uom_repository->get_base_unit(
      iv_material = iv_material ).
    IF lv_base_unit IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lt_base_units) = VALUE ty_material_base_units(
      ( material = iv_material base_unit = lv_base_unit ) ).

    DATA(lt_coverage) = read_reservation_coverage_core(
      it_wbs_elements          = VALUE #( )
      it_keys                  = VALUE #( ( material    = iv_material
                                            plant       = iv_plant
                                            wbs_element = iv_wbs_element ) )
      it_base_units            = lt_base_units
      it_excluded_reservations = it_excluded_reservations
      iv_required_through_date = iv_required_through_date ).
    READ TABLE lt_coverage INTO rs_coverage
      WITH KEY material = iv_material
               plant = iv_plant
               wbs_element = iv_wbs_element.
    IF sy-subrc = 0.
      IF rs_coverage-base_unit <> lv_base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      RETURN.
    ENDIF.

    rs_coverage = VALUE #(
      material         = iv_material
      plant            = iv_plant
      wbs_element      = iv_wbs_element
      base_unit        = lv_base_unit
      is_fully_covered = abap_true ).
  ENDMETHOD.

  METHOD read_resv_coverage_keys_bulk.
    rt_results = read_resv_cov_keys_bulk_core(
      it_requests                  = it_requests
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations = it_request_excl_reservations ).
  ENDMETHOD.

  METHOD read_resv_cov_keys_bulk_core.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_coverage_request_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_base_units TYPE ty_material_base_units.
    DATA lt_base_requests TYPE ty_coverage_requests.
    DATA lt_base_results TYPE ty_coverage_bulk_items.

    lt_base_units = it_base_units.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date(
        iv_date = ls_request-required_through_date ).
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_base_units INTO DATA(ls_request_base_unit)
        WITH TABLE KEY material = ls_request-material.
      IF sy-subrc <> 0.
        DATA(lv_base_unit) = mo_uom_repository->get_base_unit(
          iv_material = ls_request-material ).
        IF lv_base_unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          material  = ls_request-material
          base_unit = lv_base_unit ) INTO TABLE lt_base_units.
        READ TABLE lt_base_units INTO ls_request_base_unit
          WITH TABLE KEY material = ls_request-material.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      IF ls_request_base_unit-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id            = ls_request-request_id
        wbs_element           = ls_request-wbs_element
        required_through_date = ls_request-required_through_date )
        TO lt_base_requests.
    ENDLOOP.

    lt_base_results = read_reservation_cov_bulk_core(
      it_requests                  = lt_base_requests
      it_key_requests              = it_requests
      it_base_units                = lt_base_units
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations =
        it_request_excl_reservations ).
    IF lines( lt_base_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_base_results INTO DATA(ls_base_result).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE it_requests INTO ls_request INDEX lv_request_index.
      IF sy-subrc <> 0
          OR ls_base_result-request_id <> ls_request-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_base_units INTO ls_request_base_unit
        WITH TABLE KEY material = ls_request-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_coverage) = VALUE ty_reservation_coverage(
        material         = ls_request-material
        plant            = ls_request-plant
        wbs_element      = ls_request-wbs_element
        base_unit        = ls_request_base_unit-base_unit
        is_fully_covered = abap_true ).
      READ TABLE ls_base_result-coverage INTO DATA(ls_found_coverage)
        WITH KEY material = ls_request-material
                 plant = ls_request-plant
                 wbs_element = ls_request-wbs_element.
      IF sy-subrc = 0.
        IF ls_found_coverage-base_unit <> ls_request_base_unit-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ls_coverage = ls_found_coverage.
      ENDIF.
      APPEND VALUE #(
        request_id            = ls_request-request_id
        material              = ls_request-material
        plant                 = ls_request-plant
        wbs_element           = ls_request-wbs_element
        required_through_date = ls_request-required_through_date
        coverage              = ls_coverage ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_reservation_coverage_uom.
    DATA ls_coverage TYPE ty_reservation_coverage.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).

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

    DATA(lv_verified_base_unit) = mo_uom_repository->get_base_unit(
      iv_material = iv_material ).
    IF lv_verified_base_unit IS INITIAL
        OR lv_verified_base_unit <> ls_unit_ratio-base_unit.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    ls_coverage = VALUE #(
      material    = iv_material
      plant       = iv_plant
      wbs_element = iv_wbs_element
      base_unit   = ls_unit_ratio-base_unit ).

    DATA(lt_base_units) = VALUE ty_material_base_units(
      ( material  = iv_material
        base_unit = ls_unit_ratio-base_unit ) ).

    DATA(lt_coverage) = read_reservation_coverage_core(
      it_wbs_elements          = VALUE #( )
      it_keys                  = VALUE #( ( material    = iv_material
                                            plant       = iv_plant
                                            wbs_element = iv_wbs_element ) )
      it_base_units            = lt_base_units
      it_excluded_reservations = it_excluded_reservations
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
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_coverage_request_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_unit_ratios TYPE ty_stock_unit_ratios.
    DATA lt_base_units TYPE ty_material_base_units.
    DATA lt_base_requests TYPE ty_coverage_key_requests.
    DATA lt_base_results TYPE ty_coverage_key_bulk_items.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).

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

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

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
      READ TABLE lt_base_units INTO DATA(ls_base_unit)
        WITH TABLE KEY material = ls_request-material.
      IF sy-subrc = 0.
        IF ls_base_unit-base_unit <> ls_unit_ratio-result-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ELSE.
        DATA(lv_verified_base_unit) = mo_uom_repository->get_base_unit(
          iv_material = ls_request-material ).
        IF lv_verified_base_unit IS INITIAL
            OR lv_verified_base_unit <> ls_unit_ratio-result-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          material  = ls_request-material
          base_unit = lv_verified_base_unit ) INTO TABLE lt_base_units.
      ENDIF.
      APPEND VALUE #(
        request_id            = ls_request-request_id
        material              = ls_request-material
        plant                 = ls_request-plant
        wbs_element           = ls_request-wbs_element
        required_through_date = ls_request-required_through_date )
        TO lt_base_requests.
    ENDLOOP.

    lt_base_results = read_resv_cov_keys_bulk_core(
      it_requests                  = lt_base_requests
      it_base_units                = lt_base_units
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations =
        it_request_excl_reservations ).
    IF lines( lt_base_results ) <> lines( it_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_base_results INTO DATA(ls_base_result).
      DATA(lv_request_index) = sy-tabix.
      READ TABLE it_requests INTO ls_request INDEX lv_request_index.
      IF sy-subrc <> 0
          OR ls_base_result-request_id <> ls_request-request_id
          OR ls_base_result-material <> ls_request-material
          OR ls_base_result-plant <> ls_request-plant
          OR ls_base_result-wbs_element <> ls_request-wbs_element.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_unit_ratios INTO ls_unit_ratio
        WITH TABLE KEY material = ls_request-material
                       unit = ls_request-requested_unit.
      IF sy-subrc <> 0
          OR ls_base_result-coverage-base_unit
            <> ls_unit_ratio-result-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        request_id            = ls_request-request_id
        material              = ls_request-material
        plant                 = ls_request-plant
        wbs_element           = ls_request-wbs_element
        requested_unit        = ls_request-requested_unit
        required_through_date = ls_request-required_through_date
        coverage              = convert_coverage_to_unit(
          is_coverage   = ls_base_result-coverage
          iv_unit       = ls_request-requested_unit
          is_unit_ratio = ls_unit_ratio-result ) ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.
  METHOD read_reservation_coverage_bulk.
    rt_results = read_reservation_cov_bulk_core(
      it_requests                  = it_requests
      it_excluded_reservations     = it_excluded_reservations
      it_request_excl_reservations = it_request_excl_reservations ).
  ENDMETHOD.

  METHOD read_reservation_cov_bulk_core.
    TYPES ty_seen_request_id TYPE c LENGTH 30.
    TYPES ty_coverage_date TYPE d.
    TYPES ty_coverage_dates TYPE HASHED TABLE OF ty_coverage_date
      WITH UNIQUE KEY table_line.
    TYPES ty_coverage_group_id TYPE i.
    TYPES ty_coverage_group_ids TYPE SORTED TABLE OF
      ty_coverage_group_id WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_request_exclusion_group,
        request_id TYPE c LENGTH 30,
        group_id   TYPE i,
      END OF ty_request_exclusion_group,
      ty_request_exclusion_group_map TYPE HASHED TABLE OF
        ty_request_exclusion_group WITH UNIQUE KEY request_id,
      BEGIN OF ty_group_reservation_key,
        group_id           TYPE i,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_group_reservation_key,
      ty_group_reservation_keys TYPE STANDARD TABLE OF
        ty_group_reservation_key WITH EMPTY KEY,
      ty_group_stock_keys TYPE SORTED TABLE OF
        zif_project_stock_repository=>ty_key
        WITH UNIQUE KEY material plant wbs_element,
      BEGIN OF ty_dated_coverage,
        required_through_date TYPE d,
        group_id              TYPE i,
        coverage              TYPE ty_reservation_coverage,
      END OF ty_dated_coverage,
      ty_dated_coverages TYPE STANDARD TABLE OF
        ty_dated_coverage WITH EMPTY KEY.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_seen_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_key_request_ids TYPE HASHED TABLE OF ty_seen_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_request_exclusions TYPE HASHED TABLE OF
      ty_coverage_request_exclusion
      WITH UNIQUE KEY request_id reservation_number reservation_item.
    DATA lt_dates TYPE ty_coverage_dates.
    DATA lt_group_ids TYPE ty_coverage_group_ids.
    DATA lt_group_reservations TYPE ty_group_reservation_keys.
    DATA lt_request_groups TYPE ty_request_exclusion_group_map.
    DATA lt_request_keys TYPE zif_stock_repository=>ty_reservation_keys.
    DATA lt_effective_exclusions TYPE zif_stock_repository=>ty_reservation_keys.
    DATA lt_group_stock_keys TYPE ty_group_stock_keys.
    DATA lt_group_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_dated_coverage TYPE ty_dated_coverages.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_coverage TYPE ty_reservation_coverages.
    DATA lv_next_group_id TYPE i.
    DATA lv_group_key_count TYPE i.
    DATA lv_candidate_group_id TYPE i.
    DATA lv_request_group_id TYPE i.
    DATA lv_same_group TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_coverage_bulk_item.

    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).

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

    IF it_key_requests IS NOT INITIAL.
      IF lines( it_key_requests ) <> lines( it_requests ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      LOOP AT it_key_requests INTO DATA(ls_key_request).
        INSERT ls_key_request-request_id INTO TABLE
          lt_seen_key_request_ids.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        READ TABLE it_requests INTO DATA(ls_key_base_request)
          WITH KEY request_id = ls_key_request-request_id.
        IF sy-subrc <> 0
            OR ls_key_request-material IS INITIAL
            OR ls_key_request-plant IS INITIAL
            OR ls_key_request-wbs_element
              <> ls_key_base_request-wbs_element
            OR ls_key_request-required_through_date
              <> ls_key_base_request-required_through_date.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT it_request_excl_reservations
        INTO DATA(ls_request_exclusion).
      IF ls_request_exclusion-request_id IS INITIAL
          OR ls_request_exclusion-reservation_number IS INITIAL
          OR ls_request_exclusion-reservation_item IS INITIAL
          OR NOT line_exists( lt_seen_request_ids[
            table_line = ls_request_exclusion-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_exclusion INTO TABLE lt_seen_request_exclusions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      CLEAR lt_request_keys.
      LOOP AT it_request_excl_reservations
          INTO ls_request_exclusion
          WHERE request_id = ls_request-request_id.
        APPEND VALUE #(
          reservation_number = ls_request_exclusion-reservation_number
          reservation_item   = ls_request_exclusion-reservation_item )
          TO lt_request_keys.
      ENDLOOP.
      SORT lt_request_keys BY reservation_number reservation_item.

      CLEAR lv_request_group_id.
      LOOP AT lt_group_ids INTO lv_candidate_group_id.
        CLEAR lv_group_key_count.
        LOOP AT lt_group_reservations TRANSPORTING NO FIELDS
            WHERE group_id = lv_candidate_group_id.
          lv_group_key_count += 1.
        ENDLOOP.
        IF lv_group_key_count <> lines( lt_request_keys ).
          CONTINUE.
        ENDIF.

        lv_same_group = abap_true.
        LOOP AT lt_request_keys INTO DATA(ls_request_key).
          IF NOT line_exists( lt_group_reservations[
            group_id = lv_candidate_group_id
            reservation_number = ls_request_key-reservation_number
            reservation_item = ls_request_key-reservation_item ] ).
            lv_same_group = abap_false.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_same_group = abap_true.
          lv_request_group_id = lv_candidate_group_id.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_request_group_id IS INITIAL.
        lv_next_group_id += 1.
        lv_request_group_id = lv_next_group_id.
        INSERT lv_request_group_id INTO TABLE lt_group_ids.
        LOOP AT lt_request_keys INTO DATA(ls_new_group_key).
          APPEND VALUE #(
            group_id           = lv_request_group_id
            reservation_number = ls_new_group_key-reservation_number
            reservation_item   = ls_new_group_key-reservation_item )
            TO lt_group_reservations.
        ENDLOOP.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_request-request_id
        group_id   = lv_request_group_id ) INTO TABLE lt_request_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_dates INTO DATA(lv_required_through_date).
      LOOP AT lt_group_ids INTO DATA(lv_group_id).
        CLEAR lt_wbs_elements.
        LOOP AT it_requests INTO ls_request
          WHERE required_through_date = lv_required_through_date.
          READ TABLE lt_request_groups INTO DATA(ls_request_group)
            WITH TABLE KEY request_id = ls_request-request_id.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          IF ls_request_group-group_id <> lv_group_id.
            CONTINUE.
          ENDIF.
          IF NOT line_exists( lt_wbs_elements[
            table_line = ls_request-wbs_element ] ).
            APPEND ls_request-wbs_element TO lt_wbs_elements.
          ENDIF.
        ENDLOOP.
        IF lt_wbs_elements IS INITIAL.
          CONTINUE.
        ENDIF.

        lt_effective_exclusions = it_excluded_reservations.
        LOOP AT lt_group_reservations INTO DATA(ls_group_reservation)
            WHERE group_id = lv_group_id.
          IF NOT line_exists( lt_effective_exclusions[
            reservation_number = ls_group_reservation-reservation_number
            reservation_item = ls_group_reservation-reservation_item ] ).
            APPEND VALUE #(
              reservation_number = ls_group_reservation-reservation_number
              reservation_item   = ls_group_reservation-reservation_item )
              TO lt_effective_exclusions.
          ENDIF.
        ENDLOOP.

        IF it_key_requests IS INITIAL.
          lt_coverage = read_reservation_coverage_core(
            it_wbs_elements          = lt_wbs_elements
            it_base_units            = it_base_units
            it_excluded_reservations = lt_effective_exclusions
            iv_required_through_date = lv_required_through_date ).
        ELSE.
          CLEAR lt_group_stock_keys.
          LOOP AT it_key_requests INTO ls_key_request
              WHERE required_through_date = lv_required_through_date.
            READ TABLE lt_request_groups INTO ls_request_group
              WITH TABLE KEY request_id = ls_key_request-request_id.
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            IF ls_request_group-group_id <> lv_group_id.
              CONTINUE.
            ENDIF.
            INSERT VALUE #(
              material    = ls_key_request-material
              plant       = ls_key_request-plant
              wbs_element = ls_key_request-wbs_element )
              INTO TABLE lt_group_stock_keys.
          ENDLOOP.
          CLEAR lt_group_keys.
          LOOP AT lt_group_stock_keys INTO DATA(ls_group_stock_key).
            APPEND VALUE #(
              material    = ls_group_stock_key-material
              plant       = ls_group_stock_key-plant
              wbs_element = ls_group_stock_key-wbs_element )
              TO lt_group_keys.
          ENDLOOP.
          IF lt_group_keys IS INITIAL.
            CONTINUE.
          ENDIF.
          lt_coverage = read_reservation_coverage_core(
            it_wbs_elements          = VALUE #( )
            it_keys                  = lt_group_keys
            it_base_units            = it_base_units
            it_excluded_reservations = lt_effective_exclusions
            iv_required_through_date = lv_required_through_date ).
        ENDIF.
        LOOP AT lt_coverage INTO DATA(ls_coverage).
          APPEND VALUE #(
            required_through_date = lv_required_through_date
            group_id              = lv_group_id
            coverage              = ls_coverage ) TO lt_dated_coverage.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rt_results ASSIGNING <ls_result>.
      <ls_result>-request_id = ls_request-request_id.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-required_through_date =
        ls_request-required_through_date.
      READ TABLE lt_request_groups INTO DATA(ls_result_group)
        WITH TABLE KEY request_id = ls_request-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      LOOP AT lt_dated_coverage INTO DATA(ls_dated_coverage).
        IF ls_dated_coverage-required_through_date
              <> ls_request-required_through_date
            OR ls_dated_coverage-group_id <> ls_result_group-group_id
            OR ls_dated_coverage-coverage-wbs_element
              <> ls_request-wbs_element.
          CONTINUE.
        ENDIF.
        APPEND ls_dated_coverage-coverage TO <ls_result>-coverage.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_fefo.
    DATA lt_seen_requests TYPE ty_request_keys.
    DATA lt_seen_request_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_scoped_requests TYPE ty_request_keys.
    DATA lt_seen_locations TYPE ty_storage_location_set.
    DATA lt_allowed_locations TYPE ty_storage_location_set.
    DATA lt_prepared_demands TYPE ty_prepared_demands.
    DATA lt_stock_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_stock_balances TYPE ty_stock_balances.
    DATA lt_candidates TYPE ty_candidates.
    DATA lv_demand_as_of_date TYPE d.
    DATA lv_demand_minimum_shelf_life TYPE i.
    DATA lv_demand_include_undated TYPE abap_bool.
    DATA lv_remaining_shelf_life_days TYPE i.
    DATA lv_available_quantity TYPE decfloat34.
    DATA lv_on_hand_from_date TYPE d.
    DATA lv_allocation_sequence TYPE i.

    validate_required_date( iv_date = iv_as_of_date ).
    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
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

    LOOP AT it_demands INTO DATA(ls_request_demand).
      IF ls_request_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_request_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_seen_requests[
            request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_request_location-request_id )
        INTO TABLE lt_scoped_requests.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_seen_requests[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_request_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-request_locations = it_request_locations.
    IF it_demands IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_policy_demand).
      IF ( ls_policy_demand-require_known_expiry <> abap_true
            AND ls_policy_demand-require_known_expiry <> abap_false )
          OR ( ls_policy_demand-allow_undated_batches <> abap_true
            AND ls_policy_demand-allow_undated_batches <> abap_false )
          OR ( ls_policy_demand-require_full_quantity <> abap_true
            AND ls_policy_demand-require_full_quantity <> abap_false )
          OR ( ls_policy_demand-allow_location_fallback <> abap_true
            AND ls_policy_demand-allow_location_fallback <> abap_false )
          OR ls_policy_demand-minimum_coverage_pct < 0
          OR ls_policy_demand-minimum_coverage_pct > 100
          OR ( ls_policy_demand-require_known_expiry = abap_true
            AND ls_policy_demand-allow_undated_batches = abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-wbs_element IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-minimum_shelf_life_days < 0
          OR ls_demand-location_as_of_date IS NOT INITIAL
          OR ( ls_demand-require_known_expiry <> abap_true
            AND ls_demand-require_known_expiry <> abap_false )
          OR ( ls_demand-allow_undated_batches <> abap_true
            AND ls_demand-allow_undated_batches <> abap_false )
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false )
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-allow_location_fallback = abap_true
            AND ls_demand-storage_location IS INITIAL )
          OR ( ls_demand-require_known_expiry = abap_true
            AND ls_demand-allow_undated_batches = abap_true )
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_demand-storage_location ] ) )
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND line_exists( lt_scoped_requests[
              request_id = ls_demand-request_id ] )
            AND NOT line_exists( lt_seen_request_locations[
              request_id = ls_demand-request_id
              storage_location = ls_demand-storage_location ] ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date( iv_date = ls_demand-fefo_as_of_date ).

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
        allow_location_fallback = ls_demand-allow_location_fallback
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        base_quantity           = ls_conversion-base_quantity
        base_unit               = ls_conversion-base_unit
        fefo_as_of_date         = ls_demand-fefo_as_of_date
        minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days
        require_known_expiry    = ls_demand-require_known_expiry
        allow_undated_batches   = ls_demand-allow_undated_batches
        minimum_coverage_pct    = ls_demand-minimum_coverage_pct )
        TO lt_prepared_demands.
      APPEND VALUE #(
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        allocation_sequence = lines( lt_prepared_demands ) )
        TO rs_result-wbs_assignments.
    ENDLOOP.

    LOOP AT it_projected_batch_receipts
        INTO DATA(ls_projected_receipt).
      IF ls_projected_receipt-wbs_element IS INITIAL
          OR ls_projected_receipt-material IS INITIAL
          OR ls_projected_receipt-plant IS INITIAL
          OR ls_projected_receipt-storage_location IS INITIAL
          OR ls_projected_receipt-batch IS INITIAL
          OR ls_projected_receipt-base_quantity <= 0
          OR NOT line_exists( it_demands[
            wbs_element = ls_projected_receipt-wbs_element
            material = ls_projected_receipt-material
            plant = ls_projected_receipt-plant ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date(
        iv_date = ls_projected_receipt-receipt_date ).
      validate_optional_date(
        iv_date = ls_projected_receipt-expiration_date ).
      IF ls_projected_receipt-expiration_date IS NOT INITIAL
          AND ls_projected_receipt-expiration_date
            < ls_projected_receipt-receipt_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      LOOP AT it_projected_batch_receipts
          INTO DATA(ls_matching_receipt)
          WHERE material = ls_projected_receipt-material
            AND plant = ls_projected_receipt-plant
            AND batch = ls_projected_receipt-batch.
        IF ls_matching_receipt-expiration_date
            <> ls_projected_receipt-expiration_date.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DATA(lt_raw_project_stocks) = mo_repository->read_project_stocks(
      it_keys = lt_stock_keys ).
    DATA(lt_project_reservations) =
      mo_repository->read_project_reservations(
        it_keys                  = lt_stock_keys
        iv_required_through_date = iv_reservation_through_date ).
    DATA(ls_subtraction) = subtract_project_reservations(
      it_excluded_reservations    = it_excluded_reservations
      it_stocks                   = lt_raw_project_stocks
      it_reservations             = lt_project_reservations
      iv_batch_only               = abap_true
      iv_reservation_through_date = iv_reservation_through_date ).
    DATA(lt_project_stocks) = ls_subtraction-stocks.
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
                         batch = ls_project_stock-batch
                         available_from_date = lv_on_hand_from_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF <ls_existing_balance>-expiration_date
            <> ls_project_stock-expiration_date.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        DATA(lv_combined_quantity) =
          CONV decfloat34( <ls_existing_balance>-remaining_quantity )
          + CONV decfloat34(
            ls_project_stock-unrestricted_quantity ).
        <ls_existing_balance>-remaining_quantity =
          me->checked_stock_quantity(
            iv_quantity = lv_combined_quantity ).
      ENDIF.
    ENDLOOP.

    LOOP AT it_projected_batch_receipts
        INTO ls_projected_receipt.
      LOOP AT lt_stock_balances INTO DATA(ls_expiry_balance)
          WHERE material = ls_projected_receipt-material
            AND plant = ls_projected_receipt-plant
            AND batch = ls_projected_receipt-batch.
        IF ls_expiry_balance-expiration_date
            <> ls_projected_receipt-expiration_date.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
      INSERT VALUE #(
        material            = ls_projected_receipt-material
        plant               = ls_projected_receipt-plant
        wbs_element         = ls_projected_receipt-wbs_element
        storage_location    = ls_projected_receipt-storage_location
        batch               = ls_projected_receipt-batch
        expiration_date     = ls_projected_receipt-expiration_date
        available_from_date = ls_projected_receipt-receipt_date
        remaining_quantity  = ls_projected_receipt-base_quantity )
        INTO TABLE lt_stock_balances.
      IF sy-subrc <> 0.
        READ TABLE lt_stock_balances
          ASSIGNING FIELD-SYMBOL(<ls_existing_receipt_balance>)
          WITH TABLE KEY material = ls_projected_receipt-material
                         plant = ls_projected_receipt-plant
                         wbs_element = ls_projected_receipt-wbs_element
                         storage_location =
                           ls_projected_receipt-storage_location
                         batch = ls_projected_receipt-batch
                         available_from_date =
                           ls_projected_receipt-receipt_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        DATA(lv_combined_receipt_quantity) =
          CONV decfloat34(
            <ls_existing_receipt_balance>-remaining_quantity )
          + CONV decfloat34( ls_projected_receipt-base_quantity ).
        <ls_existing_receipt_balance>-remaining_quantity =
          me->checked_stock_quantity(
            iv_quantity = lv_combined_receipt_quantity ).
      ENDIF.
    ENDLOOP.

    LOOP AT lt_prepared_demands INTO DATA(ls_prepared_demand).
      ADD 1 TO lv_allocation_sequence.
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
      lv_demand_include_undated = iv_include_undated_batches.
      IF ls_prepared_demand-allow_undated_batches = abap_true.
        lv_demand_include_undated = abap_true.
      ENDIF.
      IF ls_prepared_demand-require_known_expiry = abap_true.
        lv_demand_include_undated = abap_false.
      ENDIF.
      DATA lv_request_has_priorities TYPE abap_bool.
      CLEAR lv_request_has_priorities.
      LOOP AT it_request_location_priorities
          TRANSPORTING NO FIELDS
          WHERE request_id = ls_prepared_demand-request_id.
        lv_request_has_priorities = abap_true.
        EXIT.
      ENDLOOP.
      CLEAR lt_candidates.
      LOOP AT lt_stock_balances INTO DATA(ls_balance)
        WHERE material = ls_prepared_demand-material
          AND plant = ls_prepared_demand-plant
          AND wbs_element = ls_prepared_demand-wbs_element.
        IF ls_balance-available_from_date > lv_demand_as_of_date.
          CONTINUE.
        ENDIF.
        IF ls_prepared_demand-storage_location IS NOT INITIAL
            AND ls_prepared_demand-allow_location_fallback <> abap_true
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
        IF line_exists( lt_scoped_requests[
            request_id = ls_prepared_demand-request_id ] )
            AND NOT line_exists( lt_seen_request_locations[
              request_id = ls_prepared_demand-request_id
              storage_location = ls_balance-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF ls_balance-expiration_date IS INITIAL.
          IF lv_demand_include_undated = abap_false
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
        DATA(lv_request_ranked) = abap_false.
        IF lv_request_has_priorities = abap_true.
          CLEAR lv_location_priority.
          READ TABLE it_request_location_priorities
            INTO DATA(ls_location_priority_row)
            WITH KEY request_id = ls_prepared_demand-request_id
                     storage_location = ls_balance-storage_location.
          IF sy-subrc = 0.
            lv_location_priority =
              ls_location_priority_row-priority_rank.
            lv_request_ranked = abap_true.
          ENDIF.
        ELSE.
          READ TABLE it_storage_location_priority
            TRANSPORTING NO FIELDS
            WITH KEY table_line = ls_balance-storage_location.
          IF sy-subrc = 0.
            lv_location_priority = sy-tabix.
          ENDIF.
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
          available_from_date  = ls_balance-available_from_date
          preferred_location   = xsdbool(
            ls_prepared_demand-allow_location_fallback = abap_true
            AND ls_prepared_demand-storage_location =
              ls_balance-storage_location )
          request_ranked       = lv_request_ranked
          location_priority    = lv_location_priority )
          TO lt_candidates.
      ENDLOOP.
      SORT lt_candidates BY sort_expiration_date ASCENDING
                            preferred_location DESCENDING
                            request_ranked DESCENDING
                            location_priority ASCENDING
                            storage_location ASCENDING
                            batch ASCENDING
                            available_from_date ASCENDING.

      DATA(ls_allocation) = VALUE zcl_stock_service=>ty_allocation(
        request_id           = ls_prepared_demand-request_id
        material             = ls_prepared_demand-material
        plant                = ls_prepared_demand-plant
        allocation_sequence  = lv_allocation_sequence
        requested_quantity   = ls_prepared_demand-base_quantity
        minimum_coverage_pct =
          ls_prepared_demand-minimum_coverage_pct ).
      CLEAR lv_available_quantity.
      LOOP AT lt_candidates INTO DATA(ls_candidate).
        READ TABLE lt_stock_balances ASSIGNING FIELD-SYMBOL(<ls_balance>)
          WITH TABLE KEY material = ls_candidate-material
                         plant = ls_candidate-plant
                         wbs_element = ls_candidate-wbs_element
                         storage_location = ls_candidate-storage_location
                         batch = ls_candidate-batch
                         available_from_date =
                           ls_candidate-available_from_date.
        IF sy-subrc = 0.
          lv_available_quantity = lv_available_quantity
            + CONV decfloat34( <ls_balance>-remaining_quantity ).
        ENDIF.
      ENDLOOP.
      ls_allocation-available_quantity = me->checked_stock_quantity(
        iv_quantity = lv_available_quantity ).

      DATA lv_remaining_quantity TYPE mard-labst.
      DATA lv_allocated_quantity TYPE mard-labst.
      lv_remaining_quantity = ls_prepared_demand-base_quantity.
      CLEAR lv_allocated_quantity.
      IF ( iv_require_full_quantity = abap_true
            OR ls_prepared_demand-require_full_quantity = abap_true )
          AND ls_prepared_demand-base_quantity
            > ls_allocation-available_quantity.
        ls_allocation-shortfall_quantity =
          ls_prepared_demand-base_quantity.
      ELSEIF lv_available_quantity <
          CONV decfloat34( ls_prepared_demand-base_quantity )
          AND lv_available_quantity * CONV decfloat34( 100 )
            < CONV decfloat34( ls_prepared_demand-base_quantity )
              * CONV decfloat34(
                ls_prepared_demand-minimum_coverage_pct ).
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
                           batch = ls_candidate-batch
                           available_from_date =
                             ls_candidate-available_from_date.
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
              require_known_expiry    =
                ls_prepared_demand-require_known_expiry
              allow_undated_batches   =
                ls_prepared_demand-allow_undated_batches
              minimum_coverage_pct    =
                ls_prepared_demand-minimum_coverage_pct
              available_from_date     =
                ls_candidate-available_from_date
              allocated_quantity      = lv_split_quantity )
            available_from_date       =
              ls_candidate-available_from_date
            base_unit                 = ls_prepared_demand-base_unit
            source_unit               = ls_prepared_demand-unit
            allocated_source_quantity =
              ls_source_split-alternative_quantity
            allocation_sequence       = lv_allocation_sequence )
            TO rs_result-allocation-batch_allocations.
          SUBTRACT lv_split_quantity FROM <ls_balance>-remaining_quantity.
          SUBTRACT lv_split_quantity FROM lv_remaining_quantity.
          ADD lv_split_quantity TO lv_allocated_quantity.
        ENDLOOP.
        ls_allocation-allocated_quantity = lv_allocated_quantity.
        ls_allocation-shortfall_quantity = lv_remaining_quantity.
      ENDIF.
      ls_allocation-require_full_quantity = xsdbool(
        iv_require_full_quantity = abap_true
        OR ls_prepared_demand-require_full_quantity = abap_true ).
      ls_allocation-require_known_expiry =
        ls_prepared_demand-require_known_expiry.
      ls_allocation-allow_undated_batches =
        ls_prepared_demand-allow_undated_batches.
      ls_allocation-minimum_coverage_rejected = xsdbool(
        CONV decfloat34( ls_allocation-allocated_quantity )
          * CONV decfloat34( 100 )
          < CONV decfloat34( ls_prepared_demand-base_quantity )
            * CONV decfloat34(
              ls_prepared_demand-minimum_coverage_pct ) ).
      ls_allocation-allocation_outcome = COND #(
        WHEN ls_allocation-allocated_quantity =
            ls_prepared_demand-base_quantity
          THEN zif_stock_repository=>c_allocation_outcome_full
        WHEN ls_allocation-allocated_quantity > 0
          THEN zif_stock_repository=>c_allocation_outcome_partial
        ELSE zif_stock_repository=>c_allocation_outcome_none ).
      ls_allocation-allocation_coverage_pct =
        CONV zcl_stock_service=>ty_allocation_coverage_pct(
          CONV decfloat34( ls_allocation-allocated_quantity )
          * CONV decfloat34( 100 )
          / CONV decfloat34( ls_prepared_demand-base_quantity ) ).

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

  METHOD preview_fefo_priority.
    TYPES:
      BEGIN OF ty_indexed_demand,
        input_index TYPE i,
        demand      TYPE ty_priority_fefo_demand,
      END OF ty_indexed_demand,
      ty_indexed_demands TYPE STANDARD TABLE OF ty_indexed_demand
        WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_request_context,
        input_index         TYPE i,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE ty_wbs_element,
        priority            TYPE i,
      END OF ty_request_context,
      ty_request_contexts TYPE STANDARD TABLE OF ty_request_context
        WITH EMPTY KEY.
    DATA lt_indexed_demands TYPE ty_indexed_demands.
    DATA lt_contexts TYPE ty_request_contexts.
    DATA lt_base_demands TYPE ty_demands.
    DATA lt_base_location_priorities TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_base_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA ls_base_result TYPE ty_result.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF iv_prioritize_by_date <> abap_true
        AND iv_prioritize_by_date <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_prioritize_by_date = abap_true.
      LOOP AT it_demands INTO DATA(ls_date_demand).
        IF ls_date_demand-fefo_as_of_date IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        validate_required_date(
          iv_date = ls_date_demand-fefo_as_of_date ).
      ENDLOOP.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_input_demand).
      IF ls_input_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = sy-tabix
        demand      = ls_input_demand )
        TO lt_indexed_demands.
    ENDLOOP.
    IF iv_prioritize_by_date = abap_true.
      SORT lt_indexed_demands STABLE BY
        demand-fefo_as_of_date ASCENDING demand-priority DESCENDING.
    ELSE.
      SORT lt_indexed_demands STABLE BY demand-priority DESCENDING.
    ENDIF.

    LOOP AT lt_indexed_demands INTO DATA(ls_indexed_demand).
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        wbs_element             = ls_indexed_demand-demand-wbs_element
        material                = ls_indexed_demand-demand-material
        plant                   = ls_indexed_demand-demand-plant
        storage_location        =
          ls_indexed_demand-demand-storage_location
        allow_location_fallback =
          ls_indexed_demand-demand-allow_location_fallback
        batch                   = ls_indexed_demand-demand-batch
        requested_quantity      =
          ls_indexed_demand-demand-requested_quantity
        require_full_quantity   =
          ls_indexed_demand-demand-require_full_quantity
        unit                    = ls_indexed_demand-demand-unit
        fefo_as_of_date         =
          ls_indexed_demand-demand-fefo_as_of_date
        minimum_shelf_life_days =
          ls_indexed_demand-demand-minimum_shelf_life_days
        require_known_expiry    =
          ls_indexed_demand-demand-require_known_expiry
        allow_undated_batches   =
          ls_indexed_demand-demand-allow_undated_batches
        minimum_coverage_pct    =
          ls_indexed_demand-demand-minimum_coverage_pct )
        TO lt_base_demands.
      APPEND VALUE #(
        input_index         = ls_indexed_demand-input_index
        internal_request_id = lv_internal_request_id
        request_id          = ls_indexed_demand-demand-request_id
        wbs_element         = ls_indexed_demand-demand-wbs_element
        priority            = ls_indexed_demand-demand-priority )
        TO lt_contexts.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_scope_context).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_context-request_id.
        APPEND VALUE #(
          request_id       = ls_scope_context-internal_request_id
          storage_location = ls_request_location-storage_location )
          TO lt_base_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    =
            ls_request_location_priority-priority_rank )
          TO lt_base_location_priorities.
      ENDLOOP.
    ENDLOOP.

    ls_base_result = preview_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_base_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_base_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_base_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    rs_result-request_locations = it_request_locations.
    SORT lt_contexts BY input_index ASCENDING.
    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_base_result-allocation-allocations
          INTO DATA(ls_allocation)
        WITH KEY allocation-request_id = ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_allocation-allocation-request_id = ls_context-request_id.
      ls_allocation-allocation-priority = ls_context-priority.
      APPEND VALUE #(
        allocation          = ls_allocation
        priority            = ls_context-priority
        allocation_sequence =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-allocations.

      LOOP AT ls_base_result-allocation-batch_allocations
          INTO DATA(ls_batch_split)
          WHERE batch_allocation-request_id =
            ls_context-internal_request_id.
        ls_batch_split-batch_allocation-request_id = ls_context-request_id.
        APPEND VALUE #(
          split               = ls_batch_split
          priority            = ls_context-priority
          allocation_sequence =
            ls_batch_split-allocation_sequence )
          TO rs_result-batch_allocations.
      ENDLOOP.

      APPEND VALUE #(
        request_id          = ls_context-request_id
        wbs_element         = ls_context-wbs_element
        priority            = ls_context-priority
        allocation_sequence =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-wbs_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_fefo_priority_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_fefo_priority(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_prioritize_by_date          = iv_prioritize_by_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_fefo_by_date.
    DATA lt_work TYPE ty_dated_fefo_works.
    DATA lt_sorted_demands TYPE ty_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocation_order TYPE ty_dated_allocation_orders.
    DATA lt_split_order TYPE ty_dated_split_orders.
    DATA ls_internal_demand TYPE ty_dated_fefo_demand.
    DATA lv_internal_request_id TYPE c LENGTH 30.
    DATA lv_input_index TYPE i.
    DATA lv_allocation_sequence TYPE i.

    LOOP AT it_demands INTO DATA(ls_demand).
      ADD 1 TO lv_input_index.
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date( iv_date = ls_demand-required_date ).
      validate_optional_date( iv_date = ls_demand-fefo_as_of_date ).
      lv_internal_request_id = |D{ lv_input_index }|.
      INSERT VALUE #(
        request_id        = lv_internal_request_id
        caller_request_id = ls_demand-request_id
        input_index       = lv_input_index
        required_date     = ls_demand-required_date
        priority          = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_internal_demand = ls_demand.
      ls_internal_demand-request_id = lv_internal_request_id.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_internal_demand ) TO lt_work.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_scope_index).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_index-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_scope_index-request_id
          storage_location = ls_request_location-storage_location )
          TO lt_int_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_rank_index).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_index-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_rank_index-request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    =
            ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      ADD 1 TO lv_allocation_sequence.
      READ TABLE lt_demand_indexes ASSIGNING FIELD-SYMBOL(<ls_demand_index>)
        WITH TABLE KEY request_id = ls_work-demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_index>-allocation_sequence = lv_allocation_sequence.
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
        allow_location_fallback =
          ls_work-demand-allow_location_fallback
        batch                   = ls_work-demand-batch
        requested_quantity      = ls_work-demand-requested_quantity
        require_full_quantity   = ls_work-demand-require_full_quantity
        unit                    = ls_work-demand-unit
        fefo_as_of_date         = lv_fefo_as_of_date
        minimum_shelf_life_days =
          ls_work-demand-minimum_shelf_life_days
        require_known_expiry    = ls_work-demand-require_known_expiry
        allow_undated_batches   = ls_work-demand-allow_undated_batches
        minimum_coverage_pct    = ls_work-demand-minimum_coverage_pct )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_sorted_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    rs_result-request_locations = it_request_locations.

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
      ls_local_allocation-allocation-request_id =
        ls_allocation_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation          = ls_local_allocation
          required_date       = ls_allocation_index-required_date
          priority            = ls_allocation_index-priority
          allocation_sequence =
            ls_allocation_index-allocation_sequence ) )
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
      ls_local_split-batch_allocation-request_id =
        ls_split_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split               = ls_local_split
          required_date       = ls_split_index-required_date
          priority            = ls_split_index-priority
          allocation_sequence =
            ls_split_index-allocation_sequence ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-batch_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      lv_internal_request_id = |D{ sy-tabix }|.
      READ TABLE lt_demand_indexes INTO DATA(ls_assignment_index)
        WITH TABLE KEY request_id = lv_internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        required_date       = ls_demand-required_date
        priority            = ls_demand-priority
        allocation_sequence =
          ls_assignment_index-allocation_sequence )
        TO rs_result-wbs_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_fefo_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocation-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           = ls_allocation-allocation-material
        plant              = ls_allocation-allocation-plant
        base_unit          = ls_allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_fefo_by_date_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = preview_fefo_by_date(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = ls_allocation-required_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD get_project_atp_checks.
    DATA lv_group_quantity TYPE decfloat34.
    DATA lv_cumulative_quantity TYPE decfloat34.
    DATA lv_cumulative_mard_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    DATA lv_confirmed_quantity TYPE decfloat34.
    FIELD-SYMBOLS <ls_atp_check> TYPE
      zcl_stock_service=>ty_local_atp_check.

    LOOP AT it_demands INTO DATA(ls_demand).
      READ TABLE rt_checks ASSIGNING <ls_atp_check>
        WITH KEY material = ls_demand-material
                 plant = ls_demand-plant
                 base_unit = ls_demand-base_unit
                 check_date = ls_demand-required_date.
      IF sy-subrc = 0.
        lv_group_quantity =
          CONV decfloat34(
            <ls_atp_check>-allocated_base_quantity )
          + CONV decfloat34( ls_demand-allocated_quantity ).
        <ls_atp_check>-allocated_base_quantity =
          me->checked_stock_quantity(
            iv_quantity = lv_group_quantity ).
      ELSE.
        APPEND VALUE #(
          material                = ls_demand-material
          plant                   = ls_demand-plant
          base_unit               = ls_demand-base_unit
          check_date              = ls_demand-required_date
          allocated_base_quantity = ls_demand-allocated_quantity )
          TO rt_checks.
      ENDIF.
    ENDLOOP.

    SORT rt_checks BY material ASCENDING
                      plant ASCENDING
                      base_unit ASCENDING
                      check_date ASCENDING.
    LOOP AT rt_checks ASSIGNING <ls_atp_check>.
      IF sy-tabix = 1
          OR <ls_atp_check>-material <> lv_previous_material
          OR <ls_atp_check>-plant <> lv_previous_plant
          OR <ls_atp_check>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      lv_cumulative_quantity = lv_cumulative_quantity
        + CONV decfloat34(
          <ls_atp_check>-allocated_base_quantity ).
      lv_cumulative_mard_quantity = me->checked_stock_quantity(
        iv_quantity = lv_cumulative_quantity ).
      <ls_atp_check>-cumulative_base_quantity =
        lv_cumulative_mard_quantity.
      <ls_atp_check>-atp_result =
        mo_material_availability_api->check_availability(
          is_request = VALUE #(
            material           = <ls_atp_check>-material
            plant              = <ls_atp_check>-plant
            unit               = <ls_atp_check>-base_unit
            check_rule         = iv_check_rule
            required_date      = <ls_atp_check>-check_date
            requested_quantity = lv_cumulative_mard_quantity ) ).

      IF <ls_atp_check>-atp_result-is_check_relevant = abap_true.
        IF <ls_atp_check>-atp_result-is_fully_available = abap_true.
          <ls_atp_check>-confirmed_base_quantity =
            lv_cumulative_mard_quantity.
        ELSE.
          CLEAR lv_confirmed_quantity.
          LOOP AT <ls_atp_check>-atp_result-confirmation_lines
              INTO DATA(ls_confirmation).
            IF ls_confirmation-confirmed_quantity <= 0
                OR ls_confirmation-confirmed_date IS INITIAL
                OR ls_confirmation-confirmed_date
                  > <ls_atp_check>-check_date.
              CONTINUE.
            ENDIF.
            lv_confirmed_quantity = lv_confirmed_quantity
              + CONV decfloat34(
                ls_confirmation-confirmed_quantity ).
            IF lv_confirmed_quantity >= lv_cumulative_quantity.
              lv_confirmed_quantity = lv_cumulative_quantity.
              EXIT.
            ENDIF.
          ENDLOOP.
          <ls_atp_check>-confirmed_base_quantity =
            me->checked_stock_quantity(
              iv_quantity = lv_confirmed_quantity ).
        ENDIF.
        <ls_atp_check>-unconfirmed_base_quantity =
          lv_cumulative_quantity
          - <ls_atp_check>-confirmed_base_quantity.
      ENDIF.

      lv_previous_material = <ls_atp_check>-material.
      lv_previous_plant = <ls_atp_check>-plant.
      lv_previous_unit = <ls_atp_check>-base_unit.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_by_location.
    DATA lt_seen_requests TYPE ty_request_keys.
    DATA lt_seen_request_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_scoped_requests TYPE ty_request_keys.
    DATA lt_seen_priority TYPE ty_storage_location_set.
    DATA lt_allowed_locations TYPE ty_storage_location_set.
    DATA lt_prepared_demands TYPE ty_prepared_demands.
    DATA lt_stock_keys TYPE zif_project_stock_repository=>ty_keys.
    DATA lt_location_balances TYPE ty_location_balances.
    DATA lt_candidates TYPE ty_location_candidates.
    DATA lv_available_quantity TYPE decfloat34.
    DATA lv_effective_as_of_date TYPE d.
    DATA lv_on_hand_from_date TYPE d.
    DATA lv_allocation_sequence TYPE i.

    validate_required_date( iv_date = iv_as_of_date ).
    validate_excluded_reservations(
      it_excluded_reservations = it_excluded_reservations ).
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

    LOOP AT it_demands INTO DATA(ls_request_demand).
      IF ls_request_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_request_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_seen_requests[
            request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #( request_id = ls_request_location-request_id )
        INTO TABLE lt_scoped_requests.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_seen_requests[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_request_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-request_locations = it_request_locations.
    IF it_demands IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_coverage_demand).
      IF ls_coverage_demand-minimum_coverage_pct < 0
          OR ls_coverage_demand-minimum_coverage_pct > 100.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-wbs_element IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false )
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-allow_location_fallback <> abap_true
            AND ls_demand-allow_location_fallback <> abap_false )
          OR ( ls_demand-allow_location_fallback = abap_true
            AND ls_demand-storage_location IS INITIAL )
          OR ls_demand-batch IS NOT INITIAL
          OR ls_demand-fefo_as_of_date IS NOT INITIAL
          OR ls_demand-minimum_shelf_life_days <> 0
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_demand-storage_location ] ) )
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND line_exists( lt_scoped_requests[
              request_id = ls_demand-request_id ] )
            AND NOT line_exists( lt_seen_request_locations[
              request_id = ls_demand-request_id
              storage_location = ls_demand-storage_location ] ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_optional_date( iv_date = ls_demand-location_as_of_date ).
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
        allow_location_fallback = ls_demand-allow_location_fallback
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        base_quantity           = ls_conversion-base_quantity
        base_unit               = ls_conversion-base_unit
        location_as_of_date     = ls_demand-location_as_of_date
        minimum_coverage_pct    = ls_demand-minimum_coverage_pct )
        TO lt_prepared_demands.
      APPEND VALUE #(
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        allocation_sequence = lines( lt_prepared_demands ) )
        TO rs_result-wbs_assignments.
    ENDLOOP.

    LOOP AT it_projected_location_receipts
        INTO DATA(ls_projected_location_receipt).
      IF ls_projected_location_receipt-wbs_element IS INITIAL
          OR ls_projected_location_receipt-material IS INITIAL
          OR ls_projected_location_receipt-plant IS INITIAL
          OR ls_projected_location_receipt-storage_location IS INITIAL
          OR ls_projected_location_receipt-base_quantity <= 0
          OR NOT line_exists( it_demands[
            wbs_element = ls_projected_location_receipt-wbs_element
            material = ls_projected_location_receipt-material
            plant = ls_projected_location_receipt-plant ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date(
        iv_date = ls_projected_location_receipt-receipt_date ).
    ENDLOOP.

    DATA(lt_raw_project_stocks) = mo_repository->read_project_stocks(
      it_keys = lt_stock_keys ).
    DATA(lt_project_reservations) =
      mo_repository->read_project_reservations(
        it_keys                  = lt_stock_keys
        iv_required_through_date = iv_reservation_through_date ).
    DATA(ls_subtraction) = subtract_project_reservations(
      it_excluded_reservations    = it_excluded_reservations
      it_stocks                   = lt_raw_project_stocks
      it_reservations             = lt_project_reservations
      iv_batch_only               = abap_false
      iv_reservation_through_date = iv_reservation_through_date ).
    DATA(lt_project_stocks) = ls_subtraction-stocks.
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
                         storage_location = ls_project_stock-storage_location
                         available_from_date = lv_on_hand_from_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        DATA(lv_combined_quantity) =
          CONV decfloat34( <ls_location_balance>-remaining_quantity )
          + CONV decfloat34(
            ls_project_stock-unrestricted_quantity ).
        <ls_location_balance>-remaining_quantity =
          me->checked_stock_quantity(
            iv_quantity = lv_combined_quantity ).
      ENDIF.
    ENDLOOP.

    LOOP AT it_projected_location_receipts
        INTO ls_projected_location_receipt.
      INSERT VALUE #(
        material            = ls_projected_location_receipt-material
        plant               = ls_projected_location_receipt-plant
        wbs_element         = ls_projected_location_receipt-wbs_element
        storage_location    =
          ls_projected_location_receipt-storage_location
        available_from_date =
          ls_projected_location_receipt-receipt_date
        remaining_quantity  =
          ls_projected_location_receipt-base_quantity )
        INTO TABLE lt_location_balances.
      IF sy-subrc <> 0.
        READ TABLE lt_location_balances
          ASSIGNING FIELD-SYMBOL(<ls_proj_loc_balance>)
          WITH TABLE KEY material = ls_projected_location_receipt-material
                         plant = ls_projected_location_receipt-plant
                         wbs_element =
                           ls_projected_location_receipt-wbs_element
                         storage_location =
                           ls_projected_location_receipt-storage_location
                         available_from_date =
                           ls_projected_location_receipt-receipt_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        DATA(lv_combined_receipt_quantity) =
          CONV decfloat34(
            <ls_proj_loc_balance>-remaining_quantity )
          + CONV decfloat34(
            ls_projected_location_receipt-base_quantity ).
        <ls_proj_loc_balance>-remaining_quantity =
          me->checked_stock_quantity(
            iv_quantity = lv_combined_receipt_quantity ).
      ENDIF.
    ENDLOOP.

    LOOP AT lt_prepared_demands INTO DATA(ls_prepared_demand).
      ADD 1 TO lv_allocation_sequence.
      CLEAR lt_candidates.
      lv_effective_as_of_date = iv_as_of_date.
      IF ls_prepared_demand-location_as_of_date
          > lv_effective_as_of_date.
        lv_effective_as_of_date =
          ls_prepared_demand-location_as_of_date.
      ENDIF.
      DATA(lv_request_has_priorities) = abap_false.
      LOOP AT it_request_location_priorities
          TRANSPORTING NO FIELDS
          WHERE request_id = ls_prepared_demand-request_id.
        lv_request_has_priorities = abap_true.
        EXIT.
      ENDLOOP.
      LOOP AT lt_location_balances INTO DATA(ls_balance)
        WHERE material = ls_prepared_demand-material
          AND plant = ls_prepared_demand-plant
          AND wbs_element = ls_prepared_demand-wbs_element.
        IF ls_balance-available_from_date > lv_effective_as_of_date.
          CONTINUE.
        ENDIF.
        IF ls_prepared_demand-storage_location IS NOT INITIAL
            AND ls_prepared_demand-allow_location_fallback <> abap_true
            AND ls_balance-storage_location
              <> ls_prepared_demand-storage_location.
          CONTINUE.
        ENDIF.
        IF lt_allowed_locations IS NOT INITIAL
            AND NOT line_exists( lt_allowed_locations[
              storage_location = ls_balance-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF line_exists( lt_scoped_requests[
            request_id = ls_prepared_demand-request_id ] )
            AND NOT line_exists( lt_seen_request_locations[
              request_id = ls_prepared_demand-request_id
              storage_location = ls_balance-storage_location ] ).
          CONTINUE.
        ENDIF.

        DATA(lv_location_priority) = lines(
          it_storage_location_priority ) + 1.
        DATA(lv_request_ranked) = abap_false.
        IF lv_request_has_priorities = abap_true.
          CLEAR lv_location_priority.
          READ TABLE it_request_location_priorities
            INTO DATA(ls_location_priority_row)
            WITH KEY request_id = ls_prepared_demand-request_id
                     storage_location = ls_balance-storage_location.
          IF sy-subrc = 0.
            lv_location_priority = ls_location_priority_row-priority_rank.
            lv_request_ranked = abap_true.
          ENDIF.
        ELSE.
          READ TABLE it_storage_location_priority
            TRANSPORTING NO FIELDS
            WITH KEY table_line = ls_balance-storage_location.
          IF sy-subrc = 0.
            lv_location_priority = sy-tabix.
          ENDIF.
        ENDIF.
        APPEND VALUE #(
          material            = ls_balance-material
          plant               = ls_balance-plant
          wbs_element         = ls_balance-wbs_element
          storage_location    = ls_balance-storage_location
          available_from_date = ls_balance-available_from_date
          preferred_location  = xsdbool(
            ls_prepared_demand-allow_location_fallback = abap_true
            AND ls_prepared_demand-storage_location =
              ls_balance-storage_location )
          request_ranked      = lv_request_ranked
          location_priority   = lv_location_priority )
          TO lt_candidates.
      ENDLOOP.
      SORT lt_candidates BY preferred_location DESCENDING
                            request_ranked DESCENDING
                            location_priority ASCENDING
                            storage_location ASCENDING
                            available_from_date ASCENDING.

      DATA(ls_allocation) = VALUE zcl_stock_service=>ty_allocation(
        request_id           = ls_prepared_demand-request_id
        material             = ls_prepared_demand-material
        plant                = ls_prepared_demand-plant
        allocation_sequence  = lv_allocation_sequence
        requested_quantity   = ls_prepared_demand-base_quantity
        minimum_coverage_pct =
          ls_prepared_demand-minimum_coverage_pct ).
      CLEAR lv_available_quantity.
      LOOP AT lt_candidates INTO DATA(ls_candidate).
        READ TABLE lt_location_balances INTO DATA(ls_available_balance)
          WITH TABLE KEY material = ls_candidate-material
                         plant = ls_candidate-plant
                         wbs_element = ls_candidate-wbs_element
                         storage_location = ls_candidate-storage_location
                         available_from_date =
                           ls_candidate-available_from_date.
        IF sy-subrc = 0.
          lv_available_quantity = lv_available_quantity
            + CONV decfloat34(
              ls_available_balance-remaining_quantity ).
        ENDIF.
      ENDLOOP.
      ls_allocation-available_quantity = me->checked_stock_quantity(
        iv_quantity = lv_available_quantity ).

      DATA lv_remaining_quantity TYPE mard-labst.
      DATA lv_allocated_quantity TYPE mard-labst.
      lv_remaining_quantity = ls_prepared_demand-base_quantity.
      CLEAR lv_allocated_quantity.
      IF ( iv_require_full_quantity = abap_true
            OR ls_prepared_demand-require_full_quantity = abap_true )
          AND ls_prepared_demand-base_quantity
            > ls_allocation-available_quantity.
        ls_allocation-shortfall_quantity =
          ls_prepared_demand-base_quantity.
      ELSEIF lv_available_quantity <
          CONV decfloat34( ls_prepared_demand-base_quantity )
          AND lv_available_quantity * CONV decfloat34( 100 )
            < CONV decfloat34( ls_prepared_demand-base_quantity )
              * CONV decfloat34(
                ls_prepared_demand-minimum_coverage_pct ).
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
                           storage_location = ls_candidate-storage_location
                           available_from_date =
                             ls_candidate-available_from_date.
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
            available_from_date       =
              ls_candidate-available_from_date
            base_unit                 = ls_prepared_demand-base_unit
            source_unit               = ls_prepared_demand-unit
            allocated_source_quantity =
              ls_source_split-alternative_quantity
            allocation_sequence       = lv_allocation_sequence )
            TO rs_result-allocation-storage_allocations.
          SUBTRACT lv_split_quantity
            FROM <ls_alloc_balance>-remaining_quantity.
          SUBTRACT lv_split_quantity FROM lv_remaining_quantity.
          ADD lv_split_quantity TO lv_allocated_quantity.
        ENDLOOP.
        ls_allocation-allocated_quantity = lv_allocated_quantity.
        ls_allocation-shortfall_quantity = lv_remaining_quantity.
      ENDIF.
      ls_allocation-require_full_quantity = xsdbool(
        iv_require_full_quantity = abap_true
        OR ls_prepared_demand-require_full_quantity = abap_true ).
      ls_allocation-minimum_coverage_rejected = xsdbool(
        CONV decfloat34( ls_allocation-allocated_quantity )
          * CONV decfloat34( 100 )
          < CONV decfloat34( ls_prepared_demand-base_quantity )
            * CONV decfloat34(
              ls_prepared_demand-minimum_coverage_pct ) ).
      ls_allocation-allocation_outcome = COND #(
        WHEN ls_allocation-allocated_quantity =
            ls_prepared_demand-base_quantity
          THEN zif_stock_repository=>c_allocation_outcome_full
        WHEN ls_allocation-allocated_quantity > 0
          THEN zif_stock_repository=>c_allocation_outcome_partial
        ELSE zif_stock_repository=>c_allocation_outcome_none ).
      ls_allocation-allocation_coverage_pct =
        CONV zcl_stock_service=>ty_allocation_coverage_pct(
          CONV decfloat34( ls_allocation-allocated_quantity )
          * CONV decfloat34( 100 )
          / CONV decfloat34( ls_prepared_demand-base_quantity ) ).

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

  METHOD preview_by_location_priority.
    TYPES:
      BEGIN OF ty_indexed_demand,
        input_index TYPE i,
        demand      TYPE ty_priority_location_demand,
      END OF ty_indexed_demand,
      ty_indexed_demands TYPE STANDARD TABLE OF ty_indexed_demand
        WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_request_context,
        input_index         TYPE i,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE ty_wbs_element,
        priority            TYPE i,
      END OF ty_request_context,
      ty_request_contexts TYPE STANDARD TABLE OF ty_request_context
        WITH EMPTY KEY.
    DATA lt_indexed_demands TYPE ty_indexed_demands.
    DATA lt_contexts TYPE ty_request_contexts.
    DATA lt_base_demands TYPE ty_demands.
    DATA lt_base_location_priorities TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_base_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA ls_base_result TYPE ty_location_result.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    LOOP AT it_demands INTO DATA(ls_input_demand).
      IF ls_input_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = sy-tabix
        demand      = ls_input_demand )
        TO lt_indexed_demands.
    ENDLOOP.
    SORT lt_indexed_demands STABLE BY demand-priority DESCENDING.

    LOOP AT lt_indexed_demands INTO DATA(ls_indexed_demand).
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        wbs_element             = ls_indexed_demand-demand-wbs_element
        material                = ls_indexed_demand-demand-material
        plant                   = ls_indexed_demand-demand-plant
        storage_location        = ls_indexed_demand-demand-storage_location
        allow_location_fallback =
          ls_indexed_demand-demand-allow_location_fallback
        requested_quantity      =
          ls_indexed_demand-demand-requested_quantity
        require_full_quantity   =
          ls_indexed_demand-demand-require_full_quantity
        unit                    = ls_indexed_demand-demand-unit
        location_as_of_date     =
          ls_indexed_demand-demand-location_as_of_date
        minimum_coverage_pct    =
          ls_indexed_demand-demand-minimum_coverage_pct )
        TO lt_base_demands.
      APPEND VALUE #(
        input_index         = ls_indexed_demand-input_index
        internal_request_id = lv_internal_request_id
        request_id          = ls_indexed_demand-demand-request_id
        wbs_element         = ls_indexed_demand-demand-wbs_element
        priority            = ls_indexed_demand-demand-priority )
        TO lt_contexts.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_scope_context).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_context-request_id.
        APPEND VALUE #(
          request_id       = ls_scope_context-internal_request_id
          storage_location = ls_request_location-storage_location )
          TO lt_base_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_base_location_priorities.
      ENDLOOP.
    ENDLOOP.

    ls_base_result = preview_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_base_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_base_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_base_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    rs_result-request_locations = it_request_locations.
    SORT lt_contexts BY input_index ASCENDING.
    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_base_result-allocation-allocations
          INTO DATA(ls_allocation)
        WITH KEY allocation-request_id = ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_allocation-allocation-request_id = ls_context-request_id.
      ls_allocation-allocation-priority = ls_context-priority.
      APPEND VALUE #(
        allocation          = ls_allocation
        priority            = ls_context-priority
        allocation_sequence =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-allocations.

      LOOP AT ls_base_result-allocation-storage_allocations
          INTO DATA(ls_storage_split)
          WHERE storage_allocation-request_id =
            ls_context-internal_request_id.
        ls_storage_split-storage_allocation-request_id =
          ls_context-request_id.
        APPEND VALUE #(
          split               = ls_storage_split
          priority            = ls_context-priority
          allocation_sequence =
            ls_storage_split-allocation_sequence )
          TO rs_result-storage_allocations.
      ENDLOOP.

      APPEND VALUE #(
        request_id          = ls_context-request_id
        wbs_element         = ls_context-wbs_element
        priority            = ls_context-priority
        allocation_sequence =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-wbs_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_location_priority_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_by_location_priority(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_by_location_date.
    DATA lt_work TYPE ty_dated_location_works.
    DATA lt_sorted_demands TYPE ty_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocation_order TYPE ty_dated_location_allocation_orders.
    DATA lt_split_order TYPE ty_dated_location_split_orders.
    DATA ls_internal_demand TYPE ty_dated_location_demand.
    DATA lv_internal_request_id TYPE c LENGTH 30.
    DATA lv_input_index TYPE i.
    DATA lv_allocation_sequence TYPE i.

    LOOP AT it_demands INTO DATA(ls_demand).
      ADD 1 TO lv_input_index.
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_required_date( iv_date = ls_demand-required_date ).
      lv_internal_request_id = |D{ lv_input_index }|.
      INSERT VALUE #(
        request_id        = lv_internal_request_id
        caller_request_id = ls_demand-request_id
        input_index       = lv_input_index
        required_date     = ls_demand-required_date
        priority          = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_internal_demand = ls_demand.
      ls_internal_demand-request_id = lv_internal_request_id.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_internal_demand ) TO lt_work.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_scope_index).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_index-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_scope_index-request_id
          storage_location = ls_request_location-storage_location )
          TO lt_int_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      ADD 1 TO lv_allocation_sequence.
      READ TABLE lt_demand_indexes ASSIGNING FIELD-SYMBOL(<ls_demand_index>)
        WITH TABLE KEY request_id = ls_work-demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_index>-allocation_sequence = lv_allocation_sequence.
      APPEND VALUE #(
        request_id              = ls_work-demand-request_id
        wbs_element             = ls_work-demand-wbs_element
        material                = ls_work-demand-material
        plant                   = ls_work-demand-plant
        storage_location        = ls_work-demand-storage_location
        allow_location_fallback =
          ls_work-demand-allow_location_fallback
        requested_quantity      = ls_work-demand-requested_quantity
        require_full_quantity   = ls_work-demand-require_full_quantity
        unit                    = ls_work-demand-unit
        location_as_of_date     = ls_work-demand-required_date
        minimum_coverage_pct    = ls_work-demand-minimum_coverage_pct )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_sorted_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    rs_result-request_locations = it_request_locations.

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
      ls_local_allocation-allocation-request_id =
        ls_allocation_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation          = ls_local_allocation
          required_date       = ls_allocation_index-required_date
          priority            = ls_allocation_index-priority
          allocation_sequence =
            ls_allocation_index-allocation_sequence ) )
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
      ls_local_split-storage_allocation-request_id =
        ls_split_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split               = ls_local_split
          required_date       = ls_split_index-required_date
          priority            = ls_split_index-priority
          allocation_sequence = ls_split_index-allocation_sequence ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-storage_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      lv_internal_request_id = |D{ sy-tabix }|.
      READ TABLE lt_demand_indexes INTO DATA(ls_assignment_index)
        WITH TABLE KEY request_id = lv_internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        required_date       = ls_demand-required_date
        priority            = ls_demand-priority
        allocation_sequence =
          ls_assignment_index-allocation_sequence )
        TO rs_result-wbs_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_by_location_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocation-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           = ls_allocation-allocation-material
        plant              = ls_allocation-allocation-plant
        base_unit          = ls_allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_by_location_date_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = preview_by_location_date(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = ls_allocation-required_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_transfer_fefo.
    DATA lt_stock_demands TYPE ty_demands.

    validate_required_date( iv_date = iv_as_of_date ).
    validate_optional_date( iv_date = iv_reservation_through_date ).
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-source_wbs_element IS INITIAL
          OR ls_demand-destination_wbs_element IS INITIAL
          OR ls_demand-source_wbs_element
            = ls_demand-destination_wbs_element
          OR ls_demand-location_as_of_date IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        request_id              = ls_demand-request_id
        wbs_element             = ls_demand-source_wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        fefo_as_of_date         = ls_demand-fefo_as_of_date
        minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days
        require_known_expiry    = ls_demand-require_known_expiry
        allow_undated_batches   = ls_demand-allow_undated_batches
        minimum_coverage_pct    = ls_demand-minimum_coverage_pct )
        TO lt_stock_demands.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element = ls_demand-destination_wbs_element
        allocation_sequence     = lines( lt_stock_demands ) )
        TO rs_result-transfer_assignments.
    ENDLOOP.

    DATA(ls_stock_preview) = preview_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_stock_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-allocation = ls_stock_preview-allocation.
    rs_result-request_locations = ls_stock_preview-request_locations.
  ENDMETHOD.

  METHOD preview_transfer_fefo_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_transfer_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocation-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           = ls_allocation-allocation-material
        plant              = ls_allocation-allocation-plant
        base_unit          = ls_allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_transfer_fefo_priority.
    TYPES:
      BEGIN OF ty_indexed_demand,
        input_index TYPE i,
        demand      TYPE ty_priority_transfer_fefo_demand,
      END OF ty_indexed_demand,
      ty_indexed_demands TYPE STANDARD TABLE OF ty_indexed_demand
        WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_context,
        input_index             TYPE i,
        internal_request_id     TYPE c LENGTH 30,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        priority                TYPE i,
      END OF ty_transfer_context,
      ty_transfer_contexts TYPE STANDARD TABLE OF ty_transfer_context
        WITH EMPTY KEY.
    DATA lt_indexed_demands TYPE ty_indexed_demands.
    DATA lt_contexts TYPE ty_transfer_contexts.
    DATA lt_base_demands TYPE ty_transfer_demands.
    DATA lt_base_location_priorities TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_base_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA ls_base_result TYPE ty_transfer_result.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF iv_prioritize_by_date <> abap_true
        AND iv_prioritize_by_date <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_prioritize_by_date = abap_true.
      LOOP AT it_demands INTO DATA(ls_date_demand).
        IF ls_date_demand-fefo_as_of_date IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        validate_required_date(
          iv_date = ls_date_demand-fefo_as_of_date ).
      ENDLOOP.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_input_demand).
      IF ls_input_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = sy-tabix
        demand      = ls_input_demand )
        TO lt_indexed_demands.
    ENDLOOP.
    IF iv_prioritize_by_date = abap_true.
      SORT lt_indexed_demands STABLE BY
        demand-fefo_as_of_date ASCENDING demand-priority DESCENDING.
    ELSE.
      SORT lt_indexed_demands STABLE BY demand-priority DESCENDING.
    ENDIF.

    LOOP AT lt_indexed_demands INTO DATA(ls_indexed_demand).
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        source_wbs_element      =
          ls_indexed_demand-demand-source_wbs_element
        destination_wbs_element =
          ls_indexed_demand-demand-destination_wbs_element
        material                = ls_indexed_demand-demand-material
        plant                   = ls_indexed_demand-demand-plant
        storage_location        =
          ls_indexed_demand-demand-storage_location
        allow_location_fallback =
          ls_indexed_demand-demand-allow_location_fallback
        batch                   = ls_indexed_demand-demand-batch
        requested_quantity      =
          ls_indexed_demand-demand-requested_quantity
        require_full_quantity   =
          ls_indexed_demand-demand-require_full_quantity
        unit                    = ls_indexed_demand-demand-unit
        fefo_as_of_date         =
          ls_indexed_demand-demand-fefo_as_of_date
        minimum_shelf_life_days =
          ls_indexed_demand-demand-minimum_shelf_life_days
        require_known_expiry    =
          ls_indexed_demand-demand-require_known_expiry
        allow_undated_batches   =
          ls_indexed_demand-demand-allow_undated_batches
        minimum_coverage_pct    =
          ls_indexed_demand-demand-minimum_coverage_pct )
        TO lt_base_demands.
      APPEND VALUE #(
        input_index             = ls_indexed_demand-input_index
        internal_request_id     = lv_internal_request_id
        request_id              = ls_indexed_demand-demand-request_id
        source_wbs_element      =
          ls_indexed_demand-demand-source_wbs_element
        destination_wbs_element =
          ls_indexed_demand-demand-destination_wbs_element
        priority                = ls_indexed_demand-demand-priority )
        TO lt_contexts.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_scope_context).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_context-request_id.
        APPEND VALUE #(
          request_id       = ls_scope_context-internal_request_id
          storage_location = ls_request_location-storage_location )
          TO lt_base_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_base_location_priorities.
      ENDLOOP.
    ENDLOOP.

    ls_base_result = preview_transfer_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_base_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_base_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_base_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-request_locations = it_request_locations.

    SORT lt_contexts BY input_index ASCENDING.
    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_base_result-allocation-allocations
          INTO DATA(ls_allocation)
        WITH KEY allocation-request_id = ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_allocation-allocation-request_id = ls_context-request_id.
      ls_allocation-allocation-priority = ls_context-priority.
      APPEND VALUE #(
        allocation          = ls_allocation
        priority            = ls_context-priority
        allocation_sequence =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-allocations.

      LOOP AT ls_base_result-allocation-batch_allocations
          INTO DATA(ls_batch_split)
          WHERE batch_allocation-request_id =
            ls_context-internal_request_id.
        ls_batch_split-batch_allocation-request_id =
          ls_context-request_id.
        APPEND VALUE #(
          split               = ls_batch_split
          priority            = ls_context-priority
          allocation_sequence =
            ls_batch_split-allocation_sequence )
          TO rs_result-batch_allocations.
      ENDLOOP.

      APPEND VALUE #(
        request_id              = ls_context-request_id
        source_wbs_element      = ls_context-source_wbs_element
        destination_wbs_element = ls_context-destination_wbs_element
        priority                = ls_context-priority
        allocation_sequence     =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-transfer_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_transfer_fefo_prio_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_transfer_fefo_priority(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_prioritize_by_date          = iv_prioritize_by_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_transfer_fefo_by_date.
    DATA lt_work TYPE ty_dated_transfer_works.
    DATA lt_sorted_demands TYPE ty_transfer_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocation_order TYPE ty_dated_allocation_orders.
    DATA lt_split_order TYPE ty_dated_split_orders.
    DATA ls_internal_demand TYPE ty_dated_transfer_demand.
    DATA lv_internal_request_id TYPE c LENGTH 30.
    DATA lv_input_index TYPE i.
    DATA lv_allocation_sequence TYPE i.

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
      lv_internal_request_id = |D{ lv_input_index }|.
      INSERT VALUE #(
        request_id        = lv_internal_request_id
        caller_request_id = ls_demand-request_id
        input_index       = lv_input_index
        required_date     = ls_demand-required_date
        priority          = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_internal_demand = ls_demand.
      ls_internal_demand-request_id = lv_internal_request_id.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_internal_demand ) TO lt_work.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_scope_index).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_index-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_scope_index-request_id
          storage_location = ls_request_location-storage_location )
          TO lt_int_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      ADD 1 TO lv_allocation_sequence.
      READ TABLE lt_demand_indexes ASSIGNING FIELD-SYMBOL(<ls_demand_index>)
        WITH TABLE KEY request_id = ls_work-demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_index>-allocation_sequence = lv_allocation_sequence.
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
        allow_location_fallback =
          ls_work-demand-allow_location_fallback
        batch                   = ls_work-demand-batch
        requested_quantity      = ls_work-demand-requested_quantity
        require_full_quantity   = ls_work-demand-require_full_quantity
        unit                    = ls_work-demand-unit
        fefo_as_of_date         = lv_fefo_as_of_date
        minimum_shelf_life_days =
          ls_work-demand-minimum_shelf_life_days
        require_known_expiry    =
          ls_work-demand-require_known_expiry
        allow_undated_batches   =
          ls_work-demand-allow_undated_batches
        minimum_coverage_pct    =
          ls_work-demand-minimum_coverage_pct )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_transfer_fefo(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_sorted_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-request_locations = it_request_locations.
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
      ls_local_allocation-allocation-request_id =
        ls_allocation_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation          = ls_local_allocation
          required_date       = ls_allocation_index-required_date
          priority            = ls_allocation_index-priority
          allocation_sequence =
            ls_allocation_index-allocation_sequence ) )
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
      ls_local_split-batch_allocation-request_id =
        ls_split_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split               = ls_local_split
          required_date       = ls_split_index-required_date
          priority            = ls_split_index-priority
          allocation_sequence = ls_split_index-allocation_sequence ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-batch_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      lv_internal_request_id = |D{ sy-tabix }|.
      READ TABLE lt_demand_indexes INTO DATA(ls_assignment_index)
        WITH TABLE KEY request_id = lv_internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element = ls_demand-destination_wbs_element
        required_date           = ls_demand-required_date
        priority                = ls_demand-priority
        allocation_sequence     =
          ls_assignment_index-allocation_sequence )
        TO rs_result-transfer_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_transfer_fefo_date_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = preview_transfer_fefo_by_date(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_batch_receipts    = it_projected_batch_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = ls_allocation-required_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
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
        request_id              = ls_demand-request_id
        wbs_element             = ls_demand-source_wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        location_as_of_date     = ls_demand-location_as_of_date
        minimum_coverage_pct    = ls_demand-minimum_coverage_pct )
        TO lt_stock_demands.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element = ls_demand-destination_wbs_element
        allocation_sequence     = lines( lt_stock_demands ) )
        TO rs_result-transfer_assignments.
    ENDLOOP.

    DATA(ls_stock_preview) = preview_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_stock_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-allocation = ls_stock_preview-allocation.
    rs_result-request_locations = ls_stock_preview-request_locations.
  ENDMETHOD.

  METHOD preview_transfer_loc_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_transfer_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocation-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           = ls_allocation-allocation-material
        plant              = ls_allocation-allocation-plant
        base_unit          = ls_allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_transfer_loc_priority.
    TYPES:
      BEGIN OF ty_indexed_demand,
        input_index TYPE i,
        demand      TYPE ty_priority_location_transfer_demand,
      END OF ty_indexed_demand,
      ty_indexed_demands TYPE STANDARD TABLE OF ty_indexed_demand
        WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_context,
        input_index             TYPE i,
        internal_request_id     TYPE c LENGTH 30,
        request_id              TYPE c LENGTH 30,
        source_wbs_element      TYPE ty_wbs_element,
        destination_wbs_element TYPE ty_wbs_element,
        priority                TYPE i,
      END OF ty_transfer_context,
      ty_transfer_contexts TYPE STANDARD TABLE OF ty_transfer_context
        WITH EMPTY KEY.
    DATA lt_indexed_demands TYPE ty_indexed_demands.
    DATA lt_contexts TYPE ty_transfer_contexts.
    DATA lt_base_demands TYPE ty_transfer_demands.
    DATA lt_base_location_priorities TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_base_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA ls_base_result TYPE ty_transfer_location_result.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    LOOP AT it_demands INTO DATA(ls_input_demand).
      IF ls_input_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index = sy-tabix
        demand      = ls_input_demand )
        TO lt_indexed_demands.
    ENDLOOP.
    SORT lt_indexed_demands STABLE BY demand-priority DESCENDING.

    LOOP AT lt_indexed_demands INTO DATA(ls_indexed_demand).
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        source_wbs_element      =
          ls_indexed_demand-demand-source_wbs_element
        destination_wbs_element =
          ls_indexed_demand-demand-destination_wbs_element
        material                = ls_indexed_demand-demand-material
        plant                   = ls_indexed_demand-demand-plant
        storage_location        =
          ls_indexed_demand-demand-storage_location
        allow_location_fallback =
          ls_indexed_demand-demand-allow_location_fallback
        requested_quantity      =
          ls_indexed_demand-demand-requested_quantity
        require_full_quantity   =
          ls_indexed_demand-demand-require_full_quantity
        unit                    = ls_indexed_demand-demand-unit
        location_as_of_date     =
          ls_indexed_demand-demand-location_as_of_date
        minimum_coverage_pct    =
          ls_indexed_demand-demand-minimum_coverage_pct )
        TO lt_base_demands.
      APPEND VALUE #(
        input_index             = ls_indexed_demand-input_index
        internal_request_id     = lv_internal_request_id
        request_id              = ls_indexed_demand-demand-request_id
        source_wbs_element      =
          ls_indexed_demand-demand-source_wbs_element
        destination_wbs_element =
          ls_indexed_demand-demand-destination_wbs_element
        priority                = ls_indexed_demand-demand-priority )
        TO lt_contexts.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_scope_context).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_context-request_id.
        APPEND VALUE #(
          request_id       = ls_scope_context-internal_request_id
          storage_location = ls_request_location-storage_location )
          TO lt_base_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_base_location_priorities.
      ENDLOOP.
    ENDLOOP.

    ls_base_result = preview_transfer_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_base_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_base_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_base_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-request_locations = it_request_locations.

    SORT lt_contexts BY input_index ASCENDING.
    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_base_result-allocation-allocations
          INTO DATA(ls_allocation)
        WITH KEY allocation-request_id = ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_allocation-allocation-request_id = ls_context-request_id.
      ls_allocation-allocation-priority = ls_context-priority.
      APPEND VALUE #(
        allocation          = ls_allocation
        priority            = ls_context-priority
        allocation_sequence =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-allocations.

      LOOP AT ls_base_result-allocation-storage_allocations
          INTO DATA(ls_storage_split)
          WHERE storage_allocation-request_id =
            ls_context-internal_request_id.
        ls_storage_split-storage_allocation-request_id =
          ls_context-request_id.
        APPEND VALUE #(
          split               = ls_storage_split
          priority            = ls_context-priority
          allocation_sequence =
            ls_storage_split-allocation_sequence )
          TO rs_result-storage_allocations.
      ENDLOOP.

      APPEND VALUE #(
        request_id              = ls_context-request_id
        source_wbs_element      = ls_context-source_wbs_element
        destination_wbs_element = ls_context-destination_wbs_element
        priority                = ls_context-priority
        allocation_sequence     =
          ls_allocation-allocation-allocation_sequence )
        TO rs_result-transfer_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_transfer_loc_prio_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.
    DATA lv_atp_check_date TYPE d.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lv_atp_check_date = sy-datum.
    IF iv_atp_check_date IS NOT INITIAL.
      validate_required_date( iv_date = iv_atp_check_date ).
      lv_atp_check_date = iv_atp_check_date.
    ENDIF.

    rs_result-local_estimate = preview_transfer_loc_priority(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = lv_atp_check_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD preview_transfer_location_date.
    DATA lt_work TYPE ty_dated_location_transfer_works.
    DATA lt_sorted_demands TYPE ty_transfer_demands.
    DATA lt_demand_indexes TYPE ty_dated_fefo_indexes.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE ty_request_locations.
    DATA lt_seen_request_locations TYPE HASHED TABLE OF
      ty_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocation_order TYPE ty_dated_location_allocation_orders.
    DATA lt_split_order TYPE ty_dated_location_split_orders.
    DATA ls_internal_demand TYPE ty_dated_location_transfer_demand.
    DATA lv_internal_request_id TYPE c LENGTH 30.
    DATA lv_input_index TYPE i.
    DATA lv_allocation_sequence TYPE i.

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
      lv_internal_request_id = |D{ lv_input_index }|.
      INSERT VALUE #(
        request_id        = lv_internal_request_id
        caller_request_id = ls_demand-request_id
        input_index       = lv_input_index
        required_date     = ls_demand-required_date
        priority          = ls_demand-priority )
        INTO TABLE lt_demand_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_internal_demand = ls_demand.
      ls_internal_demand-request_id = lv_internal_request_id.
      APPEND VALUE #(
        input_index   = lv_input_index
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = ls_internal_demand ) TO lt_work.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_seen_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_demand_indexes[
            caller_request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_scope_index).
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_scope_index-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_scope_index-request_id
          storage_location = ls_request_location-storage_location )
          TO lt_int_request_locations.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_demand_indexes INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-caller_request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    SORT lt_work BY required_date ASCENDING
                    priority DESCENDING
                    input_index ASCENDING.
    LOOP AT lt_work INTO DATA(ls_work).
      ADD 1 TO lv_allocation_sequence.
      READ TABLE lt_demand_indexes ASSIGNING FIELD-SYMBOL(<ls_demand_index>)
        WITH TABLE KEY request_id = ls_work-demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_index>-allocation_sequence = lv_allocation_sequence.
      APPEND VALUE #(
        request_id              = ls_work-demand-request_id
        source_wbs_element      = ls_work-demand-source_wbs_element
        destination_wbs_element =
          ls_work-demand-destination_wbs_element
        material                = ls_work-demand-material
        plant                   = ls_work-demand-plant
        storage_location        = ls_work-demand-storage_location
        allow_location_fallback =
          ls_work-demand-allow_location_fallback
        location_as_of_date     = ls_work-demand-required_date
        requested_quantity      = ls_work-demand-requested_quantity
        require_full_quantity   = ls_work-demand-require_full_quantity
        unit                    = ls_work-demand-unit
        minimum_coverage_pct    =
          ls_work-demand-minimum_coverage_pct )
        TO lt_sorted_demands.
    ENDLOOP.

    DATA(ls_local_result) = preview_transfer_by_location(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = lt_sorted_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-request_locations = it_request_locations.
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
      ls_local_allocation-allocation-request_id =
        ls_allocation_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_allocation_index-input_index
        result      = VALUE #(
          allocation          = ls_local_allocation
          required_date       = ls_allocation_index-required_date
          priority            = ls_allocation_index-priority
          allocation_sequence =
            ls_allocation_index-allocation_sequence ) )
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
      ls_local_split-storage_allocation-request_id =
        ls_split_index-caller_request_id.
      APPEND VALUE #(
        input_index = ls_split_index-input_index
        split_index = lv_split_index
        result      = VALUE #(
          split               = ls_local_split
          required_date       = ls_split_index-required_date
          priority            = ls_split_index-priority
          allocation_sequence = ls_split_index-allocation_sequence ) )
        TO lt_split_order.
    ENDLOOP.
    SORT lt_split_order BY input_index ASCENDING
                           split_index ASCENDING.
    LOOP AT lt_split_order INTO DATA(ls_split_order).
      APPEND ls_split_order-result TO rs_result-storage_allocations.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      lv_internal_request_id = |D{ sy-tabix }|.
      READ TABLE lt_demand_indexes INTO DATA(ls_assignment_index)
        WITH TABLE KEY request_id = lv_internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        source_wbs_element      = ls_demand-source_wbs_element
        destination_wbs_element =
          ls_demand-destination_wbs_element
        required_date           = ls_demand-required_date
        priority                = ls_demand-priority
        allocation_sequence     =
          ls_assignment_index-allocation_sequence )
        TO rs_result-transfer_assignments.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_transfer_loc_date_atp.
    DATA lt_atp_demands TYPE ty_project_atp_demands.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-local_estimate = preview_transfer_location_date(
      it_excluded_reservations       = it_excluded_reservations
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      it_projected_location_receipts = it_projected_location_receipts
      iv_as_of_date                  = iv_as_of_date
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    LOOP AT rs_result-local_estimate-allocations
        INTO DATA(ls_allocation).
      IF ls_allocation-allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material           =
          ls_allocation-allocation-allocation-material
        plant              = ls_allocation-allocation-allocation-plant
        base_unit          = ls_allocation-allocation-base_unit
        required_date      = ls_allocation-required_date
        allocated_quantity =
          ls_allocation-allocation-allocation-allocated_quantity )
        TO lt_atp_demands.
    ENDLOOP.

    rs_result-atp_checks = get_project_atp_checks(
      it_demands    = lt_atp_demands
      iv_check_rule = iv_check_rule ).
  ENDMETHOD.

  METHOD subtract_project_reservations.
    DATA lt_reservation_worklist TYPE ty_reservation_worklist.
    IF ( iv_batch_only <> abap_true AND iv_batch_only <> abap_false )
        OR ( iv_all_stock_types <> abap_true
          AND iv_all_stock_types <> abap_false )
        OR ( iv_collect_deductions <> abap_true
          AND iv_collect_deductions <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_subtraction-stocks = it_stocks.
    DELETE rs_subtraction-stocks WHERE storage_location IS INITIAL.
    IF iv_all_stock_types = abap_true.
      " Keep both stock types for a single combined reservation deduction.
    ELSEIF iv_batch_only = abap_true.
      DELETE rs_subtraction-stocks WHERE batch IS INITIAL.
    ELSE.
      DELETE rs_subtraction-stocks WHERE batch IS NOT INITIAL.
    ENDIF.
    SORT rs_subtraction-stocks BY material plant wbs_element
      storage_location batch.

    LOOP AT it_reservations INTO DATA(ls_reservation).
      IF line_exists( it_excluded_reservations[
          reservation_number = ls_reservation-reservation_number
          reservation_item = ls_reservation-reservation_item ] ).
        CONTINUE.
      ENDIF.
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

      DATA(lv_outstanding_quantity) =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_reservation-required_quantity
          iv_withdrawn_quantity = ls_reservation-withdrawn_quantity ).
      IF lv_outstanding_quantity <= 0.
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
        reservation_number   = ls_reservation-reservation_number
        reservation_item     = ls_reservation-reservation_item
        specificity          = lv_specificity
        outstanding_quantity = lv_outstanding_quantity )
        TO lt_reservation_worklist.
    ENDLOOP.

    SORT lt_reservation_worklist BY material plant wbs_element
      specificity storage_location batch reservation_number
      reservation_item.
    LOOP AT lt_reservation_worklist INTO DATA(ls_reservation_work).
      DATA(lv_remaining_quantity) =
        ls_reservation_work-outstanding_quantity.
      LOOP AT rs_subtraction-stocks ASSIGNING FIELD-SYMBOL(<ls_stock>)
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
        IF iv_collect_deductions = abap_true.
          APPEND VALUE #(
            material               = <ls_stock>-material
            plant                  = <ls_stock>-plant
            wbs_element            = <ls_stock>-wbs_element
            storage_location       = <ls_stock>-storage_location
            batch                  = <ls_stock>-batch
            reservation_number     = ls_reservation_work-reservation_number
            reservation_item       = ls_reservation_work-reservation_item
            reserved_quantity      = lv_deduction
            base_reserved_quantity = lv_deduction )
            TO rs_subtraction-stock_reservation_deductions.
        ENDIF.
        lv_remaining_quantity = lv_remaining_quantity - lv_deduction.
        IF lv_remaining_quantity <= 0.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_remaining_quantity <= 0.
        CONTINUE.
      ENDIF.

      LOOP AT rs_subtraction-stocks ASSIGNING <ls_stock>
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
        IF iv_collect_deductions = abap_true.
          APPEND VALUE #(
            material               = <ls_stock>-material
            plant                  = <ls_stock>-plant
            wbs_element            = <ls_stock>-wbs_element
            storage_location       = <ls_stock>-storage_location
            batch                  = <ls_stock>-batch
            reservation_number     = ls_reservation_work-reservation_number
            reservation_item       = ls_reservation_work-reservation_item
            reserved_quantity      = lv_deduction
            base_reserved_quantity = lv_deduction )
            TO rs_subtraction-stock_reservation_deductions.
        ENDIF.
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
    DATA lv_project_stock TYPE decfloat34.
    DATA lv_reserved TYPE decfloat34.
    DATA lv_available TYPE decfloat34.
    DATA lv_shortfall TYPE decfloat34.
    lv_project_stock = CONV decfloat34(
      is_coverage-project_stock_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    lv_reserved = CONV decfloat34( is_coverage-reserved_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    lv_available = CONV decfloat34(
      is_coverage-available_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    lv_shortfall = CONV decfloat34( is_coverage-shortfall_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    TRY.
        rs_coverage-project_stock_quantity =
          CONV mspr-prlab( lv_project_stock ).
        rs_coverage-reserved_quantity = CONV mspr-prlab( lv_reserved ).
        rs_coverage-available_quantity =
          CONV mspr-prlab( lv_available ).
        rs_coverage-shortfall_quantity =
          CONV mspr-prlab( lv_shortfall ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
    IF ( is_coverage-project_stock_quantity <> 0
          AND rs_coverage-project_stock_quantity IS INITIAL )
        OR ( is_coverage-reserved_quantity <> 0
          AND rs_coverage-reserved_quantity IS INITIAL )
        OR ( is_coverage-available_quantity <> 0
          AND rs_coverage-available_quantity IS INITIAL )
        OR ( is_coverage-shortfall_quantity <> 0
          AND rs_coverage-shortfall_quantity IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    LOOP AT is_coverage-stock_details INTO DATA(ls_base_stock_detail).
      IF ls_base_stock_detail-base_unit <> is_unit_ratio-base_unit
          OR ls_base_stock_detail-unit <> is_unit_ratio-base_unit
          OR ls_base_stock_detail-base_project_stock_quantity <= 0
          OR ls_base_stock_detail-base_reserved_quantity < 0
          OR ls_base_stock_detail-base_available_quantity < 0
          OR ls_base_stock_detail-base_project_stock_quantity
            <> ls_base_stock_detail-base_reserved_quantity
              + ls_base_stock_detail-base_available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_stock_as_unit) = CONV decfloat34(
        ls_base_stock_detail-base_project_stock_quantity )
        * CONV decfloat34( is_unit_ratio-denominator )
        / CONV decfloat34( is_unit_ratio-numerator ).
      DATA(lv_available_stock_as_unit) = CONV decfloat34(
        ls_base_stock_detail-base_available_quantity )
        * CONV decfloat34( is_unit_ratio-denominator )
        / CONV decfloat34( is_unit_ratio-numerator ).
      DATA lv_stock_quantity_as_unit TYPE mspr-prlab.
      DATA lv_available_as_unit TYPE mspr-prlab.
      DATA lv_stock_reserved_as_unit TYPE mspr-prlab.
      TRY.
          lv_stock_quantity_as_unit = CONV mspr-prlab( lv_stock_as_unit ).
          lv_available_as_unit = CONV mspr-prlab(
            lv_available_stock_as_unit ).
          IF lv_stock_quantity_as_unit < lv_available_as_unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          lv_stock_reserved_as_unit = lv_stock_quantity_as_unit
            - lv_available_as_unit.
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
      IF ( ls_base_stock_detail-base_project_stock_quantity > 0
          AND lv_stock_quantity_as_unit IS INITIAL )
          OR ( ls_base_stock_detail-base_available_quantity > 0
            AND lv_available_as_unit IS INITIAL )
          OR ( ls_base_stock_detail-base_reserved_quantity > 0
            AND lv_stock_reserved_as_unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        storage_location            = ls_base_stock_detail-storage_location
        batch                       = ls_base_stock_detail-batch
        unit                        = iv_unit
        base_unit                   = ls_base_stock_detail-base_unit
        project_stock_quantity      = lv_stock_quantity_as_unit
        reserved_quantity           = lv_stock_reserved_as_unit
        available_quantity          = lv_available_as_unit
        base_project_stock_quantity =
          ls_base_stock_detail-base_project_stock_quantity
        base_reserved_quantity      =
          ls_base_stock_detail-base_reserved_quantity
        base_available_quantity     =
          ls_base_stock_detail-base_available_quantity )
        TO rs_coverage-stock_details.
    ENDLOOP.
    SORT rs_coverage-stock_details BY storage_location batch.
    LOOP AT is_coverage-stock_reservation_deductions
        INTO DATA(ls_base_stock_deduction).
      IF ls_base_stock_deduction-material
          <> is_coverage-material
          OR ls_base_stock_deduction-plant
            <> is_coverage-plant
          OR ls_base_stock_deduction-wbs_element
            <> is_coverage-wbs_element
          OR ls_base_stock_deduction-storage_location
            IS INITIAL
          OR ls_base_stock_deduction-reservation_number
            IS INITIAL
          OR ls_base_stock_deduction-reservation_item
            IS INITIAL
          OR NOT line_exists( is_coverage-open_reservation_keys[
            reservation_number =
              ls_base_stock_deduction-reservation_number
            reservation_item = ls_base_stock_deduction-reservation_item ] )
          OR NOT line_exists( is_coverage-stock_details[
            storage_location =
              ls_base_stock_deduction-storage_location
            batch = ls_base_stock_deduction-batch ] )
          OR ls_base_stock_deduction-unit
            <> is_unit_ratio-base_unit
          OR ls_base_stock_deduction-base_unit
            <> is_unit_ratio-base_unit
          OR ls_base_stock_deduction-base_reserved_quantity
            <= 0
          OR ls_base_stock_deduction-reserved_quantity
            <> ls_base_stock_deduction-base_reserved_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_stock_reservation_as_unit) = CONV decfloat34(
        ls_base_stock_deduction-base_reserved_quantity )
        * CONV decfloat34( is_unit_ratio-denominator )
        / CONV decfloat34( is_unit_ratio-numerator ).
      DATA lv_deduction_as_unit TYPE mspr-prlab.
      TRY.
          lv_deduction_as_unit = CONV mspr-prlab(
            lv_stock_reservation_as_unit ).
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
      IF lv_deduction_as_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        material               =
          ls_base_stock_deduction-material
        plant                  = ls_base_stock_deduction-plant
        wbs_element            =
          ls_base_stock_deduction-wbs_element
        storage_location       =
          ls_base_stock_deduction-storage_location
        batch                  = ls_base_stock_deduction-batch
        reservation_number     =
          ls_base_stock_deduction-reservation_number
        reservation_item       =
          ls_base_stock_deduction-reservation_item
        reserved_quantity      = lv_deduction_as_unit
        unit                   = iv_unit
        base_reserved_quantity =
          ls_base_stock_deduction-base_reserved_quantity
        base_unit              =
          ls_base_stock_deduction-base_unit )
        TO rs_coverage-stock_reservation_deductions.
    ENDLOOP.
    SORT rs_coverage-stock_reservation_deductions BY
      storage_location batch reservation_number reservation_item.
    rs_coverage-open_reservation_items =
      is_coverage-open_reservation_items.
    rs_coverage-open_reservation_keys =
      is_coverage-open_reservation_keys.
    rs_coverage-excluded_open_reservations =
      is_coverage-excluded_open_reservations.
    LOOP AT is_coverage-open_reservations
        INTO DATA(ls_base_reservation).
      IF ls_base_reservation-base_unit <> is_unit_ratio-base_unit
          OR ls_base_reservation-unit <> is_unit_ratio-base_unit
          OR ls_base_reservation-base_reserved_quantity <= 0
          OR ls_base_reservation-base_covered_quantity < 0
          OR ls_base_reservation-base_uncovered_quantity < 0
          OR ls_base_reservation-base_covered_quantity
            > ls_base_reservation-base_reserved_quantity
          OR ls_base_reservation-base_uncovered_quantity
            > ls_base_reservation-base_reserved_quantity
          OR CONV decfloat34(
            ls_base_reservation-base_covered_quantity )
            + CONV decfloat34(
              ls_base_reservation-base_uncovered_quantity )
            <> CONV decfloat34(
              ls_base_reservation-base_reserved_quantity ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(lv_reservation_as_unit) = CONV decfloat34(
        ls_base_reservation-base_reserved_quantity )
        * CONV decfloat34( is_unit_ratio-denominator )
        / CONV decfloat34( is_unit_ratio-numerator ).
      DATA(lv_uncovered_resv_as_unit) = CONV decfloat34(
        ls_base_reservation-base_uncovered_quantity )
        * CONV decfloat34( is_unit_ratio-denominator )
        / CONV decfloat34( is_unit_ratio-numerator ).
      DATA lv_reserved_as_unit TYPE mspr-prlab.
      DATA lv_covered_as_unit TYPE mspr-prlab.
      DATA lv_uncovered_as_unit TYPE mspr-prlab.
      TRY.
          lv_reserved_as_unit = CONV mspr-prlab( lv_reservation_as_unit ).
          lv_uncovered_as_unit = CONV mspr-prlab(
            lv_uncovered_resv_as_unit ).
          IF lv_uncovered_as_unit > lv_reserved_as_unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          lv_covered_as_unit = lv_reserved_as_unit
            - lv_uncovered_as_unit.
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
      IF lv_reserved_as_unit IS INITIAL
          OR ( ls_base_reservation-base_covered_quantity > 0
            AND lv_covered_as_unit IS INITIAL )
          OR ( ls_base_reservation-base_uncovered_quantity > 0
            AND lv_uncovered_as_unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        reservation_number        = ls_base_reservation-reservation_number
        reservation_item          = ls_base_reservation-reservation_item
        reserved_quantity         = lv_reserved_as_unit
        covered_quantity          = lv_covered_as_unit
        uncovered_quantity        = lv_uncovered_as_unit
        unit                      = iv_unit
        base_reserved_quantity    =
          ls_base_reservation-base_reserved_quantity
        base_covered_quantity     =
          ls_base_reservation-base_covered_quantity
        base_uncovered_quantity   =
          ls_base_reservation-base_uncovered_quantity
        base_unit                 = ls_base_reservation-base_unit
        source_open_quantity      = ls_base_reservation-source_open_quantity
        source_required_quantity  =
          ls_base_reservation-source_required_quantity
        source_withdrawn_quantity =
          ls_base_reservation-source_withdrawn_quantity
        source_unit               = ls_base_reservation-source_unit
        source_entry_unit         = ls_base_reservation-source_entry_unit
        required_date             = ls_base_reservation-required_date
        storage_location          = ls_base_reservation-storage_location
        batch                     = ls_base_reservation-batch )
        TO rs_coverage-open_reservations.
    ENDLOOP.
    rs_coverage-excluded_open_resv_items =
      is_coverage-excluded_open_resv_items.
    rs_coverage-excluded_reservations =
      is_coverage-excluded_reservations.
    rs_coverage-is_fully_covered = is_coverage-is_fully_covered.
  ENDMETHOD.
  METHOD convert_open_resv_to_unit.
    IF is_unit_ratio-is_successful <> abap_true
        OR is_unit_ratio-base_unit IS INITIAL
        OR is_unit_ratio-numerator <= 0
        OR is_unit_ratio-denominator <= 0
        OR is_reservation-unit <> is_unit_ratio-base_unit
        OR is_reservation-required_quantity <= 0
        OR is_reservation-withdrawn_quantity < 0
        OR is_reservation-open_quantity <= 0
        OR is_reservation-required_quantity
          <> is_reservation-withdrawn_quantity
            + is_reservation-open_quantity.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lv_open_as_unit) = CONV decfloat34(
      is_reservation-open_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    DATA(lv_withdrawn_as_unit) = CONV decfloat34(
      is_reservation-withdrawn_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    TRY.
        rs_reservation-open_quantity = CONV mspr-prlab(
          lv_open_as_unit ).
        rs_reservation-withdrawn_quantity = CONV mspr-prlab(
          lv_withdrawn_as_unit ).
        rs_reservation-required_quantity = CONV mspr-prlab(
          CONV decfloat34( rs_reservation-open_quantity )
          + CONV decfloat34( rs_reservation-withdrawn_quantity ) ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
    IF rs_reservation-open_quantity IS INITIAL
        OR ( is_reservation-withdrawn_quantity > 0
          AND rs_reservation-withdrawn_quantity IS INITIAL )
        OR rs_reservation-required_quantity
          <= rs_reservation-withdrawn_quantity.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_reservation-source_reservation = is_reservation.
    rs_reservation-requested_unit = iv_unit.
    rs_reservation-base_unit = is_unit_ratio-base_unit.
    rs_reservation-base_required_quantity =
      is_reservation-required_quantity.
    rs_reservation-base_withdrawn_quantity =
      is_reservation-withdrawn_quantity.
    rs_reservation-base_open_quantity = is_reservation-open_quantity.
  ENDMETHOD.

  METHOD convert_resv_item_to_unit.
    IF is_unit_ratio-is_successful <> abap_true
        OR is_unit_ratio-base_unit IS INITIAL
        OR is_unit_ratio-numerator <= 0
        OR is_unit_ratio-denominator <= 0
        OR is_reservation-unit <> is_unit_ratio-base_unit
        OR is_reservation-required_quantity < 0
        OR is_reservation-withdrawn_quantity < 0
        OR is_reservation-open_quantity < 0
        OR is_reservation-required_quantity
          <> is_reservation-withdrawn_quantity
            + is_reservation-open_quantity.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lv_open_as_unit) = CONV decfloat34(
      is_reservation-open_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    DATA(lv_withdrawn_as_unit) = CONV decfloat34(
      is_reservation-withdrawn_quantity )
      * CONV decfloat34( is_unit_ratio-denominator )
      / CONV decfloat34( is_unit_ratio-numerator ).
    TRY.
        rs_reservation-open_quantity = CONV mspr-prlab(
          lv_open_as_unit ).
        rs_reservation-withdrawn_quantity = CONV mspr-prlab(
          lv_withdrawn_as_unit ).
        rs_reservation-required_quantity = CONV mspr-prlab(
          CONV decfloat34( rs_reservation-open_quantity )
          + CONV decfloat34( rs_reservation-withdrawn_quantity ) ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
    IF ( is_reservation-open_quantity > 0
          AND rs_reservation-open_quantity IS INITIAL )
        OR ( is_reservation-withdrawn_quantity > 0
          AND rs_reservation-withdrawn_quantity IS INITIAL )
        OR ( is_reservation-required_quantity > 0
          AND rs_reservation-required_quantity IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_reservation-source_reservation = is_reservation.
    rs_reservation-requested_unit = iv_unit.
    rs_reservation-base_unit = is_unit_ratio-base_unit.
    rs_reservation-base_required_quantity =
      is_reservation-required_quantity.
    rs_reservation-base_withdrawn_quantity =
      is_reservation-withdrawn_quantity.
    rs_reservation-base_open_quantity = is_reservation-open_quantity.
  ENDMETHOD.

  METHOD checked_stock_quantity.
    TRY.
        rv_quantity = CONV mard-labst( iv_quantity ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD validate_excluded_reservations.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.

    LOOP AT it_excluded_reservations INTO DATA(ls_excluded_reservation).
      IF ls_excluded_reservation-reservation_number IS INITIAL
          OR ls_excluded_reservation-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_excluded_reservation INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
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
