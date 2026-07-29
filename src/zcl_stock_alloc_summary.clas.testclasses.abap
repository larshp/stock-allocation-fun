CLASS ltcl_stock_alloc_summary DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS summarizes_mixed_results FOR TESTING.
    METHODS summarizes_empty_results FOR TESTING.
    METHODS summarizes_large_totals FOR TESTING.
    METHODS calculates_fulfillment_kpis FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_alloc_summary IMPLEMENTATION.
  METHOD summarizes_mixed_results.
    DATA(lt_allocations) = VALUE zif_stock_allocation=>tt_allocations(
      ( requested_qty = '5' allocated_qty = '5' shortage_qty = '0' unit = 'EA'
        status = zif_stock_allocation=>c_status_full )
      ( requested_qty = '4' allocated_qty = '2' shortage_qty = '2' unit = 'EA'
        status = zif_stock_allocation=>c_status_partial )
      ( requested_qty = '3' allocated_qty = '0' shortage_qty = '3' unit = 'EA'
        status = zif_stock_allocation=>c_status_none ) ).

    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = lt_allocations
      iv_reserve = '1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-demand_count exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-full_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-partial_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-none_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-requested_qty exp = '12' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocated_qty exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-shortage_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-reserve_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-unit exp = 'EA' ).
  ENDMETHOD.

  METHOD summarizes_empty_results.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = VALUE #( )
      iv_stock_qty = '10'
      iv_allocatable_qty = '8'
      iv_reserve = '2'
      iv_unit = 'EA' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-demand_count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-stock_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocatable_qty exp = '8' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-reserve_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-unit exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-quantity_fill_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-service_level_pct exp = 0 ).
  ENDMETHOD.

  METHOD summarizes_large_totals.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = VALUE #(
        ( requested_qty = '900000000000.000'
          allocated_qty = '900000000000.000'
          status = zif_stock_allocation=>c_status_full )
        ( requested_qty = '900000000000.000'
          allocated_qty = '900000000000.000'
          status = zif_stock_allocation=>c_status_full ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-requested_qty
      exp = '1800000000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-allocated_qty
      exp = '1800000000000' ).
  ENDMETHOD.

  METHOD calculates_fulfillment_kpis.
    DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = VALUE #(
        ( requested_qty = '2.5' allocated_qty = '2.5'
          status = zif_stock_allocation=>c_status_full )
        ( requested_qty = '2.5' allocated_qty = '2.5'
          status = zif_stock_allocation=>c_status_full )
        ( requested_qty = '2.5' allocated_qty = '0'
          shortage_qty = '2.5' status = zif_stock_allocation=>c_status_none )
        ( requested_qty = '2.5' allocated_qty = '0'
          shortage_qty = '2.5' status = zif_stock_allocation=>c_status_none ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-quantity_fill_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-service_level_pct
      exp = 50 ).
  ENDMETHOD.
ENDCLASS.
