CLASS zcl_sales_order_alloc_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_batch_selection,
        item_number      TYPE c LENGTH 6,
        schedule_line    TYPE c LENGTH 4,
        batch            TYPE mchb-charg,
        storage_location TYPE mard-lgort,
        allow_fallback   TYPE abap_bool,
      END OF ty_batch_selection.
    TYPES ty_batch_selections TYPE STANDARD TABLE OF ty_batch_selection
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_selection,
        item_number      TYPE c LENGTH 6,
        schedule_line    TYPE c LENGTH 4,
        storage_location TYPE mard-lgort,
        allow_fallback   TYPE abap_bool,
      END OF ty_location_selection.
    TYPES ty_location_selections TYPE STANDARD TABLE OF ty_location_selection
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sales_unit_allocation,
        request_id              TYPE c LENGTH 30,
        sales_document          TYPE zif_sales_order_api=>ty_sales_document,
        item_number             TYPE c LENGTH 6,
        schedule_line           TYPE c LENGTH 4,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        required_date           TYPE d,
        sales_unit              TYPE c LENGTH 3,
        base_unit               TYPE mara-meins,
        requested_quantity      TYPE mard-labst,
        requested_base_quantity TYPE mard-labst,
        available_quantity      TYPE mard-labst,
        available_base_quantity TYPE mard-labst,
        allocated_quantity      TYPE mard-labst,
        allocated_base_quantity TYPE mard-labst,
        shortfall_quantity      TYPE mard-labst,
        shortfall_base_quantity TYPE mard-labst,
      END OF ty_sales_unit_allocation.
    TYPES ty_sales_unit_allocations TYPE STANDARD TABLE OF
      ty_sales_unit_allocation WITH EMPTY KEY.
    TYPES ty_sales_documents TYPE STANDARD TABLE OF
      zif_sales_order_api=>ty_sales_document WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atp_check,
        request_id                    TYPE c LENGTH 30,
        item_number                   TYPE c LENGTH 6,
        schedule_line                 TYPE c LENGTH 4,
        line_requested_quantity       TYPE mard-labst,
        cumulative_requested_quantity TYPE mard-labst,
        confirmed_base_quantity       TYPE mard-labst,
        unconfirmed_base_quantity     TYPE mard-labst,
        result                        TYPE zif_material_availability_api=>ty_result,
      END OF ty_atp_check.
    TYPES ty_atp_checks TYPE STANDARD TABLE OF ty_atp_check
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result,
        sales_document         TYPE zif_sales_order_api=>ty_sales_document,
        allocations            TYPE zcl_stock_service=>ty_allocations,
        storage_allocations    TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations      TYPE zcl_stock_service=>ty_batch_allocations,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        atp_checks             TYPE ty_atp_checks,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_reserve_result,
        sales_document         TYPE zif_sales_order_api=>ty_sales_document,
        allocations            TYPE zcl_stock_service=>ty_allocations,
        storage_allocations    TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations      TYPE zcl_stock_service=>ty_batch_allocations,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        reservations           TYPE zif_so_reservation_api=>ty_reservations,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_reserve_result.
    TYPES:
      BEGIN OF ty_multi_order_preview_result,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        atp_checks             TYPE ty_atp_checks,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_multi_order_preview_result.
    TYPES:
      BEGIN OF ty_multi_order_reserve_result,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        atp_checks             TYPE ty_atp_checks,
        reservations           TYPE zif_so_reservation_api=>ty_reservations,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_multi_order_reserve_result.

    METHODS constructor
      IMPORTING
        io_sales_order_api           TYPE REF TO zif_sales_order_api
        io_stock_repository          TYPE REF TO zif_stock_repository
        io_reservation_api           TYPE REF TO zif_so_reservation_api
          OPTIONAL
        io_material_availability_api TYPE REF TO
          zif_material_availability_api OPTIONAL.

    METHODS preview_order
      IMPORTING
        iv_sales_document       TYPE zif_sales_order_api=>ty_sales_document
        it_batch_selections     TYPE ty_batch_selections OPTIONAL
        it_location_selections  TYPE ty_location_selections OPTIONAL
        iv_use_fefo_batches     TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date      TYPE d DEFAULT sy-datum
        iv_fefo_min_days        TYPE i DEFAULT 0
        iv_prioritize_by_date   TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
        iv_check_atp            TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule       TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rs_result)        TYPE ty_result
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

    METHODS reserve_order
      IMPORTING
        iv_sales_document          TYPE zif_sales_order_api=>ty_sales_document
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        it_batch_selections        TYPE ty_batch_selections OPTIONAL
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_false
        it_location_selections     TYPE ty_location_selections OPTIONAL
        iv_use_fefo_batches        TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date         TYPE d DEFAULT sy-datum
        iv_fefo_min_days           TYPE i DEFAULT 0
        iv_prioritize_by_date      TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty       TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)           TYPE ty_reserve_result
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

    METHODS preview_orders_by_date
      IMPORTING
        it_sales_documents        TYPE ty_sales_documents
        iv_include_po_receipts    TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto   TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto  TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts  TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty      TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock   TYPE abap_bool DEFAULT abap_false
        iv_check_atp              TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule         TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rs_result)          TYPE ty_multi_order_preview_result
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

    METHODS reserve_orders_by_date
      IMPORTING
        it_sales_documents         TYPE ty_sales_documents
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_false
        iv_include_po_receipts     TYPE abap_bool DEFAULT abap_false
        iv_include_sto_in_transit  TYPE abap_bool DEFAULT abap_false
        iv_include_unissued_sto    TYPE abap_bool DEFAULT abap_false
        iv_subtract_unissued_sto   TYPE abap_bool DEFAULT abap_false
        iv_include_prod_receipts   TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty       TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock    TYPE abap_bool DEFAULT abap_false
        iv_check_atp               TYPE abap_bool DEFAULT abap_false
        iv_atp_check_rule          TYPE zif_material_availability_api=>ty_check_rule
          OPTIONAL
      RETURNING
        VALUE(rs_result)           TYPE ty_multi_order_reserve_result
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_prepared,
        order_items            TYPE zif_sales_order_api=>ty_items,
        allocations            TYPE zcl_stock_service=>ty_allocations,
        storage_allocations    TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations      TYPE zcl_stock_service=>ty_batch_allocations,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_prepared.
    TYPES:
      BEGIN OF ty_atp_demand,
        source_index       TYPE i,
        request_id         TYPE c LENGTH 30,
        item_number        TYPE c LENGTH 6,
        schedule_line      TYPE c LENGTH 4,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        unit               TYPE mara-meins,
        required_date      TYPE d,
        requested_quantity TYPE mard-labst,
      END OF ty_atp_demand.
    TYPES ty_atp_demands TYPE STANDARD TABLE OF ty_atp_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atp_day_total,
        material            TYPE mard-matnr,
        plant               TYPE mard-werks,
        unit                TYPE mara-meins,
        required_date       TYPE d,
        date_quantity       TYPE mard-labst,
        cumulative_quantity TYPE mard-labst,
        result              TYPE zif_material_availability_api=>ty_result,
      END OF ty_atp_day_total.
    TYPES ty_atp_day_totals TYPE STANDARD TABLE OF ty_atp_day_total
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_indexed_atp_check,
        source_index TYPE i,
        atp_check    TYPE ty_atp_check,
      END OF ty_indexed_atp_check.
    TYPES ty_indexed_atp_checks TYPE STANDARD TABLE OF
      ty_indexed_atp_check WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_selection_key,
        item_number   TYPE c LENGTH 6,
        schedule_line TYPE c LENGTH 4,
      END OF ty_selection_key.
    TYPES ty_selection_keys TYPE HASHED TABLE OF ty_selection_key
      WITH UNIQUE KEY item_number schedule_line.
    TYPES:
      BEGIN OF ty_selection_item,
        item_number TYPE c LENGTH 6,
      END OF ty_selection_item.
    TYPES ty_selection_items TYPE HASHED TABLE OF ty_selection_item
      WITH UNIQUE KEY item_number.
    TYPES:
      BEGIN OF ty_selection_mode,
        item_number TYPE c LENGTH 6,
        mode        TYPE c LENGTH 1,
      END OF ty_selection_mode.
    TYPES ty_selection_modes TYPE HASHED TABLE OF ty_selection_mode
      WITH UNIQUE KEY item_number.
    TYPES:
      BEGIN OF ty_date_priority,
        missing_date   TYPE abap_bool,
        requested_date TYPE d,
        source_index   TYPE i,
      END OF ty_date_priority.
    TYPES ty_date_priorities TYPE STANDARD TABLE OF ty_date_priority
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_reservation_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        item_number        TYPE c LENGTH 6,
        schedule_line      TYPE c LENGTH 4,
        requirement_date   TYPE d,
        remaining_quantity TYPE mard-labst,
      END OF ty_order_reservation_balance.
    TYPES ty_order_reservation_balances TYPE STANDARD TABLE OF
      ty_order_reservation_balance WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_multi_order_demand_context,
        request_id     TYPE c LENGTH 30,
        sales_document TYPE zif_sales_order_api=>ty_sales_document,
        order_item     TYPE zif_sales_order_api=>ty_item,
      END OF ty_multi_order_demand_context.
    TYPES ty_multi_order_demand_contexts TYPE HASHED TABLE OF
      ty_multi_order_demand_context WITH UNIQUE KEY request_id.
    TYPES ty_seen_sales_documents TYPE HASHED TABLE OF
      zif_sales_order_api=>ty_sales_document WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_multi_order_request_id,
        request_id TYPE c LENGTH 30,
      END OF ty_multi_order_request_id.
    TYPES ty_seen_multi_order_requests TYPE HASHED TABLE OF
      ty_multi_order_request_id WITH UNIQUE KEY request_id.

    DATA mo_sales_order_service TYPE REF TO zcl_sales_order_service.
    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_reservation_api TYPE REF TO zif_so_reservation_api.

    METHODS prepare_order_allocations
      IMPORTING
        iv_sales_document       TYPE zif_sales_order_api=>ty_sales_document
        it_batch_selections     TYPE ty_batch_selections OPTIONAL
        it_location_selections  TYPE ty_location_selections OPTIONAL
        iv_use_fefo_batches     TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date      TYPE d DEFAULT sy-datum
        iv_fefo_min_days        TYPE i DEFAULT 0
        iv_prioritize_by_date   TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
        iv_check_atp            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_prepared)      TYPE ty_prepared
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

    METHODS subtract_order_reservations
      IMPORTING
        it_reservations TYPE zif_stock_repository=>ty_sales_order_reservations
      CHANGING
        ct_order_items  TYPE zif_sales_order_api=>ty_items.

    METHODS reservation_results_match
      IMPORTING
        it_requests        TYPE zif_so_reservation_api=>ty_requests
        it_reservations    TYPE zif_so_reservation_api=>ty_reservations
        iv_test_run        TYPE abap_bool
      RETURNING
        VALUE(rv_is_valid) TYPE abap_bool.

    METHODS build_sales_unit_allocations
      IMPORTING
        iv_sales_document     TYPE zif_sales_order_api=>ty_sales_document
        it_order_items        TYPE zif_sales_order_api=>ty_items
        it_allocations        TYPE zcl_stock_service=>ty_allocations
      RETURNING
        VALUE(rt_allocations) TYPE ty_sales_unit_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_base_to_sales_unit
      IMPORTING
        iv_base_quantity   TYPE mard-labst
        iv_numerator       TYPE bapisdit-sales_qty1
        iv_denominator     TYPE bapisdit-sales_qty2
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst.
ENDCLASS.

