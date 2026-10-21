CLASS zcl_prod_order_read_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_receipt_progress_not_started TYPE c LENGTH 1 VALUE 'N'.
    CONSTANTS c_receipt_progress_partial TYPE c LENGTH 1 VALUE 'P'.
    CONSTANTS c_receipt_progress_complete TYPE c LENGTH 1 VALUE 'C'.
    CONSTANTS c_receipt_over_received TYPE c LENGTH 1 VALUE 'O'.
    TYPES:
      BEGIN OF ty_exec_duration_issue_count,
        issue_code                  TYPE c LENGTH 2,
        status                      TYPE c LENGTH 1,
        confirmation_count          TYPE i,
        confirmation_pct            TYPE decfloat34,
        nonrev_confirmation_count   TYPE i,
        reversed_confirmation_count TYPE i,
        nonrev_confirmation_pct     TYPE decfloat34,
        reversed_confirmation_pct   TYPE decfloat34,
        issue_share_pct             TYPE decfloat34,
        nonrev_issue_share_pct      TYPE decfloat34,
        reversed_issue_share_pct    TYPE decfloat34,
        status_share_pct            TYPE decfloat34,
        nonrev_status_share_pct     TYPE decfloat34,
        reversed_status_share_pct   TYPE decfloat34,
      END OF ty_exec_duration_issue_count.
    TYPES ty_exec_duration_issue_counts TYPE SORTED TABLE OF
      ty_exec_duration_issue_count WITH UNIQUE KEY issue_code.
    TYPES:
      BEGIN OF ty_status_result,
        status_code       TYPE zif_prod_order_read_repo=>ty_order_status-status_code,
        is_user_status    TYPE abap_bool,
        status_short_name TYPE zif_prod_order_read_repo=>ty_order_status-status_short_name,
        status_name       TYPE zif_prod_order_read_repo=>ty_order_status-status_name,
      END OF ty_status_result.
    TYPES ty_status_results TYPE STANDARD TABLE OF ty_status_result
      WITH EMPTY KEY.
    TYPES ty_receipt_progress_status TYPE c LENGTH 1.
    TYPES:
      BEGIN OF ty_item_result,
        order_item                    TYPE
          zif_prod_order_read_repo=>ty_order_item,
        order_quantity_base           TYPE decfloat34,
        received_quantity_base        TYPE decfloat34,
        open_quantity_base            TYPE decfloat34,
        over_receipt_quantity_base    TYPE decfloat34,
        open_quantity_order_unit      TYPE decfloat34,
        over_receipt_qty_order_unit   TYPE decfloat34,
        over_receipt_pct_of_order_qty TYPE p LENGTH 16 DECIMALS 2,
        received_pct_of_order_qty     TYPE p LENGTH 16 DECIMALS 2,
        open_pct_of_order_qty         TYPE p LENGTH 5 DECIMALS 2,
        receipt_progress_status       TYPE ty_receipt_progress_status,
        is_receipt_progress_valid     TYPE abap_bool,
        matches_finish_selection      TYPE abap_bool,
        is_quantity_converted         TYPE abap_bool,
      END OF ty_item_result.
    TYPES ty_item_results TYPE STANDARD TABLE OF ty_item_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_receipt_progress_counts,
        total_item_count         TYPE i,
        not_started_item_count   TYPE i,
        partial_item_count       TYPE i,
        complete_item_count      TYPE i,
        over_received_item_count TYPE i,
        invalid_item_count       TYPE i,
        not_started_pct          TYPE p LENGTH 5 DECIMALS 2,
        partial_pct              TYPE p LENGTH 5 DECIMALS 2,
        complete_pct             TYPE p LENGTH 5 DECIMALS 2,
        over_received_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_pct              TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_receipt_progress_counts.
    TYPES:
      BEGIN OF ty_finish_base_progress_qty,
        order_qty_base_total          TYPE decfloat34,
        received_qty_base_total       TYPE decfloat34,
        open_qty_base_total           TYPE decfloat34,
        over_rcpt_qty_base_total      TYPE decfloat34,
        order_qty_total_share_pct     TYPE p LENGTH 5 DECIMALS 2,
        received_qty_total_share_pct  TYPE p LENGTH 5 DECIMALS 2,
        open_qty_total_share_pct      TYPE p LENGTH 5 DECIMALS 2,
        over_rcpt_qty_total_share_pct TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_finish_base_progress_qty.
    TYPES:
      BEGIN OF ty_progress_qty_totals,
        not_started   TYPE ty_finish_base_progress_qty,
        partial       TYPE ty_finish_base_progress_qty,
        complete      TYPE ty_finish_base_progress_qty,
        over_received TYPE ty_finish_base_progress_qty,
        invalid       TYPE ty_finish_base_progress_qty,
      END OF ty_progress_qty_totals.
    TYPES:
      BEGIN OF ty_finish_base_qty_summary,
        item_count                     TYPE i,
        excluded_item_count            TYPE i,
        invalid_progress_count         TYPE i,
        valid_progress_conv_fail_count TYPE i,
        order_qty_base_total           TYPE decfloat34,
        received_qty_base_total        TYPE decfloat34,
        open_qty_base_total            TYPE decfloat34,
        over_rcpt_qty_base_total       TYPE decfloat34,
        contributing_progress_counts   TYPE ty_receipt_progress_counts,
        contributing_progress_qty      TYPE ty_progress_qty_totals,
        contributing_item_pct          TYPE p LENGTH 5 DECIMALS 2,
        excluded_item_pct              TYPE p LENGTH 5 DECIMALS 2,
        invalid_progress_pct           TYPE p LENGTH 5 DECIMALS 2,
        valid_progress_conv_fail_pct   TYPE p LENGTH 5 DECIMALS 2,
        invalid_excluded_share_pct     TYPE p LENGTH 5 DECIMALS 2,
        conv_fail_excluded_share_pct   TYPE p LENGTH 5 DECIMALS 2,
        received_pct_of_order_qty      TYPE p LENGTH 16 DECIMALS 2,
        open_pct_of_order_qty          TYPE p LENGTH 16 DECIMALS 2,
        over_rcpt_pct_of_order_qty     TYPE p LENGTH 16 DECIMALS 2,
        over_rcpt_pct_of_received_qty  TYPE p LENGTH 16 DECIMALS 2,
      END OF ty_finish_base_qty_summary.
    TYPES:
      BEGIN OF ty_order_result,
        request_index              TYPE i,
        production_order           TYPE
          zif_prod_order_read_repo=>ty_order_number,
        items                      TYPE ty_item_results,
        receipt_progress_counts    TYPE ty_receipt_progress_counts,
        conversion_succeeded_count TYPE i,
        conversion_failed_count    TYPE i,
        matching_conv_ok_count     TYPE i,
        matching_conv_fail_count   TYPE i,
        statuses                   TYPE ty_status_results,
        status_filter_lost         TYPE abap_bool,
        finish_filter_lost         TYPE abap_bool,
        finish_window_match_count  TYPE i,
        matching_progress_counts   TYPE ty_receipt_progress_counts,
        matching_base_qty_summary  TYPE ty_finish_base_qty_summary,
        is_found                   TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_read_result,
        orders                        TYPE ty_order_results,
        found_count                   TYPE i,
        not_found_count               TYPE i,
        conversion_succeeded_count    TYPE i,
        conversion_failed_count       TYPE i,
        finish_match_conv_ok_count    TYPE i,
        finish_match_conv_fail_count  TYPE i,
        receipt_progress_counts       TYPE ty_receipt_progress_counts,
        finish_match_progress_counts  TYPE ty_receipt_progress_counts,
        finish_match_base_qty_summary TYPE ty_finish_base_qty_summary,
        is_truncated                  TYPE abap_bool,
        next_finish_date              TYPE afko-gltrp,
        next_production_order         TYPE
          zif_prod_order_read_repo=>ty_order_number,
        key_selection_timestamp       TYPE timestampl,
        snapshot_timestamp            TYPE timestampl,
        status_filter_lost_count      TYPE i,
        finish_filter_lost_count      TYPE i,
        is_successful                 TYPE abap_bool,
      END OF ty_bulk_read_result.
    TYPES:
      BEGIN OF ty_work_center_confirmation_quantity_summary,
        quantity_unit                  TYPE afru-meinh,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        yield_quantity_total           TYPE decfloat34,
        rework_quantity_total          TYPE decfloat34,
        scrap_quantity_total           TYPE decfloat34,
        yield_non_reversed_total       TYPE decfloat34,
        rework_non_reversed_total      TYPE decfloat34,
        scrap_non_reversed_total       TYPE decfloat34,
      END OF ty_work_center_confirmation_quantity_summary.
    TYPES ty_work_center_confirmation_quantity_summaries TYPE SORTED TABLE OF
      ty_work_center_confirmation_quantity_summary
      WITH UNIQUE KEY quantity_unit.
    TYPES:
      BEGIN OF ty_work_center_confirmation_summary,
        work_center                    TYPE crhd-arbpl,
        work_center_plant              TYPE crhd-werks,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        quantity_summaries             TYPE
          ty_work_center_confirmation_quantity_summaries,
      END OF ty_work_center_confirmation_summary.
    TYPES ty_work_center_confirmation_summaries TYPE SORTED TABLE OF
      ty_work_center_confirmation_summary
      WITH UNIQUE KEY work_center_plant work_center.
    TYPES:
      BEGIN OF ty_confirmation_order_result,
        request_index      TYPE i,
        production_order   TYPE
          zif_prod_order_read_repo=>ty_order_number,
        confirmations      TYPE
          zif_prod_order_read_repo=>ty_order_confirmations,
        confirmation_count TYPE i,
        is_found           TYPE abap_bool,
      END OF ty_confirmation_order_result.
    TYPES ty_confirmation_order_results TYPE STANDARD TABLE OF
      ty_confirmation_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_operation_order_result,
        request_index    TYPE i,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        operation_count  TYPE i,
        operations       TYPE
          zif_prod_order_read_repo=>ty_order_operations,
        is_found         TYPE abap_bool,
      END OF ty_operation_order_result.
    TYPES ty_operation_order_results TYPE STANDARD TABLE OF
      ty_operation_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_work_center_operation_summary,
        work_center       TYPE crhd-arbpl,
        work_center_plant TYPE crhd-werks,
        operation_count   TYPE i,
        order_count       TYPE i,
        operation_pct     TYPE p LENGTH 5 DECIMALS 2,
        order_pct         TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_work_center_operation_summary.
    TYPES ty_work_center_operation_summaries TYPE SORTED TABLE OF
      ty_work_center_operation_summary
      WITH UNIQUE KEY work_center_plant work_center.
    TYPES:
      BEGIN OF ty_work_center_operation_order_key,
        work_center       TYPE crhd-arbpl,
        work_center_plant TYPE crhd-werks,
        production_order  TYPE aufk-aufnr,
      END OF ty_work_center_operation_order_key.
    TYPES ty_work_center_operation_order_keys TYPE SORTED TABLE OF
      ty_work_center_operation_order_key
      WITH UNIQUE KEY work_center_plant work_center production_order.
    TYPES:
      BEGIN OF ty_order_category_operation_summary,
        order_category  TYPE aufk-autyp,
        operation_count TYPE i,
        order_count     TYPE i,
        operation_pct   TYPE p LENGTH 5 DECIMALS 2,
        order_pct       TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_order_category_operation_summary.
    TYPES ty_order_category_operation_summaries TYPE SORTED TABLE OF
      ty_order_category_operation_summary
      WITH UNIQUE KEY order_category.
    TYPES:
      BEGIN OF ty_order_category_operation_order_key,
        order_category   TYPE aufk-autyp,
        production_order TYPE aufk-aufnr,
      END OF ty_order_category_operation_order_key.
    TYPES ty_order_category_operation_order_keys TYPE SORTED TABLE OF
      ty_order_category_operation_order_key
      WITH UNIQUE KEY order_category production_order.
    TYPES:
      BEGIN OF ty_order_type_operation_summary,
        order_type      TYPE aufk-auart,
        operation_count TYPE i,
        order_count     TYPE i,
        operation_pct   TYPE p LENGTH 5 DECIMALS 2,
        order_pct       TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_order_type_operation_summary.
    TYPES ty_order_type_operation_summaries TYPE SORTED TABLE OF
      ty_order_type_operation_summary
      WITH UNIQUE KEY order_type.
    TYPES:
      BEGIN OF ty_order_type_operation_order_key,
        order_type       TYPE aufk-auart,
        production_order TYPE aufk-aufnr,
      END OF ty_order_type_operation_order_key.
    TYPES ty_order_type_operation_order_keys TYPE SORTED TABLE OF
      ty_order_type_operation_order_key
      WITH UNIQUE KEY order_type production_order.
    TYPES:
      BEGIN OF ty_control_key_operation_summary,
        control_key     TYPE afvc-steus,
        operation_count TYPE i,
        order_count     TYPE i,
        operation_pct   TYPE p LENGTH 5 DECIMALS 2,
        order_pct       TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_control_key_operation_summary.
    TYPES ty_control_key_operation_summaries TYPE SORTED TABLE OF
      ty_control_key_operation_summary
      WITH UNIQUE KEY control_key.
    TYPES:
      BEGIN OF ty_control_key_operation_order_key,
        control_key      TYPE afvc-steus,
        production_order TYPE aufk-aufnr,
      END OF ty_control_key_operation_order_key.
    TYPES ty_control_key_operation_order_keys TYPE SORTED TABLE OF
      ty_control_key_operation_order_key
      WITH UNIQUE KEY control_key production_order.
    TYPES:
      BEGIN OF ty_bulk_confirmation_read_result,
        orders                    TYPE ty_confirmation_order_results,
        work_center_summaries     TYPE ty_work_center_confirmation_summaries,
        returned_count            TYPE i,
        found_count               TYPE i,
        empty_count               TYPE i,
        is_truncated              TYPE abap_bool,
        next_production_order     TYPE afru-aufnr,
        next_posting_date         TYPE afru-budat,
        next_confirmation         TYPE afru-rueck,
        next_confirmation_counter TYPE afru-rmzhl,
        snapshot_timestamp        TYPE timestampl,
        is_successful             TYPE abap_bool,
      END OF ty_bulk_confirmation_read_result.
    TYPES:
      BEGIN OF ty_confirmation_operation_summary,
        production_order               TYPE
          zif_prod_order_read_repo=>ty_order_number,
        order_category                 TYPE aufk-autyp,
        order_type                     TYPE aufk-auart,
        operation_counter              TYPE afvc-aplzl,
        operation_number               TYPE afvc-vornr,
        operation_sequence             TYPE afvc-plnfl,
        operation_suboperation         TYPE afvc-uvorn,
        operation_description          TYPE afvc-ltxa1,
        control_key                    TYPE afvc-steus,
        resource_object_id             TYPE afvc-arbid,
        work_center                    TYPE crhd-arbpl,
        work_center_plant              TYPE crhd-werks,
        quantity_unit                  TYPE afru-meinh,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        yield_quantity_total           TYPE decfloat34,
        rework_quantity_total          TYPE decfloat34,
        scrap_quantity_total           TYPE decfloat34,
        yield_non_reversed_total       TYPE decfloat34,
        rework_non_reversed_total      TYPE decfloat34,
        scrap_non_reversed_total       TYPE decfloat34,
      END OF ty_confirmation_operation_summary.
    TYPES ty_confirmation_operation_summaries TYPE SORTED TABLE OF
      ty_confirmation_operation_summary
      WITH UNIQUE KEY production_order operation_counter
        operation_number operation_sequence operation_suboperation
        quantity_unit.
    TYPES:
      BEGIN OF ty_conf_order_summary,
        production_order               TYPE
          zif_prod_order_read_repo=>ty_order_number,
        order_category                 TYPE aufk-autyp,
        order_type                     TYPE aufk-auart,
        quantity_unit                  TYPE afru-meinh,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        yield_quantity_total           TYPE decfloat34,
        rework_quantity_total          TYPE decfloat34,
        scrap_quantity_total           TYPE decfloat34,
        yield_non_reversed_total       TYPE decfloat34,
        rework_non_reversed_total      TYPE decfloat34,
        scrap_non_reversed_total       TYPE decfloat34,
      END OF ty_conf_order_summary.
    TYPES ty_conf_order_summaries TYPE SORTED TABLE OF
      ty_conf_order_summary WITH UNIQUE KEY production_order quantity_unit.
    TYPES:
      BEGIN OF ty_confirmation_search_result,
        confirmations             TYPE
          zif_prod_order_read_repo=>ty_order_confirmations,
        work_center_summaries     TYPE ty_work_center_confirmation_summaries,
        operation_summaries       TYPE ty_confirmation_operation_summaries,
        order_summaries           TYPE ty_conf_order_summaries,
        returned_count            TYPE i,
        is_truncated              TYPE abap_bool,
        next_posting_date         TYPE afru-budat,
        next_production_order     TYPE
          zif_prod_order_read_repo=>ty_order_number,
        next_confirmation         TYPE afru-rueck,
        next_confirmation_counter TYPE afru-rmzhl,
        snapshot_timestamp        TYPE timestampl,
        is_successful             TYPE abap_bool,
      END OF ty_confirmation_search_result.
    TYPES:
      BEGIN OF ty_base_conf_quantity,
        confirmation_row     TYPE
          zif_prod_order_read_repo=>ty_order_confirmation,
        base_quantity_unit   TYPE mara-meins,
        yield_quantity_base  TYPE mard-labst,
        rework_quantity_base TYPE mard-labst,
        scrap_quantity_base  TYPE mard-labst,
      END OF ty_base_conf_quantity.
    TYPES ty_base_conf_quantities TYPE STANDARD TABLE OF
      ty_base_conf_quantity WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_base_conf_summary,
        production_order               TYPE
          zif_prod_order_read_repo=>ty_order_number,
        order_category                 TYPE aufk-autyp,
        order_type                     TYPE aufk-auart,
        operation_counter              TYPE afvc-aplzl,
        operation_number               TYPE afvc-vornr,
        operation_sequence             TYPE afvc-plnfl,
        operation_suboperation         TYPE afvc-uvorn,
        operation_description          TYPE afvc-ltxa1,
        control_key                    TYPE afvc-steus,
        resource_object_id             TYPE afvc-arbid,
        work_center                    TYPE crhd-arbpl,
        work_center_plant              TYPE crhd-werks,
        base_quantity_unit             TYPE mara-meins,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        yield_quantity_base_total      TYPE decfloat34,
        rework_quantity_base_total     TYPE decfloat34,
        scrap_quantity_base_total      TYPE decfloat34,
        yield_base_non_reversed_total  TYPE decfloat34,
        rework_base_non_reversed_total TYPE decfloat34,
        scrap_base_non_reversed_total  TYPE decfloat34,
      END OF ty_base_conf_summary.
    TYPES ty_base_conf_summaries TYPE SORTED TABLE OF
      ty_base_conf_summary
      WITH UNIQUE KEY production_order operation_counter
        operation_number operation_sequence operation_suboperation
        base_quantity_unit.
    TYPES:
      BEGIN OF ty_base_conf_order_summary,
        production_order               TYPE
          zif_prod_order_read_repo=>ty_order_number,
        order_category                 TYPE aufk-autyp,
        order_type                     TYPE aufk-auart,
        base_quantity_unit             TYPE mara-meins,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        yield_quantity_base_total      TYPE decfloat34,
        rework_quantity_base_total     TYPE decfloat34,
        scrap_quantity_base_total      TYPE decfloat34,
        yield_base_non_reversed_total  TYPE decfloat34,
        rework_base_non_reversed_total TYPE decfloat34,
        scrap_base_non_reversed_total  TYPE decfloat34,
      END OF ty_base_conf_order_summary.
    TYPES ty_base_conf_order_summaries TYPE SORTED TABLE OF
      ty_base_conf_order_summary
      WITH UNIQUE KEY production_order base_quantity_unit.
    TYPES:
      BEGIN OF ty_base_work_center_conf_summary,
        work_center                    TYPE crhd-arbpl,
        work_center_plant              TYPE crhd-werks,
        base_quantity_unit             TYPE mara-meins,
        first_posting_date             TYPE afru-budat,
        last_posting_date              TYPE afru-budat,
        execution_start_count          TYPE i,
        first_execution_start_date     TYPE afru-isdd,
        first_execution_start_time     TYPE afru-isdz,
        execution_start_pct            TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_count         TYPE i,
        last_execution_finish_date     TYPE afru-iedd,
        last_execution_finish_time     TYPE afru-iedz,
        execution_finish_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_count            TYPE i,
        valid_exec_duration_pct        TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_count    TYPE i,
        invalid_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count    TYPE i,
        missing_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count       TYPE i,
        zero_exec_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_seconds_total    TYPE decfloat34,
        exec_duration_seconds_min      TYPE decfloat34,
        exec_duration_seconds_max      TYPE decfloat34,
        exec_duration_seconds_avg      TYPE decfloat34,
        exec_duration_seconds_median   TYPE decfloat34,
        exec_duration_seconds_p90      TYPE decfloat34,
        exec_duration_seconds_p95      TYPE decfloat34,
        exec_duration_seconds_p99      TYPE decfloat34,
        exec_duration_seconds_p25      TYPE decfloat34,
        exec_duration_seconds_p75      TYPE decfloat34,
        exec_duration_seconds_iqr      TYPE decfloat34,
        exec_duration_seconds_mad      TYPE decfloat34,
        exec_nonrev_median_secs        TYPE decfloat34,
        exec_reversed_median_secs      TYPE decfloat34,
        exec_nonrev_p90_secs           TYPE decfloat34,
        exec_reversed_p90_secs         TYPE decfloat34,
        exec_duration_p90_median_ratio TYPE decfloat34,
        exec_nonrev_p90_median_ratio   TYPE decfloat34,
        exec_reversed_p90_median_ratio TYPE decfloat34,
        exec_duration_p90_exceed_count TYPE i,
        exec_duration_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_exceed_count   TYPE i,
        exec_nonrev_p90_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_exceed_count TYPE i,
        exec_reversed_p90_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p90_tail_secs             TYPE decfloat34,
        exec_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p90_tail_secs      TYPE decfloat34,
        exec_nonrev_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p90_tail_secs    TYPE decfloat34,
        exec_reversed_p90_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_secs           TYPE decfloat34,
        exec_reversed_p95_secs         TYPE decfloat34,
        exec_duration_p95_median_ratio TYPE decfloat34,
        exec_nonrev_p95_median_ratio   TYPE decfloat34,
        exec_reversed_p95_median_ratio TYPE decfloat34,
        exec_duration_p99_median_ratio TYPE decfloat34,
        exec_nonrev_p99_median_ratio   TYPE decfloat34,
        exec_reversed_p99_median_ratio TYPE decfloat34,
        exec_duration_p95_exceed_count TYPE i,
        exec_duration_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_exceed_count   TYPE i,
        exec_nonrev_p95_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_exceed_count TYPE i,
        exec_reversed_p95_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p95_tail_secs             TYPE decfloat34,
        exec_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p95_tail_secs      TYPE decfloat34,
        exec_nonrev_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p95_tail_secs    TYPE decfloat34,
        exec_reversed_p95_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_duration_p99_exceed_count TYPE i,
        exec_duration_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_exceed_count   TYPE i,
        exec_nonrev_p99_exceed_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_exceed_count TYPE i,
        exec_reversed_p99_exceed_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_p99_tail_secs             TYPE decfloat34,
        exec_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_tail_secs      TYPE decfloat34,
        exec_nonrev_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_p99_tail_secs    TYPE decfloat34,
        exec_reversed_p99_tail_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_p99_secs           TYPE decfloat34,
        exec_reversed_p99_secs         TYPE decfloat34,
        exec_nonrev_p25_secs           TYPE decfloat34,
        exec_nonrev_p75_secs           TYPE decfloat34,
        exec_reversed_p25_secs         TYPE decfloat34,
        exec_reversed_p75_secs         TYPE decfloat34,
        exec_nonrev_iqr_secs           TYPE decfloat34,
        exec_reversed_iqr_secs         TYPE decfloat34,
        exec_duration_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_iqr_median_ratio   TYPE decfloat34,
        exec_reversed_iqr_median_ratio TYPE decfloat34,
        exec_nonrev_min_secs           TYPE decfloat34,
        exec_nonrev_max_secs           TYPE decfloat34,
        exec_reversed_min_secs         TYPE decfloat34,
        exec_reversed_max_secs         TYPE decfloat34,
        exec_nonrev_mad_secs           TYPE decfloat34,
        exec_reversed_mad_secs         TYPE decfloat34,
        exec_duration_mad_median_ratio TYPE decfloat34,
        exec_nonrev_mad_median_ratio   TYPE decfloat34,
        exec_reversed_mad_median_ratio TYPE decfloat34,
        exec_duration_avg_median_ratio TYPE decfloat34,
        exec_nonrev_avg_median_ratio   TYPE decfloat34,
        exec_reversed_avg_median_ratio TYPE decfloat34,
        exec_pos_duration_count        TYPE i,
        exec_pos_median_secs           TYPE decfloat34,
        exec_pos_p90_secs              TYPE decfloat34,
        exec_nonrev_pos_count          TYPE i,
        exec_nonrev_pos_median_secs    TYPE decfloat34,
        exec_nonrev_pos_p90_secs       TYPE decfloat34,
        exec_reversed_pos_count        TYPE i,
        exec_pos_duration_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_pos_duration_pct TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_valid_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_zero_valid_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_zero_valid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_zero_valid_count          TYPE i,
        exec_nonrev_zero_valid_count   TYPE i,
        exec_rev_zero_valid_count      TYPE i,
        exec_nonrev_invalid_count      TYPE i,
        exec_rev_invalid_count         TYPE i,
        exec_nonrev_missing_count      TYPE i,
        exec_rev_missing_count         TYPE i,
        exec_nonrev_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_invalid_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_invalid_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_missing_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_missing_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_top_issue_code            TYPE c LENGTH 2,
        exec_top_issue_status          TYPE c LENGTH 1,
        exec_top_issue_count           TYPE i,
        exec_top_issue_pct             TYPE decfloat34,
        exec_top_invalid_issue_code    TYPE c LENGTH 2,
        exec_top_invalid_issue_count   TYPE i,
        exec_top_invalid_share_pct     TYPE decfloat34,
        exec_top_missing_issue_code    TYPE c LENGTH 2,
        exec_top_missing_issue_count   TYPE i,
        exec_top_missing_share_pct     TYPE decfloat34,
        exec_top_nonrev_issue_code     TYPE c LENGTH 2,
        exec_top_nonrev_issue_status   TYPE c LENGTH 1,
        exec_top_nonrev_issue_count    TYPE i,
        exec_top_nonrev_issue_pct      TYPE decfloat34,
        exec_top_reversed_issue_code   TYPE c LENGTH 2,
        exec_top_reversed_issue_status TYPE c LENGTH 1,
        exec_top_reversed_issue_count  TYPE i,
        exec_top_reversed_issue_pct    TYPE decfloat34,
        exec_duration_issue_counts     TYPE ty_exec_duration_issue_counts,
        exec_reversed_pos_median_secs  TYPE decfloat34,
        exec_reversed_pos_p90_secs     TYPE decfloat34,
        exec_pos_p90_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p90_med_ratio  TYPE decfloat34,
        exec_rev_pos_p90_med_ratio     TYPE decfloat34,
        exec_pos_p90_gt_count          TYPE i,
        exec_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p90_tail_secs         TYPE decfloat34,
        exec_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_gt_count   TYPE i,
        exec_nonrev_pos_p90_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p90_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p90_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_gt_count      TYPE i,
        exec_rev_pos_p90_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p90_tail_secs     TYPE decfloat34,
        exec_rev_pos_p90_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_secs              TYPE decfloat34,
        exec_pos_p99_secs              TYPE decfloat34,
        exec_nonrev_pos_p95_secs       TYPE decfloat34,
        exec_nonrev_pos_p99_secs       TYPE decfloat34,
        exec_rev_pos_p95_secs          TYPE decfloat34,
        exec_rev_pos_p99_secs          TYPE decfloat34,
        exec_pos_p25_secs              TYPE decfloat34,
        exec_pos_p75_secs              TYPE decfloat34,
        exec_pos_iqr_secs              TYPE decfloat34,
        exec_pos_mad_secs              TYPE decfloat34,
        exec_nonrev_pos_p25_secs       TYPE decfloat34,
        exec_nonrev_pos_p75_secs       TYPE decfloat34,
        exec_nonrev_pos_iqr_secs       TYPE decfloat34,
        exec_nonrev_pos_mad_secs       TYPE decfloat34,
        exec_rev_pos_p25_secs          TYPE decfloat34,
        exec_rev_pos_p75_secs          TYPE decfloat34,
        exec_rev_pos_iqr_secs          TYPE decfloat34,
        exec_rev_pos_mad_secs          TYPE decfloat34,
        exec_pos_iqr_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_iqr_med_ratio  TYPE decfloat34,
        exec_rev_pos_iqr_med_ratio     TYPE decfloat34,
        exec_pos_mad_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_mad_med_ratio  TYPE decfloat34,
        exec_rev_pos_mad_med_ratio     TYPE decfloat34,
        exec_pos_avg_secs              TYPE decfloat34,
        exec_nonrev_pos_avg_secs       TYPE decfloat34,
        exec_rev_pos_avg_secs          TYPE decfloat34,
        exec_pos_avg_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_avg_med_ratio  TYPE decfloat34,
        exec_rev_pos_avg_med_ratio     TYPE decfloat34,
        exec_pos_min_secs              TYPE decfloat34,
        exec_pos_max_secs              TYPE decfloat34,
        exec_pos_range_secs            TYPE decfloat34,
        exec_nonrev_pos_min_secs       TYPE decfloat34,
        exec_nonrev_pos_max_secs       TYPE decfloat34,
        exec_nonrev_pos_range_secs     TYPE decfloat34,
        exec_rev_pos_min_secs          TYPE decfloat34,
        exec_rev_pos_max_secs          TYPE decfloat34,
        exec_rev_pos_range_secs        TYPE decfloat34,
        exec_pos_p95_gt_count          TYPE i,
        exec_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_tail_secs         TYPE decfloat34,
        exec_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_gt_count   TYPE i,
        exec_nonrev_pos_p95_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p95_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p95_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_gt_count      TYPE i,
        exec_rev_pos_p95_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p95_tail_secs     TYPE decfloat34,
        exec_rev_pos_p95_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_gt_count          TYPE i,
        exec_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p99_tail_secs         TYPE decfloat34,
        exec_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_gt_count   TYPE i,
        exec_nonrev_pos_p99_gt_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_nonrev_pos_p99_tail_secs  TYPE decfloat34,
        exec_nonrev_pos_p99_tail_pct   TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_gt_count      TYPE i,
        exec_rev_pos_p99_gt_pct        TYPE p LENGTH 5 DECIMALS 2,
        exec_rev_pos_p99_tail_secs     TYPE decfloat34,
        exec_rev_pos_p99_tail_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_pos_p95_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p95_med_ratio  TYPE decfloat34,
        exec_rev_pos_p95_med_ratio     TYPE decfloat34,
        exec_pos_p99_med_ratio         TYPE decfloat34,
        exec_nonrev_pos_p99_med_ratio  TYPE decfloat34,
        exec_rev_pos_p99_med_ratio     TYPE decfloat34,
        exec_covered_seconds           TYPE decfloat34,
        exec_nonrev_covered_secs       TYPE decfloat34,
        exec_nonrev_duration_count     TYPE i,
        exec_nonrev_total_secs         TYPE decfloat34,
        exec_nonrev_duration_avg_secs  TYPE decfloat34,
        exec_nonrev_excess_secs        TYPE decfloat34,
        exec_reversed_duration_count   TYPE i,
        exec_reversed_total_secs       TYPE decfloat34,
        exec_rev_duration_avg_secs     TYPE decfloat34,
        exec_reversed_covered_secs     TYPE decfloat34,
        exec_reversed_excess_secs      TYPE decfloat34,
        exec_nonrev_duration_pct       TYPE p LENGTH 5 DECIMALS 2,
        exec_reversed_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_seconds     TYPE decfloat34,
        exec_single_episode_count      TYPE i,
        exec_longest_single_secs       TYPE decfloat34,
        exec_single_active_avg_secs    TYPE decfloat34,
        exec_high_concurrency_secs     TYPE decfloat34,
        exec_exactly_two_secs          TYPE decfloat34,
        exec_exactly_two_pct           TYPE p LENGTH 5 DECIMALS 2,
        exec_3plus_episode_count       TYPE i,
        exec_longest_3plus_secs        TYPE decfloat34,
        exec_3plus_avg_secs            TYPE decfloat34,
        exec_3plus_pct                 TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_excess_seconds    TYPE decfloat34,
        exec_peak_concurrency          TYPE i,
        exec_peak_concurrency_secs     TYPE decfloat34,
        exec_peak_concurrency_pct      TYPE p LENGTH 5 DECIMALS 2,
        exec_peak_episode_count        TYPE i,
        exec_longest_peak_secs         TYPE decfloat34,
        exec_peak_episode_avg_secs     TYPE decfloat34,
        exec_avg_concurrency           TYPE decfloat34,
        exec_idle_gap_seconds          TYPE decfloat34,
        exec_idle_gap_episode_count    TYPE i,
        exec_idle_gap_avg_secs         TYPE decfloat34,
        exec_interval_coverage_pct     TYPE p LENGTH 5 DECIMALS 2,
        exec_single_active_pct         TYPE p LENGTH 5 DECIMALS 2,
        exec_overlap_wall_pct          TYPE p LENGTH 5 DECIMALS 2,
        exec_longest_idle_gap_secs     TYPE decfloat34,
        exec_overlap_wall_seconds      TYPE decfloat34,
        exec_pairwise_overlap_secs     TYPE decfloat34,
        exec_overlap_episode_count     TYPE i,
        exec_overlap_pair_count        TYPE i,
        exec_overlap_pair_avg_secs     TYPE decfloat34,
        exec_longest_pair_overlap_secs TYPE decfloat34,
        exec_overlap_avg_secs          TYPE decfloat34,
        exec_longest_overlap_secs      TYPE decfloat34,
        confirmation_count             TYPE i,
        final_confirmation_count       TYPE i,
        partial_confirmation_count     TYPE i,
        reversed_confirmation_count    TYPE i,
        final_confirmation_pct         TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct       TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct      TYPE p LENGTH 5 DECIMALS 2,
        yield_quantity_base_total      TYPE decfloat34,
        rework_quantity_base_total     TYPE decfloat34,
        scrap_quantity_base_total      TYPE decfloat34,
        yield_base_non_reversed_total  TYPE decfloat34,
        rework_base_non_reversed_total TYPE decfloat34,
        scrap_base_non_reversed_total  TYPE decfloat34,
      END OF ty_base_work_center_conf_summary.
    TYPES ty_base_work_center_conf_summaries TYPE SORTED TABLE OF
      ty_base_work_center_conf_summary
      WITH UNIQUE KEY work_center_plant work_center base_quantity_unit.
    TYPES:
      BEGIN OF ty_conf_base_search_result,
        raw_result                 TYPE ty_confirmation_search_result,
        base_quantities            TYPE ty_base_conf_quantities,
        base_operation_summaries   TYPE ty_base_conf_summaries,
        base_order_summaries       TYPE ty_base_conf_order_summaries,
        base_work_center_summaries TYPE
          ty_base_work_center_conf_summaries,
      END OF ty_conf_base_search_result.
    TYPES:
      BEGIN OF ty_bulk_operation_read_result,
        orders                   TYPE ty_operation_order_results,
        work_center_summaries    TYPE ty_work_center_operation_summaries,
        order_category_summaries TYPE ty_order_category_operation_summaries,
        order_type_summaries     TYPE ty_order_type_operation_summaries,
        control_key_summaries    TYPE ty_control_key_operation_summaries,
        found_count              TYPE i,
        empty_count              TYPE i,
        total_operation_count    TYPE i,
        is_truncated             TYPE abap_bool,
        next_production_order    TYPE aufk-aufnr,
        next_operation_sequence  TYPE afvc-plnfl,
        next_operation_number    TYPE afvc-vornr,
        next_suboperation_number TYPE afvc-uvorn,
        next_operation_counter   TYPE afvc-aplzl,
        snapshot_timestamp       TYPE timestampl,
        is_successful            TYPE abap_bool,
      END OF ty_bulk_operation_read_result.

    METHODS constructor
      IMPORTING
        io_repository    TYPE REF TO zif_prod_order_read_repo
        io_uom_converter TYPE REF TO zif_material_uom_converter OPTIONAL.

    METHODS read_orders_bulk
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)     TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_orders_by_finish_window
      IMPORTING
        is_selection     TYPE zif_prod_order_read_repo=>ty_order_selection
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_confirmations_bulk
      IMPORTING
        it_production_orders           TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        iv_order_category              TYPE aufk-autyp OPTIONAL
        iv_order_type                  TYPE aufk-auart OPTIONAL
        iv_operation_counter           TYPE afvc-aplzl OPTIONAL
        iv_operation_counter_from      TYPE afvc-aplzl OPTIONAL
        iv_operation_counter_to        TYPE afvc-aplzl OPTIONAL
        iv_operation_number            TYPE afvc-vornr OPTIONAL
        iv_operation_number_from       TYPE afvc-vornr OPTIONAL
        iv_operation_number_to         TYPE afvc-vornr OPTIONAL
        iv_filter_control_key          TYPE abap_bool OPTIONAL
        iv_control_key                 TYPE afvc-steus OPTIONAL
        iv_filter_op_description       TYPE abap_bool OPTIONAL
        iv_operation_description       TYPE afvc-ltxa1 OPTIONAL
        iv_filter_resource_object_id   TYPE abap_bool OPTIONAL
        iv_resource_object_id          TYPE afvc-arbid OPTIONAL
        iv_filter_work_center          TYPE abap_bool OPTIONAL
        iv_work_center                 TYPE crhd-arbpl OPTIONAL
        iv_filter_work_center_plant    TYPE abap_bool OPTIONAL
        iv_work_center_plant           TYPE crhd-werks OPTIONAL
        iv_filter_operation_sequence   TYPE abap_bool OPTIONAL
        iv_operation_sequence          TYPE afvc-plnfl OPTIONAL
        iv_operation_sequence_from     TYPE afvc-plnfl OPTIONAL
        iv_operation_sequence_to       TYPE afvc-plnfl OPTIONAL
        iv_filter_suboperation_number  TYPE abap_bool OPTIONAL
        iv_suboperation_number         TYPE afvc-uvorn OPTIONAL
        iv_suboperation_number_from    TYPE afvc-uvorn OPTIONAL
        iv_suboperation_number_to      TYPE afvc-uvorn OPTIONAL
        iv_confirmation_number         TYPE afru-rueck OPTIONAL
        iv_confirmation_counter        TYPE afru-rmzhl OPTIONAL
        iv_posting_date_from           TYPE afru-budat OPTIONAL
        iv_posting_date_to             TYPE afru-budat OPTIONAL
        iv_entry_date_from             TYPE afru-ersda OPTIONAL
        iv_entry_date_to               TYPE afru-ersda OPTIONAL
        iv_execution_start_date_from   TYPE afru-isdd OPTIONAL
        iv_execution_start_date_to     TYPE afru-isdd OPTIONAL
        iv_execution_finish_date_from  TYPE afru-iedd OPTIONAL
        iv_execution_finish_date_to    TYPE afru-iedd OPTIONAL
        iv_filter_execution_start_time TYPE abap_bool OPTIONAL
        iv_execution_start_time_from   TYPE afru-isdz OPTIONAL
        iv_execution_start_time_to     TYPE afru-isdz OPTIONAL
        iv_filter_exec_finish_time     TYPE abap_bool OPTIONAL
        iv_execution_finish_time_from  TYPE afru-iedz OPTIONAL
        iv_execution_finish_time_to    TYPE afru-iedz OPTIONAL
        iv_filter_entry_time           TYPE abap_bool OPTIONAL
        iv_entry_time_from             TYPE afru-erzet OPTIONAL
        iv_entry_time_to               TYPE afru-erzet OPTIONAL
        iv_filter_entered_by           TYPE abap_bool OPTIONAL
        iv_entered_by                  TYPE afru-ernam OPTIONAL
        iv_filter_changed_by           TYPE abap_bool OPTIONAL
        iv_changed_by                  TYPE afru-aenam OPTIONAL
        iv_last_change_date_from       TYPE afru-laeda OPTIONAL
        iv_last_change_date_to         TYPE afru-laeda OPTIONAL
        iv_filter_quantity_unit        TYPE abap_bool OPTIONAL
        iv_quantity_unit               TYPE afru-meinh OPTIONAL
        iv_positive_yield_only         TYPE abap_bool OPTIONAL
        iv_positive_rework_only        TYPE abap_bool OPTIONAL
        iv_positive_scrap_only         TYPE abap_bool OPTIONAL
        iv_filter_yield_quantity_from  TYPE abap_bool OPTIONAL
        iv_yield_quantity_from         TYPE afru-lmnga OPTIONAL
        iv_filter_yield_quantity_to    TYPE abap_bool OPTIONAL
        iv_yield_quantity_to           TYPE afru-lmnga OPTIONAL
        iv_filter_rework_quantity_from TYPE abap_bool OPTIONAL
        iv_rework_quantity_from        TYPE afru-rmnga OPTIONAL
        iv_filter_rework_quantity_to   TYPE abap_bool OPTIONAL
        iv_rework_quantity_to          TYPE afru-rmnga OPTIONAL
        iv_filter_scrap_quantity_from  TYPE abap_bool OPTIONAL
        iv_scrap_quantity_from         TYPE afru-xmnga OPTIONAL
        iv_filter_scrap_quantity_to    TYPE abap_bool OPTIONAL
        iv_scrap_quantity_to           TYPE afru-xmnga OPTIONAL
        iv_exclude_reversed            TYPE abap_bool OPTIONAL
        iv_reversed_only               TYPE abap_bool OPTIONAL
        iv_final_only                  TYPE abap_bool OPTIONAL
        iv_partial_only                TYPE abap_bool OPTIONAL
        iv_maximum_results             TYPE i OPTIONAL
        iv_after_production_order      TYPE afru-aufnr OPTIONAL
        iv_after_posting_date          TYPE afru-budat OPTIONAL
        iv_after_confirmation          TYPE afru-rueck OPTIONAL
        iv_after_confirmation_counter  TYPE afru-rmzhl OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_bulk_confirmation_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS search_confirmations_by_window
      IMPORTING
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
      RETURNING
        VALUE(rs_result) TYPE ty_confirmation_search_result
      RAISING
        zcx_invalid_stock_request.

    METHODS search_conf_window_base_unit
      IMPORTING
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
      RETURNING
        VALUE(rs_result) TYPE ty_conf_base_search_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_operations_bulk
      IMPORTING
        it_production_orders          TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        iv_filter_resource_object_id  TYPE abap_bool OPTIONAL
        iv_resource_object_id         TYPE afvc-arbid OPTIONAL
        iv_filter_work_center         TYPE abap_bool OPTIONAL
        iv_work_center                TYPE crhd-arbpl OPTIONAL
        iv_filter_work_center_plant   TYPE abap_bool OPTIONAL
        iv_work_center_plant          TYPE crhd-werks OPTIONAL
        iv_filter_control_key         TYPE abap_bool OPTIONAL
        iv_control_key                TYPE afvc-steus OPTIONAL
        iv_filter_op_description      TYPE abap_bool OPTIONAL
        iv_operation_description      TYPE afvc-ltxa1 OPTIONAL
        iv_operation_number           TYPE afvc-vornr OPTIONAL
        iv_operation_number_from      TYPE afvc-vornr OPTIONAL
        iv_operation_number_to        TYPE afvc-vornr OPTIONAL
        iv_operation_counter          TYPE afvc-aplzl OPTIONAL
        iv_operation_counter_from     TYPE afvc-aplzl OPTIONAL
        iv_operation_counter_to       TYPE afvc-aplzl OPTIONAL
        iv_filter_operation_sequence  TYPE abap_bool OPTIONAL
        iv_operation_sequence         TYPE afvc-plnfl OPTIONAL
        iv_operation_sequence_from    TYPE afvc-plnfl OPTIONAL
        iv_operation_sequence_to      TYPE afvc-plnfl OPTIONAL
        iv_filter_suboperation_number TYPE abap_bool OPTIONAL
        iv_suboperation_number        TYPE afvc-uvorn OPTIONAL
        iv_suboperation_number_from   TYPE afvc-uvorn OPTIONAL
        iv_suboperation_number_to     TYPE afvc-uvorn OPTIONAL
        iv_order_category             TYPE aufk-autyp OPTIONAL
        iv_order_type                 TYPE aufk-auart OPTIONAL
        iv_maximum_results            TYPE i OPTIONAL
        iv_after_production_order     TYPE aufk-aufnr OPTIONAL
        iv_after_operation_sequence   TYPE afvc-plnfl OPTIONAL
        iv_after_operation_number     TYPE afvc-vornr OPTIONAL
        iv_after_suboperation_number  TYPE afvc-uvorn OPTIONAL
        iv_after_operation_counter    TYPE afvc-aplzl OPTIONAL
      RETURNING
        VALUE(rs_result)              TYPE ty_bulk_operation_read_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    CONSTANTS c_exec_duration_valid   TYPE c LENGTH 1 VALUE 'V'.
    CONSTANTS c_exec_duration_invalid TYPE c LENGTH 1 VALUE 'I'.
    CONSTANTS c_exec_duration_missing TYPE c LENGTH 1 VALUE 'M'.

    TYPES:
      BEGIN OF ty_conf_percentages,
        final_confirmation_pct    TYPE p LENGTH 5 DECIMALS 2,
        partial_confirmation_pct  TYPE p LENGTH 5 DECIMALS 2,
        reversed_confirmation_pct TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_conf_percentages.
    TYPES:
      BEGIN OF ty_conf_execution_percentages,
        execution_start_pct         TYPE p LENGTH 5 DECIMALS 2,
        execution_finish_pct        TYPE p LENGTH 5 DECIMALS 2,
        valid_exec_duration_pct     TYPE p LENGTH 5 DECIMALS 2,
        invalid_exec_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        missing_exec_duration_count TYPE i,
        missing_exec_duration_pct   TYPE p LENGTH 5 DECIMALS 2,
        zero_exec_duration_count    TYPE i,
        zero_exec_duration_pct      TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_conf_execution_percentages.
    TYPES:
      BEGIN OF ty_exec_duration_result,
        status           TYPE c LENGTH 1,
        issue_code       TYPE c LENGTH 2,
        duration_seconds TYPE decfloat34,
      END OF ty_exec_duration_result.
    TYPES:
      BEGIN OF ty_exec_duration_interval,
        start_date       TYPE afru-isdd,
        start_time       TYPE afru-isdz,
        finish_date      TYPE afru-iedd,
        finish_time      TYPE afru-iedz,
        duration_seconds TYPE decfloat34,
      END OF ty_exec_duration_interval.
    TYPES ty_exec_duration_intervals TYPE SORTED TABLE OF
      ty_exec_duration_interval WITH NON-UNIQUE KEY start_date start_time
      finish_date finish_time.
    TYPES ty_exec_duration_values TYPE SORTED TABLE OF decfloat34
      WITH NON-UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_exec_duration_event,
        event_date        TYPE afru-isdd,
        event_time        TYPE afru-isdz,
        concurrency_delta TYPE i,
      END OF ty_exec_duration_event.
    TYPES ty_exec_duration_events TYPE STANDARD TABLE OF
      ty_exec_duration_event WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_exec_interval_metrics,
        covered_seconds               TYPE decfloat34,
        duration_median_seconds       TYPE decfloat34,
        duration_p90_seconds          TYPE decfloat34,
        duration_p95_seconds          TYPE decfloat34,
        duration_p99_seconds          TYPE decfloat34,
        duration_p25_seconds          TYPE decfloat34,
        duration_p75_seconds          TYPE decfloat34,
        duration_iqr_seconds          TYPE decfloat34,
        duration_mad_seconds          TYPE decfloat34,
        nonrev_min_seconds            TYPE decfloat34,
        nonrev_max_seconds            TYPE decfloat34,
        reversed_min_seconds          TYPE decfloat34,
        reversed_max_seconds          TYPE decfloat34,
        nonrev_duration_median_secs   TYPE decfloat34,
        reversed_duration_median_secs TYPE decfloat34,
        nonrev_p90_seconds            TYPE decfloat34,
        reversed_p90_seconds          TYPE decfloat34,
        duration_p90_median_ratio     TYPE decfloat34,
        nonrev_p90_median_ratio       TYPE decfloat34,
        reversed_p90_median_ratio     TYPE decfloat34,
        duration_p90_exceed_count     TYPE i,
        duration_p90_exceed_pct       TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p90_exceed_count       TYPE i,
        nonrev_p90_exceed_pct         TYPE p LENGTH 5 DECIMALS 2,
        reversed_p90_exceed_count     TYPE i,
        reversed_p90_exceed_pct       TYPE p LENGTH 5 DECIMALS 2,
        p90_tail_secs                 TYPE decfloat34,
        p90_tail_pct                  TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p90_tail_secs          TYPE decfloat34,
        nonrev_p90_tail_pct           TYPE p LENGTH 5 DECIMALS 2,
        reversed_p90_tail_secs        TYPE decfloat34,
        reversed_p90_tail_pct         TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p95_seconds            TYPE decfloat34,
        reversed_p95_seconds          TYPE decfloat34,
        duration_p95_median_ratio     TYPE decfloat34,
        nonrev_p95_median_ratio       TYPE decfloat34,
        reversed_p95_median_ratio     TYPE decfloat34,
        duration_p99_median_ratio     TYPE decfloat34,
        nonrev_p99_median_ratio       TYPE decfloat34,
        reversed_p99_median_ratio     TYPE decfloat34,
        duration_p95_exceed_count     TYPE i,
        duration_p95_exceed_pct       TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p95_exceed_count       TYPE i,
        nonrev_p95_exceed_pct         TYPE p LENGTH 5 DECIMALS 2,
        reversed_p95_exceed_count     TYPE i,
        reversed_p95_exceed_pct       TYPE p LENGTH 5 DECIMALS 2,
        p95_tail_secs                 TYPE decfloat34,
        p95_tail_pct                  TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p95_tail_secs          TYPE decfloat34,
        nonrev_p95_tail_pct           TYPE p LENGTH 5 DECIMALS 2,
        reversed_p95_tail_secs        TYPE decfloat34,
        reversed_p95_tail_pct         TYPE p LENGTH 5 DECIMALS 2,
        duration_p99_exceed_count     TYPE i,
        duration_p99_exceed_pct       TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p99_exceed_count       TYPE i,
        nonrev_p99_exceed_pct         TYPE p LENGTH 5 DECIMALS 2,
        reversed_p99_exceed_count     TYPE i,
        reversed_p99_exceed_pct       TYPE p LENGTH 5 DECIMALS 2,
        p99_tail_secs                 TYPE decfloat34,
        p99_tail_pct                  TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p99_tail_secs          TYPE decfloat34,
        nonrev_p99_tail_pct           TYPE p LENGTH 5 DECIMALS 2,
        reversed_p99_tail_secs        TYPE decfloat34,
        reversed_p99_tail_pct         TYPE p LENGTH 5 DECIMALS 2,
        nonrev_p99_seconds            TYPE decfloat34,
        reversed_p99_seconds          TYPE decfloat34,
        nonrev_p25_seconds            TYPE decfloat34,
        nonrev_p75_seconds            TYPE decfloat34,
        reversed_p25_seconds          TYPE decfloat34,
        reversed_p75_seconds          TYPE decfloat34,
        nonrev_iqr_seconds            TYPE decfloat34,
        reversed_iqr_seconds          TYPE decfloat34,
        duration_iqr_median_ratio     TYPE decfloat34,
        nonrev_iqr_median_ratio       TYPE decfloat34,
        reversed_iqr_median_ratio     TYPE decfloat34,
        nonrev_mad_seconds            TYPE decfloat34,
        reversed_mad_seconds          TYPE decfloat34,
        duration_mad_median_ratio     TYPE decfloat34,
        nonrev_mad_median_ratio       TYPE decfloat34,
        reversed_mad_median_ratio     TYPE decfloat34,
        duration_avg_median_ratio     TYPE decfloat34,
        nonrev_avg_median_ratio       TYPE decfloat34,
        reversed_avg_median_ratio     TYPE decfloat34,
        positive_duration_count       TYPE i,
        summary_confirmation_count    TYPE i,
        nonrev_confirmation_count     TYPE i,
        reversed_confirmation_count   TYPE i,
        positive_pct                  TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_pct                TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_pct                   TYPE p LENGTH 5 DECIMALS 2,
        pos_valid_pct                 TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_valid_pct          TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_valid_pct             TYPE p LENGTH 5 DECIMALS 2,
        zero_valid_pct                TYPE p LENGTH 5 DECIMALS 2,
        nonrev_zero_valid_pct         TYPE p LENGTH 5 DECIMALS 2,
        rev_zero_valid_pct            TYPE p LENGTH 5 DECIMALS 2,
        zero_valid_count              TYPE i,
        nonrev_zero_valid_count       TYPE i,
        rev_zero_valid_count          TYPE i,
        nonrev_invalid_count          TYPE i,
        rev_invalid_count             TYPE i,
        nonrev_missing_count          TYPE i,
        rev_missing_count             TYPE i,
        nonrev_valid_pct              TYPE p LENGTH 5 DECIMALS 2,
        rev_valid_pct                 TYPE p LENGTH 5 DECIMALS 2,
        nonrev_invalid_pct            TYPE p LENGTH 5 DECIMALS 2,
        rev_invalid_pct               TYPE p LENGTH 5 DECIMALS 2,
        nonrev_missing_pct            TYPE p LENGTH 5 DECIMALS 2,
        rev_missing_pct               TYPE p LENGTH 5 DECIMALS 2,
        top_issue_code                TYPE c LENGTH 2,
        top_issue_status              TYPE c LENGTH 1,
        top_issue_count               TYPE i,
        top_issue_pct                 TYPE decfloat34,
        top_invalid_issue_code        TYPE c LENGTH 2,
        top_invalid_issue_count       TYPE i,
        top_invalid_share_pct         TYPE decfloat34,
        top_missing_issue_code        TYPE c LENGTH 2,
        top_missing_issue_count       TYPE i,
        top_missing_share_pct         TYPE decfloat34,
        top_nonrev_issue_code         TYPE c LENGTH 2,
        top_nonrev_issue_status       TYPE c LENGTH 1,
        top_nonrev_issue_count        TYPE i,
        top_nonrev_issue_pct          TYPE decfloat34,
        top_reversed_issue_code       TYPE c LENGTH 2,
        top_reversed_issue_status     TYPE c LENGTH 1,
        top_reversed_issue_count      TYPE i,
        top_reversed_issue_pct        TYPE decfloat34,
        issue_counts                  TYPE ty_exec_duration_issue_counts,
        positive_median_secs          TYPE decfloat34,
        positive_p90_secs             TYPE decfloat34,
        nonrev_positive_count         TYPE i,
        nonrev_positive_median_secs   TYPE decfloat34,
        nonrev_positive_p90_secs      TYPE decfloat34,
        reversed_positive_count       TYPE i,
        reversed_positive_median_secs TYPE decfloat34,
        reversed_positive_p90_secs    TYPE decfloat34,
        pos_p90_med_ratio             TYPE decfloat34,
        nonrev_pos_p90_med_ratio      TYPE decfloat34,
        reversed_pos_p90_med_ratio    TYPE decfloat34,
        pos_p90_gt_count              TYPE i,
        pos_p90_gt_pct                TYPE p LENGTH 5 DECIMALS 2,
        pos_p90_tail_secs             TYPE decfloat34,
        pos_p90_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_p90_gt_count       TYPE i,
        nonrev_pos_p90_gt_pct         TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_p90_tail_secs      TYPE decfloat34,
        nonrev_pos_p90_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_p90_gt_count          TYPE i,
        rev_pos_p90_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_p90_tail_secs         TYPE decfloat34,
        rev_pos_p90_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        positive_p95_secs             TYPE decfloat34,
        positive_p99_secs             TYPE decfloat34,
        nonrev_positive_p95_secs      TYPE decfloat34,
        nonrev_positive_p99_secs      TYPE decfloat34,
        reversed_positive_p95_secs    TYPE decfloat34,
        reversed_positive_p99_secs    TYPE decfloat34,
        positive_p25_secs             TYPE decfloat34,
        positive_p75_secs             TYPE decfloat34,
        nonrev_positive_p25_secs      TYPE decfloat34,
        nonrev_positive_p75_secs      TYPE decfloat34,
        reversed_positive_p25_secs    TYPE decfloat34,
        reversed_positive_p75_secs    TYPE decfloat34,
        positive_iqr_secs             TYPE decfloat34,
        nonrev_positive_iqr_secs      TYPE decfloat34,
        reversed_positive_iqr_secs    TYPE decfloat34,
        positive_mad_secs             TYPE decfloat34,
        nonrev_positive_mad_secs      TYPE decfloat34,
        reversed_positive_mad_secs    TYPE decfloat34,
        positive_iqr_med_ratio        TYPE decfloat34,
        nonrev_positive_iqr_med_ratio TYPE decfloat34,
        reversed_pos_iqr_med_ratio    TYPE decfloat34,
        positive_mad_med_ratio        TYPE decfloat34,
        nonrev_positive_mad_med_ratio TYPE decfloat34,
        reversed_pos_mad_med_ratio    TYPE decfloat34,
        pos_avg_secs                  TYPE decfloat34,
        nonrev_pos_avg_secs           TYPE decfloat34,
        rev_pos_avg_secs              TYPE decfloat34,
        pos_avg_med_ratio             TYPE decfloat34,
        nonrev_pos_avg_med_ratio      TYPE decfloat34,
        rev_pos_avg_med_ratio         TYPE decfloat34,
        positive_min_secs             TYPE decfloat34,
        positive_max_secs             TYPE decfloat34,
        positive_range_secs           TYPE decfloat34,
        nonrev_positive_min_secs      TYPE decfloat34,
        nonrev_positive_max_secs      TYPE decfloat34,
        nonrev_positive_range_secs    TYPE decfloat34,
        reversed_positive_min_secs    TYPE decfloat34,
        reversed_positive_max_secs    TYPE decfloat34,
        reversed_positive_range_secs  TYPE decfloat34,
        pos_p95_gt_count              TYPE i,
        pos_p95_gt_pct                TYPE p LENGTH 5 DECIMALS 2,
        pos_p95_tail_secs             TYPE decfloat34,
        pos_p95_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_p95_gt_count       TYPE i,
        nonrev_pos_p95_gt_pct         TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_p95_tail_secs      TYPE decfloat34,
        nonrev_pos_p95_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_p95_gt_count          TYPE i,
        rev_pos_p95_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_p95_tail_secs         TYPE decfloat34,
        rev_pos_p95_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        pos_p99_gt_count              TYPE i,
        pos_p99_gt_pct                TYPE p LENGTH 5 DECIMALS 2,
        pos_p99_tail_secs             TYPE decfloat34,
        pos_p99_tail_pct              TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_p99_gt_count       TYPE i,
        nonrev_pos_p99_gt_pct         TYPE p LENGTH 5 DECIMALS 2,
        nonrev_pos_p99_tail_secs      TYPE decfloat34,
        nonrev_pos_p99_tail_pct       TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_p99_gt_count          TYPE i,
        rev_pos_p99_gt_pct            TYPE p LENGTH 5 DECIMALS 2,
        rev_pos_p99_tail_secs         TYPE decfloat34,
        rev_pos_p99_tail_pct          TYPE p LENGTH 5 DECIMALS 2,
        pos_p95_med_ratio             TYPE decfloat34,
        nonrev_pos_p95_med_ratio      TYPE decfloat34,
        rev_pos_p95_med_ratio         TYPE decfloat34,
        pos_p99_med_ratio             TYPE decfloat34,
        nonrev_pos_p99_med_ratio      TYPE decfloat34,
        rev_pos_p99_med_ratio         TYPE decfloat34,
        nonrev_covered_seconds        TYPE decfloat34,
        nonrev_duration_count         TYPE i,
        nonrev_duration_total         TYPE decfloat34,
        nonrev_duration_avg_secs      TYPE decfloat34,
        nonrev_excess_secs            TYPE decfloat34,
        reversed_duration_count       TYPE i,
        reversed_duration_total       TYPE decfloat34,
        reversed_avg_secs             TYPE decfloat34,
        reversed_covered_seconds      TYPE decfloat34,
        reversed_excess_secs          TYPE decfloat34,
        nonrev_duration_pct           TYPE p LENGTH 5 DECIMALS 2,
        reversed_duration_pct         TYPE p LENGTH 5 DECIMALS 2,
        single_active_seconds         TYPE decfloat34,
        single_episode_count          TYPE i,
        longest_single_secs           TYPE decfloat34,
        single_active_avg_secs        TYPE decfloat34,
        high_concurrency_seconds      TYPE decfloat34,
        exactly_two_seconds           TYPE decfloat34,
        exactly_two_pct               TYPE p LENGTH 5 DECIMALS 2,
        three_plus_episode_count      TYPE i,
        longest_three_plus_secs       TYPE decfloat34,
        three_plus_avg_secs           TYPE decfloat34,
        three_plus_pct                TYPE p LENGTH 5 DECIMALS 2,
        overlap_excess_seconds        TYPE decfloat34,
        peak_concurrency              TYPE i,
        peak_seconds                  TYPE decfloat34,
        peak_concurrency_pct          TYPE p LENGTH 5 DECIMALS 2,
        peak_episode_count            TYPE i,
        longest_peak_secs             TYPE decfloat34,
        peak_episode_avg_secs         TYPE decfloat34,
        avg_concurrency               TYPE decfloat34,
        idle_gap_seconds              TYPE decfloat34,
        longest_idle_gap_secs         TYPE decfloat34,
        idle_gap_episode_count        TYPE i,
        idle_gap_avg_secs             TYPE decfloat34,
        interval_coverage_pct         TYPE p LENGTH 5 DECIMALS 2,
        single_active_pct             TYPE p LENGTH 5 DECIMALS 2,
        overlap_wall_pct              TYPE p LENGTH 5 DECIMALS 2,
        overlap_wall_seconds          TYPE decfloat34,
        pairwise_overlap_seconds      TYPE decfloat34,
        overlap_episode_count         TYPE i,
        overlap_pair_count            TYPE i,
        overlap_pair_avg_secs         TYPE decfloat34,
        longest_pair_overlap_secs     TYPE decfloat34,
        longest_overlap_secs          TYPE decfloat34,
        overlap_avg_secs              TYPE decfloat34,
      END OF ty_exec_interval_metrics.

    METHODS calculate_conf_percentages
      IMPORTING
        iv_confirmation_count TYPE i
        iv_final_count        TYPE i
        iv_partial_count      TYPE i
        iv_reversed_count     TYPE i
      RETURNING
        VALUE(rs_percentages) TYPE ty_conf_percentages.

    METHODS calc_exec_coverage_pct
      IMPORTING
        iv_confirmation_count     TYPE i
        iv_execution_start_count  TYPE i
        iv_execution_finish_count TYPE i
        iv_duration_count         TYPE i
        iv_invalid_duration_count TYPE i
        iv_zero_duration_count    TYPE i
      RETURNING
        VALUE(rs_exec_pct)        TYPE ty_conf_execution_percentages.

    METHODS calc_exec_duration_avg
      IMPORTING
        iv_duration_count         TYPE i
        iv_duration_seconds_total TYPE decfloat34
      RETURNING
        VALUE(rv_average_seconds) TYPE decfloat34.

    METHODS update_conf_execution_metrics
      IMPORTING
        is_confirmation               TYPE zif_prod_order_read_repo=>ty_order_confirmation
      CHANGING
        cv_execution_start_count      TYPE i
        cv_first_execution_start_date TYPE afru-isdd
        cv_first_execution_start_time TYPE afru-isdz
        cv_execution_finish_count     TYPE i
        cv_last_execution_finish_date TYPE afru-iedd
        cv_last_execution_finish_time TYPE afru-iedz
        cv_duration_count             TYPE i
        cv_invalid_duration_count     TYPE i
        cv_zero_duration_count        TYPE i
        cv_duration_seconds           TYPE decfloat34
        cv_duration_seconds_min       TYPE decfloat34
        cv_duration_seconds_max       TYPE decfloat34.

    METHODS calc_exec_duration
      IMPORTING
        is_confirmation    TYPE zif_prod_order_read_repo=>ty_order_confirmation
      RETURNING
        VALUE(rs_duration) TYPE ty_exec_duration_result.

    METHODS calc_exec_duration_median
      IMPORTING
        it_duration_values       TYPE ty_exec_duration_values
      RETURNING
        VALUE(rv_median_seconds) TYPE decfloat34.

    METHODS calc_exec_duration_percentile
      IMPORTING
        it_duration_values           TYPE ty_exec_duration_values
        iv_percentile                TYPE i
      RETURNING
        VALUE(rv_percentile_seconds) TYPE decfloat34.

    METHODS calc_exec_duration_mad
      IMPORTING
        it_duration_values    TYPE ty_exec_duration_values
      RETURNING
        VALUE(rv_mad_seconds) TYPE decfloat34.

    METHODS calc_exec_interval_metrics
      IMPORTING
        it_confirmations          TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
        iv_work_center            TYPE crhd-arbpl OPTIONAL
        iv_work_center_plant      TYPE crhd-werks OPTIONAL
        iv_production_order       TYPE
          zif_prod_order_read_repo=>ty_order_number OPTIONAL
        iv_operation_counter      TYPE afvc-aplzl OPTIONAL
        iv_operation_number       TYPE afvc-vornr OPTIONAL
        iv_operation_sequence     TYPE afvc-plnfl OPTIONAL
        iv_operation_suboperation TYPE afvc-uvorn OPTIONAL
        iv_quantity_unit          TYPE afru-meinh OPTIONAL
      RETURNING
        VALUE(rs_interval_result) TYPE ty_exec_interval_metrics.

    METHODS calc_exec_interval_union
      IMPORTING
        it_intervals              TYPE ty_exec_duration_intervals
      RETURNING
        VALUE(rv_covered_seconds) TYPE decfloat34.

    METHODS validate_order_numbers
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
      RAISING
        zcx_invalid_stock_request.

    METHODS calculate_progress_shares
      CHANGING
        cs_counts TYPE ty_receipt_progress_counts.

    METHODS calc_finish_base_qty_shares
      CHANGING
        cs_summary TYPE ty_finish_base_qty_summary.

    METHODS calc_progress_qty_shares
      IMPORTING
        iv_order_qty_total     TYPE decfloat34
        iv_received_qty_total  TYPE decfloat34
        iv_open_qty_total      TYPE decfloat34
        iv_over_rcpt_qty_total TYPE decfloat34
      CHANGING
        cs_group               TYPE ty_finish_base_progress_qty.

    METHODS collect_contrib_progress_qty
      IMPORTING
        iv_progress_status TYPE ty_receipt_progress_status
        is_item            TYPE ty_item_result
      CHANGING
        cs_totals          TYPE ty_progress_qty_totals.

    METHODS collect_progress_qty_totals
      IMPORTING
        is_source TYPE ty_progress_qty_totals
      CHANGING
        cs_target TYPE ty_progress_qty_totals.

    METHODS validate_order_read_results
      IMPORTING
        it_production_orders TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_order_items       TYPE
          zif_prod_order_read_repo=>ty_order_items
        it_order_statuses    TYPE
          zif_prod_order_read_repo=>ty_order_statuses
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_order_selection
      IMPORTING
        is_selection TYPE zif_prod_order_read_repo=>ty_order_selection
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_finish_window_keys
      IMPORTING
        is_selection  TYPE zif_prod_order_read_repo=>ty_order_selection
        it_order_keys TYPE
          zif_prod_order_read_repo=>ty_finish_search_keys
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_confirmation_results
      IMPORTING
        it_production_orders           TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_confirmations               TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
        iv_order_type                  TYPE aufk-auart OPTIONAL
        iv_operation_counter           TYPE afvc-aplzl OPTIONAL
        iv_operation_counter_from      TYPE afvc-aplzl OPTIONAL
        iv_operation_counter_to        TYPE afvc-aplzl OPTIONAL
        iv_operation_number            TYPE afvc-vornr OPTIONAL
        iv_operation_number_from       TYPE afvc-vornr OPTIONAL
        iv_operation_number_to         TYPE afvc-vornr OPTIONAL
        iv_filter_operation_sequence   TYPE abap_bool OPTIONAL
        iv_operation_sequence          TYPE afvc-plnfl OPTIONAL
        iv_operation_sequence_from     TYPE afvc-plnfl OPTIONAL
        iv_operation_sequence_to       TYPE afvc-plnfl OPTIONAL
        iv_filter_suboperation_number  TYPE abap_bool OPTIONAL
        iv_suboperation_number         TYPE afvc-uvorn OPTIONAL
        iv_suboperation_number_from    TYPE afvc-uvorn OPTIONAL
        iv_suboperation_number_to      TYPE afvc-uvorn OPTIONAL
        iv_confirmation_number         TYPE afru-rueck OPTIONAL
        iv_confirmation_counter        TYPE afru-rmzhl OPTIONAL
        iv_exclude_reversed            TYPE abap_bool OPTIONAL
        iv_final_only                  TYPE abap_bool OPTIONAL
        iv_partial_only                TYPE abap_bool OPTIONAL
        iv_posting_date_from           TYPE afru-budat OPTIONAL
        iv_posting_date_to             TYPE afru-budat OPTIONAL
        iv_entry_date_from             TYPE afru-ersda OPTIONAL
        iv_entry_date_to               TYPE afru-ersda OPTIONAL
        iv_execution_start_date_from   TYPE afru-isdd OPTIONAL
        iv_execution_start_date_to     TYPE afru-isdd OPTIONAL
        iv_execution_finish_date_from  TYPE afru-iedd OPTIONAL
        iv_execution_finish_date_to    TYPE afru-iedd OPTIONAL
        iv_filter_execution_start_time TYPE abap_bool OPTIONAL
        iv_execution_start_time_from   TYPE afru-isdz OPTIONAL
        iv_execution_start_time_to     TYPE afru-isdz OPTIONAL
        iv_filter_exec_finish_time     TYPE abap_bool OPTIONAL
        iv_execution_finish_time_from  TYPE afru-iedz OPTIONAL
        iv_execution_finish_time_to    TYPE afru-iedz OPTIONAL
        iv_filter_entry_time           TYPE abap_bool OPTIONAL
        iv_entry_time_from             TYPE afru-erzet OPTIONAL
        iv_entry_time_to               TYPE afru-erzet OPTIONAL
        iv_filter_entered_by           TYPE abap_bool OPTIONAL
        iv_entered_by                  TYPE afru-ernam OPTIONAL
        iv_filter_changed_by           TYPE abap_bool OPTIONAL
        iv_changed_by                  TYPE afru-aenam OPTIONAL
        iv_last_change_date_from       TYPE afru-laeda OPTIONAL
        iv_last_change_date_to         TYPE afru-laeda OPTIONAL
        iv_filter_quantity_unit        TYPE abap_bool OPTIONAL
        iv_quantity_unit               TYPE afru-meinh OPTIONAL
        iv_positive_yield_only         TYPE abap_bool OPTIONAL
        iv_positive_rework_only        TYPE abap_bool OPTIONAL
        iv_positive_scrap_only         TYPE abap_bool OPTIONAL
        iv_filter_yield_quantity_from  TYPE abap_bool OPTIONAL
        iv_yield_quantity_from         TYPE afru-lmnga OPTIONAL
        iv_filter_yield_quantity_to    TYPE abap_bool OPTIONAL
        iv_yield_quantity_to           TYPE afru-lmnga OPTIONAL
        iv_filter_rework_quantity_from TYPE abap_bool OPTIONAL
        iv_rework_quantity_from        TYPE afru-rmnga OPTIONAL
        iv_filter_rework_quantity_to   TYPE abap_bool OPTIONAL
        iv_rework_quantity_to          TYPE afru-rmnga OPTIONAL
        iv_filter_scrap_quantity_from  TYPE abap_bool OPTIONAL
        iv_scrap_quantity_from         TYPE afru-xmnga OPTIONAL
        iv_filter_scrap_quantity_to    TYPE abap_bool OPTIONAL
        iv_scrap_quantity_to           TYPE afru-xmnga OPTIONAL
        iv_order_category              TYPE aufk-autyp OPTIONAL
        iv_reversed_only               TYPE abap_bool OPTIONAL
        iv_filter_control_key          TYPE abap_bool OPTIONAL
        iv_control_key                 TYPE afvc-steus OPTIONAL
        iv_filter_op_description       TYPE abap_bool OPTIONAL
        iv_operation_description       TYPE afvc-ltxa1 OPTIONAL
        iv_filter_resource_object_id   TYPE abap_bool OPTIONAL
        iv_resource_object_id          TYPE afvc-arbid OPTIONAL
        iv_filter_work_center          TYPE abap_bool OPTIONAL
        iv_work_center                 TYPE crhd-arbpl OPTIONAL
        iv_filter_work_center_plant    TYPE abap_bool OPTIONAL
        iv_work_center_plant           TYPE crhd-werks OPTIONAL
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_conf_selection
      IMPORTING
        is_selection TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_conf_window_results
      IMPORTING
        is_selection     TYPE
          zif_prod_order_read_repo=>ty_confirmation_window_selection
        it_confirmations TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RAISING
        zcx_invalid_stock_request.

    METHODS build_conf_summaries
      IMPORTING
        it_confirmations    TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RETURNING
        VALUE(rt_summaries) TYPE ty_confirmation_operation_summaries.

    METHODS build_wc_conf_summaries
      IMPORTING
        it_confirmations    TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RETURNING
        VALUE(rt_summaries) TYPE ty_work_center_confirmation_summaries.

    METHODS build_base_wc_conf_summaries
      IMPORTING
        it_base_quantities  TYPE ty_base_conf_quantities
      RETURNING
        VALUE(rt_summaries) TYPE ty_base_work_center_conf_summaries.

    METHODS build_conf_order_summaries
      IMPORTING
        it_operation_summaries TYPE ty_confirmation_operation_summaries
        it_confirmations       TYPE
          zif_prod_order_read_repo=>ty_order_confirmations
      RETURNING
        VALUE(rt_summaries)    TYPE ty_conf_order_summaries.

    METHODS build_base_order_summaries
      IMPORTING
        it_operation_summaries TYPE ty_base_conf_summaries
        it_base_quantities     TYPE ty_base_conf_quantities
      RETURNING
        VALUE(rt_summaries)    TYPE ty_base_conf_order_summaries.

    METHODS convert_conf_qty_to_base
      IMPORTING
        iv_quantity        TYPE decfloat34
        iv_numerator       TYPE marm-umrez
        iv_denominator     TYPE marm-umren
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_operation_results
      IMPORTING
        it_production_orders          TYPE
          zif_prod_order_read_repo=>ty_order_numbers
        it_operations                 TYPE
          zif_prod_order_read_repo=>ty_order_operations
        iv_filter_resource_object_id  TYPE abap_bool
        iv_resource_object_id         TYPE afvc-arbid
        iv_filter_work_center         TYPE abap_bool
        iv_work_center                TYPE crhd-arbpl
        iv_filter_work_center_plant   TYPE abap_bool
        iv_work_center_plant          TYPE crhd-werks
        iv_filter_control_key         TYPE abap_bool
        iv_control_key                TYPE afvc-steus
        iv_filter_op_description      TYPE abap_bool
        iv_operation_description      TYPE afvc-ltxa1
        iv_operation_number           TYPE afvc-vornr
        iv_operation_number_from      TYPE afvc-vornr
        iv_operation_number_to        TYPE afvc-vornr
        iv_operation_counter          TYPE afvc-aplzl
        iv_operation_counter_from     TYPE afvc-aplzl
        iv_operation_counter_to       TYPE afvc-aplzl
        iv_filter_operation_sequence  TYPE abap_bool
        iv_operation_sequence         TYPE afvc-plnfl
        iv_operation_sequence_from    TYPE afvc-plnfl
        iv_operation_sequence_to      TYPE afvc-plnfl
        iv_filter_suboperation_number TYPE abap_bool
        iv_suboperation_number        TYPE afvc-uvorn
        iv_suboperation_number_from   TYPE afvc-uvorn
        iv_suboperation_number_to     TYPE afvc-uvorn
        iv_order_category             TYPE aufk-autyp
        iv_order_type                 TYPE aufk-auart
      RAISING
        zcx_invalid_stock_request.

    DATA mo_repository TYPE REF TO zif_prod_order_read_repo.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
ENDCLASS.

CLASS zcl_prod_order_read_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    IF io_uom_converter IS BOUND.
      mo_uom_converter = io_uom_converter.
    ELSE.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_order_read_results.
    TYPES:
      BEGIN OF ty_order_item_key,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        production_item  TYPE
          zif_prod_order_read_repo=>ty_order_item-production_item,
      END OF ty_order_item_key,
      ty_order_item_keys TYPE HASHED TABLE OF ty_order_item_key
        WITH UNIQUE KEY production_order production_item,
      BEGIN OF ty_order_status_key,
        production_order TYPE
          zif_prod_order_read_repo=>ty_order_number,
        status_code      TYPE
          zif_prod_order_read_repo=>ty_order_status-status_code,
      END OF ty_order_status_key,
      ty_order_status_keys TYPE HASHED TABLE OF ty_order_status_key
        WITH UNIQUE KEY production_order status_code.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_order_item_keys TYPE ty_order_item_keys.
    DATA lt_order_status_keys TYPE ty_order_status_keys.

    LOOP AT it_production_orders INTO DATA(lv_requested_order).
      INSERT lv_requested_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_order_items INTO DATA(ls_order_item).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_order_item-production_order
        TRANSPORTING NO FIELDS.
      IF ls_order_item-production_order IS INITIAL
          OR ls_order_item-production_item IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        production_order = ls_order_item-production_order
        production_item  = ls_order_item-production_item )
        INTO TABLE lt_order_item_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_order_statuses INTO DATA(ls_order_status).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_order_status-production_order
        TRANSPORTING NO FIELDS.
      IF ls_order_status-production_order IS INITIAL
          OR ls_order_status-status_code IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        production_order = ls_order_status-production_order
        status_code      = ls_order_status-status_code )
        INTO TABLE lt_order_status_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_order_numbers.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_seen_orders.
      IF lv_production_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_finish_window_keys.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.
    DATA lv_has_previous_key TYPE abap_bool.
    DATA ls_previous_key TYPE zif_prod_order_read_repo=>ty_finish_search_key.

    IF lines( it_order_keys ) > is_selection-maximum_results + 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_order_keys INTO DATA(ls_order_key).
      IF ls_order_key-production_order IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_order_key-basic_finish_date ) <> abap_true
          OR ls_order_key-basic_finish_date <
            is_selection-finish_date_from
          OR ls_order_key-basic_finish_date >
            is_selection-finish_date_to
          OR ( ( is_selection-filter_basic_start_date = abap_true
                OR is_selection-basic_start_date IS NOT INITIAL )
            AND ls_order_key-basic_start_date <>
              is_selection-basic_start_date )
          OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_key-scheduled_start_date ) <> abap_true
              OR ls_order_key-scheduled_start_date <
                is_selection-scheduled_start_date_from
              OR ls_order_key-scheduled_start_date >
                is_selection-scheduled_start_date_to ) )
          OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_key-scheduled_finish_date ) <> abap_true
              OR ls_order_key-scheduled_finish_date <
                is_selection-scheduled_finish_date_from
              OR ls_order_key-scheduled_finish_date >
                is_selection-scheduled_finish_date_to ) )
          OR ( ( is_selection-filter_scheduled_start_date = abap_true
                OR is_selection-scheduled_start_date IS NOT INITIAL )
            AND ls_order_key-scheduled_start_date <>
              is_selection-scheduled_start_date )
          OR ( ( is_selection-filter_scheduled_finish_date = abap_true
                OR is_selection-scheduled_finish_date IS NOT INITIAL )
            AND ls_order_key-scheduled_finish_date <>
              is_selection-scheduled_finish_date )
          OR ( is_selection-filter_scheduled_start_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
              iv_time = ls_order_key-scheduled_start_time ) <> abap_true
              OR ls_order_key-scheduled_start_time <
                is_selection-scheduled_start_time_from
              OR ls_order_key-scheduled_start_time >
                is_selection-scheduled_start_time_to ) )
          OR ( is_selection-filter_scheduled_finish_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
              iv_time = ls_order_key-scheduled_finish_time ) <> abap_true
              OR ls_order_key-scheduled_finish_time <
                is_selection-scheduled_finish_time_from
              OR ls_order_key-scheduled_finish_time >
                is_selection-scheduled_finish_time_to ) )
          OR ( is_selection-basic_start_date_from IS NOT INITIAL
            AND ( zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_order_key-basic_start_date ) <> abap_true
              OR ls_order_key-basic_start_date <
                is_selection-basic_start_date_from
              OR ls_order_key-basic_start_date >
                is_selection-basic_start_date_to ) )
          OR ( is_selection-after_finish_date IS NOT INITIAL
            AND ( ls_order_key-basic_finish_date <
              is_selection-after_finish_date
              OR ( ls_order_key-basic_finish_date =
                is_selection-after_finish_date
                AND ls_order_key-production_order <=
                  is_selection-after_order ) ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT ls_order_key-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF lv_has_previous_key = abap_true
          AND ( ls_order_key-basic_finish_date <
            ls_previous_key-basic_finish_date
            OR ( ls_order_key-basic_finish_date =
              ls_previous_key-basic_finish_date
              AND ls_order_key-production_order <=
                ls_previous_key-production_order ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ls_previous_key = ls_order_key.
      lv_has_previous_key = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_order_selection.
    LOOP AT is_selection-active_status_codes
        INTO DATA(lv_selected_status_code).
      IF lv_selected_status_code IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF is_selection-material IS INITIAL
        OR is_selection-plant IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-finish_date_from ) <> abap_true
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-finish_date_to ) <> abap_true
        OR is_selection-finish_date_from > is_selection-finish_date_to
        OR is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500
        OR ( is_selection-filter_sales_order <> abap_true
          AND is_selection-filter_sales_order <> abap_false )
        OR ( is_selection-filter_sales_order_item <> abap_true
          AND is_selection-filter_sales_order_item <> abap_false )
        OR ( is_selection-filter_sales_schedule_line <> abap_true
          AND is_selection-filter_sales_schedule_line <> abap_false )
        OR ( is_selection-filter_planned_order <> abap_true
          AND is_selection-filter_planned_order <> abap_false )
        OR ( is_selection-filter_planning_plant <> abap_true
          AND is_selection-filter_planning_plant <> abap_false )
        OR ( is_selection-filter_delivery_plant <> abap_true
          AND is_selection-filter_delivery_plant <> abap_false )
        OR ( is_selection-filter_special_stock <> abap_true
          AND is_selection-filter_special_stock <> abap_false )
        OR ( is_selection-filter_stock_type <> abap_true
          AND is_selection-filter_stock_type <> abap_false )
        OR ( is_selection-filter_goods_recipient <> abap_true
          AND is_selection-filter_goods_recipient <> abap_false )
        OR ( is_selection-filter_unloading_point <> abap_true
          AND is_selection-filter_unloading_point <> abap_false )
        OR ( is_selection-filter_production_version <> abap_true
          AND is_selection-filter_production_version <> abap_false )
        OR ( is_selection-filter_plan_start_date <> abap_true
          AND is_selection-filter_plan_start_date <> abap_false )
        OR ( is_selection-filter_storage_location <> abap_true
          AND is_selection-filter_storage_location <> abap_false )
        OR ( is_selection-filter_batch <> abap_true
          AND is_selection-filter_batch <> abap_false )
        OR ( is_selection-filter_assignment_category <> abap_true
          AND is_selection-filter_assignment_category <> abap_false )
        OR ( is_selection-filter_mrp_area <> abap_true
          AND is_selection-filter_mrp_area <> abap_false )
        OR ( is_selection-filter_wbs_element <> abap_true
          AND is_selection-filter_wbs_element <> abap_false )
        OR ( is_selection-filter_order_description <> abap_true
          AND is_selection-filter_order_description <> abap_false )
        OR ( is_selection-filter_order_created_by <> abap_true
          AND is_selection-filter_order_created_by <> abap_false )
        OR ( is_selection-filter_order_changed_by <> abap_true
          AND is_selection-filter_order_changed_by <> abap_false )
        OR ( is_selection-basic_start_date_from IS INITIAL
          AND is_selection-basic_start_date_to IS NOT INITIAL )
        OR ( is_selection-basic_start_date_from IS NOT INITIAL
          AND is_selection-basic_start_date_to IS INITIAL )
        OR ( is_selection-basic_start_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-basic_start_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-basic_start_date_to ) <> abap_true
            OR is_selection-basic_start_date_from >
              is_selection-basic_start_date_to ) )
        OR ( is_selection-active_status_code IS NOT INITIAL
          AND is_selection-active_status_codes IS NOT INITIAL )
        OR ( is_selection-filter_basic_start_date <> abap_true
          AND is_selection-filter_basic_start_date <> abap_false )
        OR ( is_selection-basic_start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-basic_start_date ) <> abap_true )
        OR ( is_selection-planned_order_start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-planned_order_start_date ) <> abap_true )
        OR ( is_selection-scheduled_finish_date_from IS INITIAL
          AND is_selection-scheduled_finish_date_to IS NOT INITIAL )
        OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
          AND is_selection-scheduled_finish_date_to IS INITIAL )
        OR ( is_selection-scheduled_finish_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_finish_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-scheduled_finish_date_to ) <> abap_true
            OR is_selection-scheduled_finish_date_from >
              is_selection-scheduled_finish_date_to ) )
        OR ( is_selection-scheduled_start_date_from IS INITIAL
          AND is_selection-scheduled_start_date_to IS NOT INITIAL )
        OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
          AND is_selection-scheduled_start_date_to IS INITIAL )
        OR ( is_selection-scheduled_start_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_start_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-scheduled_start_date_to ) <> abap_true
            OR is_selection-scheduled_start_date_from >
              is_selection-scheduled_start_date_to ) )
        OR ( is_selection-filter_scheduled_start_date <> abap_true
          AND is_selection-filter_scheduled_start_date <> abap_false )
        OR ( is_selection-scheduled_start_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_start_date ) <> abap_true )
        OR ( is_selection-filter_scheduled_finish_date <> abap_true
          AND is_selection-filter_scheduled_finish_date <> abap_false )
        OR ( is_selection-scheduled_finish_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-scheduled_finish_date ) <> abap_true )
        OR ( is_selection-filter_scheduled_start_time <> abap_true
          AND is_selection-filter_scheduled_start_time <> abap_false )
        OR ( is_selection-filter_scheduled_start_time = abap_false
          AND ( is_selection-scheduled_start_time_from IS NOT INITIAL
            OR is_selection-scheduled_start_time_to IS NOT INITIAL ) )
        OR ( is_selection-filter_scheduled_start_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_start_time_from ) <>
                abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_start_time_to ) <>
                abap_true
            OR is_selection-scheduled_start_time_from >
              is_selection-scheduled_start_time_to ) )
        OR ( is_selection-filter_scheduled_finish_time <> abap_true
          AND is_selection-filter_scheduled_finish_time <> abap_false )
        OR ( is_selection-filter_scheduled_finish_time = abap_false
          AND ( is_selection-scheduled_finish_time_from IS NOT INITIAL
            OR is_selection-scheduled_finish_time_to IS NOT INITIAL ) )
        OR ( is_selection-filter_scheduled_finish_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_finish_time_from ) <>
                abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-scheduled_finish_time_to ) <>
                abap_true
            OR is_selection-scheduled_finish_time_from >
              is_selection-scheduled_finish_time_to ) )
        OR ( is_selection-order_category IS NOT INITIAL
          AND is_selection-order_category <> '10'
          AND is_selection-order_category <> '40' )
        OR ( is_selection-created_date_from IS INITIAL
          AND is_selection-created_date_to IS NOT INITIAL )
        OR ( is_selection-created_date_from IS NOT INITIAL
          AND is_selection-created_date_to IS INITIAL )
        OR ( is_selection-created_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-created_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-created_date_to ) <> abap_true
            OR is_selection-created_date_from >
              is_selection-created_date_to ) )
        OR ( is_selection-changed_date_from IS INITIAL
          AND is_selection-changed_date_to IS NOT INITIAL )
        OR ( is_selection-changed_date_from IS NOT INITIAL
          AND is_selection-changed_date_to IS INITIAL )
        OR ( is_selection-changed_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-changed_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-changed_date_to ) <> abap_true
            OR is_selection-changed_date_from >
              is_selection-changed_date_to ) )
        OR ( is_selection-required_phase IS NOT INITIAL
          AND is_selection-required_phase <> '1'
          AND is_selection-required_phase <> '2'
          AND is_selection-required_phase <> '3' )
        OR ( is_selection-exclude_deleted <> abap_true
          AND is_selection-exclude_deleted <> abap_false )
        OR ( is_selection-receipt_expected_only <> abap_true
          AND is_selection-receipt_expected_only <> abap_false )
        OR ( is_selection-receipt_not_expected_only <> abap_true
          AND is_selection-receipt_not_expected_only <> abap_false )
        OR ( is_selection-delivery_complete_only <> abap_true
          AND is_selection-delivery_complete_only <> abap_false )
        OR ( is_selection-delivery_not_complete_only <> abap_true
          AND is_selection-delivery_not_complete_only <> abap_false )
        OR ( is_selection-receipt_expected_only = abap_true
          AND is_selection-receipt_not_expected_only = abap_true )
        OR ( is_selection-delivery_complete_only = abap_true
          AND is_selection-delivery_not_complete_only = abap_true )
        OR ( is_selection-unreceived_quantity_only <> abap_true
          AND is_selection-unreceived_quantity_only <> abap_false )
        OR ( is_selection-filter_receipt_progress_status <> abap_true
          AND is_selection-filter_receipt_progress_status <> abap_false )
        OR ( is_selection-filter_receipt_progress_status = abap_false
          AND is_selection-receipt_progress_status IS NOT INITIAL )
        OR ( is_selection-filter_receipt_progress_status = abap_true
          AND is_selection-receipt_progress_status IS NOT INITIAL
          AND is_selection-receipt_progress_status <>
            c_receipt_progress_not_started
          AND is_selection-receipt_progress_status <>
            c_receipt_progress_partial
          AND is_selection-receipt_progress_status <>
            c_receipt_progress_complete
          AND is_selection-receipt_progress_status <>
            c_receipt_over_received )
        OR ( is_selection-filter_order_qty_from <> abap_true
          AND is_selection-filter_order_qty_from <> abap_false )
        OR ( is_selection-filter_order_qty_from = abap_false
          AND is_selection-order_qty_from IS NOT INITIAL )
        OR ( is_selection-filter_order_qty_from = abap_true
          AND is_selection-order_qty_from <= 0 )
        OR ( is_selection-filter_order_qty_to <> abap_true
          AND is_selection-filter_order_qty_to <> abap_false )
        OR ( is_selection-filter_order_qty_to = abap_false
          AND is_selection-order_qty_to IS NOT INITIAL )
        OR ( is_selection-filter_order_qty_to = abap_true
          AND is_selection-order_qty_to <= 0 )
        OR ( is_selection-filter_order_qty_from = abap_true
          AND is_selection-filter_order_qty_to = abap_true
          AND is_selection-order_qty_from >
            is_selection-order_qty_to )
        OR ( is_selection-filter_order_qty_base_from <> abap_true
          AND is_selection-filter_order_qty_base_from <> abap_false )
        OR ( is_selection-filter_order_qty_base_from = abap_false
          AND is_selection-order_qty_base_from IS NOT INITIAL )
        OR ( is_selection-filter_order_qty_base_from = abap_true
          AND is_selection-order_qty_base_from < 0 )
        OR ( is_selection-filter_order_qty_base_to <> abap_true
          AND is_selection-filter_order_qty_base_to <> abap_false )
        OR ( is_selection-filter_order_qty_base_to = abap_false
          AND is_selection-order_qty_base_to IS NOT INITIAL )
        OR ( is_selection-filter_order_qty_base_to = abap_true
          AND is_selection-order_qty_base_to < 0 )
        OR ( is_selection-filter_order_qty_base_from = abap_true
          AND is_selection-filter_order_qty_base_to = abap_true
          AND is_selection-order_qty_base_from >
            is_selection-order_qty_base_to )
        OR ( is_selection-filter_received_qty_from <> abap_true
          AND is_selection-filter_received_qty_from <> abap_false )
        OR ( is_selection-filter_received_qty_from = abap_false
          AND is_selection-received_qty_from IS NOT INITIAL )
        OR ( is_selection-filter_received_qty_from = abap_true
          AND is_selection-received_qty_from < 0 )
        OR ( is_selection-filter_received_qty_to <> abap_true
          AND is_selection-filter_received_qty_to <> abap_false )
        OR ( is_selection-filter_received_qty_to = abap_false
          AND is_selection-received_qty_to IS NOT INITIAL )
        OR ( is_selection-filter_received_qty_to = abap_true
          AND is_selection-received_qty_to < 0 )
        OR ( is_selection-filter_received_qty_from = abap_true
          AND is_selection-filter_received_qty_to = abap_true
          AND is_selection-received_qty_from >
            is_selection-received_qty_to )
        OR ( is_selection-filter_over_receipt_qty_from <> abap_true
          AND is_selection-filter_over_receipt_qty_from <> abap_false )
        OR ( is_selection-filter_over_receipt_qty_from = abap_false
          AND is_selection-over_receipt_qty_from IS NOT INITIAL )
        OR ( is_selection-filter_over_receipt_qty_from = abap_true
          AND is_selection-over_receipt_qty_from < 0 )
        OR ( is_selection-filter_over_receipt_qty_to <> abap_true
          AND is_selection-filter_over_receipt_qty_to <> abap_false )
        OR ( is_selection-filter_over_receipt_qty_to = abap_false
          AND is_selection-over_receipt_qty_to IS NOT INITIAL )
        OR ( is_selection-filter_over_receipt_qty_to = abap_true
          AND is_selection-over_receipt_qty_to < 0 )
        OR ( is_selection-filter_over_receipt_qty_from = abap_true
          AND is_selection-filter_over_receipt_qty_to = abap_true
          AND is_selection-over_receipt_qty_from >
            is_selection-over_receipt_qty_to )
        OR ( is_selection-filter_over_receipt_pct_from <> abap_true
          AND is_selection-filter_over_receipt_pct_from <> abap_false )
        OR ( is_selection-filter_over_receipt_pct_from = abap_false
          AND is_selection-over_receipt_pct_from IS NOT INITIAL )
        OR ( is_selection-filter_over_receipt_pct_from = abap_true
          AND is_selection-over_receipt_pct_from < 0 )
        OR ( is_selection-filter_over_receipt_pct_to <> abap_true
          AND is_selection-filter_over_receipt_pct_to <> abap_false )
        OR ( is_selection-filter_over_receipt_pct_to = abap_false
          AND is_selection-over_receipt_pct_to IS NOT INITIAL )
        OR ( is_selection-filter_over_receipt_pct_to = abap_true
          AND is_selection-over_receipt_pct_to < 0 )
        OR ( is_selection-filter_over_receipt_pct_from = abap_true
          AND is_selection-filter_over_receipt_pct_to = abap_true
          AND is_selection-over_receipt_pct_from >
            is_selection-over_receipt_pct_to )
        OR ( is_selection-filter_received_qty_base_from <> abap_true
          AND is_selection-filter_received_qty_base_from <> abap_false )
        OR ( is_selection-filter_received_qty_base_from = abap_false
          AND is_selection-received_qty_base_from IS NOT INITIAL )
        OR ( is_selection-filter_received_qty_base_from = abap_true
          AND is_selection-received_qty_base_from < 0 )
        OR ( is_selection-filter_received_qty_base_to <> abap_true
          AND is_selection-filter_received_qty_base_to <> abap_false )
        OR ( is_selection-filter_received_qty_base_to = abap_false
          AND is_selection-received_qty_base_to IS NOT INITIAL )
        OR ( is_selection-filter_received_qty_base_to = abap_true
          AND is_selection-received_qty_base_to < 0 )
        OR ( is_selection-filter_received_qty_base_from = abap_true
          AND is_selection-filter_received_qty_base_to = abap_true
          AND is_selection-received_qty_base_from >
            is_selection-received_qty_base_to )
        OR ( is_selection-filter_over_rcpt_qty_base_from <> abap_true
          AND is_selection-filter_over_rcpt_qty_base_from <> abap_false )
        OR ( is_selection-filter_over_rcpt_qty_base_from = abap_false
          AND is_selection-over_rcpt_qty_base_from IS NOT INITIAL )
        OR ( is_selection-filter_over_rcpt_qty_base_from = abap_true
          AND is_selection-over_rcpt_qty_base_from < 0 )
        OR ( is_selection-filter_over_rcpt_qty_base_to <> abap_true
          AND is_selection-filter_over_rcpt_qty_base_to <> abap_false )
        OR ( is_selection-filter_over_rcpt_qty_base_to = abap_false
          AND is_selection-over_rcpt_qty_base_to IS NOT INITIAL )
        OR ( is_selection-filter_over_rcpt_qty_base_to = abap_true
          AND is_selection-over_rcpt_qty_base_to < 0 )
        OR ( is_selection-filter_over_rcpt_qty_base_from = abap_true
          AND is_selection-filter_over_rcpt_qty_base_to = abap_true
          AND is_selection-over_rcpt_qty_base_from >
            is_selection-over_rcpt_qty_base_to )
        OR ( is_selection-filter_unrecv_qty_base_from <> abap_true
          AND is_selection-filter_unrecv_qty_base_from <> abap_false )
        OR ( is_selection-filter_unrecv_qty_base_from = abap_false
          AND is_selection-unrecv_qty_base_from IS NOT INITIAL )
        OR ( is_selection-filter_unrecv_qty_base_from = abap_true
          AND is_selection-unrecv_qty_base_from <= 0 )
        OR ( is_selection-filter_unrecv_qty_base_to <> abap_true
          AND is_selection-filter_unrecv_qty_base_to <> abap_false )
        OR ( is_selection-filter_unrecv_qty_base_to = abap_false
          AND is_selection-unrecv_qty_base_to IS NOT INITIAL )
        OR ( is_selection-filter_unrecv_qty_base_to = abap_true
          AND is_selection-unrecv_qty_base_to <= 0 )
        OR ( is_selection-filter_unrecv_qty_base_from = abap_true
          AND is_selection-filter_unrecv_qty_base_to = abap_true
          AND is_selection-unrecv_qty_base_from >
            is_selection-unrecv_qty_base_to )
        OR ( is_selection-filter_received_pct_from <> abap_true
          AND is_selection-filter_received_pct_from <> abap_false )
        OR ( is_selection-filter_received_pct_from = abap_false
          AND is_selection-received_pct_from IS NOT INITIAL )
        OR ( is_selection-filter_received_pct_from = abap_true
          AND is_selection-received_pct_from < 0 )
        OR ( is_selection-filter_received_pct_to <> abap_true
          AND is_selection-filter_received_pct_to <> abap_false )
        OR ( is_selection-filter_received_pct_to = abap_false
          AND is_selection-received_pct_to IS NOT INITIAL )
        OR ( is_selection-filter_received_pct_to = abap_true
          AND is_selection-received_pct_to < 0 )
        OR ( is_selection-filter_received_pct_from = abap_true
          AND is_selection-filter_received_pct_to = abap_true
          AND is_selection-received_pct_from >
            is_selection-received_pct_to )
        OR ( is_selection-filter_unreceived_pct_from <> abap_true
          AND is_selection-filter_unreceived_pct_from <> abap_false )
        OR ( is_selection-filter_unreceived_pct_from = abap_false
          AND is_selection-unreceived_pct_from IS NOT INITIAL )
        OR ( is_selection-filter_unreceived_pct_from = abap_true
          AND ( is_selection-unreceived_pct_from < 0
            OR is_selection-unreceived_pct_from > 100 ) )
        OR ( is_selection-filter_unreceived_pct_to <> abap_true
          AND is_selection-filter_unreceived_pct_to <> abap_false )
        OR ( is_selection-filter_unreceived_pct_to = abap_false
          AND is_selection-unreceived_pct_to IS NOT INITIAL )
        OR ( is_selection-filter_unreceived_pct_to = abap_true
          AND ( is_selection-unreceived_pct_to < 0
            OR is_selection-unreceived_pct_to > 100 ) )
        OR ( is_selection-filter_unreceived_pct_from = abap_true
          AND is_selection-filter_unreceived_pct_to = abap_true
          AND is_selection-unreceived_pct_from >
            is_selection-unreceived_pct_to )
        OR ( is_selection-filter_unreceived_qty_from <> abap_true
          AND is_selection-filter_unreceived_qty_from <> abap_false )
        OR ( is_selection-filter_unreceived_qty_from = abap_false
          AND is_selection-unreceived_qty_from IS NOT INITIAL )
        OR ( is_selection-filter_unreceived_qty_from = abap_true
          AND is_selection-unreceived_qty_from <= 0 )
        OR ( is_selection-filter_unreceived_qty_to <> abap_true
          AND is_selection-filter_unreceived_qty_to <> abap_false )
        OR ( is_selection-filter_unreceived_qty_to = abap_false
          AND is_selection-unreceived_qty_to IS NOT INITIAL )
        OR ( is_selection-filter_unreceived_qty_to = abap_true
          AND is_selection-unreceived_qty_to <= 0 )
        OR ( is_selection-filter_unreceived_qty_from = abap_true
          AND is_selection-filter_unreceived_qty_to = abap_true
          AND is_selection-unreceived_qty_from >
            is_selection-unreceived_qty_to )
        OR ( is_selection-after_finish_date IS INITIAL
          AND is_selection-after_order IS NOT INITIAL )
        OR ( is_selection-after_finish_date IS NOT INITIAL
          AND is_selection-after_order IS INITIAL )
        OR ( is_selection-after_finish_date IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-after_finish_date ) <> abap_true
            OR is_selection-after_finish_date <
              is_selection-finish_date_from
            OR is_selection-after_finish_date >
              is_selection-finish_date_to ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_confirmation_results.
    TYPES:
      BEGIN OF ty_confirmation_key,
        confirmation         TYPE
          zif_prod_order_read_repo=>ty_order_confirmation-confirmation,
        confirmation_counter TYPE
          zif_prod_order_read_repo=>ty_order_confirmation-confirmation_counter,
      END OF ty_confirmation_key.
    TYPES ty_confirmation_keys TYPE HASHED TABLE OF ty_confirmation_key
      WITH UNIQUE KEY confirmation confirmation_counter.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lt_confirmation_keys TYPE ty_confirmation_keys.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_confirmation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_confirmation-confirmation IS INITIAL
          OR ls_confirmation-confirmation_counter IS INITIAL
          OR ls_confirmation-production_order IS INITIAL
          OR ( iv_order_type IS NOT INITIAL
            AND ls_confirmation-order_type <> iv_order_type )
          OR ( iv_order_category IS SUPPLIED
            AND iv_order_category IS NOT INITIAL
            AND ls_confirmation-order_category <> iv_order_category )
          OR ( iv_operation_counter IS NOT INITIAL
            AND ls_confirmation-operation_counter <>
              iv_operation_counter )
          OR ( iv_operation_counter_from IS NOT INITIAL
            AND ls_confirmation-operation_counter <
              iv_operation_counter_from )
          OR ( iv_operation_counter_to IS NOT INITIAL
            AND ls_confirmation-operation_counter >
              iv_operation_counter_to )
          OR ( iv_operation_number IS NOT INITIAL
            AND ls_confirmation-operation_number <>
              iv_operation_number )
          OR ( iv_operation_number_from IS NOT INITIAL
            AND ls_confirmation-operation_number <
              iv_operation_number_from )
          OR ( iv_operation_number_to IS NOT INITIAL
            AND ls_confirmation-operation_number >
              iv_operation_number_to )
          OR ( ( iv_filter_control_key = abap_true
                OR iv_control_key IS NOT INITIAL )
            AND ls_confirmation-control_key <> iv_control_key )
          OR ( ( iv_filter_op_description = abap_true
                OR iv_operation_description IS NOT INITIAL )
            AND ls_confirmation-operation_description <>
              iv_operation_description )
          OR ( ( iv_filter_resource_object_id = abap_true
                OR iv_resource_object_id IS NOT INITIAL )
            AND ls_confirmation-resource_object_id <>
              iv_resource_object_id )
          OR ( ( iv_filter_work_center = abap_true
                OR iv_work_center IS NOT INITIAL )
            AND ls_confirmation-work_center <> iv_work_center )
          OR ( ( iv_filter_work_center_plant = abap_true
                OR iv_work_center_plant IS NOT INITIAL )
            AND ls_confirmation-work_center_plant <>
              iv_work_center_plant )
          OR ( ( iv_filter_operation_sequence = abap_true
                OR iv_operation_sequence IS NOT INITIAL )
            AND ls_confirmation-operation_sequence <>
              iv_operation_sequence )
          OR ( iv_operation_sequence_from IS NOT INITIAL
            AND ls_confirmation-operation_sequence <
              iv_operation_sequence_from )
          OR ( iv_operation_sequence_to IS NOT INITIAL
            AND ls_confirmation-operation_sequence >
              iv_operation_sequence_to )
          OR ( ( iv_filter_suboperation_number = abap_true
                OR iv_suboperation_number IS NOT INITIAL )
            AND ls_confirmation-operation_suboperation <>
              iv_suboperation_number )
          OR ( iv_suboperation_number_from IS NOT INITIAL
            AND ls_confirmation-operation_suboperation <
              iv_suboperation_number_from )
          OR ( iv_suboperation_number_to IS NOT INITIAL
            AND ls_confirmation-operation_suboperation >
              iv_suboperation_number_to )
          OR ( iv_confirmation_number IS NOT INITIAL
            AND ls_confirmation-confirmation <> iv_confirmation_number )
          OR ( iv_confirmation_counter IS NOT INITIAL
            AND ls_confirmation-confirmation_counter <>
              iv_confirmation_counter )
          OR ( ( iv_posting_date_from IS NOT INITIAL
                OR iv_posting_date_to IS NOT INITIAL )
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-posting_date ) <> abap_true )
          OR ( iv_posting_date_from IS SUPPLIED
            AND iv_posting_date_from IS NOT INITIAL
            AND ls_confirmation-posting_date < iv_posting_date_from )
          OR ( iv_posting_date_to IS SUPPLIED
            AND iv_posting_date_to IS NOT INITIAL
            AND ls_confirmation-posting_date > iv_posting_date_to )
          OR ( ( iv_entry_date_from IS NOT INITIAL
                OR iv_entry_date_to IS NOT INITIAL )
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-entry_date ) <> abap_true )
          OR ( iv_entry_date_from IS SUPPLIED
            AND iv_entry_date_from IS NOT INITIAL
            AND ls_confirmation-entry_date < iv_entry_date_from )
          OR ( iv_entry_date_to IS SUPPLIED
            AND iv_entry_date_to IS NOT INITIAL
            AND ls_confirmation-entry_date > iv_entry_date_to )
          OR ( ls_confirmation-execution_start_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-execution_start_date )
                <> abap_true )
          OR ( ls_confirmation-execution_start_time IS NOT INITIAL
            AND zcl_date_validation=>is_valid_time(
              iv_time = ls_confirmation-execution_start_time )
                <> abap_true )
          OR ( ls_confirmation-execution_finish_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-execution_finish_date )
                <> abap_true )
          OR ( ls_confirmation-execution_finish_time IS NOT INITIAL
            AND zcl_date_validation=>is_valid_time(
              iv_time = ls_confirmation-execution_finish_time )
                <> abap_true )
          OR ( iv_execution_start_date_from IS SUPPLIED
            AND iv_execution_start_date_from IS NOT INITIAL
            AND ( ls_confirmation-execution_start_date IS INITIAL
              OR ls_confirmation-execution_start_date <
                iv_execution_start_date_from ) )
          OR ( iv_execution_start_date_to IS SUPPLIED
            AND iv_execution_start_date_to IS NOT INITIAL
            AND ( ls_confirmation-execution_start_date IS INITIAL
              OR ls_confirmation-execution_start_date >
                iv_execution_start_date_to ) )
          OR ( iv_execution_finish_date_from IS SUPPLIED
            AND iv_execution_finish_date_from IS NOT INITIAL
            AND ( ls_confirmation-execution_finish_date IS INITIAL
              OR ls_confirmation-execution_finish_date <
                iv_execution_finish_date_from ) )
          OR ( iv_execution_finish_date_to IS SUPPLIED
            AND iv_execution_finish_date_to IS NOT INITIAL
            AND ( ls_confirmation-execution_finish_date IS INITIAL
              OR ls_confirmation-execution_finish_date >
                iv_execution_finish_date_to ) )
          OR ( iv_filter_execution_start_time = abap_true
            AND ( ls_confirmation-execution_start_date IS INITIAL
              OR zcl_date_validation=>is_valid_time(
                iv_time = ls_confirmation-execution_start_time )
                  <> abap_true
              OR ls_confirmation-execution_start_time <
                iv_execution_start_time_from
              OR ls_confirmation-execution_start_time >
                iv_execution_start_time_to ) )
          OR ( iv_filter_exec_finish_time = abap_true
            AND ( ls_confirmation-execution_finish_date IS INITIAL
              OR zcl_date_validation=>is_valid_time(
                iv_time = ls_confirmation-execution_finish_time )
                  <> abap_true
              OR ls_confirmation-execution_finish_time <
                iv_execution_finish_time_from
              OR ls_confirmation-execution_finish_time >
                iv_execution_finish_time_to ) )
          OR ( ( iv_filter_entered_by = abap_true
                OR iv_entered_by IS NOT INITIAL )
            AND ls_confirmation-entered_by <> iv_entered_by )
          OR ( ( iv_filter_changed_by = abap_true
                OR iv_changed_by IS NOT INITIAL )
            AND ls_confirmation-changed_by <> iv_changed_by )
          OR ( ( iv_last_change_date_from IS SUPPLIED
                AND iv_last_change_date_from IS NOT INITIAL )
              OR ( iv_last_change_date_to IS SUPPLIED
                AND iv_last_change_date_to IS NOT INITIAL ) )
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-last_change_date ) <> abap_true
          OR ( iv_last_change_date_from IS SUPPLIED
            AND iv_last_change_date_from IS NOT INITIAL
            AND ls_confirmation-last_change_date <
              iv_last_change_date_from )
          OR ( iv_last_change_date_to IS SUPPLIED
            AND iv_last_change_date_to IS NOT INITIAL
            AND ls_confirmation-last_change_date >
              iv_last_change_date_to )
          OR ( ( iv_filter_quantity_unit = abap_true
                OR iv_quantity_unit IS NOT INITIAL )
            AND ls_confirmation-quantity_unit <> iv_quantity_unit )
          OR ( iv_positive_yield_only = abap_true
            AND ls_confirmation-yield_quantity <= 0 )
          OR ( iv_positive_rework_only = abap_true
            AND ls_confirmation-rework_quantity <= 0 )
          OR ( iv_positive_scrap_only = abap_true
            AND ls_confirmation-scrap_quantity <= 0 )
          OR ( iv_filter_yield_quantity_from = abap_true
            AND ls_confirmation-yield_quantity <
              iv_yield_quantity_from )
          OR ( iv_filter_yield_quantity_to = abap_true
            AND ls_confirmation-yield_quantity >
              iv_yield_quantity_to )
          OR ( iv_filter_rework_quantity_from = abap_true
            AND ls_confirmation-rework_quantity <
              iv_rework_quantity_from )
          OR ( iv_filter_rework_quantity_to = abap_true
            AND ls_confirmation-rework_quantity >
              iv_rework_quantity_to )
          OR ( iv_filter_scrap_quantity_from = abap_true
            AND ls_confirmation-scrap_quantity <
              iv_scrap_quantity_from )
          OR ( iv_filter_scrap_quantity_to = abap_true
            AND ls_confirmation-scrap_quantity >
              iv_scrap_quantity_to )
          OR ( iv_filter_entry_time = abap_true
            AND ( zcl_date_validation=>is_valid_time(
              iv_time = ls_confirmation-entry_time ) <> abap_true
              OR ls_confirmation-entry_time < iv_entry_time_from
              OR ls_confirmation-entry_time > iv_entry_time_to ) )
          OR ( iv_exclude_reversed = abap_true
            AND ls_confirmation-is_reversed = abap_true )
          OR ( iv_reversed_only IS SUPPLIED
            AND iv_reversed_only = abap_true
            AND ls_confirmation-is_reversed <> abap_true )
          OR ( iv_final_only = abap_true
            AND ls_confirmation-is_final <> abap_true )
          OR ( iv_partial_only = abap_true
            AND ls_confirmation-is_final = abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        confirmation         = ls_confirmation-confirmation
        confirmation_counter = ls_confirmation-confirmation_counter )
        INTO TABLE lt_confirmation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_conf_selection.
    IF is_selection-material IS INITIAL
        OR is_selection-plant IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-posting_date_from ) <> abap_true
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_selection-posting_date_to ) <> abap_true
        OR is_selection-posting_date_from > is_selection-posting_date_to
        OR ( is_selection-entry_date_from IS INITIAL
          AND is_selection-entry_date_to IS NOT INITIAL )
        OR ( is_selection-entry_date_from IS NOT INITIAL
          AND is_selection-entry_date_to IS INITIAL )
        OR ( is_selection-entry_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-entry_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-entry_date_to ) <> abap_true
            OR is_selection-entry_date_from > is_selection-entry_date_to ) )
        OR ( is_selection-last_change_date_from IS INITIAL
          AND is_selection-last_change_date_to IS NOT INITIAL )
        OR ( is_selection-last_change_date_from IS NOT INITIAL
          AND is_selection-last_change_date_to IS INITIAL )
        OR ( is_selection-last_change_date_from IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-last_change_date_from ) <> abap_true
            OR zcl_date_validation=>is_valid_gregorian_date(
              iv_date = is_selection-last_change_date_to ) <> abap_true
            OR is_selection-last_change_date_from >
              is_selection-last_change_date_to ) )
        OR ( is_selection-execution_start_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-execution_start_date_from )
              <> abap_true )
        OR ( is_selection-execution_start_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-execution_start_date_to )
              <> abap_true )
        OR ( is_selection-execution_start_date_from IS NOT INITIAL
          AND is_selection-execution_start_date_to IS NOT INITIAL
          AND is_selection-execution_start_date_from >
            is_selection-execution_start_date_to )
        OR ( is_selection-filter_execution_start_time <> abap_true
          AND is_selection-filter_execution_start_time <> abap_false )
        OR ( is_selection-filter_execution_start_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
              iv_time = is_selection-execution_start_time_from )
                <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-execution_start_time_to )
                <> abap_true
            OR is_selection-execution_start_time_from >
              is_selection-execution_start_time_to ) )
        OR ( is_selection-filter_execution_start_time = abap_false
          AND ( is_selection-execution_start_time_from IS NOT INITIAL
            OR is_selection-execution_start_time_to IS NOT INITIAL ) )
        OR ( is_selection-execution_finish_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-execution_finish_date_from )
              <> abap_true )
        OR ( is_selection-execution_finish_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-execution_finish_date_to )
              <> abap_true )
        OR ( is_selection-execution_finish_date_from IS NOT INITIAL
          AND is_selection-execution_finish_date_to IS NOT INITIAL
          AND is_selection-execution_finish_date_from >
            is_selection-execution_finish_date_to )
        OR ( is_selection-filter_execution_finish_time <> abap_true
          AND is_selection-filter_execution_finish_time <> abap_false )
        OR ( is_selection-filter_execution_finish_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
              iv_time = is_selection-execution_finish_time_from )
                <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-execution_finish_time_to )
                <> abap_true
            OR is_selection-execution_finish_time_from >
              is_selection-execution_finish_time_to ) )
        OR ( is_selection-filter_execution_finish_time = abap_false
          AND ( is_selection-execution_finish_time_from IS NOT INITIAL
            OR is_selection-execution_finish_time_to IS NOT INITIAL ) )
        OR is_selection-maximum_results < 1
        OR is_selection-maximum_results > 500
        OR ( is_selection-filter_order_type <> abap_true
          AND is_selection-filter_order_type <> abap_false )
        OR ( is_selection-exclude_deleted <> abap_true
          AND is_selection-exclude_deleted <> abap_false )
        OR ( is_selection-filter_quantity_unit <> abap_true
          AND is_selection-filter_quantity_unit <> abap_false )
        OR ( is_selection-filter_entered_by <> abap_true
          AND is_selection-filter_entered_by <> abap_false )
        OR ( is_selection-filter_changed_by <> abap_true
          AND is_selection-filter_changed_by <> abap_false )
        OR ( is_selection-filter_entry_time <> abap_true
          AND is_selection-filter_entry_time <> abap_false )
        OR ( is_selection-filter_entry_time = abap_false
          AND ( is_selection-entry_time_from IS NOT INITIAL
            OR is_selection-entry_time_to IS NOT INITIAL ) )
        OR ( is_selection-filter_entry_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
            iv_time = is_selection-entry_time_from ) <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = is_selection-entry_time_to ) <> abap_true
            OR is_selection-entry_time_from > is_selection-entry_time_to ) )
        OR ( is_selection-filter_control_key <> abap_true
          AND is_selection-filter_control_key <> abap_false )
        OR ( is_selection-filter_operation_description <> abap_true
          AND is_selection-filter_operation_description <> abap_false )
        OR ( is_selection-filter_resource_object_id <> abap_true
          AND is_selection-filter_resource_object_id <> abap_false )
        OR ( is_selection-filter_work_center <> abap_true
          AND is_selection-filter_work_center <> abap_false )
        OR ( is_selection-filter_work_center_plant <> abap_true
          AND is_selection-filter_work_center_plant <> abap_false )
        OR ( is_selection-filter_operation_sequence <> abap_true
          AND is_selection-filter_operation_sequence <> abap_false )
        OR ( is_selection-filter_operation_suboperation <> abap_true
          AND is_selection-filter_operation_suboperation <> abap_false )
        OR ( is_selection-operation_number_from IS NOT INITIAL
          AND is_selection-operation_number_to IS NOT INITIAL
          AND is_selection-operation_number_from >
            is_selection-operation_number_to )
        OR ( is_selection-operation_sequence_from IS NOT INITIAL
          AND is_selection-operation_sequence_to IS NOT INITIAL
          AND is_selection-operation_sequence_from >
            is_selection-operation_sequence_to )
        OR ( is_selection-operation_number IS INITIAL
          AND ( is_selection-operation_suboperation IS NOT INITIAL
            OR is_selection-filter_operation_suboperation = abap_true ) )
        OR ( is_selection-operation_number IS INITIAL
          AND ( is_selection-operation_suboperation_from IS NOT INITIAL
            OR is_selection-operation_suboperation_to IS NOT INITIAL ) )
        OR ( is_selection-operation_suboperation_from IS NOT INITIAL
          AND is_selection-operation_suboperation_to IS NOT INITIAL
          AND is_selection-operation_suboperation_from >
            is_selection-operation_suboperation_to )
        OR ( is_selection-confirmation_number IS INITIAL
          AND ( is_selection-confirmation_counter IS NOT INITIAL
            OR is_selection-confirmation_counter_from IS NOT INITIAL
            OR is_selection-confirmation_counter_to IS NOT INITIAL ) )
        OR ( is_selection-confirmation_counter_from IS NOT INITIAL
          AND is_selection-confirmation_counter_to IS NOT INITIAL
          AND is_selection-confirmation_counter_from >
            is_selection-confirmation_counter_to )
        OR ( is_selection-order_category IS NOT INITIAL
          AND is_selection-order_category <> '10'
          AND is_selection-order_category <> '40' )
        OR ( ( is_selection-operation_counter_from IS NOT INITIAL
            OR is_selection-operation_counter_to IS NOT INITIAL )
          AND is_selection-production_order IS INITIAL )
        OR ( is_selection-operation_counter_from IS NOT INITIAL
          AND is_selection-operation_counter_to IS NOT INITIAL
          AND is_selection-operation_counter_from >
            is_selection-operation_counter_to )
        OR ( is_selection-operation_counter IS NOT INITIAL
          AND is_selection-production_order IS INITIAL )
        OR ( is_selection-exclude_reversed <> abap_true
          AND is_selection-exclude_reversed <> abap_false )
        OR ( is_selection-reversed_only <> abap_true
          AND is_selection-reversed_only <> abap_false )
        OR ( is_selection-positive_yield_only <> abap_true
          AND is_selection-positive_yield_only <> abap_false )
        OR ( is_selection-positive_rework_only <> abap_true
          AND is_selection-positive_rework_only <> abap_false )
        OR ( is_selection-positive_scrap_only <> abap_true
          AND is_selection-positive_scrap_only <> abap_false )
        OR ( is_selection-filter_yield_quantity_from <> abap_true
          AND is_selection-filter_yield_quantity_from <> abap_false )
        OR ( is_selection-filter_yield_quantity_to <> abap_true
          AND is_selection-filter_yield_quantity_to <> abap_false )
        OR ( is_selection-filter_rework_quantity_from <> abap_true
          AND is_selection-filter_rework_quantity_from <> abap_false )
        OR ( is_selection-filter_rework_quantity_to <> abap_true
          AND is_selection-filter_rework_quantity_to <> abap_false )
        OR ( is_selection-filter_scrap_quantity_from <> abap_true
          AND is_selection-filter_scrap_quantity_from <> abap_false )
        OR ( is_selection-filter_scrap_quantity_to <> abap_true
          AND is_selection-filter_scrap_quantity_to <> abap_false )
        OR ( ( is_selection-filter_yield_quantity_from = abap_true
              OR is_selection-filter_yield_quantity_to = abap_true
              OR is_selection-filter_rework_quantity_from = abap_true
              OR is_selection-filter_rework_quantity_to = abap_true
              OR is_selection-filter_scrap_quantity_from = abap_true
              OR is_selection-filter_scrap_quantity_to = abap_true )
          AND is_selection-quantity_unit IS INITIAL
          AND is_selection-filter_quantity_unit <> abap_true )
        OR ( is_selection-filter_yield_quantity_from = abap_false
          AND is_selection-yield_quantity_from IS NOT INITIAL )
        OR ( is_selection-filter_yield_quantity_to = abap_false
          AND is_selection-yield_quantity_to IS NOT INITIAL )
        OR ( is_selection-filter_rework_quantity_from = abap_false
          AND is_selection-rework_quantity_from IS NOT INITIAL )
        OR ( is_selection-filter_rework_quantity_to = abap_false
          AND is_selection-rework_quantity_to IS NOT INITIAL )
        OR ( is_selection-filter_scrap_quantity_from = abap_false
          AND is_selection-scrap_quantity_from IS NOT INITIAL )
        OR ( is_selection-filter_scrap_quantity_to = abap_false
          AND is_selection-scrap_quantity_to IS NOT INITIAL )
        OR ( is_selection-filter_yield_quantity_from = abap_true
          AND is_selection-filter_yield_quantity_to = abap_true
          AND is_selection-yield_quantity_from >
            is_selection-yield_quantity_to )
        OR ( is_selection-filter_rework_quantity_from = abap_true
          AND is_selection-filter_rework_quantity_to = abap_true
          AND is_selection-rework_quantity_from >
            is_selection-rework_quantity_to )
        OR ( is_selection-filter_scrap_quantity_from = abap_true
          AND is_selection-filter_scrap_quantity_to = abap_true
          AND is_selection-scrap_quantity_from >
            is_selection-scrap_quantity_to )
        OR ( is_selection-exclude_reversed = abap_true
          AND is_selection-reversed_only = abap_true )
        OR ( is_selection-final_only <> abap_true
          AND is_selection-final_only <> abap_false )
        OR ( is_selection-partial_only <> abap_true
          AND is_selection-partial_only <> abap_false )
        OR ( is_selection-final_only = abap_true
          AND is_selection-partial_only = abap_true )
        OR ( is_selection-after_posting_date IS INITIAL
          AND ( is_selection-after_production_order IS NOT INITIAL
            OR is_selection-after_confirmation IS NOT INITIAL
            OR is_selection-after_confirmation_counter IS NOT INITIAL ) )
        OR ( is_selection-after_posting_date IS NOT INITIAL
          AND ( is_selection-after_production_order IS INITIAL
            OR is_selection-after_confirmation IS INITIAL
            OR is_selection-after_confirmation_counter IS INITIAL ) )
        OR ( is_selection-after_posting_date IS NOT INITIAL
          AND ( zcl_date_validation=>is_valid_gregorian_date(
            iv_date = is_selection-after_posting_date ) <> abap_true
            OR is_selection-after_posting_date <
              is_selection-posting_date_from
            OR is_selection-after_posting_date >
              is_selection-posting_date_to ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_conf_window_results.
    TYPES:
      BEGIN OF ty_confirmation_sort_key,
        posting_date         TYPE afru-budat,
        production_order     TYPE
          zif_prod_order_read_repo=>ty_order_number,
        confirmation         TYPE afru-rueck,
        confirmation_counter TYPE afru-rmzhl,
      END OF ty_confirmation_sort_key.
    DATA ls_previous_key TYPE ty_confirmation_sort_key.
    DATA lv_has_previous TYPE abap_bool.

    IF lines( it_confirmations ) > is_selection-maximum_results + 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      IF zcl_date_validation=>is_valid_gregorian_date(
          iv_date = ls_confirmation-posting_date ) <> abap_true
          OR ( ls_confirmation-entry_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-entry_date ) <> abap_true )
          OR ( ls_confirmation-last_change_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-last_change_date ) <> abap_true )
          OR ( ls_confirmation-execution_start_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-execution_start_date )
                <> abap_true )
          OR ( ls_confirmation-execution_start_time IS NOT INITIAL
            AND zcl_date_validation=>is_valid_time(
              iv_time = ls_confirmation-execution_start_time )
                <> abap_true )
          OR ( ls_confirmation-execution_finish_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_confirmation-execution_finish_date )
                <> abap_true )
          OR ( ls_confirmation-execution_finish_time IS NOT INITIAL
            AND zcl_date_validation=>is_valid_time(
              iv_time = ls_confirmation-execution_finish_time )
                <> abap_true )
          OR zcl_date_validation=>is_valid_time(
            iv_time = ls_confirmation-entry_time ) <> abap_true
          OR ls_confirmation-scope_material <> is_selection-material
          OR ls_confirmation-scope_plant <> is_selection-plant
          OR ls_confirmation-posting_date <
            is_selection-posting_date_from
          OR ls_confirmation-posting_date >
            is_selection-posting_date_to
          OR ( is_selection-entry_date_from IS NOT INITIAL
            AND ( ls_confirmation-entry_date < is_selection-entry_date_from
              OR ls_confirmation-entry_date > is_selection-entry_date_to ) )
          OR ( is_selection-last_change_date_from IS NOT INITIAL
            AND ( ls_confirmation-last_change_date <
              is_selection-last_change_date_from
              OR ls_confirmation-last_change_date >
                is_selection-last_change_date_to ) )
          OR ( is_selection-execution_start_date_from IS NOT INITIAL
            AND ( ls_confirmation-execution_start_date IS INITIAL
              OR ls_confirmation-execution_start_date <
                is_selection-execution_start_date_from ) )
          OR ( is_selection-execution_start_date_to IS NOT INITIAL
            AND ( ls_confirmation-execution_start_date IS INITIAL
              OR ls_confirmation-execution_start_date >
                is_selection-execution_start_date_to ) )
          OR ( is_selection-filter_execution_start_time = abap_true
            AND ( ls_confirmation-execution_start_date IS INITIAL
              OR ls_confirmation-execution_start_time <
                is_selection-execution_start_time_from
              OR ls_confirmation-execution_start_time >
                is_selection-execution_start_time_to ) )
          OR ( is_selection-execution_finish_date_from IS NOT INITIAL
            AND ( ls_confirmation-execution_finish_date IS INITIAL
              OR ls_confirmation-execution_finish_date <
                is_selection-execution_finish_date_from ) )
          OR ( is_selection-execution_finish_date_to IS NOT INITIAL
            AND ( ls_confirmation-execution_finish_date IS INITIAL
              OR ls_confirmation-execution_finish_date >
                is_selection-execution_finish_date_to ) )
          OR ( is_selection-filter_execution_finish_time = abap_true
            AND ( ls_confirmation-execution_finish_date IS INITIAL
              OR ls_confirmation-execution_finish_time <
                is_selection-execution_finish_time_from
              OR ls_confirmation-execution_finish_time >
                is_selection-execution_finish_time_to ) )
          OR ( is_selection-filter_entry_time = abap_true
            AND ( ls_confirmation-entry_time < is_selection-entry_time_from
              OR ls_confirmation-entry_time > is_selection-entry_time_to ) )
          OR ( is_selection-production_order IS NOT INITIAL
            AND ls_confirmation-production_order <>
              is_selection-production_order )
          OR ( is_selection-order_category IS NOT INITIAL
            AND ls_confirmation-order_category <>
              is_selection-order_category )
          OR ( ( is_selection-filter_order_type = abap_true
              OR is_selection-order_type IS NOT INITIAL )
            AND ls_confirmation-order_type <> is_selection-order_type )
          OR ( is_selection-exclude_deleted = abap_true
            AND ls_confirmation-order_deletion_indicator IS NOT INITIAL )
          OR ( is_selection-operation_counter IS NOT INITIAL
            AND ls_confirmation-operation_counter <>
              is_selection-operation_counter )
          OR ( is_selection-operation_counter_from IS NOT INITIAL
            AND ls_confirmation-operation_counter <
              is_selection-operation_counter_from )
          OR ( is_selection-operation_counter_to IS NOT INITIAL
            AND ls_confirmation-operation_counter >
              is_selection-operation_counter_to )
          OR ( is_selection-operation_number IS NOT INITIAL
            AND ls_confirmation-operation_number <>
              is_selection-operation_number )
          OR ( is_selection-operation_number_from IS NOT INITIAL
            AND ls_confirmation-operation_number <
              is_selection-operation_number_from )
          OR ( is_selection-operation_number_to IS NOT INITIAL
            AND ls_confirmation-operation_number >
              is_selection-operation_number_to )
          OR ( ( is_selection-filter_operation_suboperation = abap_true
              OR is_selection-operation_suboperation IS NOT INITIAL )
            AND ls_confirmation-operation_suboperation <>
              is_selection-operation_suboperation )
          OR ( is_selection-operation_suboperation_from IS NOT INITIAL
            AND ls_confirmation-operation_suboperation <
              is_selection-operation_suboperation_from )
          OR ( is_selection-operation_suboperation_to IS NOT INITIAL
            AND ls_confirmation-operation_suboperation >
              is_selection-operation_suboperation_to )
          OR ( ( is_selection-filter_operation_sequence = abap_true
              OR is_selection-operation_sequence IS NOT INITIAL )
            AND ls_confirmation-operation_sequence <>
              is_selection-operation_sequence )
          OR ( is_selection-operation_sequence_from IS NOT INITIAL
            AND ls_confirmation-operation_sequence <
              is_selection-operation_sequence_from )
          OR ( is_selection-operation_sequence_to IS NOT INITIAL
            AND ls_confirmation-operation_sequence >
              is_selection-operation_sequence_to )
          OR ( ( is_selection-filter_control_key = abap_true
              OR is_selection-control_key IS NOT INITIAL )
            AND ls_confirmation-control_key <>
              is_selection-control_key )
          OR ( ( is_selection-filter_operation_description = abap_true
              OR is_selection-operation_description IS NOT INITIAL )
            AND ls_confirmation-operation_description <>
              is_selection-operation_description )
          OR ( ( is_selection-filter_resource_object_id = abap_true
              OR is_selection-resource_object_id IS NOT INITIAL )
            AND ls_confirmation-resource_object_id <>
              is_selection-resource_object_id )
          OR ( ( is_selection-filter_work_center = abap_true
              OR is_selection-work_center IS NOT INITIAL )
            AND ls_confirmation-work_center <> is_selection-work_center )
          OR ( ( is_selection-filter_work_center_plant = abap_true
              OR is_selection-work_center_plant IS NOT INITIAL )
            AND ls_confirmation-work_center_plant <>
              is_selection-work_center_plant )
          OR ( ( is_selection-filter_quantity_unit = abap_true
              OR is_selection-quantity_unit IS NOT INITIAL )
            AND ls_confirmation-quantity_unit <>
              is_selection-quantity_unit )
          OR ( ( is_selection-filter_entered_by = abap_true
              OR is_selection-entered_by IS NOT INITIAL )
            AND ls_confirmation-entered_by <> is_selection-entered_by )
          OR ( ( is_selection-filter_changed_by = abap_true
              OR is_selection-changed_by IS NOT INITIAL )
            AND ls_confirmation-changed_by <> is_selection-changed_by )
          OR ( is_selection-confirmation_number IS NOT INITIAL
            AND ls_confirmation-confirmation <>
              is_selection-confirmation_number )
          OR ( is_selection-confirmation_counter IS NOT INITIAL
            AND ls_confirmation-confirmation_counter <>
              is_selection-confirmation_counter )
          OR ( is_selection-confirmation_counter_from IS NOT INITIAL
            AND ls_confirmation-confirmation_counter <
              is_selection-confirmation_counter_from )
          OR ( is_selection-confirmation_counter_to IS NOT INITIAL
            AND ls_confirmation-confirmation_counter >
              is_selection-confirmation_counter_to )
          OR ( is_selection-exclude_reversed = abap_true
            AND ls_confirmation-is_reversed = abap_true )
          OR ( is_selection-reversed_only = abap_true
            AND ls_confirmation-is_reversed <> abap_true )
          OR ( is_selection-positive_yield_only = abap_true
            AND ls_confirmation-yield_quantity <= 0 )
          OR ( is_selection-filter_yield_quantity_from = abap_true
            AND ls_confirmation-yield_quantity <
              is_selection-yield_quantity_from )
          OR ( is_selection-filter_yield_quantity_to = abap_true
            AND ls_confirmation-yield_quantity >
              is_selection-yield_quantity_to )
          OR ( is_selection-filter_rework_quantity_from = abap_true
            AND ls_confirmation-rework_quantity <
              is_selection-rework_quantity_from )
          OR ( is_selection-filter_rework_quantity_to = abap_true
            AND ls_confirmation-rework_quantity >
              is_selection-rework_quantity_to )
          OR ( is_selection-filter_scrap_quantity_from = abap_true
            AND ls_confirmation-scrap_quantity <
              is_selection-scrap_quantity_from )
          OR ( is_selection-filter_scrap_quantity_to = abap_true
            AND ls_confirmation-scrap_quantity >
              is_selection-scrap_quantity_to )
          OR ( is_selection-positive_rework_only = abap_true
            AND ls_confirmation-rework_quantity <= 0 )
          OR ( is_selection-positive_scrap_only = abap_true
            AND ls_confirmation-scrap_quantity <= 0 )
          OR ( is_selection-final_only = abap_true
            AND ls_confirmation-is_final <> abap_true )
          OR ( is_selection-partial_only = abap_true
            AND ls_confirmation-is_final <> abap_false )
          OR ( is_selection-after_posting_date IS NOT INITIAL
            AND ( ls_confirmation-posting_date <
              is_selection-after_posting_date
              OR ( ls_confirmation-posting_date =
                is_selection-after_posting_date
                AND ls_confirmation-production_order <
                  is_selection-after_production_order )
              OR ( ls_confirmation-posting_date =
                is_selection-after_posting_date
                AND ls_confirmation-production_order =
                  is_selection-after_production_order
                AND ls_confirmation-confirmation <
                  is_selection-after_confirmation )
              OR ( ls_confirmation-posting_date =
                is_selection-after_posting_date
                AND ls_confirmation-production_order =
                  is_selection-after_production_order
                AND ls_confirmation-confirmation =
                  is_selection-after_confirmation
                AND ls_confirmation-confirmation_counter <=
                  is_selection-after_confirmation_counter ) ) )
          OR ( lv_has_previous = abap_true
            AND ( ls_confirmation-posting_date <
              ls_previous_key-posting_date
              OR ( ls_confirmation-posting_date =
                ls_previous_key-posting_date
                AND ls_confirmation-production_order <
                  ls_previous_key-production_order )
              OR ( ls_confirmation-posting_date =
                ls_previous_key-posting_date
                AND ls_confirmation-production_order =
                  ls_previous_key-production_order
                AND ls_confirmation-confirmation <
                  ls_previous_key-confirmation )
              OR ( ls_confirmation-posting_date =
                ls_previous_key-posting_date
                AND ls_confirmation-production_order =
                  ls_previous_key-production_order
                AND ls_confirmation-confirmation =
                  ls_previous_key-confirmation
                AND ls_confirmation-confirmation_counter <=
                  ls_previous_key-confirmation_counter ) ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ls_previous_key = VALUE #(
        posting_date         = ls_confirmation-posting_date
        production_order     = ls_confirmation-production_order
        confirmation         = ls_confirmation-confirmation
        confirmation_counter = ls_confirmation-confirmation_counter ).
      lv_has_previous = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_conf_summaries.
    FIELD-SYMBOLS <ls_summary> TYPE ty_confirmation_operation_summary.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE rt_summaries ASSIGNING <ls_summary>
        WITH TABLE KEY
          production_order       = ls_confirmation-production_order
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          quantity_unit = ls_confirmation-quantity_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order       = ls_confirmation-production_order
          order_category         = ls_confirmation-order_category
          order_type             = ls_confirmation-order_type
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          operation_description  =
            ls_confirmation-operation_description
          control_key            = ls_confirmation-control_key
          resource_object_id     = ls_confirmation-resource_object_id
          work_center            = ls_confirmation-work_center
          work_center_plant      = ls_confirmation-work_center_plant
          first_posting_date     = ls_confirmation-posting_date
          last_posting_date      = ls_confirmation-posting_date
          quantity_unit          = ls_confirmation-quantity_unit )
          INTO TABLE rt_summaries.
        READ TABLE rt_summaries ASSIGNING <ls_summary>
          WITH TABLE KEY
            production_order     = ls_confirmation-production_order
            operation_counter    = ls_confirmation-operation_counter
            operation_number     = ls_confirmation-operation_number
            operation_sequence   = ls_confirmation-operation_sequence
            operation_suboperation =
              ls_confirmation-operation_suboperation
            quantity_unit = ls_confirmation-quantity_unit.
      ENDIF.

      CALL METHOD me->update_conf_execution_metrics
        EXPORTING
          is_confirmation = ls_confirmation
        CHANGING
          cv_execution_start_count       =
            <ls_summary>-execution_start_count
          cv_first_execution_start_date  =
            <ls_summary>-first_execution_start_date
          cv_first_execution_start_time  =
            <ls_summary>-first_execution_start_time
          cv_execution_finish_count      =
            <ls_summary>-execution_finish_count
          cv_last_execution_finish_date  =
            <ls_summary>-last_execution_finish_date
          cv_last_execution_finish_time  =
            <ls_summary>-last_execution_finish_time
          cv_duration_count              =
            <ls_summary>-exec_duration_count
          cv_zero_duration_count         =
            <ls_summary>-zero_exec_duration_count
          cv_invalid_duration_count      =
            <ls_summary>-invalid_exec_duration_count
          cv_duration_seconds            =
            <ls_summary>-exec_duration_seconds_total
          cv_duration_seconds_min        =
            <ls_summary>-exec_duration_seconds_min
          cv_duration_seconds_max        =
            <ls_summary>-exec_duration_seconds_max.
      IF ls_confirmation-posting_date <
          <ls_summary>-first_posting_date.
        <ls_summary>-first_posting_date = ls_confirmation-posting_date.
      ENDIF.
      IF ls_confirmation-posting_date >
          <ls_summary>-last_posting_date.
        <ls_summary>-last_posting_date = ls_confirmation-posting_date.
      ENDIF.
      ADD 1 TO <ls_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_summary>-final_confirmation_count.
      ELSE.
        ADD 1 TO <ls_summary>-partial_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_summary>-reversed_confirmation_count.
      ENDIF.
      <ls_summary>-yield_quantity_total =
        <ls_summary>-yield_quantity_total +
        CONV decfloat34( ls_confirmation-yield_quantity ).
      <ls_summary>-rework_quantity_total =
        <ls_summary>-rework_quantity_total +
        CONV decfloat34( ls_confirmation-rework_quantity ).
      <ls_summary>-scrap_quantity_total =
        <ls_summary>-scrap_quantity_total +
        CONV decfloat34( ls_confirmation-scrap_quantity ).
      IF ls_confirmation-is_reversed <> abap_true.
        <ls_summary>-yield_non_reversed_total =
          <ls_summary>-yield_non_reversed_total +
          CONV decfloat34( ls_confirmation-yield_quantity ).
        <ls_summary>-rework_non_reversed_total =
          <ls_summary>-rework_non_reversed_total +
          CONV decfloat34( ls_confirmation-rework_quantity ).
        <ls_summary>-scrap_non_reversed_total =
          <ls_summary>-scrap_non_reversed_total +
          CONV decfloat34( ls_confirmation-scrap_quantity ).
      ENDIF.
    ENDLOOP.
    LOOP AT rt_summaries ASSIGNING <ls_summary>.
      DATA(ls_operation_exec_pct) =
        calc_exec_coverage_pct(
          iv_confirmation_count     =
            <ls_summary>-confirmation_count
          iv_execution_start_count  =
            <ls_summary>-execution_start_count
          iv_execution_finish_count =
            <ls_summary>-execution_finish_count
          iv_duration_count         =
            <ls_summary>-exec_duration_count
          iv_zero_duration_count    =
            <ls_summary>-zero_exec_duration_count
          iv_invalid_duration_count =
            <ls_summary>-invalid_exec_duration_count ).
      <ls_summary>-execution_start_pct =
        ls_operation_exec_pct-execution_start_pct.
      <ls_summary>-execution_finish_pct =
        ls_operation_exec_pct-execution_finish_pct.
      <ls_summary>-valid_exec_duration_pct =
        ls_operation_exec_pct-valid_exec_duration_pct.
      <ls_summary>-invalid_exec_duration_pct =
        ls_operation_exec_pct-invalid_exec_duration_pct.
      <ls_summary>-missing_exec_duration_count =
        ls_operation_exec_pct-missing_exec_duration_count.
      <ls_summary>-missing_exec_duration_pct =
        ls_operation_exec_pct-missing_exec_duration_pct.
      <ls_summary>-zero_exec_duration_count =
        ls_operation_exec_pct-zero_exec_duration_count.
      <ls_summary>-zero_exec_duration_pct =
        ls_operation_exec_pct-zero_exec_duration_pct.
      <ls_summary>-exec_duration_seconds_avg = calc_exec_duration_avg(
        iv_duration_count         = <ls_summary>-exec_duration_count
        iv_duration_seconds_total =
          <ls_summary>-exec_duration_seconds_total ).
      DATA(ls_summary_percentages) = calculate_conf_percentages(
        iv_confirmation_count = <ls_summary>-confirmation_count
        iv_final_count        = <ls_summary>-final_confirmation_count
        iv_partial_count      = <ls_summary>-partial_confirmation_count
        iv_reversed_count     = <ls_summary>-reversed_confirmation_count ).
      <ls_summary>-final_confirmation_pct =
        ls_summary_percentages-final_confirmation_pct.
      DATA(ls_exec_interval_metrics) = calc_exec_interval_metrics(
        it_confirmations          = it_confirmations
        iv_production_order       = <ls_summary>-production_order
        iv_operation_counter      = <ls_summary>-operation_counter
        iv_operation_number       = <ls_summary>-operation_number
        iv_operation_sequence     = <ls_summary>-operation_sequence
        iv_operation_suboperation =
          <ls_summary>-operation_suboperation
        iv_quantity_unit          = <ls_summary>-quantity_unit ).
      <ls_summary>-exec_covered_seconds =
        ls_exec_interval_metrics-covered_seconds.
      <ls_summary>-exec_duration_seconds_median =
        ls_exec_interval_metrics-duration_median_seconds.

      <ls_summary>-exec_duration_seconds_p90 =
        ls_exec_interval_metrics-duration_p90_seconds.
      <ls_summary>-exec_duration_seconds_p95 =
        ls_exec_interval_metrics-duration_p95_seconds.
      <ls_summary>-exec_duration_seconds_p99 =
        ls_exec_interval_metrics-duration_p99_seconds.
      <ls_summary>-exec_duration_seconds_p25 =
        ls_exec_interval_metrics-duration_p25_seconds.
      <ls_summary>-exec_duration_seconds_p75 =
        ls_exec_interval_metrics-duration_p75_seconds.
      <ls_summary>-exec_duration_seconds_iqr =
        ls_exec_interval_metrics-duration_iqr_seconds.
      <ls_summary>-exec_duration_seconds_mad =
        ls_exec_interval_metrics-duration_mad_seconds.
      <ls_summary>-exec_nonrev_min_secs =
        ls_exec_interval_metrics-nonrev_min_seconds.
      <ls_summary>-exec_nonrev_max_secs =
        ls_exec_interval_metrics-nonrev_max_seconds.
      <ls_summary>-exec_reversed_min_secs =
        ls_exec_interval_metrics-reversed_min_seconds.
      <ls_summary>-exec_reversed_max_secs =
        ls_exec_interval_metrics-reversed_max_seconds.
      <ls_summary>-exec_nonrev_median_secs =
        ls_exec_interval_metrics-nonrev_duration_median_secs.
      <ls_summary>-exec_reversed_median_secs =
        ls_exec_interval_metrics-reversed_duration_median_secs.
      <ls_summary>-exec_nonrev_p90_secs =
        ls_exec_interval_metrics-nonrev_p90_seconds.
      <ls_summary>-exec_reversed_p90_secs =
        ls_exec_interval_metrics-reversed_p90_seconds.
      <ls_summary>-exec_duration_p90_median_ratio =
        ls_exec_interval_metrics-duration_p90_median_ratio.
      <ls_summary>-exec_nonrev_p90_median_ratio =
        ls_exec_interval_metrics-nonrev_p90_median_ratio.
      <ls_summary>-exec_reversed_p90_median_ratio =
        ls_exec_interval_metrics-reversed_p90_median_ratio.
      <ls_summary>-exec_duration_p90_exceed_count =
        ls_exec_interval_metrics-duration_p90_exceed_count.
      <ls_summary>-exec_duration_p90_exceed_pct =
        ls_exec_interval_metrics-duration_p90_exceed_pct.
      <ls_summary>-exec_nonrev_p90_exceed_count =
        ls_exec_interval_metrics-nonrev_p90_exceed_count.
      <ls_summary>-exec_nonrev_p90_exceed_pct =
        ls_exec_interval_metrics-nonrev_p90_exceed_pct.
      <ls_summary>-exec_reversed_p90_exceed_count =
        ls_exec_interval_metrics-reversed_p90_exceed_count.
      <ls_summary>-exec_reversed_p90_exceed_pct =
        ls_exec_interval_metrics-reversed_p90_exceed_pct.
      <ls_summary>-exec_p90_tail_secs =
        ls_exec_interval_metrics-p90_tail_secs.
      <ls_summary>-exec_p90_tail_pct =
        ls_exec_interval_metrics-p90_tail_pct.
      <ls_summary>-exec_nonrev_p90_tail_secs =
        ls_exec_interval_metrics-nonrev_p90_tail_secs.
      <ls_summary>-exec_nonrev_p90_tail_pct =
        ls_exec_interval_metrics-nonrev_p90_tail_pct.
      <ls_summary>-exec_reversed_p90_tail_secs =
        ls_exec_interval_metrics-reversed_p90_tail_secs.
      <ls_summary>-exec_reversed_p90_tail_pct =
        ls_exec_interval_metrics-reversed_p90_tail_pct.
      <ls_summary>-exec_nonrev_p95_secs =
        ls_exec_interval_metrics-nonrev_p95_seconds.
      <ls_summary>-exec_reversed_p95_secs =
        ls_exec_interval_metrics-reversed_p95_seconds.
      <ls_summary>-exec_duration_p95_median_ratio =
        ls_exec_interval_metrics-duration_p95_median_ratio.
      <ls_summary>-exec_nonrev_p95_median_ratio =
        ls_exec_interval_metrics-nonrev_p95_median_ratio.
      <ls_summary>-exec_reversed_p95_median_ratio =
        ls_exec_interval_metrics-reversed_p95_median_ratio.
      <ls_summary>-exec_duration_p95_exceed_count =
        ls_exec_interval_metrics-duration_p95_exceed_count.
      <ls_summary>-exec_duration_p95_exceed_pct =
        ls_exec_interval_metrics-duration_p95_exceed_pct.
      <ls_summary>-exec_nonrev_p95_exceed_count =
        ls_exec_interval_metrics-nonrev_p95_exceed_count.
      <ls_summary>-exec_nonrev_p95_exceed_pct =
        ls_exec_interval_metrics-nonrev_p95_exceed_pct.
      <ls_summary>-exec_reversed_p95_exceed_count =
        ls_exec_interval_metrics-reversed_p95_exceed_count.
      <ls_summary>-exec_reversed_p95_exceed_pct =
        ls_exec_interval_metrics-reversed_p95_exceed_pct.
      <ls_summary>-exec_p95_tail_secs =
        ls_exec_interval_metrics-p95_tail_secs.
      <ls_summary>-exec_p95_tail_pct =
        ls_exec_interval_metrics-p95_tail_pct.
      <ls_summary>-exec_nonrev_p95_tail_secs =
        ls_exec_interval_metrics-nonrev_p95_tail_secs.
      <ls_summary>-exec_nonrev_p95_tail_pct =
        ls_exec_interval_metrics-nonrev_p95_tail_pct.
      <ls_summary>-exec_reversed_p95_tail_secs =
        ls_exec_interval_metrics-reversed_p95_tail_secs.
      <ls_summary>-exec_reversed_p95_tail_pct =
        ls_exec_interval_metrics-reversed_p95_tail_pct.
      <ls_summary>-exec_duration_p99_exceed_count =
        ls_exec_interval_metrics-duration_p99_exceed_count.
      <ls_summary>-exec_duration_p99_exceed_pct =
        ls_exec_interval_metrics-duration_p99_exceed_pct.
      <ls_summary>-exec_nonrev_p99_exceed_count =
        ls_exec_interval_metrics-nonrev_p99_exceed_count.
      <ls_summary>-exec_nonrev_p99_exceed_pct =
        ls_exec_interval_metrics-nonrev_p99_exceed_pct.
      <ls_summary>-exec_reversed_p99_exceed_count =
        ls_exec_interval_metrics-reversed_p99_exceed_count.
      <ls_summary>-exec_reversed_p99_exceed_pct =
        ls_exec_interval_metrics-reversed_p99_exceed_pct.
      <ls_summary>-exec_p99_tail_secs =
        ls_exec_interval_metrics-p99_tail_secs.
      <ls_summary>-exec_p99_tail_pct =
        ls_exec_interval_metrics-p99_tail_pct.
      <ls_summary>-exec_nonrev_p99_tail_secs =
        ls_exec_interval_metrics-nonrev_p99_tail_secs.
      <ls_summary>-exec_nonrev_p99_tail_pct =
        ls_exec_interval_metrics-nonrev_p99_tail_pct.
      <ls_summary>-exec_reversed_p99_tail_secs =
        ls_exec_interval_metrics-reversed_p99_tail_secs.
      <ls_summary>-exec_reversed_p99_tail_pct =
        ls_exec_interval_metrics-reversed_p99_tail_pct.
      <ls_summary>-exec_duration_p99_median_ratio =
        ls_exec_interval_metrics-duration_p99_median_ratio.
      <ls_summary>-exec_nonrev_p99_median_ratio =
        ls_exec_interval_metrics-nonrev_p99_median_ratio.
      <ls_summary>-exec_reversed_p99_median_ratio =
        ls_exec_interval_metrics-reversed_p99_median_ratio.
      <ls_summary>-exec_nonrev_p99_secs =
        ls_exec_interval_metrics-nonrev_p99_seconds.
      <ls_summary>-exec_reversed_p99_secs =
        ls_exec_interval_metrics-reversed_p99_seconds.
      <ls_summary>-exec_nonrev_iqr_secs =
        ls_exec_interval_metrics-nonrev_iqr_seconds.
      <ls_summary>-exec_nonrev_p25_secs =
        ls_exec_interval_metrics-nonrev_p25_seconds.
      <ls_summary>-exec_nonrev_p75_secs =
        ls_exec_interval_metrics-nonrev_p75_seconds.
      <ls_summary>-exec_reversed_p25_secs =
        ls_exec_interval_metrics-reversed_p25_seconds.
      <ls_summary>-exec_reversed_p75_secs =
        ls_exec_interval_metrics-reversed_p75_seconds.
      <ls_summary>-exec_reversed_iqr_secs =
        ls_exec_interval_metrics-reversed_iqr_seconds.
      <ls_summary>-exec_duration_iqr_median_ratio =
        ls_exec_interval_metrics-duration_iqr_median_ratio.
      <ls_summary>-exec_nonrev_iqr_median_ratio =
        ls_exec_interval_metrics-nonrev_iqr_median_ratio.
      <ls_summary>-exec_reversed_iqr_median_ratio =
        ls_exec_interval_metrics-reversed_iqr_median_ratio.
      <ls_summary>-exec_nonrev_mad_secs =
        ls_exec_interval_metrics-nonrev_mad_seconds.
      <ls_summary>-exec_reversed_mad_secs =
        ls_exec_interval_metrics-reversed_mad_seconds.
      <ls_summary>-exec_duration_mad_median_ratio =
        ls_exec_interval_metrics-duration_mad_median_ratio.
      <ls_summary>-exec_nonrev_mad_median_ratio =
        ls_exec_interval_metrics-nonrev_mad_median_ratio.
      <ls_summary>-exec_reversed_mad_median_ratio =
        ls_exec_interval_metrics-reversed_mad_median_ratio.
      <ls_summary>-exec_duration_avg_median_ratio =
        ls_exec_interval_metrics-duration_avg_median_ratio.
      <ls_summary>-exec_nonrev_avg_median_ratio =
        ls_exec_interval_metrics-nonrev_avg_median_ratio.
      <ls_summary>-exec_reversed_avg_median_ratio =
        ls_exec_interval_metrics-reversed_avg_median_ratio.
      <ls_summary>-exec_pos_duration_count =
        ls_exec_interval_metrics-positive_duration_count.
      <ls_summary>-exec_pos_median_secs =
        ls_exec_interval_metrics-positive_median_secs.
      <ls_summary>-exec_pos_p90_secs =
        ls_exec_interval_metrics-positive_p90_secs.
      <ls_summary>-exec_nonrev_pos_count =
        ls_exec_interval_metrics-nonrev_positive_count.
      <ls_summary>-exec_nonrev_pos_median_secs =
        ls_exec_interval_metrics-nonrev_positive_median_secs.
      <ls_summary>-exec_nonrev_pos_p90_secs =
        ls_exec_interval_metrics-nonrev_positive_p90_secs.
      <ls_summary>-exec_reversed_pos_count =
        ls_exec_interval_metrics-reversed_positive_count.
      <ls_summary>-exec_pos_duration_pct =
        ls_exec_interval_metrics-positive_pct.
      <ls_summary>-exec_nonrev_pos_duration_pct =
        ls_exec_interval_metrics-nonrev_pos_pct.
      <ls_summary>-exec_reversed_pos_duration_pct =
        ls_exec_interval_metrics-rev_pos_pct.
      <ls_summary>-exec_pos_valid_pct =
        ls_exec_interval_metrics-pos_valid_pct.
      <ls_summary>-exec_nonrev_pos_valid_pct =
        ls_exec_interval_metrics-nonrev_pos_valid_pct.
      <ls_summary>-exec_rev_pos_valid_pct =
        ls_exec_interval_metrics-rev_pos_valid_pct.
      <ls_summary>-exec_zero_valid_pct =
        ls_exec_interval_metrics-zero_valid_pct.
      <ls_summary>-exec_nonrev_zero_valid_pct =
        ls_exec_interval_metrics-nonrev_zero_valid_pct.
      <ls_summary>-exec_rev_zero_valid_pct =
        ls_exec_interval_metrics-rev_zero_valid_pct.
      <ls_summary>-exec_zero_valid_count =
        ls_exec_interval_metrics-zero_valid_count.
      <ls_summary>-exec_nonrev_zero_valid_count =
        ls_exec_interval_metrics-nonrev_zero_valid_count.
      <ls_summary>-exec_rev_zero_valid_count =
        ls_exec_interval_metrics-rev_zero_valid_count.
      <ls_summary>-exec_nonrev_invalid_count =
        ls_exec_interval_metrics-nonrev_invalid_count.
      <ls_summary>-exec_rev_invalid_count =
        ls_exec_interval_metrics-rev_invalid_count.
      <ls_summary>-exec_nonrev_missing_count =
        ls_exec_interval_metrics-nonrev_missing_count.
      <ls_summary>-exec_rev_missing_count =
        ls_exec_interval_metrics-rev_missing_count.
      <ls_summary>-exec_nonrev_valid_pct =
        ls_exec_interval_metrics-nonrev_valid_pct.
      <ls_summary>-exec_rev_valid_pct =
        ls_exec_interval_metrics-rev_valid_pct.
      <ls_summary>-exec_nonrev_invalid_pct =
        ls_exec_interval_metrics-nonrev_invalid_pct.
      <ls_summary>-exec_rev_invalid_pct =
        ls_exec_interval_metrics-rev_invalid_pct.
      <ls_summary>-exec_nonrev_missing_pct =
        ls_exec_interval_metrics-nonrev_missing_pct.
      <ls_summary>-exec_rev_missing_pct =
        ls_exec_interval_metrics-rev_missing_pct.
      <ls_summary>-exec_top_issue_code =
        ls_exec_interval_metrics-top_issue_code.
      <ls_summary>-exec_top_issue_status =
        ls_exec_interval_metrics-top_issue_status.
      <ls_summary>-exec_top_issue_count =
        ls_exec_interval_metrics-top_issue_count.
      <ls_summary>-exec_top_issue_pct =
        ls_exec_interval_metrics-top_issue_pct.
      <ls_summary>-exec_top_invalid_issue_code =
        ls_exec_interval_metrics-top_invalid_issue_code.
      <ls_summary>-exec_top_invalid_issue_count =
        ls_exec_interval_metrics-top_invalid_issue_count.
      <ls_summary>-exec_top_invalid_share_pct =
        ls_exec_interval_metrics-top_invalid_share_pct.
      <ls_summary>-exec_top_missing_issue_code =
        ls_exec_interval_metrics-top_missing_issue_code.
      <ls_summary>-exec_top_missing_issue_count =
        ls_exec_interval_metrics-top_missing_issue_count.
      <ls_summary>-exec_top_missing_share_pct =
        ls_exec_interval_metrics-top_missing_share_pct.
      <ls_summary>-exec_top_nonrev_issue_code =
        ls_exec_interval_metrics-top_nonrev_issue_code.
      <ls_summary>-exec_top_nonrev_issue_status =
        ls_exec_interval_metrics-top_nonrev_issue_status.
      <ls_summary>-exec_top_nonrev_issue_count =
        ls_exec_interval_metrics-top_nonrev_issue_count.
      <ls_summary>-exec_top_nonrev_issue_pct =
        ls_exec_interval_metrics-top_nonrev_issue_pct.
      <ls_summary>-exec_top_reversed_issue_code =
        ls_exec_interval_metrics-top_reversed_issue_code.
      <ls_summary>-exec_top_reversed_issue_status =
        ls_exec_interval_metrics-top_reversed_issue_status.
      <ls_summary>-exec_top_reversed_issue_count =
        ls_exec_interval_metrics-top_reversed_issue_count.
      <ls_summary>-exec_top_reversed_issue_pct =
        ls_exec_interval_metrics-top_reversed_issue_pct.
      <ls_summary>-exec_duration_issue_counts =
        ls_exec_interval_metrics-issue_counts.
      <ls_summary>-exec_reversed_pos_median_secs =
        ls_exec_interval_metrics-reversed_positive_median_secs.
      <ls_summary>-exec_reversed_pos_p90_secs =
        ls_exec_interval_metrics-reversed_positive_p90_secs.
      <ls_summary>-exec_pos_p90_med_ratio =
        ls_exec_interval_metrics-pos_p90_med_ratio.
      <ls_summary>-exec_nonrev_pos_p90_med_ratio =
        ls_exec_interval_metrics-nonrev_pos_p90_med_ratio.
      <ls_summary>-exec_rev_pos_p90_med_ratio =
        ls_exec_interval_metrics-reversed_pos_p90_med_ratio.
      <ls_summary>-exec_pos_p90_gt_count =
        ls_exec_interval_metrics-pos_p90_gt_count.
      <ls_summary>-exec_pos_p90_gt_pct =
        ls_exec_interval_metrics-pos_p90_gt_pct.
      <ls_summary>-exec_pos_p90_tail_secs =
        ls_exec_interval_metrics-pos_p90_tail_secs.
      <ls_summary>-exec_pos_p90_tail_pct =
        ls_exec_interval_metrics-pos_p90_tail_pct.
      <ls_summary>-exec_nonrev_pos_p90_gt_count =
        ls_exec_interval_metrics-nonrev_pos_p90_gt_count.
      <ls_summary>-exec_nonrev_pos_p90_gt_pct =
        ls_exec_interval_metrics-nonrev_pos_p90_gt_pct.
      <ls_summary>-exec_nonrev_pos_p90_tail_secs =
        ls_exec_interval_metrics-nonrev_pos_p90_tail_secs.
      <ls_summary>-exec_nonrev_pos_p90_tail_pct =
        ls_exec_interval_metrics-nonrev_pos_p90_tail_pct.
      <ls_summary>-exec_rev_pos_p90_gt_count =
        ls_exec_interval_metrics-rev_pos_p90_gt_count.
      <ls_summary>-exec_rev_pos_p90_gt_pct =
        ls_exec_interval_metrics-rev_pos_p90_gt_pct.
      <ls_summary>-exec_rev_pos_p90_tail_secs =
        ls_exec_interval_metrics-rev_pos_p90_tail_secs.
      <ls_summary>-exec_rev_pos_p90_tail_pct =
        ls_exec_interval_metrics-rev_pos_p90_tail_pct.
      <ls_summary>-exec_pos_p95_secs =
        ls_exec_interval_metrics-positive_p95_secs.
      <ls_summary>-exec_pos_p99_secs =
        ls_exec_interval_metrics-positive_p99_secs.
      <ls_summary>-exec_nonrev_pos_p95_secs =
        ls_exec_interval_metrics-nonrev_positive_p95_secs.
      <ls_summary>-exec_nonrev_pos_p99_secs =
        ls_exec_interval_metrics-nonrev_positive_p99_secs.
      <ls_summary>-exec_rev_pos_p95_secs =
        ls_exec_interval_metrics-reversed_positive_p95_secs.
      <ls_summary>-exec_rev_pos_p99_secs =
        ls_exec_interval_metrics-reversed_positive_p99_secs.
      <ls_summary>-exec_pos_p25_secs =
        ls_exec_interval_metrics-positive_p25_secs.
      <ls_summary>-exec_pos_p75_secs =
        ls_exec_interval_metrics-positive_p75_secs.
      <ls_summary>-exec_nonrev_pos_p25_secs =
        ls_exec_interval_metrics-nonrev_positive_p25_secs.
      <ls_summary>-exec_nonrev_pos_p75_secs =
        ls_exec_interval_metrics-nonrev_positive_p75_secs.
      <ls_summary>-exec_rev_pos_p25_secs =
        ls_exec_interval_metrics-reversed_positive_p25_secs.
      <ls_summary>-exec_rev_pos_p75_secs =
        ls_exec_interval_metrics-reversed_positive_p75_secs.
      <ls_summary>-exec_pos_iqr_secs =
        ls_exec_interval_metrics-positive_iqr_secs.
      <ls_summary>-exec_nonrev_pos_iqr_secs =
        ls_exec_interval_metrics-nonrev_positive_iqr_secs.
      <ls_summary>-exec_rev_pos_iqr_secs =
        ls_exec_interval_metrics-reversed_positive_iqr_secs.
      <ls_summary>-exec_pos_mad_secs =
        ls_exec_interval_metrics-positive_mad_secs.
      <ls_summary>-exec_nonrev_pos_mad_secs =
        ls_exec_interval_metrics-nonrev_positive_mad_secs.
      <ls_summary>-exec_rev_pos_mad_secs =
        ls_exec_interval_metrics-reversed_positive_mad_secs.
      <ls_summary>-exec_pos_iqr_med_ratio =
        ls_exec_interval_metrics-positive_iqr_med_ratio.
      <ls_summary>-exec_nonrev_pos_iqr_med_ratio =
        ls_exec_interval_metrics-nonrev_positive_iqr_med_ratio.
      <ls_summary>-exec_rev_pos_iqr_med_ratio =
        ls_exec_interval_metrics-reversed_pos_iqr_med_ratio.
      <ls_summary>-exec_pos_mad_med_ratio =
        ls_exec_interval_metrics-positive_mad_med_ratio.
      <ls_summary>-exec_nonrev_pos_mad_med_ratio =
        ls_exec_interval_metrics-nonrev_positive_mad_med_ratio.
      <ls_summary>-exec_rev_pos_mad_med_ratio =
        ls_exec_interval_metrics-reversed_pos_mad_med_ratio.
      <ls_summary>-exec_pos_avg_secs =
        ls_exec_interval_metrics-pos_avg_secs.
      <ls_summary>-exec_nonrev_pos_avg_secs =
        ls_exec_interval_metrics-nonrev_pos_avg_secs.
      <ls_summary>-exec_rev_pos_avg_secs =
        ls_exec_interval_metrics-rev_pos_avg_secs.
      <ls_summary>-exec_pos_avg_med_ratio =
        ls_exec_interval_metrics-pos_avg_med_ratio.
      <ls_summary>-exec_nonrev_pos_avg_med_ratio =
        ls_exec_interval_metrics-nonrev_pos_avg_med_ratio.
      <ls_summary>-exec_rev_pos_avg_med_ratio =
        ls_exec_interval_metrics-rev_pos_avg_med_ratio.
      <ls_summary>-exec_pos_min_secs =
        ls_exec_interval_metrics-positive_min_secs.
      <ls_summary>-exec_pos_max_secs =
        ls_exec_interval_metrics-positive_max_secs.
      <ls_summary>-exec_pos_range_secs =
        ls_exec_interval_metrics-positive_range_secs.
      <ls_summary>-exec_nonrev_pos_min_secs =
        ls_exec_interval_metrics-nonrev_positive_min_secs.
      <ls_summary>-exec_nonrev_pos_max_secs =
        ls_exec_interval_metrics-nonrev_positive_max_secs.
      <ls_summary>-exec_nonrev_pos_range_secs =
        ls_exec_interval_metrics-nonrev_positive_range_secs.
      <ls_summary>-exec_rev_pos_min_secs =
        ls_exec_interval_metrics-reversed_positive_min_secs.
      <ls_summary>-exec_rev_pos_max_secs =
        ls_exec_interval_metrics-reversed_positive_max_secs.
      <ls_summary>-exec_rev_pos_range_secs =
        ls_exec_interval_metrics-reversed_positive_range_secs.
      <ls_summary>-exec_pos_p95_gt_count =
        ls_exec_interval_metrics-pos_p95_gt_count.
      <ls_summary>-exec_pos_p95_gt_pct =
        ls_exec_interval_metrics-pos_p95_gt_pct.
      <ls_summary>-exec_pos_p95_tail_secs =
        ls_exec_interval_metrics-pos_p95_tail_secs.
      <ls_summary>-exec_pos_p95_tail_pct =
        ls_exec_interval_metrics-pos_p95_tail_pct.
      <ls_summary>-exec_nonrev_pos_p95_gt_count =
        ls_exec_interval_metrics-nonrev_pos_p95_gt_count.
      <ls_summary>-exec_nonrev_pos_p95_gt_pct =
        ls_exec_interval_metrics-nonrev_pos_p95_gt_pct.
      <ls_summary>-exec_nonrev_pos_p95_tail_secs =
        ls_exec_interval_metrics-nonrev_pos_p95_tail_secs.
      <ls_summary>-exec_nonrev_pos_p95_tail_pct =
        ls_exec_interval_metrics-nonrev_pos_p95_tail_pct.
      <ls_summary>-exec_rev_pos_p95_gt_count =
        ls_exec_interval_metrics-rev_pos_p95_gt_count.
      <ls_summary>-exec_rev_pos_p95_gt_pct =
        ls_exec_interval_metrics-rev_pos_p95_gt_pct.
      <ls_summary>-exec_rev_pos_p95_tail_secs =
        ls_exec_interval_metrics-rev_pos_p95_tail_secs.
      <ls_summary>-exec_rev_pos_p95_tail_pct =
        ls_exec_interval_metrics-rev_pos_p95_tail_pct.
      <ls_summary>-exec_pos_p99_gt_count =
        ls_exec_interval_metrics-pos_p99_gt_count.
      <ls_summary>-exec_pos_p99_gt_pct =
        ls_exec_interval_metrics-pos_p99_gt_pct.
      <ls_summary>-exec_pos_p99_tail_secs =
        ls_exec_interval_metrics-pos_p99_tail_secs.
      <ls_summary>-exec_pos_p99_tail_pct =
        ls_exec_interval_metrics-pos_p99_tail_pct.
      <ls_summary>-exec_nonrev_pos_p99_gt_count =
        ls_exec_interval_metrics-nonrev_pos_p99_gt_count.
      <ls_summary>-exec_nonrev_pos_p99_gt_pct =
        ls_exec_interval_metrics-nonrev_pos_p99_gt_pct.
      <ls_summary>-exec_nonrev_pos_p99_tail_secs =
        ls_exec_interval_metrics-nonrev_pos_p99_tail_secs.
      <ls_summary>-exec_nonrev_pos_p99_tail_pct =
        ls_exec_interval_metrics-nonrev_pos_p99_tail_pct.
      <ls_summary>-exec_rev_pos_p99_gt_count =
        ls_exec_interval_metrics-rev_pos_p99_gt_count.
      <ls_summary>-exec_rev_pos_p99_gt_pct =
        ls_exec_interval_metrics-rev_pos_p99_gt_pct.
      <ls_summary>-exec_rev_pos_p99_tail_secs =
        ls_exec_interval_metrics-rev_pos_p99_tail_secs.
      <ls_summary>-exec_rev_pos_p99_tail_pct =
        ls_exec_interval_metrics-rev_pos_p99_tail_pct.
      <ls_summary>-exec_pos_p95_med_ratio =
        ls_exec_interval_metrics-pos_p95_med_ratio.
      <ls_summary>-exec_nonrev_pos_p95_med_ratio =
        ls_exec_interval_metrics-nonrev_pos_p95_med_ratio.
      <ls_summary>-exec_rev_pos_p95_med_ratio =
        ls_exec_interval_metrics-rev_pos_p95_med_ratio.
      <ls_summary>-exec_pos_p99_med_ratio =
        ls_exec_interval_metrics-pos_p99_med_ratio.
      <ls_summary>-exec_nonrev_pos_p99_med_ratio =
        ls_exec_interval_metrics-nonrev_pos_p99_med_ratio.
      <ls_summary>-exec_rev_pos_p99_med_ratio =
        ls_exec_interval_metrics-rev_pos_p99_med_ratio.
      <ls_summary>-exec_nonrev_covered_secs =
        ls_exec_interval_metrics-nonrev_covered_seconds.
      <ls_summary>-exec_nonrev_duration_count =
        ls_exec_interval_metrics-nonrev_duration_count.
      <ls_summary>-exec_nonrev_total_secs =
        ls_exec_interval_metrics-nonrev_duration_total.
      <ls_summary>-exec_nonrev_duration_avg_secs =
        ls_exec_interval_metrics-nonrev_duration_avg_secs.
      <ls_summary>-exec_nonrev_excess_secs =
        ls_exec_interval_metrics-nonrev_excess_secs.
      <ls_summary>-exec_reversed_duration_count =
        ls_exec_interval_metrics-reversed_duration_count.
      <ls_summary>-exec_reversed_total_secs =
        ls_exec_interval_metrics-reversed_duration_total.
      <ls_summary>-exec_rev_duration_avg_secs =
        ls_exec_interval_metrics-reversed_avg_secs.
      <ls_summary>-exec_reversed_covered_secs =
        ls_exec_interval_metrics-reversed_covered_seconds.
      <ls_summary>-exec_reversed_excess_secs =
        ls_exec_interval_metrics-reversed_excess_secs.
      <ls_summary>-exec_nonrev_duration_pct =
        ls_exec_interval_metrics-nonrev_duration_pct.
      <ls_summary>-exec_reversed_duration_pct =
        ls_exec_interval_metrics-reversed_duration_pct.
      <ls_summary>-exec_single_active_seconds =
        ls_exec_interval_metrics-single_active_seconds.
      <ls_summary>-exec_single_episode_count =
        ls_exec_interval_metrics-single_episode_count.
      <ls_summary>-exec_longest_single_secs =
        ls_exec_interval_metrics-longest_single_secs.
      <ls_summary>-exec_single_active_avg_secs =
        ls_exec_interval_metrics-single_active_avg_secs.
      <ls_summary>-exec_high_concurrency_secs =
        ls_exec_interval_metrics-high_concurrency_seconds.
      <ls_summary>-exec_exactly_two_secs =
        ls_exec_interval_metrics-exactly_two_seconds.
      <ls_summary>-exec_exactly_two_pct =
        ls_exec_interval_metrics-exactly_two_pct.
      <ls_summary>-exec_3plus_episode_count =
        ls_exec_interval_metrics-three_plus_episode_count.
      <ls_summary>-exec_longest_3plus_secs =
        ls_exec_interval_metrics-longest_three_plus_secs.
      <ls_summary>-exec_3plus_avg_secs =
        ls_exec_interval_metrics-three_plus_avg_secs.
      <ls_summary>-exec_3plus_pct =
        ls_exec_interval_metrics-three_plus_pct.
      <ls_summary>-exec_overlap_excess_seconds =
        ls_exec_interval_metrics-overlap_excess_seconds.
      <ls_summary>-exec_peak_concurrency =
        ls_exec_interval_metrics-peak_concurrency.
      <ls_summary>-exec_idle_gap_seconds =
        ls_exec_interval_metrics-idle_gap_seconds.
      <ls_summary>-exec_idle_gap_episode_count =
        ls_exec_interval_metrics-idle_gap_episode_count.
      <ls_summary>-exec_idle_gap_avg_secs =
        ls_exec_interval_metrics-idle_gap_avg_secs.
      <ls_summary>-exec_interval_coverage_pct =
        ls_exec_interval_metrics-interval_coverage_pct.
      <ls_summary>-exec_single_active_pct =
        ls_exec_interval_metrics-single_active_pct.
      <ls_summary>-exec_overlap_wall_pct =
        ls_exec_interval_metrics-overlap_wall_pct.
      <ls_summary>-exec_longest_idle_gap_secs =
        ls_exec_interval_metrics-longest_idle_gap_secs.
      <ls_summary>-exec_overlap_wall_seconds =
        ls_exec_interval_metrics-overlap_wall_seconds.
      <ls_summary>-exec_pairwise_overlap_secs =
        ls_exec_interval_metrics-pairwise_overlap_seconds.
      <ls_summary>-exec_overlap_episode_count =
        ls_exec_interval_metrics-overlap_episode_count.
      <ls_summary>-exec_overlap_pair_count =
        ls_exec_interval_metrics-overlap_pair_count.
      <ls_summary>-exec_overlap_pair_avg_secs =
        ls_exec_interval_metrics-overlap_pair_avg_secs.
      <ls_summary>-exec_longest_pair_overlap_secs =
        ls_exec_interval_metrics-longest_pair_overlap_secs.
      <ls_summary>-exec_peak_concurrency_secs =
        ls_exec_interval_metrics-peak_seconds.
      <ls_summary>-exec_peak_concurrency_pct =
        ls_exec_interval_metrics-peak_concurrency_pct.
      <ls_summary>-exec_peak_episode_count =
        ls_exec_interval_metrics-peak_episode_count.
      <ls_summary>-exec_longest_peak_secs =
        ls_exec_interval_metrics-longest_peak_secs.
      <ls_summary>-exec_peak_episode_avg_secs =
        ls_exec_interval_metrics-peak_episode_avg_secs.
      <ls_summary>-exec_avg_concurrency =
        ls_exec_interval_metrics-avg_concurrency.
      <ls_summary>-exec_longest_overlap_secs =
        ls_exec_interval_metrics-longest_overlap_secs.
      <ls_summary>-exec_overlap_avg_secs =
        ls_exec_interval_metrics-overlap_avg_secs.
      <ls_summary>-partial_confirmation_pct =
        ls_summary_percentages-partial_confirmation_pct.
      <ls_summary>-reversed_confirmation_pct =
        ls_summary_percentages-reversed_confirmation_pct.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_wc_conf_summaries.
    FIELD-SYMBOLS <ls_summary> TYPE ty_work_center_confirmation_summary.
    FIELD-SYMBOLS <ls_quantity_summary> TYPE
      ty_work_center_confirmation_quantity_summary.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE rt_summaries ASSIGNING <ls_summary>
        WITH TABLE KEY
          work_center_plant = ls_confirmation-work_center_plant
          work_center = ls_confirmation-work_center.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          work_center       = ls_confirmation-work_center
          work_center_plant = ls_confirmation-work_center_plant )
          INTO TABLE rt_summaries.
        READ TABLE rt_summaries ASSIGNING <ls_summary>
          WITH TABLE KEY
            work_center_plant = ls_confirmation-work_center_plant
            work_center = ls_confirmation-work_center.
      ENDIF.

      CALL METHOD me->update_conf_execution_metrics
        EXPORTING
          is_confirmation = ls_confirmation
        CHANGING
          cv_execution_start_count       =
            <ls_summary>-execution_start_count
          cv_first_execution_start_date  =
            <ls_summary>-first_execution_start_date
          cv_first_execution_start_time  =
            <ls_summary>-first_execution_start_time
          cv_execution_finish_count      =
            <ls_summary>-execution_finish_count
          cv_last_execution_finish_date  =
            <ls_summary>-last_execution_finish_date
          cv_last_execution_finish_time  =
            <ls_summary>-last_execution_finish_time
          cv_duration_count              =
            <ls_summary>-exec_duration_count
          cv_zero_duration_count         =
            <ls_summary>-zero_exec_duration_count
          cv_invalid_duration_count      =
            <ls_summary>-invalid_exec_duration_count
          cv_duration_seconds            =
            <ls_summary>-exec_duration_seconds_total
          cv_duration_seconds_min        =
            <ls_summary>-exec_duration_seconds_min
          cv_duration_seconds_max        =
            <ls_summary>-exec_duration_seconds_max.
      IF ls_confirmation-posting_date IS NOT INITIAL.
        IF <ls_summary>-first_posting_date IS INITIAL
            OR ls_confirmation-posting_date <
              <ls_summary>-first_posting_date.
          <ls_summary>-first_posting_date = ls_confirmation-posting_date.
        ENDIF.
        IF <ls_summary>-last_posting_date IS INITIAL
            OR ls_confirmation-posting_date >
              <ls_summary>-last_posting_date.
          <ls_summary>-last_posting_date = ls_confirmation-posting_date.
        ENDIF.
      ENDIF.
      ADD 1 TO <ls_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_summary>-final_confirmation_count.
      ELSE.
        ADD 1 TO <ls_summary>-partial_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_summary>-reversed_confirmation_count.
      ENDIF.
      READ TABLE <ls_summary>-quantity_summaries
          ASSIGNING <ls_quantity_summary>
        WITH TABLE KEY quantity_unit = ls_confirmation-quantity_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          quantity_unit = ls_confirmation-quantity_unit )
          INTO TABLE <ls_summary>-quantity_summaries.
        READ TABLE <ls_summary>-quantity_summaries
            ASSIGNING <ls_quantity_summary>
          WITH TABLE KEY quantity_unit = ls_confirmation-quantity_unit.
      ENDIF.

      CALL METHOD me->update_conf_execution_metrics
        EXPORTING
          is_confirmation = ls_confirmation
        CHANGING
          cv_execution_start_count       =
            <ls_quantity_summary>-execution_start_count
          cv_first_execution_start_date  =
            <ls_quantity_summary>-first_execution_start_date
          cv_first_execution_start_time  =
            <ls_quantity_summary>-first_execution_start_time
          cv_execution_finish_count      =
            <ls_quantity_summary>-execution_finish_count
          cv_last_execution_finish_date  =
            <ls_quantity_summary>-last_execution_finish_date
          cv_last_execution_finish_time  =
            <ls_quantity_summary>-last_execution_finish_time
          cv_duration_count              =
            <ls_quantity_summary>-exec_duration_count
          cv_zero_duration_count         =
            <ls_quantity_summary>-zero_exec_duration_count
          cv_invalid_duration_count      =
            <ls_quantity_summary>-invalid_exec_duration_count
          cv_duration_seconds            =
            <ls_quantity_summary>-exec_duration_seconds_total
          cv_duration_seconds_min        =
            <ls_quantity_summary>-exec_duration_seconds_min
          cv_duration_seconds_max        =
            <ls_quantity_summary>-exec_duration_seconds_max.
      IF ls_confirmation-posting_date IS NOT INITIAL.
        IF <ls_quantity_summary>-first_posting_date IS INITIAL
            OR ls_confirmation-posting_date <
              <ls_quantity_summary>-first_posting_date.
          <ls_quantity_summary>-first_posting_date =
            ls_confirmation-posting_date.
        ENDIF.
        IF <ls_quantity_summary>-last_posting_date IS INITIAL
            OR ls_confirmation-posting_date >
              <ls_quantity_summary>-last_posting_date.
          <ls_quantity_summary>-last_posting_date =
            ls_confirmation-posting_date.
        ENDIF.
      ENDIF.
      ADD 1 TO <ls_quantity_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_quantity_summary>-final_confirmation_count.
      ELSE.
        ADD 1 TO <ls_quantity_summary>-partial_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_quantity_summary>-reversed_confirmation_count.
      ENDIF.
      <ls_quantity_summary>-yield_quantity_total =
        <ls_quantity_summary>-yield_quantity_total +
        CONV decfloat34( ls_confirmation-yield_quantity ).
      <ls_quantity_summary>-rework_quantity_total =
        <ls_quantity_summary>-rework_quantity_total +
        CONV decfloat34( ls_confirmation-rework_quantity ).
      <ls_quantity_summary>-scrap_quantity_total =
        <ls_quantity_summary>-scrap_quantity_total +
        CONV decfloat34( ls_confirmation-scrap_quantity ).
      IF ls_confirmation-is_reversed <> abap_true.
        <ls_quantity_summary>-yield_non_reversed_total =
          <ls_quantity_summary>-yield_non_reversed_total +
          CONV decfloat34( ls_confirmation-yield_quantity ).
        <ls_quantity_summary>-rework_non_reversed_total =
          <ls_quantity_summary>-rework_non_reversed_total +
          CONV decfloat34( ls_confirmation-rework_quantity ).
        <ls_quantity_summary>-scrap_non_reversed_total =
          <ls_quantity_summary>-scrap_non_reversed_total +
          CONV decfloat34( ls_confirmation-scrap_quantity ).
      ENDIF.
    ENDLOOP.

    LOOP AT rt_summaries ASSIGNING <ls_summary>.
      DATA(ls_execution_percentages) =
        calc_exec_coverage_pct(
          iv_confirmation_count     =
            <ls_summary>-confirmation_count
          iv_execution_start_count  =
            <ls_summary>-execution_start_count
          iv_execution_finish_count =
            <ls_summary>-execution_finish_count
          iv_duration_count         =
            <ls_summary>-exec_duration_count
          iv_zero_duration_count    =
            <ls_summary>-zero_exec_duration_count
          iv_invalid_duration_count =
            <ls_summary>-invalid_exec_duration_count ).
      <ls_summary>-execution_start_pct =
        ls_execution_percentages-execution_start_pct.
      <ls_summary>-execution_finish_pct =
        ls_execution_percentages-execution_finish_pct.
      <ls_summary>-valid_exec_duration_pct =
        ls_execution_percentages-valid_exec_duration_pct.
      <ls_summary>-invalid_exec_duration_pct =
        ls_execution_percentages-invalid_exec_duration_pct.
      <ls_summary>-missing_exec_duration_count =
        ls_execution_percentages-missing_exec_duration_count.
      <ls_summary>-missing_exec_duration_pct =
        ls_execution_percentages-missing_exec_duration_pct.
      <ls_summary>-zero_exec_duration_count =
        ls_execution_percentages-zero_exec_duration_count.
      <ls_summary>-zero_exec_duration_pct =
        ls_execution_percentages-zero_exec_duration_pct.
      <ls_summary>-exec_duration_seconds_avg = calc_exec_duration_avg(
        iv_duration_count         = <ls_summary>-exec_duration_count
        iv_duration_seconds_total =
          <ls_summary>-exec_duration_seconds_total ).
      DATA(ls_wc_interval_metrics) = calc_exec_interval_metrics(
        it_confirmations     = it_confirmations
        iv_work_center       = <ls_summary>-work_center
        iv_work_center_plant = <ls_summary>-work_center_plant ).
      <ls_summary>-exec_covered_seconds =
        ls_wc_interval_metrics-covered_seconds.
      <ls_summary>-exec_duration_seconds_median =
        ls_wc_interval_metrics-duration_median_seconds.

      <ls_summary>-exec_duration_seconds_p90 =
        ls_wc_interval_metrics-duration_p90_seconds.
      <ls_summary>-exec_duration_seconds_p95 =
        ls_wc_interval_metrics-duration_p95_seconds.
      <ls_summary>-exec_duration_seconds_p99 =
        ls_wc_interval_metrics-duration_p99_seconds.
      <ls_summary>-exec_duration_seconds_p25 =
        ls_wc_interval_metrics-duration_p25_seconds.
      <ls_summary>-exec_duration_seconds_p75 =
        ls_wc_interval_metrics-duration_p75_seconds.
      <ls_summary>-exec_duration_seconds_iqr =
        ls_wc_interval_metrics-duration_iqr_seconds.
      <ls_summary>-exec_duration_seconds_mad =
        ls_wc_interval_metrics-duration_mad_seconds.
      <ls_summary>-exec_nonrev_min_secs =
        ls_wc_interval_metrics-nonrev_min_seconds.
      <ls_summary>-exec_nonrev_max_secs =
        ls_wc_interval_metrics-nonrev_max_seconds.
      <ls_summary>-exec_reversed_min_secs =
        ls_wc_interval_metrics-reversed_min_seconds.
      <ls_summary>-exec_reversed_max_secs =
        ls_wc_interval_metrics-reversed_max_seconds.
      <ls_summary>-exec_nonrev_median_secs =
        ls_wc_interval_metrics-nonrev_duration_median_secs.
      <ls_summary>-exec_reversed_median_secs =
        ls_wc_interval_metrics-reversed_duration_median_secs.
      <ls_summary>-exec_nonrev_p90_secs =
        ls_wc_interval_metrics-nonrev_p90_seconds.
      <ls_summary>-exec_reversed_p90_secs =
        ls_wc_interval_metrics-reversed_p90_seconds.
      <ls_summary>-exec_duration_p90_median_ratio =
        ls_wc_interval_metrics-duration_p90_median_ratio.
      <ls_summary>-exec_nonrev_p90_median_ratio =
        ls_wc_interval_metrics-nonrev_p90_median_ratio.
      <ls_summary>-exec_reversed_p90_median_ratio =
        ls_wc_interval_metrics-reversed_p90_median_ratio.
      <ls_summary>-exec_duration_p90_exceed_count =
        ls_wc_interval_metrics-duration_p90_exceed_count.
      <ls_summary>-exec_duration_p90_exceed_pct =
        ls_wc_interval_metrics-duration_p90_exceed_pct.
      <ls_summary>-exec_nonrev_p90_exceed_count =
        ls_wc_interval_metrics-nonrev_p90_exceed_count.
      <ls_summary>-exec_nonrev_p90_exceed_pct =
        ls_wc_interval_metrics-nonrev_p90_exceed_pct.
      <ls_summary>-exec_reversed_p90_exceed_count =
        ls_wc_interval_metrics-reversed_p90_exceed_count.
      <ls_summary>-exec_reversed_p90_exceed_pct =
        ls_wc_interval_metrics-reversed_p90_exceed_pct.
      <ls_summary>-exec_p90_tail_secs =
        ls_wc_interval_metrics-p90_tail_secs.
      <ls_summary>-exec_p90_tail_pct =
        ls_wc_interval_metrics-p90_tail_pct.
      <ls_summary>-exec_nonrev_p90_tail_secs =
        ls_wc_interval_metrics-nonrev_p90_tail_secs.
      <ls_summary>-exec_nonrev_p90_tail_pct =
        ls_wc_interval_metrics-nonrev_p90_tail_pct.
      <ls_summary>-exec_reversed_p90_tail_secs =
        ls_wc_interval_metrics-reversed_p90_tail_secs.
      <ls_summary>-exec_reversed_p90_tail_pct =
        ls_wc_interval_metrics-reversed_p90_tail_pct.
      <ls_summary>-exec_nonrev_p95_secs =
        ls_wc_interval_metrics-nonrev_p95_seconds.
      <ls_summary>-exec_reversed_p95_secs =
        ls_wc_interval_metrics-reversed_p95_seconds.
      <ls_summary>-exec_duration_p95_median_ratio =
        ls_wc_interval_metrics-duration_p95_median_ratio.
      <ls_summary>-exec_nonrev_p95_median_ratio =
        ls_wc_interval_metrics-nonrev_p95_median_ratio.
      <ls_summary>-exec_reversed_p95_median_ratio =
        ls_wc_interval_metrics-reversed_p95_median_ratio.
      <ls_summary>-exec_duration_p95_exceed_count =
        ls_wc_interval_metrics-duration_p95_exceed_count.
      <ls_summary>-exec_duration_p95_exceed_pct =
        ls_wc_interval_metrics-duration_p95_exceed_pct.
      <ls_summary>-exec_nonrev_p95_exceed_count =
        ls_wc_interval_metrics-nonrev_p95_exceed_count.
      <ls_summary>-exec_nonrev_p95_exceed_pct =
        ls_wc_interval_metrics-nonrev_p95_exceed_pct.
      <ls_summary>-exec_reversed_p95_exceed_count =
        ls_wc_interval_metrics-reversed_p95_exceed_count.
      <ls_summary>-exec_reversed_p95_exceed_pct =
        ls_wc_interval_metrics-reversed_p95_exceed_pct.
      <ls_summary>-exec_p95_tail_secs =
        ls_wc_interval_metrics-p95_tail_secs.
      <ls_summary>-exec_p95_tail_pct =
        ls_wc_interval_metrics-p95_tail_pct.
      <ls_summary>-exec_nonrev_p95_tail_secs =
        ls_wc_interval_metrics-nonrev_p95_tail_secs.
      <ls_summary>-exec_nonrev_p95_tail_pct =
        ls_wc_interval_metrics-nonrev_p95_tail_pct.
      <ls_summary>-exec_reversed_p95_tail_secs =
        ls_wc_interval_metrics-reversed_p95_tail_secs.
      <ls_summary>-exec_reversed_p95_tail_pct =
        ls_wc_interval_metrics-reversed_p95_tail_pct.
      <ls_summary>-exec_duration_p99_exceed_count =
        ls_wc_interval_metrics-duration_p99_exceed_count.
      <ls_summary>-exec_duration_p99_exceed_pct =
        ls_wc_interval_metrics-duration_p99_exceed_pct.
      <ls_summary>-exec_nonrev_p99_exceed_count =
        ls_wc_interval_metrics-nonrev_p99_exceed_count.
      <ls_summary>-exec_nonrev_p99_exceed_pct =
        ls_wc_interval_metrics-nonrev_p99_exceed_pct.
      <ls_summary>-exec_reversed_p99_exceed_count =
        ls_wc_interval_metrics-reversed_p99_exceed_count.
      <ls_summary>-exec_reversed_p99_exceed_pct =
        ls_wc_interval_metrics-reversed_p99_exceed_pct.
      <ls_summary>-exec_p99_tail_secs =
        ls_wc_interval_metrics-p99_tail_secs.
      <ls_summary>-exec_p99_tail_pct =
        ls_wc_interval_metrics-p99_tail_pct.
      <ls_summary>-exec_nonrev_p99_tail_secs =
        ls_wc_interval_metrics-nonrev_p99_tail_secs.
      <ls_summary>-exec_nonrev_p99_tail_pct =
        ls_wc_interval_metrics-nonrev_p99_tail_pct.
      <ls_summary>-exec_reversed_p99_tail_secs =
        ls_wc_interval_metrics-reversed_p99_tail_secs.
      <ls_summary>-exec_reversed_p99_tail_pct =
        ls_wc_interval_metrics-reversed_p99_tail_pct.
      <ls_summary>-exec_duration_p99_median_ratio =
        ls_wc_interval_metrics-duration_p99_median_ratio.
      <ls_summary>-exec_nonrev_p99_median_ratio =
        ls_wc_interval_metrics-nonrev_p99_median_ratio.
      <ls_summary>-exec_reversed_p99_median_ratio =
        ls_wc_interval_metrics-reversed_p99_median_ratio.
      <ls_summary>-exec_nonrev_p99_secs =
        ls_wc_interval_metrics-nonrev_p99_seconds.
      <ls_summary>-exec_reversed_p99_secs =
        ls_wc_interval_metrics-reversed_p99_seconds.
      <ls_summary>-exec_nonrev_iqr_secs =
        ls_wc_interval_metrics-nonrev_iqr_seconds.
      <ls_summary>-exec_nonrev_p25_secs =
        ls_wc_interval_metrics-nonrev_p25_seconds.
      <ls_summary>-exec_nonrev_p75_secs =
        ls_wc_interval_metrics-nonrev_p75_seconds.
      <ls_summary>-exec_reversed_p25_secs =
        ls_wc_interval_metrics-reversed_p25_seconds.
      <ls_summary>-exec_reversed_p75_secs =
        ls_wc_interval_metrics-reversed_p75_seconds.
      <ls_summary>-exec_reversed_iqr_secs =
        ls_wc_interval_metrics-reversed_iqr_seconds.
      <ls_summary>-exec_duration_iqr_median_ratio =
        ls_wc_interval_metrics-duration_iqr_median_ratio.
      <ls_summary>-exec_nonrev_iqr_median_ratio =
        ls_wc_interval_metrics-nonrev_iqr_median_ratio.
      <ls_summary>-exec_reversed_iqr_median_ratio =
        ls_wc_interval_metrics-reversed_iqr_median_ratio.
      <ls_summary>-exec_nonrev_mad_secs =
        ls_wc_interval_metrics-nonrev_mad_seconds.
      <ls_summary>-exec_reversed_mad_secs =
        ls_wc_interval_metrics-reversed_mad_seconds.
      <ls_summary>-exec_duration_mad_median_ratio =
        ls_wc_interval_metrics-duration_mad_median_ratio.
      <ls_summary>-exec_nonrev_mad_median_ratio =
        ls_wc_interval_metrics-nonrev_mad_median_ratio.
      <ls_summary>-exec_reversed_mad_median_ratio =
        ls_wc_interval_metrics-reversed_mad_median_ratio.
      <ls_summary>-exec_duration_avg_median_ratio =
        ls_wc_interval_metrics-duration_avg_median_ratio.
      <ls_summary>-exec_nonrev_avg_median_ratio =
        ls_wc_interval_metrics-nonrev_avg_median_ratio.
      <ls_summary>-exec_reversed_avg_median_ratio =
        ls_wc_interval_metrics-reversed_avg_median_ratio.
      <ls_summary>-exec_pos_duration_count =
        ls_wc_interval_metrics-positive_duration_count.
      <ls_summary>-exec_pos_median_secs =
        ls_wc_interval_metrics-positive_median_secs.
      <ls_summary>-exec_pos_p90_secs =
        ls_wc_interval_metrics-positive_p90_secs.
      <ls_summary>-exec_nonrev_pos_count =
        ls_wc_interval_metrics-nonrev_positive_count.
      <ls_summary>-exec_nonrev_pos_median_secs =
        ls_wc_interval_metrics-nonrev_positive_median_secs.
      <ls_summary>-exec_nonrev_pos_p90_secs =
        ls_wc_interval_metrics-nonrev_positive_p90_secs.
      <ls_summary>-exec_reversed_pos_count =
        ls_wc_interval_metrics-reversed_positive_count.
      <ls_summary>-exec_pos_duration_pct =
        ls_wc_interval_metrics-positive_pct.
      <ls_summary>-exec_nonrev_pos_duration_pct =
        ls_wc_interval_metrics-nonrev_pos_pct.
      <ls_summary>-exec_reversed_pos_duration_pct =
        ls_wc_interval_metrics-rev_pos_pct.
      <ls_summary>-exec_pos_valid_pct =
        ls_wc_interval_metrics-pos_valid_pct.
      <ls_summary>-exec_nonrev_pos_valid_pct =
        ls_wc_interval_metrics-nonrev_pos_valid_pct.
      <ls_summary>-exec_rev_pos_valid_pct =
        ls_wc_interval_metrics-rev_pos_valid_pct.
      <ls_summary>-exec_zero_valid_pct =
        ls_wc_interval_metrics-zero_valid_pct.
      <ls_summary>-exec_nonrev_zero_valid_pct =
        ls_wc_interval_metrics-nonrev_zero_valid_pct.
      <ls_summary>-exec_rev_zero_valid_pct =
        ls_wc_interval_metrics-rev_zero_valid_pct.
      <ls_summary>-exec_zero_valid_count =
        ls_wc_interval_metrics-zero_valid_count.
      <ls_summary>-exec_nonrev_zero_valid_count =
        ls_wc_interval_metrics-nonrev_zero_valid_count.
      <ls_summary>-exec_rev_zero_valid_count =
        ls_wc_interval_metrics-rev_zero_valid_count.
      <ls_summary>-exec_nonrev_invalid_count =
        ls_wc_interval_metrics-nonrev_invalid_count.
      <ls_summary>-exec_rev_invalid_count =
        ls_wc_interval_metrics-rev_invalid_count.
      <ls_summary>-exec_nonrev_missing_count =
        ls_wc_interval_metrics-nonrev_missing_count.
      <ls_summary>-exec_rev_missing_count =
        ls_wc_interval_metrics-rev_missing_count.
      <ls_summary>-exec_nonrev_valid_pct =
        ls_wc_interval_metrics-nonrev_valid_pct.
      <ls_summary>-exec_rev_valid_pct =
        ls_wc_interval_metrics-rev_valid_pct.
      <ls_summary>-exec_nonrev_invalid_pct =
        ls_wc_interval_metrics-nonrev_invalid_pct.
      <ls_summary>-exec_rev_invalid_pct =
        ls_wc_interval_metrics-rev_invalid_pct.
      <ls_summary>-exec_nonrev_missing_pct =
        ls_wc_interval_metrics-nonrev_missing_pct.
      <ls_summary>-exec_rev_missing_pct =
        ls_wc_interval_metrics-rev_missing_pct.
      <ls_summary>-exec_top_issue_code =
        ls_wc_interval_metrics-top_issue_code.
      <ls_summary>-exec_top_issue_status =
        ls_wc_interval_metrics-top_issue_status.
      <ls_summary>-exec_top_issue_count =
        ls_wc_interval_metrics-top_issue_count.
      <ls_summary>-exec_top_issue_pct =
        ls_wc_interval_metrics-top_issue_pct.
      <ls_summary>-exec_top_invalid_issue_code =
        ls_wc_interval_metrics-top_invalid_issue_code.
      <ls_summary>-exec_top_invalid_issue_count =
        ls_wc_interval_metrics-top_invalid_issue_count.
      <ls_summary>-exec_top_invalid_share_pct =
        ls_wc_interval_metrics-top_invalid_share_pct.
      <ls_summary>-exec_top_missing_issue_code =
        ls_wc_interval_metrics-top_missing_issue_code.
      <ls_summary>-exec_top_missing_issue_count =
        ls_wc_interval_metrics-top_missing_issue_count.
      <ls_summary>-exec_top_missing_share_pct =
        ls_wc_interval_metrics-top_missing_share_pct.
      <ls_summary>-exec_top_nonrev_issue_code =
        ls_wc_interval_metrics-top_nonrev_issue_code.
      <ls_summary>-exec_top_nonrev_issue_status =
        ls_wc_interval_metrics-top_nonrev_issue_status.
      <ls_summary>-exec_top_nonrev_issue_count =
        ls_wc_interval_metrics-top_nonrev_issue_count.
      <ls_summary>-exec_top_nonrev_issue_pct =
        ls_wc_interval_metrics-top_nonrev_issue_pct.
      <ls_summary>-exec_top_reversed_issue_code =
        ls_wc_interval_metrics-top_reversed_issue_code.
      <ls_summary>-exec_top_reversed_issue_status =
        ls_wc_interval_metrics-top_reversed_issue_status.
      <ls_summary>-exec_top_reversed_issue_count =
        ls_wc_interval_metrics-top_reversed_issue_count.
      <ls_summary>-exec_top_reversed_issue_pct =
        ls_wc_interval_metrics-top_reversed_issue_pct.
      <ls_summary>-exec_duration_issue_counts =
        ls_wc_interval_metrics-issue_counts.
      <ls_summary>-exec_reversed_pos_median_secs =
        ls_wc_interval_metrics-reversed_positive_median_secs.
      <ls_summary>-exec_reversed_pos_p90_secs =
        ls_wc_interval_metrics-reversed_positive_p90_secs.
      <ls_summary>-exec_pos_p90_med_ratio =
        ls_wc_interval_metrics-pos_p90_med_ratio.
      <ls_summary>-exec_nonrev_pos_p90_med_ratio =
        ls_wc_interval_metrics-nonrev_pos_p90_med_ratio.
      <ls_summary>-exec_rev_pos_p90_med_ratio =
        ls_wc_interval_metrics-reversed_pos_p90_med_ratio.
      <ls_summary>-exec_pos_p90_gt_count =
        ls_wc_interval_metrics-pos_p90_gt_count.
      <ls_summary>-exec_pos_p90_gt_pct =
        ls_wc_interval_metrics-pos_p90_gt_pct.
      <ls_summary>-exec_pos_p90_tail_secs =
        ls_wc_interval_metrics-pos_p90_tail_secs.
      <ls_summary>-exec_pos_p90_tail_pct =
        ls_wc_interval_metrics-pos_p90_tail_pct.
      <ls_summary>-exec_nonrev_pos_p90_gt_count =
        ls_wc_interval_metrics-nonrev_pos_p90_gt_count.
      <ls_summary>-exec_nonrev_pos_p90_gt_pct =
        ls_wc_interval_metrics-nonrev_pos_p90_gt_pct.
      <ls_summary>-exec_nonrev_pos_p90_tail_secs =
        ls_wc_interval_metrics-nonrev_pos_p90_tail_secs.
      <ls_summary>-exec_nonrev_pos_p90_tail_pct =
        ls_wc_interval_metrics-nonrev_pos_p90_tail_pct.
      <ls_summary>-exec_rev_pos_p90_gt_count =
        ls_wc_interval_metrics-rev_pos_p90_gt_count.
      <ls_summary>-exec_rev_pos_p90_gt_pct =
        ls_wc_interval_metrics-rev_pos_p90_gt_pct.
      <ls_summary>-exec_rev_pos_p90_tail_secs =
        ls_wc_interval_metrics-rev_pos_p90_tail_secs.
      <ls_summary>-exec_rev_pos_p90_tail_pct =
        ls_wc_interval_metrics-rev_pos_p90_tail_pct.
      <ls_summary>-exec_pos_p95_secs =
        ls_wc_interval_metrics-positive_p95_secs.
      <ls_summary>-exec_pos_p99_secs =
        ls_wc_interval_metrics-positive_p99_secs.
      <ls_summary>-exec_nonrev_pos_p95_secs =
        ls_wc_interval_metrics-nonrev_positive_p95_secs.
      <ls_summary>-exec_nonrev_pos_p99_secs =
        ls_wc_interval_metrics-nonrev_positive_p99_secs.
      <ls_summary>-exec_rev_pos_p95_secs =
        ls_wc_interval_metrics-reversed_positive_p95_secs.
      <ls_summary>-exec_rev_pos_p99_secs =
        ls_wc_interval_metrics-reversed_positive_p99_secs.
      <ls_summary>-exec_pos_p25_secs =
        ls_wc_interval_metrics-positive_p25_secs.
      <ls_summary>-exec_pos_p75_secs =
        ls_wc_interval_metrics-positive_p75_secs.
      <ls_summary>-exec_nonrev_pos_p25_secs =
        ls_wc_interval_metrics-nonrev_positive_p25_secs.
      <ls_summary>-exec_nonrev_pos_p75_secs =
        ls_wc_interval_metrics-nonrev_positive_p75_secs.
      <ls_summary>-exec_rev_pos_p25_secs =
        ls_wc_interval_metrics-reversed_positive_p25_secs.
      <ls_summary>-exec_rev_pos_p75_secs =
        ls_wc_interval_metrics-reversed_positive_p75_secs.
      <ls_summary>-exec_pos_iqr_secs =
        ls_wc_interval_metrics-positive_iqr_secs.
      <ls_summary>-exec_nonrev_pos_iqr_secs =
        ls_wc_interval_metrics-nonrev_positive_iqr_secs.
      <ls_summary>-exec_rev_pos_iqr_secs =
        ls_wc_interval_metrics-reversed_positive_iqr_secs.
      <ls_summary>-exec_pos_mad_secs =
        ls_wc_interval_metrics-positive_mad_secs.
      <ls_summary>-exec_nonrev_pos_mad_secs =
        ls_wc_interval_metrics-nonrev_positive_mad_secs.
      <ls_summary>-exec_rev_pos_mad_secs =
        ls_wc_interval_metrics-reversed_positive_mad_secs.
      <ls_summary>-exec_pos_iqr_med_ratio =
        ls_wc_interval_metrics-positive_iqr_med_ratio.
      <ls_summary>-exec_nonrev_pos_iqr_med_ratio =
        ls_wc_interval_metrics-nonrev_positive_iqr_med_ratio.
      <ls_summary>-exec_rev_pos_iqr_med_ratio =
        ls_wc_interval_metrics-reversed_pos_iqr_med_ratio.
      <ls_summary>-exec_pos_mad_med_ratio =
        ls_wc_interval_metrics-positive_mad_med_ratio.
      <ls_summary>-exec_nonrev_pos_mad_med_ratio =
        ls_wc_interval_metrics-nonrev_positive_mad_med_ratio.
      <ls_summary>-exec_rev_pos_mad_med_ratio =
        ls_wc_interval_metrics-reversed_pos_mad_med_ratio.
      <ls_summary>-exec_pos_avg_secs =
        ls_wc_interval_metrics-pos_avg_secs.
      <ls_summary>-exec_nonrev_pos_avg_secs =
        ls_wc_interval_metrics-nonrev_pos_avg_secs.
      <ls_summary>-exec_rev_pos_avg_secs =
        ls_wc_interval_metrics-rev_pos_avg_secs.
      <ls_summary>-exec_pos_avg_med_ratio =
        ls_wc_interval_metrics-pos_avg_med_ratio.
      <ls_summary>-exec_nonrev_pos_avg_med_ratio =
        ls_wc_interval_metrics-nonrev_pos_avg_med_ratio.
      <ls_summary>-exec_rev_pos_avg_med_ratio =
        ls_wc_interval_metrics-rev_pos_avg_med_ratio.
      <ls_summary>-exec_pos_min_secs =
        ls_wc_interval_metrics-positive_min_secs.
      <ls_summary>-exec_pos_max_secs =
        ls_wc_interval_metrics-positive_max_secs.
      <ls_summary>-exec_pos_range_secs =
        ls_wc_interval_metrics-positive_range_secs.
      <ls_summary>-exec_nonrev_pos_min_secs =
        ls_wc_interval_metrics-nonrev_positive_min_secs.
      <ls_summary>-exec_nonrev_pos_max_secs =
        ls_wc_interval_metrics-nonrev_positive_max_secs.
      <ls_summary>-exec_nonrev_pos_range_secs =
        ls_wc_interval_metrics-nonrev_positive_range_secs.
      <ls_summary>-exec_rev_pos_min_secs =
        ls_wc_interval_metrics-reversed_positive_min_secs.
      <ls_summary>-exec_rev_pos_max_secs =
        ls_wc_interval_metrics-reversed_positive_max_secs.
      <ls_summary>-exec_rev_pos_range_secs =
        ls_wc_interval_metrics-reversed_positive_range_secs.
      <ls_summary>-exec_pos_p95_gt_count =
        ls_wc_interval_metrics-pos_p95_gt_count.
      <ls_summary>-exec_pos_p95_gt_pct =
        ls_wc_interval_metrics-pos_p95_gt_pct.
      <ls_summary>-exec_pos_p95_tail_secs =
        ls_wc_interval_metrics-pos_p95_tail_secs.
      <ls_summary>-exec_pos_p95_tail_pct =
        ls_wc_interval_metrics-pos_p95_tail_pct.
      <ls_summary>-exec_nonrev_pos_p95_gt_count =
        ls_wc_interval_metrics-nonrev_pos_p95_gt_count.
      <ls_summary>-exec_nonrev_pos_p95_gt_pct =
        ls_wc_interval_metrics-nonrev_pos_p95_gt_pct.
      <ls_summary>-exec_nonrev_pos_p95_tail_secs =
        ls_wc_interval_metrics-nonrev_pos_p95_tail_secs.
      <ls_summary>-exec_nonrev_pos_p95_tail_pct =
        ls_wc_interval_metrics-nonrev_pos_p95_tail_pct.
      <ls_summary>-exec_rev_pos_p95_gt_count =
        ls_wc_interval_metrics-rev_pos_p95_gt_count.
      <ls_summary>-exec_rev_pos_p95_gt_pct =
        ls_wc_interval_metrics-rev_pos_p95_gt_pct.
      <ls_summary>-exec_rev_pos_p95_tail_secs =
        ls_wc_interval_metrics-rev_pos_p95_tail_secs.
      <ls_summary>-exec_rev_pos_p95_tail_pct =
        ls_wc_interval_metrics-rev_pos_p95_tail_pct.
      <ls_summary>-exec_pos_p99_gt_count =
        ls_wc_interval_metrics-pos_p99_gt_count.
      <ls_summary>-exec_pos_p99_gt_pct =
        ls_wc_interval_metrics-pos_p99_gt_pct.
      <ls_summary>-exec_pos_p99_tail_secs =
        ls_wc_interval_metrics-pos_p99_tail_secs.
      <ls_summary>-exec_pos_p99_tail_pct =
        ls_wc_interval_metrics-pos_p99_tail_pct.
      <ls_summary>-exec_nonrev_pos_p99_gt_count =
        ls_wc_interval_metrics-nonrev_pos_p99_gt_count.
      <ls_summary>-exec_nonrev_pos_p99_gt_pct =
        ls_wc_interval_metrics-nonrev_pos_p99_gt_pct.
      <ls_summary>-exec_nonrev_pos_p99_tail_secs =
        ls_wc_interval_metrics-nonrev_pos_p99_tail_secs.
      <ls_summary>-exec_nonrev_pos_p99_tail_pct =
        ls_wc_interval_metrics-nonrev_pos_p99_tail_pct.
      <ls_summary>-exec_rev_pos_p99_gt_count =
        ls_wc_interval_metrics-rev_pos_p99_gt_count.
      <ls_summary>-exec_rev_pos_p99_gt_pct =
        ls_wc_interval_metrics-rev_pos_p99_gt_pct.
      <ls_summary>-exec_rev_pos_p99_tail_secs =
        ls_wc_interval_metrics-rev_pos_p99_tail_secs.
      <ls_summary>-exec_rev_pos_p99_tail_pct =
        ls_wc_interval_metrics-rev_pos_p99_tail_pct.
      <ls_summary>-exec_pos_p95_med_ratio =
        ls_wc_interval_metrics-pos_p95_med_ratio.
      <ls_summary>-exec_nonrev_pos_p95_med_ratio =
        ls_wc_interval_metrics-nonrev_pos_p95_med_ratio.
      <ls_summary>-exec_rev_pos_p95_med_ratio =
        ls_wc_interval_metrics-rev_pos_p95_med_ratio.
      <ls_summary>-exec_pos_p99_med_ratio =
        ls_wc_interval_metrics-pos_p99_med_ratio.
      <ls_summary>-exec_nonrev_pos_p99_med_ratio =
        ls_wc_interval_metrics-nonrev_pos_p99_med_ratio.
      <ls_summary>-exec_rev_pos_p99_med_ratio =
        ls_wc_interval_metrics-rev_pos_p99_med_ratio.
      <ls_summary>-exec_nonrev_covered_secs =
        ls_wc_interval_metrics-nonrev_covered_seconds.
      <ls_summary>-exec_nonrev_duration_count =
        ls_wc_interval_metrics-nonrev_duration_count.
      <ls_summary>-exec_nonrev_total_secs =
        ls_wc_interval_metrics-nonrev_duration_total.
      <ls_summary>-exec_nonrev_duration_avg_secs =
        ls_wc_interval_metrics-nonrev_duration_avg_secs.
      <ls_summary>-exec_nonrev_excess_secs =
        ls_wc_interval_metrics-nonrev_excess_secs.
      <ls_summary>-exec_reversed_duration_count =
        ls_wc_interval_metrics-reversed_duration_count.
      <ls_summary>-exec_reversed_total_secs =
        ls_wc_interval_metrics-reversed_duration_total.
      <ls_summary>-exec_rev_duration_avg_secs =
        ls_wc_interval_metrics-reversed_avg_secs.
      <ls_summary>-exec_reversed_covered_secs =
        ls_wc_interval_metrics-reversed_covered_seconds.
      <ls_summary>-exec_reversed_excess_secs =
        ls_wc_interval_metrics-reversed_excess_secs.
      <ls_summary>-exec_nonrev_duration_pct =
        ls_wc_interval_metrics-nonrev_duration_pct.
      <ls_summary>-exec_reversed_duration_pct =
        ls_wc_interval_metrics-reversed_duration_pct.
      <ls_summary>-exec_single_active_seconds =
        ls_wc_interval_metrics-single_active_seconds.
      <ls_summary>-exec_single_episode_count =
        ls_wc_interval_metrics-single_episode_count.
      <ls_summary>-exec_longest_single_secs =
        ls_wc_interval_metrics-longest_single_secs.
      <ls_summary>-exec_single_active_avg_secs =
        ls_wc_interval_metrics-single_active_avg_secs.
      <ls_summary>-exec_high_concurrency_secs =
        ls_wc_interval_metrics-high_concurrency_seconds.
      <ls_summary>-exec_exactly_two_secs =
        ls_wc_interval_metrics-exactly_two_seconds.
      <ls_summary>-exec_exactly_two_pct =
        ls_wc_interval_metrics-exactly_two_pct.
      <ls_summary>-exec_3plus_episode_count =
        ls_wc_interval_metrics-three_plus_episode_count.
      <ls_summary>-exec_longest_3plus_secs =
        ls_wc_interval_metrics-longest_three_plus_secs.
      <ls_summary>-exec_3plus_avg_secs =
        ls_wc_interval_metrics-three_plus_avg_secs.
      <ls_summary>-exec_3plus_pct =
        ls_wc_interval_metrics-three_plus_pct.
      <ls_summary>-exec_overlap_excess_seconds =
        ls_wc_interval_metrics-overlap_excess_seconds.
      <ls_summary>-exec_peak_concurrency =
        ls_wc_interval_metrics-peak_concurrency.
      <ls_summary>-exec_idle_gap_seconds =
        ls_wc_interval_metrics-idle_gap_seconds.
      <ls_summary>-exec_idle_gap_episode_count =
        ls_wc_interval_metrics-idle_gap_episode_count.
      <ls_summary>-exec_idle_gap_avg_secs =
        ls_wc_interval_metrics-idle_gap_avg_secs.
      <ls_summary>-exec_interval_coverage_pct =
        ls_wc_interval_metrics-interval_coverage_pct.
      <ls_summary>-exec_single_active_pct =
        ls_wc_interval_metrics-single_active_pct.
      <ls_summary>-exec_overlap_wall_pct =
        ls_wc_interval_metrics-overlap_wall_pct.
      <ls_summary>-exec_longest_idle_gap_secs =
        ls_wc_interval_metrics-longest_idle_gap_secs.
      <ls_summary>-exec_overlap_wall_seconds =
        ls_wc_interval_metrics-overlap_wall_seconds.
      <ls_summary>-exec_pairwise_overlap_secs =
        ls_wc_interval_metrics-pairwise_overlap_seconds.
      <ls_summary>-exec_overlap_episode_count =
        ls_wc_interval_metrics-overlap_episode_count.
      <ls_summary>-exec_overlap_pair_count =
        ls_wc_interval_metrics-overlap_pair_count.
      <ls_summary>-exec_overlap_pair_avg_secs =
        ls_wc_interval_metrics-overlap_pair_avg_secs.
      <ls_summary>-exec_longest_pair_overlap_secs =
        ls_wc_interval_metrics-longest_pair_overlap_secs.
      <ls_summary>-exec_peak_concurrency_secs =
        ls_wc_interval_metrics-peak_seconds.
      <ls_summary>-exec_peak_concurrency_pct =
        ls_wc_interval_metrics-peak_concurrency_pct.
      <ls_summary>-exec_peak_episode_count =
        ls_wc_interval_metrics-peak_episode_count.
      <ls_summary>-exec_longest_peak_secs =
        ls_wc_interval_metrics-longest_peak_secs.
      <ls_summary>-exec_peak_episode_avg_secs =
        ls_wc_interval_metrics-peak_episode_avg_secs.
      <ls_summary>-exec_avg_concurrency =
        ls_wc_interval_metrics-avg_concurrency.
      <ls_summary>-exec_longest_overlap_secs =
        ls_wc_interval_metrics-longest_overlap_secs.
      <ls_summary>-exec_overlap_avg_secs =
        ls_wc_interval_metrics-overlap_avg_secs.
      DATA(ls_percentages) = calculate_conf_percentages(
        iv_confirmation_count = <ls_summary>-confirmation_count
        iv_final_count        = <ls_summary>-final_confirmation_count
        iv_partial_count      = <ls_summary>-partial_confirmation_count
        iv_reversed_count     = <ls_summary>-reversed_confirmation_count ).
      <ls_summary>-final_confirmation_pct =
        ls_percentages-final_confirmation_pct.
      <ls_summary>-partial_confirmation_pct =
        ls_percentages-partial_confirmation_pct.
      <ls_summary>-reversed_confirmation_pct =
        ls_percentages-reversed_confirmation_pct.

      LOOP AT <ls_summary>-quantity_summaries
          ASSIGNING <ls_quantity_summary>.
        DATA(ls_unit_exec_pct) =
          calc_exec_coverage_pct(
            iv_confirmation_count     =
              <ls_quantity_summary>-confirmation_count
            iv_execution_start_count  =
              <ls_quantity_summary>-execution_start_count
            iv_execution_finish_count =
              <ls_quantity_summary>-execution_finish_count
            iv_duration_count         =
              <ls_quantity_summary>-exec_duration_count
            iv_zero_duration_count    =
              <ls_quantity_summary>-zero_exec_duration_count
            iv_invalid_duration_count =
              <ls_quantity_summary>-invalid_exec_duration_count ).
        <ls_quantity_summary>-execution_start_pct =
          ls_unit_exec_pct-execution_start_pct.
        <ls_quantity_summary>-execution_finish_pct =
          ls_unit_exec_pct-execution_finish_pct.
        <ls_quantity_summary>-valid_exec_duration_pct =
          ls_unit_exec_pct-valid_exec_duration_pct.
        <ls_quantity_summary>-invalid_exec_duration_pct =
          ls_unit_exec_pct-invalid_exec_duration_pct.
        <ls_quantity_summary>-missing_exec_duration_count =
          ls_unit_exec_pct-missing_exec_duration_count.
        <ls_quantity_summary>-missing_exec_duration_pct =
          ls_unit_exec_pct-missing_exec_duration_pct.
        <ls_quantity_summary>-zero_exec_duration_count =
          ls_unit_exec_pct-zero_exec_duration_count.
        <ls_quantity_summary>-zero_exec_duration_pct =
          ls_unit_exec_pct-zero_exec_duration_pct.
        <ls_quantity_summary>-exec_duration_seconds_avg =
          calc_exec_duration_avg(
            iv_duration_count         =
              <ls_quantity_summary>-exec_duration_count
            iv_duration_seconds_total =
              <ls_quantity_summary>-exec_duration_seconds_total ).
        DATA(ls_unit_interval_metrics) = calc_exec_interval_metrics(
            it_confirmations     = it_confirmations
            iv_work_center       = <ls_summary>-work_center
            iv_work_center_plant = <ls_summary>-work_center_plant
            iv_quantity_unit     = <ls_quantity_summary>-quantity_unit ).
        <ls_quantity_summary>-exec_covered_seconds =
          ls_unit_interval_metrics-covered_seconds.
        <ls_quantity_summary>-exec_duration_seconds_median =
          ls_unit_interval_metrics-duration_median_seconds.

        <ls_quantity_summary>-exec_duration_seconds_p90 =
          ls_unit_interval_metrics-duration_p90_seconds.
        <ls_quantity_summary>-exec_duration_seconds_p95 =
          ls_unit_interval_metrics-duration_p95_seconds.
        <ls_quantity_summary>-exec_duration_seconds_p99 =
          ls_unit_interval_metrics-duration_p99_seconds.
        <ls_quantity_summary>-exec_duration_seconds_p25 =
          ls_unit_interval_metrics-duration_p25_seconds.
        <ls_quantity_summary>-exec_duration_seconds_p75 =
          ls_unit_interval_metrics-duration_p75_seconds.
        <ls_quantity_summary>-exec_duration_seconds_iqr =
          ls_unit_interval_metrics-duration_iqr_seconds.
        <ls_quantity_summary>-exec_duration_seconds_mad =
          ls_unit_interval_metrics-duration_mad_seconds.
        <ls_quantity_summary>-exec_nonrev_min_secs =
          ls_unit_interval_metrics-nonrev_min_seconds.
        <ls_quantity_summary>-exec_nonrev_max_secs =
          ls_unit_interval_metrics-nonrev_max_seconds.
        <ls_quantity_summary>-exec_reversed_min_secs =
          ls_unit_interval_metrics-reversed_min_seconds.
        <ls_quantity_summary>-exec_reversed_max_secs =
          ls_unit_interval_metrics-reversed_max_seconds.
        <ls_quantity_summary>-exec_nonrev_median_secs =
          ls_unit_interval_metrics-nonrev_duration_median_secs.
        <ls_quantity_summary>-exec_reversed_median_secs =
          ls_unit_interval_metrics-reversed_duration_median_secs.
        <ls_quantity_summary>-exec_nonrev_p90_secs =
          ls_unit_interval_metrics-nonrev_p90_seconds.
        <ls_quantity_summary>-exec_reversed_p90_secs =
          ls_unit_interval_metrics-reversed_p90_seconds.
        <ls_quantity_summary>-exec_duration_p90_median_ratio =
          ls_unit_interval_metrics-duration_p90_median_ratio.
        <ls_quantity_summary>-exec_nonrev_p90_median_ratio =
          ls_unit_interval_metrics-nonrev_p90_median_ratio.
        <ls_quantity_summary>-exec_reversed_p90_median_ratio =
          ls_unit_interval_metrics-reversed_p90_median_ratio.
        <ls_quantity_summary>-exec_duration_p90_exceed_count =
          ls_unit_interval_metrics-duration_p90_exceed_count.
        <ls_quantity_summary>-exec_duration_p90_exceed_pct =
          ls_unit_interval_metrics-duration_p90_exceed_pct.
        <ls_quantity_summary>-exec_nonrev_p90_exceed_count =
          ls_unit_interval_metrics-nonrev_p90_exceed_count.
        <ls_quantity_summary>-exec_nonrev_p90_exceed_pct =
          ls_unit_interval_metrics-nonrev_p90_exceed_pct.
        <ls_quantity_summary>-exec_reversed_p90_exceed_count =
          ls_unit_interval_metrics-reversed_p90_exceed_count.
        <ls_quantity_summary>-exec_reversed_p90_exceed_pct =
          ls_unit_interval_metrics-reversed_p90_exceed_pct.
        <ls_quantity_summary>-exec_p90_tail_secs =
          ls_unit_interval_metrics-p90_tail_secs.
        <ls_quantity_summary>-exec_p90_tail_pct =
          ls_unit_interval_metrics-p90_tail_pct.
        <ls_quantity_summary>-exec_nonrev_p90_tail_secs =
          ls_unit_interval_metrics-nonrev_p90_tail_secs.
        <ls_quantity_summary>-exec_nonrev_p90_tail_pct =
          ls_unit_interval_metrics-nonrev_p90_tail_pct.
        <ls_quantity_summary>-exec_reversed_p90_tail_secs =
          ls_unit_interval_metrics-reversed_p90_tail_secs.
        <ls_quantity_summary>-exec_reversed_p90_tail_pct =
          ls_unit_interval_metrics-reversed_p90_tail_pct.
        <ls_quantity_summary>-exec_nonrev_p95_secs =
          ls_unit_interval_metrics-nonrev_p95_seconds.
        <ls_quantity_summary>-exec_reversed_p95_secs =
          ls_unit_interval_metrics-reversed_p95_seconds.
        <ls_quantity_summary>-exec_duration_p95_median_ratio =
          ls_unit_interval_metrics-duration_p95_median_ratio.
        <ls_quantity_summary>-exec_nonrev_p95_median_ratio =
          ls_unit_interval_metrics-nonrev_p95_median_ratio.
        <ls_quantity_summary>-exec_reversed_p95_median_ratio =
          ls_unit_interval_metrics-reversed_p95_median_ratio.
        <ls_quantity_summary>-exec_duration_p95_exceed_count =
          ls_unit_interval_metrics-duration_p95_exceed_count.
        <ls_quantity_summary>-exec_duration_p95_exceed_pct =
          ls_unit_interval_metrics-duration_p95_exceed_pct.
        <ls_quantity_summary>-exec_nonrev_p95_exceed_count =
          ls_unit_interval_metrics-nonrev_p95_exceed_count.
        <ls_quantity_summary>-exec_nonrev_p95_exceed_pct =
          ls_unit_interval_metrics-nonrev_p95_exceed_pct.
        <ls_quantity_summary>-exec_reversed_p95_exceed_count =
          ls_unit_interval_metrics-reversed_p95_exceed_count.
        <ls_quantity_summary>-exec_reversed_p95_exceed_pct =
          ls_unit_interval_metrics-reversed_p95_exceed_pct.
        <ls_quantity_summary>-exec_p95_tail_secs =
          ls_unit_interval_metrics-p95_tail_secs.
        <ls_quantity_summary>-exec_p95_tail_pct =
          ls_unit_interval_metrics-p95_tail_pct.
        <ls_quantity_summary>-exec_nonrev_p95_tail_secs =
          ls_unit_interval_metrics-nonrev_p95_tail_secs.
        <ls_quantity_summary>-exec_nonrev_p95_tail_pct =
          ls_unit_interval_metrics-nonrev_p95_tail_pct.
        <ls_quantity_summary>-exec_reversed_p95_tail_secs =
          ls_unit_interval_metrics-reversed_p95_tail_secs.
        <ls_quantity_summary>-exec_reversed_p95_tail_pct =
          ls_unit_interval_metrics-reversed_p95_tail_pct.
        <ls_quantity_summary>-exec_duration_p99_exceed_count =
          ls_unit_interval_metrics-duration_p99_exceed_count.
        <ls_quantity_summary>-exec_duration_p99_exceed_pct =
          ls_unit_interval_metrics-duration_p99_exceed_pct.
        <ls_quantity_summary>-exec_nonrev_p99_exceed_count =
          ls_unit_interval_metrics-nonrev_p99_exceed_count.
        <ls_quantity_summary>-exec_nonrev_p99_exceed_pct =
          ls_unit_interval_metrics-nonrev_p99_exceed_pct.
        <ls_quantity_summary>-exec_reversed_p99_exceed_count =
          ls_unit_interval_metrics-reversed_p99_exceed_count.
        <ls_quantity_summary>-exec_reversed_p99_exceed_pct =
          ls_unit_interval_metrics-reversed_p99_exceed_pct.
        <ls_quantity_summary>-exec_p99_tail_secs =
          ls_unit_interval_metrics-p99_tail_secs.
        <ls_quantity_summary>-exec_p99_tail_pct =
          ls_unit_interval_metrics-p99_tail_pct.
        <ls_quantity_summary>-exec_nonrev_p99_tail_secs =
          ls_unit_interval_metrics-nonrev_p99_tail_secs.
        <ls_quantity_summary>-exec_nonrev_p99_tail_pct =
          ls_unit_interval_metrics-nonrev_p99_tail_pct.
        <ls_quantity_summary>-exec_reversed_p99_tail_secs =
          ls_unit_interval_metrics-reversed_p99_tail_secs.
        <ls_quantity_summary>-exec_reversed_p99_tail_pct =
          ls_unit_interval_metrics-reversed_p99_tail_pct.
        <ls_quantity_summary>-exec_duration_p99_median_ratio =
          ls_unit_interval_metrics-duration_p99_median_ratio.
        <ls_quantity_summary>-exec_nonrev_p99_median_ratio =
          ls_unit_interval_metrics-nonrev_p99_median_ratio.
        <ls_quantity_summary>-exec_reversed_p99_median_ratio =
          ls_unit_interval_metrics-reversed_p99_median_ratio.
        <ls_quantity_summary>-exec_nonrev_p99_secs =
          ls_unit_interval_metrics-nonrev_p99_seconds.
        <ls_quantity_summary>-exec_reversed_p99_secs =
          ls_unit_interval_metrics-reversed_p99_seconds.
        <ls_quantity_summary>-exec_nonrev_iqr_secs =
          ls_unit_interval_metrics-nonrev_iqr_seconds.
        <ls_quantity_summary>-exec_nonrev_p25_secs =
          ls_unit_interval_metrics-nonrev_p25_seconds.
        <ls_quantity_summary>-exec_nonrev_p75_secs =
          ls_unit_interval_metrics-nonrev_p75_seconds.
        <ls_quantity_summary>-exec_reversed_p25_secs =
          ls_unit_interval_metrics-reversed_p25_seconds.
        <ls_quantity_summary>-exec_reversed_p75_secs =
          ls_unit_interval_metrics-reversed_p75_seconds.
        <ls_quantity_summary>-exec_reversed_iqr_secs =
          ls_unit_interval_metrics-reversed_iqr_seconds.
        <ls_quantity_summary>-exec_duration_iqr_median_ratio =
          ls_unit_interval_metrics-duration_iqr_median_ratio.
        <ls_quantity_summary>-exec_nonrev_iqr_median_ratio =
          ls_unit_interval_metrics-nonrev_iqr_median_ratio.
        <ls_quantity_summary>-exec_reversed_iqr_median_ratio =
          ls_unit_interval_metrics-reversed_iqr_median_ratio.
        <ls_quantity_summary>-exec_nonrev_mad_secs =
          ls_unit_interval_metrics-nonrev_mad_seconds.
        <ls_quantity_summary>-exec_reversed_mad_secs =
          ls_unit_interval_metrics-reversed_mad_seconds.
        <ls_quantity_summary>-exec_duration_mad_median_ratio =
          ls_unit_interval_metrics-duration_mad_median_ratio.
        <ls_quantity_summary>-exec_nonrev_mad_median_ratio =
          ls_unit_interval_metrics-nonrev_mad_median_ratio.
        <ls_quantity_summary>-exec_reversed_mad_median_ratio =
          ls_unit_interval_metrics-reversed_mad_median_ratio.
        <ls_quantity_summary>-exec_duration_avg_median_ratio =
          ls_unit_interval_metrics-duration_avg_median_ratio.
        <ls_quantity_summary>-exec_nonrev_avg_median_ratio =
          ls_unit_interval_metrics-nonrev_avg_median_ratio.
        <ls_quantity_summary>-exec_reversed_avg_median_ratio =
          ls_unit_interval_metrics-reversed_avg_median_ratio.
        <ls_quantity_summary>-exec_pos_duration_count =
          ls_unit_interval_metrics-positive_duration_count.
        <ls_quantity_summary>-exec_pos_median_secs =
          ls_unit_interval_metrics-positive_median_secs.
        <ls_quantity_summary>-exec_pos_p90_secs =
          ls_unit_interval_metrics-positive_p90_secs.
        <ls_quantity_summary>-exec_nonrev_pos_count =
          ls_unit_interval_metrics-nonrev_positive_count.
        <ls_quantity_summary>-exec_nonrev_pos_median_secs =
          ls_unit_interval_metrics-nonrev_positive_median_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p90_secs =
          ls_unit_interval_metrics-nonrev_positive_p90_secs.
        <ls_quantity_summary>-exec_reversed_pos_count =
          ls_unit_interval_metrics-reversed_positive_count.
        <ls_quantity_summary>-exec_pos_duration_pct =
          ls_unit_interval_metrics-positive_pct.
        <ls_quantity_summary>-exec_nonrev_pos_duration_pct =
          ls_unit_interval_metrics-nonrev_pos_pct.
        <ls_quantity_summary>-exec_reversed_pos_duration_pct =
          ls_unit_interval_metrics-rev_pos_pct.
        <ls_quantity_summary>-exec_pos_valid_pct =
          ls_unit_interval_metrics-pos_valid_pct.
        <ls_quantity_summary>-exec_nonrev_pos_valid_pct =
          ls_unit_interval_metrics-nonrev_pos_valid_pct.
        <ls_quantity_summary>-exec_rev_pos_valid_pct =
          ls_unit_interval_metrics-rev_pos_valid_pct.
        <ls_quantity_summary>-exec_zero_valid_pct =
          ls_unit_interval_metrics-zero_valid_pct.
        <ls_quantity_summary>-exec_nonrev_zero_valid_pct =
          ls_unit_interval_metrics-nonrev_zero_valid_pct.
        <ls_quantity_summary>-exec_rev_zero_valid_pct =
          ls_unit_interval_metrics-rev_zero_valid_pct.
        <ls_quantity_summary>-exec_zero_valid_count =
          ls_unit_interval_metrics-zero_valid_count.
        <ls_quantity_summary>-exec_nonrev_zero_valid_count =
          ls_unit_interval_metrics-nonrev_zero_valid_count.
        <ls_quantity_summary>-exec_rev_zero_valid_count =
          ls_unit_interval_metrics-rev_zero_valid_count.
        <ls_quantity_summary>-exec_nonrev_invalid_count =
          ls_unit_interval_metrics-nonrev_invalid_count.
        <ls_quantity_summary>-exec_rev_invalid_count =
          ls_unit_interval_metrics-rev_invalid_count.
        <ls_quantity_summary>-exec_nonrev_missing_count =
          ls_unit_interval_metrics-nonrev_missing_count.
        <ls_quantity_summary>-exec_rev_missing_count =
          ls_unit_interval_metrics-rev_missing_count.
        <ls_quantity_summary>-exec_nonrev_valid_pct =
          ls_unit_interval_metrics-nonrev_valid_pct.
        <ls_quantity_summary>-exec_rev_valid_pct =
          ls_unit_interval_metrics-rev_valid_pct.
        <ls_quantity_summary>-exec_nonrev_invalid_pct =
          ls_unit_interval_metrics-nonrev_invalid_pct.
        <ls_quantity_summary>-exec_rev_invalid_pct =
          ls_unit_interval_metrics-rev_invalid_pct.
        <ls_quantity_summary>-exec_nonrev_missing_pct =
          ls_unit_interval_metrics-nonrev_missing_pct.
        <ls_quantity_summary>-exec_rev_missing_pct =
          ls_unit_interval_metrics-rev_missing_pct.
        <ls_quantity_summary>-exec_top_issue_code =
          ls_unit_interval_metrics-top_issue_code.
        <ls_quantity_summary>-exec_top_issue_status =
          ls_unit_interval_metrics-top_issue_status.
        <ls_quantity_summary>-exec_top_issue_count =
          ls_unit_interval_metrics-top_issue_count.
        <ls_quantity_summary>-exec_top_issue_pct =
          ls_unit_interval_metrics-top_issue_pct.
        <ls_quantity_summary>-exec_top_invalid_issue_code =
          ls_unit_interval_metrics-top_invalid_issue_code.
        <ls_quantity_summary>-exec_top_invalid_issue_count =
          ls_unit_interval_metrics-top_invalid_issue_count.
        <ls_quantity_summary>-exec_top_invalid_share_pct =
          ls_unit_interval_metrics-top_invalid_share_pct.
        <ls_quantity_summary>-exec_top_missing_issue_code =
          ls_unit_interval_metrics-top_missing_issue_code.
        <ls_quantity_summary>-exec_top_missing_issue_count =
          ls_unit_interval_metrics-top_missing_issue_count.
        <ls_quantity_summary>-exec_top_missing_share_pct =
          ls_unit_interval_metrics-top_missing_share_pct.
        <ls_quantity_summary>-exec_top_nonrev_issue_code =
          ls_unit_interval_metrics-top_nonrev_issue_code.
        <ls_quantity_summary>-exec_top_nonrev_issue_status =
          ls_unit_interval_metrics-top_nonrev_issue_status.
        <ls_quantity_summary>-exec_top_nonrev_issue_count =
          ls_unit_interval_metrics-top_nonrev_issue_count.
        <ls_quantity_summary>-exec_top_nonrev_issue_pct =
          ls_unit_interval_metrics-top_nonrev_issue_pct.
        <ls_quantity_summary>-exec_top_reversed_issue_code =
          ls_unit_interval_metrics-top_reversed_issue_code.
        <ls_quantity_summary>-exec_top_reversed_issue_status =
          ls_unit_interval_metrics-top_reversed_issue_status.
        <ls_quantity_summary>-exec_top_reversed_issue_count =
          ls_unit_interval_metrics-top_reversed_issue_count.
        <ls_quantity_summary>-exec_top_reversed_issue_pct =
          ls_unit_interval_metrics-top_reversed_issue_pct.
        <ls_quantity_summary>-exec_duration_issue_counts =
          ls_unit_interval_metrics-issue_counts.
        <ls_quantity_summary>-exec_reversed_pos_median_secs =
          ls_unit_interval_metrics-reversed_positive_median_secs.
        <ls_quantity_summary>-exec_reversed_pos_p90_secs =
          ls_unit_interval_metrics-reversed_positive_p90_secs.
        <ls_quantity_summary>-exec_pos_p90_med_ratio =
          ls_unit_interval_metrics-pos_p90_med_ratio.
        <ls_quantity_summary>-exec_nonrev_pos_p90_med_ratio =
          ls_unit_interval_metrics-nonrev_pos_p90_med_ratio.
        <ls_quantity_summary>-exec_rev_pos_p90_med_ratio =
          ls_unit_interval_metrics-reversed_pos_p90_med_ratio.
        <ls_quantity_summary>-exec_pos_p90_gt_count =
          ls_unit_interval_metrics-pos_p90_gt_count.
        <ls_quantity_summary>-exec_pos_p90_gt_pct =
          ls_unit_interval_metrics-pos_p90_gt_pct.
        <ls_quantity_summary>-exec_pos_p90_tail_secs =
          ls_unit_interval_metrics-pos_p90_tail_secs.
        <ls_quantity_summary>-exec_pos_p90_tail_pct =
          ls_unit_interval_metrics-pos_p90_tail_pct.
        <ls_quantity_summary>-exec_nonrev_pos_p90_gt_count =
          ls_unit_interval_metrics-nonrev_pos_p90_gt_count.
        <ls_quantity_summary>-exec_nonrev_pos_p90_gt_pct =
          ls_unit_interval_metrics-nonrev_pos_p90_gt_pct.
        <ls_quantity_summary>-exec_nonrev_pos_p90_tail_secs =
          ls_unit_interval_metrics-nonrev_pos_p90_tail_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p90_tail_pct =
          ls_unit_interval_metrics-nonrev_pos_p90_tail_pct.
        <ls_quantity_summary>-exec_rev_pos_p90_gt_count =
          ls_unit_interval_metrics-rev_pos_p90_gt_count.
        <ls_quantity_summary>-exec_rev_pos_p90_gt_pct =
          ls_unit_interval_metrics-rev_pos_p90_gt_pct.
        <ls_quantity_summary>-exec_rev_pos_p90_tail_secs =
          ls_unit_interval_metrics-rev_pos_p90_tail_secs.
        <ls_quantity_summary>-exec_rev_pos_p90_tail_pct =
          ls_unit_interval_metrics-rev_pos_p90_tail_pct.
        <ls_quantity_summary>-exec_pos_p95_secs =
          ls_unit_interval_metrics-positive_p95_secs.
        <ls_quantity_summary>-exec_pos_p99_secs =
          ls_unit_interval_metrics-positive_p99_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p95_secs =
          ls_unit_interval_metrics-nonrev_positive_p95_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p99_secs =
          ls_unit_interval_metrics-nonrev_positive_p99_secs.
        <ls_quantity_summary>-exec_rev_pos_p95_secs =
          ls_unit_interval_metrics-reversed_positive_p95_secs.
        <ls_quantity_summary>-exec_rev_pos_p99_secs =
          ls_unit_interval_metrics-reversed_positive_p99_secs.
        <ls_quantity_summary>-exec_pos_p25_secs =
          ls_unit_interval_metrics-positive_p25_secs.
        <ls_quantity_summary>-exec_pos_p75_secs =
          ls_unit_interval_metrics-positive_p75_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p25_secs =
          ls_unit_interval_metrics-nonrev_positive_p25_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p75_secs =
          ls_unit_interval_metrics-nonrev_positive_p75_secs.
        <ls_quantity_summary>-exec_rev_pos_p25_secs =
          ls_unit_interval_metrics-reversed_positive_p25_secs.
        <ls_quantity_summary>-exec_rev_pos_p75_secs =
          ls_unit_interval_metrics-reversed_positive_p75_secs.
        <ls_quantity_summary>-exec_pos_iqr_secs =
          ls_unit_interval_metrics-positive_iqr_secs.
        <ls_quantity_summary>-exec_nonrev_pos_iqr_secs =
          ls_unit_interval_metrics-nonrev_positive_iqr_secs.
        <ls_quantity_summary>-exec_rev_pos_iqr_secs =
          ls_unit_interval_metrics-reversed_positive_iqr_secs.
        <ls_quantity_summary>-exec_pos_mad_secs =
          ls_unit_interval_metrics-positive_mad_secs.
        <ls_quantity_summary>-exec_nonrev_pos_mad_secs =
          ls_unit_interval_metrics-nonrev_positive_mad_secs.
        <ls_quantity_summary>-exec_rev_pos_mad_secs =
          ls_unit_interval_metrics-reversed_positive_mad_secs.
        <ls_quantity_summary>-exec_pos_iqr_med_ratio =
          ls_unit_interval_metrics-positive_iqr_med_ratio.
        <ls_quantity_summary>-exec_nonrev_pos_iqr_med_ratio =
          ls_unit_interval_metrics-nonrev_positive_iqr_med_ratio.
        <ls_quantity_summary>-exec_rev_pos_iqr_med_ratio =
          ls_unit_interval_metrics-reversed_pos_iqr_med_ratio.
        <ls_quantity_summary>-exec_pos_mad_med_ratio =
          ls_unit_interval_metrics-positive_mad_med_ratio.
        <ls_quantity_summary>-exec_nonrev_pos_mad_med_ratio =
          ls_unit_interval_metrics-nonrev_positive_mad_med_ratio.
        <ls_quantity_summary>-exec_rev_pos_mad_med_ratio =
          ls_unit_interval_metrics-reversed_pos_mad_med_ratio.
        <ls_quantity_summary>-exec_pos_avg_secs =
          ls_unit_interval_metrics-pos_avg_secs.
        <ls_quantity_summary>-exec_nonrev_pos_avg_secs =
          ls_unit_interval_metrics-nonrev_pos_avg_secs.
        <ls_quantity_summary>-exec_rev_pos_avg_secs =
          ls_unit_interval_metrics-rev_pos_avg_secs.
        <ls_quantity_summary>-exec_pos_avg_med_ratio =
          ls_unit_interval_metrics-pos_avg_med_ratio.
        <ls_quantity_summary>-exec_nonrev_pos_avg_med_ratio =
          ls_unit_interval_metrics-nonrev_pos_avg_med_ratio.
        <ls_quantity_summary>-exec_rev_pos_avg_med_ratio =
          ls_unit_interval_metrics-rev_pos_avg_med_ratio.
        <ls_quantity_summary>-exec_pos_min_secs =
          ls_unit_interval_metrics-positive_min_secs.
        <ls_quantity_summary>-exec_pos_max_secs =
          ls_unit_interval_metrics-positive_max_secs.
        <ls_quantity_summary>-exec_pos_range_secs =
          ls_unit_interval_metrics-positive_range_secs.
        <ls_quantity_summary>-exec_nonrev_pos_min_secs =
          ls_unit_interval_metrics-nonrev_positive_min_secs.
        <ls_quantity_summary>-exec_nonrev_pos_max_secs =
          ls_unit_interval_metrics-nonrev_positive_max_secs.
        <ls_quantity_summary>-exec_nonrev_pos_range_secs =
          ls_unit_interval_metrics-nonrev_positive_range_secs.
        <ls_quantity_summary>-exec_rev_pos_min_secs =
          ls_unit_interval_metrics-reversed_positive_min_secs.
        <ls_quantity_summary>-exec_rev_pos_max_secs =
          ls_unit_interval_metrics-reversed_positive_max_secs.
        <ls_quantity_summary>-exec_rev_pos_range_secs =
          ls_unit_interval_metrics-reversed_positive_range_secs.
        <ls_quantity_summary>-exec_pos_p95_gt_count =
          ls_unit_interval_metrics-pos_p95_gt_count.
        <ls_quantity_summary>-exec_pos_p95_gt_pct =
          ls_unit_interval_metrics-pos_p95_gt_pct.
        <ls_quantity_summary>-exec_pos_p95_tail_secs =
          ls_unit_interval_metrics-pos_p95_tail_secs.
        <ls_quantity_summary>-exec_pos_p95_tail_pct =
          ls_unit_interval_metrics-pos_p95_tail_pct.
        <ls_quantity_summary>-exec_nonrev_pos_p95_gt_count =
          ls_unit_interval_metrics-nonrev_pos_p95_gt_count.
        <ls_quantity_summary>-exec_nonrev_pos_p95_gt_pct =
          ls_unit_interval_metrics-nonrev_pos_p95_gt_pct.
        <ls_quantity_summary>-exec_nonrev_pos_p95_tail_secs =
          ls_unit_interval_metrics-nonrev_pos_p95_tail_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p95_tail_pct =
          ls_unit_interval_metrics-nonrev_pos_p95_tail_pct.
        <ls_quantity_summary>-exec_rev_pos_p95_gt_count =
          ls_unit_interval_metrics-rev_pos_p95_gt_count.
        <ls_quantity_summary>-exec_rev_pos_p95_gt_pct =
          ls_unit_interval_metrics-rev_pos_p95_gt_pct.
        <ls_quantity_summary>-exec_rev_pos_p95_tail_secs =
          ls_unit_interval_metrics-rev_pos_p95_tail_secs.
        <ls_quantity_summary>-exec_rev_pos_p95_tail_pct =
          ls_unit_interval_metrics-rev_pos_p95_tail_pct.
        <ls_quantity_summary>-exec_pos_p99_gt_count =
          ls_unit_interval_metrics-pos_p99_gt_count.
        <ls_quantity_summary>-exec_pos_p99_gt_pct =
          ls_unit_interval_metrics-pos_p99_gt_pct.
        <ls_quantity_summary>-exec_pos_p99_tail_secs =
          ls_unit_interval_metrics-pos_p99_tail_secs.
        <ls_quantity_summary>-exec_pos_p99_tail_pct =
          ls_unit_interval_metrics-pos_p99_tail_pct.
        <ls_quantity_summary>-exec_nonrev_pos_p99_gt_count =
          ls_unit_interval_metrics-nonrev_pos_p99_gt_count.
        <ls_quantity_summary>-exec_nonrev_pos_p99_gt_pct =
          ls_unit_interval_metrics-nonrev_pos_p99_gt_pct.
        <ls_quantity_summary>-exec_nonrev_pos_p99_tail_secs =
          ls_unit_interval_metrics-nonrev_pos_p99_tail_secs.
        <ls_quantity_summary>-exec_nonrev_pos_p99_tail_pct =
          ls_unit_interval_metrics-nonrev_pos_p99_tail_pct.
        <ls_quantity_summary>-exec_rev_pos_p99_gt_count =
          ls_unit_interval_metrics-rev_pos_p99_gt_count.
        <ls_quantity_summary>-exec_rev_pos_p99_gt_pct =
          ls_unit_interval_metrics-rev_pos_p99_gt_pct.
        <ls_quantity_summary>-exec_rev_pos_p99_tail_secs =
          ls_unit_interval_metrics-rev_pos_p99_tail_secs.
        <ls_quantity_summary>-exec_rev_pos_p99_tail_pct =
          ls_unit_interval_metrics-rev_pos_p99_tail_pct.
        <ls_quantity_summary>-exec_pos_p95_med_ratio =
          ls_unit_interval_metrics-pos_p95_med_ratio.
        <ls_quantity_summary>-exec_nonrev_pos_p95_med_ratio =
          ls_unit_interval_metrics-nonrev_pos_p95_med_ratio.
        <ls_quantity_summary>-exec_rev_pos_p95_med_ratio =
          ls_unit_interval_metrics-rev_pos_p95_med_ratio.
        <ls_quantity_summary>-exec_pos_p99_med_ratio =
          ls_unit_interval_metrics-pos_p99_med_ratio.
        <ls_quantity_summary>-exec_nonrev_pos_p99_med_ratio =
          ls_unit_interval_metrics-nonrev_pos_p99_med_ratio.
        <ls_quantity_summary>-exec_rev_pos_p99_med_ratio =
          ls_unit_interval_metrics-rev_pos_p99_med_ratio.
        <ls_quantity_summary>-exec_nonrev_covered_secs =
          ls_unit_interval_metrics-nonrev_covered_seconds.
        <ls_quantity_summary>-exec_nonrev_duration_count =
          ls_unit_interval_metrics-nonrev_duration_count.
        <ls_quantity_summary>-exec_nonrev_total_secs =
          ls_unit_interval_metrics-nonrev_duration_total.
        <ls_quantity_summary>-exec_nonrev_duration_avg_secs =
          ls_unit_interval_metrics-nonrev_duration_avg_secs.
        <ls_quantity_summary>-exec_nonrev_excess_secs =
          ls_unit_interval_metrics-nonrev_excess_secs.
        <ls_quantity_summary>-exec_reversed_duration_count =
          ls_unit_interval_metrics-reversed_duration_count.
        <ls_quantity_summary>-exec_reversed_total_secs =
          ls_unit_interval_metrics-reversed_duration_total.
        <ls_quantity_summary>-exec_rev_duration_avg_secs =
          ls_unit_interval_metrics-reversed_avg_secs.
        <ls_quantity_summary>-exec_reversed_covered_secs =
          ls_unit_interval_metrics-reversed_covered_seconds.
        <ls_quantity_summary>-exec_reversed_excess_secs =
          ls_unit_interval_metrics-reversed_excess_secs.
        <ls_quantity_summary>-exec_nonrev_duration_pct =
          ls_unit_interval_metrics-nonrev_duration_pct.
        <ls_quantity_summary>-exec_reversed_duration_pct =
          ls_unit_interval_metrics-reversed_duration_pct.
        <ls_quantity_summary>-exec_single_active_seconds =
          ls_unit_interval_metrics-single_active_seconds.
        <ls_quantity_summary>-exec_single_episode_count =
          ls_unit_interval_metrics-single_episode_count.
        <ls_quantity_summary>-exec_longest_single_secs =
          ls_unit_interval_metrics-longest_single_secs.
        <ls_quantity_summary>-exec_single_active_avg_secs =
          ls_unit_interval_metrics-single_active_avg_secs.
        <ls_quantity_summary>-exec_high_concurrency_secs =
          ls_unit_interval_metrics-high_concurrency_seconds.
        <ls_quantity_summary>-exec_exactly_two_secs =
          ls_unit_interval_metrics-exactly_two_seconds.
        <ls_quantity_summary>-exec_exactly_two_pct =
          ls_unit_interval_metrics-exactly_two_pct.
        <ls_quantity_summary>-exec_3plus_episode_count =
          ls_unit_interval_metrics-three_plus_episode_count.
        <ls_quantity_summary>-exec_longest_3plus_secs =
          ls_unit_interval_metrics-longest_three_plus_secs.
        <ls_quantity_summary>-exec_3plus_avg_secs =
          ls_unit_interval_metrics-three_plus_avg_secs.
        <ls_quantity_summary>-exec_3plus_pct =
          ls_unit_interval_metrics-three_plus_pct.
        <ls_quantity_summary>-exec_overlap_excess_seconds =
          ls_unit_interval_metrics-overlap_excess_seconds.
        <ls_quantity_summary>-exec_peak_concurrency =
          ls_unit_interval_metrics-peak_concurrency.
        <ls_quantity_summary>-exec_idle_gap_seconds =
          ls_unit_interval_metrics-idle_gap_seconds.
        <ls_quantity_summary>-exec_idle_gap_episode_count =
          ls_unit_interval_metrics-idle_gap_episode_count.
        <ls_quantity_summary>-exec_idle_gap_avg_secs =
          ls_unit_interval_metrics-idle_gap_avg_secs.
        <ls_quantity_summary>-exec_interval_coverage_pct =
          ls_unit_interval_metrics-interval_coverage_pct.
        <ls_quantity_summary>-exec_single_active_pct =
          ls_unit_interval_metrics-single_active_pct.
        <ls_quantity_summary>-exec_overlap_wall_pct =
          ls_unit_interval_metrics-overlap_wall_pct.
        <ls_quantity_summary>-exec_longest_idle_gap_secs =
          ls_unit_interval_metrics-longest_idle_gap_secs.
        <ls_quantity_summary>-exec_overlap_wall_seconds =
          ls_unit_interval_metrics-overlap_wall_seconds.
        <ls_quantity_summary>-exec_pairwise_overlap_secs =
          ls_unit_interval_metrics-pairwise_overlap_seconds.
        <ls_quantity_summary>-exec_overlap_episode_count =
          ls_unit_interval_metrics-overlap_episode_count.
        <ls_quantity_summary>-exec_overlap_pair_count =
          ls_unit_interval_metrics-overlap_pair_count.
        <ls_quantity_summary>-exec_overlap_pair_avg_secs =
          ls_unit_interval_metrics-overlap_pair_avg_secs.
        <ls_quantity_summary>-exec_longest_pair_overlap_secs =
          ls_unit_interval_metrics-longest_pair_overlap_secs.
        <ls_quantity_summary>-exec_peak_concurrency_secs =
          ls_unit_interval_metrics-peak_seconds.
        <ls_quantity_summary>-exec_peak_concurrency_pct =
          ls_unit_interval_metrics-peak_concurrency_pct.
        <ls_quantity_summary>-exec_peak_episode_count =
          ls_unit_interval_metrics-peak_episode_count.
        <ls_quantity_summary>-exec_longest_peak_secs =
          ls_unit_interval_metrics-longest_peak_secs.
        <ls_quantity_summary>-exec_peak_episode_avg_secs =
          ls_unit_interval_metrics-peak_episode_avg_secs.
        <ls_quantity_summary>-exec_avg_concurrency =
          ls_unit_interval_metrics-avg_concurrency.
        <ls_quantity_summary>-exec_longest_overlap_secs =
          ls_unit_interval_metrics-longest_overlap_secs.
        <ls_quantity_summary>-exec_overlap_avg_secs =
          ls_unit_interval_metrics-overlap_avg_secs.
        DATA(ls_quantity_percentages) = calculate_conf_percentages(
          iv_confirmation_count =
            <ls_quantity_summary>-confirmation_count
          iv_final_count        =
            <ls_quantity_summary>-final_confirmation_count
          iv_partial_count      =
            <ls_quantity_summary>-partial_confirmation_count
          iv_reversed_count     =
            <ls_quantity_summary>-reversed_confirmation_count ).
        <ls_quantity_summary>-final_confirmation_pct =
          ls_quantity_percentages-final_confirmation_pct.
        <ls_quantity_summary>-partial_confirmation_pct =
          ls_quantity_percentages-partial_confirmation_pct.
        <ls_quantity_summary>-reversed_confirmation_pct =
          ls_quantity_percentages-reversed_confirmation_pct.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_base_wc_conf_summaries.
    FIELD-SYMBOLS <ls_summary> TYPE ty_base_work_center_conf_summary.
    DATA lt_base_wc_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.

    LOOP AT it_base_quantities INTO DATA(ls_base_quantity).
      DATA(ls_confirmation) = ls_base_quantity-confirmation_row.
      READ TABLE rt_summaries ASSIGNING <ls_summary>
        WITH TABLE KEY
          work_center_plant = ls_confirmation-work_center_plant
          work_center = ls_confirmation-work_center
          base_quantity_unit = ls_base_quantity-base_quantity_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          work_center        = ls_confirmation-work_center
          work_center_plant  = ls_confirmation-work_center_plant
          base_quantity_unit = ls_base_quantity-base_quantity_unit )
          INTO TABLE rt_summaries.
        READ TABLE rt_summaries ASSIGNING <ls_summary>
          WITH TABLE KEY
            work_center_plant = ls_confirmation-work_center_plant
            work_center = ls_confirmation-work_center
            base_quantity_unit = ls_base_quantity-base_quantity_unit.
      ENDIF.

      CALL METHOD me->update_conf_execution_metrics
        EXPORTING
          is_confirmation = ls_confirmation
        CHANGING
          cv_execution_start_count       =
            <ls_summary>-execution_start_count
          cv_first_execution_start_date  =
            <ls_summary>-first_execution_start_date
          cv_first_execution_start_time  =
            <ls_summary>-first_execution_start_time
          cv_execution_finish_count      =
            <ls_summary>-execution_finish_count
          cv_last_execution_finish_date  =
            <ls_summary>-last_execution_finish_date
          cv_last_execution_finish_time  =
            <ls_summary>-last_execution_finish_time
          cv_duration_count              =
            <ls_summary>-exec_duration_count
          cv_zero_duration_count         =
            <ls_summary>-zero_exec_duration_count
          cv_invalid_duration_count      =
            <ls_summary>-invalid_exec_duration_count
          cv_duration_seconds            =
            <ls_summary>-exec_duration_seconds_total
          cv_duration_seconds_min        =
            <ls_summary>-exec_duration_seconds_min
          cv_duration_seconds_max        =
            <ls_summary>-exec_duration_seconds_max.
      IF ls_confirmation-posting_date IS NOT INITIAL.
        IF <ls_summary>-first_posting_date IS INITIAL
            OR ls_confirmation-posting_date <
              <ls_summary>-first_posting_date.
          <ls_summary>-first_posting_date = ls_confirmation-posting_date.
        ENDIF.
        IF <ls_summary>-last_posting_date IS INITIAL
            OR ls_confirmation-posting_date >
              <ls_summary>-last_posting_date.
          <ls_summary>-last_posting_date = ls_confirmation-posting_date.
        ENDIF.
      ENDIF.
      ADD 1 TO <ls_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_summary>-final_confirmation_count.
      ELSE.
        ADD 1 TO <ls_summary>-partial_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_summary>-reversed_confirmation_count.
      ENDIF.
      <ls_summary>-yield_quantity_base_total =
        <ls_summary>-yield_quantity_base_total +
        CONV decfloat34( ls_base_quantity-yield_quantity_base ).
      <ls_summary>-rework_quantity_base_total =
        <ls_summary>-rework_quantity_base_total +
        CONV decfloat34( ls_base_quantity-rework_quantity_base ).
      <ls_summary>-scrap_quantity_base_total =
        <ls_summary>-scrap_quantity_base_total +
        CONV decfloat34( ls_base_quantity-scrap_quantity_base ).
      IF ls_confirmation-is_reversed <> abap_true.
        <ls_summary>-yield_base_non_reversed_total =
          <ls_summary>-yield_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-yield_quantity_base ).
        <ls_summary>-rework_base_non_reversed_total =
          <ls_summary>-rework_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-rework_quantity_base ).
        <ls_summary>-scrap_base_non_reversed_total =
          <ls_summary>-scrap_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-scrap_quantity_base ).
      ENDIF.
    ENDLOOP.

    LOOP AT rt_summaries ASSIGNING <ls_summary>.
      DATA(ls_execution_percentages) =
        calc_exec_coverage_pct(
          iv_confirmation_count     =
            <ls_summary>-confirmation_count
          iv_execution_start_count  =
            <ls_summary>-execution_start_count
          iv_execution_finish_count =
            <ls_summary>-execution_finish_count
          iv_duration_count         =
            <ls_summary>-exec_duration_count
          iv_zero_duration_count    =
            <ls_summary>-zero_exec_duration_count
          iv_invalid_duration_count =
            <ls_summary>-invalid_exec_duration_count ).
      <ls_summary>-execution_start_pct =
        ls_execution_percentages-execution_start_pct.
      <ls_summary>-execution_finish_pct =
        ls_execution_percentages-execution_finish_pct.
      <ls_summary>-valid_exec_duration_pct =
        ls_execution_percentages-valid_exec_duration_pct.
      <ls_summary>-invalid_exec_duration_pct =
        ls_execution_percentages-invalid_exec_duration_pct.
      <ls_summary>-missing_exec_duration_count =
        ls_execution_percentages-missing_exec_duration_count.
      <ls_summary>-missing_exec_duration_pct =
        ls_execution_percentages-missing_exec_duration_pct.
      <ls_summary>-zero_exec_duration_count =
        ls_execution_percentages-zero_exec_duration_count.
      <ls_summary>-zero_exec_duration_pct =
        ls_execution_percentages-zero_exec_duration_pct.
      <ls_summary>-exec_duration_seconds_avg = calc_exec_duration_avg(
        iv_duration_count         = <ls_summary>-exec_duration_count
        iv_duration_seconds_total =
          <ls_summary>-exec_duration_seconds_total ).
      DATA(ls_percentages) = calculate_conf_percentages(
        iv_confirmation_count = <ls_summary>-confirmation_count
        iv_final_count        = <ls_summary>-final_confirmation_count
        iv_partial_count      = <ls_summary>-partial_confirmation_count
        iv_reversed_count     = <ls_summary>-reversed_confirmation_count ).
      <ls_summary>-final_confirmation_pct =
        ls_percentages-final_confirmation_pct.
      <ls_summary>-partial_confirmation_pct =
        ls_percentages-partial_confirmation_pct.
      <ls_summary>-reversed_confirmation_pct =
        ls_percentages-reversed_confirmation_pct.
      CLEAR lt_base_wc_confirmations.
      LOOP AT it_base_quantities INTO DATA(ls_base_union_quantity)
          WHERE base_quantity_unit = <ls_summary>-base_quantity_unit.
        APPEND ls_base_union_quantity-confirmation_row
          TO lt_base_wc_confirmations.
      ENDLOOP.
      DATA(ls_base_wc_interval_metrics) = calc_exec_interval_metrics(
        it_confirmations     = lt_base_wc_confirmations
        iv_work_center       = <ls_summary>-work_center
        iv_work_center_plant = <ls_summary>-work_center_plant ).
      <ls_summary>-exec_covered_seconds =
        ls_base_wc_interval_metrics-covered_seconds.
      <ls_summary>-exec_duration_seconds_median =
        ls_base_wc_interval_metrics-duration_median_seconds.

      <ls_summary>-exec_duration_seconds_p90 =
        ls_base_wc_interval_metrics-duration_p90_seconds.
      <ls_summary>-exec_duration_seconds_p95 =
        ls_base_wc_interval_metrics-duration_p95_seconds.
      <ls_summary>-exec_duration_seconds_p99 =
        ls_base_wc_interval_metrics-duration_p99_seconds.
      <ls_summary>-exec_duration_seconds_p25 =
        ls_base_wc_interval_metrics-duration_p25_seconds.
      <ls_summary>-exec_duration_seconds_p75 =
        ls_base_wc_interval_metrics-duration_p75_seconds.
      <ls_summary>-exec_duration_seconds_iqr =
        ls_base_wc_interval_metrics-duration_iqr_seconds.
      <ls_summary>-exec_duration_seconds_mad =
        ls_base_wc_interval_metrics-duration_mad_seconds.
      <ls_summary>-exec_nonrev_min_secs =
        ls_base_wc_interval_metrics-nonrev_min_seconds.
      <ls_summary>-exec_nonrev_max_secs =
        ls_base_wc_interval_metrics-nonrev_max_seconds.
      <ls_summary>-exec_reversed_min_secs =
        ls_base_wc_interval_metrics-reversed_min_seconds.
      <ls_summary>-exec_reversed_max_secs =
        ls_base_wc_interval_metrics-reversed_max_seconds.
      <ls_summary>-exec_nonrev_median_secs =
        ls_base_wc_interval_metrics-nonrev_duration_median_secs.
      <ls_summary>-exec_reversed_median_secs =
        ls_base_wc_interval_metrics-reversed_duration_median_secs.
      <ls_summary>-exec_nonrev_p90_secs =
        ls_base_wc_interval_metrics-nonrev_p90_seconds.
      <ls_summary>-exec_reversed_p90_secs =
        ls_base_wc_interval_metrics-reversed_p90_seconds.
      <ls_summary>-exec_duration_p90_median_ratio =
        ls_base_wc_interval_metrics-duration_p90_median_ratio.
      <ls_summary>-exec_nonrev_p90_median_ratio =
        ls_base_wc_interval_metrics-nonrev_p90_median_ratio.
      <ls_summary>-exec_reversed_p90_median_ratio =
        ls_base_wc_interval_metrics-reversed_p90_median_ratio.
      <ls_summary>-exec_duration_p90_exceed_count =
        ls_base_wc_interval_metrics-duration_p90_exceed_count.
      <ls_summary>-exec_duration_p90_exceed_pct =
        ls_base_wc_interval_metrics-duration_p90_exceed_pct.
      <ls_summary>-exec_nonrev_p90_exceed_count =
        ls_base_wc_interval_metrics-nonrev_p90_exceed_count.
      <ls_summary>-exec_nonrev_p90_exceed_pct =
        ls_base_wc_interval_metrics-nonrev_p90_exceed_pct.
      <ls_summary>-exec_reversed_p90_exceed_count =
        ls_base_wc_interval_metrics-reversed_p90_exceed_count.
      <ls_summary>-exec_reversed_p90_exceed_pct =
        ls_base_wc_interval_metrics-reversed_p90_exceed_pct.
      <ls_summary>-exec_p90_tail_secs =
        ls_base_wc_interval_metrics-p90_tail_secs.
      <ls_summary>-exec_p90_tail_pct =
        ls_base_wc_interval_metrics-p90_tail_pct.
      <ls_summary>-exec_nonrev_p90_tail_secs =
        ls_base_wc_interval_metrics-nonrev_p90_tail_secs.
      <ls_summary>-exec_nonrev_p90_tail_pct =
        ls_base_wc_interval_metrics-nonrev_p90_tail_pct.
      <ls_summary>-exec_reversed_p90_tail_secs =
        ls_base_wc_interval_metrics-reversed_p90_tail_secs.
      <ls_summary>-exec_reversed_p90_tail_pct =
        ls_base_wc_interval_metrics-reversed_p90_tail_pct.
      <ls_summary>-exec_nonrev_p95_secs =
        ls_base_wc_interval_metrics-nonrev_p95_seconds.
      <ls_summary>-exec_reversed_p95_secs =
        ls_base_wc_interval_metrics-reversed_p95_seconds.
      <ls_summary>-exec_duration_p95_median_ratio =
        ls_base_wc_interval_metrics-duration_p95_median_ratio.
      <ls_summary>-exec_nonrev_p95_median_ratio =
        ls_base_wc_interval_metrics-nonrev_p95_median_ratio.
      <ls_summary>-exec_reversed_p95_median_ratio =
        ls_base_wc_interval_metrics-reversed_p95_median_ratio.
      <ls_summary>-exec_duration_p95_exceed_count =
        ls_base_wc_interval_metrics-duration_p95_exceed_count.
      <ls_summary>-exec_duration_p95_exceed_pct =
        ls_base_wc_interval_metrics-duration_p95_exceed_pct.
      <ls_summary>-exec_nonrev_p95_exceed_count =
        ls_base_wc_interval_metrics-nonrev_p95_exceed_count.
      <ls_summary>-exec_nonrev_p95_exceed_pct =
        ls_base_wc_interval_metrics-nonrev_p95_exceed_pct.
      <ls_summary>-exec_reversed_p95_exceed_count =
        ls_base_wc_interval_metrics-reversed_p95_exceed_count.
      <ls_summary>-exec_reversed_p95_exceed_pct =
        ls_base_wc_interval_metrics-reversed_p95_exceed_pct.
      <ls_summary>-exec_p95_tail_secs =
        ls_base_wc_interval_metrics-p95_tail_secs.
      <ls_summary>-exec_p95_tail_pct =
        ls_base_wc_interval_metrics-p95_tail_pct.
      <ls_summary>-exec_nonrev_p95_tail_secs =
        ls_base_wc_interval_metrics-nonrev_p95_tail_secs.
      <ls_summary>-exec_nonrev_p95_tail_pct =
        ls_base_wc_interval_metrics-nonrev_p95_tail_pct.
      <ls_summary>-exec_reversed_p95_tail_secs =
        ls_base_wc_interval_metrics-reversed_p95_tail_secs.
      <ls_summary>-exec_reversed_p95_tail_pct =
        ls_base_wc_interval_metrics-reversed_p95_tail_pct.
      <ls_summary>-exec_duration_p99_exceed_count =
        ls_base_wc_interval_metrics-duration_p99_exceed_count.
      <ls_summary>-exec_duration_p99_exceed_pct =
        ls_base_wc_interval_metrics-duration_p99_exceed_pct.
      <ls_summary>-exec_nonrev_p99_exceed_count =
        ls_base_wc_interval_metrics-nonrev_p99_exceed_count.
      <ls_summary>-exec_nonrev_p99_exceed_pct =
        ls_base_wc_interval_metrics-nonrev_p99_exceed_pct.
      <ls_summary>-exec_reversed_p99_exceed_count =
        ls_base_wc_interval_metrics-reversed_p99_exceed_count.
      <ls_summary>-exec_reversed_p99_exceed_pct =
        ls_base_wc_interval_metrics-reversed_p99_exceed_pct.
      <ls_summary>-exec_p99_tail_secs =
        ls_base_wc_interval_metrics-p99_tail_secs.
      <ls_summary>-exec_p99_tail_pct =
        ls_base_wc_interval_metrics-p99_tail_pct.
      <ls_summary>-exec_nonrev_p99_tail_secs =
        ls_base_wc_interval_metrics-nonrev_p99_tail_secs.
      <ls_summary>-exec_nonrev_p99_tail_pct =
        ls_base_wc_interval_metrics-nonrev_p99_tail_pct.
      <ls_summary>-exec_reversed_p99_tail_secs =
        ls_base_wc_interval_metrics-reversed_p99_tail_secs.
      <ls_summary>-exec_reversed_p99_tail_pct =
        ls_base_wc_interval_metrics-reversed_p99_tail_pct.
      <ls_summary>-exec_duration_p99_median_ratio =
        ls_base_wc_interval_metrics-duration_p99_median_ratio.
      <ls_summary>-exec_nonrev_p99_median_ratio =
        ls_base_wc_interval_metrics-nonrev_p99_median_ratio.
      <ls_summary>-exec_reversed_p99_median_ratio =
        ls_base_wc_interval_metrics-reversed_p99_median_ratio.
      <ls_summary>-exec_nonrev_p99_secs =
        ls_base_wc_interval_metrics-nonrev_p99_seconds.
      <ls_summary>-exec_reversed_p99_secs =
        ls_base_wc_interval_metrics-reversed_p99_seconds.
      <ls_summary>-exec_nonrev_iqr_secs =
        ls_base_wc_interval_metrics-nonrev_iqr_seconds.
      <ls_summary>-exec_nonrev_p25_secs =
        ls_base_wc_interval_metrics-nonrev_p25_seconds.
      <ls_summary>-exec_nonrev_p75_secs =
        ls_base_wc_interval_metrics-nonrev_p75_seconds.
      <ls_summary>-exec_reversed_p25_secs =
        ls_base_wc_interval_metrics-reversed_p25_seconds.
      <ls_summary>-exec_reversed_p75_secs =
        ls_base_wc_interval_metrics-reversed_p75_seconds.
      <ls_summary>-exec_reversed_iqr_secs =
        ls_base_wc_interval_metrics-reversed_iqr_seconds.
      <ls_summary>-exec_duration_iqr_median_ratio =
        ls_base_wc_interval_metrics-duration_iqr_median_ratio.
      <ls_summary>-exec_nonrev_iqr_median_ratio =
        ls_base_wc_interval_metrics-nonrev_iqr_median_ratio.
      <ls_summary>-exec_reversed_iqr_median_ratio =
        ls_base_wc_interval_metrics-reversed_iqr_median_ratio.
      <ls_summary>-exec_nonrev_mad_secs =
        ls_base_wc_interval_metrics-nonrev_mad_seconds.
      <ls_summary>-exec_reversed_mad_secs =
        ls_base_wc_interval_metrics-reversed_mad_seconds.
      <ls_summary>-exec_duration_mad_median_ratio =
        ls_base_wc_interval_metrics-duration_mad_median_ratio.
      <ls_summary>-exec_nonrev_mad_median_ratio =
        ls_base_wc_interval_metrics-nonrev_mad_median_ratio.
      <ls_summary>-exec_reversed_mad_median_ratio =
        ls_base_wc_interval_metrics-reversed_mad_median_ratio.
      <ls_summary>-exec_duration_avg_median_ratio =
        ls_base_wc_interval_metrics-duration_avg_median_ratio.
      <ls_summary>-exec_nonrev_avg_median_ratio =
        ls_base_wc_interval_metrics-nonrev_avg_median_ratio.
      <ls_summary>-exec_reversed_avg_median_ratio =
        ls_base_wc_interval_metrics-reversed_avg_median_ratio.
      <ls_summary>-exec_pos_duration_count =
        ls_base_wc_interval_metrics-positive_duration_count.
      <ls_summary>-exec_pos_median_secs =
        ls_base_wc_interval_metrics-positive_median_secs.
      <ls_summary>-exec_pos_p90_secs =
        ls_base_wc_interval_metrics-positive_p90_secs.
      <ls_summary>-exec_nonrev_pos_count =
        ls_base_wc_interval_metrics-nonrev_positive_count.
      <ls_summary>-exec_nonrev_pos_median_secs =
        ls_base_wc_interval_metrics-nonrev_positive_median_secs.
      <ls_summary>-exec_nonrev_pos_p90_secs =
        ls_base_wc_interval_metrics-nonrev_positive_p90_secs.
      <ls_summary>-exec_reversed_pos_count =
        ls_base_wc_interval_metrics-reversed_positive_count.
      <ls_summary>-exec_pos_duration_pct =
        ls_base_wc_interval_metrics-positive_pct.
      <ls_summary>-exec_nonrev_pos_duration_pct =
        ls_base_wc_interval_metrics-nonrev_pos_pct.
      <ls_summary>-exec_reversed_pos_duration_pct =
        ls_base_wc_interval_metrics-rev_pos_pct.
      <ls_summary>-exec_pos_valid_pct =
        ls_base_wc_interval_metrics-pos_valid_pct.
      <ls_summary>-exec_nonrev_pos_valid_pct =
        ls_base_wc_interval_metrics-nonrev_pos_valid_pct.
      <ls_summary>-exec_rev_pos_valid_pct =
        ls_base_wc_interval_metrics-rev_pos_valid_pct.
      <ls_summary>-exec_zero_valid_pct =
        ls_base_wc_interval_metrics-zero_valid_pct.
      <ls_summary>-exec_nonrev_zero_valid_pct =
        ls_base_wc_interval_metrics-nonrev_zero_valid_pct.
      <ls_summary>-exec_rev_zero_valid_pct =
        ls_base_wc_interval_metrics-rev_zero_valid_pct.
      <ls_summary>-exec_zero_valid_count =
        ls_base_wc_interval_metrics-zero_valid_count.
      <ls_summary>-exec_nonrev_zero_valid_count =
        ls_base_wc_interval_metrics-nonrev_zero_valid_count.
      <ls_summary>-exec_rev_zero_valid_count =
        ls_base_wc_interval_metrics-rev_zero_valid_count.
      <ls_summary>-exec_nonrev_invalid_count =
        ls_base_wc_interval_metrics-nonrev_invalid_count.
      <ls_summary>-exec_rev_invalid_count =
        ls_base_wc_interval_metrics-rev_invalid_count.
      <ls_summary>-exec_nonrev_missing_count =
        ls_base_wc_interval_metrics-nonrev_missing_count.
      <ls_summary>-exec_rev_missing_count =
        ls_base_wc_interval_metrics-rev_missing_count.
      <ls_summary>-exec_nonrev_valid_pct =
        ls_base_wc_interval_metrics-nonrev_valid_pct.
      <ls_summary>-exec_rev_valid_pct =
        ls_base_wc_interval_metrics-rev_valid_pct.
      <ls_summary>-exec_nonrev_invalid_pct =
        ls_base_wc_interval_metrics-nonrev_invalid_pct.
      <ls_summary>-exec_rev_invalid_pct =
        ls_base_wc_interval_metrics-rev_invalid_pct.
      <ls_summary>-exec_nonrev_missing_pct =
        ls_base_wc_interval_metrics-nonrev_missing_pct.
      <ls_summary>-exec_rev_missing_pct =
        ls_base_wc_interval_metrics-rev_missing_pct.
      <ls_summary>-exec_top_issue_code =
        ls_base_wc_interval_metrics-top_issue_code.
      <ls_summary>-exec_top_issue_status =
        ls_base_wc_interval_metrics-top_issue_status.
      <ls_summary>-exec_top_issue_count =
        ls_base_wc_interval_metrics-top_issue_count.
      <ls_summary>-exec_top_issue_pct =
        ls_base_wc_interval_metrics-top_issue_pct.
      <ls_summary>-exec_top_invalid_issue_code =
        ls_base_wc_interval_metrics-top_invalid_issue_code.
      <ls_summary>-exec_top_invalid_issue_count =
        ls_base_wc_interval_metrics-top_invalid_issue_count.
      <ls_summary>-exec_top_invalid_share_pct =
        ls_base_wc_interval_metrics-top_invalid_share_pct.
      <ls_summary>-exec_top_missing_issue_code =
        ls_base_wc_interval_metrics-top_missing_issue_code.
      <ls_summary>-exec_top_missing_issue_count =
        ls_base_wc_interval_metrics-top_missing_issue_count.
      <ls_summary>-exec_top_missing_share_pct =
        ls_base_wc_interval_metrics-top_missing_share_pct.
      <ls_summary>-exec_top_nonrev_issue_code =
        ls_base_wc_interval_metrics-top_nonrev_issue_code.
      <ls_summary>-exec_top_nonrev_issue_status =
        ls_base_wc_interval_metrics-top_nonrev_issue_status.
      <ls_summary>-exec_top_nonrev_issue_count =
        ls_base_wc_interval_metrics-top_nonrev_issue_count.
      <ls_summary>-exec_top_nonrev_issue_pct =
        ls_base_wc_interval_metrics-top_nonrev_issue_pct.
      <ls_summary>-exec_top_reversed_issue_code =
        ls_base_wc_interval_metrics-top_reversed_issue_code.
      <ls_summary>-exec_top_reversed_issue_status =
        ls_base_wc_interval_metrics-top_reversed_issue_status.
      <ls_summary>-exec_top_reversed_issue_count =
        ls_base_wc_interval_metrics-top_reversed_issue_count.
      <ls_summary>-exec_top_reversed_issue_pct =
        ls_base_wc_interval_metrics-top_reversed_issue_pct.
      <ls_summary>-exec_duration_issue_counts =
        ls_base_wc_interval_metrics-issue_counts.
      <ls_summary>-exec_reversed_pos_median_secs =
        ls_base_wc_interval_metrics-reversed_positive_median_secs.
      <ls_summary>-exec_reversed_pos_p90_secs =
        ls_base_wc_interval_metrics-reversed_positive_p90_secs.
      <ls_summary>-exec_pos_p90_med_ratio =
        ls_base_wc_interval_metrics-pos_p90_med_ratio.
      <ls_summary>-exec_nonrev_pos_p90_med_ratio =
        ls_base_wc_interval_metrics-nonrev_pos_p90_med_ratio.
      <ls_summary>-exec_rev_pos_p90_med_ratio =
        ls_base_wc_interval_metrics-reversed_pos_p90_med_ratio.
      <ls_summary>-exec_pos_p90_gt_count =
        ls_base_wc_interval_metrics-pos_p90_gt_count.
      <ls_summary>-exec_pos_p90_gt_pct =
        ls_base_wc_interval_metrics-pos_p90_gt_pct.
      <ls_summary>-exec_pos_p90_tail_secs =
        ls_base_wc_interval_metrics-pos_p90_tail_secs.
      <ls_summary>-exec_pos_p90_tail_pct =
        ls_base_wc_interval_metrics-pos_p90_tail_pct.
      <ls_summary>-exec_nonrev_pos_p90_gt_count =
        ls_base_wc_interval_metrics-nonrev_pos_p90_gt_count.
      <ls_summary>-exec_nonrev_pos_p90_gt_pct =
        ls_base_wc_interval_metrics-nonrev_pos_p90_gt_pct.
      <ls_summary>-exec_nonrev_pos_p90_tail_secs =
        ls_base_wc_interval_metrics-nonrev_pos_p90_tail_secs.
      <ls_summary>-exec_nonrev_pos_p90_tail_pct =
        ls_base_wc_interval_metrics-nonrev_pos_p90_tail_pct.
      <ls_summary>-exec_rev_pos_p90_gt_count =
        ls_base_wc_interval_metrics-rev_pos_p90_gt_count.
      <ls_summary>-exec_rev_pos_p90_gt_pct =
        ls_base_wc_interval_metrics-rev_pos_p90_gt_pct.
      <ls_summary>-exec_rev_pos_p90_tail_secs =
        ls_base_wc_interval_metrics-rev_pos_p90_tail_secs.
      <ls_summary>-exec_rev_pos_p90_tail_pct =
        ls_base_wc_interval_metrics-rev_pos_p90_tail_pct.
      <ls_summary>-exec_pos_p95_secs =
        ls_base_wc_interval_metrics-positive_p95_secs.
      <ls_summary>-exec_pos_p99_secs =
        ls_base_wc_interval_metrics-positive_p99_secs.
      <ls_summary>-exec_nonrev_pos_p95_secs =
        ls_base_wc_interval_metrics-nonrev_positive_p95_secs.
      <ls_summary>-exec_nonrev_pos_p99_secs =
        ls_base_wc_interval_metrics-nonrev_positive_p99_secs.
      <ls_summary>-exec_rev_pos_p95_secs =
        ls_base_wc_interval_metrics-reversed_positive_p95_secs.
      <ls_summary>-exec_rev_pos_p99_secs =
        ls_base_wc_interval_metrics-reversed_positive_p99_secs.
      <ls_summary>-exec_pos_p25_secs =
        ls_base_wc_interval_metrics-positive_p25_secs.
      <ls_summary>-exec_pos_p75_secs =
        ls_base_wc_interval_metrics-positive_p75_secs.
      <ls_summary>-exec_nonrev_pos_p25_secs =
        ls_base_wc_interval_metrics-nonrev_positive_p25_secs.
      <ls_summary>-exec_nonrev_pos_p75_secs =
        ls_base_wc_interval_metrics-nonrev_positive_p75_secs.
      <ls_summary>-exec_rev_pos_p25_secs =
        ls_base_wc_interval_metrics-reversed_positive_p25_secs.
      <ls_summary>-exec_rev_pos_p75_secs =
        ls_base_wc_interval_metrics-reversed_positive_p75_secs.
      <ls_summary>-exec_pos_iqr_secs =
        ls_base_wc_interval_metrics-positive_iqr_secs.
      <ls_summary>-exec_nonrev_pos_iqr_secs =
        ls_base_wc_interval_metrics-nonrev_positive_iqr_secs.
      <ls_summary>-exec_rev_pos_iqr_secs =
        ls_base_wc_interval_metrics-reversed_positive_iqr_secs.
      <ls_summary>-exec_pos_mad_secs =
        ls_base_wc_interval_metrics-positive_mad_secs.
      <ls_summary>-exec_nonrev_pos_mad_secs =
        ls_base_wc_interval_metrics-nonrev_positive_mad_secs.
      <ls_summary>-exec_rev_pos_mad_secs =
        ls_base_wc_interval_metrics-reversed_positive_mad_secs.
      <ls_summary>-exec_pos_iqr_med_ratio =
        ls_base_wc_interval_metrics-positive_iqr_med_ratio.
      <ls_summary>-exec_nonrev_pos_iqr_med_ratio =
        ls_base_wc_interval_metrics-nonrev_positive_iqr_med_ratio.
      <ls_summary>-exec_rev_pos_iqr_med_ratio =
        ls_base_wc_interval_metrics-reversed_pos_iqr_med_ratio.
      <ls_summary>-exec_pos_mad_med_ratio =
        ls_base_wc_interval_metrics-positive_mad_med_ratio.
      <ls_summary>-exec_nonrev_pos_mad_med_ratio =
        ls_base_wc_interval_metrics-nonrev_positive_mad_med_ratio.
      <ls_summary>-exec_rev_pos_mad_med_ratio =
        ls_base_wc_interval_metrics-reversed_pos_mad_med_ratio.
      <ls_summary>-exec_pos_avg_secs =
        ls_base_wc_interval_metrics-pos_avg_secs.
      <ls_summary>-exec_nonrev_pos_avg_secs =
        ls_base_wc_interval_metrics-nonrev_pos_avg_secs.
      <ls_summary>-exec_rev_pos_avg_secs =
        ls_base_wc_interval_metrics-rev_pos_avg_secs.
      <ls_summary>-exec_pos_avg_med_ratio =
        ls_base_wc_interval_metrics-pos_avg_med_ratio.
      <ls_summary>-exec_nonrev_pos_avg_med_ratio =
        ls_base_wc_interval_metrics-nonrev_pos_avg_med_ratio.
      <ls_summary>-exec_rev_pos_avg_med_ratio =
        ls_base_wc_interval_metrics-rev_pos_avg_med_ratio.
      <ls_summary>-exec_pos_min_secs =
        ls_base_wc_interval_metrics-positive_min_secs.
      <ls_summary>-exec_pos_max_secs =
        ls_base_wc_interval_metrics-positive_max_secs.
      <ls_summary>-exec_pos_range_secs =
        ls_base_wc_interval_metrics-positive_range_secs.
      <ls_summary>-exec_nonrev_pos_min_secs =
        ls_base_wc_interval_metrics-nonrev_positive_min_secs.
      <ls_summary>-exec_nonrev_pos_max_secs =
        ls_base_wc_interval_metrics-nonrev_positive_max_secs.
      <ls_summary>-exec_nonrev_pos_range_secs =
        ls_base_wc_interval_metrics-nonrev_positive_range_secs.
      <ls_summary>-exec_rev_pos_min_secs =
        ls_base_wc_interval_metrics-reversed_positive_min_secs.
      <ls_summary>-exec_rev_pos_max_secs =
        ls_base_wc_interval_metrics-reversed_positive_max_secs.
      <ls_summary>-exec_rev_pos_range_secs =
        ls_base_wc_interval_metrics-reversed_positive_range_secs.
      <ls_summary>-exec_pos_p95_gt_count =
        ls_base_wc_interval_metrics-pos_p95_gt_count.
      <ls_summary>-exec_pos_p95_gt_pct =
        ls_base_wc_interval_metrics-pos_p95_gt_pct.
      <ls_summary>-exec_pos_p95_tail_secs =
        ls_base_wc_interval_metrics-pos_p95_tail_secs.
      <ls_summary>-exec_pos_p95_tail_pct =
        ls_base_wc_interval_metrics-pos_p95_tail_pct.
      <ls_summary>-exec_nonrev_pos_p95_gt_count =
        ls_base_wc_interval_metrics-nonrev_pos_p95_gt_count.
      <ls_summary>-exec_nonrev_pos_p95_gt_pct =
        ls_base_wc_interval_metrics-nonrev_pos_p95_gt_pct.
      <ls_summary>-exec_nonrev_pos_p95_tail_secs =
        ls_base_wc_interval_metrics-nonrev_pos_p95_tail_secs.
      <ls_summary>-exec_nonrev_pos_p95_tail_pct =
        ls_base_wc_interval_metrics-nonrev_pos_p95_tail_pct.
      <ls_summary>-exec_rev_pos_p95_gt_count =
        ls_base_wc_interval_metrics-rev_pos_p95_gt_count.
      <ls_summary>-exec_rev_pos_p95_gt_pct =
        ls_base_wc_interval_metrics-rev_pos_p95_gt_pct.
      <ls_summary>-exec_rev_pos_p95_tail_secs =
        ls_base_wc_interval_metrics-rev_pos_p95_tail_secs.
      <ls_summary>-exec_rev_pos_p95_tail_pct =
        ls_base_wc_interval_metrics-rev_pos_p95_tail_pct.
      <ls_summary>-exec_pos_p99_gt_count =
        ls_base_wc_interval_metrics-pos_p99_gt_count.
      <ls_summary>-exec_pos_p99_gt_pct =
        ls_base_wc_interval_metrics-pos_p99_gt_pct.
      <ls_summary>-exec_pos_p99_tail_secs =
        ls_base_wc_interval_metrics-pos_p99_tail_secs.
      <ls_summary>-exec_pos_p99_tail_pct =
        ls_base_wc_interval_metrics-pos_p99_tail_pct.
      <ls_summary>-exec_nonrev_pos_p99_gt_count =
        ls_base_wc_interval_metrics-nonrev_pos_p99_gt_count.
      <ls_summary>-exec_nonrev_pos_p99_gt_pct =
        ls_base_wc_interval_metrics-nonrev_pos_p99_gt_pct.
      <ls_summary>-exec_nonrev_pos_p99_tail_secs =
        ls_base_wc_interval_metrics-nonrev_pos_p99_tail_secs.
      <ls_summary>-exec_nonrev_pos_p99_tail_pct =
        ls_base_wc_interval_metrics-nonrev_pos_p99_tail_pct.
      <ls_summary>-exec_rev_pos_p99_gt_count =
        ls_base_wc_interval_metrics-rev_pos_p99_gt_count.
      <ls_summary>-exec_rev_pos_p99_gt_pct =
        ls_base_wc_interval_metrics-rev_pos_p99_gt_pct.
      <ls_summary>-exec_rev_pos_p99_tail_secs =
        ls_base_wc_interval_metrics-rev_pos_p99_tail_secs.
      <ls_summary>-exec_rev_pos_p99_tail_pct =
        ls_base_wc_interval_metrics-rev_pos_p99_tail_pct.
      <ls_summary>-exec_pos_p95_med_ratio =
        ls_base_wc_interval_metrics-pos_p95_med_ratio.
      <ls_summary>-exec_nonrev_pos_p95_med_ratio =
        ls_base_wc_interval_metrics-nonrev_pos_p95_med_ratio.
      <ls_summary>-exec_rev_pos_p95_med_ratio =
        ls_base_wc_interval_metrics-rev_pos_p95_med_ratio.
      <ls_summary>-exec_pos_p99_med_ratio =
        ls_base_wc_interval_metrics-pos_p99_med_ratio.
      <ls_summary>-exec_nonrev_pos_p99_med_ratio =
        ls_base_wc_interval_metrics-nonrev_pos_p99_med_ratio.
      <ls_summary>-exec_rev_pos_p99_med_ratio =
        ls_base_wc_interval_metrics-rev_pos_p99_med_ratio.
      <ls_summary>-exec_nonrev_covered_secs =
        ls_base_wc_interval_metrics-nonrev_covered_seconds.
      <ls_summary>-exec_nonrev_duration_count =
        ls_base_wc_interval_metrics-nonrev_duration_count.
      <ls_summary>-exec_nonrev_total_secs =
        ls_base_wc_interval_metrics-nonrev_duration_total.
      <ls_summary>-exec_nonrev_duration_avg_secs =
        ls_base_wc_interval_metrics-nonrev_duration_avg_secs.
      <ls_summary>-exec_nonrev_excess_secs =
        ls_base_wc_interval_metrics-nonrev_excess_secs.
      <ls_summary>-exec_reversed_duration_count =
        ls_base_wc_interval_metrics-reversed_duration_count.
      <ls_summary>-exec_reversed_total_secs =
        ls_base_wc_interval_metrics-reversed_duration_total.
      <ls_summary>-exec_rev_duration_avg_secs =
        ls_base_wc_interval_metrics-reversed_avg_secs.
      <ls_summary>-exec_reversed_covered_secs =
        ls_base_wc_interval_metrics-reversed_covered_seconds.
      <ls_summary>-exec_reversed_excess_secs =
        ls_base_wc_interval_metrics-reversed_excess_secs.
      <ls_summary>-exec_nonrev_duration_pct =
        ls_base_wc_interval_metrics-nonrev_duration_pct.
      <ls_summary>-exec_reversed_duration_pct =
        ls_base_wc_interval_metrics-reversed_duration_pct.
      <ls_summary>-exec_single_active_seconds =
        ls_base_wc_interval_metrics-single_active_seconds.
      <ls_summary>-exec_single_episode_count =
        ls_base_wc_interval_metrics-single_episode_count.
      <ls_summary>-exec_longest_single_secs =
        ls_base_wc_interval_metrics-longest_single_secs.
      <ls_summary>-exec_single_active_avg_secs =
        ls_base_wc_interval_metrics-single_active_avg_secs.
      <ls_summary>-exec_high_concurrency_secs =
        ls_base_wc_interval_metrics-high_concurrency_seconds.
      <ls_summary>-exec_exactly_two_secs =
        ls_base_wc_interval_metrics-exactly_two_seconds.
      <ls_summary>-exec_exactly_two_pct =
        ls_base_wc_interval_metrics-exactly_two_pct.
      <ls_summary>-exec_3plus_episode_count =
        ls_base_wc_interval_metrics-three_plus_episode_count.
      <ls_summary>-exec_longest_3plus_secs =
        ls_base_wc_interval_metrics-longest_three_plus_secs.
      <ls_summary>-exec_3plus_avg_secs =
        ls_base_wc_interval_metrics-three_plus_avg_secs.
      <ls_summary>-exec_3plus_pct =
        ls_base_wc_interval_metrics-three_plus_pct.
      <ls_summary>-exec_overlap_excess_seconds =
        ls_base_wc_interval_metrics-overlap_excess_seconds.
      <ls_summary>-exec_peak_concurrency =
        ls_base_wc_interval_metrics-peak_concurrency.
      <ls_summary>-exec_idle_gap_seconds =
        ls_base_wc_interval_metrics-idle_gap_seconds.
      <ls_summary>-exec_idle_gap_episode_count =
        ls_base_wc_interval_metrics-idle_gap_episode_count.
      <ls_summary>-exec_idle_gap_avg_secs =
        ls_base_wc_interval_metrics-idle_gap_avg_secs.
      <ls_summary>-exec_interval_coverage_pct =
        ls_base_wc_interval_metrics-interval_coverage_pct.
      <ls_summary>-exec_single_active_pct =
        ls_base_wc_interval_metrics-single_active_pct.
      <ls_summary>-exec_overlap_wall_pct =
        ls_base_wc_interval_metrics-overlap_wall_pct.
      <ls_summary>-exec_longest_idle_gap_secs =
        ls_base_wc_interval_metrics-longest_idle_gap_secs.
      <ls_summary>-exec_overlap_wall_seconds =
        ls_base_wc_interval_metrics-overlap_wall_seconds.
      <ls_summary>-exec_pairwise_overlap_secs =
        ls_base_wc_interval_metrics-pairwise_overlap_seconds.
      <ls_summary>-exec_overlap_episode_count =
        ls_base_wc_interval_metrics-overlap_episode_count.
      <ls_summary>-exec_overlap_pair_count =
        ls_base_wc_interval_metrics-overlap_pair_count.
      <ls_summary>-exec_overlap_pair_avg_secs =
        ls_base_wc_interval_metrics-overlap_pair_avg_secs.
      <ls_summary>-exec_longest_pair_overlap_secs =
        ls_base_wc_interval_metrics-longest_pair_overlap_secs.
      <ls_summary>-exec_peak_concurrency_secs =
        ls_base_wc_interval_metrics-peak_seconds.
      <ls_summary>-exec_peak_concurrency_pct =
        ls_base_wc_interval_metrics-peak_concurrency_pct.
      <ls_summary>-exec_peak_episode_count =
        ls_base_wc_interval_metrics-peak_episode_count.
      <ls_summary>-exec_longest_peak_secs =
        ls_base_wc_interval_metrics-longest_peak_secs.
      <ls_summary>-exec_peak_episode_avg_secs =
        ls_base_wc_interval_metrics-peak_episode_avg_secs.
      <ls_summary>-exec_avg_concurrency =
        ls_base_wc_interval_metrics-avg_concurrency.
      <ls_summary>-exec_longest_overlap_secs =
        ls_base_wc_interval_metrics-longest_overlap_secs.
      <ls_summary>-exec_overlap_avg_secs =
        ls_base_wc_interval_metrics-overlap_avg_secs.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_conf_order_summaries.
    FIELD-SYMBOLS <ls_order_summary> TYPE ty_conf_order_summary.

    LOOP AT it_operation_summaries INTO DATA(ls_operation_summary).
      READ TABLE rt_summaries ASSIGNING <ls_order_summary>
        WITH TABLE KEY
          production_order = ls_operation_summary-production_order
          quantity_unit = ls_operation_summary-quantity_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order   = ls_operation_summary-production_order
          order_category     = ls_operation_summary-order_category
          order_type         = ls_operation_summary-order_type
          quantity_unit      = ls_operation_summary-quantity_unit
          first_posting_date = ls_operation_summary-first_posting_date
          last_posting_date  = ls_operation_summary-last_posting_date )
          INTO TABLE rt_summaries.
        READ TABLE rt_summaries ASSIGNING <ls_order_summary>
          WITH TABLE KEY
            production_order = ls_operation_summary-production_order
            quantity_unit = ls_operation_summary-quantity_unit.
      ELSE.
        IF ls_operation_summary-first_posting_date <
            <ls_order_summary>-first_posting_date.
          <ls_order_summary>-first_posting_date =
            ls_operation_summary-first_posting_date.
        ENDIF.
        IF ls_operation_summary-last_posting_date >
            <ls_order_summary>-last_posting_date.
          <ls_order_summary>-last_posting_date =
            ls_operation_summary-last_posting_date.
        ENDIF.
      ENDIF.

      ADD ls_operation_summary-confirmation_count TO
        <ls_order_summary>-confirmation_count.
      ADD ls_operation_summary-final_confirmation_count TO
        <ls_order_summary>-final_confirmation_count.
      ADD ls_operation_summary-partial_confirmation_count TO
        <ls_order_summary>-partial_confirmation_count.
      ADD ls_operation_summary-reversed_confirmation_count TO
        <ls_order_summary>-reversed_confirmation_count.
      <ls_order_summary>-yield_quantity_total =
        <ls_order_summary>-yield_quantity_total +
        ls_operation_summary-yield_quantity_total.
      <ls_order_summary>-rework_quantity_total =
        <ls_order_summary>-rework_quantity_total +
        ls_operation_summary-rework_quantity_total.
      <ls_order_summary>-scrap_quantity_total =
        <ls_order_summary>-scrap_quantity_total +
        ls_operation_summary-scrap_quantity_total.
      <ls_order_summary>-yield_non_reversed_total =
        <ls_order_summary>-yield_non_reversed_total +
        ls_operation_summary-yield_non_reversed_total.
      <ls_order_summary>-rework_non_reversed_total =
        <ls_order_summary>-rework_non_reversed_total +
        ls_operation_summary-rework_non_reversed_total.
      <ls_order_summary>-scrap_non_reversed_total =
        <ls_order_summary>-scrap_non_reversed_total +
        ls_operation_summary-scrap_non_reversed_total.
    ENDLOOP.

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      READ TABLE rt_summaries ASSIGNING <ls_order_summary>
        WITH TABLE KEY
          production_order = ls_confirmation-production_order
          quantity_unit = ls_confirmation-quantity_unit.
      IF sy-subrc = 0.
        CALL METHOD me->update_conf_execution_metrics
          EXPORTING
            is_confirmation = ls_confirmation
          CHANGING
            cv_execution_start_count       =
              <ls_order_summary>-execution_start_count
            cv_first_execution_start_date  =
              <ls_order_summary>-first_execution_start_date
            cv_first_execution_start_time  =
              <ls_order_summary>-first_execution_start_time
            cv_execution_finish_count      =
              <ls_order_summary>-execution_finish_count
            cv_last_execution_finish_date  =
              <ls_order_summary>-last_execution_finish_date
            cv_last_execution_finish_time  =
              <ls_order_summary>-last_execution_finish_time
            cv_duration_count              =
              <ls_order_summary>-exec_duration_count
            cv_zero_duration_count         =
              <ls_order_summary>-zero_exec_duration_count
            cv_invalid_duration_count      =
              <ls_order_summary>-invalid_exec_duration_count
            cv_duration_seconds            =
              <ls_order_summary>-exec_duration_seconds_total
            cv_duration_seconds_min        =
              <ls_order_summary>-exec_duration_seconds_min
            cv_duration_seconds_max        =
              <ls_order_summary>-exec_duration_seconds_max.
      ENDIF.
    ENDLOOP.
    LOOP AT rt_summaries ASSIGNING <ls_order_summary>.
      DATA(ls_order_exec_pct) =
        calc_exec_coverage_pct(
          iv_confirmation_count     =
            <ls_order_summary>-confirmation_count
          iv_execution_start_count  =
            <ls_order_summary>-execution_start_count
          iv_execution_finish_count =
            <ls_order_summary>-execution_finish_count
          iv_duration_count         =
            <ls_order_summary>-exec_duration_count
          iv_zero_duration_count    =
            <ls_order_summary>-zero_exec_duration_count
          iv_invalid_duration_count =
            <ls_order_summary>-invalid_exec_duration_count ).
      <ls_order_summary>-execution_start_pct =
        ls_order_exec_pct-execution_start_pct.
      <ls_order_summary>-execution_finish_pct =
        ls_order_exec_pct-execution_finish_pct.
      <ls_order_summary>-valid_exec_duration_pct =
        ls_order_exec_pct-valid_exec_duration_pct.
      <ls_order_summary>-invalid_exec_duration_pct =
        ls_order_exec_pct-invalid_exec_duration_pct.
      <ls_order_summary>-missing_exec_duration_count =
        ls_order_exec_pct-missing_exec_duration_count.
      <ls_order_summary>-missing_exec_duration_pct =
        ls_order_exec_pct-missing_exec_duration_pct.
      <ls_order_summary>-zero_exec_duration_count =
        ls_order_exec_pct-zero_exec_duration_count.
      <ls_order_summary>-zero_exec_duration_pct =
        ls_order_exec_pct-zero_exec_duration_pct.
      <ls_order_summary>-exec_duration_seconds_avg =
        calc_exec_duration_avg(
          iv_duration_count         =
            <ls_order_summary>-exec_duration_count
          iv_duration_seconds_total =
            <ls_order_summary>-exec_duration_seconds_total ).
      DATA(ls_order_percentages) = calculate_conf_percentages(
        iv_confirmation_count = <ls_order_summary>-confirmation_count
        iv_final_count        = <ls_order_summary>-final_confirmation_count
        iv_partial_count      = <ls_order_summary>-partial_confirmation_count
        iv_reversed_count     = <ls_order_summary>-reversed_confirmation_count ).
      <ls_order_summary>-final_confirmation_pct =
        ls_order_percentages-final_confirmation_pct.
      <ls_order_summary>-partial_confirmation_pct =
        ls_order_percentages-partial_confirmation_pct.
      <ls_order_summary>-reversed_confirmation_pct =
        ls_order_percentages-reversed_confirmation_pct.
      DATA(ls_order_interval_metrics) = calc_exec_interval_metrics(
        it_confirmations    = it_confirmations
        iv_production_order = <ls_order_summary>-production_order
        iv_quantity_unit    = <ls_order_summary>-quantity_unit ).
      <ls_order_summary>-exec_covered_seconds =
        ls_order_interval_metrics-covered_seconds.
      <ls_order_summary>-exec_duration_seconds_median =
        ls_order_interval_metrics-duration_median_seconds.

      <ls_order_summary>-exec_duration_seconds_p90 =
        ls_order_interval_metrics-duration_p90_seconds.
      <ls_order_summary>-exec_duration_seconds_p95 =
        ls_order_interval_metrics-duration_p95_seconds.
      <ls_order_summary>-exec_duration_seconds_p99 =
        ls_order_interval_metrics-duration_p99_seconds.
      <ls_order_summary>-exec_duration_seconds_p25 =
        ls_order_interval_metrics-duration_p25_seconds.
      <ls_order_summary>-exec_duration_seconds_p75 =
        ls_order_interval_metrics-duration_p75_seconds.
      <ls_order_summary>-exec_duration_seconds_iqr =
        ls_order_interval_metrics-duration_iqr_seconds.
      <ls_order_summary>-exec_duration_seconds_mad =
        ls_order_interval_metrics-duration_mad_seconds.
      <ls_order_summary>-exec_nonrev_min_secs =
        ls_order_interval_metrics-nonrev_min_seconds.
      <ls_order_summary>-exec_nonrev_max_secs =
        ls_order_interval_metrics-nonrev_max_seconds.
      <ls_order_summary>-exec_reversed_min_secs =
        ls_order_interval_metrics-reversed_min_seconds.
      <ls_order_summary>-exec_reversed_max_secs =
        ls_order_interval_metrics-reversed_max_seconds.
      <ls_order_summary>-exec_nonrev_median_secs =
        ls_order_interval_metrics-nonrev_duration_median_secs.
      <ls_order_summary>-exec_reversed_median_secs =
        ls_order_interval_metrics-reversed_duration_median_secs.
      <ls_order_summary>-exec_nonrev_p90_secs =
        ls_order_interval_metrics-nonrev_p90_seconds.
      <ls_order_summary>-exec_reversed_p90_secs =
        ls_order_interval_metrics-reversed_p90_seconds.
      <ls_order_summary>-exec_duration_p90_median_ratio =
        ls_order_interval_metrics-duration_p90_median_ratio.
      <ls_order_summary>-exec_nonrev_p90_median_ratio =
        ls_order_interval_metrics-nonrev_p90_median_ratio.
      <ls_order_summary>-exec_reversed_p90_median_ratio =
        ls_order_interval_metrics-reversed_p90_median_ratio.
      <ls_order_summary>-exec_duration_p90_exceed_count =
        ls_order_interval_metrics-duration_p90_exceed_count.
      <ls_order_summary>-exec_duration_p90_exceed_pct =
        ls_order_interval_metrics-duration_p90_exceed_pct.
      <ls_order_summary>-exec_nonrev_p90_exceed_count =
        ls_order_interval_metrics-nonrev_p90_exceed_count.
      <ls_order_summary>-exec_nonrev_p90_exceed_pct =
        ls_order_interval_metrics-nonrev_p90_exceed_pct.
      <ls_order_summary>-exec_reversed_p90_exceed_count =
        ls_order_interval_metrics-reversed_p90_exceed_count.
      <ls_order_summary>-exec_reversed_p90_exceed_pct =
        ls_order_interval_metrics-reversed_p90_exceed_pct.
      <ls_order_summary>-exec_p90_tail_secs =
        ls_order_interval_metrics-p90_tail_secs.
      <ls_order_summary>-exec_p90_tail_pct =
        ls_order_interval_metrics-p90_tail_pct.
      <ls_order_summary>-exec_nonrev_p90_tail_secs =
        ls_order_interval_metrics-nonrev_p90_tail_secs.
      <ls_order_summary>-exec_nonrev_p90_tail_pct =
        ls_order_interval_metrics-nonrev_p90_tail_pct.
      <ls_order_summary>-exec_reversed_p90_tail_secs =
        ls_order_interval_metrics-reversed_p90_tail_secs.
      <ls_order_summary>-exec_reversed_p90_tail_pct =
        ls_order_interval_metrics-reversed_p90_tail_pct.
      <ls_order_summary>-exec_nonrev_p95_secs =
        ls_order_interval_metrics-nonrev_p95_seconds.
      <ls_order_summary>-exec_reversed_p95_secs =
        ls_order_interval_metrics-reversed_p95_seconds.
      <ls_order_summary>-exec_duration_p95_median_ratio =
        ls_order_interval_metrics-duration_p95_median_ratio.
      <ls_order_summary>-exec_nonrev_p95_median_ratio =
        ls_order_interval_metrics-nonrev_p95_median_ratio.
      <ls_order_summary>-exec_reversed_p95_median_ratio =
        ls_order_interval_metrics-reversed_p95_median_ratio.
      <ls_order_summary>-exec_duration_p95_exceed_count =
        ls_order_interval_metrics-duration_p95_exceed_count.
      <ls_order_summary>-exec_duration_p95_exceed_pct =
        ls_order_interval_metrics-duration_p95_exceed_pct.
      <ls_order_summary>-exec_nonrev_p95_exceed_count =
        ls_order_interval_metrics-nonrev_p95_exceed_count.
      <ls_order_summary>-exec_nonrev_p95_exceed_pct =
        ls_order_interval_metrics-nonrev_p95_exceed_pct.
      <ls_order_summary>-exec_reversed_p95_exceed_count =
        ls_order_interval_metrics-reversed_p95_exceed_count.
      <ls_order_summary>-exec_reversed_p95_exceed_pct =
        ls_order_interval_metrics-reversed_p95_exceed_pct.
      <ls_order_summary>-exec_p95_tail_secs =
        ls_order_interval_metrics-p95_tail_secs.
      <ls_order_summary>-exec_p95_tail_pct =
        ls_order_interval_metrics-p95_tail_pct.
      <ls_order_summary>-exec_nonrev_p95_tail_secs =
        ls_order_interval_metrics-nonrev_p95_tail_secs.
      <ls_order_summary>-exec_nonrev_p95_tail_pct =
        ls_order_interval_metrics-nonrev_p95_tail_pct.
      <ls_order_summary>-exec_reversed_p95_tail_secs =
        ls_order_interval_metrics-reversed_p95_tail_secs.
      <ls_order_summary>-exec_reversed_p95_tail_pct =
        ls_order_interval_metrics-reversed_p95_tail_pct.
      <ls_order_summary>-exec_duration_p99_exceed_count =
        ls_order_interval_metrics-duration_p99_exceed_count.
      <ls_order_summary>-exec_duration_p99_exceed_pct =
        ls_order_interval_metrics-duration_p99_exceed_pct.
      <ls_order_summary>-exec_nonrev_p99_exceed_count =
        ls_order_interval_metrics-nonrev_p99_exceed_count.
      <ls_order_summary>-exec_nonrev_p99_exceed_pct =
        ls_order_interval_metrics-nonrev_p99_exceed_pct.
      <ls_order_summary>-exec_reversed_p99_exceed_count =
        ls_order_interval_metrics-reversed_p99_exceed_count.
      <ls_order_summary>-exec_reversed_p99_exceed_pct =
        ls_order_interval_metrics-reversed_p99_exceed_pct.
      <ls_order_summary>-exec_p99_tail_secs =
        ls_order_interval_metrics-p99_tail_secs.
      <ls_order_summary>-exec_p99_tail_pct =
        ls_order_interval_metrics-p99_tail_pct.
      <ls_order_summary>-exec_nonrev_p99_tail_secs =
        ls_order_interval_metrics-nonrev_p99_tail_secs.
      <ls_order_summary>-exec_nonrev_p99_tail_pct =
        ls_order_interval_metrics-nonrev_p99_tail_pct.
      <ls_order_summary>-exec_reversed_p99_tail_secs =
        ls_order_interval_metrics-reversed_p99_tail_secs.
      <ls_order_summary>-exec_reversed_p99_tail_pct =
        ls_order_interval_metrics-reversed_p99_tail_pct.
      <ls_order_summary>-exec_duration_p99_median_ratio =
        ls_order_interval_metrics-duration_p99_median_ratio.
      <ls_order_summary>-exec_nonrev_p99_median_ratio =
        ls_order_interval_metrics-nonrev_p99_median_ratio.
      <ls_order_summary>-exec_reversed_p99_median_ratio =
        ls_order_interval_metrics-reversed_p99_median_ratio.
      <ls_order_summary>-exec_nonrev_p99_secs =
        ls_order_interval_metrics-nonrev_p99_seconds.
      <ls_order_summary>-exec_reversed_p99_secs =
        ls_order_interval_metrics-reversed_p99_seconds.
      <ls_order_summary>-exec_nonrev_iqr_secs =
        ls_order_interval_metrics-nonrev_iqr_seconds.
      <ls_order_summary>-exec_nonrev_p25_secs =
        ls_order_interval_metrics-nonrev_p25_seconds.
      <ls_order_summary>-exec_nonrev_p75_secs =
        ls_order_interval_metrics-nonrev_p75_seconds.
      <ls_order_summary>-exec_reversed_p25_secs =
        ls_order_interval_metrics-reversed_p25_seconds.
      <ls_order_summary>-exec_reversed_p75_secs =
        ls_order_interval_metrics-reversed_p75_seconds.
      <ls_order_summary>-exec_reversed_iqr_secs =
        ls_order_interval_metrics-reversed_iqr_seconds.
      <ls_order_summary>-exec_duration_iqr_median_ratio =
        ls_order_interval_metrics-duration_iqr_median_ratio.
      <ls_order_summary>-exec_nonrev_iqr_median_ratio =
        ls_order_interval_metrics-nonrev_iqr_median_ratio.
      <ls_order_summary>-exec_reversed_iqr_median_ratio =
        ls_order_interval_metrics-reversed_iqr_median_ratio.
      <ls_order_summary>-exec_nonrev_mad_secs =
        ls_order_interval_metrics-nonrev_mad_seconds.
      <ls_order_summary>-exec_reversed_mad_secs =
        ls_order_interval_metrics-reversed_mad_seconds.
      <ls_order_summary>-exec_duration_mad_median_ratio =
        ls_order_interval_metrics-duration_mad_median_ratio.
      <ls_order_summary>-exec_nonrev_mad_median_ratio =
        ls_order_interval_metrics-nonrev_mad_median_ratio.
      <ls_order_summary>-exec_reversed_mad_median_ratio =
        ls_order_interval_metrics-reversed_mad_median_ratio.
      <ls_order_summary>-exec_duration_avg_median_ratio =
        ls_order_interval_metrics-duration_avg_median_ratio.
      <ls_order_summary>-exec_nonrev_avg_median_ratio =
        ls_order_interval_metrics-nonrev_avg_median_ratio.
      <ls_order_summary>-exec_reversed_avg_median_ratio =
        ls_order_interval_metrics-reversed_avg_median_ratio.
      <ls_order_summary>-exec_pos_duration_count =
        ls_order_interval_metrics-positive_duration_count.
      <ls_order_summary>-exec_pos_median_secs =
        ls_order_interval_metrics-positive_median_secs.
      <ls_order_summary>-exec_pos_p90_secs =
        ls_order_interval_metrics-positive_p90_secs.
      <ls_order_summary>-exec_nonrev_pos_count =
        ls_order_interval_metrics-nonrev_positive_count.
      <ls_order_summary>-exec_nonrev_pos_median_secs =
        ls_order_interval_metrics-nonrev_positive_median_secs.
      <ls_order_summary>-exec_nonrev_pos_p90_secs =
        ls_order_interval_metrics-nonrev_positive_p90_secs.
      <ls_order_summary>-exec_reversed_pos_count =
        ls_order_interval_metrics-reversed_positive_count.
      <ls_order_summary>-exec_pos_duration_pct =
        ls_order_interval_metrics-positive_pct.
      <ls_order_summary>-exec_nonrev_pos_duration_pct =
        ls_order_interval_metrics-nonrev_pos_pct.
      <ls_order_summary>-exec_reversed_pos_duration_pct =
        ls_order_interval_metrics-rev_pos_pct.
      <ls_order_summary>-exec_pos_valid_pct =
        ls_order_interval_metrics-pos_valid_pct.
      <ls_order_summary>-exec_nonrev_pos_valid_pct =
        ls_order_interval_metrics-nonrev_pos_valid_pct.
      <ls_order_summary>-exec_rev_pos_valid_pct =
        ls_order_interval_metrics-rev_pos_valid_pct.
      <ls_order_summary>-exec_zero_valid_pct =
        ls_order_interval_metrics-zero_valid_pct.
      <ls_order_summary>-exec_nonrev_zero_valid_pct =
        ls_order_interval_metrics-nonrev_zero_valid_pct.
      <ls_order_summary>-exec_rev_zero_valid_pct =
        ls_order_interval_metrics-rev_zero_valid_pct.
      <ls_order_summary>-exec_zero_valid_count =
        ls_order_interval_metrics-zero_valid_count.
      <ls_order_summary>-exec_nonrev_zero_valid_count =
        ls_order_interval_metrics-nonrev_zero_valid_count.
      <ls_order_summary>-exec_rev_zero_valid_count =
        ls_order_interval_metrics-rev_zero_valid_count.
      <ls_order_summary>-exec_nonrev_invalid_count =
        ls_order_interval_metrics-nonrev_invalid_count.
      <ls_order_summary>-exec_rev_invalid_count =
        ls_order_interval_metrics-rev_invalid_count.
      <ls_order_summary>-exec_nonrev_missing_count =
        ls_order_interval_metrics-nonrev_missing_count.
      <ls_order_summary>-exec_rev_missing_count =
        ls_order_interval_metrics-rev_missing_count.
      <ls_order_summary>-exec_nonrev_valid_pct =
        ls_order_interval_metrics-nonrev_valid_pct.
      <ls_order_summary>-exec_rev_valid_pct =
        ls_order_interval_metrics-rev_valid_pct.
      <ls_order_summary>-exec_nonrev_invalid_pct =
        ls_order_interval_metrics-nonrev_invalid_pct.
      <ls_order_summary>-exec_rev_invalid_pct =
        ls_order_interval_metrics-rev_invalid_pct.
      <ls_order_summary>-exec_nonrev_missing_pct =
        ls_order_interval_metrics-nonrev_missing_pct.
      <ls_order_summary>-exec_rev_missing_pct =
        ls_order_interval_metrics-rev_missing_pct.
      <ls_order_summary>-exec_top_issue_code =
        ls_order_interval_metrics-top_issue_code.
      <ls_order_summary>-exec_top_issue_status =
        ls_order_interval_metrics-top_issue_status.
      <ls_order_summary>-exec_top_issue_count =
        ls_order_interval_metrics-top_issue_count.
      <ls_order_summary>-exec_top_issue_pct =
        ls_order_interval_metrics-top_issue_pct.
      <ls_order_summary>-exec_top_invalid_issue_code =
        ls_order_interval_metrics-top_invalid_issue_code.
      <ls_order_summary>-exec_top_invalid_issue_count =
        ls_order_interval_metrics-top_invalid_issue_count.
      <ls_order_summary>-exec_top_invalid_share_pct =
        ls_order_interval_metrics-top_invalid_share_pct.
      <ls_order_summary>-exec_top_missing_issue_code =
        ls_order_interval_metrics-top_missing_issue_code.
      <ls_order_summary>-exec_top_missing_issue_count =
        ls_order_interval_metrics-top_missing_issue_count.
      <ls_order_summary>-exec_top_missing_share_pct =
        ls_order_interval_metrics-top_missing_share_pct.
      <ls_order_summary>-exec_top_nonrev_issue_code =
        ls_order_interval_metrics-top_nonrev_issue_code.
      <ls_order_summary>-exec_top_nonrev_issue_status =
        ls_order_interval_metrics-top_nonrev_issue_status.
      <ls_order_summary>-exec_top_nonrev_issue_count =
        ls_order_interval_metrics-top_nonrev_issue_count.
      <ls_order_summary>-exec_top_nonrev_issue_pct =
        ls_order_interval_metrics-top_nonrev_issue_pct.
      <ls_order_summary>-exec_top_reversed_issue_code =
        ls_order_interval_metrics-top_reversed_issue_code.
      <ls_order_summary>-exec_top_reversed_issue_status =
        ls_order_interval_metrics-top_reversed_issue_status.
      <ls_order_summary>-exec_top_reversed_issue_count =
        ls_order_interval_metrics-top_reversed_issue_count.
      <ls_order_summary>-exec_top_reversed_issue_pct =
        ls_order_interval_metrics-top_reversed_issue_pct.
      <ls_order_summary>-exec_duration_issue_counts =
        ls_order_interval_metrics-issue_counts.
      <ls_order_summary>-exec_reversed_pos_median_secs =
        ls_order_interval_metrics-reversed_positive_median_secs.
      <ls_order_summary>-exec_reversed_pos_p90_secs =
        ls_order_interval_metrics-reversed_positive_p90_secs.
      <ls_order_summary>-exec_pos_p90_med_ratio =
        ls_order_interval_metrics-pos_p90_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_p90_med_ratio =
        ls_order_interval_metrics-nonrev_pos_p90_med_ratio.
      <ls_order_summary>-exec_rev_pos_p90_med_ratio =
        ls_order_interval_metrics-reversed_pos_p90_med_ratio.
      <ls_order_summary>-exec_pos_p90_gt_count =
        ls_order_interval_metrics-pos_p90_gt_count.
      <ls_order_summary>-exec_pos_p90_gt_pct =
        ls_order_interval_metrics-pos_p90_gt_pct.
      <ls_order_summary>-exec_pos_p90_tail_secs =
        ls_order_interval_metrics-pos_p90_tail_secs.
      <ls_order_summary>-exec_pos_p90_tail_pct =
        ls_order_interval_metrics-pos_p90_tail_pct.
      <ls_order_summary>-exec_nonrev_pos_p90_gt_count =
        ls_order_interval_metrics-nonrev_pos_p90_gt_count.
      <ls_order_summary>-exec_nonrev_pos_p90_gt_pct =
        ls_order_interval_metrics-nonrev_pos_p90_gt_pct.
      <ls_order_summary>-exec_nonrev_pos_p90_tail_secs =
        ls_order_interval_metrics-nonrev_pos_p90_tail_secs.
      <ls_order_summary>-exec_nonrev_pos_p90_tail_pct =
        ls_order_interval_metrics-nonrev_pos_p90_tail_pct.
      <ls_order_summary>-exec_rev_pos_p90_gt_count =
        ls_order_interval_metrics-rev_pos_p90_gt_count.
      <ls_order_summary>-exec_rev_pos_p90_gt_pct =
        ls_order_interval_metrics-rev_pos_p90_gt_pct.
      <ls_order_summary>-exec_rev_pos_p90_tail_secs =
        ls_order_interval_metrics-rev_pos_p90_tail_secs.
      <ls_order_summary>-exec_rev_pos_p90_tail_pct =
        ls_order_interval_metrics-rev_pos_p90_tail_pct.
      <ls_order_summary>-exec_pos_p95_secs =
        ls_order_interval_metrics-positive_p95_secs.
      <ls_order_summary>-exec_pos_p99_secs =
        ls_order_interval_metrics-positive_p99_secs.
      <ls_order_summary>-exec_nonrev_pos_p95_secs =
        ls_order_interval_metrics-nonrev_positive_p95_secs.
      <ls_order_summary>-exec_nonrev_pos_p99_secs =
        ls_order_interval_metrics-nonrev_positive_p99_secs.
      <ls_order_summary>-exec_rev_pos_p95_secs =
        ls_order_interval_metrics-reversed_positive_p95_secs.
      <ls_order_summary>-exec_rev_pos_p99_secs =
        ls_order_interval_metrics-reversed_positive_p99_secs.
      <ls_order_summary>-exec_pos_p25_secs =
        ls_order_interval_metrics-positive_p25_secs.
      <ls_order_summary>-exec_pos_p75_secs =
        ls_order_interval_metrics-positive_p75_secs.
      <ls_order_summary>-exec_nonrev_pos_p25_secs =
        ls_order_interval_metrics-nonrev_positive_p25_secs.
      <ls_order_summary>-exec_nonrev_pos_p75_secs =
        ls_order_interval_metrics-nonrev_positive_p75_secs.
      <ls_order_summary>-exec_rev_pos_p25_secs =
        ls_order_interval_metrics-reversed_positive_p25_secs.
      <ls_order_summary>-exec_rev_pos_p75_secs =
        ls_order_interval_metrics-reversed_positive_p75_secs.
      <ls_order_summary>-exec_pos_iqr_secs =
        ls_order_interval_metrics-positive_iqr_secs.
      <ls_order_summary>-exec_nonrev_pos_iqr_secs =
        ls_order_interval_metrics-nonrev_positive_iqr_secs.
      <ls_order_summary>-exec_rev_pos_iqr_secs =
        ls_order_interval_metrics-reversed_positive_iqr_secs.
      <ls_order_summary>-exec_pos_mad_secs =
        ls_order_interval_metrics-positive_mad_secs.
      <ls_order_summary>-exec_nonrev_pos_mad_secs =
        ls_order_interval_metrics-nonrev_positive_mad_secs.
      <ls_order_summary>-exec_rev_pos_mad_secs =
        ls_order_interval_metrics-reversed_positive_mad_secs.
      <ls_order_summary>-exec_pos_iqr_med_ratio =
        ls_order_interval_metrics-positive_iqr_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_iqr_med_ratio =
        ls_order_interval_metrics-nonrev_positive_iqr_med_ratio.
      <ls_order_summary>-exec_rev_pos_iqr_med_ratio =
        ls_order_interval_metrics-reversed_pos_iqr_med_ratio.
      <ls_order_summary>-exec_pos_mad_med_ratio =
        ls_order_interval_metrics-positive_mad_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_mad_med_ratio =
        ls_order_interval_metrics-nonrev_positive_mad_med_ratio.
      <ls_order_summary>-exec_rev_pos_mad_med_ratio =
        ls_order_interval_metrics-reversed_pos_mad_med_ratio.
      <ls_order_summary>-exec_pos_avg_secs =
        ls_order_interval_metrics-pos_avg_secs.
      <ls_order_summary>-exec_nonrev_pos_avg_secs =
        ls_order_interval_metrics-nonrev_pos_avg_secs.
      <ls_order_summary>-exec_rev_pos_avg_secs =
        ls_order_interval_metrics-rev_pos_avg_secs.
      <ls_order_summary>-exec_pos_avg_med_ratio =
        ls_order_interval_metrics-pos_avg_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_avg_med_ratio =
        ls_order_interval_metrics-nonrev_pos_avg_med_ratio.
      <ls_order_summary>-exec_rev_pos_avg_med_ratio =
        ls_order_interval_metrics-rev_pos_avg_med_ratio.
      <ls_order_summary>-exec_pos_min_secs =
        ls_order_interval_metrics-positive_min_secs.
      <ls_order_summary>-exec_pos_max_secs =
        ls_order_interval_metrics-positive_max_secs.
      <ls_order_summary>-exec_pos_range_secs =
        ls_order_interval_metrics-positive_range_secs.
      <ls_order_summary>-exec_nonrev_pos_min_secs =
        ls_order_interval_metrics-nonrev_positive_min_secs.
      <ls_order_summary>-exec_nonrev_pos_max_secs =
        ls_order_interval_metrics-nonrev_positive_max_secs.
      <ls_order_summary>-exec_nonrev_pos_range_secs =
        ls_order_interval_metrics-nonrev_positive_range_secs.
      <ls_order_summary>-exec_rev_pos_min_secs =
        ls_order_interval_metrics-reversed_positive_min_secs.
      <ls_order_summary>-exec_rev_pos_max_secs =
        ls_order_interval_metrics-reversed_positive_max_secs.
      <ls_order_summary>-exec_rev_pos_range_secs =
        ls_order_interval_metrics-reversed_positive_range_secs.
      <ls_order_summary>-exec_pos_p95_gt_count =
        ls_order_interval_metrics-pos_p95_gt_count.
      <ls_order_summary>-exec_pos_p95_gt_pct =
        ls_order_interval_metrics-pos_p95_gt_pct.
      <ls_order_summary>-exec_pos_p95_tail_secs =
        ls_order_interval_metrics-pos_p95_tail_secs.
      <ls_order_summary>-exec_pos_p95_tail_pct =
        ls_order_interval_metrics-pos_p95_tail_pct.
      <ls_order_summary>-exec_nonrev_pos_p95_gt_count =
        ls_order_interval_metrics-nonrev_pos_p95_gt_count.
      <ls_order_summary>-exec_nonrev_pos_p95_gt_pct =
        ls_order_interval_metrics-nonrev_pos_p95_gt_pct.
      <ls_order_summary>-exec_nonrev_pos_p95_tail_secs =
        ls_order_interval_metrics-nonrev_pos_p95_tail_secs.
      <ls_order_summary>-exec_nonrev_pos_p95_tail_pct =
        ls_order_interval_metrics-nonrev_pos_p95_tail_pct.
      <ls_order_summary>-exec_rev_pos_p95_gt_count =
        ls_order_interval_metrics-rev_pos_p95_gt_count.
      <ls_order_summary>-exec_rev_pos_p95_gt_pct =
        ls_order_interval_metrics-rev_pos_p95_gt_pct.
      <ls_order_summary>-exec_rev_pos_p95_tail_secs =
        ls_order_interval_metrics-rev_pos_p95_tail_secs.
      <ls_order_summary>-exec_rev_pos_p95_tail_pct =
        ls_order_interval_metrics-rev_pos_p95_tail_pct.
      <ls_order_summary>-exec_pos_p99_gt_count =
        ls_order_interval_metrics-pos_p99_gt_count.
      <ls_order_summary>-exec_pos_p99_gt_pct =
        ls_order_interval_metrics-pos_p99_gt_pct.
      <ls_order_summary>-exec_pos_p99_tail_secs =
        ls_order_interval_metrics-pos_p99_tail_secs.
      <ls_order_summary>-exec_pos_p99_tail_pct =
        ls_order_interval_metrics-pos_p99_tail_pct.
      <ls_order_summary>-exec_nonrev_pos_p99_gt_count =
        ls_order_interval_metrics-nonrev_pos_p99_gt_count.
      <ls_order_summary>-exec_nonrev_pos_p99_gt_pct =
        ls_order_interval_metrics-nonrev_pos_p99_gt_pct.
      <ls_order_summary>-exec_nonrev_pos_p99_tail_secs =
        ls_order_interval_metrics-nonrev_pos_p99_tail_secs.
      <ls_order_summary>-exec_nonrev_pos_p99_tail_pct =
        ls_order_interval_metrics-nonrev_pos_p99_tail_pct.
      <ls_order_summary>-exec_rev_pos_p99_gt_count =
        ls_order_interval_metrics-rev_pos_p99_gt_count.
      <ls_order_summary>-exec_rev_pos_p99_gt_pct =
        ls_order_interval_metrics-rev_pos_p99_gt_pct.
      <ls_order_summary>-exec_rev_pos_p99_tail_secs =
        ls_order_interval_metrics-rev_pos_p99_tail_secs.
      <ls_order_summary>-exec_rev_pos_p99_tail_pct =
        ls_order_interval_metrics-rev_pos_p99_tail_pct.
      <ls_order_summary>-exec_pos_p95_med_ratio =
        ls_order_interval_metrics-pos_p95_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_p95_med_ratio =
        ls_order_interval_metrics-nonrev_pos_p95_med_ratio.
      <ls_order_summary>-exec_rev_pos_p95_med_ratio =
        ls_order_interval_metrics-rev_pos_p95_med_ratio.
      <ls_order_summary>-exec_pos_p99_med_ratio =
        ls_order_interval_metrics-pos_p99_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_p99_med_ratio =
        ls_order_interval_metrics-nonrev_pos_p99_med_ratio.
      <ls_order_summary>-exec_rev_pos_p99_med_ratio =
        ls_order_interval_metrics-rev_pos_p99_med_ratio.
      <ls_order_summary>-exec_nonrev_covered_secs =
        ls_order_interval_metrics-nonrev_covered_seconds.
      <ls_order_summary>-exec_nonrev_duration_count =
        ls_order_interval_metrics-nonrev_duration_count.
      <ls_order_summary>-exec_nonrev_total_secs =
        ls_order_interval_metrics-nonrev_duration_total.
      <ls_order_summary>-exec_nonrev_duration_avg_secs =
        ls_order_interval_metrics-nonrev_duration_avg_secs.
      <ls_order_summary>-exec_nonrev_excess_secs =
        ls_order_interval_metrics-nonrev_excess_secs.
      <ls_order_summary>-exec_reversed_duration_count =
        ls_order_interval_metrics-reversed_duration_count.
      <ls_order_summary>-exec_reversed_total_secs =
        ls_order_interval_metrics-reversed_duration_total.
      <ls_order_summary>-exec_rev_duration_avg_secs =
        ls_order_interval_metrics-reversed_avg_secs.
      <ls_order_summary>-exec_reversed_covered_secs =
        ls_order_interval_metrics-reversed_covered_seconds.
      <ls_order_summary>-exec_reversed_excess_secs =
        ls_order_interval_metrics-reversed_excess_secs.
      <ls_order_summary>-exec_nonrev_duration_pct =
        ls_order_interval_metrics-nonrev_duration_pct.
      <ls_order_summary>-exec_reversed_duration_pct =
        ls_order_interval_metrics-reversed_duration_pct.
      <ls_order_summary>-exec_single_active_seconds =
        ls_order_interval_metrics-single_active_seconds.
      <ls_order_summary>-exec_single_episode_count =
        ls_order_interval_metrics-single_episode_count.
      <ls_order_summary>-exec_longest_single_secs =
        ls_order_interval_metrics-longest_single_secs.
      <ls_order_summary>-exec_single_active_avg_secs =
        ls_order_interval_metrics-single_active_avg_secs.
      <ls_order_summary>-exec_high_concurrency_secs =
        ls_order_interval_metrics-high_concurrency_seconds.
      <ls_order_summary>-exec_exactly_two_secs =
        ls_order_interval_metrics-exactly_two_seconds.
      <ls_order_summary>-exec_exactly_two_pct =
        ls_order_interval_metrics-exactly_two_pct.
      <ls_order_summary>-exec_3plus_episode_count =
        ls_order_interval_metrics-three_plus_episode_count.
      <ls_order_summary>-exec_longest_3plus_secs =
        ls_order_interval_metrics-longest_three_plus_secs.
      <ls_order_summary>-exec_3plus_avg_secs =
        ls_order_interval_metrics-three_plus_avg_secs.
      <ls_order_summary>-exec_3plus_pct =
        ls_order_interval_metrics-three_plus_pct.
      <ls_order_summary>-exec_overlap_excess_seconds =
        ls_order_interval_metrics-overlap_excess_seconds.
      <ls_order_summary>-exec_peak_concurrency =
        ls_order_interval_metrics-peak_concurrency.
      <ls_order_summary>-exec_idle_gap_seconds =
        ls_order_interval_metrics-idle_gap_seconds.
      <ls_order_summary>-exec_idle_gap_episode_count =
        ls_order_interval_metrics-idle_gap_episode_count.
      <ls_order_summary>-exec_idle_gap_avg_secs =
        ls_order_interval_metrics-idle_gap_avg_secs.
      <ls_order_summary>-exec_interval_coverage_pct =
        ls_order_interval_metrics-interval_coverage_pct.
      <ls_order_summary>-exec_single_active_pct =
        ls_order_interval_metrics-single_active_pct.
      <ls_order_summary>-exec_overlap_wall_pct =
        ls_order_interval_metrics-overlap_wall_pct.
      <ls_order_summary>-exec_longest_idle_gap_secs =
        ls_order_interval_metrics-longest_idle_gap_secs.
      <ls_order_summary>-exec_overlap_wall_seconds =
        ls_order_interval_metrics-overlap_wall_seconds.
      <ls_order_summary>-exec_pairwise_overlap_secs =
        ls_order_interval_metrics-pairwise_overlap_seconds.
      <ls_order_summary>-exec_overlap_episode_count =
        ls_order_interval_metrics-overlap_episode_count.
      <ls_order_summary>-exec_overlap_pair_count =
        ls_order_interval_metrics-overlap_pair_count.
      <ls_order_summary>-exec_overlap_pair_avg_secs =
        ls_order_interval_metrics-overlap_pair_avg_secs.
      <ls_order_summary>-exec_longest_pair_overlap_secs =
        ls_order_interval_metrics-longest_pair_overlap_secs.
      <ls_order_summary>-exec_peak_concurrency_secs =
        ls_order_interval_metrics-peak_seconds.
      <ls_order_summary>-exec_peak_concurrency_pct =
        ls_order_interval_metrics-peak_concurrency_pct.
      <ls_order_summary>-exec_peak_episode_count =
        ls_order_interval_metrics-peak_episode_count.
      <ls_order_summary>-exec_longest_peak_secs =
        ls_order_interval_metrics-longest_peak_secs.
      <ls_order_summary>-exec_peak_episode_avg_secs =
        ls_order_interval_metrics-peak_episode_avg_secs.
      <ls_order_summary>-exec_avg_concurrency =
        ls_order_interval_metrics-avg_concurrency.
      <ls_order_summary>-exec_longest_overlap_secs =
        ls_order_interval_metrics-longest_overlap_secs.
      <ls_order_summary>-exec_overlap_avg_secs =
        ls_order_interval_metrics-overlap_avg_secs.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_base_order_summaries.
    FIELD-SYMBOLS <ls_order_summary> TYPE ty_base_conf_order_summary.
    DATA lt_base_order_conf TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.

    LOOP AT it_operation_summaries INTO DATA(ls_operation_summary).
      READ TABLE rt_summaries ASSIGNING <ls_order_summary>
        WITH TABLE KEY
          production_order = ls_operation_summary-production_order
          base_quantity_unit = ls_operation_summary-base_quantity_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order   = ls_operation_summary-production_order
          order_category     = ls_operation_summary-order_category
          order_type         = ls_operation_summary-order_type
          base_quantity_unit = ls_operation_summary-base_quantity_unit
          first_posting_date = ls_operation_summary-first_posting_date
          last_posting_date  = ls_operation_summary-last_posting_date )
          INTO TABLE rt_summaries.
        READ TABLE rt_summaries ASSIGNING <ls_order_summary>
          WITH TABLE KEY
            production_order = ls_operation_summary-production_order
            base_quantity_unit = ls_operation_summary-base_quantity_unit.
      ELSE.
        IF ls_operation_summary-first_posting_date <
            <ls_order_summary>-first_posting_date.
          <ls_order_summary>-first_posting_date =
            ls_operation_summary-first_posting_date.
        ENDIF.
        IF ls_operation_summary-last_posting_date >
            <ls_order_summary>-last_posting_date.
          <ls_order_summary>-last_posting_date =
            ls_operation_summary-last_posting_date.
        ENDIF.
      ENDIF.

      ADD ls_operation_summary-confirmation_count TO
        <ls_order_summary>-confirmation_count.
      ADD ls_operation_summary-final_confirmation_count TO
        <ls_order_summary>-final_confirmation_count.
      ADD ls_operation_summary-partial_confirmation_count TO
        <ls_order_summary>-partial_confirmation_count.
      ADD ls_operation_summary-reversed_confirmation_count TO
        <ls_order_summary>-reversed_confirmation_count.
      <ls_order_summary>-yield_quantity_base_total =
        <ls_order_summary>-yield_quantity_base_total +
        ls_operation_summary-yield_quantity_base_total.
      <ls_order_summary>-rework_quantity_base_total =
        <ls_order_summary>-rework_quantity_base_total +
        ls_operation_summary-rework_quantity_base_total.
      <ls_order_summary>-scrap_quantity_base_total =
        <ls_order_summary>-scrap_quantity_base_total +
        ls_operation_summary-scrap_quantity_base_total.
      <ls_order_summary>-yield_base_non_reversed_total =
        <ls_order_summary>-yield_base_non_reversed_total +
        ls_operation_summary-yield_base_non_reversed_total.
      <ls_order_summary>-rework_base_non_reversed_total =
        <ls_order_summary>-rework_base_non_reversed_total +
        ls_operation_summary-rework_base_non_reversed_total.
      <ls_order_summary>-scrap_base_non_reversed_total =
        <ls_order_summary>-scrap_base_non_reversed_total +
        ls_operation_summary-scrap_base_non_reversed_total.
    ENDLOOP.

    LOOP AT it_base_quantities INTO DATA(ls_base_quantity).
      DATA(ls_confirmation) = ls_base_quantity-confirmation_row.
      READ TABLE rt_summaries ASSIGNING <ls_order_summary>
        WITH TABLE KEY
          production_order = ls_confirmation-production_order
          base_quantity_unit = ls_base_quantity-base_quantity_unit.
      IF sy-subrc = 0.
        CALL METHOD me->update_conf_execution_metrics
          EXPORTING
            is_confirmation = ls_confirmation
          CHANGING
            cv_execution_start_count       =
              <ls_order_summary>-execution_start_count
            cv_first_execution_start_date  =
              <ls_order_summary>-first_execution_start_date
            cv_first_execution_start_time  =
              <ls_order_summary>-first_execution_start_time
            cv_execution_finish_count      =
              <ls_order_summary>-execution_finish_count
            cv_last_execution_finish_date  =
              <ls_order_summary>-last_execution_finish_date
            cv_last_execution_finish_time  =
              <ls_order_summary>-last_execution_finish_time
            cv_duration_count              =
              <ls_order_summary>-exec_duration_count
            cv_zero_duration_count         =
              <ls_order_summary>-zero_exec_duration_count
            cv_invalid_duration_count      =
              <ls_order_summary>-invalid_exec_duration_count
            cv_duration_seconds            =
              <ls_order_summary>-exec_duration_seconds_total
            cv_duration_seconds_min        =
              <ls_order_summary>-exec_duration_seconds_min
            cv_duration_seconds_max        =
              <ls_order_summary>-exec_duration_seconds_max.
      ENDIF.
    ENDLOOP.
    LOOP AT rt_summaries ASSIGNING <ls_order_summary>.
      DATA(ls_base_order_exec_pct) =
        calc_exec_coverage_pct(
          iv_confirmation_count     =
            <ls_order_summary>-confirmation_count
          iv_execution_start_count  =
            <ls_order_summary>-execution_start_count
          iv_execution_finish_count =
            <ls_order_summary>-execution_finish_count
          iv_duration_count         =
            <ls_order_summary>-exec_duration_count
          iv_zero_duration_count    =
            <ls_order_summary>-zero_exec_duration_count
          iv_invalid_duration_count =
            <ls_order_summary>-invalid_exec_duration_count ).
      <ls_order_summary>-execution_start_pct =
        ls_base_order_exec_pct-execution_start_pct.
      <ls_order_summary>-execution_finish_pct =
        ls_base_order_exec_pct-execution_finish_pct.
      <ls_order_summary>-valid_exec_duration_pct =
        ls_base_order_exec_pct-valid_exec_duration_pct.
      <ls_order_summary>-invalid_exec_duration_pct =
        ls_base_order_exec_pct-invalid_exec_duration_pct.
      <ls_order_summary>-missing_exec_duration_count =
        ls_base_order_exec_pct-missing_exec_duration_count.
      <ls_order_summary>-missing_exec_duration_pct =
        ls_base_order_exec_pct-missing_exec_duration_pct.
      <ls_order_summary>-zero_exec_duration_count =
        ls_base_order_exec_pct-zero_exec_duration_count.
      <ls_order_summary>-zero_exec_duration_pct =
        ls_base_order_exec_pct-zero_exec_duration_pct.
      <ls_order_summary>-exec_duration_seconds_avg =
        calc_exec_duration_avg(
          iv_duration_count         =
            <ls_order_summary>-exec_duration_count
          iv_duration_seconds_total =
            <ls_order_summary>-exec_duration_seconds_total ).
      DATA(ls_base_order_percentages) = calculate_conf_percentages(
        iv_confirmation_count = <ls_order_summary>-confirmation_count
        iv_final_count        = <ls_order_summary>-final_confirmation_count
        iv_partial_count      = <ls_order_summary>-partial_confirmation_count
        iv_reversed_count     = <ls_order_summary>-reversed_confirmation_count ).
      <ls_order_summary>-final_confirmation_pct =
        ls_base_order_percentages-final_confirmation_pct.
      <ls_order_summary>-partial_confirmation_pct =
        ls_base_order_percentages-partial_confirmation_pct.
      <ls_order_summary>-reversed_confirmation_pct =
        ls_base_order_percentages-reversed_confirmation_pct.
      CLEAR lt_base_order_conf.
      LOOP AT it_base_quantities INTO DATA(ls_union_base_ord_qty).
        IF ls_union_base_ord_qty-base_quantity_unit =
            <ls_order_summary>-base_quantity_unit
            AND ls_union_base_ord_qty-confirmation_row-production_order =
              <ls_order_summary>-production_order.
          APPEND ls_union_base_ord_qty-confirmation_row
            TO lt_base_order_conf.
        ENDIF.
      ENDLOOP.
      DATA(ls_base_order_interval_metrics) = calc_exec_interval_metrics(
        it_confirmations    = lt_base_order_conf
        iv_production_order = <ls_order_summary>-production_order ).
      <ls_order_summary>-exec_covered_seconds =
        ls_base_order_interval_metrics-covered_seconds.
      <ls_order_summary>-exec_duration_seconds_median =
        ls_base_order_interval_metrics-duration_median_seconds.

      <ls_order_summary>-exec_duration_seconds_p90 =
        ls_base_order_interval_metrics-duration_p90_seconds.
      <ls_order_summary>-exec_duration_seconds_p95 =
        ls_base_order_interval_metrics-duration_p95_seconds.
      <ls_order_summary>-exec_duration_seconds_p99 =
        ls_base_order_interval_metrics-duration_p99_seconds.
      <ls_order_summary>-exec_duration_seconds_p25 =
        ls_base_order_interval_metrics-duration_p25_seconds.
      <ls_order_summary>-exec_duration_seconds_p75 =
        ls_base_order_interval_metrics-duration_p75_seconds.
      <ls_order_summary>-exec_duration_seconds_iqr =
        ls_base_order_interval_metrics-duration_iqr_seconds.
      <ls_order_summary>-exec_duration_seconds_mad =
        ls_base_order_interval_metrics-duration_mad_seconds.
      <ls_order_summary>-exec_nonrev_min_secs =
        ls_base_order_interval_metrics-nonrev_min_seconds.
      <ls_order_summary>-exec_nonrev_max_secs =
        ls_base_order_interval_metrics-nonrev_max_seconds.
      <ls_order_summary>-exec_reversed_min_secs =
        ls_base_order_interval_metrics-reversed_min_seconds.
      <ls_order_summary>-exec_reversed_max_secs =
        ls_base_order_interval_metrics-reversed_max_seconds.
      <ls_order_summary>-exec_nonrev_median_secs =
        ls_base_order_interval_metrics-nonrev_duration_median_secs.
      <ls_order_summary>-exec_reversed_median_secs =
        ls_base_order_interval_metrics-reversed_duration_median_secs.
      <ls_order_summary>-exec_nonrev_p90_secs =
        ls_base_order_interval_metrics-nonrev_p90_seconds.
      <ls_order_summary>-exec_reversed_p90_secs =
        ls_base_order_interval_metrics-reversed_p90_seconds.
      <ls_order_summary>-exec_duration_p90_median_ratio =
        ls_base_order_interval_metrics-duration_p90_median_ratio.
      <ls_order_summary>-exec_nonrev_p90_median_ratio =
        ls_base_order_interval_metrics-nonrev_p90_median_ratio.
      <ls_order_summary>-exec_reversed_p90_median_ratio =
        ls_base_order_interval_metrics-reversed_p90_median_ratio.
      <ls_order_summary>-exec_duration_p90_exceed_count =
        ls_base_order_interval_metrics-duration_p90_exceed_count.
      <ls_order_summary>-exec_duration_p90_exceed_pct =
        ls_base_order_interval_metrics-duration_p90_exceed_pct.
      <ls_order_summary>-exec_nonrev_p90_exceed_count =
        ls_base_order_interval_metrics-nonrev_p90_exceed_count.
      <ls_order_summary>-exec_nonrev_p90_exceed_pct =
        ls_base_order_interval_metrics-nonrev_p90_exceed_pct.
      <ls_order_summary>-exec_reversed_p90_exceed_count =
        ls_base_order_interval_metrics-reversed_p90_exceed_count.
      <ls_order_summary>-exec_reversed_p90_exceed_pct =
        ls_base_order_interval_metrics-reversed_p90_exceed_pct.
      <ls_order_summary>-exec_p90_tail_secs =
        ls_base_order_interval_metrics-p90_tail_secs.
      <ls_order_summary>-exec_p90_tail_pct =
        ls_base_order_interval_metrics-p90_tail_pct.
      <ls_order_summary>-exec_nonrev_p90_tail_secs =
        ls_base_order_interval_metrics-nonrev_p90_tail_secs.
      <ls_order_summary>-exec_nonrev_p90_tail_pct =
        ls_base_order_interval_metrics-nonrev_p90_tail_pct.
      <ls_order_summary>-exec_reversed_p90_tail_secs =
        ls_base_order_interval_metrics-reversed_p90_tail_secs.
      <ls_order_summary>-exec_reversed_p90_tail_pct =
        ls_base_order_interval_metrics-reversed_p90_tail_pct.
      <ls_order_summary>-exec_nonrev_p95_secs =
        ls_base_order_interval_metrics-nonrev_p95_seconds.
      <ls_order_summary>-exec_reversed_p95_secs =
        ls_base_order_interval_metrics-reversed_p95_seconds.
      <ls_order_summary>-exec_duration_p95_median_ratio =
        ls_base_order_interval_metrics-duration_p95_median_ratio.
      <ls_order_summary>-exec_nonrev_p95_median_ratio =
        ls_base_order_interval_metrics-nonrev_p95_median_ratio.
      <ls_order_summary>-exec_reversed_p95_median_ratio =
        ls_base_order_interval_metrics-reversed_p95_median_ratio.
      <ls_order_summary>-exec_duration_p95_exceed_count =
        ls_base_order_interval_metrics-duration_p95_exceed_count.
      <ls_order_summary>-exec_duration_p95_exceed_pct =
        ls_base_order_interval_metrics-duration_p95_exceed_pct.
      <ls_order_summary>-exec_nonrev_p95_exceed_count =
        ls_base_order_interval_metrics-nonrev_p95_exceed_count.
      <ls_order_summary>-exec_nonrev_p95_exceed_pct =
        ls_base_order_interval_metrics-nonrev_p95_exceed_pct.
      <ls_order_summary>-exec_reversed_p95_exceed_count =
        ls_base_order_interval_metrics-reversed_p95_exceed_count.
      <ls_order_summary>-exec_reversed_p95_exceed_pct =
        ls_base_order_interval_metrics-reversed_p95_exceed_pct.
      <ls_order_summary>-exec_p95_tail_secs =
        ls_base_order_interval_metrics-p95_tail_secs.
      <ls_order_summary>-exec_p95_tail_pct =
        ls_base_order_interval_metrics-p95_tail_pct.
      <ls_order_summary>-exec_nonrev_p95_tail_secs =
        ls_base_order_interval_metrics-nonrev_p95_tail_secs.
      <ls_order_summary>-exec_nonrev_p95_tail_pct =
        ls_base_order_interval_metrics-nonrev_p95_tail_pct.
      <ls_order_summary>-exec_reversed_p95_tail_secs =
        ls_base_order_interval_metrics-reversed_p95_tail_secs.
      <ls_order_summary>-exec_reversed_p95_tail_pct =
        ls_base_order_interval_metrics-reversed_p95_tail_pct.
      <ls_order_summary>-exec_duration_p99_exceed_count =
        ls_base_order_interval_metrics-duration_p99_exceed_count.
      <ls_order_summary>-exec_duration_p99_exceed_pct =
        ls_base_order_interval_metrics-duration_p99_exceed_pct.
      <ls_order_summary>-exec_nonrev_p99_exceed_count =
        ls_base_order_interval_metrics-nonrev_p99_exceed_count.
      <ls_order_summary>-exec_nonrev_p99_exceed_pct =
        ls_base_order_interval_metrics-nonrev_p99_exceed_pct.
      <ls_order_summary>-exec_reversed_p99_exceed_count =
        ls_base_order_interval_metrics-reversed_p99_exceed_count.
      <ls_order_summary>-exec_reversed_p99_exceed_pct =
        ls_base_order_interval_metrics-reversed_p99_exceed_pct.
      <ls_order_summary>-exec_p99_tail_secs =
        ls_base_order_interval_metrics-p99_tail_secs.
      <ls_order_summary>-exec_p99_tail_pct =
        ls_base_order_interval_metrics-p99_tail_pct.
      <ls_order_summary>-exec_nonrev_p99_tail_secs =
        ls_base_order_interval_metrics-nonrev_p99_tail_secs.
      <ls_order_summary>-exec_nonrev_p99_tail_pct =
        ls_base_order_interval_metrics-nonrev_p99_tail_pct.
      <ls_order_summary>-exec_reversed_p99_tail_secs =
        ls_base_order_interval_metrics-reversed_p99_tail_secs.
      <ls_order_summary>-exec_reversed_p99_tail_pct =
        ls_base_order_interval_metrics-reversed_p99_tail_pct.
      <ls_order_summary>-exec_duration_p99_median_ratio =
        ls_base_order_interval_metrics-duration_p99_median_ratio.
      <ls_order_summary>-exec_nonrev_p99_median_ratio =
        ls_base_order_interval_metrics-nonrev_p99_median_ratio.
      <ls_order_summary>-exec_reversed_p99_median_ratio =
        ls_base_order_interval_metrics-reversed_p99_median_ratio.
      <ls_order_summary>-exec_nonrev_p99_secs =
        ls_base_order_interval_metrics-nonrev_p99_seconds.
      <ls_order_summary>-exec_reversed_p99_secs =
        ls_base_order_interval_metrics-reversed_p99_seconds.
      <ls_order_summary>-exec_nonrev_iqr_secs =
        ls_base_order_interval_metrics-nonrev_iqr_seconds.
      <ls_order_summary>-exec_nonrev_p25_secs =
        ls_base_order_interval_metrics-nonrev_p25_seconds.
      <ls_order_summary>-exec_nonrev_p75_secs =
        ls_base_order_interval_metrics-nonrev_p75_seconds.
      <ls_order_summary>-exec_reversed_p25_secs =
        ls_base_order_interval_metrics-reversed_p25_seconds.
      <ls_order_summary>-exec_reversed_p75_secs =
        ls_base_order_interval_metrics-reversed_p75_seconds.
      <ls_order_summary>-exec_reversed_iqr_secs =
        ls_base_order_interval_metrics-reversed_iqr_seconds.
      <ls_order_summary>-exec_duration_iqr_median_ratio =
        ls_base_order_interval_metrics-duration_iqr_median_ratio.
      <ls_order_summary>-exec_nonrev_iqr_median_ratio =
        ls_base_order_interval_metrics-nonrev_iqr_median_ratio.
      <ls_order_summary>-exec_reversed_iqr_median_ratio =
        ls_base_order_interval_metrics-reversed_iqr_median_ratio.
      <ls_order_summary>-exec_nonrev_mad_secs =
        ls_base_order_interval_metrics-nonrev_mad_seconds.
      <ls_order_summary>-exec_reversed_mad_secs =
        ls_base_order_interval_metrics-reversed_mad_seconds.
      <ls_order_summary>-exec_duration_mad_median_ratio =
        ls_base_order_interval_metrics-duration_mad_median_ratio.
      <ls_order_summary>-exec_nonrev_mad_median_ratio =
        ls_base_order_interval_metrics-nonrev_mad_median_ratio.
      <ls_order_summary>-exec_reversed_mad_median_ratio =
        ls_base_order_interval_metrics-reversed_mad_median_ratio.
      <ls_order_summary>-exec_duration_avg_median_ratio =
        ls_base_order_interval_metrics-duration_avg_median_ratio.
      <ls_order_summary>-exec_nonrev_avg_median_ratio =
        ls_base_order_interval_metrics-nonrev_avg_median_ratio.
      <ls_order_summary>-exec_reversed_avg_median_ratio =
        ls_base_order_interval_metrics-reversed_avg_median_ratio.
      <ls_order_summary>-exec_pos_duration_count =
        ls_base_order_interval_metrics-positive_duration_count.
      <ls_order_summary>-exec_pos_median_secs =
        ls_base_order_interval_metrics-positive_median_secs.
      <ls_order_summary>-exec_pos_p90_secs =
        ls_base_order_interval_metrics-positive_p90_secs.
      <ls_order_summary>-exec_nonrev_pos_count =
        ls_base_order_interval_metrics-nonrev_positive_count.
      <ls_order_summary>-exec_nonrev_pos_median_secs =
        ls_base_order_interval_metrics-nonrev_positive_median_secs.
      <ls_order_summary>-exec_nonrev_pos_p90_secs =
        ls_base_order_interval_metrics-nonrev_positive_p90_secs.
      <ls_order_summary>-exec_reversed_pos_count =
        ls_base_order_interval_metrics-reversed_positive_count.
      <ls_order_summary>-exec_pos_duration_pct =
        ls_base_order_interval_metrics-positive_pct.
      <ls_order_summary>-exec_nonrev_pos_duration_pct =
        ls_base_order_interval_metrics-nonrev_pos_pct.
      <ls_order_summary>-exec_reversed_pos_duration_pct =
        ls_base_order_interval_metrics-rev_pos_pct.
      <ls_order_summary>-exec_pos_valid_pct =
        ls_base_order_interval_metrics-pos_valid_pct.
      <ls_order_summary>-exec_nonrev_pos_valid_pct =
        ls_base_order_interval_metrics-nonrev_pos_valid_pct.
      <ls_order_summary>-exec_rev_pos_valid_pct =
        ls_base_order_interval_metrics-rev_pos_valid_pct.
      <ls_order_summary>-exec_zero_valid_pct =
        ls_base_order_interval_metrics-zero_valid_pct.
      <ls_order_summary>-exec_nonrev_zero_valid_pct =
        ls_base_order_interval_metrics-nonrev_zero_valid_pct.
      <ls_order_summary>-exec_rev_zero_valid_pct =
        ls_base_order_interval_metrics-rev_zero_valid_pct.
      <ls_order_summary>-exec_zero_valid_count =
        ls_base_order_interval_metrics-zero_valid_count.
      <ls_order_summary>-exec_nonrev_zero_valid_count =
        ls_base_order_interval_metrics-nonrev_zero_valid_count.
      <ls_order_summary>-exec_rev_zero_valid_count =
        ls_base_order_interval_metrics-rev_zero_valid_count.
      <ls_order_summary>-exec_nonrev_invalid_count =
        ls_base_order_interval_metrics-nonrev_invalid_count.
      <ls_order_summary>-exec_rev_invalid_count =
        ls_base_order_interval_metrics-rev_invalid_count.
      <ls_order_summary>-exec_nonrev_missing_count =
        ls_base_order_interval_metrics-nonrev_missing_count.
      <ls_order_summary>-exec_rev_missing_count =
        ls_base_order_interval_metrics-rev_missing_count.
      <ls_order_summary>-exec_nonrev_valid_pct =
        ls_base_order_interval_metrics-nonrev_valid_pct.
      <ls_order_summary>-exec_rev_valid_pct =
        ls_base_order_interval_metrics-rev_valid_pct.
      <ls_order_summary>-exec_nonrev_invalid_pct =
        ls_base_order_interval_metrics-nonrev_invalid_pct.
      <ls_order_summary>-exec_rev_invalid_pct =
        ls_base_order_interval_metrics-rev_invalid_pct.
      <ls_order_summary>-exec_nonrev_missing_pct =
        ls_base_order_interval_metrics-nonrev_missing_pct.
      <ls_order_summary>-exec_rev_missing_pct =
        ls_base_order_interval_metrics-rev_missing_pct.
      <ls_order_summary>-exec_top_issue_code =
        ls_base_order_interval_metrics-top_issue_code.
      <ls_order_summary>-exec_top_issue_status =
        ls_base_order_interval_metrics-top_issue_status.
      <ls_order_summary>-exec_top_issue_count =
        ls_base_order_interval_metrics-top_issue_count.
      <ls_order_summary>-exec_top_issue_pct =
        ls_base_order_interval_metrics-top_issue_pct.
      <ls_order_summary>-exec_top_invalid_issue_code =
        ls_base_order_interval_metrics-top_invalid_issue_code.
      <ls_order_summary>-exec_top_invalid_issue_count =
        ls_base_order_interval_metrics-top_invalid_issue_count.
      <ls_order_summary>-exec_top_invalid_share_pct =
        ls_base_order_interval_metrics-top_invalid_share_pct.
      <ls_order_summary>-exec_top_missing_issue_code =
        ls_base_order_interval_metrics-top_missing_issue_code.
      <ls_order_summary>-exec_top_missing_issue_count =
        ls_base_order_interval_metrics-top_missing_issue_count.
      <ls_order_summary>-exec_top_missing_share_pct =
        ls_base_order_interval_metrics-top_missing_share_pct.
      <ls_order_summary>-exec_top_nonrev_issue_code =
        ls_base_order_interval_metrics-top_nonrev_issue_code.
      <ls_order_summary>-exec_top_nonrev_issue_status =
        ls_base_order_interval_metrics-top_nonrev_issue_status.
      <ls_order_summary>-exec_top_nonrev_issue_count =
        ls_base_order_interval_metrics-top_nonrev_issue_count.
      <ls_order_summary>-exec_top_nonrev_issue_pct =
        ls_base_order_interval_metrics-top_nonrev_issue_pct.
      <ls_order_summary>-exec_top_reversed_issue_code =
        ls_base_order_interval_metrics-top_reversed_issue_code.
      <ls_order_summary>-exec_top_reversed_issue_status =
        ls_base_order_interval_metrics-top_reversed_issue_status.
      <ls_order_summary>-exec_top_reversed_issue_count =
        ls_base_order_interval_metrics-top_reversed_issue_count.
      <ls_order_summary>-exec_top_reversed_issue_pct =
        ls_base_order_interval_metrics-top_reversed_issue_pct.
      <ls_order_summary>-exec_duration_issue_counts =
        ls_base_order_interval_metrics-issue_counts.
      <ls_order_summary>-exec_reversed_pos_median_secs =
        ls_base_order_interval_metrics-reversed_positive_median_secs.
      <ls_order_summary>-exec_reversed_pos_p90_secs =
        ls_base_order_interval_metrics-reversed_positive_p90_secs.
      <ls_order_summary>-exec_pos_p90_med_ratio =
        ls_base_order_interval_metrics-pos_p90_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_p90_med_ratio =
        ls_base_order_interval_metrics-nonrev_pos_p90_med_ratio.
      <ls_order_summary>-exec_rev_pos_p90_med_ratio =
        ls_base_order_interval_metrics-reversed_pos_p90_med_ratio.
      <ls_order_summary>-exec_pos_p90_gt_count =
        ls_base_order_interval_metrics-pos_p90_gt_count.
      <ls_order_summary>-exec_pos_p90_gt_pct =
        ls_base_order_interval_metrics-pos_p90_gt_pct.
      <ls_order_summary>-exec_pos_p90_tail_secs =
        ls_base_order_interval_metrics-pos_p90_tail_secs.
      <ls_order_summary>-exec_pos_p90_tail_pct =
        ls_base_order_interval_metrics-pos_p90_tail_pct.
      <ls_order_summary>-exec_nonrev_pos_p90_gt_count =
        ls_base_order_interval_metrics-nonrev_pos_p90_gt_count.
      <ls_order_summary>-exec_nonrev_pos_p90_gt_pct =
        ls_base_order_interval_metrics-nonrev_pos_p90_gt_pct.
      <ls_order_summary>-exec_nonrev_pos_p90_tail_secs =
        ls_base_order_interval_metrics-nonrev_pos_p90_tail_secs.
      <ls_order_summary>-exec_nonrev_pos_p90_tail_pct =
        ls_base_order_interval_metrics-nonrev_pos_p90_tail_pct.
      <ls_order_summary>-exec_rev_pos_p90_gt_count =
        ls_base_order_interval_metrics-rev_pos_p90_gt_count.
      <ls_order_summary>-exec_rev_pos_p90_gt_pct =
        ls_base_order_interval_metrics-rev_pos_p90_gt_pct.
      <ls_order_summary>-exec_rev_pos_p90_tail_secs =
        ls_base_order_interval_metrics-rev_pos_p90_tail_secs.
      <ls_order_summary>-exec_rev_pos_p90_tail_pct =
        ls_base_order_interval_metrics-rev_pos_p90_tail_pct.
      <ls_order_summary>-exec_pos_p95_secs =
        ls_base_order_interval_metrics-positive_p95_secs.
      <ls_order_summary>-exec_pos_p99_secs =
        ls_base_order_interval_metrics-positive_p99_secs.
      <ls_order_summary>-exec_nonrev_pos_p95_secs =
        ls_base_order_interval_metrics-nonrev_positive_p95_secs.
      <ls_order_summary>-exec_nonrev_pos_p99_secs =
        ls_base_order_interval_metrics-nonrev_positive_p99_secs.
      <ls_order_summary>-exec_rev_pos_p95_secs =
        ls_base_order_interval_metrics-reversed_positive_p95_secs.
      <ls_order_summary>-exec_rev_pos_p99_secs =
        ls_base_order_interval_metrics-reversed_positive_p99_secs.
      <ls_order_summary>-exec_pos_p25_secs =
        ls_base_order_interval_metrics-positive_p25_secs.
      <ls_order_summary>-exec_pos_p75_secs =
        ls_base_order_interval_metrics-positive_p75_secs.
      <ls_order_summary>-exec_nonrev_pos_p25_secs =
        ls_base_order_interval_metrics-nonrev_positive_p25_secs.
      <ls_order_summary>-exec_nonrev_pos_p75_secs =
        ls_base_order_interval_metrics-nonrev_positive_p75_secs.
      <ls_order_summary>-exec_rev_pos_p25_secs =
        ls_base_order_interval_metrics-reversed_positive_p25_secs.
      <ls_order_summary>-exec_rev_pos_p75_secs =
        ls_base_order_interval_metrics-reversed_positive_p75_secs.
      <ls_order_summary>-exec_pos_iqr_secs =
        ls_base_order_interval_metrics-positive_iqr_secs.
      <ls_order_summary>-exec_nonrev_pos_iqr_secs =
        ls_base_order_interval_metrics-nonrev_positive_iqr_secs.
      <ls_order_summary>-exec_rev_pos_iqr_secs =
        ls_base_order_interval_metrics-reversed_positive_iqr_secs.
      <ls_order_summary>-exec_pos_mad_secs =
        ls_base_order_interval_metrics-positive_mad_secs.
      <ls_order_summary>-exec_nonrev_pos_mad_secs =
        ls_base_order_interval_metrics-nonrev_positive_mad_secs.
      <ls_order_summary>-exec_rev_pos_mad_secs =
        ls_base_order_interval_metrics-reversed_positive_mad_secs.
      <ls_order_summary>-exec_pos_iqr_med_ratio =
        ls_base_order_interval_metrics-positive_iqr_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_iqr_med_ratio =
        ls_base_order_interval_metrics-nonrev_positive_iqr_med_ratio.
      <ls_order_summary>-exec_rev_pos_iqr_med_ratio =
        ls_base_order_interval_metrics-reversed_pos_iqr_med_ratio.
      <ls_order_summary>-exec_pos_mad_med_ratio =
        ls_base_order_interval_metrics-positive_mad_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_mad_med_ratio =
        ls_base_order_interval_metrics-nonrev_positive_mad_med_ratio.
      <ls_order_summary>-exec_rev_pos_mad_med_ratio =
        ls_base_order_interval_metrics-reversed_pos_mad_med_ratio.
      <ls_order_summary>-exec_pos_avg_secs =
        ls_base_order_interval_metrics-pos_avg_secs.
      <ls_order_summary>-exec_nonrev_pos_avg_secs =
        ls_base_order_interval_metrics-nonrev_pos_avg_secs.
      <ls_order_summary>-exec_rev_pos_avg_secs =
        ls_base_order_interval_metrics-rev_pos_avg_secs.
      <ls_order_summary>-exec_pos_avg_med_ratio =
        ls_base_order_interval_metrics-pos_avg_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_avg_med_ratio =
        ls_base_order_interval_metrics-nonrev_pos_avg_med_ratio.
      <ls_order_summary>-exec_rev_pos_avg_med_ratio =
        ls_base_order_interval_metrics-rev_pos_avg_med_ratio.
      <ls_order_summary>-exec_pos_min_secs =
        ls_base_order_interval_metrics-positive_min_secs.
      <ls_order_summary>-exec_pos_max_secs =
        ls_base_order_interval_metrics-positive_max_secs.
      <ls_order_summary>-exec_pos_range_secs =
        ls_base_order_interval_metrics-positive_range_secs.
      <ls_order_summary>-exec_nonrev_pos_min_secs =
        ls_base_order_interval_metrics-nonrev_positive_min_secs.
      <ls_order_summary>-exec_nonrev_pos_max_secs =
        ls_base_order_interval_metrics-nonrev_positive_max_secs.
      <ls_order_summary>-exec_nonrev_pos_range_secs =
        ls_base_order_interval_metrics-nonrev_positive_range_secs.
      <ls_order_summary>-exec_rev_pos_min_secs =
        ls_base_order_interval_metrics-reversed_positive_min_secs.
      <ls_order_summary>-exec_rev_pos_max_secs =
        ls_base_order_interval_metrics-reversed_positive_max_secs.
      <ls_order_summary>-exec_rev_pos_range_secs =
        ls_base_order_interval_metrics-reversed_positive_range_secs.
      <ls_order_summary>-exec_pos_p95_gt_count =
        ls_base_order_interval_metrics-pos_p95_gt_count.
      <ls_order_summary>-exec_pos_p95_gt_pct =
        ls_base_order_interval_metrics-pos_p95_gt_pct.
      <ls_order_summary>-exec_pos_p95_tail_secs =
        ls_base_order_interval_metrics-pos_p95_tail_secs.
      <ls_order_summary>-exec_pos_p95_tail_pct =
        ls_base_order_interval_metrics-pos_p95_tail_pct.
      <ls_order_summary>-exec_nonrev_pos_p95_gt_count =
        ls_base_order_interval_metrics-nonrev_pos_p95_gt_count.
      <ls_order_summary>-exec_nonrev_pos_p95_gt_pct =
        ls_base_order_interval_metrics-nonrev_pos_p95_gt_pct.
      <ls_order_summary>-exec_nonrev_pos_p95_tail_secs =
        ls_base_order_interval_metrics-nonrev_pos_p95_tail_secs.
      <ls_order_summary>-exec_nonrev_pos_p95_tail_pct =
        ls_base_order_interval_metrics-nonrev_pos_p95_tail_pct.
      <ls_order_summary>-exec_rev_pos_p95_gt_count =
        ls_base_order_interval_metrics-rev_pos_p95_gt_count.
      <ls_order_summary>-exec_rev_pos_p95_gt_pct =
        ls_base_order_interval_metrics-rev_pos_p95_gt_pct.
      <ls_order_summary>-exec_rev_pos_p95_tail_secs =
        ls_base_order_interval_metrics-rev_pos_p95_tail_secs.
      <ls_order_summary>-exec_rev_pos_p95_tail_pct =
        ls_base_order_interval_metrics-rev_pos_p95_tail_pct.
      <ls_order_summary>-exec_pos_p99_gt_count =
        ls_base_order_interval_metrics-pos_p99_gt_count.
      <ls_order_summary>-exec_pos_p99_gt_pct =
        ls_base_order_interval_metrics-pos_p99_gt_pct.
      <ls_order_summary>-exec_pos_p99_tail_secs =
        ls_base_order_interval_metrics-pos_p99_tail_secs.
      <ls_order_summary>-exec_pos_p99_tail_pct =
        ls_base_order_interval_metrics-pos_p99_tail_pct.
      <ls_order_summary>-exec_nonrev_pos_p99_gt_count =
        ls_base_order_interval_metrics-nonrev_pos_p99_gt_count.
      <ls_order_summary>-exec_nonrev_pos_p99_gt_pct =
        ls_base_order_interval_metrics-nonrev_pos_p99_gt_pct.
      <ls_order_summary>-exec_nonrev_pos_p99_tail_secs =
        ls_base_order_interval_metrics-nonrev_pos_p99_tail_secs.
      <ls_order_summary>-exec_nonrev_pos_p99_tail_pct =
        ls_base_order_interval_metrics-nonrev_pos_p99_tail_pct.
      <ls_order_summary>-exec_rev_pos_p99_gt_count =
        ls_base_order_interval_metrics-rev_pos_p99_gt_count.
      <ls_order_summary>-exec_rev_pos_p99_gt_pct =
        ls_base_order_interval_metrics-rev_pos_p99_gt_pct.
      <ls_order_summary>-exec_rev_pos_p99_tail_secs =
        ls_base_order_interval_metrics-rev_pos_p99_tail_secs.
      <ls_order_summary>-exec_rev_pos_p99_tail_pct =
        ls_base_order_interval_metrics-rev_pos_p99_tail_pct.
      <ls_order_summary>-exec_pos_p95_med_ratio =
        ls_base_order_interval_metrics-pos_p95_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_p95_med_ratio =
        ls_base_order_interval_metrics-nonrev_pos_p95_med_ratio.
      <ls_order_summary>-exec_rev_pos_p95_med_ratio =
        ls_base_order_interval_metrics-rev_pos_p95_med_ratio.
      <ls_order_summary>-exec_pos_p99_med_ratio =
        ls_base_order_interval_metrics-pos_p99_med_ratio.
      <ls_order_summary>-exec_nonrev_pos_p99_med_ratio =
        ls_base_order_interval_metrics-nonrev_pos_p99_med_ratio.
      <ls_order_summary>-exec_rev_pos_p99_med_ratio =
        ls_base_order_interval_metrics-rev_pos_p99_med_ratio.
      <ls_order_summary>-exec_nonrev_covered_secs =
        ls_base_order_interval_metrics-nonrev_covered_seconds.
      <ls_order_summary>-exec_nonrev_duration_count =
        ls_base_order_interval_metrics-nonrev_duration_count.
      <ls_order_summary>-exec_nonrev_total_secs =
        ls_base_order_interval_metrics-nonrev_duration_total.
      <ls_order_summary>-exec_nonrev_duration_avg_secs =
        ls_base_order_interval_metrics-nonrev_duration_avg_secs.
      <ls_order_summary>-exec_nonrev_excess_secs =
        ls_base_order_interval_metrics-nonrev_excess_secs.
      <ls_order_summary>-exec_reversed_duration_count =
        ls_base_order_interval_metrics-reversed_duration_count.
      <ls_order_summary>-exec_reversed_total_secs =
        ls_base_order_interval_metrics-reversed_duration_total.
      <ls_order_summary>-exec_rev_duration_avg_secs =
        ls_base_order_interval_metrics-reversed_avg_secs.
      <ls_order_summary>-exec_reversed_covered_secs =
        ls_base_order_interval_metrics-reversed_covered_seconds.
      <ls_order_summary>-exec_reversed_excess_secs =
        ls_base_order_interval_metrics-reversed_excess_secs.
      <ls_order_summary>-exec_nonrev_duration_pct =
        ls_base_order_interval_metrics-nonrev_duration_pct.
      <ls_order_summary>-exec_reversed_duration_pct =
        ls_base_order_interval_metrics-reversed_duration_pct.
      <ls_order_summary>-exec_single_active_seconds =
        ls_base_order_interval_metrics-single_active_seconds.
      <ls_order_summary>-exec_single_episode_count =
        ls_base_order_interval_metrics-single_episode_count.
      <ls_order_summary>-exec_longest_single_secs =
        ls_base_order_interval_metrics-longest_single_secs.
      <ls_order_summary>-exec_single_active_avg_secs =
        ls_base_order_interval_metrics-single_active_avg_secs.
      <ls_order_summary>-exec_high_concurrency_secs =
        ls_base_order_interval_metrics-high_concurrency_seconds.
      <ls_order_summary>-exec_exactly_two_secs =
        ls_base_order_interval_metrics-exactly_two_seconds.
      <ls_order_summary>-exec_exactly_two_pct =
        ls_base_order_interval_metrics-exactly_two_pct.
      <ls_order_summary>-exec_3plus_episode_count =
        ls_base_order_interval_metrics-three_plus_episode_count.
      <ls_order_summary>-exec_longest_3plus_secs =
        ls_base_order_interval_metrics-longest_three_plus_secs.
      <ls_order_summary>-exec_3plus_avg_secs =
        ls_base_order_interval_metrics-three_plus_avg_secs.
      <ls_order_summary>-exec_3plus_pct =
        ls_base_order_interval_metrics-three_plus_pct.
      <ls_order_summary>-exec_overlap_excess_seconds =
        ls_base_order_interval_metrics-overlap_excess_seconds.
      <ls_order_summary>-exec_peak_concurrency =
        ls_base_order_interval_metrics-peak_concurrency.
      <ls_order_summary>-exec_idle_gap_seconds =
        ls_base_order_interval_metrics-idle_gap_seconds.
      <ls_order_summary>-exec_idle_gap_episode_count =
        ls_base_order_interval_metrics-idle_gap_episode_count.
      <ls_order_summary>-exec_idle_gap_avg_secs =
        ls_base_order_interval_metrics-idle_gap_avg_secs.
      <ls_order_summary>-exec_interval_coverage_pct =
        ls_base_order_interval_metrics-interval_coverage_pct.
      <ls_order_summary>-exec_single_active_pct =
        ls_base_order_interval_metrics-single_active_pct.
      <ls_order_summary>-exec_overlap_wall_pct =
        ls_base_order_interval_metrics-overlap_wall_pct.
      <ls_order_summary>-exec_longest_idle_gap_secs =
        ls_base_order_interval_metrics-longest_idle_gap_secs.
      <ls_order_summary>-exec_overlap_wall_seconds =
        ls_base_order_interval_metrics-overlap_wall_seconds.
      <ls_order_summary>-exec_pairwise_overlap_secs =
        ls_base_order_interval_metrics-pairwise_overlap_seconds.
      <ls_order_summary>-exec_overlap_episode_count =
        ls_base_order_interval_metrics-overlap_episode_count.
      <ls_order_summary>-exec_overlap_pair_count =
        ls_base_order_interval_metrics-overlap_pair_count.
      <ls_order_summary>-exec_overlap_pair_avg_secs =
        ls_base_order_interval_metrics-overlap_pair_avg_secs.
      <ls_order_summary>-exec_longest_pair_overlap_secs =
        ls_base_order_interval_metrics-longest_pair_overlap_secs.
      <ls_order_summary>-exec_peak_concurrency_secs =
        ls_base_order_interval_metrics-peak_seconds.
      <ls_order_summary>-exec_peak_concurrency_pct =
        ls_base_order_interval_metrics-peak_concurrency_pct.
      <ls_order_summary>-exec_peak_episode_count =
        ls_base_order_interval_metrics-peak_episode_count.
      <ls_order_summary>-exec_longest_peak_secs =
        ls_base_order_interval_metrics-longest_peak_secs.
      <ls_order_summary>-exec_peak_episode_avg_secs =
        ls_base_order_interval_metrics-peak_episode_avg_secs.
      <ls_order_summary>-exec_avg_concurrency =
        ls_base_order_interval_metrics-avg_concurrency.
      <ls_order_summary>-exec_longest_overlap_secs =
        ls_base_order_interval_metrics-longest_overlap_secs.
      <ls_order_summary>-exec_overlap_avg_secs =
        ls_base_order_interval_metrics-overlap_avg_secs.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_orders_bulk.
    DATA(lo_quantity_calculator) = NEW zcl_prod_order_qty_calc( ).
    DATA lv_snapshot_timestamp TYPE timestampl.
    rs_result-is_successful = abap_true.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers( it_production_orders = it_production_orders ).
    DATA(lt_order_items) = mo_repository->read_orders(
      it_production_orders = it_production_orders ).
    DATA(lt_order_statuses) = mo_repository->read_order_statuses(
      it_production_orders = it_production_orders ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
    validate_order_read_results(
      it_production_orders = it_production_orders
      it_order_items       = lt_order_items
      it_order_statuses    = lt_order_statuses ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      LOOP AT lt_order_items INTO DATA(ls_order_item)
          WHERE production_order = lv_production_order.
        DATA(ls_item_result) = VALUE ty_item_result(
          order_item = ls_order_item ).
        APPEND ls_item_result TO <ls_order_result>-items.
        ASSIGN <ls_order_result>-items[ lines(
          <ls_order_result>-items ) ] TO FIELD-SYMBOL(<ls_item_result>).

        IF <ls_order_result>-is_found <> abap_true.
          <ls_order_result>-is_found = abap_true.
          ADD 1 TO rs_result-found_count.
        ENDIF.

        IF ls_order_item-order_quantity > 0
            AND ls_order_item-received_quantity >= 0.
          <ls_item_result>-is_receipt_progress_valid = abap_true.
          DATA(lv_order_quantity) =
            CONV decfloat34( ls_order_item-order_quantity ).
          DATA(lv_received_quantity) =
            CONV decfloat34( ls_order_item-received_quantity ).
          <ls_item_result>-received_pct_of_order_qty =
            lv_received_quantity * 100 / lv_order_quantity.
          IF ls_order_item-received_quantity = 0.
            <ls_item_result>-receipt_progress_status =
              c_receipt_progress_not_started.
            <ls_item_result>-open_quantity_order_unit =
              lv_order_quantity.
            <ls_item_result>-open_pct_of_order_qty = 100.
          ELSEIF ls_order_item-received_quantity <
              ls_order_item-order_quantity.
            <ls_item_result>-receipt_progress_status =
              c_receipt_progress_partial.
            <ls_item_result>-open_quantity_order_unit =
              lv_order_quantity - lv_received_quantity.
            <ls_item_result>-open_pct_of_order_qty =
              <ls_item_result>-open_quantity_order_unit * 100
              / lv_order_quantity.
          ELSEIF ls_order_item-received_quantity >
              ls_order_item-order_quantity.
            <ls_item_result>-receipt_progress_status =
              c_receipt_over_received.
            <ls_item_result>-over_receipt_qty_order_unit =
              lv_received_quantity - lv_order_quantity.
            <ls_item_result>-over_receipt_pct_of_order_qty =
              <ls_item_result>-over_receipt_qty_order_unit * 100
                / lv_order_quantity.
          ELSE.
            <ls_item_result>-receipt_progress_status =
              c_receipt_progress_complete.
          ENDIF.
        ELSE.
          <ls_item_result>-is_receipt_progress_valid = abap_false.
        ENDIF.

        CASE <ls_item_result>-receipt_progress_status.
          WHEN c_receipt_progress_not_started.
            ADD 1 TO rs_result-receipt_progress_counts-not_started_item_count.
            ADD 1 TO
              <ls_order_result>-receipt_progress_counts-not_started_item_count.
          WHEN c_receipt_progress_partial.
            ADD 1 TO rs_result-receipt_progress_counts-partial_item_count.
            ADD 1 TO
              <ls_order_result>-receipt_progress_counts-partial_item_count.
          WHEN c_receipt_progress_complete.
            ADD 1 TO rs_result-receipt_progress_counts-complete_item_count.
            ADD 1 TO
              <ls_order_result>-receipt_progress_counts-complete_item_count.
          WHEN c_receipt_over_received.
            ADD 1 TO rs_result-receipt_progress_counts-over_received_item_count.
            ADD 1 TO
              <ls_order_result>-receipt_progress_counts-over_received_item_count.
          WHEN OTHERS.
            ADD 1 TO rs_result-receipt_progress_counts-invalid_item_count.
            ADD 1 TO
              <ls_order_result>-receipt_progress_counts-invalid_item_count.
        ENDCASE.

        IF ls_order_item-order_unit IS INITIAL
            OR ls_order_item-base_unit IS INITIAL
            OR ls_order_item-order_quantity < 0
            OR ls_order_item-received_quantity < 0
            OR ls_order_item-order_to_base_numerator <= 0
            OR ls_order_item-order_to_base_denominator <= 0.
          rs_result-is_successful = abap_false.
          ADD 1 TO rs_result-conversion_failed_count.
          ADD 1 TO <ls_order_result>-conversion_failed_count.
          CONTINUE.
        ENDIF.

        <ls_item_result>-order_quantity_base =
          lo_quantity_calculator->calculate_base_quantity(
            iv_quantity            = ls_order_item-order_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-received_quantity_base =
          lo_quantity_calculator->calculate_base_quantity(
            iv_quantity            = ls_order_item-received_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        <ls_item_result>-open_quantity_base =
          lo_quantity_calculator->calculate_open_base_quantity(
            iv_order_quantity      = ls_order_item-order_quantity
            iv_received_quantity   = ls_order_item-received_quantity
            iv_order_to_base_num   =
              ls_order_item-order_to_base_numerator
            iv_order_to_base_denom =
              ls_order_item-order_to_base_denominator ).
        IF <ls_item_result>-is_receipt_progress_valid = abap_true
            AND ls_order_item-received_quantity >
              ls_order_item-order_quantity.
          <ls_item_result>-over_receipt_quantity_base =
            lo_quantity_calculator->calculate_base_quantity(
              iv_quantity            = ls_order_item-received_quantity
                - ls_order_item-order_quantity
              iv_order_to_base_num   =
                ls_order_item-order_to_base_numerator
              iv_order_to_base_denom =
                ls_order_item-order_to_base_denominator ).
        ENDIF.
        <ls_item_result>-is_quantity_converted = abap_true.
        ADD 1 TO rs_result-conversion_succeeded_count.
        ADD 1 TO <ls_order_result>-conversion_succeeded_count.
      ENDLOOP.
      calculate_progress_shares(
        CHANGING cs_counts = <ls_order_result>-receipt_progress_counts ).

      LOOP AT lt_order_statuses INTO DATA(ls_order_status)
          WHERE production_order = lv_production_order.
        APPEND VALUE #(
          status_code       = ls_order_status-status_code
          is_user_status    = ls_order_status-is_user_status
          status_short_name = ls_order_status-status_short_name
          status_name       = ls_order_status-status_name )
          TO <ls_order_result>-statuses.
      ENDLOOP.

      IF <ls_order_result>-is_found <> abap_true.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-not_found_count.
      ENDIF.
    ENDLOOP.
    calculate_progress_shares(
      CHANGING cs_counts = rs_result-receipt_progress_counts ).
  ENDMETHOD.

  METHOD read_orders_by_finish_window.
    DATA lt_order_keys TYPE
      zif_prod_order_read_repo=>ty_finish_search_keys.
    DATA lt_production_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA lv_is_truncated TYPE abap_bool.
    DATA lv_last_index TYPE i.
    DATA lv_key_selection_timestamp TYPE timestampl.
    DATA ls_last_key TYPE zif_prod_order_read_repo=>ty_finish_search_key.
    DATA lv_finish_filter_matches TYPE abap_bool.
    DATA lv_finish_item_index TYPE i.

    validate_order_selection( is_selection = is_selection ).
    lt_order_keys = mo_repository->read_orders_by_finish_window(
      is_selection = is_selection ).
    GET TIME STAMP FIELD lv_key_selection_timestamp.
    validate_finish_window_keys(
      is_selection  = is_selection
      it_order_keys = lt_order_keys ).

    IF lines( lt_order_keys ) > is_selection-maximum_results.
      lv_is_truncated = abap_true.
      DELETE lt_order_keys INDEX is_selection-maximum_results + 1.
    ENDIF.

    LOOP AT lt_order_keys INTO DATA(ls_order_key).
      APPEND ls_order_key-production_order TO lt_production_orders.
    ENDLOOP.

    rs_result = read_orders_bulk(
      it_production_orders = lt_production_orders ).
    LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_finish_order>).
      CLEAR lv_finish_filter_matches.
      LOOP AT <ls_finish_order>-items INTO DATA(ls_finish_item).
        lv_finish_item_index = sy-tabix.
        IF ls_finish_item-order_item-material = is_selection-material
            AND ls_finish_item-order_item-plant = is_selection-plant
            AND ( ( is_selection-filter_planning_plant = abap_false
                  AND is_selection-planning_plant IS INITIAL )
              OR ls_finish_item-order_item-planning_plant =
                is_selection-planning_plant )
            AND ( ( is_selection-filter_delivery_plant = abap_false
                  AND is_selection-delivery_plant IS INITIAL )
              OR ls_finish_item-order_item-delivery_plant =
                is_selection-delivery_plant )
            AND ( ( is_selection-filter_special_stock = abap_false
                  AND is_selection-special_stock_indicator IS INITIAL )
              OR ls_finish_item-order_item-special_stock_indicator =
                is_selection-special_stock_indicator )
            AND ( ( is_selection-filter_stock_type = abap_false
                  AND is_selection-stock_type IS INITIAL )
              OR ls_finish_item-order_item-stock_type =
                is_selection-stock_type )
            AND ( ( is_selection-filter_goods_recipient = abap_false
                  AND is_selection-goods_recipient IS INITIAL )
              OR ls_finish_item-order_item-goods_recipient =
                is_selection-goods_recipient )
            AND ( ( is_selection-filter_unloading_point = abap_false
                  AND is_selection-unloading_point IS INITIAL )
              OR ls_finish_item-order_item-unloading_point =
                is_selection-unloading_point )
            AND ( ( is_selection-filter_production_version = abap_false
                  AND is_selection-production_version IS INITIAL )
              OR ls_finish_item-order_item-production_version =
                is_selection-production_version )
            AND ( ( is_selection-filter_plan_start_date = abap_false
                  AND is_selection-planned_order_start_date IS INITIAL )
              OR ls_finish_item-order_item-planned_order_start_date =
                is_selection-planned_order_start_date )
            AND ( ( is_selection-filter_sales_order = abap_false
                  AND is_selection-sales_order IS INITIAL )
              OR ls_finish_item-order_item-sales_order =
                is_selection-sales_order )
            AND ( ( is_selection-filter_sales_order_item = abap_false
                  AND is_selection-sales_order_item IS INITIAL )
              OR ls_finish_item-order_item-sales_order_item =
                is_selection-sales_order_item )
            AND ( ( is_selection-filter_sales_schedule_line = abap_false
                  AND is_selection-sales_order_schedule_line IS INITIAL )
              OR ls_finish_item-order_item-sales_order_schedule_line =
                is_selection-sales_order_schedule_line )
            AND ( ( is_selection-filter_planned_order = abap_false
                  AND is_selection-planned_order IS INITIAL )
              OR ls_finish_item-order_item-planned_order =
                is_selection-planned_order )
            AND ( ( is_selection-filter_storage_location = abap_false
                  AND is_selection-storage_location IS INITIAL )
              OR ls_finish_item-order_item-storage_location =
                is_selection-storage_location )
            AND ( ( is_selection-filter_batch = abap_false
                  AND is_selection-batch IS INITIAL )
              OR ls_finish_item-order_item-batch = is_selection-batch )
            AND ( ( is_selection-filter_assignment_category = abap_false
                  AND is_selection-account_assignment_category IS INITIAL )
              OR ls_finish_item-order_item-account_assignment_category =
                is_selection-account_assignment_category )
            AND ( ( is_selection-filter_mrp_area = abap_false
                  AND is_selection-mrp_area IS INITIAL )
              OR ls_finish_item-order_item-mrp_area = is_selection-mrp_area )
            AND ( ( is_selection-filter_wbs_element = abap_false
                  AND is_selection-wbs_element IS INITIAL )
              OR ( is_selection-wbs_element IS INITIAL
                AND ls_finish_item-order_item-wbs_element_internal_id IS INITIAL )
              OR ls_finish_item-order_item-wbs_element =
                is_selection-wbs_element )
            AND ( is_selection-production_item IS INITIAL
              OR ls_finish_item-order_item-production_item =
                is_selection-production_item )
            AND ( is_selection-order_unit IS INITIAL
              OR ls_finish_item-order_item-order_unit =
                is_selection-order_unit )
            AND ( ls_finish_item-order_item-order_category = '10'
              OR ls_finish_item-order_item-order_category = '40' )
            AND ( is_selection-order_category IS INITIAL
              OR ls_finish_item-order_item-order_category =
                is_selection-order_category )
            AND ( is_selection-order_type IS INITIAL
              OR ls_finish_item-order_item-order_type =
                is_selection-order_type )
            AND ( ( is_selection-filter_order_description = abap_false
                  AND is_selection-order_description IS INITIAL )
              OR ls_finish_item-order_item-order_description =
                is_selection-order_description )
            AND ( ( is_selection-filter_order_created_by = abap_false
                  AND is_selection-order_created_by IS INITIAL )
              OR ls_finish_item-order_item-order_created_by =
                is_selection-order_created_by )
            AND ( ( is_selection-filter_order_changed_by = abap_false
                  AND is_selection-order_changed_by IS INITIAL )
              OR ls_finish_item-order_item-order_changed_by =
                is_selection-order_changed_by )
            AND ( is_selection-required_phase IS INITIAL
              OR ( is_selection-required_phase = '1'
                AND ls_finish_item-order_item-phase_1_indicator = abap_true )
              OR ( is_selection-required_phase = '2'
                AND ls_finish_item-order_item-phase_2_indicator = abap_true )
              OR ( is_selection-required_phase = '3'
                AND ls_finish_item-order_item-phase_3_indicator = abap_true ) )
            AND ( is_selection-created_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date = ls_finish_item-order_item-created_date )
                  = abap_true
                AND ls_finish_item-order_item-created_date >=
                  is_selection-created_date_from
                AND ls_finish_item-order_item-created_date <=
                  is_selection-created_date_to ) )
            AND ( is_selection-changed_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date = ls_finish_item-order_item-changed_date )
                  = abap_true
                AND ls_finish_item-order_item-changed_date >=
                  is_selection-changed_date_from
                AND ls_finish_item-order_item-changed_date <=
                  is_selection-changed_date_to ) )
            AND ( is_selection-exclude_deleted = abap_false
              OR ( ls_finish_item-order_item-order_deletion_indicator
                    IS INITIAL
                AND ls_finish_item-order_item-item_deletion_indicator
                    IS INITIAL ) )
            AND ( is_selection-receipt_expected_only = abap_false
              OR ls_finish_item-order_item-receipt_expected = abap_true )
            AND ( is_selection-receipt_not_expected_only = abap_false
              OR ls_finish_item-order_item-receipt_expected IS INITIAL )
            AND ( is_selection-delivery_complete_only = abap_false
              OR ls_finish_item-order_item-delivery_complete = abap_true )
            AND ( is_selection-delivery_not_complete_only = abap_false
              OR ls_finish_item-order_item-delivery_complete IS INITIAL )
            AND ( is_selection-unreceived_quantity_only = abap_false
              OR ls_finish_item-order_item-order_quantity >
                ls_finish_item-order_item-received_quantity )
            AND ( is_selection-filter_receipt_progress_status = abap_false
              OR ls_finish_item-receipt_progress_status =
                is_selection-receipt_progress_status )
            AND ( is_selection-filter_order_qty_from = abap_false
              OR ls_finish_item-order_item-order_quantity >=
                is_selection-order_qty_from )
            AND ( is_selection-filter_order_qty_to = abap_false
              OR ls_finish_item-order_item-order_quantity <=
                is_selection-order_qty_to )
            AND ( is_selection-filter_order_qty_base_from = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-order_quantity_base >=
                  is_selection-order_qty_base_from ) )
            AND ( is_selection-filter_order_qty_base_to = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-order_quantity_base <=
                  is_selection-order_qty_base_to ) )
            AND ( is_selection-filter_received_qty_from = abap_false
              OR ls_finish_item-order_item-received_quantity >=
                is_selection-received_qty_from )
            AND ( is_selection-filter_received_qty_to = abap_false
              OR ls_finish_item-order_item-received_quantity <=
                is_selection-received_qty_to )
            AND ( is_selection-filter_over_receipt_qty_from = abap_false
              OR ( ls_finish_item-is_receipt_progress_valid = abap_true
                AND ls_finish_item-over_receipt_qty_order_unit >=
                  is_selection-over_receipt_qty_from ) )
            AND ( is_selection-filter_over_receipt_qty_to = abap_false
              OR ( ls_finish_item-is_receipt_progress_valid = abap_true
                AND ls_finish_item-over_receipt_qty_order_unit <=
                  is_selection-over_receipt_qty_to ) )
            AND ( is_selection-filter_over_receipt_pct_from = abap_false
              OR ( ls_finish_item-is_receipt_progress_valid = abap_true
                AND ( is_selection-over_receipt_pct_from = 0
                  OR ( ls_finish_item-order_item-received_quantity >
                        ls_finish_item-order_item-order_quantity
                    AND ls_finish_item-order_item-received_quantity * 100
                        - ls_finish_item-order_item-order_quantity * 100 >=
                      is_selection-over_receipt_pct_from
                        * ls_finish_item-order_item-order_quantity ) ) ) )
            AND ( is_selection-filter_over_receipt_pct_to = abap_false
              OR ( ls_finish_item-is_receipt_progress_valid = abap_true
                AND ( ls_finish_item-order_item-received_quantity <=
                      ls_finish_item-order_item-order_quantity
                  OR ls_finish_item-order_item-received_quantity * 100
                      - ls_finish_item-order_item-order_quantity * 100 <=
                    is_selection-over_receipt_pct_to
                      * ls_finish_item-order_item-order_quantity ) ) )
            AND ( is_selection-filter_received_qty_base_from = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-received_quantity_base >=
                  is_selection-received_qty_base_from ) )
            AND ( is_selection-filter_received_qty_base_to = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-received_quantity_base <=
                  is_selection-received_qty_base_to ) )
            AND ( is_selection-filter_over_rcpt_qty_base_from = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-is_receipt_progress_valid = abap_true
                AND ls_finish_item-over_receipt_quantity_base >=
                  is_selection-over_rcpt_qty_base_from ) )
            AND ( is_selection-filter_over_rcpt_qty_base_to = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-is_receipt_progress_valid = abap_true
                AND ls_finish_item-over_receipt_quantity_base <=
                  is_selection-over_rcpt_qty_base_to ) )
            AND ( is_selection-filter_unrecv_qty_base_from = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-open_quantity_base >=
                  is_selection-unrecv_qty_base_from ) )
            AND ( is_selection-filter_unrecv_qty_base_to = abap_false
              OR ( ls_finish_item-is_quantity_converted = abap_true
                AND ls_finish_item-open_quantity_base <=
                  is_selection-unrecv_qty_base_to ) )
            AND ( is_selection-filter_received_pct_from = abap_false
              OR ( ls_finish_item-order_item-order_quantity > 0
                AND ls_finish_item-order_item-received_quantity >= 0
                AND ls_finish_item-order_item-received_quantity * 100 >=
                  is_selection-received_pct_from
                    * ls_finish_item-order_item-order_quantity ) )
            AND ( is_selection-filter_received_pct_to = abap_false
              OR ( ls_finish_item-order_item-order_quantity > 0
                AND ls_finish_item-order_item-received_quantity >= 0
                AND ls_finish_item-order_item-received_quantity * 100 <=
                  is_selection-received_pct_to
                    * ls_finish_item-order_item-order_quantity ) )
            AND ( is_selection-filter_unreceived_qty_from =
                abap_false
              OR ( ls_finish_item-order_item-order_quantity >
                  ls_finish_item-order_item-received_quantity
                AND ls_finish_item-order_item-order_quantity
                    - ls_finish_item-order_item-received_quantity >=
                  is_selection-unreceived_qty_from ) )
            AND ( is_selection-filter_unreceived_qty_to =
                abap_false
              OR ( ls_finish_item-order_item-order_quantity >
                  ls_finish_item-order_item-received_quantity
                AND ls_finish_item-order_item-order_quantity
                    - ls_finish_item-order_item-received_quantity <=
                  is_selection-unreceived_qty_to ) )
            AND ( is_selection-filter_unreceived_pct_from =
                abap_false
              OR ( ls_finish_item-order_item-order_quantity > 0
                AND ls_finish_item-order_item-received_quantity >= 0
                AND ( is_selection-unreceived_pct_from = 0
                  OR ( ls_finish_item-order_item-order_quantity >
                      ls_finish_item-order_item-received_quantity
                    AND ( ls_finish_item-order_item-order_quantity
                        - ls_finish_item-order_item-received_quantity ) * 100
                      >= is_selection-unreceived_pct_from
                        * ls_finish_item-order_item-order_quantity ) ) ) )
            AND ( is_selection-filter_unreceived_pct_to =
                abap_false
              OR ( ls_finish_item-order_item-order_quantity > 0
                AND ls_finish_item-order_item-received_quantity >= 0
                AND ( ls_finish_item-order_item-order_quantity <=
                    ls_finish_item-order_item-received_quantity
                  OR ( ls_finish_item-order_item-order_quantity >
                      ls_finish_item-order_item-received_quantity
                    AND ( ls_finish_item-order_item-order_quantity
                        - ls_finish_item-order_item-received_quantity ) * 100
                      <= is_selection-unreceived_pct_to
                        * ls_finish_item-order_item-order_quantity ) ) ) )
            AND zcl_date_validation=>is_valid_gregorian_date(
              iv_date = ls_finish_item-order_item-basic_finish_date )
              = abap_true
            AND ls_finish_item-order_item-basic_finish_date >=
              is_selection-finish_date_from
            AND ls_finish_item-order_item-basic_finish_date <=
              is_selection-finish_date_to
            AND ( is_selection-basic_start_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date =
                      ls_finish_item-order_item-basic_start_date )
                  = abap_true
                AND ls_finish_item-order_item-basic_start_date >=
                  is_selection-basic_start_date_from
                AND ls_finish_item-order_item-basic_start_date <=
                  is_selection-basic_start_date_to ) )
            AND ( ( is_selection-filter_basic_start_date = abap_false
                  AND is_selection-basic_start_date IS INITIAL )
              OR ls_finish_item-order_item-basic_start_date =
                is_selection-basic_start_date )
            AND ( is_selection-scheduled_finish_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date =
                      ls_finish_item-order_item-scheduled_finish_date )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_finish_date >=
                  is_selection-scheduled_finish_date_from
                AND ls_finish_item-order_item-scheduled_finish_date <=
                  is_selection-scheduled_finish_date_to ) )
            AND ( is_selection-scheduled_start_date_from IS INITIAL
              OR ( zcl_date_validation=>is_valid_gregorian_date(
                    iv_date =
                      ls_finish_item-order_item-scheduled_start_date )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_start_date >=
                  is_selection-scheduled_start_date_from
                AND ls_finish_item-order_item-scheduled_start_date <=
                  is_selection-scheduled_start_date_to ) )
            AND ( ( is_selection-filter_scheduled_start_date = abap_false
                  AND is_selection-scheduled_start_date IS INITIAL )
              OR ls_finish_item-order_item-scheduled_start_date =
                is_selection-scheduled_start_date )
            AND ( ( is_selection-filter_scheduled_finish_date = abap_false
                  AND is_selection-scheduled_finish_date IS INITIAL )
              OR ls_finish_item-order_item-scheduled_finish_date =
                is_selection-scheduled_finish_date )
            AND ( is_selection-filter_scheduled_start_time = abap_false
              OR ( zcl_date_validation=>is_valid_time(
                    iv_time =
                      ls_finish_item-order_item-scheduled_start_time )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_start_time >=
                  is_selection-scheduled_start_time_from
                AND ls_finish_item-order_item-scheduled_start_time <=
                  is_selection-scheduled_start_time_to ) )
            AND ( is_selection-filter_scheduled_finish_time = abap_false
              OR ( zcl_date_validation=>is_valid_time(
                    iv_time =
                      ls_finish_item-order_item-scheduled_finish_time )
                  = abap_true
                AND ls_finish_item-order_item-scheduled_finish_time >=
                  is_selection-scheduled_finish_time_from
                AND ls_finish_item-order_item-scheduled_finish_time <=
                  is_selection-scheduled_finish_time_to ) ).
          ASSIGN <ls_finish_order>-items[ lv_finish_item_index ]
            TO FIELD-SYMBOL(<ls_matching_finish_item>).
          <ls_matching_finish_item>-matches_finish_selection =
            abap_true.
          ADD 1 TO
            <ls_finish_order>-finish_window_match_count.
          IF <ls_matching_finish_item>-is_quantity_converted = abap_true.
            ADD 1 TO rs_result-finish_match_conv_ok_count.
            ADD 1 TO <ls_finish_order>-matching_conv_ok_count.
          ELSE.
            ADD 1 TO rs_result-finish_match_conv_fail_count.
            ADD 1 TO <ls_finish_order>-matching_conv_fail_count.
          ENDIF.
          IF <ls_matching_finish_item>-is_receipt_progress_valid <>
              abap_true.
            ADD 1 TO
              <ls_finish_order>-matching_base_qty_summary-invalid_progress_count.
          ELSEIF <ls_matching_finish_item>-is_quantity_converted <>
              abap_true.
            ADD 1 TO
              <ls_finish_order>-matching_base_qty_summary-valid_progress_conv_fail_count.
          ENDIF.
          IF <ls_matching_finish_item>-is_quantity_converted = abap_true
              AND <ls_matching_finish_item>-is_receipt_progress_valid =
                abap_true.
            ADD 1 TO
              <ls_finish_order>-matching_base_qty_summary-item_count.
            CASE <ls_matching_finish_item>-receipt_progress_status.
              WHEN c_receipt_progress_not_started.
                ADD 1 TO
                  <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-not_started_item_count.
              WHEN c_receipt_progress_partial.
                ADD 1 TO
                  <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-partial_item_count.
              WHEN c_receipt_progress_complete.
                ADD 1 TO
                  <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-complete_item_count.
              WHEN c_receipt_over_received.
                ADD 1 TO
                  <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-over_received_item_count.
              WHEN OTHERS.
                ADD 1 TO
                  <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-invalid_item_count.
            ENDCASE.
            collect_contrib_progress_qty(
              EXPORTING
              iv_progress_status =
                <ls_matching_finish_item>-receipt_progress_status
              is_item            = <ls_matching_finish_item>
              CHANGING
                cs_totals        =
                  <ls_finish_order>-matching_base_qty_summary-contributing_progress_qty ).
            <ls_finish_order>-matching_base_qty_summary-order_qty_base_total =
              <ls_finish_order>-matching_base_qty_summary-order_qty_base_total
              + <ls_matching_finish_item>-order_quantity_base.
            <ls_finish_order>-matching_base_qty_summary-received_qty_base_total =
              <ls_finish_order>-matching_base_qty_summary-received_qty_base_total
              + <ls_matching_finish_item>-received_quantity_base.
            <ls_finish_order>-matching_base_qty_summary-open_qty_base_total =
              <ls_finish_order>-matching_base_qty_summary-open_qty_base_total
              + <ls_matching_finish_item>-open_quantity_base.
            <ls_finish_order>-matching_base_qty_summary-over_rcpt_qty_base_total =
              <ls_finish_order>-matching_base_qty_summary-over_rcpt_qty_base_total
              + <ls_matching_finish_item>-over_receipt_quantity_base.
          ENDIF.
          lv_finish_filter_matches = abap_true.
          CASE ls_finish_item-receipt_progress_status.
            WHEN c_receipt_progress_not_started.
              ADD 1 TO
                rs_result-finish_match_progress_counts-not_started_item_count.
              ADD 1 TO
                <ls_finish_order>-matching_progress_counts-not_started_item_count.
            WHEN c_receipt_progress_partial.
              ADD 1 TO
                rs_result-finish_match_progress_counts-partial_item_count.
              ADD 1 TO
                <ls_finish_order>-matching_progress_counts-partial_item_count.
            WHEN c_receipt_progress_complete.
              ADD 1 TO
                rs_result-finish_match_progress_counts-complete_item_count.
              ADD 1 TO
                <ls_finish_order>-matching_progress_counts-complete_item_count.
            WHEN c_receipt_over_received.
              ADD 1 TO
                rs_result-finish_match_progress_counts-over_received_item_count.
              ADD 1 TO
                <ls_finish_order>-matching_progress_counts-over_received_item_count.
            WHEN OTHERS.
              ADD 1 TO
                rs_result-finish_match_progress_counts-invalid_item_count.
              ADD 1 TO
                <ls_finish_order>-matching_progress_counts-invalid_item_count.
          ENDCASE.
        ENDIF.
      ENDLOOP.
      <ls_finish_order>-matching_base_qty_summary-excluded_item_count =
        <ls_finish_order>-matching_base_qty_summary-invalid_progress_count
        + <ls_finish_order>-matching_base_qty_summary-valid_progress_conv_fail_count.
      calc_finish_base_qty_shares(
        CHANGING
          cs_summary =
            <ls_finish_order>-matching_base_qty_summary ).
      calculate_progress_shares(
        CHANGING
          cs_counts =
            <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts ).
      rs_result-finish_match_base_qty_summary-item_count =
        rs_result-finish_match_base_qty_summary-item_count
        + <ls_finish_order>-matching_base_qty_summary-item_count.
      rs_result-finish_match_base_qty_summary-contributing_progress_counts-not_started_item_count =
        rs_result-finish_match_base_qty_summary-contributing_progress_counts-not_started_item_count
        + <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-not_started_item_count.
      rs_result-finish_match_base_qty_summary-contributing_progress_counts-partial_item_count =
        rs_result-finish_match_base_qty_summary-contributing_progress_counts-partial_item_count
        + <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-partial_item_count.
      rs_result-finish_match_base_qty_summary-contributing_progress_counts-complete_item_count =
        rs_result-finish_match_base_qty_summary-contributing_progress_counts-complete_item_count
        + <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-complete_item_count.
      rs_result-finish_match_base_qty_summary-contributing_progress_counts-over_received_item_count =
        rs_result-finish_match_base_qty_summary-contributing_progress_counts-over_received_item_count
        + <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-over_received_item_count.
      rs_result-finish_match_base_qty_summary-contributing_progress_counts-invalid_item_count =
        rs_result-finish_match_base_qty_summary-contributing_progress_counts-invalid_item_count
        + <ls_finish_order>-matching_base_qty_summary-contributing_progress_counts-invalid_item_count.
      collect_progress_qty_totals(
        EXPORTING
        is_source   =
          <ls_finish_order>-matching_base_qty_summary-contributing_progress_qty
        CHANGING
          cs_target =
            rs_result-finish_match_base_qty_summary-contributing_progress_qty ).
      rs_result-finish_match_base_qty_summary-excluded_item_count =
        rs_result-finish_match_base_qty_summary-excluded_item_count
        + <ls_finish_order>-matching_base_qty_summary-excluded_item_count.
      rs_result-finish_match_base_qty_summary-invalid_progress_count =
        rs_result-finish_match_base_qty_summary-invalid_progress_count
        + <ls_finish_order>-matching_base_qty_summary-invalid_progress_count.
      rs_result-finish_match_base_qty_summary-valid_progress_conv_fail_count =
        rs_result-finish_match_base_qty_summary-valid_progress_conv_fail_count
        + <ls_finish_order>-matching_base_qty_summary-valid_progress_conv_fail_count.
      rs_result-finish_match_base_qty_summary-order_qty_base_total =
        rs_result-finish_match_base_qty_summary-order_qty_base_total
        + <ls_finish_order>-matching_base_qty_summary-order_qty_base_total.
      rs_result-finish_match_base_qty_summary-received_qty_base_total =
        rs_result-finish_match_base_qty_summary-received_qty_base_total
        + <ls_finish_order>-matching_base_qty_summary-received_qty_base_total.
      rs_result-finish_match_base_qty_summary-open_qty_base_total =
        rs_result-finish_match_base_qty_summary-open_qty_base_total
        + <ls_finish_order>-matching_base_qty_summary-open_qty_base_total.
      rs_result-finish_match_base_qty_summary-over_rcpt_qty_base_total =
        rs_result-finish_match_base_qty_summary-over_rcpt_qty_base_total
        + <ls_finish_order>-matching_base_qty_summary-over_rcpt_qty_base_total.
      IF lv_finish_filter_matches <> abap_true.
        <ls_finish_order>-finish_filter_lost = abap_true.
        ADD 1 TO rs_result-finish_filter_lost_count.
      ENDIF.
      calculate_progress_shares(
        CHANGING cs_counts = <ls_finish_order>-matching_progress_counts ).
    ENDLOOP.
    calculate_progress_shares(
      CHANGING cs_counts = rs_result-finish_match_progress_counts ).
    calc_finish_base_qty_shares(
      CHANGING
        cs_summary = rs_result-finish_match_base_qty_summary ).
    calculate_progress_shares(
      CHANGING
        cs_counts =
          rs_result-finish_match_base_qty_summary-contributing_progress_counts ).
    IF is_selection-active_status_code IS NOT INITIAL
        OR is_selection-active_status_codes IS NOT INITIAL.
      LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_order_result>).
        DATA(lv_selected_status_found) = abap_false.
        IF is_selection-active_status_code IS NOT INITIAL.
          READ TABLE <ls_order_result>-statuses
            WITH KEY status_code = is_selection-active_status_code
            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_selected_status_found = abap_true.
          ENDIF.
        ELSE.
          LOOP AT is_selection-active_status_codes
              INTO DATA(lv_status_code).
            READ TABLE <ls_order_result>-statuses
              WITH KEY status_code = lv_status_code
              TRANSPORTING NO FIELDS.
            IF sy-subrc = 0.
              lv_selected_status_found = abap_true.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF lv_selected_status_found <> abap_true.
          <ls_order_result>-status_filter_lost = abap_true.
          ADD 1 TO rs_result-status_filter_lost_count.
        ENDIF.
      ENDLOOP.
    ENDIF.
    rs_result-is_truncated = lv_is_truncated.
    rs_result-key_selection_timestamp = lv_key_selection_timestamp.
    IF lv_is_truncated = abap_true.
      lv_last_index = lines( lt_order_keys ).
      READ TABLE lt_order_keys INTO ls_last_key INDEX lv_last_index.
      IF sy-subrc = 0.
        rs_result-next_finish_date = ls_last_key-basic_finish_date.
        rs_result-next_production_order = ls_last_key-production_order.
      ENDIF.
    ENDIF.
    GET TIME STAMP FIELD rs_result-snapshot_timestamp.
  ENDMETHOD.

  METHOD calculate_progress_shares.
    DATA(lv_total_count) =
      cs_counts-not_started_item_count
      + cs_counts-partial_item_count
      + cs_counts-complete_item_count
      + cs_counts-over_received_item_count
      + cs_counts-invalid_item_count.
    cs_counts-total_item_count = lv_total_count.
    IF lv_total_count = 0.
      RETURN.
    ENDIF.

    cs_counts-not_started_pct =
      CONV decfloat34( cs_counts-not_started_item_count ) * 100
      / lv_total_count.
    cs_counts-partial_pct =
      CONV decfloat34( cs_counts-partial_item_count ) * 100
      / lv_total_count.
    cs_counts-complete_pct =
      CONV decfloat34( cs_counts-complete_item_count ) * 100
      / lv_total_count.
    cs_counts-over_received_pct =
      CONV decfloat34( cs_counts-over_received_item_count ) * 100
      / lv_total_count.
    cs_counts-invalid_pct =
      CONV decfloat34( cs_counts-invalid_item_count ) * 100
      / lv_total_count.
  ENDMETHOD.

  METHOD calc_finish_base_qty_shares.
    DATA(lv_matching_count) =
      cs_summary-item_count + cs_summary-excluded_item_count.
    IF lv_matching_count > 0.
      cs_summary-contributing_item_pct =
        CONV decfloat34( cs_summary-item_count ) * 100
        / lv_matching_count.
      cs_summary-excluded_item_pct =
        CONV decfloat34( cs_summary-excluded_item_count ) * 100
        / lv_matching_count.
      cs_summary-invalid_progress_pct =
        CONV decfloat34( cs_summary-invalid_progress_count ) * 100
        / lv_matching_count.
      cs_summary-valid_progress_conv_fail_pct =
        CONV decfloat34( cs_summary-valid_progress_conv_fail_count ) * 100
        / lv_matching_count.
    ENDIF.

    IF cs_summary-excluded_item_count > 0.
      cs_summary-invalid_excluded_share_pct =
        CONV decfloat34( cs_summary-invalid_progress_count ) * 100
        / cs_summary-excluded_item_count.
      cs_summary-conv_fail_excluded_share_pct =
        CONV decfloat34( cs_summary-valid_progress_conv_fail_count ) * 100
        / cs_summary-excluded_item_count.
    ENDIF.

    calc_progress_qty_shares(
      EXPORTING
        iv_order_qty_total     = cs_summary-order_qty_base_total
        iv_received_qty_total  = cs_summary-received_qty_base_total
        iv_open_qty_total      = cs_summary-open_qty_base_total
        iv_over_rcpt_qty_total = cs_summary-over_rcpt_qty_base_total
      CHANGING
        cs_group               = cs_summary-contributing_progress_qty-not_started ).
    calc_progress_qty_shares(
      EXPORTING
        iv_order_qty_total     = cs_summary-order_qty_base_total
        iv_received_qty_total  = cs_summary-received_qty_base_total
        iv_open_qty_total      = cs_summary-open_qty_base_total
        iv_over_rcpt_qty_total = cs_summary-over_rcpt_qty_base_total
      CHANGING
        cs_group               = cs_summary-contributing_progress_qty-partial ).
    calc_progress_qty_shares(
      EXPORTING
        iv_order_qty_total     = cs_summary-order_qty_base_total
        iv_received_qty_total  = cs_summary-received_qty_base_total
        iv_open_qty_total      = cs_summary-open_qty_base_total
        iv_over_rcpt_qty_total = cs_summary-over_rcpt_qty_base_total
      CHANGING
        cs_group               = cs_summary-contributing_progress_qty-complete ).
    calc_progress_qty_shares(
      EXPORTING
        iv_order_qty_total     = cs_summary-order_qty_base_total
        iv_received_qty_total  = cs_summary-received_qty_base_total
        iv_open_qty_total      = cs_summary-open_qty_base_total
        iv_over_rcpt_qty_total = cs_summary-over_rcpt_qty_base_total
      CHANGING
        cs_group               = cs_summary-contributing_progress_qty-over_received ).
    calc_progress_qty_shares(
      EXPORTING
        iv_order_qty_total     = cs_summary-order_qty_base_total
        iv_received_qty_total  = cs_summary-received_qty_base_total
        iv_open_qty_total      = cs_summary-open_qty_base_total
        iv_over_rcpt_qty_total = cs_summary-over_rcpt_qty_base_total
      CHANGING
        cs_group               = cs_summary-contributing_progress_qty-invalid ).

    IF cs_summary-item_count = 0
        OR cs_summary-order_qty_base_total <= 0.
      RETURN.
    ENDIF.

    cs_summary-received_pct_of_order_qty =
      cs_summary-received_qty_base_total * 100
      / cs_summary-order_qty_base_total.
    cs_summary-open_pct_of_order_qty =
      cs_summary-open_qty_base_total * 100
      / cs_summary-order_qty_base_total.
    cs_summary-over_rcpt_pct_of_order_qty =
      cs_summary-over_rcpt_qty_base_total * 100
      / cs_summary-order_qty_base_total.
    IF cs_summary-received_qty_base_total <= 0.
      RETURN.
    ENDIF.
    cs_summary-over_rcpt_pct_of_received_qty =
      cs_summary-over_rcpt_qty_base_total * 100
      / cs_summary-received_qty_base_total.
  ENDMETHOD.

  METHOD calc_progress_qty_shares.
    IF iv_order_qty_total > 0.
      cs_group-order_qty_total_share_pct =
        cs_group-order_qty_base_total * 100 / iv_order_qty_total.
    ENDIF.
    IF iv_received_qty_total > 0.
      cs_group-received_qty_total_share_pct =
        cs_group-received_qty_base_total * 100 / iv_received_qty_total.
    ENDIF.
    IF iv_open_qty_total > 0.
      cs_group-open_qty_total_share_pct =
        cs_group-open_qty_base_total * 100 / iv_open_qty_total.
    ENDIF.
    IF iv_over_rcpt_qty_total > 0.
      cs_group-over_rcpt_qty_total_share_pct =
        cs_group-over_rcpt_qty_base_total * 100 / iv_over_rcpt_qty_total.
    ENDIF.
  ENDMETHOD.

  METHOD collect_contrib_progress_qty.
    CASE iv_progress_status.
      WHEN c_receipt_progress_not_started.
        cs_totals-not_started-order_qty_base_total =
          cs_totals-not_started-order_qty_base_total
          + is_item-order_quantity_base.
        cs_totals-not_started-received_qty_base_total =
          cs_totals-not_started-received_qty_base_total
          + is_item-received_quantity_base.
        cs_totals-not_started-open_qty_base_total =
          cs_totals-not_started-open_qty_base_total
          + is_item-open_quantity_base.
        cs_totals-not_started-over_rcpt_qty_base_total =
          cs_totals-not_started-over_rcpt_qty_base_total
          + is_item-over_receipt_quantity_base.
      WHEN c_receipt_progress_partial.
        cs_totals-partial-order_qty_base_total =
          cs_totals-partial-order_qty_base_total
          + is_item-order_quantity_base.
        cs_totals-partial-received_qty_base_total =
          cs_totals-partial-received_qty_base_total
          + is_item-received_quantity_base.
        cs_totals-partial-open_qty_base_total =
          cs_totals-partial-open_qty_base_total
          + is_item-open_quantity_base.
        cs_totals-partial-over_rcpt_qty_base_total =
          cs_totals-partial-over_rcpt_qty_base_total
          + is_item-over_receipt_quantity_base.
      WHEN c_receipt_progress_complete.
        cs_totals-complete-order_qty_base_total =
          cs_totals-complete-order_qty_base_total
          + is_item-order_quantity_base.
        cs_totals-complete-received_qty_base_total =
          cs_totals-complete-received_qty_base_total
          + is_item-received_quantity_base.
        cs_totals-complete-open_qty_base_total =
          cs_totals-complete-open_qty_base_total
          + is_item-open_quantity_base.
        cs_totals-complete-over_rcpt_qty_base_total =
          cs_totals-complete-over_rcpt_qty_base_total
          + is_item-over_receipt_quantity_base.
      WHEN c_receipt_over_received.
        cs_totals-over_received-order_qty_base_total =
          cs_totals-over_received-order_qty_base_total
          + is_item-order_quantity_base.
        cs_totals-over_received-received_qty_base_total =
          cs_totals-over_received-received_qty_base_total
          + is_item-received_quantity_base.
        cs_totals-over_received-open_qty_base_total =
          cs_totals-over_received-open_qty_base_total
          + is_item-open_quantity_base.
        cs_totals-over_received-over_rcpt_qty_base_total =
          cs_totals-over_received-over_rcpt_qty_base_total
          + is_item-over_receipt_quantity_base.
      WHEN OTHERS.
        cs_totals-invalid-order_qty_base_total =
          cs_totals-invalid-order_qty_base_total
          + is_item-order_quantity_base.
        cs_totals-invalid-received_qty_base_total =
          cs_totals-invalid-received_qty_base_total
          + is_item-received_quantity_base.
        cs_totals-invalid-open_qty_base_total =
          cs_totals-invalid-open_qty_base_total
          + is_item-open_quantity_base.
        cs_totals-invalid-over_rcpt_qty_base_total =
          cs_totals-invalid-over_rcpt_qty_base_total
          + is_item-over_receipt_quantity_base.
    ENDCASE.
  ENDMETHOD.

  METHOD collect_progress_qty_totals.
    cs_target-not_started-order_qty_base_total =
      cs_target-not_started-order_qty_base_total
      + is_source-not_started-order_qty_base_total.
    cs_target-not_started-received_qty_base_total =
      cs_target-not_started-received_qty_base_total
      + is_source-not_started-received_qty_base_total.
    cs_target-not_started-open_qty_base_total =
      cs_target-not_started-open_qty_base_total
      + is_source-not_started-open_qty_base_total.
    cs_target-not_started-over_rcpt_qty_base_total =
      cs_target-not_started-over_rcpt_qty_base_total
      + is_source-not_started-over_rcpt_qty_base_total.

    cs_target-partial-order_qty_base_total =
      cs_target-partial-order_qty_base_total
      + is_source-partial-order_qty_base_total.
    cs_target-partial-received_qty_base_total =
      cs_target-partial-received_qty_base_total
      + is_source-partial-received_qty_base_total.
    cs_target-partial-open_qty_base_total =
      cs_target-partial-open_qty_base_total
      + is_source-partial-open_qty_base_total.
    cs_target-partial-over_rcpt_qty_base_total =
      cs_target-partial-over_rcpt_qty_base_total
      + is_source-partial-over_rcpt_qty_base_total.

    cs_target-complete-order_qty_base_total =
      cs_target-complete-order_qty_base_total
      + is_source-complete-order_qty_base_total.
    cs_target-complete-received_qty_base_total =
      cs_target-complete-received_qty_base_total
      + is_source-complete-received_qty_base_total.
    cs_target-complete-open_qty_base_total =
      cs_target-complete-open_qty_base_total
      + is_source-complete-open_qty_base_total.
    cs_target-complete-over_rcpt_qty_base_total =
      cs_target-complete-over_rcpt_qty_base_total
      + is_source-complete-over_rcpt_qty_base_total.

    cs_target-over_received-order_qty_base_total =
      cs_target-over_received-order_qty_base_total
      + is_source-over_received-order_qty_base_total.
    cs_target-over_received-received_qty_base_total =
      cs_target-over_received-received_qty_base_total
      + is_source-over_received-received_qty_base_total.
    cs_target-over_received-open_qty_base_total =
      cs_target-over_received-open_qty_base_total
      + is_source-over_received-open_qty_base_total.
    cs_target-over_received-over_rcpt_qty_base_total =
      cs_target-over_received-over_rcpt_qty_base_total
      + is_source-over_received-over_rcpt_qty_base_total.

    cs_target-invalid-order_qty_base_total =
      cs_target-invalid-order_qty_base_total
      + is_source-invalid-order_qty_base_total.
    cs_target-invalid-received_qty_base_total =
      cs_target-invalid-received_qty_base_total
      + is_source-invalid-received_qty_base_total.
    cs_target-invalid-open_qty_base_total =
      cs_target-invalid-open_qty_base_total
      + is_source-invalid-open_qty_base_total.
    cs_target-invalid-over_rcpt_qty_base_total =
      cs_target-invalid-over_rcpt_qty_base_total
      + is_source-invalid-over_rcpt_qty_base_total.
  ENDMETHOD.

  METHOD calculate_conf_percentages.
    IF iv_confirmation_count = 0.
      RETURN.
    ENDIF.

    rs_percentages-final_confirmation_pct =
      CONV decfloat34( iv_final_count ) * 100
      / iv_confirmation_count.
    rs_percentages-partial_confirmation_pct =
      CONV decfloat34( iv_partial_count ) * 100
      / iv_confirmation_count.
    rs_percentages-reversed_confirmation_pct =
      CONV decfloat34( iv_reversed_count ) * 100
      / iv_confirmation_count.
  ENDMETHOD.

  METHOD calc_exec_coverage_pct.
    IF iv_confirmation_count = 0.
      RETURN.
    ENDIF.

    rs_exec_pct-execution_start_pct =
      CONV decfloat34( iv_execution_start_count ) * 100
      / iv_confirmation_count.
    rs_exec_pct-execution_finish_pct =
      CONV decfloat34( iv_execution_finish_count ) * 100
      / iv_confirmation_count.
    rs_exec_pct-valid_exec_duration_pct =
      CONV decfloat34( iv_duration_count ) * 100
      / iv_confirmation_count.
    rs_exec_pct-invalid_exec_duration_pct =
      CONV decfloat34( iv_invalid_duration_count ) * 100
      / iv_confirmation_count.
    rs_exec_pct-zero_exec_duration_pct =
      CONV decfloat34( iv_zero_duration_count ) * 100
      / iv_confirmation_count.
    rs_exec_pct-zero_exec_duration_count = iv_zero_duration_count.
    rs_exec_pct-missing_exec_duration_count =
      iv_confirmation_count - iv_duration_count -
      iv_invalid_duration_count.
    rs_exec_pct-missing_exec_duration_pct =
      CONV decfloat34( rs_exec_pct-missing_exec_duration_count ) * 100
      / iv_confirmation_count.
  ENDMETHOD.

  METHOD calc_exec_duration_avg.
    IF iv_duration_count = 0.
      RETURN.
    ENDIF.

    rv_average_seconds = iv_duration_seconds_total /
      CONV decfloat34( iv_duration_count ).
  ENDMETHOD.

  METHOD calc_exec_duration.
    IF is_confirmation-execution_start_date IS INITIAL
        OR is_confirmation-execution_finish_date IS INITIAL.
      rs_duration-status = c_exec_duration_missing.
      IF is_confirmation-execution_start_date IS INITIAL
          AND is_confirmation-execution_finish_date IS INITIAL.
        rs_duration-issue_code = 'MD'.
      ELSEIF is_confirmation-execution_start_date IS INITIAL.
        rs_duration-issue_code = 'MS'.
      ELSE.
        rs_duration-issue_code = 'MF'.
      ENDIF.
      RETURN.
    ENDIF.

    IF zcl_date_validation=>is_valid_gregorian_date(
        iv_date = is_confirmation-execution_start_date ) <> abap_true.
      rs_duration-issue_code = 'IS'.
    ELSEIF zcl_date_validation=>is_valid_gregorian_date(
        iv_date = is_confirmation-execution_finish_date ) <> abap_true.
      rs_duration-issue_code = 'IF'.
    ELSEIF zcl_date_validation=>is_valid_time(
        iv_time = is_confirmation-execution_start_time ) <> abap_true.
      rs_duration-issue_code = 'TS'.
    ELSEIF zcl_date_validation=>is_valid_time(
        iv_time = is_confirmation-execution_finish_time ) <> abap_true.
      rs_duration-issue_code = 'TF'.
    ENDIF.
    IF rs_duration-issue_code IS NOT INITIAL.
      rs_duration-status = c_exec_duration_invalid.
      RETURN.
    ENDIF.

    DATA(lv_start_hours) = CONV i(
      is_confirmation-execution_start_time+0(2) ).
    DATA(lv_start_minutes) = CONV i(
      is_confirmation-execution_start_time+2(2) ).
    DATA(lv_start_seconds) = CONV i(
      is_confirmation-execution_start_time+4(2) ).
    DATA(lv_start_day_seconds) =
      lv_start_hours * 3600 + lv_start_minutes * 60 +
      lv_start_seconds.
    DATA(lv_finish_hours) = CONV i(
      is_confirmation-execution_finish_time+0(2) ).
    DATA(lv_finish_minutes) = CONV i(
      is_confirmation-execution_finish_time+2(2) ).
    DATA(lv_finish_seconds) = CONV i(
      is_confirmation-execution_finish_time+4(2) ).
    DATA(lv_finish_day_seconds) =
      lv_finish_hours * 3600 + lv_finish_minutes * 60 +
      lv_finish_seconds.
    rs_duration-duration_seconds =
      CONV decfloat34(
        is_confirmation-execution_finish_date -
        is_confirmation-execution_start_date ) * 86400
      + lv_finish_day_seconds - lv_start_day_seconds.

    IF rs_duration-duration_seconds < 0.
      rs_duration-status = c_exec_duration_invalid.
      rs_duration-issue_code = 'NE'.
    ELSE.
      rs_duration-status = c_exec_duration_valid.
    ENDIF.
  ENDMETHOD.

  METHOD calc_exec_duration_median.
    DATA(lv_duration_count) = lines( it_duration_values ).
    IF lv_duration_count > 0.
      IF lv_duration_count MOD 2 = 1.
        DATA(lv_middle_index) = CONV i(
          ( lv_duration_count + 1 ) / 2 ).
        rv_median_seconds = it_duration_values[ lv_middle_index ].
      ELSE.
        DATA(lv_left_middle_index) = CONV i(
          lv_duration_count / 2 ).
        DATA(lv_right_middle_index) = lv_left_middle_index + 1.
        rv_median_seconds =
          ( it_duration_values[ lv_left_middle_index ]
            + it_duration_values[ lv_right_middle_index ] ) / 2.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD calc_exec_duration_percentile.
    DATA(lv_duration_count) = lines( it_duration_values ).
    IF lv_duration_count > 0
        AND iv_percentile > 0
        AND iv_percentile <= 100.
      DO lv_duration_count TIMES.
        IF sy-index * 100 >= lv_duration_count * iv_percentile.
          rv_percentile_seconds = it_duration_values[ sy-index ].
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDMETHOD.

  METHOD calc_exec_duration_mad.
    DATA lt_deviation_values TYPE ty_exec_duration_values.
    DATA(lv_median_seconds) = calc_exec_duration_median(
      it_duration_values = it_duration_values ).
    LOOP AT it_duration_values INTO DATA(lv_duration_value).
      DATA(lv_deviation_seconds) = lv_duration_value - lv_median_seconds.
      IF lv_deviation_seconds < 0.
        lv_deviation_seconds = - lv_deviation_seconds.
      ENDIF.
      INSERT lv_deviation_seconds INTO TABLE lt_deviation_values.
    ENDLOOP.
    rv_mad_seconds = calc_exec_duration_median(
      it_duration_values = lt_deviation_values ).
  ENDMETHOD.

  METHOD calc_exec_interval_metrics.
    DATA lt_intervals TYPE ty_exec_duration_intervals.
    DATA lt_duration_values TYPE ty_exec_duration_values.
    DATA lt_nonrev_duration_values TYPE ty_exec_duration_values.
    DATA lt_reversed_duration_values TYPE ty_exec_duration_values.
    DATA lt_positive_duration_values TYPE ty_exec_duration_values.
    DATA lt_nonrev_pos_duration_values TYPE ty_exec_duration_values.
    DATA lt_rev_pos_duration_values TYPE ty_exec_duration_values.
    DATA lt_non_reversed_intervals TYPE ty_exec_duration_intervals.
    DATA lt_reversed_intervals TYPE ty_exec_duration_intervals.
    DATA lt_events TYPE ty_exec_duration_events.
    DATA lv_has_covered_interval TYPE abap_bool.
    DATA lv_covered_finish_date TYPE afru-iedd.
    DATA lv_covered_finish_time TYPE afru-iedz.
    DATA lv_has_positive_interval TYPE abap_bool.
    DATA lv_positive_start_date TYPE afru-isdd.
    DATA lv_positive_start_time TYPE afru-isdz.
    DATA lv_positive_finish_date TYPE afru-iedd.
    DATA lv_positive_finish_time TYPE afru-iedz.
    DATA lv_duration_seconds_total TYPE decfloat34.
    DATA lv_active_concurrency TYPE i.
    DATA lv_has_event_group TYPE abap_bool.
    DATA lv_event_group_date TYPE afru-isdd.
    DATA lv_event_group_time TYPE afru-isdz.
    DATA lv_event_group_delta TYPE i.
    DATA lv_overlap_episode_seconds TYPE decfloat34.
    DATA lv_single_episode_seconds TYPE decfloat34.
    DATA lv_three_plus_episode_seconds TYPE decfloat34.
    DATA lv_peak_episode_seconds TYPE decfloat34.

    rs_interval_result-issue_counts = VALUE #(
      ( issue_code = 'IF' status = c_exec_duration_invalid )
      ( issue_code = 'IS' status = c_exec_duration_invalid )
      ( issue_code = 'MD' status = c_exec_duration_missing )
      ( issue_code = 'MF' status = c_exec_duration_missing )
      ( issue_code = 'MS' status = c_exec_duration_missing )
      ( issue_code = 'NE' status = c_exec_duration_invalid )
      ( issue_code = 'TF' status = c_exec_duration_invalid )
      ( issue_code = 'TS' status = c_exec_duration_invalid ) ).

    LOOP AT it_confirmations INTO DATA(ls_confirmation).
      IF iv_work_center_plant IS SUPPLIED
          AND ls_confirmation-work_center_plant <>
            iv_work_center_plant.
        CONTINUE.
      ENDIF.
      IF iv_work_center IS SUPPLIED
          AND ls_confirmation-work_center <> iv_work_center.
        CONTINUE.
      ENDIF.
      IF iv_production_order IS SUPPLIED
          AND ls_confirmation-production_order <> iv_production_order.
        CONTINUE.
      ENDIF.
      IF iv_operation_counter IS SUPPLIED
          AND ls_confirmation-operation_counter <> iv_operation_counter.
        CONTINUE.
      ENDIF.
      IF iv_operation_number IS SUPPLIED
          AND ls_confirmation-operation_number <> iv_operation_number.
        CONTINUE.
      ENDIF.
      IF iv_operation_sequence IS SUPPLIED
          AND ls_confirmation-operation_sequence <> iv_operation_sequence.
        CONTINUE.
      ENDIF.
      IF iv_operation_suboperation IS SUPPLIED
          AND ls_confirmation-operation_suboperation <>
            iv_operation_suboperation.
        CONTINUE.
      ENDIF.
      IF iv_quantity_unit IS SUPPLIED
          AND ls_confirmation-quantity_unit <> iv_quantity_unit.
        CONTINUE.
      ENDIF.

      ADD 1 TO rs_interval_result-summary_confirmation_count.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO rs_interval_result-reversed_confirmation_count.
      ELSE.
        ADD 1 TO rs_interval_result-nonrev_confirmation_count.
      ENDIF.
      DATA(ls_duration) = calc_exec_duration(
        is_confirmation = ls_confirmation ).
      IF ls_duration-issue_code IS NOT INITIAL.
        READ TABLE rs_interval_result-issue_counts
          ASSIGNING FIELD-SYMBOL(<ls_duration_issue_count>)
          WITH TABLE KEY issue_code = ls_duration-issue_code.
        IF sy-subrc = 0.
          ADD 1 TO <ls_duration_issue_count>-confirmation_count.
          IF ls_confirmation-is_reversed = abap_true.
            ADD 1 TO
              <ls_duration_issue_count>-reversed_confirmation_count.
          ELSE.
            ADD 1 TO
              <ls_duration_issue_count>-nonrev_confirmation_count.
          ENDIF.
        ENDIF.
      ENDIF.
      IF ls_duration-status = c_exec_duration_invalid.
        IF ls_confirmation-is_reversed = abap_true.
          ADD 1 TO rs_interval_result-rev_invalid_count.
        ELSE.
          ADD 1 TO rs_interval_result-nonrev_invalid_count.
        ENDIF.
      ELSEIF ls_duration-status = c_exec_duration_missing.
        IF ls_confirmation-is_reversed = abap_true.
          ADD 1 TO rs_interval_result-rev_missing_count.
        ELSE.
          ADD 1 TO rs_interval_result-nonrev_missing_count.
        ENDIF.
      ENDIF.
      IF ls_duration-status <> c_exec_duration_valid.
        CONTINUE.
      ENDIF.

      INSERT ls_duration-duration_seconds INTO TABLE lt_duration_values.
      INSERT VALUE #(
        start_date       = ls_confirmation-execution_start_date
        start_time       = ls_confirmation-execution_start_time
        finish_date      = ls_confirmation-execution_finish_date
        finish_time      = ls_confirmation-execution_finish_time
        duration_seconds = ls_duration-duration_seconds )
        INTO TABLE lt_intervals.
      IF ls_confirmation-is_reversed = abap_true.
        INSERT ls_duration-duration_seconds
          INTO TABLE lt_reversed_duration_values.
        rs_interval_result-reversed_duration_count =
          rs_interval_result-reversed_duration_count + 1.
        rs_interval_result-reversed_duration_total =
          rs_interval_result-reversed_duration_total
          + ls_duration-duration_seconds.
        INSERT VALUE #(
          start_date       = ls_confirmation-execution_start_date
          start_time       = ls_confirmation-execution_start_time
          finish_date      = ls_confirmation-execution_finish_date
          finish_time      = ls_confirmation-execution_finish_time
          duration_seconds = ls_duration-duration_seconds )
          INTO TABLE lt_reversed_intervals.
      ELSE.
        INSERT ls_duration-duration_seconds
          INTO TABLE lt_nonrev_duration_values.
        rs_interval_result-nonrev_duration_count =
          rs_interval_result-nonrev_duration_count + 1.
        rs_interval_result-nonrev_duration_total =
          rs_interval_result-nonrev_duration_total
          + ls_duration-duration_seconds.
        INSERT VALUE #(
          start_date       = ls_confirmation-execution_start_date
          start_time       = ls_confirmation-execution_start_time
          finish_date      = ls_confirmation-execution_finish_date
          finish_time      = ls_confirmation-execution_finish_time
          duration_seconds = ls_duration-duration_seconds )
          INTO TABLE lt_non_reversed_intervals.
      ENDIF.
      lv_duration_seconds_total = lv_duration_seconds_total
        + ls_duration-duration_seconds.
      IF ls_duration-duration_seconds > 0.
        INSERT ls_duration-duration_seconds
          INTO TABLE lt_positive_duration_values.
        IF ls_confirmation-is_reversed = abap_true.
          INSERT ls_duration-duration_seconds
            INTO TABLE lt_rev_pos_duration_values.
        ELSE.
          INSERT ls_duration-duration_seconds
            INTO TABLE lt_nonrev_pos_duration_values.
        ENDIF.
        APPEND VALUE #(
          event_date        = ls_confirmation-execution_start_date
          event_time        = ls_confirmation-execution_start_time
          concurrency_delta = 1 ) TO lt_events.
        APPEND VALUE #(
          event_date        = ls_confirmation-execution_finish_date
          event_time        = ls_confirmation-execution_finish_time
          concurrency_delta = -1 ) TO lt_events.
      ENDIF.
    ENDLOOP.

    LOOP AT rs_interval_result-issue_counts
        ASSIGNING FIELD-SYMBOL(<ls_duration_issue_pct>).
      IF rs_interval_result-summary_confirmation_count > 0.
        <ls_duration_issue_pct>-confirmation_pct =
          CONV decfloat34(
            <ls_duration_issue_pct>-confirmation_count ) * 100
          / rs_interval_result-summary_confirmation_count.
      ENDIF.
      IF rs_interval_result-nonrev_confirmation_count > 0.
        <ls_duration_issue_pct>-nonrev_confirmation_pct =
          CONV decfloat34(
            <ls_duration_issue_pct>-nonrev_confirmation_count ) * 100
          / rs_interval_result-nonrev_confirmation_count.
      ENDIF.
      IF rs_interval_result-reversed_confirmation_count > 0.
        <ls_duration_issue_pct>-reversed_confirmation_pct =
          CONV decfloat34(
            <ls_duration_issue_pct>-reversed_confirmation_count ) * 100
          / rs_interval_result-reversed_confirmation_count.
      ENDIF.
    ENDLOOP.

    LOOP AT rs_interval_result-issue_counts
        INTO DATA(ls_top_issue_candidate).
      IF ls_top_issue_candidate-confirmation_count >
          rs_interval_result-top_issue_count.
        rs_interval_result-top_issue_code =
          ls_top_issue_candidate-issue_code.
        rs_interval_result-top_issue_status =
          ls_top_issue_candidate-status.
        rs_interval_result-top_issue_count =
          ls_top_issue_candidate-confirmation_count.
      ENDIF.
      IF ls_top_issue_candidate-status = c_exec_duration_invalid
          AND ls_top_issue_candidate-confirmation_count >
            rs_interval_result-top_invalid_issue_count.
        rs_interval_result-top_invalid_issue_code =
          ls_top_issue_candidate-issue_code.
        rs_interval_result-top_invalid_issue_count =
          ls_top_issue_candidate-confirmation_count.
      ELSEIF ls_top_issue_candidate-status = c_exec_duration_missing
          AND ls_top_issue_candidate-confirmation_count >
            rs_interval_result-top_missing_issue_count.
        rs_interval_result-top_missing_issue_code =
          ls_top_issue_candidate-issue_code.
        rs_interval_result-top_missing_issue_count =
          ls_top_issue_candidate-confirmation_count.
      ENDIF.
      IF ls_top_issue_candidate-nonrev_confirmation_count >
          rs_interval_result-top_nonrev_issue_count.
        rs_interval_result-top_nonrev_issue_code =
          ls_top_issue_candidate-issue_code.
        rs_interval_result-top_nonrev_issue_status =
          ls_top_issue_candidate-status.
        rs_interval_result-top_nonrev_issue_count =
          ls_top_issue_candidate-nonrev_confirmation_count.
      ENDIF.
      IF ls_top_issue_candidate-reversed_confirmation_count >
          rs_interval_result-top_reversed_issue_count.
        rs_interval_result-top_reversed_issue_code =
          ls_top_issue_candidate-issue_code.
        rs_interval_result-top_reversed_issue_status =
          ls_top_issue_candidate-status.
        rs_interval_result-top_reversed_issue_count =
          ls_top_issue_candidate-reversed_confirmation_count.
      ENDIF.
    ENDLOOP.
    IF rs_interval_result-top_issue_count > 0
        AND rs_interval_result-summary_confirmation_count > 0.
      rs_interval_result-top_issue_pct =
        CONV decfloat34( rs_interval_result-top_issue_count ) * 100
        / rs_interval_result-summary_confirmation_count.
    ENDIF.
    IF rs_interval_result-nonrev_confirmation_count > 0.
      rs_interval_result-top_nonrev_issue_pct =
        CONV decfloat34( rs_interval_result-top_nonrev_issue_count ) * 100
        / rs_interval_result-nonrev_confirmation_count.
    ENDIF.
    IF rs_interval_result-reversed_confirmation_count > 0.
      rs_interval_result-top_reversed_issue_pct =
        CONV decfloat34( rs_interval_result-top_reversed_issue_count ) * 100
        / rs_interval_result-reversed_confirmation_count.
    ENDIF.

    DATA(lv_duration_value_count) = lines( lt_duration_values ).
    DATA(lv_issue_confirmation_count) =
      rs_interval_result-summary_confirmation_count
      - lv_duration_value_count.
    DATA(lv_nonrev_issue_total) =
      rs_interval_result-nonrev_invalid_count
      + rs_interval_result-nonrev_missing_count.
    DATA(lv_reversed_issue_total) =
      rs_interval_result-rev_invalid_count
      + rs_interval_result-rev_missing_count.
    DATA(lv_invalid_issue_total) =
      rs_interval_result-nonrev_invalid_count
      + rs_interval_result-rev_invalid_count.
    DATA(lv_missing_issue_total) =
      rs_interval_result-nonrev_missing_count
      + rs_interval_result-rev_missing_count.
    IF lv_invalid_issue_total > 0.
      rs_interval_result-top_invalid_share_pct =
        CONV decfloat34(
          rs_interval_result-top_invalid_issue_count ) * 100
        / lv_invalid_issue_total.
    ENDIF.
    IF lv_missing_issue_total > 0.
      rs_interval_result-top_missing_share_pct =
        CONV decfloat34(
          rs_interval_result-top_missing_issue_count ) * 100
        / lv_missing_issue_total.
    ENDIF.
    LOOP AT rs_interval_result-issue_counts
        ASSIGNING FIELD-SYMBOL(<ls_duration_issue_share>).
      IF lv_issue_confirmation_count > 0.
        <ls_duration_issue_share>-issue_share_pct =
          CONV decfloat34(
            <ls_duration_issue_share>-confirmation_count ) * 100
          / lv_issue_confirmation_count.
      ENDIF.
      IF lv_nonrev_issue_total > 0.
        <ls_duration_issue_share>-nonrev_issue_share_pct =
          CONV decfloat34(
            <ls_duration_issue_share>-nonrev_confirmation_count ) * 100
          / lv_nonrev_issue_total.
      ENDIF.
      IF lv_reversed_issue_total > 0.
        <ls_duration_issue_share>-reversed_issue_share_pct =
          CONV decfloat34(
            <ls_duration_issue_share>-reversed_confirmation_count ) * 100
          / lv_reversed_issue_total.
      ENDIF.
      IF <ls_duration_issue_share>-status = c_exec_duration_invalid
          AND lv_invalid_issue_total > 0.
        <ls_duration_issue_share>-status_share_pct =
          CONV decfloat34(
            <ls_duration_issue_share>-confirmation_count ) * 100
          / lv_invalid_issue_total.
        IF rs_interval_result-nonrev_invalid_count > 0.
          <ls_duration_issue_share>-nonrev_status_share_pct =
            CONV decfloat34(
              <ls_duration_issue_share>-nonrev_confirmation_count ) * 100
            / rs_interval_result-nonrev_invalid_count.
        ENDIF.
        IF rs_interval_result-rev_invalid_count > 0.
          <ls_duration_issue_share>-reversed_status_share_pct =
            CONV decfloat34(
              <ls_duration_issue_share>-reversed_confirmation_count ) * 100
            / rs_interval_result-rev_invalid_count.
        ENDIF.
      ELSEIF <ls_duration_issue_share>-status = c_exec_duration_missing
          AND lv_missing_issue_total > 0.
        <ls_duration_issue_share>-status_share_pct =
          CONV decfloat34(
            <ls_duration_issue_share>-confirmation_count ) * 100
          / lv_missing_issue_total.
        IF rs_interval_result-nonrev_missing_count > 0.
          <ls_duration_issue_share>-nonrev_status_share_pct =
            CONV decfloat34(
              <ls_duration_issue_share>-nonrev_confirmation_count ) * 100
            / rs_interval_result-nonrev_missing_count.
        ENDIF.
        IF rs_interval_result-rev_missing_count > 0.
          <ls_duration_issue_share>-reversed_status_share_pct =
            CONV decfloat34(
              <ls_duration_issue_share>-reversed_confirmation_count ) * 100
            / rs_interval_result-rev_missing_count.
        ENDIF.
      ENDIF.
    ENDLOOP.
    rs_interval_result-positive_duration_count =
      lines( lt_positive_duration_values ).
    rs_interval_result-positive_median_secs =
      calc_exec_duration_median( lt_positive_duration_values ).
    rs_interval_result-positive_p90_secs = calc_exec_duration_percentile(
      it_duration_values = lt_positive_duration_values
      iv_percentile      = 90 ).
    rs_interval_result-nonrev_positive_count =
      lines( lt_nonrev_pos_duration_values ).
    rs_interval_result-nonrev_positive_median_secs =
      calc_exec_duration_median( lt_nonrev_pos_duration_values ).
    rs_interval_result-nonrev_positive_p90_secs = calc_exec_duration_percentile(
      it_duration_values = lt_nonrev_pos_duration_values
      iv_percentile      = 90 ).
    rs_interval_result-reversed_positive_count =
      lines( lt_rev_pos_duration_values ).
    rs_interval_result-zero_valid_count =
      lv_duration_value_count
      - rs_interval_result-positive_duration_count.
    rs_interval_result-nonrev_zero_valid_count =
      lines( lt_nonrev_duration_values )
      - rs_interval_result-nonrev_positive_count.
    rs_interval_result-rev_zero_valid_count =
      lines( lt_reversed_duration_values )
      - rs_interval_result-reversed_positive_count.
    IF rs_interval_result-nonrev_confirmation_count > 0.
      rs_interval_result-nonrev_valid_pct =
        CONV decfloat34( rs_interval_result-nonrev_duration_count ) * 100
        / rs_interval_result-nonrev_confirmation_count.
      rs_interval_result-nonrev_invalid_pct =
        CONV decfloat34( rs_interval_result-nonrev_invalid_count ) * 100
        / rs_interval_result-nonrev_confirmation_count.
      rs_interval_result-nonrev_missing_pct =
        CONV decfloat34( rs_interval_result-nonrev_missing_count ) * 100
        / rs_interval_result-nonrev_confirmation_count.
    ENDIF.
    IF rs_interval_result-reversed_confirmation_count > 0.
      rs_interval_result-rev_valid_pct =
        CONV decfloat34( rs_interval_result-reversed_duration_count ) * 100
        / rs_interval_result-reversed_confirmation_count.
      rs_interval_result-rev_invalid_pct =
        CONV decfloat34( rs_interval_result-rev_invalid_count ) * 100
        / rs_interval_result-reversed_confirmation_count.
      rs_interval_result-rev_missing_pct =
        CONV decfloat34( rs_interval_result-rev_missing_count ) * 100
        / rs_interval_result-reversed_confirmation_count.
    ENDIF.
    IF rs_interval_result-summary_confirmation_count > 0.
      rs_interval_result-positive_pct =
        CONV decfloat34( rs_interval_result-positive_duration_count ) * 100
        / rs_interval_result-summary_confirmation_count.
    ENDIF.
    IF rs_interval_result-nonrev_confirmation_count > 0.
      rs_interval_result-nonrev_pos_pct =
        CONV decfloat34( rs_interval_result-nonrev_positive_count ) * 100
        / rs_interval_result-nonrev_confirmation_count.
    ENDIF.
    IF rs_interval_result-reversed_confirmation_count > 0.
      rs_interval_result-rev_pos_pct =
        CONV decfloat34( rs_interval_result-reversed_positive_count ) * 100
        / rs_interval_result-reversed_confirmation_count.
    ENDIF.
    IF lv_duration_value_count > 0.
      rs_interval_result-pos_valid_pct =
        CONV decfloat34( rs_interval_result-positive_duration_count ) * 100
        / lv_duration_value_count.
    ENDIF.
    IF lines( lt_nonrev_duration_values ) > 0.
      rs_interval_result-nonrev_pos_valid_pct =
        CONV decfloat34( rs_interval_result-nonrev_positive_count ) * 100
        / lines( lt_nonrev_duration_values ).
    ENDIF.
    IF lines( lt_reversed_duration_values ) > 0.
      rs_interval_result-rev_pos_valid_pct =
        CONV decfloat34( rs_interval_result-reversed_positive_count ) * 100
        / lines( lt_reversed_duration_values ).
    ENDIF.
    IF lv_duration_value_count > 0.
      rs_interval_result-zero_valid_pct =
        CONV decfloat34( rs_interval_result-zero_valid_count ) * 100
        / lv_duration_value_count.
    ENDIF.
    IF lines( lt_nonrev_duration_values ) > 0.
      rs_interval_result-nonrev_zero_valid_pct =
        CONV decfloat34( rs_interval_result-nonrev_zero_valid_count ) * 100
        / lines( lt_nonrev_duration_values ).
    ENDIF.
    IF lines( lt_reversed_duration_values ) > 0.
      rs_interval_result-rev_zero_valid_pct =
        CONV decfloat34( rs_interval_result-rev_zero_valid_count ) * 100
        / lines( lt_reversed_duration_values ).
    ENDIF.
    IF rs_interval_result-positive_duration_count > 0.
      rs_interval_result-positive_min_secs = lt_positive_duration_values[ 1 ].
      rs_interval_result-positive_max_secs = lt_positive_duration_values[
        rs_interval_result-positive_duration_count ].
      rs_interval_result-positive_range_secs =
        rs_interval_result-positive_max_secs
        - rs_interval_result-positive_min_secs.
    ENDIF.
    IF rs_interval_result-nonrev_positive_count > 0.
      rs_interval_result-nonrev_positive_min_secs =
        lt_nonrev_pos_duration_values[ 1 ].
      rs_interval_result-nonrev_positive_max_secs =
        lt_nonrev_pos_duration_values[
          rs_interval_result-nonrev_positive_count ].
      rs_interval_result-nonrev_positive_range_secs =
        rs_interval_result-nonrev_positive_max_secs
        - rs_interval_result-nonrev_positive_min_secs.
    ENDIF.
    IF rs_interval_result-reversed_positive_count > 0.
      rs_interval_result-reversed_positive_min_secs =
        lt_rev_pos_duration_values[ 1 ].
      rs_interval_result-reversed_positive_max_secs =
        lt_rev_pos_duration_values[
          rs_interval_result-reversed_positive_count ].
      rs_interval_result-reversed_positive_range_secs =
        rs_interval_result-reversed_positive_max_secs
        - rs_interval_result-reversed_positive_min_secs.
    ENDIF.
    rs_interval_result-reversed_positive_median_secs =
      calc_exec_duration_median( lt_rev_pos_duration_values ).
    rs_interval_result-reversed_positive_p90_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_rev_pos_duration_values
        iv_percentile      = 90 ).
    rs_interval_result-positive_p95_secs = calc_exec_duration_percentile(
      it_duration_values = lt_positive_duration_values
      iv_percentile      = 95 ).
    rs_interval_result-positive_p99_secs = calc_exec_duration_percentile(
      it_duration_values = lt_positive_duration_values
      iv_percentile      = 99 ).
    rs_interval_result-nonrev_positive_p95_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_nonrev_pos_duration_values
        iv_percentile      = 95 ).
    rs_interval_result-nonrev_positive_p99_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_nonrev_pos_duration_values
        iv_percentile      = 99 ).
    rs_interval_result-reversed_positive_p95_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_rev_pos_duration_values
        iv_percentile      = 95 ).
    rs_interval_result-reversed_positive_p99_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_rev_pos_duration_values
        iv_percentile      = 99 ).
    rs_interval_result-positive_p25_secs = calc_exec_duration_percentile(
      it_duration_values = lt_positive_duration_values
      iv_percentile      = 25 ).
    rs_interval_result-positive_p75_secs = calc_exec_duration_percentile(
      it_duration_values = lt_positive_duration_values
      iv_percentile      = 75 ).
    rs_interval_result-nonrev_positive_p25_secs = calc_exec_duration_percentile(
      it_duration_values = lt_nonrev_pos_duration_values
      iv_percentile      = 25 ).
    rs_interval_result-nonrev_positive_p75_secs = calc_exec_duration_percentile(
      it_duration_values = lt_nonrev_pos_duration_values
      iv_percentile      = 75 ).
    rs_interval_result-reversed_positive_p25_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_rev_pos_duration_values
        iv_percentile      = 25 ).
    rs_interval_result-reversed_positive_p75_secs =
      calc_exec_duration_percentile(
        it_duration_values = lt_rev_pos_duration_values
        iv_percentile      = 75 ).
    rs_interval_result-positive_iqr_secs =
      rs_interval_result-positive_p75_secs
      - rs_interval_result-positive_p25_secs.
    rs_interval_result-nonrev_positive_iqr_secs =
      rs_interval_result-nonrev_positive_p75_secs
      - rs_interval_result-nonrev_positive_p25_secs.
    rs_interval_result-reversed_positive_iqr_secs =
      rs_interval_result-reversed_positive_p75_secs
      - rs_interval_result-reversed_positive_p25_secs.
    rs_interval_result-positive_mad_secs = calc_exec_duration_mad(
      lt_positive_duration_values ).
    IF rs_interval_result-positive_duration_count > 0.
      rs_interval_result-pos_avg_secs = lv_duration_seconds_total /
        rs_interval_result-positive_duration_count.
    ENDIF.
    IF rs_interval_result-nonrev_positive_count > 0.
      rs_interval_result-nonrev_pos_avg_secs =
        rs_interval_result-nonrev_duration_total /
        rs_interval_result-nonrev_positive_count.
    ENDIF.
    IF rs_interval_result-reversed_positive_count > 0.
      rs_interval_result-rev_pos_avg_secs =
        rs_interval_result-reversed_duration_total /
        rs_interval_result-reversed_positive_count.
    ENDIF.
    rs_interval_result-nonrev_positive_mad_secs = calc_exec_duration_mad(
      lt_nonrev_pos_duration_values ).
    rs_interval_result-reversed_positive_mad_secs = calc_exec_duration_mad(
      lt_rev_pos_duration_values ).
    IF rs_interval_result-positive_median_secs > 0.
      rs_interval_result-positive_iqr_med_ratio =
        rs_interval_result-positive_iqr_secs
        / rs_interval_result-positive_median_secs.
      rs_interval_result-positive_mad_med_ratio =
        rs_interval_result-positive_mad_secs
        / rs_interval_result-positive_median_secs.
      rs_interval_result-pos_avg_med_ratio =
        rs_interval_result-pos_avg_secs
        / rs_interval_result-positive_median_secs.
      rs_interval_result-pos_p95_med_ratio =
        rs_interval_result-positive_p95_secs
        / rs_interval_result-positive_median_secs.
      rs_interval_result-pos_p99_med_ratio =
        rs_interval_result-positive_p99_secs
        / rs_interval_result-positive_median_secs.
    ENDIF.
    IF rs_interval_result-nonrev_positive_median_secs > 0.
      rs_interval_result-nonrev_positive_iqr_med_ratio =
        rs_interval_result-nonrev_positive_iqr_secs
        / rs_interval_result-nonrev_positive_median_secs.
      rs_interval_result-nonrev_positive_mad_med_ratio =
        rs_interval_result-nonrev_positive_mad_secs
        / rs_interval_result-nonrev_positive_median_secs.
      rs_interval_result-nonrev_pos_avg_med_ratio =
        rs_interval_result-nonrev_pos_avg_secs
        / rs_interval_result-nonrev_positive_median_secs.
      rs_interval_result-nonrev_pos_p95_med_ratio =
        rs_interval_result-nonrev_positive_p95_secs
        / rs_interval_result-nonrev_positive_median_secs.
      rs_interval_result-nonrev_pos_p99_med_ratio =
        rs_interval_result-nonrev_positive_p99_secs
        / rs_interval_result-nonrev_positive_median_secs.
    ENDIF.
    IF rs_interval_result-reversed_positive_median_secs > 0.
      rs_interval_result-reversed_pos_iqr_med_ratio =
        rs_interval_result-reversed_positive_iqr_secs
        / rs_interval_result-reversed_positive_median_secs.
      rs_interval_result-reversed_pos_mad_med_ratio =
        rs_interval_result-reversed_positive_mad_secs
        / rs_interval_result-reversed_positive_median_secs.
      rs_interval_result-rev_pos_avg_med_ratio =
        rs_interval_result-rev_pos_avg_secs
        / rs_interval_result-reversed_positive_median_secs.
      rs_interval_result-rev_pos_p95_med_ratio =
        rs_interval_result-reversed_positive_p95_secs
        / rs_interval_result-reversed_positive_median_secs.
      rs_interval_result-rev_pos_p99_med_ratio =
        rs_interval_result-reversed_positive_p99_secs
        / rs_interval_result-reversed_positive_median_secs.
    ENDIF.
    IF rs_interval_result-positive_median_secs > 0.
      rs_interval_result-pos_p90_med_ratio =
        rs_interval_result-positive_p90_secs /
        rs_interval_result-positive_median_secs.
    ENDIF.
    IF rs_interval_result-nonrev_positive_median_secs > 0.
      rs_interval_result-nonrev_pos_p90_med_ratio =
        rs_interval_result-nonrev_positive_p90_secs /
        rs_interval_result-nonrev_positive_median_secs.
    ENDIF.
    IF rs_interval_result-reversed_positive_median_secs > 0.
      rs_interval_result-reversed_pos_p90_med_ratio =
        rs_interval_result-reversed_positive_p90_secs /
        rs_interval_result-reversed_positive_median_secs.
    ENDIF.
    IF lv_duration_value_count > 0.
      rs_interval_result-duration_median_seconds =
        calc_exec_duration_median( lt_duration_values ).
      DATA(lv_nonrev_value_count) =
        lines( lt_nonrev_duration_values ).
      IF lv_nonrev_value_count > 0.
        rs_interval_result-nonrev_min_seconds =
          lt_nonrev_duration_values[ 1 ].
        rs_interval_result-nonrev_max_seconds =
          lt_nonrev_duration_values[ lv_nonrev_value_count ].
      ENDIF.
      DATA(lv_reversed_value_count) =
        lines( lt_reversed_duration_values ).
      IF lv_reversed_value_count > 0.
        rs_interval_result-reversed_min_seconds =
          lt_reversed_duration_values[ 1 ].
        rs_interval_result-reversed_max_seconds =
          lt_reversed_duration_values[ lv_reversed_value_count ].
      ENDIF.
      rs_interval_result-nonrev_duration_median_secs =
        calc_exec_duration_median( lt_nonrev_duration_values ).
      rs_interval_result-reversed_duration_median_secs =
        calc_exec_duration_median( lt_reversed_duration_values ).
      rs_interval_result-duration_mad_seconds =
        calc_exec_duration_mad( it_duration_values = lt_duration_values ).
      rs_interval_result-nonrev_mad_seconds =
        calc_exec_duration_mad(
          it_duration_values = lt_nonrev_duration_values ).
      rs_interval_result-reversed_mad_seconds =
        calc_exec_duration_mad(
          it_duration_values = lt_reversed_duration_values ).
      IF rs_interval_result-duration_median_seconds > 0.
        rs_interval_result-duration_mad_median_ratio =
          rs_interval_result-duration_mad_seconds /
          rs_interval_result-duration_median_seconds.
      ENDIF.
      IF rs_interval_result-nonrev_duration_median_secs > 0.
        rs_interval_result-nonrev_mad_median_ratio =
          rs_interval_result-nonrev_mad_seconds /
          rs_interval_result-nonrev_duration_median_secs.
      ENDIF.
      IF rs_interval_result-reversed_duration_median_secs > 0.
        rs_interval_result-reversed_mad_median_ratio =
          rs_interval_result-reversed_mad_seconds /
          rs_interval_result-reversed_duration_median_secs.
      ENDIF.
      IF rs_interval_result-duration_median_seconds > 0.
        rs_interval_result-duration_avg_median_ratio =
          calc_exec_duration_avg(
            iv_duration_count         = lv_duration_value_count
            iv_duration_seconds_total = lv_duration_seconds_total ) /
          rs_interval_result-duration_median_seconds.
      ENDIF.
      rs_interval_result-duration_p90_seconds =
        calc_exec_duration_percentile(
          it_duration_values = lt_duration_values
          iv_percentile      = 90 ).
      rs_interval_result-nonrev_p90_seconds =
        calc_exec_duration_percentile(
          it_duration_values = lt_nonrev_duration_values
          iv_percentile      = 90 ).
      rs_interval_result-reversed_p90_seconds =
        calc_exec_duration_percentile(
          it_duration_values = lt_reversed_duration_values
          iv_percentile      = 90 ).
      IF rs_interval_result-duration_median_seconds > 0.
        rs_interval_result-duration_p90_median_ratio =
          rs_interval_result-duration_p90_seconds /
          rs_interval_result-duration_median_seconds.
      ENDIF.
      IF rs_interval_result-nonrev_duration_median_secs > 0.
        rs_interval_result-nonrev_p90_median_ratio =
          rs_interval_result-nonrev_p90_seconds /
          rs_interval_result-nonrev_duration_median_secs.
      ENDIF.
      IF rs_interval_result-reversed_duration_median_secs > 0.
        rs_interval_result-reversed_p90_median_ratio =
          rs_interval_result-reversed_p90_seconds /
          rs_interval_result-reversed_duration_median_secs.
      ENDIF.
      LOOP AT lt_positive_duration_values INTO DATA(lv_pos_p90_value).
        IF lv_pos_p90_value > rs_interval_result-positive_p90_secs.
          rs_interval_result-pos_p90_tail_secs =
            rs_interval_result-pos_p90_tail_secs + lv_pos_p90_value.
          rs_interval_result-pos_p90_gt_count =
            rs_interval_result-pos_p90_gt_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_nonrev_pos_duration_values
          INTO DATA(lv_nonrev_pos_p90_value).
        IF lv_nonrev_pos_p90_value > rs_interval_result-nonrev_positive_p90_secs.
          rs_interval_result-nonrev_pos_p90_tail_secs =
            rs_interval_result-nonrev_pos_p90_tail_secs
            + lv_nonrev_pos_p90_value.
          rs_interval_result-nonrev_pos_p90_gt_count =
            rs_interval_result-nonrev_pos_p90_gt_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_rev_pos_duration_values INTO DATA(lv_rev_pos_p90_value).
        IF lv_rev_pos_p90_value > rs_interval_result-reversed_positive_p90_secs.
          rs_interval_result-rev_pos_p90_tail_secs =
            rs_interval_result-rev_pos_p90_tail_secs + lv_rev_pos_p90_value.
          rs_interval_result-rev_pos_p90_gt_count =
            rs_interval_result-rev_pos_p90_gt_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_positive_duration_values INTO DATA(lv_positive_tail_value).
        IF lv_positive_tail_value > rs_interval_result-positive_p95_secs.
          rs_interval_result-pos_p95_tail_secs =
            rs_interval_result-pos_p95_tail_secs + lv_positive_tail_value.
          rs_interval_result-pos_p95_gt_count =
            rs_interval_result-pos_p95_gt_count + 1.
        ENDIF.
        IF lv_positive_tail_value > rs_interval_result-positive_p99_secs.
          rs_interval_result-pos_p99_tail_secs =
            rs_interval_result-pos_p99_tail_secs + lv_positive_tail_value.
          rs_interval_result-pos_p99_gt_count =
            rs_interval_result-pos_p99_gt_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_nonrev_pos_duration_values
          INTO DATA(lv_nonrev_positive_tail_value).
        IF lv_nonrev_positive_tail_value >
            rs_interval_result-nonrev_positive_p95_secs.
          rs_interval_result-nonrev_pos_p95_tail_secs =
            rs_interval_result-nonrev_pos_p95_tail_secs
            + lv_nonrev_positive_tail_value.
          rs_interval_result-nonrev_pos_p95_gt_count =
            rs_interval_result-nonrev_pos_p95_gt_count + 1.
        ENDIF.
        IF lv_nonrev_positive_tail_value >
            rs_interval_result-nonrev_positive_p99_secs.
          rs_interval_result-nonrev_pos_p99_tail_secs =
            rs_interval_result-nonrev_pos_p99_tail_secs
            + lv_nonrev_positive_tail_value.
          rs_interval_result-nonrev_pos_p99_gt_count =
            rs_interval_result-nonrev_pos_p99_gt_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_rev_pos_duration_values INTO DATA(lv_rev_positive_tail_value).
        IF lv_rev_positive_tail_value >
            rs_interval_result-reversed_positive_p95_secs.
          rs_interval_result-rev_pos_p95_tail_secs =
            rs_interval_result-rev_pos_p95_tail_secs
            + lv_rev_positive_tail_value.
          rs_interval_result-rev_pos_p95_gt_count =
            rs_interval_result-rev_pos_p95_gt_count + 1.
        ENDIF.
        IF lv_rev_positive_tail_value >
            rs_interval_result-reversed_positive_p99_secs.
          rs_interval_result-rev_pos_p99_tail_secs =
            rs_interval_result-rev_pos_p99_tail_secs
            + lv_rev_positive_tail_value.
          rs_interval_result-rev_pos_p99_gt_count =
            rs_interval_result-rev_pos_p99_gt_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_duration_values INTO DATA(lv_gross_p90_value).
        IF lv_gross_p90_value > rs_interval_result-duration_p90_seconds.
          rs_interval_result-p90_tail_secs =
            rs_interval_result-p90_tail_secs + lv_gross_p90_value.
          rs_interval_result-duration_p90_exceed_count =
            rs_interval_result-duration_p90_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_nonrev_duration_values INTO DATA(lv_nonrev_p90_value).
        IF lv_nonrev_p90_value > rs_interval_result-nonrev_p90_seconds.
          rs_interval_result-nonrev_p90_tail_secs =
            rs_interval_result-nonrev_p90_tail_secs + lv_nonrev_p90_value.
          rs_interval_result-nonrev_p90_exceed_count =
            rs_interval_result-nonrev_p90_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_reversed_duration_values INTO
          DATA(lv_reversed_p90_value).
        IF lv_reversed_p90_value > rs_interval_result-reversed_p90_seconds.
          rs_interval_result-reversed_p90_tail_secs =
            rs_interval_result-reversed_p90_tail_secs
            + lv_reversed_p90_value.
          rs_interval_result-reversed_p90_exceed_count =
            rs_interval_result-reversed_p90_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      IF rs_interval_result-positive_duration_count > 0.
        rs_interval_result-pos_p90_gt_pct =
          CONV decfloat34( rs_interval_result-pos_p90_gt_count )
          * 100 / rs_interval_result-positive_duration_count.
        rs_interval_result-pos_p90_tail_pct =
          rs_interval_result-pos_p90_tail_secs * 100
          / lv_duration_seconds_total.
        rs_interval_result-pos_p95_gt_pct =
          CONV decfloat34( rs_interval_result-pos_p95_gt_count ) * 100
          / rs_interval_result-positive_duration_count.
        rs_interval_result-pos_p95_tail_pct =
          rs_interval_result-pos_p95_tail_secs * 100
          / lv_duration_seconds_total.
        rs_interval_result-pos_p99_gt_pct =
          CONV decfloat34( rs_interval_result-pos_p99_gt_count ) * 100
          / rs_interval_result-positive_duration_count.
        rs_interval_result-pos_p99_tail_pct =
          rs_interval_result-pos_p99_tail_secs * 100
          / lv_duration_seconds_total.
      ENDIF.
      IF rs_interval_result-nonrev_positive_count > 0.
        rs_interval_result-nonrev_pos_p90_gt_pct =
          CONV decfloat34( rs_interval_result-nonrev_pos_p90_gt_count )
          * 100 / rs_interval_result-nonrev_positive_count.
        rs_interval_result-nonrev_pos_p90_tail_pct =
          rs_interval_result-nonrev_pos_p90_tail_secs * 100
          / rs_interval_result-nonrev_duration_total.
        rs_interval_result-nonrev_pos_p95_gt_pct =
          CONV decfloat34( rs_interval_result-nonrev_pos_p95_gt_count )
          * 100 / rs_interval_result-nonrev_positive_count.
        rs_interval_result-nonrev_pos_p95_tail_pct =
          rs_interval_result-nonrev_pos_p95_tail_secs * 100
          / rs_interval_result-nonrev_duration_total.
        rs_interval_result-nonrev_pos_p99_gt_pct =
          CONV decfloat34( rs_interval_result-nonrev_pos_p99_gt_count )
          * 100 / rs_interval_result-nonrev_positive_count.
        rs_interval_result-nonrev_pos_p99_tail_pct =
          rs_interval_result-nonrev_pos_p99_tail_secs * 100
          / rs_interval_result-nonrev_duration_total.
      ENDIF.
      IF rs_interval_result-reversed_positive_count > 0.
        rs_interval_result-rev_pos_p90_gt_pct =
          CONV decfloat34( rs_interval_result-rev_pos_p90_gt_count )
          * 100 / rs_interval_result-reversed_positive_count.
        rs_interval_result-rev_pos_p90_tail_pct =
          rs_interval_result-rev_pos_p90_tail_secs * 100
          / rs_interval_result-reversed_duration_total.
        rs_interval_result-rev_pos_p95_gt_pct =
          CONV decfloat34( rs_interval_result-rev_pos_p95_gt_count )
          * 100 / rs_interval_result-reversed_positive_count.
        rs_interval_result-rev_pos_p95_tail_pct =
          rs_interval_result-rev_pos_p95_tail_secs * 100
          / rs_interval_result-reversed_duration_total.
        rs_interval_result-rev_pos_p99_gt_pct =
          CONV decfloat34( rs_interval_result-rev_pos_p99_gt_count )
          * 100 / rs_interval_result-reversed_positive_count.
        rs_interval_result-rev_pos_p99_tail_pct =
          rs_interval_result-rev_pos_p99_tail_secs * 100
          / rs_interval_result-reversed_duration_total.
      ENDIF.
      IF lv_duration_value_count > 0.
        rs_interval_result-duration_p90_exceed_pct =
          CONV decfloat34( rs_interval_result-duration_p90_exceed_count )
          * 100 / lv_duration_value_count.
      ENDIF.
      IF lines( lt_nonrev_duration_values ) > 0.
        rs_interval_result-nonrev_p90_exceed_pct =
          CONV decfloat34( rs_interval_result-nonrev_p90_exceed_count )
          * 100 / lines( lt_nonrev_duration_values ).
      ENDIF.
      IF lines( lt_reversed_duration_values ) > 0.
        rs_interval_result-reversed_p90_exceed_pct =
          CONV decfloat34( rs_interval_result-reversed_p90_exceed_count )
          * 100 / lines( lt_reversed_duration_values ).
      ENDIF.
      IF lv_duration_seconds_total > 0.
        rs_interval_result-p90_tail_pct =
          rs_interval_result-p90_tail_secs * 100
          / lv_duration_seconds_total.
      ENDIF.
      IF rs_interval_result-nonrev_duration_total > 0.
        rs_interval_result-nonrev_p90_tail_pct =
          rs_interval_result-nonrev_p90_tail_secs * 100
          / rs_interval_result-nonrev_duration_total.
      ENDIF.
      IF rs_interval_result-reversed_duration_total > 0.
        rs_interval_result-reversed_p90_tail_pct =
          rs_interval_result-reversed_p90_tail_secs * 100
          / rs_interval_result-reversed_duration_total.
      ENDIF.
      DATA(lv_duration_p95_seconds) = calc_exec_duration_percentile(
        it_duration_values = lt_duration_values
        iv_percentile      = 95 ).
      rs_interval_result-duration_p95_seconds = lv_duration_p95_seconds.
      DATA(lv_nonrev_p95_seconds) = calc_exec_duration_percentile(
        it_duration_values = lt_nonrev_duration_values
        iv_percentile      = 95 ).
      rs_interval_result-nonrev_p95_seconds = lv_nonrev_p95_seconds.
      DATA(lv_reversed_p95_seconds) = calc_exec_duration_percentile(
        it_duration_values = lt_reversed_duration_values
        iv_percentile      = 95 ).
      rs_interval_result-reversed_p95_seconds = lv_reversed_p95_seconds.
      IF rs_interval_result-duration_median_seconds > 0.
        rs_interval_result-duration_p95_median_ratio =
          rs_interval_result-duration_p95_seconds /
          rs_interval_result-duration_median_seconds.
      ENDIF.
      IF rs_interval_result-nonrev_duration_median_secs > 0.
        rs_interval_result-nonrev_p95_median_ratio =
          rs_interval_result-nonrev_p95_seconds /
          rs_interval_result-nonrev_duration_median_secs.
      ENDIF.
      IF rs_interval_result-reversed_duration_median_secs > 0.
        rs_interval_result-reversed_p95_median_ratio =
          rs_interval_result-reversed_p95_seconds /
          rs_interval_result-reversed_duration_median_secs.
      ENDIF.
      LOOP AT lt_duration_values INTO DATA(lv_gross_duration_value).
        IF lv_gross_duration_value > lv_duration_p95_seconds.
          rs_interval_result-p95_tail_secs =
            rs_interval_result-p95_tail_secs
            + lv_gross_duration_value.
          rs_interval_result-duration_p95_exceed_count =
            rs_interval_result-duration_p95_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_nonrev_duration_values INTO DATA(lv_nonrev_duration_value).
        IF lv_nonrev_duration_value > lv_nonrev_p95_seconds.
          rs_interval_result-nonrev_p95_tail_secs =
            rs_interval_result-nonrev_p95_tail_secs
            + lv_nonrev_duration_value.
          rs_interval_result-nonrev_p95_exceed_count =
            rs_interval_result-nonrev_p95_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_reversed_duration_values INTO
          DATA(lv_reversed_duration_value).
        IF lv_reversed_duration_value > lv_reversed_p95_seconds.
          rs_interval_result-reversed_p95_tail_secs =
            rs_interval_result-reversed_p95_tail_secs
            + lv_reversed_duration_value.
          rs_interval_result-reversed_p95_exceed_count =
            rs_interval_result-reversed_p95_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      rs_interval_result-duration_p95_exceed_pct =
        CONV decfloat34( rs_interval_result-duration_p95_exceed_count )
        * 100 / lv_duration_value_count.
      IF lines( lt_nonrev_duration_values ) > 0.
        rs_interval_result-nonrev_p95_exceed_pct =
          CONV decfloat34( rs_interval_result-nonrev_p95_exceed_count )
          * 100 / lines( lt_nonrev_duration_values ).
      ENDIF.
      IF lines( lt_reversed_duration_values ) > 0.
        rs_interval_result-reversed_p95_exceed_pct =
          CONV decfloat34( rs_interval_result-reversed_p95_exceed_count )
          * 100 / lines( lt_reversed_duration_values ).
      ENDIF.
      IF lv_duration_seconds_total > 0.
        rs_interval_result-p95_tail_pct =
          rs_interval_result-p95_tail_secs * 100
          / lv_duration_seconds_total.
      ENDIF.
      IF rs_interval_result-nonrev_duration_total > 0.
        rs_interval_result-nonrev_p95_tail_pct =
          rs_interval_result-nonrev_p95_tail_secs * 100
          / rs_interval_result-nonrev_duration_total.
      ENDIF.
      IF rs_interval_result-reversed_duration_total > 0.
        rs_interval_result-reversed_p95_tail_pct =
          rs_interval_result-reversed_p95_tail_secs * 100
          / rs_interval_result-reversed_duration_total.
      ENDIF.
      rs_interval_result-duration_p99_seconds =
        calc_exec_duration_percentile(
          it_duration_values = lt_duration_values
          iv_percentile      = 99 ).
      rs_interval_result-nonrev_p99_seconds =
        calc_exec_duration_percentile(
          it_duration_values = lt_nonrev_duration_values
          iv_percentile      = 99 ).
      rs_interval_result-reversed_p99_seconds =
        calc_exec_duration_percentile(
          it_duration_values = lt_reversed_duration_values
          iv_percentile      = 99 ).
      IF rs_interval_result-duration_median_seconds > 0.
        rs_interval_result-duration_p99_median_ratio =
          rs_interval_result-duration_p99_seconds /
          rs_interval_result-duration_median_seconds.
      ENDIF.
      IF rs_interval_result-nonrev_duration_median_secs > 0.
        rs_interval_result-nonrev_p99_median_ratio =
          rs_interval_result-nonrev_p99_seconds /
          rs_interval_result-nonrev_duration_median_secs.
      ENDIF.
      IF rs_interval_result-reversed_duration_median_secs > 0.
        rs_interval_result-reversed_p99_median_ratio =
          rs_interval_result-reversed_p99_seconds /
          rs_interval_result-reversed_duration_median_secs.
      ENDIF.
      LOOP AT lt_duration_values INTO DATA(lv_gross_p99_value).
        IF lv_gross_p99_value > rs_interval_result-duration_p99_seconds.
          rs_interval_result-p99_tail_secs =
            rs_interval_result-p99_tail_secs + lv_gross_p99_value.
          rs_interval_result-duration_p99_exceed_count =
            rs_interval_result-duration_p99_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_nonrev_duration_values INTO DATA(lv_nonrev_p99_value).
        IF lv_nonrev_p99_value > rs_interval_result-nonrev_p99_seconds.
          rs_interval_result-nonrev_p99_tail_secs =
            rs_interval_result-nonrev_p99_tail_secs + lv_nonrev_p99_value.
          rs_interval_result-nonrev_p99_exceed_count =
            rs_interval_result-nonrev_p99_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_reversed_duration_values INTO
          DATA(lv_reversed_p99_value).
        IF lv_reversed_p99_value > rs_interval_result-reversed_p99_seconds.
          rs_interval_result-reversed_p99_tail_secs =
            rs_interval_result-reversed_p99_tail_secs
            + lv_reversed_p99_value.
          rs_interval_result-reversed_p99_exceed_count =
            rs_interval_result-reversed_p99_exceed_count + 1.
        ENDIF.
      ENDLOOP.
      IF lv_duration_value_count > 0.
        rs_interval_result-duration_p99_exceed_pct =
          CONV decfloat34( rs_interval_result-duration_p99_exceed_count )
          * 100 / lv_duration_value_count.
      ENDIF.
      IF lines( lt_nonrev_duration_values ) > 0.
        rs_interval_result-nonrev_p99_exceed_pct =
          CONV decfloat34( rs_interval_result-nonrev_p99_exceed_count )
          * 100 / lines( lt_nonrev_duration_values ).
      ENDIF.
      IF lines( lt_reversed_duration_values ) > 0.
        rs_interval_result-reversed_p99_exceed_pct =
          CONV decfloat34( rs_interval_result-reversed_p99_exceed_count )
          * 100 / lines( lt_reversed_duration_values ).
      ENDIF.
      IF lv_duration_seconds_total > 0.
        rs_interval_result-p99_tail_pct =
          rs_interval_result-p99_tail_secs * 100
          / lv_duration_seconds_total.
      ENDIF.
      IF rs_interval_result-nonrev_duration_total > 0.
        rs_interval_result-nonrev_p99_tail_pct =
          rs_interval_result-nonrev_p99_tail_secs * 100
          / rs_interval_result-nonrev_duration_total.
      ENDIF.
      IF rs_interval_result-reversed_duration_total > 0.
        rs_interval_result-reversed_p99_tail_pct =
          rs_interval_result-reversed_p99_tail_secs * 100
          / rs_interval_result-reversed_duration_total.
      ENDIF.
      DATA(lv_gross_p25_secs) = calc_exec_duration_percentile(
        it_duration_values = lt_duration_values
        iv_percentile      = 25 ).
      DATA(lv_gross_p75_secs) = calc_exec_duration_percentile(
        it_duration_values = lt_duration_values
        iv_percentile      = 75 ).
      rs_interval_result-duration_p25_seconds = lv_gross_p25_secs.
      rs_interval_result-duration_p75_seconds = lv_gross_p75_secs.
      rs_interval_result-duration_iqr_seconds =
        lv_gross_p75_secs - lv_gross_p25_secs.
      DATA(lv_nonrev_p25_secs) = calc_exec_duration_percentile(
        it_duration_values = lt_nonrev_duration_values
        iv_percentile      = 25 ).
      DATA(lv_nonrev_p75_secs) = calc_exec_duration_percentile(
        it_duration_values = lt_nonrev_duration_values
        iv_percentile      = 75 ).
      rs_interval_result-nonrev_p25_seconds = lv_nonrev_p25_secs.
      rs_interval_result-nonrev_p75_seconds = lv_nonrev_p75_secs.
      rs_interval_result-nonrev_iqr_seconds =
        lv_nonrev_p75_secs - lv_nonrev_p25_secs.
      DATA(lv_reversed_p25_secs) = calc_exec_duration_percentile(
        it_duration_values = lt_reversed_duration_values
        iv_percentile      = 25 ).
      DATA(lv_reversed_p75_secs) = calc_exec_duration_percentile(
        it_duration_values = lt_reversed_duration_values
        iv_percentile      = 75 ).
      rs_interval_result-reversed_p25_seconds = lv_reversed_p25_secs.
      rs_interval_result-reversed_p75_seconds = lv_reversed_p75_secs.
      rs_interval_result-reversed_iqr_seconds =
        lv_reversed_p75_secs - lv_reversed_p25_secs.
      IF rs_interval_result-duration_median_seconds > 0.
        rs_interval_result-duration_iqr_median_ratio =
          rs_interval_result-duration_iqr_seconds /
          rs_interval_result-duration_median_seconds.
      ENDIF.
      IF rs_interval_result-nonrev_duration_median_secs > 0.
        rs_interval_result-nonrev_iqr_median_ratio =
          rs_interval_result-nonrev_iqr_seconds /
          rs_interval_result-nonrev_duration_median_secs.
      ENDIF.
      IF rs_interval_result-reversed_duration_median_secs > 0.
        rs_interval_result-reversed_iqr_median_ratio =
          rs_interval_result-reversed_iqr_seconds /
          rs_interval_result-reversed_duration_median_secs.
      ENDIF.
    ENDIF.

    LOOP AT lt_intervals INTO DATA(ls_interval).
      IF ls_interval-duration_seconds > 0.
        IF lv_has_positive_interval = abap_false.
          lv_positive_start_date = ls_interval-start_date.
          lv_positive_start_time = ls_interval-start_time.
          lv_positive_finish_date = ls_interval-finish_date.
          lv_positive_finish_time = ls_interval-finish_time.
          lv_has_positive_interval = abap_true.
        ELSEIF ls_interval-finish_date > lv_positive_finish_date
            OR ( ls_interval-finish_date = lv_positive_finish_date
              AND ls_interval-finish_time > lv_positive_finish_time ).
          lv_positive_finish_date = ls_interval-finish_date.
          lv_positive_finish_time = ls_interval-finish_time.
        ENDIF.
      ENDIF.

      IF ls_interval-duration_seconds <= 0.
        CONTINUE.
      ENDIF.

      IF lv_has_covered_interval = abap_false.
        rs_interval_result-covered_seconds =
          rs_interval_result-covered_seconds
          + ls_interval-duration_seconds.
        lv_covered_finish_date = ls_interval-finish_date.
        lv_covered_finish_time = ls_interval-finish_time.
        lv_has_covered_interval = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_interval-start_date > lv_covered_finish_date
          OR ( ls_interval-start_date = lv_covered_finish_date
            AND ls_interval-start_time > lv_covered_finish_time ).
        rs_interval_result-idle_gap_episode_count =
          rs_interval_result-idle_gap_episode_count + 1.
        DATA(ls_covered_gap_conf) = VALUE
          zif_prod_order_read_repo=>ty_order_confirmation(
            execution_start_date  = lv_covered_finish_date
            execution_start_time  = lv_covered_finish_time
            execution_finish_date = ls_interval-start_date
            execution_finish_time = ls_interval-start_time ).
        DATA(ls_covered_gap_duration) = calc_exec_duration(
          is_confirmation = ls_covered_gap_conf ).
        IF ls_covered_gap_duration-duration_seconds >
            rs_interval_result-longest_idle_gap_secs.
          rs_interval_result-longest_idle_gap_secs =
            ls_covered_gap_duration-duration_seconds.
        ENDIF.
        rs_interval_result-covered_seconds =
          rs_interval_result-covered_seconds
          + ls_interval-duration_seconds.
        lv_covered_finish_date = ls_interval-finish_date.
        lv_covered_finish_time = ls_interval-finish_time.
        CONTINUE.
      ENDIF.

      IF ls_interval-finish_date > lv_covered_finish_date
          OR ( ls_interval-finish_date = lv_covered_finish_date
            AND ls_interval-finish_time > lv_covered_finish_time ).
        DATA(ls_extension_confirmation) = VALUE
          zif_prod_order_read_repo=>ty_order_confirmation(
            execution_start_date  = lv_covered_finish_date
            execution_start_time  = lv_covered_finish_time
            execution_finish_date = ls_interval-finish_date
            execution_finish_time = ls_interval-finish_time ).
        DATA(ls_extension) = calc_exec_duration(
          is_confirmation = ls_extension_confirmation ).
        rs_interval_result-covered_seconds =
          rs_interval_result-covered_seconds
          + ls_extension-duration_seconds.
        lv_covered_finish_date = ls_interval-finish_date.
        lv_covered_finish_time = ls_interval-finish_time.
      ENDIF.
    ENDLOOP.

    rs_interval_result-nonrev_covered_seconds =
      calc_exec_interval_union(
        it_intervals = lt_non_reversed_intervals ).
    rs_interval_result-reversed_covered_seconds =
      calc_exec_interval_union(
        it_intervals = lt_reversed_intervals ).
    rs_interval_result-nonrev_excess_secs =
      rs_interval_result-nonrev_duration_total -
      rs_interval_result-nonrev_covered_seconds.
    rs_interval_result-nonrev_duration_avg_secs =
      calc_exec_duration_avg(
        iv_duration_count         = rs_interval_result-nonrev_duration_count
        iv_duration_seconds_total =
          rs_interval_result-nonrev_duration_total ).
    rs_interval_result-reversed_excess_secs =
      rs_interval_result-reversed_duration_total -
      rs_interval_result-reversed_covered_seconds.
    rs_interval_result-reversed_avg_secs =
      calc_exec_duration_avg(
        iv_duration_count         = rs_interval_result-reversed_duration_count
        iv_duration_seconds_total =
          rs_interval_result-reversed_duration_total ).
    IF rs_interval_result-nonrev_duration_median_secs > 0.
      rs_interval_result-nonrev_avg_median_ratio =
        rs_interval_result-nonrev_duration_avg_secs /
        rs_interval_result-nonrev_duration_median_secs.
    ENDIF.
    IF rs_interval_result-reversed_duration_median_secs > 0.
      rs_interval_result-reversed_avg_median_ratio =
        rs_interval_result-reversed_avg_secs /
        rs_interval_result-reversed_duration_median_secs.
    ENDIF.
    IF lv_duration_seconds_total > 0.
      rs_interval_result-nonrev_duration_pct =
        rs_interval_result-nonrev_duration_total * 100 /
        lv_duration_seconds_total.
      rs_interval_result-reversed_duration_pct =
        rs_interval_result-reversed_duration_total * 100 /
        lv_duration_seconds_total.
    ENDIF.
    rs_interval_result-overlap_excess_seconds =
      lv_duration_seconds_total - rs_interval_result-covered_seconds.
    IF lv_has_positive_interval = abap_true.
      DATA(ls_span_confirmation) = VALUE
        zif_prod_order_read_repo=>ty_order_confirmation(
          execution_start_date  = lv_positive_start_date
          execution_start_time  = lv_positive_start_time
          execution_finish_date = lv_positive_finish_date
          execution_finish_time = lv_positive_finish_time ).
      DATA(ls_interval_span) = calc_exec_duration(
        is_confirmation = ls_span_confirmation ).
      DATA(lv_positive_span_seconds) =
        ls_interval_span-duration_seconds.
      rs_interval_result-idle_gap_seconds =
        ls_interval_span-duration_seconds -
        rs_interval_result-covered_seconds.
      IF rs_interval_result-idle_gap_episode_count > 0.
        rs_interval_result-idle_gap_avg_secs =
          rs_interval_result-idle_gap_seconds /
          rs_interval_result-idle_gap_episode_count.
      ENDIF.
      IF ls_interval_span-duration_seconds > 0.
        rs_interval_result-interval_coverage_pct =
          rs_interval_result-covered_seconds * 100 /
          ls_interval_span-duration_seconds.
      ENDIF.
    ENDIF.

    DATA lv_interval_index TYPE i.
    LOOP AT lt_intervals INTO DATA(ls_pair_left).
      lv_interval_index = sy-tabix.
      IF ls_pair_left-duration_seconds <= 0.
        CONTINUE.
      ENDIF.
      DATA(lv_next_interval_index) = lv_interval_index + 1.
      LOOP AT lt_intervals INTO DATA(ls_pair_right)
          FROM lv_next_interval_index.
        IF ls_pair_right-start_date > ls_pair_left-finish_date
            OR ( ls_pair_right-start_date =
              ls_pair_left-finish_date
              AND ls_pair_right-start_time >=
                ls_pair_left-finish_time ).
          EXIT.
        ENDIF.
        IF ls_pair_right-duration_seconds > 0.
          DATA(lv_pair_finish_date) = ls_pair_left-finish_date.
          DATA(lv_pair_finish_time) = ls_pair_left-finish_time.
          IF ls_pair_right-finish_date < lv_pair_finish_date
              OR ( ls_pair_right-finish_date = lv_pair_finish_date
                AND ls_pair_right-finish_time < lv_pair_finish_time ).
            lv_pair_finish_date = ls_pair_right-finish_date.
            lv_pair_finish_time = ls_pair_right-finish_time.
          ENDIF.
          DATA(ls_pair_overlap_confirmation) = VALUE
            zif_prod_order_read_repo=>ty_order_confirmation(
              execution_start_date  = ls_pair_right-start_date
              execution_start_time  = ls_pair_right-start_time
              execution_finish_date = lv_pair_finish_date
              execution_finish_time = lv_pair_finish_time ).
          DATA(ls_pair_overlap_duration) = calc_exec_duration(
            is_confirmation = ls_pair_overlap_confirmation ).
          IF ls_pair_overlap_duration-duration_seconds >
              rs_interval_result-longest_pair_overlap_secs.
            rs_interval_result-longest_pair_overlap_secs =
              ls_pair_overlap_duration-duration_seconds.
          ENDIF.
          rs_interval_result-overlap_pair_count =
            rs_interval_result-overlap_pair_count + 1.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    SORT lt_events BY event_date event_time concurrency_delta.
    LOOP AT lt_events INTO DATA(ls_event).
      IF lv_has_event_group = abap_false.
        lv_event_group_date = ls_event-event_date.
        lv_event_group_time = ls_event-event_time.
        lv_event_group_delta = ls_event-concurrency_delta.
        lv_has_event_group = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_event-event_date = lv_event_group_date
          AND ls_event-event_time = lv_event_group_time.
        lv_event_group_delta = lv_event_group_delta
          + ls_event-concurrency_delta.
        CONTINUE.
      ENDIF.

      DATA(lv_next_concurrency) = lv_active_concurrency
        + lv_event_group_delta.
      IF lv_active_concurrency <> 1
          AND lv_next_concurrency = 1.
        rs_interval_result-single_episode_count =
          rs_interval_result-single_episode_count + 1.
        lv_single_episode_seconds = 0.
      ENDIF.
      IF lv_active_concurrency < 3 AND lv_next_concurrency >= 3.
        rs_interval_result-three_plus_episode_count =
          rs_interval_result-three_plus_episode_count + 1.
        lv_three_plus_episode_seconds = 0.
      ENDIF.
      IF lv_active_concurrency < 2 AND lv_next_concurrency >= 2.
        rs_interval_result-overlap_episode_count =
          rs_interval_result-overlap_episode_count + 1.
        lv_overlap_episode_seconds = 0.
      ELSEIF lv_active_concurrency >= 2 AND lv_next_concurrency < 2.
        lv_overlap_episode_seconds = 0.
      ENDIF.
      IF lv_next_concurrency > rs_interval_result-peak_concurrency.
        rs_interval_result-peak_concurrency = lv_next_concurrency.
        rs_interval_result-peak_seconds = 0.
        rs_interval_result-peak_episode_count = 0.
        rs_interval_result-longest_peak_secs = 0.
        lv_peak_episode_seconds = 0.
      ENDIF.
      IF lv_active_concurrency < rs_interval_result-peak_concurrency
          AND lv_next_concurrency =
            rs_interval_result-peak_concurrency.
        rs_interval_result-peak_episode_count =
          rs_interval_result-peak_episode_count + 1.
        lv_peak_episode_seconds = 0.
      ELSEIF lv_active_concurrency =
            rs_interval_result-peak_concurrency
          AND lv_next_concurrency <
            rs_interval_result-peak_concurrency.
        lv_peak_episode_seconds = 0.
      ENDIF.
      lv_active_concurrency = lv_next_concurrency.
      DATA(ls_event_seg_conf) = VALUE
        zif_prod_order_read_repo=>ty_order_confirmation(
          execution_start_date  = lv_event_group_date
          execution_start_time  = lv_event_group_time
          execution_finish_date = ls_event-event_date
          execution_finish_time = ls_event-event_time ).
      DATA(ls_event_seg_dur) = calc_exec_duration(
        is_confirmation = ls_event_seg_conf ).
      IF lv_active_concurrency = rs_interval_result-peak_concurrency.
        rs_interval_result-peak_seconds =
          rs_interval_result-peak_seconds
          + ls_event_seg_dur-duration_seconds.
        lv_peak_episode_seconds = lv_peak_episode_seconds
          + ls_event_seg_dur-duration_seconds.
        IF lv_peak_episode_seconds >
            rs_interval_result-longest_peak_secs.
          rs_interval_result-longest_peak_secs =
            lv_peak_episode_seconds.
        ENDIF.
      ENDIF.
      IF lv_active_concurrency >= 2.
        DATA(lv_pair_count) =
          CONV decfloat34( lv_active_concurrency ) *
          CONV decfloat34( lv_active_concurrency - 1 ) / 2.
        rs_interval_result-pairwise_overlap_seconds =
          rs_interval_result-pairwise_overlap_seconds
          + ls_event_seg_dur-duration_seconds * lv_pair_count.
      ENDIF.
      IF lv_active_concurrency >= 2.
        rs_interval_result-overlap_wall_seconds =
          rs_interval_result-overlap_wall_seconds
          + ls_event_seg_dur-duration_seconds.
        lv_overlap_episode_seconds = lv_overlap_episode_seconds
          + ls_event_seg_dur-duration_seconds.
        IF lv_overlap_episode_seconds >
            rs_interval_result-longest_overlap_secs.
          rs_interval_result-longest_overlap_secs =
            lv_overlap_episode_seconds.
        ENDIF.
      ENDIF.
      IF lv_active_concurrency = 2.
        rs_interval_result-exactly_two_seconds =
          rs_interval_result-exactly_two_seconds
          + ls_event_seg_dur-duration_seconds.
      ENDIF.
      IF lv_active_concurrency >= 3.
        rs_interval_result-high_concurrency_seconds =
          rs_interval_result-high_concurrency_seconds
          + ls_event_seg_dur-duration_seconds.
        lv_three_plus_episode_seconds = lv_three_plus_episode_seconds
          + ls_event_seg_dur-duration_seconds.
        IF lv_three_plus_episode_seconds >
            rs_interval_result-longest_three_plus_secs.
          rs_interval_result-longest_three_plus_secs =
            lv_three_plus_episode_seconds.
        ENDIF.
      ENDIF.
      IF lv_active_concurrency = 1.
        lv_single_episode_seconds = lv_single_episode_seconds
          + ls_event_seg_dur-duration_seconds.
        IF lv_single_episode_seconds >
            rs_interval_result-longest_single_secs.
          rs_interval_result-longest_single_secs =
            lv_single_episode_seconds.
        ENDIF.
      ENDIF.

      lv_event_group_date = ls_event-event_date.
      lv_event_group_time = ls_event-event_time.
      lv_event_group_delta = ls_event-concurrency_delta.
    ENDLOOP.
    IF lv_has_event_group = abap_true.
      DATA(lv_final_concurrency) = lv_active_concurrency
        + lv_event_group_delta.
      IF lv_active_concurrency < 2 AND lv_final_concurrency >= 2.
        rs_interval_result-overlap_episode_count =
          rs_interval_result-overlap_episode_count + 1.
        lv_overlap_episode_seconds = 0.
      ELSEIF lv_active_concurrency >= 2 AND lv_final_concurrency < 2.
        lv_overlap_episode_seconds = 0.
      ENDIF.
      lv_active_concurrency = lv_final_concurrency.
      IF lv_active_concurrency > rs_interval_result-peak_concurrency.
        rs_interval_result-peak_concurrency = lv_active_concurrency.
        rs_interval_result-peak_seconds = 0.
      ENDIF.
    ENDIF.
    rs_interval_result-single_active_seconds =
      rs_interval_result-covered_seconds -
      rs_interval_result-overlap_wall_seconds.
    IF rs_interval_result-overlap_episode_count > 0.
      rs_interval_result-overlap_avg_secs =
        rs_interval_result-overlap_wall_seconds /
        CONV decfloat34( rs_interval_result-overlap_episode_count ).
    ENDIF.
    IF rs_interval_result-single_episode_count > 0.
      rs_interval_result-single_active_avg_secs =
        rs_interval_result-single_active_seconds /
        CONV decfloat34( rs_interval_result-single_episode_count ).
    ENDIF.
    IF rs_interval_result-peak_episode_count > 0.
      rs_interval_result-peak_episode_avg_secs =
        rs_interval_result-peak_seconds /
        CONV decfloat34( rs_interval_result-peak_episode_count ).
    ENDIF.
    IF rs_interval_result-overlap_pair_count > 0.
      rs_interval_result-overlap_pair_avg_secs =
        rs_interval_result-pairwise_overlap_seconds /
        CONV decfloat34( rs_interval_result-overlap_pair_count ).
    ENDIF.
    IF rs_interval_result-three_plus_episode_count > 0.
      rs_interval_result-three_plus_avg_secs =
        rs_interval_result-high_concurrency_seconds /
        CONV decfloat34( rs_interval_result-three_plus_episode_count ).
    ENDIF.
    IF lv_positive_span_seconds > 0.
      rs_interval_result-avg_concurrency =
        lv_duration_seconds_total / lv_positive_span_seconds.
    ENDIF.
    IF lv_positive_span_seconds > 0.
      rs_interval_result-peak_concurrency_pct =
        rs_interval_result-peak_seconds * 100 /
        lv_positive_span_seconds.
    ENDIF.
    IF lv_positive_span_seconds > 0.
      rs_interval_result-exactly_two_pct =
        rs_interval_result-exactly_two_seconds * 100 /
        lv_positive_span_seconds.
    ENDIF.
    IF lv_positive_span_seconds > 0.
      rs_interval_result-three_plus_pct =
        rs_interval_result-high_concurrency_seconds * 100 /
        lv_positive_span_seconds.
    ENDIF.
    IF lv_positive_span_seconds > 0.
      rs_interval_result-overlap_wall_pct =
        rs_interval_result-overlap_wall_seconds * 100 /
        lv_positive_span_seconds.
    ENDIF.
    IF lv_positive_span_seconds > 0.
      rs_interval_result-single_active_pct =
        rs_interval_result-single_active_seconds * 100 /
        lv_positive_span_seconds.
    ENDIF.
  ENDMETHOD.


  METHOD calc_exec_interval_union.
    DATA lv_has_covered_interval TYPE abap_bool.
    DATA lv_covered_finish_date TYPE afru-iedd.
    DATA lv_covered_finish_time TYPE afru-iedz.

    LOOP AT it_intervals INTO DATA(ls_interval).
      IF ls_interval-duration_seconds <= 0.
        CONTINUE.
      ENDIF.

      IF lv_has_covered_interval = abap_false.
        rv_covered_seconds = ls_interval-duration_seconds.
        lv_covered_finish_date = ls_interval-finish_date.
        lv_covered_finish_time = ls_interval-finish_time.
        lv_has_covered_interval = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_interval-start_date > lv_covered_finish_date
          OR ( ls_interval-start_date = lv_covered_finish_date
            AND ls_interval-start_time > lv_covered_finish_time ).
        rv_covered_seconds = rv_covered_seconds
          + ls_interval-duration_seconds.
        lv_covered_finish_date = ls_interval-finish_date.
        lv_covered_finish_time = ls_interval-finish_time.
        CONTINUE.
      ENDIF.

      IF ls_interval-finish_date > lv_covered_finish_date
          OR ( ls_interval-finish_date = lv_covered_finish_date
            AND ls_interval-finish_time > lv_covered_finish_time ).
        DATA(ls_extension_conf) = VALUE
          zif_prod_order_read_repo=>ty_order_confirmation(
            execution_start_date  = lv_covered_finish_date
            execution_start_time  = lv_covered_finish_time
            execution_finish_date = ls_interval-finish_date
            execution_finish_time = ls_interval-finish_time ).
        DATA(ls_extension) = calc_exec_duration(
          is_confirmation = ls_extension_conf ).
        rv_covered_seconds = rv_covered_seconds
          + ls_extension-duration_seconds.
        lv_covered_finish_date = ls_interval-finish_date.
        lv_covered_finish_time = ls_interval-finish_time.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  METHOD update_conf_execution_metrics.
    IF is_confirmation-execution_start_date IS NOT INITIAL.
      ADD 1 TO cv_execution_start_count.
      IF cv_first_execution_start_date IS INITIAL
          OR is_confirmation-execution_start_date <
            cv_first_execution_start_date
          OR ( is_confirmation-execution_start_date =
            cv_first_execution_start_date
            AND is_confirmation-execution_start_time <
              cv_first_execution_start_time ).
        cv_first_execution_start_date =
          is_confirmation-execution_start_date.
        cv_first_execution_start_time =
          is_confirmation-execution_start_time.
      ENDIF.
    ENDIF.

    IF is_confirmation-execution_finish_date IS NOT INITIAL.
      ADD 1 TO cv_execution_finish_count.
      IF cv_last_execution_finish_date IS INITIAL
          OR is_confirmation-execution_finish_date >
            cv_last_execution_finish_date
          OR ( is_confirmation-execution_finish_date =
            cv_last_execution_finish_date
            AND is_confirmation-execution_finish_time >
              cv_last_execution_finish_time ).
        cv_last_execution_finish_date =
          is_confirmation-execution_finish_date.
        cv_last_execution_finish_time =
          is_confirmation-execution_finish_time.
      ENDIF.
    ENDIF.

    DATA(ls_duration) = calc_exec_duration(
      is_confirmation = is_confirmation ).
    CASE ls_duration-status.
      WHEN c_exec_duration_invalid.
        ADD 1 TO cv_invalid_duration_count.
      WHEN c_exec_duration_valid.
        IF cv_duration_count = 0.
          cv_duration_seconds_min = ls_duration-duration_seconds.
          cv_duration_seconds_max = ls_duration-duration_seconds.
        ELSE.
          IF ls_duration-duration_seconds < cv_duration_seconds_min.
            cv_duration_seconds_min = ls_duration-duration_seconds.
          ENDIF.
          IF ls_duration-duration_seconds > cv_duration_seconds_max.
            cv_duration_seconds_max = ls_duration-duration_seconds.
          ENDIF.
        ENDIF.
        IF ls_duration-duration_seconds = 0.
          ADD 1 TO cv_zero_duration_count.
        ENDIF.
        ADD 1 TO cv_duration_count.
        cv_duration_seconds = cv_duration_seconds
          + ls_duration-duration_seconds.
    ENDCASE.
  ENDMETHOD.

  METHOD read_confirmations_bulk.
    DATA lv_snapshot_timestamp TYPE timestampl.
    DATA lv_maximum_results TYPE i.
    DATA lv_has_cursor TYPE abap_bool VALUE abap_false.
    DATA lv_confirmation_is_after TYPE abap_bool.
    DATA lv_is_truncated TYPE abap_bool VALUE abap_false.
    DATA lv_last_confirmation_index TYPE i.
    DATA ls_page_selection TYPE
      zif_prod_order_read_repo=>ty_confirmation_page_selection.
    DATA lt_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    rs_result-is_successful = abap_true.

    IF iv_order_category IS NOT INITIAL
        AND iv_order_category <> '10'
        AND iv_order_category <> '40'.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_exclude_reversed <> abap_true
          AND iv_exclude_reversed <> abap_false )
        OR ( iv_reversed_only <> abap_true
          AND iv_reversed_only <> abap_false )
        OR ( iv_exclude_reversed = abap_true
          AND iv_reversed_only = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_final_only <> abap_true AND iv_final_only <> abap_false )
        OR ( iv_partial_only <> abap_true
          AND iv_partial_only <> abap_false )
        OR ( iv_final_only = abap_true AND iv_partial_only = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_filter_control_key <> abap_true
          AND iv_filter_control_key <> abap_false )
        OR ( iv_filter_op_description <> abap_true
          AND iv_filter_op_description <> abap_false )
        OR ( iv_filter_resource_object_id <> abap_true
          AND iv_filter_resource_object_id <> abap_false )
        OR ( iv_filter_work_center <> abap_true
          AND iv_filter_work_center <> abap_false )
        OR ( iv_filter_work_center_plant <> abap_true
          AND iv_filter_work_center_plant <> abap_false )
        OR ( iv_filter_entered_by <> abap_true
          AND iv_filter_entered_by <> abap_false )
        OR ( iv_filter_changed_by <> abap_true
          AND iv_filter_changed_by <> abap_false )
        OR ( iv_filter_entry_time <> abap_true
          AND iv_filter_entry_time <> abap_false )
        OR ( iv_filter_quantity_unit <> abap_true
          AND iv_filter_quantity_unit <> abap_false )
        OR ( iv_positive_yield_only <> abap_true
          AND iv_positive_yield_only <> abap_false )
        OR ( iv_positive_rework_only <> abap_true
          AND iv_positive_rework_only <> abap_false )
        OR ( iv_positive_scrap_only <> abap_true
          AND iv_positive_scrap_only <> abap_false )
        OR ( iv_filter_yield_quantity_from <> abap_true
          AND iv_filter_yield_quantity_from <> abap_false )
        OR ( iv_filter_yield_quantity_to <> abap_true
          AND iv_filter_yield_quantity_to <> abap_false )
        OR ( iv_filter_rework_quantity_from <> abap_true
          AND iv_filter_rework_quantity_from <> abap_false )
        OR ( iv_filter_rework_quantity_to <> abap_true
          AND iv_filter_rework_quantity_to <> abap_false )
        OR ( iv_filter_scrap_quantity_from <> abap_true
          AND iv_filter_scrap_quantity_from <> abap_false )
        OR ( iv_filter_scrap_quantity_to <> abap_true
          AND iv_filter_scrap_quantity_to <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_operation_counter_from IS NOT INITIAL
        AND iv_operation_counter_to IS NOT INITIAL
        AND iv_operation_counter_from > iv_operation_counter_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_operation_number_from IS NOT INITIAL
        AND iv_operation_number_to IS NOT INITIAL
        AND iv_operation_number_from > iv_operation_number_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_operation_sequence_from IS NOT INITIAL
        AND iv_operation_sequence_to IS NOT INITIAL
        AND iv_operation_sequence_from > iv_operation_sequence_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_suboperation_number_from IS NOT INITIAL
        AND iv_suboperation_number_to IS NOT INITIAL
        AND iv_suboperation_number_from > iv_suboperation_number_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_filter_operation_sequence <> abap_true
        AND iv_filter_operation_sequence <> abap_false )
        OR ( iv_filter_suboperation_number <> abap_true
          AND iv_filter_suboperation_number <> abap_false )
        OR ( iv_operation_number IS INITIAL
          AND ( iv_suboperation_number IS NOT INITIAL
            OR iv_suboperation_number_from IS NOT INITIAL
            OR iv_suboperation_number_to IS NOT INITIAL
            OR iv_filter_suboperation_number = abap_true ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_confirmation_number IS INITIAL
        AND iv_confirmation_counter IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_posting_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_posting_date_from ) <> abap_true )
        OR ( iv_posting_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_posting_date_to ) <> abap_true )
        OR ( iv_posting_date_from IS NOT INITIAL
          AND iv_posting_date_to IS NOT INITIAL
          AND iv_posting_date_from > iv_posting_date_to ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF ( iv_entry_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_entry_date_from ) <> abap_true )
        OR ( iv_entry_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_entry_date_to ) <> abap_true )
        OR ( iv_entry_date_from IS NOT INITIAL
          AND iv_entry_date_to IS NOT INITIAL
          AND iv_entry_date_from > iv_entry_date_to ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF ( iv_execution_start_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_execution_start_date_from ) <> abap_true )
        OR ( iv_execution_start_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_execution_start_date_to ) <> abap_true )
        OR ( iv_execution_start_date_from IS NOT INITIAL
          AND iv_execution_start_date_to IS NOT INITIAL
          AND iv_execution_start_date_from >
            iv_execution_start_date_to )
        OR ( iv_execution_finish_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_execution_finish_date_from ) <> abap_true )
        OR ( iv_execution_finish_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_execution_finish_date_to ) <> abap_true )
        OR ( iv_execution_finish_date_from IS NOT INITIAL
          AND iv_execution_finish_date_to IS NOT INITIAL
          AND iv_execution_finish_date_from >
            iv_execution_finish_date_to ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF ( iv_filter_execution_start_time <> abap_true
          AND iv_filter_execution_start_time <> abap_false )
        OR ( iv_filter_exec_finish_time <> abap_true
          AND iv_filter_exec_finish_time <> abap_false )
        OR ( iv_filter_execution_start_time = abap_false
          AND ( iv_execution_start_time_from IS NOT INITIAL
            OR iv_execution_start_time_to IS NOT INITIAL ) )
        OR ( iv_filter_execution_start_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
            iv_time = iv_execution_start_time_from ) <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = iv_execution_start_time_to ) <> abap_true
            OR iv_execution_start_time_from >
              iv_execution_start_time_to ) )
        OR ( iv_filter_exec_finish_time = abap_false
          AND ( iv_execution_finish_time_from IS NOT INITIAL
            OR iv_execution_finish_time_to IS NOT INITIAL ) )
        OR ( iv_filter_exec_finish_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
            iv_time = iv_execution_finish_time_from ) <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = iv_execution_finish_time_to ) <> abap_true
            OR iv_execution_finish_time_from >
              iv_execution_finish_time_to ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF ( iv_filter_entry_time = abap_false
          AND ( iv_entry_time_from IS NOT INITIAL
            OR iv_entry_time_to IS NOT INITIAL ) )
        OR ( iv_filter_entry_time = abap_true
          AND ( zcl_date_validation=>is_valid_time(
            iv_time = iv_entry_time_from ) <> abap_true
            OR zcl_date_validation=>is_valid_time(
              iv_time = iv_entry_time_to ) <> abap_true
            OR iv_entry_time_from > iv_entry_time_to ) ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF ( iv_last_change_date_from IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_last_change_date_from ) <> abap_true )
        OR ( iv_last_change_date_to IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_last_change_date_to ) <> abap_true )
        OR ( iv_last_change_date_from IS NOT INITIAL
          AND iv_last_change_date_to IS NOT INITIAL
          AND iv_last_change_date_from > iv_last_change_date_to ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF ( iv_filter_yield_quantity_from = abap_false
          AND iv_yield_quantity_from IS NOT INITIAL )
        OR ( iv_filter_yield_quantity_to = abap_false
          AND iv_yield_quantity_to IS NOT INITIAL )
        OR ( iv_filter_rework_quantity_from = abap_false
          AND iv_rework_quantity_from IS NOT INITIAL )
        OR ( iv_filter_rework_quantity_to = abap_false
          AND iv_rework_quantity_to IS NOT INITIAL )
        OR ( iv_filter_scrap_quantity_from = abap_false
          AND iv_scrap_quantity_from IS NOT INITIAL )
        OR ( iv_filter_scrap_quantity_to = abap_false
          AND iv_scrap_quantity_to IS NOT INITIAL )
        OR ( iv_filter_yield_quantity_from = abap_true
          AND iv_filter_yield_quantity_to = abap_true
          AND iv_yield_quantity_from > iv_yield_quantity_to )
        OR ( iv_filter_rework_quantity_from = abap_true
          AND iv_filter_rework_quantity_to = abap_true
          AND iv_rework_quantity_from > iv_rework_quantity_to )
        OR ( iv_filter_scrap_quantity_from = abap_true
          AND iv_filter_scrap_quantity_to = abap_true
          AND iv_scrap_quantity_from > iv_scrap_quantity_to )
        OR ( ( iv_filter_yield_quantity_from = abap_true
              OR iv_filter_yield_quantity_to = abap_true
              OR iv_filter_rework_quantity_from = abap_true
              OR iv_filter_rework_quantity_to = abap_true
              OR iv_filter_scrap_quantity_from = abap_true
              OR iv_filter_scrap_quantity_to = abap_true )
          AND iv_quantity_unit IS INITIAL
          AND iv_filter_quantity_unit <> abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_maximum_results IS SUPPLIED.
      lv_maximum_results = iv_maximum_results.
    ELSE.
      lv_maximum_results = 500.
    ENDIF.
    IF lv_maximum_results < 1 OR lv_maximum_results > 500.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_after_production_order IS SUPPLIED
        OR iv_after_posting_date IS SUPPLIED
        OR iv_after_confirmation IS SUPPLIED
        OR iv_after_confirmation_counter IS SUPPLIED.
      IF iv_after_production_order IS NOT SUPPLIED
          OR iv_after_posting_date IS NOT SUPPLIED
          OR iv_after_confirmation IS NOT SUPPLIED
          OR iv_after_confirmation_counter IS NOT SUPPLIED
          OR iv_after_production_order IS INITIAL
          OR iv_after_confirmation IS INITIAL
          OR iv_after_confirmation_counter IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = iv_after_posting_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_has_cursor = abap_true.
    ENDIF.

    IF it_production_orders IS INITIAL.
      IF lv_has_cursor = abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      RETURN.
    ENDIF.

    validate_order_numbers(
      it_production_orders = it_production_orders ).
    IF lv_has_cursor = abap_true.
      READ TABLE it_production_orders
        WITH KEY table_line = iv_after_production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDIF.

    ls_page_selection = VALUE #(
      maximum_results            = lv_maximum_results
      has_cursor                 = lv_has_cursor
      after_production_order     = iv_after_production_order
      after_posting_date         = iv_after_posting_date
      after_confirmation         = iv_after_confirmation
      after_confirmation_counter = iv_after_confirmation_counter ).
    lt_confirmations = mo_repository->read_confirmations(
      it_production_orders           = it_production_orders
      iv_order_category              = iv_order_category
      iv_order_type                  = iv_order_type
      iv_operation_counter           = iv_operation_counter
      iv_operation_counter_from      = iv_operation_counter_from
      iv_operation_counter_to        = iv_operation_counter_to
      iv_operation_number            = iv_operation_number
      iv_operation_number_from       = iv_operation_number_from
      iv_operation_number_to         = iv_operation_number_to
      iv_filter_control_key          = iv_filter_control_key
      iv_control_key                 = iv_control_key
      iv_filter_op_description       =
        iv_filter_op_description
      iv_operation_description       = iv_operation_description
      iv_filter_resource_object_id   = iv_filter_resource_object_id
      iv_resource_object_id          = iv_resource_object_id
      iv_filter_work_center          = iv_filter_work_center
      iv_work_center                 = iv_work_center
      iv_filter_work_center_plant    = iv_filter_work_center_plant
      iv_work_center_plant           = iv_work_center_plant
      iv_filter_operation_sequence   = iv_filter_operation_sequence
      iv_operation_sequence          = iv_operation_sequence
      iv_operation_sequence_from     = iv_operation_sequence_from
      iv_operation_sequence_to       = iv_operation_sequence_to
      iv_filter_suboperation_number  = iv_filter_suboperation_number
      iv_suboperation_number         = iv_suboperation_number
      iv_suboperation_number_from    = iv_suboperation_number_from
      iv_suboperation_number_to      = iv_suboperation_number_to
      iv_confirmation_number         = iv_confirmation_number
      iv_confirmation_counter        = iv_confirmation_counter
      iv_posting_date_from           = iv_posting_date_from
      iv_posting_date_to             = iv_posting_date_to
      iv_entry_date_from             = iv_entry_date_from
      iv_entry_date_to               = iv_entry_date_to
      iv_execution_start_date_from   = iv_execution_start_date_from
      iv_execution_start_date_to     = iv_execution_start_date_to
      iv_execution_finish_date_from  = iv_execution_finish_date_from
      iv_execution_finish_date_to    = iv_execution_finish_date_to
      iv_filter_execution_start_time = iv_filter_execution_start_time
      iv_execution_start_time_from   = iv_execution_start_time_from
      iv_execution_start_time_to     = iv_execution_start_time_to
      iv_filter_exec_finish_time     = iv_filter_exec_finish_time
      iv_execution_finish_time_from  = iv_execution_finish_time_from
      iv_execution_finish_time_to    = iv_execution_finish_time_to
      iv_filter_entry_time           = iv_filter_entry_time
      iv_entry_time_from             = iv_entry_time_from
      iv_entry_time_to               = iv_entry_time_to
      iv_filter_entered_by           = iv_filter_entered_by
      iv_entered_by                  = iv_entered_by
      iv_filter_changed_by           = iv_filter_changed_by
      iv_changed_by                  = iv_changed_by
      iv_last_change_date_from       = iv_last_change_date_from
      iv_last_change_date_to         = iv_last_change_date_to
      iv_filter_quantity_unit        = iv_filter_quantity_unit
      iv_quantity_unit               = iv_quantity_unit
      iv_positive_yield_only         = iv_positive_yield_only
      iv_positive_rework_only        = iv_positive_rework_only
      iv_positive_scrap_only         = iv_positive_scrap_only
      iv_filter_yield_quantity_from  = iv_filter_yield_quantity_from
      iv_yield_quantity_from         = iv_yield_quantity_from
      iv_filter_yield_quantity_to    = iv_filter_yield_quantity_to
      iv_yield_quantity_to           = iv_yield_quantity_to
      iv_filter_rework_quantity_from = iv_filter_rework_quantity_from
      iv_rework_quantity_from        = iv_rework_quantity_from
      iv_filter_rework_quantity_to   = iv_filter_rework_quantity_to
      iv_rework_quantity_to          = iv_rework_quantity_to
      iv_filter_scrap_quantity_from  = iv_filter_scrap_quantity_from
      iv_scrap_quantity_from         = iv_scrap_quantity_from
      iv_filter_scrap_quantity_to    = iv_filter_scrap_quantity_to
      iv_scrap_quantity_to           = iv_scrap_quantity_to
      iv_exclude_reversed            = iv_exclude_reversed
      iv_reversed_only               = iv_reversed_only
      iv_final_only                  = iv_final_only
      iv_partial_only                = iv_partial_only
      is_page_selection              = ls_page_selection ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.

    IF lines( lt_confirmations ) > lv_maximum_results + 1.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    SORT lt_confirmations BY production_order posting_date DESCENDING
      confirmation DESCENDING confirmation_counter DESCENDING.
    validate_confirmation_results(
      it_production_orders           = it_production_orders
      it_confirmations               = lt_confirmations
      iv_order_category              = iv_order_category
      iv_order_type                  = iv_order_type
      iv_operation_counter           = iv_operation_counter
      iv_operation_counter_from      = iv_operation_counter_from
      iv_operation_counter_to        = iv_operation_counter_to
      iv_operation_number            = iv_operation_number
      iv_operation_number_from       = iv_operation_number_from
      iv_operation_number_to         = iv_operation_number_to
      iv_filter_control_key          = iv_filter_control_key
      iv_control_key                 = iv_control_key
      iv_filter_op_description       =
        iv_filter_op_description
      iv_operation_description       = iv_operation_description
      iv_filter_resource_object_id   = iv_filter_resource_object_id
      iv_resource_object_id          = iv_resource_object_id
      iv_filter_work_center          = iv_filter_work_center
      iv_work_center                 = iv_work_center
      iv_filter_work_center_plant    = iv_filter_work_center_plant
      iv_work_center_plant           = iv_work_center_plant
      iv_filter_operation_sequence   = iv_filter_operation_sequence
      iv_operation_sequence          = iv_operation_sequence
      iv_operation_sequence_from     = iv_operation_sequence_from
      iv_operation_sequence_to       = iv_operation_sequence_to
      iv_filter_suboperation_number  = iv_filter_suboperation_number
      iv_suboperation_number         = iv_suboperation_number
      iv_suboperation_number_from    = iv_suboperation_number_from
      iv_suboperation_number_to      = iv_suboperation_number_to
      iv_confirmation_number         = iv_confirmation_number
      iv_confirmation_counter        = iv_confirmation_counter
      iv_posting_date_from           = iv_posting_date_from
      iv_posting_date_to             = iv_posting_date_to
      iv_entry_date_from             = iv_entry_date_from
      iv_entry_date_to               = iv_entry_date_to
      iv_execution_start_date_from   = iv_execution_start_date_from
      iv_execution_start_date_to     = iv_execution_start_date_to
      iv_execution_finish_date_from  = iv_execution_finish_date_from
      iv_execution_finish_date_to    = iv_execution_finish_date_to
      iv_filter_execution_start_time = iv_filter_execution_start_time
      iv_execution_start_time_from   = iv_execution_start_time_from
      iv_execution_start_time_to     = iv_execution_start_time_to
      iv_filter_exec_finish_time     = iv_filter_exec_finish_time
      iv_execution_finish_time_from  = iv_execution_finish_time_from
      iv_execution_finish_time_to    = iv_execution_finish_time_to
      iv_filter_entry_time           = iv_filter_entry_time
      iv_entry_time_from             = iv_entry_time_from
      iv_entry_time_to               = iv_entry_time_to
      iv_filter_entered_by           = iv_filter_entered_by
      iv_entered_by                  = iv_entered_by
      iv_filter_changed_by           = iv_filter_changed_by
      iv_changed_by                  = iv_changed_by
      iv_last_change_date_from       = iv_last_change_date_from
      iv_last_change_date_to         = iv_last_change_date_to
      iv_filter_quantity_unit        = iv_filter_quantity_unit
      iv_quantity_unit               = iv_quantity_unit
      iv_positive_yield_only         = iv_positive_yield_only
      iv_positive_rework_only        = iv_positive_rework_only
      iv_positive_scrap_only         = iv_positive_scrap_only
      iv_filter_yield_quantity_from  = iv_filter_yield_quantity_from
      iv_yield_quantity_from         = iv_yield_quantity_from
      iv_filter_yield_quantity_to    = iv_filter_yield_quantity_to
      iv_yield_quantity_to           = iv_yield_quantity_to
      iv_filter_rework_quantity_from = iv_filter_rework_quantity_from
      iv_rework_quantity_from        = iv_rework_quantity_from
      iv_filter_rework_quantity_to   = iv_filter_rework_quantity_to
      iv_rework_quantity_to          = iv_rework_quantity_to
      iv_filter_scrap_quantity_from  = iv_filter_scrap_quantity_from
      iv_scrap_quantity_from         = iv_scrap_quantity_from
      iv_filter_scrap_quantity_to    = iv_filter_scrap_quantity_to
      iv_scrap_quantity_to           = iv_scrap_quantity_to
      iv_exclude_reversed            = iv_exclude_reversed
      iv_reversed_only               = iv_reversed_only
      iv_final_only                  = iv_final_only
      iv_partial_only                = iv_partial_only ).

    IF lv_has_cursor = abap_true.
      LOOP AT lt_confirmations INTO DATA(ls_cursor_confirmation).
        lv_confirmation_is_after = abap_false.
        IF ls_cursor_confirmation-production_order >
            iv_after_production_order
            OR ( ls_cursor_confirmation-production_order =
                iv_after_production_order
              AND ls_cursor_confirmation-posting_date <
                iv_after_posting_date )
            OR ( ls_cursor_confirmation-production_order =
                iv_after_production_order
              AND ls_cursor_confirmation-posting_date =
                iv_after_posting_date
              AND ls_cursor_confirmation-confirmation <
                iv_after_confirmation )
            OR ( ls_cursor_confirmation-production_order =
                iv_after_production_order
              AND ls_cursor_confirmation-posting_date =
                iv_after_posting_date
              AND ls_cursor_confirmation-confirmation =
                iv_after_confirmation
              AND ls_cursor_confirmation-confirmation_counter <
                iv_after_confirmation_counter ).
          lv_confirmation_is_after = abap_true.
        ENDIF.
        IF lv_confirmation_is_after = abap_false.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lines( lt_confirmations ) > lv_maximum_results.
      lv_is_truncated = abap_true.
      DELETE lt_confirmations INDEX lv_maximum_results + 1.
      lv_last_confirmation_index = lines( lt_confirmations ).
      READ TABLE lt_confirmations INDEX lv_last_confirmation_index
        INTO DATA(ls_last_confirmation).
      IF sy-subrc = 0.
        rs_result-next_production_order =
          ls_last_confirmation-production_order.
        rs_result-next_posting_date = ls_last_confirmation-posting_date.
        rs_result-next_confirmation = ls_last_confirmation-confirmation.
        rs_result-next_confirmation_counter =
          ls_last_confirmation-confirmation_counter.
      ENDIF.
    ENDIF.
    rs_result-is_truncated = lv_is_truncated.

    LOOP AT lt_confirmations ASSIGNING
        FIELD-SYMBOL(<ls_status_confirmation>).
      DATA(ls_interval_status) = calc_exec_duration(
        is_confirmation = <ls_status_confirmation> ).
      <ls_status_confirmation>-exec_duration_status =
        ls_interval_status-status.
      <ls_status_confirmation>-exec_duration_issue_code =
        ls_interval_status-issue_code.
      CLEAR <ls_status_confirmation>-exec_duration_seconds.
      IF ls_interval_status-status = c_exec_duration_valid.
        <ls_status_confirmation>-exec_duration_seconds =
          ls_interval_status-duration_seconds.
      ENDIF.
    ENDLOOP.

    rs_result-work_center_summaries = build_wc_conf_summaries(
      it_confirmations = lt_confirmations ).

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_confirmation_order>).

      LOOP AT lt_confirmations INTO DATA(ls_confirmation)
          WHERE production_order = lv_production_order.
        APPEND ls_confirmation TO <ls_confirmation_order>-confirmations.
      ENDLOOP.

      <ls_confirmation_order>-confirmation_count =
        lines( <ls_confirmation_order>-confirmations ).
      rs_result-returned_count = rs_result-returned_count
        + <ls_confirmation_order>-confirmation_count.

      IF <ls_confirmation_order>-confirmations IS INITIAL.
        ADD 1 TO rs_result-empty_count.
      ELSE.
        <ls_confirmation_order>-is_found = abap_true.
        ADD 1 TO rs_result-found_count.
      ENDIF.
    ENDLOOP.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
  ENDMETHOD.

  METHOD search_confirmations_by_window.
    TYPES ty_seen_order TYPE zif_prod_order_read_repo=>ty_order_number.
    DATA lt_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    DATA lt_production_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.
    DATA lv_is_truncated TYPE abap_bool.
    DATA lv_snapshot_timestamp TYPE timestampl.
    DATA lv_last_index TYPE i.
    DATA ls_last_confirmation TYPE
      zif_prod_order_read_repo=>ty_order_confirmation.

    validate_conf_selection( is_selection = is_selection ).
    lt_confirmations = mo_repository->search_confirmations_by_window(
      is_selection = is_selection ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.

    LOOP AT lt_confirmations INTO DATA(ls_confirmation).
      INSERT ls_confirmation-production_order INTO TABLE lt_seen_orders.
      IF sy-subrc = 0.
        APPEND ls_confirmation-production_order TO lt_production_orders.
      ENDIF.
    ENDLOOP.
    IF lt_confirmations IS NOT INITIAL.
      validate_confirmation_results(
        it_production_orders = lt_production_orders
        it_confirmations     = lt_confirmations ).
    ENDIF.
    validate_conf_window_results(
      is_selection     = is_selection
      it_confirmations = lt_confirmations ).

    IF lines( lt_confirmations ) > is_selection-maximum_results.
      lv_is_truncated = abap_true.
      WHILE lines( lt_confirmations ) > is_selection-maximum_results.
        DELETE lt_confirmations INDEX is_selection-maximum_results + 1.
      ENDWHILE.
    ENDIF.

    LOOP AT lt_confirmations ASSIGNING
        FIELD-SYMBOL(<ls_status_confirmation>).
      DATA(ls_interval_status) = calc_exec_duration(
        is_confirmation = <ls_status_confirmation> ).
      <ls_status_confirmation>-exec_duration_status =
        ls_interval_status-status.
      <ls_status_confirmation>-exec_duration_issue_code =
        ls_interval_status-issue_code.
      CLEAR <ls_status_confirmation>-exec_duration_seconds.
      IF ls_interval_status-status = c_exec_duration_valid.
        <ls_status_confirmation>-exec_duration_seconds =
          ls_interval_status-duration_seconds.
      ENDIF.
    ENDLOOP.

    rs_result-confirmations = lt_confirmations.
    rs_result-work_center_summaries = build_wc_conf_summaries(
      it_confirmations = lt_confirmations ).
    rs_result-operation_summaries = build_conf_summaries(
      it_confirmations = lt_confirmations ).
    rs_result-order_summaries = build_conf_order_summaries(
      it_operation_summaries = rs_result-operation_summaries
      it_confirmations       = rs_result-confirmations ).
    rs_result-returned_count = lines( lt_confirmations ).
    rs_result-is_truncated = lv_is_truncated.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
    rs_result-is_successful = abap_true.
    IF lv_is_truncated = abap_true.
      lv_last_index = lines( lt_confirmations ).
      READ TABLE lt_confirmations INTO ls_last_confirmation
        INDEX lv_last_index.
      IF sy-subrc = 0.
        rs_result-next_posting_date =
          ls_last_confirmation-posting_date.
        rs_result-next_production_order =
          ls_last_confirmation-production_order.
        rs_result-next_confirmation = ls_last_confirmation-confirmation.
        rs_result-next_confirmation_counter =
          ls_last_confirmation-confirmation_counter.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD search_conf_window_base_unit.
    TYPES:
      BEGIN OF ty_cached_unit_ratio,
        quantity_unit TYPE afru-meinh,
        ratio         TYPE zif_material_uom_converter=>ty_unit_ratio,
      END OF ty_cached_unit_ratio,
      ty_cached_unit_ratios TYPE HASHED TABLE OF ty_cached_unit_ratio
        WITH UNIQUE KEY quantity_unit.
    DATA lt_cached_unit_ratios TYPE ty_cached_unit_ratios.
    DATA lt_base_op_conf TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    FIELD-SYMBOLS <ls_base_summary> TYPE ty_base_conf_summary.

    rs_result-raw_result = search_confirmations_by_window(
      is_selection = is_selection ).

    LOOP AT rs_result-raw_result-confirmations
        INTO DATA(ls_confirmation).
      DATA ls_cached_unit_ratio TYPE ty_cached_unit_ratio.
      CLEAR ls_cached_unit_ratio.
      READ TABLE lt_cached_unit_ratios INTO ls_cached_unit_ratio
        WITH TABLE KEY quantity_unit = ls_confirmation-quantity_unit.
      IF sy-subrc <> 0.
        ls_cached_unit_ratio-quantity_unit =
          ls_confirmation-quantity_unit.
        ls_cached_unit_ratio-ratio =
          mo_uom_converter->get_material_unit_ratio(
            iv_material         = is_selection-material
            iv_alternative_unit = ls_confirmation-quantity_unit ).
        IF ls_cached_unit_ratio-ratio-is_successful <> abap_true
            OR ls_cached_unit_ratio-ratio-base_unit IS INITIAL
            OR ls_cached_unit_ratio-ratio-numerator <= 0
            OR ls_cached_unit_ratio-ratio-denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_cached_unit_ratio INTO TABLE lt_cached_unit_ratios.
      ENDIF.

      DATA(ls_base_quantity) = VALUE ty_base_conf_quantity(
        confirmation_row     = ls_confirmation
        base_quantity_unit   = ls_cached_unit_ratio-ratio-base_unit
        yield_quantity_base  = convert_conf_qty_to_base(
          iv_quantity    = CONV decfloat34( ls_confirmation-yield_quantity )
          iv_numerator   = ls_cached_unit_ratio-ratio-numerator
          iv_denominator = ls_cached_unit_ratio-ratio-denominator )
        rework_quantity_base = convert_conf_qty_to_base(
          iv_quantity    = CONV decfloat34( ls_confirmation-rework_quantity )
          iv_numerator   = ls_cached_unit_ratio-ratio-numerator
          iv_denominator = ls_cached_unit_ratio-ratio-denominator )
        scrap_quantity_base  = convert_conf_qty_to_base(
          iv_quantity    = CONV decfloat34( ls_confirmation-scrap_quantity )
          iv_numerator   = ls_cached_unit_ratio-ratio-numerator
          iv_denominator = ls_cached_unit_ratio-ratio-denominator ) ).
      APPEND ls_base_quantity TO rs_result-base_quantities.

      READ TABLE rs_result-base_operation_summaries
        ASSIGNING <ls_base_summary>
        WITH TABLE KEY
          production_order       = ls_confirmation-production_order
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          base_quantity_unit     = ls_cached_unit_ratio-ratio-base_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          production_order       = ls_confirmation-production_order
          order_category         = ls_confirmation-order_category
          order_type             = ls_confirmation-order_type
          operation_counter      = ls_confirmation-operation_counter
          operation_number       = ls_confirmation-operation_number
          operation_sequence     = ls_confirmation-operation_sequence
          operation_suboperation =
            ls_confirmation-operation_suboperation
          operation_description  = ls_confirmation-operation_description
          control_key            = ls_confirmation-control_key
          resource_object_id     = ls_confirmation-resource_object_id
          work_center            = ls_confirmation-work_center
          work_center_plant      = ls_confirmation-work_center_plant
          base_quantity_unit     = ls_cached_unit_ratio-ratio-base_unit
          first_posting_date     = ls_confirmation-posting_date
          last_posting_date      = ls_confirmation-posting_date )
          INTO TABLE rs_result-base_operation_summaries.
        READ TABLE rs_result-base_operation_summaries
          ASSIGNING <ls_base_summary>
          WITH TABLE KEY
            production_order = ls_confirmation-production_order
            operation_counter = ls_confirmation-operation_counter
            operation_number = ls_confirmation-operation_number
            operation_sequence = ls_confirmation-operation_sequence
            operation_suboperation =
              ls_confirmation-operation_suboperation
            base_quantity_unit = ls_cached_unit_ratio-ratio-base_unit.
      ENDIF.

      CALL METHOD me->update_conf_execution_metrics
        EXPORTING
          is_confirmation = ls_confirmation
        CHANGING
          cv_execution_start_count       =
            <ls_base_summary>-execution_start_count
          cv_first_execution_start_date  =
            <ls_base_summary>-first_execution_start_date
          cv_first_execution_start_time  =
            <ls_base_summary>-first_execution_start_time
          cv_execution_finish_count      =
            <ls_base_summary>-execution_finish_count
          cv_last_execution_finish_date  =
            <ls_base_summary>-last_execution_finish_date
          cv_last_execution_finish_time  =
            <ls_base_summary>-last_execution_finish_time
          cv_duration_count              =
            <ls_base_summary>-exec_duration_count
          cv_zero_duration_count         =
            <ls_base_summary>-zero_exec_duration_count
          cv_invalid_duration_count      =
            <ls_base_summary>-invalid_exec_duration_count
          cv_duration_seconds            =
            <ls_base_summary>-exec_duration_seconds_total
          cv_duration_seconds_min        =
            <ls_base_summary>-exec_duration_seconds_min
          cv_duration_seconds_max        =
            <ls_base_summary>-exec_duration_seconds_max.
      IF ls_confirmation-posting_date <
          <ls_base_summary>-first_posting_date.
        <ls_base_summary>-first_posting_date =
          ls_confirmation-posting_date.
      ENDIF.
      IF ls_confirmation-posting_date >
          <ls_base_summary>-last_posting_date.
        <ls_base_summary>-last_posting_date =
          ls_confirmation-posting_date.
      ENDIF.
      ADD 1 TO <ls_base_summary>-confirmation_count.
      IF ls_confirmation-is_final = abap_true.
        ADD 1 TO <ls_base_summary>-final_confirmation_count.
      ELSE.
        ADD 1 TO <ls_base_summary>-partial_confirmation_count.
      ENDIF.
      IF ls_confirmation-is_reversed = abap_true.
        ADD 1 TO <ls_base_summary>-reversed_confirmation_count.
      ENDIF.
      <ls_base_summary>-yield_quantity_base_total =
        <ls_base_summary>-yield_quantity_base_total +
        CONV decfloat34( ls_base_quantity-yield_quantity_base ).
      <ls_base_summary>-rework_quantity_base_total =
        <ls_base_summary>-rework_quantity_base_total +
        CONV decfloat34( ls_base_quantity-rework_quantity_base ).
      <ls_base_summary>-scrap_quantity_base_total =
        <ls_base_summary>-scrap_quantity_base_total +
        CONV decfloat34( ls_base_quantity-scrap_quantity_base ).
      IF ls_confirmation-is_reversed <> abap_true.
        <ls_base_summary>-yield_base_non_reversed_total =
          <ls_base_summary>-yield_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-yield_quantity_base ).
        <ls_base_summary>-rework_base_non_reversed_total =
          <ls_base_summary>-rework_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-rework_quantity_base ).
        <ls_base_summary>-scrap_base_non_reversed_total =
          <ls_base_summary>-scrap_base_non_reversed_total +
          CONV decfloat34( ls_base_quantity-scrap_quantity_base ).
      ENDIF.
    ENDLOOP.
    LOOP AT rs_result-base_operation_summaries
        ASSIGNING <ls_base_summary>.
      DATA(ls_base_operation_exec_pct) =
        calc_exec_coverage_pct(
          iv_confirmation_count     =
            <ls_base_summary>-confirmation_count
          iv_execution_start_count  =
            <ls_base_summary>-execution_start_count
          iv_execution_finish_count =
            <ls_base_summary>-execution_finish_count
          iv_duration_count         =
            <ls_base_summary>-exec_duration_count
          iv_zero_duration_count    =
            <ls_base_summary>-zero_exec_duration_count
          iv_invalid_duration_count =
            <ls_base_summary>-invalid_exec_duration_count ).
      <ls_base_summary>-execution_start_pct =
        ls_base_operation_exec_pct-execution_start_pct.
      <ls_base_summary>-execution_finish_pct =
        ls_base_operation_exec_pct-execution_finish_pct.
      <ls_base_summary>-valid_exec_duration_pct =
        ls_base_operation_exec_pct-valid_exec_duration_pct.
      <ls_base_summary>-invalid_exec_duration_pct =
        ls_base_operation_exec_pct-invalid_exec_duration_pct.
      <ls_base_summary>-missing_exec_duration_count =
        ls_base_operation_exec_pct-missing_exec_duration_count.
      <ls_base_summary>-missing_exec_duration_pct =
        ls_base_operation_exec_pct-missing_exec_duration_pct.
      <ls_base_summary>-zero_exec_duration_count =
        ls_base_operation_exec_pct-zero_exec_duration_count.
      <ls_base_summary>-zero_exec_duration_pct =
        ls_base_operation_exec_pct-zero_exec_duration_pct.
      <ls_base_summary>-exec_duration_seconds_avg =
        calc_exec_duration_avg(
          iv_duration_count         =
            <ls_base_summary>-exec_duration_count
          iv_duration_seconds_total =
            <ls_base_summary>-exec_duration_seconds_total ).
      DATA(ls_base_operation_percentages) =
        calculate_conf_percentages(
          iv_confirmation_count =
            <ls_base_summary>-confirmation_count
          iv_final_count        =
            <ls_base_summary>-final_confirmation_count
          iv_partial_count      =
            <ls_base_summary>-partial_confirmation_count
          iv_reversed_count     =
            <ls_base_summary>-reversed_confirmation_count ).
      <ls_base_summary>-final_confirmation_pct =
        ls_base_operation_percentages-final_confirmation_pct.
      <ls_base_summary>-partial_confirmation_pct =
        ls_base_operation_percentages-partial_confirmation_pct.
      <ls_base_summary>-reversed_confirmation_pct =
        ls_base_operation_percentages-reversed_confirmation_pct.
      CLEAR lt_base_op_conf.
      LOOP AT rs_result-base_quantities
          INTO DATA(ls_union_base_op_qty).
        IF ls_union_base_op_qty-base_quantity_unit <>
            <ls_base_summary>-base_quantity_unit
            OR ls_union_base_op_qty-confirmation_row-production_order <>
              <ls_base_summary>-production_order
            OR ls_union_base_op_qty-confirmation_row-operation_counter <>
              <ls_base_summary>-operation_counter
            OR ls_union_base_op_qty-confirmation_row-operation_number <>
              <ls_base_summary>-operation_number
            OR ls_union_base_op_qty-confirmation_row-operation_sequence <>
              <ls_base_summary>-operation_sequence
            OR ls_union_base_op_qty-confirmation_row-operation_suboperation <>
              <ls_base_summary>-operation_suboperation.
          CONTINUE.
        ENDIF.
        APPEND ls_union_base_op_qty-confirmation_row
          TO lt_base_op_conf.
      ENDLOOP.
      DATA(ls_base_op_interval_metrics) = calc_exec_interval_metrics(
        it_confirmations = lt_base_op_conf ).
      <ls_base_summary>-exec_covered_seconds =
        ls_base_op_interval_metrics-covered_seconds.
      <ls_base_summary>-exec_duration_seconds_median =
        ls_base_op_interval_metrics-duration_median_seconds.

      <ls_base_summary>-exec_duration_seconds_p90 =
        ls_base_op_interval_metrics-duration_p90_seconds.
      <ls_base_summary>-exec_duration_seconds_p95 =
        ls_base_op_interval_metrics-duration_p95_seconds.
      <ls_base_summary>-exec_duration_seconds_p99 =
        ls_base_op_interval_metrics-duration_p99_seconds.
      <ls_base_summary>-exec_duration_seconds_p25 =
        ls_base_op_interval_metrics-duration_p25_seconds.
      <ls_base_summary>-exec_duration_seconds_p75 =
        ls_base_op_interval_metrics-duration_p75_seconds.
      <ls_base_summary>-exec_duration_seconds_iqr =
        ls_base_op_interval_metrics-duration_iqr_seconds.
      <ls_base_summary>-exec_duration_seconds_mad =
        ls_base_op_interval_metrics-duration_mad_seconds.
      <ls_base_summary>-exec_nonrev_min_secs =
        ls_base_op_interval_metrics-nonrev_min_seconds.
      <ls_base_summary>-exec_nonrev_max_secs =
        ls_base_op_interval_metrics-nonrev_max_seconds.
      <ls_base_summary>-exec_reversed_min_secs =
        ls_base_op_interval_metrics-reversed_min_seconds.
      <ls_base_summary>-exec_reversed_max_secs =
        ls_base_op_interval_metrics-reversed_max_seconds.
      <ls_base_summary>-exec_nonrev_median_secs =
        ls_base_op_interval_metrics-nonrev_duration_median_secs.
      <ls_base_summary>-exec_reversed_median_secs =
        ls_base_op_interval_metrics-reversed_duration_median_secs.
      <ls_base_summary>-exec_nonrev_p90_secs =
        ls_base_op_interval_metrics-nonrev_p90_seconds.
      <ls_base_summary>-exec_reversed_p90_secs =
        ls_base_op_interval_metrics-reversed_p90_seconds.
      <ls_base_summary>-exec_duration_p90_median_ratio =
        ls_base_op_interval_metrics-duration_p90_median_ratio.
      <ls_base_summary>-exec_nonrev_p90_median_ratio =
        ls_base_op_interval_metrics-nonrev_p90_median_ratio.
      <ls_base_summary>-exec_reversed_p90_median_ratio =
        ls_base_op_interval_metrics-reversed_p90_median_ratio.
      <ls_base_summary>-exec_duration_p90_exceed_count =
        ls_base_op_interval_metrics-duration_p90_exceed_count.
      <ls_base_summary>-exec_duration_p90_exceed_pct =
        ls_base_op_interval_metrics-duration_p90_exceed_pct.
      <ls_base_summary>-exec_nonrev_p90_exceed_count =
        ls_base_op_interval_metrics-nonrev_p90_exceed_count.
      <ls_base_summary>-exec_nonrev_p90_exceed_pct =
        ls_base_op_interval_metrics-nonrev_p90_exceed_pct.
      <ls_base_summary>-exec_reversed_p90_exceed_count =
        ls_base_op_interval_metrics-reversed_p90_exceed_count.
      <ls_base_summary>-exec_reversed_p90_exceed_pct =
        ls_base_op_interval_metrics-reversed_p90_exceed_pct.
      <ls_base_summary>-exec_p90_tail_secs =
        ls_base_op_interval_metrics-p90_tail_secs.
      <ls_base_summary>-exec_p90_tail_pct =
        ls_base_op_interval_metrics-p90_tail_pct.
      <ls_base_summary>-exec_nonrev_p90_tail_secs =
        ls_base_op_interval_metrics-nonrev_p90_tail_secs.
      <ls_base_summary>-exec_nonrev_p90_tail_pct =
        ls_base_op_interval_metrics-nonrev_p90_tail_pct.
      <ls_base_summary>-exec_reversed_p90_tail_secs =
        ls_base_op_interval_metrics-reversed_p90_tail_secs.
      <ls_base_summary>-exec_reversed_p90_tail_pct =
        ls_base_op_interval_metrics-reversed_p90_tail_pct.
      <ls_base_summary>-exec_nonrev_p95_secs =
        ls_base_op_interval_metrics-nonrev_p95_seconds.
      <ls_base_summary>-exec_reversed_p95_secs =
        ls_base_op_interval_metrics-reversed_p95_seconds.
      <ls_base_summary>-exec_duration_p95_median_ratio =
        ls_base_op_interval_metrics-duration_p95_median_ratio.
      <ls_base_summary>-exec_nonrev_p95_median_ratio =
        ls_base_op_interval_metrics-nonrev_p95_median_ratio.
      <ls_base_summary>-exec_reversed_p95_median_ratio =
        ls_base_op_interval_metrics-reversed_p95_median_ratio.
      <ls_base_summary>-exec_duration_p95_exceed_count =
        ls_base_op_interval_metrics-duration_p95_exceed_count.
      <ls_base_summary>-exec_duration_p95_exceed_pct =
        ls_base_op_interval_metrics-duration_p95_exceed_pct.
      <ls_base_summary>-exec_nonrev_p95_exceed_count =
        ls_base_op_interval_metrics-nonrev_p95_exceed_count.
      <ls_base_summary>-exec_nonrev_p95_exceed_pct =
        ls_base_op_interval_metrics-nonrev_p95_exceed_pct.
      <ls_base_summary>-exec_reversed_p95_exceed_count =
        ls_base_op_interval_metrics-reversed_p95_exceed_count.
      <ls_base_summary>-exec_reversed_p95_exceed_pct =
        ls_base_op_interval_metrics-reversed_p95_exceed_pct.
      <ls_base_summary>-exec_p95_tail_secs =
        ls_base_op_interval_metrics-p95_tail_secs.
      <ls_base_summary>-exec_p95_tail_pct =
        ls_base_op_interval_metrics-p95_tail_pct.
      <ls_base_summary>-exec_nonrev_p95_tail_secs =
        ls_base_op_interval_metrics-nonrev_p95_tail_secs.
      <ls_base_summary>-exec_nonrev_p95_tail_pct =
        ls_base_op_interval_metrics-nonrev_p95_tail_pct.
      <ls_base_summary>-exec_reversed_p95_tail_secs =
        ls_base_op_interval_metrics-reversed_p95_tail_secs.
      <ls_base_summary>-exec_reversed_p95_tail_pct =
        ls_base_op_interval_metrics-reversed_p95_tail_pct.
      <ls_base_summary>-exec_duration_p99_exceed_count =
        ls_base_op_interval_metrics-duration_p99_exceed_count.
      <ls_base_summary>-exec_duration_p99_exceed_pct =
        ls_base_op_interval_metrics-duration_p99_exceed_pct.
      <ls_base_summary>-exec_nonrev_p99_exceed_count =
        ls_base_op_interval_metrics-nonrev_p99_exceed_count.
      <ls_base_summary>-exec_nonrev_p99_exceed_pct =
        ls_base_op_interval_metrics-nonrev_p99_exceed_pct.
      <ls_base_summary>-exec_reversed_p99_exceed_count =
        ls_base_op_interval_metrics-reversed_p99_exceed_count.
      <ls_base_summary>-exec_reversed_p99_exceed_pct =
        ls_base_op_interval_metrics-reversed_p99_exceed_pct.
      <ls_base_summary>-exec_p99_tail_secs =
        ls_base_op_interval_metrics-p99_tail_secs.
      <ls_base_summary>-exec_p99_tail_pct =
        ls_base_op_interval_metrics-p99_tail_pct.
      <ls_base_summary>-exec_nonrev_p99_tail_secs =
        ls_base_op_interval_metrics-nonrev_p99_tail_secs.
      <ls_base_summary>-exec_nonrev_p99_tail_pct =
        ls_base_op_interval_metrics-nonrev_p99_tail_pct.
      <ls_base_summary>-exec_reversed_p99_tail_secs =
        ls_base_op_interval_metrics-reversed_p99_tail_secs.
      <ls_base_summary>-exec_reversed_p99_tail_pct =
        ls_base_op_interval_metrics-reversed_p99_tail_pct.
      <ls_base_summary>-exec_duration_p99_median_ratio =
        ls_base_op_interval_metrics-duration_p99_median_ratio.
      <ls_base_summary>-exec_nonrev_p99_median_ratio =
        ls_base_op_interval_metrics-nonrev_p99_median_ratio.
      <ls_base_summary>-exec_reversed_p99_median_ratio =
        ls_base_op_interval_metrics-reversed_p99_median_ratio.
      <ls_base_summary>-exec_nonrev_p99_secs =
        ls_base_op_interval_metrics-nonrev_p99_seconds.
      <ls_base_summary>-exec_reversed_p99_secs =
        ls_base_op_interval_metrics-reversed_p99_seconds.
      <ls_base_summary>-exec_nonrev_iqr_secs =
        ls_base_op_interval_metrics-nonrev_iqr_seconds.
      <ls_base_summary>-exec_nonrev_p25_secs =
        ls_base_op_interval_metrics-nonrev_p25_seconds.
      <ls_base_summary>-exec_nonrev_p75_secs =
        ls_base_op_interval_metrics-nonrev_p75_seconds.
      <ls_base_summary>-exec_reversed_p25_secs =
        ls_base_op_interval_metrics-reversed_p25_seconds.
      <ls_base_summary>-exec_reversed_p75_secs =
        ls_base_op_interval_metrics-reversed_p75_seconds.
      <ls_base_summary>-exec_reversed_iqr_secs =
        ls_base_op_interval_metrics-reversed_iqr_seconds.
      <ls_base_summary>-exec_duration_iqr_median_ratio =
        ls_base_op_interval_metrics-duration_iqr_median_ratio.
      <ls_base_summary>-exec_nonrev_iqr_median_ratio =
        ls_base_op_interval_metrics-nonrev_iqr_median_ratio.
      <ls_base_summary>-exec_reversed_iqr_median_ratio =
        ls_base_op_interval_metrics-reversed_iqr_median_ratio.
      <ls_base_summary>-exec_nonrev_mad_secs =
        ls_base_op_interval_metrics-nonrev_mad_seconds.
      <ls_base_summary>-exec_reversed_mad_secs =
        ls_base_op_interval_metrics-reversed_mad_seconds.
      <ls_base_summary>-exec_duration_mad_median_ratio =
        ls_base_op_interval_metrics-duration_mad_median_ratio.
      <ls_base_summary>-exec_nonrev_mad_median_ratio =
        ls_base_op_interval_metrics-nonrev_mad_median_ratio.
      <ls_base_summary>-exec_reversed_mad_median_ratio =
        ls_base_op_interval_metrics-reversed_mad_median_ratio.
      <ls_base_summary>-exec_duration_avg_median_ratio =
        ls_base_op_interval_metrics-duration_avg_median_ratio.
      <ls_base_summary>-exec_nonrev_avg_median_ratio =
        ls_base_op_interval_metrics-nonrev_avg_median_ratio.
      <ls_base_summary>-exec_reversed_avg_median_ratio =
        ls_base_op_interval_metrics-reversed_avg_median_ratio.
      <ls_base_summary>-exec_pos_duration_count =
        ls_base_op_interval_metrics-positive_duration_count.
      <ls_base_summary>-exec_pos_median_secs =
        ls_base_op_interval_metrics-positive_median_secs.
      <ls_base_summary>-exec_pos_p90_secs =
        ls_base_op_interval_metrics-positive_p90_secs.
      <ls_base_summary>-exec_nonrev_pos_count =
        ls_base_op_interval_metrics-nonrev_positive_count.
      <ls_base_summary>-exec_nonrev_pos_median_secs =
        ls_base_op_interval_metrics-nonrev_positive_median_secs.
      <ls_base_summary>-exec_nonrev_pos_p90_secs =
        ls_base_op_interval_metrics-nonrev_positive_p90_secs.
      <ls_base_summary>-exec_reversed_pos_count =
        ls_base_op_interval_metrics-reversed_positive_count.
      <ls_base_summary>-exec_pos_duration_pct =
        ls_base_op_interval_metrics-positive_pct.
      <ls_base_summary>-exec_nonrev_pos_duration_pct =
        ls_base_op_interval_metrics-nonrev_pos_pct.
      <ls_base_summary>-exec_reversed_pos_duration_pct =
        ls_base_op_interval_metrics-rev_pos_pct.
      <ls_base_summary>-exec_pos_valid_pct =
        ls_base_op_interval_metrics-pos_valid_pct.
      <ls_base_summary>-exec_nonrev_pos_valid_pct =
        ls_base_op_interval_metrics-nonrev_pos_valid_pct.
      <ls_base_summary>-exec_rev_pos_valid_pct =
        ls_base_op_interval_metrics-rev_pos_valid_pct.
      <ls_base_summary>-exec_zero_valid_pct =
        ls_base_op_interval_metrics-zero_valid_pct.
      <ls_base_summary>-exec_nonrev_zero_valid_pct =
        ls_base_op_interval_metrics-nonrev_zero_valid_pct.
      <ls_base_summary>-exec_rev_zero_valid_pct =
        ls_base_op_interval_metrics-rev_zero_valid_pct.
      <ls_base_summary>-exec_zero_valid_count =
        ls_base_op_interval_metrics-zero_valid_count.
      <ls_base_summary>-exec_nonrev_zero_valid_count =
        ls_base_op_interval_metrics-nonrev_zero_valid_count.
      <ls_base_summary>-exec_rev_zero_valid_count =
        ls_base_op_interval_metrics-rev_zero_valid_count.
      <ls_base_summary>-exec_nonrev_invalid_count =
        ls_base_op_interval_metrics-nonrev_invalid_count.
      <ls_base_summary>-exec_rev_invalid_count =
        ls_base_op_interval_metrics-rev_invalid_count.
      <ls_base_summary>-exec_nonrev_missing_count =
        ls_base_op_interval_metrics-nonrev_missing_count.
      <ls_base_summary>-exec_rev_missing_count =
        ls_base_op_interval_metrics-rev_missing_count.
      <ls_base_summary>-exec_nonrev_valid_pct =
        ls_base_op_interval_metrics-nonrev_valid_pct.
      <ls_base_summary>-exec_rev_valid_pct =
        ls_base_op_interval_metrics-rev_valid_pct.
      <ls_base_summary>-exec_nonrev_invalid_pct =
        ls_base_op_interval_metrics-nonrev_invalid_pct.
      <ls_base_summary>-exec_rev_invalid_pct =
        ls_base_op_interval_metrics-rev_invalid_pct.
      <ls_base_summary>-exec_nonrev_missing_pct =
        ls_base_op_interval_metrics-nonrev_missing_pct.
      <ls_base_summary>-exec_rev_missing_pct =
        ls_base_op_interval_metrics-rev_missing_pct.
      <ls_base_summary>-exec_top_issue_code =
        ls_base_op_interval_metrics-top_issue_code.
      <ls_base_summary>-exec_top_issue_status =
        ls_base_op_interval_metrics-top_issue_status.
      <ls_base_summary>-exec_top_issue_count =
        ls_base_op_interval_metrics-top_issue_count.
      <ls_base_summary>-exec_top_issue_pct =
        ls_base_op_interval_metrics-top_issue_pct.
      <ls_base_summary>-exec_top_invalid_issue_code =
        ls_base_op_interval_metrics-top_invalid_issue_code.
      <ls_base_summary>-exec_top_invalid_issue_count =
        ls_base_op_interval_metrics-top_invalid_issue_count.
      <ls_base_summary>-exec_top_invalid_share_pct =
        ls_base_op_interval_metrics-top_invalid_share_pct.
      <ls_base_summary>-exec_top_missing_issue_code =
        ls_base_op_interval_metrics-top_missing_issue_code.
      <ls_base_summary>-exec_top_missing_issue_count =
        ls_base_op_interval_metrics-top_missing_issue_count.
      <ls_base_summary>-exec_top_missing_share_pct =
        ls_base_op_interval_metrics-top_missing_share_pct.
      <ls_base_summary>-exec_top_nonrev_issue_code =
        ls_base_op_interval_metrics-top_nonrev_issue_code.
      <ls_base_summary>-exec_top_nonrev_issue_status =
        ls_base_op_interval_metrics-top_nonrev_issue_status.
      <ls_base_summary>-exec_top_nonrev_issue_count =
        ls_base_op_interval_metrics-top_nonrev_issue_count.
      <ls_base_summary>-exec_top_nonrev_issue_pct =
        ls_base_op_interval_metrics-top_nonrev_issue_pct.
      <ls_base_summary>-exec_top_reversed_issue_code =
        ls_base_op_interval_metrics-top_reversed_issue_code.
      <ls_base_summary>-exec_top_reversed_issue_status =
        ls_base_op_interval_metrics-top_reversed_issue_status.
      <ls_base_summary>-exec_top_reversed_issue_count =
        ls_base_op_interval_metrics-top_reversed_issue_count.
      <ls_base_summary>-exec_top_reversed_issue_pct =
        ls_base_op_interval_metrics-top_reversed_issue_pct.
      <ls_base_summary>-exec_duration_issue_counts =
        ls_base_op_interval_metrics-issue_counts.
      <ls_base_summary>-exec_reversed_pos_median_secs =
        ls_base_op_interval_metrics-reversed_positive_median_secs.
      <ls_base_summary>-exec_reversed_pos_p90_secs =
        ls_base_op_interval_metrics-reversed_positive_p90_secs.
      <ls_base_summary>-exec_pos_p90_med_ratio =
        ls_base_op_interval_metrics-pos_p90_med_ratio.
      <ls_base_summary>-exec_nonrev_pos_p90_med_ratio =
        ls_base_op_interval_metrics-nonrev_pos_p90_med_ratio.
      <ls_base_summary>-exec_rev_pos_p90_med_ratio =
        ls_base_op_interval_metrics-reversed_pos_p90_med_ratio.
      <ls_base_summary>-exec_pos_p90_gt_count =
        ls_base_op_interval_metrics-pos_p90_gt_count.
      <ls_base_summary>-exec_pos_p90_gt_pct =
        ls_base_op_interval_metrics-pos_p90_gt_pct.
      <ls_base_summary>-exec_pos_p90_tail_secs =
        ls_base_op_interval_metrics-pos_p90_tail_secs.
      <ls_base_summary>-exec_pos_p90_tail_pct =
        ls_base_op_interval_metrics-pos_p90_tail_pct.
      <ls_base_summary>-exec_nonrev_pos_p90_gt_count =
        ls_base_op_interval_metrics-nonrev_pos_p90_gt_count.
      <ls_base_summary>-exec_nonrev_pos_p90_gt_pct =
        ls_base_op_interval_metrics-nonrev_pos_p90_gt_pct.
      <ls_base_summary>-exec_nonrev_pos_p90_tail_secs =
        ls_base_op_interval_metrics-nonrev_pos_p90_tail_secs.
      <ls_base_summary>-exec_nonrev_pos_p90_tail_pct =
        ls_base_op_interval_metrics-nonrev_pos_p90_tail_pct.
      <ls_base_summary>-exec_rev_pos_p90_gt_count =
        ls_base_op_interval_metrics-rev_pos_p90_gt_count.
      <ls_base_summary>-exec_rev_pos_p90_gt_pct =
        ls_base_op_interval_metrics-rev_pos_p90_gt_pct.
      <ls_base_summary>-exec_rev_pos_p90_tail_secs =
        ls_base_op_interval_metrics-rev_pos_p90_tail_secs.
      <ls_base_summary>-exec_rev_pos_p90_tail_pct =
        ls_base_op_interval_metrics-rev_pos_p90_tail_pct.
      <ls_base_summary>-exec_pos_p95_secs =
        ls_base_op_interval_metrics-positive_p95_secs.
      <ls_base_summary>-exec_pos_p99_secs =
        ls_base_op_interval_metrics-positive_p99_secs.
      <ls_base_summary>-exec_nonrev_pos_p95_secs =
        ls_base_op_interval_metrics-nonrev_positive_p95_secs.
      <ls_base_summary>-exec_nonrev_pos_p99_secs =
        ls_base_op_interval_metrics-nonrev_positive_p99_secs.
      <ls_base_summary>-exec_rev_pos_p95_secs =
        ls_base_op_interval_metrics-reversed_positive_p95_secs.
      <ls_base_summary>-exec_rev_pos_p99_secs =
        ls_base_op_interval_metrics-reversed_positive_p99_secs.
      <ls_base_summary>-exec_pos_p25_secs =
        ls_base_op_interval_metrics-positive_p25_secs.
      <ls_base_summary>-exec_pos_p75_secs =
        ls_base_op_interval_metrics-positive_p75_secs.
      <ls_base_summary>-exec_nonrev_pos_p25_secs =
        ls_base_op_interval_metrics-nonrev_positive_p25_secs.
      <ls_base_summary>-exec_nonrev_pos_p75_secs =
        ls_base_op_interval_metrics-nonrev_positive_p75_secs.
      <ls_base_summary>-exec_rev_pos_p25_secs =
        ls_base_op_interval_metrics-reversed_positive_p25_secs.
      <ls_base_summary>-exec_rev_pos_p75_secs =
        ls_base_op_interval_metrics-reversed_positive_p75_secs.
      <ls_base_summary>-exec_pos_iqr_secs =
        ls_base_op_interval_metrics-positive_iqr_secs.
      <ls_base_summary>-exec_nonrev_pos_iqr_secs =
        ls_base_op_interval_metrics-nonrev_positive_iqr_secs.
      <ls_base_summary>-exec_rev_pos_iqr_secs =
        ls_base_op_interval_metrics-reversed_positive_iqr_secs.
      <ls_base_summary>-exec_pos_mad_secs =
        ls_base_op_interval_metrics-positive_mad_secs.
      <ls_base_summary>-exec_nonrev_pos_mad_secs =
        ls_base_op_interval_metrics-nonrev_positive_mad_secs.
      <ls_base_summary>-exec_rev_pos_mad_secs =
        ls_base_op_interval_metrics-reversed_positive_mad_secs.
      <ls_base_summary>-exec_pos_iqr_med_ratio =
        ls_base_op_interval_metrics-positive_iqr_med_ratio.
      <ls_base_summary>-exec_nonrev_pos_iqr_med_ratio =
        ls_base_op_interval_metrics-nonrev_positive_iqr_med_ratio.
      <ls_base_summary>-exec_rev_pos_iqr_med_ratio =
        ls_base_op_interval_metrics-reversed_pos_iqr_med_ratio.
      <ls_base_summary>-exec_pos_mad_med_ratio =
        ls_base_op_interval_metrics-positive_mad_med_ratio.
      <ls_base_summary>-exec_nonrev_pos_mad_med_ratio =
        ls_base_op_interval_metrics-nonrev_positive_mad_med_ratio.
      <ls_base_summary>-exec_rev_pos_mad_med_ratio =
        ls_base_op_interval_metrics-reversed_pos_mad_med_ratio.
      <ls_base_summary>-exec_pos_avg_secs =
        ls_base_op_interval_metrics-pos_avg_secs.
      <ls_base_summary>-exec_nonrev_pos_avg_secs =
        ls_base_op_interval_metrics-nonrev_pos_avg_secs.
      <ls_base_summary>-exec_rev_pos_avg_secs =
        ls_base_op_interval_metrics-rev_pos_avg_secs.
      <ls_base_summary>-exec_pos_avg_med_ratio =
        ls_base_op_interval_metrics-pos_avg_med_ratio.
      <ls_base_summary>-exec_nonrev_pos_avg_med_ratio =
        ls_base_op_interval_metrics-nonrev_pos_avg_med_ratio.
      <ls_base_summary>-exec_rev_pos_avg_med_ratio =
        ls_base_op_interval_metrics-rev_pos_avg_med_ratio.
      <ls_base_summary>-exec_pos_min_secs =
        ls_base_op_interval_metrics-positive_min_secs.
      <ls_base_summary>-exec_pos_max_secs =
        ls_base_op_interval_metrics-positive_max_secs.
      <ls_base_summary>-exec_pos_range_secs =
        ls_base_op_interval_metrics-positive_range_secs.
      <ls_base_summary>-exec_nonrev_pos_min_secs =
        ls_base_op_interval_metrics-nonrev_positive_min_secs.
      <ls_base_summary>-exec_nonrev_pos_max_secs =
        ls_base_op_interval_metrics-nonrev_positive_max_secs.
      <ls_base_summary>-exec_nonrev_pos_range_secs =
        ls_base_op_interval_metrics-nonrev_positive_range_secs.
      <ls_base_summary>-exec_rev_pos_min_secs =
        ls_base_op_interval_metrics-reversed_positive_min_secs.
      <ls_base_summary>-exec_rev_pos_max_secs =
        ls_base_op_interval_metrics-reversed_positive_max_secs.
      <ls_base_summary>-exec_rev_pos_range_secs =
        ls_base_op_interval_metrics-reversed_positive_range_secs.
      <ls_base_summary>-exec_pos_p95_gt_count =
        ls_base_op_interval_metrics-pos_p95_gt_count.
      <ls_base_summary>-exec_pos_p95_gt_pct =
        ls_base_op_interval_metrics-pos_p95_gt_pct.
      <ls_base_summary>-exec_pos_p95_tail_secs =
        ls_base_op_interval_metrics-pos_p95_tail_secs.
      <ls_base_summary>-exec_pos_p95_tail_pct =
        ls_base_op_interval_metrics-pos_p95_tail_pct.
      <ls_base_summary>-exec_nonrev_pos_p95_gt_count =
        ls_base_op_interval_metrics-nonrev_pos_p95_gt_count.
      <ls_base_summary>-exec_nonrev_pos_p95_gt_pct =
        ls_base_op_interval_metrics-nonrev_pos_p95_gt_pct.
      <ls_base_summary>-exec_nonrev_pos_p95_tail_secs =
        ls_base_op_interval_metrics-nonrev_pos_p95_tail_secs.
      <ls_base_summary>-exec_nonrev_pos_p95_tail_pct =
        ls_base_op_interval_metrics-nonrev_pos_p95_tail_pct.
      <ls_base_summary>-exec_rev_pos_p95_gt_count =
        ls_base_op_interval_metrics-rev_pos_p95_gt_count.
      <ls_base_summary>-exec_rev_pos_p95_gt_pct =
        ls_base_op_interval_metrics-rev_pos_p95_gt_pct.
      <ls_base_summary>-exec_rev_pos_p95_tail_secs =
        ls_base_op_interval_metrics-rev_pos_p95_tail_secs.
      <ls_base_summary>-exec_rev_pos_p95_tail_pct =
        ls_base_op_interval_metrics-rev_pos_p95_tail_pct.
      <ls_base_summary>-exec_pos_p99_gt_count =
        ls_base_op_interval_metrics-pos_p99_gt_count.
      <ls_base_summary>-exec_pos_p99_gt_pct =
        ls_base_op_interval_metrics-pos_p99_gt_pct.
      <ls_base_summary>-exec_pos_p99_tail_secs =
        ls_base_op_interval_metrics-pos_p99_tail_secs.
      <ls_base_summary>-exec_pos_p99_tail_pct =
        ls_base_op_interval_metrics-pos_p99_tail_pct.
      <ls_base_summary>-exec_nonrev_pos_p99_gt_count =
        ls_base_op_interval_metrics-nonrev_pos_p99_gt_count.
      <ls_base_summary>-exec_nonrev_pos_p99_gt_pct =
        ls_base_op_interval_metrics-nonrev_pos_p99_gt_pct.
      <ls_base_summary>-exec_nonrev_pos_p99_tail_secs =
        ls_base_op_interval_metrics-nonrev_pos_p99_tail_secs.
      <ls_base_summary>-exec_nonrev_pos_p99_tail_pct =
        ls_base_op_interval_metrics-nonrev_pos_p99_tail_pct.
      <ls_base_summary>-exec_rev_pos_p99_gt_count =
        ls_base_op_interval_metrics-rev_pos_p99_gt_count.
      <ls_base_summary>-exec_rev_pos_p99_gt_pct =
        ls_base_op_interval_metrics-rev_pos_p99_gt_pct.
      <ls_base_summary>-exec_rev_pos_p99_tail_secs =
        ls_base_op_interval_metrics-rev_pos_p99_tail_secs.
      <ls_base_summary>-exec_rev_pos_p99_tail_pct =
        ls_base_op_interval_metrics-rev_pos_p99_tail_pct.
      <ls_base_summary>-exec_pos_p95_med_ratio =
        ls_base_op_interval_metrics-pos_p95_med_ratio.
      <ls_base_summary>-exec_nonrev_pos_p95_med_ratio =
        ls_base_op_interval_metrics-nonrev_pos_p95_med_ratio.
      <ls_base_summary>-exec_rev_pos_p95_med_ratio =
        ls_base_op_interval_metrics-rev_pos_p95_med_ratio.
      <ls_base_summary>-exec_pos_p99_med_ratio =
        ls_base_op_interval_metrics-pos_p99_med_ratio.
      <ls_base_summary>-exec_nonrev_pos_p99_med_ratio =
        ls_base_op_interval_metrics-nonrev_pos_p99_med_ratio.
      <ls_base_summary>-exec_rev_pos_p99_med_ratio =
        ls_base_op_interval_metrics-rev_pos_p99_med_ratio.
      <ls_base_summary>-exec_nonrev_covered_secs =
        ls_base_op_interval_metrics-nonrev_covered_seconds.
      <ls_base_summary>-exec_nonrev_duration_count =
        ls_base_op_interval_metrics-nonrev_duration_count.
      <ls_base_summary>-exec_nonrev_total_secs =
        ls_base_op_interval_metrics-nonrev_duration_total.
      <ls_base_summary>-exec_nonrev_duration_avg_secs =
        ls_base_op_interval_metrics-nonrev_duration_avg_secs.
      <ls_base_summary>-exec_nonrev_excess_secs =
        ls_base_op_interval_metrics-nonrev_excess_secs.
      <ls_base_summary>-exec_reversed_duration_count =
        ls_base_op_interval_metrics-reversed_duration_count.
      <ls_base_summary>-exec_reversed_total_secs =
        ls_base_op_interval_metrics-reversed_duration_total.
      <ls_base_summary>-exec_rev_duration_avg_secs =
        ls_base_op_interval_metrics-reversed_avg_secs.
      <ls_base_summary>-exec_reversed_covered_secs =
        ls_base_op_interval_metrics-reversed_covered_seconds.
      <ls_base_summary>-exec_reversed_excess_secs =
        ls_base_op_interval_metrics-reversed_excess_secs.
      <ls_base_summary>-exec_nonrev_duration_pct =
        ls_base_op_interval_metrics-nonrev_duration_pct.
      <ls_base_summary>-exec_reversed_duration_pct =
        ls_base_op_interval_metrics-reversed_duration_pct.
      <ls_base_summary>-exec_single_active_seconds =
        ls_base_op_interval_metrics-single_active_seconds.
      <ls_base_summary>-exec_single_episode_count =
        ls_base_op_interval_metrics-single_episode_count.
      <ls_base_summary>-exec_longest_single_secs =
        ls_base_op_interval_metrics-longest_single_secs.
      <ls_base_summary>-exec_single_active_avg_secs =
        ls_base_op_interval_metrics-single_active_avg_secs.
      <ls_base_summary>-exec_high_concurrency_secs =
        ls_base_op_interval_metrics-high_concurrency_seconds.
      <ls_base_summary>-exec_exactly_two_secs =
        ls_base_op_interval_metrics-exactly_two_seconds.
      <ls_base_summary>-exec_exactly_two_pct =
        ls_base_op_interval_metrics-exactly_two_pct.
      <ls_base_summary>-exec_3plus_episode_count =
        ls_base_op_interval_metrics-three_plus_episode_count.
      <ls_base_summary>-exec_longest_3plus_secs =
        ls_base_op_interval_metrics-longest_three_plus_secs.
      <ls_base_summary>-exec_3plus_avg_secs =
        ls_base_op_interval_metrics-three_plus_avg_secs.
      <ls_base_summary>-exec_3plus_pct =
        ls_base_op_interval_metrics-three_plus_pct.
      <ls_base_summary>-exec_overlap_excess_seconds =
        ls_base_op_interval_metrics-overlap_excess_seconds.
      <ls_base_summary>-exec_peak_concurrency =
        ls_base_op_interval_metrics-peak_concurrency.
      <ls_base_summary>-exec_idle_gap_seconds =
        ls_base_op_interval_metrics-idle_gap_seconds.
      <ls_base_summary>-exec_idle_gap_episode_count =
        ls_base_op_interval_metrics-idle_gap_episode_count.
      <ls_base_summary>-exec_idle_gap_avg_secs =
        ls_base_op_interval_metrics-idle_gap_avg_secs.
      <ls_base_summary>-exec_interval_coverage_pct =
        ls_base_op_interval_metrics-interval_coverage_pct.
      <ls_base_summary>-exec_single_active_pct =
        ls_base_op_interval_metrics-single_active_pct.
      <ls_base_summary>-exec_overlap_wall_pct =
        ls_base_op_interval_metrics-overlap_wall_pct.
      <ls_base_summary>-exec_longest_idle_gap_secs =
        ls_base_op_interval_metrics-longest_idle_gap_secs.
      <ls_base_summary>-exec_overlap_wall_seconds =
        ls_base_op_interval_metrics-overlap_wall_seconds.
      <ls_base_summary>-exec_pairwise_overlap_secs =
        ls_base_op_interval_metrics-pairwise_overlap_seconds.
      <ls_base_summary>-exec_overlap_episode_count =
        ls_base_op_interval_metrics-overlap_episode_count.
      <ls_base_summary>-exec_overlap_pair_count =
        ls_base_op_interval_metrics-overlap_pair_count.
      <ls_base_summary>-exec_overlap_pair_avg_secs =
        ls_base_op_interval_metrics-overlap_pair_avg_secs.
      <ls_base_summary>-exec_longest_pair_overlap_secs =
        ls_base_op_interval_metrics-longest_pair_overlap_secs.
      <ls_base_summary>-exec_peak_concurrency_secs =
        ls_base_op_interval_metrics-peak_seconds.
      <ls_base_summary>-exec_peak_concurrency_pct =
        ls_base_op_interval_metrics-peak_concurrency_pct.
      <ls_base_summary>-exec_peak_episode_count =
        ls_base_op_interval_metrics-peak_episode_count.
      <ls_base_summary>-exec_longest_peak_secs =
        ls_base_op_interval_metrics-longest_peak_secs.
      <ls_base_summary>-exec_peak_episode_avg_secs =
        ls_base_op_interval_metrics-peak_episode_avg_secs.
      <ls_base_summary>-exec_avg_concurrency =
        ls_base_op_interval_metrics-avg_concurrency.
      <ls_base_summary>-exec_longest_overlap_secs =
        ls_base_op_interval_metrics-longest_overlap_secs.
      <ls_base_summary>-exec_overlap_avg_secs =
        ls_base_op_interval_metrics-overlap_avg_secs.
    ENDLOOP.
    rs_result-base_work_center_summaries = build_base_wc_conf_summaries(
      it_base_quantities = rs_result-base_quantities ).
    rs_result-base_order_summaries = build_base_order_summaries(
      it_operation_summaries = rs_result-base_operation_summaries
      it_base_quantities     = rs_result-base_quantities ).
  ENDMETHOD.

  METHOD convert_conf_qty_to_base.
    TRY.
        rv_quantity = CONV mard-labst(
          iv_quantity
          * CONV decfloat34( iv_numerator )
          / CONV decfloat34( iv_denominator ) ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.

    IF iv_quantity <> 0 AND rv_quantity IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_operation_results.
    TYPES:
      BEGIN OF ty_operation_key,
        production_order  TYPE
          zif_prod_order_read_repo=>ty_order_operation-production_order,
        operation_counter TYPE
          zif_prod_order_read_repo=>ty_order_operation-operation_counter,
      END OF ty_operation_key.
    TYPES ty_operation_keys TYPE HASHED TABLE OF ty_operation_key
      WITH UNIQUE KEY production_order operation_counter.
    DATA lt_requested_orders TYPE HASHED TABLE OF
      zif_prod_order_read_repo=>ty_order_number WITH UNIQUE KEY table_line.
    DATA lt_operation_keys TYPE ty_operation_keys.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      INSERT lv_production_order INTO TABLE lt_requested_orders.
    ENDLOOP.

    LOOP AT it_operations INTO DATA(ls_operation).
      READ TABLE lt_requested_orders
        WITH TABLE KEY table_line = ls_operation-production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0
          OR ls_operation-production_order IS INITIAL
          OR ls_operation-operation_counter IS INITIAL
          OR ls_operation-operation_number IS INITIAL
          OR ( ( iv_filter_resource_object_id = abap_true
              OR iv_resource_object_id IS NOT INITIAL )
            AND ls_operation-resource_object_id <>
              iv_resource_object_id )
            OR ( ( iv_filter_work_center = abap_true
                OR iv_work_center IS NOT INITIAL )
              AND ls_operation-work_center <> iv_work_center )
            OR ( ( iv_filter_work_center_plant = abap_true
                OR iv_work_center_plant IS NOT INITIAL )
              AND ls_operation-work_center_plant <> iv_work_center_plant )
            OR ( ( iv_filter_control_key = abap_true
                OR iv_control_key IS NOT INITIAL )
              AND ls_operation-control_key <> iv_control_key )
            OR ( ( iv_filter_op_description = abap_true
                OR iv_operation_description IS NOT INITIAL )
              AND ls_operation-operation_description <>
                iv_operation_description )
            OR ( iv_operation_number IS NOT INITIAL
              AND ls_operation-operation_number <> iv_operation_number )
            OR ( iv_operation_number_from IS NOT INITIAL
              AND ls_operation-operation_number < iv_operation_number_from )
            OR ( iv_operation_number_to IS NOT INITIAL
              AND ls_operation-operation_number > iv_operation_number_to )
            OR ( iv_operation_counter IS NOT INITIAL
              AND ls_operation-operation_counter <> iv_operation_counter )
            OR ( iv_operation_counter_from IS NOT INITIAL
              AND ls_operation-operation_counter <
                iv_operation_counter_from )
            OR ( iv_operation_counter_to IS NOT INITIAL
              AND ls_operation-operation_counter >
                iv_operation_counter_to )
            OR ( ( iv_filter_operation_sequence = abap_true
                OR iv_operation_sequence IS NOT INITIAL )
              AND ls_operation-operation_sequence <> iv_operation_sequence )
            OR ( iv_operation_sequence_from IS NOT INITIAL
              AND ls_operation-operation_sequence <
                iv_operation_sequence_from )
            OR ( iv_operation_sequence_to IS NOT INITIAL
              AND ls_operation-operation_sequence >
                iv_operation_sequence_to )
            OR ( ( iv_filter_suboperation_number = abap_true
                OR iv_suboperation_number IS NOT INITIAL )
              AND ls_operation-suboperation_number <>
                iv_suboperation_number )
            OR ( iv_suboperation_number_from IS NOT INITIAL
              AND ls_operation-suboperation_number <
                iv_suboperation_number_from )
            OR ( iv_suboperation_number_to IS NOT INITIAL
              AND ls_operation-suboperation_number >
                iv_suboperation_number_to )
            OR ( iv_order_category IS NOT INITIAL
              AND ls_operation-order_category <> iv_order_category )
            OR ( iv_order_type IS NOT INITIAL
              AND ls_operation-order_type <> iv_order_type ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        production_order  = ls_operation-production_order
        operation_counter = ls_operation-operation_counter )
        INTO TABLE lt_operation_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_operations_bulk.
    DATA lv_snapshot_timestamp TYPE timestampl.
    DATA lt_page_operations TYPE
      zif_prod_order_read_repo=>ty_order_operations.
    DATA lv_maximum_results TYPE i.
    DATA lv_has_cursor TYPE abap_bool VALUE abap_false.
    DATA lv_operation_is_after_cursor TYPE abap_bool.
    DATA lv_is_truncated TYPE abap_bool VALUE abap_false.
    rs_result-is_successful = abap_true.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_maximum_results IS SUPPLIED.
      lv_maximum_results = iv_maximum_results.
    ELSE.
      lv_maximum_results = 500.
    ENDIF.
    IF lv_maximum_results < 1 OR lv_maximum_results > 500.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_filter_resource_object_id <> abap_true
        AND iv_filter_resource_object_id <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_filter_work_center <> abap_true
        AND iv_filter_work_center <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_filter_work_center_plant <> abap_true
        AND iv_filter_work_center_plant <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_filter_control_key <> abap_true
        AND iv_filter_control_key <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_filter_op_description <> abap_true
        AND iv_filter_op_description <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_filter_operation_sequence <> abap_true
        AND iv_filter_operation_sequence <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_filter_suboperation_number <> abap_true
        AND iv_filter_suboperation_number <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_order_category IS NOT INITIAL
        AND iv_order_category <> '10'
        AND iv_order_category <> '40'.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_operation_number_from IS NOT INITIAL
        AND iv_operation_number_to IS NOT INITIAL
        AND iv_operation_number_from > iv_operation_number_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_operation_counter_from IS NOT INITIAL
        AND iv_operation_counter_to IS NOT INITIAL
        AND iv_operation_counter_from > iv_operation_counter_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_operation_sequence_from IS NOT INITIAL
        AND iv_operation_sequence_to IS NOT INITIAL
        AND iv_operation_sequence_from > iv_operation_sequence_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF iv_suboperation_number_from IS NOT INITIAL
        AND iv_suboperation_number_to IS NOT INITIAL
        AND iv_suboperation_number_from > iv_suboperation_number_to.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF ( iv_suboperation_number_from IS NOT INITIAL
        OR iv_suboperation_number_to IS NOT INITIAL )
        AND iv_operation_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    validate_order_numbers(
      it_production_orders = it_production_orders ).
    IF iv_after_production_order IS SUPPLIED
        OR iv_after_operation_sequence IS SUPPLIED
        OR iv_after_operation_number IS SUPPLIED
        OR iv_after_suboperation_number IS SUPPLIED
        OR iv_after_operation_counter IS SUPPLIED.
      IF iv_after_production_order IS NOT SUPPLIED
          OR iv_after_operation_sequence IS NOT SUPPLIED
          OR iv_after_operation_number IS NOT SUPPLIED
          OR iv_after_suboperation_number IS NOT SUPPLIED
          OR iv_after_operation_counter IS NOT SUPPLIED
          OR iv_after_production_order IS INITIAL
          OR iv_after_operation_number IS INITIAL
          OR iv_after_operation_counter IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE it_production_orders
        WITH KEY table_line = iv_after_production_order
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_has_cursor = abap_true.
    ENDIF.

    DATA(ls_page_selection) =
      VALUE zif_prod_order_read_repo=>ty_operation_page_selection(
        maximum_results           = lv_maximum_results
        has_cursor                = lv_has_cursor
        after_production_order    = iv_after_production_order
        after_operation_sequence  = iv_after_operation_sequence
        after_operation_number    = iv_after_operation_number
        after_suboperation_number = iv_after_suboperation_number
        after_operation_counter   = iv_after_operation_counter ).

    DATA(lt_operations) = mo_repository->read_operations(
      it_production_orders          = it_production_orders
      iv_filter_resource_object_id  = iv_filter_resource_object_id
      iv_resource_object_id         = iv_resource_object_id
      iv_filter_work_center         = iv_filter_work_center
      iv_work_center                = iv_work_center
      iv_filter_work_center_plant   = iv_filter_work_center_plant
      iv_work_center_plant          = iv_work_center_plant
      iv_filter_control_key         = iv_filter_control_key
      iv_control_key                = iv_control_key
      iv_filter_op_description      = iv_filter_op_description
      iv_operation_description      = iv_operation_description
      iv_operation_number           = iv_operation_number
      iv_operation_number_from      = iv_operation_number_from
      iv_operation_number_to        = iv_operation_number_to
      iv_operation_counter          = iv_operation_counter
      iv_operation_counter_from     = iv_operation_counter_from
      iv_operation_counter_to       = iv_operation_counter_to
      iv_filter_operation_sequence  = iv_filter_operation_sequence
      iv_operation_sequence         = iv_operation_sequence
      iv_operation_sequence_from    = iv_operation_sequence_from
      iv_operation_sequence_to      = iv_operation_sequence_to
      iv_filter_suboperation_number = iv_filter_suboperation_number
      iv_suboperation_number        = iv_suboperation_number
      iv_suboperation_number_from   = iv_suboperation_number_from
      iv_suboperation_number_to     = iv_suboperation_number_to
      iv_order_category             = iv_order_category
      iv_order_type                 = iv_order_type
      is_page_selection             = ls_page_selection ).
    GET TIME STAMP FIELD lv_snapshot_timestamp.
    SORT lt_operations BY production_order operation_sequence
      operation_number suboperation_number operation_counter.
    validate_operation_results(
      it_production_orders          = it_production_orders
      it_operations                 = lt_operations
      iv_filter_resource_object_id  = iv_filter_resource_object_id
      iv_resource_object_id         = iv_resource_object_id
      iv_filter_work_center         = iv_filter_work_center
      iv_work_center                = iv_work_center
      iv_filter_work_center_plant   = iv_filter_work_center_plant
      iv_work_center_plant          = iv_work_center_plant
      iv_filter_control_key         = iv_filter_control_key
      iv_control_key                = iv_control_key
      iv_filter_op_description      = iv_filter_op_description
      iv_operation_description      = iv_operation_description
      iv_operation_number           = iv_operation_number
      iv_operation_number_from      = iv_operation_number_from
      iv_operation_number_to        = iv_operation_number_to
      iv_operation_counter          = iv_operation_counter
      iv_operation_counter_from     = iv_operation_counter_from
      iv_operation_counter_to       = iv_operation_counter_to
      iv_filter_operation_sequence  = iv_filter_operation_sequence
      iv_operation_sequence         = iv_operation_sequence
      iv_operation_sequence_from    = iv_operation_sequence_from
      iv_operation_sequence_to      = iv_operation_sequence_to
      iv_filter_suboperation_number = iv_filter_suboperation_number
      iv_suboperation_number        = iv_suboperation_number
      iv_suboperation_number_from   = iv_suboperation_number_from
      iv_suboperation_number_to     = iv_suboperation_number_to
      iv_order_category             = iv_order_category
      iv_order_type                 = iv_order_type ).

    LOOP AT lt_operations INTO DATA(ls_operation).
      lv_operation_is_after_cursor = abap_false.
      IF lv_has_cursor = abap_false
          OR ls_operation-production_order > iv_after_production_order
          OR ( ls_operation-production_order = iv_after_production_order
            AND ls_operation-operation_sequence >
              iv_after_operation_sequence )
          OR ( ls_operation-production_order = iv_after_production_order
            AND ls_operation-operation_sequence =
              iv_after_operation_sequence
            AND ls_operation-operation_number > iv_after_operation_number )
          OR ( ls_operation-production_order = iv_after_production_order
            AND ls_operation-operation_sequence =
              iv_after_operation_sequence
            AND ls_operation-operation_number = iv_after_operation_number
            AND ls_operation-suboperation_number >
              iv_after_suboperation_number )
          OR ( ls_operation-production_order = iv_after_production_order
            AND ls_operation-operation_sequence =
              iv_after_operation_sequence
            AND ls_operation-operation_number = iv_after_operation_number
            AND ls_operation-suboperation_number =
              iv_after_suboperation_number
            AND ls_operation-operation_counter >
              iv_after_operation_counter ).
        lv_operation_is_after_cursor = abap_true.
      ENDIF.

      IF lv_operation_is_after_cursor = abap_true.
        APPEND ls_operation TO lt_page_operations.
        IF lines( lt_page_operations ) > lv_maximum_results.
          lv_is_truncated = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_is_truncated = abap_true.
      DELETE lt_page_operations INDEX lv_maximum_results + 1.
      DATA(lv_last_operation_index) = lines( lt_page_operations ).
      READ TABLE lt_page_operations INDEX lv_last_operation_index
        INTO DATA(ls_last_operation).
      rs_result-next_production_order =
        ls_last_operation-production_order.
      rs_result-next_operation_sequence =
        ls_last_operation-operation_sequence.
      rs_result-next_operation_number = ls_last_operation-operation_number.
      rs_result-next_suboperation_number =
        ls_last_operation-suboperation_number.
      rs_result-next_operation_counter =
        ls_last_operation-operation_counter.
    ENDIF.
    rs_result-is_truncated = lv_is_truncated.

    DATA lt_work_center_orders TYPE ty_work_center_operation_order_keys.
    DATA lv_is_new_work_center_order TYPE abap_bool.
    LOOP AT lt_page_operations INTO DATA(ls_work_center_operation).
      lv_is_new_work_center_order = abap_false.
      INSERT VALUE #(
        work_center       = ls_work_center_operation-work_center
        work_center_plant = ls_work_center_operation-work_center_plant
        production_order  = ls_work_center_operation-production_order )
        INTO TABLE lt_work_center_orders.
      IF sy-subrc = 0.
        lv_is_new_work_center_order = abap_true.
      ENDIF.
      READ TABLE rs_result-work_center_summaries
        ASSIGNING FIELD-SYMBOL(<ls_work_center_summary>)
        WITH TABLE KEY
          work_center_plant = ls_work_center_operation-work_center_plant
          work_center = ls_work_center_operation-work_center.
      IF sy-subrc = 0.
        ADD 1 TO <ls_work_center_summary>-operation_count.
        IF lv_is_new_work_center_order = abap_true.
          ADD 1 TO <ls_work_center_summary>-order_count.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          work_center       = ls_work_center_operation-work_center
          work_center_plant = ls_work_center_operation-work_center_plant
          operation_count   = 1
          order_count       = 1 )
          INTO TABLE rs_result-work_center_summaries.
      ENDIF.
    ENDLOOP.

    DATA lt_order_category_orders TYPE
      ty_order_category_operation_order_keys.
    DATA lt_order_type_orders TYPE ty_order_type_operation_order_keys.
    DATA lt_control_key_orders TYPE ty_control_key_operation_order_keys.
    DATA lv_is_new_summary_order TYPE abap_bool.
    LOOP AT lt_page_operations INTO DATA(ls_order_category_operation).
      lv_is_new_summary_order = abap_false.
      INSERT VALUE #(
        order_category   = ls_order_category_operation-order_category
        production_order = ls_order_category_operation-production_order )
        INTO TABLE lt_order_category_orders.
      IF sy-subrc = 0.
        lv_is_new_summary_order = abap_true.
      ENDIF.
      READ TABLE rs_result-order_category_summaries
        ASSIGNING FIELD-SYMBOL(<ls_order_category_summary>)
        WITH TABLE KEY
          order_category = ls_order_category_operation-order_category.
      IF sy-subrc = 0.
        ADD 1 TO <ls_order_category_summary>-operation_count.
        IF lv_is_new_summary_order = abap_true.
          ADD 1 TO <ls_order_category_summary>-order_count.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          order_category  = ls_order_category_operation-order_category
          operation_count = 1
          order_count     = 1 )
          INTO TABLE rs_result-order_category_summaries.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_page_operations INTO DATA(ls_order_type_operation).
      lv_is_new_summary_order = abap_false.
      INSERT VALUE #(
        order_type       = ls_order_type_operation-order_type
        production_order = ls_order_type_operation-production_order )
        INTO TABLE lt_order_type_orders.
      IF sy-subrc = 0.
        lv_is_new_summary_order = abap_true.
      ENDIF.
      READ TABLE rs_result-order_type_summaries
        ASSIGNING FIELD-SYMBOL(<ls_order_type_summary>)
        WITH TABLE KEY
          order_type = ls_order_type_operation-order_type.
      IF sy-subrc = 0.
        ADD 1 TO <ls_order_type_summary>-operation_count.
        IF lv_is_new_summary_order = abap_true.
          ADD 1 TO <ls_order_type_summary>-order_count.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          order_type      = ls_order_type_operation-order_type
          operation_count = 1
          order_count     = 1 )
          INTO TABLE rs_result-order_type_summaries.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_page_operations INTO DATA(ls_control_key_operation).
      lv_is_new_summary_order = abap_false.
      INSERT VALUE #(
        control_key      = ls_control_key_operation-control_key
        production_order = ls_control_key_operation-production_order )
        INTO TABLE lt_control_key_orders.
      IF sy-subrc = 0.
        lv_is_new_summary_order = abap_true.
      ENDIF.
      READ TABLE rs_result-control_key_summaries
        ASSIGNING FIELD-SYMBOL(<ls_control_key_summary>)
        WITH TABLE KEY
          control_key = ls_control_key_operation-control_key.
      IF sy-subrc = 0.
        ADD 1 TO <ls_control_key_summary>-operation_count.
        IF lv_is_new_summary_order = abap_true.
          ADD 1 TO <ls_control_key_summary>-order_count.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          control_key     = ls_control_key_operation-control_key
          operation_count = 1
          order_count     = 1 )
          INTO TABLE rs_result-control_key_summaries.
      ENDIF.
    ENDLOOP.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index    = lv_request_index
        production_order = lv_production_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_operation_order>).

      LOOP AT lt_page_operations INTO DATA(ls_page_operation)
          WHERE production_order = lv_production_order.
        APPEND ls_page_operation TO <ls_operation_order>-operations.
        ADD 1 TO <ls_operation_order>-operation_count.
        ADD 1 TO rs_result-total_operation_count.
      ENDLOOP.

      IF <ls_operation_order>-operations IS INITIAL.
        ADD 1 TO rs_result-empty_count.
      ELSE.
        <ls_operation_order>-is_found = abap_true.
        ADD 1 TO rs_result-found_count.
      ENDIF.
    ENDLOOP.
    IF rs_result-total_operation_count > 0.
      LOOP AT rs_result-work_center_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_work_center_summary>).
        <ls_page_work_center_summary>-operation_pct =
          CONV decfloat34(
            <ls_page_work_center_summary>-operation_count ) * 100
          / rs_result-total_operation_count.
      ENDLOOP.
      LOOP AT rs_result-order_category_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_category_summary>).
        <ls_page_category_summary>-operation_pct =
          CONV decfloat34(
            <ls_page_category_summary>-operation_count ) * 100
          / rs_result-total_operation_count.
      ENDLOOP.
      LOOP AT rs_result-order_type_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_type_summary>).
        <ls_page_type_summary>-operation_pct =
          CONV decfloat34(
            <ls_page_type_summary>-operation_count ) * 100
          / rs_result-total_operation_count.
      ENDLOOP.
      LOOP AT rs_result-control_key_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_control_summary>).
        <ls_page_control_summary>-operation_pct =
          CONV decfloat34(
            <ls_page_control_summary>-operation_count ) * 100
          / rs_result-total_operation_count.
      ENDLOOP.
    ENDIF.
    IF rs_result-found_count > 0.
      LOOP AT rs_result-work_center_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_wc_order_pct>).
        <ls_page_wc_order_pct>-order_pct =
          CONV decfloat34(
            <ls_page_wc_order_pct>-order_count ) * 100
          / rs_result-found_count.
      ENDLOOP.
      LOOP AT rs_result-order_category_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_cat_order_pct>).
        <ls_page_cat_order_pct>-order_pct =
          CONV decfloat34(
            <ls_page_cat_order_pct>-order_count ) * 100
          / rs_result-found_count.
      ENDLOOP.
      LOOP AT rs_result-order_type_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_type_order_pct>).
        <ls_page_type_order_pct>-order_pct =
          CONV decfloat34(
            <ls_page_type_order_pct>-order_count ) * 100
          / rs_result-found_count.
      ENDLOOP.
      LOOP AT rs_result-control_key_summaries
          ASSIGNING FIELD-SYMBOL(<ls_page_ctrl_order_pct>).
        <ls_page_ctrl_order_pct>-order_pct =
          CONV decfloat34(
            <ls_page_ctrl_order_pct>-order_count ) * 100
          / rs_result-found_count.
      ENDLOOP.
    ENDIF.
    rs_result-snapshot_timestamp = lv_snapshot_timestamp.
  ENDMETHOD.

ENDCLASS.
