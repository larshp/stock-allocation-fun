REPORT zstock_alloc_health.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_dfrom TYPE i.
PARAMETERS p_dto TYPE i.
PARAMETERS p_avf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_spf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_tfrom TYPE i.
PARAMETERS p_tto TYPE i.
PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_ffrom TYPE d.
PARAMETERS p_fto TYPE d.
PARAMETERS p_legacy AS CHECKBOX.
PARAMETERS p_cov TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_spct TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_safon AS CHECKBOX.
PARAMETERS p_saf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_safto TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_ovrd AS CHECKBOX.
PARAMETERS p_odate TYPE d.
PARAMETERS p_dead AS CHECKBOX.
PARAMETERS p_deadf TYPE d.
PARAMETERS p_deadt TYPE d.
PARAMETERS p_dagef TYPE i.
PARAMETERS p_daget TYPE i.
PARAMETERS p_daged TYPE d.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_stale TYPE i DEFAULT 3600.
PARAMETERS p_age_to TYPE i.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
  DATA ls_stale_summary TYPE zif_allocation_audit=>ty_summary.
  DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error TYPE string.
  DATA lv_overdue_date TYPE d.
  DATA lv_deadline_age_date TYPE d.

  IF p_csv = abap_true AND p_json = abap_true.
    lv_error = 'Select only one export mode: CSV or JSON'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSE.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ENDIF.
    RETURN.
  ENDIF.
  IF p_stale < 0.
    lv_error = 'Stale threshold cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cov < 0 OR p_cov > 100.
    lv_error = 'Minimum coverage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_spct < 0 OR p_spct > 100.
    lv_error = 'Maximum shortage percentage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_legacy = abap_true AND p_strat IS NOT INITIAL.
    lv_error = 'Legacy strategy filter cannot be combined with a strategy filter'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_odate IS NOT INITIAL AND p_ovrd = abap_false.
    lv_error = 'Overdue as-of date requires overdue filtering'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ovrd = abap_true.
    lv_overdue_date = p_odate.
    IF lv_overdue_date IS INITIAL.
      lv_overdue_date = sy-datum.
    ENDIF.
  ENDIF.
  IF p_deadf IS NOT INITIAL AND p_deadt IS NOT INITIAL
      AND p_deadf > p_deadt.
    lv_error = 'Requested deadline start must not be after end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dagef IS NOT INITIAL AND p_daget IS NOT INITIAL
      AND p_dagef > p_daget.
    lv_error = 'Deadline age start must not be after end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_daged IS NOT INITIAL
      AND p_dagef IS INITIAL AND p_daget IS INITIAL.
    lv_error = 'Deadline age date requires an age range'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_health'
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL.
    lv_deadline_age_date = p_daged.
    IF lv_deadline_age_date IS INITIAL.
      lv_deadline_age_date = sy-datum.
    ENDIF.
  ENDIF.

  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_strat TO UPPER CASE.
  TRANSLATE p_stat TO UPPER CASE.
  TRANSLATE p_meins TO UPPER CASE.
  CREATE OBJECT lo_authority TYPE zcl_allocation_read_auth_sap.
  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_read_authority = lo_authority.
  TRY.
      ls_summary = lo_audit->get_summary(
        iv_material          = p_matnr
        iv_plant             = p_werks
        iv_storage_location  = p_lgort
        iv_batch             = p_charg
        iv_unit              = p_meins
        iv_movement_type     = p_mvt
        iv_strategy          = p_strat
        iv_status            = p_stat
        iv_message_contains  = p_msg
        iv_message_only      = p_monly
        iv_demand_from       = p_dfrom
        iv_demand_to         = p_dto
        iv_available_from    = p_avf
        iv_available_to      = p_avt
        iv_requested_from    = p_qf
        iv_requested_to      = p_qt
        iv_allocated_from    = p_af
        iv_allocated_to      = p_at
        iv_shortage_from     = p_shf
        iv_shortage_to       = p_sht
        iv_shortage_pct_from = p_spf
        iv_shortage_pct_to   = p_spt
        iv_coverage_from     = p_covf
        iv_coverage_to       = p_covt
        iv_duration_from     = p_tfrom
        iv_duration_to       = p_tto
        iv_start_date_from   = p_from
        iv_start_date_to     = p_to
        iv_finish_date_from  = p_ffrom
        iv_finish_date_to    = p_fto
        iv_running_age_to    = p_age_to
        iv_legacy_strategy   = p_legacy
        iv_min_shelf_life    = p_shelf
        iv_safety_filter     = p_safon
        iv_safety_from       = p_saf
        iv_safety_to         = p_safto
        iv_requested_on_from = p_reqf
        iv_requested_on_to   = p_until
        iv_requested_overdue = p_ovrd
        iv_overdue_date      = lv_overdue_date
        iv_deadline_only     = p_dead
        iv_deadline_from     = p_deadf
        iv_deadline_to       = p_deadt
        iv_deadline_age_from = p_dagef
        iv_deadline_age_to   = p_daget
        iv_deadline_age_date = lv_deadline_age_date ).
      IF p_stale > 0.
        ls_stale_summary = lo_audit->get_summary(
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_unit              = p_meins
          iv_movement_type     = p_mvt
          iv_strategy          = p_strat
          iv_status            = p_stat
          iv_message_contains  = p_msg
          iv_message_only      = p_monly
          iv_demand_from       = p_dfrom
          iv_demand_to         = p_dto
          iv_available_from    = p_avf
          iv_available_to      = p_avt
          iv_requested_from    = p_qf
          iv_requested_to      = p_qt
          iv_allocated_from    = p_af
          iv_allocated_to      = p_at
          iv_shortage_from     = p_shf
          iv_shortage_to       = p_sht
          iv_shortage_pct_from = p_spf
          iv_shortage_pct_to   = p_spt
          iv_coverage_from     = p_covf
          iv_coverage_to       = p_covt
          iv_duration_from     = p_tfrom
          iv_duration_to       = p_tto
          iv_start_date_from   = p_from
          iv_start_date_to     = p_to
          iv_finish_date_from  = p_ffrom
          iv_finish_date_to    = p_fto
          iv_running_age_to    = p_age_to
          iv_legacy_strategy   = p_legacy
          iv_min_shelf_life    = p_shelf
          iv_safety_filter     = p_safon
          iv_safety_from       = p_saf
          iv_safety_to         = p_safto
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until
          iv_requested_overdue = p_ovrd
          iv_overdue_date      = lv_overdue_date
          iv_deadline_only     = p_dead
          iv_deadline_from     = p_deadf
          iv_deadline_to       = p_deadt
          iv_deadline_age_from = p_dagef
          iv_deadline_age_to   = p_daget
          iv_deadline_age_date = lv_deadline_age_date
          iv_stale_seconds     = p_stale ).
      ENDIF.
      ls_health = zcl_stock_allocation_health=>evaluate(
        is_summary               = ls_summary
        iv_stale_running_runs    = ls_stale_summary-running_runs
        iv_stale_scope_evaluated = xsdbool( p_stale > 0 )
        iv_stale_threshold       = p_stale
        iv_min_coverage          = p_cov
        iv_max_shortage_pct      = p_spct ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error = 'Allocation health read failed'.
      ELSE.
        lv_error = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_health'
          iv_message = lv_error ).
      ELSE.
        WRITE: / 'Allocation health failed:', lv_error.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_json = abap_true.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'schema_version'
      iv_value = 28 ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status'
      iv_value = ls_health-status ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message'
      iv_value = ls_health-message ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'reason_code'
      iv_value = ls_health-reason_code ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'strategy_filter'
      iv_value = p_strat ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status_filter'
      iv_value = p_stat ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message_filter'
      iv_value = p_msg ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'message_only'
      iv_value = p_monly ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_demand_count'
      iv_value = p_dfrom ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_demand_count'
      iv_value = p_dto ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_available_stock'
      iv_value = p_avf ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_available_stock'
      iv_value = p_avt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_requested_quantity'
      iv_value = p_qf ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_requested_quantity'
      iv_value = p_qt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_allocated_quantity'
      iv_value = p_af ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_allocated_quantity'
      iv_value = p_at ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_shortage_quantity'
      iv_value = p_shf ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_shortage_quantity'
      iv_value = p_sht ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_shortage_pct'
      iv_value = p_spf ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_shortage_pct'
      iv_value = p_spt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_coverage_pct'
      iv_value = p_covf ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_coverage_pct'
      iv_value = p_covt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'audit_duration_from_filter'
      iv_value = p_tfrom ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'audit_duration_to_filter'
      iv_value = p_tto ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'start_date_from_filter'
      iv_value = p_from ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'start_date_to_filter'
      iv_value = p_to ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'finish_date_from_filter'
      iv_value = p_ffrom ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'finish_date_to_filter'
      iv_value = p_fto ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_running_age_filter'
      iv_value = p_age_to ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'legacy_strategy_filter'
      iv_value = p_legacy ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'overdue_only'
      iv_value = p_ovrd ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_overdue_as_of'
      iv_value = lv_overdue_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'requested_deadline_only'
      iv_value = p_dead ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_deadline_from'
      iv_value = p_deadf ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_deadline_to'
      iv_value = p_deadt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_deadline_age_days'
      iv_value = p_dagef ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_deadline_age_days'
      iv_value = p_daget ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_age_as_of'
      iv_value = lv_deadline_age_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'deadline_count'
      iv_value = ls_health-deadline_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'earliest_requested_deadline'
      iv_value = ls_health-earliest_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'latest_requested_deadline'
      iv_value = ls_health-latest_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_deadline_age_days'
      iv_value = ls_health-last_deadline_age_days ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'oldest_deadline_age_days'
      iv_value = ls_health-oldest_deadline_age_days ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'newest_deadline_age_days'
      iv_value = ls_health-newest_deadline_age_days ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_age_reference_date'
      iv_value = ls_health-deadline_age_reference_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_coverage'
      iv_value = p_cov ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_shortage_pct'
      iv_value = p_spct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'total_runs'
      iv_value = ls_health-total_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'running_runs'
      iv_value = ls_health-running_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'stale_running_runs'
      iv_value = ls_health-stale_running_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'error_runs'
      iv_value = ls_health-error_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'partial_runs'
      iv_value = ls_health-partial_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'fair_runs'
      iv_value = ls_health-fair_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'weighted_runs'
      iv_value = ls_health-weighted_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'adaptive_runs'
      iv_value = ls_health-adaptive_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'adaptive_priority_runs'
      iv_value = ls_health-adaptive_priority_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'adaptive_fair_runs'
      iv_value = ls_health-adaptive_fair_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = ls_health-unit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_available'
      iv_value = ls_health-shortage_available ) TO lt_json_fields.
    IF ls_health-shortage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'requested'
        iv_value = ls_health-requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'allocated'
        iv_value = ls_health-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'shortage'
        iv_value = ls_health-shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'coverage_available'
      iv_value = ls_health-coverage_available ) TO lt_json_fields.
    IF ls_health-coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'coverage_pct'
        iv_value = ls_health-coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'fair_share_available'
      iv_value = ls_health-fair_share_available ) TO lt_json_fields.
    IF ls_health-fair_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_requested'
        iv_value = ls_health-fair_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_allocated'
        iv_value = ls_health-fair_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_shortage'
        iv_value = ls_health-fair_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'fair_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'fair_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'fair_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'fair_coverage_available'
      iv_value = ls_health-fair_coverage_available ) TO lt_json_fields.
    IF ls_health-fair_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_coverage_pct'
        iv_value = ls_health-fair_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'fair_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'weighted_share_available'
      iv_value = ls_health-weighted_share_available ) TO lt_json_fields.
    IF ls_health-weighted_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'weighted_requested'
        iv_value = ls_health-weighted_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'weighted_allocated'
        iv_value = ls_health-weighted_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'weighted_shortage'
        iv_value = ls_health-weighted_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'weighted_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'weighted_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'weighted_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'weighted_coverage_available'
      iv_value = ls_health-weighted_coverage_ok ) TO lt_json_fields.
    IF ls_health-weighted_coverage_ok = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'weighted_coverage_pct'
        iv_value = ls_health-weighted_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'weighted_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'adaptive_share_available'
      iv_value = ls_health-adaptive_share_available ) TO lt_json_fields.
    IF ls_health-adaptive_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'adaptive_requested'
        iv_value = ls_health-adaptive_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'adaptive_allocated'
        iv_value = ls_health-adaptive_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'adaptive_shortage'
        iv_value = ls_health-adaptive_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'adaptive_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'adaptive_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'adaptive_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'adaptive_coverage_available'
      iv_value = ls_health-adaptive_coverage_ok ) TO lt_json_fields.
    IF ls_health-adaptive_coverage_ok = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'adaptive_coverage_pct'
        iv_value = ls_health-adaptive_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'adaptive_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'coverage_threshold_active'
      iv_value = ls_health-coverage_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'coverage_below_threshold'
      iv_value = ls_health-coverage_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_threshold_active'
      iv_value = ls_health-shortage_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_above_threshold'
      iv_value = ls_health-shortage_above_threshold ) TO lt_json_fields.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    WRITE: / 'mode;schema_version;status;message;reason_code;strategy_filter;'
      && 'status_filter;message_filter;message_only;'
      && 'minimum_demand_count;maximum_demand_count;'
      && 'minimum_available_stock;maximum_available_stock;'
      && 'minimum_requested_quantity;maximum_requested_quantity;'
      && 'minimum_allocated_quantity;maximum_allocated_quantity;'
      && 'minimum_shortage_quantity;maximum_shortage_quantity;'
      && 'minimum_shortage_pct;maximum_shortage_pct;'
      && 'minimum_coverage_pct;maximum_coverage_pct;'
      && 'audit_duration_from_filter;audit_duration_to_filter;'
      && 'start_date_from_filter;start_date_to_filter;'
      && 'finish_date_from_filter;finish_date_to_filter;'
      && 'maximum_running_age_filter;legacy_strategy_filter;'
      && 'overdue_only;requested_overdue_as_of;'
      && 'requested_deadline_only;requested_deadline_from;requested_deadline_to;'
      && 'minimum_deadline_age_days;maximum_deadline_age_days;deadline_age_as_of;'
      && 'minimum_coverage;'
      && 'maximum_shortage_pct;total_runs;'
      && 'deadline_count;earliest_requested_deadline;latest_requested_deadline;'
      && 'last_deadline_age_days;oldest_deadline_age_days;newest_deadline_age_days;'
      && 'deadline_age_reference_date;'
      && 'running_runs;stale_running_runs;error_runs;partial_runs;fair_runs;weighted_runs;adaptive_runs;'
      && 'adaptive_priority_runs;adaptive_fair_runs;unit;shortage_available;'
      && 'requested;allocated;shortage;coverage_pct;fair_share_available;fair_requested;'
      && 'fair_allocated;fair_shortage;fair_coverage_pct;weighted_share_available;weighted_requested;'
      && 'weighted_allocated;weighted_shortage;weighted_coverage_available;weighted_coverage_pct;'
      && 'adaptive_share_available;adaptive_requested;'
      && 'adaptive_allocated;adaptive_shortage;adaptive_coverage_available;'
      && 'adaptive_coverage_pct;coverage_threshold_active;'
      && 'coverage_below_threshold;shortage_threshold_active;shortage_above_threshold'.
    APPEND zcl_stock_csv=>quote( 'zstock_alloc_health' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 28 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-message ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-reason_code ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_strat ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_stat ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_msg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_monly ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dfrom ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dto ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_avf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_avt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_qf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_qt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_af ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_at ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_shf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_sht ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_spf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_spt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_covf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_covt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_tfrom ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_tto ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_from ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_to ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ffrom ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_fto ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_age_to ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_legacy ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_overdue_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_dead ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_deadf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_deadt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dagef ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_daget ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_age_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cov ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_spct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-total_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-deadline_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-earliest_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-latest_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-last_deadline_age_days ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-oldest_deadline_age_days ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-newest_deadline_age_days ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-deadline_age_reference_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-running_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-stale_running_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-error_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-fair_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-weighted_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_priority_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_fair_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-shortage_available ) TO lt_csv_fields.
    IF ls_health-shortage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-fair_share_available ) TO lt_csv_fields.
    IF ls_health-fair_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-fair_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-fair_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-fair_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-fair_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-fair_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-weighted_share_available ) TO lt_csv_fields.
    IF ls_health-weighted_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-weighted_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-weighted_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-weighted_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-weighted_coverage_ok = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-weighted_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-adaptive_share_available ) TO lt_csv_fields.
    IF ls_health-adaptive_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-adaptive_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-adaptive_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-adaptive_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-adaptive_coverage_ok = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-adaptive_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-coverage_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-coverage_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-shortage_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-shortage_above_threshold ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

    WRITE: / 'Allocation health:', ls_health-status,
         / 'Message:', ls_health-message,
         / 'Reason code:', ls_health-reason_code,
         / 'Strategy filter:', p_strat,
         / 'Status filter:', p_stat,
         / 'Message filter:', p_msg,
         / 'Message-only filter:', p_monly,
         / 'Minimum demand count:', p_dfrom,
         / 'Maximum demand count:', p_dto,
         / 'Minimum available stock:', p_avf,
         / 'Maximum available stock:', p_avt,
         / 'Minimum requested quantity:', p_qf,
         / 'Maximum requested quantity:', p_qt,
         / 'Minimum allocated quantity:', p_af,
         / 'Maximum allocated quantity:', p_at,
         / 'Minimum shortage quantity:', p_shf,
         / 'Maximum shortage quantity:', p_sht,
         / 'Minimum shortage percentage:', p_spf, '%',
         / 'Maximum shortage percentage:', p_spt, '%',
         / 'Minimum coverage percentage:', p_covf, '%',
         / 'Maximum coverage percentage:', p_covt, '%',
         / 'Audit duration from:', p_tfrom, 'seconds',
         / 'Audit duration to:', p_tto, 'seconds',
         / 'Audit start date from:', p_from,
         / 'Audit start date to:', p_to,
         / 'Audit finish date from:', p_ffrom,
         / 'Audit finish date to:', p_fto,
         / 'Maximum running age:', p_age_to, 'seconds',
         / 'Legacy strategy filter:', p_legacy,
         / 'Overdue only:', p_ovrd,
         / 'Requested overdue as-of:', lv_overdue_date,
         / 'Requested deadline only:', p_dead,
         / 'Requested deadline from:', p_deadf,
         / 'Requested deadline to:', p_deadt,
         / 'Minimum deadline age days:', p_dagef,
         / 'Maximum deadline age days:', p_daget,
         / 'Deadline age as-of:', lv_deadline_age_date,
         / 'Minimum coverage:', p_cov, '%',
         / 'Maximum shortage:', p_spct, '%',
         / 'Deadline count:', ls_health-deadline_count,
         / 'Earliest requested deadline:', ls_health-earliest_requested_deadline,
         / 'Latest requested deadline:', ls_health-latest_requested_deadline,
         / 'Last deadline age days:', ls_health-last_deadline_age_days,
         / 'Oldest deadline age days:', ls_health-oldest_deadline_age_days,
         / 'Newest deadline age days:', ls_health-newest_deadline_age_days,
         / 'Deadline age reference date:', ls_health-deadline_age_reference_date,
         / 'Runs:', ls_health-total_runs,
         / 'Running:', ls_health-running_runs,
         / 'Stale running:', ls_health-stale_running_runs,
         / 'Errors:', ls_health-error_runs,
         / 'Partial:', ls_health-partial_runs,
         / 'Fair-share runs:', ls_health-fair_runs,
         / 'Weighted fair-share runs:', ls_health-weighted_runs,
         / 'Adaptive runs:', ls_health-adaptive_runs,
         / 'Adaptive priority branch runs:', ls_health-adaptive_priority_runs,
         / 'Adaptive fair-share branch runs:', ls_health-adaptive_fair_runs,
         / 'Unit:', ls_health-unit.
  IF ls_health-shortage_available = abap_true.
    WRITE: / 'Requested:', ls_health-requested,
           / 'Allocated:', ls_health-allocated,
           / 'Shortage:', ls_health-shortage.
  ELSE.
    WRITE: / 'Quantities: not comparable across mixed units'.
  ENDIF.
  IF ls_health-coverage_available = abap_true.
    WRITE: / 'Coverage:', ls_health-coverage, '%'.
  ELSE.
    WRITE: / 'Coverage: n/a'.
  ENDIF.
  IF ls_health-fair_share_available = abap_true.
    WRITE: / 'Fair-share totals (', ls_health-unit, '): requested',
             ls_health-fair_requested, 'allocated', ls_health-fair_allocated,
             'shortage', ls_health-fair_shortage.
  ELSE.
    WRITE: / 'Fair-share totals: n/a (mixed units or no fair-share demand)'.
  ENDIF.
  IF ls_health-fair_coverage_available = abap_true.
    WRITE: / 'Fair-share coverage:', ls_health-fair_coverage, '%' .
  ELSE.
    WRITE: / 'Fair-share coverage: n/a'.
  ENDIF.
  IF ls_health-weighted_share_available = abap_true.
    WRITE: / 'Weighted totals (', ls_health-unit, '): requested',
      ls_health-weighted_requested, 'allocated', ls_health-weighted_allocated,
      'shortage', ls_health-weighted_shortage.
  ELSE.
    WRITE: / 'Weighted totals: n/a'.
  ENDIF.
  IF ls_health-weighted_coverage_ok = abap_true.
    WRITE: / 'Weighted coverage:', ls_health-weighted_coverage, '%' .
  ELSE.
    WRITE: / 'Weighted coverage: n/a'.
  ENDIF.
  IF ls_health-adaptive_share_available = abap_true.
    WRITE: / 'Adaptive totals (', ls_health-unit, '): requested',
             ls_health-adaptive_requested, 'allocated', ls_health-adaptive_allocated,
             'shortage', ls_health-adaptive_shortage.
  ELSE.
    WRITE: / 'Adaptive totals: n/a (mixed units or no adaptive demand)'.
  ENDIF.
  IF ls_health-adaptive_coverage_ok = abap_true.
    WRITE: / 'Adaptive coverage:', ls_health-adaptive_coverage, '%' .
  ELSE.
    WRITE: / 'Adaptive coverage: n/a'.
  ENDIF.
  WRITE: / 'Coverage threshold active:', ls_health-coverage_threshold_active,
         / 'Coverage threshold breached:', ls_health-coverage_below_threshold,
         / 'Shortage threshold active:', ls_health-shortage_threshold_active,
         / 'Shortage threshold breached:', ls_health-shortage_above_threshold.
