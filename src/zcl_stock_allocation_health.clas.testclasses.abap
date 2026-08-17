CLASS ltcl_stock_allocation_health DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reports_healthy_scope FOR TESTING.
    METHODS reports_policy_context FOR TESTING.
    METHODS reports_success_runs FOR TESTING.
    METHODS reports_run_rates FOR TESTING.
    METHODS reports_line_counts FOR TESTING.
    METHODS reports_line_rates FOR TESTING.
    METHODS reports_recency_telemetry FOR TESTING.
    METHODS reports_duration_threshold FOR TESTING.
    METHODS reports_cdur_threshold FOR TESTING.
    METHODS reports_cdur_min_threshold FOR TESTING.
    METHODS reports_completed_success FOR TESTING.
    METHODS reports_success_streak FOR TESTING.
    METHODS reports_failure_streak FOR TESTING.
    METHODS reports_avg_duration_threshold FOR TESTING.
    METHODS reports_max_duration_threshold FOR TESTING.
    METHODS reports_duration_count FOR TESTING.
    METHODS reports_run_count FOR TESTING.
    METHODS reports_deadline_count FOR TESTING.
    METHODS reports_deadline_mix_threshold FOR TESTING.
    METHODS reports_overdue_mix_threshold FOR TESTING.
    METHODS reports_current_deadline_mix FOR TESTING.
    METHODS reports_future_deadline_mix FOR TESTING.
    METHODS reports_mixed_policy_warning FOR TESTING.
    METHODS reports_mixed_unit_warning FOR TESTING.
    METHODS reports_avail_context FOR TESTING.
    METHODS reports_avail_threshold FOR TESTING.
    METHODS reports_completion_threshold FOR TESTING.
    METHODS reports_success_threshold FOR TESTING.
    METHODS reports_success_count FOR TESTING.
    METHODS reports_error_threshold FOR TESTING.
    METHODS reports_partial_threshold FOR TESTING.
    METHODS reports_full_line_threshold FOR TESTING.
    METHODS reports_unalloc_line_threshold FOR TESTING.
    METHODS reports_partial_line_threshold FOR TESTING.
    METHODS reports_full_count_threshold FOR TESTING.
    METHODS reports_demand_count_threshold FOR TESTING.
    METHODS reports_demandmin_warn FOR TESTING.
    METHODS reports_run_count_threshold FOR TESTING.
    METHODS reports_shortage_qty_threshold FOR TESTING.
    METHODS reports_core_strategy_counts FOR TESTING.
    METHODS reports_strategy_mix FOR TESTING.
    METHODS reports_core_strategy_metrics FOR TESTING.
    METHODS reports_no_runs FOR TESTING.
    METHODS reports_backlog_warning FOR TESTING.
    METHODS reports_stale_work_as_critical FOR TESTING.
    METHODS honors_zero_stale_scope FOR TESTING.
    METHODS reports_fair_share_metrics FOR TESTING.
    METHODS reports_weighted_metrics FOR TESTING.
    METHODS reports_adaptive_metrics FOR TESTING.
    METHODS reports_legacy_metrics FOR TESTING.
    METHODS reports_deadline_telemetry FOR TESTING.
    METHODS reports_low_coverage_warning FOR TESTING.
    METHODS reports_latest_cov_warning FOR TESTING.
    METHODS reports_latest_shortage_rate FOR TESTING.
    METHODS reports_latest_spct_warn FOR TESTING.
    METHODS reports_latest_age_warn FOR TESTING.
    METHODS reports_completed_demand_warn FOR TESTING.
    METHODS reports_completed_qty_warn FOR TESTING.
    METHODS reports_completed_alloc_warn FOR TESTING.
    METHODS reports_completed_req_warn FOR TESTING.
    METHODS reports_reqmin_warn FOR TESTING.
    METHODS reports_completed_amax_warn FOR TESTING.
    METHODS reports_completed_covmax_warn FOR TESTING.
    METHODS reports_completed_stock_warn FOR TESTING.
    METHODS reports_completed_full_warn FOR TESTING.
    METHODS reports_completed_fullmax_warn FOR TESTING.
    METHODS reports_unalloccnt_warn FOR TESTING.
    METHODS reports_partcnt_warn FOR TESTING.
    METHODS reports_completed_unalloc_warn FOR TESTING.
    METHODS reports_completed_partial_warn FOR TESTING.
    METHODS reports_completed_fcnt_warn FOR TESTING.
    METHODS reports_completed_acnt_warn FOR TESTING.
    METHODS reports_completed_acmax_warn FOR TESTING.
    METHODS reports_shorcnt_warn FOR TESTING.
    METHODS reports_latest_line_rates FOR TESTING.
    METHODS reports_latest_shortage_warn FOR TESTING.
    METHODS reports_high_shortage_warning FOR TESTING.
    METHODS suppress_mixed_units FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_health IMPLEMENTATION.
  METHOD reports_healthy_scope.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 3.
    ls_summary-preview_runs = 1.
    ls_summary-operational_runs = 2.
    ls_summary-deadline_count = 1.
    ls_summary-deadline_mix_pct = '33.33'.
    ls_summary-overdue_count = 1.
    ls_summary-overdue_mix_pct = '33.33'.
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
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-preview_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-operational_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-preview_mix_pct
      exp = '33.33' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-operational_mix_pct
      exp = '66.67' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_mix_pct
      exp = '33.33' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_mix_pct
      exp = '33.33' ).
  ENDMETHOD.

  METHOD reports_policy_context.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-policy_context_available = abap_true.
    ls_summary-mixed_policies = abap_false.
    ls_summary-movement_type_context = '201'.
    ls_summary-min_shelf_life_context = 5.
    ls_summary-safety_stock_context = 3.
    ls_summary-last_requested_on_from = '20260801'.
    ls_summary-last_requested_on_to = '20260807'.
    ls_summary-last_requested_deadline = '20260807'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-policy_context_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_policies
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-movement_type_context
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-minimum_shelf_life_context
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-safety_stock_context
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_requested_on_from
      exp = '20260801' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_requested_on_to
      exp = '20260807' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_requested_deadline
      exp = '20260807' ).

    ls_summary-mixed_policies = abap_true.
    ls_summary-movement_type_context = 'mixed'.
    CLEAR: ls_summary-min_shelf_life_context,
           ls_summary-safety_stock_context.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_policies
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-movement_type_context
      exp = 'mixed' ).
    cl_abap_unit_assert=>assert_initial(
      ls_health-minimum_shelf_life_context ).

    ls_summary-mixed_units = abap_true.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_units
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_available
      exp = abap_false ).
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
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_run_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_metrics_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_deadline_age_reason
      exp = 'no_completed_run' ).
    cl_abap_unit_assert=>assert_initial( ls_health-priority_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-legacy_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-preview_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-operational_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-deadline_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-overdue_count ).
    cl_abap_unit_assert=>assert_initial(
      ls_health-current_deadline_count ).
    cl_abap_unit_assert=>assert_initial( ls_health-future_deadline_count ).
    cl_abap_unit_assert=>assert_initial( ls_health-overdue_mix_pct ).
    cl_abap_unit_assert=>assert_initial(
      ls_health-current_deadline_mix_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-future_deadline_mix_pct ).
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
      act = ls_health-stale_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-stale_threshold
      exp = 3600 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-stale_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'ERROR_OR_STALE' ).
  ENDMETHOD.

  METHOD reports_success_runs.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-success_runs = 3.
    ls_summary-partial_runs = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_runs
      exp = 3 ).
  ENDMETHOD.

  METHOD reports_run_rates.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 5.
    ls_summary-success_runs = 2.
    ls_summary-partial_runs = 1.
    ls_summary-error_runs = 1.
    ls_summary-completion_pct = '80.00'.
    ls_summary-success_rate_pct = '50.00'.
    ls_summary-partial_rate_pct = '25.00'.
    ls_summary-error_rate_pct = '25.00'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-completion_pct
      exp = '80.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_rate_pct
      exp = '50.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_rate_pct
      exp = '25.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-error_rate_pct
      exp = '25.00' ).
  ENDMETHOD.

  METHOD reports_line_counts.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-demand_count = 7.
    ls_summary-full_count = 3.
    ls_summary-partial_count = 2.
    ls_summary-unallocated_count = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-demand_count
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-unallocated_count
      exp = 2 ).
  ENDMETHOD.

  METHOD reports_line_rates.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-demand_count = 10.
    ls_summary-full_count = 5.
    ls_summary-partial_count = 3.
    ls_summary-unallocated_count = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_line_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_line_pct
      exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-unallocated_line_pct
      exp = 20 ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).
    cl_abap_unit_assert=>assert_initial( ls_health-full_line_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-partial_line_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-unallocated_line_pct ).
  ENDMETHOD.

  METHOD reports_recency_telemetry.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 3.
    ls_summary-last_run_id = 'RUN-HEALTH-LAST'.
    ls_summary-last_avail = 12.
    ls_summary-last_avail_unit = 'EA'.
    ls_summary-last_avail_ok = abap_true.
    ls_summary-last_requested = 20.
    ls_summary-last_allocated = 12.
    ls_summary-last_shortage = 8.
    ls_summary-last_coverage = 60.
    ls_summary-last_demand = 4.
    ls_summary-last_full = 2.
    ls_summary-last_partial = 1.
    ls_summary-last_unalloc = 1.
    ls_summary-last_strategy = 'F'.
    ls_summary-last_status = 'S'.
    ls_summary-last_start_date = '20260813'.
    ls_summary-last_start_time = '101530'.
    ls_summary-last_finish_date = '20260813'.
    ls_summary-last_finish_time = '101532'.
    ls_summary-last_duration_seconds = 2.
    ls_summary-average_duration_seconds = '2.50'.
    ls_summary-minimum_duration_seconds = 1.
    ls_summary-maximum_duration_seconds = 5.
    ls_summary-completed_duration_runs = 2.
    ls_summary-oldest_running_age_seconds = 7200.
    ls_summary-oldest_running_run_id = 'RUN-HEALTH-OLD'.
    ls_summary-newest_running_age_seconds = 120.
    ls_summary-newest_running_run_id = 'RUN-HEALTH-NEW'.
    ls_summary-last_message = 'Completed successfully'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_run_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_metrics_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_run_id
      exp = 'RUN-HEALTH-LAST' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_available_stock_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_available_stock
      exp = 12 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_available_stock_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_requested_quantity
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_allocated_quantity
      exp = 12 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_quantity
      exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_coverage_pct
      exp = 60 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_demand_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_full_line_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_partial_line_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_unallocated_line_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_strategy
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_status
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_start_date
      exp = '20260813' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_finish_time
      exp = '101532' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_duration_seconds
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-average_duration_seconds
      exp = '2.50' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-minimum_duration_seconds
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-maximum_duration_seconds
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-completed_duration_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-oldest_running_age_seconds
      exp = 7200 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-oldest_running_run_id
      exp = 'RUN-HEALTH-OLD' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-newest_running_age_seconds
      exp = 120 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-newest_running_run_id
      exp = 'RUN-HEALTH-NEW' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_run_message
      exp = 'Completed successfully' ).
  ENDMETHOD.

  METHOD reports_duration_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_run_id = 'RUN-HEALTH-SLOW'.
    ls_summary-last_status = 'S'.
    ls_summary-last_finish_date = '20260813'.
    ls_summary-last_finish_time = '101532'.
    ls_summary-last_duration_seconds = 12.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_max_last_duration = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_duration_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_threshold
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_summary-last_run_id = 'RUN-HEALTH-RUNNING'.
    ls_summary-last_status = 'R'.
    ls_summary-last_duration_seconds = 999.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_max_last_duration = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_duration_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_cdur_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-last_run_id = 'RUN-HEALTH-RUNNING'.
    ls_summary-last_status = 'R'.
    ls_summary-last_completed_run_id = 'RUN-HEALTH-COMPLETED'.
    ls_summary-last_completed_duration = 24.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_completed_duration = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_limit
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_duration' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_completed_duration = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_cdur_min_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-last_run_id = 'RUN-HEALTH-RUNNING'.
    ls_summary-last_status = 'R'.
    ls_summary-last_completed_run_id = 'RUN-HEALTH-COMPLETED'.
    ls_summary-last_completed_duration = 4.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_min_last_completed_duration = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_dur_min_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_min_limit
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_duration_min' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_min_last_completed_duration = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_below_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_success.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-last_run_id = 'RUN-HEALTH-RUNNING'.
    ls_summary-last_status = 'R'.
    ls_summary-last_completed_run_id = 'RUN-HEALTH-COMPLETED'.
    ls_summary-last_completed_status = 'P'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_require_last_comp_success = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_success_required_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_success_breach
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_not_success' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_require_last_comp_success = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_success_breach
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_success_streak.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 3.
    ls_summary-last_completed_run_id = 'RUN-HEALTH-COMPLETED'.
    ls_summary-last_completed_success_streak = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_min_last_comp_succ_streak = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_success_streak
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_succ_streak_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_success_streak_limit
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_cmp_succ_streak_below_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_success_streak' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_min_last_comp_succ_streak = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_cmp_succ_streak_below_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_failure_streak.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 3.
    ls_summary-last_completed_run_id = 'RUN-HEALTH-FAILURE-STREAK'.
    ls_summary-last_comp_non_success_streak = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_max_last_comp_fail_streak = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_non_success_streak
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_non_success_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_non_success_limit
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_non_succ_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_non_success_streak' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_max_last_comp_fail_streak = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_non_succ_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_avg_duration_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-completed_duration_runs = 4.
    ls_summary-average_duration_seconds = '12.50'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary              = ls_summary
      iv_max_average_duration = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-average_duration_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-average_duration_threshold
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-average_duration_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'average_duration' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary              = ls_summary
      iv_max_average_duration = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-average_duration_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_max_duration_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-completed_duration_runs = 4.
    ls_summary-maximum_duration_seconds = 22.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                = ls_summary
      iv_max_completed_duration = 15 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-maximum_duration_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-maximum_duration_threshold
      exp = 15 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-maximum_duration_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'maximum_duration' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                = ls_summary
      iv_max_completed_duration = 15 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-maximum_duration_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_duration_count.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-completed_duration_runs = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_min_duration_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_count_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_count_threshold
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_count_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'duration_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_summary-total_runs = 1.
    ls_summary-completed_duration_runs = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_min_duration_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-duration_count_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_run_count.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary       = ls_summary
      iv_min_run_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-run_count_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-run_count_threshold
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-run_count_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'run_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary       = ls_summary
      iv_min_run_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-run_count_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_deadline_count.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-deadline_count = 1.
    ls_summary-deadline_mix_pct = '25'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_min_deadline_count = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_count_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_mix_pct
      exp = '25' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_count_threshold
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_count_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'deadline_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_min_deadline_count = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_count_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_deadline_mix_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-deadline_count = 1.
    ls_summary-deadline_mix_pct = '25'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_min_deadline_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_mix_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_mix_threshold
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_mix_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'deadline_mix' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_min_deadline_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_mix_below_threshold
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-threshold_breach_count ).
  ENDMETHOD.

  METHOD reports_overdue_mix_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-deadline_count = 4.
    ls_summary-overdue_count = 3.
    ls_summary-overdue_mix_pct = '75'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary         = ls_summary
      iv_max_overdue_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_mix_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_mix_threshold
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_mix_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'overdue_mix' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary         = ls_summary
      iv_max_overdue_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_mix_above_threshold
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-threshold_breach_count ).
  ENDMETHOD.

  METHOD reports_current_deadline_mix.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-deadline_count = 4.
    ls_summary-current_deadline_count = 3.
    ls_summary-current_deadline_mix_pct = '75'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                  = ls_summary
      iv_max_current_deadline_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-current_deadline_mix_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-current_deadline_mix_threshold
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-curr_deadline_mix_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'current_deadline_mix' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                  = ls_summary
      iv_max_current_deadline_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-curr_deadline_mix_above_limit
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-threshold_breach_count ).
  ENDMETHOD.

  METHOD reports_future_deadline_mix.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-deadline_count = 4.
    ls_summary-future_deadline_count = 1.
    ls_summary-future_deadline_mix_pct = '25'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_min_future_deadline_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-future_deadline_mix_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-future_deadline_mix_threshold
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fut_deadline_mix_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'future_deadline_mix' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_min_future_deadline_mix = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fut_deadline_mix_below_limit
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-threshold_breach_count ).
  ENDMETHOD.

  METHOD reports_mixed_policy_warning.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-policy_context_available = abap_true.
    ls_summary-mixed_policies = abap_true.
    ls_summary-movement_type_context = 'mixed'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_warn_mixed_policies = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_policy_warning_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_policy_breach
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'mixed_policies' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_warn_mixed_policies = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_policy_warning_active
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_policy_breach
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_mixed_unit_warning.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-mixed_units = abap_true.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_warn_mixed_units = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_unit_warning_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_unit_breach
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'mixed_units' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_warn_mixed_units = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_unit_warning_active
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_unit_breach
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_avail_context.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-available_context = 25.
    ls_summary-available_context_ok = abap_true.
    ls_summary-mixed_available = abap_false.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-avail_stock_context_avail
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-available_stock_context
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_available_stock
      exp = abap_false ).

    CLEAR ls_summary.
    ls_summary-total_runs = 2.
    ls_summary-mixed_units = abap_true.
    ls_summary-mixed_available = abap_true.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-avail_stock_context_avail
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-mixed_available_stock
      exp = abap_true ).
  ENDMETHOD.

  METHOD reports_avail_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-available_context = 5.
    ls_summary-available_context_ok = abap_true.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_available_stock = 6
      iv_max_available_stock = 10 ).

    cl_abap_unit_assert=>assert_true(
      ls_health-avail_stock_min_limit_active ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-avail_stock_min_threshold
      exp = 6 ).
    cl_abap_unit_assert=>assert_true(
      ls_health-avail_stock_below_threshold ).
    cl_abap_unit_assert=>assert_false(
      ls_health-avail_stock_above_threshold ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'available_stock_min' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_available_stock = 1
      iv_max_available_stock = 4 ).

    cl_abap_unit_assert=>assert_false(
      ls_health-avail_stock_below_threshold ).
    cl_abap_unit_assert=>assert_true(
      ls_health-avail_stock_above_threshold ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'available_stock_max' ).

    ls_summary-available_context_ok = abap_false.
    ls_summary-mixed_available = abap_true.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_available_stock = 6
      iv_max_available_stock = 4 ).

    cl_abap_unit_assert=>assert_false(
      ls_health-avail_stock_below_threshold ).
    cl_abap_unit_assert=>assert_false(
      ls_health-avail_stock_above_threshold ).
  ENDMETHOD.

  METHOD reports_completion_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 5.
    ls_summary-completion_pct = '60.00'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_completion_rate = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-completion_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-completion_threshold
      exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-completion_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'completion' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_completion_rate = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-completion_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_success_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 5.
    ls_summary-success_runs = 2.
    ls_summary-success_rate_pct = '40.00'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_min_success_rate = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_threshold
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'success' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    ls_summary-requested = 100.
    ls_summary-allocated = 80.
    ls_summary-shortage = 20.
    ls_summary-coverage = 80.
    ls_summary-shortage_pct = 20.
    ls_summary-last_run_id = 'RUN-HEALTH-MULTI'.
    ls_summary-last_status = 'S'.
    ls_summary-last_finish_date = '20260813'.
    ls_summary-last_finish_time = '101532'.
    ls_summary-last_duration_seconds = 12.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_min_coverage      = 90
      iv_max_shortage_pct  = 10
      iv_max_last_duration = 10
      iv_min_success_rate  = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'coverage|shortage|duration|success' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_min_success_rate = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_threshold_active
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_success_count.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 4.
    ls_summary-success_runs = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_min_success_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_count_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_count_threshold
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_count_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'success_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_min_success_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-success_count_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_error_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 5.
    ls_summary-error_runs = 1.
    ls_summary-error_rate_pct = '20.00'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary        = ls_summary
      iv_max_error_rate = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-error_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-error_threshold
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-error_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'error' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'CRITICAL' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary        = ls_summary
      iv_max_error_rate = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-error_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_partial_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 8.
    ls_summary-partial_runs = 3.
    ls_summary-partial_rate_pct = '37.50'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_max_partial_rate = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_threshold
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'partial' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_max_partial_rate = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_full_line_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-demand_count = 10.
    ls_summary-full_count = 4.
    ls_summary-partial_count = 3.
    ls_summary-unallocated_count = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_min_full_line_rate = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_line_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_line_threshold
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_line_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'full_line' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_min_full_line_rate = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_line_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_unalloc_line_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-demand_count = 10.
    ls_summary-full_count = 4.
    ls_summary-partial_count = 2.
    ls_summary-unallocated_count = 4.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_unalloc_line_rate = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-unallocated_line_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-unallocated_line_threshold
      exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-unallocated_line_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'unallocated_line' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_unalloc_line_rate = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-unallocated_line_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_partial_line_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-demand_count = 10.
    ls_summary-full_count = 4.
    ls_summary-partial_count = 4.
    ls_summary-unallocated_count = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_partial_line_rate = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_line_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_line_threshold
      exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_line_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'partial_line' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_partial_line_rate = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-partial_line_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_full_count_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-demand_count = 5.
    ls_summary-full_count = 2.
    ls_summary-partial_count = 1.
    ls_summary-unallocated_count = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_full_line_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_count_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_count_threshold
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_count_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'full_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary             = ls_summary
      iv_min_full_line_count = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_count_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_demand_count_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-demand_count = 11.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_max_demand_count = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-demand_count_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-demand_count_threshold
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-demand_count_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'demand_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary          = ls_summary
      iv_max_demand_count = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-demand_count_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_demandmin_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-DEMAND-MIN'.
    ls_summary-last_completed_demand = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_min_last_comp_demand_count = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_cmp_demand_cnt_min_lim_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_cnt_min_limit
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_cnt_below_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_demand_count_min' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_min_last_comp_demand_count = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_cnt_below_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_run_count_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 3.
    ls_summary-running_runs = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_max_running_count = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-running_count_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-running_count_threshold
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-running_count_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'running_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_max_running_count = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-running_count_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_shortage_qty_threshold.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-requested = 100.
    ls_summary-allocated = 70.
    ls_summary-shortage = 30.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_shortage_quantity = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_quantity_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_quantity_threshold
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_quantity_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breach_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'shortage_quantity' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-reason_code
      exp = 'THRESHOLD_BREACH' ).

    ls_summary-mixed_units = abap_true.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_shortage_quantity = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_quantity_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_core_strategy_counts.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 12.
    ls_summary-priority_runs = 2.
    ls_summary-fifo_runs = 3.
    ls_summary-full_only_runs = 1.
    ls_summary-smallest_runs = 2.
    ls_summary-largest_runs = 1.
    ls_summary-best_runs = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fifo_runs
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_only_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-smallest_runs
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-largest_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-best_runs
      exp = 3 ).
  ENDMETHOD.

  METHOD reports_strategy_mix.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 20.
    ls_summary-priority_runs = 2.
    ls_summary-fifo_runs = 4.
    ls_summary-full_only_runs = 2.
    ls_summary-smallest_runs = 3.
    ls_summary-largest_runs = 1.
    ls_summary-best_runs = 2.
    ls_summary-fair_runs = 2.
    ls_summary-weighted_runs = 1.
    ls_summary-adaptive_runs = 2.
    ls_summary-legacy_strategy_runs = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_mix_pct
      exp = '10.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fifo_mix_pct
      exp = '20.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_only_mix_pct
      exp = '10.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-smallest_mix_pct
      exp = '15.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-largest_mix_pct
      exp = '5.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-best_mix_pct
      exp = '10.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fair_mix_pct
      exp = '10.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-weighted_mix_pct
      exp = '5.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-adaptive_mix_pct
      exp = '10.00' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_mix_pct
      exp = '5.00' ).
  ENDMETHOD.

  METHOD honors_zero_stale_scope.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-running_runs = 1.
    ls_summary-oldest_running_age_seconds = 7200.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_stale_running_runs    = 0
      iv_stale_scope_evaluated = abap_true
      iv_stale_threshold       = 3600 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'HEALTHY' ).
    cl_abap_unit_assert=>assert_initial( ls_health-stale_running_runs ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-stale_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-stale_above_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_core_strategy_metrics.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 6.
    ls_summary-unit = 'EA'.
    ls_summary-priority_requested = 10.
    ls_summary-priority_allocated = 8.
    ls_summary-priority_shortage = 2.
    ls_summary-priority_coverage = 80.
    ls_summary-fifo_requested = 9.
    ls_summary-fifo_allocated = 9.
    ls_summary-fifo_coverage = 100.
    ls_summary-full_only_requested = 7.
    ls_summary-full_only_allocated = 5.
    ls_summary-full_only_shortage = 2.
    ls_summary-full_only_coverage = '71.43'.
    ls_summary-smallest_requested = 6.
    ls_summary-smallest_allocated = 4.
    ls_summary-smallest_shortage = 2.
    ls_summary-smallest_coverage = '66.67'.
    ls_summary-largest_requested = 8.
    ls_summary-largest_allocated = 6.
    ls_summary-largest_shortage = 2.
    ls_summary-largest_coverage = 75.
    ls_summary-best_requested = 5.
    ls_summary-best_allocated = 5.
    ls_summary-best_coverage = 100.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_share_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_requested
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_allocated
      exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_shortage
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_coverage
      exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fifo_requested
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-fifo_coverage
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_only_shortage
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-full_only_coverage
      exp = '71.43' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-smallest_allocated
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-smallest_coverage
      exp = '66.67' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-largest_requested
      exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-largest_coverage
      exp = 75 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-best_allocated
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-best_coverage
      exp = 100 ).
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

  METHOD reports_legacy_metrics.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-legacy_strategy_runs = 1.
    ls_summary-unit = 'EA'.
    ls_summary-legacy_requested = 9.
    ls_summary-legacy_allocated = 6.
    ls_summary-legacy_shortage = 3.
    ls_summary-legacy_coverage = '66.67'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_runs
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_share_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_requested
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_allocated
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_shortage
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-legacy_coverage
      exp = '66.67' ).
  ENDMETHOD.

  METHOD reports_deadline_telemetry.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-deadline_count = 2.
    ls_summary-deadline_mix_pct = 100.
    ls_summary-overdue_count = 1.
    ls_summary-current_deadline_count = 1.
    ls_summary-overdue_mix_pct = 50.
    ls_summary-current_deadline_mix_pct = 50.
    ls_summary-last_requested_deadline = '20260808'.
    ls_summary-earliest_requested_deadline = '20260801'.
    ls_summary-latest_requested_deadline = '20260811'.
    ls_summary-last_deadline_age_days = 3.
    ls_summary-oldest_deadline_age_days = 7.
    ls_summary-newest_deadline_age_days = -2.
    ls_summary-last_deadline_urgency = 'overdue'.
    ls_summary-oldest_deadline_urgency = 'overdue'.
    ls_summary-newest_deadline_urgency = 'future'.
    ls_summary-deadline_age_reference_date = '20260811'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-current_deadline_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-overdue_mix_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-current_deadline_mix_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-earliest_requested_deadline
      exp = '20260801' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-latest_requested_deadline
      exp = '20260811' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_deadline_age_days
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_deadline_urgency
      exp = 'overdue' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-oldest_deadline_age_days
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-oldest_deadline_urgency
      exp = 'overdue' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-newest_deadline_age_days
      exp = -2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-newest_deadline_urgency
      exp = 'future' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-deadline_age_reference_date
      exp = '20260811' ).
    CLEAR ls_summary.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_deadline_urgency
      exp = 'n/a' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-oldest_deadline_urgency
      exp = 'n/a' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-newest_deadline_urgency
      exp = 'n/a' ).
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
      act = ls_health-coverage_threshold
      exp = 80 ).
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
      act = ls_health-shortage_threshold
      exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_above_threshold
      exp = abap_true ).
  ENDMETHOD.

  METHOD reports_latest_cov_warning.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-last_run_id = 'RUN-LATEST-COVERAGE'.
    ls_summary-last_requested = 100.
    ls_summary-last_allocated = 60.
    ls_summary-last_coverage = 60.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_min_last_coverage = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_coverage_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_coverage_threshold
      exp = 80 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_coverage_below_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_coverage' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_requested = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary           = ls_summary
      iv_min_last_coverage = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_coverage_below_threshold
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_latest_shortage_rate.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_run_id = 'RUN-LATEST-SHORTAGE-RATE'.
    ls_summary-last_requested = 80.
    ls_summary-last_shortage = 20.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct
      exp = 25 ).

    ls_summary-last_requested = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-last_shortage_pct ).
  ENDMETHOD.

  METHOD reports_latest_spct_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_run_id = 'RUN-LATEST-SHORTAGE-PCT'.
    ls_summary-last_requested = 100.
    ls_summary-last_shortage = 20.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_last_shortage_pct = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct_threshold
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_shortage_pct' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_requested = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_last_shortage_pct = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_pct_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_latest_age_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_run_id = 'RUN-LATEST-AGE'.
    ls_summary-last_preview = abap_true.
    ls_summary-last_status = 'S'.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-AGE'.
    ls_summary-last_completed_preview = abap_true.
    ls_summary-last_completed_finish_date = '20260812'.
    ls_summary-last_completed_finish_time = '120000'.
    ls_summary-last_completed_status = 'S'.
    ls_summary-last_completed_message = 'completed diagnostic'.
    ls_summary-last_completed_start_date = '20260812'.
    ls_summary-last_completed_start_time = '110000'.
    ls_summary-last_comp_policy_available = abap_true.
    ls_summary-last_completed_movement_type = '201'.
    ls_summary-last_completed_min_shelf_life = 5.
    ls_summary-last_completed_safety_stock = 3.
    ls_summary-last_comp_horizon_available = abap_true.
    ls_summary-last_comp_requested_on_from = '20260801'.
    ls_summary-last_completed_requested_on_to = '20260807'.
    ls_summary-last_comp_requested_deadline = '20260807'.
    ls_summary-last_comp_deadline_age_avail = abap_true.
    ls_summary-last_comp_deadline_age_reason = 'available'.
    ls_summary-last_comp_deadline_age_days = 3.
    ls_summary-last_comp_deadline_urgency = 'overdue'.
    ls_summary-last_completed_duration = 45.
    ls_summary-last_completed_requested = 1.
    ls_summary-last_completed_allocated = 1.
    ls_summary-last_completed_shortage = 0.
    ls_summary-last_completed_coverage = 100.
    ls_summary-last_completed_demand = 1.
    ls_summary-last_completed_avail = 25.
    ls_summary-last_completed_avail_unit = 'EA'.
    ls_summary-last_completed_avail_ok = abap_true.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_last_age_available          = abap_true
      iv_last_age_seconds            = 7200
      iv_last_age_reference_date     = '20260813'
      iv_last_age_reference_time     = '150000'
      iv_max_last_age                = 3600
      iv_max_last_comp_deadline_age  = 2
      iv_min_last_completed_coverage = 90
      iv_max_last_comp_shortage_pct  = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_seconds
      exp = 7200 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_reason
      exp = 'available' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_reference_date
      exp = '20260813' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_reference_time
      exp = '150000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_run_id
      exp = 'RUN-COMPLETED-AGE' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_preview
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_preview
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_duration_seconds
      exp = 45 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_message
      exp = 'completed diagnostic' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_start_date
      exp = '20260812' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_start_time
      exp = '110000' ).
    cl_abap_unit_assert=>assert_true(
      ls_health-last_comp_policy_available ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_movement_type
      exp = '201' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_min_shelf_life
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_safety_stock
      exp = 3 ).
    cl_abap_unit_assert=>assert_true(
      ls_health-last_comp_horizon_available ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_requested_on_from
      exp = '20260801' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_requested_on_to
      exp = '20260807' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_requested_deadline
      exp = '20260807' ).
    cl_abap_unit_assert=>assert_true(
      ls_health-last_comp_deadline_age_avail ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_deadline_age_reason
      exp = 'available' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_deadline_age_days
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_deadline_urgency
      exp = 'overdue' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_available_stock
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_available_stock_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_true(
      ls_health-last_comp_avail_stock_avail ).
    ls_summary-last_completed_avail = 0.
    ls_summary-last_completed_avail_ok = abap_true.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_last_age_available          = abap_true
      iv_last_age_seconds            = 7200
      iv_last_age_reference_date     = '20260813'
      iv_last_age_reference_time     = '150000'
      iv_max_last_age                = 3600
      iv_max_last_comp_deadline_age  = 2
      iv_min_last_completed_coverage = 90
      iv_max_last_comp_shortage_pct  = 10 ).
    cl_abap_unit_assert=>assert_true(
      ls_health-last_comp_avail_stock_avail ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_available_stock
      exp = 0 ).
    ls_summary-last_comp_deadline_age_avail = abap_false.
    ls_summary-last_comp_deadline_age_reason = 'no_deadline'.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_deadline_age = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_ddl_age_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_ddl_age_above_limit
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_deadline_age_reason
      exp = 'no_deadline' ).
    ls_summary-last_comp_deadline_age_avail = abap_true.
    ls_summary-last_comp_deadline_age_reason = 'available'.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_last_age_available          = abap_true
      iv_last_age_seconds            = 7200
      iv_last_age_reference_date     = '20260813'
      iv_last_age_reference_time     = '150000'
      iv_max_last_age                = 3600
      iv_max_last_comp_deadline_age  = 2
      iv_min_last_completed_coverage = 90
      iv_max_last_comp_shortage_pct  = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_requested
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_allocated
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_shortage
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_demand
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_shortage_pct_avail
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_shortage_pct
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_line_rates_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_completed_full_line_pct
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_threshold_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_threshold
      exp = 3600 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_above_threshold
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_ddl_age_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_deadline_age_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_ddl_age_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_below_limit
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_pct_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_pct_above_lim
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_age|last_completed_deadline_age' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary            = ls_summary
      iv_last_age_available = abap_false
      iv_last_age_seconds   = 7200
      iv_max_last_age       = 3600 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-last_age_seconds ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_reason
      exp = 'unavailable' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_above_threshold
      exp = abap_false ).

    ls_summary-last_completed_coverage = 50.
    ls_summary-last_completed_shortage = 1.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_min_last_completed_coverage = 90
      iv_max_last_comp_shortage_pct  = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_pct_above_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_coverage|last_completed_shortage_pct' ).

    ls_summary-last_completed_requested = 0.
    ls_summary-last_completed_demand = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_last_age_available          = abap_false
      iv_min_last_completed_coverage = 90
      iv_max_last_comp_shortage_pct  = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_shortage_pct_avail
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial(
      ls_health-last_completed_shortage_pct ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_line_rates_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial(
      ls_health-last_completed_full_line_pct ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_age_reason
      exp = 'unavailable' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_below_limit
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_pct_above_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_demand_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-DEMAND'.
    ls_summary-last_completed_demand = 5.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_demand_count = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_cnt_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_count_limit
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_cnt_above_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_demand_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_demand_count = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_demand_cnt_above_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_qty_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-SHORTAGE'.
    ls_summary-last_completed_shortage = 5.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_shortage_qty = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_qty_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_shortage_qty_limit
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_qty_above_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_shortage_quantity' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_shortage = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_shortage_qty = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_qty_above_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_alloc_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-ALLOCATED'.
    ls_summary-last_completed_requested = 10.
    ls_summary-last_completed_allocated = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_min_last_comp_allocated = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_allocated_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_allocated_limit
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_allocated' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_requested = 0.
    ls_summary-last_completed_allocated = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_min_last_comp_allocated = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_below_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_req_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-REQUESTED'.
    ls_summary-last_completed_requested = 10.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_max_last_comp_requested = 8 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_requested_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_requested_limit
      exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_req_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_requested' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_requested = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_max_last_comp_requested = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_req_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_reqmin_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-REQUEST-MIN'.
    ls_summary-last_completed_demand = 2.
    ls_summary-last_completed_requested = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_min_last_comp_requested = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_req_min_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_requested_min_limit
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_req_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_requested_min' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_requested = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_min_last_comp_requested = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_req_below_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_amax_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-ALLOC-MAX'.
    ls_summary-last_completed_requested = 10.
    ls_summary-last_completed_allocated = 8.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_max_last_comp_allocated = 7 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_max_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_allocated_max_limit
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_allocated_max' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_requested = 0.
    ls_summary-last_completed_allocated = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                 = ls_summary
      iv_max_last_comp_allocated = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_covmax_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-COVERAGE-MAX'.
    ls_summary-last_completed_requested = 10.
    ls_summary-last_completed_allocated = 10.
    ls_summary-last_completed_coverage = 100.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_completed_coverage = 95 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_cov_max_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_max_limit
      exp = 95 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_coverage_max' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_requested = 0.
    ls_summary-last_completed_allocated = 0.
    ls_summary-last_completed_coverage = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_completed_coverage = 95 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_coverage_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_stock_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-STOCK'.
    ls_summary-last_completed_avail = 3.
    ls_summary-last_completed_avail_ok = abap_true.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_min_last_comp_avail_stock = 4
      iv_max_last_comp_avail_stock = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_min_lim_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_min_limit
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_below_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_max_lim_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_max_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_above_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_available_stock_min|last_completed_available_stock_max' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_avail_ok = abap_false.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_min_last_comp_avail_stock = 4
      iv_max_last_comp_avail_stock = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_below_lim
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_avail_stk_above_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_full_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-FULL'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_full = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_min_last_comp_full_ln_rate = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_line_rates_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_line_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_line_limit
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_ln_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_full_line' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_full = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_min_last_comp_full_ln_rate = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_ln_below_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_fullmax_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-FULL-MAX'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_full = 4.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_full_ln_rate = 95 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_ln_max_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_line_max_limit
      exp = 95 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_ln_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_full_line_max' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_full = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_full_ln_rate = 95 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_ln_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_unalloccnt_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-UNALLOC-COUNT'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_unalloc = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_comp_unalloc_count = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_cnt_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_count_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_cnt_over_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_unallocated_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_unalloc = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_comp_unalloc_count = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_cnt_over_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_partcnt_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-PARTIAL-COUNT'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_partial = 3.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_comp_partial_count = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_partial_cnt_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_partial_count_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_part_cnt_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_partial_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_partial = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_max_last_comp_partial_count = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_part_cnt_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_shorcnt_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-SHORTAGE-COUNT'.
    ls_summary-last_completed_demand = 5.
    ls_summary-last_completed_partial = 1.
    ls_summary-last_completed_unalloc = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_shortage_cnt = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_cnt_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_shortage_count_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_cnt_above_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_shortage_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_partial = 0.
    ls_summary-last_completed_unalloc = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_shortage_cnt = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_short_cnt_above_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_unalloc_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-UNALLOC'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_unalloc = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_unalloc_rate = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_line_rates_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_ln_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_line_limit
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_ln_above_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_unallocated_line' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_unalloc = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_unalloc_rate = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_unalloc_ln_above_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_partial_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-PARTIAL'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_partial = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_partial_rate = 25 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_line_rates_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_part_line_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_partial_line_limit
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_part_ln_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_partial_line' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_partial = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                    = ls_summary
      iv_max_last_comp_partial_rate = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_part_ln_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_fcnt_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-FULL-COUNT'.
    ls_summary-last_completed_demand = 4.
    ls_summary-last_completed_full = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_min_last_comp_full_ln_count = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_line_rates_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_count_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_count_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_cnt_below_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_full_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_full = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                     = ls_summary
      iv_min_last_comp_full_ln_count = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_full_cnt_below_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_acnt_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-ALLOCATED-COUNT'.
    ls_summary-last_completed_demand = 5.
    ls_summary-last_completed_full = 1.
    ls_summary-last_completed_partial = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_min_last_comp_alloc_lines = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_allocated_line_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_count_limit_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_count_limit
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_cnt_below_lim
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_allocated_count' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_full = 0.
    ls_summary-last_completed_partial = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_min_last_comp_alloc_lines = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_cnt_below_lim
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_completed_acmax_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_completed_run_id = 'RUN-COMPLETED-ALLOCATED-COUNT-MAX'.
    ls_summary-last_completed_demand = 5.
    ls_summary-last_completed_full = 1.
    ls_summary-last_completed_partial = 2.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_max_last_comp_alloc_lines = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_allocated_line_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_cnt_max_lim_on
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_alloc_cnt_max_limit
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_acnt_max_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_completed_allocated_count_max' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_completed_demand = 0.
    ls_summary-last_completed_full = 0.
    ls_summary-last_completed_partial = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary                   = ls_summary
      iv_max_last_comp_alloc_lines = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_comp_acnt_max_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD reports_latest_line_rates.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 1.
    ls_summary-last_run_id = 'RUN-LATEST-LINES'.
    ls_summary-last_demand = 4.
    ls_summary-last_full = 2.
    ls_summary-last_partial = 1.
    ls_summary-last_unalloc = 1.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_line_rates_available
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_full_line_pct
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_partial_line_pct
      exp = 25 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_unallocated_line_pct
      exp = 25 ).

    ls_summary-last_demand = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_line_rates_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_initial( ls_health-last_full_line_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-last_partial_line_pct ).
    cl_abap_unit_assert=>assert_initial( ls_health-last_unallocated_line_pct ).
  ENDMETHOD.

  METHOD reports_latest_shortage_warn.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-last_run_id = 'RUN-LATEST-SHORTAGE'.
    ls_summary-last_requested = 100.
    ls_summary-last_shortage = 12.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_last_shortage_qty = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_qty_limit_active
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_qty_threshold
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_qty_above_limit
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-threshold_breaches
      exp = 'last_shortage_quantity' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-status
      exp = 'WARNING' ).

    ls_summary-last_requested = 0.
    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary               = ls_summary
      iv_max_last_shortage_qty = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-last_shortage_qty_above_limit
      exp = abap_false ).
  ENDMETHOD.

  METHOD suppress_mixed_units.
    DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
    DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.

    ls_summary-total_runs = 2.
    ls_summary-mixed_units = abap_true.
    ls_summary-requested = 10.
    ls_summary-allocated = 8.
    ls_summary-shortage = 2.
    ls_summary-priority_requested = 4.
    ls_summary-priority_allocated = 3.
    ls_summary-priority_shortage = 1.
    ls_summary-unit = 'mixed'.

    ls_health = zcl_stock_allocation_health=>evaluate(
      is_summary = ls_summary ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_health-shortage_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-requested
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_share_available
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_health-priority_requested
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
