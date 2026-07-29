CLASS ltcl_stock_strategy_selector DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS maximizes_complete_service FOR TESTING RAISING zcx_stock_allocation.
    METHODS maximizes_quantity_fill FOR TESTING RAISING zcx_stock_allocation.
    METHODS maximizes_fairness FOR TESTING RAISING zcx_stock_allocation.
    METHODS keeps_input_order_on_tie FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_invalid_comparison FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_strategy_selector IMPLEMENTATION.
  METHOD maximizes_complete_service.
    DATA(lt_plans) = VALUE zif_stock_allocation=>tt_plans(
      ( strategy = zif_stock_allocation=>c_strategy_fifo
        allocations = VALUE #(
          ( allocated_qty = '5' status = zif_stock_allocation=>c_status_partial ) ) )
      ( strategy = zif_stock_allocation=>c_strategy_smallest_first
        allocations = VALUE #(
          ( allocated_qty = '2' status = zif_stock_allocation=>c_status_full )
          ( allocated_qty = '3' status = zif_stock_allocation=>c_status_full ) ) ) ).

    DATA(lv_strategy) = zcl_stock_strategy_selector=>recommend(
      it_plans = lt_plans
      iv_objective = zif_stock_allocation=>c_objective_service ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_strategy
      exp = zif_stock_allocation=>c_strategy_smallest_first ).
  ENDMETHOD.

  METHOD maximizes_quantity_fill.
    DATA(lt_plans) = VALUE zif_stock_allocation=>tt_plans(
      ( strategy = zif_stock_allocation=>c_strategy_complete_only
        allocations = VALUE #(
          ( allocated_qty = '3' status = zif_stock_allocation=>c_status_full ) ) )
      ( strategy = zif_stock_allocation=>c_strategy_fifo
        allocations = VALUE #(
          ( allocated_qty = '5' status = zif_stock_allocation=>c_status_partial ) ) ) ).

    DATA(lv_strategy) = zcl_stock_strategy_selector=>recommend(
      it_plans = lt_plans
      iv_objective = zif_stock_allocation=>c_objective_fill ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_strategy
      exp = zif_stock_allocation=>c_strategy_fifo ).
  ENDMETHOD.

  METHOD maximizes_fairness.
    DATA(lt_plans) = VALUE zif_stock_allocation=>tt_plans(
      ( strategy = zif_stock_allocation=>c_strategy_fifo
        allocations = VALUE #(
          ( requested_qty = '2' allocated_qty = '2'
            status = zif_stock_allocation=>c_status_full )
          ( requested_qty = '6' allocated_qty = '2'
            status = zif_stock_allocation=>c_status_partial ) ) )
      ( strategy = zif_stock_allocation=>c_strategy_proportional
        allocations = VALUE #(
          ( requested_qty = '2' allocated_qty = '1'
            status = zif_stock_allocation=>c_status_partial )
          ( requested_qty = '6' allocated_qty = '3'
            status = zif_stock_allocation=>c_status_partial ) ) ) ).

    DATA(lv_strategy) = zcl_stock_strategy_selector=>recommend(
      it_plans = lt_plans
      iv_objective = zif_stock_allocation=>c_objective_fairness ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_strategy
      exp = zif_stock_allocation=>c_strategy_proportional ).
  ENDMETHOD.

  METHOD keeps_input_order_on_tie.
    DATA(lv_strategy) = zcl_stock_strategy_selector=>recommend(
      it_plans = VALUE #(
        ( strategy = zif_stock_allocation=>c_strategy_proportional )
        ( strategy = zif_stock_allocation=>c_strategy_fifo ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_strategy
      exp = zif_stock_allocation=>c_strategy_proportional ).
  ENDMETHOD.

  METHOD rejects_invalid_comparison.
    TRY.
        zcl_stock_strategy_selector=>recommend(
          it_plans = VALUE #( )
          iv_objective = 'X' ).
        cl_abap_unit_assert=>fail( 'Invalid recommendation input must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    TRY.
        zcl_stock_strategy_selector=>recommend(
          it_plans = VALUE #( )
          iv_objective = zif_stock_allocation=>c_objective_service ).
        cl_abap_unit_assert=>fail( 'Empty recommendation input must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_empty_error).
        cl_abap_unit_assert=>assert_not_initial( lo_empty_error->get_text( ) ).
    ENDTRY.

    TRY.
        zcl_stock_strategy_selector=>recommend(
          it_plans = VALUE #( ( strategy = 'X' ) ) ).
        cl_abap_unit_assert=>fail( 'Unknown candidate strategy must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_strategy_error).
        cl_abap_unit_assert=>assert_not_initial( lo_strategy_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
