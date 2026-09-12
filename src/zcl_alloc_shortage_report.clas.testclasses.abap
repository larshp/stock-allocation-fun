CLASS ltcl_alloc_shortage_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_shortage_report.

    METHODS setup.

    METHODS result
      IMPORTING
        iv_id            TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
        iv_tolerance     TYPE abap_bool DEFAULT abap_false
        iv_deferred      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zcl_stock_allocator=>ty_result.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_id            TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
        iv_tolerance     TYPE abap_bool DEFAULT abap_false
        iv_deferred      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS full_coverage_is_100     FOR TESTING.
    METHODS partial_coverage_floors  FOR TESTING.
    METHODS summary_aggregates       FOR TESTING.
    METHODS critical_below_threshold FOR TESTING.
    METHODS no_shortage_no_critical  FOR TESTING.
    METHODS zero_request_is_covered  FOR TESTING.
    METHODS empty_result_zero_lines  FOR TESTING.
    METHODS tolerance_line_is_covered FOR TESTING.
    METHODS short_line_is_not_covered FOR TESTING.
    METHODS full_delivery_counts_covered FOR TESTING.
    METHODS deferred_line_is_covered FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_shortage_report IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_shortage_report( ).
  ENDMETHOD.

  METHOD result.
    rs_result-requirement_id = iv_id.
    rs_result-requested_qty = iv_requested.
    rs_result-allocated_qty = iv_allocated.
    rs_result-shortage_qty = iv_requested - iv_allocated.
    rs_result-within_tolerance = iv_tolerance.
    rs_result-deferred = iv_deferred.
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    rt_result = it_result.
    ls_line = result( iv_id        = iv_id
                      iv_requested = iv_requested
                      iv_allocated = iv_allocated
                      iv_tolerance = iv_tolerance
                      iv_deferred  = iv_deferred ).

    APPEND ls_line TO rt_result.
  ENDMETHOD.

  METHOD full_coverage_is_100.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_report-lines[ 1 ]-coverage_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-coverage_pct
                                        exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-short_lines
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_initial( act = ls_report-critical ).
  ENDMETHOD.

  METHOD partial_coverage_floors.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '3'
                          iv_allocated = '1' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_report-lines[ 1 ]-coverage_pct exp = 33 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_report-lines[ 1 ]-shortage_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-short_lines
                                        exp = 1 ).
  ENDMETHOD.

  METHOD summary_aggregates.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '5' ).
    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-2'
                          iv_requested = '20'
                          iv_allocated = '20' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-requested_qty
                                        exp = '30' ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-allocated_qty
                                        exp = '25' ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-shortage_qty
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-coverage_pct
                                        exp = 83 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-lines
                                        exp = 2 ).
  ENDMETHOD.

  METHOD critical_below_threshold.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-LOW'
                          iv_requested = '10'
                          iv_allocated = '5' ).
    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-HIGH'
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(ls_report) = mo_cut->build( it_result       = lt_result
                                     iv_min_coverage = 90 ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_report-critical )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_report-critical[ 1 ]-requirement_id exp = 'REQ-LOW' ).
  ENDMETHOD.

  METHOD no_shortage_no_critical.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_initial( act = ls_report-critical ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-coverage_pct
                                        exp = 100 ).
  ENDMETHOD.

  METHOD zero_request_is_covered.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '0'
                          iv_allocated = '0' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_report-lines[ 1 ]-coverage_pct exp = 100 ).
    cl_abap_unit_assert=>assert_initial( act = ls_report-critical ).
  ENDMETHOD.

  METHOD empty_result_zero_lines.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_initial( act = ls_report-lines ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-lines
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-coverage_pct
                                        exp = 100 ).
  ENDMETHOD.

  METHOD tolerance_line_is_covered.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '100'
                          iv_allocated = '97'
                          iv_tolerance = abap_true ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-lines[ 1 ]-covered
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-covered_lines
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_initial( act = ls_report-critical ).
  ENDMETHOD.

  METHOD short_line_is_not_covered.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '100'
                          iv_allocated = '90' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-lines[ 1 ]-covered
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-covered_lines
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_report-critical )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD full_delivery_counts_covered.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '10' ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-lines[ 1 ]-covered
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-covered_lines
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-short_lines
                                        exp = 0 ).
  ENDMETHOD.

  METHOD deferred_line_is_covered.
    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_id        = 'REQ-1'
                          iv_requested = '10'
                          iv_allocated = '0'
                          iv_deferred  = abap_true ).

    DATA(ls_report) = mo_cut->build( lt_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-lines[ 1 ]-covered
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-summary-covered_lines
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_initial( act = ls_report-critical ).
  ENDMETHOD.

ENDCLASS.
