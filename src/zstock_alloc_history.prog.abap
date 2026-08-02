REPORT zstock_alloc_history.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_rid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_legacy AS CHECKBOX.
PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_ffrom TYPE d.
PARAMETERS p_fto TYPE d.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_dfrom TYPE i.
PARAMETERS p_dto TYPE i.
PARAMETERS p_tfrom TYPE i.
PARAMETERS p_tto TYPE i.
PARAMETERS p_stale TYPE i.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_cov AS CHECKBOX.
PARAMETERS p_spct AS CHECKBOX.
PARAMETERS p_sstat AS CHECKBOX.
PARAMETERS p_tdur AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_latest AS CHECKBOX.
PARAMETERS p_max TYPE i.
PARAMETERS p_skip TYPE i.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.
PARAMETERS p_ndjson AS CHECKBOX.

START-OF-SELECTION.
  TRANSLATE p_strat TO UPPER CASE.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  DATA lt_context_runs TYPE zif_allocation_audit=>tt_runs.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.
  DATA lv_running_runs TYPE i.
  DATA lv_success_runs TYPE i.
  DATA lv_partial_runs TYPE i.
  DATA lv_error_runs TYPE i.
  DATA lv_completed_runs TYPE i.
  DATA lv_successful_runs TYPE i.
  DATA lv_partial_completed TYPE i.
  DATA lv_error_completed TYPE i.
  DATA lv_completion_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_success_rate_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_partial_rate_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_error_rate_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_priority_runs TYPE i.
  DATA lv_fifo_runs TYPE i.
  DATA lv_full_only_runs TYPE i.
  DATA lv_smallest_runs TYPE i.
  DATA lv_largest_runs TYPE i.
  DATA lv_best_runs TYPE i.
  DATA lv_legacy_strategy_runs TYPE i.
  DATA lv_full_count TYPE i.
  DATA lv_partial_count TYPE i.
  DATA lv_unallocated_count TYPE i.
  DATA lv_available_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_allocated_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_shortage_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_priority_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_priority_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_priority_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_fifo_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_fifo_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_fifo_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_full_only_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_full_only_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_full_only_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_smallest_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_smallest_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_smallest_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_largest_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_largest_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_largest_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_best_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_best_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_best_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_legacy_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_legacy_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_legacy_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_priority_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_fifo_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_full_only_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_smallest_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_largest_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_best_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_legacy_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_coverage TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_shortage_pct_text TYPE string.
  DATA lv_run_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_run_coverage_text TYPE c LENGTH 8.
  DATA lv_run_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_run_shortage_pct_text TYPE c LENGTH 8.
  DATA lv_duration_seconds TYPE i.
  DATA lv_duration_text TYPE string.
  DATA lv_running_age_seconds TYPE i.
  DATA lv_running_age_text TYPE string.
  DATA ls_running_age TYPE zif_allocation_audit=>ty_running_age.
  DATA lv_duration_total TYPE p LENGTH 12 DECIMALS 2.
  DATA lv_duration_count TYPE i.
  DATA lv_running_age_count TYPE i.
  DATA lv_oldest_running_age TYPE i.
  DATA lv_oldest_running_age_text TYPE string.
  DATA lv_oldest_running_run_id TYPE zif_allocation_audit=>ty_run_id.
  DATA lv_oldest_running_run_id_text TYPE string.
  DATA lv_newest_running_age TYPE i.
  DATA lv_newest_running_age_text TYPE string.
  DATA lv_newest_running_run_id TYPE zif_allocation_audit=>ty_run_id.
  DATA lv_newest_running_run_id_text TYPE string.
  DATA lv_average_duration TYPE zif_allocation_audit=>ty_duration.
  DATA lv_average_duration_text TYPE string.
  DATA lv_minimum_duration TYPE i.
  DATA lv_maximum_duration TYPE i.
  DATA lv_minimum_duration_text TYPE string.
  DATA lv_maximum_duration_text TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_json_line TYPE string.
  DATA lv_summary_json TYPE string.
  DATA lv_numeric_json TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_csv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_summary_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_summary_strategy TYPE string.
  DATA lv_display_strategy TYPE string.
  DATA lv_mixed_units TYPE abap_bool.
  DATA lt_filter_names TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_filter_names_text TYPE string.
  DATA lv_has_more TYPE abap_bool.
  DATA lv_query_max TYPE i.
  DATA lv_page_end TYPE i.
  DATA lv_next_offset TYPE i.
  DATA lv_sort_mode TYPE string.
  DATA lv_filters_applied TYPE abap_bool.
  DATA lv_page_number TYPE i.
  DATA lv_page_count TYPE i.
  DATA lv_last_offset TYPE i.
  DATA lv_has_previous TYPE abap_bool.
  DATA lv_previous_offset TYPE i.
  DATA lv_row_index TYPE i.
  DATA lv_total_rows TYPE i.
  FIELD-SYMBOLS <lv_csv_field> TYPE string.

  IF p_csv = abap_true AND p_json = abap_true.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Select only one export mode: CSV or JSON' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Select only one export mode: CSV or JSON.'.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    IF p_ndjson = abap_true AND p_json = abap_false.
      lv_csv_error_message = 'NDJSON output requires JSON mode.'.
    ELSEIF p_meta = abap_true AND p_json = abap_false.
      lv_csv_error_message = 'Metadata output requires JSON mode.'.
    ELSEIF p_typed = abap_true AND p_json = abap_false.
      lv_csv_error_message = 'Typed output requires JSON mode.'.
    ELSEIF p_typed = abap_true AND p_meta = abap_true.
      lv_csv_error_message =
        'Select either typed rows or metadata output, not both.'.
    ELSEIF p_skip < 0.
      lv_csv_error_message = 'Row offset must not be negative'.
    ELSEIF p_latest = abap_true AND p_skip > 0.
      lv_csv_error_message =
        'Latest-run mode cannot be combined with a row offset'.
    ELSEIF p_max < 0.
      lv_csv_error_message = 'Row limit must not be negative'.
    ELSEIF p_stale < 0.
      lv_csv_error_message = 'Stale-running threshold must not be negative'.
    ELSEIF p_stat IS NOT INITIAL
        AND p_stat <> 'R'
        AND p_stat <> 'S'
        AND p_stat <> 'P'
        AND p_stat <> 'E'.
      lv_csv_error_message = 'Status must be R, S, P, or E'.
    ELSEIF p_strat IS NOT INITIAL
        AND p_strat <> 'P'
        AND p_strat <> 'F'
        AND p_strat <> 'N'
        AND p_strat <> 'S'
        AND p_strat <> 'L'
        AND p_strat <> 'B'.
      lv_csv_error_message = 'Strategy must be P, F, N, S, L, or B'.
    ELSEIF p_legacy = abap_true AND p_strat IS NOT INITIAL.
      lv_csv_error_message = 'Strategy filters cannot be combined'.
    ELSEIF p_from IS NOT INITIAL AND p_to IS NOT INITIAL AND p_from > p_to.
      lv_csv_error_message =
        'The start date must not be after the end date'.
    ELSEIF p_ffrom IS NOT INITIAL AND p_fto IS NOT INITIAL
        AND p_ffrom > p_fto.
      lv_csv_error_message =
        'The finish date must not be after the end date'.
    ELSEIF ( p_shf IS NOT INITIAL AND p_shf < 0 )
        OR ( p_sht IS NOT INITIAL AND p_sht < 0 ).
      lv_csv_error_message = 'Shortage quantity bounds must not be negative'.
    ELSEIF p_shf IS NOT INITIAL AND p_sht IS NOT INITIAL AND p_shf > p_sht.
      lv_csv_error_message =
        'Shortage quantity start must not be after the end value'.
    ELSEIF ( p_af IS NOT INITIAL AND p_af < 0 )
        OR ( p_at IS NOT INITIAL AND p_at < 0 ).
      lv_csv_error_message = 'Allocated quantity bounds must not be negative'.
    ELSEIF p_af IS NOT INITIAL AND p_at IS NOT INITIAL AND p_af > p_at.
      lv_csv_error_message =
        'Allocated quantity start must not be after the end value'.
    ELSEIF ( p_avf IS NOT INITIAL AND p_avf < 0 )
        OR ( p_avt IS NOT INITIAL AND p_avt < 0 ).
      lv_csv_error_message = 'Available quantity bounds must not be negative'.
    ELSEIF p_avf IS NOT INITIAL AND p_avt IS NOT INITIAL AND p_avf > p_avt.
      lv_csv_error_message =
        'Available quantity start must not be after the end value'.
    ELSEIF ( p_qf IS NOT INITIAL AND p_qf < 0 )
        OR ( p_qt IS NOT INITIAL AND p_qt < 0 ).
      lv_csv_error_message = 'Requested quantity bounds must not be negative'.
    ELSEIF p_qf IS NOT INITIAL AND p_qt IS NOT INITIAL AND p_qf > p_qt.
      lv_csv_error_message =
        'Requested quantity start must not be after the end value'.
    ELSEIF ( p_dfrom IS NOT INITIAL AND p_dfrom < 0 )
        OR ( p_dto IS NOT INITIAL AND p_dto < 0 ).
      lv_csv_error_message = 'Demand-count bounds must not be negative'.
    ELSEIF p_dfrom IS NOT INITIAL AND p_dto IS NOT INITIAL
        AND p_dfrom > p_dto.
      lv_csv_error_message =
        'Demand-count start must not be after the end value'.
    ELSEIF ( p_tfrom IS NOT INITIAL AND p_tfrom < 0 )
        OR ( p_tto IS NOT INITIAL AND p_tto < 0 ).
      lv_csv_error_message = 'Duration bounds must not be negative'.
    ELSEIF p_tfrom IS NOT INITIAL AND p_tto IS NOT INITIAL
        AND p_tfrom > p_tto.
      lv_csv_error_message =
        'Duration start must not be after the end value'.
    ELSEIF ( p_covf IS NOT INITIAL AND ( p_covf < 0 OR p_covf > 100 ) )
        OR ( p_covt IS NOT INITIAL AND ( p_covt < 0 OR p_covt > 100 ) ).
      lv_csv_error_message = 'Coverage bounds must be between 0 and 100'.
    ELSEIF p_covf IS NOT INITIAL AND p_covt IS NOT INITIAL
        AND p_covf > p_covt.
      lv_csv_error_message =
        'Coverage start must not be after the end value'.
    ELSEIF ( p_spf IS NOT INITIAL AND ( p_spf < 0 OR p_spf > 100 ) )
        OR ( p_spt IS NOT INITIAL AND ( p_spt < 0 OR p_spt > 100 ) ).
      lv_csv_error_message =
        'Shortage percentage bounds must be between 0 and 100'.
    ELSEIF p_spf IS NOT INITIAL AND p_spt IS NOT INITIAL
        AND p_spf > p_spt.
      lv_csv_error_message =
        'Shortage percentage start must not be after the end value'.
    ELSEIF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL
        AND p_reqf > p_until.
      lv_csv_error_message =
        'The requested horizon start must not be after the end date'.
    ENDIF.
    IF lv_csv_error_message IS NOT INITIAL.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_history'
        iv_message = lv_csv_error_message ).
      RETURN.
    ENDIF.
  ENDIF.

  IF p_meta = abap_true AND p_json = abap_false.
    WRITE: / 'Metadata output requires JSON mode.'.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    WRITE: / 'Typed output requires JSON mode.'.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_json = abap_false.
    WRITE: / 'NDJSON output requires JSON mode.'.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_meta = abap_true.
    WRITE: / 'Select either typed rows or metadata output, not both.'.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_meta = abap_true.
    WRITE: / 'NDJSON output cannot be combined with metadata output.'.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_sum = abap_true.
    WRITE: / 'NDJSON output cannot be combined with summary mode.'.
    RETURN.
  ENDIF.

  IF p_skip < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Row offset must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Row offset must not be negative.'.
    RETURN.
  ENDIF.
  IF p_latest = abap_true AND p_skip > 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Latest-run mode cannot be combined with a row offset' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Latest-run mode cannot be combined with a row offset.'.
    RETURN.
  ENDIF.
  IF p_max < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Row limit must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Row limit must not be negative.'.
    RETURN.
  ENDIF.
  IF p_stale < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Stale-running threshold must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Stale-running threshold must not be negative.'.
    RETURN.
  ENDIF.

  IF p_stat IS NOT INITIAL
      AND p_stat <> 'R'
      AND p_stat <> 'S'
      AND p_stat <> 'P'
      AND p_stat <> 'E'.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Status must be R, S, P, or E' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Status must be R, S, P, or E.'.
    RETURN.
  ENDIF.
  IF p_strat IS NOT INITIAL
      AND p_strat <> 'P'
      AND p_strat <> 'F'
      AND p_strat <> 'N'
      AND p_strat <> 'S'
      AND p_strat <> 'L'
      AND p_strat <> 'B'.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Strategy must be P, F, N, S, L, or B' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Strategy must be P, F, N, S, L, or B.'.
    RETURN.
  ENDIF.
  IF p_legacy = abap_true AND p_strat IS NOT INITIAL.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Strategy filters cannot be combined' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Strategy filters cannot be combined.'.
    RETURN.
  ENDIF.
  IF p_from IS NOT INITIAL AND p_to IS NOT INITIAL AND p_from > p_to.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The start date must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'The start date must not be after the end date.'.
    RETURN.
  ENDIF.
  IF p_ffrom IS NOT INITIAL AND p_fto IS NOT INITIAL AND p_ffrom > p_fto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The finish date must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'The finish date must not be after the end date.'.
    RETURN.
  ENDIF.
  IF ( p_shf IS NOT INITIAL AND p_shf < 0 )
      OR ( p_sht IS NOT INITIAL AND p_sht < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Shortage quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Shortage quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_shf IS NOT INITIAL AND p_sht IS NOT INITIAL AND p_shf > p_sht.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Shortage quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Shortage quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_af IS NOT INITIAL AND p_af < 0 )
      OR ( p_at IS NOT INITIAL AND p_at < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Allocated quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Allocated quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_af IS NOT INITIAL AND p_at IS NOT INITIAL AND p_af > p_at.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Allocated quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Allocated quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_avf IS NOT INITIAL AND p_avf < 0 )
      OR ( p_avt IS NOT INITIAL AND p_avt < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Available quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Available quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_avf IS NOT INITIAL AND p_avt IS NOT INITIAL AND p_avf > p_avt.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Available quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Available quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_qf IS NOT INITIAL AND p_qf < 0 )
      OR ( p_qt IS NOT INITIAL AND p_qt < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Requested quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Requested quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_qf IS NOT INITIAL AND p_qt IS NOT INITIAL AND p_qf > p_qt.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Requested quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Requested quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_dfrom IS NOT INITIAL AND p_dfrom < 0 )
      OR ( p_dto IS NOT INITIAL AND p_dto < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Demand-count bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Demand-count bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_dfrom IS NOT INITIAL AND p_dto IS NOT INITIAL AND p_dfrom > p_dto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Demand-count start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Demand-count start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_tfrom IS NOT INITIAL AND p_tfrom < 0 )
      OR ( p_tto IS NOT INITIAL AND p_tto < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Duration bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Duration bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_tfrom IS NOT INITIAL AND p_tto IS NOT INITIAL AND p_tfrom > p_tto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Duration start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Duration start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_covf IS NOT INITIAL AND ( p_covf < 0 OR p_covf > 100 ) )
      OR ( p_covt IS NOT INITIAL AND ( p_covt < 0 OR p_covt > 100 ) ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Coverage bounds must be between 0 and 100' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Coverage bounds must be between 0 and 100.'.
    RETURN.
  ENDIF.
  IF p_covf IS NOT INITIAL AND p_covt IS NOT INITIAL AND p_covf > p_covt.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Coverage start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Coverage start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_spf IS NOT INITIAL AND ( p_spf < 0 OR p_spf > 100 ) )
      OR ( p_spt IS NOT INITIAL AND ( p_spt < 0 OR p_spt > 100 ) ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Shortage percentage bounds must be between 0 and 100' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Shortage percentage bounds must be between 0 and 100.'.
    RETURN.
  ENDIF.
  IF p_spf IS NOT INITIAL AND p_spt IS NOT INITIAL AND p_spf > p_spt.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Shortage percentage start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Shortage percentage start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL AND p_reqf > p_until.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The requested horizon start must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'The requested horizon start must not be after the end date.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_allocation_read_auth_sap.
  TRY.
      lo_authority->check_audit( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
      IF p_json = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Audit read authorization is missing' ).
        ELSE.
          lv_error_message = lo_auth_error->message.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_history'
            iv_message = 'Audit read authorization is missing' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_history'
            iv_message = lo_auth_error->message ).
        ENDIF.
        WRITE: / 'mode;status;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_auth_error->message IS INITIAL.
        WRITE: / 'History is unavailable; read authorization is missing.'.
      ELSE.
        WRITE: / 'History is unavailable:', lo_auth_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_read_authority = lo_authority.
  lv_query_max = p_max.
  IF p_latest = abap_true.
    lv_query_max = 1.
  ELSEIF p_max > 0.
    lv_query_max = p_max + 1.
  ENDIF.
  TRY.
      lt_runs = lo_audit->get_runs(
        EXPORTING
        iv_material          = p_matnr
        iv_plant             = p_werks
        iv_storage_location  = p_lgort
        iv_batch             = p_charg
        iv_requested_on_from = p_reqf
        iv_requested_on_to   = p_until
        iv_run_id            = p_runid
        iv_run_id_contains   = p_rid
        iv_unit              = p_meins
        iv_start_date_from   = p_from
        iv_start_date_to     = p_to
        iv_finish_date_from  = p_ffrom
        iv_finish_date_to    = p_fto
        iv_shortage_from     = p_shf
        iv_shortage_to       = p_sht
        iv_allocated_from    = p_af
        iv_allocated_to      = p_at
        iv_available_from    = p_avf
        iv_available_to      = p_avt
        iv_requested_from    = p_qf
        iv_requested_to      = p_qt
        iv_demand_from       = p_dfrom
        iv_demand_to         = p_dto
        iv_duration_from     = p_tfrom
        iv_duration_to       = p_tto
        iv_stale_seconds     = p_stale
        iv_sort_by_shortage  = p_shrt
        iv_coverage_from     = p_covf
        iv_coverage_to       = p_covt
        iv_shortage_pct_from = p_spf
        iv_shortage_pct_to   = p_spt
        iv_sort_by_coverage  = p_cov
        iv_sort_by_shrt_pct  = p_spct
        iv_sort_by_status    = p_sstat
        iv_sort_by_duration  = p_tdur
        iv_max_rows          = lv_query_max
        iv_status            = p_stat
        iv_strategy          = p_strat
        iv_legacy_strategy   = p_legacy
        iv_message_contains  = p_msg
        iv_message_only      = p_monly
        iv_offset            = p_skip
        IMPORTING
          ev_total_rows      = lv_total_rows ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'History is unavailable for the requested scope' ).
        ELSE.
          lv_error_message = lo_error->message.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_history'
            iv_message = 'History is unavailable for the requested scope' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_history'
            iv_message = lo_error->message ).
        ENDIF.
        WRITE: / 'mode;status;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_error->message IS INITIAL.
        WRITE: / 'History is unavailable for the requested scope.'.
      ELSE.
        WRITE: / 'History is unavailable:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  lv_has_more = abap_false.
  IF p_max > 0 AND lines( lt_runs ) > p_max.
    lv_has_more = abap_true.
    lv_page_end = p_max + 1.
    DELETE lt_runs INDEX lv_page_end.
  ENDIF.
  lv_next_offset = p_skip + lines( lt_runs ).
  CLEAR lv_page_number.
  CLEAR lv_page_count.
  CLEAR lv_last_offset.
  IF p_max > 0.
    lv_page_number = p_skip / p_max + 1.
    IF lv_total_rows > 0.
      lv_page_count = ( lv_total_rows + p_max - 1 ) / p_max.
      lv_last_offset = ( ( lv_total_rows - 1 ) / p_max ) * p_max.
    ENDIF.
  ENDIF.
  lv_has_previous = abap_false.
  CLEAR lv_previous_offset.
  IF p_skip > 0.
    lv_has_previous = abap_true.
    IF p_max > 0 AND p_skip >= p_max.
      lv_previous_offset = p_skip - p_max.
    ENDIF.
  ENDIF.
  lv_sort_mode = 'default'.
  IF p_cov = abap_true.
    lv_sort_mode = 'coverage'.
  ELSEIF p_spct = abap_true.
    lv_sort_mode = 'shortage_percentage'.
  ELSEIF p_sstat = abap_true.
    lv_sort_mode = 'status'.
  ELSEIF p_tdur = abap_true.
    lv_sort_mode = 'duration'.
  ELSEIF p_shrt = abap_true.
    lv_sort_mode = 'shortage'.
  ENDIF.
  lv_filters_applied = abap_false.
  IF p_charg IS NOT INITIAL
      OR p_reqf IS NOT INITIAL
      OR p_until IS NOT INITIAL
      OR p_runid IS NOT INITIAL
      OR p_rid IS NOT INITIAL
      OR p_meins IS NOT INITIAL
      OR p_stat IS NOT INITIAL
      OR p_strat IS NOT INITIAL
      OR p_legacy = abap_true
      OR p_from IS NOT INITIAL
      OR p_to IS NOT INITIAL
      OR p_ffrom IS NOT INITIAL
      OR p_fto IS NOT INITIAL
      OR p_shf IS NOT INITIAL
      OR p_sht IS NOT INITIAL
      OR p_af IS NOT INITIAL
      OR p_at IS NOT INITIAL
      OR p_avf IS NOT INITIAL
      OR p_avt IS NOT INITIAL
      OR p_qf IS NOT INITIAL
      OR p_qt IS NOT INITIAL
      OR p_dfrom IS NOT INITIAL
      OR p_dto IS NOT INITIAL
      OR p_tfrom IS NOT INITIAL
      OR p_tto IS NOT INITIAL
      OR p_stale IS NOT INITIAL
      OR p_covf IS NOT INITIAL
      OR p_covt IS NOT INITIAL
      OR p_spf IS NOT INITIAL
      OR p_spt IS NOT INITIAL
      OR p_msg IS NOT INITIAL
      OR p_monly = abap_true
      OR p_latest = abap_true.
      lv_filters_applied = abap_true.
  ENDIF.
  CLEAR lt_filter_names.
  IF p_charg IS NOT INITIAL.
    APPEND 'batch' TO lt_filter_names.
  ENDIF.
  IF p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL.
    APPEND 'requested_date' TO lt_filter_names.
  ENDIF.
  IF p_runid IS NOT INITIAL.
    APPEND 'run_id' TO lt_filter_names.
  ENDIF.
  IF p_rid IS NOT INITIAL.
    APPEND 'run_id_contains' TO lt_filter_names.
  ENDIF.
  IF p_meins IS NOT INITIAL.
    APPEND 'unit' TO lt_filter_names.
  ENDIF.
  IF p_stat IS NOT INITIAL.
    APPEND 'status' TO lt_filter_names.
  ENDIF.
  IF p_strat IS NOT INITIAL.
    APPEND 'strategy' TO lt_filter_names.
  ENDIF.
  IF p_legacy = abap_true.
    APPEND 'legacy_strategy' TO lt_filter_names.
  ENDIF.
  IF p_from IS NOT INITIAL OR p_to IS NOT INITIAL.
    APPEND 'start_date' TO lt_filter_names.
  ENDIF.
  IF p_ffrom IS NOT INITIAL OR p_fto IS NOT INITIAL.
    APPEND 'finish_date' TO lt_filter_names.
  ENDIF.
  IF p_shf IS NOT INITIAL OR p_sht IS NOT INITIAL.
    APPEND 'shortage' TO lt_filter_names.
  ENDIF.
  IF p_af IS NOT INITIAL OR p_at IS NOT INITIAL.
    APPEND 'allocated_quantity' TO lt_filter_names.
  ENDIF.
  IF p_avf IS NOT INITIAL OR p_avt IS NOT INITIAL.
    APPEND 'available_stock' TO lt_filter_names.
  ENDIF.
  IF p_qf IS NOT INITIAL OR p_qt IS NOT INITIAL.
    APPEND 'requested_quantity' TO lt_filter_names.
  ENDIF.
  IF p_dfrom IS NOT INITIAL OR p_dto IS NOT INITIAL.
    APPEND 'demand_count' TO lt_filter_names.
  ENDIF.
  IF p_tfrom IS NOT INITIAL OR p_tto IS NOT INITIAL.
    APPEND 'duration' TO lt_filter_names.
  ENDIF.
  IF p_stale IS NOT INITIAL.
    APPEND 'stale_running' TO lt_filter_names.
  ENDIF.
  IF p_covf IS NOT INITIAL OR p_covt IS NOT INITIAL.
    APPEND 'coverage' TO lt_filter_names.
  ENDIF.
  IF p_spf IS NOT INITIAL OR p_spt IS NOT INITIAL.
    APPEND 'shortage_percentage' TO lt_filter_names.
  ENDIF.
  IF p_msg IS NOT INITIAL.
    APPEND 'message' TO lt_filter_names.
  ENDIF.
  IF p_monly = abap_true.
    APPEND 'message_only' TO lt_filter_names.
  ENDIF.
  IF p_latest = abap_true.
    APPEND 'latest' TO lt_filter_names.
  ENDIF.
  CONCATENATE LINES OF lt_filter_names INTO lv_filter_names_text
    SEPARATED BY '|'.

  IF lines( lt_runs ) = 0 AND p_sum = abap_false
      AND p_meta = abap_false
      AND p_ndjson = abap_false.
    IF p_json = abap_true.
      WRITE: / '[]'.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      IF p_sum = abap_true.
        WRITE: / 'mode;generated_date;generated_time;schema_version;sort;filters_applied;filters;offset;max_rows;'
          && 'page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;total_rows;material;'
          && 'plant;storage_location;batch;unit;strategy;mixed_units;run_count;priority_run_count;fifo_run_count;'
          && 'full_only_run_count;smallest_run_count;largest_run_count;best_run_count;legacy_strategy_run_count;'
          && 'priority_requested;priority_allocated;priority_shortage;priority_coverage_pct;fifo_requested;'
          && 'fifo_allocated;fifo_shortage;fifo_coverage_pct;full_only_requested;full_only_allocated;'
          && 'full_only_shortage;full_only_coverage_pct;smallest_requested;smallest_allocated;smallest_shortage;'
          && 'smallest_coverage_pct;largest_requested;largest_allocated;largest_shortage;largest_coverage_pct;'
          && 'best_requested;best_allocated;best_shortage;best_coverage_pct;legacy_requested;legacy_allocated;'
          && 'legacy_shortage;legacy_coverage_pct;running_count;success_count;partial_run_count;error_count;'
          && 'completion_pct;success_rate_pct;partial_rate_pct;error_rate_pct;full_count;partial_count;'
          && 'unallocated_count;available;requested;allocated;shortage;coverage_pct;shortage_pct;'
          && 'average_duration_seconds;minimum_duration_seconds;maximum_duration_seconds;completed_duration_runs;'
          && 'oldest_running_age_seconds;oldest_running_run_id;newest_running_age_seconds;newest_running_run_id'.
      ELSE.
        WRITE: / 'run_id;generated_date;generated_time;schema_version;sort;filters_applied;filters;offset;max_rows;'
          && 'page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;total_rows;material;'
          && 'plant;storage_location;batch;unit;strategy;requested_on_from;requested_on_to;available;allocated;'
          && 'shortage;coverage_pct;shortage_pct;status;message;demand_count;full_count;partial_count;'
          && 'unallocated_count;start_date;start_time;finish_date;finish_time;duration_seconds;running_age_seconds'.
      ENDIF.
      RETURN.
    ENDIF.
    WRITE: / 'No allocation runs found.'.
    RETURN.
  ENDIF.

  CLEAR: lv_duration_total,
         lv_duration_count,
         lv_average_duration,
         lv_average_duration_text,
         lv_minimum_duration,
         lv_maximum_duration,
         lv_minimum_duration_text,
         lv_maximum_duration_text,
         lv_running_age_count,
         lv_oldest_running_age,
         lv_oldest_running_age_text,
         lv_oldest_running_run_id,
         lv_oldest_running_run_id_text,
         lv_newest_running_age,
         lv_newest_running_age_text,
         lv_newest_running_run_id,
         lv_newest_running_run_id_text.
  LOOP AT lt_runs ASSIGNING <ls_run>.
    IF <ls_run>-status = 'R'.
      ls_running_age = lo_audit->get_running_age( <ls_run> ).
      IF ls_running_age-available = abap_true.
        lv_running_age_seconds = ls_running_age-seconds.
        lv_running_age_count = lv_running_age_count + 1.
        IF lv_running_age_count = 1
            OR lv_running_age_seconds > lv_oldest_running_age.
          lv_oldest_running_age = lv_running_age_seconds.
          lv_oldest_running_run_id = <ls_run>-run_id.
        ENDIF.
        IF lv_running_age_count = 1
            OR lv_running_age_seconds < lv_newest_running_age.
          lv_newest_running_age = lv_running_age_seconds.
          lv_newest_running_run_id = <ls_run>-run_id.
        ENDIF.
      ENDIF.
    ENDIF.
    IF <ls_run>-finish_date IS NOT INITIAL.
      CLEAR lv_duration_seconds.
      cl_abap_tstmp=>td_subtract(
        EXPORTING
          date1    = <ls_run>-finish_date
          time1    = <ls_run>-finish_time
          date2    = <ls_run>-start_date
          time2    = <ls_run>-start_time
        IMPORTING
          res_secs = lv_duration_seconds ).
      lv_duration_total = lv_duration_total + lv_duration_seconds.
      IF lv_duration_count = 0
          OR lv_duration_seconds < lv_minimum_duration.
        lv_minimum_duration = lv_duration_seconds.
      ENDIF.
      IF lv_duration_count = 0
          OR lv_duration_seconds > lv_maximum_duration.
        lv_maximum_duration = lv_duration_seconds.
      ENDIF.
      lv_duration_count = lv_duration_count + 1.
    ENDIF.
  ENDLOOP.
  CLEAR: lv_completed_runs,
         lv_successful_runs,
         lv_partial_completed,
         lv_error_completed,
         lv_completion_pct,
         lv_success_rate_pct,
         lv_partial_rate_pct,
         lv_error_rate_pct.
  LOOP AT lt_runs ASSIGNING <ls_run>.
    IF <ls_run>-status = 'S'
        OR <ls_run>-status = 'P'
        OR <ls_run>-status = 'E'.
      lv_completed_runs = lv_completed_runs + 1.
      IF <ls_run>-status = 'S'.
        lv_successful_runs = lv_successful_runs + 1.
      ELSEIF <ls_run>-status = 'P'.
        lv_partial_completed = lv_partial_completed + 1.
      ELSEIF <ls_run>-status = 'E'.
        lv_error_completed = lv_error_completed + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF lines( lt_runs ) > 0.
    lv_completion_pct = lv_completed_runs * 100 / lines( lt_runs ).
  ENDIF.
  IF lv_completed_runs > 0.
    lv_success_rate_pct = lv_successful_runs * 100 / lv_completed_runs.
    lv_partial_rate_pct = lv_partial_completed * 100 / lv_completed_runs.
    lv_error_rate_pct = lv_error_completed * 100 / lv_completed_runs.
  ENDIF.
  IF lv_duration_count > 0.
    lv_average_duration = lv_duration_total / lv_duration_count.
    lv_average_duration_text = zcl_stock_csv=>number(
      lv_average_duration ).
    lv_minimum_duration_text = zcl_stock_csv=>number(
      lv_minimum_duration ).
    lv_maximum_duration_text = zcl_stock_csv=>number(
      lv_maximum_duration ).
  ELSE.
    lv_average_duration_text = 'n/a'.
    lv_minimum_duration_text = 'n/a'.
    lv_maximum_duration_text = 'n/a'.
  ENDIF.
  IF lv_running_age_count > 0.
    lv_oldest_running_age_text = zcl_stock_csv=>number(
      lv_oldest_running_age ).
  ELSE.
    lv_oldest_running_age_text = 'n/a'.
  ENDIF.
  IF lv_running_age_count > 0.
    lv_oldest_running_run_id_text = lv_oldest_running_run_id.
    lv_newest_running_age_text = zcl_stock_csv=>number(
      lv_newest_running_age ).
    lv_newest_running_run_id_text = lv_newest_running_run_id.
  ELSE.
    lv_oldest_running_run_id_text = 'n/a'.
    lv_newest_running_age_text = 'n/a'.
    lv_newest_running_run_id_text = 'n/a'.
  ENDIF.

  IF p_csv = abap_true.
    IF p_sum = abap_true.
      CLEAR: lv_running_runs,
             lv_success_runs,
             lv_partial_runs,
             lv_error_runs,
             lv_full_count,
              lv_partial_count,
              lv_unallocated_count,
              lv_priority_runs,
              lv_fifo_runs,
              lv_full_only_runs,
              lv_smallest_runs,
              lv_largest_runs,
              lv_best_runs,
              lv_legacy_strategy_runs,
              lv_available_total,
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_priority_requested,
             lv_priority_allocated,
             lv_priority_shortage,
             lv_fifo_requested,
             lv_fifo_allocated,
             lv_fifo_shortage,
             lv_full_only_requested,
             lv_full_only_allocated,
             lv_full_only_shortage,
             lv_smallest_requested,
             lv_smallest_allocated,
             lv_smallest_shortage,
             lv_largest_requested,
             lv_largest_allocated,
             lv_largest_shortage,
             lv_best_requested,
             lv_best_allocated,
             lv_best_shortage,
             lv_legacy_requested,
             lv_legacy_allocated,
             lv_legacy_shortage,
             lv_summary_unit,
             lv_mixed_units,
             lv_coverage,
             lv_run_coverage_text,
             lv_csv_line,
             lv_csv_field,
             lt_csv_fields.
      LOOP AT lt_runs ASSIGNING <ls_run>.
        IF lv_summary_unit IS INITIAL.
          lv_summary_unit = <ls_run>-unit.
        ELSEIF lv_summary_unit <> <ls_run>-unit.
          lv_mixed_units = abap_true.
          CLEAR: lv_available_total,
                 lv_requested_total,
                 lv_allocated_total,
                 lv_shortage_total,
                 lv_priority_requested,
                 lv_priority_allocated,
                 lv_priority_shortage,
                 lv_fifo_requested,
                 lv_fifo_allocated,
                 lv_fifo_shortage,
                 lv_full_only_requested,
                 lv_full_only_allocated,
                 lv_full_only_shortage,
                 lv_smallest_requested,
                 lv_smallest_allocated,
                 lv_smallest_shortage,
                 lv_largest_requested,
                 lv_largest_allocated,
                 lv_largest_shortage,
             lv_best_requested,
             lv_best_allocated,
             lv_best_shortage,
             lv_legacy_requested,
             lv_legacy_allocated,
             lv_legacy_shortage,
             lv_priority_coverage,
             lv_fifo_coverage,
             lv_full_only_coverage,
             lv_smallest_coverage,
             lv_largest_coverage,
             lv_best_coverage,
             lv_legacy_coverage.
        ENDIF.
        CASE <ls_run>-status.
          WHEN 'R'.
            lv_running_runs = lv_running_runs + 1.
          WHEN 'S'.
            lv_success_runs = lv_success_runs + 1.
          WHEN 'P'.
            lv_partial_runs = lv_partial_runs + 1.
          WHEN 'E'.
            lv_error_runs = lv_error_runs + 1.
        ENDCASE.
        CASE <ls_run>-strategy.
          WHEN 'P'.
            lv_priority_runs = lv_priority_runs + 1.
          WHEN 'F'.
            lv_fifo_runs = lv_fifo_runs + 1.
          WHEN 'N'.
            lv_full_only_runs = lv_full_only_runs + 1.
          WHEN 'S'.
            lv_smallest_runs = lv_smallest_runs + 1.
          WHEN 'L'.
            lv_largest_runs = lv_largest_runs + 1.
          WHEN 'B'.
            lv_best_runs = lv_best_runs + 1.
          WHEN OTHERS.
            lv_legacy_strategy_runs = lv_legacy_strategy_runs + 1.
        ENDCASE.
        IF lv_mixed_units = abap_false.
          CASE <ls_run>-strategy.
            WHEN 'P'.
              lv_priority_allocated = lv_priority_allocated
                + <ls_run>-allocated.
              lv_priority_shortage = lv_priority_shortage
                + <ls_run>-shortage.
              lv_priority_requested = lv_priority_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'F'.
              lv_fifo_allocated = lv_fifo_allocated + <ls_run>-allocated.
              lv_fifo_shortage = lv_fifo_shortage + <ls_run>-shortage.
              lv_fifo_requested = lv_fifo_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'N'.
              lv_full_only_allocated = lv_full_only_allocated
                + <ls_run>-allocated.
              lv_full_only_shortage = lv_full_only_shortage
                + <ls_run>-shortage.
              lv_full_only_requested = lv_full_only_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'S'.
              lv_smallest_allocated = lv_smallest_allocated
                + <ls_run>-allocated.
              lv_smallest_shortage = lv_smallest_shortage
                + <ls_run>-shortage.
              lv_smallest_requested = lv_smallest_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'L'.
              lv_largest_allocated = lv_largest_allocated
                + <ls_run>-allocated.
              lv_largest_shortage = lv_largest_shortage
                + <ls_run>-shortage.
              lv_largest_requested = lv_largest_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'B'.
              lv_best_allocated = lv_best_allocated
                + <ls_run>-allocated.
              lv_best_shortage = lv_best_shortage
                + <ls_run>-shortage.
              lv_best_requested = lv_best_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN OTHERS.
              lv_legacy_allocated = lv_legacy_allocated
                + <ls_run>-allocated.
              lv_legacy_shortage = lv_legacy_shortage
                + <ls_run>-shortage.
              lv_legacy_requested = lv_legacy_requested
                + <ls_run>-allocated + <ls_run>-shortage.
          ENDCASE.
        ENDIF.
        IF lv_priority_requested > 0.
          lv_priority_coverage = lv_priority_allocated * 100
            / lv_priority_requested.
        ENDIF.
        IF lv_fifo_requested > 0.
          lv_fifo_coverage = lv_fifo_allocated * 100
            / lv_fifo_requested.
        ENDIF.
        IF lv_full_only_requested > 0.
          lv_full_only_coverage = lv_full_only_allocated * 100
            / lv_full_only_requested.
        ENDIF.
        IF lv_smallest_requested > 0.
          lv_smallest_coverage = lv_smallest_allocated * 100
            / lv_smallest_requested.
        ENDIF.
        IF lv_largest_requested > 0.
          lv_largest_coverage = lv_largest_allocated * 100
            / lv_largest_requested.
        ENDIF.
        IF lv_best_requested > 0.
          lv_best_coverage = lv_best_allocated * 100
            / lv_best_requested.
        ENDIF.
        IF lv_legacy_requested > 0.
          lv_legacy_coverage = lv_legacy_allocated * 100
            / lv_legacy_requested.
        ENDIF.
        lv_full_count = lv_full_count + <ls_run>-full_count.
        lv_partial_count = lv_partial_count + <ls_run>-partial_count.
        lv_unallocated_count = lv_unallocated_count
          + <ls_run>-unallocated_count.
        IF lv_mixed_units = abap_false.
          lv_available_total = lv_available_total + <ls_run>-available.
          lv_requested_total = lv_requested_total + <ls_run>-allocated
            + <ls_run>-shortage.
          lv_allocated_total = lv_allocated_total + <ls_run>-allocated.
          lv_shortage_total = lv_shortage_total + <ls_run>-shortage.
         ENDIF.
       ENDLOOP.
       CLEAR lv_summary_strategy.
       IF lv_priority_runs > 0.
         lv_summary_strategy = 'P'.
       ENDIF.
       IF lv_fifo_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'F'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_full_only_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'N'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_smallest_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'S'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_largest_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'L'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_best_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'B'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_legacy_strategy_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'legacy'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_summary_strategy IS INITIAL.
         lv_summary_strategy = 'n/a'.
       ENDIF.
       IF lv_mixed_units = abap_true.
       lv_summary_unit = 'mixed'.
        lv_run_coverage_text = 'n/a'.
        lv_shortage_pct_text = 'n/a'.
      ELSEIF lv_requested_total > 0.
        lv_coverage = lv_allocated_total * 100 / lv_requested_total.
        lv_run_coverage_text = zcl_stock_csv=>number( lv_coverage ).
        lv_shortage_pct = lv_shortage_total * 100 / lv_requested_total.
        lv_shortage_pct_text = zcl_stock_csv=>number( lv_shortage_pct ).
      ELSE.
        lv_run_coverage_text = 'n/a'.
        lv_shortage_pct_text = 'n/a'.
      ENDIF.
      WRITE: / 'mode;generated_date;generated_time;schema_version;sort;filters_applied;filters;offset;max_rows;'
        && 'page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;total_rows;material;'
        && 'plant;storage_location;batch;unit;strategy;mixed_units;run_count;priority_run_count;fifo_run_count;'
        && 'full_only_run_count;smallest_run_count;largest_run_count;best_run_count;legacy_strategy_run_count;'
        && 'priority_requested;priority_allocated;priority_shortage;priority_coverage_pct;fifo_requested;'
        && 'fifo_allocated;fifo_shortage;fifo_coverage_pct;full_only_requested;full_only_allocated;'
        && 'full_only_shortage;full_only_coverage_pct;smallest_requested;smallest_allocated;smallest_shortage;'
        && 'smallest_coverage_pct;largest_requested;largest_allocated;largest_shortage;largest_coverage_pct;'
        && 'best_requested;best_allocated;best_shortage;best_coverage_pct;legacy_requested;legacy_allocated;'
        && 'legacy_shortage;legacy_coverage_pct;running_count;success_count;partial_run_count;error_count;'
        && 'completion_pct;success_rate_pct;partial_rate_pct;error_rate_pct;full_count;partial_count;'
        && 'unallocated_count;available;requested;allocated;shortage;coverage_pct;shortage_pct;'
        && 'average_duration_seconds;minimum_duration_seconds;maximum_duration_seconds;completed_duration_runs;'
        && 'oldest_running_age_seconds;oldest_running_run_id;newest_running_age_seconds;newest_running_run_id'.
      APPEND 'summary' TO lt_csv_fields.
      APPEND sy-datum TO lt_csv_fields.
      APPEND sy-uzeit TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 20 ) TO lt_csv_fields.
      APPEND lv_sort_mode TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND lv_filter_names_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_page_number ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_page_count ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_last_offset ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF lv_has_previous = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_previous_offset ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF lv_has_more = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>number( lv_next_offset ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_rows ) TO lt_csv_fields.
      WRITE p_matnr TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE p_werks TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE p_lgort TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE p_charg TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_summary_unit TO lt_csv_fields.
      APPEND lv_summary_strategy TO lt_csv_fields.
      IF lv_mixed_units = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      lv_csv_field = zcl_stock_csv=>number( lines( lt_runs ) ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_priority_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_fifo_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_full_only_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_smallest_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_largest_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_best_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_legacy_strategy_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      IF lv_mixed_units = abap_true.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>number( lv_priority_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_priority_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_priority_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_priority_coverage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_fifo_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_fifo_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_fifo_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_fifo_coverage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_full_only_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_full_only_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_full_only_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_full_only_coverage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_smallest_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_smallest_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_smallest_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_smallest_coverage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_largest_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_largest_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_largest_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_largest_coverage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_best_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_best_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_best_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_best_coverage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_legacy_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_legacy_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_legacy_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_legacy_coverage ) TO lt_csv_fields.
      ENDIF.
      lv_csv_field = zcl_stock_csv=>number( lv_running_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_success_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_partial_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_error_runs ).
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_completion_pct ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_success_rate_pct ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_partial_rate_pct ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_error_rate_pct ) TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_full_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_partial_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_unallocated_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      IF lv_mixed_units = abap_true.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
      ELSE.
        lv_csv_field = zcl_stock_csv=>number( lv_available_total ).
        APPEND lv_csv_field TO lt_csv_fields.
        lv_csv_field = zcl_stock_csv=>number( lv_requested_total ).
        APPEND lv_csv_field TO lt_csv_fields.
        lv_csv_field = zcl_stock_csv=>number( lv_allocated_total ).
        APPEND lv_csv_field TO lt_csv_fields.
        lv_csv_field = zcl_stock_csv=>number( lv_shortage_total ).
        APPEND lv_csv_field TO lt_csv_fields.
      ENDIF.
      APPEND lv_run_coverage_text TO lt_csv_fields.
      APPEND lv_shortage_pct_text TO lt_csv_fields.
      APPEND lv_average_duration_text TO lt_csv_fields.
      IF lv_duration_count > 0.
        APPEND zcl_stock_csv=>number( lv_minimum_duration ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_maximum_duration ) TO lt_csv_fields.
      ELSE.
        APPEND lv_minimum_duration_text TO lt_csv_fields.
        APPEND lv_maximum_duration_text TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>number( lv_duration_count ) TO lt_csv_fields.
      APPEND lv_oldest_running_age_text TO lt_csv_fields.
      APPEND lv_oldest_running_run_id_text TO lt_csv_fields.
      APPEND lv_newest_running_age_text TO lt_csv_fields.
      APPEND lv_newest_running_run_id_text TO lt_csv_fields.
      LOOP AT lt_csv_fields ASSIGNING <lv_csv_field>.
        <lv_csv_field> = zcl_stock_csv=>quote( <lv_csv_field> ).
      ENDLOOP.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    lv_csv_line = 'run_id;generated_date;generated_time;schema_version;sort;filters_applied;filters;offset;max_rows;'
      && 'page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;total_rows;material;'
      && 'plant;storage_location;batch;unit;strategy;requested_on_from;requested_on_to;available;allocated;'
      && 'shortage;coverage_pct;shortage_pct;status;message;demand_count;full_count;partial_count;'
      && 'unallocated_count;start_date;start_time;finish_date;finish_time;duration_seconds;running_age_seconds'.
    WRITE: / lv_csv_line.
    LOOP AT lt_runs ASSIGNING <ls_run>.
      CLEAR: lv_run_coverage,
             lv_run_coverage_text,
             lv_run_shortage_pct,
             lv_run_shortage_pct_text,
             lv_duration_seconds,
             lv_duration_text,
             lv_running_age_seconds,
             lv_running_age_text,
             lv_csv_line,
             lv_csv_field,
             lt_csv_fields.
      IF <ls_run>-allocated + <ls_run>-shortage > 0.
        lv_run_coverage = <ls_run>-allocated * 100
          / ( <ls_run>-allocated + <ls_run>-shortage ).
        lv_run_coverage_text = zcl_stock_csv=>number( lv_run_coverage ).
        lv_run_shortage_pct = <ls_run>-shortage * 100
          / ( <ls_run>-allocated + <ls_run>-shortage ).
        lv_run_shortage_pct_text = zcl_stock_csv=>number(
          lv_run_shortage_pct ).
      ELSE.
        lv_run_coverage_text = 'n/a'.
        lv_run_shortage_pct_text = 'n/a'.
      ENDIF.
      WRITE <ls_run>-run_id TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 9 ) TO lt_csv_fields.
      APPEND lv_sort_mode TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND lv_filter_names_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_page_number ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_page_count ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_last_offset ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF lv_has_previous = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_csv=>number( lv_previous_offset ) TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      IF lv_has_more = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>number( lv_next_offset ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_rows ) TO lt_csv_fields.
      WRITE <ls_run>-material TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-plant TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-storage_location TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-batch TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-strategy TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-requested_on_from TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-requested_on_to TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-available ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-allocated ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-shortage ).
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_run_coverage_text TO lt_csv_fields.
      APPEND lv_run_shortage_pct_text TO lt_csv_fields.
      WRITE <ls_run>-status TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-message TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-demand_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-full_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-partial_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_run>-unallocated_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-start_date TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-start_time TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-finish_date TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-finish_time TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
     IF <ls_run>-finish_date IS INITIAL.
       lv_duration_text = 'n/a'.
      ELSE.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = <ls_run>-finish_date
            time1    = <ls_run>-finish_time
            date2    = <ls_run>-start_date
            time2    = <ls_run>-start_time
          IMPORTING
            res_secs = lv_duration_seconds ).
        lv_duration_text = zcl_stock_csv=>number( lv_duration_seconds ).
      ENDIF.
      IF <ls_run>-status = 'R'.
        ls_running_age = lo_audit->get_running_age( <ls_run> ).
        IF ls_running_age-available = abap_true.
          lv_running_age_seconds = ls_running_age-seconds.
          lv_running_age_text = zcl_stock_csv=>number(
            lv_running_age_seconds ).
        ENDIF.
      ENDIF.
      IF lv_running_age_text IS INITIAL.
        lv_running_age_text = 'n/a'.
      ENDIF.
      APPEND lv_duration_text TO lt_csv_fields.
      APPEND lv_running_age_text TO lt_csv_fields.
      LOOP AT lt_csv_fields ASSIGNING <lv_csv_field>.
        <lv_csv_field> = zcl_stock_csv=>quote( <lv_csv_field> ).
      ENDLOOP.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
    ENDLOOP.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    IF p_sum = abap_true.
      CLEAR: lv_running_runs,
             lv_success_runs,
             lv_partial_runs,
             lv_error_runs,
             lv_full_count,
              lv_partial_count,
              lv_unallocated_count,
              lv_priority_runs,
              lv_fifo_runs,
              lv_full_only_runs,
              lv_smallest_runs,
              lv_largest_runs,
              lv_best_runs,
              lv_legacy_strategy_runs,
              lv_available_total,
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_priority_requested,
             lv_priority_allocated,
             lv_priority_shortage,
             lv_fifo_requested,
             lv_fifo_allocated,
             lv_fifo_shortage,
             lv_full_only_requested,
             lv_full_only_allocated,
             lv_full_only_shortage,
             lv_smallest_requested,
             lv_smallest_allocated,
             lv_smallest_shortage,
             lv_largest_requested,
             lv_largest_allocated,
             lv_largest_shortage,
             lv_best_requested,
             lv_best_allocated,
             lv_best_shortage,
             lv_legacy_requested,
             lv_legacy_allocated,
             lv_legacy_shortage,
             lv_summary_unit,
             lv_mixed_units,
             lv_coverage,
             lv_run_coverage_text,
             lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 20 ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = abap_true ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_date'
          iv_value = sy-datum ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_time'
          iv_value = sy-uzeit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'material'
          iv_value = p_matnr ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'plant'
          iv_value = p_werks ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'storage_location'
          iv_value = p_lgort ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'batch'
          iv_value = p_charg ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sort'
          iv_value = lv_sort_mode ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'filters_applied'
          iv_value = lv_filters_applied ) TO lt_json_fields.
        APPEND zcl_stock_json=>string_array_property(
          iv_name   = 'filters'
          it_values = lt_filter_names ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'offset'
          iv_value = p_skip ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'max_rows'
          iv_value = p_max ) TO lt_json_fields.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'page_number'
            iv_value = lv_page_number ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'page_number' ) TO lt_json_fields.
        ENDIF.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'page_count'
            iv_value = lv_page_count ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'page_count' ) TO lt_json_fields.
        ENDIF.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'last_offset'
            iv_value = lv_last_offset ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'last_offset' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'has_previous'
          iv_value = lv_has_previous ) TO lt_json_fields.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'previous_offset'
            iv_value = lv_previous_offset ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'previous_offset' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'has_more'
          iv_value = lv_has_more ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'next_offset'
          iv_value = lv_next_offset ) TO lt_json_fields.
       APPEND zcl_stock_json=>number_property(
         iv_name  = 'total_rows'
         iv_value = lv_total_rows ) TO lt_json_fields.
      ENDIF.
      LOOP AT lt_runs ASSIGNING <ls_run>.
        IF lv_summary_unit IS INITIAL.
          lv_summary_unit = <ls_run>-unit.
        ELSEIF lv_summary_unit <> <ls_run>-unit.
          lv_mixed_units = abap_true.
          CLEAR: lv_available_total,
                 lv_requested_total,
                 lv_allocated_total,
                 lv_shortage_total,
                 lv_priority_requested,
                 lv_priority_allocated,
                 lv_priority_shortage,
                 lv_fifo_requested,
                 lv_fifo_allocated,
                 lv_fifo_shortage,
                 lv_full_only_requested,
                 lv_full_only_allocated,
                 lv_full_only_shortage,
                 lv_smallest_requested,
                 lv_smallest_allocated,
                 lv_smallest_shortage,
                 lv_largest_requested,
                 lv_largest_allocated,
                 lv_largest_shortage,
             lv_best_requested,
             lv_best_allocated,
             lv_best_shortage,
             lv_legacy_requested,
             lv_legacy_allocated,
             lv_legacy_shortage,
             lv_priority_coverage,
             lv_fifo_coverage,
             lv_full_only_coverage,
             lv_smallest_coverage,
             lv_largest_coverage,
             lv_best_coverage,
             lv_legacy_coverage.
        ENDIF.
        CASE <ls_run>-status.
          WHEN 'R'.
            lv_running_runs = lv_running_runs + 1.
          WHEN 'S'.
            lv_success_runs = lv_success_runs + 1.
          WHEN 'P'.
            lv_partial_runs = lv_partial_runs + 1.
          WHEN 'E'.
            lv_error_runs = lv_error_runs + 1.
        ENDCASE.
        CASE <ls_run>-strategy.
          WHEN 'P'.
            lv_priority_runs = lv_priority_runs + 1.
          WHEN 'F'.
            lv_fifo_runs = lv_fifo_runs + 1.
          WHEN 'N'.
            lv_full_only_runs = lv_full_only_runs + 1.
          WHEN 'S'.
            lv_smallest_runs = lv_smallest_runs + 1.
          WHEN 'L'.
            lv_largest_runs = lv_largest_runs + 1.
          WHEN 'B'.
            lv_best_runs = lv_best_runs + 1.
          WHEN OTHERS.
            lv_legacy_strategy_runs = lv_legacy_strategy_runs + 1.
        ENDCASE.
        IF lv_mixed_units = abap_false.
          CASE <ls_run>-strategy.
            WHEN 'P'.
              lv_priority_allocated = lv_priority_allocated
                + <ls_run>-allocated.
              lv_priority_shortage = lv_priority_shortage
                + <ls_run>-shortage.
              lv_priority_requested = lv_priority_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'F'.
              lv_fifo_allocated = lv_fifo_allocated + <ls_run>-allocated.
              lv_fifo_shortage = lv_fifo_shortage + <ls_run>-shortage.
              lv_fifo_requested = lv_fifo_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'N'.
              lv_full_only_allocated = lv_full_only_allocated
                + <ls_run>-allocated.
              lv_full_only_shortage = lv_full_only_shortage
                + <ls_run>-shortage.
              lv_full_only_requested = lv_full_only_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'S'.
              lv_smallest_allocated = lv_smallest_allocated
                + <ls_run>-allocated.
              lv_smallest_shortage = lv_smallest_shortage
                + <ls_run>-shortage.
              lv_smallest_requested = lv_smallest_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'L'.
              lv_largest_allocated = lv_largest_allocated
                + <ls_run>-allocated.
              lv_largest_shortage = lv_largest_shortage
                + <ls_run>-shortage.
              lv_largest_requested = lv_largest_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'B'.
              lv_best_allocated = lv_best_allocated
                + <ls_run>-allocated.
              lv_best_shortage = lv_best_shortage
                + <ls_run>-shortage.
              lv_best_requested = lv_best_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN OTHERS.
              lv_legacy_allocated = lv_legacy_allocated
                + <ls_run>-allocated.
              lv_legacy_shortage = lv_legacy_shortage
                + <ls_run>-shortage.
              lv_legacy_requested = lv_legacy_requested
                + <ls_run>-allocated + <ls_run>-shortage.
          ENDCASE.
        ENDIF.
        IF lv_priority_requested > 0.
          lv_priority_coverage = lv_priority_allocated * 100
            / lv_priority_requested.
        ENDIF.
        IF lv_fifo_requested > 0.
          lv_fifo_coverage = lv_fifo_allocated * 100
            / lv_fifo_requested.
        ENDIF.
        IF lv_full_only_requested > 0.
          lv_full_only_coverage = lv_full_only_allocated * 100
            / lv_full_only_requested.
        ENDIF.
        IF lv_smallest_requested > 0.
          lv_smallest_coverage = lv_smallest_allocated * 100
            / lv_smallest_requested.
        ENDIF.
        IF lv_largest_requested > 0.
          lv_largest_coverage = lv_largest_allocated * 100
            / lv_largest_requested.
        ENDIF.
        IF lv_best_requested > 0.
          lv_best_coverage = lv_best_allocated * 100
            / lv_best_requested.
        ENDIF.
        IF lv_legacy_requested > 0.
          lv_legacy_coverage = lv_legacy_allocated * 100
            / lv_legacy_requested.
        ENDIF.
        lv_full_count = lv_full_count + <ls_run>-full_count.
        lv_partial_count = lv_partial_count + <ls_run>-partial_count.
        lv_unallocated_count = lv_unallocated_count
          + <ls_run>-unallocated_count.
        IF lv_mixed_units = abap_false.
          lv_available_total = lv_available_total + <ls_run>-available.
          lv_requested_total = lv_requested_total + <ls_run>-allocated
            + <ls_run>-shortage.
          lv_allocated_total = lv_allocated_total + <ls_run>-allocated.
          lv_shortage_total = lv_shortage_total + <ls_run>-shortage.
         ENDIF.
       ENDLOOP.
       CLEAR lv_summary_strategy.
       IF lv_priority_runs > 0.
         lv_summary_strategy = 'P'.
       ENDIF.
       IF lv_fifo_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'F'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_full_only_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'N'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_smallest_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'S'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_largest_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'L'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_best_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'B'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_legacy_strategy_runs > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'legacy'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_summary_strategy IS INITIAL.
         lv_summary_strategy = 'n/a'.
       ENDIF.
       APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'summary' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'strategy'
        iv_value = lv_summary_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'mixed_units'
        iv_value = lv_mixed_units ) TO lt_json_fields.
      IF p_meta = abap_true OR p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'run_count'
          iv_value = lines( lt_runs ) ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'running_count'
          iv_value = lv_running_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'success_count'
          iv_value = lv_success_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'partial_run_count'
          iv_value = lv_partial_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'error_count'
          iv_value = lv_error_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'completion_pct'
          iv_value = lv_completion_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'success_rate_pct'
          iv_value = lv_success_rate_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'partial_rate_pct'
          iv_value = lv_partial_rate_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'error_rate_pct'
          iv_value = lv_error_rate_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_count'
          iv_value = lv_full_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'partial_count'
          iv_value = lv_partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'unallocated_count'
          iv_value = lv_unallocated_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority_run_count'
          iv_value = lv_priority_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fifo_run_count'
          iv_value = lv_fifo_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_only_run_count'
          iv_value = lv_full_only_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'smallest_run_count'
          iv_value = lv_smallest_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'largest_run_count'
          iv_value = lv_largest_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'best_run_count'
          iv_value = lv_best_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'legacy_strategy_run_count'
          iv_value = lv_legacy_strategy_runs ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'run_count'
          iv_value = lines( lt_runs ) ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'running_count'
          iv_value = lv_running_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'success_count'
          iv_value = lv_success_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'partial_run_count'
          iv_value = lv_partial_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'error_count'
          iv_value = lv_error_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'completion_pct'
          iv_value = lv_completion_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'success_rate_pct'
          iv_value = lv_success_rate_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'partial_rate_pct'
          iv_value = lv_partial_rate_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'error_rate_pct'
          iv_value = lv_error_rate_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_count'
          iv_value = lv_full_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'partial_count'
          iv_value = lv_partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unallocated_count'
          iv_value = lv_unallocated_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_run_count'
          iv_value = lv_priority_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_run_count'
          iv_value = lv_fifo_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_run_count'
          iv_value = lv_full_only_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_run_count'
          iv_value = lv_smallest_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_run_count'
          iv_value = lv_largest_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_run_count'
          iv_value = lv_best_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_strategy_run_count'
          iv_value = lv_legacy_strategy_runs ) TO lt_json_fields.
      ENDIF.
      IF lv_mixed_units = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
      ELSEIF p_meta = abap_true OR p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority_requested'
          iv_value = lv_priority_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority_allocated'
          iv_value = lv_priority_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority_shortage'
          iv_value = lv_priority_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority_coverage_pct'
          iv_value = lv_priority_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fifo_requested'
          iv_value = lv_fifo_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fifo_allocated'
          iv_value = lv_fifo_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fifo_shortage'
          iv_value = lv_fifo_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fifo_coverage_pct'
          iv_value = lv_fifo_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_only_requested'
          iv_value = lv_full_only_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_only_allocated'
          iv_value = lv_full_only_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_only_shortage'
          iv_value = lv_full_only_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_only_coverage_pct'
          iv_value = lv_full_only_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'smallest_requested'
          iv_value = lv_smallest_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'smallest_allocated'
          iv_value = lv_smallest_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'smallest_shortage'
          iv_value = lv_smallest_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'smallest_coverage_pct'
          iv_value = lv_smallest_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'largest_requested'
          iv_value = lv_largest_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'largest_allocated'
          iv_value = lv_largest_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'largest_shortage'
          iv_value = lv_largest_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'largest_coverage_pct'
          iv_value = lv_largest_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'best_requested'
          iv_value = lv_best_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'best_allocated'
          iv_value = lv_best_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'best_shortage'
          iv_value = lv_best_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'best_coverage_pct'
          iv_value = lv_best_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'legacy_requested'
          iv_value = lv_legacy_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'legacy_allocated'
          iv_value = lv_legacy_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'legacy_shortage'
          iv_value = lv_legacy_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'legacy_coverage_pct'
          iv_value = lv_legacy_coverage ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_requested'
          iv_value = lv_priority_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_allocated'
          iv_value = lv_priority_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_shortage'
          iv_value = lv_priority_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority_coverage_pct'
          iv_value = lv_priority_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_requested'
          iv_value = lv_fifo_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_allocated'
          iv_value = lv_fifo_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_shortage'
          iv_value = lv_fifo_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_coverage_pct'
          iv_value = lv_fifo_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_requested'
          iv_value = lv_full_only_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_allocated'
          iv_value = lv_full_only_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_shortage'
          iv_value = lv_full_only_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_coverage_pct'
          iv_value = lv_full_only_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_requested'
          iv_value = lv_smallest_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_allocated'
          iv_value = lv_smallest_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_shortage'
          iv_value = lv_smallest_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_coverage_pct'
          iv_value = lv_smallest_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_requested'
          iv_value = lv_largest_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_allocated'
          iv_value = lv_largest_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_shortage'
          iv_value = lv_largest_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_coverage_pct'
          iv_value = lv_largest_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_requested'
          iv_value = lv_best_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_allocated'
          iv_value = lv_best_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_shortage'
          iv_value = lv_best_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_coverage_pct'
          iv_value = lv_best_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_requested'
          iv_value = lv_legacy_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_allocated'
          iv_value = lv_legacy_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_shortage'
          iv_value = lv_legacy_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_coverage_pct'
          iv_value = lv_legacy_coverage ) TO lt_json_fields.
      ENDIF.
      IF lv_mixed_units = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = 'mixed' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'available'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocated'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage'
          iv_value = 'n/a' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = lv_summary_unit ) TO lt_json_fields.
        IF p_meta = abap_true OR p_typed = abap_true.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'available'
            iv_value = lv_available_total ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'requested'
            iv_value = lv_requested_total ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'allocated'
            iv_value = lv_allocated_total ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'shortage'
            iv_value = lv_shortage_total ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'available'
            iv_value = lv_available_total ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'requested'
            iv_value = lv_requested_total ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'allocated'
            iv_value = lv_allocated_total ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'shortage'
            iv_value = lv_shortage_total ) TO lt_json_fields.
        ENDIF.
        IF lv_requested_total > 0.
          lv_coverage = lv_allocated_total * 100 / lv_requested_total.
          lv_run_coverage_text = lv_coverage.
        ELSE.
          lv_run_coverage_text = 'n/a'.
        ENDIF.
        IF ( p_meta = abap_true OR p_typed = abap_true )
            AND lv_requested_total > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_coverage ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'coverage_pct'
            iv_value = lv_run_coverage_text ) TO lt_json_fields.
        ENDIF.
      ENDIF.
      IF lv_mixed_units = abap_true OR lv_requested_total <= 0.
        lv_shortage_pct_text = 'n/a'.
      ELSE.
        lv_shortage_pct = lv_shortage_total * 100 / lv_requested_total.
        lv_shortage_pct_text = lv_shortage_pct.
      ENDIF.
      IF ( p_meta = abap_true OR p_typed = abap_true )
          AND lv_requested_total > 0
          AND lv_mixed_units = abap_false.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'shortage_pct'
          iv_value = lv_shortage_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage_pct'
          iv_value = lv_shortage_pct_text ) TO lt_json_fields.
      ENDIF.
      IF p_meta = abap_true OR p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'average_duration_seconds'
          iv_value = lv_average_duration ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'average_duration_seconds'
          iv_value = lv_average_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_meta = abap_true OR p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'minimum_duration_seconds'
          iv_value = lv_minimum_duration ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'maximum_duration_seconds'
          iv_value = lv_maximum_duration ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_duration_seconds'
          iv_value = lv_minimum_duration_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'maximum_duration_seconds'
          iv_value = lv_maximum_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_meta = abap_true OR p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'completed_duration_runs'
          iv_value = lv_duration_count ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'completed_duration_runs'
          iv_value = lv_duration_count ) TO lt_json_fields.
      ENDIF.
      IF p_meta = abap_true OR p_typed = abap_true.
        IF lv_running_age_count > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'oldest_running_age_seconds'
            iv_value = lv_oldest_running_age ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'oldest_running_age_seconds' ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'oldest_running_age_seconds'
          iv_value = lv_oldest_running_age_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'oldest_running_run_id'
        iv_value = lv_oldest_running_run_id_text ) TO lt_json_fields.
      IF p_meta = abap_true OR p_typed = abap_true.
        IF lv_running_age_count > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'newest_running_age_seconds'
            iv_value = lv_newest_running_age ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'newest_running_age_seconds' ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'newest_running_age_seconds'
          iv_value = lv_newest_running_age_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'newest_running_run_id'
        iv_value = lv_newest_running_run_id_text ) TO lt_json_fields.
      IF p_meta = abap_true.
        CONCATENATE LINES OF lt_json_fields INTO lv_summary_json
          SEPARATED BY ','.
        CLEAR lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'mode'
          iv_value = 'summary' ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 20 ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_date'
          iv_value = sy-datum ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_time'
          iv_value = sy-uzeit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sort'
          iv_value = lv_sort_mode ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'filters_applied'
          iv_value = lv_filters_applied ) TO lt_json_fields.
        APPEND zcl_stock_json=>string_array_property(
          iv_name   = 'filters'
          it_values = lt_filter_names ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'material'
          iv_value = p_matnr ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'plant'
          iv_value = p_werks ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'storage_location'
          iv_value = p_lgort ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'batch'
          iv_value = p_charg ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'run_id'
          iv_value = p_runid ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'run_id_contains'
          iv_value = p_rid ) TO lt_json_fields.
        IF p_runid IS INITIAL.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_context'
            iv_value = 'not_requested' ) TO lt_json_fields.
        ELSE.
          CLEAR lt_context_runs.
          TRY.
              lt_context_runs = lo_audit->get_runs(
                iv_material         = p_matnr
                iv_plant            = p_werks
                iv_storage_location = p_lgort
                iv_batch            = p_charg
                iv_run_id           = p_runid ).
            CATCH zcx_stock_allocation.
              CLEAR lt_context_runs.
          ENDTRY.
          READ TABLE lt_context_runs ASSIGNING <ls_run> INDEX 1.
          IF sy-subrc <> 0.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_context'
              iv_value = 'unavailable' ) TO lt_json_fields.
          ELSE.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_context'
              iv_value = 'available' ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_status'
              iv_value = <ls_run>-status ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_message'
              iv_value = <ls_run>-message ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_start_date'
              iv_value = <ls_run>-start_date ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_start_time'
              iv_value = <ls_run>-start_time ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_finish_date'
              iv_value = <ls_run>-finish_date ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_finish_time'
              iv_value = <ls_run>-finish_time ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_demand_count'
              iv_value = <ls_run>-demand_count ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_full_count'
              iv_value = <ls_run>-full_count ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_partial_count'
              iv_value = <ls_run>-partial_count ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_unallocated_count'
              iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_allocated'
              iv_value = <ls_run>-allocated ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_shortage'
              iv_value = <ls_run>-shortage ) TO lt_json_fields.
          ENDIF.
        ENDIF.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'row_count'
          iv_value = lines( lt_runs ) ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'offset'
          iv_value = p_skip ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'max_rows'
          iv_value = p_max ) TO lt_json_fields.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'page_number'
            iv_value = lv_page_number ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'page_number' ) TO lt_json_fields.
        ENDIF.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'page_count'
            iv_value = lv_page_count ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'page_count' ) TO lt_json_fields.
        ENDIF.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'last_offset'
            iv_value = lv_last_offset ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'last_offset' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'has_previous'
          iv_value = lv_has_previous ) TO lt_json_fields.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'previous_offset'
            iv_value = lv_previous_offset ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'previous_offset' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'has_more'
          iv_value = lv_has_more ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'next_offset'
          iv_value = lv_next_offset ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'total_rows'
          iv_value = lv_total_rows ) TO lt_json_fields.
        CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
        CONCATENATE '{' lv_json_line ',"summary":{' lv_summary_json '}}'
          INTO lv_json_line.
      ELSE.
        CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
        CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      ENDIF.
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_meta = abap_true.
      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'detail' ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 9 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sort'
        iv_value = lv_sort_mode ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'filters_applied'
        iv_value = lv_filters_applied ) TO lt_json_fields.
      APPEND zcl_stock_json=>string_array_property(
        iv_name   = 'filters'
        it_values = lt_filter_names ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = p_matnr ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = p_werks ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = p_lgort ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = p_charg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id'
        iv_value = p_runid ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id_contains'
        iv_value = p_rid ) TO lt_json_fields.
      IF p_runid IS INITIAL.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_context'
          iv_value = 'not_requested' ) TO lt_json_fields.
      ELSE.
        READ TABLE lt_runs ASSIGNING <ls_run> INDEX 1.
        IF sy-subrc <> 0.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_context'
            iv_value = 'unavailable' ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_context'
            iv_value = 'available' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_status'
            iv_value = <ls_run>-status ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_message'
            iv_value = <ls_run>-message ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_start_date'
            iv_value = <ls_run>-start_date ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_start_time'
            iv_value = <ls_run>-start_time ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_finish_date'
            iv_value = <ls_run>-finish_date ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_finish_time'
            iv_value = <ls_run>-finish_time ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_demand_count'
            iv_value = <ls_run>-demand_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_full_count'
            iv_value = <ls_run>-full_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_partial_count'
            iv_value = <ls_run>-partial_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_unallocated_count'
            iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_allocated'
            iv_value = <ls_run>-allocated ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_shortage'
            iv_value = <ls_run>-shortage ) TO lt_json_fields.
        ENDIF.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'row_count'
        iv_value = lines( lt_runs ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'offset'
        iv_value = p_skip ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'max_rows'
        iv_value = p_max ) TO lt_json_fields.
      IF p_max > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'page_number'
          iv_value = lv_page_number ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'page_number' ) TO lt_json_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'page_count'
          iv_value = lv_page_count ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'page_count' ) TO lt_json_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_offset'
          iv_value = lv_last_offset ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_offset' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'has_previous'
        iv_value = lv_has_previous ) TO lt_json_fields.
      IF p_max > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'previous_offset'
          iv_value = lv_previous_offset ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'previous_offset' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'has_more'
        iv_value = lv_has_more ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'next_offset'
        iv_value = lv_next_offset ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'total_rows'
        iv_value = lv_total_rows ) TO lt_json_fields.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
      CONCATENATE '{' lv_json_line ',"rows":[' INTO lv_json_line.
      WRITE: / lv_json_line.
    ELSEIF p_ndjson = abap_false.
      WRITE: / '['.
    ENDIF.
    LOOP AT lt_runs ASSIGNING <ls_run>.
      lv_row_index = sy-tabix.
      CLEAR: lv_run_coverage,
             lv_run_coverage_text,
             lv_run_shortage_pct,
             lv_run_shortage_pct_text,
             lv_duration_seconds,
             lv_duration_text,
             lv_running_age_seconds,
             lv_running_age_text,
             lv_numeric_json,
             lv_json_line,
             lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 9 ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = abap_true ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_date'
          iv_value = sy-datum ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_time'
          iv_value = sy-uzeit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sort'
          iv_value = lv_sort_mode ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'filters_applied'
          iv_value = lv_filters_applied ) TO lt_json_fields.
        APPEND zcl_stock_json=>string_array_property(
          iv_name   = 'filters'
          it_values = lt_filter_names ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'offset'
          iv_value = p_skip ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'max_rows'
          iv_value = p_max ) TO lt_json_fields.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'page_number'
            iv_value = lv_page_number ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'page_number' ) TO lt_json_fields.
        ENDIF.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'page_count'
            iv_value = lv_page_count ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'page_count' ) TO lt_json_fields.
        ENDIF.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'last_offset'
            iv_value = lv_last_offset ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'last_offset' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'has_previous'
          iv_value = lv_has_previous ) TO lt_json_fields.
        IF p_max > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'previous_offset'
            iv_value = lv_previous_offset ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'previous_offset' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'has_more'
          iv_value = lv_has_more ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'next_offset'
          iv_value = lv_next_offset ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'total_rows'
          iv_value = lv_total_rows ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'material'
          iv_value = p_matnr ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'plant'
          iv_value = p_werks ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'storage_location'
          iv_value = p_lgort ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'batch'
          iv_value = p_charg ) TO lt_json_fields.
      ENDIF.
      IF <ls_run>-allocated + <ls_run>-shortage > 0.
        lv_run_coverage = <ls_run>-allocated * 100
          / ( <ls_run>-allocated + <ls_run>-shortage ).
        lv_run_coverage_text = lv_run_coverage.
        lv_run_shortage_pct = <ls_run>-shortage * 100
          / ( <ls_run>-allocated + <ls_run>-shortage ).
        lv_run_shortage_pct_text = lv_run_shortage_pct.
      ELSE.
        CLEAR lv_run_shortage_pct.
        lv_run_coverage_text = 'n/a'.
        lv_run_shortage_pct_text = 'n/a'.
      ENDIF.
      IF <ls_run>-finish_date IS INITIAL.
        lv_duration_text = 'n/a'.
      ELSE.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = <ls_run>-finish_date
            time1    = <ls_run>-finish_time
            date2    = <ls_run>-start_date
            time2    = <ls_run>-start_time
          IMPORTING
            res_secs = lv_duration_seconds ).
        lv_duration_text = lv_duration_seconds.
      ENDIF.
      IF <ls_run>-status = 'R'.
        ls_running_age = lo_audit->get_running_age( <ls_run> ).
        IF ls_running_age-available = abap_true.
          lv_running_age_seconds = ls_running_age-seconds.
          lv_running_age_text = zcl_stock_csv=>number(
            lv_running_age_seconds ).
        ENDIF.
      ELSE.
        lv_running_age_text = 'n/a'.
      ENDIF.
      IF lv_running_age_text IS INITIAL.
        lv_running_age_text = 'n/a'.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id'
        iv_value = <ls_run>-run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = <ls_run>-material ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = <ls_run>-plant ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = <ls_run>-storage_location ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = <ls_run>-batch ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = <ls_run>-unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'strategy'
        iv_value = <ls_run>-strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from'
        iv_value = <ls_run>-requested_on_from ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to'
        iv_value = <ls_run>-requested_on_to ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'available'
          iv_value = <ls_run>-available ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'allocated'
          iv_value = <ls_run>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'shortage'
          iv_value = <ls_run>-shortage ) TO lt_json_fields.
        IF <ls_run>-allocated + <ls_run>-shortage > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_run_coverage ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'coverage_pct' ) TO lt_json_fields.
        ENDIF.
        IF <ls_run>-allocated + <ls_run>-shortage > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'shortage_pct'
            iv_value = lv_run_shortage_pct ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'shortage_pct' ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'available'
          iv_value = <ls_run>-available ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocated'
          iv_value = <ls_run>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage'
          iv_value = <ls_run>-shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = lv_run_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage_pct'
          iv_value = lv_run_shortage_pct_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'status'
        iv_value = <ls_run>-status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'message'
        iv_value = <ls_run>-message ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'demand_count'
          iv_value = <ls_run>-demand_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_count'
          iv_value = <ls_run>-full_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'partial_count'
          iv_value = <ls_run>-partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'unallocated_count'
          iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'demand_count'
          iv_value = <ls_run>-demand_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_count'
          iv_value = <ls_run>-full_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'partial_count'
          iv_value = <ls_run>-partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unallocated_count'
          iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'start_date'
        iv_value = <ls_run>-start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'start_time'
        iv_value = <ls_run>-start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'finish_date'
        iv_value = <ls_run>-finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'finish_time'
        iv_value = <ls_run>-finish_time ) TO lt_json_fields.
      IF p_typed = abap_true.
        IF <ls_run>-finish_date IS INITIAL.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'duration_seconds' ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'duration_seconds'
            iv_value = lv_duration_seconds ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'duration_seconds'
          iv_value = lv_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true.
        IF <ls_run>-status = 'R'
            AND lv_running_age_text <> 'n/a'.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'running_age_seconds'
            iv_value = lv_running_age_seconds ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'running_age_seconds' ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'running_age_seconds'
          iv_value = lv_running_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_meta = abap_true.
        CLEAR lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'available'
          iv_value = <ls_run>-available ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'allocated'
          iv_value = <ls_run>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'shortage'
          iv_value = <ls_run>-shortage ) TO lt_json_fields.
        IF <ls_run>-allocated + <ls_run>-shortage > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_run_coverage ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'coverage_pct' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'demand_count'
          iv_value = <ls_run>-demand_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_count'
          iv_value = <ls_run>-full_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'partial_count'
          iv_value = <ls_run>-partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'unallocated_count'
          iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
        IF <ls_run>-finish_date IS INITIAL.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'duration_seconds' ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'duration_seconds'
            iv_value = lv_duration_seconds ) TO lt_json_fields.
        ENDIF.
        IF <ls_run>-status = 'R'
            AND lv_running_age_text <> 'n/a'.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'running_age_seconds'
            iv_value = lv_running_age_seconds ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'running_age_seconds' ) TO lt_json_fields.
        ENDIF.
        CONCATENATE LINES OF lt_json_fields INTO lv_numeric_json
          SEPARATED BY ','.
        CLEAR lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'run_id'
          iv_value = <ls_run>-run_id ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'material'
          iv_value = <ls_run>-material ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'plant'
          iv_value = <ls_run>-plant ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'storage_location'
          iv_value = <ls_run>-storage_location ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'batch'
          iv_value = <ls_run>-batch ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = <ls_run>-unit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'strategy'
          iv_value = <ls_run>-strategy ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_on_from'
          iv_value = <ls_run>-requested_on_from ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_on_to'
          iv_value = <ls_run>-requested_on_to ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'available'
          iv_value = <ls_run>-available ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocated'
          iv_value = <ls_run>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage'
          iv_value = <ls_run>-shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = lv_run_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'status'
          iv_value = <ls_run>-status ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'message'
          iv_value = <ls_run>-message ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'demand_count'
          iv_value = <ls_run>-demand_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_count'
          iv_value = <ls_run>-full_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'partial_count'
          iv_value = <ls_run>-partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unallocated_count'
          iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'start_date'
          iv_value = <ls_run>-start_date ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'start_time'
          iv_value = <ls_run>-start_time ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'finish_date'
          iv_value = <ls_run>-finish_date ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'finish_time'
          iv_value = <ls_run>-finish_time ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'duration_seconds'
          iv_value = lv_duration_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'running_age_seconds'
          iv_value = lv_running_age_text ) TO lt_json_fields.
        CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
        CONCATENATE '{' lv_json_line ',"numeric":{' lv_numeric_json '}}'
          INTO lv_json_line.
      ELSE.
        CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
        CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      ENDIF.
      IF p_ndjson = abap_false AND lv_row_index < lines( lt_runs ).
        CONCATENATE lv_json_line ',' INTO lv_json_line.
      ENDIF.
      WRITE: / lv_json_line.
    ENDLOOP.
    IF p_meta = abap_true.
      WRITE: / ']}'.
    ELSEIF p_ndjson = abap_false.
      WRITE: / ']'.
    ENDIF.
    RETURN.
  ENDIF.

  LOOP AT lt_runs ASSIGNING <ls_run>.
    IF lv_summary_unit IS INITIAL.
      lv_summary_unit = <ls_run>-unit.
    ELSEIF lv_summary_unit <> <ls_run>-unit.
      lv_mixed_units = abap_true.
      CLEAR: lv_available_total,
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_priority_requested,
             lv_priority_allocated,
             lv_priority_shortage,
             lv_fifo_requested,
             lv_fifo_allocated,
             lv_fifo_shortage,
             lv_full_only_requested,
             lv_full_only_allocated,
             lv_full_only_shortage,
             lv_smallest_requested,
             lv_smallest_allocated,
             lv_smallest_shortage,
             lv_largest_requested,
             lv_largest_allocated,
             lv_largest_shortage,
             lv_best_requested,
             lv_best_allocated,
             lv_best_shortage,
             lv_legacy_requested,
             lv_legacy_allocated,
             lv_legacy_shortage,
             lv_priority_coverage,
             lv_fifo_coverage,
             lv_full_only_coverage,
             lv_smallest_coverage,
             lv_largest_coverage,
             lv_best_coverage,
             lv_legacy_coverage.
    ENDIF.
    CASE <ls_run>-status.
      WHEN 'R'.
        lv_running_runs = lv_running_runs + 1.
      WHEN 'S'.
        lv_success_runs = lv_success_runs + 1.
      WHEN 'P'.
        lv_partial_runs = lv_partial_runs + 1.
      WHEN 'E'.
        lv_error_runs = lv_error_runs + 1.
    ENDCASE.
    CASE <ls_run>-strategy.
      WHEN 'P'.
        lv_priority_runs = lv_priority_runs + 1.
      WHEN 'F'.
        lv_fifo_runs = lv_fifo_runs + 1.
      WHEN 'N'.
        lv_full_only_runs = lv_full_only_runs + 1.
      WHEN 'S'.
        lv_smallest_runs = lv_smallest_runs + 1.
      WHEN 'L'.
        lv_largest_runs = lv_largest_runs + 1.
          WHEN OTHERS.
            lv_legacy_strategy_runs = lv_legacy_strategy_runs + 1.
        ENDCASE.
        IF lv_mixed_units = abap_false.
          CASE <ls_run>-strategy.
            WHEN 'P'.
              lv_priority_allocated = lv_priority_allocated
                + <ls_run>-allocated.
              lv_priority_shortage = lv_priority_shortage
                + <ls_run>-shortage.
              lv_priority_requested = lv_priority_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'F'.
              lv_fifo_allocated = lv_fifo_allocated + <ls_run>-allocated.
              lv_fifo_shortage = lv_fifo_shortage + <ls_run>-shortage.
              lv_fifo_requested = lv_fifo_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'N'.
              lv_full_only_allocated = lv_full_only_allocated
                + <ls_run>-allocated.
              lv_full_only_shortage = lv_full_only_shortage
                + <ls_run>-shortage.
              lv_full_only_requested = lv_full_only_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'S'.
              lv_smallest_allocated = lv_smallest_allocated
                + <ls_run>-allocated.
              lv_smallest_shortage = lv_smallest_shortage
                + <ls_run>-shortage.
              lv_smallest_requested = lv_smallest_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'L'.
              lv_largest_allocated = lv_largest_allocated
                + <ls_run>-allocated.
              lv_largest_shortage = lv_largest_shortage
                + <ls_run>-shortage.
              lv_largest_requested = lv_largest_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN 'B'.
              lv_best_allocated = lv_best_allocated
                + <ls_run>-allocated.
              lv_best_shortage = lv_best_shortage
                + <ls_run>-shortage.
              lv_best_requested = lv_best_requested
                + <ls_run>-allocated + <ls_run>-shortage.
            WHEN OTHERS.
              lv_legacy_allocated = lv_legacy_allocated
                + <ls_run>-allocated.
              lv_legacy_shortage = lv_legacy_shortage
                + <ls_run>-shortage.
              lv_legacy_requested = lv_legacy_requested
                + <ls_run>-allocated + <ls_run>-shortage.
          ENDCASE.
        ENDIF.
        IF lv_priority_requested > 0.
          lv_priority_coverage = lv_priority_allocated * 100
            / lv_priority_requested.
        ENDIF.
        IF lv_fifo_requested > 0.
          lv_fifo_coverage = lv_fifo_allocated * 100
            / lv_fifo_requested.
        ENDIF.
        IF lv_full_only_requested > 0.
          lv_full_only_coverage = lv_full_only_allocated * 100
            / lv_full_only_requested.
        ENDIF.
        IF lv_smallest_requested > 0.
          lv_smallest_coverage = lv_smallest_allocated * 100
            / lv_smallest_requested.
        ENDIF.
        IF lv_largest_requested > 0.
          lv_largest_coverage = lv_largest_allocated * 100
            / lv_largest_requested.
        ENDIF.
        IF lv_best_requested > 0.
          lv_best_coverage = lv_best_allocated * 100
            / lv_best_requested.
        ENDIF.
        IF lv_legacy_requested > 0.
          lv_legacy_coverage = lv_legacy_allocated * 100
            / lv_legacy_requested.
        ENDIF.
        lv_full_count = lv_full_count + <ls_run>-full_count.
    lv_partial_count = lv_partial_count + <ls_run>-partial_count.
    lv_unallocated_count = lv_unallocated_count + <ls_run>-unallocated_count.
    IF lv_mixed_units = abap_false.
      lv_available_total = lv_available_total + <ls_run>-available.
      lv_requested_total = lv_requested_total + <ls_run>-allocated
        + <ls_run>-shortage.
      lv_allocated_total = lv_allocated_total + <ls_run>-allocated.
      lv_shortage_total = lv_shortage_total + <ls_run>-shortage.
    ENDIF.
  ENDLOOP.

  CLEAR lv_summary_strategy.
  IF lv_priority_runs > 0.
    lv_summary_strategy = 'P'.
  ENDIF.
  IF lv_fifo_runs > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'F'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_full_only_runs > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'N'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_smallest_runs > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'S'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_largest_runs > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'L'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_best_runs > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'B'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_legacy_strategy_runs > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'legacy'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_summary_strategy IS INITIAL.
    lv_summary_strategy = 'n/a'.
  ENDIF.

  WRITE: / 'Strategy context:', lv_summary_strategy,
           'Filtered runs:', lines( lt_runs ),
           'Total matching runs:', lv_total_rows,
           'Running:', lv_running_runs,
           'Success:', lv_success_runs,
           'Partial:', lv_partial_runs,
           'Errors:', lv_error_runs,
           'Completion:', lv_completion_pct, '%',
           'Success rate:', lv_success_rate_pct, '%',
           'Partial rate:', lv_partial_rate_pct, '%',
           'Error rate:', lv_error_rate_pct, '%'.
  WRITE: / 'Strategy runs - priority:', lv_priority_runs,
           'FIFO:', lv_fifo_runs,
           'full-only:', lv_full_only_runs,
           'smallest:', lv_smallest_runs,
           'largest:', lv_largest_runs,
           'best-fit:', lv_best_runs,
           'legacy:', lv_legacy_strategy_runs.
  IF p_max > 0.
    WRITE: / 'Page:', lv_page_number, 'of', lv_page_count.
    WRITE: / 'Last page offset:', lv_last_offset.
  ENDIF.
  WRITE: / 'Demand outcomes - full:', lv_full_count,
           'partial:', lv_partial_count,
           'unallocated:', lv_unallocated_count.
  IF lv_mixed_units = abap_true.
    WRITE: / 'Quantity totals omitted: mixed allocation units.',
           / 'Allocation shortage: n/a (mixed allocation units).'.
  ELSE.
    WRITE: / 'Priority totals (', lv_summary_unit, '): requested',
             lv_priority_requested, 'allocated', lv_priority_allocated,
             'shortage', lv_priority_shortage, 'coverage',
             lv_priority_coverage, '%',
           / 'FIFO totals (', lv_summary_unit, '): requested',
             lv_fifo_requested, 'allocated', lv_fifo_allocated,
             'shortage', lv_fifo_shortage, 'coverage',
             lv_fifo_coverage, '%',
           / 'Full-only totals (', lv_summary_unit, '): requested',
             lv_full_only_requested, 'allocated', lv_full_only_allocated,
             'shortage', lv_full_only_shortage, 'coverage',
             lv_full_only_coverage, '%',
           / 'Smallest totals (', lv_summary_unit, '): requested',
             lv_smallest_requested, 'allocated', lv_smallest_allocated,
             'shortage', lv_smallest_shortage, 'coverage',
             lv_smallest_coverage, '%',
           / 'Largest totals (', lv_summary_unit, '): requested',
             lv_largest_requested, 'allocated', lv_largest_allocated,
             'shortage', lv_largest_shortage, 'coverage',
             lv_largest_coverage, '%',
           / 'Best-fit totals (', lv_summary_unit, '): requested',
             lv_best_requested, 'allocated', lv_best_allocated,
             'shortage', lv_best_shortage, 'coverage',
             lv_best_coverage, '%',
           / 'Legacy totals (', lv_summary_unit, '): requested',
             lv_legacy_requested, 'allocated', lv_legacy_allocated,
             'shortage', lv_legacy_shortage, 'coverage',
             lv_legacy_coverage, '%'.
  WRITE: / 'Quantity totals (', lv_summary_unit, ') available:',
             lv_available_total,
           / 'Allocated:', lv_allocated_total,
             'Shortage:', lv_shortage_total.
  WRITE: / 'Average duration seconds:', lv_average_duration_text,
         / 'Minimum duration seconds:', lv_minimum_duration_text,
         / 'Maximum duration seconds:', lv_maximum_duration_text,
         / 'Completed duration runs:', lv_duration_count,
         / 'Oldest running age seconds:', lv_oldest_running_age_text,
         / 'Oldest running run ID:', lv_oldest_running_run_id_text,
         / 'Newest running age seconds:', lv_newest_running_age_text,
         / 'Newest running run ID:', lv_newest_running_run_id_text.
    IF lv_requested_total > 0.
      lv_coverage = lv_allocated_total * 100 / lv_requested_total.
      lv_shortage_pct = lv_shortage_total * 100 / lv_requested_total.
      WRITE: / 'Allocation coverage:', lv_coverage, '%',
             / 'Allocation shortage:', lv_shortage_pct, '%'.
    ELSE.
      WRITE: / 'Allocation coverage: n/a (no requested quantity).',
             / 'Allocation shortage: n/a (no requested quantity).'.
    ENDIF.
  ENDIF.

  IF p_sum = abap_true.
    WRITE: / 'Summary-only mode: detail rows suppressed.'.
    RETURN.
  ENDIF.

  WRITE: / 'Run ID', 34 'Status', 42 'Strategy', 52 'Unit',
           60 'Requested from', 80 'Requested through', 100 'Available',
           114 'Allocated', 128 'Shortage', 142 'Coverage', 154 'Shortage %',
           168 'Demand', 176 'Full', 184 'Partial', 194 'Unalloc.', 206 'Started',
           226 'Finished', 246 'Duration seconds', 266 'Running age'.
  LOOP AT lt_runs ASSIGNING <ls_run>.
    CLEAR: lv_run_coverage,
           lv_run_coverage_text,
           lv_run_shortage_pct,
           lv_duration_seconds,
           lv_duration_text,
           lv_running_age_seconds,
           lv_running_age_text.
    IF <ls_run>-allocated + <ls_run>-shortage > 0.
      lv_run_coverage = <ls_run>-allocated * 100
        / ( <ls_run>-allocated + <ls_run>-shortage ).
      lv_run_coverage_text = lv_run_coverage.
      lv_run_shortage_pct = <ls_run>-shortage * 100
        / ( <ls_run>-allocated + <ls_run>-shortage ).
    ELSE.
      CLEAR lv_run_shortage_pct.
      lv_run_coverage_text = 'n/a'.
    ENDIF.
    IF <ls_run>-finish_date IS INITIAL.
      lv_duration_text = 'n/a'.
     ELSE.
       cl_abap_tstmp=>td_subtract(
        EXPORTING
          date1    = <ls_run>-finish_date
          time1    = <ls_run>-finish_time
          date2    = <ls_run>-start_date
          time2    = <ls_run>-start_time
        IMPORTING
          res_secs = lv_duration_seconds ).
       lv_duration_text = lv_duration_seconds.
     ENDIF.
     IF <ls_run>-status = 'R'.
       ls_running_age = lo_audit->get_running_age( <ls_run> ).
       IF ls_running_age-available = abap_true.
         lv_running_age_seconds = ls_running_age-seconds.
         lv_running_age_text = lv_running_age_seconds.
       ELSE.
         lv_running_age_text = 'n/a'.
       ENDIF.
     ELSE.
       lv_running_age_text = 'n/a'.
     ENDIF.
     IF <ls_run>-strategy IS INITIAL.
       lv_display_strategy = 'LEGACY'.
     ELSE.
       lv_display_strategy = <ls_run>-strategy.
     ENDIF.
     WRITE: / <ls_run>-run_id,
              34 <ls_run>-status,
              42 lv_display_strategy,
             52 <ls_run>-unit,
             60 <ls_run>-requested_on_from,
             80 <ls_run>-requested_on_to,
             100 <ls_run>-available,
             114 <ls_run>-allocated,
             128 <ls_run>-shortage,
             142 lv_run_coverage_text,
             154 lv_run_shortage_pct,
             168 <ls_run>-demand_count,
             176 <ls_run>-full_count,
             184 <ls_run>-partial_count,
             194 <ls_run>-unallocated_count,
             206 <ls_run>-start_date,
             <ls_run>-start_time,
             226 <ls_run>-finish_date,
             <ls_run>-finish_time,
             246 lv_duration_text,
             266 lv_running_age_text.
    WRITE: / 'Message:', <ls_run>-message.
  ENDLOOP.
