CLASS ltcl_sap_stock_facade DEFINITION FINAL FOR TESTING
    RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS maps_and_allocates FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS maps_shortage FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_document FOR TESTING.
    METHODS rejects_missing_item FOR TESTING.
    METHODS rejects_duplicate_item FOR TESTING.
    METHODS maps_reservation_hold FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_res_doc FOR TESTING.
    METHODS rejects_missing_res_item FOR TESTING.
    METHODS maps_fifo_strategy FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS maps_material_override FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS maps_demand_policy FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS maps_policy_simulations FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_sap_stock_facade IMPLEMENTATION.
  METHOD maps_and_allocates.
    DATA requested_quantity TYPE zcl_sap_uom_rules=>ty_quantity.
    DATA divisor TYPE zcl_sap_uom_rules=>ty_quantity.

    requested_quantity = 5.
    divisor = 2.
    requested_quantity = requested_quantity / divisor.

    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000010` posnr = `000010` group_id = `SALES-GROUP`
        matnr = `MAT-1` werks = `1000` bdter = '20260801'
        priority = 1 kwmeng = requested_quantity vrkme = `BOX`
        meins = `EA` complete_delivery = abap_true
        min_shelf_life_days = 5 ) ).
    DATA(stocks) = VALUE zcl_sap_stock_facade=>ty_stocks(
      ( matnr = `MAT-1` werks = `1000` charg = `B1` meins = `EA`
        vfdat = '20261231' labst = 20 eisbe = 3 ) ).
    DATA(conversions) = VALUE zcl_sap_stock_facade=>ty_uom_conversions(
      ( matnr = `MAT-1` meinh = `BOX` meins = `EA`
        umrez = 6 umren = 1 ) ).

    DATA(result) = zcl_sap_stock_facade=>allocate(
      requirements = requirements
      stocks = stocks
      allocation_date = '20260729'
      conversions = conversions
      run_id = `SAP-RUN-1` ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-vbeln
      exp = `5000000010` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-posnr
      exp = `000010` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 15 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-meins
      exp = `EA` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-status
      exp = zcl_stock_allocator=>status_full ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-requested_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 15 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-remaining_stocks[ 1 ]-labst
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-remaining_stocks[ 1 ]-eisbe
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 3 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-vbeln
      exp = `5000000010` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-posnr
      exp = `000010` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-event_type
      exp = zcl_stock_allocator=>event_request_evaluated ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_id
      exp = `SAP-RUN-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-group_id
      exp = `SALES-GROUP` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-group_summaries[ 1 ]-group_id
      exp = `SALES-GROUP` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-run_id
      exp = `SAP-RUN-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-run_metrics-full_service_pct
      exp = CONV zcl_stock_allocator=>ty_percentage( 100 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-material_metrics[ 1 ]-matnr
      exp = `MAT-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-material_metrics[ 1 ]-quantity_fill_pct
      exp = CONV zcl_stock_allocator=>ty_percentage( 100 ) ).
  ENDMETHOD.

  METHOD maps_shortage.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000011` posnr = `000020`
        matnr = `MAT-1` werks = `1000` bdter = '20260801'
        priority = 1 kwmeng = 5 vrkme = `EA` meins = `EA` ) ).

    DATA(result) = zcl_sap_stock_facade=>allocate(
      requirements = requirements
      stocks = VALUE #( )
      allocation_date = '20260729' ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-vbeln
      exp = `5000000011` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 5 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-status
      exp = zcl_stock_allocator=>status_shortage ).
  ENDMETHOD.

  METHOD rejects_missing_document.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( posnr = `000010` matnr = `MAT-1` werks = `1000`
        kwmeng = 1 vrkme = `EA` meins = `EA` ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_sap_stock_facade=>allocate(
          requirements = requirements
          stocks = VALUE #( )
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>missing_sales_document ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD rejects_missing_item.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000010` matnr = `MAT-1` werks = `1000`
        kwmeng = 1 vrkme = `EA` meins = `EA` ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_sap_stock_facade=>allocate(
          requirements = requirements
          stocks = VALUE #( )
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>missing_sales_item ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD rejects_duplicate_item.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000010` posnr = `000010`
        matnr = `MAT-1` werks = `1000` kwmeng = 1
        vrkme = `EA` meins = `EA` )
      ( vbeln = `5000000010` posnr = `000010`
        matnr = `MAT-2` werks = `1000` kwmeng = 1
        vrkme = `EA` meins = `EA` ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_sap_stock_facade=>allocate(
          requirements = requirements
          stocks = VALUE #( )
          allocation_date = '20260729' ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>duplicate_request_id ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD maps_reservation_hold.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000010` posnr = `000010`
        matnr = `MAT-1` werks = `1000` bdter = '20260801'
        priority = 1 kwmeng = 8 vrkme = `EA` meins = `EA` ) ).
    DATA(stocks) = VALUE zcl_sap_stock_facade=>ty_stocks(
      ( matnr = `MAT-1` werks = `1000` charg = `B1` meins = `EA`
        vfdat = '20261231' labst = 10 ) ).
    DATA(reservations) = VALUE zcl_sap_stock_facade=>ty_reservations(
      ( rsnum = `0000000001` rspos = `0001`
        matnr = `MAT-1` werks = `1000` charg = `B1` bdmng = 4
        valid_from = '20260701' valid_to = '20260801' ) ).

    DATA(result) = zcl_sap_stock_facade=>allocate(
      requirements = requirements
      stocks = stocks
      allocation_date = '20260729'
      reservations = reservations ).

    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-allocated_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 6 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = result-summaries[ 1 ]-shortage_qty
      exp = CONV zcl_sap_uom_rules=>ty_quantity( 2 ) ).
  ENDMETHOD.

  METHOD rejects_missing_res_doc.
    DATA(reservations) = VALUE zcl_sap_stock_facade=>ty_reservations(
      ( rspos = `0001` matnr = `MAT-1` werks = `1000` bdmng = 1 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_sap_stock_facade=>allocate(
          requirements = VALUE #( )
          stocks = VALUE #( )
          allocation_date = '20260729'
          reservations = reservations ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>missing_reservation_doc ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD rejects_missing_res_item.
    DATA(reservations) = VALUE zcl_sap_stock_facade=>ty_reservations(
      ( rsnum = `0000000001` matnr = `MAT-1` werks = `1000` bdmng = 1 ) ).
    DATA caught TYPE abap_bool.

    TRY.
        DATA(result) = zcl_sap_stock_facade=>allocate(
          requirements = VALUE #( )
          stocks = VALUE #( )
          allocation_date = '20260729'
          reservations = reservations ).
      CATCH zcx_stock_allocation INTO DATA(error).
        caught = abap_true.
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = zcx_stock_allocation=>missing_reservation_item ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( caught ).
  ENDMETHOD.

  METHOD maps_fifo_strategy.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000010` posnr = `000010`
        matnr = `MAT-1` werks = `1000` kwmeng = 5
        vrkme = `EA` meins = `EA` ) ).
    DATA(stocks) = VALUE zcl_sap_stock_facade=>ty_stocks(
      ( matnr = `MAT-1` werks = `1000` charg = `NEW`
        meins = `EA` vfdat = '20261001' budat = '20260720' labst = 5 )
      ( matnr = `MAT-1` werks = `1000` charg = `OLD`
        meins = `EA` vfdat = '20261231' budat = '20260701' labst = 5 ) ).

    DATA(result) = zcl_sap_stock_facade=>allocate(
      requirements = requirements
      stocks = stocks
      allocation_date = '20260729'
      batch_strategy = zcl_stock_allocator=>strategy_fifo ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-charg
      exp = `OLD` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-batch_strategy
      exp = zcl_stock_allocator=>strategy_fifo ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-batch_strategy
      exp = zcl_stock_allocator=>strategy_fifo ).
  ENDMETHOD.

  METHOD maps_material_override.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000010` posnr = `000010`
        matnr = `MAT-1` werks = `1000` kwmeng = 5
        vrkme = `EA` meins = `EA` ) ).
    DATA(stocks) = VALUE zcl_sap_stock_facade=>ty_stocks(
      ( matnr = `MAT-1` werks = `1000` charg = `FEFO`
        meins = `EA` vfdat = '20261001' budat = '20260720' labst = 5 )
      ( matnr = `MAT-1` werks = `1000` charg = `FIFO`
        meins = `EA` vfdat = '20261231' budat = '20260701' labst = 5 ) ).
    DATA(overrides) = VALUE zcl_sap_stock_facade=>ty_strategy_overrides(
      ( matnr = `MAT-1`
        batch_strategy = zcl_stock_allocator=>strategy_fifo ) ).

    DATA(result) = zcl_sap_stock_facade=>allocate(
      requirements = requirements
      stocks = stocks
      allocation_date = '20260729'
      batch_strategy = zcl_stock_allocator=>strategy_fefo
      strategy_overrides = overrides ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-charg
      exp = `FIFO` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-strategy_overrides[ 1 ]-matnr
      exp = `MAT-1` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-batch_strategy
      exp = zcl_stock_allocator=>strategy_fifo ).
  ENDMETHOD.

  METHOD maps_demand_policy.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000002` posnr = `000010`
        matnr = `MAT-1` werks = `1000` bdter = '20260810'
        priority = 1 kwmeng = 5 vrkme = `EA` meins = `EA` )
      ( vbeln = `5000000001` posnr = `000010`
        matnr = `MAT-1` werks = `1000` bdter = '20260801'
        priority = 2 kwmeng = 5 vrkme = `EA` meins = `EA` ) ).
    DATA(stocks) = VALUE zcl_sap_stock_facade=>ty_stocks(
      ( matnr = `MAT-1` werks = `1000` charg = `B1`
        meins = `EA` labst = 5 ) ).

    DATA(result) = zcl_sap_stock_facade=>allocate(
      requirements = requirements
      stocks = stocks
      allocation_date = '20260729'
      demand_policy = zcl_stock_allocator=>demand_policy_date_priority ).

    cl_abap_unit_assert=>assert_equals(
      act = result-allocations[ 1 ]-vbeln
      exp = `5000000001` ).
    cl_abap_unit_assert=>assert_equals(
      act = result-demand_policy
      exp = zcl_stock_allocator=>demand_policy_date_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = result-audit_events[ 1 ]-demand_policy
      exp = zcl_stock_allocator=>demand_policy_date_priority ).
  ENDMETHOD.

  METHOD maps_policy_simulations.
    DATA(requirements) = VALUE zcl_sap_stock_facade=>ty_requirements(
      ( vbeln = `5000000003` posnr = `000010`
        matnr = `MAT-1` werks = `1000` bdter = '20260810'
        priority = 1 kwmeng = 5 vrkme = `EA` meins = `EA` )
      ( vbeln = `5000000002` posnr = `000010`
        matnr = `MAT-1` werks = `1000` bdter = '20260801'
        priority = 2 kwmeng = 5 vrkme = `EA` meins = `EA` )
      ( vbeln = `5000000001` posnr = `000010`
        matnr = `MAT-1` werks = `1000` bdter = '20260805'
        priority = 3 kwmeng = 5 vrkme = `EA` meins = `EA` ) ).
    DATA(stocks) = VALUE zcl_sap_stock_facade=>ty_stocks(
      ( matnr = `MAT-1` werks = `1000` charg = `B1`
        meins = `EA` labst = 5 ) ).

    DATA(simulations) =
      zcl_sap_stock_facade=>simulate_demand_policies(
        requirements = requirements
        stocks = stocks
        allocation_date = '20260729'
        run_id = `SAP-SIM-1` ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( simulations )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 1 ]-result-allocations[ 1 ]-vbeln
      exp = `5000000003` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 2 ]-result-allocations[ 1 ]-vbeln
      exp = `5000000002` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 3 ]-result-allocations[ 1 ]-vbeln
      exp = `5000000001` ).
    cl_abap_unit_assert=>assert_equals(
      act = simulations[ 3 ]-result-run_metrics-run_id
      exp = `SAP-SIM-1` ).
  ENDMETHOD.
ENDCLASS.
