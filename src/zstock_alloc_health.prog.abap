REPORT zstock_alloc_health.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_cov TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_spct TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_safon AS CHECKBOX.
PARAMETERS p_saf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_safto TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_stale TYPE i DEFAULT 3600.
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

  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_strat TO UPPER CASE.
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
        iv_min_shelf_life    = p_shelf
        iv_safety_filter     = p_safon
        iv_safety_from       = p_saf
        iv_safety_to         = p_safto
        iv_requested_on_from = p_reqf
        iv_requested_on_to   = p_until ).
      IF p_stale > 0.
        ls_stale_summary = lo_audit->get_summary(
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_unit              = p_meins
          iv_movement_type     = p_mvt
          iv_strategy          = p_strat
          iv_min_shelf_life    = p_shelf
          iv_safety_filter     = p_safon
          iv_safety_from       = p_saf
          iv_safety_to         = p_safto
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until
          iv_stale_seconds     = p_stale ).
      ENDIF.
      ls_health = zcl_stock_allocation_health=>evaluate(
        is_summary            = ls_summary
        iv_stale_running_runs = ls_stale_summary-running_runs
        iv_stale_threshold    = p_stale
        iv_min_coverage       = p_cov
        iv_max_shortage_pct   = p_spct ).
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
      iv_value = 9 ) TO lt_json_fields.
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
    WRITE: / 'mode;schema_version;status;message;reason_code;strategy_filter;minimum_coverage;'
      && 'maximum_shortage_pct;total_runs;'
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
    APPEND zcl_stock_csv=>number( 9 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-message ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-reason_code ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_strat ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cov ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_spct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-total_runs ) TO lt_csv_fields.
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
         / 'Minimum coverage:', p_cov, '%',
         / 'Maximum shortage:', p_spct, '%',
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
