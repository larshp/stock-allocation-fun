CLASS zcl_stock_allocation_health DEFINITION  PUBLIC  FINAL  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES ty_status TYPE c LENGTH 8.
    TYPES:      BEGIN OF ty_health,
        status                         TYPE ty_status,
        message                        TYPE zif_allocation_audit=>ty_message,
        reason_code                    TYPE c LENGTH 16,
        total_runs                     TYPE i,
        preview_runs                   TYPE i,
        operational_runs               TYPE i,
        preview_mix_pct                TYPE zif_allocation_audit=>ty_coverage,
        operational_mix_pct            TYPE zif_allocation_audit=>ty_coverage,
        deadline_mix_pct               TYPE zif_allocation_audit=>ty_coverage,
        overdue_count                  TYPE i,
        current_deadline_count         TYPE i,
        future_deadline_count          TYPE i,
        overdue_mix_pct                TYPE zif_allocation_audit=>ty_coverage,
        current_deadline_mix_pct       TYPE zif_allocation_audit=>ty_coverage,
        future_deadline_mix_pct        TYPE zif_allocation_audit=>ty_coverage,
        deadline_mix_threshold_active  TYPE abap_bool,
        deadline_mix_threshold         TYPE zif_allocation_audit=>ty_coverage,
        deadline_mix_below_threshold   TYPE abap_bool,
        overdue_mix_threshold_active   TYPE abap_bool,
        overdue_mix_threshold          TYPE zif_allocation_audit=>ty_coverage,
        overdue_mix_above_threshold    TYPE abap_bool,
        current_deadline_mix_limit_on  TYPE abap_bool,
        current_deadline_mix_threshold TYPE zif_allocation_audit=>ty_coverage,
        curr_deadline_mix_above_limit  TYPE abap_bool,
        future_deadline_mix_limit_on   TYPE abap_bool,
        future_deadline_mix_threshold  TYPE zif_allocation_audit=>ty_coverage,
        fut_deadline_mix_below_limit   TYPE abap_bool,
        run_count_threshold_active     TYPE abap_bool,
        run_count_threshold            TYPE i,
        run_count_below_threshold      TYPE abap_bool,
        deadline_count_limit_active    TYPE abap_bool,
        deadline_count_threshold       TYPE i,
        deadline_count_below_threshold TYPE abap_bool,
        success_runs                   TYPE i,
        success_count_threshold_active TYPE abap_bool,
        success_count_threshold        TYPE i,
        success_count_below_threshold  TYPE abap_bool,
        duration_count_limit_active    TYPE abap_bool,
        duration_count_threshold       TYPE i,
        duration_count_below_threshold TYPE abap_bool,
        completion_pct                 TYPE zif_allocation_audit=>ty_coverage,
        success_rate_pct               TYPE zif_allocation_audit=>ty_coverage,
        partial_rate_pct               TYPE zif_allocation_audit=>ty_coverage,
        error_rate_pct                 TYPE zif_allocation_audit=>ty_coverage,
        demand_count                   TYPE i,
        full_count                     TYPE i,
        partial_count                  TYPE i,
        unallocated_count              TYPE i,
        demand_count_threshold_active  TYPE abap_bool,
        demand_count_threshold         TYPE i,
        demand_count_above_threshold   TYPE abap_bool,
        running_count_threshold_active TYPE abap_bool,
        running_count_threshold        TYPE i,
        running_count_above_threshold  TYPE abap_bool,
        shortage_quantity_limit_active TYPE abap_bool,
        shortage_quantity_threshold    TYPE zif_stock_allocation=>ty_quantity,
        shortage_quantity_above_limit  TYPE abap_bool,
        full_line_pct                  TYPE zif_allocation_audit=>ty_coverage,
        partial_line_pct               TYPE zif_allocation_audit=>ty_coverage,
        unallocated_line_pct           TYPE zif_allocation_audit=>ty_coverage,
        full_count_threshold_active    TYPE abap_bool,
        full_count_threshold           TYPE i,
        full_count_below_threshold     TYPE abap_bool,
        full_line_threshold_active     TYPE abap_bool,
        full_line_threshold            TYPE zif_allocation_audit=>ty_coverage,
        full_line_below_threshold      TYPE abap_bool,
        unallocated_line_limit_active  TYPE abap_bool,
        unallocated_line_threshold     TYPE zif_allocation_audit=>ty_coverage,
        unallocated_line_above_limit   TYPE abap_bool,
        partial_line_threshold_active  TYPE abap_bool,
        partial_line_threshold         TYPE zif_allocation_audit=>ty_coverage,
        partial_line_above_threshold   TYPE abap_bool,
        priority_runs                  TYPE i,
        fifo_runs                      TYPE i,
        full_only_runs                 TYPE i,
        smallest_runs                  TYPE i,
        largest_runs                   TYPE i,
        best_runs                      TYPE i,
        running_runs                   TYPE i,
        stale_running_runs             TYPE i,
        stale_threshold_active         TYPE abap_bool,
        stale_threshold                TYPE i,
        stale_above_threshold          TYPE abap_bool,
        error_runs                     TYPE i,
        partial_runs                   TYPE i,
        fair_runs                      TYPE i,
        weighted_runs                  TYPE i,
        adaptive_runs                  TYPE i,
        adaptive_priority_runs         TYPE i,
        adaptive_fair_runs             TYPE i,
        legacy_runs                    TYPE i,
        priority_mix_pct               TYPE zif_allocation_audit=>ty_coverage,
        fifo_mix_pct                   TYPE zif_allocation_audit=>ty_coverage,
        full_only_mix_pct              TYPE zif_allocation_audit=>ty_coverage,
        smallest_mix_pct               TYPE zif_allocation_audit=>ty_coverage,
        largest_mix_pct                TYPE zif_allocation_audit=>ty_coverage,
        best_mix_pct                   TYPE zif_allocation_audit=>ty_coverage,
        fair_mix_pct                   TYPE zif_allocation_audit=>ty_coverage,
        weighted_mix_pct               TYPE zif_allocation_audit=>ty_coverage,
        adaptive_mix_pct               TYPE zif_allocation_audit=>ty_coverage,
        legacy_mix_pct                 TYPE zif_allocation_audit=>ty_coverage,
        last_run_available             TYPE abap_bool,
        duration_metrics_available     TYPE abap_bool,
        last_duration_available        TYPE abap_bool,
        last_age_available             TYPE abap_bool,
        last_age_seconds               TYPE i,
        last_age_reason                TYPE string,
        last_age_reference_date        TYPE d,
        last_age_reference_time        TYPE t,
        last_completed_run_available   TYPE abap_bool,
        last_completed_run_id          TYPE zif_allocation_audit=>ty_run_id,
        last_completed_preview         TYPE abap_bool,
        last_completed_status          TYPE zif_allocation_audit=>ty_run_status,
        last_completed_success_streak  TYPE i,
        last_comp_non_success_streak   TYPE i,
        last_completed_message         TYPE zif_allocation_audit=>ty_message,
        last_completed_start_date      TYPE d,
        last_completed_start_time      TYPE t,
        last_completed_finish_date     TYPE d,
        last_completed_finish_time     TYPE t,
        last_comp_duration_seconds     TYPE i,
        last_completed_unit            TYPE string,
        last_comp_policy_available     TYPE abap_bool,
        last_completed_movement_type   TYPE string,
        last_completed_min_shelf_life  TYPE i,
        last_completed_safety_stock    TYPE zif_stock_allocation=>ty_quantity,
        last_comp_horizon_available    TYPE abap_bool,
        last_comp_requested_on_from    TYPE d,
        last_completed_requested_on_to TYPE d,
        last_comp_requested_deadline   TYPE d,
        last_comp_deadline_age_avail   TYPE abap_bool,
        last_comp_deadline_age_days    TYPE i,
        last_comp_deadline_age_reason  TYPE string,
        last_comp_deadline_urgency     TYPE string,
        last_completed_available_stock TYPE zif_stock_allocation=>ty_quantity,
        last_comp_available_stock_unit TYPE string,
        last_comp_avail_stock_avail    TYPE abap_bool,
        last_completed_strategy        TYPE zif_allocation_audit=>ty_strategy,
        last_completed_requested       TYPE zif_stock_allocation=>ty_quantity,
        last_completed_allocated       TYPE zif_stock_allocation=>ty_quantity,
        last_completed_shortage        TYPE zif_stock_allocation=>ty_quantity,
        last_completed_coverage        TYPE zif_allocation_audit=>ty_coverage,
        last_completed_demand          TYPE i,
        last_completed_full            TYPE i,
        last_completed_partial         TYPE i,
        last_completed_unalloc         TYPE i,
        last_comp_allocated_line_count TYPE i,
        last_comp_shortage_pct_avail   TYPE abap_bool,
        last_completed_shortage_pct    TYPE zif_allocation_audit=>ty_coverage,
        last_comp_line_rates_available TYPE abap_bool,
        last_completed_full_line_pct   TYPE zif_allocation_audit=>ty_coverage,
        last_comp_partial_line_pct     TYPE zif_allocation_audit=>ty_coverage,
        last_comp_unalloc_line_pct     TYPE zif_allocation_audit=>ty_coverage,
        last_run_id                    TYPE zif_allocation_audit=>ty_run_id,
        last_preview                   TYPE abap_bool,
        last_available_stock           TYPE zif_stock_allocation=>ty_quantity,
        last_available_stock_unit      TYPE string,
        last_available_stock_available TYPE abap_bool,
        last_requested_quantity        TYPE zif_stock_allocation=>ty_quantity,
        last_allocated_quantity        TYPE zif_stock_allocation=>ty_quantity,
        last_shortage_quantity         TYPE zif_stock_allocation=>ty_quantity,
        last_shortage_pct_available    TYPE abap_bool,
        last_shortage_pct              TYPE zif_allocation_audit=>ty_coverage,
        last_coverage_pct              TYPE zif_allocation_audit=>ty_coverage,
        last_demand_count              TYPE i,
        last_full_line_count           TYPE i,
        last_partial_line_count        TYPE i,
        last_unallocated_line_count    TYPE i,
        last_line_rates_available      TYPE abap_bool,
        last_full_line_pct             TYPE zif_allocation_audit=>ty_coverage,
        last_partial_line_pct          TYPE zif_allocation_audit=>ty_coverage,
        last_unallocated_line_pct      TYPE zif_allocation_audit=>ty_coverage,
        last_strategy                  TYPE zif_allocation_audit=>ty_strategy,
        last_status                    TYPE zif_allocation_audit=>ty_run_status,
        last_start_date                TYPE d,
        last_start_time                TYPE t,
        last_finish_date               TYPE d,
        last_finish_time               TYPE t,
        last_duration_seconds          TYPE i,
        average_duration_seconds       TYPE zif_allocation_audit=>ty_duration,
        minimum_duration_seconds       TYPE i,
        maximum_duration_seconds       TYPE i,
        completed_duration_runs        TYPE i,
        oldest_running_age_seconds     TYPE i,
        oldest_running_run_id          TYPE zif_allocation_audit=>ty_run_id,
        newest_running_age_seconds     TYPE i,
        newest_running_run_id          TYPE zif_allocation_audit=>ty_run_id,
        last_run_message               TYPE zif_allocation_audit=>ty_message,
        unit                           TYPE string,
        available_stock_context        TYPE zif_stock_allocation=>ty_quantity,
        avail_stock_context_avail      TYPE abap_bool,
        mixed_available_stock          TYPE abap_bool,
        avail_stock_min_limit_active   TYPE abap_bool,
        avail_stock_min_threshold      TYPE zif_stock_allocation=>ty_quantity,
        avail_stock_below_threshold    TYPE abap_bool,
        avail_stock_max_limit_active   TYPE abap_bool,
        avail_stock_max_threshold      TYPE zif_stock_allocation=>ty_quantity,
        avail_stock_above_threshold    TYPE abap_bool,
        policy_context_available       TYPE abap_bool,
        mixed_policies                 TYPE abap_bool,
        movement_type_context          TYPE string,
        minimum_shelf_life_context     TYPE i,
        safety_stock_context           TYPE zif_stock_allocation=>ty_quantity,
        mixed_units                    TYPE abap_bool,
        mixed_policy_warning_active    TYPE abap_bool,
        mixed_policy_breach            TYPE abap_bool,
        mixed_unit_warning_active      TYPE abap_bool,
        mixed_unit_breach              TYPE abap_bool,
        shortage_available             TYPE abap_bool,
        requested                      TYPE zif_stock_allocation=>ty_quantity,
        allocated                      TYPE zif_stock_allocation=>ty_quantity,
        shortage                       TYPE zif_stock_allocation=>ty_quantity,
        coverage_available             TYPE abap_bool,
        coverage                       TYPE zif_allocation_audit=>ty_coverage,
        priority_share_available       TYPE abap_bool,
        priority_requested             TYPE zif_stock_allocation=>ty_quantity,
        priority_allocated             TYPE zif_stock_allocation=>ty_quantity,
        priority_shortage              TYPE zif_stock_allocation=>ty_quantity,
        priority_coverage_available    TYPE abap_bool,
        priority_coverage              TYPE zif_allocation_audit=>ty_coverage,
        fifo_share_available           TYPE abap_bool,
        fifo_requested                 TYPE zif_stock_allocation=>ty_quantity,
        fifo_allocated                 TYPE zif_stock_allocation=>ty_quantity,
        fifo_shortage                  TYPE zif_stock_allocation=>ty_quantity,
        fifo_coverage_available        TYPE abap_bool,
        fifo_coverage                  TYPE zif_allocation_audit=>ty_coverage,
        full_only_share_available      TYPE abap_bool,
        full_only_requested            TYPE zif_stock_allocation=>ty_quantity,
        full_only_allocated            TYPE zif_stock_allocation=>ty_quantity,
        full_only_shortage             TYPE zif_stock_allocation=>ty_quantity,
        full_only_coverage_available   TYPE abap_bool,
        full_only_coverage             TYPE zif_allocation_audit=>ty_coverage,
        smallest_share_available       TYPE abap_bool,
        smallest_requested             TYPE zif_stock_allocation=>ty_quantity,
        smallest_allocated             TYPE zif_stock_allocation=>ty_quantity,
        smallest_shortage              TYPE zif_stock_allocation=>ty_quantity,
        smallest_coverage_available    TYPE abap_bool,
        smallest_coverage              TYPE zif_allocation_audit=>ty_coverage,
        largest_share_available        TYPE abap_bool,
        largest_requested              TYPE zif_stock_allocation=>ty_quantity,
        largest_allocated              TYPE zif_stock_allocation=>ty_quantity,
        largest_shortage               TYPE zif_stock_allocation=>ty_quantity,
        largest_coverage_available     TYPE abap_bool,
        largest_coverage               TYPE zif_allocation_audit=>ty_coverage,
        best_share_available           TYPE abap_bool,
        best_requested                 TYPE zif_stock_allocation=>ty_quantity,
        best_allocated                 TYPE zif_stock_allocation=>ty_quantity,
        best_shortage                  TYPE zif_stock_allocation=>ty_quantity,
        best_coverage_available        TYPE abap_bool,
        best_coverage                  TYPE zif_allocation_audit=>ty_coverage,
        coverage_threshold_active      TYPE abap_bool,
        coverage_threshold             TYPE zif_allocation_audit=>ty_coverage,
        coverage_below_threshold       TYPE abap_bool,
        last_coverage_threshold_active TYPE abap_bool,
        last_coverage_threshold        TYPE zif_allocation_audit=>ty_coverage,
        last_coverage_below_threshold  TYPE abap_bool,
        last_shortage_qty_limit_active TYPE abap_bool,
        last_shortage_qty_threshold    TYPE zif_stock_allocation=>ty_quantity,
        last_shortage_qty_above_limit  TYPE abap_bool,
        last_shortage_pct_limit_active TYPE abap_bool,
        last_shortage_pct_threshold    TYPE zif_allocation_audit=>ty_coverage,
        last_shortage_pct_above_limit  TYPE abap_bool,
        last_comp_coverage_limit_on    TYPE abap_bool,
        last_comp_coverage_limit       TYPE zif_allocation_audit=>ty_coverage,
        last_comp_coverage_below_limit TYPE abap_bool,
        last_comp_cov_max_limit_on     TYPE abap_bool,
        last_comp_coverage_max_limit   TYPE zif_allocation_audit=>ty_coverage,
        last_comp_coverage_above_limit TYPE abap_bool,
        last_comp_short_pct_limit_on   TYPE abap_bool,
        last_comp_shortage_pct_limit   TYPE zif_allocation_audit=>ty_coverage,
        last_comp_short_pct_above_lim  TYPE abap_bool,
        last_comp_short_qty_limit_on   TYPE abap_bool,
        last_comp_shortage_qty_limit   TYPE zif_stock_allocation=>ty_quantity,
        last_comp_short_qty_above_lim  TYPE abap_bool,
        last_comp_requested_limit_on   TYPE abap_bool,
        last_comp_requested_limit      TYPE zif_stock_allocation=>ty_quantity,
        last_comp_req_above_limit      TYPE abap_bool,
        last_comp_req_min_limit_on     TYPE abap_bool,
        last_comp_requested_min_limit  TYPE zif_stock_allocation=>ty_quantity,
        last_comp_req_below_limit      TYPE abap_bool,
        last_comp_allocated_limit_on   TYPE abap_bool,
        last_comp_allocated_limit      TYPE zif_stock_allocation=>ty_quantity,
        last_comp_alloc_below_limit    TYPE abap_bool,
        last_comp_alloc_max_limit_on   TYPE abap_bool,
        last_comp_allocated_max_limit  TYPE zif_stock_allocation=>ty_quantity,
        last_comp_alloc_above_limit    TYPE abap_bool,
        last_comp_avail_stk_min_lim_on TYPE abap_bool,
        last_comp_avail_stk_min_limit  TYPE zif_stock_allocation=>ty_quantity,
        last_comp_avail_stk_below_lim  TYPE abap_bool,
        last_comp_avail_stk_max_lim_on TYPE abap_bool,
        last_comp_avail_stk_max_limit  TYPE zif_stock_allocation=>ty_quantity,
        last_comp_avail_stk_above_lim  TYPE abap_bool,
        last_comp_full_line_limit_on   TYPE abap_bool,
        last_comp_full_line_limit      TYPE zif_allocation_audit=>ty_coverage,
        last_comp_full_ln_below_limit  TYPE abap_bool,
        last_comp_full_ln_max_limit_on TYPE abap_bool,
        last_comp_full_line_max_limit  TYPE zif_allocation_audit=>ty_coverage,
        last_comp_full_ln_above_limit  TYPE abap_bool,
        last_comp_unalloc_ln_limit_on  TYPE abap_bool,
        last_comp_unalloc_line_limit   TYPE zif_allocation_audit=>ty_coverage,
        last_comp_unalloc_ln_above_lim TYPE abap_bool,
        last_comp_part_line_limit_on   TYPE abap_bool,
        last_comp_partial_line_limit   TYPE zif_allocation_audit=>ty_coverage,
        last_comp_part_ln_above_limit  TYPE abap_bool,
        last_comp_full_count_limit_on  TYPE abap_bool,
        last_comp_full_count_limit     TYPE i,
        last_comp_full_cnt_below_limit TYPE abap_bool,
        last_comp_unalloc_cnt_limit_on TYPE abap_bool,
        last_comp_unalloc_count_limit  TYPE i,
        last_comp_unalloc_cnt_over_lim TYPE abap_bool,
        last_comp_partial_cnt_limit_on TYPE abap_bool,
        last_comp_partial_count_limit  TYPE i,
        last_comp_part_cnt_above_limit TYPE abap_bool,
        last_comp_alloc_count_limit_on TYPE abap_bool,
        last_comp_alloc_count_limit    TYPE i,
        last_comp_alloc_cnt_below_lim  TYPE abap_bool,
        last_comp_alloc_cnt_max_lim_on TYPE abap_bool,
        last_comp_alloc_cnt_max_limit  TYPE i,
        last_comp_acnt_max_above_limit TYPE abap_bool,
        last_comp_short_cnt_limit_on   TYPE abap_bool,
        last_comp_shortage_count_limit TYPE i,
        last_comp_short_cnt_above_lim  TYPE abap_bool,
        last_age_threshold_active      TYPE abap_bool,
        last_age_threshold             TYPE i,
        last_age_above_threshold       TYPE abap_bool,
        last_comp_ddl_age_limit_on     TYPE abap_bool,
        last_comp_deadline_age_limit   TYPE i,
        last_comp_ddl_age_above_limit  TYPE abap_bool,
        last_comp_demand_cnt_limit_on  TYPE abap_bool,
        last_comp_demand_count_limit   TYPE i,
        last_comp_demand_cnt_above_lim TYPE abap_bool,
        last_cmp_demand_cnt_min_lim_on TYPE abap_bool,
        last_comp_demand_cnt_min_limit TYPE i,
        last_comp_demand_cnt_below_lim TYPE abap_bool,
        shortage_threshold_active      TYPE abap_bool,
        shortage_threshold             TYPE zif_allocation_audit=>ty_coverage,
        shortage_above_threshold       TYPE abap_bool,
        duration_threshold_active      TYPE abap_bool,
        duration_threshold             TYPE i,
        duration_above_threshold       TYPE abap_bool,
        last_comp_duration_limit_on    TYPE abap_bool,
        last_comp_duration_limit       TYPE i,
        last_comp_duration_above_limit TYPE abap_bool,
        last_comp_dur_min_limit_on     TYPE abap_bool,
        last_comp_duration_min_limit   TYPE i,
        last_comp_duration_below_limit TYPE abap_bool,
        last_comp_success_required_on  TYPE abap_bool,
        last_completed_success_breach  TYPE abap_bool,
        last_comp_succ_streak_limit_on TYPE abap_bool,
        last_comp_success_streak_limit TYPE i,
        last_cmp_succ_streak_below_lim TYPE abap_bool,
        last_comp_non_success_limit_on TYPE abap_bool,
        last_comp_non_success_limit    TYPE i,
        last_comp_non_succ_above_limit TYPE abap_bool,
        average_duration_limit_active  TYPE abap_bool,
        average_duration_threshold     TYPE i,
        average_duration_above_limit   TYPE abap_bool,
        maximum_duration_limit_active  TYPE abap_bool,
        maximum_duration_threshold     TYPE i,
        maximum_duration_above_limit   TYPE abap_bool,
        completion_threshold_active    TYPE abap_bool,
        completion_threshold           TYPE zif_allocation_audit=>ty_coverage,
        completion_below_threshold     TYPE abap_bool,
        success_threshold_active       TYPE abap_bool,
        success_threshold              TYPE zif_allocation_audit=>ty_coverage,
        success_below_threshold        TYPE abap_bool,
        error_threshold_active         TYPE abap_bool,
        error_threshold                TYPE zif_allocation_audit=>ty_coverage,
        error_above_threshold          TYPE abap_bool,
        partial_threshold_active       TYPE abap_bool,
        partial_threshold              TYPE zif_allocation_audit=>ty_coverage,
        partial_above_threshold        TYPE abap_bool,
        threshold_breach_count         TYPE i,
        threshold_breaches             TYPE string,
        fair_share_available           TYPE abap_bool,
        fair_requested                 TYPE zif_stock_allocation=>ty_quantity,
        fair_allocated                 TYPE zif_stock_allocation=>ty_quantity,
        fair_shortage                  TYPE zif_stock_allocation=>ty_quantity,
        fair_coverage_available        TYPE abap_bool,
        fair_coverage                  TYPE zif_allocation_audit=>ty_coverage,
        weighted_share_available       TYPE abap_bool,
        weighted_requested             TYPE zif_stock_allocation=>ty_quantity,
        weighted_allocated             TYPE zif_stock_allocation=>ty_quantity,
        weighted_shortage              TYPE zif_stock_allocation=>ty_quantity,
        weighted_coverage_ok           TYPE abap_bool,
        weighted_coverage              TYPE zif_allocation_audit=>ty_coverage,
        adaptive_share_available       TYPE abap_bool,
        adaptive_requested             TYPE zif_stock_allocation=>ty_quantity,
        adaptive_allocated             TYPE zif_stock_allocation=>ty_quantity,
        adaptive_shortage              TYPE zif_stock_allocation=>ty_quantity,
        adaptive_coverage_ok           TYPE abap_bool,
        adaptive_coverage              TYPE zif_allocation_audit=>ty_coverage,
        legacy_share_available         TYPE abap_bool,
        legacy_requested               TYPE zif_stock_allocation=>ty_quantity,
        legacy_allocated               TYPE zif_stock_allocation=>ty_quantity,
        legacy_shortage                TYPE zif_stock_allocation=>ty_quantity,
        legacy_coverage_available      TYPE abap_bool,
        legacy_coverage                TYPE zif_allocation_audit=>ty_coverage,
        deadline_count                 TYPE i,
        last_requested_on_from         TYPE d,
        last_requested_on_to           TYPE d,
        last_requested_deadline        TYPE d,
        earliest_requested_deadline    TYPE d,
        latest_requested_deadline      TYPE d,
        last_deadline_age_days         TYPE i,
        oldest_deadline_age_days       TYPE i,
        newest_deadline_age_days       TYPE i,
        last_deadline_urgency          TYPE string,
        oldest_deadline_urgency        TYPE string,
        newest_deadline_urgency        TYPE string,
        deadline_age_reference_date    TYPE d,
      END OF ty_health.
    CLASS-METHODS evaluate
      IMPORTING
        is_summary                                TYPE zif_allocation_audit=>ty_summary
        iv_stale_running_runs                     TYPE i OPTIONAL
        iv_stale_scope_evaluated                  TYPE abap_bool OPTIONAL
        iv_stale_threshold                        TYPE i DEFAULT 3600
        iv_last_age_available                     TYPE abap_bool OPTIONAL
        iv_last_age_seconds                       TYPE i OPTIONAL
        iv_last_age_reason                        TYPE string OPTIONAL
        iv_last_age_reference_date                TYPE d OPTIONAL
        iv_last_age_reference_time                TYPE t OPTIONAL
        iv_min_coverage                           TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_last_coverage                      TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_shortage_pct                       TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_duration                      TYPE i OPTIONAL
        iv_max_last_completed_duration            TYPE i OPTIONAL
        iv_min_last_completed_duration            TYPE i OPTIONAL
        iv_require_last_completed_success         TYPE abap_bool OPTIONAL
        iv_min_last_completed_success_streak      TYPE i OPTIONAL
        iv_max_last_completed_non_success_streak  TYPE i OPTIONAL
        iv_max_average_duration                   TYPE i OPTIONAL
        iv_max_completed_duration                 TYPE i OPTIONAL
        iv_min_duration_count                     TYPE i OPTIONAL
        iv_min_run_count                          TYPE i OPTIONAL
        iv_min_deadline_count                     TYPE i OPTIONAL
        iv_min_deadline_mix                       TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_overdue_mix                        TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_current_deadline_mix               TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_future_deadline_mix                TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_warn_mixed_policies                    TYPE abap_bool OPTIONAL
        iv_warn_mixed_units                       TYPE abap_bool OPTIONAL
        iv_min_completion_rate                    TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_success_rate                       TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_success_count                      TYPE i OPTIONAL
        iv_max_error_rate                         TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_partial_rate                       TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_full_line_rate                     TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_unalloc_line_rate                  TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_partial_line_rate                  TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_full_line_count                    TYPE i OPTIONAL
        iv_max_demand_count                       TYPE i OPTIONAL
        iv_max_running_count                      TYPE i OPTIONAL
        iv_max_shortage_quantity                  TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_max_last_shortage_qty                  TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_max_last_shortage_pct                  TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_last_completed_coverage            TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_completed_coverage            TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_completed_shortage_pct        TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_completed_shortage_qty        TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_min_last_completed_requested           TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_max_last_completed_requested           TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_min_last_completed_allocated           TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_max_last_completed_allocated           TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_min_last_completed_avail_stock         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_max_last_completed_avail_stock         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_min_last_completed_full_line_rate      TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_completed_full_line_rate      TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_completed_unalloc_line_rate   TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_last_completed_partial_line_rate   TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_min_last_completed_full_line_count     TYPE i OPTIONAL
        iv_max_last_completed_unalloc_line_count  TYPE i OPTIONAL
        iv_max_last_completed_partial_line_count  TYPE i OPTIONAL
        iv_max_last_completed_shortage_line_count TYPE i OPTIONAL
        iv_min_last_completed_alloc_lines         TYPE i OPTIONAL
        iv_max_last_completed_alloc_lines         TYPE i OPTIONAL
        iv_max_last_age                           TYPE i OPTIONAL
        iv_max_last_completed_deadline_age        TYPE i OPTIONAL
        iv_min_last_completed_demand_count        TYPE i OPTIONAL
        iv_max_last_completed_demand_count        TYPE i OPTIONAL
        iv_min_available_stock                    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_max_available_stock                    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      RETURNING
      VALUE(rs_health)                            TYPE ty_health.

