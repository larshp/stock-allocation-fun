REPORT zstock_alloc_watch.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_safon AS CHECKBOX.
PARAMETERS p_saf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_safto TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_ffrom TYPE d.
PARAMETERS p_fto TYPE d.
PARAMETERS p_ovrd AS CHECKBOX.
PARAMETERS p_odate TYPE d.
PARAMETERS p_dead AS CHECKBOX.
PARAMETERS p_deadf TYPE d.
PARAMETERS p_deadt TYPE d.
PARAMETERS p_dagef TYPE i.
PARAMETERS p_daget TYPE i.
PARAMETERS p_daged TYPE d.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_prev TYPE zif_allocation_audit=>ty_preview_filter.
PARAMETERS p_legacy AS CHECKBOX.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_runq TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_spf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_dfrom TYPE i.
PARAMETERS p_dto TYPE i.
PARAMETERS p_avf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_stale TYPE i DEFAULT 3600.
PARAMETERS p_age_to TYPE i.
PARAMETERS p_max TYPE i.
PARAMETERS p_skip TYPE i.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_cov AS CHECKBOX.
PARAMETERS p_spct AS CHECKBOX.
PARAMETERS p_dcnt AS CHECKBOX.
PARAMETERS p_dage AS CHECKBOX.
PARAMETERS p_due AS CHECKBOX.
PARAMETERS p_new AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.
PARAMETERS p_ndjson AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  DATA lv_total_rows TYPE i.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_items TYPE string.
  DATA lv_item TYPE string.
  DATA lv_field TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_run_age TYPE zif_allocation_audit=>ty_running_age.
  DATA lv_json_header TYPE string.
  DATA lv_json_threshold TYPE string.
  DATA lv_json_count TYPE string.
  DATA lv_json_runs TYPE string.
  DATA lv_json_ndjson_prefix TYPE string.
  DATA lv_strategy_filter TYPE string.
  DATA lv_preview_filter TYPE string.
  DATA lv_legacy_filter_text TYPE string.
  DATA lv_run_filter TYPE string.
  DATA lv_run_contains_filter TYPE string.
  DATA lv_message_filter TYPE string.
  DATA lv_message_only_text TYPE string.
  DATA lv_overdue_only_text TYPE string.
  DATA lv_overdue_as_of_filter TYPE c LENGTH 10.
  DATA lv_deadline_reference_date TYPE d.
  DATA lv_deadline_only_text TYPE string.
  DATA lv_movement_filter TYPE string.
  DATA lv_min_shelf_filter TYPE string.
  DATA lv_safety_stock_filter_text TYPE string.
  DATA lv_safety_stock_from_filter TYPE string.
  DATA lv_safety_stock_to_filter TYPE string.
  DATA lv_requested_from_filter TYPE c LENGTH 10.
  DATA lv_requested_to_filter TYPE c LENGTH 10.
  DATA lv_start_date_from_filter TYPE c LENGTH 10.
  DATA lv_start_date_to_filter TYPE c LENGTH 10.
  DATA lv_finish_date_from_filter TYPE c LENGTH 10.
  DATA lv_finish_date_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_from_filter TYPE c LENGTH 10.
  DATA lv_deadline_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_age_from_filter TYPE string.
  DATA lv_deadline_age_to_filter TYPE string.
  DATA lv_deadline_age_date_filter TYPE c LENGTH 10.
  DATA lv_shortage_filter TYPE string.
  DATA lv_max_shortage_filter TYPE string.
  DATA lv_min_shortage_pct_filter TYPE string.
  DATA lv_max_shortage_pct_filter TYPE string.
  DATA lv_min_demand_filter TYPE string.
  DATA lv_max_demand_filter TYPE string.
  DATA lv_min_available_filter TYPE string.
  DATA lv_max_available_filter TYPE string.
  DATA lv_min_requested_filter TYPE string.
  DATA lv_max_requested_filter TYPE string.
  DATA lv_min_allocated_filter TYPE string.
  DATA lv_max_allocated_filter TYPE string.
  DATA lv_min_coverage_filter TYPE string.
  DATA lv_coverage_filter TYPE string.
  DATA lv_max_age_filter TYPE string.
  DATA lv_run_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_run_coverage_available TYPE abap_bool.
  DATA lv_run_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_run_shortage_pct_available TYPE abap_bool.
  DATA lv_sort_mode TYPE string.
  DATA lv_total_available TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_total_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_weighted_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_weighted_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_weighted_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_weighted_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_summary_unit TYPE string.
  DATA lv_safety_stock TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_safety_stock_text TYPE string.
  DATA lv_safety_stock_available TYPE abap_bool.
  DATA lv_safety_stock_mixed TYPE abap_bool.
  DATA lv_mixed_units TYPE abap_bool.
  DATA lv_mixed_units_text TYPE string.
  DATA lv_oldest_age TYPE i.
  DATA lv_newest_age TYPE i.
  DATA lv_earliest_deadline_text TYPE string.
  DATA lv_latest_deadline_text TYPE string.
  DATA lv_oldest_deadline_age_text TYPE string.
  DATA lv_newest_deadline_age_text TYPE string.
  DATA lv_deadline_count TYPE i.
  DATA lv_deadline_age_days TYPE i.
  DATA lv_alert_deadline_age_text TYPE string.
  DATA lv_deadline_age_mixed TYPE abap_bool.
  DATA lv_deadline_age_mixed_text TYPE string.
  DATA lv_total_coverage_text TYPE string.
  DATA lv_total_shortage_pct_text TYPE string.
  DATA lv_total_available_text TYPE string.
  DATA lv_total_requested_text TYPE string.
  DATA lv_total_allocated_text TYPE string.
  DATA lv_total_shortage_text TYPE string.
  DATA lv_weighted_requested_text TYPE string.
  DATA lv_weighted_allocated_text TYPE string.
  DATA lv_weighted_shortage_text TYPE string.
  DATA lv_weighted_coverage_text TYPE string.
  DATA ls_unit_summary TYPE zcl_stock_allocation_watch=>ty_unit_summary.
  DATA lv_oldest_age_text TYPE string.
  DATA lv_newest_age_text TYPE string.
  DATA lv_candidate_count TYPE i.
  DATA lv_limited TYPE abap_bool.
  DATA lv_limited_text TYPE string.
  DATA lv_has_more TYPE abap_bool.
  DATA lv_has_more_text TYPE string.
  DATA lv_next_offset TYPE i.
  DATA lv_next_offset_text TYPE string.
  DATA lv_has_previous TYPE abap_bool.
  DATA lv_has_previous_text TYPE string.
  DATA lv_previous_offset TYPE i.
  DATA lv_previous_offset_text TYPE string.
  DATA lv_page_number TYPE i.
  DATA lv_page_number_text TYPE string.
  DATA lv_page_count TYPE i.
  DATA lv_page_count_text TYPE string.
  DATA lv_last_offset TYPE i.
  DATA lv_last_offset_text TYPE string.
  DATA lv_filters_applied TYPE abap_bool.
  DATA lt_filter_names TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_filter_names_text TYPE string.
  DATA lv_rank TYPE i.
  DATA lv_alert_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_alert_coverage_text TYPE string.
  DATA lv_alert_shortage_pct_text TYPE string.
  DATA lv_adaptive_branch TYPE c LENGTH 10.
  DATA lv_adaptive_priority_runs TYPE i.
  DATA lv_adaptive_fair_runs TYPE i.
  DATA lv_weighted_strategy_runs TYPE i.
  DATA lt_filter_value_fields TYPE zcl_stock_json=>tt_strings.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

  DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.
  FIELD-SYMBOLS <ls_alert> TYPE zcl_stock_allocation_watch=>ty_alert.

  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_strat TO UPPER CASE.
  TRANSLATE p_prev TO UPPER CASE.
  TRANSLATE p_meins TO UPPER CASE.
  lv_strategy_filter = p_strat.
  IF lv_strategy_filter IS INITIAL.
    lv_strategy_filter = 'n/a'.
  ENDIF.
  lv_preview_filter = p_prev.
  IF lv_preview_filter IS INITIAL.
    lv_preview_filter = 'n/a'.
  ENDIF.
  IF p_legacy = abap_true.
    lv_legacy_filter_text = 'true'.
  ELSE.
    lv_legacy_filter_text = 'false'.
  ENDIF.
  lv_run_filter = p_runid.
  IF lv_run_filter IS INITIAL.
    lv_run_filter = 'n/a'.
  ENDIF.
  lv_run_contains_filter = p_runq.
  IF lv_run_contains_filter IS INITIAL.
    lv_run_contains_filter = 'n/a'.
  ENDIF.
  lv_message_filter = p_msg.
  IF lv_message_filter IS INITIAL.
    lv_message_filter = 'n/a'.
  ENDIF.
  IF p_monly = abap_true.
    lv_message_only_text = 'true'.
  ELSE.
    lv_message_only_text = 'false'.
  ENDIF.
  IF p_ovrd = abap_true.
    lv_overdue_only_text = 'true'.
  ELSE.
    lv_overdue_only_text = 'false'.
  ENDIF.
  IF p_odate IS INITIAL.
    lv_overdue_as_of_filter = 'n/a'.
    lv_deadline_reference_date = sy-datum.
  ELSE.
    lv_overdue_as_of_filter = p_odate.
    lv_deadline_reference_date = p_odate.
  ENDIF.
  IF p_dead = abap_true.
    lv_deadline_only_text = 'true'.
  ELSE.
    lv_deadline_only_text = 'false'.
  ENDIF.
  lv_movement_filter = p_mvt.
  IF lv_movement_filter IS INITIAL.
    lv_movement_filter = 'n/a'.
  ENDIF.
  IF p_shelf IS INITIAL.
    lv_min_shelf_filter = 'n/a'.
  ELSE.
    lv_min_shelf_filter = zcl_stock_csv=>number( p_shelf ).
  ENDIF.
  IF p_safon = abap_true.
    lv_safety_stock_filter_text = 'true'.
    lv_safety_stock_from_filter = zcl_stock_csv=>number( p_saf ).
    lv_safety_stock_to_filter = zcl_stock_csv=>number( p_safto ).
  ELSE.
    lv_safety_stock_filter_text = 'false'.
    lv_safety_stock_from_filter = 'n/a'.
    lv_safety_stock_to_filter = 'n/a'.
  ENDIF.
  IF p_reqf IS INITIAL.
    lv_requested_from_filter = 'n/a'.
  ELSE.
    lv_requested_from_filter = p_reqf.
  ENDIF.
  IF p_until IS INITIAL.
    lv_requested_to_filter = 'n/a'.
  ELSE.
    lv_requested_to_filter = p_until.
  ENDIF.
  IF p_from IS INITIAL.
    lv_start_date_from_filter = 'n/a'.
  ELSE.
    lv_start_date_from_filter = p_from.
  ENDIF.
  IF p_to IS INITIAL.
    lv_start_date_to_filter = 'n/a'.
  ELSE.
    lv_start_date_to_filter = p_to.
  ENDIF.
  IF p_ffrom IS INITIAL.
    lv_finish_date_from_filter = 'n/a'.
  ELSE.
    lv_finish_date_from_filter = p_ffrom.
  ENDIF.
  IF p_fto IS INITIAL.
    lv_finish_date_to_filter = 'n/a'.
  ELSE.
    lv_finish_date_to_filter = p_fto.
  ENDIF.
  IF p_deadf IS INITIAL.
    lv_deadline_from_filter = 'n/a'.
  ELSE.
    lv_deadline_from_filter = p_deadf.
  ENDIF.
  IF p_deadt IS INITIAL.
    lv_deadline_to_filter = 'n/a'.
  ELSE.
    lv_deadline_to_filter = p_deadt.
  ENDIF.
  IF p_dagef IS INITIAL.
    lv_deadline_age_from_filter = 'n/a'.
  ELSE.
    lv_deadline_age_from_filter = zcl_stock_csv=>number( p_dagef ).
  ENDIF.
  IF p_daget IS INITIAL.
    lv_deadline_age_to_filter = 'n/a'.
  ELSE.
    lv_deadline_age_to_filter = zcl_stock_csv=>number( p_daget ).
  ENDIF.
  IF p_daged IS INITIAL.
    lv_deadline_age_date_filter = 'n/a'.
  ELSE.
    lv_deadline_age_date_filter = p_daged.
    lv_deadline_reference_date = p_daged.
  ENDIF.
  IF p_shf IS INITIAL.
    lv_shortage_filter = 'n/a'.
  ELSE.
    lv_shortage_filter = zcl_stock_csv=>number( p_shf ).
  ENDIF.
  IF p_sht IS INITIAL.
    lv_max_shortage_filter = 'n/a'.
  ELSE.
    lv_max_shortage_filter = zcl_stock_csv=>number( p_sht ).
  ENDIF.
  IF p_spf IS INITIAL.
    lv_min_shortage_pct_filter = 'n/a'.
  ELSE.
    lv_min_shortage_pct_filter = zcl_stock_csv=>number( p_spf ).
  ENDIF.
  IF p_spt IS INITIAL.
    lv_max_shortage_pct_filter = 'n/a'.
  ELSE.
    lv_max_shortage_pct_filter = zcl_stock_csv=>number( p_spt ).
  ENDIF.
  IF p_dfrom IS INITIAL.
    lv_min_demand_filter = 'n/a'.
  ELSE.
    lv_min_demand_filter = zcl_stock_csv=>number( p_dfrom ).
  ENDIF.
  IF p_dto IS INITIAL.
    lv_max_demand_filter = 'n/a'.
  ELSE.
    lv_max_demand_filter = zcl_stock_csv=>number( p_dto ).
  ENDIF.
  IF p_avf IS INITIAL.
    lv_min_available_filter = 'n/a'.
  ELSE.
    lv_min_available_filter = zcl_stock_csv=>number( p_avf ).
  ENDIF.
  IF p_avt IS INITIAL.
    lv_max_available_filter = 'n/a'.
  ELSE.
    lv_max_available_filter = zcl_stock_csv=>number( p_avt ).
  ENDIF.
  IF p_qf IS INITIAL.
    lv_min_requested_filter = 'n/a'.
  ELSE.
    lv_min_requested_filter = zcl_stock_csv=>number( p_qf ).
  ENDIF.
  IF p_qt IS INITIAL.
    lv_max_requested_filter = 'n/a'.
  ELSE.
    lv_max_requested_filter = zcl_stock_csv=>number( p_qt ).
  ENDIF.
  IF p_af IS INITIAL.
    lv_min_allocated_filter = 'n/a'.
  ELSE.
    lv_min_allocated_filter = zcl_stock_csv=>number( p_af ).
  ENDIF.
  IF p_at IS INITIAL.
    lv_max_allocated_filter = 'n/a'.
  ELSE.
    lv_max_allocated_filter = zcl_stock_csv=>number( p_at ).
  ENDIF.
  IF p_covf IS INITIAL.
    lv_min_coverage_filter = 'n/a'.
  ELSE.
    lv_min_coverage_filter = zcl_stock_csv=>number( p_covf ).
  ENDIF.
  IF p_covt IS INITIAL.
    lv_coverage_filter = 'n/a'.
  ELSE.
    lv_coverage_filter = zcl_stock_csv=>number( p_covt ).
  ENDIF.
  IF p_age_to IS INITIAL.
    lv_max_age_filter = 'n/a'.
  ELSE.
    lv_max_age_filter = zcl_stock_csv=>number( p_age_to ).
  ENDIF.
  IF p_cov = abap_true.
    lv_sort_mode = 'coverage'.
  ELSEIF p_spct = abap_true.
    lv_sort_mode = 'shortage_percentage'.
  ELSEIF p_dcnt = abap_true.
    lv_sort_mode = 'demand_count'.
  ELSEIF p_dage = abap_true.
    lv_sort_mode = 'deadline_age'.
  ELSEIF p_due = abap_true.
    lv_sort_mode = 'requested_date'.
  ELSEIF p_shrt = abap_true.
    lv_sort_mode = 'shortage'.
  ELSEIF p_new = abap_true.
    lv_sort_mode = 'newest'.
  ELSE.
    lv_sort_mode = 'age'.
  ENDIF.
  IF p_csv = abap_true AND p_json = abap_true.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'Select only one export mode: CSV or JSON'
        iv_schema  = 62 ).
    ELSE.
      WRITE: / 'Select only one export mode: CSV or JSON.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_watch'
        iv_schema  = 59
        iv_message = 'Typed output requires JSON mode' ).
    ELSE.
      WRITE: / 'Typed output requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_watch'
        iv_schema  = 59
        iv_message = 'NDJSON output requires JSON mode' ).
    ELSE.
      WRITE: / 'NDJSON output requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_sum = abap_true.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_watch'
        iv_schema  = 59
        iv_message = 'NDJSON output cannot be combined with summary mode' ).
    ELSEIF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'NDJSON output cannot be combined with summary mode'
        iv_schema  = 62 ).
    ELSE.
      WRITE: / 'NDJSON output cannot be combined with summary mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_stale < 0.
    lv_error_message = 'Stale-running threshold must not be negative'.
  ELSEIF p_age_to < 0.
    lv_error_message = 'Maximum age must not be negative'.
  ELSEIF p_age_to IS NOT INITIAL AND p_age_to < p_stale.
    lv_error_message = 'Maximum age must not be below stale threshold'.
  ELSEIF p_max < 0.
    lv_error_message = 'Maximum rows must not be negative'.
  ELSEIF p_skip < 0.
    lv_error_message = 'Offset must not be negative'.
  ELSEIF p_shf < 0.
    lv_error_message = 'Minimum shortage must not be negative'.
  ELSEIF p_shelf < 0.
    lv_error_message = 'Minimum shelf-life filter must not be negative'.
  ELSEIF p_safon = abap_true
      AND ( p_saf < 0 OR p_safto < 0 OR p_saf > p_safto ).
    lv_error_message =
      'Safety-stock bounds require a valid nonnegative range'.
  ELSEIF p_safon = abap_false
      AND ( p_saf IS NOT INITIAL OR p_safto IS NOT INITIAL ).
    lv_error_message =
      'Safety-stock bounds require the filter switch'.
  ELSEIF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL
      AND p_reqf > p_until.
    lv_error_message =
      'Requested horizon start must not be after end date'.
  ELSEIF p_from IS NOT INITIAL AND p_to IS NOT INITIAL
      AND p_from > p_to.
    lv_error_message =
      'Audit start-date lower bound must not be after upper bound'.
  ELSEIF p_ffrom IS NOT INITIAL AND p_fto IS NOT INITIAL
      AND p_ffrom > p_fto.
    lv_error_message =
      'Audit finish-date lower bound must not be after upper bound'.
  ELSEIF p_deadf IS NOT INITIAL AND p_deadt IS NOT INITIAL
      AND p_deadf > p_deadt.
    lv_error_message =
      'Requested deadline start must not be after end date'.
  ELSEIF p_dagef IS NOT INITIAL AND p_daget IS NOT INITIAL
      AND p_dagef > p_daget.
    lv_error_message =
      'Deadline age start must not be after end value'.
  ELSEIF p_daged IS NOT INITIAL
      AND p_dagef IS INITIAL AND p_daget IS INITIAL.
    lv_error_message = 'Deadline age date requires an age range'.
  ELSEIF p_odate IS NOT INITIAL AND p_ovrd = abap_false.
    lv_error_message =
      'Overdue as-of date requires overdue-only filtering'.
  ELSEIF p_sht < 0.
    lv_error_message = 'Maximum shortage must not be negative'.
  ELSEIF p_shf IS NOT INITIAL AND p_sht IS NOT INITIAL
      AND p_shf > p_sht.
    lv_error_message = 'Minimum shortage must not exceed maximum shortage'.
  ELSEIF p_spt < 0 OR p_spt > 100.
    lv_error_message = 'Maximum shortage percentage must be between 0 and 100'.
  ELSEIF p_spf < 0 OR p_spf > 100.
    lv_error_message = 'Minimum shortage percentage must be between 0 and 100'.
  ELSEIF p_spf IS NOT INITIAL AND p_spt IS NOT INITIAL
      AND p_spf > p_spt.
    lv_error_message = 'Minimum shortage percentage must not exceed maximum'.
  ELSEIF p_dfrom < 0 OR p_dto < 0.
    lv_error_message = 'Demand-count bounds must not be negative'.
  ELSEIF p_dfrom IS NOT INITIAL AND p_dto IS NOT INITIAL
      AND p_dfrom > p_dto.
    lv_error_message = 'Minimum demand count must not exceed maximum'.
  ELSEIF p_avf < 0 OR p_avt < 0.
    lv_error_message = 'Available-stock bounds must not be negative'.
  ELSEIF p_avf IS NOT INITIAL AND p_avt IS NOT INITIAL
      AND p_avf > p_avt.
    lv_error_message = 'Minimum available stock must not exceed maximum'.
  ELSEIF p_qf < 0 OR p_qt < 0.
    lv_error_message = 'Requested-quantity bounds must not be negative'.
  ELSEIF p_qf IS NOT INITIAL AND p_qt IS NOT INITIAL
      AND p_qf > p_qt.
    lv_error_message = 'Minimum requested quantity must not exceed maximum'.
  ELSEIF p_af < 0 OR p_at < 0.
    lv_error_message = 'Allocated-quantity bounds must not be negative'.
  ELSEIF p_af IS NOT INITIAL AND p_at IS NOT INITIAL
      AND p_af > p_at.
    lv_error_message = 'Minimum allocated quantity must not exceed maximum'.
  ELSEIF p_covt < 0 OR p_covt > 100.
    lv_error_message = 'Maximum coverage must be between 0 and 100'.
  ELSEIF p_covf < 0 OR p_covf > 100.
    lv_error_message = 'Minimum coverage must be between 0 and 100'.
  ELSEIF p_covf IS NOT INITIAL
      AND p_covt IS NOT INITIAL
      AND p_covf > p_covt.
    lv_error_message = 'Minimum coverage must not exceed maximum coverage'.
  ELSEIF p_legacy = abap_true AND p_strat IS NOT INITIAL.
    lv_error_message = 'Legacy strategy cannot be combined with watch strategy'.
  ELSEIF p_prev IS NOT INITIAL
      AND p_prev <> 'P'
      AND p_prev <> 'O'.
    lv_error_message = 'Watch preview filter is invalid'.
  ELSEIF p_strat IS NOT INITIAL
      AND p_strat <> 'P'
      AND p_strat <> 'F'
      AND p_strat <> 'N'
      AND p_strat <> 'S'
      AND p_strat <> 'L'
      AND p_strat <> 'B'
      AND p_strat <> 'E'
      AND p_strat <> 'A'
      AND p_strat <> 'W'.
    lv_error_message = 'Watch strategy is invalid'.
  ENDIF.
  IF lv_error_message IS NOT INITIAL.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error_message
        iv_schema  = 62 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_watch'
        iv_schema  = 59
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.

  CLEAR lt_filter_names.
  IF p_charg IS NOT INITIAL.
    APPEND 'batch' TO lt_filter_names.
  ENDIF.
  IF p_mvt IS NOT INITIAL.
    APPEND 'movement_type' TO lt_filter_names.
  ENDIF.
  IF p_shelf IS NOT INITIAL.
    APPEND 'minimum_shelf_life' TO lt_filter_names.
  ENDIF.
  IF p_safon = abap_true.
    APPEND 'safety_stock' TO lt_filter_names.
  ENDIF.
  IF p_reqf IS NOT INITIAL.
    APPEND 'requested_date_from' TO lt_filter_names.
  ENDIF.
  IF p_until IS NOT INITIAL.
    APPEND 'requested_date_to' TO lt_filter_names.
  ENDIF.
  IF p_from IS NOT INITIAL.
    APPEND 'start_date_from' TO lt_filter_names.
  ENDIF.
  IF p_to IS NOT INITIAL.
    APPEND 'start_date_to' TO lt_filter_names.
  ENDIF.
  IF p_ffrom IS NOT INITIAL.
    APPEND 'finish_date_from' TO lt_filter_names.
  ENDIF.
  IF p_fto IS NOT INITIAL.
    APPEND 'finish_date_to' TO lt_filter_names.
  ENDIF.
  IF p_meins IS NOT INITIAL.
    APPEND 'unit' TO lt_filter_names.
  ENDIF.
  IF p_strat IS NOT INITIAL.
    APPEND 'strategy' TO lt_filter_names.
  ENDIF.
  IF p_prev IS NOT INITIAL.
    APPEND 'preview' TO lt_filter_names.
  ENDIF.
  IF p_legacy = abap_true.
    APPEND 'legacy_strategy' TO lt_filter_names.
  ENDIF.
  IF p_runid IS NOT INITIAL.
    APPEND 'run_id' TO lt_filter_names.
  ENDIF.
  IF p_runq IS NOT INITIAL.
    APPEND 'run_id_contains' TO lt_filter_names.
  ENDIF.
  IF p_msg IS NOT INITIAL.
    APPEND 'message' TO lt_filter_names.
  ENDIF.
  IF p_monly = abap_true.
    APPEND 'message_only' TO lt_filter_names.
  ENDIF.
  IF p_ovrd = abap_true.
    APPEND 'requested_overdue_only' TO lt_filter_names.
  ENDIF.
  IF p_odate IS NOT INITIAL.
    APPEND 'requested_overdue_as_of' TO lt_filter_names.
  ENDIF.
  IF p_dead = abap_true.
    APPEND 'requested_deadline_only' TO lt_filter_names.
  ENDIF.
  IF p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL.
    APPEND 'requested_deadline_range' TO lt_filter_names.
  ENDIF.
  IF p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL
      OR p_daged IS NOT INITIAL.
    APPEND 'deadline_age_range' TO lt_filter_names.
  ENDIF.
  IF p_shf IS NOT INITIAL.
    APPEND 'minimum_shortage' TO lt_filter_names.
  ENDIF.
  IF p_sht IS NOT INITIAL.
    APPEND 'maximum_shortage' TO lt_filter_names.
  ENDIF.
  IF p_spf IS NOT INITIAL.
    APPEND 'minimum_shortage_pct' TO lt_filter_names.
  ENDIF.
  IF p_spt IS NOT INITIAL.
    APPEND 'maximum_shortage_pct' TO lt_filter_names.
  ENDIF.
  IF p_dfrom IS NOT INITIAL.
    APPEND 'minimum_demand_count' TO lt_filter_names.
  ENDIF.
  IF p_dto IS NOT INITIAL.
    APPEND 'maximum_demand_count' TO lt_filter_names.
  ENDIF.
  IF p_avf IS NOT INITIAL.
    APPEND 'minimum_available_stock' TO lt_filter_names.
  ENDIF.
  IF p_avt IS NOT INITIAL.
    APPEND 'maximum_available_stock' TO lt_filter_names.
  ENDIF.
  IF p_qf IS NOT INITIAL.
    APPEND 'minimum_requested_quantity' TO lt_filter_names.
  ENDIF.
  IF p_qt IS NOT INITIAL.
    APPEND 'maximum_requested_quantity' TO lt_filter_names.
  ENDIF.
  IF p_af IS NOT INITIAL.
    APPEND 'minimum_allocated_quantity' TO lt_filter_names.
  ENDIF.
  IF p_at IS NOT INITIAL.
    APPEND 'maximum_allocated_quantity' TO lt_filter_names.
  ENDIF.
  IF p_covf IS NOT INITIAL.
    APPEND 'minimum_coverage' TO lt_filter_names.
  ENDIF.
  IF p_covt IS NOT INITIAL.
    APPEND 'maximum_coverage' TO lt_filter_names.
  ENDIF.
  IF p_stale <> 3600.
    APPEND 'stale_threshold' TO lt_filter_names.
  ENDIF.
  IF p_age_to IS NOT INITIAL.
    APPEND 'maximum_age_seconds' TO lt_filter_names.
  ENDIF.
  IF p_skip IS NOT INITIAL.
    APPEND 'offset' TO lt_filter_names.
  ENDIF.
  IF p_max IS NOT INITIAL.
    APPEND 'max_rows' TO lt_filter_names.
  ENDIF.
  IF lines( lt_filter_names ) > 0.
    lv_filters_applied = abap_true.
    CONCATENATE LINES OF lt_filter_names INTO lv_filter_names_text
      SEPARATED BY '|'.
  ELSE.
    lv_filters_applied = abap_false.
    lv_filter_names_text = 'n/a'.
  ENDIF.

  IF p_typed = abap_true.
    CLEAR lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'preview_filter'
      iv_value = p_prev ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_shelf_life'
      iv_value   = p_shelf
      iv_text    = lv_min_shelf_filter
      iv_present = xsdbool( p_shelf IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'safety_stock_filter'
      iv_value = p_safon ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_safety_stock'
      iv_value   = p_saf
      iv_text    = lv_safety_stock_from_filter
      iv_present = p_safon
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_safety_stock'
      iv_value   = p_safto
      iv_text    = lv_safety_stock_to_filter
      iv_present = p_safon
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'start_date_from_filter'
      iv_value = lv_start_date_from_filter ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'start_date_to_filter'
      iv_value = lv_start_date_to_filter ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'finish_date_from_filter'
      iv_value = lv_finish_date_from_filter ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'finish_date_to_filter'
      iv_value = lv_finish_date_to_filter ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'requested_overdue_only'
      iv_value = p_ovrd ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_overdue_as_of'
      iv_value = lv_overdue_as_of_filter ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'requested_deadline_only'
      iv_value = p_dead ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_deadline_from'
      iv_value = p_deadf ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_deadline_to'
      iv_value = p_deadt ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_deadline_age_days'
      iv_value   = p_dagef
      iv_text    = lv_deadline_age_from_filter
      iv_present = xsdbool( p_dagef IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_deadline_age_days'
      iv_value   = p_daget
      iv_text    = lv_deadline_age_to_filter
      iv_present = xsdbool( p_daget IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_age_as_of'
      iv_value = lv_deadline_age_date_filter ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_demand_count'
      iv_value   = p_dfrom
      iv_text    = lv_min_demand_filter
      iv_present = xsdbool( p_dfrom IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_demand_count'
      iv_value   = p_dto
      iv_text    = lv_max_demand_filter
      iv_present = xsdbool( p_dto IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_available_stock'
      iv_value   = p_avf
      iv_text    = lv_min_available_filter
      iv_present = xsdbool( p_avf IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_available_stock'
      iv_value   = p_avt
      iv_text    = lv_max_available_filter
      iv_present = xsdbool( p_avt IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_requested_quantity'
      iv_value   = p_qf
      iv_text    = lv_min_requested_filter
      iv_present = xsdbool( p_qf IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_requested_quantity'
      iv_value   = p_qt
      iv_text    = lv_max_requested_filter
      iv_present = xsdbool( p_qt IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_allocated_quantity'
      iv_value   = p_af
      iv_text    = lv_min_allocated_filter
      iv_present = xsdbool( p_af IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_allocated_quantity'
      iv_value   = p_at
      iv_text    = lv_max_allocated_filter
      iv_present = xsdbool( p_at IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_shortage'
      iv_value   = p_shf
      iv_text    = lv_shortage_filter
      iv_present = xsdbool( p_shf IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_shortage'
      iv_value   = p_sht
      iv_text    = lv_max_shortage_filter
      iv_present = xsdbool( p_sht IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_shortage_pct'
      iv_value   = p_spf
      iv_text    = lv_min_shortage_pct_filter
      iv_present = xsdbool( p_spf IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_shortage_pct'
      iv_value   = p_spt
      iv_text    = lv_max_shortage_pct_filter
      iv_present = xsdbool( p_spt IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_coverage'
      iv_value   = p_covf
      iv_text    = lv_min_coverage_filter
      iv_present = xsdbool( p_covf IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_coverage'
      iv_value   = p_covt
      iv_text    = lv_coverage_filter
      iv_present = xsdbool( p_covt IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'stale_threshold_seconds'
      iv_value = p_stale ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_age_seconds'
      iv_value   = p_age_to
      iv_text    = lv_max_age_filter
      iv_present = xsdbool( p_age_to IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'offset'
      iv_value = p_skip ) TO lt_filter_value_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'max_rows'
      iv_value   = p_max
      iv_text    = 'n/a'
      iv_present = xsdbool( p_max IS NOT INITIAL )
      iv_typed   = abap_true ) TO lt_filter_value_fields.
  ENDIF.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
  TRY.
      lt_runs = lo_audit->get_runs(
        EXPORTING
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_movement_type     = p_mvt
          iv_min_shelf_life    = p_shelf
          iv_safety_filter     = p_safon
          iv_safety_from       = p_saf
          iv_safety_to         = p_safto
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until
          iv_start_date_from   = p_from
          iv_start_date_to     = p_to
          iv_finish_date_from  = p_ffrom
          iv_finish_date_to    = p_fto
          iv_requested_overdue = p_ovrd
          iv_overdue_date      = p_odate
          iv_deadline_only     = p_dead
          iv_deadline_from     = p_deadf
          iv_deadline_to       = p_deadt
          iv_deadline_age_from = p_dagef
          iv_deadline_age_to   = p_daget
          iv_deadline_age_date = p_daged
          iv_unit              = p_meins
          iv_strategy          = p_strat
          iv_preview_filter    = p_prev
          iv_legacy_strategy   = p_legacy
          iv_run_id            = p_runid
          iv_run_id_contains   = p_runq
          iv_message_contains  = p_msg
          iv_message_only      = p_monly
          iv_shortage_from     = p_shf
          iv_shortage_to       = p_sht
          iv_shortage_pct_from = p_spf
          iv_shortage_pct_to   = p_spt
          iv_demand_from       = p_dfrom
          iv_demand_to         = p_dto
          iv_available_from    = p_avf
          iv_available_to      = p_avt
          iv_requested_from    = p_qf
          iv_requested_to      = p_qt
          iv_allocated_from    = p_af
          iv_allocated_to      = p_at
          iv_status            = 'R'
        IMPORTING
          ev_total_rows        = lv_total_rows ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      lv_error_message = lo_error->message.
      IF lv_error_message IS INITIAL.
        lv_error_message = 'Audit run read failed'.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error_message
          iv_schema  = 62 ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / zcl_stock_csv=>error_with_schema(
          iv_mode    = 'zstock_alloc_watch'
          iv_schema  = 59
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  LOOP AT lt_runs ASSIGNING <ls_run>.
    lv_run_age = lo_audit->get_running_age( is_run = <ls_run> ).
    CLEAR lv_run_coverage.
    lv_run_coverage_available = abap_false.
    CLEAR lv_run_shortage_pct.
    lv_run_shortage_pct_available = abap_false.
    IF <ls_run>-requested > 0.
      lv_run_coverage = <ls_run>-allocated * 100 / <ls_run>-requested.
      lv_run_coverage_available = abap_true.
      lv_run_shortage_pct = <ls_run>-shortage * 100 / <ls_run>-requested.
      lv_run_shortage_pct_available = abap_true.
    ENDIF.
    IF lv_run_age-available = abap_true
        AND lv_run_age-seconds >= p_stale
        AND ( p_age_to IS INITIAL OR lv_run_age-seconds <= p_age_to )
        AND ( p_shf IS INITIAL OR <ls_run>-shortage >= p_shf )
        AND ( p_sht IS INITIAL OR <ls_run>-shortage <= p_sht )
        AND ( p_covf IS INITIAL
          OR ( <ls_run>-requested > 0 AND lv_run_coverage >= p_covf ) )
        AND ( p_covt IS INITIAL
          OR ( <ls_run>-requested > 0 AND lv_run_coverage <= p_covt ) ).
      CLEAR lv_deadline_age_days.
      IF <ls_run>-requested_deadline IS NOT INITIAL.
        lv_deadline_age_days = lv_deadline_reference_date
          - <ls_run>-requested_deadline.
      ENDIF.
      lv_adaptive_branch = 'n/a'.
      IF <ls_run>-strategy = 'A'.
        IF <ls_run>-available >= <ls_run>-requested.
          lv_adaptive_branch = 'priority'.
        ELSE.
          lv_adaptive_branch = 'fair-share'.
        ENDIF.
      ENDIF.
      APPEND VALUE #(
        run_id                 = <ls_run>-run_id
        strategy               = <ls_run>-strategy
        adaptive_branch        = lv_adaptive_branch
        movement_type          = <ls_run>-movement_type
        min_shelf_life         = <ls_run>-min_shelf_life
        safety_stock           = <ls_run>-safety_stock
        requested_on_from      = <ls_run>-requested_on_from
        requested_on_to        = <ls_run>-requested_on_to
        requested_deadline     = <ls_run>-requested_deadline
        deadline_age_days      = lv_deadline_age_days
        deadline_age_available = xsdbool(
          <ls_run>-requested_deadline IS NOT INITIAL )
        deadline_age_ref       = lv_deadline_reference_date
        horizon_available      = xsdbool(
          <ls_run>-requested_on_from IS NOT INITIAL
          OR <ls_run>-requested_on_to IS NOT INITIAL )
        unit                   = <ls_run>-unit
        start_date             = <ls_run>-start_date
        start_time             = <ls_run>-start_time
        age_seconds            = lv_run_age-seconds
        available              = <ls_run>-available
        requested              = <ls_run>-requested
        allocated              = <ls_run>-allocated
        shortage               = <ls_run>-shortage
        coverage               = lv_run_coverage
        coverage_available     = lv_run_coverage_available
        shortage_pct           = lv_run_shortage_pct
        shortage_pct_available = lv_run_shortage_pct_available
        demand_count           = <ls_run>-demand_count
        message                = <ls_run>-message ) TO lt_alerts.
    ENDIF.
  ENDLOOP.

  CLEAR: lv_safety_stock,
         lv_safety_stock_text,
         lv_safety_stock_available,
         lv_safety_stock_mixed.
  LOOP AT lt_alerts ASSIGNING <ls_alert>.
    IF lv_safety_stock_available = abap_false.
      lv_safety_stock = <ls_alert>-safety_stock.
      lv_safety_stock_available = abap_true.
    ELSEIF lv_safety_stock <> <ls_alert>-safety_stock.
      lv_safety_stock_mixed = abap_true.
    ENDIF.
  ENDLOOP.
  IF lv_safety_stock_available = abap_false.
    lv_safety_stock_text = 'n/a'.
  ELSEIF lv_safety_stock_mixed = abap_true.
    lv_safety_stock_text = 'mixed'.
  ELSE.
    lv_safety_stock_text = zcl_stock_csv=>number( lv_safety_stock ).
  ENDIF.

  lv_candidate_count = lines( lt_alerts ).

  zcl_stock_allocation_watch=>sort_and_limit(
    EXPORTING
      iv_sort_by_shortage     = p_shrt
      iv_sort_by_coverage     = p_cov
      iv_sort_by_shrt_pct     = p_spct
      iv_sort_by_demand_count = p_dcnt
      iv_sort_by_deadline_age = p_dage
      iv_sort_by_due          = p_due
      iv_sort_by_newest       = p_new
      iv_max                  = p_max
      iv_offset               = p_skip
    CHANGING
      ct_alerts               = lt_alerts ).

  IF lv_candidate_count > p_skip + lines( lt_alerts ).
    lv_has_more = abap_true.
    lv_has_more_text = 'true'.
  ELSE.
    lv_has_more = abap_false.
    lv_has_more_text = 'false'.
  ENDIF.
  IF lv_has_more = abap_true.
    lv_next_offset = p_skip + lines( lt_alerts ).
    lv_next_offset_text = zcl_stock_csv=>number( lv_next_offset ).
  ELSE.
    lv_next_offset = 0.
    lv_next_offset_text = 'n/a'.
  ENDIF.
  IF p_max > 0.
    lv_page_number = p_skip DIV p_max + 1.
    lv_page_number_text = zcl_stock_csv=>number( lv_page_number ).
    IF p_skip > 0.
      lv_has_previous = abap_true.
      lv_has_previous_text = 'true'.
      IF p_skip >= p_max.
        lv_previous_offset = p_skip - p_max.
      ELSE.
        lv_previous_offset = 0.
      ENDIF.
      lv_previous_offset_text = zcl_stock_csv=>number(
        lv_previous_offset ).
    ELSE.
      lv_has_previous = abap_false.
      lv_has_previous_text = 'false'.
      lv_previous_offset = 0.
      lv_previous_offset_text = 'n/a'.
    ENDIF.
  ELSE.
    lv_has_previous = abap_false.
    lv_has_previous_text = 'false'.
    lv_previous_offset = 0.
    lv_previous_offset_text = 'n/a'.
    lv_page_number = 0.
    lv_page_number_text = 'n/a'.
  ENDIF.
  IF p_max > 0.
    lv_page_count = ( lv_candidate_count + p_max - 1 ) DIV p_max.
    lv_page_count_text = zcl_stock_csv=>number( lv_page_count ).
    IF lv_page_count > 0.
      lv_last_offset = ( lv_page_count - 1 ) * p_max.
    ELSE.
      lv_last_offset = 0.
    ENDIF.
    lv_last_offset_text = zcl_stock_csv=>number( lv_last_offset ).
  ELSE.
    lv_page_count = 0.
    lv_page_count_text = 'n/a'.
    lv_last_offset = 0.
    lv_last_offset_text = 'n/a'.
  ENDIF.

  CLEAR: lv_adaptive_priority_runs,
         lv_adaptive_fair_runs.
  LOOP AT lt_alerts ASSIGNING <ls_alert>.
    CASE <ls_alert>-adaptive_branch.
      WHEN 'priority'.
        lv_adaptive_priority_runs = lv_adaptive_priority_runs + 1.
      WHEN 'fair-share'.
        lv_adaptive_fair_runs = lv_adaptive_fair_runs + 1.
    ENDCASE.
  ENDLOOP.
  IF p_skip > 0 OR lv_has_more = abap_true.
    lv_limited = abap_true.
    lv_limited_text = 'true'.
  ELSE.
    lv_limited = abap_false.
    lv_limited_text = 'false'.
  ENDIF.

  ls_unit_summary = zcl_stock_allocation_watch=>summarize_units( lt_alerts ).
  IF ls_unit_summary-deadline_age_reference_date IS NOT INITIAL.
    lv_deadline_reference_date =
      ls_unit_summary-deadline_age_reference_date.
  ENDIF.
  lv_total_available = ls_unit_summary-total_available.
  lv_total_requested = ls_unit_summary-total_requested.
  lv_total_allocated = ls_unit_summary-total_allocated.
  lv_total_shortage = ls_unit_summary-total_shortage.
  lv_oldest_age = ls_unit_summary-oldest_age_seconds.
  lv_newest_age = ls_unit_summary-newest_age_seconds.
  lv_deadline_count = ls_unit_summary-deadline_count.
  lv_deadline_age_mixed = ls_unit_summary-deadline_age_mixed.
  lv_weighted_strategy_runs = ls_unit_summary-weighted_strategy_runs.
  lv_weighted_requested = ls_unit_summary-weighted_requested.
  lv_weighted_allocated = ls_unit_summary-weighted_allocated.
  lv_weighted_shortage = ls_unit_summary-weighted_shortage.
  IF lv_deadline_age_mixed = abap_true.
    lv_deadline_age_mixed_text = 'true'.
  ELSE.
    lv_deadline_age_mixed_text = 'false'.
  ENDIF.
  IF ls_unit_summary-earliest_requested_deadline IS INITIAL.
    lv_earliest_deadline_text = 'n/a'.
  ELSE.
    lv_earliest_deadline_text = ls_unit_summary-earliest_requested_deadline.
  ENDIF.
  IF ls_unit_summary-latest_requested_deadline IS INITIAL.
    lv_latest_deadline_text = 'n/a'.
  ELSE.
    lv_latest_deadline_text = ls_unit_summary-latest_requested_deadline.
  ENDIF.
  IF lv_deadline_count = 0.
    lv_oldest_deadline_age_text = 'n/a'.
    lv_newest_deadline_age_text = 'n/a'.
  ELSE.
    lv_oldest_deadline_age_text = zcl_stock_csv=>number(
      ls_unit_summary-oldest_deadline_age_days ).
    lv_newest_deadline_age_text = zcl_stock_csv=>number(
      ls_unit_summary-newest_deadline_age_days ).
  ENDIF.
  DATA(lv_total_demand_count) = ls_unit_summary-demand_count.
  lv_summary_unit = ls_unit_summary-unit.
  lv_mixed_units = ls_unit_summary-mixed_units.
  IF lv_mixed_units = abap_true.
    lv_summary_unit = 'mixed'.
    lv_mixed_units_text = 'true'.
    lv_total_coverage_text = 'n/a'.
    lv_total_shortage_pct_text = 'n/a'.
  ELSE.
    lv_mixed_units_text = 'false'.
  ENDIF.
  IF lv_mixed_units = abap_false AND lv_total_requested > 0.
    lv_total_coverage = lv_total_allocated * 100 / lv_total_requested.
    lv_total_coverage_text = zcl_stock_csv=>number( lv_total_coverage ).
    lv_total_shortage_pct = lv_total_shortage * 100 / lv_total_requested.
    lv_total_shortage_pct_text = zcl_stock_csv=>number(
      lv_total_shortage_pct ).
  ELSEIF lv_mixed_units = abap_false.
    lv_total_coverage_text = 'n/a'.
    lv_total_shortage_pct_text = 'n/a'.
  ENDIF.
  IF lv_mixed_units = abap_true.
    lv_total_available_text = 'n/a'.
    lv_total_requested_text = 'n/a'.
    lv_total_allocated_text = 'n/a'.
    lv_total_shortage_text = 'n/a'.
  ELSE.
    lv_total_available_text = zcl_stock_csv=>number( lv_total_available ).
    lv_total_requested_text = zcl_stock_csv=>number( lv_total_requested ).
    lv_total_allocated_text = zcl_stock_csv=>number( lv_total_allocated ).
    lv_total_shortage_text = zcl_stock_csv=>number( lv_total_shortage ).
  ENDIF.
  IF lv_mixed_units = abap_true.
    lv_weighted_requested_text = 'n/a'.
    lv_weighted_allocated_text = 'n/a'.
    lv_weighted_shortage_text = 'n/a'.
    lv_weighted_coverage_text = 'n/a'.
  ELSE.
    lv_weighted_requested_text = zcl_stock_csv=>number(
      lv_weighted_requested ).
    lv_weighted_allocated_text = zcl_stock_csv=>number(
      lv_weighted_allocated ).
    lv_weighted_shortage_text = zcl_stock_csv=>number(
      lv_weighted_shortage ).
    IF lv_weighted_requested > 0.
      lv_weighted_coverage = lv_weighted_allocated * 100
        / lv_weighted_requested.
      lv_weighted_coverage_text = zcl_stock_csv=>number(
        lv_weighted_coverage ).
    ELSE.
      lv_weighted_coverage_text = 'n/a'.
    ENDIF.
  ENDIF.
  IF lines( lt_alerts ) > 0.
    lv_oldest_age_text = zcl_stock_csv=>number( lv_oldest_age ).
    lv_newest_age_text = zcl_stock_csv=>number( lv_newest_age ).
  ELSE.
    lv_oldest_age_text = 'n/a'.
    lv_newest_age_text = 'n/a'.
  ENDIF.
  IF p_csv = abap_true.
    IF p_sum = abap_true.
      WRITE: / 'schema_version;material;plant;storage_location;batch;requested_unit;'
        && 'filters_applied;filters;'
        && 'sort_mode;strategy_filter;preview_filter;movement_type_filter;minimum_shelf_life_filter;'
        && 'safety_stock_filter;minimum_safety_stock_filter;maximum_safety_stock_filter;'
        && 'requested_on_from_filter;requested_on_to_filter;'
        && 'start_date_from_filter;start_date_to_filter;'
        && 'finish_date_from_filter;finish_date_to_filter;'
        && 'requested_overdue_only;requested_overdue_as_of_filter;'
        && 'requested_deadline_only;requested_deadline_from;requested_deadline_to;'
        && 'deadline_age_from_filter;deadline_age_to_filter;deadline_age_date_filter;'
        && 'legacy_strategy_filter;'
        && 'run_id_filter;run_id_contains_filter;'
        && 'message_filter;message_only;offset;has_more;next_offset;has_previous;'
        && 'previous_offset;page_number;page_count;last_offset;'
        && 'minimum_demand_count;maximum_demand_count;minimum_available_stock;'
        && 'maximum_available_stock;minimum_shortage;maximum_shortage;'
        && 'minimum_shortage_pct;maximum_shortage_pct;minimum_coverage;'
        && 'maximum_coverage;minimum_requested_quantity;maximum_requested_quantity;'
        && 'minimum_allocated_quantity;maximum_allocated_quantity;'
        && 'stale_threshold_seconds;maximum_age_seconds;'
        && 'candidate_count;limited;alert_count;adaptive_priority_runs;'
        && 'adaptive_fair_runs;weighted_strategy_runs;weighted_requested;'
        && 'weighted_allocated;weighted_shortage;weighted_coverage_pct;'
        && 'demand_count;'
        && 'deadline_count;unit;'
        && 'safety_stock_context;mixed_units;available;requested;'
        && 'allocated;shortage;coverage_pct;shortage_pct;'
        && 'oldest_age_seconds;newest_age_seconds;earliest_requested_deadline;'
        && 'latest_requested_deadline;oldest_deadline_age_days;'
        && 'newest_deadline_age_days;deadline_age_reference_date;'
        && 'deadline_age_mixed'.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>number( 59 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_filter_names_text ) TO lt_csv_fields.
      APPEND lv_sort_mode TO lt_csv_fields.
      APPEND lv_strategy_filter TO lt_csv_fields.
      APPEND lv_preview_filter TO lt_csv_fields.
      APPEND lv_movement_filter TO lt_csv_fields.
      APPEND lv_min_shelf_filter TO lt_csv_fields.
      APPEND lv_safety_stock_filter_text TO lt_csv_fields.
      APPEND lv_safety_stock_from_filter TO lt_csv_fields.
      APPEND lv_safety_stock_to_filter TO lt_csv_fields.
      APPEND lv_requested_from_filter TO lt_csv_fields.
      APPEND lv_requested_to_filter TO lt_csv_fields.
      APPEND lv_start_date_from_filter TO lt_csv_fields.
      APPEND lv_start_date_to_filter TO lt_csv_fields.
      APPEND lv_finish_date_from_filter TO lt_csv_fields.
      APPEND lv_finish_date_to_filter TO lt_csv_fields.
      APPEND lv_overdue_only_text TO lt_csv_fields.
      APPEND lv_overdue_as_of_filter TO lt_csv_fields.
      APPEND lv_deadline_only_text TO lt_csv_fields.
      APPEND lv_deadline_from_filter TO lt_csv_fields.
      APPEND lv_deadline_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_from_filter TO lt_csv_fields.
      APPEND lv_deadline_age_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_date_filter TO lt_csv_fields.
      APPEND lv_legacy_filter_text TO lt_csv_fields.
      APPEND lv_run_filter TO lt_csv_fields.
      APPEND lv_run_contains_filter TO lt_csv_fields.
      APPEND lv_message_filter TO lt_csv_fields.
      APPEND lv_message_only_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND lv_has_more_text TO lt_csv_fields.
      APPEND lv_next_offset_text TO lt_csv_fields.
      APPEND lv_has_previous_text TO lt_csv_fields.
      APPEND lv_previous_offset_text TO lt_csv_fields.
      APPEND lv_page_number_text TO lt_csv_fields.
      APPEND lv_page_count_text TO lt_csv_fields.
      APPEND lv_last_offset_text TO lt_csv_fields.
      APPEND lv_min_demand_filter TO lt_csv_fields.
      APPEND lv_max_demand_filter TO lt_csv_fields.
      APPEND lv_min_available_filter TO lt_csv_fields.
      APPEND lv_max_available_filter TO lt_csv_fields.
      APPEND lv_shortage_filter TO lt_csv_fields.
      APPEND lv_max_shortage_filter TO lt_csv_fields.
      APPEND lv_min_shortage_pct_filter TO lt_csv_fields.
      APPEND lv_max_shortage_pct_filter TO lt_csv_fields.
      APPEND lv_min_coverage_filter TO lt_csv_fields.
      APPEND lv_coverage_filter TO lt_csv_fields.
      APPEND lv_min_requested_filter TO lt_csv_fields.
      APPEND lv_max_requested_filter TO lt_csv_fields.
      APPEND lv_min_allocated_filter TO lt_csv_fields.
      APPEND lv_max_allocated_filter TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_stale ) TO lt_csv_fields.
      APPEND lv_max_age_filter TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_candidate_count ) TO lt_csv_fields.
      APPEND lv_limited_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_alerts ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_adaptive_priority_runs ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_adaptive_fair_runs ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_weighted_strategy_runs ) TO lt_csv_fields.
      APPEND lv_weighted_requested_text TO lt_csv_fields.
      APPEND lv_weighted_allocated_text TO lt_csv_fields.
      APPEND lv_weighted_shortage_text TO lt_csv_fields.
      APPEND lv_weighted_coverage_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_deadline_count ) TO lt_csv_fields.
      APPEND lv_summary_unit TO lt_csv_fields.
      APPEND lv_safety_stock_text TO lt_csv_fields.
      APPEND lv_mixed_units_text TO lt_csv_fields.
      IF lv_mixed_units = abap_true.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>number( lv_total_available ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_total_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_total_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_total_shortage ) TO lt_csv_fields.
      ENDIF.
      APPEND lv_total_coverage_text TO lt_csv_fields.
      APPEND lv_total_shortage_pct_text TO lt_csv_fields.
      APPEND lv_oldest_age_text TO lt_csv_fields.
      APPEND lv_newest_age_text TO lt_csv_fields.
      APPEND lv_earliest_deadline_text TO lt_csv_fields.
      APPEND lv_latest_deadline_text TO lt_csv_fields.
      APPEND lv_oldest_deadline_age_text TO lt_csv_fields.
      APPEND lv_newest_deadline_age_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_reference_date )
        TO lt_csv_fields.
      APPEND lv_deadline_age_mixed_text TO lt_csv_fields.
      LOOP AT lt_csv_fields ASSIGNING FIELD-SYMBOL(<lv_csv_field>).
        <lv_csv_field> = zcl_stock_csv=>quote( <lv_csv_field> ).
      ENDLOOP.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'schema_version;material;plant;storage_location;batch;requested_unit;'
      && 'filters_applied;filters;'
      && 'sort_mode;strategy_filter;preview_filter;movement_type_filter;minimum_shelf_life_filter;'
      && 'safety_stock_filter;minimum_safety_stock_filter;maximum_safety_stock_filter;'
      && 'requested_on_from_filter;requested_on_to_filter;'
      && 'start_date_from_filter;start_date_to_filter;'
      && 'finish_date_from_filter;finish_date_to_filter;'
      && 'requested_overdue_only;requested_overdue_as_of_filter;'
      && 'requested_deadline_only;requested_deadline_from;requested_deadline_to;'
      && 'deadline_age_from_filter;deadline_age_to_filter;deadline_age_date_filter;'
      && 'legacy_strategy_filter;'
      && 'run_id_filter;run_id_contains_filter;'
      && 'message_filter;message_only;offset;has_more;next_offset;has_previous;'
      && 'previous_offset;page_number;page_count;last_offset;'
      && 'minimum_demand_count;maximum_demand_count;minimum_available_stock;'
      && 'maximum_available_stock;minimum_requested_quantity;maximum_requested_quantity;'
      && 'minimum_allocated_quantity;maximum_allocated_quantity;maximum_age_seconds;'
      && 'minimum_shortage;maximum_shortage;minimum_shortage_pct;'
      && 'maximum_shortage_pct;minimum_coverage;maximum_coverage;'
      && 'candidate_count;limited;rank;'
       && 'run_id;strategy;weighted_strategy;adaptive_branch;movement_type;'
       && 'min_shelf_life;safety_stock;requested_on_from;requested_on_to;'
       && 'requested_deadline;deadline_age_days;'
       && 'deadline_age_reference_date;deadline_age_mixed;'
      && 'unit;start_date;start_time;age_seconds;'
      && 'available;requested;allocated;shortage;coverage_pct;shortage_pct;demand_count;message'.
    LOOP AT lt_alerts ASSIGNING <ls_alert>.
      CLEAR lt_csv_fields.
       APPEND zcl_stock_csv=>number( 59 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_filter_names_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_sort_mode ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_strategy_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_preview_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND lv_min_shelf_filter TO lt_csv_fields.
      APPEND lv_safety_stock_filter_text TO lt_csv_fields.
      APPEND lv_safety_stock_from_filter TO lt_csv_fields.
      APPEND lv_safety_stock_to_filter TO lt_csv_fields.
       APPEND lv_requested_from_filter TO lt_csv_fields.
       APPEND lv_requested_to_filter TO lt_csv_fields.
       APPEND lv_start_date_from_filter TO lt_csv_fields.
       APPEND lv_start_date_to_filter TO lt_csv_fields.
       APPEND lv_finish_date_from_filter TO lt_csv_fields.
       APPEND lv_finish_date_to_filter TO lt_csv_fields.
      APPEND lv_overdue_only_text TO lt_csv_fields.
      APPEND lv_overdue_as_of_filter TO lt_csv_fields.
      APPEND lv_deadline_only_text TO lt_csv_fields.
      APPEND lv_deadline_from_filter TO lt_csv_fields.
      APPEND lv_deadline_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_from_filter TO lt_csv_fields.
      APPEND lv_deadline_age_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_date_filter TO lt_csv_fields.
      APPEND lv_legacy_filter_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_run_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_run_contains_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_message_filter ) TO lt_csv_fields.
      APPEND lv_message_only_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND lv_has_more_text TO lt_csv_fields.
      APPEND lv_next_offset_text TO lt_csv_fields.
      APPEND lv_has_previous_text TO lt_csv_fields.
      APPEND lv_previous_offset_text TO lt_csv_fields.
      APPEND lv_page_number_text TO lt_csv_fields.
      APPEND lv_page_count_text TO lt_csv_fields.
      APPEND lv_last_offset_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_demand_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_demand_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_available_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_available_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_requested_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_requested_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_allocated_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_allocated_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_age_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_shortage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shortage_pct_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_max_shortage_pct_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_coverage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_coverage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_candidate_count ) TO lt_csv_fields.
      APPEND lv_limited_text TO lt_csv_fields.
      lv_rank = p_skip + sy-tabix.
      APPEND zcl_stock_csv=>number( lv_rank ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-run_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-strategy ) TO lt_csv_fields.
      APPEND xsdbool( <ls_alert>-strategy = 'W' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-adaptive_branch ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-min_shelf_life ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-safety_stock ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-requested_deadline ) TO lt_csv_fields.
      IF <ls_alert>-requested_deadline IS INITIAL.
        APPEND 'n/a' TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>number( <ls_alert>-deadline_age_days )
          TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_deadline_reference_date )
        TO lt_csv_fields.
      APPEND lv_deadline_age_mixed_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-age_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-shortage ) TO lt_csv_fields.
      CLEAR lv_alert_coverage.
      IF <ls_alert>-requested > 0.
        lv_alert_coverage = <ls_alert>-allocated * 100 / <ls_alert>-requested.
        lv_alert_coverage_text = zcl_stock_csv=>number( lv_alert_coverage ).
      ELSE.
        lv_alert_coverage_text = 'n/a'.
      ENDIF.
      APPEND lv_alert_coverage_text TO lt_csv_fields.
      IF <ls_alert>-shortage_pct_available = abap_true.
        lv_alert_shortage_pct_text = zcl_stock_csv=>number(
          <ls_alert>-shortage_pct ).
      ELSE.
        lv_alert_shortage_pct_text = 'n/a'.
      ENDIF.
      APPEND lv_alert_shortage_pct_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-message ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
    ENDLOOP.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    LOOP AT lt_alerts ASSIGNING <ls_alert>.
      lv_rank = p_skip + sy-tabix.
      lv_item = zcl_stock_json=>property(
        iv_name  = 'run_id'
        iv_value = <ls_alert>-run_id ).
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'rank'
        iv_value = lv_rank ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'strategy'
        iv_value = <ls_alert>-strategy ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>boolean_property(
        iv_name  = 'weighted_strategy'
        iv_value = xsdbool( <ls_alert>-strategy = 'W' ) ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'adaptive_branch'
        iv_value = <ls_alert>-adaptive_branch ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'movement_type'
        iv_value = <ls_alert>-movement_type ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF p_typed = abap_true.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'min_shelf_life'
          iv_value = <ls_alert>-min_shelf_life ).
      ELSE.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'min_shelf_life'
          iv_value = <ls_alert>-min_shelf_life ).
      ENDIF.
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF p_typed = abap_true.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'safety_stock'
          iv_value = <ls_alert>-safety_stock ).
      ELSE.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'safety_stock'
          iv_value = <ls_alert>-safety_stock ).
      ENDIF.
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'requested_on_from'
        iv_value = <ls_alert>-requested_on_from ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'requested_on_to'
        iv_value = <ls_alert>-requested_on_to ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'requested_deadline'
        iv_value = <ls_alert>-requested_deadline ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF <ls_alert>-requested_deadline IS INITIAL.
        lv_field = zcl_stock_json=>null_property(
          iv_name = 'deadline_age_days' ).
      ELSE.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'deadline_age_days'
          iv_value = <ls_alert>-deadline_age_days ).
      ENDIF.
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'deadline_age_reference_date'
        iv_value = lv_deadline_reference_date ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>boolean_property(
        iv_name  = 'deadline_age_mixed'
        iv_value = lv_deadline_age_mixed ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = <ls_alert>-unit ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'start_date'
        iv_value = <ls_alert>-start_date ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'start_time'
        iv_value = <ls_alert>-start_time ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'age_seconds'
        iv_value = <ls_alert>-age_seconds ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'available'
        iv_value = <ls_alert>-available ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'requested'
        iv_value = <ls_alert>-requested ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'allocated'
        iv_value = <ls_alert>-allocated ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'shortage'
        iv_value = <ls_alert>-shortage ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF <ls_alert>-requested > 0.
        lv_alert_coverage = <ls_alert>-allocated * 100 / <ls_alert>-requested.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'coverage_pct'
          iv_value = lv_alert_coverage ).
      ELSE.
        lv_field = zcl_stock_json=>null_property(
          iv_name = 'coverage_pct' ).
      ENDIF.
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF <ls_alert>-shortage_pct_available = abap_true.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'shortage_pct'
          iv_value = <ls_alert>-shortage_pct ).
      ELSE.
        lv_field = zcl_stock_json=>null_property(
          iv_name = 'shortage_pct' ).
      ENDIF.
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'demand_count'
        iv_value = <ls_alert>-demand_count ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'message'
        iv_value = <ls_alert>-message ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF p_ndjson = abap_true.
        lv_json_ndjson_prefix = zcl_stock_json=>property(
          iv_name  = 'mode'
          iv_value = 'zstock_alloc_watch' ).
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 62 ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'sort_mode'
          iv_value = lv_sort_mode ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'strategy_filter'
          iv_value = lv_strategy_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'preview_filter'
          iv_value = lv_preview_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'movement_type_filter'
          iv_value = lv_movement_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'requested_on_from_filter'
          iv_value = lv_requested_from_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'requested_on_to_filter'
          iv_value = lv_requested_to_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'start_date_from_filter'
          iv_value = lv_start_date_from_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'start_date_to_filter'
          iv_value = lv_start_date_to_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'finish_date_from_filter'
          iv_value = lv_finish_date_from_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'finish_date_to_filter'
          iv_value = lv_finish_date_to_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'requested_overdue_only'
          iv_value = p_ovrd ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'requested_overdue_as_of_filter'
          iv_value = lv_overdue_as_of_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'deadline_age_reference_date'
          iv_value = lv_deadline_reference_date ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'deadline_age_mixed'
          iv_value = lv_deadline_age_mixed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'requested_deadline_only'
          iv_value = p_dead ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'requested_deadline_from'
          iv_value = lv_deadline_from_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'requested_deadline_to'
          iv_value = lv_deadline_to_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'deadline_age_from_filter'
          iv_value = lv_deadline_age_from_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'deadline_age_to_filter'
          iv_value = lv_deadline_age_to_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'deadline_age_date_filter'
          iv_value = lv_deadline_age_date_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_typed = abap_true.
          lv_field = zcl_stock_json=>filter_number_property(
            iv_name    = 'minimum_shelf_life_filter'
            iv_value   = p_shelf
            iv_text    = lv_min_shelf_filter
            iv_present = xsdbool( p_shelf IS NOT INITIAL )
            iv_typed   = abap_true ).
        ELSE.
          lv_field = zcl_stock_json=>property(
            iv_name  = 'minimum_shelf_life_filter'
            iv_value = lv_min_shelf_filter ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'safety_stock_filter'
          iv_value = p_safon ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_typed = abap_true.
          lv_field = zcl_stock_json=>filter_number_property(
            iv_name    = 'minimum_safety_stock_filter'
            iv_value   = p_saf
            iv_text    = lv_safety_stock_from_filter
            iv_present = p_safon
            iv_typed   = abap_true ).
        ELSE.
          lv_field = zcl_stock_json=>property(
            iv_name  = 'minimum_safety_stock_filter'
            iv_value = lv_safety_stock_from_filter ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_typed = abap_true.
          lv_field = zcl_stock_json=>filter_number_property(
            iv_name    = 'maximum_safety_stock_filter'
            iv_value   = p_safto
            iv_text    = lv_safety_stock_to_filter
            iv_present = p_safon
            iv_typed   = abap_true ).
        ELSE.
          lv_field = zcl_stock_json=>property(
            iv_name  = 'maximum_safety_stock_filter'
            iv_value = lv_safety_stock_to_filter ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'legacy_strategy_filter'
          iv_value = p_legacy ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'run_id_filter'
          iv_value = lv_run_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'run_id_contains_filter'
          iv_value = lv_run_contains_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'message_filter'
          iv_value = lv_message_filter ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'message_only'
          iv_value = p_monly ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'offset'
          iv_value = p_skip ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'has_more'
          iv_value = lv_has_more ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_typed = abap_true.
          lv_field = zcl_stock_json=>object_property(
            iv_name   = 'filter_values'
            it_fields = lt_filter_value_fields ).
          CONCATENATE lv_json_ndjson_prefix lv_field
            INTO lv_json_ndjson_prefix SEPARATED BY ','.
        ENDIF.
        IF lv_has_more = abap_true.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'next_offset'
            iv_value = lv_next_offset ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'next_offset' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'has_previous'
          iv_value = lv_has_previous ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_has_previous = abap_true.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'previous_offset'
            iv_value = lv_previous_offset ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'previous_offset' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_max > 0.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'page_number'
            iv_value = lv_page_number ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'page_number' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_max > 0.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'page_count'
            iv_value = lv_page_count ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'page_count' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_max > 0.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'last_offset'
            iv_value = lv_last_offset ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'last_offset' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_demand_count'
          iv_value   = p_dfrom
          iv_text    = lv_min_demand_filter
          iv_present = xsdbool( p_dfrom IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_demand_count'
          iv_value   = p_dto
          iv_text    = lv_max_demand_filter
          iv_present = xsdbool( p_dto IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_available_stock'
          iv_value   = p_avf
          iv_text    = lv_min_available_filter
          iv_present = xsdbool( p_avf IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_available_stock'
          iv_value   = p_avt
          iv_text    = lv_max_available_filter
          iv_present = xsdbool( p_avt IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_requested_quantity'
          iv_value   = p_qf
          iv_text    = lv_min_requested_filter
          iv_present = xsdbool( p_qf IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_requested_quantity'
          iv_value   = p_qt
          iv_text    = lv_max_requested_filter
          iv_present = xsdbool( p_qt IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_allocated_quantity'
          iv_value   = p_af
          iv_text    = lv_min_allocated_filter
          iv_present = xsdbool( p_af IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_allocated_quantity'
          iv_value   = p_at
          iv_text    = lv_max_allocated_filter
          iv_present = xsdbool( p_at IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shortage'
          iv_value   = p_shf
          iv_text    = lv_shortage_filter
          iv_present = xsdbool( p_shf IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_shortage'
          iv_value   = p_sht
          iv_text    = lv_max_shortage_filter
          iv_present = xsdbool( p_sht IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shortage_pct'
          iv_value   = p_spf
          iv_text    = lv_min_shortage_pct_filter
          iv_present = xsdbool( p_spf IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_shortage_pct'
          iv_value   = p_spt
          iv_text    = lv_max_shortage_pct_filter
          iv_present = xsdbool( p_spt IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_coverage'
          iv_value   = p_covf
          iv_text    = lv_min_coverage_filter
          iv_present = xsdbool( p_covf IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_coverage'
          iv_value   = p_covt
          iv_text    = lv_coverage_filter
          iv_present = xsdbool( p_covt IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'stale_threshold_seconds'
          iv_value = p_stale ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>filter_number_property(
          iv_name    = 'maximum_age_seconds'
          iv_value   = p_age_to
          iv_text    = lv_max_age_filter
          iv_present = xsdbool( p_age_to IS NOT INITIAL )
          iv_typed   = p_typed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'candidate_count'
          iv_value = lv_candidate_count ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'limited'
          iv_value = lv_limited ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'alert_count'
          iv_value = lines( lt_alerts ) ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'weighted_strategy_runs'
          iv_value = lv_weighted_strategy_runs ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'weighted_requested' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'weighted_requested'
            iv_value = lv_weighted_requested ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'weighted_allocated' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'weighted_allocated'
            iv_value = lv_weighted_allocated ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'weighted_shortage' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'weighted_shortage'
            iv_value = lv_weighted_shortage ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_false AND lv_weighted_requested > 0.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'weighted_coverage_pct'
            iv_value = lv_weighted_coverage ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'weighted_coverage_pct' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'demand_count'
          iv_value = lv_total_demand_count ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>number_property(
          iv_name  = 'deadline_count'
          iv_value = lv_deadline_count ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'scope'
          iv_value = |{ p_matnr }/{ p_werks }/{ p_lgort }| ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'material'
          iv_value = p_matnr ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'plant'
          iv_value = p_werks ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'storage_location'
          iv_value = p_lgort ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'batch'
          iv_value = p_charg ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'requested_unit'
          iv_value = p_meins ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF p_typed = abap_true AND lv_safety_stock_available = abap_true
            AND lv_safety_stock_mixed = abap_false.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'safety_stock_context'
            iv_value = lv_safety_stock ).
        ELSEIF p_typed = abap_true.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'safety_stock_context' ).
        ELSE.
          lv_field = zcl_stock_json=>property(
            iv_name  = 'safety_stock_context'
            iv_value = lv_safety_stock_text ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'filters_applied'
          iv_value = lv_filters_applied ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>string_array_property(
          iv_name   = 'filters'
          it_values = lt_filter_names ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = lv_summary_unit ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'mixed_units'
          iv_value = lv_mixed_units ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'earliest_requested_deadline'
          iv_value = lv_earliest_deadline_text ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'latest_requested_deadline'
          iv_value = lv_latest_deadline_text ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>property(
          iv_name  = 'deadline_age_reference_date'
          iv_value = lv_deadline_reference_date ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        lv_field = zcl_stock_json=>boolean_property(
          iv_name  = 'deadline_age_mixed'
          iv_value = lv_deadline_age_mixed ).
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_deadline_count = 0.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'oldest_deadline_age_days' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'oldest_deadline_age_days'
            iv_value = ls_unit_summary-oldest_deadline_age_days ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_deadline_count = 0.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'newest_deadline_age_days' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'newest_deadline_age_days'
            iv_value = ls_unit_summary-newest_deadline_age_days ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property( iv_name = 'available' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'available'
            iv_value = lv_total_available ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property( iv_name = 'requested' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'requested'
            iv_value = lv_total_requested ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property( iv_name = 'allocated' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'allocated'
            iv_value = lv_total_allocated ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_true.
          lv_field = zcl_stock_json=>null_property( iv_name = 'shortage' ).
        ELSE.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'shortage'
            iv_value = lv_total_shortage ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_false AND lv_total_requested > 0.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_total_coverage ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'coverage_pct' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        IF lv_mixed_units = abap_false AND lv_total_requested > 0.
          lv_field = zcl_stock_json=>number_property(
            iv_name  = 'shortage_pct'
            iv_value = lv_total_shortage_pct ).
        ELSE.
          lv_field = zcl_stock_json=>null_property(
            iv_name = 'shortage_pct' ).
        ENDIF.
        CONCATENATE lv_json_ndjson_prefix lv_field
          INTO lv_json_ndjson_prefix SEPARATED BY ','.
        CONCATENATE '{' lv_json_ndjson_prefix ',' lv_item '}'
          INTO lv_json_line.
        WRITE: / lv_json_line.
      ELSEIF lv_items IS INITIAL.
        lv_items = lv_item.
      ELSE.
        CONCATENATE lv_items lv_item INTO lv_items SEPARATED BY ','.
      ENDIF.
    ENDLOOP.
    lv_json_header = zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'zstock_alloc_watch' ).
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'schema_version'
      iv_value = 62 ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'typed'
      iv_value = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'sort_mode'
      iv_value = lv_sort_mode ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'strategy_filter'
      iv_value = lv_strategy_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'preview_filter'
      iv_value = lv_preview_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'movement_type_filter'
      iv_value = lv_movement_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'requested_on_from_filter'
      iv_value = lv_requested_from_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'requested_on_to_filter'
      iv_value = lv_requested_to_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'start_date_from_filter'
      iv_value = lv_start_date_from_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'start_date_to_filter'
      iv_value = lv_start_date_to_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'finish_date_from_filter'
      iv_value = lv_finish_date_from_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'finish_date_to_filter'
      iv_value = lv_finish_date_to_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'requested_overdue_only'
      iv_value = p_ovrd ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'requested_overdue_as_of_filter'
      iv_value = lv_overdue_as_of_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'requested_deadline_only'
      iv_value = p_dead ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'requested_deadline_from'
      iv_value = lv_deadline_from_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'requested_deadline_to'
      iv_value = lv_deadline_to_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'deadline_age_from_filter'
      iv_value = lv_deadline_age_from_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'deadline_age_to_filter'
      iv_value = lv_deadline_age_to_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'deadline_age_date_filter'
      iv_value = lv_deadline_age_date_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_typed = abap_true.
      lv_field = zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shelf_life_filter'
        iv_value   = p_shelf
        iv_text    = lv_min_shelf_filter
        iv_present = xsdbool( p_shelf IS NOT INITIAL )
        iv_typed   = abap_true ).
    ELSE.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'minimum_shelf_life_filter'
        iv_value = lv_min_shelf_filter ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'safety_stock_filter'
      iv_value = p_safon ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_typed = abap_true.
      lv_field = zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_safety_stock_filter'
        iv_value   = p_saf
        iv_text    = lv_safety_stock_from_filter
        iv_present = p_safon
        iv_typed   = abap_true ).
    ELSE.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'minimum_safety_stock_filter'
        iv_value = lv_safety_stock_from_filter ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_typed = abap_true.
      lv_field = zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_safety_stock_filter'
        iv_value   = p_safto
        iv_text    = lv_safety_stock_to_filter
        iv_present = p_safon
        iv_typed   = abap_true ).
    ELSE.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'maximum_safety_stock_filter'
        iv_value = lv_safety_stock_to_filter ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'legacy_strategy_filter'
      iv_value = p_legacy ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'run_id_filter'
      iv_value = lv_run_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'run_id_contains_filter'
      iv_value = lv_run_contains_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'message_filter'
      iv_value = lv_message_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'message_only'
      iv_value = p_monly ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'offset'
      iv_value = p_skip ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'has_more'
      iv_value = lv_has_more ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_typed = abap_true.
      lv_field = zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_filter_value_fields ).
      CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    ENDIF.
    IF lv_has_more = abap_true.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'next_offset'
        iv_value = lv_next_offset ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'next_offset' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'has_previous'
      iv_value = lv_has_previous ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_has_previous = abap_true.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'previous_offset'
        iv_value = lv_previous_offset ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'previous_offset' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_max > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'page_number'
        iv_value = lv_page_number ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'page_number' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_max > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'page_count'
        iv_value = lv_page_count ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'page_count' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_max > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'last_offset'
        iv_value = lv_last_offset ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'last_offset' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_demand_count'
      iv_value   = p_dfrom
      iv_text    = lv_min_demand_filter
      iv_present = xsdbool( p_dfrom IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_demand_count'
      iv_value   = p_dto
      iv_text    = lv_max_demand_filter
      iv_present = xsdbool( p_dto IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_available_stock'
      iv_value   = p_avf
      iv_text    = lv_min_available_filter
      iv_present = xsdbool( p_avf IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_available_stock'
      iv_value   = p_avt
      iv_text    = lv_max_available_filter
      iv_present = xsdbool( p_avt IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_requested_quantity'
      iv_value   = p_qf
      iv_text    = lv_min_requested_filter
      iv_present = xsdbool( p_qf IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_requested_quantity'
      iv_value   = p_qt
      iv_text    = lv_max_requested_filter
      iv_present = xsdbool( p_qt IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_allocated_quantity'
      iv_value   = p_af
      iv_text    = lv_min_allocated_filter
      iv_present = xsdbool( p_af IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_allocated_quantity'
      iv_value   = p_at
      iv_text    = lv_max_allocated_filter
      iv_present = xsdbool( p_at IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_shortage'
      iv_value   = p_shf
      iv_text    = lv_shortage_filter
      iv_present = xsdbool( p_shf IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_shortage'
      iv_value   = p_sht
      iv_text    = lv_max_shortage_filter
      iv_present = xsdbool( p_sht IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_shortage_pct'
      iv_value   = p_spf
      iv_text    = lv_min_shortage_pct_filter
      iv_present = xsdbool( p_spf IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_shortage_pct'
      iv_value   = p_spt
      iv_text    = lv_max_shortage_pct_filter
      iv_present = xsdbool( p_spt IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'minimum_coverage'
      iv_value   = p_covf
      iv_text    = lv_min_coverage_filter
      iv_present = xsdbool( p_covf IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_coverage'
      iv_value   = p_covt
      iv_text    = lv_coverage_filter
      iv_present = xsdbool( p_covt IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'candidate_count'
      iv_value = lv_candidate_count ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'limited'
      iv_value = lv_limited ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_json_threshold = zcl_stock_json=>number_property(
      iv_name  = 'stale_threshold_seconds'
      iv_value = p_stale ).
    lv_field = zcl_stock_json=>filter_number_property(
      iv_name    = 'maximum_age_seconds'
      iv_value   = p_age_to
      iv_text    = lv_max_age_filter
      iv_present = xsdbool( p_age_to IS NOT INITIAL )
      iv_typed   = p_typed ).
    CONCATENATE lv_json_threshold lv_field INTO lv_json_threshold SEPARATED BY ','.
    lv_json_count = zcl_stock_json=>number_property(
      iv_name  = 'alert_count'
      iv_value = lines( lt_alerts ) ).
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'adaptive_priority_runs'
      iv_value = lv_adaptive_priority_runs ).
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'adaptive_fair_runs'
      iv_value = lv_adaptive_fair_runs ).
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'weighted_strategy_runs'
      iv_value = lv_weighted_strategy_runs ).
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'weighted_requested' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'weighted_requested'
        iv_value = lv_weighted_requested ).
    ENDIF.
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'weighted_allocated' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'weighted_allocated'
        iv_value = lv_weighted_allocated ).
    ENDIF.
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'weighted_shortage' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'weighted_shortage'
        iv_value = lv_weighted_shortage ).
    ENDIF.
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    IF lv_mixed_units = abap_false AND lv_weighted_requested > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'weighted_coverage_pct'
        iv_value = lv_weighted_coverage ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'weighted_coverage_pct' ).
    ENDIF.
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'demand_count'
      iv_value = lv_total_demand_count ).
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'deadline_count'
      iv_value = lv_deadline_count ).
    CONCATENATE lv_json_count lv_field INTO lv_json_count SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = lv_summary_unit ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF p_typed = abap_true AND lv_safety_stock_available = abap_true
        AND lv_safety_stock_mixed = abap_false.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'safety_stock_context'
        iv_value = lv_safety_stock ).
    ELSEIF p_typed = abap_true.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'safety_stock_context' ).
    ELSE.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'safety_stock_context'
        iv_value = lv_safety_stock_text ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_units'
      iv_value = lv_mixed_units ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'earliest_requested_deadline'
      iv_value = lv_earliest_deadline_text ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'latest_requested_deadline'
      iv_value = lv_latest_deadline_text ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'deadline_age_reference_date'
      iv_value = lv_deadline_reference_date ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'deadline_age_mixed'
      iv_value = lv_deadline_age_mixed ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_deadline_count = 0.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'oldest_deadline_age_days' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'oldest_deadline_age_days'
        iv_value = ls_unit_summary-oldest_deadline_age_days ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_deadline_count = 0.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'newest_deadline_age_days' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'newest_deadline_age_days'
        iv_value = ls_unit_summary-newest_deadline_age_days ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property( iv_name = 'available' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'available'
        iv_value = lv_total_available ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property( iv_name = 'requested' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'requested'
        iv_value = lv_total_requested ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property( iv_name = 'allocated' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'allocated'
        iv_value = lv_total_allocated ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_mixed_units = abap_true.
      lv_field = zcl_stock_json=>null_property( iv_name = 'shortage' ).
    ELSE.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'shortage'
        iv_value = lv_total_shortage ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_mixed_units = abap_false AND lv_total_requested > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'coverage_pct'
        iv_value = lv_total_coverage ).
    ELSE.
      lv_field = zcl_stock_json=>null_property( iv_name = 'coverage_pct' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_mixed_units = abap_false AND lv_total_requested > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'shortage_pct'
        iv_value = lv_total_shortage_pct ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'shortage_pct' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lines( lt_alerts ) > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'oldest_age_seconds'
        iv_value = lv_oldest_age ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'oldest_age_seconds' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lines( lt_alerts ) > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'newest_age_seconds'
        iv_value = lv_newest_age ).
    ELSE.
      lv_field = zcl_stock_json=>null_property(
        iv_name = 'newest_age_seconds' ).
    ENDIF.
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'material'
      iv_value = p_matnr ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'plant'
      iv_value = p_werks ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'storage_location'
      iv_value = p_lgort ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'batch'
      iv_value = p_charg ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'requested_unit'
      iv_value = p_meins ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'filters_applied'
      iv_value = lv_filters_applied ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>string_array_property(
      iv_name   = 'filters'
      it_values = lt_filter_names ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_json_runs = zcl_stock_json=>property(
      iv_name  = 'scope'
      iv_value = |{ p_matnr }/{ p_werks }/{ p_lgort }| ).
    IF p_ndjson = abap_true.
      RETURN.
    ELSEIF p_sum = abap_true.
      CONCATENATE '{' lv_json_header ',' lv_json_threshold ',' lv_json_count
        ',' lv_json_runs '}' INTO lv_json_line.
    ELSE.
      CONCATENATE '{' lv_json_header ',' lv_json_threshold ',' lv_json_count
        ',' lv_json_runs ',"runs":[' lv_items ']}' INTO lv_json_line.
    ENDIF.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  WRITE: / 'Stale running allocations:', lines( lt_alerts ),
         / 'Demand lines:', lv_total_demand_count,
         / 'Alerts with requested deadline:', lv_deadline_count,
         / 'Candidate alerts:', lv_candidate_count,
         / 'Limited:', lv_limited_text,
         / 'Threshold (seconds):', p_stale,
         / 'Maximum age (seconds):', lv_max_age_filter,
         / 'Sort mode:', lv_sort_mode,
         / 'Strategy filter:', lv_strategy_filter,
         / 'Preview filter:', lv_preview_filter,
         / 'Movement type filter:', lv_movement_filter,
         / 'Minimum shelf-life filter:', lv_min_shelf_filter,
         / 'Requested horizon from:', lv_requested_from_filter,
         / 'Requested horizon to:', lv_requested_to_filter,
         / 'Audit start date from:', lv_start_date_from_filter,
         / 'Audit start date to:', lv_start_date_to_filter,
         / 'Audit finish date from:', lv_finish_date_from_filter,
         / 'Audit finish date to:', lv_finish_date_to_filter,
         / 'Requested deadline from:', lv_deadline_from_filter,
         / 'Requested deadline to:', lv_deadline_to_filter,
         / 'Deadline age from:', lv_deadline_age_from_filter,
         / 'Deadline age to:', lv_deadline_age_to_filter,
         / 'Deadline age as-of:', lv_deadline_age_date_filter,
         / 'Overdue as-of date:', lv_overdue_as_of_filter,
         / 'Legacy strategy filter:', lv_legacy_filter_text,
         / 'Run ID filter:', lv_run_filter,
         / 'Run ID contains filter:', lv_run_contains_filter,
         / 'Message filter:', lv_message_filter,
         / 'Message only:', lv_message_only_text,
         / 'Overdue requested horizon only:', lv_overdue_only_text,
         / 'Filters applied:', lv_filters_applied,
         / 'Filters:', lv_filter_names_text,
         / 'Offset:', p_skip,
         / 'Has more:', lv_has_more_text,
         / 'Next offset:', lv_next_offset_text,
         / 'Has previous:', lv_has_previous_text,
         / 'Previous offset:', lv_previous_offset_text,
         / 'Page number:', lv_page_number_text,
         / 'Page count:', lv_page_count_text,
         / 'Last offset:', lv_last_offset_text,
         / 'Minimum shortage:', lv_shortage_filter,
         / 'Maximum shortage:', lv_max_shortage_filter,
         / 'Minimum shortage percentage:', lv_min_shortage_pct_filter,
         / 'Maximum shortage percentage:', lv_max_shortage_pct_filter,
         / 'Minimum demand count:', lv_min_demand_filter,
         / 'Maximum demand count:', lv_max_demand_filter,
         / 'Minimum available stock:', lv_min_available_filter,
         / 'Maximum available stock:', lv_max_available_filter,
         / 'Minimum requested quantity:', lv_min_requested_filter,
         / 'Maximum requested quantity:', lv_max_requested_filter,
         / 'Minimum allocated quantity:', lv_min_allocated_filter,
         / 'Maximum allocated quantity:', lv_max_allocated_filter,
         / 'Minimum coverage:', lv_min_coverage_filter,
         / 'Maximum coverage:', lv_coverage_filter,
         / 'Unit:', lv_summary_unit,
         / 'Safety stock context:', lv_safety_stock_text,
         / 'Mixed units:', lv_mixed_units_text,
         / 'Available:', lv_total_available_text,
         / 'Requested:', lv_total_requested_text,
         / 'Allocated:', lv_total_allocated_text,
         / 'Shortage:', lv_total_shortage_text,
         / 'Coverage:', lv_total_coverage_text,
         / 'Shortage percentage:', lv_total_shortage_pct_text,
         / 'Weighted strategy runs:', lv_weighted_strategy_runs,
         / 'Weighted requested:', lv_weighted_requested_text,
         / 'Weighted allocated:', lv_weighted_allocated_text,
         / 'Weighted shortage:', lv_weighted_shortage_text,
         / 'Weighted coverage:', lv_weighted_coverage_text,
         / 'Earliest requested deadline:', lv_earliest_deadline_text,
         / 'Latest requested deadline:', lv_latest_deadline_text,
         / 'Oldest deadline age (days):', lv_oldest_deadline_age_text,
         / 'Newest deadline age (days):', lv_newest_deadline_age_text,
         / 'Deadline age reference date:', lv_deadline_reference_date,
         / 'Deadline age mixed:', lv_deadline_age_mixed_text,
         / 'Scope:', p_matnr, p_werks, p_lgort, p_charg, p_meins.
  IF p_sum = abap_true.
    RETURN.
  ENDIF.
  LOOP AT lt_alerts ASSIGNING <ls_alert>.
    lv_rank = p_skip + sy-tabix.
    CLEAR lv_alert_coverage.
    IF <ls_alert>-requested > 0.
      lv_alert_coverage = <ls_alert>-allocated * 100 / <ls_alert>-requested.
      lv_alert_coverage_text = zcl_stock_csv=>number( lv_alert_coverage ).
    ELSE.
      lv_alert_coverage_text = 'n/a'.
    ENDIF.
    IF <ls_alert>-shortage_pct_available = abap_true.
      lv_alert_shortage_pct_text = zcl_stock_csv=>number(
        <ls_alert>-shortage_pct ).
    ELSE.
      lv_alert_shortage_pct_text = 'n/a'.
    ENDIF.
    WRITE: / 'rank', lv_rank,
             <ls_alert>-run_id,
             'age', <ls_alert>-age_seconds,
             'strategy', <ls_alert>-strategy,
             'weighted strategy', xsdbool( <ls_alert>-strategy = 'W' ),
             'adaptive branch', <ls_alert>-adaptive_branch,
             'movement type', <ls_alert>-movement_type,
             'minimum shelf-life days', <ls_alert>-min_shelf_life,
             'safety stock', <ls_alert>-safety_stock,
             'requested horizon', <ls_alert>-requested_on_from,
             <ls_alert>-requested_on_to,
             'requested deadline', <ls_alert>-requested_deadline,
             'deadline age days', <ls_alert>-deadline_age_days,
             'deadline age reference date', lv_deadline_reference_date,
             'deadline age mixed', lv_deadline_age_mixed_text,
             'unit', <ls_alert>-unit,
             'shortage', <ls_alert>-shortage,
             'coverage', lv_alert_coverage_text,
             'shortage %', lv_alert_shortage_pct_text.
  ENDLOOP.
