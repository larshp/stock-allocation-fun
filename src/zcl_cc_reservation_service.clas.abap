CLASS zcl_cc_reservation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        material                  TYPE mard-matnr,
        plant                     TYPE mard-werks,
        storage_location          TYPE mard-lgort,
        batch                     TYPE mchb-charg,
        cost_center               TYPE bapi2093_res_head-costcenter,
        requested_quantity        TYPE mard-labst,
        source_unit               TYPE mara-meins,
        base_requested_quantity   TYPE mard-labst,
        base_unit                 TYPE mara-meins,
        available_quantity        TYPE mard-labst,
        allocated_quantity        TYPE mard-labst,
        shortfall_quantity        TYPE mard-labst,
        minimum_coverage_pct      TYPE p LENGTH 5 DECIMALS 2,
        minimum_coverage_rejected TYPE abap_bool,
        allocation_outcome        TYPE c LENGTH 1,
        allocation_coverage_pct   TYPE zcl_stock_service=>ty_allocation_coverage_pct,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
        storage_allocations       TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations         TYPE zcl_stock_service=>ty_batch_allocations,
        require_known_expiry      TYPE abap_bool,
        allow_undated_batches     TYPE abap_bool,
        fefo_as_of_date           TYPE d,
        reservation_number        TYPE bapi2093_res_key-reserv_no,
        messages                  TYPE zif_cc_reservation_api=>ty_messages,
        is_successful             TYPE abap_bool,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_preview_demand,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        cost_center           TYPE bapi2093_res_head-costcenter,
        priority              TYPE i,
        requested_quantity    TYPE mard-labst,
        unit                  TYPE mara-meins,
        require_full_quantity TYPE abap_bool,
        minimum_coverage_pct  TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_preview_demand.
    TYPES ty_preview_demands TYPE STANDARD TABLE OF ty_preview_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        priority                  TYPE i,
        require_full_quantity     TYPE abap_bool,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_demand_preview.
    TYPES ty_demand_previews TYPE STANDARD TABLE OF ty_demand_preview
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_preview_demand,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        cost_center           TYPE bapi2093_res_head-costcenter,
        required_date         TYPE d,
        priority              TYPE i,
        requested_quantity    TYPE mard-labst,
        unit                  TYPE mara-meins,
        require_full_quantity TYPE abap_bool,
        minimum_coverage_pct  TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_dated_preview_demand.
    TYPES ty_dated_preview_demands TYPE STANDARD TABLE OF
      ty_dated_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        priority                  TYPE i,
        allocation_sequence       TYPE i,
        require_full_quantity     TYPE abap_bool,
        allocation                TYPE zcl_stock_service=>ty_date_unit_allocation,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_dated_demand_preview.
    TYPES ty_dated_demand_previews TYPE STANDARD TABLE OF
      ty_dated_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        priority                    TYPE i,
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
        require_full_quantity       TYPE abap_bool,
        minimum_coverage_pct        TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_location_preview_demand.
    TYPES ty_location_preview_demands TYPE STANDARD TABLE OF
      ty_location_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        priority                  TYPE i,
        require_full_quantity     TYPE abap_bool,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        storage_allocations       TYPE zcl_stock_service=>ty_unit_storage_splits,
        request_locations         TYPE zcl_stock_service=>ty_request_locations,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_location_demand_preview.
    TYPES ty_location_demand_previews TYPE STANDARD TABLE OF
      ty_location_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        required_date               TYPE d,
        priority                    TYPE i,
        requested_quantity          TYPE mard-labst,
        require_full_quantity       TYPE abap_bool,
        unit                        TYPE mara-meins,
        minimum_coverage_pct        TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_dated_location_preview_demand.
    TYPES ty_dated_location_preview_demands TYPE STANDARD TABLE OF
      ty_dated_location_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_location_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        required_date             TYPE d,
        priority                  TYPE i,
        allocation_sequence       TYPE i,
        require_full_quantity     TYPE abap_bool,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        storage_allocations       TYPE zcl_stock_service=>ty_dated_unit_location_splits,
        request_locations         TYPE zcl_stock_service=>ty_request_locations,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_dated_location_demand_preview.
    TYPES ty_dated_location_demand_previews TYPE STANDARD TABLE OF
      ty_dated_location_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        batch                       TYPE mchb-charg,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        required_date               TYPE d,
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
        priority                    TYPE i,
        require_full_quantity       TYPE abap_bool,
        minimum_shelf_life_days     TYPE i,
        require_known_expiry        TYPE abap_bool,
        allow_undated_batches       TYPE abap_bool,
        minimum_coverage_pct        TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_batch_preview_demand.
    TYPES ty_batch_preview_demands TYPE STANDARD TABLE OF
      ty_batch_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        selected_batch            TYPE mchb-charg,
        required_date             TYPE d,
        priority                  TYPE i,
        allocation_sequence       TYPE i,
        require_full_quantity     TYPE abap_bool,
        minimum_shelf_life_days   TYPE i,
        include_undated_batches   TYPE abap_bool,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        batch_allocations         TYPE zcl_stock_service=>ty_unit_batch_splits,
        request_locations         TYPE zcl_stock_service=>ty_request_locations,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_batch_demand_preview.
    TYPES ty_batch_demand_previews TYPE STANDARD TABLE OF
      ty_batch_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        batch                       TYPE mchb-charg,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        priority                    TYPE i,
        require_full_quantity       TYPE abap_bool,
        unit                        TYPE mara-meins,
        fefo_as_of_date             TYPE d,
        minimum_shelf_life_days     TYPE i,
        require_known_expiry        TYPE abap_bool,
        allow_undated_batches       TYPE abap_bool,
        minimum_coverage_pct        TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_fefo_preview_demand.
    TYPES ty_fefo_preview_demands TYPE STANDARD TABLE OF
      ty_fefo_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_fefo_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        batch                       TYPE mchb-charg,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        require_full_quantity       TYPE abap_bool,
        unit                        TYPE mara-meins,
        required_date               TYPE d,
        priority                    TYPE i,
        fefo_as_of_date             TYPE d,
        minimum_shelf_life_days     TYPE i,
        require_known_expiry        TYPE abap_bool,
        allow_undated_batches       TYPE abap_bool,
        minimum_coverage_pct        TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_dated_fefo_preview_demand.
    TYPES ty_dated_fefo_preview_demands TYPE STANDARD TABLE OF
      ty_dated_fefo_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        required_date             TYPE d,
        priority                  TYPE i,
        allocation_sequence       TYPE i,
        as_of_date                TYPE d,
        minimum_shelf_life_days   TYPE i,
        include_undated_batches   TYPE abap_bool,
        require_full_quantity     TYPE abap_bool,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        batch_allocations         TYPE zcl_stock_service=>ty_unit_batch_splits,
        request_locations         TYPE zcl_stock_service=>ty_request_locations,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_fefo_demand_preview.
    TYPES ty_fefo_demand_previews TYPE STANDARD TABLE OF
      ty_fefo_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_reservation_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        batch                       TYPE mchb-charg,
        required_date               TYPE d,
        fefo_as_of_date             TYPE d,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
        priority                    TYPE i,
        minimum_shelf_life_days     TYPE i,
        require_known_expiry        TYPE abap_bool,
        allow_undated_batches       TYPE abap_bool,
        minimum_coverage_pct        TYPE zcl_stock_service=>ty_minimum_coverage_pct,
      END OF ty_atomic_reservation_demand.
    TYPES ty_atomic_reservation_demands TYPE STANDARD TABLE OF
      ty_atomic_reservation_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_reservation_line,
        request_id                TYPE c LENGTH 30,
        required_date             TYPE d,
        priority                  TYPE i,
        allocation_sequence       TYPE i,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        storage_allocations       TYPE zcl_stock_service=>ty_unit_storage_splits,
        batch_allocations         TYPE zcl_stock_service=>ty_unit_batch_splits,
        request_locations         TYPE zcl_stock_service=>ty_request_locations,
        fefo_as_of_date           TYPE d,
        minimum_shelf_life_days   TYPE i,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
        reservation_result        TYPE zif_cc_reservation_api=>ty_result,
        is_committed              TYPE abap_bool,
      END OF ty_atomic_reservation_line.
    TYPES ty_atomic_reservation_lines TYPE STANDARD TABLE OF
      ty_atomic_reservation_line WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_reservation_item,
        request_id                TYPE c LENGTH 30,
        required_date             TYPE d,
        priority                  TYPE i,
        allocation_sequence       TYPE i,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        storage_allocations       TYPE zcl_stock_service=>ty_unit_storage_splits,
        batch_allocations         TYPE zcl_stock_service=>ty_unit_batch_splits,
        request_locations         TYPE zcl_stock_service=>ty_request_locations,
        fefo_as_of_date           TYPE d,
        minimum_shelf_life_days   TYPE i,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
        reservation_result        TYPE zif_cc_reservation_api=>ty_result,
        is_successful             TYPE abap_bool,
        is_committed              TYPE abap_bool,
        was_rolled_back           TYPE abap_bool,
        is_skipped                TYPE abap_bool,
      END OF ty_bulk_reservation_item.
    TYPES ty_bulk_reservation_items TYPE STANDARD TABLE OF
      ty_bulk_reservation_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_reservation_result,
        items              TYPE ty_bulk_reservation_items,
        messages           TYPE zif_cc_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
      END OF ty_bulk_reservation_result.
    TYPES:
      BEGIN OF ty_atomic_reservation_result,
        items           TYPE ty_atomic_reservation_lines,
        messages        TYPE zif_cc_reservation_api=>ty_messages,
        is_successful   TYPE abap_bool,
        is_test_run     TYPE abap_bool,
        was_rolled_back TYPE abap_bool,
      END OF ty_atomic_reservation_result.
    TYPES:
      BEGIN OF ty_delete_reservations_result,
        reservation_numbers TYPE
          zif_cc_reservation_api=>ty_reservation_numbers,
        messages            TYPE zif_cc_reservation_api=>ty_messages,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
        is_committed        TYPE abap_bool,
        was_rolled_back     TYPE abap_bool,
      END OF ty_delete_reservations_result.
    TYPES:
      BEGIN OF ty_bulk_delete_item,
        reservation_number TYPE
          zif_cc_reservation_api=>ty_reservation_number,
        messages           TYPE zif_cc_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_committed       TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_bulk_delete_item.
    TYPES ty_bulk_delete_items TYPE STANDARD TABLE OF ty_bulk_delete_item
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_read_result,
        request_id    TYPE c LENGTH 30,
        cost_center   TYPE rkpf-kostl,
        reservations  TYPE zif_cc_reservation_read_repo=>ty_reservations,
        messages      TYPE zif_cc_reservation_api=>ty_messages,
        is_successful TYPE abap_bool,
      END OF ty_reservation_read_result.
    TYPES ty_reservation_read_results TYPE STANDARD TABLE OF
      ty_reservation_read_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_read_request,
        request_id            TYPE c LENGTH 30,
        cost_center           TYPE rkpf-kostl,
        required_through_date TYPE resb-bdter,
      END OF ty_reservation_read_request.
    TYPES ty_reservation_read_requests TYPE STANDARD TABLE OF
      ty_reservation_read_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_reservation_read_result,
        items         TYPE ty_reservation_read_results,
        messages      TYPE zif_cc_reservation_api=>ty_messages,
        is_successful TYPE abap_bool,
      END OF ty_bulk_reservation_read_result.
    TYPES:
      BEGIN OF ty_item_delete_result,
        cost_center        TYPE rkpf-kostl,
        reservation_number TYPE resb-rsnum,
        item_numbers       TYPE
          zif_cc_reservation_api=>ty_reservation_item_numbers,
        messages           TYPE zif_cc_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_item_delete_result.
    TYPES:
      BEGIN OF ty_item_delete_request,
        cost_center        TYPE rkpf-kostl,
        reservation_number TYPE resb-rsnum,
        item_numbers       TYPE
          zif_cc_reservation_api=>ty_reservation_item_numbers,
      END OF ty_item_delete_request.
    TYPES ty_item_delete_requests TYPE STANDARD TABLE OF
      ty_item_delete_request WITH EMPTY KEY.
    TYPES ty_item_delete_results TYPE STANDARD TABLE OF
      ty_item_delete_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_item_delete_result,
        items              TYPE ty_item_delete_results,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
      END OF ty_bulk_item_delete_result.
    TYPES:
      BEGIN OF ty_bulk_delete_result,
        items              TYPE ty_bulk_delete_items,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
      END OF ty_bulk_delete_result.

    METHODS constructor
      IMPORTING
        io_stock_repository          TYPE REF TO zif_stock_repository
        io_reservation_api           TYPE REF TO zif_cc_reservation_api OPTIONAL
        io_uom_repository            TYPE REF TO zif_material_uom_repository OPTIONAL
        io_material_availability_api TYPE REF TO
          zif_material_availability_api OPTIONAL
        io_reservation_reader        TYPE REF TO zif_cc_reservation_read_repo
          OPTIONAL.

    METHODS read_cost_center_reservations
      IMPORTING
        iv_cost_center           TYPE rkpf-kostl
        iv_required_through_date TYPE resb-bdter OPTIONAL
      RETURNING
        VALUE(rs_result)         TYPE ty_reservation_read_result
      RAISING
        zcx_invalid_reservation.

    METHODS read_cc_reservations_bulk
      IMPORTING
        it_cost_centers          TYPE zif_cc_reservation_read_repo=>ty_cost_centers
        iv_required_through_date TYPE resb-bdter OPTIONAL
      RETURNING
        VALUE(rs_result)         TYPE ty_bulk_reservation_read_result
      RAISING
        zcx_invalid_reservation.

    METHODS read_cc_resv_requests_bulk
      IMPORTING
        it_requests      TYPE ty_reservation_read_requests
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_reservation_read_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_cc_reservation_items
      IMPORTING
        iv_cost_center        TYPE rkpf-kostl
        iv_reservation_number TYPE resb-rsnum
        it_item_numbers       TYPE
          zif_cc_reservation_api=>ty_reservation_item_numbers
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_item_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_reservation_items_bulk
      IMPORTING
        it_requests        TYPE ty_item_delete_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_item_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS preview_cost_center_demands
      IMPORTING
        it_demands                TYPE ty_preview_demands
        iv_protect_safety_stock   TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity  TYPE abap_bool DEFAULT abap_false
        iv_check_atp              TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule         TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_atp_check_date         TYPE d OPTIONAL
        iv_prioritize_by_priority TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)        TYPE ty_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_by_date
      IMPORTING
        it_demands                     TYPE ty_dated_preview_demands
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
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rt_previews)             TYPE ty_dated_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_locations
      IMPORTING
        it_demands                     TYPE ty_location_preview_demands
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_atp_check_date              TYPE d OPTIONAL
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)             TYPE ty_location_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cc_locations_by_date
      IMPORTING
        it_demands                     TYPE ty_dated_location_preview_demands
        it_projected_receipts          TYPE zcl_stock_service=>ty_dated_location_receipts
          OPTIONAL
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rt_previews)             TYPE ty_dated_location_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_batches
      IMPORTING
        it_demands                     TYPE ty_batch_preview_demands
        it_projected_batch_receipts    TYPE
          zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)             TYPE ty_batch_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cc_batches_by_date
      IMPORTING
        it_demands                     TYPE ty_batch_preview_demands
        it_projected_batch_receipts    TYPE
          zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)             TYPE ty_batch_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_fefo
      IMPORTING
        it_demands                     TYPE ty_fefo_preview_demands
        it_projected_batch_receipts    TYPE
          zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rt_previews)             TYPE ty_fefo_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_fefo_date
      IMPORTING
        it_demands                     TYPE ty_dated_fefo_preview_demands
        it_projected_batch_receipts    TYPE
          zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rt_previews)             TYPE ty_fefo_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cc_fefo_date_atomic
      IMPORTING
        it_demands                     TYPE ty_dated_fefo_preview_demands
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date             TYPE d DEFAULT sy-datum
        iv_fefo_min_days               TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation    TYPE abap_bool DEFAULT abap_false
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_atomic_reservation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cc_fefo_date_bulk
      IMPORTING
        it_demands                     TYPE ty_dated_fefo_preview_demands
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date             TYPE d DEFAULT sy-datum
        iv_fefo_min_days               TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation    TYPE abap_bool DEFAULT abap_false
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_bulk_reservation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cost_centers_atomic
      IMPORTING
        it_demands                     TYPE ty_atomic_reservation_demands
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_use_fefo_batches            TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date             TYPE d DEFAULT sy-datum
        iv_fefo_min_days               TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation    TYPE abap_bool DEFAULT abap_false
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_atomic_reservation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cc_atomic_by_date
      IMPORTING
        it_demands                     TYPE ty_atomic_reservation_demands
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_use_fefo_batches            TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date             TYPE d DEFAULT sy-datum
        iv_fefo_min_days               TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation    TYPE abap_bool DEFAULT abap_false
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_atomic_reservation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cc_bulk_by_date
      IMPORTING
        it_demands                     TYPE ty_atomic_reservation_demands
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_use_fefo_batches            TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date             TYPE d DEFAULT sy-datum
        iv_fefo_min_days               TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation    TYPE abap_bool DEFAULT abap_false
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_bulk_reservation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cost_centers_bulk
      IMPORTING
        it_demands                     TYPE ty_atomic_reservation_demands
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_use_fefo_batches            TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date             TYPE d DEFAULT sy-datum
        iv_fefo_min_days               TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation    TYPE abap_bool DEFAULT abap_false
        it_location_priority           TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_bulk_reservation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_reservations
      IMPORTING
        it_reservation_numbers TYPE
          zif_cc_reservation_api=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_delete_reservations_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_reservations_bulk
      IMPORTING
        it_reservation_numbers TYPE
          zif_cc_reservation_api=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS reserve_for_cost_center
      IMPORTING
        iv_material                  TYPE mard-matnr
        iv_plant                     TYPE mard-werks
        iv_storage_location          TYPE mard-lgort OPTIONAL
        iv_allow_fallback            TYPE abap_bool DEFAULT abap_false
        iv_cost_center               TYPE bapi2093_res_head-costcenter
        iv_requested_quantity        TYPE mard-labst
        iv_unit                      TYPE mara-meins
        iv_batch                     TYPE mchb-charg OPTIONAL
        iv_required_date             TYPE d DEFAULT sy-datum
        iv_use_fefo_batches          TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date           TYPE d DEFAULT sy-datum
        iv_fefo_min_days             TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_known_expiry      TYPE abap_bool DEFAULT abap_false
        iv_allow_undated_batches     TYPE abap_bool DEFAULT abap_false
        iv_batch_min_days            TYPE i DEFAULT 0
        iv_minimum_coverage_pct      TYPE zcl_stock_service=>ty_minimum_coverage_pct
          OPTIONAL
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
        iv_require_full_alloc        TYPE abap_bool DEFAULT abap_false
        iv_require_atp_confirmation  TYPE abap_bool DEFAULT abap_false
        iv_check_atp                 TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule            TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_stock_request.

    METHODS preview_for_cost_center
      IMPORTING
        iv_material                  TYPE mard-matnr
        iv_plant                     TYPE mard-werks
        iv_storage_location          TYPE mard-lgort OPTIONAL
        iv_allow_fallback            TYPE abap_bool DEFAULT abap_false
        iv_cost_center               TYPE bapi2093_res_head-costcenter
        iv_requested_quantity        TYPE mard-labst
        iv_unit                      TYPE mara-meins
        iv_batch                     TYPE mchb-charg OPTIONAL
        iv_required_date             TYPE d DEFAULT sy-datum
        iv_use_fefo_batches          TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date           TYPE d DEFAULT sy-datum
        iv_fefo_min_days             TYPE i DEFAULT 0
        iv_include_undated_batches   TYPE abap_bool DEFAULT abap_true
        iv_require_known_expiry      TYPE abap_bool DEFAULT abap_false
        iv_allow_undated_batches     TYPE abap_bool DEFAULT abap_false
        iv_batch_min_days            TYPE i DEFAULT 0
        iv_minimum_coverage_pct      TYPE zcl_stock_service=>ty_minimum_coverage_pct
          OPTIONAL
        iv_require_full_alloc        TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_check_atp                 TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule            TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_prepared_reservation,
        result  TYPE ty_result,
        request TYPE zif_cc_reservation_api=>ty_request,
      END OF ty_prepared_reservation.

    METHODS validate_reservation_read
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        it_reservations  TYPE zif_cc_reservation_read_repo=>ty_reservations
      RETURNING
        VALUE(rs_result) TYPE ty_reservation_read_result.

    METHODS check_batch_allocation_atp
      IMPORTING
        it_batch_allocations TYPE zcl_stock_service=>ty_unit_batch_splits
        iv_check_rule        TYPE zif_material_availability_api=>ty_check_rule
      RETURNING
        VALUE(rt_atp_checks) TYPE zcl_stock_service=>ty_local_atp_checks
      RAISING
        zcx_invalid_stock_request.

    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_reservation_api TYPE REF TO zif_cc_reservation_api.
    DATA mo_uom_repository TYPE REF TO zif_material_uom_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
    DATA mo_reservation_reader TYPE REF TO zif_cc_reservation_read_repo.

    METHODS prepare_reservation
      IMPORTING
        iv_material                  TYPE mard-matnr
        iv_plant                     TYPE mard-werks
        iv_storage_location          TYPE mard-lgort
        iv_location_supplied         TYPE abap_bool
        iv_allow_fallback            TYPE abap_bool
        iv_cost_center               TYPE bapi2093_res_head-costcenter
        iv_requested_quantity        TYPE mard-labst
        iv_unit                      TYPE mara-meins
        iv_batch                     TYPE mchb-charg
        iv_batch_supplied            TYPE abap_bool
        iv_required_date             TYPE d
        iv_use_fefo_batches          TYPE abap_bool
        iv_fefo_as_of_date           TYPE d
        iv_fefo_min_days             TYPE i
        iv_include_undated_batches   TYPE abap_bool
        iv_require_known_expiry      TYPE abap_bool
        iv_allow_undated_batches     TYPE abap_bool
        iv_batch_min_days            TYPE i
        iv_minimum_coverage_pct      TYPE zcl_stock_service=>ty_minimum_coverage_pct
        iv_require_full_alloc        TYPE abap_bool
        iv_protect_safety_stock      TYPE abap_bool
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
      RETURNING
        VALUE(rs_prepared)           TYPE ty_prepared_reservation
      RAISING
        zcx_invalid_reservation
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_cc_reservation_service IMPLEMENTATION.

  METHOD constructor.
    IF io_reservation_reader IS BOUND.
      mo_reservation_reader = io_reservation_reader.
    ELSE.
      mo_reservation_reader = NEW zcl_cc_reservation_read_repo( ).
    ENDIF.

    IF io_reservation_api IS BOUND.
      mo_reservation_api = io_reservation_api.
    ELSE.
      mo_reservation_api = NEW zcl_bapi_cc_reservation( ).
    ENDIF.

    IF io_uom_repository IS BOUND.
      mo_uom_repository = io_uom_repository.
    ELSE.
      mo_uom_repository = NEW zcl_material_uom_repository( ).
    ENDIF.

    mo_uom_converter = NEW zcl_material_uom_converter(
      io_repository = mo_uom_repository ).

    mo_stock_service = NEW zcl_stock_service(
      io_stock_repository          = io_stock_repository
      io_uom_converter             = mo_uom_converter
      io_material_availability_api = io_material_availability_api ).
  ENDMETHOD.

  METHOD read_cost_center_reservations.
    DATA lt_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.

    IF iv_cost_center IS INITIAL
        OR ( iv_required_through_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_required_through_date ) <> abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    lt_reservations = mo_reservation_reader->get_open_reservations(
      iv_cost_center           = iv_cost_center
      iv_required_through_date = iv_required_through_date ).
    LOOP AT lt_reservations INTO DATA(ls_reservation)
        WHERE cost_center <> iv_cost_center.
      rs_result = validate_reservation_read(
        iv_cost_center  = iv_cost_center
        it_reservations = lt_reservations ).
      RETURN.
    ENDLOOP.
    IF iv_required_through_date IS NOT INITIAL.
      DELETE lt_reservations
        WHERE required_date IS NOT INITIAL
          AND required_date > iv_required_through_date.
    ENDIF.

    rs_result = validate_reservation_read(
      iv_cost_center  = iv_cost_center
      it_reservations = lt_reservations ).
  ENDMETHOD.

  METHOD read_cc_reservations_bulk.
    TYPES ty_seen_cost_center TYPE rkpf-kostl.
    TYPES:
      BEGIN OF ty_reservation_position,
        cost_center TYPE rkpf-kostl,
        row_number  TYPE i,
      END OF ty_reservation_position.
    TYPES ty_reservation_positions TYPE SORTED TABLE OF
      ty_reservation_position WITH UNIQUE KEY cost_center row_number.
    DATA lt_seen_cost_centers TYPE HASHED TABLE OF ty_seen_cost_center
      WITH UNIQUE KEY table_line.
    DATA lt_requested_cost_centers TYPE HASHED TABLE OF
      ty_seen_cost_center WITH UNIQUE KEY table_line.
    DATA lt_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.
    DATA lt_center_reservations TYPE
      zif_cc_reservation_read_repo=>ty_reservations.
    DATA lt_reservation_positions TYPE ty_reservation_positions.
    DATA lv_reservation_row_number TYPE i.
    DATA ls_center_reservation TYPE
      zif_cc_reservation_read_repo=>ty_reservation.

    rs_result-is_successful = abap_true.
    IF iv_required_through_date IS NOT INITIAL
        AND zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_required_through_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    IF it_cost_centers IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_cost_centers INTO DATA(lv_cost_center).
      INSERT lv_cost_center INTO TABLE lt_seen_cost_centers.
      IF lv_cost_center IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT lv_cost_center INTO TABLE lt_requested_cost_centers.
    ENDLOOP.

    lt_reservations = mo_reservation_reader->get_open_reservations_bulk(
      it_cost_centers          = it_cost_centers
      iv_required_through_date = iv_required_through_date ).

    LOOP AT lt_reservations INTO DATA(ls_returned_reservation).
      READ TABLE lt_requested_cost_centers TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line = ls_returned_reservation-cost_center.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Cost-center reservation reader returned an unrequested cost center' )
          TO rs_result-messages.
        rs_result-is_successful = abap_false.
        CLEAR rs_result-items.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_required_through_date IS NOT INITIAL.
      DELETE lt_reservations
        WHERE required_date IS NOT INITIAL
          AND required_date > iv_required_through_date.
    ENDIF.

    LOOP AT lt_reservations INTO ls_returned_reservation.
      lv_reservation_row_number = sy-tabix.
      IF lines( it_cost_centers ) > 1.
        INSERT VALUE #(
          cost_center = ls_returned_reservation-cost_center
          row_number  = lv_reservation_row_number )
          INTO TABLE lt_reservation_positions.
      ENDIF.
    ENDLOOP.

    LOOP AT it_cost_centers INTO lv_cost_center.
      CLEAR lt_center_reservations.
      IF lt_reservation_positions IS INITIAL.
        LOOP AT lt_reservations INTO ls_center_reservation
            WHERE cost_center = lv_cost_center.
          APPEND ls_center_reservation TO lt_center_reservations.
        ENDLOOP.
      ELSE.
        LOOP AT lt_reservation_positions INTO DATA(ls_reservation_position)
            WHERE cost_center = lv_cost_center.
          READ TABLE lt_reservations INTO ls_center_reservation
            INDEX ls_reservation_position-row_number.
          IF sy-subrc = 0.
            APPEND ls_center_reservation TO lt_center_reservations.
          ENDIF.
        ENDLOOP.
      ENDIF.

      DATA(ls_center_result) = validate_reservation_read(
        iv_cost_center  = lv_cost_center
        it_reservations = lt_center_reservations ).
      APPEND ls_center_result TO rs_result-items.
      IF ls_center_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_cc_resv_requests_bulk.
    TYPES ty_seen_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_cached_read,
        cost_center           TYPE rkpf-kostl,
        required_through_date TYPE resb-bdter,
        read_result           TYPE ty_reservation_read_result,
      END OF ty_cached_read,
      ty_cached_reads TYPE SORTED TABLE OF ty_cached_read
        WITH UNIQUE KEY cost_center required_through_date.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_seen_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_required_dates TYPE SORTED TABLE OF resb-bdter
      WITH UNIQUE KEY table_line.
    DATA lt_cost_centers TYPE zif_cc_reservation_read_repo=>ty_cost_centers.
    DATA lt_cached_reads TYPE ty_cached_reads.
    DATA lv_required_through_date TYPE resb-bdter.

    rs_result-is_successful = abap_true.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-cost_center IS INITIAL
          OR ( ls_request-required_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_request-required_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-required_through_date INTO TABLE lt_required_dates.
    ENDLOOP.

    LOOP AT lt_required_dates INTO lv_required_through_date.
      CLEAR lt_cost_centers.
      LOOP AT it_requests INTO ls_request
          WHERE required_through_date = lv_required_through_date.
        READ TABLE lt_cost_centers TRANSPORTING NO FIELDS
          WITH KEY table_line = ls_request-cost_center.
        IF sy-subrc <> 0.
          APPEND ls_request-cost_center TO lt_cost_centers.
        ENDIF.
      ENDLOOP.

      DATA(ls_group_result) = read_cc_reservations_bulk(
        it_cost_centers          = lt_cost_centers
        iv_required_through_date = lv_required_through_date ).
      APPEND LINES OF ls_group_result-messages TO rs_result-messages.

      LOOP AT lt_cost_centers INTO DATA(lv_cost_center).
        READ TABLE ls_group_result-items INTO DATA(ls_read_result)
          WITH KEY cost_center = lv_cost_center.
        IF sy-subrc <> 0.
          CLEAR ls_read_result.
          ls_read_result-cost_center = lv_cost_center.
          ls_read_result-is_successful = abap_false.
          ls_read_result-messages = ls_group_result-messages.
          IF ls_read_result-messages IS INITIAL.
            APPEND VALUE #(
              type    = 'E'
              message = 'Bulk cost-center reservation read omitted a requested center' )
              TO ls_read_result-messages.
          ENDIF.
        ENDIF.
        INSERT VALUE #(
          cost_center           = lv_cost_center
          required_through_date = lv_required_through_date
          read_result           = ls_read_result )
          INTO TABLE lt_cached_reads.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_cached_reads INTO DATA(ls_cached_read)
        WITH TABLE KEY cost_center           = ls_request-cost_center
                       required_through_date = ls_request-required_through_date.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(ls_request_result) = ls_cached_read-read_result.
      ls_request_result-request_id = ls_request-request_id.
      APPEND ls_request_result TO rs_result-items.
      IF ls_request_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_reservation_read.
    DATA lt_seen_items TYPE HASHED TABLE OF
      zif_cc_reservation_read_repo=>ty_reservation
      WITH UNIQUE KEY reservation_number reservation_item.

    rs_result-cost_center = iv_cost_center.
    rs_result-reservations = it_reservations.
    rs_result-is_successful = abap_true.

    LOOP AT rs_result-reservations INTO DATA(ls_reservation).
      IF ls_reservation-cost_center <> iv_cost_center
          OR ls_reservation-reservation_number IS INITIAL
          OR ls_reservation-reservation_item IS INITIAL
          OR ls_reservation-material IS INITIAL
          OR ls_reservation-plant IS INITIAL
          OR ls_reservation-unit IS INITIAL
          OR ls_reservation-required_quantity <= 0
          OR ls_reservation-withdrawn_quantity < 0
          OR ls_reservation-open_quantity <= 0
          OR CONV decfloat34( ls_reservation-open_quantity )
            + CONV decfloat34(
              ls_reservation-withdrawn_quantity ) <>
              CONV decfloat34(
                ls_reservation-required_quantity ).
        APPEND VALUE #(
          type    = 'E'
          message = 'Cost-center reservation reader returned invalid item data' )
          TO rs_result-messages.
        CLEAR rs_result-reservations.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.

      INSERT ls_reservation INTO TABLE lt_seen_items.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Cost-center reservation reader returned duplicate items' )
          TO rs_result-messages.
        CLEAR rs_result-reservations.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_cc_reservation_items.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA ls_read_result TYPE ty_reservation_read_result.

    IF iv_cost_center IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-cost_center = iv_cost_center.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    ls_read_result = read_cost_center_reservations(
      iv_cost_center = iv_cost_center ).
    IF ls_read_result-is_successful <> abap_true.
      rs_result-messages = ls_read_result-messages.
      RETURN.
    ENDIF.

    LOOP AT it_item_numbers INTO lv_item_number.
      READ TABLE ls_read_result-reservations TRANSPORTING NO FIELDS
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = lv_item_number.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_reservation_api->delete_reservation_items(
      iv_reservation_number = iv_reservation_number
      it_item_numbers       = it_item_numbers ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_reservation_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_reservation_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Selected reservation item deletion commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD delete_reservation_items_bulk.
    TYPES ty_seen_reservation TYPE resb-rsnum.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_item_delete_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-cost_center IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-cost_center = ls_request-cost_center.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = delete_cc_reservation_items(
            iv_cost_center        = ls_request-cost_center
            iv_reservation_number = ls_request-reservation_number
            it_item_numbers       = ls_request-item_numbers
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-cost_center = ls_request-cost_center.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_numbers = ls_request-item_numbers.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items are not open under this cost center and reservation' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT rs_result-items INTO DATA(ls_item_result).
      IF ls_item_result-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
      ELSEIF ls_item_result-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
      ELSE.
        ADD 1 TO rs_result-failed_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_demands.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_demands.
    DATA lt_priority_unit_demands TYPE
      zcl_stock_service=>ty_priority_unit_demands.
    DATA lt_allocations TYPE zcl_stock_service=>ty_unit_allocations.
    DATA ls_atp_result TYPE zcl_stock_service=>ty_unit_atp_result.
    DATA ls_priority_atp_result TYPE
      zcl_stock_service=>ty_priority_unit_atp_result.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_local_atp_check.

    IF ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_demands IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        request_id            = ls_demand-request_id
        material              = ls_demand-material
        plant                 = ls_demand-plant
        requested_quantity    = ls_demand-requested_quantity
        requested_unit        = ls_demand-unit
        require_full_quantity = ls_demand-require_full_quantity
        minimum_coverage_pct  = ls_demand-minimum_coverage_pct )
        TO lt_unit_demands.
      APPEND VALUE #(
        request_id            = ls_demand-request_id
        material              = ls_demand-material
        plant                 = ls_demand-plant
        priority              = ls_demand-priority
        requested_quantity    = ls_demand-requested_quantity
        requested_unit        = ls_demand-unit
        require_full_quantity = ls_demand-require_full_quantity
        minimum_coverage_pct  = ls_demand-minimum_coverage_pct )
        TO lt_priority_unit_demands.
    ENDLOOP.

    IF iv_prioritize_by_priority = abap_true
        AND iv_check_atp = abap_true.
      ls_priority_atp_result =
        mo_stock_service->allocate_demands_uom_atp_prio(
          it_demands               = lt_priority_unit_demands
          iv_check_rule            = iv_atp_check_rule
          iv_atp_check_date        = iv_atp_check_date
          iv_protect_safety_stock  = iv_protect_safety_stock
          iv_require_full_quantity = iv_require_full_quantity ).
      lt_allocations = ls_priority_atp_result-local_estimate.
      ls_atp_result-atp_checks = ls_priority_atp_result-atp_checks.
    ELSEIF iv_prioritize_by_priority = abap_true.
      lt_allocations = mo_stock_service->allocate_demands_uom_priority(
        it_demands               = lt_priority_unit_demands
        iv_protect_safety_stock  = iv_protect_safety_stock
        iv_require_full_quantity = iv_require_full_quantity ).
    ELSEIF iv_check_atp = abap_true.
      ls_atp_result = mo_stock_service->allocate_demands_uom_atp(
        it_demands               = lt_unit_demands
        iv_check_rule            = iv_atp_check_rule
        iv_atp_check_date        = iv_atp_check_date
        iv_protect_safety_stock  = iv_protect_safety_stock
        iv_require_full_quantity = iv_require_full_quantity ).
      lt_allocations = ls_atp_result-local_estimate.
    ELSE.
      lt_allocations = mo_stock_service->allocate_demands_in_units(
        it_demands               = lt_unit_demands
        iv_protect_safety_stock  = iv_protect_safety_stock
        iv_require_full_quantity = iv_require_full_quantity ).
    ENDIF.
    IF lines( lt_allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_allocations INTO DATA(ls_allocation) INDEX sy-tabix.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF iv_check_atp = abap_true.
        CLEAR ls_atp_check.
        READ TABLE ls_atp_result-atp_checks INTO ls_atp_check
          WITH KEY material = ls_allocation-allocation-material
                   plant = ls_allocation-allocation-plant
                   base_unit = ls_allocation-base_unit.
        IF sy-subrc <> 0
            AND ls_allocation-allocation-allocated_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          request_id                = ls_demand-request_id
          cost_center               = ls_demand-cost_center
          priority                  = ls_demand-priority
          require_full_quantity     = xsdbool(
            iv_require_full_quantity = abap_true
            OR ls_demand-require_full_quantity = abap_true )
          allocation                = ls_allocation
          cumulative_base_quantity  =
            ls_atp_check-cumulative_base_quantity
          confirmed_base_quantity   =
            ls_atp_check-confirmed_base_quantity
          unconfirmed_base_quantity =
            ls_atp_check-unconfirmed_base_quantity
          is_fully_confirmed        = ls_atp_check-is_fully_confirmed
          atp_result                = ls_atp_check-atp_result )
          TO rt_previews.
      ELSE.
        APPEND VALUE #(
          request_id            = ls_demand-request_id
          cost_center           = ls_demand-cost_center
          priority              = ls_demand-priority
          require_full_quantity = xsdbool(
            iv_require_full_quantity = abap_true
            OR ls_demand-require_full_quantity = abap_true )
          allocation            = ls_allocation )
          TO rt_previews.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_by_date.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_dated_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_date_unit_demands TYPE zcl_stock_service=>ty_date_unit_demands.
    DATA lt_allocations TYPE zcl_stock_service=>ty_date_unit_allocations.
    DATA lt_atp_allocations TYPE zcl_stock_service=>ty_date_unit_atp_allocations.

    IF ( iv_include_po_receipts <> abap_true
          AND iv_include_po_receipts <> abap_false )
        OR ( iv_include_sto_in_transit <> abap_true
          AND iv_include_sto_in_transit <> abap_false )
        OR ( iv_include_unissued_sto <> abap_true
          AND iv_include_unissued_sto <> abap_false )
        OR ( iv_subtract_unissued_sto <> abap_true
          AND iv_subtract_unissued_sto <> abap_false )
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
          AND iv_include_sched_agmt_receipts <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_demands IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id            = ls_demand-request_id
        material              = ls_demand-material
        plant                 = ls_demand-plant
        required_date         = ls_demand-required_date
        priority              = ls_demand-priority
        requested_quantity    = ls_demand-requested_quantity
        requested_unit        = ls_demand-unit
        require_full_quantity = ls_demand-require_full_quantity
        minimum_coverage_pct  = ls_demand-minimum_coverage_pct )
        TO lt_date_unit_demands.
    ENDLOOP.

    IF iv_check_atp = abap_true.
      lt_atp_allocations = mo_stock_service->allocate_date_demands_atp(
        it_demands                     = lt_date_unit_demands
        iv_check_rule                  = iv_atp_check_rule
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_subtract_unissued_sto       = iv_subtract_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       = iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_quantity ).
      IF lines( lt_atp_allocations ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ELSE.
      lt_allocations = mo_stock_service->allocate_date_demands_in_units(
        it_demands                     = lt_date_unit_demands
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_subtract_unissued_sto       = iv_subtract_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       = iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_quantity ).
      IF lines( lt_allocations ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      IF iv_check_atp = abap_true.
        READ TABLE lt_atp_allocations INTO DATA(ls_atp_allocation)
          INDEX sy-tabix.
        IF sy-subrc <> 0
            OR ls_atp_allocation-local_estimate-allocation-request_id
              <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          request_id                = ls_demand-request_id
          cost_center               = ls_demand-cost_center
          priority                  = ls_demand-priority
          require_full_quantity     = xsdbool(
            iv_require_full_quantity = abap_true
            OR ls_demand-require_full_quantity = abap_true )
          allocation                = ls_atp_allocation-local_estimate
          allocation_sequence       =
            ls_atp_allocation-local_estimate-allocation-allocation_sequence
          cumulative_base_quantity  =
            ls_atp_allocation-cumulative_base_quantity
          confirmed_base_quantity   =
            ls_atp_allocation-confirmed_base_quantity
          unconfirmed_base_quantity =
            ls_atp_allocation-unconfirmed_base_quantity
          is_fully_confirmed        = ls_atp_allocation-is_fully_confirmed
          atp_result                = ls_atp_allocation-atp_result )
          TO rt_previews.
      ELSE.
        READ TABLE lt_allocations INTO DATA(ls_allocation) INDEX sy-tabix.
        IF sy-subrc <> 0
            OR ls_allocation-allocation-request_id <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          request_id            = ls_demand-request_id
          cost_center           = ls_demand-cost_center
          priority              = ls_demand-priority
          require_full_quantity = xsdbool(
            iv_require_full_quantity = abap_true
            OR ls_demand-require_full_quantity = abap_true )
          allocation            = ls_allocation
          allocation_sequence   =
            ls_allocation-allocation-allocation_sequence )
          TO rt_previews.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_locations.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_location_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_location_demands.
    DATA lt_priority_unit_demands TYPE
      zcl_stock_service=>ty_priority_unit_location_demands.
    DATA ls_location_result TYPE zcl_stock_service=>ty_unit_location_result.
    DATA ls_priority_location_result TYPE
      zcl_stock_service=>ty_priority_unit_location_result.
    DATA ls_prio_loc_atp_result TYPE
      zcl_stock_service=>ty_priority_location_atp_result.
    DATA ls_location_atp_result TYPE zcl_stock_service=>ty_location_atp_result.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_local_atp_check.

    IF ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_demands IS INITIAL.
      IF it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        requested_unit              = ls_demand-unit
        require_full_quantity       = ls_demand-require_full_quantity
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_unit_demands.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        priority                    = ls_demand-priority
        requested_quantity          = ls_demand-requested_quantity
        requested_unit              = ls_demand-unit
        require_full_quantity       = ls_demand-require_full_quantity
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_priority_unit_demands.
    ENDLOOP.

    IF iv_prioritize_by_priority = abap_true.
      IF iv_check_atp = abap_true.
        ls_prio_loc_atp_result =
          mo_stock_service->allocate_location_uom_atp_prio(
            it_demands                     = lt_priority_unit_demands
            iv_check_rule                  = iv_atp_check_rule
            iv_atp_check_date              = iv_atp_check_date
            it_storage_location_priority   = it_location_priority
            it_request_location_priorities = it_request_location_priorities
            it_allowed_storage_locations   = it_allowed_storage_locations
            it_request_locations           = it_request_locations
            iv_protect_safety_stock        = iv_protect_safety_stock
            iv_require_full_quantity       = iv_require_full_quantity ).
        ls_location_atp_result-atp_checks =
          ls_prio_loc_atp_result-atp_checks.
        ls_priority_location_result =
          ls_prio_loc_atp_result-local_estimate.
      ELSE.
        ls_priority_location_result =
          mo_stock_service->allocate_location_uom_priority(
            it_demands                     = lt_priority_unit_demands
            it_storage_location_priority   = it_location_priority
            it_request_location_priorities = it_request_location_priorities
            it_allowed_storage_locations   = it_allowed_storage_locations
            it_request_locations           = it_request_locations
            iv_protect_safety_stock        = iv_protect_safety_stock
            iv_require_full_quantity       = iv_require_full_quantity ).
      ENDIF.
      ls_location_result-allocations =
        ls_priority_location_result-allocations.
      ls_location_result-request_locations =
        ls_priority_location_result-request_locations.
      LOOP AT ls_priority_location_result-storage_allocations
          INTO DATA(ls_priority_storage_allocation).
        APPEND ls_priority_storage_allocation-storage_split
          TO ls_location_result-storage_allocations.
      ENDLOOP.
    ELSEIF iv_check_atp = abap_true.
      ls_location_atp_result = mo_stock_service->allocate_by_location_atp(
        it_demands                     = lt_unit_demands
        iv_check_rule                  = iv_atp_check_rule
        iv_atp_check_date              = iv_atp_check_date
        it_storage_location_priority   = it_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_quantity ).
      ls_location_result = ls_location_atp_result-local_estimate.
    ELSE.
      ls_location_result = mo_stock_service->allocate_by_location_in_units(
        it_demands                     = lt_unit_demands
        it_storage_location_priority   = it_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_quantity ).
    ENDIF.
    IF lines( ls_location_result-allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_location_result-allocations
        INTO DATA(ls_allocation) INDEX sy-tabix.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_previews ASSIGNING
        FIELD-SYMBOL(<ls_preview>).
      <ls_preview>-request_id = ls_demand-request_id.
      <ls_preview>-cost_center = ls_demand-cost_center.
      <ls_preview>-priority = ls_demand-priority.
      <ls_preview>-require_full_quantity = xsdbool(
        iv_require_full_quantity = abap_true
        OR ls_demand-require_full_quantity = abap_true ).
      <ls_preview>-allocation = ls_allocation.
      IF iv_check_atp = abap_true.
        CLEAR ls_atp_check.
        READ TABLE ls_location_atp_result-atp_checks INTO ls_atp_check
          WITH KEY material = ls_allocation-allocation-material
                   plant = ls_allocation-allocation-plant
                   base_unit = ls_allocation-base_unit.
        IF sy-subrc <> 0
            AND ls_allocation-allocation-allocated_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_preview>-cumulative_base_quantity =
          ls_atp_check-cumulative_base_quantity.
        <ls_preview>-confirmed_base_quantity =
          ls_atp_check-confirmed_base_quantity.
        <ls_preview>-unconfirmed_base_quantity =
          ls_atp_check-unconfirmed_base_quantity.
        <ls_preview>-is_fully_confirmed =
          ls_atp_check-is_fully_confirmed.
        <ls_preview>-atp_result = ls_atp_check-atp_result.
      ENDIF.
      LOOP AT ls_location_result-storage_allocations
        INTO DATA(ls_storage_allocation).
        IF ls_storage_allocation-storage_allocation-request_id =
            ls_demand-request_id.
          APPEND ls_storage_allocation
            TO <ls_preview>-storage_allocations.
        ENDIF.
      ENDLOOP.
      LOOP AT it_request_locations INTO DATA(ls_request_location)
          WHERE request_id = ls_demand-request_id.
        APPEND ls_request_location TO <ls_preview>-request_locations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cc_locations_by_date.
    DATA lt_unique_demands TYPE HASHED TABLE OF
      ty_dated_location_preview_demand WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE
      zcl_stock_service=>ty_dated_unit_location_demands.
    DATA ls_location_result TYPE
      zcl_stock_service=>ty_dated_unit_location_result.
    DATA ls_location_atp_result TYPE
      zcl_stock_service=>ty_location_date_atp_result.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_local_atp_check.

    IF ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_demands IS INITIAL.
      IF it_request_locations IS NOT INITIAL
          OR it_projected_receipts IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      RETURN.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        required_date               = ls_demand-required_date
        priority                    = ls_demand-priority
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        requested_unit              = ls_demand-unit
        require_full_quantity       = ls_demand-require_full_quantity
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_unit_demands.
    ENDLOOP.

    IF iv_check_atp = abap_true.
      ls_location_atp_result = mo_stock_service->allocate_location_date_uom_atp(
        it_demands                     = lt_unit_demands
        it_projected_receipts          = it_projected_receipts
        iv_check_rule                  = iv_atp_check_rule
        it_storage_location_priority   = it_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_quantity ).
      ls_location_result = ls_location_atp_result-local_estimate.
    ELSE.
      ls_location_result = mo_stock_service->allocate_location_by_date_uom(
        it_demands                     = lt_unit_demands
        it_projected_receipts          = it_projected_receipts
        it_storage_location_priority   = it_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_quantity ).
    ENDIF.
    IF lines( ls_location_result-allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_location_result-allocations
        INTO DATA(ls_allocation)
        WITH KEY allocation-allocation-request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-allocation-request_id
            <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_previews ASSIGNING
        FIELD-SYMBOL(<ls_preview>).
      <ls_preview>-request_id = ls_demand-request_id.
      <ls_preview>-cost_center = ls_demand-cost_center.
      <ls_preview>-required_date = ls_demand-required_date.
      <ls_preview>-priority = ls_demand-priority.
      <ls_preview>-require_full_quantity = xsdbool(
        iv_require_full_quantity = abap_true
        OR ls_demand-require_full_quantity = abap_true ).
      <ls_preview>-allocation = ls_allocation-allocation.
      <ls_preview>-allocation_sequence =
        ls_allocation-allocation-allocation-allocation_sequence.
      LOOP AT ls_location_result-storage_allocations
          INTO DATA(ls_storage_allocation).
        IF ls_storage_allocation-storage_split-storage_allocation-request_id
            = ls_demand-request_id.
          ls_storage_allocation-allocation_sequence =
            <ls_preview>-allocation_sequence.
          ls_storage_allocation-storage_split-allocation_sequence =
            <ls_preview>-allocation_sequence.
          APPEND ls_storage_allocation
            TO <ls_preview>-storage_allocations.
        ENDIF.
      ENDLOOP.
      LOOP AT it_request_locations INTO DATA(ls_request_location)
          WHERE request_id = ls_demand-request_id.
        APPEND ls_request_location TO <ls_preview>-request_locations.
      ENDLOOP.

      IF iv_check_atp = abap_true
          AND ls_allocation-allocation-allocation-allocated_quantity > 0.
        CLEAR ls_atp_check.
        READ TABLE ls_location_atp_result-atp_checks INTO ls_atp_check
          WITH KEY material = ls_allocation-allocation-allocation-material
                   plant = ls_allocation-allocation-allocation-plant
                   base_unit = ls_allocation-allocation-base_unit
                   check_date = ls_demand-required_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_preview>-cumulative_base_quantity =
          ls_atp_check-cumulative_base_quantity.
        <ls_preview>-confirmed_base_quantity =
          ls_atp_check-confirmed_base_quantity.
        <ls_preview>-unconfirmed_base_quantity =
          ls_atp_check-unconfirmed_base_quantity.
        <ls_preview>-is_fully_confirmed =
          ls_atp_check-is_fully_confirmed.
        <ls_preview>-atp_result = ls_atp_check-atp_result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_batches.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_batch_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_sorted_demands TYPE ty_batch_preview_demands.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_batch_demands.
    DATA ls_batch_result TYPE zcl_stock_service=>ty_unit_batch_result.
    DATA lt_atp_checks TYPE zcl_stock_service=>ty_local_atp_checks.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_local_atp_check.
    DATA lv_atp_check_date TYPE d.

    IF ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_demands IS INITIAL.
      IF it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      RETURN.
    ENDIF.

    lt_sorted_demands = it_demands.
    IF iv_prioritize_by_priority = abap_true.
      SORT lt_sorted_demands STABLE BY priority DESCENDING.
    ENDIF.

    LOOP AT lt_sorted_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-batch IS INITIAL
          OR ( ls_demand-required_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_demand-required_date ) <> abap_true )
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-minimum_shelf_life_days < 0
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ( ls_demand-minimum_shelf_life_days > 0
            AND ls_demand-required_date IS INITIAL )
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-require_known_expiry <> abap_true
            AND ls_demand-require_known_expiry <> abap_false )
          OR ( ls_demand-allow_undated_batches <> abap_true
            AND ls_demand-allow_undated_batches <> abap_false )
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false )
          OR ( ls_demand-require_known_expiry = abap_true
            AND ls_demand-allow_undated_batches = abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        batch                       = ls_demand-batch
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        requested_unit              = ls_demand-unit
        require_full_quantity       = ls_demand-require_full_quantity
        as_of_date                  = ls_demand-required_date
        minimum_shelf_life_days     =
          ls_demand-minimum_shelf_life_days
        require_known_expiry        = ls_demand-require_known_expiry
        allow_undated_batches       = ls_demand-allow_undated_batches
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_unit_demands.
    ENDLOOP.

    ls_batch_result = mo_stock_service->allocate_by_batch_in_units(
      it_demands                     = lt_unit_demands
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_storage_location_priority   = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity ).
    IF lines( ls_batch_result-allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true.
      lt_atp_checks = check_batch_allocation_atp(
        it_batch_allocations = ls_batch_result-batch_allocations
        iv_check_rule        = iv_atp_check_rule ).
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_batch_result-allocations
        INTO DATA(ls_allocation)
        WITH KEY allocation-request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_previews ASSIGNING
        FIELD-SYMBOL(<ls_preview>).
      <ls_preview>-request_id = ls_demand-request_id.
      <ls_preview>-cost_center = ls_demand-cost_center.
      <ls_preview>-selected_batch = ls_demand-batch.
      <ls_preview>-required_date = ls_demand-required_date.
      <ls_preview>-priority = ls_demand-priority.
      <ls_preview>-require_full_quantity = xsdbool(
        iv_require_full_quantity = abap_true
        OR ls_demand-require_full_quantity = abap_true ).
      <ls_preview>-minimum_shelf_life_days =
        ls_demand-minimum_shelf_life_days.
      <ls_preview>-include_undated_batches = xsdbool(
        iv_include_undated_batches = abap_true
        OR ls_demand-allow_undated_batches = abap_true ).
      IF ls_demand-require_known_expiry = abap_true.
        <ls_preview>-include_undated_batches = abap_false.
      ENDIF.
      <ls_preview>-allocation = ls_allocation.
      LOOP AT ls_batch_result-batch_allocations INTO DATA(ls_batch_allocation).
        IF ls_batch_allocation-batch_allocation-request_id =
            ls_demand-request_id.
          APPEND ls_batch_allocation TO <ls_preview>-batch_allocations.
        ENDIF.
      ENDLOOP.
      IF iv_check_atp = abap_true
          AND <ls_preview>-batch_allocations IS NOT INITIAL.
        lv_atp_check_date =
          <ls_preview>-batch_allocations[ 1 ]-batch_allocation-as_of_date.
        IF lv_atp_check_date IS INITIAL.
          lv_atp_check_date = sy-datum.
        ENDIF.
        CLEAR ls_atp_check.
        READ TABLE lt_atp_checks INTO ls_atp_check
          WITH KEY material = ls_demand-material
                   plant = ls_demand-plant
                   base_unit = ls_allocation-base_unit
                   check_date = lv_atp_check_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_preview>-cumulative_base_quantity =
          ls_atp_check-cumulative_base_quantity.
        <ls_preview>-confirmed_base_quantity =
          ls_atp_check-confirmed_base_quantity.
        <ls_preview>-unconfirmed_base_quantity =
          ls_atp_check-unconfirmed_base_quantity.
        <ls_preview>-is_fully_confirmed =
          ls_atp_check-is_fully_confirmed.
        <ls_preview>-atp_result = ls_atp_check-atp_result.
      ENDIF.
      LOOP AT it_request_locations INTO DATA(ls_request_location)
          WHERE request_id = ls_demand-request_id.
        APPEND ls_request_location TO <ls_preview>-request_locations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cc_batches_by_date.
    TYPES:
      BEGIN OF ty_indexed_batch_demand,
        input_index         TYPE i,
        effective_date      TYPE d,
        allocation_sequence TYPE i,
        demand              TYPE ty_batch_preview_demand,
      END OF ty_indexed_batch_demand,
      ty_indexed_batch_demands TYPE STANDARD TABLE OF
        ty_indexed_batch_demand WITH EMPTY KEY.
    DATA lt_indexed_demands TYPE ty_indexed_batch_demands.
    DATA lt_sorted_demands TYPE ty_batch_preview_demands.
    DATA lt_sorted_previews TYPE ty_batch_demand_previews.
    DATA lv_allocation_sequence TYPE i.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-required_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        input_index    = sy-tabix
        effective_date = COND d(
          WHEN ls_demand-required_date IS INITIAL
            THEN sy-datum
          ELSE ls_demand-required_date )
        demand         = ls_demand )
        TO lt_indexed_demands.
    ENDLOOP.

    SORT lt_indexed_demands STABLE BY effective_date ASCENDING
      demand-priority DESCENDING.
    LOOP AT lt_indexed_demands ASSIGNING FIELD-SYMBOL(<ls_indexed_demand>).
      ADD 1 TO lv_allocation_sequence.
      <ls_indexed_demand>-allocation_sequence = lv_allocation_sequence.
      APPEND <ls_indexed_demand>-demand TO lt_sorted_demands.
    ENDLOOP.

    lt_sorted_previews = preview_cost_center_batches(
      it_demands                     = lt_sorted_demands
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_location_priority           = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_check_atp                   = iv_check_atp
      iv_atp_check_rule              = iv_atp_check_rule
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_prioritize_by_priority      = abap_false ).
    IF lines( lt_sorted_previews ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_sorted_previews INTO DATA(ls_preview)
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_indexed_demands INTO DATA(ls_indexed_demand)
        WITH KEY demand-request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_preview-allocation_sequence =
        ls_indexed_demand-allocation_sequence.
      ls_preview-allocation-allocation-allocation_sequence =
        ls_indexed_demand-allocation_sequence.
      LOOP AT ls_preview-batch_allocations
          ASSIGNING FIELD-SYMBOL(<ls_batch_split>).
        <ls_batch_split>-allocation_sequence =
          ls_indexed_demand-allocation_sequence.
      ENDLOOP.
      APPEND ls_preview TO rt_previews.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_fefo.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_fefo_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_sorted_demands TYPE ty_fefo_preview_demands.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_fefo_demands.
    DATA ls_fefo_result TYPE zcl_stock_service=>ty_unit_batch_result.
    DATA lt_atp_checks TYPE zcl_stock_service=>ty_local_atp_checks.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_local_atp_check.
    DATA lv_atp_check_date TYPE d.

    IF iv_as_of_date IS INITIAL
        OR iv_min_days < 0
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF zcl_date_validation=>is_valid_gregorian_date(
        iv_date = iv_as_of_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_demands IS INITIAL.
      IF it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      RETURN.
    ENDIF.

    lt_sorted_demands = it_demands.
    IF iv_prioritize_by_priority = abap_true.
      SORT lt_sorted_demands STABLE BY priority DESCENDING.
    ENDIF.

    LOOP AT lt_sorted_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-minimum_shelf_life_days < 0
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-require_full_quantity <> abap_true
            AND ls_demand-require_full_quantity <> abap_false )
          OR ( ls_demand-require_known_expiry <> abap_true
            AND ls_demand-require_known_expiry <> abap_false )
          OR ( ls_demand-allow_undated_batches <> abap_true
            AND ls_demand-allow_undated_batches <> abap_false )
          OR ( ls_demand-require_known_expiry = abap_true
            AND ls_demand-allow_undated_batches = abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-fefo_as_of_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-fefo_as_of_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        batch                       = ls_demand-batch
        plant                       = ls_demand-plant
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        require_full_quantity       = ls_demand-require_full_quantity
        requested_unit              = ls_demand-unit
        fefo_as_of_date             = ls_demand-fefo_as_of_date
        minimum_shelf_life_days     = ls_demand-minimum_shelf_life_days
        require_known_expiry        = ls_demand-require_known_expiry
        allow_undated_batches       = ls_demand-allow_undated_batches
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_unit_demands.
    ENDLOOP.

    ls_fefo_result = mo_stock_service->allocate_by_expiry_in_units(
      it_demands                     = lt_unit_demands
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_storage_location_priority   = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_min_days                    = iv_min_days
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity ).
    IF lines( ls_fefo_result-allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true.
      lt_atp_checks = check_batch_allocation_atp(
        it_batch_allocations = ls_fefo_result-batch_allocations
        iv_check_rule        = iv_atp_check_rule ).
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_fefo_result-allocations
        INTO DATA(ls_allocation)
        WITH KEY allocation-request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_previews ASSIGNING
        FIELD-SYMBOL(<ls_preview>).
      <ls_preview>-request_id = ls_demand-request_id.
      <ls_preview>-cost_center = ls_demand-cost_center.
      <ls_preview>-priority = ls_demand-priority.
      <ls_preview>-require_full_quantity = xsdbool(
        iv_require_full_quantity = abap_true
        OR ls_demand-require_full_quantity = abap_true ).
      <ls_preview>-as_of_date = iv_as_of_date.
      IF ls_demand-fefo_as_of_date > <ls_preview>-as_of_date.
        <ls_preview>-as_of_date = ls_demand-fefo_as_of_date.
      ENDIF.
      <ls_preview>-minimum_shelf_life_days = iv_min_days.
      IF ls_demand-minimum_shelf_life_days >
          <ls_preview>-minimum_shelf_life_days.
        <ls_preview>-minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days.
      ENDIF.
      <ls_preview>-include_undated_batches =
        iv_include_undated_batches.
      <ls_preview>-allocation = ls_allocation.
      LOOP AT ls_fefo_result-batch_allocations
        INTO DATA(ls_batch_allocation).
        IF ls_batch_allocation-batch_allocation-request_id =
            ls_demand-request_id.
          APPEND ls_batch_allocation TO <ls_preview>-batch_allocations.
        ENDIF.
      ENDLOOP.
      IF iv_check_atp = abap_true
          AND <ls_preview>-batch_allocations IS NOT INITIAL.
        lv_atp_check_date =
          <ls_preview>-batch_allocations[ 1 ]-batch_allocation-as_of_date.
        IF lv_atp_check_date IS INITIAL.
          lv_atp_check_date = <ls_preview>-as_of_date.
        ENDIF.
        CLEAR ls_atp_check.
        READ TABLE lt_atp_checks INTO ls_atp_check
          WITH KEY material = ls_demand-material
                   plant = ls_demand-plant
                   base_unit = ls_allocation-base_unit
                   check_date = lv_atp_check_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_preview>-cumulative_base_quantity =
          ls_atp_check-cumulative_base_quantity.
        <ls_preview>-confirmed_base_quantity =
          ls_atp_check-confirmed_base_quantity.
        <ls_preview>-unconfirmed_base_quantity =
          ls_atp_check-unconfirmed_base_quantity.
        <ls_preview>-is_fully_confirmed =
          ls_atp_check-is_fully_confirmed.
        <ls_preview>-atp_result = ls_atp_check-atp_result.
      ENDIF.
      LOOP AT it_request_locations INTO DATA(ls_preview_request_location)
          WHERE request_id = ls_demand-request_id.
        APPEND ls_preview_request_location
          TO <ls_preview>-request_locations.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_fefo_date.
    TYPES:
      BEGIN OF ty_request_sequence,
        request_id          TYPE c LENGTH 30,
        allocation_sequence TYPE i,
      END OF ty_request_sequence.
    TYPES ty_request_sequences TYPE STANDARD TABLE OF ty_request_sequence
      WITH EMPTY KEY.
    DATA lt_sorted_demands TYPE ty_dated_fefo_preview_demands.
    DATA lt_fefo_demands TYPE ty_fefo_preview_demands.
    DATA lt_sorted_previews TYPE ty_fefo_demand_previews.
    DATA lt_request_sequences TYPE ty_request_sequences.
    DATA lv_allocation_sequence TYPE i.
    DATA lv_effective_date TYPE d.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-fefo_as_of_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-fefo_as_of_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      lv_effective_date = ls_demand-required_date.
      IF ls_demand-fefo_as_of_date > lv_effective_date.
        lv_effective_date = ls_demand-fefo_as_of_date.
      ENDIF.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        batch                       = ls_demand-batch
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        require_full_quantity       = ls_demand-require_full_quantity
        unit                        = ls_demand-unit
        required_date               = ls_demand-required_date
        priority                    = ls_demand-priority
        fefo_as_of_date             = lv_effective_date
        minimum_shelf_life_days     = ls_demand-minimum_shelf_life_days
        require_known_expiry        = ls_demand-require_known_expiry
        allow_undated_batches       = ls_demand-allow_undated_batches
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_sorted_demands.
    ENDLOOP.

    SORT lt_sorted_demands STABLE BY required_date ASCENDING
      priority DESCENDING.
    LOOP AT lt_sorted_demands INTO ls_demand.
      ADD 1 TO lv_allocation_sequence.
      APPEND VALUE #(
        request_id          = ls_demand-request_id
        allocation_sequence = lv_allocation_sequence )
        TO lt_request_sequences.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        batch                       = ls_demand-batch
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        require_full_quantity       = ls_demand-require_full_quantity
        unit                        = ls_demand-unit
        fefo_as_of_date             = ls_demand-fefo_as_of_date
        minimum_shelf_life_days     = ls_demand-minimum_shelf_life_days
        require_known_expiry        = ls_demand-require_known_expiry
        allow_undated_batches       = ls_demand-allow_undated_batches
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_fefo_demands.
    ENDLOOP.

    lt_sorted_previews = preview_cost_center_fefo(
      it_demands                     = lt_fefo_demands
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_location_priority           = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_min_days                    = iv_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_quantity
      iv_check_atp                   = iv_check_atp
      iv_atp_check_rule              = iv_atp_check_rule ).
    IF lines( lt_sorted_previews ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_sorted_previews INTO DATA(ls_preview)
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_preview-required_date = ls_demand-required_date.
      ls_preview-priority = ls_demand-priority.
      READ TABLE lt_request_sequences INTO DATA(ls_request_sequence)
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_preview-allocation_sequence =
        ls_request_sequence-allocation_sequence.
      ls_preview-allocation-allocation-allocation_sequence =
        ls_request_sequence-allocation_sequence.
      LOOP AT ls_preview-batch_allocations
          ASSIGNING FIELD-SYMBOL(<ls_batch_split>).
        <ls_batch_split>-allocation_sequence =
          ls_request_sequence-allocation_sequence.
      ENDLOOP.
      APPEND ls_preview TO rt_previews.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_cc_fefo_date_atomic.
    TYPES:
      BEGIN OF ty_ordered_demand,
        required_date TYPE d,
        priority      TYPE i,
        demand        TYPE ty_atomic_reservation_demand,
      END OF ty_ordered_demand.
    TYPES ty_ordered_demands TYPE STANDARD TABLE OF ty_ordered_demand
      WITH EMPTY KEY.
    DATA lt_ordered_demands TYPE ty_ordered_demands.
    DATA lt_sorted_demands TYPE ty_atomic_reservation_demands.
    DATA lt_sorted_items TYPE ty_atomic_reservation_lines.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true
          OR ( ls_demand-fefo_as_of_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_demand-fefo_as_of_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = VALUE #(
          request_id                  = ls_demand-request_id
          material                    = ls_demand-material
          plant                       = ls_demand-plant
          cost_center                 = ls_demand-cost_center
          batch                       = ls_demand-batch
          required_date               = ls_demand-required_date
          fefo_as_of_date             = ls_demand-fefo_as_of_date
          storage_location            = ls_demand-storage_location
          fallback_to_other_locations =
            ls_demand-fallback_to_other_locations
          requested_quantity          = ls_demand-requested_quantity
          unit                        = ls_demand-unit
          priority                    = ls_demand-priority
          minimum_shelf_life_days     =
            ls_demand-minimum_shelf_life_days
          require_known_expiry        = ls_demand-require_known_expiry
          allow_undated_batches       = ls_demand-allow_undated_batches
          minimum_coverage_pct        = ls_demand-minimum_coverage_pct ) )
        TO lt_ordered_demands.
    ENDLOOP.

    SORT lt_ordered_demands STABLE BY required_date ASCENDING
      priority DESCENDING.
    LOOP AT lt_ordered_demands INTO DATA(ls_ordered_demand).
      APPEND ls_ordered_demand-demand TO lt_sorted_demands.
    ENDLOOP.

    rs_result = reserve_cost_centers_atomic(
      it_demands                     = lt_sorted_demands
      iv_test_run                    = iv_test_run
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_use_fefo_batches            = abap_true
      iv_fefo_as_of_date             = iv_fefo_as_of_date
      iv_fefo_min_days               = iv_fefo_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_check_atp                   = iv_check_atp
      iv_atp_check_rule              = iv_atp_check_rule
      iv_require_atp_confirmation    = iv_require_atp_confirmation
      it_location_priority           = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations ).

    lt_sorted_items = rs_result-items.
    LOOP AT lt_sorted_items ASSIGNING FIELD-SYMBOL(<ls_fefo_atomic_item>).
      DATA(lv_fefo_atomic_sequence) = sy-tabix.
      <ls_fefo_atomic_item>-allocation_sequence =
        lv_fefo_atomic_sequence.
      <ls_fefo_atomic_item>-allocation-allocation-allocation_sequence =
        lv_fefo_atomic_sequence.
      LOOP AT <ls_fefo_atomic_item>-storage_allocations
          ASSIGNING FIELD-SYMBOL(<ls_fefo_atomic_storage_split>).
        <ls_fefo_atomic_storage_split>-allocation_sequence =
          lv_fefo_atomic_sequence.
      ENDLOOP.
      LOOP AT <ls_fefo_atomic_item>-batch_allocations
          ASSIGNING FIELD-SYMBOL(<ls_fefo_atomic_batch_split>).
        <ls_fefo_atomic_batch_split>-allocation_sequence =
          lv_fefo_atomic_sequence.
      ENDLOOP.
    ENDLOOP.
    IF lines( lt_sorted_items ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    CLEAR rs_result-items.
    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_sorted_items INTO DATA(ls_sorted_item)
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_sorted_item-required_date = ls_demand-required_date.
      ls_sorted_item-priority = ls_demand-priority.
      APPEND ls_sorted_item TO rs_result-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_cc_fefo_date_bulk.
    TYPES:
      BEGIN OF ty_ordered_demand,
        required_date TYPE d,
        priority      TYPE i,
        demand        TYPE ty_atomic_reservation_demand,
      END OF ty_ordered_demand.
    TYPES ty_ordered_demands TYPE STANDARD TABLE OF ty_ordered_demand
      WITH EMPTY KEY.
    DATA lt_ordered_demands TYPE ty_ordered_demands.
    DATA lt_sorted_demands TYPE ty_atomic_reservation_demands.
    DATA lt_sorted_items TYPE ty_bulk_reservation_items.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true
          OR ( ls_demand-fefo_as_of_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_demand-fefo_as_of_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        required_date = ls_demand-required_date
        priority      = ls_demand-priority
        demand        = VALUE #(
          request_id                  = ls_demand-request_id
          material                    = ls_demand-material
          plant                       = ls_demand-plant
          cost_center                 = ls_demand-cost_center
          batch                       = ls_demand-batch
          required_date               = ls_demand-required_date
          fefo_as_of_date             = ls_demand-fefo_as_of_date
          storage_location            = ls_demand-storage_location
          fallback_to_other_locations =
            ls_demand-fallback_to_other_locations
          requested_quantity          = ls_demand-requested_quantity
          unit                        = ls_demand-unit
          priority                    = ls_demand-priority
          minimum_shelf_life_days     =
            ls_demand-minimum_shelf_life_days
          require_known_expiry        = ls_demand-require_known_expiry
          allow_undated_batches       = ls_demand-allow_undated_batches
          minimum_coverage_pct        = ls_demand-minimum_coverage_pct ) )
        TO lt_ordered_demands.
    ENDLOOP.

    SORT lt_ordered_demands STABLE BY required_date ASCENDING
      priority DESCENDING.
    LOOP AT lt_ordered_demands INTO DATA(ls_ordered_demand).
      APPEND ls_ordered_demand-demand TO lt_sorted_demands.
    ENDLOOP.

    rs_result = reserve_cost_centers_bulk(
      it_demands                     = lt_sorted_demands
      iv_test_run                    = iv_test_run
      iv_stop_on_failure             = iv_stop_on_failure
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_use_fefo_batches            = abap_true
      iv_fefo_as_of_date             = iv_fefo_as_of_date
      iv_fefo_min_days               = iv_fefo_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_check_atp                   = iv_check_atp
      iv_atp_check_rule              = iv_atp_check_rule
      iv_require_atp_confirmation    = iv_require_atp_confirmation
      it_location_priority           = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations ).

    lt_sorted_items = rs_result-items.
    LOOP AT lt_sorted_items ASSIGNING FIELD-SYMBOL(<ls_fefo_bulk_item>).
      DATA(lv_fefo_bulk_sequence) = sy-tabix.
      <ls_fefo_bulk_item>-allocation_sequence = lv_fefo_bulk_sequence.
      <ls_fefo_bulk_item>-allocation-allocation-allocation_sequence =
        lv_fefo_bulk_sequence.
      LOOP AT <ls_fefo_bulk_item>-storage_allocations
          ASSIGNING FIELD-SYMBOL(<ls_fefo_bulk_storage_split>).
        <ls_fefo_bulk_storage_split>-allocation_sequence =
          lv_fefo_bulk_sequence.
      ENDLOOP.
      LOOP AT <ls_fefo_bulk_item>-batch_allocations
          ASSIGNING FIELD-SYMBOL(<ls_fefo_bulk_batch_split>).
        <ls_fefo_bulk_batch_split>-allocation_sequence =
          lv_fefo_bulk_sequence.
      ENDLOOP.
    ENDLOOP.
    IF lines( lt_sorted_items ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    CLEAR rs_result-items.
    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_sorted_items INTO DATA(ls_sorted_item)
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_sorted_item-required_date = ls_demand-required_date.
      ls_sorted_item-priority = ls_demand-priority.
      APPEND ls_sorted_item TO rs_result-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_cost_centers_atomic.
    TYPES:
      BEGIN OF ty_atomic_atp_day,
        material                  TYPE mard-matnr,
        plant                     TYPE mard-werks,
        base_unit                 TYPE mara-meins,
        required_date             TYPE d,
        demand_quantity           TYPE mard-labst,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_fully_confirmed        TYPE abap_bool,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_atomic_atp_day.
    TYPES ty_atomic_atp_days TYPE STANDARD TABLE OF ty_atomic_atp_day
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_atomic_request,
        request_id TYPE c LENGTH 30,
        priority   TYPE i,
        request    TYPE zif_cc_reservation_api=>ty_request,
      END OF ty_prepared_atomic_request.
    TYPES ty_prepared_atomic_requests TYPE STANDARD TABLE OF
      ty_prepared_atomic_request WITH EMPTY KEY.
    DATA lt_unique_demands TYPE HASHED TABLE OF
      ty_atomic_reservation_demand WITH UNIQUE KEY request_id.
    DATA lt_seen_locations TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_location_demands TYPE ty_location_preview_demands.
    DATA lt_batch_demands TYPE ty_batch_preview_demands.
    DATA lt_fefo_demands TYPE ty_fefo_preview_demands.
    DATA lt_location_previews TYPE ty_location_demand_previews.
    DATA lt_batch_previews TYPE ty_batch_demand_previews.
    DATA lt_fefo_previews TYPE ty_fefo_demand_previews.
    DATA lt_api_requests TYPE ty_prepared_atomic_requests.
    DATA lt_atp_days TYPE ty_atomic_atp_days.
    DATA lt_reservation_numbers TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA ls_api_request TYPE zif_cc_reservation_api=>ty_request.
    DATA ls_api_result TYPE zif_cc_reservation_api=>ty_result.
    DATA lv_request_index TYPE i.
    DATA lv_has_shortfall TYPE abap_bool.
    DATA lv_batch_mode TYPE abap_bool.
    DATA lv_unbatched_mode TYPE abap_bool.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    DATA lv_atp_failure TYPE abap_bool.
    DATA lv_demand_fefo_as_of_date TYPE d.
    FIELD-SYMBOLS:
      <ls_atp_day>        TYPE ty_atomic_atp_day,
      <ls_atp_line>       TYPE ty_atomic_reservation_line,
      <ls_rollback_line>  TYPE ty_atomic_reservation_line.

    rs_result-is_test_run = iv_test_run.
    IF it_demands IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_use_fefo_batches <> abap_true
          AND iv_use_fefo_batches <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false )
        OR ( iv_require_atp_confirmation <> abap_true
          AND iv_require_atp_confirmation <> abap_false )
        OR iv_fefo_min_days < 0
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true )
        OR ( iv_use_fefo_batches = abap_true
          AND iv_fefo_as_of_date IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_require_atp_confirmation = abap_true
        AND iv_check_atp <> abap_true.
      APPEND VALUE #(
        type    = 'E'
        message = 'Full ATP confirmation requirement needs ATP checking' )
        TO rs_result-messages.
      RETURN.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_use_fefo_batches = abap_true
        AND zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_fefo_as_of_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_location_priority INTO DATA(lv_priority_location).
      IF lv_priority_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_priority_location INTO TABLE lt_seen_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
    CLEAR lt_seen_locations.
    LOOP AT it_allowed_storage_locations INTO DATA(lv_allowed_location).
      IF lv_allowed_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_allowed_location INTO TABLE lt_seen_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true
          OR ( ls_demand-fefo_as_of_date IS NOT INITIAL
            AND ( iv_use_fefo_batches <> abap_true
              OR zcl_date_validation=>is_valid_gregorian_date(
                iv_date = ls_demand-fefo_as_of_date ) <> abap_true ) )
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ls_demand-minimum_shelf_life_days < 0
          OR ( ls_demand-minimum_shelf_life_days > 0
            AND iv_use_fefo_batches <> abap_true
            AND ls_demand-batch IS INITIAL )
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-require_known_expiry <> abap_true
            AND ls_demand-require_known_expiry <> abap_false )
          OR ( ls_demand-allow_undated_batches <> abap_true
            AND ls_demand-allow_undated_batches <> abap_false )
          OR ( ls_demand-require_known_expiry = abap_true
            AND ls_demand-allow_undated_batches = abap_true )
          OR ( ( ls_demand-require_known_expiry = abap_true
              OR ls_demand-allow_undated_batches = abap_true )
            AND ls_demand-batch IS INITIAL
            AND iv_use_fefo_batches <> abap_true )
          OR ( ls_demand-fallback_to_other_locations = abap_true
            AND ls_demand-storage_location IS INITIAL )
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND it_allowed_storage_locations IS NOT INITIAL
            AND NOT line_exists( lt_seen_locations[
              table_line = ls_demand-storage_location ] ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-batch IS INITIAL.
        lv_unbatched_mode = abap_true.
      ELSE.
        lv_batch_mode = abap_true.
      ENDIF.
      CLEAR lv_demand_fefo_as_of_date.
      IF ls_demand-fefo_as_of_date > ls_demand-required_date.
        lv_demand_fefo_as_of_date = ls_demand-fefo_as_of_date.
      ELSE.
        lv_demand_fefo_as_of_date = ls_demand-required_date.
      ENDIF.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        unit                        = ls_demand-unit
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_location_demands.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        batch                       = ls_demand-batch
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        unit                        = ls_demand-unit
        required_date               = ls_demand-required_date
        priority                    = ls_demand-priority
        minimum_shelf_life_days     =
          ls_demand-minimum_shelf_life_days
        require_known_expiry        = ls_demand-require_known_expiry
        allow_undated_batches       = ls_demand-allow_undated_batches
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_batch_demands.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        batch                       = ls_demand-batch
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        unit                        = ls_demand-unit
        fefo_as_of_date             = lv_demand_fefo_as_of_date
        priority                    = ls_demand-priority
        minimum_shelf_life_days     = ls_demand-minimum_shelf_life_days
        require_known_expiry        = ls_demand-require_known_expiry
        allow_undated_batches       = ls_demand-allow_undated_batches
        minimum_coverage_pct        = ls_demand-minimum_coverage_pct )
        TO lt_fefo_demands.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_unique_demands[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF iv_use_fefo_batches <> abap_true
        AND lv_batch_mode = abap_true
        AND lv_unbatched_mode = abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_prioritize_by_priority = abap_true
        AND iv_use_fefo_batches <> abap_true
        AND ( lv_batch_mode <> abap_true
          OR lv_unbatched_mode = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_use_fefo_batches = abap_true.
      lt_fefo_previews = preview_cost_center_fefo(
        it_demands                   = lt_fefo_demands
        it_location_priority         = it_location_priority
      it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations = it_allowed_storage_locations
        it_request_locations         = it_request_locations
        iv_as_of_date                = iv_fefo_as_of_date
        iv_min_days                  = iv_fefo_min_days
        iv_protect_safety_stock      = iv_protect_safety_stock
        iv_include_undated_batches   = iv_include_undated_batches
        iv_prioritize_by_priority    = iv_prioritize_by_priority ).
      IF lines( lt_fefo_previews ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ELSEIF lv_batch_mode = abap_true.
      lt_batch_previews = preview_cost_center_batches(
        it_demands                   = lt_batch_demands
        it_location_priority         = it_location_priority
      it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations = it_allowed_storage_locations
        it_request_locations         = it_request_locations
        iv_protect_safety_stock      = iv_protect_safety_stock
        iv_include_undated_batches   = iv_include_undated_batches
        iv_prioritize_by_priority    = iv_prioritize_by_priority ).
      IF lines( lt_batch_previews ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ELSE.
      lt_location_previews = preview_cost_center_locations(
        it_demands                   = lt_location_demands
        it_location_priority         = it_location_priority
      it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations = it_allowed_storage_locations
        it_request_locations         = it_request_locations
        iv_protect_safety_stock      = iv_protect_safety_stock ).
      IF lines( lt_location_previews ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      lv_request_index = sy-tabix.
      APPEND INITIAL LINE TO rs_result-items
        ASSIGNING FIELD-SYMBOL(<ls_new_line>).
      <ls_new_line>-request_id = ls_demand-request_id.
      <ls_new_line>-required_date = ls_demand-required_date.
      <ls_new_line>-priority = ls_demand-priority.
      LOOP AT it_request_locations INTO DATA(ls_result_request_location)
          WHERE request_id = ls_demand-request_id.
        APPEND ls_result_request_location
          TO <ls_new_line>-request_locations.
      ENDLOOP.
      IF iv_use_fefo_batches = abap_true.
        READ TABLE lt_fefo_previews INTO DATA(ls_fefo_preview)
          INDEX lv_request_index.
        IF sy-subrc <> 0
            OR ls_fefo_preview-request_id <> ls_demand-request_id
            OR ls_fefo_preview-allocation-allocation-request_id
              <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_new_line>-allocation = ls_fefo_preview-allocation.
        <ls_new_line>-batch_allocations =
          ls_fefo_preview-batch_allocations.
        <ls_new_line>-fefo_as_of_date = ls_fefo_preview-as_of_date.
        <ls_new_line>-minimum_shelf_life_days =
          ls_fefo_preview-minimum_shelf_life_days.
      ELSEIF lv_batch_mode = abap_true.
        READ TABLE lt_batch_previews INTO DATA(ls_batch_preview)
          INDEX lv_request_index.
        IF sy-subrc <> 0
            OR ls_batch_preview-request_id <> ls_demand-request_id
            OR ls_batch_preview-allocation-allocation-request_id
              <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_new_line>-allocation = ls_batch_preview-allocation.
        <ls_new_line>-batch_allocations =
          ls_batch_preview-batch_allocations.
        <ls_new_line>-minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days.
      ELSE.
        READ TABLE lt_location_previews INTO DATA(ls_location_preview)
          INDEX lv_request_index.
        IF sy-subrc <> 0
            OR ls_location_preview-request_id <> ls_demand-request_id
            OR ls_location_preview-allocation-allocation-request_id
              <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_new_line>-allocation = ls_location_preview-allocation.
        <ls_new_line>-storage_allocations =
          ls_location_preview-storage_allocations.
      ENDIF.

      IF <ls_new_line>-allocation-shortfall_source_quantity > 0
          OR <ls_new_line>-allocation-base_quantity <= 0.
        lv_has_shortfall = abap_true.
        APPEND VALUE #(
          type    = 'E'
          message = 'Demand was not fully available for atomic reservation' )
          TO <ls_new_line>-reservation_result-messages.
      ENDIF.
      IF <ls_new_line>-storage_allocations IS INITIAL
          AND <ls_new_line>-batch_allocations IS INITIAL
          AND <ls_new_line>-allocation-allocated_source_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF lv_has_shortfall = abap_true.
      APPEND VALUE #(
        type    = 'E'
        message = 'Full demand unavailable; atomic reservations were not created' )
        TO rs_result-messages.
      LOOP AT rs_result-items ASSIGNING FIELD-SYMBOL(<ls_uncreated_line>).
        IF <ls_uncreated_line>-reservation_result-messages IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Atomic group was not created because a demand was short' )
            TO <ls_uncreated_line>-reservation_result-messages.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF iv_check_atp = abap_true.
      LOOP AT it_demands INTO ls_demand.
        lv_request_index = sy-tabix.
        READ TABLE rs_result-items INTO DATA(ls_atp_source)
          INDEX lv_request_index.
        IF sy-subrc <> 0
            OR ls_atp_source-request_id <> ls_demand-request_id
            OR ls_atp_source-allocation-base_unit IS INITIAL
            OR ls_atp_source-allocation-base_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
          WITH KEY material = ls_demand-material
                   plant = ls_demand-plant
                   base_unit = ls_atp_source-allocation-base_unit
                   required_date = ls_demand-required_date.
        IF sy-subrc = 0.
          ADD ls_atp_source-allocation-base_quantity
            TO <ls_atp_day>-demand_quantity.
        ELSE.
          APPEND VALUE #(
            material        = ls_demand-material
            plant           = ls_demand-plant
            base_unit       = ls_atp_source-allocation-base_unit
            required_date   = ls_demand-required_date
            demand_quantity = ls_atp_source-allocation-base_quantity )
            TO lt_atp_days.
        ENDIF.
      ENDLOOP.

      SORT lt_atp_days BY material plant base_unit required_date.
      LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
        IF sy-tabix = 1
            OR <ls_atp_day>-material <> lv_previous_material
            OR <ls_atp_day>-plant <> lv_previous_plant
            OR <ls_atp_day>-base_unit <> lv_previous_unit.
          CLEAR lv_cumulative_quantity.
        ENDIF.
        ADD <ls_atp_day>-demand_quantity TO lv_cumulative_quantity.
        <ls_atp_day>-cumulative_base_quantity = lv_cumulative_quantity.
        <ls_atp_day>-atp_result = mo_stock_service->check_atp_request(
          is_request = VALUE #(
            material           = <ls_atp_day>-material
            plant              = <ls_atp_day>-plant
            unit               = <ls_atp_day>-base_unit
            check_rule         = iv_atp_check_rule
            required_date      = <ls_atp_day>-required_date
            requested_quantity = lv_cumulative_quantity ) ).
        DATA(ls_atp_confirmation) =
          mo_stock_service->get_atp_confirmation_split(
            iv_requested_base_quantity = lv_cumulative_quantity
            iv_required_date           = <ls_atp_day>-required_date
            is_atp_result              = <ls_atp_day>-atp_result ).
        <ls_atp_day>-confirmed_base_quantity =
          ls_atp_confirmation-confirmed_base_quantity.
        <ls_atp_day>-unconfirmed_base_quantity =
          ls_atp_confirmation-unconfirmed_base_quantity.
        <ls_atp_day>-is_fully_confirmed = COND abap_bool(
          WHEN <ls_atp_day>-confirmed_base_quantity >=
              <ls_atp_day>-cumulative_base_quantity
            THEN abap_true
          ELSE abap_false ).
        IF iv_require_atp_confirmation = abap_true
            AND <ls_atp_day>-is_fully_confirmed <> abap_true.
          lv_atp_failure = abap_true.
        ENDIF.
        lv_previous_material = <ls_atp_day>-material.
        lv_previous_plant = <ls_atp_day>-plant.
        lv_previous_unit = <ls_atp_day>-base_unit.
      ENDLOOP.

      LOOP AT it_demands INTO ls_demand.
        lv_request_index = sy-tabix.
        READ TABLE rs_result-items ASSIGNING <ls_atp_line>
          INDEX lv_request_index.
        IF sy-subrc <> 0
            OR <ls_atp_line>-request_id <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        READ TABLE lt_atp_days INTO DATA(ls_atp_day)
          WITH KEY material = ls_demand-material
                   plant = ls_demand-plant
                   base_unit = <ls_atp_line>-allocation-base_unit
                   required_date = ls_demand-required_date.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_atp_line>-cumulative_base_quantity =
          ls_atp_day-cumulative_base_quantity.
        <ls_atp_line>-confirmed_base_quantity =
          ls_atp_day-confirmed_base_quantity.
        <ls_atp_line>-unconfirmed_base_quantity =
          ls_atp_day-unconfirmed_base_quantity.
        <ls_atp_line>-is_fully_confirmed =
          ls_atp_day-is_fully_confirmed.
        <ls_atp_line>-atp_result = ls_atp_day-atp_result.
      ENDLOOP.

      IF lv_atp_failure = abap_true.
        APPEND VALUE #(
          type    = 'E'
          message = 'Full cumulative ATP confirmation required; atomic reservations were not created' )
          TO rs_result-messages.
        LOOP AT rs_result-items ASSIGNING <ls_atp_line>.
          APPEND VALUE #(
            type    = 'E'
            message = 'Atomic group was not created because cumulative ATP confirmation was short' )
            TO <ls_atp_line>-reservation_result-messages.
        ENDLOOP.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      lv_request_index = sy-tabix.
      READ TABLE rs_result-items INTO DATA(ls_result_line)
        INDEX lv_request_index.
      IF sy-subrc <> 0
          OR ls_result_line-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR ls_api_request.
      ls_api_request-material = ls_demand-material.
      ls_api_request-plant = ls_demand-plant.
      ls_api_request-cost_center = ls_demand-cost_center.
      ls_api_request-required_date = ls_demand-required_date.
      LOOP AT ls_result_line-storage_allocations
        INTO DATA(ls_storage_split).
        IF ls_storage_split-storage_allocation-allocated_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF ls_storage_split-base_unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          storage_location =
            ls_storage_split-storage_allocation-storage_location
          quantity         =
            ls_storage_split-storage_allocation-allocated_quantity
          unit             = ls_storage_split-base_unit )
          TO ls_api_request-items.
      ENDLOOP.
      LOOP AT ls_result_line-batch_allocations
        INTO DATA(ls_batch_split).
        IF ls_batch_split-batch_allocation-allocated_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF ls_batch_split-base_unit IS INITIAL
            OR ls_batch_split-batch_allocation-batch IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          storage_location =
            ls_batch_split-batch_allocation-storage_location
          batch            = ls_batch_split-batch_allocation-batch
          quantity         =
            ls_batch_split-batch_allocation-allocated_quantity
          unit             = ls_batch_split-base_unit )
          TO ls_api_request-items.
      ENDLOOP.
      IF ls_api_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_demand-request_id
        priority   = ls_demand-priority
        request    = ls_api_request )
        TO lt_api_requests.
    ENDLOOP.

    IF iv_prioritize_by_priority = abap_true.
      SORT lt_api_requests STABLE BY priority DESCENDING.
    ENDIF.
    LOOP AT lt_api_requests INTO DATA(ls_prepared_request).
      READ TABLE rs_result-items ASSIGNING FIELD-SYMBOL(<ls_line>)
        WITH KEY request_id = ls_prepared_request-request_id.
      IF sy-subrc <> 0
          OR <ls_line>-request_id <> ls_prepared_request-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ls_api_result = mo_reservation_api->create_reservation(
        is_request  = ls_prepared_request-request
        iv_test_run = iv_test_run ).
      <ls_line>-reservation_result = ls_api_result.
      APPEND LINES OF ls_api_result-messages TO rs_result-messages.

      DATA(lv_create_failed) = xsdbool(
        ls_api_result-is_successful <> abap_true ).
      LOOP AT ls_api_result-messages INTO DATA(ls_api_message).
        IF ls_api_message-type = 'A'
            OR ls_api_message-type = 'E'
            OR ls_api_message-type = 'X'.
          lv_create_failed = abap_true.
        ENDIF.
      ENDLOOP.
      IF iv_test_run = abap_false
          AND ls_api_result-reservation_number IS INITIAL.
        lv_create_failed = abap_true.
        IF NOT line_exists(
            <ls_line>-reservation_result-messages[ type = 'A' ] )
            AND NOT line_exists(
              <ls_line>-reservation_result-messages[ type = 'E' ] )
            AND NOT line_exists(
              <ls_line>-reservation_result-messages[ type = 'X' ] ).
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation API returned no reservation number' )
            TO <ls_line>-reservation_result-messages.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation API returned no reservation number' )
            TO rs_result-messages.
        ENDIF.
      ENDIF.
      IF iv_test_run = abap_false
          AND lv_create_failed = abap_false.
        INSERT ls_api_result-reservation_number
          INTO TABLE lt_reservation_numbers.
        IF sy-subrc <> 0.
          lv_create_failed = abap_true.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation API returned a duplicate reservation number' )
            TO <ls_line>-reservation_result-messages.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation API returned a duplicate reservation number' )
            TO rs_result-messages.
        ENDIF.
      ENDIF.
      IF lv_create_failed = abap_true.
        IF NOT line_exists(
            <ls_line>-reservation_result-messages[ type = 'A' ] )
            AND NOT line_exists(
              <ls_line>-reservation_result-messages[ type = 'E' ] )
            AND NOT line_exists(
              <ls_line>-reservation_result-messages[ type = 'X' ] ).
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation creation failed for atomic demand' )
            TO <ls_line>-reservation_result-messages.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation creation failed for atomic demand' )
            TO rs_result-messages.
        ENDIF.
        <ls_line>-reservation_result-is_successful = abap_false.
        CLEAR <ls_line>-reservation_result-reservation_number.
        mo_reservation_api->rollback( ).
        LOOP AT rs_result-items ASSIGNING <ls_rollback_line>.
          CLEAR <ls_rollback_line>-reservation_result-reservation_number.
        ENDLOOP.
        rs_result-was_rolled_back = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_reservation_api->rollback( ).
      LOOP AT rs_result-items ASSIGNING <ls_rollback_line>.
        CLEAR <ls_rollback_line>-reservation_result-reservation_number.
      ENDLOOP.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
        IF ls_commit_result-message-type <> 'A'
            AND ls_commit_result-message-type <> 'E'
            AND ls_commit_result-message-type <> 'X'.
          APPEND VALUE #(
            type    = 'E'
            message = 'Atomic reservation commit failed; all reservations were rolled back' )
            TO rs_result-messages.
        ENDIF.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation commit failed; all reservations were rolled back' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    LOOP AT rs_result-items ASSIGNING <ls_line>.
      <ls_line>-is_committed = abap_true.
    ENDLOOP.
    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD reserve_cc_atomic_by_date.
    DATA lt_ordered_demands TYPE ty_atomic_reservation_demands.
    DATA lt_ordered_items TYPE ty_atomic_reservation_lines.
    DATA ls_demand TYPE ty_atomic_reservation_demand.
    DATA ls_ordered_item TYPE ty_atomic_reservation_line.

    lt_ordered_demands = it_demands.
    LOOP AT lt_ordered_demands INTO ls_demand.
      IF ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
    SORT lt_ordered_demands STABLE BY required_date ASCENDING
      priority DESCENDING.

    rs_result = reserve_cost_centers_atomic(
      it_demands                     = lt_ordered_demands
      iv_test_run                    = iv_test_run
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_use_fefo_batches            = iv_use_fefo_batches
      iv_prioritize_by_priority      = abap_false
      iv_fefo_as_of_date             = iv_fefo_as_of_date
      iv_fefo_min_days               = iv_fefo_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_check_atp                   = iv_check_atp
      iv_atp_check_rule              = iv_atp_check_rule
      iv_require_atp_confirmation    = iv_require_atp_confirmation
      it_location_priority           = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations ).

    lt_ordered_items = rs_result-items.
    LOOP AT lt_ordered_items ASSIGNING FIELD-SYMBOL(<ls_dated_atomic_item>).
      DATA(lv_dated_atomic_sequence) = sy-tabix.
      <ls_dated_atomic_item>-allocation_sequence =
        lv_dated_atomic_sequence.
      <ls_dated_atomic_item>-allocation-allocation-allocation_sequence =
        lv_dated_atomic_sequence.
      LOOP AT <ls_dated_atomic_item>-storage_allocations
          ASSIGNING FIELD-SYMBOL(<ls_dt_atomic_store_split>).
        <ls_dt_atomic_store_split>-allocation_sequence =
          lv_dated_atomic_sequence.
      ENDLOOP.
      LOOP AT <ls_dated_atomic_item>-batch_allocations
          ASSIGNING FIELD-SYMBOL(<ls_dated_atomic_batch_split>).
        <ls_dated_atomic_batch_split>-allocation_sequence =
          lv_dated_atomic_sequence.
      ENDLOOP.
    ENDLOOP.
    CLEAR rs_result-items.
    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_ordered_items INTO ls_ordered_item
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_ordered_item-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_ordered_item TO rs_result-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_cost_centers_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_seen_locations TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_request_location_priorities TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_request_locations TYPE
      zcl_stock_service=>ty_request_locations.
    DATA lt_seen_request_locations TYPE
      zcl_stock_service=>ty_request_locations.
    DATA lt_ordered_demands TYPE ty_atomic_reservation_demands.
    DATA lt_ordered_items TYPE ty_bulk_reservation_items.
    DATA lv_batch_mode TYPE abap_bool.
    DATA lv_unbatched_mode TYPE abap_bool.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_item> TYPE ty_bulk_reservation_item.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_use_fefo_batches <> abap_true
          AND iv_use_fefo_batches <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_check_atp <> abap_true
          AND iv_check_atp <> abap_false )
        OR ( iv_require_atp_confirmation <> abap_true
          AND iv_require_atp_confirmation <> abap_false )
        OR iv_fefo_min_days < 0
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true )
        OR ( iv_use_fefo_batches = abap_true
          AND iv_fefo_as_of_date IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_use_fefo_batches = abap_true
        AND zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_fefo_as_of_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_location_priority INTO DATA(lv_priority_location).
      IF lv_priority_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_priority_location INTO TABLE lt_seen_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
    CLEAR lt_seen_locations.
    LOOP AT it_allowed_storage_locations INTO DATA(lv_allowed_location).
      IF lv_allowed_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_allowed_location INTO TABLE lt_seen_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true
          OR ( ls_demand-fefo_as_of_date IS NOT INITIAL
            AND ( iv_use_fefo_batches <> abap_true
              OR zcl_date_validation=>is_valid_gregorian_date(
                iv_date = ls_demand-fefo_as_of_date ) <> abap_true ) )
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-minimum_coverage_pct < 0
          OR ls_demand-minimum_coverage_pct > 100
          OR ls_demand-minimum_shelf_life_days < 0
          OR ( ls_demand-minimum_shelf_life_days > 0
            AND iv_use_fefo_batches <> abap_true
            AND ls_demand-batch IS INITIAL )
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-require_known_expiry <> abap_true
            AND ls_demand-require_known_expiry <> abap_false )
          OR ( ls_demand-allow_undated_batches <> abap_true
            AND ls_demand-allow_undated_batches <> abap_false )
          OR ( ls_demand-require_known_expiry = abap_true
            AND ls_demand-allow_undated_batches = abap_true )
          OR ( ( ls_demand-require_known_expiry = abap_true
              OR ls_demand-allow_undated_batches = abap_true )
            AND ls_demand-batch IS INITIAL
            AND iv_use_fefo_batches <> abap_true )
          OR ( ls_demand-fallback_to_other_locations = abap_true
            AND ls_demand-storage_location IS INITIAL )
          OR ( ls_demand-storage_location IS NOT INITIAL
            AND it_allowed_storage_locations IS NOT INITIAL
            AND NOT line_exists( lt_seen_locations[
              table_line = ls_demand-storage_location ] ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand-request_id INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-batch IS INITIAL.
        lv_unbatched_mode = abap_true.
      ELSE.
        lv_batch_mode = abap_true.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_seen_requests[
            table_line = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL
          OR NOT line_exists( lt_seen_requests[
            table_line = ls_request_location-request_id ] )
          OR line_exists( lt_seen_request_locations[
            request_id = ls_request_location-request_id
            storage_location = ls_request_location-storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_request_location TO lt_seen_request_locations.
    ENDLOOP.

    IF iv_prioritize_by_priority = abap_true
        AND iv_use_fefo_batches <> abap_true
        AND ( lv_batch_mode <> abap_true
          OR lv_unbatched_mode = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    lt_ordered_demands = it_demands.
    IF iv_prioritize_by_priority = abap_true.
      SORT lt_ordered_demands STABLE BY priority DESCENDING.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT lt_ordered_demands INTO ls_demand.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_item>.
      <ls_item>-request_id = ls_demand-request_id.
      <ls_item>-required_date = ls_demand-required_date.
      <ls_item>-priority = ls_demand-priority.
      CLEAR lt_request_location_priorities.
      CLEAR lt_request_locations.
      LOOP AT it_request_locations INTO ls_request_location
          WHERE request_id = ls_demand-request_id.
        APPEND ls_request_location TO lt_request_locations.
        APPEND ls_request_location TO <ls_item>-request_locations.
      ENDLOOP.
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_demand-request_id.
        APPEND ls_request_location_priority
          TO lt_request_location_priorities.
      ENDLOOP.
      IF lv_stop_processing = abap_true.
        <ls_item>-is_skipped = abap_true.
        CONTINUE.
      ENDIF.
      TRY.
          DATA(ls_single_result) = reserve_cost_centers_atomic(
            it_demands                     = VALUE #( ( ls_demand ) )
            iv_test_run                    = iv_test_run
            iv_protect_safety_stock        = iv_protect_safety_stock
            iv_use_fefo_batches            = iv_use_fefo_batches
            iv_prioritize_by_priority      = iv_prioritize_by_priority
            iv_fefo_as_of_date             = iv_fefo_as_of_date
            iv_fefo_min_days               = iv_fefo_min_days
            iv_include_undated_batches     = iv_include_undated_batches
            iv_check_atp                   = iv_check_atp
            iv_atp_check_rule              = iv_atp_check_rule
            iv_require_atp_confirmation    = iv_require_atp_confirmation
            it_location_priority           = it_location_priority
            it_request_location_priorities = lt_request_location_priorities
            it_allowed_storage_locations   = it_allowed_storage_locations
            it_request_locations           = lt_request_locations ).
          IF lines( ls_single_result-items ) <> 1
              OR ls_single_result-items[ 1 ]-request_id
                <> ls_demand-request_id.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          MOVE-CORRESPONDING ls_single_result-items[ 1 ] TO <ls_item>.
          <ls_item>-is_successful = ls_single_result-is_successful.
          <ls_item>-was_rolled_back =
            ls_single_result-was_rolled_back.
          IF <ls_item>-is_committed = abap_true.
            rs_result-is_committed = abap_true.
          ENDIF.
          APPEND LINES OF ls_single_result-messages
            TO rs_result-messages.
          IF <ls_item>-is_successful <> abap_true.
            IF <ls_item>-reservation_result-messages IS INITIAL.
              APPEND LINES OF ls_single_result-messages
                TO <ls_item>-reservation_result-messages.
            ENDIF.
            rs_result-is_successful = abap_false.
            IF iv_stop_on_failure = abap_true.
              lv_stop_processing = abap_true.
              rs_result-stopped_on_failure = abap_true.
            ENDIF.
          ENDIF.
        CATCH zcx_invalid_stock_request.
          <ls_item>-is_successful = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation demand could not be processed' )
            TO <ls_item>-reservation_result-messages.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation demand could not be processed' )
            TO rs_result-messages.
          rs_result-is_successful = abap_false.
          IF iv_stop_on_failure = abap_true.
            lv_stop_processing = abap_true.
            rs_result-stopped_on_failure = abap_true.
          ENDIF.
      ENDTRY.
    ENDLOOP.

    lt_ordered_items = rs_result-items.
    LOOP AT lt_ordered_items ASSIGNING FIELD-SYMBOL(<ls_bulk_item_sequence>).
      DATA(lv_bulk_item_sequence) = sy-tabix.
      <ls_bulk_item_sequence>-allocation_sequence =
        lv_bulk_item_sequence.
      <ls_bulk_item_sequence>-allocation-allocation-allocation_sequence =
        lv_bulk_item_sequence.
      LOOP AT <ls_bulk_item_sequence>-storage_allocations
          ASSIGNING FIELD-SYMBOL(<ls_bulk_storage_sequence>).
        <ls_bulk_storage_sequence>-allocation_sequence =
          lv_bulk_item_sequence.
      ENDLOOP.
      LOOP AT <ls_bulk_item_sequence>-batch_allocations
          ASSIGNING FIELD-SYMBOL(<ls_bulk_batch_sequence>).
        <ls_bulk_batch_sequence>-allocation_sequence =
          lv_bulk_item_sequence.
      ENDLOOP.
    ENDLOOP.
    CLEAR rs_result-items.
    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_ordered_items INTO DATA(ls_ordered_item)
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_ordered_item TO rs_result-items.
    ENDLOOP.

    LOOP AT rs_result-items ASSIGNING <ls_item>.
      IF <ls_item>-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
      ELSEIF <ls_item>-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
      ELSE.
        ADD 1 TO rs_result-failed_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_cc_bulk_by_date.
    DATA lt_ordered_demands TYPE ty_atomic_reservation_demands.
    DATA lt_ordered_items TYPE ty_bulk_reservation_items.
    DATA ls_demand TYPE ty_atomic_reservation_demand.
    DATA ls_ordered_item TYPE ty_bulk_reservation_item.

    lt_ordered_demands = it_demands.
    LOOP AT lt_ordered_demands INTO ls_demand.
      IF ls_demand-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
    SORT lt_ordered_demands STABLE BY required_date ASCENDING
      priority DESCENDING.

    rs_result = reserve_cost_centers_bulk(
      it_demands                     = lt_ordered_demands
      iv_test_run                    = iv_test_run
      iv_stop_on_failure             = iv_stop_on_failure
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_use_fefo_batches            = iv_use_fefo_batches
      iv_prioritize_by_priority      = abap_false
      iv_fefo_as_of_date             = iv_fefo_as_of_date
      iv_fefo_min_days               = iv_fefo_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_check_atp                   = iv_check_atp
      iv_atp_check_rule              = iv_atp_check_rule
      iv_require_atp_confirmation    = iv_require_atp_confirmation
      it_location_priority           = it_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations ).

    lt_ordered_items = rs_result-items.
    CLEAR rs_result-items.
    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_ordered_items INTO ls_ordered_item
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_ordered_item-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_ordered_item TO rs_result-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_reservations.
    TYPES ty_seen_reservation TYPE
      zif_cc_reservation_api=>ty_reservation_number.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.

    IF it_reservation_numbers IS INITIAL
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      INSERT lv_reservation_number INTO TABLE lt_seen_reservations.
      IF lv_reservation_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-reservation_numbers = it_reservation_numbers.
    rs_result-is_test_run = iv_test_run.

    DATA(ls_api_result) = mo_reservation_api->delete_reservations(
      it_reservation_numbers = it_reservation_numbers
      iv_test_run            = iv_test_run ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_reservation_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_reservation_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation deletion commit failed; deletions were rolled back' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD delete_reservations_bulk.
    TYPES ty_seen_reservation TYPE
      zif_cc_reservation_api=>ty_reservation_number.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_item> TYPE ty_bulk_delete_item.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      INSERT lv_reservation_number INTO TABLE lt_seen_reservations.
      IF lv_reservation_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    LOOP AT it_reservation_numbers INTO lv_reservation_number.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_item>.
      <ls_item>-reservation_number = lv_reservation_number.

      IF lv_stop_processing = abap_true.
        <ls_item>-is_skipped = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_api_result) = mo_reservation_api->delete_reservations(
        it_reservation_numbers = VALUE #( ( lv_reservation_number ) )
        iv_test_run            = iv_test_run ).
      <ls_item>-messages = ls_api_result-messages.
      <ls_item>-is_successful = ls_api_result-is_successful.
      LOOP AT <ls_item>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_item>-is_successful = abap_false.
        ENDIF.
      ENDLOOP.

      IF <ls_item>-is_successful <> abap_true.
        mo_reservation_api->rollback( ).
        <ls_item>-was_rolled_back = abap_true.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF iv_test_run = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_commit_result) = mo_reservation_api->commit( ).
      IF ls_commit_result-is_successful <> abap_true
          OR ls_commit_result-message-type = 'A'
          OR ls_commit_result-message-type = 'E'
          OR ls_commit_result-message-type = 'X'.
        mo_reservation_api->rollback( ).
        <ls_item>-is_successful = abap_false.
        <ls_item>-was_rolled_back = abap_true.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
        IF ls_commit_result-message-message IS NOT INITIAL.
          APPEND ls_commit_result-message TO <ls_item>-messages.
        ELSE.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation deletion commit failed; this deletion was rolled back' )
            TO <ls_item>-messages.
        ENDIF.
        CONTINUE.
      ENDIF.

      <ls_item>-is_committed = abap_true.
      rs_result-is_committed = abap_true.
    ENDLOOP.

    LOOP AT rs_result-items INTO DATA(ls_delete_item).
      IF ls_delete_item-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
      ELSEIF ls_delete_item-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
      ELSE.
        ADD 1 TO rs_result-failed_count.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_for_cost_center.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_check_atp <> abap_true AND iv_check_atp <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_require_atp_confirmation <> abap_true
        AND iv_require_atp_confirmation <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_require_atp_confirmation = abap_true
        AND iv_check_atp <> abap_true.
      APPEND VALUE #(
        type    = 'E'
        message = 'Full ATP confirmation requirement needs ATP checking' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    DATA(ls_prepared) = prepare_reservation(
      iv_material                  = iv_material
      iv_plant                     = iv_plant
      iv_storage_location          = iv_storage_location
      iv_location_supplied         =
        xsdbool( iv_storage_location IS SUPPLIED )
      iv_allow_fallback            = iv_allow_fallback
      iv_cost_center               = iv_cost_center
      iv_requested_quantity        = iv_requested_quantity
      iv_unit                      = iv_unit
      iv_batch                     = iv_batch
      iv_batch_supplied            = xsdbool( iv_batch IS SUPPLIED )
      iv_required_date             = iv_required_date
      iv_use_fefo_batches          = iv_use_fefo_batches
      iv_fefo_as_of_date           = iv_fefo_as_of_date
      iv_fefo_min_days             = iv_fefo_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_known_expiry      = iv_require_known_expiry
      iv_allow_undated_batches     = iv_allow_undated_batches
      iv_batch_min_days            = iv_batch_min_days
      iv_minimum_coverage_pct      = iv_minimum_coverage_pct
      iv_require_full_alloc        = iv_require_full_alloc
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_location_priority         = it_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations ).
    rs_result = ls_prepared-result.

    IF rs_result-is_successful = abap_false
        OR rs_result-allocated_quantity <= 0.
      RETURN.
    ENDIF.

    IF iv_check_atp = abap_true.
      rs_result-atp_result = mo_stock_service->check_atp_request(
        is_request = VALUE #(
          material           = ls_prepared-result-material
          plant              = ls_prepared-result-plant
          unit               = ls_prepared-result-base_unit
          check_rule         = iv_atp_check_rule
          required_date      = iv_required_date
          requested_quantity =
            ls_prepared-result-base_requested_quantity ) ).
      DATA(ls_confirmation_split) =
        mo_stock_service->get_atp_confirmation_split(
          iv_requested_base_quantity =
            ls_prepared-result-base_requested_quantity
          iv_required_date           = iv_required_date
          is_atp_result              = rs_result-atp_result ).
      rs_result-confirmed_base_quantity =
        ls_confirmation_split-confirmed_base_quantity.
      rs_result-unconfirmed_base_quantity =
        ls_confirmation_split-unconfirmed_base_quantity.
      rs_result-is_fully_confirmed = COND abap_bool(
        WHEN ls_confirmation_split-confirmed_base_quantity >=
            rs_result-base_requested_quantity
          THEN abap_true
        ELSE abap_false ).
    ENDIF.

    IF iv_require_atp_confirmation = abap_true
        AND rs_result-is_fully_confirmed <> abap_true.
      APPEND VALUE #(
        type    = 'E'
        message = 'Full ATP confirmation required; no reservation was created' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_create_result) = mo_reservation_api->create_reservation(
      is_request  = ls_prepared-request
      iv_test_run = iv_test_run ).
    APPEND LINES OF ls_create_result-messages TO rs_result-messages.
    rs_result-reservation_number = ls_create_result-reservation_number.

    IF ls_create_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservation_number.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT ls_create_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_reservation_api->rollback( ).
        CLEAR rs_result-reservation_number.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-reservation_number IS INITIAL.
      mo_reservation_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API returned no reservation number' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservation_number.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD check_batch_allocation_atp.
    TYPES:
      BEGIN OF ty_atp_group,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        base_unit               TYPE mara-meins,
        check_date              TYPE d,
        allocated_base_quantity TYPE decfloat34,
      END OF ty_atp_group.
    TYPES ty_atp_groups TYPE STANDARD TABLE OF ty_atp_group WITH EMPTY KEY.
    DATA lt_atp_groups TYPE ty_atp_groups.
    DATA lv_check_date          TYPE d.
    DATA lv_group_quantity TYPE decfloat34.
    DATA lv_cumulative_total TYPE decfloat34.
    DATA lv_group_base_quantity TYPE mard-labst.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material   TYPE mard-matnr.
    DATA lv_previous_plant      TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    FIELD-SYMBOLS <ls_atp_group> TYPE ty_atp_group.

    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_batch_allocations INTO DATA(ls_batch_split).
      IF ls_batch_split-batch_allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      lv_check_date = ls_batch_split-batch_allocation-as_of_date.
      IF lv_check_date IS INITIAL.
        lv_check_date = sy-datum.
      ENDIF.
      lv_group_quantity = CONV decfloat34(
        ls_batch_split-batch_allocation-allocated_quantity ).
      READ TABLE lt_atp_groups ASSIGNING <ls_atp_group>
        WITH KEY material = ls_batch_split-batch_allocation-material
                 plant = ls_batch_split-batch_allocation-plant
                 base_unit = ls_batch_split-base_unit
                 check_date = lv_check_date.
      IF sy-subrc = 0.
        <ls_atp_group>-allocated_base_quantity =
          <ls_atp_group>-allocated_base_quantity + lv_group_quantity.
      ELSE.
        APPEND VALUE #(
          material                =
            ls_batch_split-batch_allocation-material
          plant                   = ls_batch_split-batch_allocation-plant
          base_unit               = ls_batch_split-base_unit
          check_date              = lv_check_date
          allocated_base_quantity = lv_group_quantity )
          TO lt_atp_groups.
      ENDIF.
    ENDLOOP.

    SORT lt_atp_groups BY material plant base_unit check_date.
    LOOP AT lt_atp_groups INTO DATA(ls_atp_group).
      IF sy-tabix = 1
          OR ls_atp_group-material <> lv_previous_material
          OR ls_atp_group-plant <> lv_previous_plant
          OR ls_atp_group-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      TRY.
          lv_group_base_quantity = CONV mard-labst(
            ls_atp_group-allocated_base_quantity ).
          lv_cumulative_total = CONV decfloat34(
            lv_cumulative_quantity )
            + ls_atp_group-allocated_base_quantity.
          lv_cumulative_quantity = CONV mard-labst(
            lv_cumulative_total ).
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.

      DATA(ls_atp_result) = mo_stock_service->check_atp_request(
        is_request = VALUE #(
          material           = ls_atp_group-material
          plant              = ls_atp_group-plant
          unit               = ls_atp_group-base_unit
          check_rule         = iv_check_rule
          required_date      = ls_atp_group-check_date
          requested_quantity = lv_cumulative_quantity ) ).
      DATA(ls_confirmation_split) =
        mo_stock_service->get_atp_confirmation_split(
          iv_requested_base_quantity = lv_cumulative_quantity
          iv_required_date           = ls_atp_group-check_date
          is_atp_result              = ls_atp_result ).
      APPEND VALUE #(
        material                  = ls_atp_group-material
        plant                     = ls_atp_group-plant
        base_unit                 = ls_atp_group-base_unit
        check_date                = ls_atp_group-check_date
        allocated_base_quantity   = lv_group_base_quantity
        cumulative_base_quantity  = lv_cumulative_quantity
        confirmed_base_quantity   =
          ls_confirmation_split-confirmed_base_quantity
        unconfirmed_base_quantity =
          ls_confirmation_split-unconfirmed_base_quantity
        is_fully_confirmed        = COND abap_bool(
          WHEN ls_confirmation_split-confirmed_base_quantity >=
              lv_cumulative_quantity
            THEN abap_true
          ELSE abap_false )
        atp_result                = ls_atp_result )
        TO rt_atp_checks.
      lv_previous_material = ls_atp_group-material.
      lv_previous_plant = ls_atp_group-plant.
      lv_previous_unit = ls_atp_group-base_unit.
    ENDLOOP.  ENDMETHOD.

  METHOD preview_for_cost_center.
    IF iv_check_atp <> abap_true AND iv_check_atp <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_prepared) = prepare_reservation(
      iv_material                  = iv_material
      iv_plant                     = iv_plant
      iv_storage_location          = iv_storage_location
      iv_location_supplied         =
        xsdbool( iv_storage_location IS SUPPLIED )
      iv_allow_fallback            = iv_allow_fallback
      iv_cost_center               = iv_cost_center
      iv_requested_quantity        = iv_requested_quantity
      iv_unit                      = iv_unit
      iv_batch                     = iv_batch
      iv_batch_supplied            = xsdbool( iv_batch IS SUPPLIED )
      iv_required_date             = iv_required_date
      iv_use_fefo_batches          = iv_use_fefo_batches
      iv_fefo_as_of_date           = iv_fefo_as_of_date
      iv_fefo_min_days             = iv_fefo_min_days
      iv_include_undated_batches   = iv_include_undated_batches
      iv_require_known_expiry      = iv_require_known_expiry
      iv_allow_undated_batches     = iv_allow_undated_batches
      iv_batch_min_days            = iv_batch_min_days
      iv_minimum_coverage_pct      = iv_minimum_coverage_pct
      iv_require_full_alloc        = iv_require_full_alloc
      iv_protect_safety_stock      = iv_protect_safety_stock
      it_location_priority         = it_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations ).
    rs_result = ls_prepared-result.

    IF iv_check_atp = abap_true.
      rs_result-atp_result = mo_stock_service->check_atp_request(
        is_request = VALUE #(
          material           = ls_prepared-result-material
          plant              = ls_prepared-result-plant
          unit               = ls_prepared-result-base_unit
          check_rule         = iv_atp_check_rule
          required_date      = iv_required_date
          requested_quantity =
            ls_prepared-result-base_requested_quantity ) ).
      DATA(ls_confirmation_split) =
      mo_stock_service->get_atp_confirmation_split(
        iv_requested_base_quantity =
          ls_prepared-result-base_requested_quantity
        iv_required_date           = iv_required_date
        is_atp_result              = rs_result-atp_result ).
      rs_result-confirmed_base_quantity =
        ls_confirmation_split-confirmed_base_quantity.
      rs_result-unconfirmed_base_quantity =
        ls_confirmation_split-unconfirmed_base_quantity.
      rs_result-is_fully_confirmed = COND abap_bool(
        WHEN ls_confirmation_split-confirmed_base_quantity >=
            rs_result-base_requested_quantity
          THEN abap_true
        ELSE abap_false ).
    ENDIF.
  ENDMETHOD.

  METHOD prepare_reservation.
    DATA lt_allowed_locations TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    DATA lv_effective_fefo_as_of_date TYPE d.

    LOOP AT it_allowed_storage_locations INTO DATA(lv_allowed_location).
      IF lv_allowed_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_allowed_location INTO TABLE lt_allowed_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF iv_location_supplied = abap_true
        AND lt_allowed_locations IS NOT INITIAL
        AND NOT line_exists( lt_allowed_locations[
          table_line = iv_storage_location ] ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR ( iv_location_supplied = abap_true
          AND iv_storage_location IS INITIAL )
        OR ( iv_allow_fallback = abap_true
          AND iv_location_supplied = abap_false )
        OR iv_cost_center IS INITIAL
        OR iv_requested_quantity <= 0
        OR iv_unit IS INITIAL
        OR iv_required_date IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_required_date ) <> abap_true
        OR ( iv_batch_supplied = abap_true AND iv_batch IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    IF ( iv_allow_fallback <> abap_true
          AND iv_allow_fallback <> abap_false )
        OR ( iv_use_fefo_batches <> abap_true
          AND iv_use_fefo_batches <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_require_full_alloc <> abap_true
          AND iv_require_full_alloc <> abap_false )
        OR iv_fefo_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_known_expiry <> abap_true
          AND iv_require_known_expiry <> abap_false )
        OR ( iv_allow_undated_batches <> abap_true
          AND iv_allow_undated_batches <> abap_false )
        OR ( iv_require_known_expiry = abap_true
          AND iv_allow_undated_batches = abap_true )
        OR ( ( iv_require_known_expiry = abap_true
            OR iv_allow_undated_batches = abap_true )
          AND iv_use_fefo_batches <> abap_true
          AND iv_batch_supplied <> abap_true )
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true )
        OR iv_batch_min_days < 0
        OR ( iv_batch_min_days > 0
          AND iv_batch_supplied <> abap_true )
        OR iv_minimum_coverage_pct < 0
        OR iv_minimum_coverage_pct > 100
        OR ( iv_use_fefo_batches = abap_true
          AND iv_fefo_as_of_date IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_use_fefo_batches = abap_true.
      IF zcl_date_validation=>is_valid_gregorian_date(
          iv_date = iv_fefo_as_of_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_effective_fefo_as_of_date = iv_fefo_as_of_date.
      IF iv_required_date > lv_effective_fefo_as_of_date.
        lv_effective_fefo_as_of_date = iv_required_date.
      ENDIF.
    ENDIF.

    DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
      iv_material    = iv_material
      iv_quantity    = iv_requested_quantity
      iv_source_unit = iv_unit ).
    IF ls_conversion-is_successful <> abap_true
        OR ls_conversion-base_unit IS INITIAL
        OR ls_conversion-base_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_prepared-result-material = iv_material.
    rs_prepared-result-plant = iv_plant.
    rs_prepared-result-storage_location = iv_storage_location.
    rs_prepared-result-batch = iv_batch.
    rs_prepared-result-cost_center = iv_cost_center.
    rs_prepared-result-fefo_as_of_date =
      lv_effective_fefo_as_of_date.
    rs_prepared-result-require_known_expiry = iv_require_known_expiry.
    rs_prepared-result-allow_undated_batches = iv_allow_undated_batches.
    rs_prepared-result-minimum_coverage_pct = iv_minimum_coverage_pct.
    rs_prepared-result-requested_quantity = iv_requested_quantity.
    rs_prepared-result-source_unit = iv_unit.
    rs_prepared-result-base_requested_quantity =
      ls_conversion-base_quantity.
    rs_prepared-result-base_unit = ls_conversion-base_unit.

    DATA ls_allocation TYPE zcl_stock_service=>ty_allocation.
    DATA ls_batch_result TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_fefo_result TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_location_result TYPE zcl_stock_service=>ty_location_result.

    IF iv_use_fefo_batches = abap_true.
      ls_fefo_result = mo_stock_service->allocate_by_expiry(
        it_demands                   = VALUE #(
          ( material                    = iv_material
            plant                       = iv_plant
            batch                       = iv_batch
            storage_location            = iv_storage_location
            fallback_to_other_locations = iv_allow_fallback
            requested_quantity          = ls_conversion-base_quantity
            fefo_as_of_date             =
              lv_effective_fefo_as_of_date
            minimum_shelf_life_days     = iv_batch_min_days
            require_known_expiry        = iv_require_known_expiry
            allow_undated_batches       = iv_allow_undated_batches
            minimum_coverage_pct        = iv_minimum_coverage_pct ) )
        iv_as_of_date                = iv_fefo_as_of_date
        iv_min_days                  = iv_fefo_min_days
        iv_include_undated_batches   = iv_include_undated_batches
        it_storage_location_priority = it_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_protect_safety_stock      = iv_protect_safety_stock ).
      READ TABLE ls_fefo_result-allocations INDEX 1 INTO ls_allocation.
    ELSEIF iv_batch_supplied = abap_true.
      ls_batch_result = mo_stock_service->allocate_by_batch(
        it_demands                   = VALUE #(
          ( material                    = iv_material
            plant                       = iv_plant
            storage_location            = iv_storage_location
            fallback_to_other_locations = iv_allow_fallback
            batch                       = iv_batch
            requested_quantity          = ls_conversion-base_quantity
            as_of_date                  = iv_required_date
            minimum_shelf_life_days     =
              iv_batch_min_days
            require_known_expiry        = iv_require_known_expiry
            allow_undated_batches       = iv_allow_undated_batches
            minimum_coverage_pct        = iv_minimum_coverage_pct ) )
        it_storage_location_priority = it_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_protect_safety_stock      = iv_protect_safety_stock
        iv_include_undated_batches   = iv_include_undated_batches ).
      READ TABLE ls_batch_result-allocations INDEX 1 INTO ls_allocation.
    ELSE.
      ls_location_result = mo_stock_service->allocate_by_storage_location(
          it_demands                   = VALUE #(
            ( material                    = iv_material
              plant                       = iv_plant
              storage_location            = iv_storage_location
              fallback_to_other_locations = iv_allow_fallback
              requested_quantity          = ls_conversion-base_quantity
              minimum_coverage_pct        = iv_minimum_coverage_pct ) )
          it_storage_location_priority = it_location_priority
          it_allowed_storage_locations = it_allowed_storage_locations
          iv_protect_safety_stock      = iv_protect_safety_stock ).
      READ TABLE ls_location_result-allocations INDEX 1 INTO ls_allocation.
    ENDIF.

    rs_prepared-result-available_quantity =
      ls_allocation-available_quantity.
    rs_prepared-result-allocated_quantity =
      ls_allocation-allocated_quantity.
    rs_prepared-result-shortfall_quantity =
      ls_allocation-shortfall_quantity.
    rs_prepared-result-allocation_outcome =
      ls_allocation-allocation_outcome.
    rs_prepared-result-minimum_coverage_rejected = xsdbool(
      ls_allocation-minimum_coverage_rejected = abap_true
      OR ( iv_minimum_coverage_pct > 0
        AND iv_require_full_alloc = abap_true
        AND ls_allocation-allocated_quantity <
          ls_allocation-requested_quantity ) ).
    rs_prepared-result-allocation_coverage_pct =
      ls_allocation-allocation_coverage_pct.

    DATA lt_request_items TYPE zif_cc_reservation_api=>ty_items.
    IF iv_use_fefo_batches = abap_true.
      rs_prepared-result-batch_allocations =
        ls_fefo_result-batch_allocations.
      LOOP AT ls_fefo_result-batch_allocations
        INTO DATA(ls_fefo_allocation).
        APPEND VALUE #(
          storage_location = ls_fefo_allocation-storage_location
          batch            = ls_fefo_allocation-batch
          quantity         = ls_fefo_allocation-allocated_quantity
          unit             = ls_conversion-base_unit )
          TO lt_request_items.
      ENDLOOP.
    ELSEIF iv_batch_supplied = abap_true.
      rs_prepared-result-batch_allocations =
        ls_batch_result-batch_allocations.
      LOOP AT ls_batch_result-batch_allocations
        INTO DATA(ls_batch_allocation).
        APPEND VALUE #(
          storage_location = ls_batch_allocation-storage_location
          batch            = ls_batch_allocation-batch
          quantity         = ls_batch_allocation-allocated_quantity
          unit             = ls_conversion-base_unit )
          TO lt_request_items.
      ENDLOOP.
    ELSE.
      rs_prepared-result-storage_allocations =
        ls_location_result-storage_allocations.
      LOOP AT ls_location_result-storage_allocations
        INTO DATA(ls_storage_allocation).
        APPEND VALUE #(
          storage_location = ls_storage_allocation-storage_location
          quantity         = ls_storage_allocation-allocated_quantity
          unit             = ls_conversion-base_unit )
          TO lt_request_items.
      ENDLOOP.
    ENDIF.

    rs_prepared-request = VALUE #(
      material      = iv_material
      plant         = iv_plant
      cost_center   = iv_cost_center
      required_date = iv_required_date
      items         = lt_request_items ).

    IF iv_require_full_alloc = abap_true
        AND rs_prepared-result-shortfall_quantity > 0.
      APPEND VALUE #(
        type    = 'E'
        message = 'Full allocation required; no cost-center reservation was created' )
        TO rs_prepared-result-messages.
      RETURN.
    ENDIF.

    IF rs_prepared-result-allocated_quantity <= 0.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocatable stock; no cost-center reservation was created' )
        TO rs_prepared-result-messages.
      rs_prepared-result-is_successful = abap_true.
      RETURN.
    ENDIF.

    rs_prepared-result-is_successful = abap_true.
  ENDMETHOD.
ENDCLASS.
