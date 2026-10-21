CLASS zcl_prod_comp_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lead_time_status TYPE c LENGTH 20.
    TYPES ty_lead_time_origin TYPE c LENGTH 12.
    TYPES ty_comp_seq_scope TYPE c LENGTH 1.
    CONSTANTS:
      c_comp_seq_scope_dated TYPE
        ty_comp_seq_scope VALUE 'D',
      c_comp_seq_scope_scoped TYPE
        ty_comp_seq_scope VALUE 'S'.
    TYPES ty_pr_release_urgency TYPE c LENGTH 12.
    CONSTANTS:
      c_repl_status_estimate TYPE ty_lead_time_status
        VALUE 'MATERIAL_ESTIMATE',
      c_repl_status_no_policy TYPE ty_lead_time_status
        VALUE 'NO_POLICY',
      c_repl_status_in_house TYPE ty_lead_time_status
        VALUE 'IN_HOUSE',
      c_repl_status_ambiguous TYPE ty_lead_time_status
        VALUE 'AMBIGUOUS',
      c_repl_status_special_source TYPE ty_lead_time_status
        VALUE 'SPECIAL_SOURCE',
      c_repl_status_missing_calendar TYPE ty_lead_time_status
        VALUE 'MISSING_CALENDAR',
      c_repl_status_calendar_error TYPE ty_lead_time_status
        VALUE 'CALENDAR_ERROR',
      c_repl_status_unsupported TYPE ty_lead_time_status
        VALUE 'UNSUPPORTED',
      c_repl_status_receipt TYPE ty_lead_time_status
        VALUE 'COVERED_BY_RECEIPT',
      c_repl_status_supply TYPE ty_lead_time_status
        VALUE 'COVERED_BY_SUPPLY',
      c_repl_status_covered TYPE ty_lead_time_status
        VALUE 'COVERED_BY_SURPLUS',
      c_pr_urgency_no_estimate TYPE ty_pr_release_urgency
        VALUE 'NO_ESTIMATE',
      c_pr_urgency_overdue TYPE ty_pr_release_urgency
        VALUE 'OVERDUE',
      c_pr_urgency_due_today TYPE ty_pr_release_urgency
        VALUE 'DUE_TODAY',
      c_pr_urgency_upcoming TYPE ty_pr_release_urgency
        VALUE 'UPCOMING',
      c_repl_days_origin_info_record TYPE ty_lead_time_origin
        VALUE 'INFO_RECORD',
      c_repl_days_origin_caller TYPE ty_lead_time_origin
        VALUE 'CALLER',
      c_repl_days_origin_material TYPE ty_lead_time_origin
        VALUE 'MATERIAL',
      c_repl_days_origin_none TYPE ty_lead_time_origin
        VALUE 'NONE'.
    TYPES:
      BEGIN OF ty_component,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
        movement_type      TYPE resb-bwart,
        required_date      TYPE resb-bdter,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
        open_quantity      TYPE resb-bdmng,
        unit               TYPE resb-meins,
    END OF ty_component.
    TYPES ty_components TYPE STANDARD TABLE OF ty_component WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_component_allocation_policy,
        reservation_number        TYPE resb-rsnum,
        reservation_item          TYPE resb-rspos,
        priority                  TYPE i,
        require_full_quantity     TYPE abap_bool,
        minimum_coverage_pct      TYPE zcl_stock_service=>ty_minimum_coverage_pct,
        allow_location_fallback   TYPE abap_bool,
        allow_batch_fallback      TYPE abap_bool,
        override_storage_location TYPE abap_bool,
        storage_location          TYPE mard-lgort,
        override_required_date    TYPE abap_bool,
        required_date             TYPE resb-bdter,
        override_open_quantity    TYPE abap_bool,
        open_quantity             TYPE resb-bdmng,
        override_batch            TYPE abap_bool,
        batch                     TYPE mchb-charg,
        minimum_shelf_life_days   TYPE i,
        require_known_expiry      TYPE abap_bool,
      END OF ty_component_allocation_policy.
    TYPES ty_component_allocation_policies TYPE STANDARD TABLE OF
      ty_component_allocation_policy WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_comp_location_priority,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        storage_location   TYPE mard-lgort,
        priority_rank      TYPE i,
      END OF ty_comp_location_priority.

    TYPES ty_comp_location_priorities TYPE STANDARD TABLE OF
      ty_comp_location_priority WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_comp_location_candidate,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        storage_location   TYPE mard-lgort,
      END OF ty_comp_location_candidate.
    TYPES ty_comp_location_candidates TYPE STANDARD TABLE OF
      ty_comp_location_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_comp_batch_priority,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        batch              TYPE mchb-charg,
        priority_rank      TYPE i,
      END OF ty_comp_batch_priority.

    TYPES ty_comp_batch_priorities TYPE STANDARD TABLE OF
      ty_comp_batch_priority WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_comp_batch_candidate,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        batch              TYPE mchb-charg,
      END OF ty_comp_batch_candidate.
    TYPES ty_comp_batch_candidates TYPE STANDARD TABLE OF
      ty_comp_batch_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_component_selection,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_component_selection.
    TYPES ty_component_selections TYPE STANDARD TABLE OF
      ty_component_selection WITH EMPTY KEY.
    TYPES ty_component_issue_keys TYPE STANDARD TABLE OF
      ty_component_selection WITH EMPTY KEY.
    TYPES ty_component_return_keys TYPE STANDARD TABLE OF
      ty_component_selection WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_component_local_estimate,
        allocation_sequence       TYPE i,
        allocation_sequence_scope TYPE ty_comp_seq_scope,
        requested_quantity        TYPE mard-labst,
        available_quantity        TYPE mard-labst,
        allocated_quantity        TYPE mard-labst,
        shortfall_quantity        TYPE mard-labst,
        minimum_coverage_pct      TYPE zcl_stock_service=>ty_minimum_coverage_pct,
        minimum_coverage_rejected TYPE abap_bool,
        allocation_outcome        TYPE c LENGTH 1,
        allocation_coverage_pct   TYPE zcl_stock_service=>ty_allocation_coverage_pct,
      END OF ty_component_local_estimate.
    TYPES:
      BEGIN OF ty_component_check,
        component                      TYPE ty_component,
        allocation_policy              TYPE ty_component_allocation_policy,
        effective_storage_location     TYPE mard-lgort,
        effective_required_date        TYPE resb-bdter,
        effective_open_quantity        TYPE resb-bdmng,
        effective_batch                TYPE mchb-charg,
        location_fallback_used         TYPE abap_bool,
        batch_fallback_used            TYPE abap_bool,
        base_unit                      TYPE mara-meins,
        requested_base_quantity        TYPE mard-labst,
        cumulative_base_quantity       TYPE mard-labst,
        confirmed_base_quantity        TYPE mard-labst,
        unconfirmed_base_quantity      TYPE mard-labst,
        component_confirmed_quantity   TYPE mard-labst,
        component_unconfirmed_quantity TYPE mard-labst,
        is_fully_confirmed             TYPE abap_bool,
        local_estimate                 TYPE ty_component_local_estimate,
        component_local_estimate       TYPE ty_component_local_estimate,
        batch_allocations              TYPE
          zcl_stock_service=>ty_scoped_component_batch_splits,
        location_allocations           TYPE
          zcl_stock_service=>ty_scoped_component_location_splits,
        atp_result                     TYPE zif_material_availability_api=>ty_result,
      END OF ty_component_check.
    TYPES ty_component_checks TYPE STANDARD TABLE OF
      ty_component_check WITH EMPTY KEY.
    TYPES ty_component_atp_check TYPE ty_component_check.
    TYPES ty_component_atp_checks TYPE ty_component_checks.
    TYPES:
      BEGIN OF ty_component_order_readiness,
        production_order            TYPE resb-aufnr,
        open_component_count        TYPE i,
        covered_component_count     TYPE i,
        short_component_count       TYPE i,
        zero_demand_component_count TYPE i,
        requested_base_quantity     TYPE mard-labst,
        allocated_base_quantity     TYPE mard-labst,
        shortfall_base_quantity     TYPE mard-labst,
        first_required_date         TYPE resb-bdter,
        last_required_date          TYPE resb-bdter,
        first_local_shortage_date   TYPE resb-bdter,
        is_locally_ready            TYPE abap_bool,
      END OF ty_component_order_readiness.
    TYPES ty_component_order_readinesses TYPE STANDARD TABLE OF
      ty_component_order_readiness WITH EMPTY KEY.
    TYPES ty_component_order_numbers TYPE SORTED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_component_shortage,
        material                   TYPE mard-matnr,
        plant                      TYPE mard-werks,
        base_unit                  TYPE mara-meins,
        required_date              TYPE resb-bdter,
        component_count            TYPE i,
        short_component_count      TYPE i,
        affected_order_count       TYPE i,
        affected_production_orders TYPE ty_component_order_numbers,
        requested_base_quantity    TYPE mard-labst,
        allocated_base_quantity    TYPE mard-labst,
        shortfall_base_quantity    TYPE mard-labst,
      END OF ty_component_shortage.
    TYPES ty_component_shortages TYPE STANDARD TABLE OF
      ty_component_shortage WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_receipt,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        base_unit            TYPE mara-meins,
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
      BEGIN OF ty_planning_calendar_period,
        plant                TYPE marc-werks,
        planning_calendar_id TYPE marc-mrppp,
        start_date           TYPE d,
        end_date             TYPE d,
      END OF ty_planning_calendar_period.
    TYPES ty_planning_calendar_periods TYPE STANDARD TABLE OF
      ty_planning_calendar_period WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_resolved_lot_size_period,
        plant              TYPE marc-werks,
        lot_size_procedure TYPE marc-disls,
        start_date         TYPE d,
        end_date           TYPE d,
      END OF ty_resolved_lot_size_period.
    TYPES ty_resolved_lot_size_periods TYPE STANDARD TABLE OF
      ty_resolved_lot_size_period WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_projected_receipt_use,
        receipt_date         TYPE d,
        quantity             TYPE mard-labst,
        source_type          TYPE c LENGTH 16,
        source_document      TYPE c LENGTH 35,
        source_item          TYPE c LENGTH 10,
        source_plant         TYPE eban-reswk,
        source_schedule_line TYPE eket-etenr,
      END OF ty_projected_receipt_use.
    TYPES ty_projected_receipt_uses TYPE STANDARD TABLE OF
      ty_projected_receipt_use WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_replenishment_policy,
        lot_size_procedure            TYPE marc-disls,
        planning_calendar_id          TYPE marc-mrppp,
        procurement_type              TYPE marc-beskz,
        special_procurement_key       TYPE marc-sobsl,
        material                      TYPE mard-matnr,
        plant                         TYPE mard-werks,
        base_unit                     TYPE mara-meins,
        factory_calendar_id           TYPE t001w-fabkl,
        planned_delivery_days         TYPE marc-plifz,
        source_vendor                 TYPE eina-lifnr,
        source_purchasing_org         TYPE eine-ekorg,
        source_info_record            TYPE eina-infnr,
        source_agreement              TYPE eord-ebeln,
        source_agreement_item         TYPE eord-ebelp,
        source_category               TYPE eina-esokz,
        source_planned_delivery_days  TYPE eine-aplfz,
        goods_receipt_processing_days TYPE marc-webaz,
        purchasing_processing_days    TYPE t399d-bzteK,
        minimum_base_quantity         TYPE mard-labst,
        maximum_base_quantity         TYPE mard-labst,
        maximum_stock_quantity        TYPE mard-labst,
        fixed_base_quantity           TYPE mard-labst,
        order_multiple_base_quantity  TYPE mard-labst,
        rounding_profile              TYPE marc-rdprf,
      END OF ty_replenishment_policy.
    TYPES ty_replenishment_policies TYPE STANDARD TABLE OF
      ty_replenishment_policy WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_comp_replenishment,
        material                       TYPE mard-matnr,
        plant                          TYPE mard-werks,
        base_unit                      TYPE mara-meins,
        required_date                  TYPE resb-bdter,
        lot_size_period_start          TYPE d,
        lot_size_period_end            TYPE d,
        grouped_shortage_count         TYPE i,
        component_count                TYPE i,
        affected_order_count           TYPE i,
        affected_production_orders     TYPE ty_component_order_numbers,
        lot_size_procedure             TYPE marc-disls,
        planning_calendar_id           TYPE marc-mrppp,
        rounding_profile               TYPE marc-rdprf,
        policy_origin                  TYPE c LENGTH 12,
        procurement_type               TYPE marc-beskz,
        special_procurement_key        TYPE marc-sobsl,
        factory_calendar_id            TYPE t001w-fabkl,
        planned_delivery_days          TYPE marc-plifz,
        source_vendor                  TYPE eina-lifnr,
        source_purchasing_org          TYPE eine-ekorg,
        source_info_record             TYPE eina-infnr,
        source_agreement               TYPE eord-ebeln,
        source_agreement_item          TYPE eord-ebelp,
        source_category                TYPE eina-esokz,
        source_planned_delivery_days   TYPE eine-aplfz,
        lead_time_days_origin          TYPE ty_lead_time_origin,
        goods_receipt_processing_days  TYPE marc-webaz,
        purchasing_processing_days     TYPE t399d-bzteK,
        estimated_delivery_date        TYPE d,
        latest_purchase_order_date     TYPE d,
        latest_pr_release_date         TYPE d,
        as_of_date                     TYPE d,
        pr_release_is_overdue          TYPE abap_bool,
        pr_release_days_overdue        TYPE i,
        pr_release_urgency             TYPE ty_pr_release_urgency,
        lead_time_status               TYPE ty_lead_time_status,
        shortfall_base_quantity        TYPE mard-labst,
        planning_shortfall_qty         TYPE mard-labst,
        projected_receipt_used_qty     TYPE mard-labst,
        projected_receipt_uses         TYPE ty_projected_receipt_uses,
        prior_surplus_used_qty         TYPE mard-labst,
        minimum_base_quantity          TYPE mard-labst,
        maximum_base_quantity          TYPE mard-labst,
        maximum_stock_quantity         TYPE mard-labst,
        fixed_base_quantity            TYPE mard-labst,
        order_multiple_base_quantity   TYPE mard-labst,
        suggested_base_quantity        TYPE mard-labst,
        suggested_receipt_count        TYPE int8,
        final_receipt_base_quantity    TYPE mard-labst,
        rounding_surplus_base_quantity TYPE mard-labst,
      END OF ty_comp_replenishment.
    TYPES ty_comp_replenishments TYPE STANDARD TABLE OF
      ty_comp_replenishment WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_component_order_atp_summary,
        production_order          TYPE resb-aufnr,
        material                  TYPE mard-matnr,
        plant                     TYPE mard-werks,
        base_unit                 TYPE mara-meins,
        component_count           TYPE i,
        fully_confirmed_count     TYPE i,
        partially_confirmed_count TYPE i,
        unconfirmed_count         TYPE i,
        first_required_date       TYPE resb-bdter,
        last_required_date        TYPE resb-bdter,
        first_unconfirmed_date    TYPE resb-bdter,
        requested_base_quantity   TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        is_split_fully_confirmed  TYPE abap_bool,
      END OF ty_component_order_atp_summary.
    TYPES ty_component_order_atp_summaries TYPE STANDARD TABLE OF
      ty_component_order_atp_summary WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_request,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        quantity           TYPE resb-bdmng,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
      END OF ty_issue_request.
    TYPES ty_issue_requests TYPE STANDARD TABLE OF ty_issue_request
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_issue_request,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        quantity           TYPE resb-bdmng,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
      END OF ty_bulk_issue_request.
    TYPES ty_bulk_issue_requests TYPE STANDARD TABLE OF ty_bulk_issue_request
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_component_issue_item,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        movement_result    TYPE zif_goods_movement_api=>ty_result,
        is_attempted       TYPE abap_bool,
        is_skipped         TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_component_issue_item.
    TYPES ty_bulk_component_issue_items TYPE STANDARD TABLE OF
      ty_bulk_component_issue_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_component_issue_result,
        items              TYPE ty_bulk_component_issue_items,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_component_issue_result.
    TYPES:
      BEGIN OF ty_issue_request_in_unit,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        quantity           TYPE resb-bdmng,
        unit               TYPE mara-meins,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
      END OF ty_issue_request_in_unit.
    TYPES ty_issue_requests_in_unit TYPE STANDARD TABLE OF
      ty_issue_request_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_issue_request_in_unit,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        quantity           TYPE resb-bdmng,
        unit               TYPE mara-meins,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
      END OF ty_bulk_issue_request_in_unit.
    TYPES ty_bulk_issue_requests_in_unit TYPE STANDARD TABLE OF
      ty_bulk_issue_request_in_unit WITH EMPTY KEY.
    TYPES ty_return_request TYPE ty_issue_request.
    TYPES ty_return_requests TYPE STANDARD TABLE OF ty_return_request
      WITH EMPTY KEY.
    TYPES ty_return_request_in_unit TYPE ty_issue_request_in_unit.
    TYPES ty_return_requests_in_unit TYPE STANDARD TABLE OF
      ty_return_request_in_unit WITH EMPTY KEY.
    TYPES ty_bulk_return_request TYPE ty_bulk_issue_request.
    TYPES ty_bulk_return_requests TYPE STANDARD TABLE OF
      ty_bulk_return_request WITH EMPTY KEY.
    TYPES ty_bulk_return_request_in_unit TYPE
      ty_bulk_issue_request_in_unit.
    TYPES ty_bulk_return_requests_in_unit TYPE STANDARD TABLE OF
      ty_bulk_return_request_in_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_return_item,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        movement_result    TYPE zif_goods_movement_api=>ty_result,
        is_attempted       TYPE abap_bool,
        is_skipped         TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_return_item.
    TYPES ty_bulk_return_items TYPE STANDARD TABLE OF ty_bulk_return_item
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_return_result,
        items              TYPE ty_bulk_return_items,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_return_result.

    METHODS constructor
      IMPORTING
        io_repository             TYPE REF TO zif_prod_comp_repo OPTIONAL
        io_reservation_reader     TYPE REF TO zif_so_reservation_reader OPTIONAL
        io_goods_movement_api     TYPE REF TO zif_goods_movement_api OPTIONAL
        io_stock_service          TYPE REF TO zcl_stock_service OPTIONAL
        io_uom_converter          TYPE REF TO zif_material_uom_converter OPTIONAL
        io_repl_policy_repo       TYPE REF TO zif_replenishment_policy_repo OPTIONAL
        io_planning_calendar_repo TYPE REF TO zif_planning_calendar_repo OPTIONAL
        io_factory_calendar_api   TYPE REF TO zif_factory_calendar_api OPTIONAL.

    METHODS get_open_components
      IMPORTING
        iv_production_order  TYPE resb-aufnr
      RETURNING
        VALUE(rt_components) TYPE ty_components
      RAISING
        zcx_invalid_production_order.

    METHODS get_open_components_bulk
      IMPORTING
        it_production_orders TYPE zif_prod_comp_repo=>ty_production_orders
      RETURNING
        VALUE(rt_components) TYPE ty_components
      RAISING
        zcx_invalid_production_order.

    METHODS preview_components_atp_bulk
      IMPORTING
        it_production_orders           TYPE zif_prod_comp_repo=>ty_production_orders
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
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
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_atp_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS preview_components_atp
      IMPORTING
        iv_production_order            TYPE resb-aufnr
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
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
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_atp_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS preview_components_stock_bulk
      IMPORTING
        it_production_orders           TYPE zif_prod_comp_repo=>ty_production_orders
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
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
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS preview_scoped_components_bulk
      IMPORTING
        it_production_orders           TYPE zif_prod_comp_repo=>ty_production_orders
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS preview_scoped_components
      IMPORTING
        iv_production_order            TYPE resb-aufnr
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS preview_components_stock
      IMPORTING
        iv_production_order            TYPE resb-aufnr
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
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
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS summarize_component_readiness
      IMPORTING
        it_checks           TYPE ty_component_checks
      RETURNING
        VALUE(rt_readiness) TYPE ty_component_order_readinesses
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS summarize_component_shortages
      IMPORTING
        it_checks           TYPE ty_component_checks
      RETURNING
        VALUE(rt_shortages) TYPE ty_component_shortages
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS summarize_order_atp
      IMPORTING
        it_checks           TYPE ty_component_atp_checks
      RETURNING
        VALUE(rt_summaries) TYPE ty_component_order_atp_summaries
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS suggest_comp_replenishment
      IMPORTING
        it_shortages                 TYPE ty_component_shortages
        it_policies                  TYPE ty_replenishment_policies
        it_projected_receipts        TYPE ty_projected_receipts OPTIONAL
        it_planning_calendar_periods TYPE ty_planning_calendar_periods OPTIONAL
        it_resolved_lot_size_periods TYPE ty_resolved_lot_size_periods OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_net_prior_surplus         TYPE abap_bool DEFAULT abap_false
        iv_week_start_weekday        TYPE i DEFAULT 1
      RETURNING
        VALUE(rt_suggestions)        TYPE ty_comp_replenishments
      RAISING
        zcx_invalid_stock_request.

    METHODS suggest_comp_repl_from_stock
      IMPORTING
        it_shortages                   TYPE ty_component_shortages
        it_policies                    TYPE ty_replenishment_policies
        it_planning_calendar_periods   TYPE ty_planning_calendar_periods OPTIONAL
        it_resolved_lot_size_periods   TYPE ty_resolved_lot_size_periods OPTIONAL
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
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_net_prior_surplus           TYPE abap_bool DEFAULT abap_false
        iv_week_start_weekday          TYPE i DEFAULT 1
      RETURNING
        VALUE(rt_suggestions)          TYPE ty_comp_replenishments
      RAISING
        zcx_invalid_stock_request.

    METHODS issue_components
      IMPORTING
        iv_production_order TYPE resb-aufnr
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_requests         TYPE ty_issue_requests
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS issue_components_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_bulk_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS preview_remaining_components
      IMPORTING
        it_component_keys    TYPE ty_component_issue_keys
      RETURNING
        VALUE(rt_components) TYPE ty_components
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS issue_remaining_components
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_component_keys TYPE ty_component_issue_keys
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS issue_remaining_bulk
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_component_keys  TYPE ty_component_issue_keys
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_component_issue_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS issue_components_in_unit
      IMPORTING
        iv_production_order TYPE resb-aufnr
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_requests         TYPE ty_issue_requests_in_unit
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS issue_components_bulk_in_unit
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_bulk_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS return_components
      IMPORTING
        iv_production_order TYPE resb-aufnr
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_requests         TYPE ty_return_requests
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS return_components_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_bulk_return_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS preview_returnable_components
      IMPORTING
        it_component_keys    TYPE ty_component_return_keys
      RETURNING
        VALUE(rt_components) TYPE ty_components
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS return_remaining_components
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_component_keys TYPE ty_component_return_keys
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS return_remaining_bulk
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_component_keys  TYPE ty_component_return_keys
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_return_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS return_components_in_unit
      IMPORTING
        iv_production_order TYPE resb-aufnr
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_requests         TYPE ty_return_requests_in_unit
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS return_components_bulk_in_unit
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_bulk_return_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS cancel_component_issue
      IMPORTING
        iv_material_document TYPE zif_goods_movement_api=>ty_material_document
        iv_fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year
        iv_posting_date      TYPE d OPTIONAL
        it_item_numbers      TYPE zif_goods_movement_api=>ty_material_document_items OPTIONAL
      RETURNING
        VALUE(rs_result)     TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel_component_issues_bulk
      IMPORTING
        it_requests        TYPE zcl_goods_movement_service=>ty_cancel_document_requests
        iv_atomic          TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE zcl_goods_movement_service=>ty_cancel_documents_result
      RAISING
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES ty_repl_policy_origin TYPE c LENGTH 12.
    TYPES:
      BEGIN OF ty_replenishment_timing,
        estimated_delivery_date    TYPE d,
        latest_purchase_order_date TYPE d,
        latest_pr_release_date     TYPE d,
        lead_time_status           TYPE ty_lead_time_status,
      END OF ty_replenishment_timing.

    TYPES:
      BEGIN OF ty_lot_size_period_bounds,
        start_date TYPE d,
        end_date   TYPE d,
      END OF ty_lot_size_period_bounds.

    TYPES:
      BEGIN OF ty_planning_shortage,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        base_unit                   TYPE mara-meins,
        required_date               TYPE resb-bdter,
        lot_size_period_start       TYPE d,
        lot_size_period_end         TYPE d,
        grouped_shortage_count      TYPE i,
        component_count             TYPE i,
        short_component_count       TYPE i,
        affected_order_count        TYPE i,
        affected_production_orders  TYPE ty_component_order_numbers,
        requested_base_quantity     TYPE mard-labst,
        allocated_base_quantity     TYPE mard-labst,
        shortfall_base_quantity     TYPE mard-labst,
        has_complete_order_identity TYPE abap_bool,
        input_index                 TYPE i,
        pre_receipt_used_milli      TYPE int8,
      END OF ty_planning_shortage.
    TYPES ty_planning_shortages TYPE STANDARD TABLE OF
      ty_planning_shortage WITH EMPTY KEY.
    TYPES ty_period_planning_shortages TYPE HASHED TABLE OF
      ty_planning_shortage WITH UNIQUE KEY material plant base_unit
        lot_size_period_start.
    TYPES:
      BEGIN OF ty_period_rcpt_use,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        base_unit             TYPE mara-meins,
        lot_size_period_start TYPE d,
        receipt_date          TYPE d,
        quantity              TYPE mard-labst,
        source_type           TYPE c LENGTH 16,
        source_document       TYPE c LENGTH 35,
        source_item           TYPE c LENGTH 10,
        source_plant          TYPE eban-reswk,
        source_schedule_line  TYPE eket-etenr,
      END OF ty_period_rcpt_use.
    TYPES ty_period_rcpt_uses TYPE STANDARD TABLE OF
      ty_period_rcpt_use WITH EMPTY KEY.

    METHODS get_month_period_bounds
      IMPORTING
        iv_date                 TYPE d
      RETURNING
        VALUE(rs_period_bounds) TYPE ty_lot_size_period_bounds.

    METHODS get_week_period_bounds
      IMPORTING
        iv_date                 TYPE d
        iv_week_start_weekday   TYPE i
      RETURNING
        VALUE(rs_period_bounds) TYPE ty_lot_size_period_bounds.

    METHODS round_replenishment_quantity
      IMPORTING
        iv_plant           TYPE rdpr-werks
        iv_profile         TYPE rdpr-rdprf
        iv_quantity        TYPE decfloat34
        it_profile_values  TYPE zif_replenishment_policy_repo=>ty_rounding_profiles
      RETURNING
        VALUE(rv_quantity) TYPE decfloat34
      RAISING
        zcx_invalid_stock_request.

    METHODS estimate_repl_timing
      IMPORTING
        iv_required_date              TYPE resb-bdter
        iv_policy_origin              TYPE ty_repl_policy_origin
        iv_procurement_type           TYPE marc-beskz
        iv_special_procurement_key    TYPE marc-sobsl
        iv_factory_calendar_id        TYPE t001w-fabkl
        iv_planned_delivery_days      TYPE marc-plifz
        iv_gr_processing_days         TYPE marc-webaz
        iv_purchasing_processing_days TYPE t399d-bzteK
      RETURNING
        VALUE(rs_timing)              TYPE ty_replenishment_timing.

    METHODS convert_component_quantity
      IMPORTING
        iv_source_quantity      TYPE resb-bdmng
        iv_numerator            TYPE marm-umrez
        iv_denominator          TYPE marm-umren
      RETURNING
        VALUE(rv_base_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS milli_to_stock_quantity
      IMPORTING
        iv_quantity_milli  TYPE int8
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_components_internal
      IMPORTING
        it_production_orders           TYPE zif_prod_comp_repo=>ty_production_orders
        it_excluded_reservations       TYPE
          zif_stock_repository=>ty_reservation_keys OPTIONAL
        it_projected_batch_receipts    TYPE zcl_stock_service=>ty_dated_batch_receipts OPTIONAL
        it_projected_location_receipts TYPE zcl_stock_service=>ty_dated_location_receipts OPTIONAL
        it_allocation_policies         TYPE ty_component_allocation_policies OPTIONAL
        it_storage_location_priority   TYPE zcl_stock_service=>ty_storage_locations OPTIONAL

        it_comp_location_priorities    TYPE ty_comp_location_priorities OPTIONAL
        it_comp_location_candidates    TYPE ty_comp_location_candidates OPTIONAL

        it_comp_batch_priorities       TYPE ty_comp_batch_priorities OPTIONAL
        it_comp_batch_candidates       TYPE ty_comp_batch_candidates OPTIONAL
        iv_check_atp                   TYPE abap_bool
        iv_check_rule                  TYPE zif_material_availability_api=>ty_check_rule
        iv_include_po_receipts         TYPE abap_bool
        iv_include_po_confirmations    TYPE abap_bool
        iv_include_sto_in_transit      TYPE abap_bool
        iv_include_unissued_sto        TYPE abap_bool
        iv_subtract_unissued_sto       TYPE abap_bool
        iv_include_prod_receipts       TYPE abap_bool
        iv_include_pr_receipts         TYPE abap_bool
        iv_include_sto_pr_receipts     TYPE abap_bool
        iv_include_planned_receipts    TYPE abap_bool
        iv_include_fixed_planned       TYPE abap_bool
        iv_include_sched_agmt_receipts TYPE abap_bool
        iv_protect_safety_stock        TYPE abap_bool
      RETURNING
        VALUE(rt_checks)               TYPE ty_component_checks
      RAISING
        zcx_invalid_production_order
        zcx_invalid_stock_request.

    METHODS post_component_issues_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_bulk_issue_requests
        it_components    TYPE ty_components
        iv_test_run      TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    METHODS post_component_returns_bulk
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_bulk_return_requests
        it_components    TYPE zif_prod_comp_repo=>ty_reservation_items
        iv_test_run      TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

    TYPES:
      BEGIN OF ty_component_key,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_component_key.
    TYPES:
      BEGIN OF ty_component_reservation_key,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
      END OF ty_component_reservation_key.
    TYPES:
      BEGIN OF ty_component_unit_ratio,
        material    TYPE mard-matnr,
        source_unit TYPE mara-meins,
        ratio       TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_component_unit_ratio.
    TYPES:
      BEGIN OF ty_component_shortage_order_key,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        base_unit        TYPE mara-meins,
        required_date    TYPE resb-bdter,
        production_order TYPE resb-aufnr,
      END OF ty_component_shortage_order_key.
    TYPES ty_component_shortage_order_keys TYPE HASHED TABLE OF
      ty_component_shortage_order_key WITH UNIQUE KEY material plant
        base_unit required_date production_order.
    TYPES ty_component_unit_ratios TYPE HASHED TABLE OF
      ty_component_unit_ratio WITH UNIQUE KEY material source_unit.
    TYPES:
      BEGIN OF ty_component_atp_day,
        request_id                   TYPE c LENGTH 30,
        material                     TYPE mard-matnr,
        plant                        TYPE mard-werks,
        base_unit                    TYPE mara-meins,
        required_date                TYPE resb-bdter,
        date_quantity                TYPE mard-labst,
        cumulative_quantity          TYPE mard-labst,
        cum_confirmed_quantity       TYPE mard-labst,
        cum_unconfirmed_quantity     TYPE mard-labst,
        confirmed_remaining_quantity TYPE mard-labst,
        local_remaining_quantity     TYPE mard-labst,
        local_estimate               TYPE zcl_stock_service=>ty_dated_allocation,
        atp_result                   TYPE zif_material_availability_api=>ty_result,
      END OF ty_component_atp_day.
    TYPES ty_component_atp_days TYPE SORTED TABLE OF ty_component_atp_day
      WITH UNIQUE KEY material plant base_unit required_date.

    DATA mo_repository TYPE REF TO zif_prod_comp_repo.
    DATA mo_issue_service TYPE REF TO zcl_reservation_issue_service.
    DATA mo_goods_movement_service TYPE REF TO zcl_goods_movement_service.
    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
    DATA mo_repl_policy_repo TYPE REF TO
      zif_replenishment_policy_repo.
    DATA mo_planning_calendar_repo TYPE REF TO
      zif_planning_calendar_repo.
    DATA mo_factory_calendar_api TYPE REF TO zif_factory_calendar_api.

    METHODS sum_stock_quantities
      IMPORTING
        iv_left_quantity   TYPE mard-labst
        iv_right_quantity  TYPE mard-labst
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_prod_comp_service IMPLEMENTATION.

  METHOD constructor.
    IF io_repository IS BOUND.
      mo_repository = io_repository.
    ELSE.
      mo_repository = NEW zcl_prod_comp_repo( ).
    ENDIF.
    IF io_uom_converter IS BOUND.
      mo_uom_converter = io_uom_converter.
    ELSE.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.
    IF io_stock_service IS BOUND.
      mo_stock_service = io_stock_service.
    ELSE.
      mo_stock_service = NEW zcl_stock_service(
        io_stock_repository = NEW zcl_mard_stock_repository( )
        io_uom_converter    = mo_uom_converter ).
    ENDIF.
    DATA lo_goods_movement_api TYPE REF TO zif_goods_movement_api.
    IF io_goods_movement_api IS BOUND.
      lo_goods_movement_api = io_goods_movement_api.
    ELSE.
      lo_goods_movement_api = NEW zcl_bapi_goods_movement_api( ).
    ENDIF.
    mo_issue_service = NEW zcl_reservation_issue_service(
      io_reservation_reader = io_reservation_reader
      io_goods_movement_api = lo_goods_movement_api ).
    mo_goods_movement_service = NEW zcl_goods_movement_service(
      io_api = lo_goods_movement_api ).
    IF io_repl_policy_repo IS BOUND.
      mo_repl_policy_repo = io_repl_policy_repo.
    ELSE.
      mo_repl_policy_repo = NEW zcl_marc_repl_policy_repo( ).
    ENDIF.
    IF io_planning_calendar_repo IS BOUND.
      mo_planning_calendar_repo = io_planning_calendar_repo.
    ELSE.
      mo_planning_calendar_repo =
        NEW zcl_t439i_cal_period_repo( ).
    ENDIF.
    IF io_factory_calendar_api IS BOUND.
      mo_factory_calendar_api = io_factory_calendar_api.
    ELSE.
      mo_factory_calendar_api = NEW zcl_sap_factory_calendar( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_open_components.
    IF iv_production_order IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    APPEND iv_production_order TO lt_production_orders.
    DATA(lt_all_components) = get_open_components_bulk(
      it_production_orders = lt_production_orders ).

    LOOP AT lt_all_components INTO DATA(ls_component)
        WHERE production_order = iv_production_order.
      APPEND ls_component TO rt_components.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_open_components_bulk.
    DATA lv_open_quantity TYPE resb-bdmng.
    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.

    IF it_production_orders IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      IF lv_production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      INSERT lv_production_order INTO TABLE lt_seen_orders.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
    ENDLOOP.

    DATA(lt_items) = mo_repository->get_components_bulk(
      it_production_orders = it_production_orders ).

    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE lt_seen_orders WITH TABLE KEY
        table_line = ls_item-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_item-is_deleted <> space
          OR ls_item-is_final_issue = abap_true
          OR ls_item-reservation_number IS INITIAL
          OR ls_item-reservation_item IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_open_quantity = zcl_stock_avail_qty_calc=>calculate_open_res_qty(
        iv_required_quantity  = ls_item-required_quantity
        iv_withdrawn_quantity = ls_item-withdrawn_quantity ).
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        production_order   = ls_item-production_order
        reservation_number = ls_item-reservation_number
        reservation_item   = ls_item-reservation_item
        material           = ls_item-material
        plant              = ls_item-plant
        storage_location   = ls_item-storage_location
        batch              = ls_item-batch
        movement_type      = ls_item-movement_type
        required_date      = ls_item-required_date
        required_quantity  = ls_item-required_quantity
        withdrawn_quantity = ls_item-withdrawn_quantity
        open_quantity      = lv_open_quantity
        unit               = ls_item-unit ) TO rt_components.
    ENDLOOP.

    SORT rt_components BY production_order reservation_number reservation_item.
  ENDMETHOD.

  METHOD sum_stock_quantities.
    DATA lv_total TYPE decfloat34.

    IF iv_left_quantity < 0 OR iv_right_quantity < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    lv_total = CONV decfloat34( iv_left_quantity )
      + CONV decfloat34( iv_right_quantity ).
    TRY.
        rv_quantity = CONV mard-labst( lv_total ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD convert_component_quantity.
    IF iv_numerator <= 0 OR iv_denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    TRY.
        rv_base_quantity = CONV mard-labst(
          CONV decfloat34( iv_source_quantity )
          * CONV decfloat34( iv_numerator )
          / CONV decfloat34( iv_denominator ) ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
    IF iv_source_quantity <> 0 AND rv_base_quantity IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD milli_to_stock_quantity.
    TRY.
        rv_quantity = CONV mard-labst(
          CONV decfloat34( CONV string( iv_quantity_milli ) ) / 1000 ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
  ENDMETHOD.

  METHOD preview_components_internal.
    TYPES:
      BEGIN OF ty_component_material_plant,
        material              TYPE mard-matnr,
        plant                 TYPE mard-werks,
        through_date          TYPE d,
        use_scoped            TYPE abap_bool,
        has_allocation_policy TYPE abap_bool,
      END OF ty_component_material_plant,
      ty_component_material_plants TYPE SORTED TABLE OF
        ty_component_material_plant WITH UNIQUE KEY material plant.
    TYPES:
      BEGIN OF ty_comp_seq_row,
        request_id          TYPE c LENGTH 30,
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        required_date       TYPE resb-bdter,
        input_index         TYPE i,
        allocation_sequence TYPE i,
      END OF ty_comp_seq_row.
    TYPES ty_comp_seq_rows TYPE STANDARD TABLE OF
      ty_comp_seq_row WITH EMPTY KEY.
    DATA lt_components TYPE ty_components.
    DATA lt_unit_ratios TYPE ty_component_unit_ratios.
    DATA lt_projected_scope_keys TYPE ty_component_material_plants.
    DATA lt_automatic_receipts TYPE zif_stock_repository=>ty_projected_receipts.
    DATA lt_scoped_batch_receipts TYPE
      zcl_stock_service=>ty_dated_batch_receipts.
    DATA lt_scoped_location_receipts TYPE
      zcl_stock_service=>ty_dated_location_receipts.
    DATA lt_excluded_reservations TYPE
      zif_stock_repository=>ty_reservation_keys.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_excluded_reservations TYPE HASHED TABLE OF
      zif_stock_repository=>ty_reservation_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_allocation_policies TYPE HASHED TABLE OF
      ty_component_allocation_policy
      WITH UNIQUE KEY reservation_number reservation_item.

    DATA lt_seen_comp_loc_priorities TYPE HASHED TABLE OF
      ty_comp_location_priority WITH UNIQUE KEY
        reservation_number reservation_item storage_location.
    DATA lt_seen_comp_loc_candidates TYPE HASHED TABLE OF
      ty_comp_location_candidate WITH UNIQUE KEY
        reservation_number reservation_item storage_location.

    DATA lt_seen_comp_batch_prios TYPE HASHED TABLE OF
      ty_comp_batch_priority WITH UNIQUE KEY
        reservation_number reservation_item batch.
    DATA lt_seen_comp_batch_cands TYPE HASHED TABLE OF
      ty_comp_batch_candidate WITH UNIQUE KEY
        reservation_number reservation_item batch.

    DATA lt_stock_loc_priorities TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_stock_loc_candidates TYPE
      zcl_stock_service=>ty_request_location_candidates.

    DATA lt_stock_batch_priorities TYPE
      zcl_stock_service=>ty_request_batch_priorities.
    DATA lt_stock_batch_candidates TYPE
      zcl_stock_service=>ty_request_batch_candidates.
    DATA lt_atp_days TYPE ty_component_atp_days.
    DATA lt_local_demands TYPE zcl_stock_service=>ty_dated_demands.
    DATA lt_local_estimates TYPE zcl_stock_service=>ty_dated_allocations.
    DATA lt_scoped_demands TYPE zcl_stock_service=>ty_scoped_component_demands.
    DATA lt_comp_seq_rows TYPE
      ty_comp_seq_rows.
    DATA lt_scoped_use_demands TYPE
      zcl_stock_service=>ty_scoped_component_demands.
    DATA lt_scoped_allocations TYPE
      zcl_stock_service=>ty_scoped_component_allocations.
    DATA lt_component_batch_splits TYPE
      zcl_stock_service=>ty_scoped_component_batch_splits.
    DATA lt_component_location_splits TYPE
      zcl_stock_service=>ty_scoped_component_location_splits.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_confirmed_quantity TYPE mard-labst.
    DATA lv_date_confirmed_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    DATA lv_local_request_id TYPE c LENGTH 30.
    DATA lv_comp_allocation_seq TYPE i.
    DATA lv_component_sequence_scope TYPE
      ty_comp_seq_scope.
    DATA lv_component_floor_rejected TYPE abap_bool.
    DATA lv_component_request_id TYPE c LENGTH 30.
    DATA lv_component_index TYPE i.
    DATA lv_component_storage_location TYPE mard-lgort.
    DATA lv_component_batch TYPE mchb-charg.
    DATA lv_component_required_date TYPE resb-bdter.
    DATA lv_component_open_quantity TYPE resb-bdmng.
    DATA lv_has_location_fallback TYPE abap_bool.
    DATA lv_has_component_scope TYPE abap_bool.
    DATA lv_use_scoped_allocation TYPE abap_bool.
    DATA lv_auto_receipt_options TYPE abap_bool.
    DATA lv_component_uses_scoped TYPE abap_bool.
    DATA lv_fallback_used TYPE abap_bool.
    DATA lv_batch_fallback_used TYPE abap_bool.
    DATA lv_component_available TYPE mard-labst.
    DATA lv_component_allocated TYPE mard-labst.
    DATA lv_component_shortfall TYPE mard-labst.
    DATA lv_group_available TYPE mard-labst.
    DATA lv_group_allocated TYPE mard-labst.
    DATA lv_group_shortfall TYPE mard-labst.
    DATA ls_component_allocation_policy TYPE
      ty_component_allocation_policy.
    DATA ls_component_group_estimate TYPE ty_component_local_estimate.
    FIELD-SYMBOLS <ls_atp_day> TYPE ty_component_atp_day.
    FIELD-SYMBOLS <ls_projected_scope_key>
      TYPE ty_component_material_plant.

    IF iv_include_sto_pr_receipts <> abap_true
        AND iv_include_sto_pr_receipts <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_include_planned_receipts <> abap_true
        AND iv_include_planned_receipts <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_include_fixed_planned <> abap_true
        AND iv_include_fixed_planned <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_include_sched_agmt_receipts <> abap_true
        AND iv_include_sched_agmt_receipts <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_include_po_confirmations <> abap_true
          AND iv_include_po_confirmations <> abap_false )
        OR ( iv_include_po_receipts = abap_true
          AND iv_include_po_confirmations = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
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
          AND iv_include_pr_receipts <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_allocation_policies IS NOT INITIAL
        AND iv_subtract_unissued_sto = abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( it_projected_batch_receipts IS NOT INITIAL
          OR it_projected_location_receipts IS NOT INITIAL )
        AND ( iv_include_po_receipts = abap_true
          OR iv_include_po_confirmations = abap_true
          OR iv_include_sto_in_transit = abap_true
          OR iv_include_unissued_sto = abap_true
          OR iv_subtract_unissued_sto = abap_true
          OR iv_include_prod_receipts = abap_true
          OR iv_include_pr_receipts = abap_true
          OR iv_include_sto_pr_receipts = abap_true
          OR iv_include_planned_receipts = abap_true
          OR iv_include_fixed_planned = abap_true
          OR iv_include_sched_agmt_receipts = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_allocation_policies
        INTO DATA(ls_policy_input).
      IF ls_policy_input-reservation_number IS INITIAL
          OR ls_policy_input-reservation_item IS INITIAL
          OR ( ls_policy_input-require_full_quantity <> abap_true
            AND ls_policy_input-require_full_quantity <> abap_false )
          OR ls_policy_input-minimum_coverage_pct < 0
          OR ls_policy_input-minimum_coverage_pct > 100
          OR ( ls_policy_input-allow_location_fallback <> abap_true
            AND ls_policy_input-allow_location_fallback <> abap_false )
          OR ( ls_policy_input-allow_batch_fallback <> abap_true
            AND ls_policy_input-allow_batch_fallback <> abap_false )
          OR ( ls_policy_input-override_storage_location <> abap_true
            AND ls_policy_input-override_storage_location <> abap_false )
          OR ( ls_policy_input-override_batch <> abap_true
            AND ls_policy_input-override_batch <> abap_false )
          OR ( ls_policy_input-override_required_date <> abap_true
            AND ls_policy_input-override_required_date <> abap_false )
          OR ( ls_policy_input-override_required_date = abap_false
            AND ls_policy_input-required_date IS NOT INITIAL )
          OR ( ls_policy_input-override_required_date = abap_true
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_policy_input-required_date ) <> abap_true )
          OR ( ls_policy_input-override_open_quantity <> abap_true
            AND ls_policy_input-override_open_quantity <> abap_false )
          OR ( ls_policy_input-override_open_quantity = abap_false
            AND ls_policy_input-open_quantity IS NOT INITIAL )
          OR ( ls_policy_input-override_open_quantity = abap_true
            AND ls_policy_input-open_quantity < 0 )
          OR ( ls_policy_input-override_storage_location = abap_false
            AND ls_policy_input-storage_location IS NOT INITIAL )
          OR ( ls_policy_input-override_batch = abap_false
            AND ls_policy_input-batch IS NOT INITIAL )
          OR ls_policy_input-minimum_shelf_life_days < 0
          OR ( ls_policy_input-require_known_expiry <> abap_true
            AND ls_policy_input-require_known_expiry <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_policy_input INTO TABLE lt_allocation_policies.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_excluded_reservations
        INTO DATA(ls_call_excl_reservation).
      IF ls_call_excl_reservation-reservation_number IS INITIAL
          OR ls_call_excl_reservation-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_call_excl_reservation
        INTO TABLE lt_seen_excluded_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_call_excl_reservation
        TO lt_excluded_reservations.
    ENDLOOP.

    lt_scoped_batch_receipts = it_projected_batch_receipts.
    lt_scoped_location_receipts = it_projected_location_receipts.

    lt_components = get_open_components_bulk(
      it_production_orders = it_production_orders ).

    LOOP AT lt_components INTO DATA(ls_component).
      CLEAR ls_component_allocation_policy.
      READ TABLE lt_allocation_policies
        INTO ls_component_allocation_policy
        WITH TABLE KEY reservation_number =
          ls_component-reservation_number
                       reservation_item = ls_component-reservation_item.
      lv_component_required_date = COND #(
        WHEN ls_component_allocation_policy-override_required_date
          = abap_true
        THEN ls_component_allocation_policy-required_date
        ELSE ls_component-required_date ).
      lv_component_open_quantity = COND #(
        WHEN ls_component_allocation_policy-override_open_quantity
          = abap_true
        THEN ls_component_allocation_policy-open_quantity
        ELSE ls_component-open_quantity ).
      IF ls_component-material IS INITIAL
          OR ls_component-plant IS INITIAL
          OR ls_component-unit IS INITIAL
          OR ls_component-reservation_number IS INITIAL
          OR ls_component-reservation_item IS INITIAL
          OR lv_component_open_quantity < 0
          OR zcl_date_validation=>is_valid_gregorian_date(
            lv_component_required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      DATA(ls_reservation_key) = VALUE zif_stock_repository=>ty_reservation_key(
        reservation_number = ls_component-reservation_number
        reservation_item   = ls_component-reservation_item ).
      INSERT ls_reservation_key INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      INSERT ls_reservation_key INTO TABLE
        lt_seen_excluded_reservations.
      IF sy-subrc = 0.
        APPEND ls_reservation_key TO lt_excluded_reservations.
      ENDIF.

      READ TABLE lt_unit_ratios INTO DATA(ls_unit_ratio_cache)
        WITH TABLE KEY material = ls_component-material
                       source_unit = ls_component-unit.
      IF sy-subrc = 0.
        DATA(ls_unit_ratio) = ls_unit_ratio_cache-ratio.
      ELSE.
        ls_unit_ratio = mo_uom_converter->get_material_unit_ratio(
          iv_material         = ls_component-material
          iv_alternative_unit = ls_component-unit ).
        IF ls_unit_ratio-is_successful <> abap_true
            OR ls_unit_ratio-base_unit IS INITIAL
            OR ls_unit_ratio-numerator <= 0
            OR ls_unit_ratio-denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          material    = ls_component-material
          source_unit = ls_component-unit
          ratio       = ls_unit_ratio ) INTO TABLE lt_unit_ratios.
      ENDIF.

      DATA(lv_base_quantity) = convert_component_quantity(
        iv_source_quantity = lv_component_open_quantity
        iv_numerator       = ls_unit_ratio-numerator
        iv_denominator     = ls_unit_ratio-denominator ).
      lv_component_index += 1.
      lv_component_request_id = |COMP_SCOPE_{ lv_component_index }|.
      APPEND VALUE #(
        request_id    = lv_component_request_id
        material      = ls_component-material
        plant         = ls_component-plant
        required_date = lv_component_required_date
        input_index   = lv_component_index )
        TO lt_comp_seq_rows.
      lv_component_storage_location = COND #(
        WHEN ls_component_allocation_policy-override_storage_location
          = abap_true
        THEN ls_component_allocation_policy-storage_location
        ELSE ls_component-storage_location ).
      lv_component_batch = COND #(
        WHEN ls_component_allocation_policy-override_batch = abap_true
        THEN ls_component_allocation_policy-batch
        ELSE ls_component-batch ).
      IF ls_component_allocation_policy-allow_location_fallback = abap_true
          AND lv_component_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_component_allocation_policy-allow_batch_fallback = abap_true
          AND lv_component_batch IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_component_allocation_policy-allow_location_fallback = abap_true.
        lv_has_location_fallback = abap_true.
      ENDIF.
      APPEND VALUE #(
        request_id              = lv_component_request_id
        material                = ls_component-material
        plant                   = ls_component-plant
        reservation_number      = ls_component-reservation_number
        reservation_item        = ls_component-reservation_item
        required_date           = lv_component_required_date
        priority                = ls_component_allocation_policy-priority
        require_full_quantity   =
          ls_component_allocation_policy-require_full_quantity
        minimum_coverage_pct    =
          ls_component_allocation_policy-minimum_coverage_pct
        allow_location_fallback =
          ls_component_allocation_policy-allow_location_fallback
        allow_batch_fallback    =
          ls_component_allocation_policy-allow_batch_fallback
        minimum_shelf_life_days =
          ls_component_allocation_policy-minimum_shelf_life_days
        require_known_expiry    =
          ls_component_allocation_policy-require_known_expiry
        storage_location        = lv_component_storage_location
        batch                   = lv_component_batch
        requested_quantity      = lv_base_quantity ) TO lt_scoped_demands.
      READ TABLE lt_projected_scope_keys ASSIGNING <ls_projected_scope_key>
        WITH TABLE KEY material = ls_component-material
                       plant = ls_component-plant.
      IF sy-subrc = 0.
        IF lv_component_required_date >
            <ls_projected_scope_key>-through_date.
          <ls_projected_scope_key>-through_date =
            lv_component_required_date.
        ENDIF.
        IF ls_component_allocation_policy-reservation_number IS NOT INITIAL.
          <ls_projected_scope_key>-use_scoped = abap_true.
          <ls_projected_scope_key>-has_allocation_policy = abap_true.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material              = ls_component-material
          plant                 = ls_component-plant
          through_date          = lv_component_required_date
          use_scoped            = COND #(
            WHEN ls_component_allocation_policy-reservation_number
              IS NOT INITIAL THEN abap_true
            ELSE abap_false )
          has_allocation_policy = COND #(
            WHEN ls_component_allocation_policy-reservation_number
              IS NOT INITIAL THEN abap_true
            ELSE abap_false ) )
          INTO TABLE lt_projected_scope_keys.
      ENDIF.
      IF ls_component-storage_location IS NOT INITIAL
          OR ls_component-batch IS NOT INITIAL.
        lv_has_component_scope = abap_true.
      ENDIF.
      READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
        WITH TABLE KEY material = ls_component-material
                       plant = ls_component-plant
                       base_unit = ls_unit_ratio-base_unit
                       required_date = lv_component_required_date.
      IF sy-subrc = 0.
        <ls_atp_day>-date_quantity = sum_stock_quantities(
          iv_left_quantity  = <ls_atp_day>-date_quantity
          iv_right_quantity = lv_base_quantity ).
      ELSE.
        INSERT VALUE #(
          material      = ls_component-material
          plant         = ls_component-plant
          base_unit     = ls_unit_ratio-base_unit
          required_date = lv_component_required_date
          date_quantity = lv_base_quantity ) INTO TABLE lt_atp_days.
      ENDIF.
    ENDLOOP.

    LOOP AT it_comp_location_candidates
        INTO DATA(ls_comp_location_candidate).
      IF ls_comp_location_candidate-reservation_number IS INITIAL
          OR ls_comp_location_candidate-reservation_item IS INITIAL
          OR ls_comp_location_candidate-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_comp_location_candidate
        INTO TABLE lt_seen_comp_loc_candidates.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_scoped_demands INTO DATA(ls_location_candidate_demand)
        WITH KEY reservation_number =
                   ls_comp_location_candidate-reservation_number
                 reservation_item =
                   ls_comp_location_candidate-reservation_item.
      IF sy-subrc <> 0
          OR ls_location_candidate_demand-allow_location_fallback
            <> abap_true
          OR ls_location_candidate_demand-storage_location =
            ls_comp_location_candidate-storage_location.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id       = ls_location_candidate_demand-request_id
        storage_location = ls_comp_location_candidate-storage_location )
        TO lt_stock_loc_candidates.
    ENDLOOP.

    LOOP AT it_comp_location_priorities
        INTO DATA(ls_comp_location_priority).
      IF ls_comp_location_priority-reservation_number IS INITIAL
          OR ls_comp_location_priority-reservation_item IS INITIAL
          OR ls_comp_location_priority-storage_location IS INITIAL
          OR ls_comp_location_priority-priority_rank <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_comp_location_priority INTO TABLE lt_seen_comp_loc_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_scoped_demands INTO DATA(ls_priority_component_demand)
        WITH KEY reservation_number =
                   ls_comp_location_priority-reservation_number
                 reservation_item =
                   ls_comp_location_priority-reservation_item.
      IF sy-subrc <> 0
          OR ls_priority_component_demand-allow_location_fallback
            <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id       = ls_priority_component_demand-request_id
        storage_location = ls_comp_location_priority-storage_location
        priority_rank    = ls_comp_location_priority-priority_rank )
        TO lt_stock_loc_priorities.
    ENDLOOP.


    LOOP AT it_comp_batch_candidates
        INTO DATA(ls_comp_batch_candidate).
      IF ls_comp_batch_candidate-reservation_number IS INITIAL
          OR ls_comp_batch_candidate-reservation_item IS INITIAL
          OR ls_comp_batch_candidate-batch IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_comp_batch_candidate INTO TABLE lt_seen_comp_batch_cands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_scoped_demands INTO DATA(ls_batch_candidate_demand)
        WITH KEY reservation_number =
                   ls_comp_batch_candidate-reservation_number
                 reservation_item = ls_comp_batch_candidate-reservation_item.
      IF sy-subrc <> 0
          OR ls_batch_candidate_demand-allow_batch_fallback <> abap_true
          OR ls_batch_candidate_demand-batch =
            ls_comp_batch_candidate-batch.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id = ls_batch_candidate_demand-request_id
        batch      = ls_comp_batch_candidate-batch )
        TO lt_stock_batch_candidates.
    ENDLOOP.

    LOOP AT it_comp_batch_priorities
        INTO DATA(ls_comp_batch_priority).
      IF ls_comp_batch_priority-reservation_number IS INITIAL
          OR ls_comp_batch_priority-reservation_item IS INITIAL
          OR ls_comp_batch_priority-batch IS INITIAL
          OR ls_comp_batch_priority-priority_rank <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_comp_batch_priority INTO TABLE lt_seen_comp_batch_prios.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_scoped_demands INTO DATA(ls_batch_priority_demand)
        WITH KEY reservation_number =
                   ls_comp_batch_priority-reservation_number
                 reservation_item = ls_comp_batch_priority-reservation_item.
      IF sy-subrc <> 0
          OR ls_batch_priority_demand-allow_batch_fallback <> abap_true
          OR ls_batch_priority_demand-batch =
            ls_comp_batch_priority-batch.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id    = ls_batch_priority_demand-request_id
        batch         = ls_comp_batch_priority-batch
        priority_rank = ls_comp_batch_priority-priority_rank )
        TO lt_stock_batch_priorities.
    ENDLOOP.

    LOOP AT lt_allocation_policies
        INTO DATA(ls_validated_allocation_policy).
      READ TABLE lt_seen_reservations TRANSPORTING NO FIELDS
        WITH TABLE KEY
          reservation_number =
            ls_validated_allocation_policy-reservation_number
          reservation_item =
            ls_validated_allocation_policy-reservation_item.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF it_storage_location_priority IS NOT INITIAL
        AND lv_has_location_fallback <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_include_po_receipts = abap_true
        OR iv_include_po_confirmations = abap_true
        OR iv_include_sto_in_transit = abap_true
        OR iv_include_unissued_sto = abap_true
        OR iv_include_prod_receipts = abap_true
        OR iv_include_pr_receipts = abap_true
        OR iv_include_sto_pr_receipts = abap_true
        OR iv_include_planned_receipts = abap_true
        OR iv_include_fixed_planned = abap_true
        OR iv_include_sched_agmt_receipts = abap_true.
      lv_auto_receipt_options = abap_true.
    ENDIF.

    IF iv_subtract_unissued_sto = abap_false
        AND ( iv_check_atp = abap_false
          OR it_allocation_policies IS NOT INITIAL
          OR it_projected_batch_receipts IS NOT INITIAL
          OR it_projected_location_receipts IS NOT INITIAL
          OR ( lv_has_component_scope = abap_true
            AND lv_auto_receipt_options = abap_true ) )
        AND ( lv_has_component_scope = abap_true
          OR it_allocation_policies IS NOT INITIAL
          OR it_projected_batch_receipts IS NOT INITIAL
          OR it_projected_location_receipts IS NOT INITIAL ).
      IF lv_has_component_scope = abap_true
          OR it_projected_batch_receipts IS NOT INITIAL
          OR it_projected_location_receipts IS NOT INITIAL.
        LOOP AT lt_projected_scope_keys ASSIGNING <ls_projected_scope_key>.
          <ls_projected_scope_key>-use_scoped = abap_true.
        ENDLOOP.
      ENDIF.
      IF lt_projected_scope_keys IS NOT INITIAL
          OR it_projected_batch_receipts IS NOT INITIAL
          OR it_projected_location_receipts IS NOT INITIAL.
        lv_use_scoped_allocation = abap_true.
      ENDIF.

      IF lv_auto_receipt_options = abap_true
          AND it_projected_batch_receipts IS INITIAL
          AND it_projected_location_receipts IS INITIAL.
        LOOP AT lt_projected_scope_keys ASSIGNING <ls_projected_scope_key>.
          lt_automatic_receipts = mo_stock_service->get_projected_receipts(
            iv_material                    = <ls_projected_scope_key>-material
            iv_plant                       = <ls_projected_scope_key>-plant
            iv_through_date                = <ls_projected_scope_key>-through_date
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
          LOOP AT lt_automatic_receipts INTO DATA(ls_automatic_receipt).
            IF ls_automatic_receipt-storage_location IS INITIAL.
              IF <ls_projected_scope_key>-has_allocation_policy = abap_true.
                RAISE EXCEPTION TYPE zcx_invalid_stock_request.
              ENDIF.
              <ls_projected_scope_key>-use_scoped = abap_false.
              EXIT.
            ENDIF.
            IF ls_automatic_receipt-batch IS INITIAL.
              APPEND VALUE #(
                material             = ls_automatic_receipt-material
                plant                = ls_automatic_receipt-plant
                storage_location     = ls_automatic_receipt-storage_location
                receipt_date         = ls_automatic_receipt-receipt_date
                base_quantity        = ls_automatic_receipt-quantity
                source_type          = ls_automatic_receipt-source_type
                source_document      = ls_automatic_receipt-source_document
                source_item          = ls_automatic_receipt-source_item
                source_plant         = ls_automatic_receipt-source_plant
                source_schedule_line =
                  ls_automatic_receipt-source_schedule_line )
                TO lt_scoped_location_receipts.
            ELSE.
              APPEND VALUE #(
                material             = ls_automatic_receipt-material
                plant                = ls_automatic_receipt-plant
                storage_location     = ls_automatic_receipt-storage_location
                batch                = ls_automatic_receipt-batch
                receipt_date         = ls_automatic_receipt-receipt_date
                base_quantity        = ls_automatic_receipt-quantity
                source_type          = ls_automatic_receipt-source_type
                source_document      = ls_automatic_receipt-source_document
                source_item          = ls_automatic_receipt-source_item
                source_plant         = ls_automatic_receipt-source_plant
                source_schedule_line =
                  ls_automatic_receipt-source_schedule_line )
                TO lt_scoped_batch_receipts.
            ENDIF.
          ENDLOOP.
          IF <ls_projected_scope_key>-use_scoped = abap_false.
            DELETE lt_scoped_batch_receipts
              WHERE material = <ls_projected_scope_key>-material
                AND plant = <ls_projected_scope_key>-plant.
            DELETE lt_scoped_location_receipts
              WHERE material = <ls_projected_scope_key>-material
                AND plant = <ls_projected_scope_key>-plant.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    LOOP AT lt_scoped_demands INTO DATA(ls_scoped_demand).
      READ TABLE lt_projected_scope_keys INTO DATA(ls_demand_scope_key)
        WITH TABLE KEY material = ls_scoped_demand-material
                       plant = ls_scoped_demand-plant.
      IF sy-subrc = 0 AND ls_demand_scope_key-use_scoped = abap_true.
        APPEND ls_scoped_demand TO lt_scoped_use_demands.
      ENDIF.
    ENDLOOP.

    IF lv_use_scoped_allocation = abap_true
        AND ( lt_scoped_use_demands IS NOT INITIAL
          OR it_projected_batch_receipts IS NOT INITIAL
          OR it_projected_location_receipts IS NOT INITIAL ).
      lt_scoped_allocations = mo_stock_service->allocate_component_stock(
        it_demands                     = lt_scoped_use_demands
        it_excluded_reservations       = lt_excluded_reservations
        it_projected_batch_receipts    = lt_scoped_batch_receipts
        it_projected_location_receipts = lt_scoped_location_receipts
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = lt_stock_loc_priorities
        it_request_location_candidates = lt_stock_loc_candidates
        it_request_batch_priorities    = lt_stock_batch_priorities
        it_request_batch_candidates    = lt_stock_batch_candidates
        iv_protect_safety_stock        = iv_protect_safety_stock ).
    ENDIF.

    SORT lt_comp_seq_rows BY material plant
      required_date input_index.
    CLEAR lv_comp_allocation_seq.
    LOOP AT lt_comp_seq_rows
        ASSIGNING FIELD-SYMBOL(<ls_component_sequence>).
      READ TABLE lt_projected_scope_keys INTO DATA(ls_sequence_scope)
        WITH TABLE KEY material = <ls_component_sequence>-material
                       plant = <ls_component_sequence>-plant.
      IF sy-subrc = 0 AND ls_sequence_scope-use_scoped = abap_true.
        CONTINUE.
      ENDIF.
      ADD 1 TO lv_comp_allocation_seq.
      <ls_component_sequence>-allocation_sequence =
        lv_comp_allocation_seq.
    ENDLOOP.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      IF sy-tabix = 1
          OR <ls_atp_day>-material <> lv_previous_material
          OR <ls_atp_day>-plant <> lv_previous_plant
          OR <ls_atp_day>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
        CLEAR lv_previous_confirmed_quantity.
      ENDIF.
      lv_cumulative_quantity = sum_stock_quantities(
        iv_left_quantity  = lv_cumulative_quantity
        iv_right_quantity = <ls_atp_day>-date_quantity ).
      <ls_atp_day>-cumulative_quantity = lv_cumulative_quantity.

      IF iv_check_atp = abap_true
          AND lv_cumulative_quantity > 0.
        <ls_atp_day>-atp_result = mo_stock_service->check_atp_request(
          is_request = VALUE #(
            material           = <ls_atp_day>-material
            plant              = <ls_atp_day>-plant
            unit               = <ls_atp_day>-base_unit
            check_rule         = iv_check_rule
            required_date      = <ls_atp_day>-required_date
            requested_quantity = lv_cumulative_quantity ) ).
        DATA(ls_confirmation_split) =
          mo_stock_service->get_atp_confirmation_split(
            iv_requested_base_quantity = lv_cumulative_quantity
            iv_required_date           = <ls_atp_day>-required_date
            is_atp_result              = <ls_atp_day>-atp_result ).
        <ls_atp_day>-cum_confirmed_quantity =
          ls_confirmation_split-confirmed_base_quantity.
        <ls_atp_day>-cum_unconfirmed_quantity =
          ls_confirmation_split-unconfirmed_base_quantity.
        lv_date_confirmed_quantity =
          <ls_atp_day>-cum_confirmed_quantity
          - lv_previous_confirmed_quantity.
        IF lv_date_confirmed_quantity < 0.
          CLEAR lv_date_confirmed_quantity.
        ELSEIF lv_date_confirmed_quantity > <ls_atp_day>-date_quantity.
          lv_date_confirmed_quantity = <ls_atp_day>-date_quantity.
        ENDIF.
        <ls_atp_day>-confirmed_remaining_quantity =
          lv_date_confirmed_quantity.
        lv_previous_confirmed_quantity =
          <ls_atp_day>-cum_confirmed_quantity.
      ENDIF.

      lv_previous_material = <ls_atp_day>-material.
      lv_previous_plant = <ls_atp_day>-plant.
      lv_previous_unit = <ls_atp_day>-base_unit.
    ENDLOOP.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      lv_local_request_id = |COMP_ATP_{ sy-tabix }|.
      <ls_atp_day>-request_id = lv_local_request_id.
      READ TABLE lt_projected_scope_keys INTO DATA(ls_day_scope_key)
        WITH TABLE KEY material = <ls_atp_day>-material
                       plant = <ls_atp_day>-plant.
      IF sy-subrc <> 0 OR ls_day_scope_key-use_scoped <> abap_true.
        APPEND VALUE #(
          request_id         = lv_local_request_id
          material           = <ls_atp_day>-material
          plant              = <ls_atp_day>-plant
          required_date      = <ls_atp_day>-required_date
          requested_quantity = <ls_atp_day>-date_quantity )
          TO lt_local_demands.
      ENDIF.
    ENDLOOP.

    IF lt_local_demands IS NOT INITIAL.
      lt_local_estimates = mo_stock_service->allocate_demands_by_date(
        it_demands                     = lt_local_demands
        it_excluded_reservations       = lt_excluded_reservations
        iv_include_po_receipts         = iv_include_po_receipts
        iv_include_po_confirmations    = iv_include_po_confirmations
        iv_include_sto_in_transit      = iv_include_sto_in_transit
        iv_include_unissued_sto        = iv_include_unissued_sto
        iv_subtract_unissued_sto       = iv_subtract_unissued_sto
        iv_include_prod_receipts       = iv_include_prod_receipts
        iv_include_pr_receipts         = iv_include_pr_receipts
        iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
        iv_include_planned_receipts    = iv_include_planned_receipts
        iv_include_fixed_planned       = iv_include_fixed_planned
        iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
        iv_protect_safety_stock        = iv_protect_safety_stock ).

      LOOP AT lt_local_estimates INTO DATA(ls_local_estimate).
        READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
          WITH KEY request_id = ls_local_estimate-request_id.
        IF sy-subrc = 0.
          <ls_atp_day>-local_estimate = ls_local_estimate.
          <ls_atp_day>-local_remaining_quantity =
            ls_local_estimate-available_quantity.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_atp_days ASSIGNING <ls_atp_day>.
      READ TABLE lt_projected_scope_keys INTO ls_day_scope_key
        WITH TABLE KEY material = <ls_atp_day>-material
                       plant = <ls_atp_day>-plant.
      IF sy-subrc = 0 AND ls_day_scope_key-use_scoped = abap_true.
        CLEAR lv_group_available.
        CLEAR lv_group_allocated.
        CLEAR lv_group_shortfall.
        LOOP AT lt_scoped_allocations INTO DATA(ls_scoped_group_row).
          IF ls_scoped_group_row-allocation-material <>
                <ls_atp_day>-material
              OR ls_scoped_group_row-allocation-plant <>
                <ls_atp_day>-plant
              OR ls_scoped_group_row-allocation-required_date <>
                <ls_atp_day>-required_date.
            CONTINUE.
          ENDIF.
          lv_group_available =
            ls_scoped_group_row-group_available_quantity.
          lv_group_allocated +=
            ls_scoped_group_row-allocation-allocated_quantity.
          lv_group_shortfall +=
            ls_scoped_group_row-allocation-shortfall_quantity.
        ENDLOOP.
        <ls_atp_day>-local_estimate = VALUE #(
          request_id         = <ls_atp_day>-request_id
          material           = <ls_atp_day>-material
          plant              = <ls_atp_day>-plant
          required_date      = <ls_atp_day>-required_date
          requested_quantity = <ls_atp_day>-date_quantity
          available_quantity = lv_group_available
          allocated_quantity = lv_group_allocated
          shortfall_quantity = lv_group_shortfall ).
      ENDIF.
    ENDLOOP.

    CLEAR lv_component_index.
    LOOP AT lt_components INTO ls_component.
      CLEAR lv_comp_allocation_seq.
      CLEAR lv_component_sequence_scope.
      READ TABLE lt_unit_ratios INTO ls_unit_ratio_cache
        WITH TABLE KEY material = ls_component-material
                       source_unit = ls_component-unit.
      CLEAR ls_component_allocation_policy.
      READ TABLE lt_allocation_policies
        INTO ls_component_allocation_policy
        WITH TABLE KEY reservation_number = ls_component-reservation_number
                       reservation_item = ls_component-reservation_item.
      lv_component_open_quantity = COND #(
        WHEN ls_component_allocation_policy-override_open_quantity
          = abap_true
        THEN ls_component_allocation_policy-open_quantity
        ELSE ls_component-open_quantity ).
      lv_component_index += 1.
      lv_component_request_id = |COMP_SCOPE_{ lv_component_index }|.
      READ TABLE lt_scoped_demands INTO DATA(ls_component_scoped_demand)
        WITH KEY request_id = lv_component_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_atp_days ASSIGNING <ls_atp_day>
        WITH TABLE KEY material = ls_component-material
                       plant = ls_component-plant
                       base_unit = ls_unit_ratio_cache-ratio-base_unit
                       required_date =
                         ls_component_scoped_demand-required_date.
      DATA(lv_component_base_quantity) =
        ls_component_scoped_demand-requested_quantity.
      DATA(lv_component_confirmed) = COND mard-labst(
        WHEN iv_check_atp = abap_true
          AND <ls_atp_day>-atp_result-is_check_relevant = abap_true
          AND lv_component_base_quantity <
            <ls_atp_day>-confirmed_remaining_quantity
        THEN lv_component_base_quantity
        WHEN iv_check_atp = abap_true
          AND <ls_atp_day>-atp_result-is_check_relevant = abap_true
        THEN <ls_atp_day>-confirmed_remaining_quantity
        ELSE 0 ).
      IF iv_check_atp = abap_true
          AND <ls_atp_day>-atp_result-is_check_relevant = abap_true.
        <ls_atp_day>-confirmed_remaining_quantity =
          <ls_atp_day>-confirmed_remaining_quantity
            - lv_component_confirmed.
      ENDIF.
      DATA(lv_component_unconfirmed) = COND mard-labst(
        WHEN iv_check_atp = abap_true
          AND <ls_atp_day>-atp_result-is_check_relevant = abap_true
        THEN lv_component_base_quantity - lv_component_confirmed
        ELSE 0 ).
      CLEAR ls_component_group_estimate.
      READ TABLE lt_projected_scope_keys INTO DATA(ls_component_scope_key)
        WITH TABLE KEY material = ls_component-material
                       plant = ls_component-plant.
      lv_component_uses_scoped = COND #(
        WHEN sy-subrc = 0
          AND ls_component_scope_key-use_scoped = abap_true
        THEN abap_true
        ELSE abap_false ).
      CLEAR lt_component_batch_splits.
      CLEAR lt_component_location_splits.
      CLEAR lv_component_floor_rejected.
      IF lv_component_uses_scoped = abap_true.
        READ TABLE lt_scoped_allocations INTO DATA(ls_scoped_allocation)
          WITH KEY allocation-request_id = lv_component_request_id.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_comp_allocation_seq =
          ls_scoped_allocation-allocation-allocation_sequence.
        lv_component_floor_rejected =
          ls_scoped_allocation-allocation-minimum_coverage_rejected.
        lv_component_sequence_scope =
          c_comp_seq_scope_scoped.
        lv_component_available =
          ls_scoped_allocation-allocation-available_quantity.
        lv_component_allocated =
          ls_scoped_allocation-allocation-allocated_quantity.
        lv_component_shortfall =
          ls_scoped_allocation-allocation-shortfall_quantity.
        lt_component_batch_splits =
          ls_scoped_allocation-batch_allocations.
        lt_component_location_splits =
          ls_scoped_allocation-location_allocations.
        ls_component_group_estimate = VALUE #(
          requested_quantity =
            <ls_atp_day>-local_estimate-requested_quantity
          available_quantity =
            <ls_atp_day>-local_estimate-available_quantity
          allocated_quantity =
            <ls_atp_day>-local_estimate-allocated_quantity
          shortfall_quantity =
            <ls_atp_day>-local_estimate-shortfall_quantity ).
      ELSE.
        lv_component_available = COND mard-labst(
          WHEN <ls_atp_day>-local_remaining_quantity > 0
          THEN <ls_atp_day>-local_remaining_quantity
          ELSE 0 ).
        lv_component_allocated = COND mard-labst(
          WHEN lv_component_base_quantity < lv_component_available
          THEN lv_component_base_quantity
          ELSE lv_component_available ).
        lv_component_shortfall = lv_component_base_quantity
          - lv_component_allocated.
        <ls_atp_day>-local_remaining_quantity = lv_component_available
          - lv_component_allocated.
        ls_component_group_estimate = VALUE #(
          requested_quantity =
            <ls_atp_day>-local_estimate-requested_quantity
          available_quantity =
            <ls_atp_day>-local_estimate-available_quantity
          allocated_quantity =
            <ls_atp_day>-local_estimate-allocated_quantity
          shortfall_quantity =
            <ls_atp_day>-local_estimate-shortfall_quantity ).
        ls_component_group_estimate-allocation_sequence =
          <ls_atp_day>-local_estimate-allocation_sequence.
        ls_component_group_estimate-allocation_sequence_scope =
          c_comp_seq_scope_dated.
        READ TABLE lt_comp_seq_rows
            INTO DATA(ls_component_sequence)
          WITH KEY request_id = lv_component_request_id.
        IF sy-subrc <> 0 OR ls_component_sequence-allocation_sequence <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_comp_allocation_seq =
          ls_component_sequence-allocation_sequence.
        lv_component_sequence_scope =
          c_comp_seq_scope_dated.
      ENDIF.
      ls_component_group_estimate-allocation_outcome = COND #(
        WHEN ls_component_group_estimate-allocated_quantity =
            ls_component_group_estimate-requested_quantity
          THEN zif_stock_repository=>c_allocation_outcome_full
        WHEN ls_component_group_estimate-allocated_quantity > 0
          THEN zif_stock_repository=>c_allocation_outcome_partial
        ELSE zif_stock_repository=>c_allocation_outcome_none ).
      ls_component_group_estimate-allocation_coverage_pct = COND #(
        WHEN ls_component_group_estimate-requested_quantity > 0
        THEN CONV zcl_stock_service=>ty_allocation_coverage_pct(
          CONV decfloat34( ls_component_group_estimate-allocated_quantity )
          * CONV decfloat34( 100 )
          / CONV decfloat34( ls_component_group_estimate-requested_quantity ) )
        ELSE 0 ).
      CLEAR lv_fallback_used.
      IF ls_component_scoped_demand-allow_location_fallback = abap_true.
        LOOP AT lt_component_batch_splits
            INTO DATA(ls_fallback_batch_split)
            WHERE storage_location <>
                ls_component_scoped_demand-storage_location
              AND allocated_quantity > 0.
          lv_fallback_used = abap_true.
          EXIT.
        ENDLOOP.
        IF lv_fallback_used <> abap_true.
          LOOP AT lt_component_location_splits
              INTO DATA(ls_fallback_location_split)
              WHERE storage_location <>
                  ls_component_scoped_demand-storage_location
                AND allocated_quantity > 0.
            lv_fallback_used = abap_true.
            EXIT.
          ENDLOOP.
        ENDIF.
      ENDIF.
      CLEAR lv_batch_fallback_used.
      IF ls_component_scoped_demand-allow_batch_fallback = abap_true.
        LOOP AT lt_component_batch_splits
            INTO DATA(ls_batch_fallback_split)
            WHERE batch <> ls_component_scoped_demand-batch
              AND allocated_quantity > 0.
          lv_batch_fallback_used = abap_true.
          EXIT.
        ENDLOOP.
      ENDIF.
      APPEND VALUE #(
        component                      = ls_component
        allocation_policy              = ls_component_allocation_policy
        effective_storage_location     =
          ls_component_scoped_demand-storage_location
        effective_required_date        =
          ls_component_scoped_demand-required_date
        effective_open_quantity        = lv_component_open_quantity
        effective_batch                = ls_component_scoped_demand-batch
        location_fallback_used         = lv_fallback_used
        batch_fallback_used            = lv_batch_fallback_used
        base_unit                      = ls_unit_ratio_cache-ratio-base_unit
        requested_base_quantity        = lv_component_base_quantity
        cumulative_base_quantity       = <ls_atp_day>-cumulative_quantity
        confirmed_base_quantity        =
          <ls_atp_day>-cum_confirmed_quantity
        unconfirmed_base_quantity      =
          <ls_atp_day>-cum_unconfirmed_quantity
        component_confirmed_quantity   = lv_component_confirmed
        component_unconfirmed_quantity = lv_component_unconfirmed
        is_fully_confirmed             = COND abap_bool(
          WHEN iv_check_atp = abap_true
            AND <ls_atp_day>-atp_result-is_check_relevant = abap_true
            AND lv_component_unconfirmed = 0
            THEN abap_true
          ELSE abap_false )
        local_estimate                 = ls_component_group_estimate
        component_local_estimate       = VALUE #(
          allocation_sequence       = lv_comp_allocation_seq
          allocation_sequence_scope = lv_component_sequence_scope
          requested_quantity        = lv_component_base_quantity
          available_quantity        = lv_component_available
          allocated_quantity        = lv_component_allocated
          shortfall_quantity        = lv_component_shortfall
          minimum_coverage_pct      =
            ls_component_allocation_policy-minimum_coverage_pct
          minimum_coverage_rejected = lv_component_floor_rejected
          allocation_outcome        = COND #(
            WHEN lv_component_allocated = lv_component_base_quantity
              THEN zif_stock_repository=>c_allocation_outcome_full
            WHEN lv_component_allocated > 0
              THEN zif_stock_repository=>c_allocation_outcome_partial
            ELSE zif_stock_repository=>c_allocation_outcome_none )
          allocation_coverage_pct   = COND #(
            WHEN lv_component_base_quantity > 0
            THEN CONV zcl_stock_service=>ty_allocation_coverage_pct(
              CONV decfloat34( lv_component_allocated )
              * CONV decfloat34( 100 )
              / CONV decfloat34( lv_component_base_quantity ) )
            ELSE 0 ) )
        batch_allocations              = lt_component_batch_splits
        location_allocations           = lt_component_location_splits
        atp_result                     = <ls_atp_day>-atp_result ) TO rt_checks.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_components_atp_bulk.
    IF iv_check_rule IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rt_checks = preview_components_internal(
      it_production_orders           = it_production_orders
      it_excluded_reservations       = it_excluded_reservations
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_projected_location_receipts = it_projected_location_receipts
      it_allocation_policies         = it_allocation_policies
      it_storage_location_priority   = it_storage_location_priority
      it_comp_location_priorities    = it_comp_location_priorities
      it_comp_location_candidates    = it_comp_location_candidates
      it_comp_batch_priorities       = it_comp_batch_priorities
      it_comp_batch_candidates       = it_comp_batch_candidates
      iv_check_atp                   = abap_true
      iv_check_rule                  = iv_check_rule
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       = iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock ).
  ENDMETHOD.

  METHOD preview_components_atp.
    IF iv_production_order IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    APPEND iv_production_order TO lt_production_orders.
    rt_checks = preview_components_atp_bulk(
      it_production_orders           = lt_production_orders
      it_excluded_reservations       = it_excluded_reservations
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_projected_location_receipts = it_projected_location_receipts
      it_allocation_policies         = it_allocation_policies
      it_storage_location_priority   = it_storage_location_priority
      it_comp_location_priorities    = it_comp_location_priorities
      it_comp_location_candidates    = it_comp_location_candidates
      it_comp_batch_priorities       = it_comp_batch_priorities
      it_comp_batch_candidates       = it_comp_batch_candidates
      iv_check_rule                  = iv_check_rule
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       = iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock ).
  ENDMETHOD.

  METHOD preview_components_stock_bulk.
    rt_checks = preview_components_internal(
      it_production_orders           = it_production_orders
      it_excluded_reservations       = it_excluded_reservations
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_projected_location_receipts = it_projected_location_receipts
      it_allocation_policies         = it_allocation_policies
      it_storage_location_priority   = it_storage_location_priority
      it_comp_location_priorities    = it_comp_location_priorities
      it_comp_location_candidates    = it_comp_location_candidates
      it_comp_batch_priorities       = it_comp_batch_priorities
      it_comp_batch_candidates       = it_comp_batch_candidates
      iv_check_atp                   = abap_false
      iv_check_rule                  = space
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       = iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock ).
  ENDMETHOD.

  METHOD preview_scoped_components_bulk.
    rt_checks = preview_components_internal(
      it_production_orders           = it_production_orders
      it_excluded_reservations       = it_excluded_reservations
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_projected_location_receipts = it_projected_location_receipts
      it_allocation_policies         = it_allocation_policies
      it_storage_location_priority   = it_storage_location_priority
      it_comp_location_priorities    = it_comp_location_priorities
      it_comp_location_candidates    = it_comp_location_candidates
      it_comp_batch_priorities       = it_comp_batch_priorities
      it_comp_batch_candidates       = it_comp_batch_candidates
      iv_check_atp                   = abap_false
      iv_check_rule                  = space
      iv_include_po_receipts         = abap_false
      iv_include_po_confirmations    = abap_false
      iv_include_sto_in_transit      = abap_false
      iv_include_unissued_sto        = abap_false
      iv_subtract_unissued_sto       = abap_false
      iv_include_prod_receipts       = abap_false
      iv_include_pr_receipts         = abap_false
      iv_include_sto_pr_receipts     = abap_false
      iv_include_planned_receipts    = abap_false
      iv_include_fixed_planned       = abap_false
      iv_include_sched_agmt_receipts = abap_false
      iv_protect_safety_stock        = iv_protect_safety_stock ).
  ENDMETHOD.

  METHOD preview_scoped_components.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.

    IF iv_production_order IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    APPEND iv_production_order TO lt_production_orders.
    rt_checks = preview_scoped_components_bulk(
      it_production_orders           = lt_production_orders
      it_excluded_reservations       = it_excluded_reservations
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_projected_location_receipts = it_projected_location_receipts
      it_allocation_policies         = it_allocation_policies
      it_storage_location_priority   = it_storage_location_priority
      it_comp_location_priorities    = it_comp_location_priorities
      it_comp_location_candidates    = it_comp_location_candidates
      it_comp_batch_priorities       = it_comp_batch_priorities
      it_comp_batch_candidates       = it_comp_batch_candidates
      iv_protect_safety_stock        = iv_protect_safety_stock ).
  ENDMETHOD.

  METHOD preview_components_stock.
    IF iv_production_order IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    APPEND iv_production_order TO lt_production_orders.
    rt_checks = preview_components_stock_bulk(
      it_production_orders           = lt_production_orders
      it_excluded_reservations       = it_excluded_reservations
      it_projected_batch_receipts    = it_projected_batch_receipts
      it_projected_location_receipts = it_projected_location_receipts
      it_allocation_policies         = it_allocation_policies
      it_storage_location_priority   = it_storage_location_priority
      it_comp_location_priorities    = it_comp_location_priorities
      it_comp_location_candidates    = it_comp_location_candidates
      it_comp_batch_priorities       = it_comp_batch_priorities
      it_comp_batch_candidates       = it_comp_batch_candidates
      iv_include_po_receipts         = iv_include_po_receipts
      iv_include_po_confirmations    = iv_include_po_confirmations
      iv_include_sto_in_transit      = iv_include_sto_in_transit
      iv_include_unissued_sto        = iv_include_unissued_sto
      iv_subtract_unissued_sto       = iv_subtract_unissued_sto
      iv_include_prod_receipts       = iv_include_prod_receipts
      iv_include_pr_receipts         = iv_include_pr_receipts
      iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
      iv_include_planned_receipts    = iv_include_planned_receipts
      iv_include_fixed_planned       = iv_include_fixed_planned
      iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts
      iv_protect_safety_stock        = iv_protect_safety_stock ).
  ENDMETHOD.

  METHOD summarize_component_readiness.
    DATA lt_seen_components TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_readiness TYPE SORTED TABLE OF ty_component_order_readiness
      WITH UNIQUE KEY production_order.
    FIELD-SYMBOLS <ls_readiness> TYPE ty_component_order_readiness.

    LOOP AT it_checks INTO DATA(ls_check).
      DATA(lv_effective_required_date) = COND resb-bdter(
        WHEN ls_check-effective_required_date IS INITIAL
        THEN ls_check-component-required_date
        ELSE ls_check-effective_required_date ).
      IF ls_check-component-production_order IS INITIAL
          OR ls_check-component-reservation_number IS INITIAL
          OR ls_check-component-reservation_item IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            lv_effective_required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      INSERT VALUE #(
        production_order   = ls_check-component-production_order
        reservation_number = ls_check-component-reservation_number
        reservation_item   = ls_check-component-reservation_item )
        INTO TABLE lt_seen_components.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      DATA(lv_expected_allocated) = COND mard-labst(
        WHEN ls_check-requested_base_quantity <
          ls_check-component_local_estimate-available_quantity
        THEN ls_check-requested_base_quantity
        ELSE ls_check-component_local_estimate-available_quantity ).
      IF ls_check-requested_base_quantity < 0
          OR ls_check-component_local_estimate-requested_quantity < 0
          OR ls_check-component_local_estimate-available_quantity < 0
          OR ls_check-component_local_estimate-allocated_quantity < 0
          OR ls_check-component_local_estimate-shortfall_quantity < 0
          OR ls_check-component_local_estimate-requested_quantity
            <> ls_check-requested_base_quantity
          OR ls_check-component_local_estimate-allocated_quantity
            <> lv_expected_allocated
          OR ls_check-component_local_estimate-shortfall_quantity
            <> ls_check-requested_base_quantity - lv_expected_allocated.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_readiness ASSIGNING <ls_readiness>
        WITH TABLE KEY production_order =
          ls_check-component-production_order.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order = ls_check-component-production_order
          is_locally_ready = abap_true ) INTO TABLE lt_readiness.
        READ TABLE lt_readiness ASSIGNING <ls_readiness>
          WITH TABLE KEY production_order =
            ls_check-component-production_order.
      ENDIF.

      ADD 1 TO <ls_readiness>-open_component_count.
      <ls_readiness>-requested_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_readiness>-requested_base_quantity
        iv_right_quantity = ls_check-requested_base_quantity ).
      <ls_readiness>-allocated_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_readiness>-allocated_base_quantity
        iv_right_quantity =
          ls_check-component_local_estimate-allocated_quantity ).
      <ls_readiness>-shortfall_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_readiness>-shortfall_base_quantity
        iv_right_quantity =
          ls_check-component_local_estimate-shortfall_quantity ).
      IF <ls_readiness>-first_required_date IS INITIAL
          OR lv_effective_required_date <
            <ls_readiness>-first_required_date.
        <ls_readiness>-first_required_date =
          lv_effective_required_date.
      ENDIF.
      IF lv_effective_required_date >
          <ls_readiness>-last_required_date.
        <ls_readiness>-last_required_date =
          lv_effective_required_date.
      ENDIF.

      IF ls_check-requested_base_quantity = 0.
        ADD 1 TO <ls_readiness>-zero_demand_component_count.
      ELSEIF ls_check-component_local_estimate-shortfall_quantity = 0.
        ADD 1 TO <ls_readiness>-covered_component_count.
      ELSE.
        ADD 1 TO <ls_readiness>-short_component_count.
        <ls_readiness>-is_locally_ready = abap_false.
        IF <ls_readiness>-first_local_shortage_date IS INITIAL
            OR lv_effective_required_date <
              <ls_readiness>-first_local_shortage_date.
          <ls_readiness>-first_local_shortage_date =
            lv_effective_required_date.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_readiness INTO DATA(ls_readiness).
      APPEND ls_readiness TO rt_readiness.
    ENDLOOP.
  ENDMETHOD.

  METHOD summarize_component_shortages.
    DATA(lt_readiness) = summarize_component_readiness(
      it_checks = it_checks ).
    DATA lt_shortages TYPE SORTED TABLE OF ty_component_shortage
      WITH UNIQUE KEY material plant base_unit required_date.
    DATA lt_affected_orders TYPE ty_component_shortage_order_keys.
    FIELD-SYMBOLS <ls_shortage> TYPE ty_component_shortage.

    LOOP AT it_checks INTO DATA(ls_check).
      DATA(lv_effective_required_date) = COND resb-bdter(
        WHEN ls_check-effective_required_date IS INITIAL
        THEN ls_check-component-required_date
        ELSE ls_check-effective_required_date ).
      IF ls_check-component-material IS INITIAL
          OR ls_check-component-plant IS INITIAL
          OR ls_check-base_unit IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            lv_effective_required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_shortages ASSIGNING <ls_shortage>
        WITH TABLE KEY material = ls_check-component-material
                       plant = ls_check-component-plant
                       base_unit = ls_check-base_unit
                       required_date = lv_effective_required_date.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material      = ls_check-component-material
          plant         = ls_check-component-plant
          base_unit     = ls_check-base_unit
          required_date = lv_effective_required_date )
          INTO TABLE lt_shortages.
        READ TABLE lt_shortages ASSIGNING <ls_shortage>
          WITH TABLE KEY material = ls_check-component-material
                         plant = ls_check-component-plant
                         base_unit = ls_check-base_unit
                         required_date =
                           lv_effective_required_date.
      ENDIF.

      ADD 1 TO <ls_shortage>-component_count.
      <ls_shortage>-requested_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_shortage>-requested_base_quantity
        iv_right_quantity = ls_check-requested_base_quantity ).
      <ls_shortage>-allocated_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_shortage>-allocated_base_quantity
        iv_right_quantity =
          ls_check-component_local_estimate-allocated_quantity ).
      <ls_shortage>-shortfall_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_shortage>-shortfall_base_quantity
        iv_right_quantity =
          ls_check-component_local_estimate-shortfall_quantity ).

      IF ls_check-component_local_estimate-shortfall_quantity > 0.
        IF ls_check-component-production_order IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ADD 1 TO <ls_shortage>-short_component_count.
        INSERT VALUE #(
          material         = ls_check-component-material
          plant            = ls_check-component-plant
          base_unit        = ls_check-base_unit
          required_date    = lv_effective_required_date
          production_order = ls_check-component-production_order )
          INTO TABLE lt_affected_orders.
        IF sy-subrc = 0.
          ADD 1 TO <ls_shortage>-affected_order_count.
          INSERT ls_check-component-production_order
            INTO TABLE <ls_shortage>-affected_production_orders.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_shortages INTO DATA(ls_shortage)
        WHERE shortfall_base_quantity > 0.
      APPEND ls_shortage TO rt_shortages.
    ENDLOOP.
  ENDMETHOD.

  METHOD summarize_order_atp.
    DATA lt_seen_components TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_summaries TYPE SORTED TABLE OF ty_component_order_atp_summary
      WITH UNIQUE KEY production_order material plant base_unit.
    FIELD-SYMBOLS <ls_summary> TYPE ty_component_order_atp_summary.

    LOOP AT it_checks INTO DATA(ls_check).
      DATA(lv_effective_required_date) = COND resb-bdter(
        WHEN ls_check-effective_required_date IS INITIAL
        THEN ls_check-component-required_date
        ELSE ls_check-effective_required_date ).
      IF ls_check-component-production_order IS INITIAL
          OR ls_check-component-reservation_number IS INITIAL
          OR ls_check-component-reservation_item IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            lv_effective_required_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      INSERT VALUE #(
        production_order   = ls_check-component-production_order
        reservation_number = ls_check-component-reservation_number
        reservation_item   = ls_check-component-reservation_item )
        INTO TABLE lt_seen_components.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.

      IF ls_check-component-material IS INITIAL
          OR ls_check-component-plant IS INITIAL
          OR ls_check-base_unit IS INITIAL
          OR ( ls_check-atp_result-is_check_relevant <> abap_true
            AND ( ls_check-requested_base_quantity <> 0
              OR ls_check-cumulative_base_quantity <> 0
              OR ls_check-confirmed_base_quantity <> 0
              OR ls_check-unconfirmed_base_quantity <> 0
              OR ls_check-component_confirmed_quantity <> 0
              OR ls_check-component_unconfirmed_quantity <> 0 ) )
          OR ls_check-requested_base_quantity < 0
          OR ls_check-cumulative_base_quantity <
            ls_check-requested_base_quantity
          OR ls_check-confirmed_base_quantity < 0
          OR ls_check-unconfirmed_base_quantity < 0
          OR ls_check-component_confirmed_quantity < 0
          OR ls_check-component_unconfirmed_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF sum_stock_quantities(
          iv_left_quantity  = ls_check-confirmed_base_quantity
          iv_right_quantity = ls_check-unconfirmed_base_quantity )
            <> ls_check-cumulative_base_quantity
          OR sum_stock_quantities(
            iv_left_quantity  = ls_check-component_confirmed_quantity
            iv_right_quantity =
              ls_check-component_unconfirmed_quantity )
            <> ls_check-requested_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_summaries ASSIGNING <ls_summary>
        WITH TABLE KEY production_order =
                         ls_check-component-production_order
                       material = ls_check-component-material
                       plant = ls_check-component-plant
                       base_unit = ls_check-base_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order         = ls_check-component-production_order
          material                 = ls_check-component-material
          plant                    = ls_check-component-plant
          base_unit                = ls_check-base_unit
          is_split_fully_confirmed = abap_true ) INTO TABLE lt_summaries.
        READ TABLE lt_summaries ASSIGNING <ls_summary>
          WITH TABLE KEY production_order =
                           ls_check-component-production_order
                         material = ls_check-component-material
                         plant = ls_check-component-plant
                         base_unit = ls_check-base_unit.
      ENDIF.

      ADD 1 TO <ls_summary>-component_count.
      <ls_summary>-requested_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_summary>-requested_base_quantity
        iv_right_quantity = ls_check-requested_base_quantity ).
      <ls_summary>-confirmed_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_summary>-confirmed_base_quantity
        iv_right_quantity = ls_check-component_confirmed_quantity ).
      <ls_summary>-unconfirmed_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_summary>-unconfirmed_base_quantity
        iv_right_quantity = ls_check-component_unconfirmed_quantity ).

      IF <ls_summary>-first_required_date IS INITIAL
          OR lv_effective_required_date <
            <ls_summary>-first_required_date.
        <ls_summary>-first_required_date =
          lv_effective_required_date.
      ENDIF.
      IF lv_effective_required_date >
          <ls_summary>-last_required_date.
        <ls_summary>-last_required_date =
          lv_effective_required_date.
      ENDIF.

      IF ls_check-component_unconfirmed_quantity = 0.
        ADD 1 TO <ls_summary>-fully_confirmed_count.
      ELSEIF ls_check-component_confirmed_quantity > 0.
        ADD 1 TO <ls_summary>-partially_confirmed_count.
        <ls_summary>-is_split_fully_confirmed = abap_false.
      ELSE.
        ADD 1 TO <ls_summary>-unconfirmed_count.
        <ls_summary>-is_split_fully_confirmed = abap_false.
      ENDIF.

      IF ls_check-component_unconfirmed_quantity > 0
          AND ( <ls_summary>-first_unconfirmed_date IS INITIAL
            OR lv_effective_required_date <
              <ls_summary>-first_unconfirmed_date ).
        <ls_summary>-first_unconfirmed_date =
          lv_effective_required_date.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_summaries INTO DATA(ls_summary).
      APPEND ls_summary TO rt_summaries.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_month_period_bounds.
    DATA(lv_year) = CONV i( iv_date+0(4) ).
    DATA(lv_month) = CONV i( iv_date+4(2) ).
    DATA lv_last_day TYPE i.
    DATA lv_last_day_text TYPE n LENGTH 2.

    rs_period_bounds-start_date = iv_date.
    rs_period_bounds-start_date+6(2) = '01'.
    CASE lv_month.
      WHEN 4 OR 6 OR 9 OR 11.
        lv_last_day = 30.
      WHEN 2.
        IF lv_year MOD 400 = 0
            OR ( lv_year MOD 4 = 0 AND lv_year MOD 100 <> 0 ).
          lv_last_day = 29.
        ELSE.
          lv_last_day = 28.
        ENDIF.
      WHEN OTHERS.
        lv_last_day = 31.
    ENDCASE.
    lv_last_day_text = lv_last_day.
    rs_period_bounds-end_date = rs_period_bounds-start_date.
    rs_period_bounds-end_date+6(2) = lv_last_day_text.
  ENDMETHOD.

  METHOD get_week_period_bounds.
    DATA(lv_year) = CONV i( iv_date+0(4) ).
    DATA(lv_month) = CONV i( iv_date+4(2) ).
    DATA(lv_day) = CONV i( iv_date+6(2) ).

    IF lv_month < 3.
      lv_month = lv_month + 12.
      lv_year = lv_year - 1.
    ENDIF.
    DATA(lv_year_part) = lv_year MOD 100.
    DATA(lv_century_part) = lv_year DIV 100.
    DATA(lv_zeller_weekday) = ( lv_day
      + ( 13 * ( lv_month + 1 ) ) DIV 5
      + lv_year_part + ( lv_year_part DIV 4 )
      + ( lv_century_part DIV 4 ) + ( 5 * lv_century_part ) ) MOD 7.
    DATA(lv_weekday) = ( lv_zeller_weekday + 5 ) MOD 7 + 1.
    DATA(lv_days_since_week_start) = ( lv_weekday
      - iv_week_start_weekday + 7 ) MOD 7.

    rs_period_bounds-start_date = iv_date - lv_days_since_week_start.
    rs_period_bounds-end_date = rs_period_bounds-start_date + 6.
  ENDMETHOD.

  METHOD round_replenishment_quantity.
    DATA lt_profile_levels TYPE
      zif_replenishment_policy_repo=>ty_rounding_profiles.
    DATA lv_remaining_quantity TYPE decfloat34.
    DATA lv_rounded_quantity TYPE decfloat34.
    DATA lv_threshold_quantity TYPE decfloat34.
    DATA lv_rounding_quantity TYPE decfloat34.
    DATA lv_whole_quantity TYPE decfloat34.
    DATA lv_remainder_quantity TYPE decfloat34.
    DATA lv_level_quantity TYPE decfloat34.
    DATA lv_previous_threshold TYPE decfloat34.
    DATA lv_previous_level TYPE rdpr-rdzae.

    rv_quantity = iv_quantity.
    IF iv_profile IS INITIAL OR iv_quantity <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_profile_values INTO DATA(ls_profile_line)
        WHERE plant = iv_plant
          AND rounding_profile = iv_profile.
      APPEND ls_profile_line TO lt_profile_levels.
    ENDLOOP.
    IF lt_profile_levels IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    SORT lt_profile_levels BY level_number DESCENDING.
    LOOP AT lt_profile_levels INTO ls_profile_line.
      lv_threshold_quantity = CONV decfloat34(
        ls_profile_line-threshold_quantity ).
      lv_rounding_quantity = CONV decfloat34(
        ls_profile_line-rounding_quantity ).
      IF ls_profile_line-level_number IS INITIAL
          OR lv_threshold_quantity < 0
          OR lv_rounding_quantity <= 0
          OR ( lv_previous_level IS NOT INITIAL
            AND ls_profile_line-level_number >= lv_previous_level )
          OR ( lv_previous_level IS NOT INITIAL
            AND lv_threshold_quantity > lv_previous_threshold ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_previous_level = ls_profile_line-level_number.
      lv_previous_threshold = lv_threshold_quantity.
    ENDLOOP.

    lv_remaining_quantity = iv_quantity.
    LOOP AT lt_profile_levels INTO ls_profile_line.
      lv_threshold_quantity = CONV decfloat34(
        ls_profile_line-threshold_quantity ).
      lv_rounding_quantity = CONV decfloat34(
        ls_profile_line-rounding_quantity ).
      IF sy-tabix = lines( lt_profile_levels ).
        IF lv_remaining_quantity >= lv_threshold_quantity.
          lv_level_quantity = CONV decfloat34(
            floor( lv_remaining_quantity / lv_rounding_quantity ) )
              * lv_rounding_quantity.
          IF lv_level_quantity < lv_remaining_quantity.
            lv_level_quantity = lv_level_quantity + lv_rounding_quantity.
          ENDIF.
          lv_rounded_quantity = lv_rounded_quantity + lv_level_quantity.
        ELSE.
          lv_rounded_quantity = lv_rounded_quantity
            + lv_remaining_quantity.
        ENDIF.
        EXIT.
      ENDIF.

      lv_whole_quantity = CONV decfloat34(
        floor( lv_remaining_quantity / lv_rounding_quantity ) )
          * lv_rounding_quantity.
      lv_remainder_quantity = lv_remaining_quantity - lv_whole_quantity.
      lv_rounded_quantity = lv_rounded_quantity + lv_whole_quantity.
      IF lv_remainder_quantity > 0
          AND lv_remainder_quantity >= lv_threshold_quantity.
        lv_rounded_quantity = lv_rounded_quantity
          + lv_rounding_quantity.
        EXIT.
      ENDIF.
      lv_remaining_quantity = lv_remainder_quantity.
    ENDLOOP.

    rv_quantity = lv_rounded_quantity.
  ENDMETHOD.

  METHOD estimate_repl_timing.
    IF iv_policy_origin = 'NONE'.
      rs_timing-lead_time_status = c_repl_status_no_policy.
      RETURN.
    ENDIF.

    CASE iv_procurement_type.
      WHEN 'E'.
        rs_timing-lead_time_status = c_repl_status_in_house.
        RETURN.
      WHEN 'X'.
        rs_timing-lead_time_status = c_repl_status_ambiguous.
        RETURN.
      WHEN 'F'.
        IF iv_special_procurement_key IS NOT INITIAL.
          rs_timing-lead_time_status = c_repl_status_special_source.
          RETURN.
        ENDIF.
      WHEN OTHERS.
        rs_timing-lead_time_status = c_repl_status_unsupported.
        RETURN.
    ENDCASE.

    IF iv_factory_calendar_id IS INITIAL.
      rs_timing-lead_time_status = c_repl_status_missing_calendar.
      RETURN.
    ENDIF.

    DATA(ls_delivery_result) = mo_factory_calendar_api->subtract_workdays(
      iv_date                = CONV d( iv_required_date )
      iv_factory_calendar_id = iv_factory_calendar_id
      iv_workdays            = CONV i(
        iv_gr_processing_days ) ).
    IF ls_delivery_result-is_successful <> abap_true.
      rs_timing-lead_time_status = c_repl_status_calendar_error.
      RETURN.
    ENDIF.
    rs_timing-estimated_delivery_date = ls_delivery_result-date.

    DATA(lv_po_candidate_date) =
      rs_timing-estimated_delivery_date
        - CONV i( iv_planned_delivery_days ).
    DATA(ls_po_result) = mo_factory_calendar_api->subtract_workdays(
      iv_date                = CONV d( lv_po_candidate_date )
      iv_factory_calendar_id = iv_factory_calendar_id
      iv_workdays            = 0 ).
    IF ls_po_result-is_successful <> abap_true.
      CLEAR rs_timing-estimated_delivery_date.
      rs_timing-lead_time_status = c_repl_status_calendar_error.
      RETURN.
    ENDIF.
    rs_timing-latest_purchase_order_date = ls_po_result-date.

    DATA(ls_release_result) = mo_factory_calendar_api->subtract_workdays(
      iv_date                = rs_timing-latest_purchase_order_date
      iv_factory_calendar_id = iv_factory_calendar_id
      iv_workdays            = CONV i(
        iv_purchasing_processing_days ) ).
    IF ls_release_result-is_successful <> abap_true.
      CLEAR rs_timing-estimated_delivery_date.
      CLEAR rs_timing-latest_purchase_order_date.
      rs_timing-lead_time_status = c_repl_status_calendar_error.
      RETURN.
    ENDIF.
    rs_timing-latest_pr_release_date = ls_release_result-date.
    rs_timing-lead_time_status = c_repl_status_estimate.
  ENDMETHOD.

  METHOD suggest_comp_replenishment.
    TYPES:
      BEGIN OF ty_prior_surplus,
        material       TYPE mard-matnr,
        plant          TYPE mard-werks,
        base_unit      TYPE mara-meins,
        quantity_milli TYPE int8,
      END OF ty_prior_surplus.
    TYPES:
      BEGIN OF ty_remaining_receipt,
        material             TYPE mard-matnr,
        plant                TYPE mard-werks,
        base_unit            TYPE mara-meins,
        receipt_date         TYPE d,
        quantity_milli       TYPE int8,
        source_type          TYPE c LENGTH 16,
        source_document      TYPE c LENGTH 35,
        source_item          TYPE c LENGTH 10,
        source_plant         TYPE eban-reswk,
        source_schedule_line TYPE eket-etenr,
        receipt_sequence     TYPE i,
      END OF ty_remaining_receipt.
    DATA lt_policies TYPE HASHED TABLE OF ty_replenishment_policy
      WITH UNIQUE KEY material plant base_unit.
    DATA lt_master_policies TYPE HASHED TABLE OF
      zif_replenishment_policy_repo=>ty_policy
      WITH UNIQUE KEY material plant.
    DATA lt_rounding_profile_keys TYPE
      zif_replenishment_policy_repo=>ty_rounding_profile_keys.
    DATA lt_rounding_profiles TYPE
      zif_replenishment_policy_repo=>ty_rounding_profiles.
    DATA lt_missing_material_plants TYPE SORTED TABLE OF
      zif_replenishment_policy_repo=>ty_material_plant
      WITH UNIQUE KEY material plant.
    DATA lt_seen_shortages TYPE HASHED TABLE OF ty_component_shortage
      WITH UNIQUE KEY material plant base_unit required_date.
    DATA lt_prior_surpluses TYPE HASHED TABLE OF ty_prior_surplus
      WITH UNIQUE KEY material plant base_unit.
    DATA lt_projected_receipts TYPE SORTED TABLE OF
      ty_remaining_receipt WITH NON-UNIQUE KEY material plant base_unit
        receipt_date receipt_sequence.
    DATA lt_receipt_uses TYPE ty_projected_receipt_uses.
    DATA lt_planning_shortages TYPE ty_planning_shortages.
    DATA lt_period_planning_shortages TYPE ty_period_planning_shortages.
    DATA lt_period_rcpt_uses TYPE ty_period_rcpt_uses.
    DATA lt_planning_calendar_periods TYPE SORTED TABLE OF
      ty_planning_calendar_period
      WITH UNIQUE KEY plant planning_calendar_id start_date.
    DATA lt_resolved_lot_size_periods TYPE SORTED TABLE OF
      ty_resolved_lot_size_period
      WITH UNIQUE KEY plant lot_size_procedure start_date.
    DATA lt_calendar_periods_input TYPE
      ty_planning_calendar_periods.
    DATA lt_calendar_requests TYPE HASHED TABLE OF
      zif_planning_calendar_repo=>ty_request
      WITH UNIQUE KEY plant planning_calendar_id.
    DATA lt_receipt_ordered_shortages TYPE ty_component_shortages.
    DATA lv_group_lot_size_procedure TYPE marc-disls.
    DATA lv_group_planning_calendar_id TYPE marc-mrppp.
    DATA lv_period_grouping TYPE abap_bool.
    DATA lv_previous_period_end TYPE d.
    DATA lv_previous_period_plant TYPE marc-werks.
    DATA lv_previous_calendar_id TYPE marc-mrppp.
    DATA lv_previous_lot_period_plant TYPE marc-werks.
    DATA lv_previous_lot_period_proc TYPE marc-disls.
    DATA lv_previous_lot_period_end TYPE d.
    DATA ls_timing TYPE ty_replenishment_timing.
    DATA lv_receipt_sequence TYPE i.
    DATA lv_input_index TYPE i.
    DATA ls_planning_shortage TYPE ty_planning_shortage.
    FIELD-SYMBOLS <ls_prior_surplus> TYPE ty_prior_surplus.
    FIELD-SYMBOLS <ls_projected_receipt> TYPE ty_remaining_receipt.
    FIELD-SYMBOLS <ls_month_shortage> TYPE ty_planning_shortage.
    FIELD-SYMBOLS <ls_calendar_request>
      TYPE zif_planning_calendar_repo=>ty_request.

    IF ( iv_net_prior_surplus <> abap_true
          AND iv_net_prior_surplus <> abap_false )
        OR iv_week_start_weekday < 1
        OR iv_week_start_weekday > 7.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    lt_receipt_ordered_shortages = it_shortages.
    SORT lt_receipt_ordered_shortages BY material plant base_unit
      required_date.

    LOOP AT it_projected_receipts INTO DATA(ls_projected_receipt).
      IF ls_projected_receipt-material IS INITIAL
          OR ls_projected_receipt-plant IS INITIAL
          OR ls_projected_receipt-base_unit IS INITIAL
          OR ls_projected_receipt-receipt_date IS INITIAL
          OR ls_projected_receipt-quantity <= 0
          OR ( ( ls_projected_receipt-source_type IS NOT INITIAL
              OR ls_projected_receipt-source_document IS NOT INITIAL
              OR ls_projected_receipt-source_item IS NOT INITIAL
              OR ls_projected_receipt-source_plant IS NOT INITIAL
              OR ls_projected_receipt-source_schedule_line IS NOT INITIAL )
            AND ( ls_projected_receipt-source_type IS INITIAL
              OR ls_projected_receipt-source_document IS INITIAL ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ADD 1 TO lv_receipt_sequence.
      INSERT VALUE #(
        material             = ls_projected_receipt-material
        plant                = ls_projected_receipt-plant
        base_unit            = ls_projected_receipt-base_unit
        receipt_date         = ls_projected_receipt-receipt_date
        source_type          = ls_projected_receipt-source_type
        source_document      = ls_projected_receipt-source_document
        source_item          = ls_projected_receipt-source_item
        source_plant         = ls_projected_receipt-source_plant
        source_schedule_line = ls_projected_receipt-source_schedule_line
        receipt_sequence     = lv_receipt_sequence
        quantity_milli       = CONV int8(
          CONV decfloat34( ls_projected_receipt-quantity ) * 1000 ) )
      INTO TABLE lt_projected_receipts.
    ENDLOOP.

    LOOP AT it_policies INTO DATA(ls_policy).
      IF ls_policy-material IS INITIAL
          OR ls_policy-plant IS INITIAL
          OR ls_policy-base_unit IS INITIAL
          OR ls_policy-planned_delivery_days < 0
          OR ls_policy-source_planned_delivery_days < 0
          OR ls_policy-goods_receipt_processing_days < 0
          OR ls_policy-purchasing_processing_days < 0
          OR ls_policy-minimum_base_quantity < 0
          OR ls_policy-maximum_base_quantity < 0
          OR ls_policy-maximum_stock_quantity < 0
          OR ls_policy-fixed_base_quantity < 0
          OR ls_policy-order_multiple_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_policy-source_agreement IS NOT INITIAL
          OR ls_policy-source_agreement_item IS NOT INITIAL.
        IF ls_policy-source_agreement IS INITIAL
            OR ls_policy-source_agreement_item IS INITIAL
            OR ls_policy-source_vendor IS INITIAL
            OR ls_policy-source_purchasing_org IS INITIAL
            OR ls_policy-source_info_record IS NOT INITIAL
            OR ls_policy-source_category IS NOT INITIAL
            OR ls_policy-source_planned_delivery_days > 0
            OR ls_policy-procurement_type <> 'F'
            OR ls_policy-special_procurement_key IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ELSEIF ls_policy-source_vendor IS NOT INITIAL
          OR ls_policy-source_purchasing_org IS NOT INITIAL
          OR ls_policy-source_info_record IS NOT INITIAL
          OR ls_policy-source_category IS NOT INITIAL
          OR ls_policy-source_planned_delivery_days > 0.
        IF ls_policy-source_vendor IS INITIAL
            OR ls_policy-source_purchasing_org IS INITIAL
            OR ls_policy-source_info_record IS INITIAL
            OR ls_policy-source_category IS INITIAL
            OR ls_policy-procurement_type <> 'F'
            OR ls_policy-special_procurement_key IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      INSERT ls_policy INTO TABLE lt_policies.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_shortages INTO DATA(ls_shortage).
      IF ls_shortage-material IS INITIAL
          OR ls_shortage-plant IS INITIAL
          OR ls_shortage-base_unit IS INITIAL
          OR ls_shortage-required_date IS INITIAL
          OR ls_shortage-component_count <= 0
          OR ls_shortage-affected_order_count < 0
          OR ls_shortage-requested_base_quantity < 0
          OR ls_shortage-allocated_base_quantity < 0
          OR ls_shortage-shortfall_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF sum_stock_quantities(
          iv_left_quantity  = ls_shortage-allocated_base_quantity
          iv_right_quantity = ls_shortage-shortfall_base_quantity )
            <> ls_shortage-requested_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_shortage-affected_production_orders IS NOT INITIAL
          AND lines( ls_shortage-affected_production_orders ) <>
            ls_shortage-affected_order_count.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      LOOP AT ls_shortage-affected_production_orders
          INTO DATA(lv_affected_order).
        IF lv_affected_order IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.

      INSERT ls_shortage INTO TABLE lt_seen_shortages.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_policies TRANSPORTING NO FIELDS
        WITH TABLE KEY material = ls_shortage-material
                       plant = ls_shortage-plant
                       base_unit = ls_shortage-base_unit.
      IF sy-subrc <> 0.
        LOOP AT it_policies TRANSPORTING NO FIELDS
            WHERE material = ls_shortage-material
              AND plant = ls_shortage-plant.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDLOOP.
        INSERT VALUE #(
          material = ls_shortage-material
          plant    = ls_shortage-plant ) INTO TABLE lt_missing_material_plants.
      ENDIF.
    ENDLOOP.

    IF lt_missing_material_plants IS NOT INITIAL.
      DATA(lt_loaded_policies) =
        mo_repl_policy_repo->get_policies_bulk(
          it_material_plants = CORRESPONDING #(
            lt_missing_material_plants ) ).

      LOOP AT lt_loaded_policies INTO DATA(ls_master_policy).
        IF ls_master_policy-material IS INITIAL
            OR ls_master_policy-plant IS INITIAL
            OR ls_master_policy-base_unit IS INITIAL
            OR ls_master_policy-planned_delivery_days < 0
            OR ls_master_policy-goods_receipt_processing_days < 0
            OR ls_master_policy-purchasing_processing_days < 0
            OR ls_master_policy-minimum_base_quantity < 0
            OR ls_master_policy-maximum_base_quantity < 0
            OR ls_master_policy-maximum_stock_quantity < 0
            OR ls_master_policy-fixed_base_quantity < 0
            OR ls_master_policy-order_multiple_base_quantity < 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        READ TABLE lt_missing_material_plants TRANSPORTING NO FIELDS
          WITH TABLE KEY material = ls_master_policy-material
                         plant = ls_master_policy-plant.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_master_policy INTO TABLE lt_master_policies.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_policies INTO ls_policy
        WHERE rounding_profile IS NOT INITIAL.
      INSERT VALUE #(
        plant            = ls_policy-plant
        rounding_profile = ls_policy-rounding_profile )
        INTO TABLE lt_rounding_profile_keys.
    ENDLOOP.
    LOOP AT lt_master_policies INTO ls_master_policy
        WHERE rounding_profile IS NOT INITIAL.
      INSERT VALUE #(
        plant            = ls_master_policy-plant
        rounding_profile = ls_master_policy-rounding_profile )
        INTO TABLE lt_rounding_profile_keys.
    ENDLOOP.
    IF lt_rounding_profile_keys IS NOT INITIAL.
      lt_rounding_profiles =
        mo_repl_policy_repo->get_rounding_profiles_bulk(
          it_profile_keys = lt_rounding_profile_keys ).
    ENDIF.

    IF it_planning_calendar_periods IS INITIAL.
      LOOP AT it_shortages INTO ls_shortage.
        CLEAR lv_group_lot_size_procedure.
        CLEAR lv_group_planning_calendar_id.
        READ TABLE lt_policies INTO ls_policy
          WITH TABLE KEY material = ls_shortage-material
                         plant = ls_shortage-plant
                         base_unit = ls_shortage-base_unit.
        IF sy-subrc = 0.
          lv_group_lot_size_procedure = ls_policy-lot_size_procedure.
          lv_group_planning_calendar_id =
            ls_policy-planning_calendar_id.
        ELSE.
          READ TABLE lt_master_policies INTO ls_master_policy
            WITH TABLE KEY material = ls_shortage-material
                           plant = ls_shortage-plant.
          IF sy-subrc = 0.
            lv_group_lot_size_procedure =
              ls_master_policy-lot_size_procedure.
            lv_group_planning_calendar_id =
              ls_master_policy-planning_calendar_id.
          ENDIF.
        ENDIF.
        IF lv_group_lot_size_procedure <> 'PK'
            OR lv_group_planning_calendar_id IS INITIAL.
          CONTINUE.
        ENDIF.

        READ TABLE lt_calendar_requests ASSIGNING <ls_calendar_request>
          WITH TABLE KEY plant = ls_shortage-plant
                         planning_calendar_id =
                           lv_group_planning_calendar_id.
        IF sy-subrc = 0.
          IF ls_shortage-required_date <
              <ls_calendar_request>-from_date.
            <ls_calendar_request>-from_date =
              ls_shortage-required_date.
          ENDIF.
          IF ls_shortage-required_date >
              <ls_calendar_request>-through_date.
            <ls_calendar_request>-through_date =
              ls_shortage-required_date.
          ENDIF.
        ELSE.
          INSERT VALUE #(
            plant                = ls_shortage-plant
            planning_calendar_id = lv_group_planning_calendar_id
            from_date            = ls_shortage-required_date
            through_date         = ls_shortage-required_date )
            INTO TABLE lt_calendar_requests.
        ENDIF.
      ENDLOOP.

      IF lt_calendar_requests IS NOT INITIAL.
        DATA(lt_loaded_calendar_periods) =
          mo_planning_calendar_repo->get_periods_bulk(
            it_requests = CORRESPONDING #( lt_calendar_requests ) ).
        lt_calendar_periods_input = CORRESPONDING #(
          lt_loaded_calendar_periods ).
      ENDIF.
    ELSE.
      lt_calendar_periods_input = it_planning_calendar_periods.
    ENDIF.

    LOOP AT lt_calendar_periods_input
        INTO DATA(ls_input_calendar_period).
      IF ls_input_calendar_period-plant IS INITIAL
          OR ls_input_calendar_period-planning_calendar_id IS INITIAL
          OR ls_input_calendar_period-start_date IS INITIAL
          OR ls_input_calendar_period-end_date IS INITIAL
          OR ls_input_calendar_period-start_date
            > ls_input_calendar_period-end_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_input_calendar_period INTO TABLE
        lt_planning_calendar_periods.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_resolved_lot_size_periods
        INTO DATA(ls_resolved_lot_period).
      IF ls_resolved_lot_period-plant IS INITIAL
          OR ls_resolved_lot_period-lot_size_procedure IS INITIAL
          OR ls_resolved_lot_period-lot_size_procedure = 'EX'
          OR ls_resolved_lot_period-lot_size_procedure = 'FX'
          OR ls_resolved_lot_period-lot_size_procedure = 'HB'
          OR ls_resolved_lot_period-lot_size_procedure = 'MB'
          OR ls_resolved_lot_period-lot_size_procedure = 'PK'
          OR ls_resolved_lot_period-lot_size_procedure = 'TB'
          OR ls_resolved_lot_period-lot_size_procedure = 'WB'
          OR ls_resolved_lot_period-start_date IS INITIAL
          OR ls_resolved_lot_period-end_date IS INITIAL
          OR ls_resolved_lot_period-start_date
            > ls_resolved_lot_period-end_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_resolved_lot_period INTO TABLE
        lt_resolved_lot_size_periods.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_resolved_lot_size_periods
        INTO DATA(ls_validated_lot_period).
      IF lv_previous_lot_period_plant = ls_validated_lot_period-plant
          AND lv_previous_lot_period_proc =
            ls_validated_lot_period-lot_size_procedure
          AND ls_validated_lot_period-start_date
            <= lv_previous_lot_period_end.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_previous_lot_period_plant = ls_validated_lot_period-plant.
      lv_previous_lot_period_proc =
        ls_validated_lot_period-lot_size_procedure.
      lv_previous_lot_period_end = ls_validated_lot_period-end_date.
    ENDLOOP.

    LOOP AT lt_planning_calendar_periods
        INTO DATA(ls_validated_calendar_period).
      IF lv_previous_period_plant = ls_validated_calendar_period-plant
          AND lv_previous_calendar_id =
            ls_validated_calendar_period-planning_calendar_id
          AND ls_validated_calendar_period-start_date
            <= lv_previous_period_end.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_previous_period_plant = ls_validated_calendar_period-plant.
      lv_previous_calendar_id =
        ls_validated_calendar_period-planning_calendar_id.
      lv_previous_period_end = ls_validated_calendar_period-end_date.
    ENDLOOP.

    LOOP AT it_shortages INTO ls_shortage.
      ADD 1 TO lv_input_index.
      CLEAR lv_group_lot_size_procedure.
      CLEAR lv_group_planning_calendar_id.
      READ TABLE lt_policies INTO ls_policy
        WITH TABLE KEY material = ls_shortage-material
                       plant = ls_shortage-plant
                       base_unit = ls_shortage-base_unit.
      IF sy-subrc = 0.
        lv_group_lot_size_procedure = ls_policy-lot_size_procedure.
        lv_group_planning_calendar_id =
          ls_policy-planning_calendar_id.
      ELSE.
        READ TABLE lt_master_policies INTO ls_master_policy
          WITH TABLE KEY material = ls_shortage-material
                         plant = ls_shortage-plant.
        IF sy-subrc = 0.
          IF ls_master_policy-base_unit <> ls_shortage-base_unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          lv_group_lot_size_procedure =
            ls_master_policy-lot_size_procedure.
          lv_group_planning_calendar_id =
            ls_master_policy-planning_calendar_id.
        ENDIF.
      ENDIF.

      CLEAR lv_period_grouping.
      IF lv_group_lot_size_procedure = 'TB'
          OR lv_group_lot_size_procedure = 'MB'
          OR lv_group_lot_size_procedure = 'WB'
          OR lv_group_lot_size_procedure = 'PK'.
        lv_period_grouping = abap_true.
      ENDIF.
      IF lv_period_grouping <> abap_true.
        LOOP AT lt_resolved_lot_size_periods
            TRANSPORTING NO FIELDS
            WHERE plant = ls_shortage-plant
              AND lot_size_procedure = lv_group_lot_size_procedure
              AND start_date <= ls_shortage-required_date
              AND end_date >= ls_shortage-required_date.
          lv_period_grouping = abap_true.
          EXIT.
        ENDLOOP.
      ENDIF.
      IF lv_period_grouping <> abap_true.
        READ TABLE lt_resolved_lot_size_periods
          TRANSPORTING NO FIELDS
          WITH KEY plant = ls_shortage-plant
            lot_size_procedure = lv_group_lot_size_procedure.
        IF sy-subrc = 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      IF lv_period_grouping = abap_true.
        DATA(ls_period_bounds) = VALUE ty_lot_size_period_bounds( ).
        CASE lv_group_lot_size_procedure.
          WHEN 'TB'.
            ls_period_bounds-start_date = ls_shortage-required_date.
            ls_period_bounds-end_date = ls_shortage-required_date.
          WHEN 'MB'.
            ls_period_bounds = get_month_period_bounds(
              iv_date = ls_shortage-required_date ).
          WHEN 'WB'.
            ls_period_bounds = get_week_period_bounds(
              iv_date               = ls_shortage-required_date
              iv_week_start_weekday = iv_week_start_weekday ).
          WHEN 'PK'.
            IF lv_group_planning_calendar_id IS INITIAL.
              CLEAR lv_period_grouping.
            ELSE.
              LOOP AT lt_planning_calendar_periods
                  INTO DATA(ls_matching_calendar_period)
                  WHERE plant = ls_shortage-plant
                    AND planning_calendar_id =
                      lv_group_planning_calendar_id
                    AND start_date <= ls_shortage-required_date
                    AND end_date >= ls_shortage-required_date.
                ls_period_bounds-start_date =
                  ls_matching_calendar_period-start_date.
                ls_period_bounds-end_date =
                  ls_matching_calendar_period-end_date.
                EXIT.
              ENDLOOP.
              IF sy-subrc <> 0.
                CLEAR lv_period_grouping.
              ENDIF.
            ENDIF.
          WHEN OTHERS.
            LOOP AT lt_resolved_lot_size_periods
                INTO DATA(ls_matching_lot_period)
                WHERE plant = ls_shortage-plant
                  AND lot_size_procedure = lv_group_lot_size_procedure
                  AND start_date <= ls_shortage-required_date
                  AND end_date >= ls_shortage-required_date.
              ls_period_bounds-start_date =
                ls_matching_lot_period-start_date.
              ls_period_bounds-end_date =
                ls_matching_lot_period-end_date.
              lv_period_grouping = abap_true.
              EXIT.
            ENDLOOP.
            IF lv_period_grouping <> abap_true.
              READ TABLE lt_resolved_lot_size_periods
                TRANSPORTING NO FIELDS
                WITH KEY plant = ls_shortage-plant
                  lot_size_procedure = lv_group_lot_size_procedure.
              IF sy-subrc = 0.
                RAISE EXCEPTION TYPE zcx_invalid_stock_request.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDIF.

      IF lv_period_grouping <> abap_true.
        APPEND VALUE #(
          material                   = ls_shortage-material
          plant                      = ls_shortage-plant
          base_unit                  = ls_shortage-base_unit
          required_date              = ls_shortage-required_date
          grouped_shortage_count     = 1
          component_count            = ls_shortage-component_count
          short_component_count      = ls_shortage-short_component_count
          affected_order_count       = ls_shortage-affected_order_count
          affected_production_orders =
            ls_shortage-affected_production_orders
          requested_base_quantity    =
            ls_shortage-requested_base_quantity
          allocated_base_quantity    =
            ls_shortage-allocated_base_quantity
          shortfall_base_quantity    =
            ls_shortage-shortfall_base_quantity
          input_index                = lv_input_index )
          TO lt_planning_shortages.
        CONTINUE.
      ENDIF.
      READ TABLE lt_period_planning_shortages ASSIGNING
        <ls_month_shortage>
        WITH TABLE KEY material = ls_shortage-material
                       plant = ls_shortage-plant
                       base_unit = ls_shortage-base_unit
                       lot_size_period_start =
                         ls_period_bounds-start_date.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          material                    = ls_shortage-material
          plant                       = ls_shortage-plant
          base_unit                   = ls_shortage-base_unit
          required_date               = ls_shortage-required_date
          lot_size_period_start       = ls_period_bounds-start_date
          lot_size_period_end         = ls_period_bounds-end_date
          affected_production_orders  =
            ls_shortage-affected_production_orders
          has_complete_order_identity = xsdbool(
            lines( ls_shortage-affected_production_orders ) =
              ls_shortage-affected_order_count )
          input_index                 = lv_input_index )
          INTO TABLE lt_period_planning_shortages.
        READ TABLE lt_period_planning_shortages ASSIGNING
          <ls_month_shortage>
          WITH TABLE KEY material = ls_shortage-material
                         plant = ls_shortage-plant
                         base_unit = ls_shortage-base_unit
                         lot_size_period_start =
                           ls_period_bounds-start_date.
      ENDIF.
      IF ls_shortage-required_date < <ls_month_shortage>-required_date.
        <ls_month_shortage>-required_date = ls_shortage-required_date.
      ENDIF.
      IF lv_input_index < <ls_month_shortage>-input_index.
        <ls_month_shortage>-input_index = lv_input_index.
      ENDIF.
      ADD 1 TO <ls_month_shortage>-grouped_shortage_count.
      <ls_month_shortage>-component_count =
        <ls_month_shortage>-component_count
          + ls_shortage-component_count.
      <ls_month_shortage>-short_component_count =
        <ls_month_shortage>-short_component_count
          + ls_shortage-short_component_count.
      IF <ls_month_shortage>-has_complete_order_identity = abap_true
          AND lines( ls_shortage-affected_production_orders ) =
            ls_shortage-affected_order_count.
        LOOP AT ls_shortage-affected_production_orders
            INTO DATA(lv_period_order_number).
          INSERT lv_period_order_number
            INTO TABLE <ls_month_shortage>-affected_production_orders.
        ENDLOOP.
      ELSE.
        <ls_month_shortage>-has_complete_order_identity = abap_false.
        CLEAR <ls_month_shortage>-affected_production_orders.
      ENDIF.
      <ls_month_shortage>-affected_order_count =
        <ls_month_shortage>-affected_order_count
          + ls_shortage-affected_order_count.
      <ls_month_shortage>-requested_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_month_shortage>-requested_base_quantity
        iv_right_quantity = ls_shortage-requested_base_quantity ).
      <ls_month_shortage>-allocated_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_month_shortage>-allocated_base_quantity
        iv_right_quantity = ls_shortage-allocated_base_quantity ).
      <ls_month_shortage>-shortfall_base_quantity = sum_stock_quantities(
        iv_left_quantity  = <ls_month_shortage>-shortfall_base_quantity
        iv_right_quantity = ls_shortage-shortfall_base_quantity ).
    ENDLOOP.

    LOOP AT lt_receipt_ordered_shortages INTO DATA(ls_month_member).
      UNASSIGN <ls_month_shortage>.
      LOOP AT lt_period_planning_shortages ASSIGNING <ls_month_shortage>
          WHERE material = ls_month_member-material
            AND plant = ls_month_member-plant
            AND base_unit = ls_month_member-base_unit
            AND lot_size_period_start <= ls_month_member-required_date
            AND lot_size_period_end >= ls_month_member-required_date.
        EXIT.
      ENDLOOP.
      IF <ls_month_shortage> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DATA(lv_member_remaining_milli) = CONV int8(
        CONV decfloat34( ls_month_member-shortfall_base_quantity )
          * 1000 ).
      LOOP AT lt_projected_receipts ASSIGNING <ls_projected_receipt>
          WHERE material = <ls_month_shortage>-material
            AND plant = <ls_month_shortage>-plant
            AND base_unit = <ls_month_shortage>-base_unit
            AND receipt_date <= ls_month_member-required_date.
        IF <ls_projected_receipt>-quantity_milli <= 0
            OR lv_member_remaining_milli <= 0.
          CONTINUE.
        ENDIF.
        DATA(lv_month_receipt_usage_milli) =
          lv_member_remaining_milli.
        IF lv_month_receipt_usage_milli >
            <ls_projected_receipt>-quantity_milli.
          lv_month_receipt_usage_milli =
            <ls_projected_receipt>-quantity_milli.
        ENDIF.
        APPEND VALUE #(
          material              = <ls_month_shortage>-material
          plant                 = <ls_month_shortage>-plant
          base_unit             = <ls_month_shortage>-base_unit
          lot_size_period_start =
            <ls_month_shortage>-lot_size_period_start
          receipt_date          = <ls_projected_receipt>-receipt_date
          quantity              = milli_to_stock_quantity(
            iv_quantity_milli = lv_month_receipt_usage_milli )
          source_type           = <ls_projected_receipt>-source_type
          source_document       = <ls_projected_receipt>-source_document
          source_item           = <ls_projected_receipt>-source_item
          source_plant          = <ls_projected_receipt>-source_plant
          source_schedule_line  =
            <ls_projected_receipt>-source_schedule_line )
          TO lt_period_rcpt_uses.
        <ls_projected_receipt>-quantity_milli =
          <ls_projected_receipt>-quantity_milli
            - lv_month_receipt_usage_milli.
        <ls_month_shortage>-pre_receipt_used_milli =
          <ls_month_shortage>-pre_receipt_used_milli
            + lv_month_receipt_usage_milli.
        lv_member_remaining_milli = lv_member_remaining_milli
          - lv_month_receipt_usage_milli.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_period_planning_shortages INTO DATA(ls_month_period_row).
      APPEND VALUE #(
        material                   = ls_month_period_row-material
        plant                      = ls_month_period_row-plant
        base_unit                  = ls_month_period_row-base_unit
        required_date              = ls_month_period_row-required_date
        lot_size_period_start      =
          ls_month_period_row-lot_size_period_start
        lot_size_period_end        = ls_month_period_row-lot_size_period_end
        grouped_shortage_count     =
          ls_month_period_row-grouped_shortage_count
        component_count            = ls_month_period_row-component_count
        short_component_count      =
          ls_month_period_row-short_component_count
        affected_order_count       = COND i(
          WHEN ls_month_period_row-has_complete_order_identity = abap_true
          THEN lines(
            ls_month_period_row-affected_production_orders )
          ELSE ls_month_period_row-affected_order_count )
        affected_production_orders =
          ls_month_period_row-affected_production_orders
        requested_base_quantity    =
          ls_month_period_row-requested_base_quantity
        allocated_base_quantity    =
          ls_month_period_row-allocated_base_quantity
        shortfall_base_quantity    =
          ls_month_period_row-shortfall_base_quantity
        input_index                = ls_month_period_row-input_index
        pre_receipt_used_milli     =
          ls_month_period_row-pre_receipt_used_milli )
        TO lt_planning_shortages.
    ENDLOOP.
    IF iv_net_prior_surplus = abap_true
        OR it_projected_receipts IS NOT INITIAL.
      SORT lt_planning_shortages BY material plant base_unit required_date.
    ELSE.
      SORT lt_planning_shortages BY input_index.
    ENDIF.

    DATA lv_lot_size_procedure TYPE marc-disls.
    DATA lv_planning_calendar_id TYPE marc-mrppp.
    DATA lv_procurement_type TYPE marc-beskz.
    DATA lv_special_procurement_key TYPE marc-sobsl.
    DATA lv_factory_calendar_id TYPE t001w-fabkl.
    DATA lv_planned_delivery_days TYPE marc-plifz.
    DATA lv_source_vendor TYPE eina-lifnr.
    DATA lv_source_purchasing_org TYPE eine-ekorg.
    DATA lv_source_info_record TYPE eina-infnr.
    DATA lv_source_agreement TYPE eord-ebeln.
    DATA lv_source_agreement_item TYPE eord-ebelp.
    DATA lv_source_category TYPE eina-esokz.
    DATA lv_source_plifz TYPE eine-aplfz.
    DATA lv_rounding_profile TYPE marc-rdprf.
    DATA lv_lead_time_days_origin TYPE ty_lead_time_origin.
    DATA lv_gr_processing_days TYPE marc-webaz.
    DATA lv_purchasing_processing_days TYPE t399d-bzteK.
    DATA lv_policy_origin TYPE c LENGTH 12.
    LOOP AT lt_planning_shortages INTO ls_planning_shortage.
      MOVE-CORRESPONDING ls_planning_shortage TO ls_shortage.
      CLEAR lt_receipt_uses.
      CLEAR lv_lot_size_procedure.
      CLEAR lv_planning_calendar_id.
      CLEAR lv_procurement_type.
      CLEAR lv_special_procurement_key.
      CLEAR lv_factory_calendar_id.
      CLEAR lv_planned_delivery_days.
      CLEAR lv_source_vendor.
      CLEAR lv_source_purchasing_org.
      CLEAR lv_source_info_record.
      CLEAR lv_source_agreement.
      CLEAR lv_source_agreement_item.
      CLEAR lv_source_category.
      CLEAR lv_source_plifz.
      CLEAR lv_rounding_profile.
      CLEAR lv_lead_time_days_origin.
      CLEAR lv_gr_processing_days.
      CLEAR lv_purchasing_processing_days.
      lv_policy_origin = 'NONE'.
      DATA(lv_minimum_quantity) = CONV mard-labst( 0 ).
      DATA(lv_maximum_quantity) = CONV mard-labst( 0 ).
      DATA(lv_maximum_stock_quantity) = CONV mard-labst( 0 ).
      DATA(lv_fixed_quantity) = CONV mard-labst( 0 ).
      DATA(lv_order_multiple) = CONV mard-labst( 0 ).
      READ TABLE lt_policies INTO ls_policy
        WITH TABLE KEY material = ls_shortage-material
                       plant = ls_shortage-plant
                       base_unit = ls_shortage-base_unit.
      IF sy-subrc = 0.
        lv_lot_size_procedure = ls_policy-lot_size_procedure.
        lv_planning_calendar_id = ls_policy-planning_calendar_id.
        lv_procurement_type = ls_policy-procurement_type.
        lv_special_procurement_key =
          ls_policy-special_procurement_key.
        lv_factory_calendar_id = ls_policy-factory_calendar_id.
        lv_planned_delivery_days = ls_policy-planned_delivery_days.
        lv_source_vendor = ls_policy-source_vendor.
        lv_source_purchasing_org = ls_policy-source_purchasing_org.
        lv_source_info_record = ls_policy-source_info_record.
        lv_source_agreement = ls_policy-source_agreement.
        lv_source_agreement_item = ls_policy-source_agreement_item.
        lv_source_category = ls_policy-source_category.
        lv_source_plifz =
          ls_policy-source_planned_delivery_days.
        lv_rounding_profile = ls_policy-rounding_profile.
        lv_lead_time_days_origin = c_repl_days_origin_caller.
        lv_gr_processing_days =
          ls_policy-goods_receipt_processing_days.
        lv_purchasing_processing_days =
          ls_policy-purchasing_processing_days.
        lv_policy_origin = 'CALLER'.
        IF lv_lot_size_procedure IS INITIAL.
          lv_minimum_quantity = ls_policy-minimum_base_quantity.
          lv_maximum_quantity = ls_policy-maximum_base_quantity.
          lv_fixed_quantity = ls_policy-fixed_base_quantity.
          lv_order_multiple = ls_policy-order_multiple_base_quantity.
        ELSE.
          CASE lv_lot_size_procedure.
            WHEN 'EX' OR 'TB' OR 'MB' OR 'WB' OR 'PK'.
              lv_minimum_quantity = ls_policy-minimum_base_quantity.
              lv_maximum_quantity = ls_policy-maximum_base_quantity.
              lv_order_multiple =
                ls_policy-order_multiple_base_quantity.
            WHEN 'FX'.
              IF ls_policy-fixed_base_quantity > 0.
                lv_fixed_quantity = ls_policy-fixed_base_quantity.
              ELSE.
                lv_policy_origin = 'UNSUPPORTED'.
              ENDIF.
            WHEN 'HB'.
              IF ls_policy-maximum_stock_quantity > 0.
                lv_maximum_stock_quantity =
                  ls_policy-maximum_stock_quantity.
              ELSE.
                lv_policy_origin = 'UNSUPPORTED'.
              ENDIF.
            WHEN OTHERS.
              READ TABLE lt_resolved_lot_size_periods
                TRANSPORTING NO FIELDS
                WITH KEY plant = ls_policy-plant
                  lot_size_procedure = ls_policy-lot_size_procedure.
              IF sy-subrc = 0.
                lv_minimum_quantity = ls_policy-minimum_base_quantity.
                lv_maximum_quantity = ls_policy-maximum_base_quantity.
                lv_order_multiple =
                  ls_policy-order_multiple_base_quantity.
              ELSE.
                lv_policy_origin = 'UNSUPPORTED'.
              ENDIF.
          ENDCASE.
        ENDIF.
      ELSE.
        READ TABLE lt_master_policies INTO ls_master_policy
          WITH TABLE KEY material = ls_shortage-material
                         plant = ls_shortage-plant.
        IF sy-subrc = 0.
          IF ls_master_policy-base_unit <> ls_shortage-base_unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          lv_lot_size_procedure = ls_master_policy-lot_size_procedure.
          lv_planning_calendar_id =
            ls_master_policy-planning_calendar_id.
          lv_rounding_profile = ls_master_policy-rounding_profile.
          lv_procurement_type = ls_master_policy-procurement_type.
          lv_special_procurement_key =
            ls_master_policy-special_procurement_key.
          lv_factory_calendar_id = ls_master_policy-factory_calendar_id.
          lv_planned_delivery_days =
            ls_master_policy-planned_delivery_days.
          lv_lead_time_days_origin = c_repl_days_origin_material.
          lv_gr_processing_days =
            ls_master_policy-goods_receipt_processing_days.
          lv_purchasing_processing_days =
            ls_master_policy-purchasing_processing_days.
          CASE lv_lot_size_procedure.
            WHEN 'EX' OR 'TB' OR 'MB' OR 'WB' OR 'PK'.
              lv_policy_origin = 'MARC'.
              lv_minimum_quantity =
                ls_master_policy-minimum_base_quantity.
              lv_maximum_quantity =
                ls_master_policy-maximum_base_quantity.
              lv_order_multiple =
                ls_master_policy-order_multiple_base_quantity.
            WHEN 'FX'.
              IF ls_master_policy-fixed_base_quantity > 0.
                lv_policy_origin = 'MARC'.
                lv_fixed_quantity =
                  ls_master_policy-fixed_base_quantity.
              ELSE.
                lv_policy_origin = 'UNSUPPORTED'.
              ENDIF.
            WHEN 'HB'.
              IF ls_master_policy-maximum_stock_quantity > 0.
                lv_policy_origin = 'MARC'.
                lv_maximum_stock_quantity =
                  ls_master_policy-maximum_stock_quantity.
              ELSE.
                lv_policy_origin = 'UNSUPPORTED'.
              ENDIF.
            WHEN OTHERS.
              READ TABLE lt_resolved_lot_size_periods
                TRANSPORTING NO FIELDS
                WITH KEY plant = ls_master_policy-plant
                  lot_size_procedure =
                    ls_master_policy-lot_size_procedure.
              IF sy-subrc = 0.
                lv_policy_origin = 'MARC'.
                lv_minimum_quantity =
                  ls_master_policy-minimum_base_quantity.
                lv_maximum_quantity =
                  ls_master_policy-maximum_base_quantity.
                lv_order_multiple =
                  ls_master_policy-order_multiple_base_quantity.
              ELSE.
                lv_policy_origin = 'UNSUPPORTED'.
              ENDIF.
          ENDCASE.
        ENDIF.
      ENDIF.

      IF lv_source_plifz > 0.
        lv_planned_delivery_days = lv_source_plifz.
        lv_lead_time_days_origin = c_repl_days_origin_info_record.
      ELSEIF lv_lead_time_days_origin IS INITIAL.
        lv_lead_time_days_origin = c_repl_days_origin_none.
      ENDIF.

      DATA(lv_original_shortfall_milli) = CONV int8(
        CONV decfloat34( ls_shortage-shortfall_base_quantity ) * 1000 ).
      DATA(lv_receipt_used_milli) =
        ls_planning_shortage-pre_receipt_used_milli.
      IF ls_planning_shortage-lot_size_period_start IS NOT INITIAL.
        LOOP AT lt_period_rcpt_uses
            INTO DATA(ls_month_receipt_use)
            WHERE material = ls_planning_shortage-material
              AND plant = ls_planning_shortage-plant
              AND base_unit = ls_planning_shortage-base_unit
              AND lot_size_period_start =
                ls_planning_shortage-lot_size_period_start.
          APPEND VALUE #(
            receipt_date         = ls_month_receipt_use-receipt_date
            quantity             = ls_month_receipt_use-quantity
            source_type          = ls_month_receipt_use-source_type
            source_document      = ls_month_receipt_use-source_document
            source_item          = ls_month_receipt_use-source_item
            source_plant         = ls_month_receipt_use-source_plant
            source_schedule_line =
              ls_month_receipt_use-source_schedule_line )
            TO lt_receipt_uses.
        ENDLOOP.
      ELSE.
        CLEAR lv_receipt_used_milli.
        LOOP AT lt_projected_receipts ASSIGNING <ls_projected_receipt>
            WHERE material = ls_shortage-material
              AND plant = ls_shortage-plant
              AND base_unit = ls_shortage-base_unit
              AND receipt_date <= ls_shortage-required_date.
          IF <ls_projected_receipt>-quantity_milli <= 0.
            CONTINUE.
          ENDIF.
          DATA(lv_remaining_shortfall_milli) =
            lv_original_shortfall_milli
              - lv_receipt_used_milli.
          IF lv_remaining_shortfall_milli <= 0.
            EXIT.
          ENDIF.
          DATA(lv_receipt_usage_milli) = lv_remaining_shortfall_milli.
          IF lv_receipt_usage_milli >
              <ls_projected_receipt>-quantity_milli.
            lv_receipt_usage_milli =
              <ls_projected_receipt>-quantity_milli.
          ENDIF.
          APPEND VALUE #(
            receipt_date         = <ls_projected_receipt>-receipt_date
            quantity             = milli_to_stock_quantity(
            iv_quantity_milli = lv_receipt_usage_milli )
            source_type          = <ls_projected_receipt>-source_type
            source_document      = <ls_projected_receipt>-source_document
            source_item          = <ls_projected_receipt>-source_item
            source_plant         = <ls_projected_receipt>-source_plant
            source_schedule_line =
              <ls_projected_receipt>-source_schedule_line )
            TO lt_receipt_uses.
          <ls_projected_receipt>-quantity_milli =
            <ls_projected_receipt>-quantity_milli
              - lv_receipt_usage_milli.
          lv_receipt_used_milli =
            lv_receipt_used_milli + lv_receipt_usage_milli.
        ENDLOOP.
      ENDIF.

      DATA(lv_available_surplus_milli) = CONV int8( 0 ).
      IF iv_net_prior_surplus = abap_true.
        READ TABLE lt_prior_surpluses INTO DATA(ls_prior_surplus)
          WITH TABLE KEY material = ls_shortage-material
                         plant = ls_shortage-plant
                         base_unit = ls_shortage-base_unit.
        IF sy-subrc = 0.
          lv_available_surplus_milli = ls_prior_surplus-quantity_milli.
        ENDIF.
      ENDIF.
      DATA(lv_prior_surplus_used_milli) = CONV int8( 0 ).
      IF iv_net_prior_surplus = abap_true.
        lv_prior_surplus_used_milli = lv_original_shortfall_milli
          - lv_receipt_used_milli.
      ENDIF.
      IF lv_prior_surplus_used_milli > lv_available_surplus_milli.
        lv_prior_surplus_used_milli = lv_available_surplus_milli.
      ENDIF.
      DATA(lv_planning_shortfall_milli) =
        lv_original_shortfall_milli - lv_receipt_used_milli
          - lv_prior_surplus_used_milli.
      DATA(lv_target_milli) = lv_planning_shortfall_milli.
      DATA(lv_minimum_milli) = CONV int8(
        CONV decfloat34( lv_minimum_quantity ) * 1000 ).
      DATA(lv_fixed_milli) = CONV int8(
        CONV decfloat34( lv_fixed_quantity ) * 1000 ).
      DATA(lv_multiple_milli) = CONV int8(
        CONV decfloat34( lv_order_multiple ) * 1000 ).
      DATA(lv_maximum_milli) = CONV int8(
        CONV decfloat34( lv_maximum_quantity ) * 1000 ).
      DATA(lv_maximum_stock_milli) = CONV int8(
        CONV decfloat34( lv_maximum_stock_quantity ) * 1000 ).
      DATA(lv_receipt_count) = CONV int8( 1 ).
      DATA(lv_final_receipt_milli) = lv_target_milli.

      IF lv_planning_shortfall_milli = 0.
        CLEAR lv_receipt_count.
        CLEAR lv_final_receipt_milli.
      ELSEIF lv_policy_origin = 'UNSUPPORTED'
          OR ( lv_maximum_milli > 0
            AND lv_minimum_milli > lv_maximum_milli ).
        lv_policy_origin = 'UNSUPPORTED'.
        CLEAR lv_minimum_quantity.
        CLEAR lv_maximum_quantity.
        CLEAR lv_maximum_stock_quantity.
        CLEAR lv_fixed_quantity.
        CLEAR lv_order_multiple.
        lv_target_milli = lv_planning_shortfall_milli.
        lv_final_receipt_milli = lv_target_milli.
      ELSE.
        IF lv_lot_size_procedure = 'HB'.
          IF lv_target_milli < lv_maximum_stock_milli.
            lv_target_milli = lv_maximum_stock_milli.
          ENDIF.
          lv_final_receipt_milli = lv_target_milli.
        ELSE.
          IF lv_target_milli < lv_minimum_milli.
            lv_target_milli = lv_minimum_milli.
          ENDIF.

          IF lv_fixed_milli > 0.
            lv_multiple_milli = lv_fixed_milli.
          ENDIF.
          IF lv_multiple_milli > 0.
            DATA(lv_lot_count) = lv_target_milli DIV lv_multiple_milli.
            IF lv_target_milli MOD lv_multiple_milli > 0.
              ADD 1 TO lv_lot_count.
            ENDIF.
            lv_target_milli = lv_lot_count * lv_multiple_milli.
          ENDIF.

          IF lv_fixed_milli > 0.
            lv_receipt_count = lv_target_milli DIV lv_fixed_milli.
            lv_final_receipt_milli = lv_fixed_milli.
            CLEAR lv_maximum_quantity.
          ELSEIF lv_maximum_milli > 0
              AND lv_target_milli > lv_maximum_milli.
            DATA(lv_full_lot_count) =
              lv_target_milli DIV lv_maximum_milli.
            lv_receipt_count = lv_full_lot_count.
            lv_final_receipt_milli =
              lv_target_milli MOD lv_maximum_milli.
            IF lv_final_receipt_milli > 0.
              IF lv_final_receipt_milli < lv_minimum_milli.
                lv_final_receipt_milli = lv_minimum_milli.
              ENDIF.
              IF lv_multiple_milli > 0.
                DATA(lv_final_lot_count) =
                  lv_final_receipt_milli DIV lv_multiple_milli.
                IF lv_final_receipt_milli MOD lv_multiple_milli > 0.
                  ADD 1 TO lv_final_lot_count.
                ENDIF.
                lv_final_receipt_milli =
                  lv_final_lot_count * lv_multiple_milli.
              ENDIF.
              IF lv_final_receipt_milli > lv_maximum_milli.
                lv_policy_origin = 'UNSUPPORTED'.
                CLEAR lv_minimum_quantity.
                CLEAR lv_maximum_quantity.
                CLEAR lv_maximum_stock_quantity.
                CLEAR lv_fixed_quantity.
                CLEAR lv_order_multiple.
                lv_target_milli = lv_planning_shortfall_milli.
                lv_receipt_count = 1.
                lv_final_receipt_milli = lv_target_milli.
              ELSE.
                ADD 1 TO lv_receipt_count.
                lv_target_milli = lv_full_lot_count * lv_maximum_milli
                  + lv_final_receipt_milli.
              ENDIF.
            ELSE.
              lv_final_receipt_milli = lv_maximum_milli.
              lv_target_milli = lv_full_lot_count * lv_maximum_milli.
            ENDIF.
          ELSE.
            lv_final_receipt_milli = lv_target_milli.
          ENDIF.
        ENDIF.
      ENDIF.

      IF lv_rounding_profile IS NOT INITIAL
          AND lv_target_milli > 0
          AND lv_policy_origin <> 'UNSUPPORTED'.
        DATA(lv_full_receipt_count) = lv_receipt_count - 1.
        DATA(lv_rounded_full_receipt_milli) = CONV int8( 0 ).
        IF lv_full_receipt_count > 0.
          DATA(lv_full_receipt_source_milli) = lv_maximum_milli.
          IF lv_fixed_milli > 0.
            lv_full_receipt_source_milli = lv_fixed_milli.
          ENDIF.
          DATA(lv_rounded_full_quantity) = round_replenishment_quantity(
            iv_plant          = ls_shortage-plant
            iv_profile        = lv_rounding_profile
            iv_quantity       = CONV decfloat34(
              CONV string( lv_full_receipt_source_milli ) ) / 1000
            it_profile_values = lt_rounding_profiles ).
          lv_rounded_full_receipt_milli = CONV int8(
            lv_rounded_full_quantity * 1000 ).
          IF lv_maximum_milli > 0
              AND lv_rounded_full_receipt_milli > lv_maximum_milli.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ENDIF.
        DATA(lv_rounded_final_quantity) = round_replenishment_quantity(
          iv_plant          = ls_shortage-plant
          iv_profile        = lv_rounding_profile
          iv_quantity       = CONV decfloat34(
            CONV string( lv_final_receipt_milli ) ) / 1000
          it_profile_values = lt_rounding_profiles ).
        DATA(lv_rounded_final_milli) = CONV int8(
          lv_rounded_final_quantity * 1000 ).
        IF lv_maximum_milli > 0
            AND lv_rounded_final_milli > lv_maximum_milli.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_target_milli = lv_full_receipt_count
          * lv_rounded_full_receipt_milli + lv_rounded_final_milli.
        lv_final_receipt_milli = lv_rounded_final_milli.
      ENDIF.

      DATA(lv_suggested_quantity) = milli_to_stock_quantity(
            iv_quantity_milli = lv_target_milli ).
      DATA(lv_final_receipt_quantity) = milli_to_stock_quantity(
            iv_quantity_milli = lv_final_receipt_milli ).
      DATA(lv_planning_shortfall_quantity) = milli_to_stock_quantity(
            iv_quantity_milli = lv_planning_shortfall_milli ).
      DATA(lv_prior_surplus_used_quantity) = milli_to_stock_quantity(
            iv_quantity_milli = lv_prior_surplus_used_milli ).
      DATA(lv_receipt_used_quantity) = milli_to_stock_quantity(
            iv_quantity_milli = lv_receipt_used_milli ).
      DATA(lv_rounding_surplus_milli) = lv_available_surplus_milli
        - lv_prior_surplus_used_milli + lv_target_milli
        - lv_planning_shortfall_milli.
      DATA(lv_round_surplus_qty) = milli_to_stock_quantity(
            iv_quantity_milli = lv_rounding_surplus_milli ).
      CLEAR ls_timing.
      IF lv_planning_shortfall_milli = 0.
        IF lv_receipt_used_milli > 0
            AND lv_prior_surplus_used_milli > 0.
          ls_timing-lead_time_status = c_repl_status_supply.
        ELSEIF lv_receipt_used_milli > 0.
          ls_timing-lead_time_status = c_repl_status_receipt.
        ELSE.
          ls_timing-lead_time_status = c_repl_status_covered.
        ENDIF.
      ELSE.
        ls_timing = estimate_repl_timing(
          iv_required_date              = ls_shortage-required_date
          iv_policy_origin              = lv_policy_origin
          iv_procurement_type           = lv_procurement_type
          iv_special_procurement_key    = lv_special_procurement_key
          iv_factory_calendar_id        = lv_factory_calendar_id
          iv_planned_delivery_days      = lv_planned_delivery_days
          iv_gr_processing_days         = lv_gr_processing_days
          iv_purchasing_processing_days = lv_purchasing_processing_days ).
      ENDIF.
      DATA(lv_pr_release_is_overdue) = abap_false.
      DATA(lv_pr_release_days_overdue) = 0.
      DATA(lv_pr_release_urgency) = c_pr_urgency_no_estimate.
      IF ls_timing-latest_pr_release_date IS NOT INITIAL.
        DATA(lv_release_date_delta) =
          CONV i( ls_timing-latest_pr_release_date - iv_as_of_date ).
        IF lv_release_date_delta < 0.
          lv_pr_release_is_overdue = abap_true.
          lv_pr_release_days_overdue = 0 - lv_release_date_delta.
          lv_pr_release_urgency = c_pr_urgency_overdue.
        ELSEIF lv_release_date_delta = 0.
          lv_pr_release_urgency = c_pr_urgency_due_today.
        ELSE.
          lv_pr_release_urgency = c_pr_urgency_upcoming.
        ENDIF.
      ENDIF.
      IF iv_net_prior_surplus = abap_true.
        DATA(lv_remaining_surplus_milli) =
          lv_available_surplus_milli - lv_prior_surplus_used_milli.
        DATA(lv_new_surplus_milli) = lv_target_milli
          - lv_planning_shortfall_milli.
        DATA(lv_updated_surplus_milli) = lv_remaining_surplus_milli
          + lv_new_surplus_milli.
        READ TABLE lt_prior_surpluses ASSIGNING <ls_prior_surplus>
          WITH TABLE KEY material = ls_shortage-material
                         plant = ls_shortage-plant
                         base_unit = ls_shortage-base_unit.
        IF sy-subrc = 0.
          <ls_prior_surplus>-quantity_milli = lv_updated_surplus_milli.
        ELSE.
          INSERT VALUE #(
            material       = ls_shortage-material
            plant          = ls_shortage-plant
            base_unit      = ls_shortage-base_unit
            quantity_milli = lv_updated_surplus_milli )
            INTO TABLE lt_prior_surpluses.
        ENDIF.
      ENDIF.
      APPEND VALUE #(
        material                       = ls_shortage-material
        plant                          = ls_shortage-plant
        base_unit                      = ls_shortage-base_unit
        required_date                  = ls_shortage-required_date
        lot_size_period_start          =
          ls_planning_shortage-lot_size_period_start
        lot_size_period_end            =
          ls_planning_shortage-lot_size_period_end
        grouped_shortage_count         =
          ls_planning_shortage-grouped_shortage_count
        component_count                = ls_shortage-component_count
        affected_order_count           = ls_shortage-affected_order_count
        affected_production_orders     =
          ls_shortage-affected_production_orders
        lot_size_procedure             = lv_lot_size_procedure
        planning_calendar_id           = lv_planning_calendar_id
        rounding_profile               = lv_rounding_profile
        policy_origin                  = lv_policy_origin
        procurement_type               = lv_procurement_type
        special_procurement_key        = lv_special_procurement_key
        factory_calendar_id            = lv_factory_calendar_id
        planned_delivery_days          = lv_planned_delivery_days
        source_vendor                  = lv_source_vendor
        source_purchasing_org          = lv_source_purchasing_org
        source_info_record             = lv_source_info_record
        source_agreement               = lv_source_agreement
        source_agreement_item          = lv_source_agreement_item
        source_category                = lv_source_category
        source_planned_delivery_days   = lv_source_plifz
        lead_time_days_origin          = lv_lead_time_days_origin
        goods_receipt_processing_days  =
          lv_gr_processing_days
        purchasing_processing_days     = lv_purchasing_processing_days
        estimated_delivery_date        = ls_timing-estimated_delivery_date
        latest_purchase_order_date     =
          ls_timing-latest_purchase_order_date
        latest_pr_release_date         =
          ls_timing-latest_pr_release_date
        as_of_date                     = iv_as_of_date
        pr_release_is_overdue          = lv_pr_release_is_overdue
        pr_release_days_overdue        = lv_pr_release_days_overdue
        pr_release_urgency             = lv_pr_release_urgency
        lead_time_status               = ls_timing-lead_time_status
        shortfall_base_quantity        = ls_shortage-shortfall_base_quantity
        planning_shortfall_qty         = lv_planning_shortfall_quantity
        projected_receipt_used_qty     = lv_receipt_used_quantity
        projected_receipt_uses         = lt_receipt_uses
        prior_surplus_used_qty         = lv_prior_surplus_used_quantity
        minimum_base_quantity          = lv_minimum_quantity
        maximum_base_quantity          = lv_maximum_quantity
        maximum_stock_quantity         = lv_maximum_stock_quantity
        fixed_base_quantity            = lv_fixed_quantity
        order_multiple_base_quantity   = lv_order_multiple
        suggested_base_quantity        = lv_suggested_quantity
        suggested_receipt_count        = lv_receipt_count
        final_receipt_base_quantity    = lv_final_receipt_quantity
        rounding_surplus_base_quantity = lv_round_surplus_qty )
      TO rt_suggestions.
    ENDLOOP.
  ENDMETHOD.

  METHOD suggest_comp_repl_from_stock.
    TYPES:
      BEGIN OF ty_receipt_request,
        material     TYPE mard-matnr,
        plant        TYPE mard-werks,
        through_date TYPE d,
      END OF ty_receipt_request.
    TYPES:
      BEGIN OF ty_replenishment_receipt_key,
        material  TYPE mard-matnr,
        plant     TYPE mard-werks,
        base_unit TYPE mara-meins,
      END OF ty_replenishment_receipt_key.
    DATA lt_receipt_requests TYPE HASHED TABLE OF ty_receipt_request
      WITH UNIQUE KEY material plant.
    DATA lt_po_conf_requests TYPE
      zcl_stock_service=>ty_projected_receipt_requests.
    DATA lt_receipt_keys TYPE HASHED TABLE OF
      ty_replenishment_receipt_key
      WITH UNIQUE KEY material plant base_unit.
    DATA lt_seen_shortages TYPE HASHED TABLE OF ty_component_shortage
      WITH UNIQUE KEY material plant base_unit required_date.
    DATA lt_projected_receipts TYPE ty_projected_receipts.
    DATA lv_request_index TYPE i.
    DATA lv_request_id TYPE c LENGTH 30.
    FIELD-SYMBOLS <ls_receipt_request> TYPE ty_receipt_request.

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
          AND iv_include_sched_agmt_receipts <> abap_false )
        OR ( iv_net_prior_surplus <> abap_true
          AND iv_net_prior_surplus <> abap_false )
        OR iv_week_start_weekday < 1
        OR iv_week_start_weekday > 7.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_shortages INTO DATA(ls_shortage).
      IF ls_shortage-material IS INITIAL
          OR ls_shortage-plant IS INITIAL
          OR ls_shortage-base_unit IS INITIAL
          OR ls_shortage-required_date IS INITIAL
          OR ls_shortage-component_count <= 0
          OR ls_shortage-affected_order_count < 0
          OR ls_shortage-requested_base_quantity < 0
          OR ls_shortage-allocated_base_quantity < 0
          OR ls_shortage-shortfall_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF sum_stock_quantities(
          iv_left_quantity  = ls_shortage-allocated_base_quantity
          iv_right_quantity = ls_shortage-shortfall_base_quantity )
            <> ls_shortage-requested_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_shortage INTO TABLE lt_seen_shortages.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        material  = ls_shortage-material
        plant     = ls_shortage-plant
        base_unit = ls_shortage-base_unit ) INTO TABLE lt_receipt_keys.

      READ TABLE lt_receipt_requests ASSIGNING <ls_receipt_request>
        WITH TABLE KEY material = ls_shortage-material
                       plant = ls_shortage-plant.
      IF sy-subrc = 0.
        IF ls_shortage-required_date > <ls_receipt_request>-through_date.
          <ls_receipt_request>-through_date = ls_shortage-required_date.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material     = ls_shortage-material
          plant        = ls_shortage-plant
          through_date = ls_shortage-required_date )
          INTO TABLE lt_receipt_requests.
      ENDIF.
    ENDLOOP.

    IF iv_include_po_receipts = abap_true
        OR iv_include_sto_in_transit = abap_true
        OR iv_include_unissued_sto = abap_true
        OR iv_include_prod_receipts = abap_true
        OR iv_include_pr_receipts = abap_true
        OR iv_include_sto_pr_receipts = abap_true
        OR iv_include_planned_receipts = abap_true
        OR iv_include_fixed_planned = abap_true
        OR iv_include_sched_agmt_receipts = abap_true.
      LOOP AT lt_receipt_requests INTO DATA(ls_receipt_request).
        DATA(lt_material_receipts) = mo_stock_service->get_projected_receipts(
          iv_material                    = ls_receipt_request-material
          iv_plant                       = ls_receipt_request-plant
          iv_through_date                = ls_receipt_request-through_date
          iv_include_po_receipts         = iv_include_po_receipts
          iv_include_sto_in_transit      = iv_include_sto_in_transit
          iv_include_unissued_sto        = iv_include_unissued_sto
          iv_include_prod_receipts       = iv_include_prod_receipts
          iv_include_pr_receipts         = iv_include_pr_receipts
          iv_include_sto_pr_receipts     = iv_include_sto_pr_receipts
          iv_include_planned_receipts    = iv_include_planned_receipts
          iv_include_fixed_planned       = iv_include_fixed_planned
          iv_include_sched_agmt_receipts = iv_include_sched_agmt_receipts ).
        LOOP AT lt_material_receipts INTO DATA(ls_receipt).
          READ TABLE lt_receipt_keys TRANSPORTING NO FIELDS
            WITH TABLE KEY material = ls_receipt-material
                           plant = ls_receipt-plant
                           base_unit = ls_receipt-base_unit.
          IF sy-subrc = 0.
            APPEND CORRESPONDING #( ls_receipt ) TO lt_projected_receipts.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF iv_include_po_confirmations = abap_true.
      LOOP AT lt_receipt_requests INTO DATA(ls_po_conf_request).
        ADD 1 TO lv_request_index.
        lv_request_id = lv_request_index.
        APPEND VALUE #(
          request_id   = lv_request_id
          material     = ls_po_conf_request-material
          plant        = ls_po_conf_request-plant
          through_date = ls_po_conf_request-through_date )
          TO lt_po_conf_requests.
      ENDLOOP.

      DATA(lt_po_conf_results) = mo_stock_service->get_po_conf_receipts_bulk(
        it_requests = lt_po_conf_requests ).
      LOOP AT lt_po_conf_results INTO DATA(ls_po_conf_result).
        LOOP AT ls_po_conf_result-receipts INTO DATA(ls_po_conf_receipt).
          READ TABLE lt_receipt_keys TRANSPORTING NO FIELDS
            WITH TABLE KEY material = ls_po_conf_receipt-material
                           plant = ls_po_conf_receipt-plant
                           base_unit = ls_po_conf_receipt-base_unit.
          IF sy-subrc = 0.
            APPEND CORRESPONDING #( ls_po_conf_receipt )
              TO lt_projected_receipts.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    rt_suggestions = suggest_comp_replenishment(
      it_shortages                 = it_shortages
      it_policies                  = it_policies
      it_projected_receipts        = lt_projected_receipts
      it_planning_calendar_periods = it_planning_calendar_periods
      it_resolved_lot_size_periods = it_resolved_lot_size_periods
      iv_as_of_date                = iv_as_of_date
      iv_net_prior_surplus         = iv_net_prior_surplus
      iv_week_start_weekday        = iv_week_start_weekday ).
  ENDMETHOD.

  METHOD issue_components.
    DATA lt_bulk_requests TYPE ty_bulk_issue_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        production_order   = iv_production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_request-quantity
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_bulk_requests.
    ENDLOOP.

    rs_result = issue_components_bulk(
      is_header   = is_header
      it_requests = lt_bulk_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_components_in_unit.
    DATA lt_bulk_requests TYPE ty_bulk_issue_requests_in_unit.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        production_order   = iv_production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_request-quantity
        unit               = ls_request-unit
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_bulk_requests.
    ENDLOOP.

    rs_result = issue_components_bulk_in_unit(
      is_header   = is_header
      it_requests = lt_bulk_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_components_bulk.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      INSERT ls_request-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_request-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.

    DATA(lt_components) = get_open_components_bulk(
      it_production_orders = lt_production_orders ).

    rs_result = post_component_issues_bulk(
      is_header     = is_header
      it_requests   = it_requests
      it_components = lt_components
      iv_test_run   = iv_test_run ).
  ENDMETHOD.

  METHOD preview_remaining_components.
    DATA lt_seen_keys TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    DATA lt_components TYPE ty_components.
    DATA lt_seen_components TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.

    IF it_component_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_component_keys INTO DATA(ls_component_key).
      IF ls_component_key-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      IF ls_component_key-reservation_number IS INITIAL
          OR ls_component_key-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        production_order   = ls_component_key-production_order
        reservation_number = ls_component_key-reservation_number
        reservation_item   = ls_component_key-reservation_item )
        INTO TABLE lt_seen_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_component_key-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_component_key-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.

    lt_components = get_open_components_bulk(
      it_production_orders = lt_production_orders ).
    LOOP AT lt_components INTO DATA(ls_component).
      INSERT VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number
        reservation_item   = ls_component-reservation_item )
        INTO TABLE lt_seen_components.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_component_keys INTO ls_component_key.
      READ TABLE lt_components INTO ls_component
        WITH KEY production_order   = ls_component_key-production_order
                 reservation_number = ls_component_key-reservation_number
                 reservation_item   = ls_component_key-reservation_item.
      IF sy-subrc <> 0 OR ls_component-movement_type <> '261'.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_component TO rt_components.
    ENDLOOP.
  ENDMETHOD.

  METHOD issue_remaining_components.
    DATA lt_requests TYPE ty_bulk_issue_requests.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_components) = preview_remaining_components(
      it_component_keys = it_component_keys ).
    LOOP AT lt_components INTO DATA(ls_component).
      APPEND VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number
        reservation_item   = ls_component-reservation_item
        quantity           = ls_component-open_quantity
        storage_location   = ls_component-storage_location
        batch              = ls_component-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = issue_components_bulk(
      is_header   = is_header
      it_requests = lt_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_remaining_bulk.
    DATA lt_components TYPE ty_components.
    DATA lt_groups TYPE STANDARD TABLE OF ty_component_reservation_key
      WITH EMPTY KEY.
    DATA lt_seen_groups TYPE HASHED TABLE OF ty_component_reservation_key
      WITH UNIQUE KEY production_order reservation_number.
    DATA lt_reservation_orders TYPE HASHED TABLE OF
      ty_component_reservation_key WITH UNIQUE KEY reservation_number.
    DATA lt_requests TYPE ty_bulk_issue_requests.
    DATA lt_group_requests TYPE ty_issue_requests.
    FIELD-SYMBOLS <ls_result_item> TYPE ty_bulk_component_issue_item.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR it_component_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    lt_components = preview_remaining_components(
      it_component_keys = it_component_keys ).
    LOOP AT lt_components INTO DATA(ls_component).
      IF ls_component-movement_type <> '261'
          OR ls_component-required_quantity < 0
          OR ls_component-withdrawn_quantity < 0
          OR ls_component-open_quantity <= 0
          OR ls_component-required_quantity
            < ls_component-withdrawn_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE lt_reservation_orders INTO DATA(ls_reservation_order)
        WITH TABLE KEY reservation_number = ls_component-reservation_number.
      IF sy-subrc = 0.
        IF ls_reservation_order-production_order
            <> ls_component-production_order.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          production_order   = ls_component-production_order
          reservation_number = ls_component-reservation_number )
          INTO TABLE lt_reservation_orders.
      ENDIF.

      INSERT VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number )
        INTO TABLE lt_seen_groups.
      IF sy-subrc = 0.
        APPEND VALUE #(
          production_order   = ls_component-production_order
          reservation_number = ls_component-reservation_number )
          TO lt_groups.
      ENDIF.
      APPEND VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number
        reservation_item   = ls_component-reservation_item
        quantity           = ls_component-open_quantity
        storage_location   = ls_component-storage_location
        batch              = ls_component-batch ) TO lt_requests.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT lt_groups INTO DATA(ls_result_group).
      APPEND VALUE #(
        production_order   = ls_result_group-production_order
        reservation_number = ls_result_group-reservation_number )
        TO rs_result-items.
    ENDLOOP.

    LOOP AT rs_result-items ASSIGNING <ls_result_item>.
      <ls_result_item>-is_attempted = abap_true.
      CLEAR lt_group_requests.
      LOOP AT lt_requests INTO DATA(ls_request)
          WHERE production_order = <ls_result_item>-production_order
            AND reservation_number =
              <ls_result_item>-reservation_number.
        APPEND VALUE #(
          reservation_number = ls_request-reservation_number
          reservation_item   = ls_request-reservation_item
          quantity           = ls_request-quantity
          storage_location   = ls_request-storage_location
          batch              = ls_request-batch ) TO lt_group_requests.
      ENDLOOP.

      TRY.
          <ls_result_item>-movement_result = issue_components(
            iv_production_order = <ls_result_item>-production_order
            is_header           = is_header
            it_requests         = lt_group_requests
            iv_test_run         = iv_test_run ).
        CATCH zcx_invalid_production_order.
          APPEND VALUE #(
            type    = 'E'
            message = 'Component issue failed production order validation' )
            TO <ls_result_item>-movement_result-messages.
        CATCH zcx_invalid_goods_movement.
          APPEND VALUE #(
            type    = 'E'
            message = 'Component issue failed goods movement validation' )
            TO <ls_result_item>-movement_result-messages.
      ENDTRY.

      <ls_result_item>-is_successful =
        <ls_result_item>-movement_result-is_successful.
      IF <ls_result_item>-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        IF iv_test_run = abap_false.
          <ls_result_item>-is_committed = abap_true.
        ENDIF.
        IF <ls_result_item>-is_committed = abap_true.
          rs_result-is_committed = abap_true.
        ENDIF.
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result_item>
          WHERE is_attempted = abap_false.
        <ls_result_item>-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD issue_components_bulk_in_unit.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_request-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.

    DATA(lt_components) = get_open_components_bulk(
      it_production_orders = lt_production_orders ).
    DATA lt_seen TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_base_requests TYPE ty_bulk_issue_requests.

    LOOP AT it_requests INTO ls_request.
      INSERT VALUE #(
        production_order   = ls_request-production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE lt_components INTO DATA(ls_component)
        WITH KEY production_order   = ls_request-production_order
                 reservation_number = ls_request-reservation_number
                 reservation_item   = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_component-material IS INITIAL
          OR ls_component-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_component-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_component-unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        production_order   = ls_request-production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_conversion-base_quantity
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_base_requests.
    ENDLOOP.

    rs_result = post_component_issues_bulk(
      is_header     = is_header
      it_requests   = lt_base_requests
      it_components = lt_components
      iv_test_run   = iv_test_run ).
  ENDMETHOD.

  METHOD post_component_issues_bulk.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_issue_requests TYPE zcl_reservation_issue_service=>ty_issue_requests.

    LOOP AT it_requests INTO DATA(ls_issue_request).
      IF ls_issue_request-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      IF ls_issue_request-reservation_number IS INITIAL
          OR ls_issue_request-reservation_item IS INITIAL
          OR ls_issue_request-quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        production_order   = ls_issue_request-production_order
        reservation_number = ls_issue_request-reservation_number
        reservation_item   = ls_issue_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_components INTO DATA(ls_component)
        WITH KEY production_order   = ls_issue_request-production_order
                 reservation_number = ls_issue_request-reservation_number
                 reservation_item   = ls_issue_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_component-movement_type <> '261'
          OR ls_issue_request-quantity > ls_component-open_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_issue_request-reservation_number
        reservation_item   = ls_issue_request-reservation_item
        base_quantity      = ls_issue_request-quantity
        storage_location   = ls_issue_request-storage_location
        batch              = ls_issue_request-batch ) TO lt_issue_requests.
    ENDLOOP.

    rs_result = mo_issue_service->post_goods_issue(
      is_header   = is_header
      it_requests = lt_issue_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD preview_returnable_components.
    DATA lt_seen_keys TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    DATA lt_items TYPE zif_prod_comp_repo=>ty_reservation_items.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.

    IF it_component_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_component_keys INTO DATA(ls_component_key).
      IF ls_component_key-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      IF ls_component_key-reservation_number IS INITIAL
          OR ls_component_key-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        production_order   = ls_component_key-production_order
        reservation_number = ls_component_key-reservation_number
        reservation_item   = ls_component_key-reservation_item )
        INTO TABLE lt_seen_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_component_key-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_component_key-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.

    lt_items = mo_repository->get_components_bulk(
      it_production_orders = lt_production_orders ).
    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE lt_seen_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY production_order   = ls_item-production_order
                       reservation_number = ls_item-reservation_number
                       reservation_item   = ls_item-reservation_item.
      IF sy-subrc = 0.
        INSERT VALUE #(
          production_order   = ls_item-production_order
          reservation_number = ls_item-reservation_number
          reservation_item   = ls_item-reservation_item )
          INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_component_keys INTO ls_component_key.
      READ TABLE lt_items INTO ls_item
        WITH KEY production_order   = ls_component_key-production_order
                 reservation_number = ls_component_key-reservation_number
                 reservation_item   = ls_component_key-reservation_item.
      IF sy-subrc <> 0
          OR ls_item-is_deleted <> space
          OR ls_item-movement_type <> '261'
          OR ls_item-withdrawn_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(lv_open_quantity) =
        zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_item-required_quantity
          iv_withdrawn_quantity = ls_item-withdrawn_quantity ).

      APPEND VALUE #(
        production_order   = ls_item-production_order
        reservation_number = ls_item-reservation_number
        reservation_item   = ls_item-reservation_item
        material           = ls_item-material
        plant              = ls_item-plant
        storage_location   = ls_item-storage_location
        batch              = ls_item-batch
        movement_type      = ls_item-movement_type
        required_date      = ls_item-required_date
        required_quantity  = ls_item-required_quantity
        withdrawn_quantity = ls_item-withdrawn_quantity
        open_quantity      = lv_open_quantity
        unit               = ls_item-unit ) TO rt_components.
    ENDLOOP.
  ENDMETHOD.

  METHOD return_remaining_components.
    DATA lt_requests TYPE ty_bulk_return_requests.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_components) = preview_returnable_components(
      it_component_keys = it_component_keys ).
    LOOP AT lt_components INTO DATA(ls_component).
      APPEND VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number
        reservation_item   = ls_component-reservation_item
        quantity           = ls_component-withdrawn_quantity
        storage_location   = ls_component-storage_location
        batch              = ls_component-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = return_components_bulk(
      is_header   = is_header
      it_requests = lt_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_remaining_bulk.
    DATA lt_components TYPE ty_components.
    DATA lt_groups TYPE STANDARD TABLE OF ty_component_reservation_key
      WITH EMPTY KEY.
    DATA lt_seen_groups TYPE HASHED TABLE OF ty_component_reservation_key
      WITH UNIQUE KEY production_order reservation_number.
    DATA lt_reservation_orders TYPE HASHED TABLE OF
      ty_component_reservation_key WITH UNIQUE KEY reservation_number.
    DATA lt_requests TYPE ty_bulk_return_requests.
    DATA lt_group_requests TYPE ty_return_requests.
    FIELD-SYMBOLS <ls_result_item> TYPE ty_bulk_return_item.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR it_component_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    lt_components = preview_returnable_components(
      it_component_keys = it_component_keys ).
    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.

    LOOP AT lt_components INTO DATA(ls_component).
      READ TABLE lt_reservation_orders INTO DATA(ls_reservation_order)
        WITH TABLE KEY reservation_number =
                         ls_component-reservation_number.
      IF sy-subrc = 0.
        IF ls_reservation_order-production_order
            <> ls_component-production_order.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          production_order   = ls_component-production_order
          reservation_number = ls_component-reservation_number )
          INTO TABLE lt_reservation_orders.
      ENDIF.

      INSERT VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number )
        INTO TABLE lt_seen_groups.
      IF sy-subrc = 0.
        APPEND VALUE #(
          production_order   = ls_component-production_order
          reservation_number = ls_component-reservation_number )
          TO lt_groups.
      ENDIF.
      APPEND VALUE #(
        production_order   = ls_component-production_order
        reservation_number = ls_component-reservation_number
        reservation_item   = ls_component-reservation_item
        quantity           = ls_component-withdrawn_quantity
        storage_location   = ls_component-storage_location
        batch              = ls_component-batch ) TO lt_requests.
    ENDLOOP.

    LOOP AT lt_groups INTO DATA(ls_result_group).
      APPEND VALUE #(
        production_order   = ls_result_group-production_order
        reservation_number = ls_result_group-reservation_number )
        TO rs_result-items.
    ENDLOOP.

    LOOP AT rs_result-items ASSIGNING <ls_result_item>.
      <ls_result_item>-is_attempted = abap_true.
      CLEAR lt_group_requests.
      LOOP AT lt_requests INTO DATA(ls_request)
          WHERE production_order = <ls_result_item>-production_order
            AND reservation_number =
              <ls_result_item>-reservation_number.
        APPEND VALUE #(
          reservation_number = ls_request-reservation_number
          reservation_item   = ls_request-reservation_item
          quantity           = ls_request-quantity
          storage_location   = ls_request-storage_location
          batch              = ls_request-batch ) TO lt_group_requests.
      ENDLOOP.

      TRY.
          <ls_result_item>-movement_result = return_components(
            iv_production_order = <ls_result_item>-production_order
            is_header           = is_header
            it_requests         = lt_group_requests
            iv_test_run         = iv_test_run ).
        CATCH zcx_invalid_production_order.
          APPEND VALUE #(
            type    = 'E'
            message = 'Component return failed production order validation' )
            TO <ls_result_item>-movement_result-messages.
        CATCH zcx_invalid_goods_movement.
          APPEND VALUE #(
            type    = 'E'
            message = 'Component return failed goods movement validation' )
            TO <ls_result_item>-movement_result-messages.
      ENDTRY.

      <ls_result_item>-is_successful =
        <ls_result_item>-movement_result-is_successful.
      IF <ls_result_item>-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        IF iv_test_run = abap_false.
          <ls_result_item>-is_committed = abap_true.
        ENDIF.
        IF <ls_result_item>-is_committed = abap_true.
          rs_result-is_committed = abap_true.
        ENDIF.
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result_item>
          WHERE is_attempted = abap_false.
        <ls_result_item>-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD return_components.
    DATA lt_bulk_requests TYPE ty_bulk_return_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        production_order   = iv_production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_request-quantity
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_bulk_requests.
    ENDLOOP.

    rs_result = return_components_bulk(
      is_header   = is_header
      it_requests = lt_bulk_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_components_in_unit.
    DATA lt_bulk_requests TYPE ty_bulk_return_requests_in_unit.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        production_order   = iv_production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_request-quantity
        unit               = ls_request-unit
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_bulk_requests.
    ENDLOOP.

    rs_result = return_components_bulk_in_unit(
      is_header   = is_header
      it_requests = lt_bulk_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_components_bulk.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      INSERT ls_request-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_request-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.

    DATA(lt_components) = mo_repository->get_components_bulk(
      it_production_orders = lt_production_orders ).
    rs_result = post_component_returns_bulk(
      is_header     = is_header
      it_requests   = it_requests
      it_components = lt_components
      iv_test_run   = iv_test_run ).
  ENDMETHOD.

  METHOD return_components_bulk_in_unit.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen_orders TYPE HASHED TABLE OF resb-aufnr
      WITH UNIQUE KEY table_line.
    DATA lt_production_orders TYPE zif_prod_comp_repo=>ty_production_orders.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_request-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.

    DATA(lt_components) = mo_repository->get_components_bulk(
      it_production_orders = lt_production_orders ).
    DATA lt_seen TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_base_requests TYPE ty_bulk_return_requests.

    LOOP AT it_requests INTO ls_request.
      INSERT VALUE #(
        production_order   = ls_request-production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE lt_components INTO DATA(ls_component)
        WITH KEY production_order   = ls_request-production_order
                 reservation_number = ls_request-reservation_number
                 reservation_item   = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_component-is_deleted <> space
          OR ls_component-movement_type <> '261'
          OR ls_component-material IS INITIAL
          OR ls_component-unit IS INITIAL
          OR ls_component-withdrawn_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_component-material
        iv_quantity    = ls_request-quantity
        iv_source_unit = ls_request-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_component-unit
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        production_order   = ls_request-production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_conversion-base_quantity
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_base_requests.
    ENDLOOP.

    rs_result = post_component_returns_bulk(
      is_header     = is_header
      it_requests   = lt_base_requests
      it_components = lt_components
      iv_test_run   = iv_test_run ).
  ENDMETHOD.

  METHOD post_component_returns_bulk.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY production_order reservation_number reservation_item.
    DATA lt_return_requests TYPE zcl_reservation_issue_service=>ty_issue_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-production_order IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_production_order.
      ENDIF.
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        production_order   = ls_request-production_order
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_components INTO DATA(ls_component)
        WITH KEY production_order   = ls_request-production_order
                 reservation_number = ls_request-reservation_number
                 reservation_item   = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_component-is_deleted <> space
          OR ls_component-movement_type <> '261'
          OR ls_component-withdrawn_quantity <= 0
          OR ls_request-quantity > ls_component-withdrawn_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        base_quantity      = ls_request-quantity
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_return_requests.
    ENDLOOP.

    rs_result = mo_issue_service->post_goods_issue_reversal(
      is_header   = is_header
      it_requests = lt_return_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD cancel_component_issue.
    rs_result = mo_goods_movement_service->cancel(
      iv_material_document = iv_material_document
      iv_fiscal_year       = iv_fiscal_year
      iv_posting_date      = iv_posting_date
      it_item_numbers      = it_item_numbers ).
  ENDMETHOD.

  METHOD cancel_component_issues_bulk.
    rs_result = mo_goods_movement_service->cancel_material_documents_bulk(
      it_requests        = it_requests
      iv_atomic          = iv_atomic
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

ENDCLASS.
