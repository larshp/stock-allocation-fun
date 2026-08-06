CLASS ltcl_stock_allocation_health DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reports_healthy_scope FOR TESTING.
    METHODS reports_no_runs FOR TESTING.
    METHODS reports_backlog_warning FOR TESTING.
    METHODS reports_stale_work_as_critical FOR TESTING.
    METHODS reports_fair_share_metrics FOR TESTING.
    METHODS reports_weighted_metrics FOR TESTING.
    METHODS reports_adaptive_metrics FOR TESTING.
    METHODS reports_low_coverage_warning FOR TESTING.
    METHODS reports_high_shortage_warning FOR TESTING.
    METHODS suppress_mixed_units FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_health IMPLEMENTATION.
  METHOD reports_healthy_scope.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 3.
    ls_summary-success_runs = 3.
    ls_summary-unit = 'EA'.
    ls_summary-requested = 10.
    ls_summary-allocated = 10.
    ls_summary-coverage = 100.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'HEALTHY' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-message
      exp = 'Allocation scope is healthy' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'HEALTHY' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-coverage
      exp = 100 ).
  ENDMETHOD.

  METHOD reports_no_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'NO_RUNS' ).
  ENDMETHOD.

  METHOD reports_backlog_warning.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-partial_runs = 1.
    ls_summary-unit = 'EA'.
    ls_summary-requested = 10.
    ls_summary-allocated = 6.
    ls_summary-shortage = 4.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'BACKLOG' ).
  ENDMETHOD.

  METHOD reports_stale_work_as_critical.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-running_runs = 1.
    ls_summary-oldest_running_age_seconds = 7200.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary         = ls_summary
      iv_stale_threshold = 3600 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'CRITICAL' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-stale_running_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'ERROR_OR_STALE' ).
  ENDMETHOD.

  METHOD reports_fair_share_metrics.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-fair_runs = 1.
    ls_summary-unit = 'EA'.
    ls_summary-fair_requested = 8.
    ls_summary-fair_allocated = 6.
    ls_summary-fair_shortage = 2.
    ls_summary-fair_coverage = 75.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fair_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fair_share_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fair_shortage
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fair_coverage
      exp = 75 ).
  ENDMETHOD.

  METHOD reports_adaptive_metrics.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-adaptive_runs = 1.
    ls_summary-adaptive_priority_runs = 1.
    ls_summary-adaptive_fair_runs = 0.
    ls_summary-unit = 'EA'.
    ls_summary-adaptive_requested = 10.
    ls_summary-adaptive_allocated = 7.
    ls_summary-adaptive_shortage = 3.
    ls_summary-adaptive_coverage = 70.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_priority_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_fair_runs
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_share_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_shortage
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_coverage
      exp = 70 ).
  ENDMETHOD.

  METHOD reports_weighted_metrics.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-weighted_runs = 1.
    ls_summary-unit = 'EA'.
    ls_summary-weighted_requested = 12.
    ls_summary-weighted_allocated = 9.
    ls_summary-weighted_shortage = 3.
    ls_summary-weighted_coverage = 75.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-weighted_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-weighted_share_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-weighted_shortage
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-weighted_coverage
      exp = 75 ).
  ENDMETHOD.

  METHOD reports_low_coverage_warning.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-unit = 'EA'.
    ls_summary-requested = 100.
    ls_summary-allocated = 60.
    ls_summary-shortage = 40.
    ls_summary-coverage = 60.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary      = ls_summary
      iv_min_coverage = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-coverage_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-coverage_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).
  ENDMETHOD.

  METHOD reports_high_shortage_warning.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-unit = 'EA'.
    ls_summary-requested = 100.
    ls_summary-allocated = 60.
    ls_summary-shortage = 40.
    ls_summary-shortage_pct = 40.
    ls_summary-coverage = 60.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_max_shortage_pct = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_above_threshold
      exp = abap_true ).
  ENDMETHOD.

  METHOD suppress_mixed_units.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-mixed_units = abap_true.
    ls_summary-requested = 10.
    ls_summary-allocated = 8.
    ls_summary-shortage = 2.
    ls_summary-unit = 'mixed'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-requested
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