ENDCLASS.

CLASS zcl_stock_allocation_health IMPLEMENTATION.
  METHOD evaluate.
    DATA lv_stale TYPE abap_bool.
    rs_health-total_runs = is_summary-total_runs.
    rs_health-preview_runs = is_summary-preview_runs.
    rs_health-operational_runs = is_summary-operational_runs.
    IF is_summary-total_runs > 0.
      rs_health-preview_mix_pct = is_summary-preview_runs * 100        / is_summary-total_runs.
      rs_health-operational_mix_pct = is_summary-operational_runs * 100        / is_summary-total_runs.
      rs_health-deadline_mix_pct = is_summary-deadline_mix_pct.
    ENDIF.
    rs_health-success_runs = is_summary-success_runs.
    rs_health-completion_pct = is_summary-completion_pct.
    rs_health-success_rate_pct = is_summary-success_rate_pct.
    rs_health-partial_rate_pct = is_summary-partial_rate_pct.
    rs_health-error_rate_pct = is_summary-error_rate_pct.
    rs_health-demand_count = is_summary-demand_count.
    rs_health-full_count = is_summary-full_count.
    rs_health-partial_count = is_summary-partial_count.
    rs_health-unallocated_count = is_summary-unallocated_count.
    IF is_summary-demand_count > 0.
      rs_health-full_line_pct = is_summary-full_count * 100        / is_summary-demand_count.
      rs_health-partial_line_pct = is_summary-partial_count * 100        / is_summary-demand_count.
      rs_health-unallocated_line_pct = is_summary-unallocated_count * 100        / is_summary-demand_count.
    ENDIF.
    rs_health-priority_runs = is_summary-priority_runs.
    rs_health-fifo_runs = is_summary-fifo_runs.
    rs_health-full_only_runs = is_summary-full_only_runs.
    rs_health-smallest_runs = is_summary-smallest_runs.
    rs_health-largest_runs = is_summary-largest_runs.
    rs_health-best_runs = is_summary-best_runs.
    rs_health-running_runs = is_summary-running_runs.
    rs_health-error_runs = is_summary-error_runs.
    rs_health-partial_runs = is_summary-partial_runs.
    rs_health-fair_runs = is_summary-fair_runs.
    rs_health-weighted_runs = is_summary-weighted_runs.
    rs_health-adaptive_runs = is_summary-adaptive_runs.
    rs_health-adaptive_priority_runs = is_summary-adaptive_priority_runs.
    rs_health-adaptive_fair_runs = is_summary-adaptive_fair_runs.
    rs_health-legacy_runs = is_summary-legacy_strategy_runs.
    IF is_summary-total_runs > 0.
      rs_health-priority_mix_pct = is_summary-priority_runs * 100        / is_summary-total_runs.
      rs_health-fifo_mix_pct = is_summary-fifo_runs * 100        / is_summary-total_runs.
      rs_health-full_only_mix_pct = is_summary-full_only_runs * 100        / is_summary-total_runs.
      rs_health-smallest_mix_pct = is_summary-smallest_runs * 100        / is_summary-total_runs.
      rs_health-largest_mix_pct = is_summary-largest_runs * 100        / is_summary-total_runs.
      rs_health-best_mix_pct = is_summary-best_runs * 100        / is_summary-total_runs.
      rs_health-fair_mix_pct = is_summary-fair_runs * 100        / is_summary-total_runs.
      rs_health-weighted_mix_pct = is_summary-weighted_runs * 100        / is_summary-total_runs.
      rs_health-adaptive_mix_pct = is_summary-adaptive_runs * 100        / is_summary-total_runs.
      rs_health-legacy_mix_pct = is_summary-legacy_strategy_runs * 100        / is_summary-total_runs.
    ENDIF.
      rs_health-last_run_available = xsdbool(
        is_summary-total_runs > 0
        AND is_summary-last_run_id IS NOT INITIAL ).
    rs_health-duration_metrics_available = xsdbool(      is_summary-completed_duration_runs > 0 ).
    rs_health-last_run_id = is_summary-last_run_id.
    rs_health-last_preview = is_summary-last_preview.
    rs_health-last_available_stock = is_summary-last_avail.
    rs_health-last_available_stock_unit = is_summary-last_avail_unit.
    rs_health-last_available_stock_available =
      is_summary-last_avail_ok.
    rs_health-last_requested_quantity = is_summary-last_requested.
    rs_health-last_allocated_quantity = is_summary-last_allocated.
    rs_health-last_shortage_quantity = is_summary-last_shortage.
    IF rs_health-last_run_available = abap_true
        AND is_summary-last_requested > 0.
      rs_health-last_shortage_pct_available = abap_true.
      rs_health-last_shortage_pct = is_summary-last_shortage * 100
        / is_summary-last_requested.
    ENDIF.
    rs_health-last_coverage_pct = is_summary-last_coverage.
    rs_health-last_demand_count = is_summary-last_demand.
    rs_health-last_full_line_count = is_summary-last_full.
    rs_health-last_partial_line_count = is_summary-last_partial.
    rs_health-last_unallocated_line_count = is_summary-last_unalloc.
    IF rs_health-last_run_available = abap_true
        AND is_summary-last_demand > 0.
      rs_health-last_line_rates_available = abap_true.
      rs_health-last_full_line_pct = is_summary-last_full * 100
        / is_summary-last_demand.
      rs_health-last_partial_line_pct = is_summary-last_partial * 100
        / is_summary-last_demand.
      rs_health-last_unallocated_line_pct = is_summary-last_unalloc * 100
        / is_summary-last_demand.
    ENDIF.
    rs_health-last_strategy = is_summary-last_strategy.
    rs_health-last_status = is_summary-last_status.
    rs_health-last_start_date = is_summary-last_start_date.
    rs_health-last_start_time = is_summary-last_start_time.
    rs_health-last_finish_date = is_summary-last_finish_date.
    rs_health-last_finish_time = is_summary-last_finish_time.
    rs_health-last_duration_seconds = is_summary-last_duration_seconds.
    rs_health-average_duration_seconds = is_summary-average_duration_seconds.
    rs_health-minimum_duration_seconds = is_summary-minimum_duration_seconds.
    rs_health-maximum_duration_seconds = is_summary-maximum_duration_seconds.
    rs_health-completed_duration_runs = is_summary-completed_duration_runs.
    rs_health-oldest_running_age_seconds = is_summary-oldest_running_age_seconds.
    rs_health-oldest_running_run_id = is_summary-oldest_running_run_id.
    rs_health-newest_running_age_seconds = is_summary-newest_running_age_seconds.
    rs_health-newest_running_run_id = is_summary-newest_running_run_id.
    rs_health-last_run_message = is_summary-last_message.
    rs_health-last_age_available = iv_last_age_available.
    rs_health-last_age_reason = iv_last_age_reason.
    rs_health-last_age_reference_date = iv_last_age_reference_date.
    rs_health-last_age_reference_time = iv_last_age_reference_time.
    IF rs_health-last_age_reason IS INITIAL.
      IF rs_health-last_age_available = abap_true.
        rs_health-last_age_reason = 'available'.
      ELSEIF is_summary-last_completed_run_id IS INITIAL.
        rs_health-last_age_reason = 'no_completed_run'.
      ELSE.
        rs_health-last_age_reason = 'unavailable'.
      ENDIF.
    ENDIF.
    IF rs_health-last_age_available = abap_true.
      rs_health-last_age_seconds = iv_last_age_seconds.
    ENDIF.
    rs_health-last_completed_run_available = xsdbool(
      is_summary-last_completed_run_id IS NOT INITIAL ).
    rs_health-last_completed_run_id = is_summary-last_completed_run_id.
    rs_health-last_completed_preview = is_summary-last_completed_preview.
    rs_health-last_completed_status = is_summary-last_completed_status.
    rs_health-last_completed_success_streak =
      is_summary-last_completed_success_streak.
    rs_health-last_comp_non_success_streak =
      is_summary-last_completed_non_success_streak.
    rs_health-last_completed_message = is_summary-last_completed_message.
    rs_health-last_completed_start_date =
      is_summary-last_completed_start_date.
    rs_health-last_completed_start_time =
      is_summary-last_completed_start_time.
    rs_health-last_completed_finish_date =
      is_summary-last_completed_finish_date.
    rs_health-last_completed_finish_time =
      is_summary-last_completed_finish_time.
    rs_health-last_comp_duration_seconds =
      is_summary-last_completed_duration.
    rs_health-last_completed_unit = is_summary-last_completed_unit.
    rs_health-last_comp_policy_available =
      is_summary-last_completed_policy_available.
    rs_health-last_completed_movement_type =
      is_summary-last_completed_movement_type.
    rs_health-last_completed_min_shelf_life =
      is_summary-last_completed_min_shelf_life.
    rs_health-last_completed_safety_stock =
      is_summary-last_completed_safety_stock.
    rs_health-last_comp_horizon_available =
      is_summary-last_completed_horizon_available.
    rs_health-last_comp_requested_on_from =
      is_summary-last_completed_requested_on_from.
    rs_health-last_completed_requested_on_to =
      is_summary-last_completed_requested_on_to.
    rs_health-last_comp_requested_deadline =
      is_summary-last_completed_requested_deadline.
    rs_health-last_comp_deadline_age_avail =
      is_summary-last_completed_deadline_age_available.
    rs_health-last_comp_deadline_age_days =
      is_summary-last_completed_deadline_age_days.
    rs_health-last_comp_deadline_age_reason =
      is_summary-last_completed_deadline_age_reason.
    IF rs_health-last_comp_deadline_age_reason IS INITIAL.
      IF rs_health-last_comp_deadline_age_avail = abap_true.
        rs_health-last_comp_deadline_age_reason = 'available'.
      ELSEIF is_summary-last_completed_run_id IS INITIAL.
        rs_health-last_comp_deadline_age_reason = 'no_completed_run'.
      ELSE.
        rs_health-last_comp_deadline_age_reason = 'no_deadline'.
      ENDIF.
    ENDIF.
    IF is_summary-last_completed_deadline_urgency IS INITIAL.
      rs_health-last_comp_deadline_urgency = 'n/a'.
    ELSE.
      rs_health-last_comp_deadline_urgency =
        is_summary-last_completed_deadline_urgency.
    ENDIF.
    rs_health-last_completed_available_stock = is_summary-last_completed_avail.
    rs_health-last_comp_available_stock_unit =
      is_summary-last_completed_avail_unit.
    rs_health-last_comp_avail_stock_avail =
      is_summary-last_completed_avail_ok.
    rs_health-last_completed_strategy = is_summary-last_completed_strategy.
    rs_health-last_completed_requested = is_summary-last_completed_requested.
    rs_health-last_completed_allocated = is_summary-last_completed_allocated.
    rs_health-last_completed_shortage = is_summary-last_completed_shortage.
    rs_health-last_completed_coverage = is_summary-last_completed_coverage.
    rs_health-last_completed_demand = is_summary-last_completed_demand.
    rs_health-last_completed_full = is_summary-last_completed_full.
    rs_health-last_completed_partial = is_summary-last_completed_partial.
    rs_health-last_completed_unalloc = is_summary-last_completed_unalloc.
    rs_health-last_comp_allocated_line_count =
      rs_health-last_completed_full + rs_health-last_completed_partial.
    IF rs_health-last_completed_run_available = abap_true
        AND rs_health-last_completed_requested > 0.
      rs_health-last_comp_shortage_pct_avail = abap_true.
      rs_health-last_completed_shortage_pct =
        rs_health-last_completed_shortage * 100
        / rs_health-last_completed_requested.
    ENDIF.
    IF rs_health-last_completed_run_available = abap_true
        AND rs_health-last_completed_demand > 0.
      rs_health-last_comp_line_rates_available = abap_true.
      rs_health-last_completed_full_line_pct =
        rs_health-last_completed_full * 100
        / rs_health-last_completed_demand.
      rs_health-last_comp_partial_line_pct =
        rs_health-last_completed_partial * 100
        / rs_health-last_completed_demand.
      rs_health-last_comp_unalloc_line_pct =
        rs_health-last_completed_unalloc * 100
        / rs_health-last_completed_demand.
    ENDIF.
    rs_health-available_stock_context = is_summary-available_context.
    rs_health-avail_stock_context_avail =
      is_summary-available_context_ok.
    rs_health-mixed_available_stock = is_summary-mixed_available.
      rs_health-last_duration_available = xsdbool(
        rs_health-last_run_available = abap_true
        AND is_summary-last_status <> 'R'
        AND is_summary-last_finish_date IS NOT INITIAL
        AND is_summary-last_finish_time IS NOT INITIAL ).
    rs_health-deadline_count = is_summary-deadline_count.
    rs_health-overdue_count = is_summary-overdue_count.
    rs_health-current_deadline_count = is_summary-current_deadline_count.
    rs_health-future_deadline_count = is_summary-future_deadline_count.
    rs_health-overdue_mix_pct = is_summary-overdue_mix_pct.
    rs_health-current_deadline_mix_pct = is_summary-current_deadline_mix_pct.
    rs_health-future_deadline_mix_pct = is_summary-future_deadline_mix_pct.
    rs_health-last_requested_on_from = is_summary-last_requested_on_from.
    rs_health-last_requested_on_to = is_summary-last_requested_on_to.
    rs_health-last_requested_deadline = is_summary-last_requested_deadline.
    rs_health-earliest_requested_deadline =      is_summary-earliest_requested_deadline.
    rs_health-latest_requested_deadline =      is_summary-latest_requested_deadline.
    rs_health-last_deadline_age_days = is_summary-last_deadline_age_days.
    rs_health-oldest_deadline_age_days = is_summary-oldest_deadline_age_days.
    rs_health-newest_deadline_age_days = is_summary-newest_deadline_age_days.
    IF is_summary-last_deadline_urgency IS INITIAL.
      rs_health-last_deadline_urgency = 'n/a'.
    ELSE.
      rs_health-last_deadline_urgency = is_summary-last_deadline_urgency.
    ENDIF.
    IF is_summary-oldest_deadline_urgency IS INITIAL.
      rs_health-oldest_deadline_urgency = 'n/a'.
    ELSE.
      rs_health-oldest_deadline_urgency = is_summary-oldest_deadline_urgency.
    ENDIF.
    IF is_summary-newest_deadline_urgency IS INITIAL.
      rs_health-newest_deadline_urgency = 'n/a'.
    ELSE.
      rs_health-newest_deadline_urgency = is_summary-newest_deadline_urgency.
    ENDIF.
    rs_health-deadline_age_reference_date =      is_summary-deadline_age_reference_date.
    rs_health-unit = is_summary-unit.
    rs_health-policy_context_available = is_summary-policy_context_available.
    rs_health-mixed_policies = is_summary-mixed_policies.
    rs_health-movement_type_context = is_summary-movement_type_context.
    rs_health-minimum_shelf_life_context = is_summary-min_shelf_life_context.
    rs_health-safety_stock_context = is_summary-safety_stock_context.
    rs_health-mixed_units = is_summary-mixed_units.
      rs_health-shortage_available = xsdbool(
        is_summary-mixed_units = abap_false ).
      rs_health-coverage_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-requested > 0 ).
      rs_health-priority_share_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-priority_requested > 0 ).
    rs_health-priority_coverage_available = rs_health-priority_share_available.
      rs_health-fifo_share_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-fifo_requested > 0 ).
    rs_health-fifo_coverage_available = rs_health-fifo_share_available.
      rs_health-full_only_share_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-full_only_requested > 0 ).
    rs_health-full_only_coverage_available =      rs_health-full_only_share_available.
      rs_health-smallest_share_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-smallest_requested > 0 ).
    rs_health-smallest_coverage_available = rs_health-smallest_share_available.
      rs_health-largest_share_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-largest_requested > 0 ).
    rs_health-largest_coverage_available = rs_health-largest_share_available.
      rs_health-best_share_available = xsdbool(
        is_summary-mixed_units = abap_false
        AND is_summary-best_requested > 0 ).
    rs_health-best_coverage_available = rs_health-best_share_available.
    rs_health-fair_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-fair_requested > 0 ).
    rs_health-fair_coverage_available = rs_health-fair_share_available.
    rs_health-adaptive_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-adaptive_requested > 0 ).
    rs_health-adaptive_coverage_ok = rs_health-adaptive_share_available.
    rs_health-weighted_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-weighted_requested > 0 ).
    rs_health-weighted_coverage_ok = rs_health-weighted_share_available.
    rs_health-coverage_threshold_active = xsdbool(      iv_min_coverage > 0 ).
    rs_health-coverage_threshold = iv_min_coverage.
    rs_health-last_coverage_threshold_active = xsdbool(
      iv_min_last_coverage > 0 ).
    rs_health-last_coverage_threshold = iv_min_last_coverage.
    rs_health-shortage_threshold_active = xsdbool(      iv_max_shortage_pct > 0 ).
    rs_health-shortage_threshold = iv_max_shortage_pct.
    rs_health-duration_threshold_active = xsdbool(      iv_max_last_duration > 0 ).
    rs_health-duration_threshold = iv_max_last_duration.
    rs_health-duration_above_threshold = xsdbool(
      rs_health-duration_threshold_active = abap_true
      AND rs_health-last_duration_available = abap_true
      AND is_summary-last_duration_seconds > iv_max_last_duration ).
    rs_health-last_comp_duration_limit_on = xsdbool(
      iv_max_last_completed_duration > 0 ).
    rs_health-last_comp_duration_limit =
      iv_max_last_completed_duration.
    rs_health-last_comp_duration_above_limit = xsdbool(
      rs_health-last_comp_duration_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_duration
        > iv_max_last_completed_duration ).
    rs_health-last_comp_dur_min_limit_on = xsdbool(
      iv_min_last_completed_duration > 0 ).
    rs_health-last_comp_duration_min_limit =
      iv_min_last_completed_duration.
    rs_health-last_comp_duration_below_limit = xsdbool(
      rs_health-last_comp_dur_min_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_duration > 0
      AND is_summary-last_completed_duration
        < iv_min_last_completed_duration ).
    rs_health-last_comp_success_required_on = xsdbool(
      iv_require_last_completed_success = abap_true ).
    rs_health-last_completed_success_breach = xsdbool(
      rs_health-last_comp_success_required_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_status <> 'S' ).
    rs_health-last_comp_succ_streak_limit_on = xsdbool(
      iv_min_last_completed_success_streak > 0 ).
    rs_health-last_comp_success_streak_limit =
      iv_min_last_completed_success_streak.
    rs_health-last_cmp_succ_streak_below_lim = xsdbool(
      rs_health-last_comp_succ_streak_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_success_streak
        < iv_min_last_completed_success_streak ).
    rs_health-last_comp_non_success_limit_on = xsdbool(
      iv_max_last_completed_non_success_streak > 0 ).
    rs_health-last_comp_non_success_limit =
      iv_max_last_completed_non_success_streak.
    rs_health-last_comp_non_succ_above_limit = xsdbool(
      rs_health-last_comp_non_success_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_non_success_streak
        > iv_max_last_completed_non_success_streak ).
    rs_health-last_comp_alloc_count_limit_on = xsdbool(
      iv_min_last_completed_alloc_lines > 0 ).
    rs_health-last_comp_alloc_count_limit =
      iv_min_last_completed_alloc_lines.
    rs_health-last_comp_alloc_cnt_below_lim = xsdbool(
      rs_health-last_comp_alloc_count_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_demand > 0
      AND rs_health-last_comp_allocated_line_count
        < iv_min_last_completed_alloc_lines ).
    rs_health-last_comp_alloc_cnt_max_lim_on = xsdbool(
      iv_max_last_completed_alloc_lines > 0 ).
    rs_health-last_comp_alloc_cnt_max_limit =
      iv_max_last_completed_alloc_lines.
    rs_health-last_comp_acnt_max_above_limit = xsdbool(
      rs_health-last_comp_alloc_cnt_max_lim_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND is_summary-last_completed_demand > 0
      AND rs_health-last_comp_allocated_line_count
        > iv_max_last_completed_alloc_lines ).
    rs_health-average_duration_limit_active = xsdbool(      iv_max_average_duration > 0 ).
    rs_health-average_duration_threshold = iv_max_average_duration.
    rs_health-average_duration_above_limit = xsdbool(
      rs_health-average_duration_limit_active = abap_true
      AND rs_health-duration_metrics_available = abap_true
      AND is_summary-average_duration_seconds > iv_max_average_duration ).
    rs_health-maximum_duration_limit_active = xsdbool(      iv_max_completed_duration > 0 ).
    rs_health-maximum_duration_threshold = iv_max_completed_duration.
    rs_health-maximum_duration_above_limit = xsdbool(
      rs_health-maximum_duration_limit_active = abap_true
      AND rs_health-duration_metrics_available = abap_true
      AND is_summary-maximum_duration_seconds > iv_max_completed_duration ).
    rs_health-duration_count_limit_active = xsdbool(
      iv_min_duration_count > 0 ).
    rs_health-duration_count_threshold = iv_min_duration_count.
    rs_health-duration_count_below_threshold = xsdbool(
      rs_health-duration_count_limit_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-completed_duration_runs < iv_min_duration_count ).
    rs_health-run_count_threshold_active = xsdbool(
      iv_min_run_count > 0 ).
    rs_health-run_count_threshold = iv_min_run_count.
    rs_health-run_count_below_threshold = xsdbool(
      rs_health-run_count_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-total_runs < iv_min_run_count ).
    rs_health-deadline_count_limit_active = xsdbool(
      iv_min_deadline_count > 0 ).
    rs_health-deadline_count_threshold = iv_min_deadline_count.
    rs_health-deadline_count_below_threshold = xsdbool(
      rs_health-deadline_count_limit_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-deadline_count < iv_min_deadline_count ).
    rs_health-deadline_mix_threshold_active = xsdbool(
      iv_min_deadline_mix > 0 ).
    rs_health-deadline_mix_threshold = iv_min_deadline_mix.
    rs_health-deadline_mix_below_threshold = xsdbool(
      rs_health-deadline_mix_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-deadline_mix_pct < iv_min_deadline_mix ).
    rs_health-overdue_mix_threshold_active = xsdbool(
      iv_max_overdue_mix > 0 ).
    rs_health-overdue_mix_threshold = iv_max_overdue_mix.
    rs_health-overdue_mix_above_threshold = xsdbool(
      rs_health-overdue_mix_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-overdue_mix_pct > iv_max_overdue_mix ).
    rs_health-current_deadline_mix_limit_on = xsdbool(
      iv_max_current_deadline_mix > 0 ).
    rs_health-current_deadline_mix_threshold = iv_max_current_deadline_mix.
    rs_health-curr_deadline_mix_above_limit = xsdbool(
      rs_health-current_deadline_mix_limit_on = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-current_deadline_mix_pct > iv_max_current_deadline_mix ).
    rs_health-future_deadline_mix_limit_on = xsdbool(
      iv_min_future_deadline_mix > 0 ).
    rs_health-future_deadline_mix_threshold = iv_min_future_deadline_mix.
    rs_health-fut_deadline_mix_below_limit = xsdbool(
      rs_health-future_deadline_mix_limit_on = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-future_deadline_mix_pct < iv_min_future_deadline_mix ).
    rs_health-mixed_policy_warning_active = xsdbool(
      iv_warn_mixed_policies = abap_true ).
    rs_health-mixed_policy_breach = xsdbool(
      rs_health-mixed_policy_warning_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-mixed_policies = abap_true ).
    rs_health-mixed_unit_warning_active = xsdbool(
      iv_warn_mixed_units = abap_true ).
    rs_health-mixed_unit_breach = xsdbool(
      rs_health-mixed_unit_warning_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-mixed_units = abap_true ).
    rs_health-completion_threshold_active = xsdbool(      iv_min_completion_rate > 0 ).
    rs_health-completion_threshold = iv_min_completion_rate.
    rs_health-completion_below_threshold = xsdbool(
      rs_health-completion_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-completion_pct < iv_min_completion_rate ).
    rs_health-success_threshold_active = xsdbool(      iv_min_success_rate > 0 ).
    rs_health-success_threshold = iv_min_success_rate.
    rs_health-success_below_threshold = xsdbool(
      rs_health-success_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-success_rate_pct < iv_min_success_rate ).
    rs_health-success_count_threshold_active = xsdbool(
      iv_min_success_count > 0 ).
    rs_health-success_count_threshold = iv_min_success_count.
    rs_health-success_count_below_threshold = xsdbool(
      rs_health-success_count_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-success_runs < iv_min_success_count ).
    rs_health-error_threshold_active = xsdbool(      iv_max_error_rate > 0 ).
    rs_health-error_threshold = iv_max_error_rate.
    rs_health-error_above_threshold = xsdbool(
      rs_health-error_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-error_rate_pct > iv_max_error_rate ).
    rs_health-partial_threshold_active = xsdbool(      iv_max_partial_rate > 0 ).
    rs_health-partial_threshold = iv_max_partial_rate.
    rs_health-partial_above_threshold = xsdbool(
      rs_health-partial_threshold_active = abap_true
      AND is_summary-total_runs > 0
      AND is_summary-partial_rate_pct > iv_max_partial_rate ).
    rs_health-full_line_threshold_active = xsdbool(      iv_min_full_line_rate > 0 ).
    rs_health-full_line_threshold = iv_min_full_line_rate.
    rs_health-full_line_below_threshold = xsdbool(
      rs_health-full_line_threshold_active = abap_true
      AND is_summary-demand_count > 0
      AND rs_health-full_line_pct < iv_min_full_line_rate ).
    rs_health-unallocated_line_limit_active = xsdbool(      iv_max_unalloc_line_rate > 0 ).
    rs_health-unallocated_line_threshold = iv_max_unalloc_line_rate.
    rs_health-unallocated_line_above_limit = xsdbool(
      rs_health-unallocated_line_limit_active = abap_true
      AND is_summary-demand_count > 0
      AND rs_health-unallocated_line_pct > iv_max_unalloc_line_rate ).
    rs_health-partial_line_threshold_active = xsdbool(      iv_max_partial_line_rate > 0 ).
    rs_health-partial_line_threshold = iv_max_partial_line_rate.
    rs_health-partial_line_above_threshold = xsdbool(
      rs_health-partial_line_threshold_active = abap_true
      AND is_summary-demand_count > 0
      AND rs_health-partial_line_pct > iv_max_partial_line_rate ).
    rs_health-full_count_threshold_active = xsdbool(      iv_min_full_line_count > 0 ).
    rs_health-full_count_threshold = iv_min_full_line_count.
    rs_health-full_count_below_threshold = xsdbool(
      rs_health-full_count_threshold_active = abap_true
      AND is_summary-demand_count > 0
      AND is_summary-full_count < iv_min_full_line_count ).
    rs_health-demand_count_threshold_active = xsdbool(      iv_max_demand_count > 0 ).
    rs_health-demand_count_threshold = iv_max_demand_count.
    rs_health-demand_count_above_threshold = xsdbool(
      rs_health-demand_count_threshold_active = abap_true
      AND is_summary-demand_count > iv_max_demand_count ).
    rs_health-running_count_threshold_active = xsdbool(
      iv_max_running_count > 0 ).
    rs_health-running_count_threshold = iv_max_running_count.
    rs_health-running_count_above_threshold = xsdbool(
      rs_health-running_count_threshold_active = abap_true
      AND is_summary-running_runs > iv_max_running_count ).
    rs_health-shortage_quantity_limit_active = xsdbool(
      iv_max_shortage_quantity > 0 ).
    rs_health-shortage_quantity_threshold = iv_max_shortage_quantity.
    rs_health-shortage_quantity_above_limit = xsdbool(
      rs_health-shortage_quantity_limit_active = abap_true
      AND rs_health-shortage_available = abap_true
      AND is_summary-shortage > iv_max_shortage_quantity ).
    rs_health-last_shortage_qty_limit_active = xsdbool(
      iv_max_last_shortage_qty > 0 ).
    rs_health-last_shortage_qty_threshold = iv_max_last_shortage_qty.
    rs_health-last_shortage_qty_above_limit = xsdbool(
      rs_health-last_shortage_qty_limit_active = abap_true
      AND rs_health-last_run_available = abap_true
      AND is_summary-last_requested > 0
      AND is_summary-last_shortage > iv_max_last_shortage_qty ).
    rs_health-last_shortage_pct_limit_active = xsdbool(
      iv_max_last_shortage_pct > 0 ).
    rs_health-last_shortage_pct_threshold = iv_max_last_shortage_pct.
    rs_health-last_shortage_pct_above_limit = xsdbool(
      rs_health-last_shortage_pct_limit_active = abap_true
      AND rs_health-last_shortage_pct_available = abap_true
      AND rs_health-last_shortage_pct > iv_max_last_shortage_pct ).
    rs_health-last_comp_coverage_limit_on = xsdbool(
      iv_min_last_completed_coverage > 0 ).
    rs_health-last_comp_coverage_limit = iv_min_last_completed_coverage.
    rs_health-last_comp_coverage_below_limit = xsdbool(
      rs_health-last_comp_coverage_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_requested > 0
      AND rs_health-last_completed_coverage < iv_min_last_completed_coverage ).
    rs_health-last_comp_cov_max_limit_on = xsdbool(
      iv_max_last_completed_coverage > 0 ).
    rs_health-last_comp_coverage_max_limit =
      iv_max_last_completed_coverage.
    rs_health-last_comp_coverage_above_limit = xsdbool(
      rs_health-last_comp_cov_max_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_requested > 0
      AND rs_health-last_completed_coverage
        > iv_max_last_completed_coverage ).
    rs_health-last_comp_short_pct_limit_on = xsdbool(
      iv_max_last_completed_shortage_pct > 0 ).
    rs_health-last_comp_shortage_pct_limit =
      iv_max_last_completed_shortage_pct.
    rs_health-last_comp_short_pct_above_lim = xsdbool(
      rs_health-last_comp_short_pct_limit_on = abap_true
      AND rs_health-last_comp_shortage_pct_avail = abap_true
      AND rs_health-last_completed_shortage_pct > iv_max_last_completed_shortage_pct ).
    rs_health-last_comp_short_qty_limit_on = xsdbool(
      iv_max_last_completed_shortage_qty > 0 ).
    rs_health-last_comp_shortage_qty_limit =
      iv_max_last_completed_shortage_qty.
    rs_health-last_comp_short_qty_above_lim = xsdbool(
      rs_health-last_comp_short_qty_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_shortage
        > iv_max_last_completed_shortage_qty ).
    rs_health-last_comp_requested_limit_on = xsdbool(
      iv_max_last_completed_requested > 0 ).
    rs_health-last_comp_requested_limit =
      iv_max_last_completed_requested.
    rs_health-last_comp_req_above_limit = xsdbool(
      rs_health-last_comp_requested_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_requested > 0
      AND rs_health-last_completed_requested
        > iv_max_last_completed_requested ).
    rs_health-last_comp_req_min_limit_on = xsdbool(
      iv_min_last_completed_requested > 0 ).
    rs_health-last_comp_requested_min_limit =
      iv_min_last_completed_requested.
    rs_health-last_comp_req_below_limit = xsdbool(
      rs_health-last_comp_req_min_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_requested > 0
      AND rs_health-last_completed_requested
        < iv_min_last_completed_requested ).
    rs_health-last_comp_allocated_limit_on = xsdbool(
      iv_min_last_completed_allocated > 0 ).
    rs_health-last_comp_allocated_limit =
      iv_min_last_completed_allocated.
    rs_health-last_comp_alloc_below_limit = xsdbool(
      rs_health-last_comp_allocated_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_requested > 0
      AND rs_health-last_completed_allocated
        < iv_min_last_completed_allocated ).
    rs_health-last_comp_alloc_max_limit_on = xsdbool(
      iv_max_last_completed_allocated > 0 ).
    rs_health-last_comp_allocated_max_limit =
      iv_max_last_completed_allocated.
    rs_health-last_comp_alloc_above_limit = xsdbool(
      rs_health-last_comp_alloc_max_limit_on = abap_true
      AND rs_health-last_completed_run_available = abap_true
      AND rs_health-last_completed_requested > 0
      AND rs_health-last_completed_allocated
        > iv_max_last_completed_allocated ).
    rs_health-last_comp_avail_stk_min_lim_on = xsdbool(
      iv_min_last_completed_avail_stock > 0 ).
    rs_health-last_comp_avail_stk_min_limit =
      iv_min_last_completed_avail_stock.
    rs_health-last_comp_avail_stk_below_lim = xsdbool(
      rs_health-last_comp_avail_stk_min_lim_on = abap_true
      AND rs_health-last_comp_avail_stock_avail = abap_true
      AND rs_health-last_completed_available_stock
        < iv_min_last_completed_avail_stock ).
    rs_health-last_comp_avail_stk_max_lim_on = xsdbool(
      iv_max_last_completed_avail_stock > 0 ).
    rs_health-last_comp_avail_stk_max_limit =
      iv_max_last_completed_avail_stock.
    rs_health-last_comp_avail_stk_above_lim = xsdbool(
      rs_health-last_comp_avail_stk_max_lim_on = abap_true
      AND rs_health-last_comp_avail_stock_avail = abap_true
      AND rs_health-last_completed_available_stock
        > iv_max_last_completed_avail_stock ).
    rs_health-last_comp_full_line_limit_on = xsdbool(
      iv_min_last_completed_full_line_rate > 0 ).
    rs_health-last_comp_full_line_limit =
      iv_min_last_completed_full_line_rate.
    rs_health-last_comp_full_ln_below_limit = xsdbool(
      rs_health-last_comp_full_line_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_completed_full_line_pct
        < iv_min_last_completed_full_line_rate ).
    rs_health-last_comp_full_ln_max_limit_on = xsdbool(
      iv_max_last_completed_full_line_rate > 0 ).
    rs_health-last_comp_full_line_max_limit =
      iv_max_last_completed_full_line_rate.
    rs_health-last_comp_full_ln_above_limit = xsdbool(
      rs_health-last_comp_full_ln_max_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_completed_full_line_pct
        > iv_max_last_completed_full_line_rate ).
    rs_health-last_comp_unalloc_ln_limit_on = xsdbool(
      iv_max_last_completed_unalloc_line_rate > 0 ).
    rs_health-last_comp_unalloc_line_limit =
      iv_max_last_completed_unalloc_line_rate.
    rs_health-last_comp_unalloc_ln_above_lim = xsdbool(
      rs_health-last_comp_unalloc_ln_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_comp_unalloc_line_pct
        > iv_max_last_completed_unalloc_line_rate ).
    rs_health-last_comp_part_line_limit_on = xsdbool(
      iv_max_last_completed_partial_line_rate > 0 ).
    rs_health-last_comp_partial_line_limit =
      iv_max_last_completed_partial_line_rate.
    rs_health-last_comp_part_ln_above_limit = xsdbool(
      rs_health-last_comp_part_line_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_comp_partial_line_pct
        > iv_max_last_completed_partial_line_rate ).
    rs_health-last_comp_full_count_limit_on = xsdbool(
      iv_min_last_completed_full_line_count > 0 ).
    rs_health-last_comp_full_count_limit =
      iv_min_last_completed_full_line_count.
    rs_health-last_comp_full_cnt_below_limit = xsdbool(
      rs_health-last_comp_full_count_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_completed_full < iv_min_last_completed_full_line_count ).
    rs_health-last_comp_unalloc_cnt_limit_on = xsdbool(
      iv_max_last_completed_unalloc_line_count > 0 ).
    rs_health-last_comp_unalloc_count_limit =
      iv_max_last_completed_unalloc_line_count.
    rs_health-last_comp_unalloc_cnt_over_lim = xsdbool(
      rs_health-last_comp_unalloc_cnt_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_completed_unalloc
        > iv_max_last_completed_unalloc_line_count ).
    rs_health-last_comp_partial_cnt_limit_on = xsdbool(
      iv_max_last_completed_partial_line_count > 0 ).
    rs_health-last_comp_partial_count_limit =
      iv_max_last_completed_partial_line_count.
    rs_health-last_comp_part_cnt_above_limit = xsdbool(
      rs_health-last_comp_partial_cnt_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_completed_partial
        > iv_max_last_completed_partial_line_count ).
    rs_health-last_comp_short_cnt_limit_on = xsdbool(
      iv_max_last_completed_shortage_line_count > 0 ).
    rs_health-last_comp_shortage_count_limit =
      iv_max_last_completed_shortage_line_count.
    rs_health-last_comp_short_cnt_above_lim = xsdbool(
      rs_health-last_comp_short_cnt_limit_on = abap_true
      AND rs_health-last_comp_line_rates_available = abap_true
      AND rs_health-last_completed_partial + rs_health-last_completed_unalloc
        > iv_max_last_completed_shortage_line_count ).
    rs_health-last_age_threshold_active = xsdbool(
      iv_max_last_age > 0 ).
    rs_health-last_age_threshold = iv_max_last_age.
    rs_health-last_age_above_threshold = xsdbool(
      rs_health-last_age_threshold_active = abap_true
      AND rs_health-last_age_available = abap_true
      AND rs_health-last_age_seconds > iv_max_last_age ).
    rs_health-last_comp_ddl_age_limit_on = xsdbool(
      iv_max_last_completed_deadline_age > 0 ).
    rs_health-last_comp_deadline_age_limit =
      iv_max_last_completed_deadline_age.
    rs_health-last_comp_ddl_age_above_limit = xsdbool(
      rs_health-last_comp_ddl_age_limit_on = abap_true
      AND is_summary-last_completed_deadline_age_available = abap_true
      AND is_summary-last_completed_deadline_age_days
        > iv_max_last_completed_deadline_age ).
    rs_health-last_comp_demand_cnt_limit_on = xsdbool(
      iv_max_last_completed_demand_count > 0 ).
    rs_health-last_comp_demand_count_limit =
      iv_max_last_completed_demand_count.
    rs_health-last_comp_demand_cnt_above_lim = xsdbool(
      rs_health-last_comp_demand_cnt_limit_on = abap_true
      AND is_summary-last_completed_run_id IS NOT INITIAL
      AND is_summary-last_completed_demand
        > iv_max_last_completed_demand_count ).
    rs_health-last_cmp_demand_cnt_min_lim_on = xsdbool(
      iv_min_last_completed_demand_count > 0 ).
    rs_health-last_comp_demand_cnt_min_limit =
      iv_min_last_completed_demand_count.
    rs_health-last_comp_demand_cnt_below_lim = xsdbool(
      rs_health-last_cmp_demand_cnt_min_lim_on = abap_true
      AND is_summary-last_completed_run_id IS NOT INITIAL
      AND is_summary-last_completed_demand > 0
      AND is_summary-last_completed_demand
        < iv_min_last_completed_demand_count ).
    rs_health-avail_stock_min_limit_active = xsdbool(
      iv_min_available_stock > 0 ).
    rs_health-avail_stock_min_threshold = iv_min_available_stock.
    rs_health-avail_stock_below_threshold = xsdbool(
      rs_health-avail_stock_min_limit_active = abap_true
      AND is_summary-total_runs > 0
      AND rs_health-avail_stock_context_avail = abap_true
      AND rs_health-available_stock_context < iv_min_available_stock ).
    rs_health-avail_stock_max_limit_active = xsdbool(
      iv_max_available_stock > 0 ).
    rs_health-avail_stock_max_threshold = iv_max_available_stock.
    rs_health-avail_stock_above_threshold = xsdbool(
      rs_health-avail_stock_max_limit_active = abap_true
      AND is_summary-total_runs > 0
      AND rs_health-avail_stock_context_avail = abap_true
      AND rs_health-available_stock_context > iv_max_available_stock ).
    IF rs_health-shortage_available = abap_true.
      rs_health-requested = is_summary-requested.
      rs_health-allocated = is_summary-allocated.
      rs_health-shortage = is_summary-shortage.
    ENDIF.
    IF rs_health-coverage_available = abap_true.
      rs_health-coverage = is_summary-coverage.
    ENDIF.
    IF rs_health-priority_share_available = abap_true.
      rs_health-priority_requested = is_summary-priority_requested.
      rs_health-priority_allocated = is_summary-priority_allocated.
      rs_health-priority_shortage = is_summary-priority_shortage.
    ENDIF.
    IF rs_health-priority_coverage_available = abap_true.
      rs_health-priority_coverage = is_summary-priority_coverage.
    ENDIF.
    IF rs_health-fifo_share_available = abap_true.
      rs_health-fifo_requested = is_summary-fifo_requested.
      rs_health-fifo_allocated = is_summary-fifo_allocated.
      rs_health-fifo_shortage = is_summary-fifo_shortage.
    ENDIF.
    IF rs_health-fifo_coverage_available = abap_true.
      rs_health-fifo_coverage = is_summary-fifo_coverage.
    ENDIF.
    IF rs_health-full_only_share_available = abap_true.
      rs_health-full_only_requested = is_summary-full_only_requested.
      rs_health-full_only_allocated = is_summary-full_only_allocated.
      rs_health-full_only_shortage = is_summary-full_only_shortage.
    ENDIF.
    IF rs_health-full_only_coverage_available = abap_true.
      rs_health-full_only_coverage = is_summary-full_only_coverage.
    ENDIF.
    IF rs_health-smallest_share_available = abap_true.
      rs_health-smallest_requested = is_summary-smallest_requested.
      rs_health-smallest_allocated = is_summary-smallest_allocated.
      rs_health-smallest_shortage = is_summary-smallest_shortage.
    ENDIF.
    IF rs_health-smallest_coverage_available = abap_true.
      rs_health-smallest_coverage = is_summary-smallest_coverage.
    ENDIF.
    IF rs_health-largest_share_available = abap_true.
      rs_health-largest_requested = is_summary-largest_requested.
      rs_health-largest_allocated = is_summary-largest_allocated.
      rs_health-largest_shortage = is_summary-largest_shortage.
    ENDIF.
    IF rs_health-largest_coverage_available = abap_true.
      rs_health-largest_coverage = is_summary-largest_coverage.
    ENDIF.
    IF rs_health-best_share_available = abap_true.
      rs_health-best_requested = is_summary-best_requested.
      rs_health-best_allocated = is_summary-best_allocated.
      rs_health-best_shortage = is_summary-best_shortage.
    ENDIF.
    IF rs_health-best_coverage_available = abap_true.
      rs_health-best_coverage = is_summary-best_coverage.
    ENDIF.
    IF rs_health-fair_share_available = abap_true.
      rs_health-fair_requested = is_summary-fair_requested.
      rs_health-fair_allocated = is_summary-fair_allocated.
      rs_health-fair_shortage = is_summary-fair_shortage.
    ENDIF.
    IF rs_health-fair_coverage_available = abap_true.
      rs_health-fair_coverage = is_summary-fair_coverage.
    ENDIF.
    IF rs_health-weighted_share_available = abap_true.
      rs_health-weighted_requested = is_summary-weighted_requested.
      rs_health-weighted_allocated = is_summary-weighted_allocated.
      rs_health-weighted_shortage = is_summary-weighted_shortage.
    ENDIF.
    IF rs_health-weighted_coverage_ok = abap_true.
      rs_health-weighted_coverage = is_summary-weighted_coverage.
    ENDIF.
    IF rs_health-adaptive_share_available = abap_true.
      rs_health-adaptive_requested = is_summary-adaptive_requested.
      rs_health-adaptive_allocated = is_summary-adaptive_allocated.
      rs_health-adaptive_shortage = is_summary-adaptive_shortage.
    ENDIF.
    IF rs_health-adaptive_coverage_ok = abap_true.
      rs_health-adaptive_coverage = is_summary-adaptive_coverage.
    ENDIF.
    rs_health-legacy_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-legacy_requested > 0 ).
    rs_health-legacy_coverage_available = rs_health-legacy_share_available.
    IF rs_health-legacy_share_available = abap_true.
      rs_health-legacy_requested = is_summary-legacy_requested.
      rs_health-legacy_allocated = is_summary-legacy_allocated.
      rs_health-legacy_shortage = is_summary-legacy_shortage.
    ENDIF.
    IF rs_health-legacy_coverage_available = abap_true.
      rs_health-legacy_coverage = is_summary-legacy_coverage.
    ENDIF.
    rs_health-coverage_below_threshold = xsdbool(
      rs_health-coverage_threshold_active = abap_true
      AND rs_health-coverage_available = abap_true
      AND is_summary-coverage < iv_min_coverage ).
    rs_health-last_coverage_below_threshold = xsdbool(
      rs_health-last_coverage_threshold_active = abap_true
      AND rs_health-last_run_available = abap_true
      AND is_summary-last_requested > 0
      AND is_summary-last_coverage < iv_min_last_coverage ).
    rs_health-shortage_above_threshold = xsdbool(
      rs_health-shortage_threshold_active = abap_true
      AND rs_health-shortage_available = abap_true
      AND is_summary-shortage_pct > iv_max_shortage_pct ).
    IF rs_health-coverage_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      rs_health-threshold_breaches = 'coverage'.
    ENDIF.
    IF rs_health-last_coverage_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_coverage'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'last_coverage'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-shortage_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'shortage'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'shortage'          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-duration_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'duration'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'duration'          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_duration_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_duration'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_duration'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_duration_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_duration_min'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_duration_min'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_completed_success_breach = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_not_success'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_not_success'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_cmp_succ_streak_below_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_success_streak'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_success_streak'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_non_succ_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_non_success_streak'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_non_success_streak'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_alloc_cnt_below_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_allocated_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_allocated_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_acnt_max_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_allocated_count_max'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_allocated_count_max'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-average_duration_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'average_duration'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'average_duration'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-maximum_duration_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'maximum_duration'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'maximum_duration'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-duration_count_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'duration_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'duration_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-run_count_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'run_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'run_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-deadline_count_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'deadline_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'deadline_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-deadline_mix_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'deadline_mix'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'deadline_mix'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-overdue_mix_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'overdue_mix'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'overdue_mix'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-curr_deadline_mix_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'current_deadline_mix'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'current_deadline_mix'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-fut_deadline_mix_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'future_deadline_mix'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'future_deadline_mix'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-mixed_policy_breach = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'mixed_policies'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'mixed_policies'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-mixed_unit_breach = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'mixed_units'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'mixed_units'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-success_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'success'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'success'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-completion_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'completion'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'completion'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-error_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'error'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'error'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-partial_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'partial'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'partial'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-shortage_quantity_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'shortage_quantity'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'shortage_quantity'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-full_line_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'full_line'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'full_line'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-unallocated_line_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'unallocated_line'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'unallocated_line'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-partial_line_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'partial_line'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'partial_line'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-full_count_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'full_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'full_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-demand_count_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'demand_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'demand_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_shortage_pct_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_shortage_pct'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'last_shortage_pct'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_age_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_age'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'last_age'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_ddl_age_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_deadline_age'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_deadline_age'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_demand_cnt_above_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_demand_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_demand_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_demand_cnt_below_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_demand_count_min'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_demand_count_min'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_coverage_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_coverage'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'last_completed_coverage'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_short_pct_above_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_shortage_pct'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_shortage_pct'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_short_qty_above_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_shortage_quantity'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_shortage_quantity'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_alloc_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_allocated'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_allocated'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_req_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_requested'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_requested'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_req_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_requested_min'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_requested_min'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_alloc_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_allocated_max'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_allocated_max'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_coverage_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_coverage_max'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_coverage_max'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_avail_stk_below_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_available_stock_min'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_available_stock_min'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_avail_stk_above_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_available_stock_max'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_available_stock_max'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_full_ln_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_full_line'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_full_line'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_full_ln_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_full_line_max'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_full_line_max'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_unalloc_ln_above_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_unallocated_line'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_unallocated_line'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_part_ln_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_partial_line'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_partial_line'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_full_cnt_below_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_full_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_full_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_unalloc_cnt_over_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_unallocated_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_unallocated_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_part_cnt_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_partial_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_partial_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_comp_short_cnt_above_lim = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_completed_shortage_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches
          'last_completed_shortage_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-last_shortage_qty_above_limit = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'last_shortage_quantity'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'last_shortage_quantity'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-avail_stock_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'available_stock_min'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'available_stock_min'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-avail_stock_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'available_stock_max'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'available_stock_max'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-success_count_below_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'success_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'success_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    IF rs_health-running_count_above_threshold = abap_true.
      rs_health-threshold_breach_count += 1.
      IF rs_health-threshold_breaches IS INITIAL.
        rs_health-threshold_breaches = 'running_count'.
      ELSE.
        CONCATENATE rs_health-threshold_breaches 'running_count'
          INTO rs_health-threshold_breaches SEPARATED BY '|'.
      ENDIF.
    ENDIF.
    rs_health-stale_threshold_active = xsdbool(
      iv_stale_threshold > 0 ).
    rs_health-stale_threshold = iv_stale_threshold.
    IF iv_stale_scope_evaluated = abap_true.
      rs_health-stale_running_runs = iv_stale_running_runs.
      lv_stale = xsdbool( iv_stale_running_runs > 0 ).
    ELSEIF iv_stale_running_runs IS NOT INITIAL.
      rs_health-stale_running_runs = iv_stale_running_runs.
      lv_stale = xsdbool( iv_stale_running_runs > 0 ).
    ELSEIF iv_stale_threshold > 0
        AND is_summary-running_runs > 0
        AND is_summary-oldest_running_age_seconds >= iv_stale_threshold.
      lv_stale = abap_true.
      rs_health-stale_running_runs = 1.
    ENDIF.
    rs_health-stale_above_threshold = xsdbool(
      rs_health-stale_threshold_active = abap_true
      AND lv_stale = abap_true ).
    IF is_summary-total_runs = 0.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'NO_RUNS'.
      rs_health-message = 'No allocation runs found for the selected scope'.
    ELSEIF is_summary-error_runs > 0 OR lv_stale = abap_true.
      rs_health-status = 'CRITICAL'.
      rs_health-reason_code = 'ERROR_OR_STALE'.
      IF is_summary-error_runs > 0 AND lv_stale = abap_true.
        rs_health-message = 'Allocation errors and stale running work detected'.
      ELSEIF is_summary-error_runs > 0.
        rs_health-message = 'Allocation errors detected'.
      ELSE.
        rs_health-message = 'Stale running allocation work detected'.
      ENDIF.
    ELSEIF rs_health-coverage_below_threshold = abap_true        AND rs_health-shortage_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Coverage is below minimum and shortage is above maximum'.
    ELSEIF rs_health-coverage_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation coverage is below the configured minimum'.
    ELSEIF rs_health-last_coverage_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest allocation coverage is below the configured minimum'.
    ELSEIF rs_health-shortage_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation shortage is above the configured maximum'.
    ELSEIF rs_health-shortage_quantity_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation shortage quantity is above the configured maximum'.
    ELSEIF rs_health-last_shortage_qty_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest allocation shortage quantity is above the configured maximum'.
    ELSEIF rs_health-last_shortage_pct_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest allocation shortage percentage is above the configured maximum'.
    ELSEIF rs_health-last_age_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation age is above the configured maximum'.
    ELSEIF rs_health-last_comp_ddl_age_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed deadline age is above the configured maximum'.
    ELSEIF rs_health-last_comp_demand_cnt_above_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed demand count is above the configured maximum'.
    ELSEIF rs_health-last_comp_demand_cnt_below_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed demand count is below the configured minimum'.
    ELSEIF rs_health-last_comp_coverage_below_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation coverage is below the configured minimum'.
    ELSEIF rs_health-last_comp_short_pct_above_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation shortage percentage is above the configured maximum'.
    ELSEIF rs_health-last_comp_short_qty_above_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation shortage quantity is above the configured maximum'.
    ELSEIF rs_health-last_comp_alloc_below_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocated quantity is below the configured minimum'.
    ELSEIF rs_health-last_comp_req_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed requested quantity is above the configured maximum'.
    ELSEIF rs_health-last_comp_req_below_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed requested quantity is below the configured minimum'.
    ELSEIF rs_health-last_comp_alloc_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocated quantity is above the configured maximum'.
    ELSEIF rs_health-last_comp_coverage_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation coverage is above the configured maximum'.
    ELSEIF rs_health-last_comp_avail_stk_below_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed available stock is below the configured minimum'.
    ELSEIF rs_health-last_comp_avail_stk_above_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed available stock is above the configured maximum'.
    ELSEIF rs_health-last_comp_full_ln_below_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed full-line rate is below the configured minimum'.
    ELSEIF rs_health-last_comp_full_ln_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed full-line rate is above the configured maximum'.
    ELSEIF rs_health-last_comp_unalloc_ln_above_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed unallocated-line rate is above the configured maximum'.
    ELSEIF rs_health-last_comp_part_ln_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed partial-line rate is above the configured maximum'.
    ELSEIF rs_health-last_comp_full_cnt_below_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed full-line count is below the configured minimum'.
    ELSEIF rs_health-last_comp_unalloc_cnt_over_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed unallocated-line count is above the configured maximum'.
    ELSEIF rs_health-last_comp_part_cnt_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed partial-line count is above the configured maximum'.
    ELSEIF rs_health-last_comp_short_cnt_above_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed shortage-line count is above the configured maximum'.
    ELSEIF rs_health-avail_stock_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Available stock is below the configured minimum'.
    ELSEIF rs_health-avail_stock_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Available stock is above the configured maximum'.
    ELSEIF rs_health-duration_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest allocation duration is above the configured maximum'.
    ELSEIF rs_health-last_comp_duration_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation duration is above the configured maximum'.
    ELSEIF rs_health-last_comp_duration_below_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation duration is below the configured minimum'.
    ELSEIF rs_health-last_completed_success_breach = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation did not succeed'.
    ELSEIF rs_health-last_cmp_succ_streak_below_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation success streak is below the configured minimum'.
    ELSEIF rs_health-last_comp_non_succ_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocation non-success streak is above the configured maximum'.
    ELSEIF rs_health-last_comp_alloc_cnt_below_lim = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocated line count is below the configured minimum'.
    ELSEIF rs_health-last_comp_acnt_max_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Latest completed allocated line count is above the configured maximum'.
    ELSEIF rs_health-average_duration_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Average allocation duration is above the configured maximum'.
    ELSEIF rs_health-maximum_duration_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Maximum completed allocation duration is above the configured maximum'.
    ELSEIF rs_health-duration_count_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Completed duration sample count is below the configured minimum'.
    ELSEIF rs_health-run_count_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation run count is below the configured minimum'.
    ELSEIF rs_health-deadline_count_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Deadline-bearing run count is below the configured minimum'.
    ELSEIF rs_health-mixed_policy_breach = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Selected allocation runs use mixed policy context'.
    ELSEIF rs_health-mixed_unit_breach = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Selected allocation runs use mixed units'
        && ' and quantity totals are unavailable'.
    ELSEIF rs_health-completion_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation completion rate is below the configured minimum'.
    ELSEIF rs_health-success_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation success rate is below the configured minimum'.
    ELSEIF rs_health-success_count_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Successful allocation count is below the configured minimum'.
    ELSEIF rs_health-error_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation error rate is above the configured maximum'.
    ELSEIF rs_health-partial_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation partial-run rate is above the configured maximum'.
    ELSEIF rs_health-full_line_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Full-line allocation rate is below the configured minimum'.
    ELSEIF rs_health-unallocated_line_above_limit = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Unallocated-line rate is above the configured maximum'.
    ELSEIF rs_health-partial_line_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Partial-line rate is above the configured maximum'.
    ELSEIF rs_health-full_count_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Full-line count is below the configured minimum'.
    ELSEIF rs_health-demand_count_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Demand count is above the configured maximum'.
    ELSEIF rs_health-running_count_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Running allocation count is above the configured maximum'.
    ELSEIF is_summary-partial_runs > 0
        OR ( rs_health-shortage_available = abap_true
          AND is_summary-shortage > 0 ).
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'BACKLOG'.
      rs_health-message = 'Allocation backlog or partial runs detected'.
    ELSE.
      rs_health-status = 'HEALTHY'.
      rs_health-reason_code = 'HEALTHY'.
      rs_health-message = 'Allocation scope is healthy'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
