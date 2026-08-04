REPORT zstock_alloc_result.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_latest AS CHECKBOX.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_runid TYPE zif_stock_allocation=>ty_run_id.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_rid TYPE zif_stock_allocation=>ty_run_id.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_legacy AS CHECKBOX.
PARAMETERS p_stat TYPE zif_stock_allocation=>ty_allocation_status.
PARAMETERS p_astat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_vbeln TYPE zif_stock_allocation=>ty_sales_document.
PARAMETERS p_auart TYPE zif_stock_allocation=>ty_sales_document_type.
PARAMETERS p_posnr TYPE zif_stock_allocation=>ty_sales_item.
PARAMETERS p_etenr TYPE zif_stock_allocation=>ty_schedule_line.
PARAMETERS p_ounit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_order TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_resid TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_rmov TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_runit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_rsv AS CHECKBOX.
PARAMETERS p_unrsv AS CHECKBOX.
PARAMETERS p_bklg AS CHECKBOX.
PARAMETERS p_ovrd AS CHECKBOX.
PARAMETERS p_odate TYPE d.
PARAMETERS p_dead AS CHECKBOX.
PARAMETERS p_deadf TYPE d.
PARAMETERS p_deadt TYPE d.
PARAMETERS p_dagef TYPE i.
PARAMETERS p_daget TYPE i.
PARAMETERS p_daged TYPE d.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_rfrom TYPE d.
PARAMETERS p_rto TYPE d.
PARAMETERS p_rage TYPE i.
PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_priof TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_priot TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_pri AS CHECKBOX.
PARAMETERS p_sstat AS CHECKBOX.
PARAMETERS p_date AS CHECKBOX.
PARAMETERS p_rdate AS CHECKBOX.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_cov AS CHECKBOX.
PARAMETERS p_spct AS CHECKBOX.
PARAMETERS p_dcnt AS CHECKBOX.
PARAMETERS p_dage AS CHECKBOX.
PARAMETERS p_due AS CHECKBOX.
PARAMETERS p_tdur AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_max TYPE i.
PARAMETERS p_skip TYPE i.
PARAMETERS p_big AS CHECKBOX.
PARAMETERS p_done AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.
PARAMETERS p_ndjson AS CHECKBOX.

