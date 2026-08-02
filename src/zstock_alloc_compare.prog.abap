REPORT zstock_alloc_compare.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_old TYPE zif_stock_allocation=>ty_run_id OBLIGATORY.
PARAMETERS p_new TYPE zif_stock_allocation=>ty_run_id OBLIGATORY.
PARAMETERS p_chg TYPE zif_stock_allocation_compare=>ty_change_type.
PARAMETERS p_reason TYPE zif_stock_allocation_compare=>ty_change_reason.
PARAMETERS p_all AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_skip TYPE i.
PARAMETERS p_max TYPE i.
PARAMETERS p_guard AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.
PARAMETERS p_ndjson AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_compare TYPE REF TO zif_stock_allocation_compare.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lo_missing_run_error TYPE REF TO zcx_stock_allocation.
  DATA lt_old TYPE zif_stock_allocation=>tt_demands.
  DATA lt_new TYPE zif_stock_allocation=>tt_demands.
  DATA lt_old_runs TYPE zif_allocation_audit=>tt_runs.
  DATA lt_new_runs TYPE zif_allocation_audit=>tt_runs.
  DATA ls_old_run TYPE zif_allocation_audit=>ty_run.
  DATA ls_new_run TYPE zif_allocation_audit=>ty_run.
  DATA ls_old_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation.
  DATA lv_old_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA ls_new_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation.
  DATA lv_new_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_duration_seconds TYPE i.
  DATA lv_new_duration_seconds TYPE i.
  DATA lv_old_duration_text TYPE string.
  DATA lv_new_duration_text TYPE string.
  DATA lv_old_running_age_seconds TYPE i.
  DATA lv_new_running_age_seconds TYPE i.
  DATA lv_old_running_age_text TYPE string.
  DATA lv_new_running_age_text TYPE string.
  DATA lv_old_running_age_available TYPE abap_bool.
  DATA lv_new_running_age_available TYPE abap_bool.
  DATA ls_old_running_age TYPE zif_stock_allocation_compare=>ty_running_age.
  DATA ls_new_running_age TYPE zif_stock_allocation_compare=>ty_running_age.
  DATA lv_old_audit_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_audit_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_audit_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_audit_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_audit_coverage_text TYPE string.
  DATA lv_new_audit_coverage_text TYPE string.
  DATA lv_old_audit_shortage_pct_text TYPE string.
  DATA lv_new_audit_shortage_pct_text TYPE string.
  DATA lv_audit_units_match TYPE abap_bool.
  DATA lv_audit_horizon_changed TYPE abap_bool.
  DATA lv_audit_status_changed TYPE abap_bool.
  DATA lv_audit_strategy_changed TYPE abap_bool.
  DATA lv_audit_running_changed TYPE abap_bool.
  DATA lv_aud_dur_delta_secs TYPE i.
  DATA lv_aud_start_delta_secs TYPE i.
  DATA lv_aud_finish_delta_secs TYPE i.
  DATA lv_audit_requested_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_available_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_allocated_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_shortage_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_coverage_delta TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_audit_shortage_pct_delta TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_audit_allocated_delta_text TYPE string.
  DATA lv_audit_shortage_delta_text TYPE string.
  DATA lv_audit_coverage_delta_text TYPE string.
  DATA lv_aud_shrt_pct_delta_text TYPE string.
  DATA lv_audit_requested_delta_text TYPE string.
  DATA lv_audit_available_delta_text TYPE string.
  DATA lv_audit_duration_delta_text TYPE string.
  DATA lv_audit_running_age_delta TYPE i.
  DATA lv_aud_run_age_delta_text TYPE string.
  DATA lv_aud_run_age_trend TYPE string.
  DATA lv_audit_start_delta_text TYPE string.
  DATA lv_audit_finish_delta_text TYPE string.
  DATA lv_old_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation_status.
  DATA lv_new_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation_status.
  DATA lv_recon_status_changed TYPE abap_bool.
  DATA lv_recon_both_ok TYPE abap_bool.
  DATA lv_recon_transition TYPE string.
  DATA lv_audit_meta_changed TYPE abap_bool.
  DATA lv_audit_meta_reasons TYPE string.
  DATA lv_audit_demand_delta TYPE i.
  DATA lv_audit_full_delta TYPE i.
  DATA lv_audit_partial_delta TYPE i.
  DATA lv_audit_unallocated_delta TYPE i.
  DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
  DATA ls_summary TYPE zif_stock_allocation_compare=>ty_summary.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_summary_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_csv_line TYPE string.
  DATA lv_json_line TYPE string.
  DATA lv_json_fields TYPE string.
  DATA lv_summary_json_fields TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_first TYPE abap_bool.
  DATA lv_total_rows TYPE i.
  FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.

  TRANSLATE p_reason TO LOWER CASE.
  IF p_old = p_new.
    lv_error_message = 'Old and new allocation run IDs must be different'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_csv = abap_true AND p_json = abap_true.
    WRITE: / zcl_stock_json=>error(
      'CSV and JSON output cannot be selected together' ).
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = 'Typed output requires JSON mode' ).
    ELSE.
      WRITE: / 'Typed output requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_meta = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = 'Comparison metadata requires JSON mode' ).
    ELSE.
      WRITE: / 'Comparison metadata requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = 'NDJSON output requires JSON mode' ).
    ELSE.
      WRITE: / 'NDJSON output requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_meta = abap_true.
    WRITE: / zcl_stock_json=>error(
      'NDJSON output cannot be combined with metadata output' ).
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_sum = abap_true.
    WRITE: / zcl_stock_json=>error(
      'NDJSON output cannot be combined with summary mode' ).
    RETURN.
  ENDIF.
  IF p_chg IS NOT INITIAL
      AND p_chg <> 'A'
      AND p_chg <> 'R'
      AND p_chg <> 'C'
      AND p_chg <> 'U'.
    lv_error_message = 'Comparison change type is invalid'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_skip < 0 OR p_max < 0.
    lv_error_message = 'Comparison pagination is invalid'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_allocation_read_auth_sap.
  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
    EXPORTING
      io_read_authority = lo_authority.
  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_read_authority = lo_authority.
  TRY.
      lt_old = lo_sink->get_allocations(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins
        iv_run_id           = p_old ).
      lt_new = lo_sink->get_allocations(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins
        iv_run_id           = p_new ).
      lt_old_runs = lo_audit->get_runs(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins
        iv_run_id           = p_old ).
      lt_new_runs = lo_audit->get_runs(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins
        iv_run_id           = p_new ).
      READ TABLE lt_old_runs INTO ls_old_run INDEX 1.
      IF sy-subrc <> 0.
        CREATE OBJECT lo_missing_run_error.
        lo_missing_run_error->message = 'Old allocation run was not found'.
        RAISE EXCEPTION lo_missing_run_error.
      ENDIF.
      READ TABLE lt_new_runs INTO ls_new_run INDEX 1.
      IF sy-subrc <> 0.
        CREATE OBJECT lo_missing_run_error.
        lo_missing_run_error->message = 'New allocation run was not found'.
        RAISE EXCEPTION lo_missing_run_error.
      ENDIF.
    CATCH zcx_stock_allocation INTO DATA(lo_read_error).
      IF lo_read_error->message IS INITIAL.
        lv_error_message = 'Allocation snapshots are unavailable'.
      ELSE.
        lv_error_message = lo_read_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / 'Allocation snapshots are unavailable:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_compare TYPE zcl_stock_allocation_compare.
  TRY.
      lt_changes = lo_compare->compare(
        EXPORTING
          it_old               = lt_old
          it_new               = lt_new
          iv_change_type       = p_chg
          iv_reason            = p_reason
          iv_include_unchanged = p_all
          iv_offset            = p_skip
          iv_max_rows          = p_max
        IMPORTING
          es_summary           = ls_summary
          ev_total_rows        = lv_total_rows ).
    CATCH zcx_stock_allocation INTO DATA(lo_compare_error).
      IF lo_compare_error->message IS INITIAL.
        lv_error_message = 'Allocation snapshots cannot be compared'.
      ELSE.
        lv_error_message = lo_compare_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  ls_old_reconciliation = lo_compare->reconcile(
    it_snapshot = lt_old
    is_audit    = ls_old_run ).
  ls_new_reconciliation = lo_compare->reconcile(
    it_snapshot = lt_new
    is_audit    = ls_new_run ).
  lv_old_reconciliation = ls_old_reconciliation-status.
  lv_new_reconciliation = ls_new_reconciliation-status.
  IF lv_old_reconciliation <> lv_new_reconciliation.
    lv_recon_status_changed = abap_true.
  ELSE.
    lv_recon_status_changed = abap_false.
  ENDIF.
  lv_recon_transition = lo_compare->get_reconciliation_transition(
    iv_old_status = lv_old_reconciliation
    iv_new_status = lv_new_reconciliation ).
  IF lv_recon_transition = 'both_ok'.
    lv_recon_both_ok = abap_true.
  ELSE.
    lv_recon_both_ok = abap_false.
  ENDIF.
  lv_audit_demand_delta = ls_new_run-demand_count -
    ls_old_run-demand_count.
  lv_audit_full_delta = ls_new_run-full_count - ls_old_run-full_count.
  lv_audit_partial_delta = ls_new_run-partial_count -
    ls_old_run-partial_count.
  lv_audit_unallocated_delta = ls_new_run-unallocated_count -
    ls_old_run-unallocated_count.
  lv_old_requested_total = ls_old_reconciliation-snapshot_requested.
  lv_new_requested_total = ls_new_reconciliation-snapshot_requested.

  IF ls_old_run-finish_date IS INITIAL.
    lv_old_duration_text = 'n/a'.
  ELSE.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_old_run-finish_date
        time1    = ls_old_run-finish_time
        date2    = ls_old_run-start_date
        time2    = ls_old_run-start_time
      IMPORTING
        res_secs = lv_old_duration_seconds ).
    lv_old_duration_text = zcl_stock_csv=>number(
      lv_old_duration_seconds ).
  ENDIF.
  IF ls_new_run-finish_date IS INITIAL.
    lv_new_duration_text = 'n/a'.
  ELSE.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_new_run-finish_date
        time1    = ls_new_run-finish_time
        date2    = ls_new_run-start_date
        time2    = ls_new_run-start_time
      IMPORTING
        res_secs = lv_new_duration_seconds ).
    lv_new_duration_text = zcl_stock_csv=>number(
      lv_new_duration_seconds ).
  ENDIF.

  ls_old_running_age = lo_audit->get_running_age( ls_old_run ).
  ls_new_running_age = lo_audit->get_running_age( ls_new_run ).
  lv_old_running_age_seconds = ls_old_running_age-seconds.
  lv_new_running_age_seconds = ls_new_running_age-seconds.
  lv_old_running_age_available = ls_old_running_age-available.
  lv_new_running_age_available = ls_new_running_age-available.
  lv_old_running_age_text = 'n/a'.
  lv_new_running_age_text = 'n/a'.
  IF lv_old_running_age_available = abap_true.
    lv_old_running_age_text = zcl_stock_csv=>number(
      lv_old_running_age_seconds ).
  ENDIF.
  IF lv_new_running_age_available = abap_true.
    lv_new_running_age_text = zcl_stock_csv=>number(
      lv_new_running_age_seconds ).
  ENDIF.
  IF lv_old_running_age_available = abap_true
      AND lv_new_running_age_available = abap_true.
    lv_audit_running_age_delta = lv_new_running_age_seconds -
      lv_old_running_age_seconds.
    lv_aud_run_age_delta_text = zcl_stock_csv=>number(
      lv_audit_running_age_delta ).
  ELSE.
    lv_aud_run_age_delta_text = 'n/a'.
  ENDIF.
  lv_aud_run_age_trend = lo_compare->get_running_age_trend(
    is_old_age = ls_old_running_age
    is_new_age = ls_new_running_age ).

  IF ls_old_run-requested > 0.
    lv_old_audit_coverage = ls_old_run-allocated * 100 /
      ls_old_run-requested.
    lv_old_audit_shortage_pct = ls_old_run-shortage * 100 /
      ls_old_run-requested.
    lv_old_audit_coverage_text = zcl_stock_csv=>number(
      lv_old_audit_coverage ).
    lv_old_audit_shortage_pct_text = zcl_stock_csv=>number(
      lv_old_audit_shortage_pct ).
  ELSE.
    lv_old_audit_coverage_text = 'n/a'.
    lv_old_audit_shortage_pct_text = 'n/a'.
  ENDIF.
  IF ls_new_run-requested > 0.
    lv_new_audit_coverage = ls_new_run-allocated * 100 /
      ls_new_run-requested.
    lv_new_audit_shortage_pct = ls_new_run-shortage * 100 /
      ls_new_run-requested.
    lv_new_audit_coverage_text = zcl_stock_csv=>number(
      lv_new_audit_coverage ).
    lv_new_audit_shortage_pct_text = zcl_stock_csv=>number(
      lv_new_audit_shortage_pct ).
  ELSE.
    lv_new_audit_coverage_text = 'n/a'.
    lv_new_audit_shortage_pct_text = 'n/a'.
  ENDIF.

  IF ls_old_run-unit IS NOT INITIAL
      AND ls_old_run-unit = ls_new_run-unit.
    lv_audit_units_match = abap_true.
    lv_audit_requested_delta = ls_new_run-requested - ls_old_run-requested.
    lv_audit_available_delta = ls_new_run-available - ls_old_run-available.
    lv_audit_requested_delta_text = zcl_stock_csv=>number(
      lv_audit_requested_delta ).
    lv_audit_available_delta_text = zcl_stock_csv=>number(
      lv_audit_available_delta ).
    lv_audit_allocated_delta = ls_new_run-allocated - ls_old_run-allocated.
    lv_audit_shortage_delta = ls_new_run-shortage - ls_old_run-shortage.
    lv_audit_allocated_delta_text = zcl_stock_csv=>number(
      lv_audit_allocated_delta ).
    lv_audit_shortage_delta_text = zcl_stock_csv=>number(
      lv_audit_shortage_delta ).
    IF ls_old_run-requested > 0 AND ls_new_run-requested > 0.
      lv_audit_coverage_delta = lv_new_audit_coverage -
        lv_old_audit_coverage.
      lv_audit_shortage_pct_delta = lv_new_audit_shortage_pct -
        lv_old_audit_shortage_pct.
      lv_audit_coverage_delta_text = zcl_stock_csv=>number(
        lv_audit_coverage_delta ).
      lv_aud_shrt_pct_delta_text = zcl_stock_csv=>number(
        lv_audit_shortage_pct_delta ).
    ELSE.
      lv_audit_coverage_delta_text = 'n/a'.
      lv_aud_shrt_pct_delta_text = 'n/a'.
    ENDIF.
  ELSE.
    lv_audit_units_match = abap_false.
    lv_audit_requested_delta_text = 'n/a'.
    lv_audit_available_delta_text = 'n/a'.
    lv_audit_allocated_delta_text = 'n/a'.
    lv_audit_shortage_delta_text = 'n/a'.
    lv_audit_coverage_delta_text = 'n/a'.
    lv_aud_shrt_pct_delta_text = 'n/a'.
  ENDIF.

  IF ls_old_run-requested_on_from <> ls_new_run-requested_on_from
      OR ls_old_run-requested_on_to <> ls_new_run-requested_on_to.
    lv_audit_horizon_changed = abap_true.
  ELSE.
    lv_audit_horizon_changed = abap_false.
  ENDIF.
  IF ls_old_run-status <> ls_new_run-status.
    lv_audit_status_changed = abap_true.
  ELSE.
    lv_audit_status_changed = abap_false.
  ENDIF.
  IF ls_old_run-strategy <> ls_new_run-strategy.
    lv_audit_strategy_changed = abap_true.
  ELSE.
    lv_audit_strategy_changed = abap_false.
  ENDIF.
  IF ( ls_old_run-finish_date IS INITIAL
      AND ls_new_run-finish_date IS NOT INITIAL )
      OR ( ls_old_run-finish_date IS NOT INITIAL
      AND ls_new_run-finish_date IS INITIAL ).
    lv_audit_running_changed = abap_true.
  ELSE.
    lv_audit_running_changed = abap_false.
  ENDIF.
  IF ls_old_run-finish_date IS NOT INITIAL
      AND ls_new_run-finish_date IS NOT INITIAL.
    lv_aud_dur_delta_secs = lv_new_duration_seconds -
      lv_old_duration_seconds.
    lv_audit_duration_delta_text = zcl_stock_csv=>number(
      lv_aud_dur_delta_secs ).
  ELSE.
    lv_audit_duration_delta_text = 'n/a'.
  ENDIF.
  IF ls_old_run-start_date IS NOT INITIAL
      AND ls_new_run-start_date IS NOT INITIAL.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_new_run-start_date
        time1    = ls_new_run-start_time
        date2    = ls_old_run-start_date
        time2    = ls_old_run-start_time
      IMPORTING
        res_secs = lv_aud_start_delta_secs ).
    lv_audit_start_delta_text = zcl_stock_csv=>number(
      lv_aud_start_delta_secs ).
  ELSE.
    lv_audit_start_delta_text = 'n/a'.
  ENDIF.
  IF ls_old_run-finish_date IS NOT INITIAL
      AND ls_new_run-finish_date IS NOT INITIAL.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_new_run-finish_date
        time1    = ls_new_run-finish_time
        date2    = ls_old_run-finish_date
        time2    = ls_old_run-finish_time
      IMPORTING
        res_secs = lv_aud_finish_delta_secs ).
    lv_audit_finish_delta_text = zcl_stock_csv=>number(
      lv_aud_finish_delta_secs ).
  ELSE.
    lv_audit_finish_delta_text = 'n/a'.
  ENDIF.

  lv_audit_meta_reasons = lo_compare->get_audit_metadata_reasons(
    iv_old_run = ls_old_run
    iv_new_run = ls_new_run ).
  IF lv_audit_meta_reasons IS INITIAL.
    lv_audit_meta_changed = abap_false.
  ELSE.
    lv_audit_meta_changed = abap_true.
  ENDIF.

  IF p_guard = abap_true
      AND ( lv_old_reconciliation = 'MISMATCH'
        OR lv_new_reconciliation = 'MISMATCH' ).
    CONCATENATE 'Snapshot-to-audit reconciliation failed:'
      'old=' ls_old_reconciliation-mismatch_fields
      'new=' ls_new_reconciliation-mismatch_fields
      INTO lv_error_message SEPARATED BY space.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.

  IF p_sum = abap_true.
    IF p_csv = abap_true.
      WRITE: / 'schema_version;generated_date;generated_time;old_run;new_run;change_type;reason_filter;'
        && 'include_unchanged;'
        && 'reconciliation_guard;old_run_status;new_run_status;old_run_strategy;new_run_strategy;old_start_date;'
        && 'new_start_date;old_start_time;new_start_time;old_finish_date;new_finish_date;old_finish_time;'
        && 'new_finish_time;old_requested_on_from;new_requested_on_from;old_requested_on_to;new_requested_on_to;'
        && 'old_available;new_available;old_duration_seconds;new_duration_seconds;old_running_age_seconds;'
        && 'new_running_age_seconds;audit_running_age_delta_seconds;audit_running_age_trend;old_message;new_message;'
        && 'old_reconciliation;new_reconciliation;audit_reconciliation_changed;audit_reconciliation_ok;'
        && 'audit_reconciliation_transition;audit_metadata_changed;audit_metadata_change_reasons;'
        && 'old_reconciliation_fields;new_reconciliation_fields;old_audit_unit;new_audit_unit;audit_units_match;'
        && 'audit_horizon_changed;audit_status_changed;audit_strategy_changed;audit_running_changed;'
        && 'audit_duration_delta_seconds;audit_start_delta_seconds;audit_finish_delta_seconds;old_audit_demand_count;'
        && 'new_audit_demand_count;old_audit_full_rows;new_audit_full_rows;old_audit_partial_rows;'
        && 'new_audit_partial_rows;old_audit_unallocated_rows;new_audit_unallocated_rows;audit_demand_count_delta;'
        && 'audit_full_rows_delta;audit_partial_rows_delta;audit_unallocated_rows_delta;old_audit_requested;'
        && 'new_audit_requested;old_audit_allocated;new_audit_allocated;old_audit_shortage;new_audit_shortage;'
        && 'old_audit_coverage_pct;new_audit_coverage_pct;old_audit_shortage_pct;new_audit_shortage_pct;'
        && 'audit_requested_delta;audit_available_delta;audit_allocated_delta;audit_shortage_delta;'
        && 'audit_coverage_delta_pct;audit_shortage_pct_delta;old_snapshot_rows;new_snapshot_rows;'
        && 'old_snapshot_requested;new_snapshot_requested;old_snapshot_full_rows;new_snapshot_full_rows;'
        && 'old_snapshot_partial_rows;new_snapshot_partial_rows;old_snapshot_unallocated_rows;'
        && 'new_snapshot_unallocated_rows;old_snapshot_allocated;new_snapshot_allocated;old_snapshot_shortage;'
        && 'new_snapshot_shortage;unit;mixed_units;total_rows;returned_rows;offset;max_rows;added_rows;removed_rows;'
        && 'changed_rows;unchanged_rows;old_requested;new_requested;delta_requested;old_allocated;new_allocated;'
        && 'delta_allocated;old_shortage;new_shortage;delta_shortage'.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>number( 20 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_old ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_new ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_chg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_all ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_guard ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-available ) TO lt_csv_fields.
      APPEND lv_old_duration_text TO lt_csv_fields.
      APPEND lv_new_duration_text TO lt_csv_fields.
      APPEND lv_old_running_age_text TO lt_csv_fields.
      APPEND lv_new_running_age_text TO lt_csv_fields.
      APPEND lv_aud_run_age_delta_text TO lt_csv_fields.
      APPEND lv_aud_run_age_trend TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_both_ok ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_transition ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_reasons ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_old_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_new_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_units_match ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_horizon_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_strategy_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_running_changed ) TO lt_csv_fields.
      APPEND lv_audit_duration_delta_text TO lt_csv_fields.
      APPEND lv_audit_start_delta_text TO lt_csv_fields.
      APPEND lv_audit_finish_delta_text TO lt_csv_fields.
      APPEND lv_audit_requested_delta_text TO lt_csv_fields.
      APPEND lv_audit_available_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_demand_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_full_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_partial_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_unallocated_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-shortage ) TO lt_csv_fields.
      APPEND lv_old_audit_coverage_text TO lt_csv_fields.
      APPEND lv_new_audit_coverage_text TO lt_csv_fields.
      APPEND lv_old_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_new_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_audit_allocated_delta_text TO lt_csv_fields.
      APPEND lv_audit_shortage_delta_text TO lt_csv_fields.
      APPEND lv_audit_coverage_delta_text TO lt_csv_fields.
      APPEND lv_aud_shrt_pct_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_old ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_new ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_old_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_new_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      IF ls_summary-mixed_units = abap_true.
        APPEND zcl_stock_csv=>quote( 'mixed' ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( ls_summary-unit ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_summary-mixed_units ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-total_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_changes ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-added_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-removed_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-changed_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-unchanged_rows ) TO lt_csv_fields.
      IF ls_summary-mixed_units = abap_true.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>number( ls_summary-old_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-new_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-delta_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-old_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-new_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-delta_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-old_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-new_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-delta_shortage ) TO lt_csv_fields.
      ENDIF.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.

    IF p_json = abap_true.
      CLEAR lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'total_rows'
        iv_value = ls_summary-total_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'added_rows'
        iv_value = ls_summary-added_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'removed_rows'
        iv_value = ls_summary-removed_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'changed_rows'
        iv_value = ls_summary-changed_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'unchanged_rows'
        iv_value = ls_summary-unchanged_rows ) TO lt_summary_json_fields.
      IF ls_summary-mixed_units = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = 'mixed' ) TO lt_summary_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = ls_summary-unit ) TO lt_summary_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'mixed_units'
        iv_value = ls_summary-mixed_units ) TO lt_summary_json_fields.
      IF ls_summary-mixed_units = abap_true.
        IF p_typed = abap_true.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'old_requested' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'new_requested' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'delta_requested' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'old_allocated' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'new_allocated' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'delta_allocated' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'old_shortage' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'new_shortage' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'delta_shortage' ) TO lt_summary_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'old_requested'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'new_requested'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'delta_requested'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'old_allocated'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'new_allocated'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'delta_allocated'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'old_shortage'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'new_shortage'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'delta_shortage'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
        ENDIF.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_requested'
          iv_value = ls_summary-old_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_requested'
          iv_value = ls_summary-new_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_requested'
          iv_value = ls_summary-delta_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_allocated'
          iv_value = ls_summary-old_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_allocated'
          iv_value = ls_summary-new_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_allocated'
          iv_value = ls_summary-delta_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_shortage'
          iv_value = ls_summary-old_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_shortage'
          iv_value = ls_summary-new_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_shortage'
          iv_value = ls_summary-delta_shortage ) TO lt_summary_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_requested'
          iv_value = ls_summary-old_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_requested'
          iv_value = ls_summary-new_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_requested'
          iv_value = ls_summary-delta_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_allocated'
          iv_value = ls_summary-old_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_allocated'
          iv_value = ls_summary-new_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_allocated'
          iv_value = ls_summary-delta_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_shortage'
          iv_value = ls_summary-old_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_shortage'
          iv_value = ls_summary-new_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_shortage'
          iv_value = ls_summary-delta_shortage ) TO lt_summary_json_fields.
      ENDIF.

      CLEAR lt_json_fields.
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
        iv_name  = 'old_run'
        iv_value = p_old ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_run'
        iv_value = p_new ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'change_type'
        iv_value = p_chg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reason_filter'
        iv_value = p_reason ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'include_unchanged'
        iv_value = p_all ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'reconciliation_guard'
        iv_value = p_guard ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_run_status'
        iv_value = ls_old_run-status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_run_status'
        iv_value = ls_new_run-status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_run_strategy'
        iv_value = ls_old_run-strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_run_strategy'
        iv_value = ls_new_run-strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_start_date'
        iv_value = ls_old_run-start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_start_date'
        iv_value = ls_new_run-start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_start_time'
        iv_value = ls_old_run-start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_start_time'
        iv_value = ls_new_run-start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_finish_date'
        iv_value = ls_old_run-finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_finish_date'
        iv_value = ls_new_run-finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_finish_time'
        iv_value = ls_old_run-finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_finish_time'
        iv_value = ls_new_run-finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on_from'
        iv_value = ls_old_run-requested_on_from ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on_from'
        iv_value = ls_new_run-requested_on_from ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on_to'
        iv_value = ls_old_run-requested_on_to ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on_to'
        iv_value = ls_new_run-requested_on_to ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_available'
        iv_value = ls_old_run-available ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_available'
        iv_value = ls_new_run-available ) TO lt_json_fields.
      IF p_typed = abap_true AND ls_old_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_duration_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND ls_new_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_duration_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_running_age_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND lv_new_running_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_running_age_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true
          AND lv_new_running_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_audit_running_age_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_running_age_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_aud_run_age_delta_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_running_age_trend'
        iv_value = lv_aud_run_age_trend ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_message'
        iv_value = ls_old_run-message ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_message'
        iv_value = ls_new_run-message ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reconciliation_fields'
        iv_value = ls_old_reconciliation-mismatch_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reconciliation_fields'
        iv_value = ls_new_reconciliation-mismatch_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reconciliation'
        iv_value = lv_old_reconciliation ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reconciliation'
        iv_value = lv_new_reconciliation ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_changed'
        iv_value = lv_recon_status_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_ok'
        iv_value = lv_recon_both_ok ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_reconciliation_transition'
        iv_value = lv_recon_transition ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_metadata_changed'
        iv_value = lv_audit_meta_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_metadata_change_reasons'
        iv_value = lv_audit_meta_reasons ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_audit_unit'
        iv_value = ls_old_run-unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_audit_unit'
        iv_value = ls_new_run-unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_demand_count'
        iv_value = ls_old_run-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_demand_count'
        iv_value = ls_new_run-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_full_rows'
        iv_value = ls_old_run-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_full_rows'
        iv_value = ls_new_run-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_partial_rows'
        iv_value = ls_old_run-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_partial_rows'
        iv_value = ls_new_run-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_unallocated_rows'
        iv_value = ls_old_run-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_unallocated_rows'
        iv_value = ls_new_run-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_demand_count_delta'
        iv_value = lv_audit_demand_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_full_rows_delta'
        iv_value = lv_audit_full_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_partial_rows_delta'
        iv_value = lv_audit_partial_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_unallocated_rows_delta'
        iv_value = lv_audit_unallocated_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_requested'
        iv_value = ls_old_run-requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_requested'
        iv_value = ls_new_run-requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_allocated'
        iv_value = ls_old_run-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_allocated'
        iv_value = ls_new_run-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_shortage'
        iv_value = ls_old_run-shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_shortage'
        iv_value = ls_new_run-shortage ) TO lt_json_fields.
      IF p_typed = abap_true AND ls_old_run-requested > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_audit_coverage_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_audit_shortage_pct' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND ls_new_run-requested > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_audit_coverage_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_audit_shortage_pct' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_units_match'
        iv_value = lv_audit_units_match ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_horizon_changed'
        iv_value = lv_audit_horizon_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_status_changed'
        iv_value = lv_audit_status_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_strategy_changed'
        iv_value = lv_audit_strategy_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_running_changed'
        iv_value = lv_audit_running_changed ) TO lt_json_fields.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_aud_dur_delta_secs ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_duration_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_audit_duration_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND ls_old_run-start_date IS NOT INITIAL
          AND ls_new_run-start_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_aud_start_delta_secs ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_start_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_audit_start_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_aud_finish_delta_secs ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_finish_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_audit_finish_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_requested_delta' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_available_delta' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_allocated_delta' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_delta' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true
          AND ls_old_run-requested > 0 AND ls_new_run-requested > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_audit_shortage_pct_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_coverage_delta_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_pct_delta' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_aud_shrt_pct_delta_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_rows'
        iv_value = lines( lt_old ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_rows'
        iv_value = lines( lt_new ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_requested'
        iv_value = lv_old_requested_total ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_requested'
        iv_value = lv_new_requested_total ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_full_rows'
        iv_value = ls_old_reconciliation-snapshot_full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_full_rows'
        iv_value = ls_new_reconciliation-snapshot_full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_partial_rows'
        iv_value = ls_old_reconciliation-snapshot_partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_partial_rows'
        iv_value = ls_new_reconciliation-snapshot_partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_unallocated_rows'
        iv_value = ls_old_reconciliation-snapshot_unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_unallocated_rows'
        iv_value = ls_new_reconciliation-snapshot_unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_allocated'
        iv_value = ls_old_reconciliation-snapshot_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_allocated'
        iv_value = ls_new_reconciliation-snapshot_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_shortage'
        iv_value = ls_old_reconciliation-snapshot_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_shortage'
        iv_value = ls_new_reconciliation-snapshot_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'returned_rows'
        iv_value = lines( lt_changes ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'offset'
        iv_value = p_skip ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'max_rows'
        iv_value = p_max ) TO lt_json_fields.
      IF p_meta = abap_true.
        CONCATENATE '"summary":{' lv_summary_json_fields '}'
          INTO lv_json_line.
        APPEND lv_json_line TO lt_json_fields.
      ELSE.
        APPEND LINES OF lt_summary_json_fields TO lt_json_fields.
      ENDIF.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_fields
        SEPARATED BY ','.
      WRITE: / '{' NO-GAP.
      WRITE: / lv_json_fields NO-GAP.
      WRITE: / '}' NO-GAP.
      RETURN.
    ENDIF.
  ENDIF.

  IF p_csv = abap_true.
    WRITE: / 'schema_version;generated_date;generated_time;change_type;change_reasons;allocation_unit;order_id;'
      && 'old_allocation_strategy;new_allocation_strategy;old_sales_document;new_sales_document;'
      && 'old_sales_document_type;new_sales_document_type;old_sales_item;new_sales_item;old_schedule_line;'
      && 'new_schedule_line;old_order_unit;new_order_unit;old_requested_on;new_requested_on;old_priority;'
      && 'new_priority;old_status;new_status;old_requested;new_requested;delta_requested;old_allocated;'
      && 'new_allocated;delta_allocated;old_shortage;new_shortage;delta_shortage;old_reservation_id;'
      && 'new_reservation_id;old_reservation_date;new_reservation_date;old_reservation_movement_type;'
      && 'new_reservation_movement_type;old_reservation_unit;new_reservation_unit;old_run_status;new_run_status;'
      && 'old_run_strategy;new_run_strategy;old_start_date;new_start_date;old_start_time;new_start_time;'
      && 'old_finish_date;new_finish_date;old_requested_on_from;new_requested_on_from;old_requested_on_to;'
      && 'new_requested_on_to;old_available;new_available;old_duration_seconds;new_duration_seconds;'
      && 'old_running_age_seconds;new_running_age_seconds;audit_running_age_delta_seconds;audit_running_age_trend;'
      && 'old_message;new_message;old_reconciliation;new_reconciliation;audit_reconciliation_changed;'
      && 'audit_reconciliation_ok;audit_reconciliation_transition;audit_metadata_changed;'
      && 'audit_metadata_change_reasons;old_reconciliation_fields;new_reconciliation_fields;old_audit_unit;'
      && 'new_audit_unit;audit_units_match;audit_horizon_changed;audit_status_changed;audit_strategy_changed;'
      && 'audit_running_changed;audit_duration_delta_seconds;audit_start_delta_seconds;audit_finish_delta_seconds;'
      && 'old_audit_demand_count;new_audit_demand_count;old_audit_full_rows;new_audit_full_rows;'
      && 'old_audit_partial_rows;new_audit_partial_rows;old_audit_unallocated_rows;new_audit_unallocated_rows;'
      && 'audit_demand_count_delta;audit_full_rows_delta;audit_partial_rows_delta;audit_unallocated_rows_delta;'
      && 'old_audit_requested;new_audit_requested;old_audit_allocated;new_audit_allocated;old_audit_shortage;'
      && 'new_audit_shortage;old_audit_coverage_pct;new_audit_coverage_pct;old_audit_shortage_pct;'
      && 'new_audit_shortage_pct;audit_requested_delta;audit_available_delta;audit_allocated_delta;'
      && 'audit_shortage_delta;audit_coverage_delta_pct;audit_shortage_pct_delta;old_snapshot_rows;'
      && 'new_snapshot_rows;old_snapshot_requested;new_snapshot_requested;old_snapshot_full_rows;'
      && 'new_snapshot_full_rows;old_snapshot_partial_rows;new_snapshot_partial_rows;old_snapshot_unallocated_rows;'
      && 'new_snapshot_unallocated_rows;old_snapshot_allocated;new_snapshot_allocated;old_snapshot_shortage;'
      && 'new_snapshot_shortage;reconciliation_guard;reason_filter;total_rows;offset;max_rows'.
    LOOP AT lt_changes ASSIGNING <ls_change>.
      CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>number( 20 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-change_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-change_reasons ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-allocation_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-order_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_allocation_strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_allocation_strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_sales_document ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_sales_document ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_sales_document_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_sales_document_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_sales_item ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_sales_item ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_schedule_line ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_schedule_line ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_order_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_order_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-old_requested_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-new_requested_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_priority ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_priority ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-old_status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-new_status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-delta_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-delta_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-delta_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-old_reservation_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-new_reservation_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_reservation_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_reservation_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_reservation_movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_reservation_movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_reservation_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_reservation_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-available ) TO lt_csv_fields.
      APPEND lv_old_duration_text TO lt_csv_fields.
      APPEND lv_new_duration_text TO lt_csv_fields.
      APPEND lv_old_running_age_text TO lt_csv_fields.
      APPEND lv_new_running_age_text TO lt_csv_fields.
      APPEND lv_aud_run_age_delta_text TO lt_csv_fields.
      APPEND lv_aud_run_age_trend TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_both_ok ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_transition ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_reasons ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_old_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_new_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_units_match ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_horizon_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_strategy_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_running_changed ) TO lt_csv_fields.
      APPEND lv_audit_duration_delta_text TO lt_csv_fields.
      APPEND lv_audit_start_delta_text TO lt_csv_fields.
      APPEND lv_audit_finish_delta_text TO lt_csv_fields.
      APPEND lv_audit_requested_delta_text TO lt_csv_fields.
      APPEND lv_audit_available_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_demand_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_full_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_partial_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_unallocated_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-shortage ) TO lt_csv_fields.
      APPEND lv_old_audit_coverage_text TO lt_csv_fields.
      APPEND lv_new_audit_coverage_text TO lt_csv_fields.
      APPEND lv_old_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_new_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_audit_allocated_delta_text TO lt_csv_fields.
      APPEND lv_audit_shortage_delta_text TO lt_csv_fields.
      APPEND lv_audit_coverage_delta_text TO lt_csv_fields.
      APPEND lv_aud_shrt_pct_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_old ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_new ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_old_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_new_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_guard ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
    ENDLOOP.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    IF p_ndjson = abap_false AND p_meta = abap_true.
      WRITE: / '{' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 20 ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'total_rows'
        iv_value = lv_total_rows ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'offset'
        iv_value = p_skip ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'max_rows'
        iv_value = p_max ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_run'
        iv_value = p_old ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_run'
        iv_value = p_new ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'change_type'
        iv_value = p_chg ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reason_filter'
        iv_value = p_reason ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'include_unchanged'
        iv_value = p_all ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'reconciliation_guard'
        iv_value = p_guard ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_run_status'
        iv_value = ls_old_run-status ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_run_status'
        iv_value = ls_new_run-status ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_run_strategy'
        iv_value = ls_old_run-strategy ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_run_strategy'
        iv_value = ls_new_run-strategy ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_start_date'
        iv_value = ls_old_run-start_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_start_date'
        iv_value = ls_new_run-start_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_start_time'
        iv_value = ls_old_run-start_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_start_time'
        iv_value = ls_new_run-start_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_finish_date'
        iv_value = ls_old_run-finish_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_finish_date'
        iv_value = ls_new_run-finish_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_finish_time'
        iv_value = ls_old_run-finish_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_finish_time'
        iv_value = ls_new_run-finish_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_on_from'
        iv_value = ls_old_run-requested_on_from ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_on_from'
        iv_value = ls_new_run-requested_on_from ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_on_to'
        iv_value = ls_old_run-requested_on_to ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_on_to'
        iv_value = ls_new_run-requested_on_to ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_available'
        iv_value = ls_old_run-available ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_available'
        iv_value = ls_new_run-available ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_old_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_duration_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_new_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_duration_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_running_age_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND lv_new_running_age_available = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_running_age_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true
          AND lv_new_running_age_available = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_audit_running_age_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_running_age_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_aud_run_age_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_running_age_trend'
        iv_value = lv_aud_run_age_trend ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_message'
        iv_value = ls_old_run-message ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_message'
        iv_value = ls_new_run-message ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reconciliation_fields'
        iv_value = ls_old_reconciliation-mismatch_fields ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reconciliation_fields'
        iv_value = ls_new_reconciliation-mismatch_fields ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reconciliation'
        iv_value = lv_old_reconciliation ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reconciliation'
        iv_value = lv_new_reconciliation ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_changed'
        iv_value = lv_recon_status_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_ok'
        iv_value = lv_recon_both_ok ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_reconciliation_transition'
        iv_value = lv_recon_transition ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_metadata_changed'
        iv_value = lv_audit_meta_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_metadata_change_reasons'
        iv_value = lv_audit_meta_reasons ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_audit_unit'
        iv_value = ls_old_run-unit ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_audit_unit'
        iv_value = ls_new_run-unit ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_demand_count'
        iv_value = ls_old_run-demand_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_demand_count'
        iv_value = ls_new_run-demand_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_full_rows'
        iv_value = ls_old_run-full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_full_rows'
        iv_value = ls_new_run-full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_partial_rows'
        iv_value = ls_old_run-partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_partial_rows'
        iv_value = ls_new_run-partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_unallocated_rows'
        iv_value = ls_old_run-unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_unallocated_rows'
        iv_value = ls_new_run-unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_demand_count_delta'
        iv_value = lv_audit_demand_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_full_rows_delta'
        iv_value = lv_audit_full_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_partial_rows_delta'
        iv_value = lv_audit_partial_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_unallocated_rows_delta'
        iv_value = lv_audit_unallocated_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_requested'
        iv_value = ls_old_run-requested ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_requested'
        iv_value = ls_new_run-requested ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_allocated'
        iv_value = ls_old_run-allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_allocated'
        iv_value = ls_new_run-allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_shortage'
        iv_value = ls_old_run-shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_shortage'
        iv_value = ls_new_run-shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_old_run-requested > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_audit_coverage_pct' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_audit_shortage_pct' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_new_run-requested > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_audit_coverage_pct' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_audit_shortage_pct' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_units_match'
        iv_value = lv_audit_units_match ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_horizon_changed'
        iv_value = lv_audit_horizon_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_status_changed'
        iv_value = lv_audit_status_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_strategy_changed'
        iv_value = lv_audit_strategy_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_running_changed'
        iv_value = lv_audit_running_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_aud_dur_delta_secs ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_duration_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_audit_duration_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND ls_old_run-start_date IS NOT INITIAL
          AND ls_new_run-start_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_aud_start_delta_secs ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_start_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_audit_start_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_aud_finish_delta_secs ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_finish_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_audit_finish_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_requested_delta' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_available_delta' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_allocated_delta' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_delta' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true
          AND ls_old_run-requested > 0 AND ls_new_run-requested > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_audit_shortage_pct_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_coverage_delta_pct' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_pct_delta' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_aud_shrt_pct_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_rows'
        iv_value = lines( lt_old ) ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_rows'
        iv_value = lines( lt_new ) ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_requested'
        iv_value = lv_old_requested_total ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_requested'
        iv_value = lv_new_requested_total ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_full_rows'
        iv_value = ls_old_reconciliation-snapshot_full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_full_rows'
        iv_value = ls_new_reconciliation-snapshot_full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_partial_rows'
        iv_value = ls_old_reconciliation-snapshot_partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_partial_rows'
        iv_value = ls_new_reconciliation-snapshot_partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_unallocated_rows'
        iv_value = ls_old_reconciliation-snapshot_unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_unallocated_rows'
        iv_value = ls_new_reconciliation-snapshot_unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_allocated'
        iv_value = ls_old_reconciliation-snapshot_allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_allocated'
        iv_value = ls_new_reconciliation-snapshot_allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_shortage'
        iv_value = ls_old_reconciliation-snapshot_shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_shortage'
        iv_value = ls_new_reconciliation-snapshot_shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / '"rows":[' NO-GAP.
    ELSEIF p_ndjson = abap_false.
      WRITE: / '['.
    ENDIF.
    lv_first = abap_true.
    LOOP AT lt_changes ASSIGNING <ls_change>.
      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'change_type'
        iv_value = <ls_change>-change_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'change_reasons'
        iv_value = <ls_change>-change_reasons ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_unit'
        iv_value = <ls_change>-allocation_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'order_id'
        iv_value = <ls_change>-order_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_allocation_strategy'
        iv_value = <ls_change>-old_allocation_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_allocation_strategy'
        iv_value = <ls_change>-new_allocation_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_document'
        iv_value = <ls_change>-old_sales_document ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_document'
        iv_value = <ls_change>-new_sales_document ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_document_type'
        iv_value = <ls_change>-old_sales_document_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_document_type'
        iv_value = <ls_change>-new_sales_document_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_item'
        iv_value = <ls_change>-old_sales_item ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_item'
        iv_value = <ls_change>-new_sales_item ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_schedule_line'
        iv_value = <ls_change>-old_schedule_line ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_schedule_line'
        iv_value = <ls_change>-new_schedule_line ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_order_unit'
        iv_value = <ls_change>-old_order_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_order_unit'
        iv_value = <ls_change>-new_order_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on'
        iv_value = <ls_change>-old_requested_on ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on'
        iv_value = <ls_change>-new_requested_on ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_priority'
          iv_value = <ls_change>-old_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_priority'
          iv_value = <ls_change>-new_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_requested'
          iv_value = <ls_change>-old_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_requested'
          iv_value = <ls_change>-new_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_requested'
          iv_value = <ls_change>-delta_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_allocated'
          iv_value = <ls_change>-old_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_allocated'
          iv_value = <ls_change>-new_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_allocated'
          iv_value = <ls_change>-delta_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_shortage'
          iv_value = <ls_change>-old_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_shortage'
          iv_value = <ls_change>-new_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_shortage'
          iv_value = <ls_change>-delta_shortage ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_priority'
          iv_value = <ls_change>-old_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_priority'
          iv_value = <ls_change>-new_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_requested'
          iv_value = <ls_change>-old_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_requested'
          iv_value = <ls_change>-new_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_requested'
          iv_value = <ls_change>-delta_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_allocated'
          iv_value = <ls_change>-old_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_allocated'
          iv_value = <ls_change>-new_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_allocated'
          iv_value = <ls_change>-delta_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_shortage'
          iv_value = <ls_change>-old_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_shortage'
          iv_value = <ls_change>-new_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_shortage'
          iv_value = <ls_change>-delta_shortage ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_status'
        iv_value = <ls_change>-old_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_status'
        iv_value = <ls_change>-new_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_id'
        iv_value = <ls_change>-old_reservation_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_id'
        iv_value = <ls_change>-new_reservation_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_date'
        iv_value = <ls_change>-old_reservation_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_date'
        iv_value = <ls_change>-new_reservation_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_movement_type'
        iv_value = <ls_change>-old_reservation_movement_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_movement_type'
        iv_value = <ls_change>-new_reservation_movement_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_unit'
        iv_value = <ls_change>-old_reservation_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_unit'
        iv_value = <ls_change>-new_reservation_unit ) TO lt_json_fields.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_fields SEPARATED BY ','.
      lv_json_line = '{'.
      CONCATENATE lv_json_line lv_json_fields '}' INTO lv_json_line.
      IF p_ndjson = abap_true.
        WRITE: / lv_json_line NO-GAP.
      ELSE.
        IF lv_first = abap_true.
          lv_first = abap_false.
        ELSE.
          WRITE: / ',' NO-GAP.
        ENDIF.
        WRITE: / lv_json_line NO-GAP.
      ENDIF.
    ENDLOOP.
    IF p_ndjson = abap_false.
      IF p_meta = abap_true.
        WRITE: / ']}' NO-GAP.
      ELSE.
        WRITE: / ']' NO-GAP.
      ENDIF.
    ENDIF.
    RETURN.
  ENDIF.

  IF p_sum = abap_true.
    WRITE: / 'Allocation snapshot comparison summary'.
    WRITE: / 'Schema version:', 7.
    WRITE: / 'Generated date/time:', sy-datum, sy-uzeit.
    WRITE: / 'Old run:', p_old.
    WRITE: / 'New run:', p_new.
    WRITE: / 'Reason filter:', p_reason.
    WRITE: / 'Reconciliation guard:', p_guard.
    WRITE: / 'Old status/strategy:', ls_old_run-status, ls_old_run-strategy,
      'New status/strategy:', ls_new_run-status, ls_new_run-strategy.
    WRITE: / 'Old start/finish:', ls_old_run-start_date,
      ls_old_run-start_time, ls_old_run-finish_date,
      ls_old_run-finish_time,
      'New start/finish:', ls_new_run-start_date,
      ls_new_run-start_time, ls_new_run-finish_date,
      ls_new_run-finish_time.
    WRITE: / 'Old requested horizon:', ls_old_run-requested_on_from,
      ls_old_run-requested_on_to,
      'New requested horizon:', ls_new_run-requested_on_from,
      ls_new_run-requested_on_to.
    WRITE: / 'Available old/new:', ls_old_run-available, ls_new_run-available.
    WRITE: / 'Duration seconds old/new:', lv_old_duration_text,
      lv_new_duration_text.
    WRITE: / 'Running age seconds old/new:', lv_old_running_age_text,
      lv_new_running_age_text.
    WRITE: / 'Old message:', ls_old_run-message.
    WRITE: / 'New message:', ls_new_run-message.
    WRITE: / 'Old reconciliation:', lv_old_reconciliation,
      'Snapshot rows:', lines( lt_old ).
    WRITE: / 'Old reconciliation fields:',
      ls_old_reconciliation-mismatch_fields.
    WRITE: / 'Audit unit old/new:', ls_old_run-unit, ls_new_run-unit.
    WRITE: / 'Audit demand count old/new:', ls_old_run-demand_count,
      ls_new_run-demand_count.
    WRITE: / 'Audit full rows old/new:', ls_old_run-full_count,
      ls_new_run-full_count.
    WRITE: / 'Audit partial rows old/new:', ls_old_run-partial_count,
      ls_new_run-partial_count.
    WRITE: / 'Audit unallocated rows old/new:',
      ls_old_run-unallocated_count, ls_new_run-unallocated_count.
    WRITE: / 'Audit outcome counter deltas:', lv_audit_demand_delta,
      lv_audit_full_delta, lv_audit_partial_delta,
      lv_audit_unallocated_delta.
    WRITE: / 'Audit requested old/new:', ls_old_run-requested,
      ls_new_run-requested.
    WRITE: / 'Audit allocated old/new:', ls_old_run-allocated,
      ls_new_run-allocated.
    WRITE: / 'Audit shortage old/new:', ls_old_run-shortage,
      ls_new_run-shortage.
    WRITE: / 'Audit coverage pct old/new:', lv_old_audit_coverage_text,
      lv_new_audit_coverage_text.
    WRITE: / 'Audit shortage pct old/new:',
      lv_old_audit_shortage_pct_text, lv_new_audit_shortage_pct_text.
    WRITE: / 'Audit units match:', lv_audit_units_match.
    WRITE: / 'Audit horizon changed:', lv_audit_horizon_changed.
    WRITE: / 'Audit status/strategy changed:',
      lv_audit_status_changed, lv_audit_strategy_changed.
    WRITE: / 'Audit running changed:', lv_audit_running_changed.
    WRITE: / 'Audit duration delta seconds:',
      lv_audit_duration_delta_text.
    WRITE: / 'Audit running age delta seconds:',
      lv_aud_run_age_delta_text.
    WRITE: / 'Audit running age trend:', lv_aud_run_age_trend.
    WRITE: / 'Audit start/finish delta seconds:',
      lv_audit_start_delta_text, lv_audit_finish_delta_text.
    WRITE: / 'Audit requested/available delta:',
      lv_audit_requested_delta_text, lv_audit_available_delta_text.
    WRITE: / 'Audit allocated/shortage delta:',
      lv_audit_allocated_delta_text, lv_audit_shortage_delta_text.
    WRITE: / 'Audit coverage/shortage pct delta:',
      lv_audit_coverage_delta_text, lv_aud_shrt_pct_delta_text.
    WRITE: / 'Snapshot requested old/new:', lv_old_requested_total,
      lv_new_requested_total.
    WRITE: / 'Snapshot full rows old/new:',
      ls_old_reconciliation-snapshot_full_count,
      ls_new_reconciliation-snapshot_full_count.
    WRITE: / 'Snapshot partial rows old/new:',
      ls_old_reconciliation-snapshot_partial_count,
      ls_new_reconciliation-snapshot_partial_count.
    WRITE: / 'Snapshot unallocated rows old/new:',
      ls_old_reconciliation-snapshot_unallocated_count,
      ls_new_reconciliation-snapshot_unallocated_count.
    WRITE: / 'Snapshot allocated old/new:',
      ls_old_reconciliation-snapshot_allocated,
      ls_new_reconciliation-snapshot_allocated.
    WRITE: / 'Snapshot shortage old/new:',
      ls_old_reconciliation-snapshot_shortage,
      ls_new_reconciliation-snapshot_shortage.
    WRITE: / 'New reconciliation:', lv_new_reconciliation,
      'Snapshot rows:', lines( lt_new ).
    WRITE: / 'Audit reconciliation changed:', lv_recon_status_changed.
    WRITE: / 'Audit reconciliation OK:', lv_recon_both_ok.
    WRITE: / 'Audit reconciliation transition:', lv_recon_transition.
    WRITE: / 'Audit metadata changed:', lv_audit_meta_changed.
    WRITE: / 'Audit metadata change reasons:', lv_audit_meta_reasons.
    WRITE: / 'New reconciliation fields:',
      ls_new_reconciliation-mismatch_fields.
    WRITE: / 'Total matching changes:', ls_summary-total_rows.
    WRITE: / 'Returned changes:', lines( lt_changes ).
    WRITE: / 'Added:', ls_summary-added_rows,
      'Removed:', ls_summary-removed_rows,
      'Changed:', ls_summary-changed_rows,
      'Unchanged:', ls_summary-unchanged_rows.
    IF ls_summary-mixed_units = abap_true.
      WRITE: / 'Unit: mixed',
        'Mixed units:', ls_summary-mixed_units.
      WRITE: / 'Quantity totals: n/a (mixed allocation units).' .
    ELSE.
      WRITE: / 'Unit:', ls_summary-unit,
        'Mixed units:', ls_summary-mixed_units.
      WRITE: / 'Requested old/new/delta:', ls_summary-old_requested,
        ls_summary-new_requested, ls_summary-delta_requested.
      WRITE: / 'Allocated old/new/delta:', ls_summary-old_allocated,
        ls_summary-new_allocated, ls_summary-delta_allocated.
      WRITE: / 'Shortage old/new/delta:', ls_summary-old_shortage,
        ls_summary-new_shortage, ls_summary-delta_shortage.
    ENDIF.
    WRITE: / 'Offset:', p_skip, 'Max rows:', p_max.
    RETURN.
  ENDIF.

  WRITE: / 'Allocation snapshot comparison'.
  WRITE: / 'Schema version:', 7.
  WRITE: / 'Generated date/time:', sy-datum, sy-uzeit.
  WRITE: / 'Old run:', p_old.
  WRITE: / 'New run:', p_new.
  WRITE: / 'Reason filter:', p_reason.
  WRITE: / 'Reconciliation guard:', p_guard.
  WRITE: / 'Old status/strategy:', ls_old_run-status, ls_old_run-strategy,
    'New status/strategy:', ls_new_run-status, ls_new_run-strategy.
  WRITE: / 'Old start/finish:', ls_old_run-start_date,
    ls_old_run-start_time, ls_old_run-finish_date,
    ls_old_run-finish_time,
    'New start/finish:', ls_new_run-start_date,
    ls_new_run-start_time, ls_new_run-finish_date,
    ls_new_run-finish_time.
  WRITE: / 'Old requested horizon:', ls_old_run-requested_on_from,
    ls_old_run-requested_on_to,
    'New requested horizon:', ls_new_run-requested_on_from,
    ls_new_run-requested_on_to.
  WRITE: / 'Available old/new:', ls_old_run-available, ls_new_run-available.
  WRITE: / 'Duration seconds old/new:', lv_old_duration_text,
    lv_new_duration_text.
  WRITE: / 'Running age seconds old/new:', lv_old_running_age_text,
    lv_new_running_age_text.
  WRITE: / 'Old message:', ls_old_run-message.
  WRITE: / 'New message:', ls_new_run-message.
  WRITE: / 'Old reconciliation:', lv_old_reconciliation,
    'Snapshot rows:', lines( lt_old ).
  WRITE: / 'Old reconciliation fields:',
    ls_old_reconciliation-mismatch_fields.
  WRITE: / 'Audit unit old/new:', ls_old_run-unit, ls_new_run-unit.
  WRITE: / 'Audit demand count old/new:', ls_old_run-demand_count,
    ls_new_run-demand_count.
  WRITE: / 'Audit full rows old/new:', ls_old_run-full_count,
    ls_new_run-full_count.
  WRITE: / 'Audit partial rows old/new:', ls_old_run-partial_count,
    ls_new_run-partial_count.
  WRITE: / 'Audit unallocated rows old/new:',
    ls_old_run-unallocated_count, ls_new_run-unallocated_count.
  WRITE: / 'Audit outcome counter deltas:', lv_audit_demand_delta,
    lv_audit_full_delta, lv_audit_partial_delta,
    lv_audit_unallocated_delta.
  WRITE: / 'Audit requested old/new:', ls_old_run-requested,
    ls_new_run-requested.
  WRITE: / 'Audit allocated old/new:', ls_old_run-allocated,
    ls_new_run-allocated.
  WRITE: / 'Audit shortage old/new:', ls_old_run-shortage,
    ls_new_run-shortage.
  WRITE: / 'Audit coverage pct old/new:', lv_old_audit_coverage_text,
    lv_new_audit_coverage_text.
  WRITE: / 'Audit shortage pct old/new:',
    lv_old_audit_shortage_pct_text, lv_new_audit_shortage_pct_text.
  WRITE: / 'Audit units match:', lv_audit_units_match.
  WRITE: / 'Audit horizon changed:', lv_audit_horizon_changed.
  WRITE: / 'Audit status/strategy changed:',
    lv_audit_status_changed, lv_audit_strategy_changed.
  WRITE: / 'Audit running changed:', lv_audit_running_changed.
  WRITE: / 'Audit duration delta seconds:',
    lv_audit_duration_delta_text.
  WRITE: / 'Audit running age delta seconds:',
    lv_aud_run_age_delta_text.
  WRITE: / 'Audit running age trend:', lv_aud_run_age_trend.
  WRITE: / 'Audit start/finish delta seconds:',
    lv_audit_start_delta_text, lv_audit_finish_delta_text.
  WRITE: / 'Audit requested/available delta:',
    lv_audit_requested_delta_text, lv_audit_available_delta_text.
  WRITE: / 'Audit allocated/shortage delta:',
    lv_audit_allocated_delta_text, lv_audit_shortage_delta_text.
  WRITE: / 'Audit coverage/shortage pct delta:',
    lv_audit_coverage_delta_text, lv_aud_shrt_pct_delta_text.
  WRITE: / 'Snapshot requested old/new:', lv_old_requested_total,
    lv_new_requested_total.
  WRITE: / 'Snapshot full rows old/new:',
    ls_old_reconciliation-snapshot_full_count,
    ls_new_reconciliation-snapshot_full_count.
  WRITE: / 'Snapshot partial rows old/new:',
    ls_old_reconciliation-snapshot_partial_count,
    ls_new_reconciliation-snapshot_partial_count.
  WRITE: / 'Snapshot unallocated rows old/new:',
    ls_old_reconciliation-snapshot_unallocated_count,
    ls_new_reconciliation-snapshot_unallocated_count.
  WRITE: / 'Snapshot allocated old/new:',
    ls_old_reconciliation-snapshot_allocated,
    ls_new_reconciliation-snapshot_allocated.
  WRITE: / 'Snapshot shortage old/new:',
    ls_old_reconciliation-snapshot_shortage,
    ls_new_reconciliation-snapshot_shortage.
  WRITE: / 'New reconciliation:', lv_new_reconciliation,
    'Snapshot rows:', lines( lt_new ).
  WRITE: / 'Audit reconciliation changed:', lv_recon_status_changed.
  WRITE: / 'Audit reconciliation OK:', lv_recon_both_ok.
  WRITE: / 'Audit reconciliation transition:', lv_recon_transition.
  WRITE: / 'Audit metadata changed:', lv_audit_meta_changed.
  WRITE: / 'Audit metadata change reasons:', lv_audit_meta_reasons.
  WRITE: / 'New reconciliation fields:',
    ls_new_reconciliation-mismatch_fields.
  WRITE: / 'Total matching changes:', lv_total_rows.
  WRITE: / 'Returned changes:', lines( lt_changes ).
  WRITE: / 'Offset:', p_skip, 'Max rows:', p_max.
  IF lt_changes IS INITIAL.
    WRITE: / 'No allocation changes found.'.
    RETURN.
  ENDIF.
  WRITE: / 'Type', 8 'Unit', 15 'Order', 38 'Reasons', 80 'Old status',
    92 'New status', 104 'Old alloc', 118 'New alloc', 132 'Delta alloc',
    148 'Old shortage', 164 'New shortage', 180 'Delta shortage'.
  LOOP AT lt_changes ASSIGNING <ls_change>.
    WRITE: / <ls_change>-change_type,
      8 <ls_change>-allocation_unit,
      15 <ls_change>-order_id,
      38 <ls_change>-change_reasons,
      80 <ls_change>-old_status,
      92 <ls_change>-new_status,
      104 <ls_change>-old_allocated,
      118 <ls_change>-new_allocated,
      132 <ls_change>-delta_allocated,
      148 <ls_change>-old_shortage,
      164 <ls_change>-new_shortage,
      180 <ls_change>-delta_shortage.
  ENDLOOP.
