CLASS zcl_sap_stock_facade DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_requirement,
        vbeln                   TYPE string,
        posnr                   TYPE string,
        group_id                TYPE string,
        matnr                   TYPE string,
        werks                   TYPE string,
        bdter                   TYPE d,
        priority                TYPE i,
        kwmeng                  TYPE zcl_sap_uom_rules=>ty_quantity,
        vrkme                   TYPE string,
        meins                   TYPE string,
        complete_delivery       TYPE abap_bool,
        min_shelf_life_days     TYPE i,
      END OF ty_requirement,
      ty_requirements TYPE STANDARD TABLE OF ty_requirement WITH EMPTY KEY,
      BEGIN OF ty_stock,
        matnr TYPE string,
        werks TYPE string,
        charg TYPE string,
        meins TYPE string,
        vfdat TYPE d,
        budat TYPE d,
        labst TYPE zcl_sap_uom_rules=>ty_quantity,
        insme TYPE zcl_sap_uom_rules=>ty_quantity,
        speme TYPE zcl_sap_uom_rules=>ty_quantity,
        eisbe TYPE zcl_sap_uom_rules=>ty_quantity,
      END OF ty_stock,
      ty_stocks TYPE STANDARD TABLE OF ty_stock WITH EMPTY KEY,
      BEGIN OF ty_uom_conversion,
        matnr TYPE string,
        meinh TYPE string,
        meins TYPE string,
        umrez TYPE zcl_sap_uom_rules=>ty_quantity,
        umren TYPE zcl_sap_uom_rules=>ty_quantity,
      END OF ty_uom_conversion,
      ty_uom_conversions TYPE STANDARD TABLE OF ty_uom_conversion
        WITH EMPTY KEY,
      BEGIN OF ty_reservation,
        rsnum      TYPE string,
        rspos      TYPE string,
        matnr      TYPE string,
        werks      TYPE string,
        charg      TYPE string,
        bdmng      TYPE zcl_sap_uom_rules=>ty_quantity,
        valid_from TYPE d,
        valid_to   TYPE d,
      END OF ty_reservation,
      ty_reservations TYPE STANDARD TABLE OF ty_reservation WITH EMPTY KEY,
      BEGIN OF ty_strategy_override,
        matnr          TYPE string,
        batch_strategy TYPE string,
      END OF ty_strategy_override,
      ty_strategy_overrides TYPE STANDARD TABLE OF ty_strategy_override
        WITH EMPTY KEY,
      BEGIN OF ty_run_metrics,
        run_id                TYPE string,
        request_count         TYPE i,
        full_count            TYPE i,
        partial_count         TYPE i,
        shortage_count        TYPE i,
        served_count          TYPE i,
        allocation_line_count TYPE i,
        audit_event_count     TYPE i,
        stock_count           TYPE i,
        full_service_pct      TYPE zcl_stock_allocator=>ty_percentage,
        served_request_pct    TYPE zcl_stock_allocator=>ty_percentage,
      END OF ty_run_metrics,
      BEGIN OF ty_material_metric,
        matnr             TYPE string,
        werks             TYPE string,
        meins             TYPE string,
        request_count     TYPE i,
        full_count        TYPE i,
        partial_count     TYPE i,
        shortage_count    TYPE i,
        requested_qty     TYPE zcl_sap_uom_rules=>ty_quantity,
        allocated_qty     TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty      TYPE zcl_sap_uom_rules=>ty_quantity,
        quantity_fill_pct TYPE zcl_stock_allocator=>ty_percentage,
      END OF ty_material_metric,
      ty_material_metrics TYPE STANDARD TABLE OF ty_material_metric
        WITH EMPTY KEY,
      BEGIN OF ty_allocation,
        run_id        TYPE string,
        vbeln         TYPE string,
        posnr         TYPE string,
        group_id      TYPE string,
        matnr         TYPE string,
        werks         TYPE string,
        charg         TYPE string,
        meins         TYPE string,
        allocated_qty TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty  TYPE zcl_sap_uom_rules=>ty_quantity,
      END OF ty_allocation,
      ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY,
      BEGIN OF ty_summary,
        run_id        TYPE string,
        vbeln         TYPE string,
        posnr         TYPE string,
        group_id      TYPE string,
        matnr         TYPE string,
        werks         TYPE string,
        meins         TYPE string,
        requested_qty TYPE zcl_sap_uom_rules=>ty_quantity,
        allocated_qty TYPE zcl_sap_uom_rules=>ty_quantity,
        shortage_qty  TYPE zcl_sap_uom_rules=>ty_quantity,
        status        TYPE string,
      END OF ty_summary,
      ty_summaries TYPE STANDARD TABLE OF ty_summary WITH EMPTY KEY,
      BEGIN OF ty_group_summary,
        run_id         TYPE string,
        group_id       TYPE string,
        request_count  TYPE i,
        full_count     TYPE i,
        partial_count  TYPE i,
        shortage_count TYPE i,
      END OF ty_group_summary,
      ty_group_summaries TYPE STANDARD TABLE OF ty_group_summary
        WITH EMPTY KEY,
      BEGIN OF ty_audit_event,
        sequence        TYPE i,
        event_type      TYPE string,
        allocation_date TYPE d,
        run_id          TYPE string,
        vbeln           TYPE string,
        posnr           TYPE string,
        group_id        TYPE string,
        matnr           TYPE string,
        werks           TYPE string,
        charg           TYPE string,
        meins           TYPE string,
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
        remaining_stocks TYPE ty_stocks,
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

    CLASS-METHODS allocate
      IMPORTING
        requirements    TYPE ty_requirements
        stocks          TYPE ty_stocks
        allocation_date TYPE d
        conversions     TYPE ty_uom_conversions OPTIONAL
        reservations    TYPE ty_reservations OPTIONAL
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
        requirements    TYPE ty_requirements
        stocks          TYPE ty_stocks
        allocation_date TYPE d
        conversions     TYPE ty_uom_conversions OPTIONAL
        reservations    TYPE ty_reservations OPTIONAL
        batch_strategy  TYPE string OPTIONAL
        run_id          TYPE string OPTIONAL
        strategy_overrides TYPE ty_strategy_overrides OPTIONAL
      RETURNING
        VALUE(simulations) TYPE ty_policy_simulations
      RAISING
        zcx_stock_allocation.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_request_key,
        request_id TYPE string,
        vbeln      TYPE string,
        posnr      TYPE string,
      END OF ty_request_key,
      ty_request_keys TYPE STANDARD TABLE OF ty_request_key WITH EMPTY KEY,
      BEGIN OF ty_requirement_mapping,
        demands TYPE zcl_stock_allocator=>ty_demands,
        keys    TYPE ty_request_keys,
      END OF ty_requirement_mapping.

    CLASS-METHODS map_requirements
      IMPORTING
        requirements  TYPE ty_requirements
      RETURNING
        VALUE(result) TYPE ty_requirement_mapping
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS map_stocks
      IMPORTING
        stocks        TYPE ty_stocks
      RETURNING
        VALUE(result) TYPE zcl_sap_atp_rules=>ty_stocks.
    CLASS-METHODS map_conversions
      IMPORTING
        conversions  TYPE ty_uom_conversions
      RETURNING
        VALUE(result) TYPE zcl_sap_uom_rules=>ty_conversions.
    CLASS-METHODS map_reservations
      IMPORTING
        reservations  TYPE ty_reservations
      RETURNING
        VALUE(result) TYPE zcl_sap_atp_rules=>ty_reservations
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS map_strategies
      IMPORTING
        strategy_overrides TYPE ty_strategy_overrides
      RETURNING
        VALUE(result) TYPE zcl_stock_allocator=>ty_strategy_overrides.
    CLASS-METHODS map_domain_result
      IMPORTING
        domain_result TYPE zcl_stock_allocator=>ty_result
        keys          TYPE ty_request_keys
      RETURNING
        VALUE(result) TYPE ty_result.
