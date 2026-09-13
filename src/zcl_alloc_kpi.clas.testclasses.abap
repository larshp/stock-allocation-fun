CLASS ltcl_alloc_kpi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_kpi.

    METHODS setup.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS empty_result     FOR TESTING.
    METHODS full_delivery    FOR TESTING.
    METHODS partial_delivery FOR TESTING.
    METHODS mixed_lines      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_kpi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_kpi( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    rt_result = it_result.

    ls_line-requested_qty = iv_requested.
    ls_line-allocated_qty = iv_allocated.
    ls_line-shortage_qty = iv_requested - iv_allocated.

    APPEND ls_line TO rt_result.
  ENDMETHOD.

  METHOD empty_result.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(rs_kpi) = mo_cut->summarize( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_kpi-requirements exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-coverage_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-fill_rate_pct exp = 0 ).
  ENDMETHOD.

  METHOD full_delivery.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(rs_kpi) = mo_cut->summarize( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_kpi-fully_delivered exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-short exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-coverage_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-fill_rate_pct exp = 100 ).
  ENDMETHOD.

  METHOD partial_delivery.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_requested = '10'
                          iv_allocated = '6' ).

    DATA(rs_kpi) = mo_cut->summarize( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_kpi-short exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-shortage_qty exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-coverage_pct exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-fill_rate_pct exp = 0 ).
  ENDMETHOD.

  METHOD mixed_lines.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_requested = '10'
                          iv_allocated = '10' ).
    lt_result = add_line( it_result    = lt_result
                          iv_requested = '10'
                          iv_allocated = '5' ).

    DATA(rs_kpi) = mo_cut->summarize( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = rs_kpi-requirements exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-fully_delivered exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-short exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-requested_qty exp = '20' ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-allocated_qty exp = '15' ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-coverage_pct exp = 75 ).
    cl_abap_unit_assert=>assert_equals( act = rs_kpi-fill_rate_pct exp = 50 ).
  ENDMETHOD.

ENDCLASS.
