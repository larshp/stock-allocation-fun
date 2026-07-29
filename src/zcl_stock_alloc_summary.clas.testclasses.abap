CLASS ltcl_stock_alloc_summary DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS summarizes_mixed_results FOR TESTING.
    METHODS summarizes_empty_results FOR TESTING.
    METHODS summarizes_large_totals FOR TESTING.
    METHODS calculates_fulfillment_kpis FOR TESTING.
    METHODS calculates_fairness_index FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_alloc_summary IMPLEMENTATION.
  METHOD summarizes_mixed_results.
    DATA(lt_allocations) = VALUE zif_stock_allocation=>tt_allocations(
      ( requested_qty = '5' allocated_qty = '5' shortage_qty = '0' unit = 'EA'
        delivery_date = '20260801'
        status = zif_stock_allocation=>c_status_full )
      ( requested_qty = '4' allocated_qty = '2' shortage_qty = '2' unit = 'EA'
        delivery_date = '20260715'
        status = zif_stock_allocation=>c_status_partial )
      ( requested_qty = '3' allocated_qty = '0' shortage_qty = '3' unit = 'EA'
        delivery_date = '20260720'
        status = zif_stock_allocation=>c_status_none ) ).

    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = lt_allocations
      iv_reserve     = '1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-demand_count exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-full_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-partial_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-none_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-shortage_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-earliest_shortage_date
      exp = '20260715' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-requested_qty exp = '12' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocated_qty exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-shortage_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-reserve_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-unit exp = 'EA' ).
  ENDMETHOD.

  METHOD summarizes_empty_results.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations     = VALUE #( )
      iv_stock_qty       = '10'
      iv_allocatable_qty = '8'
      iv_reserve         = '2'
      iv_unit            = 'EA' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-demand_count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-stock_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocatable_qty exp = '8' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-reserve_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-unused_qty exp = '8' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-unit exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-quantity_fill_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-service_level_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-stock_utilization_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-fairness_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-shortage_count exp = 0 ).
    cl_abap_unit_assert=>assert_initial( ls_summary-earliest_shortage_date ).
  ENDMETHOD.

  METHOD summarizes_large_totals.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = VALUE #(
        ( requested_qty = '900000000000.000'
          allocated_qty = '900000000000.000'
          status        = zif_stock_allocation=>c_status_full )
        ( requested_qty = '900000000000.000'
          allocated_qty = '900000000000.000'
          status        = zif_stock_allocation=>c_status_full ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-requested_qty
      exp = '1800000000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-allocated_qty
      exp = '1800000000000' ).
  ENDMETHOD.

  METHOD calculates_fulfillment_kpis.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations     = VALUE #(
        ( requested_qty = '2.5' allocated_qty = '2.5'
          status = zif_stock_allocation=>c_status_full )
        ( requested_qty = '2.5' allocated_qty = '2.5'
          status = zif_stock_allocation=>c_status_full )
        ( requested_qty = '2.5' allocated_qty = '0'
          shortage_qty = '2.5' status = zif_stock_allocation=>c_status_none )
        ( requested_qty = '2.5' allocated_qty = '0'
          shortage_qty = '2.5' status = zif_stock_allocation=>c_status_none ) )
      iv_allocatable_qty = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-quantity_fill_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-service_level_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unused_qty
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-stock_utilization_pct
      exp = 50 ).
  ENDMETHOD.

  METHOD calculates_fairness_index.
    DATA(ls_even) = zcl_stock_alloc_summary=>summarize(
      it_allocations = VALUE #(
        ( requested_qty = '2' allocated_qty = '1'
          status = zif_stock_allocation=>c_status_partial )
        ( requested_qty = '6' allocated_qty = '3'
          status = zif_stock_allocation=>c_status_partial ) ) ).
    DATA(ls_concentrated) = zcl_stock_alloc_summary=>summarize(
      it_allocations = VALUE #(
        ( requested_qty = '4' allocated_qty = '4'
          status = zif_stock_allocation=>c_status_full )
        ( requested_qty = '4' allocated_qty = '0'
          shortage_qty = '4' status = zif_stock_allocation=>c_status_none ) ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_even-fairness_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_concentrated-fairness_pct exp = 50 ).
  ENDMETHOD.
ENDCLASS.