ENDCLASS.

CLASS zcl_sap_stock_facade IMPLEMENTATION.
  METHOD allocate.
    DATA(requirement_mapping) = map_requirements( requirements ).
    DATA(domain_stocks) = map_stocks( stocks ).
    DATA(domain_conversions) = map_conversions( conversions ).
    DATA(domain_reservations) = map_reservations( reservations ).
    DATA(domain_strategies) = map_strategies( strategy_overrides ).

    DATA(domain_result) = zcl_stock_allocator=>allocate_with_projection(
      demands = requirement_mapping-demands
      stocks = domain_stocks
      allocation_date = allocation_date
      conversions = domain_conversions
      reservations = domain_reservations
      batch_strategy = batch_strategy
      run_id = run_id
      strategy_overrides = domain_strategies
      demand_policy = demand_policy ).

    result = map_domain_result(
      domain_result = domain_result
      keys = requirement_mapping-keys ).
  ENDMETHOD.

  METHOD simulate_demand_policies.
    DATA(requirement_mapping) = map_requirements( requirements ).
    DATA(domain_simulations) =
      zcl_stock_allocator=>simulate_demand_policies(
        demands = requirement_mapping-demands
        stocks = map_stocks( stocks )
        allocation_date = allocation_date
        conversions = map_conversions( conversions )
        reservations = map_reservations( reservations )
        batch_strategy = batch_strategy
        run_id = run_id
        strategy_overrides = map_strategies( strategy_overrides ) ).

    LOOP AT domain_simulations INTO DATA(domain_simulation).
      APPEND VALUE #(
        demand_policy = domain_simulation-demand_policy
        result = map_domain_result(
          domain_result = domain_simulation-result
          keys = requirement_mapping-keys ) ) TO simulations.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_requirements.
    DATA request_id TYPE string.

    LOOP AT requirements INTO DATA(requirement).
      IF requirement-vbeln IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_sales_document
            material = requirement-matnr.
      ENDIF.
      IF requirement-posnr IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_sales_item
            request_id = requirement-vbeln
            material = requirement-matnr.
      ENDIF.

      request_id = requirement-vbeln && `:` && requirement-posnr.
      APPEND VALUE #(
        request_id = request_id
        demand_group = requirement-group_id
        material = requirement-matnr
        plant = requirement-werks
        requirement_date = requirement-bdter
        priority = requirement-priority
        requested_qty = requirement-kwmeng
        requested_unit = requirement-vrkme
        base_unit = requirement-meins
        complete_delivery = requirement-complete_delivery
        minimum_shelf_life_days = requirement-min_shelf_life_days
        ) TO result-demands.
      APPEND VALUE #(
        request_id = request_id
        vbeln = requirement-vbeln
        posnr = requirement-posnr ) TO result-keys.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_stocks.
    LOOP AT stocks INTO DATA(stock).
      APPEND VALUE #(
        material = stock-matnr
        plant = stock-werks
        batch = stock-charg
        unit_of_measure = stock-meins
        expiry_date = stock-vfdat
        receipt_date = stock-budat
        unrestricted_qty = stock-labst
        quality_qty = stock-insme
        blocked_qty = stock-speme
        safety_stock = stock-eisbe ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_conversions.
    LOOP AT conversions INTO DATA(conversion).
      APPEND VALUE #(
        material = conversion-matnr
        source_unit = conversion-meinh
        target_unit = conversion-meins
        numerator = conversion-umrez
        denominator = conversion-umren ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_reservations.
    LOOP AT reservations INTO DATA(reservation).
      IF reservation-rsnum IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_reservation_doc
            material = reservation-matnr
            plant = reservation-werks
            batch = reservation-charg.
      ENDIF.
      IF reservation-rspos IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_allocation
          EXPORTING
            reason = zcx_stock_allocation=>missing_reservation_item
            reservation_id = reservation-rsnum
            material = reservation-matnr
            plant = reservation-werks
            batch = reservation-charg.
      ENDIF.

      APPEND VALUE #(
        reservation_id = reservation-rsnum && `:` && reservation-rspos
        material = reservation-matnr
        plant = reservation-werks
        batch = reservation-charg
        reserved_qty = reservation-bdmng
        valid_from = reservation-valid_from
        valid_to = reservation-valid_to ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_strategies.
    LOOP AT strategy_overrides INTO DATA(strategy_override).
      APPEND VALUE #(
        material = strategy_override-matnr
        batch_strategy = strategy_override-batch_strategy ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_domain_result.
    result-batch_strategy = domain_result-batch_strategy.
    result-run_id = domain_result-run_id.
    result-demand_policy = domain_result-demand_policy.
    LOOP AT domain_result-strategy_overrides INTO DATA(strategy_override).
      APPEND VALUE #(
        matnr = strategy_override-material
        batch_strategy = strategy_override-batch_strategy
        ) TO result-strategy_overrides.
    ENDLOOP.

    result-run_metrics = CORRESPONDING #( domain_result-run_metrics ).
    LOOP AT domain_result-material_metrics INTO DATA(material_metric).
      APPEND VALUE #(
        matnr = material_metric-material
        werks = material_metric-plant
        meins = material_metric-unit_of_measure
        request_count = material_metric-request_count
        full_count = material_metric-full_count
        partial_count = material_metric-partial_count
        shortage_count = material_metric-shortage_count
        requested_qty = material_metric-requested_qty
        allocated_qty = material_metric-allocated_qty
        shortage_qty = material_metric-shortage_qty
        quantity_fill_pct = material_metric-quantity_fill_pct
        ) TO result-material_metrics.
    ENDLOOP.

    LOOP AT domain_result-allocations INTO DATA(allocation).
      READ TABLE keys INTO DATA(key)
        WITH KEY request_id = allocation-request_id.
      APPEND VALUE #(
        run_id = allocation-run_id
        vbeln = key-vbeln
        posnr = key-posnr
        group_id = allocation-demand_group
        matnr = allocation-material
        werks = allocation-plant
        charg = allocation-batch
        meins = allocation-unit_of_measure
        allocated_qty = allocation-allocated_qty
        shortage_qty = allocation-shortage_qty ) TO result-allocations.
    ENDLOOP.

    LOOP AT domain_result-summaries INTO DATA(summary).
      READ TABLE keys INTO key
        WITH KEY request_id = summary-request_id.
      APPEND VALUE #(
        run_id = summary-run_id
        vbeln = key-vbeln
        posnr = key-posnr
        group_id = summary-demand_group
        matnr = summary-material
        werks = summary-plant
        meins = summary-unit_of_measure
        requested_qty = summary-requested_qty
        allocated_qty = summary-allocated_qty
        shortage_qty = summary-shortage_qty
        status = summary-status ) TO result-summaries.
    ENDLOOP.

    LOOP AT domain_result-group_summaries INTO DATA(group_summary).
      APPEND VALUE #(
        run_id = group_summary-run_id
        group_id = group_summary-demand_group
        request_count = group_summary-request_count
        full_count = group_summary-full_count
        partial_count = group_summary-partial_count
        shortage_count = group_summary-shortage_count
        ) TO result-group_summaries.
    ENDLOOP.

    LOOP AT domain_result-remaining_stocks INTO DATA(stock).
      APPEND VALUE #(
        matnr = stock-material
        werks = stock-plant
        charg = stock-batch
        meins = stock-unit_of_measure
        vfdat = stock-expiry_date
        budat = stock-receipt_date
        labst = stock-unrestricted_qty
        insme = stock-quality_qty
        speme = stock-blocked_qty
        eisbe = stock-safety_stock ) TO result-remaining_stocks.
    ENDLOOP.

    LOOP AT domain_result-audit_events INTO DATA(event).
      READ TABLE keys INTO key
        WITH KEY request_id = event-request_id.
      APPEND VALUE #(
        sequence = event-sequence
        event_type = event-event_type
        allocation_date = event-allocation_date
        run_id = event-run_id
        vbeln = key-vbeln
        posnr = key-posnr
        group_id = event-demand_group
        matnr = event-material
        werks = event-plant
        charg = event-batch
        meins = event-unit_of_measure
        requested_qty = event-requested_qty
        allocated_qty = event-allocated_qty
        shortage_qty = event-shortage_qty
        status = event-status
        batch_strategy = event-batch_strategy
        demand_policy = event-demand_policy ) TO result-audit_events.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
