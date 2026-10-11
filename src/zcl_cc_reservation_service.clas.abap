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
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
        storage_allocations       TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations         TYPE zcl_stock_service=>ty_batch_allocations,
        reservation_number        TYPE bapi2093_res_key-reserv_no,
        messages                  TYPE zif_cc_reservation_api=>ty_messages,
        is_successful             TYPE abap_bool,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_preview_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        cost_center        TYPE bapi2093_res_head-costcenter,
        requested_quantity TYPE mard-labst,
        unit               TYPE mara-meins,
      END OF ty_preview_demand.
    TYPES ty_preview_demands TYPE STANDARD TABLE OF ty_preview_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_demand_preview,
        request_id  TYPE c LENGTH 30,
        cost_center TYPE bapi2093_res_head-costcenter,
        allocation  TYPE zcl_stock_service=>ty_unit_allocation,
      END OF ty_demand_preview.
    TYPES ty_demand_previews TYPE STANDARD TABLE OF ty_demand_preview
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_preview_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        cost_center        TYPE bapi2093_res_head-costcenter,
        required_date      TYPE d,
        priority           TYPE i,
        requested_quantity TYPE mard-labst,
        unit               TYPE mara-meins,
      END OF ty_dated_preview_demand.
    TYPES ty_dated_preview_demands TYPE STANDARD TABLE OF
      ty_dated_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_dated_demand_preview,
        request_id                TYPE c LENGTH 30,
        cost_center               TYPE bapi2093_res_head-costcenter,
        allocation                TYPE zcl_stock_service=>ty_date_unit_allocation,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
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
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
      END OF ty_location_preview_demand.
    TYPES ty_location_preview_demands TYPE STANDARD TABLE OF
      ty_location_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_demand_preview,
        request_id          TYPE c LENGTH 30,
        cost_center         TYPE bapi2093_res_head-costcenter,
        allocation          TYPE zcl_stock_service=>ty_unit_allocation_summary,
        storage_allocations TYPE zcl_stock_service=>ty_unit_storage_splits,
      END OF ty_location_demand_preview.
    TYPES ty_location_demand_previews TYPE STANDARD TABLE OF
      ty_location_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        batch                       TYPE mchb-charg,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
      END OF ty_batch_preview_demand.
    TYPES ty_batch_preview_demands TYPE STANDARD TABLE OF
      ty_batch_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_batch_demand_preview,
        request_id        TYPE c LENGTH 30,
        cost_center       TYPE bapi2093_res_head-costcenter,
        selected_batch    TYPE mchb-charg,
        allocation        TYPE zcl_stock_service=>ty_unit_allocation_summary,
        batch_allocations TYPE zcl_stock_service=>ty_unit_batch_splits,
      END OF ty_batch_demand_preview.
    TYPES ty_batch_demand_previews TYPE STANDARD TABLE OF
      ty_batch_demand_preview WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_preview_demand,
        request_id                  TYPE c LENGTH 30,
        material                    TYPE mard-matnr,
        plant                       TYPE mard-werks,
        cost_center                 TYPE bapi2093_res_head-costcenter,
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
      END OF ty_fefo_preview_demand.
    TYPES ty_fefo_preview_demands TYPE STANDARD TABLE OF
      ty_fefo_preview_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_demand_preview,
        request_id              TYPE c LENGTH 30,
        cost_center             TYPE bapi2093_res_head-costcenter,
        as_of_date              TYPE d,
        minimum_shelf_life_days TYPE i,
        allocation              TYPE zcl_stock_service=>ty_unit_allocation_summary,
        batch_allocations       TYPE zcl_stock_service=>ty_unit_batch_splits,
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
        storage_location            TYPE mard-lgort,
        fallback_to_other_locations TYPE abap_bool,
        requested_quantity          TYPE mard-labst,
        unit                        TYPE mara-meins,
      END OF ty_atomic_reservation_demand.
    TYPES ty_atomic_reservation_demands TYPE STANDARD TABLE OF
      ty_atomic_reservation_demand WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_reservation_line,
        request_id                TYPE c LENGTH 30,
        allocation                TYPE zcl_stock_service=>ty_unit_allocation_summary,
        storage_allocations       TYPE zcl_stock_service=>ty_unit_storage_splits,
        batch_allocations         TYPE zcl_stock_service=>ty_unit_batch_splits,
        fefo_as_of_date           TYPE d,
        minimum_shelf_life_days   TYPE i,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
        reservation_result        TYPE zif_cc_reservation_api=>ty_result,
        is_committed              TYPE abap_bool,
      END OF ty_atomic_reservation_line.
    TYPES ty_atomic_reservation_lines TYPE STANDARD TABLE OF
      ty_atomic_reservation_line WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_reservation_result,
        items           TYPE ty_atomic_reservation_lines,
        messages        TYPE zif_cc_reservation_api=>ty_messages,
        is_successful   TYPE abap_bool,
        is_test_run     TYPE abap_bool,
        was_rolled_back TYPE abap_bool,
      END OF ty_atomic_reservation_result.

    METHODS constructor
      IMPORTING
        io_stock_repository          TYPE REF TO zif_stock_repository
        io_reservation_api           TYPE REF TO zif_cc_reservation_api OPTIONAL
        io_uom_repository            TYPE REF TO zif_material_uom_repository OPTIONAL
        io_material_availability_api TYPE REF TO
          zif_material_availability_api OPTIONAL.

    METHODS preview_cost_center_demands
      IMPORTING
        it_demands              TYPE ty_preview_demands
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)      TYPE ty_demand_previews
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
        iv_check_atp                   TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule              TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rt_previews)             TYPE ty_dated_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_locations
      IMPORTING
        it_demands                   TYPE ty_location_preview_demands
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)           TYPE ty_location_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_batches
      IMPORTING
        it_demands                   TYPE ty_batch_preview_demands
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)           TYPE ty_batch_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_cost_center_fefo
      IMPORTING
        it_demands                   TYPE ty_fefo_preview_demands
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        iv_as_of_date                TYPE d DEFAULT sy-datum
        iv_min_days                  TYPE i DEFAULT 0
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_previews)           TYPE ty_fefo_demand_previews
      RAISING
        zcx_invalid_stock_request.

    METHODS reserve_cost_centers_atomic
      IMPORTING
        it_demands                   TYPE ty_atomic_reservation_demands
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock      TYPE abap_bool DEFAULT abap_false
        iv_use_fefo_batches          TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date           TYPE d DEFAULT sy-datum
        iv_fefo_min_days             TYPE i DEFAULT 0
        iv_check_atp                 TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule            TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
        iv_require_atp_confirmation  TYPE abap_bool DEFAULT abap_false
        it_location_priority         TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
        it_allowed_storage_locations TYPE zcl_stock_service=>ty_storage_locations
          OPTIONAL
      RETURNING
        VALUE(rs_result)             TYPE ty_atomic_reservation_result
      RAISING
        zcx_invalid_stock_request.

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

    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_reservation_api TYPE REF TO zif_cc_reservation_api.
    DATA mo_uom_repository TYPE REF TO zif_material_uom_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.

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

  METHOD preview_cost_center_demands.
    DATA lt_request_ids TYPE HASHED TABLE OF ty_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_demands.
    DATA lt_allocations TYPE zcl_stock_service=>ty_unit_allocations.

    IF iv_protect_safety_stock <> abap_true
        AND iv_protect_safety_stock <> abap_false.
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
          OR ls_demand-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        plant              = ls_demand-plant
        requested_quantity = ls_demand-requested_quantity
        requested_unit     = ls_demand-unit )
        TO lt_unit_demands.
    ENDLOOP.

    lt_allocations = mo_stock_service->allocate_demands_in_units(
      it_demands              = lt_unit_demands
      iv_protect_safety_stock = iv_protect_safety_stock ).
    IF lines( lt_allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_allocations INTO DATA(ls_allocation) INDEX sy-tabix.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id  = ls_demand-request_id
        cost_center = ls_demand-cost_center
        allocation  = ls_allocation )
        TO rt_previews.
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
          OR ls_demand-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_demand INTO TABLE lt_unique_demands.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id         = ls_demand-request_id
        material           = ls_demand-material
        plant              = ls_demand-plant
        required_date      = ls_demand-required_date
        priority           = ls_demand-priority
        requested_quantity = ls_demand-requested_quantity
        requested_unit     = ls_demand-unit )
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
        iv_protect_safety_stock        = iv_protect_safety_stock ).
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
        iv_protect_safety_stock        = iv_protect_safety_stock ).
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
          allocation                = ls_atp_allocation-local_estimate
          cumulative_base_quantity  =
            ls_atp_allocation-cumulative_base_quantity
          confirmed_base_quantity   =
            ls_atp_allocation-confirmed_base_quantity
          unconfirmed_base_quantity =
            ls_atp_allocation-unconfirmed_base_quantity
          atp_result                = ls_atp_allocation-atp_result )
          TO rt_previews.
      ELSE.
        READ TABLE lt_allocations INTO DATA(ls_allocation) INDEX sy-tabix.
        IF sy-subrc <> 0
            OR ls_allocation-allocation-request_id <> ls_demand-request_id.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND VALUE #(
          request_id  = ls_demand-request_id
          cost_center = ls_demand-cost_center
          allocation  = ls_allocation )
          TO rt_previews.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_locations.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_location_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_location_demands.
    DATA ls_location_result TYPE zcl_stock_service=>ty_unit_location_result.

    IF iv_protect_safety_stock <> abap_true
        AND iv_protect_safety_stock <> abap_false.
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
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false ).
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
        requested_unit              = ls_demand-unit )
        TO lt_unit_demands.
    ENDLOOP.

    ls_location_result = mo_stock_service->allocate_by_location_in_units(
      it_demands                   = lt_unit_demands
      it_storage_location_priority = it_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_protect_safety_stock      = iv_protect_safety_stock ).
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
      <ls_preview>-allocation = ls_allocation.
      LOOP AT ls_location_result-storage_allocations
        INTO DATA(ls_storage_allocation).
        IF ls_storage_allocation-storage_allocation-request_id =
            ls_demand-request_id.
          APPEND ls_storage_allocation
            TO <ls_preview>-storage_allocations.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_batches.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_batch_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_batch_demands.
    DATA ls_batch_result TYPE zcl_stock_service=>ty_unit_batch_result.

    IF iv_protect_safety_stock <> abap_true
        AND iv_protect_safety_stock <> abap_false.
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
          OR ls_demand-batch IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false ).
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
        requested_unit              = ls_demand-unit )
        TO lt_unit_demands.
    ENDLOOP.

    ls_batch_result = mo_stock_service->allocate_by_batch_in_units(
      it_demands                   = lt_unit_demands
      it_storage_location_priority = it_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_protect_safety_stock      = iv_protect_safety_stock ).
    IF lines( ls_batch_result-allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_batch_result-allocations
        INTO DATA(ls_allocation) INDEX sy-tabix.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_previews ASSIGNING
        FIELD-SYMBOL(<ls_preview>).
      <ls_preview>-request_id = ls_demand-request_id.
      <ls_preview>-cost_center = ls_demand-cost_center.
      <ls_preview>-selected_batch = ls_demand-batch.
      <ls_preview>-allocation = ls_allocation.
      LOOP AT ls_batch_result-batch_allocations INTO DATA(ls_batch_allocation).
        IF ls_batch_allocation-batch_allocation-request_id =
            ls_demand-request_id.
          APPEND ls_batch_allocation TO <ls_preview>-batch_allocations.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cost_center_fefo.
    DATA lt_unique_demands TYPE HASHED TABLE OF ty_fefo_preview_demand
      WITH UNIQUE KEY request_id.
    DATA lt_unit_demands TYPE zcl_stock_service=>ty_unit_fefo_demands.
    DATA ls_fefo_result TYPE zcl_stock_service=>ty_unit_batch_result.

    IF iv_as_of_date IS INITIAL
        OR iv_min_days < 0
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false ).
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
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false ).
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
        requested_unit              = ls_demand-unit )
        TO lt_unit_demands.
    ENDLOOP.

    ls_fefo_result = mo_stock_service->allocate_by_expiry_in_units(
      it_demands                   = lt_unit_demands
      it_storage_location_priority = it_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      iv_as_of_date                = iv_as_of_date
      iv_min_days                  = iv_min_days
      iv_protect_safety_stock      = iv_protect_safety_stock ).
    IF lines( ls_fefo_result-allocations ) <> lines( it_demands ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE ls_fefo_result-allocations
        INTO DATA(ls_allocation) INDEX sy-tabix.
      IF sy-subrc <> 0
          OR ls_allocation-allocation-request_id <> ls_demand-request_id.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND INITIAL LINE TO rt_previews ASSIGNING
        FIELD-SYMBOL(<ls_preview>).
      <ls_preview>-request_id = ls_demand-request_id.
      <ls_preview>-cost_center = ls_demand-cost_center.
      <ls_preview>-as_of_date = iv_as_of_date.
      <ls_preview>-minimum_shelf_life_days = iv_min_days.
      <ls_preview>-allocation = ls_allocation.
      LOOP AT ls_fefo_result-batch_allocations
        INTO DATA(ls_batch_allocation).
        IF ls_batch_allocation-batch_allocation-request_id =
            ls_demand-request_id.
          APPEND ls_batch_allocation TO <ls_preview>-batch_allocations.
        ENDIF.
      ENDLOOP.
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
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_atomic_atp_day.
    TYPES ty_atomic_atp_days TYPE STANDARD TABLE OF ty_atomic_atp_day
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_atomic_request,
        request_id TYPE c LENGTH 30,
        request    TYPE zif_cc_reservation_api=>ty_request,
      END OF ty_prepared_atomic_request.
    TYPES ty_prepared_atomic_requests TYPE STANDARD TABLE OF
      ty_prepared_atomic_request WITH EMPTY KEY.
    DATA lt_unique_demands TYPE HASHED TABLE OF
      ty_atomic_reservation_demand WITH UNIQUE KEY request_id.
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
        OR ( iv_use_fefo_batches <> abap_true
          AND iv_use_fefo_batches <> abap_false )
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

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-plant IS INITIAL
          OR ls_demand-cost_center IS INITIAL
          OR ls_demand-required_date IS INITIAL
          OR ls_demand-requested_quantity <= 0
          OR ls_demand-unit IS INITIAL
          OR ( ls_demand-fallback_to_other_locations <> abap_true
            AND ls_demand-fallback_to_other_locations <> abap_false )
          OR ( ls_demand-fallback_to_other_locations = abap_true
            AND ls_demand-storage_location IS INITIAL ).
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
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        unit                        = ls_demand-unit )
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
        unit                        = ls_demand-unit )
        TO lt_batch_demands.
      APPEND VALUE #(
        request_id                  = ls_demand-request_id
        material                    = ls_demand-material
        plant                       = ls_demand-plant
        cost_center                 = ls_demand-cost_center
        storage_location            = ls_demand-storage_location
        fallback_to_other_locations =
          ls_demand-fallback_to_other_locations
        requested_quantity          = ls_demand-requested_quantity
        unit                        = ls_demand-unit )
        TO lt_fefo_demands.
    ENDLOOP.

    IF lv_batch_mode = abap_true
        AND lv_unbatched_mode = abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_use_fefo_batches = abap_true
        AND lv_batch_mode = abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_use_fefo_batches = abap_true.
      lt_fefo_previews = preview_cost_center_fefo(
        it_demands                   = lt_fefo_demands
        it_location_priority         = it_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_as_of_date                = iv_fefo_as_of_date
        iv_min_days                  = iv_fefo_min_days
        iv_protect_safety_stock      = iv_protect_safety_stock ).
      IF lines( lt_fefo_previews ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ELSEIF lv_batch_mode = abap_true.
      lt_batch_previews = preview_cost_center_batches(
        it_demands                   = lt_batch_demands
        it_location_priority         = it_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_protect_safety_stock      = iv_protect_safety_stock ).
      IF lines( lt_batch_previews ) <> lines( it_demands ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ELSE.
      lt_location_previews = preview_cost_center_locations(
        it_demands                   = lt_location_demands
        it_location_priority         = it_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
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
        <ls_new_line>-fefo_as_of_date = iv_fefo_as_of_date.
        <ls_new_line>-minimum_shelf_life_days = iv_fefo_min_days.
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
        IF iv_require_atp_confirmation = abap_true
            AND <ls_atp_day>-confirmed_base_quantity <
              <ls_atp_day>-cumulative_base_quantity.
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
        request    = ls_api_request )
        TO lt_api_requests.
    ENDLOOP.

    CLEAR lv_request_index.
    LOOP AT lt_api_requests INTO DATA(ls_prepared_request).
      ADD 1 TO lv_request_index.
      READ TABLE rs_result-items ASSIGNING FIELD-SYMBOL(<ls_line>)
        INDEX lv_request_index.
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
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation API returned no reservation number' )
          TO <ls_line>-reservation_result-messages.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation API returned no reservation number' )
          TO rs_result-messages.
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

  METHOD reserve_for_cost_center.
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
    ENDIF.

    IF iv_require_atp_confirmation = abap_true
        AND rs_result-confirmed_base_quantity <
          rs_result-base_requested_quantity.
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

  METHOD preview_for_cost_center.
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
    ENDIF.
  ENDMETHOD.

  METHOD prepare_reservation.
    DATA lt_allowed_locations TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.

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
        OR ( iv_batch_supplied = abap_true AND iv_batch IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    IF iv_use_fefo_batches = abap_true
        AND iv_batch_supplied = abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    IF iv_fefo_min_days < 0
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true )
        OR ( iv_use_fefo_batches = abap_true
          AND iv_fefo_as_of_date IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
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
            storage_location            = iv_storage_location
            fallback_to_other_locations = iv_allow_fallback
            requested_quantity          = ls_conversion-base_quantity ) )
        iv_as_of_date                = iv_fefo_as_of_date
        iv_min_days                  = iv_fefo_min_days
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
            requested_quantity          = ls_conversion-base_quantity ) )
        it_storage_location_priority = it_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        iv_protect_safety_stock      = iv_protect_safety_stock ).
      READ TABLE ls_batch_result-allocations INDEX 1 INTO ls_allocation.
    ELSE.
      ls_location_result = mo_stock_service->allocate_by_storage_location(
          it_demands                   = VALUE #(
            ( material                    = iv_material
              plant                       = iv_plant
              storage_location            = iv_storage_location
              fallback_to_other_locations = iv_allow_fallback
              requested_quantity          = ls_conversion-base_quantity ) )
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