START-OF-SELECTION.
  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_strat TO UPPER CASE.
  TRANSLATE p_astat TO UPPER CASE.
  TYPES:
    BEGIN OF ty_strategy_total,
      strategy  TYPE c LENGTH 1,
      requested TYPE zif_stock_allocation=>ty_quantity,
      allocated TYPE zif_stock_allocation=>ty_quantity,
      shortage  TYPE zif_stock_allocation=>ty_quantity,
    END OF ty_strategy_total.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_compare TYPE REF TO zif_stock_allocation_compare.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  DATA lv_full_count TYPE i.
  DATA lv_partial_count TYPE i.
  DATA lv_unallocated_count TYPE i.
  DATA lv_priority_strategy_lines TYPE i.
  DATA lv_fifo_strategy_lines TYPE i.
  DATA lv_full_only_strategy_lines TYPE i.
  DATA lv_smallest_strategy_lines TYPE i.
  DATA lv_largest_strategy_lines TYPE i.
  DATA lv_best_strategy_lines TYPE i.
  DATA lv_legacy_strategy_lines TYPE i.
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
  DATA lv_line_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_line_coverage_text TYPE c LENGTH 8.
  DATA lv_line_shortage_text TYPE c LENGTH 8.
  DATA lv_audit_duration_seconds TYPE i.
  DATA lv_audit_duration_text TYPE string.
  DATA lv_audit_running_age_seconds TYPE i.
  DATA lv_audit_running_age_text TYPE string.
  DATA lv_audit_movement_type TYPE zif_stock_allocation=>ty_movement_type.
  DATA lv_audit_min_shelf_life TYPE i.
  DATA lv_audit_requested_deadline TYPE d.
  DATA lv_deadline_reference_date TYPE d.
  DATA lv_audit_deadline_age_days TYPE i.
  DATA lv_audit_deadline_age_text TYPE string.
  DATA lv_audit_requested_from TYPE d.
  DATA lv_audit_requested_to TYPE d.
  DATA lv_exact_audit_available TYPE abap_bool.
  DATA ls_audit_running_age TYPE zif_allocation_audit=>ty_running_age.
  DATA lv_summary_strategy TYPE string.
  DATA lt_strategy_totals TYPE SORTED TABLE OF ty_strategy_total
    WITH UNIQUE KEY strategy.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE c LENGTH 1024.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_json_line TYPE string.
  DATA lv_summary_json TYPE string.
  DATA lv_numeric_json TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_csv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_summary_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_display_strategy TYPE string.
  DATA lv_mixed_units TYPE abap_bool.
  DATA lt_filter_names TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_filter_value_fields TYPE zcl_stock_json=>tt_strings.
  DATA lv_filter_names_text TYPE string.
  DATA lv_movement_filter TYPE string.
  DATA lv_audit_status_filter TYPE string.
  DATA lv_message_filter TYPE string.
  DATA lv_message_only_text TYPE string.
  DATA lv_min_shelf_filter TYPE string.
  DATA lv_overdue_as_of_filter TYPE c LENGTH 10.
  DATA lv_requested_from_filter TYPE c LENGTH 10.
  DATA lv_requested_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_from_filter TYPE c LENGTH 10.
  DATA lv_deadline_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_age_from_filter TYPE string.
  DATA lv_deadline_age_to_filter TYPE string.
  DATA lv_deadline_age_date_filter TYPE c LENGTH 10.
  DATA lv_deadline_only_text TYPE string.
  DATA lv_reconcile_possible TYPE abap_bool.
  DATA lv_reconcile_ok TYPE abap_bool.
  DATA ls_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation.
  DATA lv_audit_context_available TYPE abap_bool.
  DATA lv_latest_empty TYPE abap_bool.
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
  FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
  FIELD-SYMBOLS <ls_strategy_total> TYPE ty_strategy_total.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.
  FIELD-SYMBOLS <lv_csv_field> TYPE string.

  lv_movement_filter = p_mvt.
  IF lv_movement_filter IS INITIAL.
    lv_movement_filter = 'n/a'.
  ENDIF.
  lv_audit_status_filter = p_astat.
  IF lv_audit_status_filter IS INITIAL.
    lv_audit_status_filter = 'n/a'.
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
  IF p_shelf IS INITIAL.
    lv_min_shelf_filter = 'n/a'.
  ELSE.
    lv_min_shelf_filter = zcl_stock_csv=>number( p_shelf ).
  ENDIF.
  IF p_odate IS INITIAL.
    lv_overdue_as_of_filter = 'n/a'.
    lv_deadline_reference_date = sy-datum.
  ELSE.
    lv_overdue_as_of_filter = p_odate.
    lv_deadline_reference_date = p_odate.
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
  IF p_dead = abap_true.
    lv_deadline_only_text = 'true'.
  ELSE.
    lv_deadline_only_text = 'false'.
  ENDIF.
  lv_audit_requested_from = p_from.
  lv_audit_requested_to = p_to.
  IF p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL.
    lv_audit_requested_from = p_reqf.
    lv_audit_requested_to = p_until.
  ENDIF.

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
    ELSEIF p_max < 0.
      lv_csv_error_message = 'Row limit must not be negative'.
    ELSEIF p_rage < 0.
      lv_csv_error_message = 'Reservation age must not be negative'.
    ELSEIF p_shelf < 0.
      lv_csv_error_message = 'Minimum shelf-life filter must not be negative'.
    ELSEIF ( p_covf IS NOT INITIAL AND ( p_covf < 0 OR p_covf > 100 ) )
        OR ( p_covt IS NOT INITIAL AND ( p_covt < 0 OR p_covt > 100 ) ).
      lv_csv_error_message =
        'Coverage bounds must be between 0 and 100'.
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
    ELSEIF p_latest = abap_true AND p_runid IS NOT INITIAL.
      lv_csv_error_message =
        'Latest-run mode cannot be combined with an exact run ID'.
    ELSEIF p_strat IS NOT INITIAL
        AND p_strat <> 'P'
        AND p_strat <> 'F'
        AND p_strat <> 'N'
        AND p_strat <> 'S'
        AND p_strat <> 'L'
        AND p_strat <> 'B'.
      lv_csv_error_message = 'Strategy must be P, F, N, S, L, or B'.
    ELSEIF p_strat IS NOT INITIAL AND p_legacy = abap_true.
      lv_csv_error_message = 'Strategy filters cannot be combined'.
    ENDIF.
    IF lv_csv_error_message IS NOT INITIAL.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_result'
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
  IF p_rage < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Reservation age must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Reservation age must not be negative.'.
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
  IF p_shelf < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Minimum shelf-life filter must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Minimum shelf-life filter must not be negative.'.
    RETURN.
  ENDIF.
  IF p_odate IS NOT INITIAL AND p_ovrd = abap_false.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Overdue as-of date requires overdue-only filtering' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_result'
        iv_message = 'Overdue as-of date requires overdue-only filtering' ).
      RETURN.
    ENDIF.
    WRITE: / 'Overdue as-of date requires overdue-only filtering.'.
    RETURN.
  ENDIF.
  IF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL AND p_reqf > p_until.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The requested horizon start must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_result'
        iv_message = 'The requested horizon start must not be after the end date' ).
      RETURN.
    ENDIF.
    WRITE: / 'The requested horizon start must not be after the end date.'.
    RETURN.
  ENDIF.
  IF p_deadf IS NOT INITIAL AND p_deadt IS NOT INITIAL
      AND p_deadf > p_deadt.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error(
        'The requested deadline start must not be after the end date' ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_result'
        iv_message = 'The requested deadline start must not be after the end date' ).
      RETURN.
    ENDIF.
    WRITE: / 'The requested deadline start must not be after the end date.'.
    RETURN.
  ENDIF.
  IF p_dagef IS NOT INITIAL AND p_daget IS NOT INITIAL
      AND p_dagef > p_daget.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error(
        'The deadline age start must not be after the end age' ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_result'
        iv_message = 'The deadline age start must not be after the end age' ).
      RETURN.
    ENDIF.
    WRITE: / 'The deadline age start must not be after the end age.'.
    RETURN.
  ENDIF.
  IF p_daged IS NOT INITIAL
      AND p_dagef IS INITIAL
      AND p_daget IS INITIAL.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error(
        'A deadline age as-of date requires a deadline age range' ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_result'
        iv_message = 'A deadline age as-of date requires a deadline age range' ).
      RETURN.
    ENDIF.
    WRITE: / 'A deadline age as-of date requires a deadline age range.'.
    RETURN.
  ENDIF.
  IF p_latest = abap_true AND p_runid IS NOT INITIAL.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Latest-run mode cannot be combined with an exact run ID' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Latest-run mode cannot be combined with an exact run ID.'.
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
  IF p_strat IS NOT INITIAL AND p_legacy = abap_true.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Strategy filters cannot be combined' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Strategy filters cannot be combined.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_allocation_read_auth_sap.
  TRY.
      lo_authority->check_results( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
      IF p_json = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Result read authorization is missing' ).
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
            iv_mode    = 'zstock_alloc_result'
            iv_message = 'Result read authorization is missing' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_result'
            iv_message = lo_auth_error->message ).
        ENDIF.
        WRITE: / 'mode;status;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_auth_error->message IS INITIAL.
        WRITE: / 'Allocation results are unavailable; read authorization is missing.'.
      ELSE.
        WRITE: / 'Allocation results are unavailable:', lo_auth_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_compare TYPE zcl_stock_allocation_compare.

  CLEAR lv_latest_empty.
  IF p_latest = abap_true.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_read_authority = lo_authority.
    TRY.
        lt_runs = lo_audit->get_runs(
           iv_material          = p_matnr
           iv_plant             = p_werks
           iv_storage_location  = p_lgort
           iv_batch             = p_charg
           iv_run_id_contains   = p_rid
           iv_unit              = p_meins
           iv_strategy          = p_strat
           iv_legacy_strategy   = p_legacy
           iv_status            = p_astat
           iv_message_contains  = p_msg
           iv_message_only      = p_monly
           iv_movement_type     = p_mvt
           iv_min_shelf_life    = p_shelf
           iv_requested_on_from = lv_audit_requested_from
           iv_requested_on_to   = lv_audit_requested_to
           iv_requested_overdue = p_ovrd
           iv_overdue_date      = p_odate
           iv_deadline_only     = p_dead
           iv_deadline_from     = p_deadf
           iv_deadline_to       = p_deadt
           iv_deadline_age_from = p_dagef
           iv_deadline_age_to   = p_daget
           iv_deadline_age_date = p_daged
           iv_coverage_from     = p_covf
           iv_coverage_to       = p_covt
           iv_shortage_pct_from = p_spf
           iv_shortage_pct_to   = p_spt
           iv_max_rows          = 1 ).
      CATCH zcx_stock_allocation INTO DATA(lo_latest_error).
        IF lo_latest_error->message IS INITIAL.
          lv_error_message = 'Latest allocation run is unavailable'.
        ELSE.
          lv_error_message = lo_latest_error->message.
        ENDIF.
        IF p_json = abap_true.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
          WRITE: / lv_json_line.
          RETURN.
        ENDIF.
        IF p_csv = abap_true.
          WRITE: / 'mode;status;message'.
          WRITE: / zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_result'
            iv_message = lv_error_message ).
          RETURN.
        ENDIF.
        WRITE: / 'Latest allocation run is unavailable:', lv_error_message.
        RETURN.
    ENDTRY.
    READ TABLE lt_runs ASSIGNING <ls_run> INDEX 1.
    IF sy-subrc = 0.
      p_runid = <ls_run>-run_id.
    ELSE.
      lv_latest_empty = abap_true.
    ENDIF.
  ENDIF.

  lv_audit_running_age_text = 'n/a'.
  lv_exact_audit_available = abap_false.
  CLEAR: lv_audit_movement_type,
         lv_audit_min_shelf_life,
         lv_audit_requested_deadline.
  lv_audit_deadline_age_text = 'n/a'.
    IF ( p_csv = abap_true OR p_json = abap_true OR p_dead = abap_true
      OR p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL
      OR p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL
      OR p_daged IS NOT INITIAL
      OR p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL
      OR p_astat IS NOT INITIAL
      OR p_msg IS NOT INITIAL OR p_monly = abap_true )
      AND p_runid IS NOT INITIAL.
    CLEAR lt_runs.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_read_authority = lo_authority.
    TRY.
        lt_runs = lo_audit->get_runs(
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_run_id            = p_runid
          iv_status            = p_astat
          iv_message_contains  = p_msg
          iv_message_only      = p_monly
          iv_deadline_only     = p_dead
          iv_deadline_from     = p_deadf
          iv_deadline_to       = p_deadt
          iv_deadline_age_from = p_dagef
          iv_deadline_age_to   = p_daget
          iv_deadline_age_date = p_daged
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until ).
      CATCH zcx_stock_allocation.
        CLEAR lt_runs.
    ENDTRY.
    READ TABLE lt_runs ASSIGNING <ls_run> INDEX 1.
    IF sy-subrc = 0.
      lv_exact_audit_available = abap_true.
      lv_audit_movement_type = <ls_run>-movement_type.
      lv_audit_min_shelf_life = <ls_run>-min_shelf_life.
      lv_audit_requested_deadline = <ls_run>-requested_deadline.
      IF lv_audit_requested_deadline IS INITIAL.
        lv_audit_deadline_age_text = 'n/a'.
      ELSE.
        lv_audit_deadline_age_days = lv_deadline_reference_date
          - lv_audit_requested_deadline.
        lv_audit_deadline_age_text = zcl_stock_csv=>number(
          lv_audit_deadline_age_days ).
      ENDIF.
      ls_audit_running_age = lo_audit->get_running_age( <ls_run> ).
      IF ls_audit_running_age-available = abap_true.
        lv_audit_running_age_seconds = ls_audit_running_age-seconds.
        lv_audit_running_age_text = zcl_stock_csv=>number(
          lv_audit_running_age_seconds ).
      ENDIF.
    ELSEIF p_dead = abap_true OR p_deadf IS NOT INITIAL
        OR p_deadt IS NOT INITIAL OR p_dagef IS NOT INITIAL
        OR p_daget IS NOT INITIAL OR p_daged IS NOT INITIAL.
      lv_latest_empty = abap_true.
    ENDIF.
  ENDIF.

  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
    EXPORTING
      io_read_authority = lo_authority.
  lv_query_max = p_max.
  IF p_max > 0.
    lv_query_max = p_max + 1.
  ENDIF.
  IF lv_latest_empty = abap_false.
    TRY.
    lt_demands = lo_sink->get_allocations(
      EXPORTING
        iv_material                   = p_matnr
        iv_plant                      = p_werks
        iv_storage_location           = p_lgort
        iv_batch                      = p_charg
        iv_unit                       = p_meins
        iv_run_id                     = p_runid
        iv_run_id_contains            = p_rid
        iv_strategy                   = p_strat
        iv_legacy_strategy            = p_legacy
        iv_allocation_movement_type   = p_mvt
        iv_min_shelf_life             = p_shelf
        iv_status                     = p_stat
        iv_run_status                 = p_astat
        iv_run_message_contains      = p_msg
        iv_run_message_only          = p_monly
        iv_sales_document             = p_vbeln
        iv_sales_document_type        = p_auart
        iv_sales_item                 = p_posnr
        iv_schedule_line              = p_etenr
        iv_order_unit                 = p_ounit
        iv_order_id                   = p_order
        iv_reservation_id             = p_resid
        iv_movement_type              = p_rmov
        iv_reservation_unit           = p_runit
        iv_reserved_only              = p_rsv
        iv_unreserved_only            = p_unrsv
        iv_shortage_only              = p_bklg
        iv_overdue_only               = p_ovrd
        iv_overdue_date               = p_odate
        iv_deadline_only              = p_dead
        iv_run_requested_on_from      = p_reqf
        iv_run_requested_on_to        = p_until
        iv_run_deadline_from          = p_deadf
        iv_run_deadline_to            = p_deadt
        iv_run_deadline_age_from      = p_dagef
        iv_run_deadline_age_to        = p_daget
        iv_run_deadline_age_date      = p_daged
        iv_reservation_date_from      = p_rfrom
        iv_reservation_date_to        = p_rto
        iv_reservation_age_from       = p_rage
        iv_requested_on_from          = p_from
        iv_requested_on_to            = p_to
        iv_priority_from              = p_priof
        iv_priority_to                = p_priot
        iv_shortage_from              = p_shf
        iv_shortage_to                = p_sht
        iv_requested_quantity_from    = p_qf
        iv_requested_quantity_to      = p_qt
        iv_allocated_quantity_from    = p_af
        iv_allocated_quantity_to      = p_at
        iv_coverage_from              = p_covf
        iv_coverage_to                = p_covt
        iv_shortage_pct_from          = p_spf
        iv_shortage_pct_to            = p_spt
        iv_max_rows                   = lv_query_max
        iv_sort_by_priority           = p_pri
        iv_sort_by_status             = p_sstat
        iv_sort_by_requested_date     = p_date
        iv_sort_by_reservation_date   = p_rdate
        iv_sort_by_shortage           = p_shrt
        iv_sort_by_coverage           = p_cov
        iv_sort_by_shrt_pct           = p_spct
        iv_sort_by_demand_count       = p_dcnt
        iv_sort_by_deadline_age       = p_dage
        iv_sort_by_requested_deadline = p_due
        iv_sort_by_audit_duration     = p_tdur
        iv_sort_by_requested_quantity = p_big
        iv_sort_by_allocated_quantity = p_done
        iv_offset                     = p_skip
      IMPORTING
        ev_total_rows                 = lv_total_rows ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Allocation results are unavailable for the requested scope' ).
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
            iv_mode    = 'zstock_alloc_result'
            iv_message =
              'Allocation results are unavailable for the requested scope' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_result'
            iv_message = lo_error->message ).
        ENDIF.
        WRITE: / 'mode;status;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_error->message IS INITIAL.
        WRITE: / 'Allocation results are unavailable for the requested scope.'.
      ELSE.
        WRITE: / 'Allocation results are unavailable:', lo_error->message.
      ENDIF.
      RETURN.
    ENDTRY.
  ENDIF.

  lv_has_more = abap_false.
  IF p_max > 0 AND lines( lt_demands ) > p_max.
    lv_has_more = abap_true.
    lv_page_end = p_max + 1.
    DELETE lt_demands INDEX lv_page_end.
  ENDIF.
  lv_next_offset = p_skip + lines( lt_demands ).
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
  IF p_pri = abap_true.
    lv_sort_mode = 'priority'.
  ELSEIF p_sstat = abap_true.
    lv_sort_mode = 'status'.
  ELSEIF p_cov = abap_true.
    lv_sort_mode = 'coverage'.
  ELSEIF p_spct = abap_true.
    lv_sort_mode = 'shortage_percentage'.
  ELSEIF p_dcnt = abap_true.
    lv_sort_mode = 'demand_count'.
  ELSEIF p_dage = abap_true.
    lv_sort_mode = 'deadline_age'.
  ELSEIF p_due = abap_true.
    lv_sort_mode = 'requested_deadline'.
  ELSEIF p_tdur = abap_true.
    lv_sort_mode = 'audit_duration'.
  ELSEIF p_big = abap_true.
    lv_sort_mode = 'requested_quantity'.
  ELSEIF p_done = abap_true.
    lv_sort_mode = 'allocated_quantity'.
  ELSEIF p_date = abap_true.
    lv_sort_mode = 'requested_date'.
  ELSEIF p_rdate = abap_true.
    lv_sort_mode = 'reservation_date'.
  ELSEIF p_shrt = abap_true.
    lv_sort_mode = 'shortage'.
  ENDIF.
  lv_filters_applied = abap_false.
  IF p_meins IS NOT INITIAL
      OR p_charg IS NOT INITIAL
      OR p_runid IS NOT INITIAL
      OR p_rid IS NOT INITIAL
      OR p_mvt IS NOT INITIAL
      OR p_shelf IS NOT INITIAL
      OR p_msg IS NOT INITIAL
      OR p_monly = abap_true
      OR p_strat IS NOT INITIAL
      OR p_legacy = abap_true
      OR p_stat IS NOT INITIAL
      OR p_astat IS NOT INITIAL
      OR p_vbeln IS NOT INITIAL
      OR p_auart IS NOT INITIAL
      OR p_posnr IS NOT INITIAL
      OR p_etenr IS NOT INITIAL
      OR p_ounit IS NOT INITIAL
      OR p_order IS NOT INITIAL
      OR p_resid IS NOT INITIAL
      OR p_rmov IS NOT INITIAL
      OR p_runit IS NOT INITIAL
      OR p_rsv = abap_true
      OR p_unrsv = abap_true
      OR p_bklg = abap_true
      OR p_ovrd = abap_true
      OR p_odate IS NOT INITIAL
      OR p_dead = abap_true
      OR p_deadf IS NOT INITIAL
      OR p_deadt IS NOT INITIAL
      OR p_dagef IS NOT INITIAL
      OR p_daget IS NOT INITIAL
      OR p_daged IS NOT INITIAL
      OR p_reqf IS NOT INITIAL
      OR p_until IS NOT INITIAL
      OR p_rfrom IS NOT INITIAL
      OR p_rto IS NOT INITIAL
      OR p_rage IS NOT INITIAL
      OR p_from IS NOT INITIAL
      OR p_to IS NOT INITIAL
      OR p_priof IS NOT INITIAL
      OR p_priot IS NOT INITIAL
      OR p_shf IS NOT INITIAL
      OR p_sht IS NOT INITIAL
      OR p_qf IS NOT INITIAL
      OR p_qt IS NOT INITIAL
      OR p_af IS NOT INITIAL
      OR p_at IS NOT INITIAL
      OR p_covf IS NOT INITIAL
      OR p_covt IS NOT INITIAL
      OR p_spf IS NOT INITIAL
      OR p_spt IS NOT INITIAL
      OR p_latest = abap_true.
      lv_filters_applied = abap_true.
  ENDIF.
  CLEAR lt_filter_names.
  IF p_meins IS NOT INITIAL.
    APPEND 'unit' TO lt_filter_names.
  ENDIF.
  IF p_charg IS NOT INITIAL.
    APPEND 'batch' TO lt_filter_names.
  ENDIF.
  IF p_runid IS NOT INITIAL AND p_latest = abap_false.
    APPEND 'run_id' TO lt_filter_names.
  ENDIF.
  IF p_rid IS NOT INITIAL.
    APPEND 'run_id_contains' TO lt_filter_names.
  ENDIF.
  IF p_mvt IS NOT INITIAL.
    APPEND 'movement_type' TO lt_filter_names.
  ENDIF.
  IF p_shelf IS NOT INITIAL.
    APPEND 'minimum_shelf_life' TO lt_filter_names.
  ENDIF.
  IF p_strat IS NOT INITIAL.
    APPEND 'strategy' TO lt_filter_names.
  ENDIF.
  IF p_legacy = abap_true.
    APPEND 'legacy_strategy' TO lt_filter_names.
  ENDIF.
  IF p_stat IS NOT INITIAL.
    APPEND 'status' TO lt_filter_names.
  ENDIF.
  IF p_astat IS NOT INITIAL.
    APPEND 'audit_status' TO lt_filter_names.
  ENDIF.
  IF p_msg IS NOT INITIAL.
    APPEND 'message' TO lt_filter_names.
  ENDIF.
  IF p_monly = abap_true.
    APPEND 'message_only' TO lt_filter_names.
  ENDIF.
  IF p_vbeln IS NOT INITIAL.
    APPEND 'sales_document' TO lt_filter_names.
  ENDIF.
  IF p_auart IS NOT INITIAL.
    APPEND 'sales_document_type' TO lt_filter_names.
  ENDIF.
  IF p_posnr IS NOT INITIAL.
    APPEND 'sales_item' TO lt_filter_names.
  ENDIF.
  IF p_etenr IS NOT INITIAL.
    APPEND 'schedule_line' TO lt_filter_names.
  ENDIF.
  IF p_ounit IS NOT INITIAL.
    APPEND 'order_unit' TO lt_filter_names.
  ENDIF.
  IF p_order IS NOT INITIAL.
    APPEND 'order_id' TO lt_filter_names.
  ENDIF.
  IF p_resid IS NOT INITIAL.
    APPEND 'reservation_id' TO lt_filter_names.
  ENDIF.
  IF p_rmov IS NOT INITIAL.
    APPEND 'reservation_movement_type' TO lt_filter_names.
  ENDIF.
  IF p_runit IS NOT INITIAL.
    APPEND 'reservation_unit' TO lt_filter_names.
  ENDIF.
  IF p_rsv = abap_true.
    APPEND 'reserved_only' TO lt_filter_names.
  ENDIF.
  IF p_unrsv = abap_true.
    APPEND 'unreserved_only' TO lt_filter_names.
  ENDIF.
  IF p_bklg = abap_true.
    APPEND 'shortage_only' TO lt_filter_names.
  ENDIF.
  IF p_ovrd = abap_true.
    APPEND 'overdue_only' TO lt_filter_names.
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
  IF p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL.
    APPEND 'deadline_age_range' TO lt_filter_names.
  ENDIF.
  IF p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL.
    APPEND 'requested_horizon' TO lt_filter_names.
  ENDIF.
  IF p_rfrom IS NOT INITIAL OR p_rto IS NOT INITIAL.
    APPEND 'reservation_date' TO lt_filter_names.
  ENDIF.
  IF p_rage IS NOT INITIAL.
    APPEND 'reservation_age' TO lt_filter_names.
  ENDIF.
  IF p_from IS NOT INITIAL OR p_to IS NOT INITIAL.
    APPEND 'requested_date' TO lt_filter_names.
  ENDIF.
  IF p_priof IS NOT INITIAL OR p_priot IS NOT INITIAL.
    APPEND 'priority' TO lt_filter_names.
  ENDIF.
  IF p_shf IS NOT INITIAL OR p_sht IS NOT INITIAL.
    APPEND 'shortage' TO lt_filter_names.
  ENDIF.
  IF p_qf IS NOT INITIAL OR p_qt IS NOT INITIAL.
    APPEND 'requested_quantity' TO lt_filter_names.
  ENDIF.
  IF p_af IS NOT INITIAL OR p_at IS NOT INITIAL.
    APPEND 'allocated_quantity' TO lt_filter_names.
  ENDIF.
  IF p_covf IS NOT INITIAL OR p_covt IS NOT INITIAL.
    APPEND 'coverage' TO lt_filter_names.
  ENDIF.
  IF p_spf IS NOT INITIAL OR p_spt IS NOT INITIAL.
    APPEND 'shortage_percentage' TO lt_filter_names.
  ENDIF.
  IF p_latest = abap_true.
    APPEND 'latest' TO lt_filter_names.
  ENDIF.
  CONCATENATE LINES OF lt_filter_names INTO lv_filter_names_text
    SEPARATED BY '|'.

  CLEAR lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'movement_type'
    iv_value = p_mvt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'audit_status'
    iv_value = lv_audit_status_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'message'
    iv_value = lv_message_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'message_only'
    iv_value = p_monly ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shelf_life'
    iv_value   = p_shelf
    iv_text    = 'n/a'
    iv_present = xsdbool( p_shelf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'overdue_only'
    iv_value = p_ovrd ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_overdue_as_of'
    iv_value = lv_overdue_as_of_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'requested_deadline_only'
    iv_value = p_dead ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_deadline_from'
    iv_value = lv_deadline_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_deadline_to'
    iv_value = lv_deadline_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'deadline_age_from'
    iv_value   = p_dagef
    iv_text    = lv_deadline_age_from_filter
    iv_present = xsdbool( p_dagef IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'deadline_age_to'
    iv_value   = p_daget
    iv_text    = lv_deadline_age_to_filter
    iv_present = xsdbool( p_daget IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'deadline_age_as_of'
    iv_value = lv_deadline_age_date_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_on_from'
    iv_value = lv_requested_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_on_to'
    iv_value = lv_requested_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_reservation_age_days'
    iv_value   = p_rage
    iv_text    = 'n/a'
    iv_present = xsdbool( p_rage IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_priority'
    iv_value   = p_priof
    iv_text    = 'n/a'
    iv_present = xsdbool( p_priof IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_priority'
    iv_value   = p_priot
    iv_text    = 'n/a'
    iv_present = xsdbool( p_priot IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shortage'
    iv_value   = p_shf
    iv_text    = 'n/a'
    iv_present = xsdbool( p_shf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_shortage'
    iv_value   = p_sht
    iv_text    = 'n/a'
    iv_present = xsdbool( p_sht IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_requested_quantity'
    iv_value   = p_qf
    iv_text    = 'n/a'
    iv_present = xsdbool( p_qf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_requested_quantity'
    iv_value   = p_qt
    iv_text    = 'n/a'
    iv_present = xsdbool( p_qt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_allocated_quantity'
    iv_value   = p_af
    iv_text    = 'n/a'
    iv_present = xsdbool( p_af IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_allocated_quantity'
    iv_value   = p_at
    iv_text    = 'n/a'
    iv_present = xsdbool( p_at IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_coverage'
    iv_value   = p_covf
    iv_text    = 'n/a'
    iv_present = xsdbool( p_covf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_coverage'
    iv_value   = p_covt
    iv_text    = 'n/a'
    iv_present = xsdbool( p_covt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shortage_pct'
    iv_value   = p_spf
    iv_text    = 'n/a'
    iv_present = xsdbool( p_spf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_shortage_pct'
    iv_value   = p_spt
    iv_text    = 'n/a'
    iv_present = xsdbool( p_spt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.

  IF lines( lt_demands ) = 0 AND p_sum = abap_false
      AND p_runid IS INITIAL
      AND p_meta = abap_false
      AND p_ndjson = abap_false.
    IF p_json = abap_true.
      WRITE: / '[]'.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      IF p_sum = abap_true.
        WRITE: / 'mode;generated_date;generated_time;schema_version;sort;filters_applied;filters;'
          && 'audit_status_filter;message_filter;message_only;movement_type_filter;minimum_shelf_life_filter;overdue_only;'
          && 'requested_overdue_as_of_filter;requested_on_from_filter;requested_on_to_filter;'
          && 'requested_deadline_only;requested_deadline_from_filter;'
          && 'requested_deadline_to_filter;deadline_age_from_filter;deadline_age_to_filter;'
          && 'deadline_age_date_filter;offset;max_rows;'
          && 'page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;total_rows;material;'
          && 'plant;storage_location;batch;unit;mixed_units;strategy_context;result_lines;'
          && 'demand_count;full_count;partial_count;'
          && 'unallocated_count;priority_strategy_lines;fifo_strategy_lines;full_only_strategy_lines;'
          && 'smallest_strategy_lines;largest_strategy_lines;best_strategy_lines;legacy_strategy_lines;'
          && 'priority_requested;priority_allocated;priority_shortage;priority_coverage_pct;fifo_requested;'
          && 'fifo_allocated;fifo_shortage;fifo_coverage_pct;full_only_requested;full_only_allocated;'
          && 'full_only_shortage;full_only_coverage_pct;smallest_requested;smallest_allocated;smallest_shortage;'
          && 'smallest_coverage_pct;largest_requested;largest_allocated;largest_shortage;largest_coverage_pct;'
          && 'best_requested;best_allocated;best_shortage;best_coverage_pct;legacy_requested;legacy_allocated;'
          && 'legacy_shortage;legacy_coverage_pct;requested;allocated;shortage;coverage_pct;shortage_pct;'
          && 'audit_movement_type;audit_min_shelf_life;audit_requested_deadline;'
          && 'audit_deadline_age_days;deadline_age_reference_date'.
      ELSE.
        WRITE: / 'allocation_run_id;strategy;generated_date;generated_time;schema_version;sort;filters_applied;filters;'
          && 'audit_status_filter;message_filter;message_only;movement_type_filter;minimum_shelf_life_filter;overdue_only;'
          && 'requested_overdue_as_of_filter;requested_on_from_filter;requested_on_to_filter;'
          && 'requested_deadline_only;requested_deadline_from_filter;'
          && 'requested_deadline_to_filter;deadline_age_from_filter;deadline_age_to_filter;'
          && 'deadline_age_date_filter;'
          && 'offset;max_rows;page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;'
          && 'total_rows;material;plant;storage_location;batch;sales_document;sales_document_type;sales_item;'
          && 'schedule_line;requested_on;priority;allocation_unit;order_unit;requested;allocated;shortage;coverage_pct;'
          && 'shortage_pct;allocation_status;reservation_id;reservation_date;reservation_movement_type;'
          && 'reservation_unit;order_id;audit_running_age_seconds;audit_movement_type;'
          && 'audit_min_shelf_life;audit_requested_deadline;audit_deadline_age_days;'
          && 'deadline_age_reference_date'.
      ENDIF.
      RETURN.
    ENDIF.
    WRITE: / 'No allocation results found.'.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    IF p_sum = abap_true.
       CLEAR: lv_full_count,
              lv_partial_count,
              lv_unallocated_count,
              lv_priority_strategy_lines,
              lv_fifo_strategy_lines,
              lv_full_only_strategy_lines,
               lv_smallest_strategy_lines,
               lv_largest_strategy_lines,
               lv_best_strategy_lines,
               lv_legacy_strategy_lines,
              lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_summary_unit,
             lv_mixed_units,
             lv_coverage,
             lv_line_coverage_text,
             lv_line_shortage_text,
              lv_csv_line,
              lv_csv_field,
              lt_csv_fields,
              lt_strategy_totals.
      LOOP AT lt_demands ASSIGNING <ls_demand>.
        IF lv_summary_unit IS INITIAL.
          lv_summary_unit = <ls_demand>-allocation_unit.
        ELSEIF lv_summary_unit <> <ls_demand>-allocation_unit.
          lv_mixed_units = abap_true.
          CLEAR: lv_requested_total,
                 lv_allocated_total,
                 lv_shortage_total.
        ENDIF.
        CASE <ls_demand>-allocation_status.
          WHEN 'F'.
            lv_full_count = lv_full_count + 1.
          WHEN 'P'.
            lv_partial_count = lv_partial_count + 1.
          WHEN 'U'.
            lv_unallocated_count = lv_unallocated_count + 1.
        ENDCASE.
        CASE <ls_demand>-allocation_strategy.
          WHEN 'P'.
            lv_priority_strategy_lines = lv_priority_strategy_lines + 1.
          WHEN 'F'.
            lv_fifo_strategy_lines = lv_fifo_strategy_lines + 1.
          WHEN 'N'.
            lv_full_only_strategy_lines = lv_full_only_strategy_lines + 1.
           WHEN 'S'.
             lv_smallest_strategy_lines = lv_smallest_strategy_lines + 1.
           WHEN 'L'.
             lv_largest_strategy_lines = lv_largest_strategy_lines + 1.
          WHEN 'B'.
          lv_best_strategy_lines = lv_best_strategy_lines + 1.
          WHEN space.
            lv_legacy_strategy_lines = lv_legacy_strategy_lines + 1.
        ENDCASE.
        IF lv_mixed_units = abap_false.
          lv_requested_total = lv_requested_total + <ls_demand>-requested.
          lv_allocated_total = lv_allocated_total + <ls_demand>-allocated.
          lv_shortage_total = lv_shortage_total + <ls_demand>-shortage.
          READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
            WITH TABLE KEY strategy = <ls_demand>-allocation_strategy.
          IF sy-subrc <> 0.
            INSERT VALUE #(
              strategy = <ls_demand>-allocation_strategy )
              INTO TABLE lt_strategy_totals.
            READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
              WITH TABLE KEY strategy = <ls_demand>-allocation_strategy.
          ENDIF.
          <ls_strategy_total>-requested =
            <ls_strategy_total>-requested + <ls_demand>-requested.
          <ls_strategy_total>-allocated =
            <ls_strategy_total>-allocated + <ls_demand>-allocated.
          <ls_strategy_total>-shortage =
            <ls_strategy_total>-shortage + <ls_demand>-shortage.
        ENDIF.
       ENDLOOP.
       CLEAR lv_summary_strategy.
       IF lv_priority_strategy_lines > 0.
         lv_summary_strategy = 'P'.
       ENDIF.
       IF lv_fifo_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'F'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_full_only_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'N'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
        IF lv_smallest_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'S'.
         ELSE.
           lv_summary_strategy = 'mixed'.
          ENDIF.
        ENDIF.
        IF lv_largest_strategy_lines > 0.
          IF lv_summary_strategy IS INITIAL.
            lv_summary_strategy = 'L'.
          ELSE.
            lv_summary_strategy = 'mixed'.
          ENDIF.
        ENDIF.
        IF lv_best_strategy_lines > 0.
          IF lv_summary_strategy IS INITIAL.
            lv_summary_strategy = 'B'.
          ELSE.
            lv_summary_strategy = 'mixed'.
          ENDIF.
        ENDIF.
        IF lv_legacy_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'legacy'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_summary_strategy IS INITIAL.
         lv_summary_strategy = 'n/a'.
       ENDIF.
       CLEAR: lv_priority_requested,
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
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'P'.
       IF sy-subrc = 0.
         lv_priority_requested = <ls_strategy_total>-requested.
         lv_priority_allocated = <ls_strategy_total>-allocated.
         lv_priority_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'F'.
       IF sy-subrc = 0.
         lv_fifo_requested = <ls_strategy_total>-requested.
         lv_fifo_allocated = <ls_strategy_total>-allocated.
         lv_fifo_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'N'.
       IF sy-subrc = 0.
         lv_full_only_requested = <ls_strategy_total>-requested.
         lv_full_only_allocated = <ls_strategy_total>-allocated.
         lv_full_only_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'S'.
        IF sy-subrc = 0.
          lv_smallest_requested = <ls_strategy_total>-requested.
          lv_smallest_allocated = <ls_strategy_total>-allocated.
          lv_smallest_shortage = <ls_strategy_total>-shortage.
        ENDIF.
        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
          WITH TABLE KEY strategy = 'L'.
        IF sy-subrc = 0.
          lv_largest_requested = <ls_strategy_total>-requested.
          lv_largest_allocated = <ls_strategy_total>-allocated.
          lv_largest_shortage = <ls_strategy_total>-shortage.
        ENDIF.

        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
          WITH TABLE KEY strategy = 'B'.
        IF sy-subrc = 0.
          lv_best_requested = <ls_strategy_total>-requested.
          lv_best_allocated = <ls_strategy_total>-allocated.
          lv_best_shortage = <ls_strategy_total>-shortage.
        ENDIF.
        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = space.
       IF sy-subrc = 0.
         lv_legacy_requested = <ls_strategy_total>-requested.
         lv_legacy_allocated = <ls_strategy_total>-allocated.
         lv_legacy_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       IF lv_mixed_units = abap_false.
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
       ENDIF.
       IF lv_mixed_units = abap_true.
        lv_summary_unit = 'mixed'.
        lv_line_coverage_text = 'n/a'.
        lv_line_shortage_text = 'n/a'.
      ELSEIF lv_requested_total > 0.
        lv_coverage = lv_allocated_total * 100 / lv_requested_total.
        lv_shortage_pct = lv_shortage_total * 100 / lv_requested_total.
        lv_line_coverage_text = zcl_stock_csv=>number( lv_coverage ).
        lv_line_shortage_text = zcl_stock_csv=>number( lv_shortage_pct ).
      ELSE.
        CLEAR lv_shortage_pct.
        lv_line_coverage_text = 'n/a'.
        lv_line_shortage_text = 'n/a'.
      ENDIF.
       WRITE: / 'mode;generated_date;generated_time;schema_version;sort;filters_applied;filters;'
         && 'audit_status_filter;message_filter;message_only;movement_type_filter;minimum_shelf_life_filter;overdue_only;'
         && 'requested_overdue_as_of_filter;requested_on_from_filter;requested_on_to_filter;'
         && 'requested_deadline_only;requested_deadline_from_filter;'
         && 'requested_deadline_to_filter;deadline_age_from_filter;deadline_age_to_filter;'
         && 'deadline_age_date_filter;offset;max_rows;'
         && 'page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;total_rows;material;'
         && 'plant;storage_location;batch;unit;mixed_units;strategy_context;result_lines;'
         && 'demand_count;full_count;partial_count;'
         && 'unallocated_count;priority_strategy_lines;fifo_strategy_lines;full_only_strategy_lines;'
         && 'smallest_strategy_lines;largest_strategy_lines;best_strategy_lines;legacy_strategy_lines;'
         && 'priority_requested;priority_allocated;priority_shortage;priority_coverage_pct;fifo_requested;'
         && 'fifo_allocated;fifo_shortage;fifo_coverage_pct;full_only_requested;full_only_allocated;'
         && 'full_only_shortage;full_only_coverage_pct;smallest_requested;smallest_allocated;smallest_shortage;'
         && 'smallest_coverage_pct;largest_requested;largest_allocated;largest_shortage;largest_coverage_pct;'
         && 'best_requested;best_allocated;best_shortage;best_coverage_pct;legacy_requested;legacy_allocated;'
         && 'legacy_shortage;legacy_coverage_pct;requested;allocated;shortage;coverage_pct;shortage_pct;'
         && 'audit_movement_type;audit_min_shelf_life;audit_requested_deadline;'
         && 'audit_deadline_age_days;deadline_age_reference_date'.
      APPEND 'summary' TO lt_csv_fields.
      APPEND sy-datum TO lt_csv_fields.
      APPEND sy-uzeit TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 32 ) TO lt_csv_fields.
      APPEND lv_sort_mode TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
       ENDIF.
       APPEND lv_filter_names_text TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_audit_status_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_message_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_message_only_text ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_overdue_as_of_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_to_filter ) TO lt_csv_fields.
      APPEND lv_deadline_only_text TO lt_csv_fields.
      APPEND lv_deadline_from_filter TO lt_csv_fields.
      APPEND lv_deadline_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_from_filter TO lt_csv_fields.
      APPEND lv_deadline_age_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_date_filter TO lt_csv_fields.
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
      IF lv_mixed_units = abap_true.
        APPEND 'true' TO lt_csv_fields.
       ELSE.
         APPEND 'false' TO lt_csv_fields.
       ENDIF.
       APPEND lv_summary_strategy TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lines( lt_demands ) ).
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_full_count ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( lv_partial_count ).
      APPEND lv_csv_field TO lt_csv_fields.
       lv_csv_field = zcl_stock_csv=>number( lv_unallocated_count ).
       APPEND lv_csv_field TO lt_csv_fields.
       lv_csv_field = zcl_stock_csv=>number( lv_priority_strategy_lines ).
       APPEND lv_csv_field TO lt_csv_fields.
       lv_csv_field = zcl_stock_csv=>number( lv_fifo_strategy_lines ).
       APPEND lv_csv_field TO lt_csv_fields.
       lv_csv_field = zcl_stock_csv=>number( lv_full_only_strategy_lines ).
       APPEND lv_csv_field TO lt_csv_fields.
        lv_csv_field = zcl_stock_csv=>number( lv_smallest_strategy_lines ).
        APPEND lv_csv_field TO lt_csv_fields.
         lv_csv_field = zcl_stock_csv=>number( lv_largest_strategy_lines ).
         APPEND lv_csv_field TO lt_csv_fields.
         lv_csv_field = zcl_stock_csv=>number( lv_best_strategy_lines ).
         APPEND lv_csv_field TO lt_csv_fields.
          lv_csv_field = zcl_stock_csv=>number( lv_legacy_strategy_lines ).
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
         lv_csv_field = zcl_stock_csv=>number( lv_requested_total ).
        APPEND lv_csv_field TO lt_csv_fields.
        lv_csv_field = zcl_stock_csv=>number( lv_allocated_total ).
        APPEND lv_csv_field TO lt_csv_fields.
        lv_csv_field = zcl_stock_csv=>number( lv_shortage_total ).
        APPEND lv_csv_field TO lt_csv_fields.
      ENDIF.
      APPEND lv_line_coverage_text TO lt_csv_fields.
      APPEND lv_line_shortage_text TO lt_csv_fields.
      IF lv_exact_audit_available = abap_true.
        APPEND lv_audit_movement_type TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_audit_min_shelf_life )
          TO lt_csv_fields.
        APPEND lv_audit_requested_deadline TO lt_csv_fields.
        APPEND lv_audit_deadline_age_text TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_deadline_reference_date )
        TO lt_csv_fields.
      LOOP AT lt_csv_fields ASSIGNING <lv_csv_field>.
        <lv_csv_field> = zcl_stock_csv=>quote( <lv_csv_field> ).
      ENDLOOP.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    lv_csv_line = 'allocation_run_id;strategy;generated_date;generated_time;schema_version;sort;filters_applied;'
      && 'filters;audit_status_filter;message_filter;message_only;movement_type_filter;minimum_shelf_life_filter;overdue_only;'
      && 'requested_overdue_as_of_filter;requested_on_from_filter;requested_on_to_filter;'
      && 'requested_deadline_only;requested_deadline_from_filter;'
      && 'requested_deadline_to_filter;deadline_age_from_filter;deadline_age_to_filter;'
      && 'deadline_age_date_filter;'
      && 'offset;max_rows;page_number;page_count;last_offset;has_previous;previous_offset;has_more;next_offset;'
      && 'total_rows;material;plant;storage_location;batch;sales_document;sales_document_type;sales_item;'
      && 'schedule_line;requested_on;priority;allocation_unit;order_unit;requested;allocated;shortage;coverage_pct;'
      && 'shortage_pct;allocation_status;reservation_id;reservation_date;reservation_movement_type;'
      && 'reservation_unit;order_id;audit_running_age_seconds;audit_movement_type;'
      && 'audit_min_shelf_life;audit_requested_deadline;audit_deadline_age_days;'
      && 'deadline_age_reference_date'.
    WRITE: / lv_csv_line.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      CLEAR: lv_line_coverage,
             lv_line_coverage_text,
             lv_shortage_pct,
             lv_line_shortage_text,
             lv_csv_line,
             lv_csv_field,
             lt_csv_fields.
      IF <ls_demand>-requested > 0.
        lv_line_coverage = <ls_demand>-allocated * 100
          / <ls_demand>-requested.
        lv_line_coverage_text = zcl_stock_csv=>number( lv_line_coverage ).
        lv_shortage_pct = <ls_demand>-shortage * 100
          / <ls_demand>-requested.
        lv_line_shortage_text = zcl_stock_csv=>number( lv_shortage_pct ).
      ELSE.
        CLEAR lv_shortage_pct.
        lv_line_coverage_text = 'n/a'.
        lv_line_shortage_text = 'n/a'.
      ENDIF.
      WRITE <ls_demand>-allocation_run_id TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-allocation_strategy TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 30 ) TO lt_csv_fields.
      APPEND lv_sort_mode TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
       ENDIF.
       APPEND lv_filter_names_text TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_audit_status_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_message_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_message_only_text ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_overdue_as_of_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_to_filter ) TO lt_csv_fields.
      APPEND lv_deadline_only_text TO lt_csv_fields.
      APPEND lv_deadline_from_filter TO lt_csv_fields.
      APPEND lv_deadline_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_from_filter TO lt_csv_fields.
      APPEND lv_deadline_age_to_filter TO lt_csv_fields.
      APPEND lv_deadline_age_date_filter TO lt_csv_fields.
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
      WRITE <ls_demand>-sales_document TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-sales_document_type TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-sales_item TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-schedule_line TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-requested_on TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_demand>-priority ).
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-allocation_unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-order_unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_demand>-requested ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_demand>-allocated ).
      APPEND lv_csv_field TO lt_csv_fields.
      lv_csv_field = zcl_stock_csv=>number( <ls_demand>-shortage ).
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_line_coverage_text TO lt_csv_fields.
      APPEND lv_line_shortage_text TO lt_csv_fields.
      WRITE <ls_demand>-allocation_status TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-reservation_id TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-reservation_date TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-reservation_movement_type TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-reservation_unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-order_id TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_audit_running_age_text TO lt_csv_fields.
      IF lv_exact_audit_available = abap_true.
        APPEND lv_audit_movement_type TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( lv_audit_min_shelf_life )
          TO lt_csv_fields.
        APPEND lv_audit_requested_deadline TO lt_csv_fields.
        APPEND lv_audit_deadline_age_text TO lt_csv_fields.
      ELSE.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
        APPEND 'n/a' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_deadline_reference_date )
        TO lt_csv_fields.
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
      CLEAR: lv_full_count,
             lv_partial_count,
             lv_unallocated_count,
             lv_priority_strategy_lines,
             lv_fifo_strategy_lines,
             lv_full_only_strategy_lines,
             lv_smallest_strategy_lines,
             lv_largest_strategy_lines,
             lv_best_strategy_lines,
             lv_legacy_strategy_lines,
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_summary_unit,
             lv_mixed_units,
             lv_coverage,
             lv_shortage_pct,
             lv_line_coverage_text,
             lv_line_shortage_text,
             lt_json_fields,
             lt_strategy_totals.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 32 ) TO lt_json_fields.
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
          iv_name  = 'deadline_age_reference_date'
          iv_value = lv_deadline_reference_date ) TO lt_json_fields.
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
        APPEND zcl_stock_json=>object_property(
          iv_name   = 'filter_values'
          it_fields = lt_filter_value_fields ) TO lt_json_fields.
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
      LOOP AT lt_demands ASSIGNING <ls_demand>.
        IF lv_summary_unit IS INITIAL.
          lv_summary_unit = <ls_demand>-allocation_unit.
        ELSEIF lv_summary_unit <> <ls_demand>-allocation_unit.
          lv_mixed_units = abap_true.
          CLEAR: lv_requested_total,
                 lv_allocated_total,
                 lv_shortage_total.
        ENDIF.
        CASE <ls_demand>-allocation_status.
          WHEN 'F'.
            lv_full_count = lv_full_count + 1.
          WHEN 'P'.
            lv_partial_count = lv_partial_count + 1.
          WHEN 'U'.
            lv_unallocated_count = lv_unallocated_count + 1.
        ENDCASE.
        CASE <ls_demand>-allocation_strategy.
          WHEN 'P'.
            lv_priority_strategy_lines = lv_priority_strategy_lines + 1.
          WHEN 'F'.
            lv_fifo_strategy_lines = lv_fifo_strategy_lines + 1.
          WHEN 'N'.
            lv_full_only_strategy_lines = lv_full_only_strategy_lines + 1.
           WHEN 'S'.
             lv_smallest_strategy_lines = lv_smallest_strategy_lines + 1.
           WHEN 'L'.
             lv_largest_strategy_lines = lv_largest_strategy_lines + 1.
           WHEN 'B'.
           lv_best_strategy_lines = lv_best_strategy_lines + 1.
           WHEN space.
            lv_legacy_strategy_lines = lv_legacy_strategy_lines + 1.
        ENDCASE.
        IF lv_mixed_units = abap_false.
          lv_requested_total = lv_requested_total + <ls_demand>-requested.
          lv_allocated_total = lv_allocated_total + <ls_demand>-allocated.
          lv_shortage_total = lv_shortage_total + <ls_demand>-shortage.
          READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
            WITH TABLE KEY strategy = <ls_demand>-allocation_strategy.
          IF sy-subrc <> 0.
            INSERT VALUE #(
              strategy = <ls_demand>-allocation_strategy )
              INTO TABLE lt_strategy_totals.
            READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
              WITH TABLE KEY strategy = <ls_demand>-allocation_strategy.
          ENDIF.
          <ls_strategy_total>-requested =
            <ls_strategy_total>-requested + <ls_demand>-requested.
          <ls_strategy_total>-allocated =
            <ls_strategy_total>-allocated + <ls_demand>-allocated.
          <ls_strategy_total>-shortage =
            <ls_strategy_total>-shortage + <ls_demand>-shortage.
        ENDIF.
       ENDLOOP.
       CLEAR lv_summary_strategy.
       IF lv_priority_strategy_lines > 0.
         lv_summary_strategy = 'P'.
       ENDIF.
       IF lv_fifo_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'F'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_full_only_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'N'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_smallest_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'S'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_largest_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'L'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_best_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'B'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_legacy_strategy_lines > 0.
         IF lv_summary_strategy IS INITIAL.
           lv_summary_strategy = 'legacy'.
         ELSE.
           lv_summary_strategy = 'mixed'.
         ENDIF.
       ENDIF.
       IF lv_summary_strategy IS INITIAL.
         lv_summary_strategy = 'n/a'.
       ENDIF.
       CLEAR: lv_priority_requested,
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
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'P'.
       IF sy-subrc = 0.
         lv_priority_requested = <ls_strategy_total>-requested.
         lv_priority_allocated = <ls_strategy_total>-allocated.
         lv_priority_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'F'.
       IF sy-subrc = 0.
         lv_fifo_requested = <ls_strategy_total>-requested.
         lv_fifo_allocated = <ls_strategy_total>-allocated.
         lv_fifo_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'N'.
       IF sy-subrc = 0.
         lv_full_only_requested = <ls_strategy_total>-requested.
         lv_full_only_allocated = <ls_strategy_total>-allocated.
         lv_full_only_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = 'S'.
        IF sy-subrc = 0.
          lv_smallest_requested = <ls_strategy_total>-requested.
          lv_smallest_allocated = <ls_strategy_total>-allocated.
          lv_smallest_shortage = <ls_strategy_total>-shortage.
        ENDIF.
        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
          WITH TABLE KEY strategy = 'L'.
        IF sy-subrc = 0.
          lv_largest_requested = <ls_strategy_total>-requested.
          lv_largest_allocated = <ls_strategy_total>-allocated.
          lv_largest_shortage = <ls_strategy_total>-shortage.
        ENDIF.

        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
          WITH TABLE KEY strategy = 'B'.
        IF sy-subrc = 0.
          lv_best_requested = <ls_strategy_total>-requested.
          lv_best_allocated = <ls_strategy_total>-allocated.
          lv_best_shortage = <ls_strategy_total>-shortage.
        ENDIF.
        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
         WITH TABLE KEY strategy = space.
       IF sy-subrc = 0.
         lv_legacy_requested = <ls_strategy_total>-requested.
         lv_legacy_allocated = <ls_strategy_total>-allocated.
         lv_legacy_shortage = <ls_strategy_total>-shortage.
       ENDIF.
       IF lv_mixed_units = abap_false.
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
       ENDIF.
       APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'summary' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'mixed_units'
        iv_value = lv_mixed_units ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'strategy_context'
        iv_value = lv_summary_strategy ) TO lt_json_fields.
      IF p_meta = abap_true OR p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'result_lines'
          iv_value = lines( lt_demands ) ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'demand_count'
          iv_value = lines( lt_demands ) ) TO lt_json_fields.
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
          iv_name  = 'priority_strategy_lines'
          iv_value = lv_priority_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fifo_strategy_lines'
          iv_value = lv_fifo_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'full_only_strategy_lines'
          iv_value = lv_full_only_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'smallest_strategy_lines'
          iv_value = lv_smallest_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'largest_strategy_lines'
          iv_value = lv_largest_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'best_strategy_lines'
          iv_value = lv_best_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'legacy_strategy_lines'
          iv_value = lv_legacy_strategy_lines ) TO lt_json_fields.
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
            iv_name  = 'fifo_requested'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'fifo_allocated'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'fifo_shortage'
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
            iv_name  = 'smallest_requested'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'smallest_allocated'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'smallest_shortage'
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
        ELSE.
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
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'result_lines'
          iv_value = lines( lt_demands ) ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'demand_count'
          iv_value = lines( lt_demands ) ) TO lt_json_fields.
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
          iv_name  = 'priority_strategy_lines'
          iv_value = lv_priority_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fifo_strategy_lines'
          iv_value = lv_fifo_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'full_only_strategy_lines'
          iv_value = lv_full_only_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'smallest_strategy_lines'
          iv_value = lv_smallest_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'largest_strategy_lines'
          iv_value = lv_largest_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'best_strategy_lines'
          iv_value = lv_best_strategy_lines ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'legacy_strategy_lines'
          iv_value = lv_legacy_strategy_lines ) TO lt_json_fields.
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
            iv_name  = 'fifo_requested'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'fifo_allocated'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'fifo_shortage'
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
            iv_name  = 'smallest_requested'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'smallest_allocated'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'smallest_shortage'
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
      ENDIF.
      IF lv_mixed_units = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = 'mixed' ) TO lt_json_fields.
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
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage_pct'
          iv_value = 'n/a' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = lv_summary_unit ) TO lt_json_fields.
        IF p_meta = abap_true OR p_typed = abap_true.
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
          lv_shortage_pct = lv_shortage_total * 100 / lv_requested_total.
          lv_line_coverage_text = lv_coverage.
          lv_line_shortage_text = lv_shortage_pct.
        ELSE.
          lv_line_coverage_text = 'n/a'.
          lv_line_shortage_text = 'n/a'.
        ENDIF.
        IF ( p_meta = abap_true OR p_typed = abap_true )
            AND lv_requested_total > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_coverage ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'coverage_pct'
            iv_value = lv_line_coverage_text ) TO lt_json_fields.
        ENDIF.
        IF ( p_meta = abap_true OR p_typed = abap_true )
            AND lv_requested_total > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'shortage_pct'
            iv_value = lv_shortage_pct ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'shortage_pct'
            iv_value = lv_line_shortage_text ) TO lt_json_fields.
        ENDIF.
        IF lv_exact_audit_available = abap_true.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_movement_type'
            iv_value = lv_audit_movement_type ) TO lt_json_fields.
          IF p_meta = abap_true OR p_typed = abap_true.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_min_shelf_life'
              iv_value = lv_audit_min_shelf_life ) TO lt_json_fields.
          ELSE.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_min_shelf_life'
              iv_value = lv_audit_min_shelf_life ) TO lt_json_fields.
          ENDIF.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_requested_deadline'
            iv_value = lv_audit_requested_deadline ) TO lt_json_fields.
          APPEND zcl_stock_json=>filter_number_property(
            iv_name    = 'audit_deadline_age_days'
            iv_value   = lv_audit_deadline_age_days
            iv_text    = lv_audit_deadline_age_text
            iv_present = xsdbool( lv_audit_deadline_age_text <> 'n/a' )
            iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
            TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_movement_type'
            iv_value = 'n/a' ) TO lt_json_fields.
          IF p_meta = abap_true OR p_typed = abap_true.
            APPEND zcl_stock_json=>null_property(
              iv_name = 'audit_min_shelf_life' ) TO lt_json_fields.
          ELSE.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_min_shelf_life'
              iv_value = 'n/a' ) TO lt_json_fields.
          ENDIF.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_requested_deadline'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>filter_number_property(
            iv_name    = 'audit_deadline_age_days'
            iv_value   = lv_audit_deadline_age_days
            iv_text    = 'n/a'
            iv_present = abap_false
            iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
            TO lt_json_fields.
        ENDIF.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_status_filter'
        iv_value = lv_audit_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'movement_type_filter'
        iv_value = lv_movement_filter ) TO lt_json_fields.
      IF p_typed = abap_true OR p_meta = abap_true.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shelf_life_filter'
          iv_value   = p_shelf
          iv_text    = lv_min_shelf_filter
          iv_present = xsdbool( p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_shelf_life_filter'
          iv_value = lv_min_shelf_filter ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'overdue_only'
        iv_value = p_ovrd ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_overdue_as_of_filter'
        iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from_filter'
        iv_value = lv_requested_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to_filter'
        iv_value = lv_requested_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'requested_deadline_only'
        iv_value = p_dead ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_deadline_from_filter'
        iv_value = lv_deadline_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_deadline_to_filter'
        iv_value = lv_deadline_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'deadline_age_from_filter'
        iv_value   = p_dagef
        iv_text    = lv_deadline_age_from_filter
        iv_present = xsdbool( p_dagef IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
        TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'deadline_age_to_filter'
        iv_value   = p_daget
        iv_text    = lv_deadline_age_to_filter
        iv_present = xsdbool( p_daget IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
        TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_date_filter'
        iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
      IF p_meta = abap_true.
        CONCATENATE LINES OF lt_json_fields INTO lv_summary_json
          SEPARATED BY ','.
        CLEAR lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'mode'
          iv_value = 'summary' ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 32 ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_date'
          iv_value = sy-datum ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_time'
          iv_value = sy-uzeit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'deadline_age_reference_date'
          iv_value = lv_deadline_reference_date ) TO lt_json_fields.
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
          iv_name  = 'audit_status_filter'
          iv_value = lv_audit_status_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'movement_type_filter'
          iv_value = lv_movement_filter ) TO lt_json_fields.
        IF p_typed = abap_true OR p_meta = abap_true.
          APPEND zcl_stock_json=>filter_number_property(
            iv_name    = 'minimum_shelf_life_filter'
            iv_value   = p_shelf
            iv_text    = lv_min_shelf_filter
            iv_present = xsdbool( p_shelf IS NOT INITIAL )
            iv_typed   = abap_true ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'minimum_shelf_life_filter'
            iv_value = lv_min_shelf_filter ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'overdue_only'
          iv_value = p_ovrd ) TO lt_json_fields.
         APPEND zcl_stock_json=>property(
           iv_name  = 'requested_overdue_as_of_filter'
           iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
         APPEND zcl_stock_json=>property(
           iv_name  = 'requested_on_from_filter'
           iv_value = lv_requested_from_filter ) TO lt_json_fields.
         APPEND zcl_stock_json=>property(
           iv_name  = 'requested_on_to_filter'
           iv_value = lv_requested_to_filter ) TO lt_json_fields.
         APPEND zcl_stock_json=>boolean_property(
           iv_name  = 'requested_deadline_only'
           iv_value = p_dead ) TO lt_json_fields.
         APPEND zcl_stock_json=>property(
           iv_name  = 'requested_deadline_from_filter'
           iv_value = lv_deadline_from_filter ) TO lt_json_fields.
         APPEND zcl_stock_json=>property(
           iv_name  = 'requested_deadline_to_filter'
           iv_value = lv_deadline_to_filter ) TO lt_json_fields.
         APPEND zcl_stock_json=>filter_number_property(
           iv_name    = 'deadline_age_from_filter'
           iv_value   = p_dagef
           iv_text    = lv_deadline_age_from_filter
           iv_present = xsdbool( p_dagef IS NOT INITIAL )
           iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
           TO lt_json_fields.
         APPEND zcl_stock_json=>filter_number_property(
           iv_name    = 'deadline_age_to_filter'
           iv_value   = p_daget
           iv_text    = lv_deadline_age_to_filter
           iv_present = xsdbool( p_daget IS NOT INITIAL )
           iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
           TO lt_json_fields.
         APPEND zcl_stock_json=>property(
           iv_name  = 'deadline_age_date_filter'
           iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>object_property(
          iv_name   = 'filter_values'
          it_fields = lt_filter_value_fields ) TO lt_json_fields.
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
          CLEAR lt_runs.
          CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
            EXPORTING
              io_read_authority = lo_authority.
          TRY.
              lt_runs = lo_audit->get_runs(
                iv_material          = p_matnr
                iv_plant             = p_werks
                iv_storage_location  = p_lgort
                iv_batch             = p_charg
                iv_run_id            = p_runid
                iv_deadline_only     = p_dead
                iv_requested_on_from = p_reqf
                iv_requested_on_to   = p_until ).
            CATCH zcx_stock_allocation.
              CLEAR lt_runs.
          ENDTRY.
          READ TABLE lt_runs ASSIGNING <ls_run> INDEX 1.
          IF sy-subrc <> 0.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_context'
              iv_value = 'unavailable' ) TO lt_json_fields.
          ELSE.
            CLEAR: lv_audit_duration_seconds,
                   lv_audit_duration_text.
            IF <ls_run>-finish_date IS INITIAL.
              lv_audit_duration_text = 'n/a'.
            ELSE.
              cl_abap_tstmp=>td_subtract(
                EXPORTING
                  date1    = <ls_run>-finish_date
                  time1    = <ls_run>-finish_time
                  date2    = <ls_run>-start_date
                  time2    = <ls_run>-start_time
                IMPORTING
                  res_secs = lv_audit_duration_seconds ).
              lv_audit_duration_text = lv_audit_duration_seconds.
            ENDIF.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_context'
              iv_value = 'available' ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_status'
              iv_value = <ls_run>-status ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_strategy'
              iv_value = <ls_run>-strategy ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_movement_type'
              iv_value = <ls_run>-movement_type ) TO lt_json_fields.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_min_shelf_life'
              iv_value = <ls_run>-min_shelf_life ) TO lt_json_fields.
            APPEND zcl_stock_json=>property(
              iv_name  = 'audit_requested_deadline'
              iv_value = <ls_run>-requested_deadline ) TO lt_json_fields.
            APPEND zcl_stock_json=>filter_number_property(
              iv_name    = 'audit_deadline_age_days'
              iv_value   = lv_audit_deadline_age_days
              iv_text    = lv_audit_deadline_age_text
              iv_present = xsdbool( lv_audit_deadline_age_text <> 'n/a' )
              iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
              TO lt_json_fields.
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
            IF <ls_run>-finish_date IS INITIAL.
              APPEND zcl_stock_json=>null_property(
                iv_name = 'audit_duration_seconds' ) TO lt_json_fields.
            ELSE.
              APPEND zcl_stock_json=>number_property(
                iv_name  = 'audit_duration_seconds'
                iv_value = lv_audit_duration_seconds ) TO lt_json_fields.
            ENDIF.
            ls_audit_running_age = lo_audit->get_running_age( <ls_run> ).
            IF ls_audit_running_age-available = abap_true.
              lv_audit_running_age_seconds = ls_audit_running_age-seconds.
                APPEND zcl_stock_json=>number_property(
                  iv_name  = 'audit_running_age_seconds'
                  iv_value = lv_audit_running_age_seconds ) TO lt_json_fields.
            ELSE.
              APPEND zcl_stock_json=>null_property(
                iv_name = 'audit_running_age_seconds' ) TO lt_json_fields.
            ENDIF.
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
          iv_value = lines( lt_demands ) ) TO lt_json_fields.
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
      CLEAR lv_audit_context_available.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'detail' ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 30 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_reference_date'
        iv_value = lv_deadline_reference_date ) TO lt_json_fields.
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
        iv_name  = 'audit_status_filter'
        iv_value = lv_audit_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'movement_type_filter'
        iv_value = lv_movement_filter ) TO lt_json_fields.
      IF p_typed = abap_true OR p_meta = abap_true.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shelf_life_filter'
          iv_value   = p_shelf
          iv_text    = lv_min_shelf_filter
          iv_present = xsdbool( p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_shelf_life_filter'
          iv_value = lv_min_shelf_filter ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'overdue_only'
        iv_value = p_ovrd ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_overdue_as_of_filter'
        iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from_filter'
        iv_value = lv_requested_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to_filter'
        iv_value = lv_requested_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'requested_deadline_only'
        iv_value = p_dead ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_deadline_from_filter'
        iv_value = lv_deadline_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_deadline_to_filter'
        iv_value = lv_deadline_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'deadline_age_from_filter'
        iv_value   = p_dagef
        iv_text    = lv_deadline_age_from_filter
        iv_present = xsdbool( p_dagef IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
        TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'deadline_age_to_filter'
        iv_value   = p_daget
        iv_text    = lv_deadline_age_to_filter
        iv_present = xsdbool( p_daget IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
        TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_date_filter'
        iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_filter_value_fields ) TO lt_json_fields.
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
        CLEAR lt_runs.
        CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
          EXPORTING
            io_read_authority = lo_authority.
        TRY.
            lt_runs = lo_audit->get_runs(
              iv_material          = p_matnr
              iv_plant             = p_werks
              iv_storage_location  = p_lgort
              iv_batch             = p_charg
              iv_run_id            = p_runid
              iv_deadline_only     = p_dead
              iv_requested_on_from = p_reqf
              iv_requested_on_to   = p_until ).
          CATCH zcx_stock_allocation.
            CLEAR lt_runs.
        ENDTRY.
        READ TABLE lt_runs ASSIGNING <ls_run> INDEX 1.
        IF sy-subrc <> 0.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_context'
            iv_value = 'unavailable' ) TO lt_json_fields.
        ELSE.
          lv_audit_context_available = abap_true.
          CLEAR: lv_audit_duration_seconds,
                 lv_audit_duration_text.
          IF <ls_run>-finish_date IS INITIAL.
            lv_audit_duration_text = 'n/a'.
          ELSE.
            cl_abap_tstmp=>td_subtract(
              EXPORTING
                date1    = <ls_run>-finish_date
                time1    = <ls_run>-finish_time
                date2    = <ls_run>-start_date
                time2    = <ls_run>-start_time
              IMPORTING
                res_secs = lv_audit_duration_seconds ).
            lv_audit_duration_text = lv_audit_duration_seconds.
          ENDIF.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_context'
            iv_value = 'available' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_status'
            iv_value = <ls_run>-status ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_strategy'
            iv_value = <ls_run>-strategy ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_movement_type'
            iv_value = <ls_run>-movement_type ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = <ls_run>-min_shelf_life ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_requested_deadline'
            iv_value = <ls_run>-requested_deadline ) TO lt_json_fields.
          APPEND zcl_stock_json=>filter_number_property(
            iv_name    = 'audit_deadline_age_days'
            iv_value   = lv_audit_deadline_age_days
            iv_text    = lv_audit_deadline_age_text
            iv_present = xsdbool( lv_audit_deadline_age_text <> 'n/a' )
            iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
            TO lt_json_fields.
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
          IF <ls_run>-finish_date IS INITIAL.
            APPEND zcl_stock_json=>null_property(
              iv_name = 'audit_duration_seconds' ) TO lt_json_fields.
          ELSE.
            APPEND zcl_stock_json=>number_property(
              iv_name  = 'audit_duration_seconds'
              iv_value = lv_audit_duration_seconds ) TO lt_json_fields.
          ENDIF.
          ls_audit_running_age = lo_audit->get_running_age( <ls_run> ).
          IF ls_audit_running_age-available = abap_true.
            lv_audit_running_age_seconds = ls_audit_running_age-seconds.
              APPEND zcl_stock_json=>number_property(
                iv_name  = 'audit_running_age_seconds'
                iv_value = lv_audit_running_age_seconds ) TO lt_json_fields.
          ELSE.
            APPEND zcl_stock_json=>null_property(
              iv_name = 'audit_running_age_seconds' ) TO lt_json_fields.
          ENDIF.
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
      IF p_runid IS INITIAL.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reconciliation'
          iv_value = 'not_requested' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reconciliation_fields'
          iv_value = 'not_requested' ) TO lt_json_fields.
      ELSEIF p_meins IS INITIAL
          AND p_rid IS INITIAL
          AND p_stat IS INITIAL
          AND p_vbeln IS INITIAL
          AND p_auart IS INITIAL
          AND p_posnr IS INITIAL
          AND p_etenr IS INITIAL
          AND p_ounit IS INITIAL
          AND p_order IS INITIAL
          AND p_resid IS INITIAL
          AND p_rmov IS INITIAL
          AND p_runit IS INITIAL
          AND p_rsv IS INITIAL
          AND p_unrsv IS INITIAL
          AND p_bklg IS INITIAL
          AND p_ovrd IS INITIAL
          AND p_rfrom IS INITIAL
          AND p_rto IS INITIAL
          AND p_rage IS INITIAL
          AND p_from IS INITIAL
          AND p_to IS INITIAL
          AND p_priof IS INITIAL
          AND p_priot IS INITIAL
          AND p_shf IS INITIAL
          AND p_sht IS INITIAL
          AND p_qf IS INITIAL
          AND p_qt IS INITIAL
          AND p_af IS INITIAL
          AND p_at IS INITIAL
          AND p_max IS INITIAL
          AND p_skip IS INITIAL.
        IF lv_audit_context_available = abap_false.
          APPEND zcl_stock_json=>property(
            iv_name  = 'reconciliation'
            iv_value = 'unavailable' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'reconciliation_fields'
            iv_value = 'unavailable' ) TO lt_json_fields.
        ELSE.
          ls_reconciliation = lo_compare->reconcile(
            it_snapshot = lt_demands
            is_audit    = <ls_run> ).
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_demand_count'
            iv_value = ls_reconciliation-snapshot_rows ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_full_count'
            iv_value = ls_reconciliation-snapshot_full_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_partial_count'
            iv_value = ls_reconciliation-snapshot_partial_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_unallocated_count'
            iv_value = ls_reconciliation-snapshot_unallocated_count ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_requested'
            iv_value = ls_reconciliation-snapshot_requested ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_allocated'
            iv_value = ls_reconciliation-snapshot_allocated ) TO lt_json_fields.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'snapshot_shortage'
            iv_value = ls_reconciliation-snapshot_shortage ) TO lt_json_fields.
          CLEAR: lv_full_count,
                 lv_partial_count,
                 lv_unallocated_count,
                 lv_requested_total,
                 lv_allocated_total,
                 lv_shortage_total,
                 lv_summary_unit,
                 lv_mixed_units,
                 lv_reconcile_ok.
          LOOP AT lt_demands ASSIGNING <ls_demand>.
            IF lv_summary_unit IS INITIAL.
              lv_summary_unit = <ls_demand>-allocation_unit.
            ELSEIF lv_summary_unit <> <ls_demand>-allocation_unit.
              lv_mixed_units = abap_true.
            ENDIF.
            CASE <ls_demand>-allocation_status.
              WHEN 'F'.
                lv_full_count = lv_full_count + 1.
              WHEN 'P'.
                lv_partial_count = lv_partial_count + 1.
              WHEN 'U'.
                lv_unallocated_count = lv_unallocated_count + 1.
            ENDCASE.
            lv_requested_total = lv_requested_total + <ls_demand>-requested.
            lv_allocated_total = lv_allocated_total + <ls_demand>-allocated.
            lv_shortage_total = lv_shortage_total + <ls_demand>-shortage.
          ENDLOOP.
          IF lines( lt_demands ) = <ls_run>-demand_count
              AND lv_full_count = <ls_run>-full_count
              AND lv_partial_count = <ls_run>-partial_count
              AND lv_unallocated_count = <ls_run>-unallocated_count
              AND lv_requested_total = <ls_run>-requested
              AND lv_allocated_total = <ls_run>-allocated
              AND lv_shortage_total = <ls_run>-shortage.
            lv_reconcile_ok = abap_true.
          ENDIF.
          IF lv_reconcile_ok = abap_true.
            APPEND zcl_stock_json=>property(
              iv_name  = 'reconciliation'
              iv_value = 'OK' ) TO lt_json_fields.
          ELSE.
            APPEND zcl_stock_json=>property(
              iv_name  = 'reconciliation'
              iv_value = 'MISMATCH' ) TO lt_json_fields.
          ENDIF.
          APPEND zcl_stock_json=>property(
            iv_name  = 'reconciliation_fields'
            iv_value = ls_reconciliation-mismatch_fields ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reconciliation'
          iv_value = 'filtered' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reconciliation_fields'
          iv_value = 'filtered' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'row_count'
        iv_value = lines( lt_demands ) ) TO lt_json_fields.
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
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      lv_row_index = sy-tabix.
      CLEAR: lv_line_coverage,
             lv_line_coverage_text,
             lv_shortage_pct,
             lv_line_shortage_text,
             lv_numeric_json,
             lv_json_line,
             lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 30 ) TO lt_json_fields.
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
          iv_name  = 'deadline_age_reference_date'
          iv_value = lv_deadline_reference_date ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sort'
          iv_value = lv_sort_mode ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'filters_applied'
          iv_value = lv_filters_applied ) TO lt_json_fields.
        APPEND zcl_stock_json=>string_array_property(
          iv_name   = 'filters'
          it_values = lt_filter_names ) TO lt_json_fields.
        APPEND zcl_stock_json=>object_property(
          iv_name   = 'filter_values'
          it_fields = lt_filter_value_fields ) TO lt_json_fields.
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
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_status_filter'
        iv_value = lv_audit_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'movement_type_filter'
        iv_value = lv_movement_filter ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shelf_life_filter'
          iv_value   = p_shelf
          iv_text    = lv_min_shelf_filter
          iv_present = xsdbool( p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_shelf_life_filter'
          iv_value = lv_min_shelf_filter ) TO lt_json_fields.
      ENDIF.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'overdue_only'
          iv_value = p_ovrd ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_overdue_as_of_filter'
          iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_on_from_filter'
          iv_value = lv_requested_from_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_on_to_filter'
          iv_value = lv_requested_to_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'requested_deadline_only'
          iv_value = p_dead ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_deadline_from_filter'
          iv_value = lv_deadline_from_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_deadline_to_filter'
          iv_value = lv_deadline_to_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'deadline_age_from_filter'
          iv_value   = p_dagef
          iv_text    = lv_deadline_age_from_filter
          iv_present = xsdbool( p_dagef IS NOT INITIAL )
          iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
          TO lt_json_fields.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'deadline_age_to_filter'
          iv_value   = p_daget
          iv_text    = lv_deadline_age_to_filter
          iv_present = xsdbool( p_daget IS NOT INITIAL )
          iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
          TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'deadline_age_date_filter'
          iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
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
      IF <ls_demand>-requested > 0.
        lv_line_coverage = <ls_demand>-allocated * 100
          / <ls_demand>-requested.
        lv_line_coverage_text = lv_line_coverage.
        lv_shortage_pct = <ls_demand>-shortage * 100
          / <ls_demand>-requested.
        lv_line_shortage_text = lv_shortage_pct.
      ELSE.
        CLEAR lv_shortage_pct.
        lv_line_coverage_text = 'n/a'.
        lv_line_shortage_text = 'n/a'.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_run_id'
        iv_value = <ls_demand>-allocation_run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'strategy'
        iv_value = <ls_demand>-allocation_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sales_document'
        iv_value = <ls_demand>-sales_document ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sales_document_type'
        iv_value = <ls_demand>-sales_document_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sales_item'
        iv_value = <ls_demand>-sales_item ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'schedule_line'
        iv_value = <ls_demand>-schedule_line ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on'
        iv_value = <ls_demand>-requested_on ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority'
          iv_value = <ls_demand>-priority ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority'
          iv_value = <ls_demand>-priority ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_unit'
        iv_value = <ls_demand>-allocation_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'order_unit'
        iv_value = <ls_demand>-order_unit ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'requested'
          iv_value = <ls_demand>-requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'allocated'
          iv_value = <ls_demand>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'shortage'
          iv_value = <ls_demand>-shortage ) TO lt_json_fields.
        IF <ls_demand>-requested > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_line_coverage ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'coverage_pct' ) TO lt_json_fields.
        ENDIF.
        IF <ls_demand>-requested > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'shortage_pct'
            iv_value = lv_shortage_pct ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'shortage_pct' ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested'
          iv_value = <ls_demand>-requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocated'
          iv_value = <ls_demand>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage'
          iv_value = <ls_demand>-shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = lv_line_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage_pct'
          iv_value = lv_line_shortage_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_status'
        iv_value = <ls_demand>-allocation_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_id'
        iv_value = <ls_demand>-reservation_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_date'
        iv_value = <ls_demand>-reservation_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_movement_type'
        iv_value = <ls_demand>-reservation_movement_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_unit'
        iv_value = <ls_demand>-reservation_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'order_id'
        iv_value = <ls_demand>-order_id ) TO lt_json_fields.
      IF lv_exact_audit_available = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_movement_type'
          iv_value = lv_audit_movement_type ) TO lt_json_fields.
        IF p_typed = abap_true.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = lv_audit_min_shelf_life ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = lv_audit_min_shelf_life ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_requested_deadline'
          iv_value = lv_audit_requested_deadline ) TO lt_json_fields.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'audit_deadline_age_days'
          iv_value   = lv_audit_deadline_age_days
          iv_text    = lv_audit_deadline_age_text
          iv_present = xsdbool( lv_audit_deadline_age_text <> 'n/a' )
          iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
          TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_movement_type'
          iv_value = 'n/a' ) TO lt_json_fields.
        IF p_typed = abap_true.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'audit_min_shelf_life' ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = 'n/a' ) TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_requested_deadline'
          iv_value = 'n/a' ) TO lt_json_fields.
            APPEND zcl_stock_json=>filter_number_property(
              iv_name    = 'audit_deadline_age_days'
              iv_value   = lv_audit_deadline_age_days
              iv_text    = 'n/a'
              iv_present = abap_false
              iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
              TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true.
        IF lv_audit_running_age_text = 'n/a'.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'audit_running_age_seconds' ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_running_age_seconds'
            iv_value = lv_audit_running_age_seconds ) TO lt_json_fields.
        ENDIF.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_running_age_seconds'
          iv_value = lv_audit_running_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_meta = abap_true.
        CLEAR lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'priority'
          iv_value = <ls_demand>-priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'requested'
          iv_value = <ls_demand>-requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'allocated'
          iv_value = <ls_demand>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'shortage'
          iv_value = <ls_demand>-shortage ) TO lt_json_fields.
        IF <ls_demand>-requested > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'coverage_pct'
            iv_value = lv_line_coverage ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'coverage_pct' ) TO lt_json_fields.
        ENDIF.
        IF <ls_demand>-requested > 0.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'shortage_pct'
            iv_value = lv_shortage_pct ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'shortage_pct' ) TO lt_json_fields.
        ENDIF.
        IF lv_audit_running_age_text = 'n/a'.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'audit_running_age_seconds' ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_running_age_seconds'
            iv_value = lv_audit_running_age_seconds ) TO lt_json_fields.
        ENDIF.
        IF lv_exact_audit_available = abap_true.
          APPEND zcl_stock_json=>number_property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = lv_audit_min_shelf_life ) TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'audit_min_shelf_life' ) TO lt_json_fields.
        ENDIF.
        CONCATENATE LINES OF lt_json_fields INTO lv_numeric_json
          SEPARATED BY ','.
        CLEAR lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocation_run_id'
          iv_value = <ls_demand>-allocation_run_id ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'strategy'
          iv_value = <ls_demand>-allocation_strategy ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sales_document'
          iv_value = <ls_demand>-sales_document ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sales_document_type'
          iv_value = <ls_demand>-sales_document_type ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'sales_item'
          iv_value = <ls_demand>-sales_item ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'schedule_line'
          iv_value = <ls_demand>-schedule_line ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested_on'
          iv_value = <ls_demand>-requested_on ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'priority'
          iv_value = <ls_demand>-priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocation_unit'
          iv_value = <ls_demand>-allocation_unit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'order_unit'
          iv_value = <ls_demand>-order_unit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested'
          iv_value = <ls_demand>-requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocated'
          iv_value = <ls_demand>-allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage'
          iv_value = <ls_demand>-shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = lv_line_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage_pct'
          iv_value = lv_line_shortage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocation_status'
          iv_value = <ls_demand>-allocation_status ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reservation_id'
          iv_value = <ls_demand>-reservation_id ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reservation_date'
          iv_value = <ls_demand>-reservation_date ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reservation_movement_type'
          iv_value = <ls_demand>-reservation_movement_type ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'reservation_unit'
          iv_value = <ls_demand>-reservation_unit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'order_id'
          iv_value = <ls_demand>-order_id ) TO lt_json_fields.
        IF lv_exact_audit_available = abap_true.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_movement_type'
            iv_value = lv_audit_movement_type ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = lv_audit_min_shelf_life ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_requested_deadline'
            iv_value = lv_audit_requested_deadline ) TO lt_json_fields.
          APPEND zcl_stock_json=>filter_number_property(
            iv_name    = 'audit_deadline_age_days'
            iv_value   = lv_audit_deadline_age_days
            iv_text    = lv_audit_deadline_age_text
            iv_present = xsdbool( lv_audit_deadline_age_text <> 'n/a' )
            iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
            TO lt_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_movement_type'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_min_shelf_life'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'audit_requested_deadline'
            iv_value = 'n/a' ) TO lt_json_fields.
          APPEND zcl_stock_json=>filter_number_property(
            iv_name    = 'audit_deadline_age_days'
            iv_value   = lv_audit_deadline_age_days
            iv_text    = 'n/a'
            iv_present = abap_false
            iv_typed   = xsdbool( p_typed = abap_true OR p_meta = abap_true ) )
            TO lt_json_fields.
        ENDIF.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_running_age_seconds'
          iv_value = lv_audit_running_age_text ) TO lt_json_fields.
        CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
        CONCATENATE '{' lv_json_line ',"numeric":{' lv_numeric_json '}}'
          INTO lv_json_line.
      ELSE.
        CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
        CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      ENDIF.
      IF p_ndjson = abap_false AND lv_row_index < lines( lt_demands ).
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

  CLEAR: lv_full_count,
         lv_partial_count,
         lv_unallocated_count,
         lv_priority_strategy_lines,
         lv_fifo_strategy_lines,
         lv_full_only_strategy_lines,
         lv_smallest_strategy_lines,
         lv_largest_strategy_lines,
         lv_best_strategy_lines,
         lv_legacy_strategy_lines,
         lv_requested_total,
         lv_allocated_total,
         lv_shortage_total,
         lv_summary_unit,
         lv_mixed_units,
         lt_strategy_totals.
  LOOP AT lt_demands ASSIGNING <ls_demand>.
    IF lv_summary_unit IS INITIAL.
      lv_summary_unit = <ls_demand>-allocation_unit.
    ELSEIF lv_summary_unit <> <ls_demand>-allocation_unit.
      lv_mixed_units = abap_true.
      CLEAR: lv_requested_total,
             lv_allocated_total,
             lv_shortage_total.
    ENDIF.
    CASE <ls_demand>-allocation_status.
      WHEN 'F'.
        lv_full_count = lv_full_count + 1.
      WHEN 'P'.
        lv_partial_count = lv_partial_count + 1.
      WHEN 'U'.
        lv_unallocated_count = lv_unallocated_count + 1.
    ENDCASE.
    CASE <ls_demand>-allocation_strategy.
      WHEN 'P'.
        lv_priority_strategy_lines = lv_priority_strategy_lines + 1.
      WHEN 'F'.
        lv_fifo_strategy_lines = lv_fifo_strategy_lines + 1.
      WHEN 'N'.
        lv_full_only_strategy_lines = lv_full_only_strategy_lines + 1.
      WHEN 'S'.
        lv_smallest_strategy_lines = lv_smallest_strategy_lines + 1.
      WHEN 'L'.
        lv_largest_strategy_lines = lv_largest_strategy_lines + 1.
      WHEN 'B'.
      lv_best_strategy_lines = lv_best_strategy_lines + 1.
      WHEN space.
        lv_legacy_strategy_lines = lv_legacy_strategy_lines + 1.
    ENDCASE.
    IF lv_mixed_units = abap_false.
      lv_requested_total = lv_requested_total + <ls_demand>-requested.
      lv_allocated_total = lv_allocated_total + <ls_demand>-allocated.
      lv_shortage_total = lv_shortage_total + <ls_demand>-shortage.
      READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
        WITH TABLE KEY strategy = <ls_demand>-allocation_strategy.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          strategy = <ls_demand>-allocation_strategy )
          INTO TABLE lt_strategy_totals.
        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
          WITH TABLE KEY strategy = <ls_demand>-allocation_strategy.
      ENDIF.
      <ls_strategy_total>-requested =
        <ls_strategy_total>-requested + <ls_demand>-requested.
      <ls_strategy_total>-allocated =
        <ls_strategy_total>-allocated + <ls_demand>-allocated.
      <ls_strategy_total>-shortage =
        <ls_strategy_total>-shortage + <ls_demand>-shortage.
    ENDIF.
  ENDLOOP.
  CLEAR lv_summary_strategy.
  IF lv_priority_strategy_lines > 0.
    lv_summary_strategy = 'P'.
  ENDIF.
  IF lv_fifo_strategy_lines > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'F'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_full_only_strategy_lines > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'N'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_smallest_strategy_lines > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'S'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_largest_strategy_lines > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'L'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_best_strategy_lines > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'B'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_legacy_strategy_lines > 0.
    IF lv_summary_strategy IS INITIAL.
      lv_summary_strategy = 'legacy'.
    ELSE.
      lv_summary_strategy = 'mixed'.
    ENDIF.
  ENDIF.
  IF lv_summary_strategy IS INITIAL.
    lv_summary_strategy = 'n/a'.
  ENDIF.
  CLEAR: lv_priority_requested,
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
  READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
    WITH TABLE KEY strategy = 'P'.
  IF sy-subrc = 0.
    lv_priority_requested = <ls_strategy_total>-requested.
    lv_priority_allocated = <ls_strategy_total>-allocated.
    lv_priority_shortage = <ls_strategy_total>-shortage.
  ENDIF.
  READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
    WITH TABLE KEY strategy = 'F'.
  IF sy-subrc = 0.
    lv_fifo_requested = <ls_strategy_total>-requested.
    lv_fifo_allocated = <ls_strategy_total>-allocated.
    lv_fifo_shortage = <ls_strategy_total>-shortage.
  ENDIF.
  READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
    WITH TABLE KEY strategy = 'N'.
  IF sy-subrc = 0.
    lv_full_only_requested = <ls_strategy_total>-requested.
    lv_full_only_allocated = <ls_strategy_total>-allocated.
    lv_full_only_shortage = <ls_strategy_total>-shortage.
  ENDIF.
  READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
    WITH TABLE KEY strategy = 'S'.
   IF sy-subrc = 0.
     lv_smallest_requested = <ls_strategy_total>-requested.
     lv_smallest_allocated = <ls_strategy_total>-allocated.
     lv_smallest_shortage = <ls_strategy_total>-shortage.
   ENDIF.
   READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
     WITH TABLE KEY strategy = 'L'.
   IF sy-subrc = 0.
     lv_largest_requested = <ls_strategy_total>-requested.
     lv_largest_allocated = <ls_strategy_total>-allocated.
     lv_largest_shortage = <ls_strategy_total>-shortage.
   ENDIF.

   READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
     WITH TABLE KEY strategy = 'B'.
   IF sy-subrc = 0.
     lv_best_requested = <ls_strategy_total>-requested.
     lv_best_allocated = <ls_strategy_total>-allocated.
     lv_best_shortage = <ls_strategy_total>-shortage.
   ENDIF.
        READ TABLE lt_strategy_totals ASSIGNING <ls_strategy_total>
    WITH TABLE KEY strategy = space.
  IF sy-subrc = 0.
    lv_legacy_requested = <ls_strategy_total>-requested.
    lv_legacy_allocated = <ls_strategy_total>-allocated.
    lv_legacy_shortage = <ls_strategy_total>-shortage.
  ENDIF.
  IF lv_mixed_units = abap_false.
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
  ENDIF.
  WRITE: / 'Allocation movement type filter:', lv_movement_filter,
         / 'Audit status filter:', lv_audit_status_filter,
         / 'Minimum shelf-life filter:', lv_min_shelf_filter,
         / 'Overdue-only filter:', p_ovrd,
         / 'Overdue as-of date:', lv_overdue_as_of_filter,
         / 'Deadline age reference date:', lv_deadline_reference_date,
         / 'Requested horizon from:', lv_requested_from_filter,
         / 'Requested horizon to:', lv_requested_to_filter,
         / 'Requested-deadline-only filter:', p_dead,
         / 'Requested deadline from:', lv_deadline_from_filter,
         / 'Requested deadline to:', lv_deadline_to_filter,
         / 'Deadline age from:', lv_deadline_age_from_filter,
         / 'Deadline age to:', lv_deadline_age_to_filter,
         / 'Deadline age as-of date:', lv_deadline_age_date_filter,
         / 'Result lines:', lines( lt_demands ),
           / 'Demand lines:', lines( lt_demands ),
         'Total matching lines:', lv_total_rows,
           / 'Fully allocated:', lv_full_count,
           / 'Partially allocated:', lv_partial_count,
           / 'Unallocated:', lv_unallocated_count,
           / 'Priority strategy lines:', lv_priority_strategy_lines,
           / 'FIFO strategy lines:', lv_fifo_strategy_lines,
           / 'Full-only strategy lines:', lv_full_only_strategy_lines,
            / 'Smallest strategy lines:', lv_smallest_strategy_lines,
            / 'Largest strategy lines:', lv_largest_strategy_lines,
            / 'Best-fit strategy lines:', lv_best_strategy_lines,
            / 'Legacy strategy lines:', lv_legacy_strategy_lines,
           / 'Strategy context:', lv_summary_strategy.
  IF lv_mixed_units = abap_true.
    WRITE: / 'Per-strategy quantity totals omitted: mixed allocation units.'.
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
  ENDIF.
  IF p_max > 0.
    WRITE: / 'Page:', lv_page_number, 'of', lv_page_count.
    WRITE: / 'Last page offset:', lv_last_offset.
  ENDIF.
  IF lv_mixed_units = abap_true.
    WRITE: / 'Quantity totals omitted: mixed allocation units.'.
    WRITE: / 'Allocation shortage: n/a (mixed allocation units).'.
  ELSE.
    WRITE: / 'Quantity totals (', lv_summary_unit, ') requested:',
             lv_requested_total,
           / 'Allocated:', lv_allocated_total,
           'Shortage:', lv_shortage_total.
    IF lv_requested_total > 0.
      lv_coverage = lv_allocated_total * 100 / lv_requested_total.
      WRITE: / 'Allocation coverage:', lv_coverage, '%'.
      lv_shortage_pct = lv_shortage_total * 100 / lv_requested_total.
      WRITE: / 'Allocation shortage:', lv_shortage_pct, '%'.
    ELSE.
      WRITE: / 'Allocation coverage: n/a (no requested quantity).'.
      WRITE: / 'Allocation shortage: n/a (no requested quantity).'.
    ENDIF.
  ENDIF.

  IF p_runid IS NOT INITIAL
      AND p_meins IS INITIAL
      AND p_rid IS INITIAL
      AND p_mvt IS INITIAL
      AND p_shelf IS INITIAL
      AND p_stat IS INITIAL
      AND p_vbeln IS INITIAL
      AND p_auart IS INITIAL
      AND p_posnr IS INITIAL
      AND p_etenr IS INITIAL
      AND p_ounit IS INITIAL
      AND p_order IS INITIAL
      AND p_resid IS INITIAL
      AND p_rmov IS INITIAL
      AND p_runit IS INITIAL
      AND p_rsv IS INITIAL
      AND p_unrsv IS INITIAL
      AND p_bklg IS INITIAL
      AND p_ovrd IS INITIAL
      AND p_rfrom IS INITIAL
      AND p_rto IS INITIAL
      AND p_rage IS INITIAL
      AND p_from IS INITIAL
      AND p_to IS INITIAL
      AND p_priof IS INITIAL
      AND p_priot IS INITIAL
      AND p_shf IS INITIAL
      AND p_sht IS INITIAL
      AND p_qf IS INITIAL
      AND p_qt IS INITIAL
      AND p_af IS INITIAL
      AND p_at IS INITIAL
      AND p_covf IS INITIAL
      AND p_covt IS INITIAL
      AND p_spf IS INITIAL
      AND p_spt IS INITIAL
      AND p_max IS INITIAL
      AND p_skip IS INITIAL.
    lv_reconcile_possible = abap_true.
  ENDIF.

  IF p_runid IS NOT INITIAL.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_read_authority = lo_authority.
    TRY.
        lt_runs = lo_audit->get_runs(
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_run_id            = p_runid
          iv_deadline_only     = p_dead
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until ).
      CATCH zcx_stock_allocation INTO DATA(lo_context_error).
        IF lo_context_error->message IS INITIAL.
          WRITE: / 'Run context is unavailable.'
               .
        ELSE.
          WRITE: / 'Run context is unavailable:', lo_context_error->message.
        ENDIF.
    ENDTRY.
    READ TABLE lt_runs ASSIGNING <ls_run> INDEX 1.
    IF sy-subrc = 0.
      IF <ls_run>-strategy IS INITIAL.
        lv_display_strategy = 'LEGACY'.
      ELSE.
        lv_display_strategy = <ls_run>-strategy.
      ENDIF.
      CLEAR: lv_audit_duration_seconds,
             lv_audit_duration_text.
      IF <ls_run>-finish_date IS INITIAL.
        lv_audit_duration_text = 'n/a'.
      ELSE.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = <ls_run>-finish_date
            time1    = <ls_run>-finish_time
            date2    = <ls_run>-start_date
            time2    = <ls_run>-start_time
          IMPORTING
            res_secs = lv_audit_duration_seconds ).
        lv_audit_duration_text = lv_audit_duration_seconds.
      ENDIF.
      lv_audit_running_age_text = 'n/a'.
      ls_audit_running_age = lo_audit->get_running_age( <ls_run> ).
      IF ls_audit_running_age-available = abap_true.
        lv_audit_running_age_seconds = ls_audit_running_age-seconds.
          lv_audit_running_age_text = zcl_stock_csv=>number(
            lv_audit_running_age_seconds ).
      ENDIF.
      WRITE: / 'Run context:', <ls_run>-run_id,
               'Status:', <ls_run>-status.
      WRITE: / 'Audit strategy:', lv_display_strategy.
      WRITE: / 'Audit movement type:', <ls_run>-movement_type,
               'Minimum shelf-life days:', <ls_run>-min_shelf_life.
      WRITE: / 'Requested from:', <ls_run>-requested_on_from,
               'through:', <ls_run>-requested_on_to,
               'deadline:', <ls_run>-requested_deadline,
               'deadline age days:', lv_audit_deadline_age_text,
               'deadline age reference date:', lv_deadline_reference_date,
               'Started:', <ls_run>-start_date, <ls_run>-start_time,
               'Finished:', <ls_run>-finish_date, <ls_run>-finish_time.
      WRITE: / 'Audit duration seconds:', lv_audit_duration_text.
      WRITE: / 'Audit running age seconds:', lv_audit_running_age_text.
      WRITE: / 'Audit demand:', <ls_run>-demand_count,
               'full:', <ls_run>-full_count,
               'partial:', <ls_run>-partial_count,
               'unallocated:', <ls_run>-unallocated_count.
      WRITE: / 'Audit allocated:', <ls_run>-allocated,
               'shortage:', <ls_run>-shortage,
               'message:', <ls_run>-message.
      IF lv_reconcile_possible = abap_true.
        ls_reconciliation = lo_compare->reconcile(
          it_snapshot = lt_demands
          is_audit    = <ls_run> ).
        IF ls_reconciliation-status = 'OK'.
          WRITE: / 'Reconciliation: OK (snapshot counts match audit).'.
        ELSE.
          WRITE: / 'Reconciliation: MISMATCH (snapshot metrics differ from audit).'.
        ENDIF.
        WRITE: / 'Reconciliation fields:',
          ls_reconciliation-mismatch_fields.
        WRITE: / 'Snapshot metrics: demand',
          ls_reconciliation-snapshot_rows,
          'full', ls_reconciliation-snapshot_full_count,
          'partial', ls_reconciliation-snapshot_partial_count,
          'unallocated', ls_reconciliation-snapshot_unallocated_count.
        WRITE: / 'Snapshot quantities: requested',
          ls_reconciliation-snapshot_requested,
          'allocated', ls_reconciliation-snapshot_allocated,
          'shortage', ls_reconciliation-snapshot_shortage.
      ENDIF.
    ELSEIF lv_reconcile_possible = abap_true.
      WRITE: / 'Run context not found for supplied run ID; reconciliation unavailable.'.
    ENDIF.
  ENDIF.

  IF lines( lt_demands ) = 0.
    WRITE: / 'No allocation snapshot rows found for this run.'.
    RETURN.
  ENDIF.

  IF p_sum = abap_true.
    WRITE: / 'Summary-only mode: detail rows suppressed.'.
    RETURN.
  ENDIF.

   WRITE: / 'Run', 28 'Strategy', 34 'Sales document', 50 'Type', 56 'Item', 64 'Schedule',
           70 'Requested on',
           84 'Priority', 94 'Alloc.unit', 106 'Order.unit', 118 'Requested', 132 'Allocated',
           146 'Shortage', 156 'Coverage', 168 'Shortage %', 180 'Status', 190 'Reservation',
           212 'Res.date', 224 'Res.move', 236 'Res.unit', 250 'Order ID'.
  LOOP AT lt_demands ASSIGNING <ls_demand>.
    CLEAR: lv_line_coverage,
           lv_shortage_pct,
           lv_line_coverage_text.
    IF <ls_demand>-requested > 0.
      lv_line_coverage = <ls_demand>-allocated * 100
        / <ls_demand>-requested.
      lv_shortage_pct = <ls_demand>-shortage * 100
        / <ls_demand>-requested.
      lv_line_coverage_text = lv_line_coverage.
    ELSE.
      lv_line_coverage_text = 'n/a'.
    ENDIF.
    WRITE: / <ls_demand>-allocation_run_id,
             28 <ls_demand>-allocation_strategy,
             34 <ls_demand>-sales_document,
             50 <ls_demand>-sales_document_type,
             56 <ls_demand>-sales_item,
             64 <ls_demand>-schedule_line,
             70 <ls_demand>-requested_on,
             84 <ls_demand>-priority,
             94 <ls_demand>-allocation_unit,
             106 <ls_demand>-order_unit,
             118 <ls_demand>-requested,
             132 <ls_demand>-allocated,
             146 <ls_demand>-shortage,
             156 lv_line_coverage_text,
             168 lv_shortage_pct,
             180 <ls_demand>-allocation_status,
             190 <ls_demand>-reservation_id,
             212 <ls_demand>-reservation_date,
             224 <ls_demand>-reservation_movement_type,
             236 <ls_demand>-reservation_unit,
             250 <ls_demand>-order_id.
  ENDLOOP.
