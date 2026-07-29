CLASS ltcl_stock_allocator DEFINITION FINAL FOR TESTING
    RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS allocates_by_priority FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS consumes_earliest_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS excludes_unavailable_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_incomplete_delivery FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS completes_from_many_batches FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_demand FOR TESTING.
    METHODS rejects_invalid_stock FOR TESTING.
    METHODS respects_minimum_shelf_life FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS shelf_life_for_complete FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_shelf_life FOR TESTING.
    METHODS converts_demand_to_base FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS converts_using_inverse FOR TESTING.
    METHODS rejects_missing_conversion FOR TESTING.
    METHODS rejects_stock_unit_mismatch FOR TESTING.
    METHODS rejects_invalid_conversion FOR TESTING.
    METHODS summarizes_request_outcomes FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS projects_remaining_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_request FOR TESTING.
    METHODS rejects_missing_request_id FOR TESTING.
    METHODS rejects_missing_demand_mat FOR TESTING.
    METHODS rejects_missing_demand_plant FOR TESTING.
    METHODS rejects_missing_stock_material FOR TESTING.
    METHODS rejects_missing_stock_plant FOR TESTING.
    METHODS rejects_missing_alloc_date FOR TESTING.
    METHODS rejects_duplicate_stock FOR TESTING.
    METHODS rejects_duplicate_conversion FOR TESTING.
    METHODS rejects_inverse_conversion FOR TESTING.
    METHODS rejects_missing_source_unit FOR TESTING.
    METHODS rejects_missing_target_unit FOR TESTING.
    METHODS rejects_missing_conv_mat FOR TESTING.
    METHODS allows_scoped_keys FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS honors_active_reservation FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS ignores_inactive_reservations FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS reservation_for_complete FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_reservation FOR TESTING.
    METHODS rejects_bad_reservation_qty FOR TESTING.
    METHODS rejects_bad_reservation_window FOR TESTING.
    METHODS rejects_missing_reservation_id FOR TESTING.
    METHODS rejects_missing_res_mat FOR TESTING.
    METHODS rejects_missing_res_plant FOR TESTING.
    METHODS emits_partial_audit FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS audits_complete_rejection FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS fefo_puts_unknown_last FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS selects_fifo_batch FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS selects_batch_code FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_strategy FOR TESTING.
    METHODS groups_request_outcomes FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS defaults_request_group FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS overrides_material_strategy FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_duplicate_override FOR TESTING.
    METHODS rejects_override_no_material FOR TESTING.
    METHODS rejects_invalid_override FOR TESTING.
    METHODS calculates_service_metrics FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS handles_empty_metrics FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS date_policy_changes_winner FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS request_policy_changes_winner FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS defaults_priority_policy FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS compares_demand_policies FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_demand_policy FOR TESTING.
    METHODS assert_rejected
      IMPORTING
        demands           TYPE zcl_stock_allocator=>ty_demands
        stocks            TYPE zcl_sap_atp_rules=>ty_stocks
        conversions       TYPE zcl_sap_uom_rules=>ty_conversions OPTIONAL
        reservations      TYPE zcl_sap_atp_rules=>ty_reservations OPTIONAL
        batch_strategy    TYPE string OPTIONAL
        strategy_overrides TYPE zcl_stock_allocator=>ty_strategy_overrides
          OPTIONAL
        demand_policy     TYPE string OPTIONAL
        allocation_date   TYPE d
        expected_reason   TYPE string
        expected_request  TYPE string OPTIONAL
        expected_material TYPE string OPTIONAL
        expected_batch    TYPE string OPTIONAL
        expected_plant    TYPE string OPTIONAL
        expected_source   TYPE string OPTIONAL
        expected_target   TYPE string OPTIONAL
        expected_reservation TYPE string OPTIONAL.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD allocates_by_priority.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        expiry_date = '20261231' unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `LOW` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 7 )
      ( request_id = `HIGH` material = `MAT-1` plant = `1000`
        requirement_date = '20260802' priority = 1 requested_qty = 6 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-request_id
      exp = `HIGH` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 6 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 4 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 3 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 3 ) ).
  ENDMETHOD.

  METHOD consumes_earliest_batch.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `LATE`
        expiry_date = '20261231' unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `EARLY`
        expiry_date = '20261031' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-batch
      exp = `EARLY` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-batch
      exp = `LATE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
  ENDMETHOD.

  METHOD excludes_unavailable_stock.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `EXPIRED`
        expiry_date = '20260101' unrestricted_qty = 8 )
      ( material = `MAT-1` plant = `1000` batch = `VALID`
        expiry_date = '20261231' unrestricted_qty = 9 safety_stock = 4
        quality_qty = 10 blocked_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-batch
      exp = `VALID` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
  ENDMETHOD.

  METHOD rejects_incomplete_delivery.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `ONLY`
        expiry_date = '20261231' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `COMPLETE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7
        complete_delivery = abap_true )
      ( request_id = `FOLLOW-UP` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-request_id
      exp = `COMPLETE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 7 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-request_id
      exp = `FOLLOW-UP` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
  ENDMETHOD.

  METHOD completes_from_many_batches.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `FIRST`
        expiry_date = '20261031' unrestricted_qty = 3 )
      ( material = `MAT-1` plant = `1000` batch = `SECOND`
        expiry_date = '20261231' unrestricted_qty = 4 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `COMPLETE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7
        complete_delivery = abap_true ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-batch
      exp = `FIRST` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 3 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-batch
      exp = `SECOND` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 4 ) ).
  ENDMETHOD.

  METHOD rejects_invalid_demand.
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `INVALID` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 0 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate(
          demands = demands
          stocks = VALUE #( )
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>invalid_demand_quantity ).
        cl_abap_unit_assert=>assert_equals(
          act = error->request_id
          exp = `INVALID` ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD rejects_invalid_stock.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `INVALID`
        expiry_date = '20261231' unrestricted_qty = -1 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate(
          demands = VALUE #( )
          stocks = stocks
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>invalid_stock_quantity ).
        cl_abap_unit_assert=>assert_equals(
          act = error->batch
          exp = `INVALID` ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD respects_minimum_shelf_life.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `TOO-SHORT`
        expiry_date = '20260805' unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `LONG-ENOUGH`
        expiry_date = '20260820' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `SHELF-LIFE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 7
        minimum_shelf_life_days = 10 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-batch
      exp = `LONG-ENOUGH` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
  ENDMETHOD.

  METHOD shelf_life_for_complete.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `TOO-SHORT`
        expiry_date = '20260805' unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `LONG-ENOUGH`
        expiry_date = '20260820' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `COMPLETE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 6
        complete_delivery = abap_true minimum_shelf_life_days = 10 )
      ( request_id = `FOLLOW-UP` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-request_id
      exp = `COMPLETE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 6 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-request_id
      exp = `FOLLOW-UP` ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 2 ]-batch
      exp = `TOO-SHORT` ).
  ENDMETHOD.

  METHOD rejects_invalid_shelf_life.
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `INVALID-SHELF-LIFE`
        material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 1
        minimum_shelf_life_days = -1 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate(
          demands = demands
          stocks = VALUE #( )
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>invalid_shelf_life ).
        cl_abap_unit_assert=>assert_equals(
          act = error->request_id
          exp = `INVALID-SHELF-LIFE` ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD converts_demand_to_base.
    DATA requested_quantity TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA divisor TYPE zcl_sap_uom_rules=>ty_quantity.

    requested_quantity = 5.
    divisor = 2.
    requested_quantity = requested_quantity / divisor.

    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `EA-STOCK`
        unit_of_measure = `EA` expiry_date = '20261231'
        unrestricted_qty = 20 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `BOX-DEMAND` material = `MAT-1` plant = `1000`
        requested_unit = `BOX` base_unit = `EA`
        requirement_date = '20260801' priority = 1
        requested_qty = requested_quantity ) ).
    DATA(conversions) = VALUE zcl_sap_uom_rules=>ty_conversions(
      ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
        numerator = 6 denominator = 1 ) ).

    DATA(result) = zcl_stock_allocator=>allocate(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      conversions = conversions ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 15 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result[ 1 ]-unit_of_measure
      exp = `EA` ).
  ENDMETHOD.

  METHOD converts_using_inverse.
    DATA(conversions) = VALUE zcl_sap_uom_rules=>ty_conversions(
      ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
        numerator = 6 denominator = 1 ) ).

    DATA(result) = zcl_sap_uom_rules=>convert(
      material = `MAT-1`
      quantity = 12
      source_unit = `EA`
      target_unit = `BOX`
      conversions = conversions ).

    cl_abap_unit_assert=>assert_true( result-found ).
    cl_abap_unit_assert=>assert_equals(
      act = result-quantity
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
  ENDMETHOD.

  METHOD rejects_missing_conversion.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `EA-STOCK`
        unit_of_measure = `EA` expiry_date = '20261231'
        unrestricted_qty = 20 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `NO-FACTOR` material = `MAT-1` plant = `1000`
        requested_unit = `BOX` base_unit = `EA`
        requirement_date = '20260801' priority = 1 requested_qty = 1 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate(
          demands = demands
          stocks = stocks
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>missing_uom_conversion ).
        cl_abap_unit_assert=>assert_equals(
          act = error->request_id
          exp = `NO-FACTOR` ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD rejects_stock_unit_mismatch.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `KG-STOCK`
        unit_of_measure = `KG` expiry_date = '20261231'
        unrestricted_qty = 20 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `EA-DEMAND` material = `MAT-1` plant = `1000`
        requested_unit = `EA` base_unit = `EA`
        requirement_date = '20260801' priority = 1 requested_qty = 1 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate(
          demands = demands
          stocks = stocks
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>invalid_stock_unit ).
        cl_abap_unit_assert=>assert_equals(
          act = error->batch
          exp = `KG-STOCK` ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD rejects_invalid_conversion.
    DATA(conversions) = VALUE zcl_sap_uom_rules=>ty_conversions(
      ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
        numerator = 6 denominator = 0 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate(
          demands = VALUE #( )
          stocks = VALUE #( )
          allocation_date = '20260729'
          conversions = conversions ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>invalid_uom_conversion ).
        cl_abap_unit_assert=>assert_equals(
          act = error->material
          exp = `MAT-1` ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD summarizes_request_outcomes.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unit_of_measure = `EA` expiry_date = '20261231'
        unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `FULL` material = `MAT-1` plant = `1000`
        requested_unit = `EA` base_unit = `EA`
        requirement_date = '20260801' priority = 1 requested_qty = 4 )
      ( request_id = `PARTIAL` material = `MAT-1` plant = `1000`
        requested_unit = `EA` base_unit = `EA`
        requirement_date = '20260801' priority = 2 requested_qty = 8 )
      ( request_id = `SHORTAGE` material = `MAT-2` plant = `1000`
        requested_unit = `EA` base_unit = `EA`
        requirement_date = '20260801' priority = 3 requested_qty = 2 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result-summaries )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-status
      exp = zcl_stock_allocator=>status_full ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 4 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 2 ]-status
      exp = zcl_stock_allocator=>status_partial ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 2 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 6 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 2 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 3 ]-status
      exp = zcl_stock_allocator=>status_shortage ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 3 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
  ENDMETHOD.

  METHOD projects_remaining_stock.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unit_of_measure = `EA` expiry_date = '20261231'
        unrestricted_qty = 10 safety_stock = 3 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_unit = `EA` base_unit = `EA`
        requirement_date = '20260801' priority = 1 requested_qty = 4 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result-remaining_stocks[ 1 ]-unrestricted_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 6 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-remaining_stocks[ 1 ]-safety_stock
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 3 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = stocks[ 1 ]-unrestricted_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 10 ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_request.
    assert_rejected(
      demands = VALUE #(
        ( request_id = `DUPLICATE` material = `MAT-1` plant = `1000`
          requested_qty = 1 )
        ( request_id = `DUPLICATE` material = `MAT-2` plant = `1000`
          requested_qty = 1 ) )
      stocks = VALUE #( )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>duplicate_request_id
      expected_request = `DUPLICATE` ).
  ENDMETHOD.

  METHOD rejects_missing_request_id.
    assert_rejected(
      demands = VALUE #(
        ( material = `MAT-1` plant = `1000` requested_qty = 1 ) )
      stocks = VALUE #( )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_request_id ).
  ENDMETHOD.

  METHOD rejects_missing_demand_mat.
    assert_rejected(
      demands = VALUE #(
        ( request_id = `NO-MATERIAL` plant = `1000` requested_qty = 1 ) )
      stocks = VALUE #( )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_material
      expected_request = `NO-MATERIAL` ).
  ENDMETHOD.

  METHOD rejects_missing_demand_plant.
    assert_rejected(
      demands = VALUE #(
        ( request_id = `NO-PLANT` material = `MAT-1` requested_qty = 1 ) )
      stocks = VALUE #( )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_plant
      expected_request = `NO-PLANT`
      expected_material = `MAT-1` ).
  ENDMETHOD.

  METHOD rejects_missing_stock_material.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #(
        ( plant = `1000` batch = `NO-MATERIAL` unrestricted_qty = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_material
      expected_batch = `NO-MATERIAL` ).
  ENDMETHOD.

  METHOD rejects_missing_stock_plant.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #(
        ( material = `MAT-1` batch = `NO-PLANT` unrestricted_qty = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_plant
      expected_material = `MAT-1`
      expected_batch = `NO-PLANT` ).
  ENDMETHOD.

  METHOD rejects_missing_alloc_date.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '00000000'
      expected_reason = zcx_stock_allocation=>missing_allocation_date ).
  ENDMETHOD.

  METHOD rejects_duplicate_stock.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #(
        ( material = `MAT-1` plant = `1000` batch = `B1`
          unrestricted_qty = 5 )
        ( material = `MAT-1` plant = `1000` batch = `B1`
          unrestricted_qty = 7 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>duplicate_stock_key
      expected_material = `MAT-1`
      expected_plant = `1000`
      expected_batch = `B1` ).
  ENDMETHOD.

  METHOD rejects_duplicate_conversion.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      conversions = VALUE #(
        ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
          numerator = 6 denominator = 1 )
        ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
          numerator = 8 denominator = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>duplicate_conversion_key
      expected_material = `MAT-1`
      expected_source = `BOX`
      expected_target = `EA` ).
  ENDMETHOD.

  METHOD rejects_inverse_conversion.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      conversions = VALUE #(
        ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
          numerator = 6 denominator = 1 )
        ( material = `MAT-1` source_unit = `EA` target_unit = `BOX`
          numerator = 1 denominator = 6 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>duplicate_conversion_key
      expected_material = `MAT-1`
      expected_source = `EA`
      expected_target = `BOX` ).
  ENDMETHOD.

  METHOD rejects_missing_source_unit.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      conversions = VALUE #(
        ( material = `MAT-1` target_unit = `EA`
          numerator = 6 denominator = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_source_unit
      expected_material = `MAT-1`
      expected_target = `EA` ).
  ENDMETHOD.

  METHOD rejects_missing_target_unit.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      conversions = VALUE #(
        ( material = `MAT-1` source_unit = `BOX`
          numerator = 6 denominator = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_target_unit
      expected_material = `MAT-1`
      expected_source = `BOX` ).
  ENDMETHOD.

  METHOD rejects_missing_conv_mat.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      conversions = VALUE #(
        ( source_unit = `BOX` target_unit = `EA`
          numerator = 6 denominator = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_material
      expected_source = `BOX`
      expected_target = `EA` ).
  ENDMETHOD.

  METHOD allows_scoped_keys.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `2000` batch = `B1`
        unrestricted_qty = 7 ) ).
    DATA(conversions) = VALUE zcl_sap_uom_rules=>ty_conversions(
      ( material = `MAT-1` source_unit = `BOX` target_unit = `EA`
        numerator = 6 denominator = 1 )
      ( material = `MAT-2` source_unit = `BOX` target_unit = `EA`
        numerator = 8 denominator = 1 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = VALUE #( )
      stocks = stocks
      allocation_date = '20260729'
      conversions = conversions ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result-remaining_stocks )
      exp = 2 ).
  ENDMETHOD.

  METHOD honors_active_reservation.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 8 ) ).
    DATA(reservations) = VALUE zcl_sap_atp_rules=>ty_reservations(
      ( reservation_id = `RES-1` material = `MAT-1` plant = `1000`
        batch = `B1` reserved_qty = 4
        valid_from = '20260701' valid_to = '20260801' ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      reservations = reservations ).

    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-status
      exp = zcl_stock_allocator=>status_partial ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 6 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-remaining_stocks[ 1 ]-unrestricted_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 4 ) ).
  ENDMETHOD.

  METHOD ignores_inactive_reservations.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 10 ) ).
    DATA(reservations) = VALUE zcl_sap_atp_rules=>ty_reservations(
      ( reservation_id = `EXPIRED` material = `MAT-1` plant = `1000`
        batch = `B1` reserved_qty = 7 valid_to = '20260728' )
      ( reservation_id = `FUTURE` material = `MAT-1` plant = `1000`
        batch = `B1` reserved_qty = 7 valid_from = '20260730' ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      reservations = reservations ).

    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-status
      exp = zcl_stock_allocator=>status_full ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 10 ) ).
  ENDMETHOD.

  METHOD reservation_for_complete.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `COMPLETE` material = `MAT-1` plant = `1000`
        requested_qty = 7 complete_delivery = abap_true ) ).
    DATA(reservations) = VALUE zcl_sap_atp_rules=>ty_reservations(
      ( reservation_id = `RES-1` material = `MAT-1` plant = `1000`
        batch = `B1` reserved_qty = 4 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      reservations = reservations ).

    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-status
      exp = zcl_stock_allocator=>status_shortage ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 7 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-remaining_stocks[ 1 ]-unrestricted_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 10 ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_reservation.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      reservations = VALUE #(
        ( reservation_id = `RES-1` material = `MAT-1` plant = `1000`
          reserved_qty = 1 )
        ( reservation_id = `RES-1` material = `MAT-2` plant = `2000`
          reserved_qty = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>duplicate_reservation_id
      expected_reservation = `RES-1` ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_qty.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      reservations = VALUE #(
        ( reservation_id = `RES-1` material = `MAT-1` plant = `1000`
          reserved_qty = 0 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>invalid_reservation_qty
      expected_reservation = `RES-1` ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_window.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      reservations = VALUE #(
        ( reservation_id = `RES-1` material = `MAT-1` plant = `1000`
          reserved_qty = 1 valid_from = '20260801' valid_to = '20260701' ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>invalid_reservation_window
      expected_reservation = `RES-1` ).
  ENDMETHOD.

  METHOD rejects_missing_reservation_id.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      reservations = VALUE #(
        ( material = `MAT-1` plant = `1000` reserved_qty = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_reservation_id ).
  ENDMETHOD.

  METHOD rejects_missing_res_mat.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      reservations = VALUE #(
        ( reservation_id = `RES-1` plant = `1000` reserved_qty = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_material
      expected_reservation = `RES-1` ).
  ENDMETHOD.

  METHOD rejects_missing_res_plant.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      reservations = VALUE #(
        ( reservation_id = `RES-1` material = `MAT-1` reserved_qty = 1 ) )
      allocation_date = '20260729'
      expected_reason = zcx_stock_allocation=>missing_plant
      expected_reservation = `RES-1` ).
  ENDMETHOD.

  METHOD emits_partial_audit.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 7 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result-audit_events )
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-sequence
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-event_type
      exp = zcl_stock_allocator=>event_request_evaluated ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-requested_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 7 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 2 ]-event_type
      exp = zcl_stock_allocator=>event_batch_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 2 ]-batch
      exp = `B1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 2 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 3 ]-event_type
      exp = zcl_stock_allocator=>event_shortage_recorded ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 3 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 4 ]-sequence
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 4 ]-event_type
      exp = zcl_stock_allocator=>event_request_completed ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 4 ]-status
      exp = zcl_stock_allocator=>status_partial ).
  ENDMETHOD.

  METHOD audits_complete_rejection.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `COMPLETE` material = `MAT-1` plant = `1000`
        requested_qty = 7 complete_delivery = abap_true ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( result-audit_events )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-event_type
      exp = zcl_stock_allocator=>event_request_evaluated ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 2 ]-event_type
      exp = zcl_stock_allocator=>event_complete_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 2 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 7 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 3 ]-event_type
      exp = zcl_stock_allocator=>event_request_completed ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 3 ]-status
      exp = zcl_stock_allocator=>status_shortage ).
  ENDMETHOD.

  METHOD fefo_puts_unknown_last.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `NO-EXPIRY`
        unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `DATED`
        expiry_date = '20261231' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-batch
      exp = `DATED` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-batch_strategy
      exp = zcl_stock_allocator=>strategy_fefo ).
  ENDMETHOD.

  METHOD selects_fifo_batch.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `FEFO`
        expiry_date = '20261001' receipt_date = '20260720'
        unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `FIFO`
        expiry_date = '20261231' receipt_date = '20260701'
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      batch_strategy = zcl_stock_allocator=>strategy_fifo ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-batch
      exp = `FIFO` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-batch_strategy
      exp = zcl_stock_allocator=>strategy_fifo ).
  ENDMETHOD.

  METHOD selects_batch_code.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `Z-BATCH`
        expiry_date = '20261001' unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `A-BATCH`
        expiry_date = '20261231' unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      batch_strategy = zcl_stock_allocator=>strategy_batch ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-batch
      exp = `A-BATCH` ).
  ENDMETHOD.

  METHOD rejects_invalid_strategy.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '20260729'
      batch_strategy = `UNKNOWN`
      expected_reason = zcx_stock_allocation=>invalid_batch_strategy ).
  ENDMETHOD.

  METHOD groups_request_outcomes.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 10 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `FULL` demand_group = `GROUP-1`
        material = `MAT-1` plant = `1000` priority = 1 requested_qty = 4 )
      ( request_id = `PARTIAL` demand_group = `GROUP-1`
        material = `MAT-1` plant = `1000` priority = 2 requested_qty = 8 )
      ( request_id = `SHORTAGE` demand_group = `GROUP-2`
        material = `MAT-2` plant = `1000` priority = 3 requested_qty = 2 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      run_id = `RUN-1` ).

    cl_abap_unit_assert=>assert_equals(
      act = result-run_id
      exp = `RUN-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( result-group_summaries )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-demand_group
      exp = `GROUP-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-request_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-full_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-partial_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 2 ]-demand_group
      exp = `GROUP-2` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 2 ]-shortage_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-run_id
      exp = `RUN-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-demand_group
      exp = `GROUP-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-run_id
      exp = `RUN-1` ).
  ENDMETHOD.

  METHOD defaults_request_group.
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `ONE` material = `MAT-1` plant = `1000`
        requested_qty = 1 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = VALUE #( )
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-demand_group
      exp = `ONE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-demand_group
      exp = `ONE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-shortage_count
      exp = 1 ).
  ENDMETHOD.

  METHOD overrides_material_strategy.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `M1-FEFO`
        expiry_date = '20261001' receipt_date = '20260720'
        unrestricted_qty = 5 )
      ( material = `MAT-1` plant = `1000` batch = `M1-FIFO`
        expiry_date = '20261231' receipt_date = '20260701'
        unrestricted_qty = 5 )
      ( material = `MAT-2` plant = `1000` batch = `M2-FEFO`
        expiry_date = '20261001' receipt_date = '20260720'
        unrestricted_qty = 5 )
      ( material = `MAT-2` plant = `1000` batch = `M2-FIFO`
        expiry_date = '20261231' receipt_date = '20260701'
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `MAT-1` material = `MAT-1` plant = `1000`
        priority = 1 requested_qty = 5 )
      ( request_id = `MAT-2` material = `MAT-2` plant = `1000`
        priority = 2 requested_qty = 5 ) ).
    DATA(overrides) = VALUE zcl_stock_allocator=>ty_strategy_overrides(
      ( material = `MAT-1`
        batch_strategy = zcl_stock_allocator=>strategy_fifo ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      batch_strategy = zcl_stock_allocator=>strategy_fefo
      strategy_overrides = overrides ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-batch
      exp = `M1-FIFO` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 2 ]-batch
      exp = `M2-FEFO` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-batch_strategy
      exp = zcl_stock_allocator=>strategy_fifo ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 4 ]-batch_strategy
      exp = zcl_stock_allocator=>strategy_fefo ).
    cl_abap_unit_assert=>assert_equals(
      act = result-strategy_overrides[ 1 ]-material
      exp = `MAT-1` ).
  ENDMETHOD.

  METHOD rejects_duplicate_override.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '20260729'
      strategy_overrides = VALUE #(
        ( material = `MAT-1` batch_strategy = `FIFO` )
        ( material = `MAT-1` batch_strategy = `BATCH` ) )
      expected_reason = zcx_stock_allocation=>duplicate_strategy_override
      expected_material = `MAT-1` ).
  ENDMETHOD.

  METHOD rejects_override_no_material.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '20260729'
      strategy_overrides = VALUE #(
        ( batch_strategy = `FIFO` ) )
      expected_reason = zcx_stock_allocation=>missing_material ).
  ENDMETHOD.

  METHOD rejects_invalid_override.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '20260729'
      strategy_overrides = VALUE #(
        ( material = `MAT-1` batch_strategy = `UNKNOWN` ) )
      expected_reason = zcx_stock_allocation=>invalid_batch_strategy
      expected_material = `MAT-1` ).
  ENDMETHOD.

  METHOD calculates_service_metrics.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 9 )
      ( material = `MAT-3` plant = `1000` batch = `B1`
        unrestricted_qty = 1 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `FULL-1` material = `MAT-1` plant = `1000`
        priority = 1 requested_qty = 3 )
      ( request_id = `PARTIAL` material = `MAT-1` plant = `1000`
        priority = 2 requested_qty = 9 )
      ( request_id = `SHORTAGE` material = `MAT-2` plant = `1000`
        priority = 3 requested_qty = 2 )
      ( request_id = `FULL-2` material = `MAT-3` plant = `1000`
        priority = 4 requested_qty = 1 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      run_id = `METRICS-RUN` ).

    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-run_id
      exp = `METRICS-RUN` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-request_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-full_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-partial_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-shortage_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-served_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-full_service_pct
      exp = CONV zcl_stock_allocator=>ty_percentage( 50 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-served_request_pct
      exp = CONV zcl_stock_allocator=>ty_percentage( 75 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-allocation_line_count
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-audit_event_count
      exp = 13 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-stock_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = result-material_metrics[ 1 ]-material
      exp = `MAT-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-material_metrics[ 1 ]-requested_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 12 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-material_metrics[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 9 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-material_metrics[ 1 ]-quantity_fill_pct
      exp = CONV zcl_stock_allocator=>ty_percentage( 75 ) ).
  ENDMETHOD.

  METHOD handles_empty_metrics.
    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '20260729'
      run_id = `EMPTY` ).

    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-run_id
      exp = `EMPTY` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-request_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial(
      act = result-run_metrics-full_service_pct ).
    cl_abap_unit_assert=>assert_initial(
      act = result-material_metrics ).
  ENDMETHOD.

  METHOD date_policy_changes_winner.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `PRIORITY` material = `MAT-1` plant = `1000`
        requirement_date = '20260810' priority = 1 requested_qty = 5 )
      ( request_id = `DATE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      demand_policy = zcl_stock_allocator=>demand_policy_date_priority ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-request_id
      exp = `DATE` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-demand_policy
      exp = zcl_stock_allocator=>demand_policy_date_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-demand_policy
      exp = zcl_stock_allocator=>demand_policy_date_priority ).
  ENDMETHOD.

  METHOD request_policy_changes_winner.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `B` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 1 requested_qty = 5 )
      ( request_id = `A` material = `MAT-1` plant = `1000`
        requirement_date = '20260810' priority = 9 requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      demand_policy = zcl_stock_allocator=>demand_policy_request_id ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-request_id
      exp = `A` ).
  ENDMETHOD.

  METHOD defaults_priority_policy.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `LOW` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 5 )
      ( request_id = `HIGH` material = `MAT-1` plant = `1000`
        requirement_date = '20260810' priority = 1 requested_qty = 5 ) ).

    DATA(result) = zcl_stock_allocator=>allocate_with_projection(
      demands = demands
      stocks = stocks
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-request_id
      exp = `HIGH` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-demand_policy
      exp = zcl_stock_allocator=>demand_policy_priority_date ).
  ENDMETHOD.

  METHOD compares_demand_policies.
    DATA(stocks) = VALUE zcl_sap_atp_rules=>ty_stocks(
      ( material = `MAT-1` plant = `1000` batch = `B1`
        unrestricted_qty = 5 ) ).
    DATA(demands) = VALUE zcl_stock_allocator=>ty_demands(
      ( request_id = `Z_PRIORITY` material = `MAT-1` plant = `1000`
        requirement_date = '20260810' priority = 1 requested_qty = 5 )
      ( request_id = `M_DATE` material = `MAT-1` plant = `1000`
        requirement_date = '20260801' priority = 2 requested_qty = 5 )
      ( request_id = `A_ID` material = `MAT-1` plant = `1000`
        requirement_date = '20260805' priority = 3 requested_qty = 5 ) ).

    DATA(simulations) = zcl_stock_allocator=>simulate_demand_policies(
      demands = demands
      stocks = stocks
      allocation_date = '20260729'
      run_id = `SIM-1` ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( simulations )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 1 ]-demand_policy
      exp = zcl_stock_allocator=>demand_policy_priority_date ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 1 ]-result-allocations[ 1 ]-request_id
      exp = `Z_PRIORITY` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 2 ]-demand_policy
      exp = zcl_stock_allocator=>demand_policy_date_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 2 ]-result-allocations[ 1 ]-request_id
      exp = `M_DATE` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 3 ]-demand_policy
      exp = zcl_stock_allocator=>demand_policy_request_id ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 3 ]-result-allocations[ 1 ]-request_id
      exp = `A_ID` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 3 ]-result-run_id
      exp = `SIM-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 1 ]-result-remaining_stocks[ 1 ]-unrestricted_qty
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = stocks[ 1 ]-unrestricted_qty
      exp = 5 ).
  ENDMETHOD.

  METHOD rejects_invalid_demand_policy.
    assert_rejected(
      demands = VALUE #( )
      stocks = VALUE #( )
      allocation_date = '20260729'
      demand_policy = `UNKNOWN`
      expected_reason = zcx_stock_allocation=>invalid_demand_policy ).
  ENDMETHOD.

  METHOD assert_rejected.
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_stock_allocator=>allocate_with_projection(
          demands = demands
          stocks = stocks
          allocation_date = allocation_date
          conversions = conversions
          reservations = reservations
          batch_strategy = batch_strategy
          strategy_overrides = strategy_overrides
          demand_policy = demand_policy ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = expected_reason ).
        IF expected_request IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->request_id
            exp = expected_request ).
        ENDIF.
        IF expected_material IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->material
            exp = expected_material ).
        ENDIF.
        IF expected_batch IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->batch
            exp = expected_batch ).
        ENDIF.
        IF expected_plant IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->plant
            exp = expected_plant ).
        ENDIF.
        IF expected_source IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->source_unit
            exp = expected_source ).
        ENDIF.
        IF expected_target IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->target_unit
            exp = expected_target ).
        ENDIF.
        IF expected_reservation IS NOT INITIAL.
          cl_abap_unit_assert=>assert_equals(
            act = error->reservation_id
            exp = expected_reservation ).
        ENDIF.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.
ENDCLASS.
