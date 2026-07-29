CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES ty_percentage TYPE p LENGTH 5 DECIMALS 2.
    TYPES:
      BEGIN OF ty_demand,
        request_id      TYPE string,
        demand_group    TYPE string,
        material        TYPE string,
        plant           TYPE string,
        requirement_date        TYPE d,
        priority                TYPE i,
        requested_qty           TYPE zcl_sap_uom_rules=>ty_quantity,
        requested_unit          TYPE string,
        base_unit               TYPE string,
        complete_delivery       TYPE abap_bool,
        minimum_shelf_life_days TYPE i,
      END OF ty_demand,
      ty_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY,
      BEGIN OF ty_allocation,
        run_id        TYPE string,
        request_id    TYPE string,
        demand_group  TYPE string,
        material      TYPE string,
        plant         TYPE string,
        batch         TYPE string,
        unit_of_measure TYPE string,
        allocated_qty TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty  TYPE zcl_sap_uom_rules=>ty_quantity,
      END OF ty_allocation,
      ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY,
      BEGIN OF ty_summary,
        run_id          TYPE string,
        request_id      TYPE string,
        demand_group    TYPE string,
        material        TYPE string,
        plant           TYPE string,
        unit_of_measure TYPE string,
        requested_qty   TYPE zcl_sap_uom_rules=>ty_quantity,
        allocated_qty   TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty    TYPE zcl_sap_uom_rules=>ty_quantity,
        status          TYPE string,
      END OF ty_summary,
      ty_summaries TYPE STANDARD TABLE OF ty_summary WITH EMPTY KEY,
      BEGIN OF ty_group_summary,
        run_id         TYPE string,
        demand_group   TYPE string,
        request_count  TYPE i,
        full_count     TYPE i,
        partial_count  TYPE i,
        shortage_count TYPE i,
      END OF ty_group_summary,
      ty_group_summaries TYPE STANDARD TABLE OF ty_group_summary
        WITH EMPTY KEY,
      BEGIN OF ty_strategy_override,
        material       TYPE string,
        batch_strategy TYPE string,
      END OF ty_strategy_override,
      ty_strategy_overrides TYPE STANDARD TABLE OF ty_strategy_override
        WITH EMPTY KEY,
      BEGIN OF ty_run_metrics,
        run_id              TYPE string,
        request_count       TYPE i,
        full_count          TYPE i,
        partial_count       TYPE i,
        shortage_count      TYPE i,
        served_count        TYPE i,
        allocation_line_count TYPE i,
        audit_event_count   TYPE i,
        stock_count         TYPE i,
        full_service_pct    TYPE ty_percentage,
        served_request_pct  TYPE ty_percentage,
      END OF ty_run_metrics,
      BEGIN OF ty_material_metric,
        material          TYPE string,
        plant             TYPE string,
        unit_of_measure   TYPE string,
        request_count     TYPE i,
        full_count        TYPE i,
        partial_count     TYPE i,
        shortage_count    TYPE i,
        requested_qty     TYPE zcl_sap_uom_rules=>ty_quantity,
        allocated_qty     TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty      TYPE zcl_sap_uom_rules=>ty_quantity,
        quantity_fill_pct TYPE ty_percentage,
      END OF ty_material_metric,
      ty_material_metrics TYPE STANDARD TABLE OF ty_material_metric
        WITH EMPTY KEY,
      BEGIN OF ty_audit_event,
        sequence        TYPE i,
        event_type      TYPE string,
        allocation_date TYPE d,
        run_id          TYPE string,
        request_id      TYPE string,
        demand_group    TYPE string,
        material        TYPE string,
        plant           TYPE string,
        batch           TYPE string,
        unit_of_measure TYPE string,
        requested_qty   TYPE zcl_sap_uom_rules=>ty_quantity,
        allocated_qty   TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty    TYPE zcl_sap_uom_rules=>ty_quantity,
        status          TYPE string,
        batch_strategy  TYPE string,
        demand_policy   TYPE string,
      END OF ty_audit_event,
      ty_audit_events TYPE STANDARD TABLE OF ty_audit_event WITH EMPTY KEY,
      BEGIN OF ty_result,
        run_id           TYPE string,
        allocations      TYPE ty_allocations,
        summaries        TYPE ty_summaries,
        group_summaries  TYPE ty_group_summaries,
        remaining_stocks TYPE zcl_sap_atp_rules=>ty_stocks,
        audit_events      TYPE ty_audit_events,
        batch_strategy    TYPE string,
        strategy_overrides TYPE ty_strategy_overrides,
        run_metrics       TYPE ty_run_metrics,
        material_metrics  TYPE ty_material_metrics,
        demand_policy     TYPE string,
      END OF ty_result,
      BEGIN OF ty_policy_simulation,
        demand_policy TYPE string,
        result        TYPE ty_result,
      END OF ty_policy_simulation,
      ty_policy_simulations TYPE STANDARD TABLE OF ty_policy_simulation
        WITH EMPTY KEY.

    CONSTANTS status_full TYPE string VALUE `FULL`.
    CONSTANTS status_partial TYPE string VALUE `PARTIAL`.
    CONSTANTS status_shortage TYPE string VALUE `SHORTAGE`.
    CONSTANTS event_request_evaluated TYPE string
      VALUE `REQUEST_EVALUATED`.
    CONSTANTS event_batch_allocated TYPE string
      VALUE `BATCH_ALLOCATED`.
    CONSTANTS event_shortage_recorded TYPE string
      VALUE `SHORTAGE_RECORDED`.
    CONSTANTS event_complete_rejected TYPE string
      VALUE `COMPLETE_REJECTED`.
    CONSTANTS event_request_completed TYPE string
      VALUE `REQUEST_COMPLETED`.
    CONSTANTS strategy_fefo TYPE string VALUE `FEFO`.
    CONSTANTS strategy_fifo TYPE string VALUE `FIFO`.
    CONSTANTS strategy_batch TYPE string VALUE `BATCH`.
    CONSTANTS demand_policy_priority_date TYPE string
      VALUE `PRIORITY_DATE`.
    CONSTANTS demand_policy_date_priority TYPE string
      VALUE `DATE_PRIORITY`.
    CONSTANTS demand_policy_request_id TYPE string
      VALUE `REQUEST_ID`.

    CLASS-METHODS allocate
      IMPORTING
        demands           TYPE ty_demands
        stocks            TYPE zcl_sap_atp_rules=>ty_stocks
        allocation_date   TYPE d
        conversions       TYPE zcl_sap_uom_rules=>ty_conversions OPTIONAL
        reservations      TYPE zcl_sap_atp_rules=>ty_reservations OPTIONAL
        batch_strategy    TYPE string OPTIONAL
        run_id            TYPE string OPTIONAL
        strategy_overrides TYPE ty_strategy_overrides OPTIONAL
        demand_policy     TYPE string OPTIONAL
      RETURNING
        VALUE(allocations) TYPE ty_allocations
      RAISING
        zcx_stock_allocation.

    CLASS-METHODS allocate_with_projection
      IMPORTING
        demands         TYPE ty_demands
        stocks          TYPE zcl_sap_atp_rules=>ty_stocks
        allocation_date TYPE d
        conversions     TYPE zcl_sap_uom_rules=>ty_conversions OPTIONAL
        reservations    TYPE zcl_sap_atp_rules=>ty_reservations OPTIONAL
        batch_strategy  TYPE string OPTIONAL
        run_id          TYPE string OPTIONAL
        strategy_overrides TYPE ty_strategy_overrides OPTIONAL
        demand_policy   TYPE string OPTIONAL
      RETURNING
        VALUE(result)   TYPE ty_result
      RAISING
        zcx_stock_allocation.

    CLASS-METHODS simulate_demand_policies
      IMPORTING
        demands         TYPE ty_demands
        stocks          TYPE zcl_sap_atp_rules=>ty_stocks
        allocation_date TYPE d
        conversions     TYPE zcl_sap_uom_rules=>ty_conversions OPTIONAL
        reservations    TYPE zcl_sap_atp_rules=>ty_reservations OPTIONAL
        batch_strategy  TYPE string OPTIONAL
        run_id          TYPE string OPTIONAL
        strategy_overrides TYPE ty_strategy_overrides OPTIONAL
      RETURNING
        VALUE(simulations) TYPE ty_policy_simulations
      RAISING
        zcx_stock_allocation.

  PRIVATE SECTION.
    CLASS-METHODS validate_inputs
      IMPORTING
        demands TYPE ty_demands
        stocks  TYPE zcl_sap_atp_rules=>ty_stocks
        conversions TYPE zcl_sap_uom_rules=>ty_conversions
        allocation_date TYPE d
        reservations TYPE zcl_sap_atp_rules=>ty_reservations
        batch_strategy TYPE string
        strategy_overrides TYPE ty_strategy_overrides
        demand_policy TYPE string
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS sort_stocks
      IMPORTING
        stocks         TYPE zcl_sap_atp_rules=>ty_stocks
        batch_strategy TYPE string
      RETURNING
        VALUE(result)  TYPE zcl_sap_atp_rules=>ty_stocks.
    CLASS-METHODS sort_demands
      IMPORTING
        demands       TYPE ty_demands
        demand_policy TYPE string
      RETURNING
        VALUE(result) TYPE ty_demands.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    DATA(result) = allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = allocation_date
      conversions = conversions
      reservations = reservations
      batch_strategy = batch_strategy
      run_id = run_id
      strategy_overrides = strategy_overrides
      demand_policy = demand_policy ).
    allocations = result-allocations.
  ENDMETHOD.

  METHOD simulate_demand_policies.
    DATA policies TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    policies = VALUE #(
      ( demand_policy_priority_date )
      ( demand_policy_date_priority )
      ( demand_policy_request_id ) ).

    LOOP AT policies INTO DATA(policy).
      DATA(policy_result) = allocate_with_projection(
        demands = demands
        stocks = stocks
        allocation_date = allocation_date
        conversions = conversions
        reservations = reservations
        batch_strategy = batch_strategy
        run_id = run_id
        strategy_overrides = strategy_overrides
        demand_policy = policy ).
      APPEND VALUE #(
        demand_policy = policy
        result = policy_result ) TO simulations.
    ENDLOOP.
  ENDMETHOD.

  METHOD allocate_with_projection.
    DATA sorted_demands TYPE ty_demands.
    DATA remaining_stocks TYPE zcl_sap_atp_rules=>ty_stocks.
    DATA remaining TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA available TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA allocated TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA total_available TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA minimum_expiry_date TYPE d.
    DATA base_unit TYPE string.
    DATA requested_unit TYPE string.
    DATA converted_demand TYPE zcl_sap_uom_rules=>ty_conversion_result.
    DATA allocated_total TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA fulfillment_status TYPE string.
    DATA reserved TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA event_sequence TYPE i.
    DATA effective_strategy TYPE string.
    DATA effective_group TYPE string.
    DATA demand_strategy TYPE string.
    DATA effective_demand_policy TYPE string.

    effective_strategy = batch_strategy.
    IF effective_strategy IS INITIAL.
      effective_strategy = strategy_fefo.
    ENDIF.
    effective_demand_policy = demand_policy.
    IF effective_demand_policy IS INITIAL.
      effective_demand_policy = demand_policy_priority_date.
    ENDIF.

    validate_inputs(
      demands = demands
      stocks = stocks
      conversions = conversions
      allocation_date = allocation_date
      reservations = reservations
      batch_strategy = effective_strategy
      strategy_overrides = strategy_overrides
      demand_policy = effective_demand_policy ).

    sorted_demands = sort_demands(
      demands = demands
      demand_policy = effective_demand_policy ).

    remaining_stocks = sort_stocks(
      stocks = stocks
      batch_strategy = effective_strategy ).
    result-batch_strategy = effective_strategy.
    result-run_id = run_id.
    result-strategy_overrides = strategy_overrides.
    result-run_metrics-run_id = run_id.
    result-demand_policy = effective_demand_policy.

    LOOP AT sorted_demands INTO DATA(demand).
      demand_strategy = effective_strategy.
      READ TABLE strategy_overrides INTO DATA(strategy_override)
        WITH KEY material = demand-material.
      IF sy-subrc = 0.
        demand_strategy = strategy_override-batch_strategy.
      ENDIF.
      remaining_stocks = sort_stocks(
        stocks = remaining_stocks
        batch_strategy = demand_strategy ).

      effective_group = demand-demand_group.
      IF effective_group IS INITIAL.
        effective_group = demand-request_id.
      ENDIF.
      base_unit = demand-base_unit.
      IF base_unit IS INITIAL.
        base_unit = demand-requested_unit.
      ENDIF.
      IF base_unit IS INITIAL.
        LOOP AT remaining_stocks INTO DATA(unit_candidate)
            WHERE material = demand-material
              AND plant = demand-plant.
          IF unit_candidate-unit_of_measure IS NOT INITIAL.
            base_unit = unit_candidate-unit_of_measure.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT remaining_stocks INTO unit_candidate
          WHERE material = demand-material
            AND plant = demand-plant.
        IF base_unit IS NOT INITIAL
            AND unit_candidate-unit_of_measure IS NOT INITIAL
            AND unit_candidate-unit_of_measure <> base_unit.
          RAISE EXCEPTION TYPE zcx_stock_allocation
            EXPORTING
              reason = zcx_stock_allocation=>invalid_stock_unit
              batch = unit_candidate-batch
              material = demand-material.
        ENDIF.
      ENDLOOP.

      requested_unit = demand-requested_unit.
      IF requested_unit IS INITIAL.
        requested_unit = base_unit.
      ENDIF.
      converted_demand = zcl_sap_uom_rules=>convert(
        material = demand-material
        quantity = demand-requested_qty
        source_unit = requested_unit
        target_unit = base_unit
        conversions = conversions ).
      IF converted_demand-found = abap_false.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_uom_conversion
            request_id = demand-request_id
            material = demand-material.
      ENDIF.
      remaining = converted_demand-quantity.
      minimum_expiry_date = demand-requirement_date.
      IF minimum_expiry_date IS INITIAL.
        minimum_expiry_date = allocation_date.
      ENDIF.
      minimum_expiry_date = minimum_expiry_date
        + demand-minimum_shelf_life_days.

      event_sequence = event_sequence + 1.
      APPEND VALUE #(
        run_id = run_id
        sequence = event_sequence
        event_type = event_request_evaluated
        allocation_date = allocation_date
        request_id = demand-request_id
        demand_group = effective_group
        material = demand-material
        plant = demand-plant
        unit_of_measure = base_unit
        requested_qty = converted_demand-quantity
        batch_strategy = demand_strategy
        demand_policy = effective_demand_policy
        ) TO result-audit_events.

      IF demand-complete_delivery = abap_true.
        CLEAR total_available.
        LOOP AT remaining_stocks INTO DATA(candidate)
            WHERE material = demand-material
              AND plant = demand-plant.
          reserved = zcl_sap_atp_rules=>active_reserved_quantity(
            stock = candidate
            reservations = reservations
            allocation_date = allocation_date ).
          total_available = total_available
            + zcl_sap_atp_rules=>available_quantity(
                stock = candidate
                allocation_date = allocation_date
                minimum_expiry_date = minimum_expiry_date
                reserved_qty = reserved ).
        ENDLOOP.

        IF total_available < remaining.
          APPEND VALUE #(
            run_id = run_id
            request_id = demand-request_id
            demand_group = effective_group
            material = demand-material
            plant = demand-plant
            unit_of_measure = base_unit
            shortage_qty = remaining ) TO result-allocations.
          APPEND VALUE #(
            run_id = run_id
            request_id = demand-request_id
            demand_group = effective_group
            material = demand-material
            plant = demand-plant
            unit_of_measure = base_unit
            requested_qty = converted_demand-quantity
            shortage_qty = remaining
            status = status_shortage ) TO result-summaries.
          event_sequence = event_sequence + 1.
          APPEND VALUE #(
            run_id = run_id
            sequence = event_sequence
            event_type = event_complete_rejected
            allocation_date = allocation_date
            request_id = demand-request_id
            demand_group = effective_group
            material = demand-material
            plant = demand-plant
            unit_of_measure = base_unit
            requested_qty = converted_demand-quantity
            shortage_qty = remaining
            status = status_shortage
            batch_strategy = demand_strategy
            demand_policy = effective_demand_policy ) TO result-audit_events.
          event_sequence = event_sequence + 1.
          APPEND VALUE #(
            run_id = run_id
            sequence = event_sequence
            event_type = event_request_completed
            allocation_date = allocation_date
            request_id = demand-request_id
            demand_group = effective_group
            material = demand-material
            plant = demand-plant
            unit_of_measure = base_unit
            requested_qty = converted_demand-quantity
            shortage_qty = remaining
            status = status_shortage
            batch_strategy = demand_strategy
            demand_policy = effective_demand_policy ) TO result-audit_events.
          CONTINUE.
        ENDIF.
      ENDIF.

      LOOP AT remaining_stocks ASSIGNING FIELD-SYMBOL(<stock>)
          WHERE material = demand-material
            AND plant = demand-plant.
        IF remaining <= 0.
          EXIT.
        ENDIF.

        reserved = zcl_sap_atp_rules=>active_reserved_quantity(
          stock = <stock>
          reservations = reservations
          allocation_date = allocation_date ).
        available = zcl_sap_atp_rules=>available_quantity(
          stock = <stock>
          allocation_date = allocation_date
          minimum_expiry_date = minimum_expiry_date
          reserved_qty = reserved ).
        IF available <= 0.
          CONTINUE.
        ENDIF.

        allocated = available.
        IF allocated > remaining.
          allocated = remaining.
        ENDIF.

        APPEND VALUE #(
          run_id = run_id
          request_id = demand-request_id
          demand_group = effective_group
          material = demand-material
          plant = demand-plant
          batch = <stock>-batch
          unit_of_measure = base_unit
          allocated_qty = allocated ) TO result-allocations.

        event_sequence = event_sequence + 1.
        APPEND VALUE #(
          run_id = run_id
          sequence = event_sequence
          event_type = event_batch_allocated
          allocation_date = allocation_date
          request_id = demand-request_id
          demand_group = effective_group
          material = demand-material
          plant = demand-plant
          batch = <stock>-batch
          unit_of_measure = base_unit
          allocated_qty = allocated
          batch_strategy = demand_strategy
          demand_policy = effective_demand_policy ) TO result-audit_events.

        <stock>-unrestricted_qty = <stock>-unrestricted_qty - allocated.
        remaining = remaining - allocated.
      ENDLOOP.

      IF remaining > 0.
        APPEND VALUE #(
          run_id = run_id
          request_id = demand-request_id
          demand_group = effective_group
          material = demand-material
          plant = demand-plant
          unit_of_measure = base_unit
          shortage_qty = remaining ) TO result-allocations.
        event_sequence = event_sequence + 1.
        APPEND VALUE #(
          run_id = run_id
          sequence = event_sequence
          event_type = event_shortage_recorded
          allocation_date = allocation_date
          request_id = demand-request_id
          demand_group = effective_group
          material = demand-material
          plant = demand-plant
          unit_of_measure = base_unit
          shortage_qty = remaining
          batch_strategy = demand_strategy
          demand_policy = effective_demand_policy ) TO result-audit_events.
      ENDIF.

      allocated_total = converted_demand-quantity - remaining.
      IF remaining = 0.
        fulfillment_status = status_full.
      ELSEIF allocated_total > 0.
        fulfillment_status = status_partial.
      ELSE.
        fulfillment_status = status_shortage.
      ENDIF.
      APPEND VALUE #(
        run_id = run_id
        request_id = demand-request_id
        demand_group = effective_group
        material = demand-material
        plant = demand-plant
        unit_of_measure = base_unit
        requested_qty = converted_demand-quantity
        allocated_qty = allocated_total
        shortage_qty = remaining
        status = fulfillment_status ) TO result-summaries.
      event_sequence = event_sequence + 1.
      APPEND VALUE #(
        run_id = run_id
        sequence = event_sequence
        event_type = event_request_completed
        allocation_date = allocation_date
        request_id = demand-request_id
        demand_group = effective_group
        material = demand-material
        plant = demand-plant
        unit_of_measure = base_unit
        requested_qty = converted_demand-quantity
        allocated_qty = allocated_total
        shortage_qty = remaining
        status = fulfillment_status
        batch_strategy = demand_strategy
        demand_policy = effective_demand_policy ) TO result-audit_events.
    ENDLOOP.

    LOOP AT result-summaries INTO DATA(summary).
      READ TABLE result-group_summaries ASSIGNING FIELD-SYMBOL(<group_summary>)
        WITH KEY run_id = summary-run_id
                 demand_group = summary-demand_group.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          run_id = summary-run_id
          demand_group = summary-demand_group ) TO result-group_summaries
          ASSIGNING <group_summary>.
      ENDIF.
      <group_summary>-request_count = <group_summary>-request_count + 1.

      READ TABLE result-material_metrics
        ASSIGNING FIELD-SYMBOL(<material_metric>)
        WITH KEY material = summary-material
                 plant = summary-plant
                 unit_of_measure = summary-unit_of_measure.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          material = summary-material
          plant = summary-plant
          unit_of_measure = summary-unit_of_measure
          ) TO result-material_metrics ASSIGNING <material_metric>.
      ENDIF.
      <material_metric>-request_count = <material_metric>-request_count + 1.
      <material_metric>-requested_qty = <material_metric>-requested_qty
        + summary-requested_qty.
      <material_metric>-allocated_qty = <material_metric>-allocated_qty
        + summary-allocated_qty.
      <material_metric>-shortage_qty = <material_metric>-shortage_qty
        + summary-shortage_qty.
      result-run_metrics-request_count = result-run_metrics-request_count + 1.

      CASE summary-status.
        WHEN status_full.
          <group_summary>-full_count = <group_summary>-full_count + 1.
          <material_metric>-full_count = <material_metric>-full_count + 1.
          result-run_metrics-full_count = result-run_metrics-full_count + 1.
        WHEN status_partial.
          <group_summary>-partial_count = <group_summary>-partial_count + 1.
          <material_metric>-partial_count = <material_metric>-partial_count + 1.
          result-run_metrics-partial_count
            = result-run_metrics-partial_count + 1.
        WHEN status_shortage.
          <group_summary>-shortage_count = <group_summary>-shortage_count + 1.
          <material_metric>-shortage_count
            = <material_metric>-shortage_count + 1.
          result-run_metrics-shortage_count
            = result-run_metrics-shortage_count + 1.
      ENDCASE.
    ENDLOOP.

    result-remaining_stocks = sort_stocks(
      stocks = remaining_stocks
      batch_strategy = effective_strategy ).
    result-run_metrics-served_count = result-run_metrics-full_count
      + result-run_metrics-partial_count.
    result-run_metrics-allocation_line_count = lines( result-allocations ).
    result-run_metrics-audit_event_count = lines( result-audit_events ).
    result-run_metrics-stock_count = lines( result-remaining_stocks ).
    IF result-run_metrics-request_count > 0.
      result-run_metrics-full_service_pct
        = result-run_metrics-full_count * 100
          / result-run_metrics-request_count.
      result-run_metrics-served_request_pct
        = result-run_metrics-served_count * 100
          / result-run_metrics-request_count.
    ENDIF.

    LOOP AT result-material_metrics ASSIGNING <material_metric>.
      IF <material_metric>-requested_qty > 0.
        <material_metric>-quantity_fill_pct
          = <material_metric>-allocated_qty * 100
            / <material_metric>-requested_qty.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_inputs.
    TYPES ty_keys TYPE HASHED TABLE OF string
      WITH UNIQUE KEY table_line.
    DATA request_ids TYPE ty_keys.
    DATA reservation_ids TYPE ty_keys.
    DATA stock_keys TYPE ty_keys.
    DATA conversion_keys TYPE ty_keys.
    DATA strategy_materials TYPE ty_keys.
    DATA stock_key TYPE string.
    DATA conversion_key TYPE string.
    DATA first_unit TYPE string.
    DATA second_unit TYPE string.

    IF allocation_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_allocation
        EXPORTING
          reason = zcx_stock_allocation=>missing_allocation_date.
    ENDIF.
    IF batch_strategy <> strategy_fefo
        AND batch_strategy <> strategy_fifo
        AND batch_strategy <> strategy_batch.
      RAISE EXCEPTION TYPE zcx_stock_allocation
        EXPORTING
          reason = zcx_stock_allocation=>invalid_batch_strategy.
    ENDIF.
    IF demand_policy <> demand_policy_priority_date
        AND demand_policy <> demand_policy_date_priority
        AND demand_policy <> demand_policy_request_id.
      RAISE EXCEPTION TYPE zcx_stock_allocation
        EXPORTING
          reason = zcx_stock_allocation=>invalid_demand_policy.
    ENDIF.

    LOOP AT strategy_overrides INTO DATA(strategy_override).
      IF strategy_override-material IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_material.
      ENDIF.
      IF strategy_override-batch_strategy <> strategy_fefo
          AND strategy_override-batch_strategy <> strategy_fifo
          AND strategy_override-batch_strategy <> strategy_batch.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_batch_strategy
            material = strategy_override-material.
      ENDIF.
      IF line_exists(
          strategy_materials[ table_line = strategy_override-material ] ).
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>duplicate_strategy_override
            material = strategy_override-material.
      ENDIF.
      INSERT strategy_override-material INTO TABLE strategy_materials.
    ENDLOOP.

    LOOP AT demands INTO DATA(demand).
      IF demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_request_id.
      ENDIF.
      IF demand-material IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_material
            request_id = demand-request_id.
      ENDIF.
      IF demand-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_plant
            request_id = demand-request_id
            material = demand-material.
      ENDIF.
      IF line_exists( request_ids[ table_line = demand-request_id ] ).
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>duplicate_request_id
            request_id = demand-request_id.
      ENDIF.
      INSERT demand-request_id INTO TABLE request_ids.

      IF demand-requested_qty <= 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_demand_quantity
            request_id = demand-request_id.
      ENDIF.
      IF demand-minimum_shelf_life_days < 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_shelf_life
            request_id = demand-request_id.
      ENDIF.
    ENDLOOP.

    LOOP AT stocks INTO DATA(stock).
      IF stock-material IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_material
            batch = stock-batch.
      ENDIF.
      IF stock-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_plant
            batch = stock-batch
            material = stock-material.
      ENDIF.
      stock_key = stock-material && `|` && stock-plant
        && `|` && stock-batch.
      IF line_exists( stock_keys[ table_line = stock_key ] ).
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>duplicate_stock_key
            batch = stock-batch
            material = stock-material
            plant = stock-plant.
      ENDIF.
      INSERT stock_key INTO TABLE stock_keys.

      IF stock-unrestricted_qty < 0
          OR stock-quality_qty < 0
          OR stock-blocked_qty < 0
          OR stock-safety_stock < 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_stock_quantity
            batch = stock-batch.
      ENDIF.
    ENDLOOP.

    LOOP AT conversions INTO DATA(conversion).
      IF conversion-material IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_material
            source_unit = conversion-source_unit
            target_unit = conversion-target_unit.
      ENDIF.
      IF conversion-source_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_source_unit
            material = conversion-material
            target_unit = conversion-target_unit.
      ENDIF.
      IF conversion-target_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_target_unit
            material = conversion-material
            source_unit = conversion-source_unit.
      ENDIF.
      IF conversion-numerator <= 0
          OR conversion-denominator <= 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_uom_conversion
            material = conversion-material.
      ENDIF.

      first_unit = conversion-source_unit.
      second_unit = conversion-target_unit.
      IF second_unit < first_unit.
        first_unit = conversion-target_unit.
        second_unit = conversion-source_unit.
      ENDIF.
      conversion_key = conversion-material && `|` && first_unit
        && `|` && second_unit.
      IF line_exists( conversion_keys[ table_line = conversion_key ] ).
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>duplicate_conversion_key
            material = conversion-material
            source_unit = conversion-source_unit
            target_unit = conversion-target_unit.
      ENDIF.
      INSERT conversion_key INTO TABLE conversion_keys.
    ENDLOOP.

    LOOP AT reservations INTO DATA(reservation).
      IF reservation-reservation_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_reservation_id
            material = reservation-material
            plant = reservation-plant
            batch = reservation-batch.
      ENDIF.
      IF line_exists(
          reservation_ids[ table_line = reservation-reservation_id ] ).
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>duplicate_reservation_id
            reservation_id = reservation-reservation_id
            material = reservation-material
            plant = reservation-plant
            batch = reservation-batch.
      ENDIF.
      INSERT reservation-reservation_id INTO TABLE reservation_ids.
      IF reservation-material IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_material
            reservation_id = reservation-reservation_id
            plant = reservation-plant
            batch = reservation-batch.
      ENDIF.
      IF reservation-plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_plant
            reservation_id = reservation-reservation_id
            material = reservation-material
            batch = reservation-batch.
      ENDIF.
      IF reservation-reserved_qty <= 0.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_reservation_qty
            reservation_id = reservation-reservation_id
            material = reservation-material
            plant = reservation-plant
            batch = reservation-batch.
      ENDIF.
      IF reservation-valid_from IS NOT INITIAL
          AND reservation-valid_to IS NOT INITIAL
          AND reservation-valid_from > reservation-valid_to.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>invalid_reservation_window
            reservation_id = reservation-reservation_id
            material = reservation-material
            plant = reservation-plant
            batch = reservation-batch.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD sort_stocks.
    DATA dated_stocks TYPE zcl_sap_atp_rules=>ty_stocks.
    DATA undated_stocks TYPE zcl_sap_atp_rules=>ty_stocks.

    CASE batch_strategy.
      WHEN strategy_fefo.
        LOOP AT stocks INTO DATA(stock).
          IF stock-expiry_date IS INITIAL.
            APPEND stock TO undated_stocks.
          ELSE.
            APPEND stock TO dated_stocks.
          ENDIF.
        ENDLOOP.
        SORT dated_stocks BY material ASCENDING plant ASCENDING
                             expiry_date ASCENDING batch ASCENDING.
        SORT undated_stocks BY material ASCENDING plant ASCENDING
                               batch ASCENDING.
      WHEN strategy_fifo.
        LOOP AT stocks INTO stock.
          IF stock-receipt_date IS INITIAL.
            APPEND stock TO undated_stocks.
          ELSE.
            APPEND stock TO dated_stocks.
          ENDIF.
        ENDLOOP.
        SORT dated_stocks BY material ASCENDING plant ASCENDING
                             receipt_date ASCENDING batch ASCENDING.
        SORT undated_stocks BY material ASCENDING plant ASCENDING
                               batch ASCENDING.
      WHEN strategy_batch.
        result = stocks.
        SORT result BY material ASCENDING plant ASCENDING batch ASCENDING.
        RETURN.
    ENDCASE.

    result = dated_stocks.
    APPEND LINES OF undated_stocks TO result.
  ENDMETHOD.

  METHOD sort_demands.
    result = demands.
    CASE demand_policy.
      WHEN demand_policy_priority_date.
        SORT result BY priority ASCENDING
                       requirement_date ASCENDING
                       request_id ASCENDING.
      WHEN demand_policy_date_priority.
        SORT result BY requirement_date ASCENDING
                       priority ASCENDING
                       request_id ASCENDING.
      WHEN demand_policy_request_id.
        SORT result BY request_id ASCENDING.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