CLASS zcl_sales_order_alloc_service IMPLEMENTATION.

  METHOD constructor.
    mo_sales_order_service = NEW zcl_sales_order_service(
      io_api = io_sales_order_api ).
    mo_stock_service = NEW zcl_stock_service(
      io_stock_repository          = io_stock_repository
      io_material_availability_api = io_material_availability_api ).
    IF io_reservation_api IS BOUND.
      mo_reservation_api = io_reservation_api.
    ELSE.
      mo_reservation_api = NEW zcl_bapi_so_reservation_api( ).
    ENDIF.
  ENDMETHOD.

  METHOD preview_order.
    DATA ls_prepared TYPE ty_prepared.
    DATA lt_atp_demands TYPE ty_atp_demands.
    DATA lt_atp_day_totals TYPE ty_atp_day_totals.
    DATA lt_indexed_atp_checks TYPE ty_indexed_atp_checks.
    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_batch_selections IS SUPPLIED
        AND it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock
        iv_check_atp            = iv_check_atp ).
    ELSEIF it_batch_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock
        iv_check_atp            = iv_check_atp ).
    ELSEIF it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock
        iv_check_atp            = iv_check_atp ).
    ELSE.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock
        iv_check_atp            = iv_check_atp ).
    ENDIF.
    rs_result-sales_document = iv_sales_document.
    rs_result-allocations = ls_prepared-allocations.
    rs_result-storage_allocations = ls_prepared-storage_allocations.
    rs_result-batch_allocations = ls_prepared-batch_allocations.
    rs_result-sales_unit_allocations =
      ls_prepared-sales_unit_allocations.
    rs_result-messages = ls_prepared-messages.
    rs_result-is_successful = ls_prepared-is_successful.

    IF iv_check_atp = abap_true
        AND ls_prepared-is_successful = abap_true.
      LOOP AT ls_prepared-order_items INTO DATA(ls_atp_item)
        WHERE open_base_quantity > 0.
        DATA lv_request_id TYPE c LENGTH 30.
        IF ls_atp_item-schedule_line IS INITIAL.
          CONCATENATE iv_sales_document ls_atp_item-item_number
            INTO lv_request_id SEPARATED BY '/'.
        ELSE.
          CONCATENATE iv_sales_document ls_atp_item-item_number
            ls_atp_item-schedule_line
            INTO lv_request_id SEPARATED BY '/'.
        ENDIF.
        APPEND VALUE #(
          source_index       = sy-tabix
          request_id         = lv_request_id
          item_number        = ls_atp_item-item_number
          schedule_line      = ls_atp_item-schedule_line
          material           = ls_atp_item-material
          plant              = ls_atp_item-plant
          unit               = ls_atp_item-base_unit
          required_date      = ls_atp_item-requested_date
          requested_quantity = ls_atp_item-open_base_quantity )
          TO lt_atp_demands.
      ENDLOOP.

      SORT lt_atp_demands BY material plant unit required_date
        source_index.
      FIELD-SYMBOLS <ls_atp_day_total> TYPE ty_atp_day_total.
      LOOP AT lt_atp_demands INTO DATA(ls_atp_day_demand).
        READ TABLE lt_atp_day_totals ASSIGNING <ls_atp_day_total>
          WITH KEY material = ls_atp_day_demand-material
                   plant = ls_atp_day_demand-plant
                   unit = ls_atp_day_demand-unit
                   required_date = ls_atp_day_demand-required_date.
        IF sy-subrc = 0.
          <ls_atp_day_total>-date_quantity =
            <ls_atp_day_total>-date_quantity
            + ls_atp_day_demand-requested_quantity.
        ELSE.
          APPEND VALUE #(
            material      = ls_atp_day_demand-material
            plant         = ls_atp_day_demand-plant
            unit          = ls_atp_day_demand-unit
            required_date = ls_atp_day_demand-required_date
            date_quantity = ls_atp_day_demand-requested_quantity )
            TO lt_atp_day_totals.
        ENDIF.
      ENDLOOP.

      SORT lt_atp_day_totals BY material plant unit required_date.
      DATA lv_previous_material TYPE mard-matnr.
      DATA lv_previous_plant TYPE mard-werks.
      DATA lv_previous_unit TYPE mara-meins.
      DATA lv_cumulative_quantity TYPE mard-labst.
      DATA lv_first_demand TYPE abap_bool VALUE abap_true.

      LOOP AT lt_atp_day_totals ASSIGNING <ls_atp_day_total>.
        IF lv_first_demand = abap_true
            OR lv_previous_material <> <ls_atp_day_total>-material
            OR lv_previous_plant <> <ls_atp_day_total>-plant
            OR lv_previous_unit <> <ls_atp_day_total>-unit.
          CLEAR lv_cumulative_quantity.
          lv_previous_material = <ls_atp_day_total>-material.
          lv_previous_plant = <ls_atp_day_total>-plant.
          lv_previous_unit = <ls_atp_day_total>-unit.
          lv_first_demand = abap_false.
        ENDIF.
        lv_cumulative_quantity = lv_cumulative_quantity
          + <ls_atp_day_total>-date_quantity.
        <ls_atp_day_total>-cumulative_quantity = lv_cumulative_quantity.
        <ls_atp_day_total>-result = mo_stock_service->check_atp_request(
          is_request = VALUE #(
            material           = <ls_atp_day_total>-material
            plant              = <ls_atp_day_total>-plant
            unit               = <ls_atp_day_total>-unit
            check_rule         = iv_atp_check_rule
            required_date      = <ls_atp_day_total>-required_date
            requested_quantity = lv_cumulative_quantity ) ).
      ENDLOOP.

      LOOP AT lt_atp_demands INTO DATA(ls_atp_demand).
        READ TABLE lt_atp_day_totals INTO DATA(ls_atp_day_total)
          WITH KEY material = ls_atp_demand-material
                   plant = ls_atp_demand-plant
                   unit = ls_atp_demand-unit
                   required_date = ls_atp_demand-required_date.
        DATA(ls_confirmation_split) =
          mo_stock_service->get_atp_confirmation_split(
            iv_requested_base_quantity =
              ls_atp_day_total-cumulative_quantity
            is_atp_result              = ls_atp_day_total-result ).
        APPEND VALUE #(
          source_index = ls_atp_demand-source_index
          atp_check    = VALUE #(
            request_id                    = ls_atp_demand-request_id
            item_number                   = ls_atp_demand-item_number
            schedule_line                 = ls_atp_demand-schedule_line
            line_requested_quantity       =
              ls_atp_demand-requested_quantity
            cumulative_requested_quantity =
              ls_atp_day_total-cumulative_quantity
            confirmed_base_quantity       =
              ls_confirmation_split-confirmed_base_quantity
            unconfirmed_base_quantity     =
              ls_confirmation_split-unconfirmed_base_quantity
            result                        = ls_atp_day_total-result ) )
          TO lt_indexed_atp_checks.
      ENDLOOP.

      SORT lt_indexed_atp_checks BY source_index.
      LOOP AT lt_indexed_atp_checks INTO DATA(ls_indexed_atp_check).
        APPEND ls_indexed_atp_check-atp_check TO rs_result-atp_checks.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD reserve_order.
    DATA ls_prepared TYPE ty_prepared.
    IF it_batch_selections IS SUPPLIED
        AND it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSEIF it_batch_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSEIF it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSE.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ENDIF.
    rs_result-sales_document = iv_sales_document.
    rs_result-allocations = ls_prepared-allocations.
    rs_result-storage_allocations = ls_prepared-storage_allocations.
    rs_result-batch_allocations = ls_prepared-batch_allocations.
    rs_result-sales_unit_allocations =
      ls_prepared-sales_unit_allocations.
    rs_result-messages = ls_prepared-messages.

    IF ls_prepared-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF iv_require_full_allocation = abap_true.
      LOOP AT ls_prepared-allocations INTO DATA(ls_checked_allocation)
        WHERE shortfall_quantity > 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Full allocation required; no reservations were created' )
          TO rs_result-messages.
        RETURN.
      ENDLOOP.
    ENDIF.

    DATA lt_requests TYPE zif_so_reservation_api=>ty_requests.
    LOOP AT ls_prepared-order_items INTO DATA(ls_order_item).
      IF ls_order_item-open_base_quantity <= 0.
        CONTINUE.
      ENDIF.

      DATA lv_request_id TYPE c LENGTH 30.
      CLEAR lv_request_id.
      IF ls_order_item-schedule_line IS INITIAL.
        CONCATENATE iv_sales_document ls_order_item-item_number
          INTO lv_request_id SEPARATED BY '/'.
      ELSE.
        CONCATENATE iv_sales_document ls_order_item-item_number
          ls_order_item-schedule_line
          INTO lv_request_id SEPARATED BY '/'.
      ENDIF.
      IF it_batch_selections IS SUPPLIED
          OR iv_use_fefo_batches = abap_true.
        LOOP AT ls_prepared-batch_allocations INTO DATA(ls_batch_allocation)
          WHERE request_id = lv_request_id.
          APPEND VALUE #(
            request_id       = lv_request_id
            sales_document   = iv_sales_document
            item_number      = ls_order_item-item_number
            material         = ls_order_item-material
            plant            = ls_order_item-plant
            storage_location = ls_batch_allocation-storage_location
            batch            = ls_batch_allocation-batch
            required_date    = ls_order_item-requested_date
            quantity         = ls_batch_allocation-allocated_quantity
            unit             = ls_order_item-base_unit ) TO lt_requests.
        ENDLOOP.
      ELSE.
        LOOP AT ls_prepared-storage_allocations INTO DATA(ls_storage_allocation)
          WHERE request_id = lv_request_id.
          APPEND VALUE #(
            request_id       = lv_request_id
            sales_document   = iv_sales_document
            item_number      = ls_order_item-item_number
            material         = ls_order_item-material
            plant            = ls_order_item-plant
            storage_location = ls_storage_allocation-storage_location
            required_date    = ls_order_item-requested_date
            quantity         = ls_storage_allocation-allocated_quantity
            unit             = ls_order_item-base_unit ) TO lt_requests.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_create_result) = mo_reservation_api->create_reservations(
      it_requests = lt_requests
      iv_test_run = iv_test_run ).
    APPEND LINES OF ls_create_result-messages TO rs_result-messages.
    rs_result-reservations = ls_create_result-reservations.

    IF ls_create_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      RETURN.
    ENDIF.

    DATA(lv_responses_match) = reservation_results_match(
      it_requests     = lt_requests
      it_reservations = rs_result-reservations
      iv_test_run     = iv_test_run ).
    IF lv_responses_match <> abap_true.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API results do not match the requests' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD preview_orders_by_date.
    DATA lt_seen_sales_documents TYPE ty_seen_sales_documents.
    DATA lt_seen_requests TYPE ty_seen_multi_order_requests.
    DATA lt_demands TYPE zcl_stock_service=>ty_dated_demands.
    DATA lt_contexts TYPE ty_multi_order_demand_contexts.
    DATA lt_all_reservations TYPE SORTED TABLE OF
      zif_stock_repository=>ty_sales_order_reservation
      WITH NON-UNIQUE KEY sales_document.
    DATA lt_document_reservations TYPE
      zif_stock_repository=>ty_sales_order_reservations.
    DATA lt_atp_demands TYPE ty_atp_demands.
    DATA lt_atp_day_totals TYPE ty_atp_day_totals.
    DATA lt_indexed_atp_checks TYPE ty_indexed_atp_checks.
    DATA lv_request_id TYPE c LENGTH 30.
    DATA lv_numerator TYPE bapisdit-sales_qty1.
    DATA lv_denominator TYPE bapisdit-sales_qty2.

    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_sales_documents IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    LOOP AT it_sales_documents INTO DATA(lv_document_to_check).
      IF lv_document_to_check IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
      INSERT lv_document_to_check INTO TABLE lt_seen_sales_documents.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.
    ENDLOOP.

    lt_all_reservations = mo_stock_service->get_order_reservations_bulk(
      it_sales_documents = it_sales_documents ).

    LOOP AT it_sales_documents INTO DATA(lv_sales_document).
      DATA(ls_read_result) = mo_sales_order_service->read_order(
        iv_sales_document = lv_sales_document ).
      APPEND LINES OF ls_read_result-messages TO rs_result-messages.
      IF ls_read_result-is_successful <> abap_true.
        IF ls_read_result-messages IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Unable to read a sales order in the date preview' )
            TO rs_result-messages.
        ENDIF.
        RETURN.
      ENDIF.

      DATA(lt_order_items) = ls_read_result-order-items.
      IF iv_use_confirmed_qty = abap_true.
        LOOP AT lt_order_items ASSIGNING FIELD-SYMBOL(<ls_order_item>).
          IF <ls_order_item>-open_base_quantity > 0
              AND ( <ls_order_item>-schedule_line IS INITIAL
                OR <ls_order_item>-has_confirmed_quantity <> abap_true ).
            APPEND VALUE #(
              type    = 'E'
              message = 'Confirmed-quantity mode requires schedule-line confirmation data' )
              TO rs_result-messages.
            RETURN.
          ENDIF.

          IF <ls_order_item>-has_confirmed_quantity = abap_true.
            IF <ls_order_item>-confirmed_quantity < 0
                OR <ls_order_item>-open_confirmed_quantity < 0
                OR <ls_order_item>-confirmed_base_quantity < 0
                OR <ls_order_item>-open_confirmed_base_quantity < 0.
              APPEND VALUE #(
                type    = 'E'
                message = 'Schedule line contains a negative confirmed quantity' )
                TO rs_result-messages.
              RETURN.
            ENDIF.

            IF <ls_order_item>-open_confirmed_quantity >
                <ls_order_item>-open_quantity.
              <ls_order_item>-open_confirmed_quantity =
                <ls_order_item>-open_quantity.
            ENDIF.
            IF <ls_order_item>-open_confirmed_base_quantity >
                <ls_order_item>-open_base_quantity.
              <ls_order_item>-open_confirmed_base_quantity =
                <ls_order_item>-open_base_quantity.
            ENDIF.

            <ls_order_item>-open_quantity =
              <ls_order_item>-open_confirmed_quantity.
            <ls_order_item>-open_base_quantity =
              <ls_order_item>-open_confirmed_base_quantity.
          ENDIF.
        ENDLOOP.
      ENDIF.
      CLEAR lt_document_reservations.
      LOOP AT lt_all_reservations INTO DATA(ls_order_reservation)
        WHERE sales_document = lv_sales_document.
        APPEND ls_order_reservation TO lt_document_reservations.
      ENDLOOP.
      subtract_order_reservations(
        EXPORTING
          it_reservations = lt_document_reservations
        CHANGING
          ct_order_items  = lt_order_items ).

      LOOP AT lt_order_items INTO DATA(ls_order_item)
        WHERE open_base_quantity > 0.
        IF ls_order_item-item_number IS INITIAL
            OR ls_order_item-material IS INITIAL
            OR ls_order_item-plant IS INITIAL
            OR ls_order_item-base_unit IS INITIAL
            OR ls_order_item-entry_unit IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Open sales-order item lacks its number, material, plant, or unit' )
            TO rs_result-messages.
          RETURN.
        ENDIF.
        IF ls_order_item-requested_date IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Date preview requires a requested date for every open item' )
            TO rs_result-messages.
          RETURN.
        ENDIF.
        IF ls_order_item-entry_unit <> ls_order_item-base_unit
            AND ( ls_order_item-sales_unit_numerator <= 0
              OR ls_order_item-sales_unit_denominator <= 0 ).
          APPEND VALUE #(
            type    = 'E'
            message = 'Open sales-order item lacks a valid sales unit conversion ratio' )
            TO rs_result-messages.
          RETURN.
        ENDIF.

        CLEAR lv_request_id.
        IF ls_order_item-schedule_line IS INITIAL.
          CONCATENATE lv_sales_document ls_order_item-item_number
            INTO lv_request_id SEPARATED BY '/'.
        ELSE.
          CONCATENATE lv_sales_document ls_order_item-item_number
            ls_order_item-schedule_line
            INTO lv_request_id SEPARATED BY '/'.
        ENDIF.
        INSERT VALUE #( request_id = lv_request_id )
          INTO TABLE lt_seen_requests.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Sales-order item and schedule keys are not unique' )
            TO rs_result-messages.
          RETURN.
        ENDIF.

        APPEND VALUE #(
          request_id         = lv_request_id
          material           = ls_order_item-material
          plant              = ls_order_item-plant
          required_date      = ls_order_item-requested_date
          requested_quantity = ls_order_item-open_base_quantity )
          TO lt_demands.
        INSERT VALUE #(
          request_id     = lv_request_id
          sales_document = lv_sales_document
          order_item     = ls_order_item ) INTO TABLE lt_contexts.
      ENDLOOP.
    ENDLOOP.

    IF lt_demands IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(lt_allocations) = mo_stock_service->allocate_demands_by_date(
      it_demands                = lt_demands
      iv_include_po_receipts    = iv_include_po_receipts
      iv_include_sto_in_transit = iv_include_sto_in_transit
      iv_include_unissued_sto   = iv_include_unissued_sto
      iv_subtract_unissued_sto  = iv_subtract_unissued_sto
      iv_include_prod_receipts  = iv_include_prod_receipts
      iv_protect_safety_stock   = iv_protect_safety_stock ).

    LOOP AT lt_allocations INTO DATA(ls_allocation).
      READ TABLE lt_contexts INTO DATA(ls_context)
        WITH KEY request_id = ls_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_sales_order.
      ENDIF.

      IF ls_context-order_item-entry_unit =
          ls_context-order_item-base_unit.
        lv_numerator = 1.
        lv_denominator = 1.
      ELSE.
        lv_numerator = ls_context-order_item-sales_unit_numerator.
        lv_denominator = ls_context-order_item-sales_unit_denominator.
      ENDIF.

      APPEND VALUE #(
        request_id              = ls_allocation-request_id
        sales_document          = ls_context-sales_document
        item_number             = ls_context-order_item-item_number
        schedule_line           = ls_context-order_item-schedule_line
        material                = ls_allocation-material
        plant                   = ls_allocation-plant
        required_date           = ls_allocation-required_date
        sales_unit              = ls_context-order_item-entry_unit
        base_unit               = ls_context-order_item-base_unit
        requested_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-requested_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        requested_base_quantity = ls_allocation-requested_quantity
        available_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-available_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        available_base_quantity = ls_allocation-available_quantity
        allocated_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-allocated_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        allocated_base_quantity = ls_allocation-allocated_quantity
        shortfall_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-shortfall_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        shortfall_base_quantity = ls_allocation-shortfall_quantity )
        TO rs_result-sales_unit_allocations.
    ENDLOOP.

    IF iv_check_atp = abap_true.
      LOOP AT lt_demands INTO DATA(ls_atp_demand_source).
        DATA(lv_demand_index) = sy-tabix.
        READ TABLE lt_contexts INTO DATA(ls_atp_context)
          WITH KEY request_id = ls_atp_demand_source-request_id.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_sales_order.
        ENDIF.
        APPEND VALUE #(
          source_index       = lv_demand_index
          request_id         = ls_atp_demand_source-request_id
          item_number        = ls_atp_context-order_item-item_number
          schedule_line      = ls_atp_context-order_item-schedule_line
          material           = ls_atp_demand_source-material
          plant              = ls_atp_demand_source-plant
          unit               = ls_atp_context-order_item-base_unit
          required_date      = ls_atp_demand_source-required_date
          requested_quantity = ls_atp_demand_source-requested_quantity )
          TO lt_atp_demands.
      ENDLOOP.

      SORT lt_atp_demands BY material plant unit required_date
        source_index.
      LOOP AT lt_atp_demands INTO DATA(ls_atp_demand).
        READ TABLE lt_atp_day_totals ASSIGNING
          FIELD-SYMBOL(<ls_atp_day_total>)
          WITH KEY material = ls_atp_demand-material
                   plant = ls_atp_demand-plant
                   unit = ls_atp_demand-unit
                   required_date = ls_atp_demand-required_date.
        IF sy-subrc = 0.
          <ls_atp_day_total>-date_quantity =
            <ls_atp_day_total>-date_quantity
            + ls_atp_demand-requested_quantity.
        ELSE.
          APPEND VALUE #(
            material      = ls_atp_demand-material
            plant         = ls_atp_demand-plant
            unit          = ls_atp_demand-unit
            required_date = ls_atp_demand-required_date
            date_quantity = ls_atp_demand-requested_quantity )
            TO lt_atp_day_totals.
        ENDIF.
      ENDLOOP.

      SORT lt_atp_day_totals BY material plant unit required_date.
      DATA lv_previous_material TYPE mard-matnr.
      DATA lv_previous_plant TYPE mard-werks.
      DATA lv_previous_unit TYPE mara-meins.
      DATA lv_cumulative_quantity TYPE mard-labst.
      DATA lv_first_demand TYPE abap_bool VALUE abap_true.

      LOOP AT lt_atp_day_totals ASSIGNING <ls_atp_day_total>.
        IF lv_first_demand = abap_true
            OR lv_previous_material <> <ls_atp_day_total>-material
            OR lv_previous_plant <> <ls_atp_day_total>-plant
            OR lv_previous_unit <> <ls_atp_day_total>-unit.
          CLEAR lv_cumulative_quantity.
          lv_previous_material = <ls_atp_day_total>-material.
          lv_previous_plant = <ls_atp_day_total>-plant.
          lv_previous_unit = <ls_atp_day_total>-unit.
          lv_first_demand = abap_false.
        ENDIF.
        lv_cumulative_quantity = lv_cumulative_quantity
          + <ls_atp_day_total>-date_quantity.
        <ls_atp_day_total>-cumulative_quantity = lv_cumulative_quantity.
        <ls_atp_day_total>-result = mo_stock_service->check_atp_request(
          is_request = VALUE #(
            material           = <ls_atp_day_total>-material
            plant              = <ls_atp_day_total>-plant
            unit               = <ls_atp_day_total>-unit
            check_rule         = iv_atp_check_rule
            required_date      = <ls_atp_day_total>-required_date
            requested_quantity = lv_cumulative_quantity ) ).
      ENDLOOP.

      LOOP AT lt_atp_demands INTO ls_atp_demand.
        READ TABLE lt_atp_day_totals INTO DATA(ls_atp_day_total)
          WITH KEY material = ls_atp_demand-material
                   plant = ls_atp_demand-plant
                   unit = ls_atp_demand-unit
                   required_date = ls_atp_demand-required_date.
        DATA(ls_confirmation_split) =
          mo_stock_service->get_atp_confirmation_split(
            iv_requested_base_quantity =
              ls_atp_day_total-cumulative_quantity
            is_atp_result              = ls_atp_day_total-result ).
        APPEND VALUE #(
          source_index = ls_atp_demand-source_index
          atp_check    = VALUE #(
            request_id                    = ls_atp_demand-request_id
            item_number                   = ls_atp_demand-item_number
            schedule_line                 = ls_atp_demand-schedule_line
            line_requested_quantity       =
              ls_atp_demand-requested_quantity
            cumulative_requested_quantity =
              ls_atp_day_total-cumulative_quantity
            confirmed_base_quantity       =
              ls_confirmation_split-confirmed_base_quantity
            unconfirmed_base_quantity     =
              ls_confirmation_split-unconfirmed_base_quantity
            result                        = ls_atp_day_total-result ) )
          TO lt_indexed_atp_checks.
      ENDLOOP.

      SORT lt_indexed_atp_checks BY source_index.
      LOOP AT lt_indexed_atp_checks INTO DATA(ls_indexed_atp_check).
        APPEND ls_indexed_atp_check-atp_check TO rs_result-atp_checks.
      ENDLOOP.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD reserve_orders_by_date.
    DATA lt_requests TYPE zif_so_reservation_api=>ty_requests.

    IF iv_check_atp = abap_true
        AND ( iv_atp_check_rule IS NOT SUPPLIED
          OR iv_atp_check_rule IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_preview) = preview_orders_by_date(
      it_sales_documents        = it_sales_documents
      iv_include_po_receipts    = iv_include_po_receipts
      iv_include_sto_in_transit = iv_include_sto_in_transit
      iv_include_unissued_sto   = iv_include_unissued_sto
      iv_subtract_unissued_sto  = iv_subtract_unissued_sto
      iv_include_prod_receipts  = iv_include_prod_receipts
      iv_use_confirmed_qty      = iv_use_confirmed_qty
      iv_protect_safety_stock   = iv_protect_safety_stock
      iv_check_atp              = iv_check_atp
      iv_atp_check_rule         = iv_atp_check_rule ).
    rs_result-sales_unit_allocations = ls_preview-sales_unit_allocations.
    rs_result-atp_checks = ls_preview-atp_checks.
    rs_result-messages = ls_preview-messages.

    IF ls_preview-is_successful <> abap_true.
      RETURN.
    ENDIF.

    IF iv_require_full_allocation = abap_true.
      LOOP AT ls_preview-sales_unit_allocations
        INTO DATA(ls_checked_allocation)
        WHERE shortfall_base_quantity > 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Full allocation required; no reservations were created' )
          TO rs_result-messages.
        RETURN.
      ENDLOOP.
    ENDIF.

    LOOP AT ls_preview-sales_unit_allocations INTO DATA(ls_allocation)
      WHERE allocated_base_quantity > 0.
      APPEND VALUE #(
        request_id     = ls_allocation-request_id
        sales_document = ls_allocation-sales_document
        item_number    = ls_allocation-item_number
        material       = ls_allocation-material
        plant          = ls_allocation-plant
        required_date  = ls_allocation-required_date
        quantity       = ls_allocation-allocated_base_quantity
        unit           = ls_allocation-base_unit )
        TO lt_requests.
    ENDLOOP.

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    SORT lt_requests STABLE BY material plant required_date.

    DATA(ls_create_result) = mo_reservation_api->create_reservations(
      it_requests = lt_requests
      iv_test_run = iv_test_run ).
    APPEND LINES OF ls_create_result-messages TO rs_result-messages.
    rs_result-reservations = ls_create_result-reservations.

    IF ls_create_result-is_successful <> abap_true.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      RETURN.
    ENDIF.

    DATA(lv_responses_match) = reservation_results_match(
      it_requests     = lt_requests
      it_reservations = rs_result-reservations
      iv_test_run     = iv_test_run ).
    IF lv_responses_match <> abap_true.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API results do not match the requests' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD reservation_results_match.
    DATA lt_unmatched_requests TYPE zif_so_reservation_api=>ty_requests.

    IF lines( it_requests ) <> lines( it_reservations ).
      RETURN.
    ENDIF.

    lt_unmatched_requests = it_requests.
    LOOP AT it_reservations INTO DATA(ls_reservation).
      IF ls_reservation-request_id IS INITIAL
          OR ( ls_reservation-reservation_number IS INITIAL
            AND iv_test_run <> abap_true ).
        RETURN.
      ENDIF.

      DATA(lv_request_found) = abap_false.
      LOOP AT lt_unmatched_requests INTO DATA(ls_request)
        WHERE request_id = ls_reservation-request_id.
        IF ls_reservation-quantity <> ls_request-quantity
            OR ( ls_request-required_date IS NOT INITIAL
              AND ls_reservation-required_date <>
                ls_request-required_date )
            OR ( ls_request-storage_location IS NOT INITIAL
              AND ls_reservation-storage_location <>
                ls_request-storage_location )
            OR ( ls_request-batch IS NOT INITIAL
              AND ls_reservation-batch <> ls_request-batch ).
          CONTINUE.
        ENDIF.

        DELETE lt_unmatched_requests INDEX sy-tabix.
        lv_request_found = abap_true.
        EXIT.
      ENDLOOP.

      IF lv_request_found <> abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF lt_unmatched_requests IS INITIAL.
      rv_is_valid = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD prepare_order_allocations.
    FIELD-SYMBOLS <ls_order_item> TYPE zif_sales_order_api=>ty_item.

    IF iv_sales_document IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    IF iv_fefo_min_days < 0
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_batch_selections IS SUPPLIED
        AND it_location_selections IS SUPPLIED.
      APPEND VALUE #(
        type    = 'E'
        message = 'Choose batch selections or location selections, not both' )
        TO rs_prepared-messages.
      RETURN.
    ENDIF.

    IF iv_use_fefo_batches = abap_true
        AND it_batch_selections IS SUPPLIED.
      APPEND VALUE #(
        type    = 'E'
        message = 'Choose FEFO allocation or explicit batch selections' )
        TO rs_prepared-messages.
      RETURN.
    ENDIF.

    IF iv_use_fefo_batches = abap_true
        AND iv_fefo_as_of_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_order_result) = mo_sales_order_service->read_order(
      iv_sales_document ).
    rs_prepared-order_items = ls_order_result-order-items.
    rs_prepared-messages = ls_order_result-messages.

    IF ls_order_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF iv_use_confirmed_qty = abap_true.
      LOOP AT rs_prepared-order_items ASSIGNING <ls_order_item>.
        IF <ls_order_item>-open_base_quantity > 0
            AND ( <ls_order_item>-schedule_line IS INITIAL
              OR <ls_order_item>-has_confirmed_quantity <> abap_true ).
          APPEND VALUE #(
            type    = 'E'
            message = 'Confirmed-quantity mode requires schedule-line confirmation data' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.

        IF <ls_order_item>-has_confirmed_quantity = abap_true.
          IF <ls_order_item>-confirmed_quantity < 0
              OR <ls_order_item>-open_confirmed_quantity < 0
              OR <ls_order_item>-confirmed_base_quantity < 0
              OR <ls_order_item>-open_confirmed_base_quantity < 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Schedule line contains a negative confirmed quantity' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.

          IF <ls_order_item>-open_confirmed_quantity >
              <ls_order_item>-open_quantity.
            <ls_order_item>-open_confirmed_quantity =
              <ls_order_item>-open_quantity.
          ENDIF.
          IF <ls_order_item>-open_confirmed_base_quantity >
              <ls_order_item>-open_base_quantity.
            <ls_order_item>-open_confirmed_base_quantity =
              <ls_order_item>-open_base_quantity.
          ENDIF.

          <ls_order_item>-open_quantity =
            <ls_order_item>-open_confirmed_quantity.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_confirmed_base_quantity.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA lt_demands TYPE zcl_stock_service=>ty_demands.
    DATA lt_batch_demands TYPE zcl_stock_service=>ty_batch_demands.
    DATA lt_fefo_demands TYPE zcl_stock_service=>ty_fefo_demands.
    DATA lt_seen_selections TYPE ty_selection_keys.
    DATA lt_open_selection_keys TYPE ty_selection_keys.
    DATA lt_open_selection_items TYPE ty_selection_items.
    DATA lt_selection_modes TYPE ty_selection_modes.
    DATA lt_date_priorities TYPE ty_date_priorities.
    DATA lt_prioritized_order_items TYPE zif_sales_order_api=>ty_items.
    DATA lv_fefo_location TYPE mard-lgort.
    DATA lv_fefo_fallback TYPE abap_bool.

    IF iv_prioritize_by_date = abap_true.
      LOOP AT rs_prepared-order_items INTO DATA(ls_priority_source).
        APPEND VALUE #(
          missing_date   = COND abap_bool(
            WHEN ls_priority_source-requested_date IS INITIAL
              THEN abap_true
            ELSE abap_false )
          requested_date = ls_priority_source-requested_date
          source_index   = sy-tabix )
          TO lt_date_priorities.
      ENDLOOP.
      SORT lt_date_priorities BY missing_date requested_date source_index.
      LOOP AT lt_date_priorities INTO DATA(ls_date_priority).
        READ TABLE rs_prepared-order_items
          INDEX ls_date_priority-source_index
          INTO DATA(ls_prioritized_order_item).
        IF sy-subrc = 0.
          APPEND ls_prioritized_order_item TO lt_prioritized_order_items.
        ENDIF.
      ENDLOOP.
      rs_prepared-order_items = lt_prioritized_order_items.
    ENDIF.

    LOOP AT rs_prepared-order_items INTO DATA(ls_validated_item)
      WHERE open_base_quantity > 0.
      IF ls_validated_item-material IS INITIAL
          OR ls_validated_item-plant IS INITIAL
          OR ls_validated_item-base_unit IS INITIAL
          OR ls_validated_item-item_number IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open order item lacks its number, material, plant, or base unit' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF ls_validated_item-schedule_line IS NOT INITIAL
          AND ls_validated_item-requested_date IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open schedule line lacks a requested date' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF iv_check_atp = abap_true
          AND ls_validated_item-requested_date IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'ATP preview requires a requested date for each open item' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF ls_validated_item-entry_unit IS NOT INITIAL
          AND ls_validated_item-entry_unit <> ls_validated_item-base_unit
          AND ( ls_validated_item-sales_unit_numerator <= 0
            OR ls_validated_item-sales_unit_denominator <= 0 ).
        APPEND VALUE #(
          type    = 'E'
          message = 'Open order item lacks a valid sales unit conversion ratio' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA(lt_order_reservations) =
      mo_stock_service->get_sales_order_reservations(
        iv_sales_document = iv_sales_document ).
    subtract_order_reservations(
      EXPORTING
        it_reservations = lt_order_reservations
      CHANGING
        ct_order_items  = rs_prepared-order_items ).

    IF it_batch_selections IS SUPPLIED.
      LOOP AT it_batch_selections INTO DATA(ls_batch_selection).
        IF ls_batch_selection-item_number IS INITIAL
            OR ls_batch_selection-batch IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection requires an item number and batch' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        IF ls_batch_selection-allow_fallback = abap_true
            AND ls_batch_selection-storage_location IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch fallback requires a preferred storage location' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        INSERT VALUE #(
          item_number   = ls_batch_selection-item_number
          schedule_line = ls_batch_selection-schedule_line )
          INTO TABLE lt_seen_selections.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection repeats an order item and schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.

        DATA(lv_selection_mode) = COND #(
          WHEN ls_batch_selection-schedule_line IS INITIAL THEN 'W'
          ELSE 'S' ).
        READ TABLE lt_selection_modes INTO DATA(ls_selection_mode)
          WITH TABLE KEY item_number = ls_batch_selection-item_number.
        IF sy-subrc = 0 AND ls_selection_mode-mode <> lv_selection_mode.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection cannot mix item-wide and schedule-line choices' )
            TO rs_prepared-messages.
          RETURN.
        ELSEIF sy-subrc <> 0.
          INSERT VALUE #(
            item_number = ls_batch_selection-item_number
            mode        = lv_selection_mode )
            INTO TABLE lt_selection_modes.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF it_location_selections IS SUPPLIED.
      LOOP AT it_location_selections INTO DATA(ls_location_selection).
        IF ls_location_selection-item_number IS INITIAL
            OR ls_location_selection-storage_location IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection requires an item number and storage location' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        INSERT VALUE #(
          item_number   = ls_location_selection-item_number
          schedule_line = ls_location_selection-schedule_line )
          INTO TABLE lt_seen_selections.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection repeats an order item and schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.

        DATA(lv_location_mode) = COND #(
          WHEN ls_location_selection-schedule_line IS INITIAL THEN 'W'
          ELSE 'S' ).
        READ TABLE lt_selection_modes INTO ls_selection_mode
          WITH TABLE KEY item_number = ls_location_selection-item_number.
        IF sy-subrc = 0 AND ls_selection_mode-mode <> lv_location_mode.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection cannot mix item-wide and schedule-line choices' )
            TO rs_prepared-messages.
          RETURN.
        ELSEIF sy-subrc <> 0.
          INSERT VALUE #(
            item_number = ls_location_selection-item_number
            mode        = lv_location_mode )
            INTO TABLE lt_selection_modes.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT rs_prepared-order_items INTO DATA(ls_order_item).
      IF ls_order_item-open_base_quantity <= 0.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        item_number   = ls_order_item-item_number
        schedule_line = ls_order_item-schedule_line )
        INTO TABLE lt_open_selection_keys.
      INSERT VALUE #( item_number = ls_order_item-item_number )
        INTO TABLE lt_open_selection_items.

      IF ls_order_item-material IS INITIAL
          OR ls_order_item-plant IS INITIAL
          OR ls_order_item-base_unit IS INITIAL
          OR ls_order_item-item_number IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open order item lacks its number, material, plant, or base unit' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF ls_order_item-schedule_line IS NOT INITIAL
          AND ls_order_item-requested_date IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open schedule line lacks a requested date' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      DATA lv_request_id TYPE c LENGTH 30.
      CLEAR lv_request_id.
      IF ls_order_item-schedule_line IS INITIAL.
        CONCATENATE iv_sales_document ls_order_item-item_number
          INTO lv_request_id SEPARATED BY '/'.
      ELSE.
        CONCATENATE iv_sales_document ls_order_item-item_number
          ls_order_item-schedule_line
          INTO lv_request_id SEPARATED BY '/'.
      ENDIF.
      IF it_batch_selections IS SUPPLIED.
        READ TABLE it_batch_selections INTO ls_batch_selection
          WITH KEY item_number   = ls_order_item-item_number
                   schedule_line = ls_order_item-schedule_line.
        IF sy-subrc <> 0 AND ls_order_item-schedule_line IS NOT INITIAL.
          READ TABLE it_batch_selections INTO ls_batch_selection
            WITH KEY item_number   = ls_order_item-item_number
                     schedule_line = space.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection is required for every open schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        APPEND VALUE #(
          request_id                  = lv_request_id
          material                    = ls_order_item-material
          plant                       = ls_order_item-plant
          batch                       = ls_batch_selection-batch
          storage_location            = ls_batch_selection-storage_location
          fallback_to_other_locations = ls_batch_selection-allow_fallback
          requested_quantity          = ls_order_item-open_base_quantity )
          TO lt_batch_demands.
      ELSEIF iv_use_fefo_batches = abap_true.
        CLEAR lv_fefo_location.
        CLEAR lv_fefo_fallback.
        IF it_location_selections IS SUPPLIED.
          READ TABLE it_location_selections INTO ls_location_selection
            WITH KEY item_number   = ls_order_item-item_number
                     schedule_line = ls_order_item-schedule_line.
          IF sy-subrc <> 0 AND ls_order_item-schedule_line IS NOT INITIAL.
            READ TABLE it_location_selections INTO ls_location_selection
              WITH KEY item_number   = ls_order_item-item_number
                       schedule_line = space.
          ENDIF.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Location selection is required for every open schedule line' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.
          lv_fefo_location = ls_location_selection-storage_location.
          lv_fefo_fallback = ls_location_selection-allow_fallback.
        ENDIF.
        APPEND VALUE #(
          request_id                  = lv_request_id
          material                    = ls_order_item-material
          plant                       = ls_order_item-plant
          storage_location            = lv_fefo_location
          fallback_to_other_locations = lv_fefo_fallback
          requested_quantity          = ls_order_item-open_base_quantity )
          TO lt_fefo_demands.
      ELSEIF it_location_selections IS SUPPLIED.
        READ TABLE it_location_selections INTO ls_location_selection
          WITH KEY item_number   = ls_order_item-item_number
                   schedule_line = ls_order_item-schedule_line.
        IF sy-subrc <> 0 AND ls_order_item-schedule_line IS NOT INITIAL.
          READ TABLE it_location_selections INTO ls_location_selection
            WITH KEY item_number   = ls_order_item-item_number
                     schedule_line = space.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection is required for every open schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        APPEND VALUE #(
          request_id                  = lv_request_id
          material                    = ls_order_item-material
          plant                       = ls_order_item-plant
          storage_location            = ls_location_selection-storage_location
          fallback_to_other_locations = ls_location_selection-allow_fallback
          requested_quantity          = ls_order_item-open_base_quantity )
          TO lt_demands.
      ELSE.
        APPEND VALUE #(
          request_id         = lv_request_id
          material           = ls_order_item-material
          plant              = ls_order_item-plant
          requested_quantity = ls_order_item-open_base_quantity )
          TO lt_demands.
      ENDIF.
    ENDLOOP.

    IF it_batch_selections IS SUPPLIED.
      LOOP AT it_batch_selections INTO ls_batch_selection.
        IF ls_batch_selection-schedule_line IS INITIAL.
          READ TABLE lt_open_selection_items TRANSPORTING NO FIELDS
            WITH TABLE KEY item_number = ls_batch_selection-item_number.
        ELSE.
          READ TABLE lt_open_selection_keys TRANSPORTING NO FIELDS
            WITH TABLE KEY item_number = ls_batch_selection-item_number
                           schedule_line = ls_batch_selection-schedule_line.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection contains an item or schedule line that is not open' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
      ENDLOOP.
      DATA(ls_batch_result) = mo_stock_service->allocate_by_batch(
        it_demands              = lt_batch_demands
        iv_protect_safety_stock = iv_protect_safety_stock ).
      rs_prepared-allocations = ls_batch_result-allocations.
      rs_prepared-batch_allocations = ls_batch_result-batch_allocations.
    ELSEIF iv_use_fefo_batches = abap_true.
      IF it_location_selections IS SUPPLIED.
        LOOP AT it_location_selections INTO ls_location_selection.
          IF ls_location_selection-schedule_line IS INITIAL.
            READ TABLE lt_open_selection_items TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number.
          ELSE.
            READ TABLE lt_open_selection_keys TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number
                             schedule_line = ls_location_selection-schedule_line.
          ENDIF.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Location selection contains an item or schedule line that is not open' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.
      DATA(ls_fefo_result) = mo_stock_service->allocate_by_expiry(
        it_demands              = lt_fefo_demands
        iv_as_of_date           = iv_fefo_as_of_date
        iv_min_days             =
          iv_fefo_min_days
        iv_protect_safety_stock = iv_protect_safety_stock ).
      rs_prepared-allocations = ls_fefo_result-allocations.
      rs_prepared-batch_allocations = ls_fefo_result-batch_allocations.
    ELSE.
      IF it_location_selections IS SUPPLIED.
        LOOP AT it_location_selections INTO ls_location_selection.
          IF ls_location_selection-schedule_line IS INITIAL.
            READ TABLE lt_open_selection_items TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number.
          ELSE.
            READ TABLE lt_open_selection_keys TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number
                             schedule_line = ls_location_selection-schedule_line.
          ENDIF.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Location selection contains an item or schedule line that is not open' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.
      DATA(ls_location_result) =
        mo_stock_service->allocate_by_storage_location(
          it_demands              = lt_demands
          iv_protect_safety_stock = iv_protect_safety_stock ).
      rs_prepared-allocations = ls_location_result-allocations.
      rs_prepared-storage_allocations =
        ls_location_result-storage_allocations.
    ENDIF.
    rs_prepared-sales_unit_allocations = build_sales_unit_allocations(
      iv_sales_document = iv_sales_document
      it_order_items    = rs_prepared-order_items
      it_allocations    = rs_prepared-allocations ).
    rs_prepared-is_successful = abap_true.
  ENDMETHOD.

  METHOD subtract_order_reservations.
    DATA lt_reservation_balances TYPE ty_order_reservation_balances.
    DATA lv_remaining_quantity TYPE mard-labst.
    FIELD-SYMBOLS <ls_order_item> TYPE zif_sales_order_api=>ty_item.

    LOOP AT it_reservations INTO DATA(ls_reservation).
      APPEND VALUE #(
        material           = ls_reservation-material
        plant              = ls_reservation-plant
        item_number        = ls_reservation-item_number
        schedule_line      = ls_reservation-schedule_line
        requirement_date   = ls_reservation-requirement_date
        remaining_quantity = ls_reservation-open_quantity )
        TO lt_reservation_balances.
    ENDLOOP.

    LOOP AT lt_reservation_balances ASSIGNING FIELD-SYMBOL(<ls_reservation>)
      WHERE schedule_line IS NOT INITIAL
        AND remaining_quantity > 0.
      lv_remaining_quantity = <ls_reservation>-remaining_quantity.
      LOOP AT ct_order_items ASSIGNING <ls_order_item>
        WHERE item_number = <ls_reservation>-item_number
          AND material = <ls_reservation>-material
          AND plant = <ls_reservation>-plant
          AND schedule_line = <ls_reservation>-schedule_line.
        IF <ls_order_item>-open_base_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_remaining_quantity >= <ls_order_item>-open_base_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - <ls_order_item>-open_base_quantity.
          CLEAR <ls_order_item>-open_base_quantity.
        ELSE.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_base_quantity - lv_remaining_quantity.
          CLEAR lv_remaining_quantity.
        ENDIF.
      ENDLOOP.
      <ls_reservation>-remaining_quantity = lv_remaining_quantity.
    ENDLOOP.

    LOOP AT lt_reservation_balances ASSIGNING <ls_reservation>
      WHERE requirement_date IS NOT INITIAL
        AND remaining_quantity > 0.
      lv_remaining_quantity = <ls_reservation>-remaining_quantity.
      LOOP AT ct_order_items ASSIGNING <ls_order_item>
        WHERE item_number = <ls_reservation>-item_number
          AND material = <ls_reservation>-material
          AND plant = <ls_reservation>-plant
          AND requested_date = <ls_reservation>-requirement_date.
        IF <ls_order_item>-open_base_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_remaining_quantity >= <ls_order_item>-open_base_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - <ls_order_item>-open_base_quantity.
          CLEAR <ls_order_item>-open_base_quantity.
        ELSE.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_base_quantity - lv_remaining_quantity.
          CLEAR lv_remaining_quantity.
        ENDIF.
      ENDLOOP.
      <ls_reservation>-remaining_quantity = lv_remaining_quantity.
    ENDLOOP.

    LOOP AT lt_reservation_balances ASSIGNING <ls_reservation>
      WHERE remaining_quantity > 0.
      lv_remaining_quantity = <ls_reservation>-remaining_quantity.
      LOOP AT ct_order_items ASSIGNING <ls_order_item>
        WHERE item_number = <ls_reservation>-item_number
          AND material = <ls_reservation>-material
          AND plant = <ls_reservation>-plant.
        IF <ls_order_item>-open_base_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_remaining_quantity >= <ls_order_item>-open_base_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - <ls_order_item>-open_base_quantity.
          CLEAR <ls_order_item>-open_base_quantity.
        ELSE.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_base_quantity - lv_remaining_quantity.
          CLEAR lv_remaining_quantity.
        ENDIF.
      ENDLOOP.
      <ls_reservation>-remaining_quantity = lv_remaining_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_sales_unit_allocations.
    DATA lv_request_id TYPE c LENGTH 30.
    DATA lv_item_found TYPE abap_bool.
    DATA lv_numerator TYPE bapisdit-sales_qty1.
    DATA lv_denominator TYPE bapisdit-sales_qty2.
    DATA ls_order_item TYPE zif_sales_order_api=>ty_item.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      CLEAR lv_item_found.
      LOOP AT it_order_items INTO ls_order_item.
        CLEAR lv_request_id.
        IF ls_order_item-schedule_line IS INITIAL.
          CONCATENATE iv_sales_document ls_order_item-item_number
            INTO lv_request_id SEPARATED BY '/'.
        ELSE.
          CONCATENATE iv_sales_document ls_order_item-item_number
            ls_order_item-schedule_line
            INTO lv_request_id SEPARATED BY '/'.
        ENDIF.
        IF lv_request_id = ls_allocation-request_id.
          lv_item_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_item_found <> abap_true
          OR ls_order_item-entry_unit IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_order_item-entry_unit = ls_order_item-base_unit.
        lv_numerator = 1.
        lv_denominator = 1.
      ELSE.
        lv_numerator = ls_order_item-sales_unit_numerator.
        lv_denominator = ls_order_item-sales_unit_denominator.
        IF lv_numerator <= 0 OR lv_denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.

      APPEND VALUE #(
        request_id              = ls_allocation-request_id
        sales_document          = iv_sales_document
        item_number             = ls_order_item-item_number
        schedule_line           = ls_order_item-schedule_line
        material                = ls_order_item-material
        plant                   = ls_order_item-plant
        required_date           = ls_order_item-requested_date
        sales_unit              = ls_order_item-entry_unit
        base_unit               = ls_order_item-base_unit
        requested_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-requested_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        requested_base_quantity = ls_allocation-requested_quantity
        available_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-available_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        available_base_quantity = ls_allocation-available_quantity
        allocated_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-allocated_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        allocated_base_quantity = ls_allocation-allocated_quantity
        shortfall_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-shortfall_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        shortfall_base_quantity = ls_allocation-shortfall_quantity )
        TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_base_to_sales_unit.
    rv_quantity = CONV mard-labst(
      CONV decfloat34( iv_base_quantity )
      * CONV decfloat34( iv_denominator )
      / CONV decfloat34( iv_numerator ) ).
  ENDMETHOD.

ENDCLASS.
