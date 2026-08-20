CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_request_id       TYPE c LENGTH 32.
    TYPES ty_material         TYPE c LENGTH 40.
    TYPES ty_plant            TYPE c LENGTH 4.
    TYPES ty_storage_location TYPE c LENGTH 4.
    TYPES ty_movement_type    TYPE c LENGTH 3.
    TYPES ty_unit             TYPE c LENGTH 3.
    TYPES ty_cost_center      TYPE c LENGTH 10.
    TYPES ty_order_id         TYPE c LENGTH 12.
    TYPES ty_wbs_element      TYPE c LENGTH 24.
    TYPES ty_sales_order      TYPE c LENGTH 10.
    TYPES ty_sales_order_item TYPE n LENGTH 6.
    TYPES ty_asset_number     TYPE c LENGTH 12.
    TYPES ty_asset_subnumber  TYPE c LENGTH 4.
    TYPES ty_network_id       TYPE c LENGTH 12.
    TYPES ty_network_activity TYPE c LENGTH 4.
    TYPES ty_quantity         TYPE decfloat34.
    TYPES ty_status           TYPE c LENGTH 12.
    TYPES ty_posting_status   TYPE c LENGTH 12.
    TYPES ty_decision_code    TYPE c LENGTH 30.
    TYPES ty_document_id      TYPE c LENGTH 10.
    TYPES ty_strategy         TYPE c LENGTH 20.
    TYPES ty_payload_version  TYPE c LENGTH 3.

    CONSTANTS gc_status_allocated TYPE ty_status VALUE 'ALLOCATED'.
    CONSTANTS gc_status_partial   TYPE ty_status VALUE 'PARTIAL'.
    CONSTANTS gc_status_rejected  TYPE ty_status VALUE 'REJECTED'.
    CONSTANTS gc_status_invalid   TYPE ty_status VALUE 'INVALID'.
    CONSTANTS gc_status_deferred  TYPE ty_status VALUE 'DEFERRED'.
    CONSTANTS gc_status_aborted   TYPE ty_status VALUE 'ABORTED'.
    CONSTANTS gc_status_config_error TYPE ty_status VALUE 'CONFIG_ERROR'.
    CONSTANTS gc_posting_pending  TYPE ty_posting_status VALUE 'PENDING'.
    CONSTANTS gc_posting_posted   TYPE ty_posting_status VALUE 'POSTED'.
    CONSTANTS gc_posting_failed   TYPE ty_posting_status VALUE 'FAILED'.
    CONSTANTS gc_posting_simulated TYPE ty_posting_status VALUE 'SIMULATED'.
    CONSTANTS gc_posting_not_required TYPE ty_posting_status VALUE 'NOT_REQUIRED'.
    CONSTANTS gc_strategy_priority_due TYPE ty_strategy VALUE 'PRIORITY_DUE'.
    CONSTANTS gc_strategy_due_priority TYPE ty_strategy VALUE 'DUE_PRIORITY'.
    CONSTANTS gc_strategy_priority_id  TYPE ty_strategy VALUE 'PRIORITY_ID'.
    CONSTANTS gc_payload_version TYPE ty_payload_version VALUE '001'.
    CONSTANTS gc_decision_fully_allocated TYPE ty_decision_code
      VALUE 'FULLY_ALLOCATED'.
    CONSTANTS gc_decision_partial TYPE ty_decision_code
      VALUE 'PARTIALLY_ALLOCATED'.
    CONSTANTS gc_decision_no_available_stock TYPE ty_decision_code
      VALUE 'NO_AVAILABLE_STOCK'.
    CONSTANTS gc_decision_partial_denied TYPE ty_decision_code
      VALUE 'PARTIAL_NOT_ALLOWED'.
    CONSTANTS gc_decision_below_minimum_fill TYPE ty_decision_code
      VALUE 'BELOW_MINIMUM_FILL'.
    CONSTANTS gc_decision_invalid_request TYPE ty_decision_code
      VALUE 'INVALID_REQUEST'.
    CONSTANTS gc_decision_rule_invalid TYPE ty_decision_code
      VALUE 'REQUEST_RULE_INVALID'.
    CONSTANTS gc_decision_duplicate_request TYPE ty_decision_code
      VALUE 'DUPLICATE_REQUEST_ID'.
    CONSTANTS gc_decision_bad_strategy TYPE ty_decision_code
      VALUE 'STRATEGY_UNSUPPORTED'.
    CONSTANTS gc_decision_replay_version TYPE ty_decision_code
      VALUE 'REPLAY_VERSION_UNSUPPORTED'.
    CONSTANTS gc_decision_replay_conflict TYPE ty_decision_code
      VALUE 'REPLAY_PAYLOAD_CONFLICT'.
    CONSTANTS gc_decision_replay_missing TYPE ty_decision_code
      VALUE 'REPLAY_RESERVATION_MISSING'.
    CONSTANTS gc_decision_replayed TYPE ty_decision_code
      VALUE 'RESERVATION_REPLAYED'.
    CONSTANTS gc_decision_outside_horizon TYPE ty_decision_code
      VALUE 'OUTSIDE_HORIZON'.
    CONSTANTS gc_decision_stock_not_found TYPE ty_decision_code
      VALUE 'STOCK_NOT_FOUND'.
    CONSTANTS gc_decision_base_unit_missing TYPE ty_decision_code
      VALUE 'BASE_UNIT_MISSING'.
    CONSTANTS gc_decision_conversion_failed TYPE ty_decision_code
      VALUE 'UNIT_CONVERSION_FAILED'.
    CONSTANTS gc_decision_plant_unauthorized TYPE ty_decision_code
      VALUE 'PLANT_UNAUTHORIZED'.
    CONSTANTS gc_decision_full_batch_aborted TYPE ty_decision_code
      VALUE 'FULL_BATCH_ABORTED'.

    TYPES:
      BEGIN OF ty_request,
        request_id       TYPE ty_request_id,
        material         TYPE ty_material,
        plant            TYPE ty_plant,
        storage_location TYPE ty_storage_location,
        movement_type    TYPE ty_movement_type,
        cost_center      TYPE ty_cost_center,
        order_id         TYPE ty_order_id,
        wbs_element      TYPE ty_wbs_element,
        sales_order      TYPE ty_sales_order,
        sales_order_item TYPE ty_sales_order_item,
        asset_number     TYPE ty_asset_number,
        asset_subnumber  TYPE ty_asset_subnumber,
        network_id       TYPE ty_network_id,
        network_activity TYPE ty_network_activity,
        unit_of_measure  TYPE ty_unit,
        requirement_date TYPE d,
        requested_qty    TYPE ty_quantity,
        minimum_fill_pct TYPE ty_quantity,
        priority         TYPE i,
        allow_partial    TYPE abap_bool,
      END OF ty_request.
    TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_stock_balance,
        material         TYPE ty_material,
        plant            TYPE ty_plant,
        storage_location TYPE ty_storage_location,
        base_unit        TYPE ty_unit,
        unrestricted_qty TYPE ty_quantity,
        safety_stock_qty TYPE ty_quantity,
      END OF ty_stock_balance.
    TYPES ty_stock_balances TYPE SORTED TABLE OF ty_stock_balance
      WITH UNIQUE KEY material plant storage_location.

    TYPES:
      BEGIN OF ty_allocation,
        request_id             TYPE ty_request_id,
        material               TYPE ty_material,
        plant                  TYPE ty_plant,
        storage_location       TYPE ty_storage_location,
        movement_type          TYPE ty_movement_type,
        cost_center            TYPE ty_cost_center,
        order_id               TYPE ty_order_id,
        wbs_element            TYPE ty_wbs_element,
        sales_order            TYPE ty_sales_order,
        sales_order_item       TYPE ty_sales_order_item,
        asset_number           TYPE ty_asset_number,
        asset_subnumber        TYPE ty_asset_subnumber,
        network_id             TYPE ty_network_id,
        network_activity       TYPE ty_network_activity,
        unit_of_measure        TYPE ty_unit,
        requirement_date       TYPE d,
        requested_qty          TYPE ty_quantity,
        source_requested_qty   TYPE ty_quantity,
        source_unit_of_measure TYPE ty_unit,
        minimum_fill_pct       TYPE ty_quantity,
        priority               TYPE i,
        allow_partial          TYPE abap_bool,
        allocated_qty          TYPE ty_quantity,
        shortfall_qty          TYPE ty_quantity,
        status                 TYPE ty_status,
        decision_code          TYPE ty_decision_code,
        posting_status         TYPE ty_posting_status,
        document_id            TYPE ty_document_id,
        replaced_document_id   TYPE ty_document_id,
        posting_message        TYPE string,
      END OF ty_allocation.
    TYPES ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_replay,
        payload_version        TYPE ty_payload_version,
        request_id             TYPE ty_request_id,
        material               TYPE ty_material,
        plant                  TYPE ty_plant,
        storage_location       TYPE ty_storage_location,
        movement_type          TYPE ty_movement_type,
        cost_center            TYPE ty_cost_center,
        order_id               TYPE ty_order_id,
        wbs_element            TYPE ty_wbs_element,
        sales_order            TYPE ty_sales_order,
        sales_order_item       TYPE ty_sales_order_item,
        asset_number           TYPE ty_asset_number,
        asset_subnumber        TYPE ty_asset_subnumber,
        network_id             TYPE ty_network_id,
        network_activity       TYPE ty_network_activity,
        requirement_date       TYPE d,
        source_requested_qty   TYPE ty_quantity,
        source_unit_of_measure TYPE ty_unit,
        minimum_fill_pct       TYPE ty_quantity,
        priority               TYPE i,
        allow_partial          TYPE abap_bool,
        requested_qty          TYPE ty_quantity,
        allocated_qty          TYPE ty_quantity,
        unit_of_measure        TYPE ty_unit,
        document_id            TYPE ty_document_id,
        document_cancelled     TYPE abap_bool,
      END OF ty_replay.
    TYPES ty_replays TYPE SORTED TABLE OF ty_replay
      WITH UNIQUE KEY request_id.

    METHODS constructor
      IMPORTING
        io_unit_converter TYPE REF TO zif_unit_converter.

    METHODS allocate
      IMPORTING
        it_requests           TYPE ty_requests
        it_stock_balances     TYPE ty_stock_balances
        it_replays            TYPE ty_replays OPTIONAL
        iv_horizon_date       TYPE d OPTIONAL
        iv_strategy           TYPE ty_strategy DEFAULT gc_strategy_priority_due
      RETURNING
        VALUE(rt_allocations) TYPE ty_allocations.

  PRIVATE SECTION.
    DATA mo_unit_converter TYPE REF TO zif_unit_converter.

    TYPES ty_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    TYPES:
      BEGIN OF ty_plant_balance,
        material         TYPE ty_material,
        plant            TYPE ty_plant,
        base_unit        TYPE ty_unit,
        unrestricted_qty TYPE ty_quantity,
        safety_stock_qty TYPE ty_quantity,
      END OF ty_plant_balance.
    TYPES ty_plant_balances TYPE SORTED TABLE OF ty_plant_balance
      WITH UNIQUE KEY material plant base_unit.

    METHODS calculate_available
      IMPORTING
        is_stock            TYPE ty_stock_balance
        is_plant            TYPE ty_plant_balance
      RETURNING
        VALUE(rv_available) TYPE ty_quantity.

    METHODS create_allocation
      IMPORTING
        is_request           TYPE ty_request
        iv_available         TYPE ty_quantity
      RETURNING
        VALUE(rs_allocation) TYPE ty_allocation.

    METHODS get_account_error
      IMPORTING
        is_request        TYPE ty_request
      RETURNING
        VALUE(rv_message) TYPE string.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD constructor.
    mo_unit_converter = io_unit_converter.
  ENDMETHOD.

  METHOD allocate.
    DATA lt_requests TYPE ty_requests.
    DATA lt_stock_balances TYPE ty_stock_balances.
    DATA lt_plant_balances TYPE ty_plant_balances.
    DATA lt_seen_request_ids TYPE ty_seen_request_ids.
    DATA lv_replaced_document_id TYPE ty_document_id.

    lt_requests = it_requests.
    lt_stock_balances = it_stock_balances.
    LOOP AT lt_stock_balances INTO DATA(ls_initial_stock).
      READ TABLE lt_plant_balances ASSIGNING FIELD-SYMBOL(<ls_plant_balance>)
        WITH TABLE KEY material = ls_initial_stock-material
                       plant = ls_initial_stock-plant
                       base_unit = ls_initial_stock-base_unit.
      IF sy-subrc = 0.
        <ls_plant_balance>-unrestricted_qty =
          <ls_plant_balance>-unrestricted_qty
          + ls_initial_stock-unrestricted_qty.
        IF ls_initial_stock-safety_stock_qty
            > <ls_plant_balance>-safety_stock_qty.
          <ls_plant_balance>-safety_stock_qty =
            ls_initial_stock-safety_stock_qty.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          material         = ls_initial_stock-material
          plant            = ls_initial_stock-plant
          base_unit        = ls_initial_stock-base_unit
          unrestricted_qty = ls_initial_stock-unrestricted_qty
          safety_stock_qty = ls_initial_stock-safety_stock_qty )
          INTO TABLE lt_plant_balances.
      ENDIF.
    ENDLOOP.
    CASE iv_strategy.
      WHEN gc_strategy_priority_due.
        SORT lt_requests BY priority ASCENDING
                            requirement_date ASCENDING
                            request_id ASCENDING.
      WHEN gc_strategy_due_priority.
        SORT lt_requests BY requirement_date ASCENDING
                            priority ASCENDING
                            request_id ASCENDING.
      WHEN gc_strategy_priority_id.
        SORT lt_requests BY priority ASCENDING
                            request_id ASCENDING.
      WHEN OTHERS.
        LOOP AT lt_requests INTO DATA(ls_invalid_strategy_request).
          APPEND VALUE #(
            request_id             = ls_invalid_strategy_request-request_id
            material               = ls_invalid_strategy_request-material
            plant                  = ls_invalid_strategy_request-plant
            storage_location       = ls_invalid_strategy_request-storage_location
            movement_type          = ls_invalid_strategy_request-movement_type
            cost_center            = ls_invalid_strategy_request-cost_center
            order_id               = ls_invalid_strategy_request-order_id
            wbs_element            = ls_invalid_strategy_request-wbs_element
            sales_order            = ls_invalid_strategy_request-sales_order
            sales_order_item       = ls_invalid_strategy_request-sales_order_item
            asset_number           = ls_invalid_strategy_request-asset_number
            asset_subnumber        = ls_invalid_strategy_request-asset_subnumber
            network_id             = ls_invalid_strategy_request-network_id
            network_activity       = ls_invalid_strategy_request-network_activity
            unit_of_measure        = ls_invalid_strategy_request-unit_of_measure
            requirement_date       = ls_invalid_strategy_request-requirement_date
            requested_qty          = ls_invalid_strategy_request-requested_qty
            source_requested_qty   = ls_invalid_strategy_request-requested_qty
            source_unit_of_measure = ls_invalid_strategy_request-unit_of_measure
            shortfall_qty          = ls_invalid_strategy_request-requested_qty
            status                 = gc_status_config_error
            decision_code          = gc_decision_bad_strategy
            posting_status         = gc_posting_not_required
            posting_message        = 'Unsupported allocation strategy' )
            TO rt_allocations.
        ENDLOOP.
        RETURN.
    ENDCASE.

    LOOP AT lt_requests INTO DATA(ls_request).
      CLEAR lv_replaced_document_id.
      DATA(lv_account_error) = get_account_error( ls_request ).
      IF ls_request-requested_qty <= 0
          OR ls_request-minimum_fill_pct < 0
          OR ls_request-minimum_fill_pct > 100
          OR ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-movement_type IS INITIAL
          OR ls_request-unit_of_measure IS INITIAL
          OR ls_request-requirement_date IS INITIAL
          OR lv_account_error IS NOT INITIAL
          OR line_exists( lt_seen_request_ids[ table_line = ls_request-request_id ] ).
        APPEND VALUE #(
          request_id             = ls_request-request_id
          material               = ls_request-material
          plant                  = ls_request-plant
          storage_location       = ls_request-storage_location
          movement_type          = ls_request-movement_type
          cost_center            = ls_request-cost_center
          order_id               = ls_request-order_id
          wbs_element            = ls_request-wbs_element
          sales_order            = ls_request-sales_order
          sales_order_item       = ls_request-sales_order_item
          asset_number           = ls_request-asset_number
          asset_subnumber        = ls_request-asset_subnumber
          network_id             = ls_request-network_id
          network_activity       = ls_request-network_activity
          unit_of_measure        = ls_request-unit_of_measure
          requirement_date       = ls_request-requirement_date
          requested_qty          = ls_request-requested_qty
          source_requested_qty   = ls_request-requested_qty
          source_unit_of_measure = ls_request-unit_of_measure
          shortfall_qty          = ls_request-requested_qty
          status                 = gc_status_invalid
          decision_code          = COND #(
            WHEN line_exists(
              lt_seen_request_ids[ table_line = ls_request-request_id ] )
            THEN gc_decision_duplicate_request
            WHEN lv_account_error IS NOT INITIAL
            THEN gc_decision_rule_invalid
            ELSE gc_decision_invalid_request )
          posting_status         = gc_posting_not_required
          posting_message        = lv_account_error ) TO rt_allocations.
        CONTINUE.
      ENDIF.

      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.

      READ TABLE it_replays INTO DATA(ls_replay)
        WITH TABLE KEY request_id = ls_request-request_id.
      IF sy-subrc = 0.
        IF ls_replay-payload_version <> gc_payload_version.
          APPEND VALUE #(
            request_id             = ls_request-request_id
            material               = ls_request-material
            plant                  = ls_request-plant
            storage_location       = ls_request-storage_location
            movement_type          = ls_request-movement_type
            cost_center            = ls_request-cost_center
            order_id               = ls_request-order_id
            wbs_element            = ls_request-wbs_element
            sales_order            = ls_request-sales_order
            sales_order_item       = ls_request-sales_order_item
            asset_number           = ls_request-asset_number
            asset_subnumber        = ls_request-asset_subnumber
            network_id             = ls_request-network_id
            network_activity       = ls_request-network_activity
            unit_of_measure        = ls_request-unit_of_measure
            requirement_date       = ls_request-requirement_date
            requested_qty          = ls_request-requested_qty
            source_requested_qty   = ls_request-requested_qty
            source_unit_of_measure = ls_request-unit_of_measure
            minimum_fill_pct       = ls_request-minimum_fill_pct
            priority               = ls_request-priority
            allow_partial          = ls_request-allow_partial
            shortfall_qty          = ls_request-requested_qty
            status                 = gc_status_invalid
            decision_code          = gc_decision_replay_version
            posting_status         = gc_posting_not_required
            posting_message        = 'Stored request payload version is unsupported' )
            TO rt_allocations.
        ELSEIF ls_replay-material <> ls_request-material
            OR ls_replay-plant <> ls_request-plant
            OR ls_replay-storage_location <> ls_request-storage_location
            OR ls_replay-movement_type <> ls_request-movement_type
            OR ls_replay-cost_center <> ls_request-cost_center
            OR ls_replay-order_id <> ls_request-order_id
            OR ls_replay-wbs_element <> ls_request-wbs_element
            OR ls_replay-sales_order <> ls_request-sales_order
            OR ls_replay-sales_order_item <> ls_request-sales_order_item
            OR ls_replay-asset_number <> ls_request-asset_number
            OR ls_replay-asset_subnumber <> ls_request-asset_subnumber
            OR ls_replay-network_id <> ls_request-network_id
            OR ls_replay-network_activity <> ls_request-network_activity
            OR ls_replay-requirement_date <> ls_request-requirement_date
            OR ls_replay-source_requested_qty <> ls_request-requested_qty
            OR ls_replay-source_unit_of_measure <> ls_request-unit_of_measure
            OR ls_replay-minimum_fill_pct <> ls_request-minimum_fill_pct
            OR ls_replay-priority <> ls_request-priority
            OR ls_replay-allow_partial <> ls_request-allow_partial.
          APPEND VALUE #(
            request_id             = ls_request-request_id
            material               = ls_request-material
            plant                  = ls_request-plant
            storage_location       = ls_request-storage_location
            movement_type          = ls_request-movement_type
            cost_center            = ls_request-cost_center
            order_id               = ls_request-order_id
            wbs_element            = ls_request-wbs_element
            sales_order            = ls_request-sales_order
            sales_order_item       = ls_request-sales_order_item
            asset_number           = ls_request-asset_number
            asset_subnumber        = ls_request-asset_subnumber
            network_id             = ls_request-network_id
            network_activity       = ls_request-network_activity
            unit_of_measure        = ls_request-unit_of_measure
            requirement_date       = ls_request-requirement_date
            requested_qty          = ls_request-requested_qty
            source_requested_qty   = ls_request-requested_qty
            source_unit_of_measure = ls_request-unit_of_measure
            minimum_fill_pct       = ls_request-minimum_fill_pct
            priority               = ls_request-priority
            allow_partial          = ls_request-allow_partial
            shortfall_qty          = ls_request-requested_qty
            status                 = gc_status_invalid
            decision_code          = gc_decision_replay_conflict
            posting_status         = gc_posting_not_required
            posting_message        = 'Request ID was already used with different input' )
            TO rt_allocations.
        ELSEIF ls_replay-document_id IS INITIAL.
          APPEND VALUE #(
            request_id             = ls_request-request_id
            material               = ls_request-material
            plant                  = ls_request-plant
            storage_location       = ls_request-storage_location
            movement_type          = ls_request-movement_type
            cost_center            = ls_request-cost_center
            order_id               = ls_request-order_id
            wbs_element            = ls_request-wbs_element
            sales_order            = ls_request-sales_order
            sales_order_item       = ls_request-sales_order_item
            asset_number           = ls_request-asset_number
            asset_subnumber        = ls_request-asset_subnumber
            network_id             = ls_request-network_id
            network_activity       = ls_request-network_activity
            unit_of_measure        = ls_request-unit_of_measure
            requirement_date       = ls_request-requirement_date
            requested_qty          = ls_request-requested_qty
            source_requested_qty   = ls_request-requested_qty
            source_unit_of_measure = ls_request-unit_of_measure
            minimum_fill_pct       = ls_request-minimum_fill_pct
            priority               = ls_request-priority
            allow_partial          = ls_request-allow_partial
            shortfall_qty          = ls_request-requested_qty
            status                 = gc_status_invalid
            decision_code          = gc_decision_replay_missing
            posting_status         = gc_posting_failed
            posting_message        = 'Request ID is claimed without a reservation' )
            TO rt_allocations.
        ELSEIF ls_replay-document_cancelled = abap_true.
          lv_replaced_document_id = ls_replay-document_id.
        ELSE.
          DATA(lv_replay_status) = COND ty_status(
            WHEN ls_replay-allocated_qty = ls_replay-requested_qty
            THEN gc_status_allocated
            ELSE gc_status_partial ).
          APPEND VALUE #(
            request_id             = ls_replay-request_id
            material               = ls_replay-material
            plant                  = ls_replay-plant
            storage_location       = ls_replay-storage_location
            movement_type          = ls_replay-movement_type
            cost_center            = ls_replay-cost_center
            order_id               = ls_replay-order_id
            wbs_element            = ls_replay-wbs_element
            sales_order            = ls_replay-sales_order
            sales_order_item       = ls_replay-sales_order_item
            asset_number           = ls_replay-asset_number
            asset_subnumber        = ls_replay-asset_subnumber
            network_id             = ls_replay-network_id
            network_activity       = ls_replay-network_activity
            unit_of_measure        = ls_replay-unit_of_measure
            requirement_date       = ls_replay-requirement_date
            requested_qty          = ls_replay-requested_qty
            source_requested_qty   = ls_replay-source_requested_qty
            source_unit_of_measure = ls_replay-source_unit_of_measure
            minimum_fill_pct       = ls_replay-minimum_fill_pct
            priority               = ls_replay-priority
            allow_partial          = ls_replay-allow_partial
            allocated_qty          = ls_replay-allocated_qty
            shortfall_qty          = ls_replay-requested_qty - ls_replay-allocated_qty
            status                 = lv_replay_status
            decision_code          = gc_decision_replayed
            posting_status         = gc_posting_posted
            document_id            = ls_replay-document_id
            posting_message        = 'Existing reservation reused' )
            TO rt_allocations.
        ENDIF.
        IF lv_replaced_document_id IS INITIAL.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF iv_horizon_date IS NOT INITIAL
          AND ls_request-requirement_date > iv_horizon_date.
        APPEND VALUE #(
          request_id             = ls_request-request_id
          material               = ls_request-material
          plant                  = ls_request-plant
          storage_location       = ls_request-storage_location
          movement_type          = ls_request-movement_type
          cost_center            = ls_request-cost_center
          order_id               = ls_request-order_id
          wbs_element            = ls_request-wbs_element
          sales_order            = ls_request-sales_order
          sales_order_item       = ls_request-sales_order_item
          asset_number           = ls_request-asset_number
          asset_subnumber        = ls_request-asset_subnumber
          network_id             = ls_request-network_id
          network_activity       = ls_request-network_activity
          unit_of_measure        = ls_request-unit_of_measure
          requirement_date       = ls_request-requirement_date
          requested_qty          = ls_request-requested_qty
          source_requested_qty   = ls_request-requested_qty
          source_unit_of_measure = ls_request-unit_of_measure
          minimum_fill_pct       = ls_request-minimum_fill_pct
          priority               = ls_request-priority
          allow_partial          = ls_request-allow_partial
          shortfall_qty          = ls_request-requested_qty
          status                 = gc_status_deferred
          decision_code          = gc_decision_outside_horizon
          posting_status         = gc_posting_not_required
          posting_message        = 'Requirement date is outside allocation horizon' )
          TO rt_allocations.
        CONTINUE.
      ENDIF.

      READ TABLE lt_stock_balances ASSIGNING FIELD-SYMBOL(<ls_stock>)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant
                       storage_location = ls_request-storage_location.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          request_id             = ls_request-request_id
          material               = ls_request-material
          plant                  = ls_request-plant
          storage_location       = ls_request-storage_location
          movement_type          = ls_request-movement_type
          cost_center            = ls_request-cost_center
          order_id               = ls_request-order_id
          wbs_element            = ls_request-wbs_element
          sales_order            = ls_request-sales_order
          sales_order_item       = ls_request-sales_order_item
          asset_number           = ls_request-asset_number
          asset_subnumber        = ls_request-asset_subnumber
          network_id             = ls_request-network_id
          network_activity       = ls_request-network_activity
          unit_of_measure        = ls_request-unit_of_measure
          requirement_date       = ls_request-requirement_date
          requested_qty          = ls_request-requested_qty
          source_requested_qty   = ls_request-requested_qty
          source_unit_of_measure = ls_request-unit_of_measure
          shortfall_qty          = ls_request-requested_qty
          status                 = gc_status_rejected
          decision_code          = gc_decision_stock_not_found
          posting_status         = gc_posting_not_required ) TO rt_allocations.
        CONTINUE.
      ENDIF.

      IF <ls_stock>-base_unit IS INITIAL.
        APPEND VALUE #(
          request_id             = ls_request-request_id
          material               = ls_request-material
          plant                  = ls_request-plant
          storage_location       = ls_request-storage_location
          movement_type          = ls_request-movement_type
          cost_center            = ls_request-cost_center
          order_id               = ls_request-order_id
          wbs_element            = ls_request-wbs_element
          sales_order            = ls_request-sales_order
          sales_order_item       = ls_request-sales_order_item
          asset_number           = ls_request-asset_number
          asset_subnumber        = ls_request-asset_subnumber
          network_id             = ls_request-network_id
          network_activity       = ls_request-network_activity
          unit_of_measure        = ls_request-unit_of_measure
          requirement_date       = ls_request-requirement_date
          requested_qty          = ls_request-requested_qty
          source_requested_qty   = ls_request-requested_qty
          source_unit_of_measure = ls_request-unit_of_measure
          shortfall_qty          = ls_request-requested_qty
          status                 = gc_status_invalid
          decision_code          = gc_decision_base_unit_missing
          posting_status         = gc_posting_not_required
          posting_message        = 'Material base unit is missing' )
          TO rt_allocations.
        CONTINUE.
      ENDIF.

      DATA(ls_normalized_request) = ls_request.
      DATA(ls_conversion) = mo_unit_converter->to_base(
        iv_material    = ls_request-material
        iv_quantity    = ls_request-requested_qty
        iv_source_unit = ls_request-unit_of_measure
        iv_base_unit   = <ls_stock>-base_unit ).
      IF ls_conversion-is_success = abap_false.
        APPEND VALUE #(
          request_id             = ls_request-request_id
          material               = ls_request-material
          plant                  = ls_request-plant
          storage_location       = ls_request-storage_location
          movement_type          = ls_request-movement_type
          cost_center            = ls_request-cost_center
          order_id               = ls_request-order_id
          wbs_element            = ls_request-wbs_element
          sales_order            = ls_request-sales_order
          sales_order_item       = ls_request-sales_order_item
          asset_number           = ls_request-asset_number
          asset_subnumber        = ls_request-asset_subnumber
          network_id             = ls_request-network_id
          network_activity       = ls_request-network_activity
          unit_of_measure        = ls_request-unit_of_measure
          requirement_date       = ls_request-requirement_date
          requested_qty          = ls_request-requested_qty
          source_requested_qty   = ls_request-requested_qty
          source_unit_of_measure = ls_request-unit_of_measure
          shortfall_qty          = ls_request-requested_qty
          status                 = gc_status_invalid
          decision_code          = gc_decision_conversion_failed
          posting_status         = gc_posting_not_required
          posting_message        = ls_conversion-message )
          TO rt_allocations.
        CONTINUE.
      ENDIF.
      ls_normalized_request-requested_qty = ls_conversion-quantity.
      ls_normalized_request-unit_of_measure = <ls_stock>-base_unit.

      READ TABLE lt_plant_balances ASSIGNING <ls_plant_balance>
        WITH TABLE KEY material = ls_normalized_request-material
                       plant = ls_normalized_request-plant
                       base_unit = ls_normalized_request-unit_of_measure.
      DATA(lv_available) = calculate_available(
        is_stock = <ls_stock>
        is_plant = <ls_plant_balance> ).
      DATA(ls_allocation) = create_allocation(
        is_request   = ls_normalized_request
        iv_available = lv_available ).
      ls_allocation-replaced_document_id = lv_replaced_document_id.
      ls_allocation-source_requested_qty = ls_request-requested_qty.
      ls_allocation-source_unit_of_measure = ls_request-unit_of_measure.
      APPEND ls_allocation TO rt_allocations.
      <ls_stock>-unrestricted_qty =
        <ls_stock>-unrestricted_qty - ls_allocation-allocated_qty.
      <ls_plant_balance>-unrestricted_qty =
        <ls_plant_balance>-unrestricted_qty - ls_allocation-allocated_qty.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_available.
    DATA(lv_plant_available) =
      is_plant-unrestricted_qty - is_plant-safety_stock_qty.
    rv_available = is_stock-unrestricted_qty.
    IF lv_plant_available < rv_available.
      rv_available = lv_plant_available.
    ENDIF.
    IF rv_available < 0.
      rv_available = 0.
    ENDIF.
  ENDMETHOD.

  METHOD create_allocation.
    rs_allocation-request_id = is_request-request_id.
    rs_allocation-material = is_request-material.
    rs_allocation-plant = is_request-plant.
    rs_allocation-storage_location = is_request-storage_location.
    rs_allocation-movement_type = is_request-movement_type.
    rs_allocation-cost_center = is_request-cost_center.
    rs_allocation-order_id = is_request-order_id.
    rs_allocation-wbs_element = is_request-wbs_element.
    rs_allocation-sales_order = is_request-sales_order.
    rs_allocation-sales_order_item = is_request-sales_order_item.
    rs_allocation-asset_number = is_request-asset_number.
    rs_allocation-asset_subnumber = is_request-asset_subnumber.
    rs_allocation-network_id = is_request-network_id.
    rs_allocation-network_activity = is_request-network_activity.
    rs_allocation-unit_of_measure = is_request-unit_of_measure.
    rs_allocation-requirement_date = is_request-requirement_date.
    rs_allocation-requested_qty = is_request-requested_qty.
    rs_allocation-minimum_fill_pct = is_request-minimum_fill_pct.
    rs_allocation-priority = is_request-priority.
    rs_allocation-allow_partial = is_request-allow_partial.
    DATA(lv_available_pct) =
      iv_available * 100 / is_request-requested_qty.

    IF iv_available >= is_request-requested_qty.
      rs_allocation-allocated_qty = is_request-requested_qty.
      rs_allocation-status = gc_status_allocated.
      rs_allocation-decision_code = gc_decision_fully_allocated.
      rs_allocation-posting_status = gc_posting_pending.
    ELSEIF is_request-allow_partial = abap_true
        AND iv_available > 0
        AND lv_available_pct >= is_request-minimum_fill_pct.
      rs_allocation-allocated_qty = iv_available.
      rs_allocation-status = gc_status_partial.
      rs_allocation-decision_code = gc_decision_partial.
      rs_allocation-posting_status = gc_posting_pending.
    ELSE.
      rs_allocation-status = gc_status_rejected.
      IF iv_available <= 0.
        rs_allocation-decision_code = gc_decision_no_available_stock.
      ELSEIF is_request-allow_partial = abap_false.
        rs_allocation-decision_code = gc_decision_partial_denied.
      ELSE.
        rs_allocation-decision_code = gc_decision_below_minimum_fill.
      ENDIF.
      rs_allocation-posting_status = gc_posting_not_required.
    ENDIF.

    rs_allocation-shortfall_qty =
      is_request-requested_qty - rs_allocation-allocated_qty.
  ENDMETHOD.

  METHOD get_account_error.
    CASE is_request-movement_type.
      WHEN '201' OR '251'.
        IF is_request-cost_center IS INITIAL.
          rv_message = |Movement type { is_request-movement_type } requires a cost center|.
        ENDIF.
      WHEN '221'.
        IF is_request-wbs_element IS INITIAL.
          rv_message = 'Movement type 221 requires a WBS element'.
        ENDIF.
      WHEN '231'.
        IF is_request-sales_order IS INITIAL.
          rv_message = 'Movement type 231 requires a sales order'.
        ELSEIF is_request-sales_order_item IS INITIAL.
          rv_message = 'Movement type 231 requires a sales order item'.
        ENDIF.
      WHEN '241'.
        IF is_request-asset_number IS INITIAL.
          rv_message = 'Movement type 241 requires an asset number'.
        ELSEIF is_request-asset_subnumber IS INITIAL.
          rv_message = 'Movement type 241 requires an asset subnumber'.
        ENDIF.
      WHEN '261'.
        IF is_request-order_id IS INITIAL.
          rv_message = 'Movement type 261 requires an order'.
        ENDIF.
      WHEN '281'.
        IF is_request-network_id IS INITIAL.
          rv_message = 'Movement type 281 requires a network'.
        ENDIF.
      WHEN OTHERS.
        rv_message = |Movement type { is_request-movement_type } is not supported|.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
