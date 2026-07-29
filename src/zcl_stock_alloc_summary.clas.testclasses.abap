CLASS ltcl_stock_alloc_summary DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS summarizes_mixed_results FOR TESTING.
    METHODS summarizes_empty_results FOR TESTING.
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
      iv_reserve = '2' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-demand_count exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-reserve_qty exp = '2' ).
  ENDMETHOD.
ENDCLASS.
