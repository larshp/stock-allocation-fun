REPORT zstock_alloc_health.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_rid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_prev TYPE zif_allocation_audit=>ty_preview_filter.
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
PARAMETERS p_lcov TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_spct TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_ccov TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_ccvmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cspct TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_durmax TYPE i DEFAULT 0.
PARAMETERS p_cdurmx TYPE i DEFAULT 0.
PARAMETERS p_cdurmn TYPE i DEFAULT 0.
PARAMETERS p_csucc AS CHECKBOX.
PARAMETERS p_cstrk TYPE i DEFAULT 0.
PARAMETERS p_cfail TYPE i DEFAULT 0.
PARAMETERS p_avgmax TYPE i DEFAULT 0.
PARAMETERS p_maxdur TYPE i DEFAULT 0.
PARAMETERS p_durcnt TYPE i DEFAULT 0.
PARAMETERS p_runcnt TYPE i DEFAULT 0.
PARAMETERS p_dcmin TYPE i DEFAULT 0.
PARAMETERS p_dmmin TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_pmix AS CHECKBOX.
PARAMETERS p_umix AS CHECKBOX.
PARAMETERS p_cmin TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_succ TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_sucnt TYPE i DEFAULT 0.
PARAMETERS p_errmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_prtmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_flmin TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_ulmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_plmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_flcnt TYPE i DEFAULT 0.
PARAMETERS p_dmax TYPE i DEFAULT 0.
PARAMETERS p_rmax TYPE i DEFAULT 0.
PARAMETERS p_shmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_lshmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_lspct TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cflmin TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cflmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_culmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cplmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cflcnt TYPE i DEFAULT 0.
PARAMETERS p_cacnt TYPE i DEFAULT 0.
PARAMETERS p_cacmax TYPE i DEFAULT 0.
PARAMETERS p_culcnt TYPE i DEFAULT 0.
PARAMETERS p_cplcnt TYPE i DEFAULT 0.
PARAMETERS p_cshcnt TYPE i DEFAULT 0.
PARAMETERS p_lage TYPE i DEFAULT 0.
PARAMETERS p_cdag TYPE i DEFAULT 0.
PARAMETERS p_odmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cdmmax TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_fdmmin TYPE zif_allocation_audit=>ty_coverage DEFAULT 0.
PARAMETERS p_cshmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_camin TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_crqmin TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_crqmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_caqmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_cavmin TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_cavmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_cdmin TYPE i DEFAULT 0.
PARAMETERS p_cdmax TYPE i DEFAULT 0.
PARAMETERS p_avmin TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_avmax TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
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
PARAMETERS p_durg TYPE c LENGTH 11.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_stale TYPE i DEFAULT 3600.
PARAMETERS p_age_to TYPE i.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
  DATA ls_stale_summary TYPE zif_allocation_audit=>ty_summary.
  DATA ls_health TYPE zcl_stock_allocation_health=>ty_health.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_summary_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_scope_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_fields TYPE zcl_stock_json=>tt_strings.
  DATA lt_filter_names TYPE zcl_stock_json=>tt_strings.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_json_line TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_error TYPE string.
  DATA lv_overdue_date TYPE d.
  DATA lv_deadline_age_date TYPE d.
  DATA lv_deadline_urgency_filter TYPE string.
  DATA lv_deadline_urgency_input TYPE string.
  DATA lv_last_age_available TYPE abap_bool.
  DATA lv_last_age_seconds TYPE i.
  DATA lv_last_age_reason TYPE string.
  DATA lv_last_age_reference_date TYPE d.
  DATA lv_last_age_reference_time TYPE t.

  lv_last_age_reference_date = sy-datum.
  lv_last_age_reference_time = sy-uzeit.

  IF p_csv = abap_true AND p_json = abap_true.
    lv_error = 'Select only one export mode: CSV or JSON'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSE.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ENDIF.
    RETURN.
  ENDIF.
  IF p_stale < 0.
    lv_error = 'Stale threshold cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_durmax < 0.
    lv_error = 'Maximum latest duration cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdurmx < 0.
    lv_error = 'Maximum latest completed duration cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdurmn < 0.
    lv_error = 'Minimum latest completed duration cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cstrk < 0.
    lv_error = 'Minimum latest completed success streak cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cfail < 0.
    lv_error = 'Maximum latest completed non-success streak cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_avgmax < 0.
    lv_error = 'Maximum average duration cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_maxdur < 0.
    lv_error = 'Maximum completed duration cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cmin < 0 OR p_cmin > 100.
    lv_error = 'Minimum completion rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_succ < 0 OR p_succ > 100.
    lv_error = 'Minimum success rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_errmax < 0 OR p_errmax > 100.
    lv_error = 'Maximum error rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.

  IF p_prtmax < 0 OR p_prtmax > 100.
    lv_error = 'Maximum partial-run rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_durcnt < 0.
    lv_error = 'Minimum duration sample count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_runcnt < 0.
    lv_error = 'Minimum total run count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dcmin < 0.
    lv_error = 'Minimum deadline-bearing run count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_meta = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = 'Metadata output requires JSON mode.' ).
      RETURN.
    ENDIF.
    WRITE: / zcl_stock_json=>error_with_schema(
      iv_message = 'Metadata output requires JSON mode.'
      iv_schema  = 130 ).
    RETURN.
  ENDIF.
  IF p_dmmin < 0 OR p_dmmin > 100.
    lv_error = 'Minimum deadline mix must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_sucnt < 0.
    lv_error = 'Minimum successful-run count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_flmin < 0 OR p_flmin > 100.
    lv_error = 'Minimum full-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ulmax < 0 OR p_ulmax > 100.
    lv_error = 'Maximum unallocated-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_plmax < 0 OR p_plmax > 100.
    lv_error = 'Maximum partial-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_flcnt < 0.
    lv_error = 'Minimum full-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dmax < 0.
    lv_error = 'Maximum demand count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_rmax < 0.
    lv_error = 'Maximum running count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shmax < 0.
    lv_error = 'Maximum shortage quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_lshmax < 0.
    lv_error = 'Maximum latest shortage quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_lspct < 0 OR p_lspct > 100.
    lv_error = 'Maximum latest shortage percentage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ccov < 0 OR p_ccov > 100.
    lv_error = 'Minimum latest completed coverage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ccvmax < 0 OR p_ccvmax > 100.
    lv_error = 'Maximum latest completed coverage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ccov > 0 AND p_ccvmax > 0 AND p_ccov > p_ccvmax.
    lv_error = 'Latest completed coverage minimum cannot exceed its maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cspct < 0 OR p_cspct > 100.
    lv_error = 'Maximum latest completed shortage percentage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cflmin < 0 OR p_cflmin > 100.
    lv_error = 'Minimum latest completed full-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cflmax < 0 OR p_cflmax > 100.
    lv_error = 'Maximum latest completed full-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cflmin > 0 AND p_cflmax > 0 AND p_cflmin > p_cflmax.
    lv_error = 'Latest completed full-line rate minimum cannot exceed its maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_culmax < 0 OR p_culmax > 100.
    lv_error = 'Maximum latest completed unallocated-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cplmax < 0 OR p_cplmax > 100.
    lv_error = 'Maximum latest completed partial-line rate must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cflcnt < 0.
    lv_error = 'Minimum latest completed full-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cacnt < 0.
    lv_error = 'Minimum latest completed allocated-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cacmax < 0.
    lv_error = 'Maximum latest completed allocated-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cacnt > 0 AND p_cacmax > 0 AND p_cacnt > p_cacmax.
    lv_error = 'Minimum latest completed allocated-line count cannot exceed maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_culcnt < 0.
    lv_error = 'Maximum latest completed unallocated-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cplcnt < 0.
    lv_error = 'Maximum latest completed partial-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cshcnt < 0.
    lv_error = 'Maximum latest completed shortage-line count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cshmax < 0.
    lv_error = 'Maximum latest completed shortage quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_camin < 0.
    lv_error = 'Minimum latest completed allocated quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_crqmax < 0.
    lv_error = 'Maximum latest completed requested quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_crqmin < 0.
    lv_error = 'Minimum latest completed requested quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_caqmax < 0.
    lv_error = 'Maximum latest completed allocated quantity cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_camin > 0 AND p_caqmax > 0 AND p_camin > p_caqmax.
    lv_error = 'Minimum latest completed allocated quantity cannot exceed maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_crqmin > 0 AND p_crqmax > 0 AND p_crqmin > p_crqmax.
    lv_error = 'Minimum latest completed requested quantity cannot exceed maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cavmin < 0.
    lv_error = 'Minimum latest completed available-stock threshold cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cavmax < 0.
    lv_error = 'Maximum latest completed available-stock threshold cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cavmin > 0 AND p_cavmax > 0 AND p_cavmin > p_cavmax.
    lv_error = 'Minimum latest completed available-stock threshold cannot exceed maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_lage < 0.
    lv_error = 'Maximum latest completed age cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdag < 0.
    lv_error = 'Maximum latest completed deadline age cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_odmax < 0 OR p_odmax > 100.
    lv_error = 'Maximum overdue deadline mix must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdmmax < 0 OR p_cdmmax > 100.
    lv_error = 'Maximum current-day deadline mix must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_fdmmin < 0 OR p_fdmmin > 100.
    lv_error = 'Minimum future deadline mix must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdmin < 0.
    lv_error = 'Minimum latest completed demand count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdmax < 0.
    lv_error = 'Maximum latest completed demand count cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cdmin > 0 AND p_cdmax > 0 AND p_cdmin > p_cdmax.
    lv_error = 'Minimum latest completed demand count cannot exceed maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_avmin < 0.
    lv_error = 'Minimum available-stock threshold cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_avmax < 0.
    lv_error = 'Maximum available-stock threshold cannot be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_avmin > 0 AND p_avmax > 0 AND p_avmin > p_avmax.
    lv_error = 'Minimum available-stock threshold cannot exceed maximum'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_cov < 0 OR p_cov > 100.
    lv_error = 'Minimum coverage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_lcov < 0 OR p_lcov > 100.
    lv_error = 'Minimum latest coverage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_spct < 0 OR p_spct > 100.
    lv_error = 'Maximum shortage percentage must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_legacy = abap_true AND p_strat IS NOT INITIAL.
    lv_error = 'Legacy strategy filter cannot be combined with a strategy filter'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_odate IS NOT INITIAL AND p_ovrd = abap_false.
    lv_error = 'Overdue as-of date requires overdue filtering'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
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
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
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
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
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
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
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

  lv_deadline_urgency_input = to_lower( p_durg ).
  lv_deadline_urgency_filter = lv_deadline_urgency_input.
  IF lv_deadline_urgency_filter IS INITIAL.
    lv_deadline_urgency_filter = 'n/a'.
  ENDIF.

  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_strat TO UPPER CASE.
  TRANSLATE p_stat TO UPPER CASE.
  TRANSLATE p_prev TO UPPER CASE.
  TRANSLATE p_meins TO UPPER CASE.
  IF p_prev IS NOT INITIAL
      AND p_prev <> 'P'
      AND p_prev <> 'O'.
    lv_error = 'Preview filter must be P or O'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = lv_error
        iv_schema  = 130 ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_health'
        iv_schema  = 130
        iv_message = lv_error ).
    ELSE.
      WRITE: / lv_error.
    ENDIF.
    RETURN.
  ENDIF.
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
        iv_run_id            = p_runid
        iv_run_id_contains   = p_rid
        iv_unit              = p_meins
        iv_movement_type     = p_mvt
        iv_strategy          = p_strat
        iv_status            = p_stat
        iv_preview_filter    = p_prev
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
        iv_deadline_urgency  = lv_deadline_urgency_input ).
      IF p_stale > 0.
        ls_stale_summary = lo_audit->get_summary(
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_run_id            = p_runid
          iv_run_id_contains   = p_rid
          iv_unit              = p_meins
          iv_movement_type     = p_mvt
          iv_strategy          = p_strat
          iv_status            = p_stat
          iv_preview_filter    = p_prev
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
          iv_deadline_urgency  = lv_deadline_urgency_input
          iv_stale_seconds     = p_stale ).
      ENDIF.
      CLEAR lv_last_age_seconds.
      lv_last_age_available = abap_false.
      lv_last_age_reason = 'no_completed_run'.
      IF ls_summary-last_completed_run_id IS NOT INITIAL.
        IF ls_summary-last_completed_finish_date IS INITIAL
            OR ls_summary-last_completed_finish_time IS INITIAL
            OR zcl_allocation_date_sap=>is_valid_or_initial(
                 ls_summary-last_completed_finish_date ) = abap_false
            OR zcl_allocation_time_sap=>is_valid_or_initial(
                 ls_summary-last_completed_finish_time ) = abap_false.
          lv_last_age_reason = 'invalid_timestamp'.
        ELSE.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = lv_last_age_reference_date
            time1    = lv_last_age_reference_time
            date2    = ls_summary-last_completed_finish_date
            time2    = ls_summary-last_completed_finish_time
          IMPORTING
            res_secs = lv_last_age_seconds ).
        IF lv_last_age_seconds >= 0.
          lv_last_age_available = abap_true.
          lv_last_age_reason = 'available'.
        ELSE.
          CLEAR lv_last_age_seconds.
          lv_last_age_reason = 'future_timestamp'.
        ENDIF.
        ENDIF.
      ENDIF.
      ls_health = zcl_stock_allocation_health=>evaluate(
        is_summary                                = ls_summary
        iv_stale_running_runs                     = ls_stale_summary-running_runs
        iv_stale_scope_evaluated                  = xsdbool( p_stale > 0 )
        iv_stale_threshold                        = p_stale
        iv_last_age_available                     = lv_last_age_available
        iv_last_age_seconds                       = lv_last_age_seconds
        iv_last_age_reason                        = lv_last_age_reason
        iv_last_age_reference_date                = lv_last_age_reference_date
        iv_last_age_reference_time                = lv_last_age_reference_time
        iv_min_coverage                           = p_cov
        iv_min_last_coverage                      = p_lcov
        iv_max_shortage_pct                       = p_spct
        iv_max_last_duration                      = p_durmax
        iv_max_last_completed_duration            = p_cdurmx
        iv_min_last_completed_duration            = p_cdurmn
        iv_require_last_completed_success         = p_csucc
        iv_min_last_completed_success_streak      = p_cstrk
        iv_max_last_completed_non_success_streak  = p_cfail
        iv_max_average_duration                   = p_avgmax
        iv_max_completed_duration                 = p_maxdur
        iv_min_duration_count                     = p_durcnt
        iv_min_run_count                          = p_runcnt
        iv_min_deadline_count                     = p_dcmin
        iv_min_deadline_mix                       = p_dmmin
        iv_warn_mixed_policies                    = p_pmix
        iv_warn_mixed_units                       = p_umix
        iv_min_completion_rate                    = p_cmin
        iv_min_success_rate                       = p_succ
        iv_min_success_count                      = p_sucnt
        iv_max_error_rate                         = p_errmax
        iv_max_partial_rate                       = p_prtmax
        iv_min_full_line_rate                     = p_flmin
        iv_max_unalloc_line_rate                  = p_ulmax
        iv_max_partial_line_rate                  = p_plmax
        iv_min_full_line_count                    = p_flcnt
        iv_max_demand_count                       = p_dmax
        iv_max_running_count                      = p_rmax
        iv_max_shortage_quantity                  = p_shmax
        iv_max_last_shortage_qty                  = p_lshmax
        iv_max_last_shortage_pct                  = p_lspct
        iv_min_last_completed_coverage            = p_ccov
        iv_max_last_completed_coverage            = p_ccvmax
        iv_max_last_completed_shortage_pct        = p_cspct
        iv_max_last_completed_shortage_qty        = p_cshmax
        iv_min_last_completed_allocated           = p_camin
        iv_min_last_completed_requested           = p_crqmin
        iv_max_last_completed_requested           = p_crqmax
        iv_max_last_completed_allocated           = p_caqmax
        iv_min_last_completed_avail_stock         = p_cavmin
        iv_max_last_completed_avail_stock         = p_cavmax
        iv_min_last_completed_full_line_rate      = p_cflmin
        iv_max_last_completed_full_line_rate      = p_cflmax
        iv_max_last_completed_unalloc_line_rate   = p_culmax
        iv_max_last_completed_partial_line_rate   = p_cplmax
        iv_min_last_completed_full_line_count     = p_cflcnt
        iv_min_last_completed_alloc_lines         = p_cacnt
        iv_max_last_completed_alloc_lines         = p_cacmax
        iv_max_last_completed_unalloc_line_count  = p_culcnt
        iv_max_last_completed_partial_line_count  = p_cplcnt
        iv_max_last_completed_shortage_line_count = p_cshcnt
        iv_max_last_age                           = p_lage
        iv_max_last_completed_deadline_age        = p_cdag
        iv_max_overdue_mix                        = p_odmax
        iv_max_current_deadline_mix               = p_cdmmax
        iv_min_future_deadline_mix                = p_fdmmin
        iv_min_last_completed_demand_count        = p_cdmin
        iv_max_last_completed_demand_count        = p_cdmax
        iv_min_available_stock                    = p_avmin
        iv_max_available_stock                    = p_avmax ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        lv_error = 'Allocation health read failed'.
      ELSE.
        lv_error = lo_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error_with_schema(
          iv_message = lv_error
          iv_schema  = 130 ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / zcl_stock_csv=>error_with_schema(
          iv_mode    = 'zstock_alloc_health'
          iv_schema  = 130
          iv_message = lv_error ).
      ELSE.
        WRITE: / 'Allocation health failed:', lv_error.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_json = abap_true.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'schema_version'
      iv_value = 130 ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'generated_date'
      iv_value = sy-datum ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'generated_time'
      iv_value = sy-uzeit ) TO lt_json_fields.
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
      iv_name  = 'run_id_filter'
      iv_value = p_runid ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'run_id_contains_filter'
      iv_value = p_rid ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'movement_type_filter'
      iv_value = p_mvt ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit_filter'
      iv_value = p_meins ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_shelf_life_filter'
      iv_value = p_shelf ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'safety_stock_filter'
      iv_value = p_safon ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_safety_stock_filter'
      iv_value = p_saf ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_safety_stock_filter'
      iv_value = p_safto ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_from_filter'
      iv_value = p_reqf ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_to_filter'
      iv_value = p_until ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'strategy_filter'
      iv_value = p_strat ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'status_filter'
      iv_value = p_stat ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'preview_filter'
      iv_value = p_prev ) TO lt_json_fields.
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
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'stale_threshold_seconds'
      iv_value = p_stale ) TO lt_json_fields.
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
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_urgency_filter'
      iv_value = lv_deadline_urgency_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'deadline_count'
      iv_value = ls_health-deadline_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'deadline_mix_pct'
      iv_value = ls_health-deadline_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'overdue_count'
      iv_value = ls_health-overdue_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'current_deadline_count'
      iv_value = ls_health-current_deadline_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'future_deadline_count'
      iv_value = ls_health-future_deadline_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'overdue_mix_pct'
      iv_value = ls_health-overdue_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'current_deadline_mix_pct'
      iv_value = ls_health-current_deadline_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'future_deadline_mix_pct'
      iv_value = ls_health-future_deadline_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_requested_on_from'
      iv_value = ls_health-last_requested_on_from ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_requested_on_to'
      iv_value = ls_health-last_requested_on_to ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_requested_deadline'
      iv_value = ls_health-last_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'earliest_requested_deadline'
      iv_value = ls_health-earliest_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'latest_requested_deadline'
      iv_value = ls_health-latest_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_deadline_age_days'
      iv_value = ls_health-last_deadline_age_days ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_deadline_urgency'
      iv_value = ls_health-last_deadline_urgency ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'oldest_deadline_age_days'
      iv_value = ls_health-oldest_deadline_age_days ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'oldest_deadline_urgency'
      iv_value = ls_health-oldest_deadline_urgency ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'newest_deadline_age_days'
      iv_value = ls_health-newest_deadline_age_days ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'newest_deadline_urgency'
      iv_value = ls_health-newest_deadline_urgency ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_age_reference_date'
      iv_value = ls_health-deadline_age_reference_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_coverage'
      iv_value = p_cov ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_coverage'
      iv_value = p_lcov ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_shortage_pct'
      iv_value = p_spct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_duration'
      iv_value = p_durmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_duration'
      iv_value = p_cdurmx ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_duration'
      iv_value = p_cdurmn ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'require_last_completed_success'
      iv_value = p_csucc ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_success_streak'
      iv_value = p_cstrk ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_non_success_streak'
      iv_value = p_cfail ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_average_duration'
      iv_value = p_avgmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_completed_duration'
      iv_value = p_maxdur ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_duration_count'
      iv_value = p_durcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_run_count'
      iv_value = p_runcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_deadline_count'
      iv_value = p_dcmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_deadline_mix'
      iv_value = p_dmmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'warn_mixed_policies'
      iv_value = p_pmix ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'warn_mixed_units'
      iv_value = p_umix ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_completion_rate'
      iv_value = p_cmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_success_rate'
      iv_value = p_succ ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_success_count'
      iv_value = p_sucnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_error_rate'
      iv_value = p_errmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_partial_rate'
      iv_value = p_prtmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_full_line_rate'
      iv_value = p_flmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_unallocated_line_rate'
      iv_value = p_ulmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_partial_line_rate'
      iv_value = p_plmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_full_line_count'
      iv_value = p_flcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_demand_count_threshold'
      iv_value = p_dmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_running_count_threshold'
      iv_value = p_rmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_shortage_quantity_threshold'
      iv_value = p_shmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_shortage_quantity'
      iv_value = p_lshmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_shortage_pct'
      iv_value = p_lspct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_coverage'
      iv_value = p_ccov ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_coverage'
      iv_value = p_ccvmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_shortage_pct'
      iv_value = p_cspct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_full_line_rate'
      iv_value = p_cflmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_full_line_rate'
      iv_value = p_cflmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_unallocated_line_rate'
      iv_value = p_culmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_partial_line_rate'
      iv_value = p_cplmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_full_line_count'
      iv_value = p_cflcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_allocated_line_count'
      iv_value = p_cacnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_allocated_line_count'
      iv_value = p_cacmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_unallocated_line_count'
      iv_value = p_culcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_partial_line_count'
      iv_value = p_cplcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_shortage_line_count'
      iv_value = p_cshcnt ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_shortage_quantity'
      iv_value = p_cshmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_allocated_quantity'
      iv_value = p_camin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_requested_quantity'
      iv_value = p_crqmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_requested_quantity'
      iv_value = p_crqmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_allocated_quantity'
      iv_value = p_caqmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_available_stock'
      iv_value = p_cavmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_available_stock'
      iv_value = p_cavmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_age'
      iv_value = p_lage ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_deadline_age'
      iv_value = p_cdag ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_overdue_deadline_mix'
      iv_value = p_odmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_current_day_deadline_mix'
      iv_value = p_cdmmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_future_deadline_mix'
      iv_value = p_fdmmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_last_completed_demand_count'
      iv_value = p_cdmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_last_completed_demand_count'
      iv_value = p_cdmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_available_stock_threshold'
      iv_value = p_avmin ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_available_stock_threshold'
      iv_value = p_avmax ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'total_runs'
      iv_value = ls_health-total_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'preview_runs'
      iv_value = ls_health-preview_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'operational_runs'
      iv_value = ls_health-operational_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'preview_mix_pct'
      iv_value = ls_health-preview_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'operational_mix_pct'
      iv_value = ls_health-operational_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'success_runs'
      iv_value = ls_health-success_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'completion_pct'
      iv_value = ls_health-completion_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'success_rate_pct'
      iv_value = ls_health-success_rate_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'partial_rate_pct'
      iv_value = ls_health-partial_rate_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'error_rate_pct'
      iv_value = ls_health-error_rate_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'demand_count'
      iv_value = ls_health-demand_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'full_count'
      iv_value = ls_health-full_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'partial_count'
      iv_value = ls_health-partial_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'unallocated_count'
      iv_value = ls_health-unallocated_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'full_line_pct'
      iv_value = ls_health-full_line_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'partial_line_pct'
      iv_value = ls_health-partial_line_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'unallocated_line_pct'
      iv_value = ls_health-unallocated_line_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'full_line_threshold_active'
      iv_value = ls_health-full_line_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'full_line_threshold'
      iv_value = ls_health-full_line_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'full_line_below_threshold'
      iv_value = ls_health-full_line_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'unallocated_line_threshold_active'
      iv_value = ls_health-unallocated_line_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'unallocated_line_threshold'
      iv_value = ls_health-unallocated_line_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'unallocated_line_above_threshold'
      iv_value = ls_health-unallocated_line_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'partial_line_threshold_active'
      iv_value = ls_health-partial_line_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'partial_line_threshold'
      iv_value = ls_health-partial_line_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'partial_line_above_threshold'
      iv_value = ls_health-partial_line_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'full_count_threshold_active'
      iv_value = ls_health-full_count_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'full_count_threshold'
      iv_value = ls_health-full_count_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'full_count_below_threshold'
      iv_value = ls_health-full_count_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'demand_count_threshold_active'
      iv_value = ls_health-demand_count_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'demand_count_threshold'
      iv_value = ls_health-demand_count_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'demand_count_above_threshold'
      iv_value = ls_health-demand_count_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'running_count_threshold_active'
      iv_value = ls_health-running_count_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'running_count_threshold'
      iv_value = ls_health-running_count_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'running_count_above_threshold'
      iv_value = ls_health-running_count_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_quantity_threshold_active'
      iv_value = ls_health-shortage_quantity_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'shortage_quantity_threshold'
      iv_value = ls_health-shortage_quantity_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_quantity_above_threshold'
      iv_value = ls_health-shortage_quantity_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_shortage_quantity_threshold_active'
      iv_value = ls_health-last_shortage_qty_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_shortage_quantity_threshold'
      iv_value = ls_health-last_shortage_qty_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_shortage_quantity_above_threshold'
      iv_value = ls_health-last_shortage_qty_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_shortage_pct_threshold_active'
      iv_value = ls_health-last_shortage_pct_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_shortage_pct_threshold'
      iv_value = ls_health-last_shortage_pct_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_shortage_pct_above_threshold'
      iv_value = ls_health-last_shortage_pct_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_coverage_threshold_active'
      iv_value = ls_health-last_comp_coverage_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_coverage_threshold'
      iv_value = ls_health-last_comp_coverage_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_coverage_below_threshold'
      iv_value = ls_health-last_comp_coverage_below_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_coverage_max_threshold_active'
      iv_value = ls_health-last_comp_cov_max_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_coverage_max_threshold'
      iv_value = ls_health-last_comp_coverage_max_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_coverage_above_threshold'
      iv_value = ls_health-last_comp_coverage_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_shortage_pct_threshold_active'
      iv_value = ls_health-last_comp_short_pct_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_shortage_pct_threshold'
      iv_value = ls_health-last_comp_shortage_pct_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_shortage_pct_above_threshold'
      iv_value = ls_health-last_comp_short_pct_above_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_shortage_qty_threshold_active'
      iv_value = ls_health-last_comp_short_qty_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_shortage_qty_threshold'
      iv_value = ls_health-last_comp_shortage_qty_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_shortage_qty_above_threshold'
      iv_value = ls_health-last_comp_short_qty_above_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_threshold_active'
      iv_value = ls_health-last_comp_allocated_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_allocated_threshold'
      iv_value = ls_health-last_comp_allocated_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_below_threshold'
      iv_value = ls_health-last_comp_alloc_below_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_requested_threshold_active'
      iv_value = ls_health-last_comp_requested_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_requested_threshold'
      iv_value = ls_health-last_comp_requested_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_requested_above_threshold'
      iv_value = ls_health-last_comp_req_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_requested_min_threshold_active'
      iv_value = ls_health-last_comp_req_min_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_requested_min_threshold'
      iv_value = ls_health-last_comp_requested_min_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_requested_below_threshold'
      iv_value = ls_health-last_comp_req_below_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_max_threshold_active'
      iv_value = ls_health-last_comp_alloc_max_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_allocated_max_threshold'
      iv_value = ls_health-last_comp_allocated_max_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_above_threshold'
      iv_value = ls_health-last_comp_alloc_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_avail_stock_min_threshold_active'
      iv_value = ls_health-last_comp_avail_stk_min_lim_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_avail_stock_min_threshold'
      iv_value = ls_health-last_comp_avail_stk_min_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_avail_stock_below_threshold'
      iv_value = ls_health-last_comp_avail_stk_below_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_avail_stock_max_threshold_active'
      iv_value = ls_health-last_comp_avail_stk_max_lim_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_avail_stock_max_threshold'
      iv_value = ls_health-last_comp_avail_stk_max_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_avail_stock_above_threshold'
      iv_value = ls_health-last_comp_avail_stk_above_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_full_line_threshold_active'
      iv_value = ls_health-last_comp_full_line_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_full_line_threshold'
      iv_value = ls_health-last_comp_full_line_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_full_line_below_threshold'
      iv_value = ls_health-last_comp_full_ln_below_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_full_line_max_threshold_active'
      iv_value = ls_health-last_comp_full_ln_max_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_full_line_max_threshold'
      iv_value = ls_health-last_comp_full_line_max_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_full_line_above_threshold'
      iv_value = ls_health-last_comp_full_ln_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_unalloc_line_threshold_active'
      iv_value = ls_health-last_comp_unalloc_ln_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_unalloc_line_threshold'
      iv_value = ls_health-last_comp_unalloc_line_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_unalloc_line_above_threshold'
      iv_value = ls_health-last_comp_unalloc_ln_above_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_partial_line_threshold_active'
      iv_value = ls_health-last_comp_part_line_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_partial_line_threshold'
      iv_value = ls_health-last_comp_partial_line_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_partial_line_above_threshold'
      iv_value = ls_health-last_comp_part_ln_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_full_count_threshold_active'
      iv_value = ls_health-last_comp_full_count_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_full_count_threshold'
      iv_value = ls_health-last_comp_full_count_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_full_count_below_threshold'
      iv_value = ls_health-last_comp_full_cnt_below_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_count_threshold_active'
      iv_value = ls_health-last_comp_alloc_count_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_allocated_count_threshold'
      iv_value = ls_health-last_comp_alloc_count_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_count_below_threshold'
      iv_value = ls_health-last_comp_alloc_cnt_below_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_count_max_threshold_active'
      iv_value = ls_health-last_comp_alloc_cnt_max_lim_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_allocated_count_max_threshold'
      iv_value = ls_health-last_comp_alloc_cnt_max_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_allocated_count_above_threshold'
      iv_value = ls_health-last_comp_acnt_max_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_unalloc_count_threshold_active'
      iv_value = ls_health-last_comp_unalloc_cnt_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_unalloc_count_threshold'
      iv_value = ls_health-last_comp_unalloc_count_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_unalloc_count_above_threshold'
      iv_value = ls_health-last_comp_unalloc_cnt_over_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_partial_count_threshold_active'
      iv_value = ls_health-last_comp_partial_cnt_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_partial_count_threshold'
      iv_value = ls_health-last_comp_partial_count_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_partial_count_above_threshold'
      iv_value = ls_health-last_comp_part_cnt_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_shortage_count_threshold_active'
      iv_value = ls_health-last_comp_short_cnt_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_shortage_count_threshold'
      iv_value = ls_health-last_comp_shortage_count_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_shortage_count_above_threshold'
      iv_value = ls_health-last_comp_short_cnt_above_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_age_threshold_active'
      iv_value = ls_health-last_age_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_age_threshold'
      iv_value = ls_health-last_age_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_age_above_threshold'
      iv_value = ls_health-last_age_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_deadline_age_threshold_active'
      iv_value = ls_health-last_comp_ddl_age_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_deadline_age_threshold'
      iv_value = ls_health-last_comp_deadline_age_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_deadline_age_above_threshold'
      iv_value = ls_health-last_comp_ddl_age_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_demand_count_threshold_active'
      iv_value = ls_health-last_comp_demand_cnt_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_demand_count_threshold'
      iv_value = ls_health-last_comp_demand_count_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_demand_count_above_threshold'
      iv_value = ls_health-last_comp_demand_cnt_above_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_demand_count_min_threshold_active'
      iv_value = ls_health-last_cmp_demand_cnt_min_lim_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_demand_count_min_threshold'
      iv_value = ls_health-last_comp_demand_cnt_min_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_demand_count_below_threshold'
      iv_value = ls_health-last_comp_demand_cnt_below_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'available_stock_min_threshold_active'
      iv_value = ls_health-avail_stock_min_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'available_stock_min_threshold'
      iv_value = ls_health-avail_stock_min_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'available_stock_below_threshold'
      iv_value = ls_health-avail_stock_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'available_stock_max_threshold_active'
      iv_value = ls_health-avail_stock_max_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'available_stock_max_threshold'
      iv_value = ls_health-avail_stock_max_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'available_stock_above_threshold'
      iv_value = ls_health-avail_stock_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'stale_threshold_active'
      iv_value = ls_health-stale_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'stale_threshold'
      iv_value = ls_health-stale_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'stale_above_threshold'
      iv_value = ls_health-stale_above_threshold ) TO lt_json_fields.
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
      iv_name  = 'priority_runs'
      iv_value = ls_health-priority_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'fifo_runs'
      iv_value = ls_health-fifo_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'full_only_runs'
      iv_value = ls_health-full_only_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'smallest_runs'
      iv_value = ls_health-smallest_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'largest_runs'
      iv_value = ls_health-largest_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'best_runs'
      iv_value = ls_health-best_runs ) TO lt_json_fields.
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
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'legacy_runs'
      iv_value = ls_health-legacy_runs ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'priority_mix_pct'
      iv_value = ls_health-priority_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'fifo_mix_pct'
      iv_value = ls_health-fifo_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'full_only_mix_pct'
      iv_value = ls_health-full_only_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'smallest_mix_pct'
      iv_value = ls_health-smallest_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'largest_mix_pct'
      iv_value = ls_health-largest_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'best_mix_pct'
      iv_value = ls_health-best_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'fair_mix_pct'
      iv_value = ls_health-fair_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'weighted_mix_pct'
      iv_value = ls_health-weighted_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'adaptive_mix_pct'
      iv_value = ls_health-adaptive_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'legacy_mix_pct'
      iv_value = ls_health-legacy_mix_pct ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_run_available'
      iv_value = ls_health-last_run_available ) TO lt_json_fields.
    IF ls_health-last_run_available = abap_true.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_run_id'
        iv_value = ls_health-last_run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_preview'
        iv_value = ls_health-last_preview ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_available_stock_available'
        iv_value = ls_health-last_available_stock_available ) TO lt_json_fields.
      IF ls_health-last_available_stock_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_available_stock'
          iv_value = ls_health-last_available_stock ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'last_available_stock_unit'
          iv_value = ls_health-last_available_stock_unit ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_available_stock' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_available_stock_unit' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_requested_quantity'
        iv_value = ls_health-last_requested_quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_allocated_quantity'
        iv_value = ls_health-last_allocated_quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_shortage_quantity'
        iv_value = ls_health-last_shortage_quantity ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_shortage_pct_available'
        iv_value = ls_health-last_shortage_pct_available ) TO lt_json_fields.
      IF ls_health-last_shortage_pct_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_shortage_pct'
          iv_value = ls_health-last_shortage_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_shortage_pct' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_coverage_pct'
        iv_value = ls_health-last_coverage_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_demand_count'
        iv_value = ls_health-last_demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_full_line_count'
        iv_value = ls_health-last_full_line_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_partial_line_count'
        iv_value = ls_health-last_partial_line_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_unallocated_line_count'
        iv_value = ls_health-last_unallocated_line_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_line_rates_available'
        iv_value = ls_health-last_line_rates_available ) TO lt_json_fields.
      IF ls_health-last_line_rates_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_full_line_pct'
          iv_value = ls_health-last_full_line_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_partial_line_pct'
          iv_value = ls_health-last_partial_line_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_unallocated_line_pct'
          iv_value = ls_health-last_unallocated_line_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_full_line_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_partial_line_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_unallocated_line_pct' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_strategy'
        iv_value = ls_health-last_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_status'
        iv_value = ls_health-last_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_start_date'
        iv_value = ls_health-last_start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_start_time'
        iv_value = ls_health-last_start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_finish_date'
        iv_value = ls_health-last_finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_finish_time'
        iv_value = ls_health-last_finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_duration_seconds'
        iv_value = ls_health-last_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_age_available'
        iv_value = ls_health-last_age_available ) TO lt_json_fields.
      IF ls_health-last_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_age_seconds'
          iv_value = ls_health-last_age_seconds ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_age_seconds' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_age_reason'
        iv_value = ls_health-last_age_reason ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_age_reference_date'
        iv_value = ls_health-last_age_reference_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_age_reference_time'
        iv_value = ls_health-last_age_reference_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_run_message'
        iv_value = ls_health-last_run_message ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_run_id' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_available_stock_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_available_stock' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_available_stock_unit' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_requested_quantity' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_allocated_quantity' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_shortage_quantity' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_shortage_pct_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_shortage_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_coverage_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_demand_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_full_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_partial_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_unallocated_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_line_rates_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_full_line_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_partial_line_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_unallocated_line_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_strategy' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_status' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_start_date' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_start_time' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_finish_date' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_finish_time' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_duration_seconds' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_age_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_age_seconds' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_age_reason'
        iv_value = ls_health-last_age_reason ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_age_reference_date'
        iv_value = ls_health-last_age_reference_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_age_reference_time'
        iv_value = ls_health-last_age_reference_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_run_message' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'last_preview' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_run_available'
      iv_value = ls_health-last_completed_run_available ) TO lt_json_fields.
    IF ls_health-last_completed_run_available = abap_true.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_run_id'
        iv_value = ls_health-last_completed_run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_preview'
        iv_value = ls_health-last_completed_preview ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_status'
        iv_value = ls_health-last_completed_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_success_streak'
        iv_value = ls_health-last_completed_success_streak ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_non_success_streak'
        iv_value = ls_health-last_comp_non_success_streak ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_message'
        iv_value = ls_health-last_completed_message ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_start_date'
        iv_value = ls_health-last_completed_start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_start_time'
        iv_value = ls_health-last_completed_start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_finish_date'
        iv_value = ls_health-last_completed_finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_finish_time'
        iv_value = ls_health-last_completed_finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_duration_seconds'
        iv_value = ls_health-last_comp_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_unit'
        iv_value = ls_health-last_completed_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_policy_available'
        iv_value = ls_health-last_comp_policy_available ) TO lt_json_fields.
      IF ls_health-last_comp_policy_available = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'last_completed_movement_type'
          iv_value = ls_health-last_completed_movement_type ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_min_shelf_life'
          iv_value = ls_health-last_completed_min_shelf_life ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_safety_stock'
          iv_value = ls_health-last_completed_safety_stock ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_movement_type' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_min_shelf_life' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_safety_stock' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_horizon_available'
        iv_value = ls_health-last_comp_horizon_available ) TO lt_json_fields.
      IF ls_health-last_comp_horizon_available = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'last_completed_requested_on_from'
          iv_value = ls_health-last_comp_requested_on_from ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'last_completed_requested_on_to'
          iv_value = ls_health-last_completed_requested_on_to ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'last_completed_requested_deadline'
          iv_value = ls_health-last_comp_requested_deadline ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_requested_on_from' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_requested_on_to' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_requested_deadline' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_deadline_age_available'
        iv_value = ls_health-last_comp_deadline_age_avail ) TO lt_json_fields.
      IF ls_health-last_comp_deadline_age_avail = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_deadline_age_days'
          iv_value = ls_health-last_comp_deadline_age_days ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_deadline_age_days' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_deadline_age_reason'
        iv_value = ls_health-last_comp_deadline_age_reason ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_deadline_urgency'
        iv_value = ls_health-last_comp_deadline_urgency ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_available_stock_available'
        iv_value = ls_health-last_comp_avail_stock_avail ) TO lt_json_fields.
      IF ls_health-last_comp_avail_stock_avail = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_available_stock'
          iv_value = ls_health-last_completed_available_stock ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'last_completed_available_stock_unit'
          iv_value = ls_health-last_comp_available_stock_unit ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_available_stock' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_available_stock_unit' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_strategy'
        iv_value = ls_health-last_completed_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_requested'
        iv_value = ls_health-last_completed_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_allocated'
        iv_value = ls_health-last_completed_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_shortage'
        iv_value = ls_health-last_completed_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_coverage_pct'
        iv_value = ls_health-last_completed_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_demand_count'
        iv_value = ls_health-last_completed_demand ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_full_line_count'
        iv_value = ls_health-last_completed_full ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_partial_line_count'
        iv_value = ls_health-last_completed_partial ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_allocated_line_count'
        iv_value = ls_health-last_comp_allocated_line_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_completed_unallocated_line_count'
        iv_value = ls_health-last_completed_unalloc ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_shortage_pct_available'
        iv_value = ls_health-last_comp_shortage_pct_avail ) TO lt_json_fields.
      IF ls_health-last_comp_shortage_pct_avail = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_shortage_pct'
          iv_value = ls_health-last_completed_shortage_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_shortage_pct' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_line_rates_available'
        iv_value = ls_health-last_comp_line_rates_available ) TO lt_json_fields.
      IF ls_health-last_comp_line_rates_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_full_line_pct'
          iv_value = ls_health-last_completed_full_line_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_partial_line_pct'
          iv_value = ls_health-last_comp_partial_line_pct ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_completed_unallocated_line_pct'
          iv_value = ls_health-last_comp_unalloc_line_pct ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_full_line_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_partial_line_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_completed_unallocated_line_pct' ) TO lt_json_fields.
      ENDIF.
    ELSE.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_run_id' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_preview' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_status' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_success_streak' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_non_success_streak' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_message' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_start_date' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_start_time' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_finish_date' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_finish_time' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_duration_seconds' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_unit' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_policy_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_movement_type' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_min_shelf_life' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_safety_stock' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_horizon_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_requested_on_from' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_requested_on_to' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_requested_deadline' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_deadline_age_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_deadline_age_days' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_deadline_age_reason'
        iv_value = ls_health-last_comp_deadline_age_reason ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_completed_deadline_urgency'
        iv_value = ls_health-last_comp_deadline_urgency ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_available_stock_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_available_stock' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_available_stock_unit' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_strategy' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_shortage' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_coverage_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_demand_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_full_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_allocated_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_partial_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_unallocated_line_count' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_shortage_pct_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_shortage_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'last_completed_line_rates_available'
        iv_value = abap_false ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_full_line_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_partial_line_pct' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'last_completed_unallocated_line_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'duration_metrics_available'
      iv_value = ls_health-duration_metrics_available ) TO lt_json_fields.
    IF ls_health-duration_metrics_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'average_duration_seconds'
        iv_value = ls_health-average_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_duration_seconds'
        iv_value = ls_health-minimum_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_duration_seconds'
        iv_value = ls_health-maximum_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'completed_duration_runs'
        iv_value = ls_health-completed_duration_runs ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'average_duration_seconds' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'minimum_duration_seconds' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'maximum_duration_seconds' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'completed_duration_runs' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'oldest_running_age_seconds'
      iv_value = ls_health-oldest_running_age_seconds ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'oldest_running_run_id'
      iv_value = ls_health-oldest_running_run_id ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'newest_running_age_seconds'
      iv_value = ls_health-newest_running_age_seconds ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'newest_running_run_id'
      iv_value = ls_health-newest_running_run_id ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = ls_health-unit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'policy_context_available'
      iv_value = ls_health-policy_context_available ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_policies'
      iv_value = ls_health-mixed_policies ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'movement_type_context'
      iv_value = ls_health-movement_type_context ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_shelf_life_context'
      iv_value = ls_health-minimum_shelf_life_context ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'safety_stock_context'
      iv_value = ls_health-safety_stock_context ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_units'
      iv_value = ls_health-mixed_units ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'available_stock_context_available'
      iv_value = ls_health-avail_stock_context_avail ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_available_stock'
      iv_value = ls_health-mixed_available_stock ) TO lt_json_fields.
    IF ls_health-avail_stock_context_avail = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'available_stock_context'
        iv_value = ls_health-available_stock_context ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property(
        iv_name = 'available_stock_context' ) TO lt_json_fields.
    ENDIF.
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
      iv_name  = 'priority_share_available'
      iv_value = ls_health-priority_share_available ) TO lt_json_fields.
    IF ls_health-priority_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_requested'
        iv_value = ls_health-priority_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_allocated'
        iv_value = ls_health-priority_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_shortage'
        iv_value = ls_health-priority_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'priority_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'priority_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'priority_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'priority_coverage_available'
      iv_value = ls_health-priority_coverage_available ) TO lt_json_fields.
    IF ls_health-priority_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_coverage_pct'
        iv_value = ls_health-priority_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'priority_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'fifo_share_available'
      iv_value = ls_health-fifo_share_available ) TO lt_json_fields.
    IF ls_health-fifo_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_requested'
        iv_value = ls_health-fifo_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_allocated'
        iv_value = ls_health-fifo_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_shortage'
        iv_value = ls_health-fifo_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'fifo_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'fifo_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'fifo_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'fifo_coverage_available'
      iv_value = ls_health-fifo_coverage_available ) TO lt_json_fields.
    IF ls_health-fifo_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_coverage_pct'
        iv_value = ls_health-fifo_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'fifo_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'full_only_share_available'
      iv_value = ls_health-full_only_share_available ) TO lt_json_fields.
    IF ls_health-full_only_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_requested'
        iv_value = ls_health-full_only_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_allocated'
        iv_value = ls_health-full_only_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_shortage'
        iv_value = ls_health-full_only_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'full_only_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'full_only_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'full_only_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'full_only_coverage_available'
      iv_value = ls_health-full_only_coverage_available ) TO lt_json_fields.
    IF ls_health-full_only_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_coverage_pct'
        iv_value = ls_health-full_only_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'full_only_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'smallest_share_available'
      iv_value = ls_health-smallest_share_available ) TO lt_json_fields.
    IF ls_health-smallest_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_requested'
        iv_value = ls_health-smallest_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_allocated'
        iv_value = ls_health-smallest_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_shortage'
        iv_value = ls_health-smallest_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'smallest_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'smallest_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'smallest_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'smallest_coverage_available'
      iv_value = ls_health-smallest_coverage_available ) TO lt_json_fields.
    IF ls_health-smallest_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_coverage_pct'
        iv_value = ls_health-smallest_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'smallest_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'largest_share_available'
      iv_value = ls_health-largest_share_available ) TO lt_json_fields.
    IF ls_health-largest_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_requested'
        iv_value = ls_health-largest_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_allocated'
        iv_value = ls_health-largest_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_shortage'
        iv_value = ls_health-largest_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'largest_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'largest_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'largest_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'largest_coverage_available'
      iv_value = ls_health-largest_coverage_available ) TO lt_json_fields.
    IF ls_health-largest_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_coverage_pct'
        iv_value = ls_health-largest_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'largest_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'best_share_available'
      iv_value = ls_health-best_share_available ) TO lt_json_fields.
    IF ls_health-best_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_requested'
        iv_value = ls_health-best_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_allocated'
        iv_value = ls_health-best_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_shortage'
        iv_value = ls_health-best_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'best_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'best_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'best_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'best_coverage_available'
      iv_value = ls_health-best_coverage_available ) TO lt_json_fields.
    IF ls_health-best_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_coverage_pct'
        iv_value = ls_health-best_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'best_coverage_pct' ) TO lt_json_fields.
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
      iv_name  = 'legacy_share_available'
      iv_value = ls_health-legacy_share_available ) TO lt_json_fields.
    IF ls_health-legacy_share_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_requested'
        iv_value = ls_health-legacy_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_allocated'
        iv_value = ls_health-legacy_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_shortage'
        iv_value = ls_health-legacy_shortage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'legacy_requested' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'legacy_allocated' ) TO lt_json_fields.
      APPEND zcl_stock_json=>null_property( iv_name = 'legacy_shortage' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'legacy_coverage_available'
      iv_value = ls_health-legacy_coverage_available ) TO lt_json_fields.
    IF ls_health-legacy_coverage_available = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_coverage_pct'
        iv_value = ls_health-legacy_coverage ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>null_property( iv_name = 'legacy_coverage_pct' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'coverage_threshold_active'
      iv_value = ls_health-coverage_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'coverage_threshold'
      iv_value = ls_health-coverage_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'coverage_below_threshold'
      iv_value = ls_health-coverage_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_coverage_threshold_active'
      iv_value = ls_health-last_coverage_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_coverage_threshold'
      iv_value = ls_health-last_coverage_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_coverage_below_threshold'
      iv_value = ls_health-last_coverage_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_threshold_active'
      iv_value = ls_health-shortage_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'shortage_threshold'
      iv_value = ls_health-shortage_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'shortage_above_threshold'
      iv_value = ls_health-shortage_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_duration_available'
      iv_value = ls_health-last_duration_available ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'duration_threshold_active'
      iv_value = ls_health-duration_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'duration_threshold'
      iv_value = ls_health-duration_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'duration_above_threshold'
      iv_value = ls_health-duration_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_duration_threshold_active'
      iv_value = ls_health-last_comp_duration_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_duration_threshold'
      iv_value = ls_health-last_comp_duration_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_duration_above_threshold'
      iv_value = ls_health-last_comp_duration_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_duration_min_threshold_active'
      iv_value = ls_health-last_comp_dur_min_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_duration_min_threshold'
      iv_value = ls_health-last_comp_duration_min_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_duration_below_threshold'
      iv_value = ls_health-last_comp_duration_below_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_success_required_active'
      iv_value = ls_health-last_comp_success_required_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_success_breach'
      iv_value = ls_health-last_completed_success_breach ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_success_streak_threshold_active'
      iv_value = ls_health-last_comp_succ_streak_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_success_streak_threshold'
      iv_value = ls_health-last_comp_success_streak_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_success_streak_below_threshold'
      iv_value = ls_health-last_cmp_succ_streak_below_lim ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_non_success_streak_threshold_active'
      iv_value = ls_health-last_comp_non_success_limit_on ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'last_completed_non_success_streak_threshold'
      iv_value = ls_health-last_comp_non_success_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'last_completed_non_success_streak_above_threshold'
      iv_value = ls_health-last_comp_non_succ_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'average_duration_threshold_active'
      iv_value = ls_health-average_duration_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'average_duration_threshold'
      iv_value = ls_health-average_duration_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'average_duration_above_threshold'
      iv_value = ls_health-average_duration_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'maximum_duration_threshold_active'
      iv_value = ls_health-maximum_duration_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'maximum_duration_threshold'
      iv_value = ls_health-maximum_duration_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'maximum_duration_above_threshold'
      iv_value = ls_health-maximum_duration_above_limit ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'duration_count_threshold_active'
      iv_value = ls_health-duration_count_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'duration_count_threshold'
      iv_value = ls_health-duration_count_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'duration_count_below_threshold'
      iv_value = ls_health-duration_count_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'run_count_threshold_active'
      iv_value = ls_health-run_count_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'run_count_threshold'
      iv_value = ls_health-run_count_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'run_count_below_threshold'
      iv_value = ls_health-run_count_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'deadline_count_threshold_active'
      iv_value = ls_health-deadline_count_limit_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'deadline_count_threshold'
      iv_value = ls_health-deadline_count_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'deadline_count_below_threshold'
      iv_value = ls_health-deadline_count_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'deadline_mix_threshold_active'
      iv_value = ls_health-deadline_mix_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'deadline_mix_threshold'
      iv_value = ls_health-deadline_mix_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'deadline_mix_below_threshold'
      iv_value = ls_health-deadline_mix_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'overdue_mix_threshold_active'
      iv_value = ls_health-overdue_mix_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'overdue_mix_threshold'
      iv_value = ls_health-overdue_mix_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'overdue_mix_above_threshold'
      iv_value = ls_health-overdue_mix_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_policy_warning_active'
      iv_value = ls_health-mixed_policy_warning_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_policy_breach'
      iv_value = ls_health-mixed_policy_breach ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_unit_warning_active'
      iv_value = ls_health-mixed_unit_warning_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'mixed_unit_breach'
      iv_value = ls_health-mixed_unit_breach ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'completion_threshold_active'
      iv_value = ls_health-completion_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'completion_threshold'
      iv_value = ls_health-completion_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'completion_below_threshold'
      iv_value = ls_health-completion_below_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'success_threshold_active'
      iv_value = ls_health-success_threshold_active ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'success_threshold'
      iv_value = ls_health-success_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'success_below_threshold'
        iv_value = ls_health-success_below_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'success_count_threshold_active'
        iv_value = ls_health-success_count_threshold_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'success_count_threshold'
        iv_value = ls_health-success_count_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'success_count_below_threshold'
        iv_value = ls_health-success_count_below_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'error_threshold_active'
        iv_value = ls_health-error_threshold_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'error_threshold'
        iv_value = ls_health-error_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'error_above_threshold'
        iv_value = ls_health-error_above_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'partial_threshold_active'
        iv_value = ls_health-partial_threshold_active ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'partial_threshold'
        iv_value = ls_health-partial_threshold ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'partial_above_threshold'
        iv_value = ls_health-partial_above_threshold ) TO lt_json_fields.
    APPEND zcl_stock_json=>number_property(
      iv_name  = 'threshold_breach_count'
      iv_value = ls_health-threshold_breach_count ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'threshold_breaches'
      iv_value = ls_health-threshold_breaches ) TO lt_json_fields.
    IF p_meta = abap_true.
      lt_summary_fields = lt_json_fields.
      CLEAR lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = p_matnr ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = p_werks ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = p_lgort ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = p_charg ) TO lt_scope_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = p_meins ) TO lt_scope_fields.
      CLEAR lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id_filter'
        iv_value = p_runid ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id_contains_filter'
        iv_value = p_rid ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'movement_type_filter'
        iv_value = p_mvt ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit_filter'
        iv_value = p_meins ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'strategy_filter'
        iv_value = p_strat ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'status_filter'
        iv_value = p_stat ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'preview_filter'
        iv_value = p_prev ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'message_filter'
        iv_value = p_msg ) TO lt_filter_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'message_only'
        iv_value = p_monly ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from_filter'
        iv_value = p_reqf ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to_filter'
        iv_value = p_until ) TO lt_filter_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_urgency_filter'
        iv_value = lv_deadline_urgency_filter ) TO lt_filter_fields.
      CLEAR lt_filter_names.
      IF p_runid IS NOT INITIAL.
        APPEND 'run_id_filter' TO lt_filter_names.
      ENDIF.
      IF p_rid IS NOT INITIAL.
        APPEND 'run_id_contains_filter' TO lt_filter_names.
      ENDIF.
      IF p_mvt IS NOT INITIAL.
        APPEND 'movement_type_filter' TO lt_filter_names.
      ENDIF.
      IF p_meins IS NOT INITIAL.
        APPEND 'unit_filter' TO lt_filter_names.
      ENDIF.
      IF p_strat IS NOT INITIAL.
        APPEND 'strategy_filter' TO lt_filter_names.
      ENDIF.
      IF p_stat IS NOT INITIAL.
        APPEND 'status_filter' TO lt_filter_names.
      ENDIF.
      IF p_prev IS NOT INITIAL.
        APPEND 'preview_filter' TO lt_filter_names.
      ENDIF.
      IF p_msg IS NOT INITIAL.
        APPEND 'message_filter' TO lt_filter_names.
      ENDIF.
      IF p_monly = abap_true.
        APPEND 'message_only' TO lt_filter_names.
      ENDIF.
      IF p_reqf IS NOT INITIAL.
        APPEND 'requested_on_from_filter' TO lt_filter_names.
      ENDIF.
      IF p_until IS NOT INITIAL.
        APPEND 'requested_on_to_filter' TO lt_filter_names.
      ENDIF.
      APPEND 'deadline_urgency_filter' TO lt_filter_names.
      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 130 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'health' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'scope'
        it_fields = lt_scope_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>string_array_property(
        iv_name   = 'filters_applied'
        it_values = lt_filter_names ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'filters'
        it_fields = lt_filter_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'summary'
        it_fields = lt_summary_fields ) TO lt_json_fields.
    ENDIF.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    WRITE: / 'mode;generated_date;generated_time;schema_version;status;message;reason_code;material;plant;'
      && 'storage_location;batch;movement_type_filter;unit_filter;'
      && 'run_id_filter;run_id_contains_filter;'
      && 'minimum_shelf_life_filter;safety_stock_filter;'
      && 'minimum_safety_stock_filter;maximum_safety_stock_filter;'
      && 'requested_on_from_filter;requested_on_to_filter;'
      && 'strategy_filter;status_filter;preview_filter;message_filter;message_only;'
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
       && 'maximum_running_age_filter;stale_threshold_seconds;legacy_strategy_filter;'
      && 'overdue_only;requested_overdue_as_of;'
      && 'requested_deadline_only;requested_deadline_from;requested_deadline_to;'
      && 'minimum_deadline_age_days;maximum_deadline_age_days;deadline_age_as_of;deadline_urgency_filter;'
      && 'minimum_coverage;maximum_shortage_pct;maximum_last_duration;'
      && 'maximum_last_completed_duration;'
      && 'minimum_last_completed_duration;'
      && 'require_last_completed_success;'
      && 'minimum_last_completed_success_streak;'
      && 'maximum_last_completed_non_success_streak;'
      && 'minimum_last_coverage;'
      && 'minimum_last_completed_coverage;maximum_last_completed_coverage;'
      && 'maximum_last_completed_shortage_pct;'
      && 'maximum_average_duration;'
      && 'maximum_completed_duration;minimum_duration_count;minimum_run_count;'
      && 'minimum_deadline_count;minimum_deadline_mix;'
      && 'warn_mixed_policies;'
      && 'warn_mixed_units;'
      && 'minimum_completion_rate;'
      && 'minimum_success_rate;minimum_success_count;maximum_error_rate;'
      && 'maximum_partial_rate;minimum_full_line_rate;'
      && 'maximum_unallocated_line_rate;'
      && 'maximum_partial_line_rate;'
      && 'minimum_full_line_count;'
      && 'maximum_demand_count_threshold;'
      && 'maximum_running_count_threshold;'
      && 'maximum_shortage_quantity_threshold;'
      && 'maximum_last_shortage_quantity;'
      && 'maximum_last_shortage_pct;'
      && 'maximum_last_age;'
      && 'maximum_last_completed_deadline_age;'
      && 'maximum_overdue_deadline_mix;'
      && 'maximum_current_day_deadline_mix;'
      && 'minimum_future_deadline_mix;'
      && 'maximum_last_completed_shortage_quantity;'
      && 'minimum_last_completed_allocated_quantity;'
      && 'minimum_last_completed_requested_quantity;'
      && 'maximum_last_completed_requested_quantity;'
      && 'maximum_last_completed_allocated_quantity;'
      && 'minimum_last_completed_full_line_rate;'
      && 'maximum_last_completed_full_line_rate;'
      && 'maximum_last_completed_unallocated_line_rate;'
      && 'maximum_last_completed_partial_line_rate;'
      && 'minimum_last_completed_full_line_count;'
      && 'minimum_last_completed_allocated_line_count;'
      && 'maximum_last_completed_allocated_line_count;'
      && 'maximum_last_completed_unallocated_line_count;'
      && 'maximum_last_completed_partial_line_count;'
      && 'maximum_last_completed_shortage_line_count;'
      && 'minimum_last_completed_available_stock;'
      && 'maximum_last_completed_available_stock;'
      && 'minimum_last_completed_demand_count;'
      && 'maximum_last_completed_demand_count;'
      && 'minimum_available_stock_threshold;maximum_available_stock_threshold;'
      && 'total_runs;preview_runs;operational_runs;preview_mix_pct;operational_mix_pct;success_runs;completion_pct;'
      && 'success_rate_pct;partial_rate_pct;error_rate_pct;'
      && 'demand_count;full_count;partial_count;unallocated_count;'
      && 'full_line_pct;partial_line_pct;unallocated_line_pct;'
      && 'deadline_count;deadline_mix_pct;overdue_count;current_deadline_count;future_deadline_count;'
      && 'overdue_mix_pct;current_deadline_mix_pct;future_deadline_mix_pct;'
      && 'last_requested_on_from;last_requested_on_to;'
      && 'last_requested_deadline;earliest_requested_deadline;latest_requested_deadline;'
      && 'last_deadline_age_days;last_deadline_urgency;oldest_deadline_age_days;'
      && 'oldest_deadline_urgency;newest_deadline_age_days;newest_deadline_urgency;'
      && 'deadline_age_reference_date;'
      && 'running_runs;stale_running_runs;error_runs;partial_runs;priority_runs;fifo_runs;'
      && 'full_only_runs;smallest_runs;largest_runs;best_runs;fair_runs;weighted_runs;adaptive_runs;'
      && 'adaptive_priority_runs;adaptive_fair_runs;legacy_runs;priority_mix_pct;'
      && 'fifo_mix_pct;full_only_mix_pct;smallest_mix_pct;largest_mix_pct;best_mix_pct;'
      && 'fair_mix_pct;weighted_mix_pct;adaptive_mix_pct;legacy_mix_pct;last_run_available;'
      && 'last_run_id;last_preview;last_available_stock_available;last_available_stock;'
      && 'last_available_stock_unit;last_requested_quantity;last_allocated_quantity;'
      && 'last_shortage_quantity;last_shortage_pct_available;last_shortage_pct;'
      && 'last_coverage_pct;last_demand_count;'
      && 'last_full_line_count;last_partial_line_count;last_unallocated_line_count;'
      && 'last_line_rates_available;last_full_line_pct;last_partial_line_pct;'
      && 'last_unallocated_line_pct;'
      && 'last_strategy;last_status;last_start_date;last_start_time;'
      && 'last_finish_date;last_finish_time;last_duration_seconds;last_run_message;'
      && 'last_age_available;last_age_seconds;last_age_reason;'
      && 'last_age_reference_date;last_age_reference_time;'
      && 'last_completed_run_available;last_completed_run_id;last_completed_preview;last_completed_status;'
      && 'last_completed_success_streak;'
      && 'last_completed_non_success_streak;'
      && 'last_completed_message;'
      && 'last_completed_start_date;last_completed_start_time;'
      && 'last_completed_finish_date;last_completed_finish_time;'
      && 'last_completed_duration_seconds;last_completed_unit;'
      && 'last_completed_policy_available;last_completed_movement_type;'
      && 'last_completed_min_shelf_life;last_completed_safety_stock;'
      && 'last_completed_horizon_available;last_completed_requested_on_from;'
      && 'last_completed_requested_on_to;last_completed_requested_deadline;'
      && 'last_completed_deadline_age_available;last_completed_deadline_age_days;'
      && 'last_completed_deadline_age_reason;last_completed_deadline_urgency;'
      && 'last_completed_available_stock_available;last_completed_available_stock;'
      && 'last_completed_available_stock_unit;last_completed_strategy;'
      && 'last_completed_requested;last_completed_allocated;last_completed_shortage;'
      && 'last_completed_coverage_pct;last_completed_demand_count;'
      && 'last_completed_full_line_count;last_completed_partial_line_count;'
      && 'last_completed_allocated_line_count;'
      && 'last_completed_unallocated_line_count;last_completed_shortage_pct_available;'
      && 'last_completed_shortage_pct;last_completed_line_rates_available;'
      && 'last_completed_full_line_pct;last_completed_partial_line_pct;'
      && 'last_completed_unallocated_line_pct;'
      && 'duration_metrics_available;average_duration_seconds;minimum_duration_seconds;'
      && 'maximum_duration_seconds;completed_duration_runs;oldest_running_age_seconds;'
      && 'oldest_running_run_id;newest_running_age_seconds;newest_running_run_id;'
      && 'unit;policy_context_available;mixed_policies;movement_type_context;'
      && 'minimum_shelf_life_context;safety_stock_context;mixed_units;'
      && 'available_stock_context_available;mixed_available_stock;'
      && 'available_stock_context;'
      && 'shortage_available;'
      && 'requested;allocated;shortage;coverage_pct;priority_share_available;'
      && 'priority_requested;priority_allocated;priority_shortage;priority_coverage_pct;'
      && 'fifo_share_available;fifo_requested;fifo_allocated;fifo_shortage;fifo_coverage_pct;'
      && 'full_only_share_available;full_only_requested;full_only_allocated;'
      && 'full_only_shortage;full_only_coverage_pct;smallest_share_available;'
      && 'smallest_requested;smallest_allocated;smallest_shortage;smallest_coverage_pct;'
      && 'largest_share_available;largest_requested;largest_allocated;largest_shortage;'
      && 'largest_coverage_pct;best_share_available;best_requested;best_allocated;'
      && 'best_shortage;best_coverage_pct;fair_share_available;fair_requested;'
      && 'fair_allocated;fair_shortage;fair_coverage_pct;weighted_share_available;weighted_requested;'
      && 'weighted_allocated;weighted_shortage;weighted_coverage_available;weighted_coverage_pct;'
      && 'adaptive_share_available;adaptive_requested;'
      && 'adaptive_allocated;adaptive_shortage;adaptive_coverage_available;'
      && 'adaptive_coverage_pct;legacy_share_available;legacy_requested;'
      && 'legacy_allocated;legacy_shortage;legacy_coverage_available;'
      && 'legacy_coverage_pct;coverage_threshold_active;coverage_threshold;'
      && 'coverage_below_threshold;shortage_threshold_active;shortage_threshold;'
      && 'last_coverage_threshold_active;last_coverage_threshold;'
      && 'last_coverage_below_threshold;'
      && 'shortage_above_threshold;'
      && 'last_duration_available;duration_threshold_active;duration_threshold;'
      && 'duration_above_threshold;completion_threshold_active;completion_threshold;'
      && 'average_duration_threshold_active;average_duration_threshold;'
      && 'average_duration_above_threshold;completion_threshold_active;'
      && 'maximum_duration_threshold_active;maximum_duration_threshold;'
      && 'maximum_duration_above_threshold;completion_threshold_active;'
      && 'completion_threshold;completion_below_threshold;success_threshold_active;'
      && 'success_threshold;success_count_threshold_active;success_count_threshold;'
      && 'success_count_below_threshold;success_below_threshold;'
      && 'duration_count_threshold_active;duration_count_threshold;'
      && 'duration_count_below_threshold;'
      && 'run_count_threshold_active;run_count_threshold;run_count_below_threshold;'
      && 'deadline_count_threshold_active;deadline_count_threshold;'
      && 'deadline_count_below_threshold;'
      && 'deadline_mix_threshold_active;deadline_mix_threshold;'
      && 'deadline_mix_below_threshold;'
      && 'overdue_mix_threshold_active;overdue_mix_threshold;'
      && 'overdue_mix_above_threshold;'
      && 'current_deadline_mix_threshold_active;current_deadline_mix_threshold;'
      && 'current_deadline_mix_above_threshold;'
      && 'future_deadline_mix_threshold_active;future_deadline_mix_threshold;'
      && 'future_deadline_mix_below_threshold;'
      && 'mixed_policy_warning_active;mixed_policy_breach;'
      && 'mixed_unit_warning_active;mixed_unit_breach;'
      && 'error_threshold_active;error_threshold;'
      && 'error_above_threshold;partial_threshold_active;partial_threshold;'
      && 'partial_above_threshold;full_line_threshold_active;full_line_threshold;'
      && 'full_line_below_threshold;unallocated_line_threshold_active;'
      && 'unallocated_line_threshold;unallocated_line_above_threshold;'
      && 'partial_line_threshold_active;partial_line_threshold;'
      && 'partial_line_above_threshold;'
      && 'full_count_threshold_active;full_count_threshold;'
      && 'full_count_below_threshold;'
      && 'demand_count_threshold_active;demand_count_threshold;'
      && 'demand_count_above_threshold;'
      && 'running_count_threshold_active;running_count_threshold;'
      && 'running_count_above_threshold;'
      && 'shortage_quantity_threshold_active;shortage_quantity_threshold;'
       && 'shortage_quantity_above_threshold;'
       && 'last_shortage_quantity_threshold_active;last_shortage_quantity_threshold;'
      && 'last_shortage_quantity_above_threshold;'
      && 'last_shortage_pct_threshold_active;last_shortage_pct_threshold;'
      && 'last_shortage_pct_above_threshold;'
      && 'last_completed_coverage_threshold_active;'
      && 'last_completed_coverage_threshold;'
      && 'last_completed_coverage_below_threshold;'
      && 'last_completed_coverage_max_threshold_active;'
      && 'last_completed_coverage_max_threshold;'
      && 'last_completed_coverage_above_threshold;'
      && 'last_completed_shortage_pct_threshold_active;'
      && 'last_completed_shortage_pct_threshold;'
      && 'last_completed_shortage_pct_above_threshold;'
      && 'last_completed_shortage_qty_threshold_active;'
      && 'last_completed_shortage_qty_threshold;'
      && 'last_completed_shortage_qty_above_threshold;'
      && 'last_completed_allocated_threshold_active;'
      && 'last_completed_allocated_threshold;'
      && 'last_completed_allocated_below_threshold;'
      && 'last_completed_requested_threshold_active;'
      && 'last_completed_requested_threshold;'
      && 'last_completed_requested_above_threshold;'
      && 'last_completed_requested_min_threshold_active;'
      && 'last_completed_requested_min_threshold;'
      && 'last_completed_requested_below_threshold;'
      && 'last_completed_allocated_max_threshold_active;'
      && 'last_completed_allocated_max_threshold;'
      && 'last_completed_allocated_above_threshold;'
      && 'last_completed_avail_stock_min_threshold_active;'
      && 'last_completed_avail_stock_min_threshold;'
      && 'last_completed_avail_stock_below_threshold;'
      && 'last_completed_avail_stock_max_threshold_active;'
      && 'last_completed_avail_stock_max_threshold;'
      && 'last_completed_avail_stock_above_threshold;'
      && 'last_completed_full_line_threshold_active;'
      && 'last_completed_full_line_threshold;'
      && 'last_completed_full_line_below_threshold;'
      && 'last_completed_full_line_max_threshold_active;'
      && 'last_completed_full_line_max_threshold;'
      && 'last_completed_full_line_above_threshold;'
      && 'last_completed_unalloc_line_threshold_active;'
      && 'last_completed_unalloc_line_threshold;'
      && 'last_completed_unalloc_line_above_threshold;'
      && 'last_completed_partial_line_threshold_active;'
      && 'last_completed_partial_line_threshold;'
      && 'last_completed_partial_line_above_threshold;'
      && 'last_completed_full_count_threshold_active;'
      && 'last_completed_full_count_threshold;'
      && 'last_completed_full_count_below_threshold;'
      && 'last_completed_allocated_count_threshold_active;'
      && 'last_completed_allocated_count_threshold;'
      && 'last_completed_allocated_count_below_threshold;'
      && 'last_completed_allocated_count_max_threshold_active;'
      && 'last_completed_allocated_count_max_threshold;'
      && 'last_completed_allocated_count_above_threshold;'
      && 'last_completed_unalloc_count_threshold_active;'
      && 'last_completed_unalloc_count_threshold;'
      && 'last_completed_unalloc_count_above_threshold;'
      && 'last_completed_partial_count_threshold_active;'
      && 'last_completed_partial_count_threshold;'
      && 'last_completed_partial_count_above_threshold;'
      && 'last_completed_shortage_count_threshold_active;'
      && 'last_completed_shortage_count_threshold;'
      && 'last_completed_shortage_count_above_threshold;'
      && 'last_age_threshold_active;last_age_threshold;last_age_above_threshold;'
      && 'last_completed_deadline_age_threshold_active;'
      && 'last_completed_deadline_age_threshold;'
      && 'last_completed_deadline_age_above_threshold;'
      && 'last_completed_demand_count_threshold_active;'
      && 'last_completed_demand_count_threshold;'
      && 'last_completed_demand_count_above_threshold;'
      && 'last_completed_demand_count_min_threshold_active;'
      && 'last_completed_demand_count_min_threshold;'
      && 'last_completed_demand_count_below_threshold;'
       && 'available_stock_min_threshold_active;available_stock_min_threshold;'
       && 'available_stock_below_threshold;available_stock_max_threshold_active;'
       && 'available_stock_max_threshold;available_stock_above_threshold;'
       && 'stale_threshold_active;stale_threshold;stale_above_threshold;'
       && 'threshold_breach_count;threshold_breaches'.
    APPEND zcl_stock_csv=>quote( 'zstock_alloc_health' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 130 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-message ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-reason_code ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_runid ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_rid ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_mvt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_shelf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_safon ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_saf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_safto ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_reqf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_until ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_strat ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_stat ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_prev ) TO lt_csv_fields.
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
     APPEND zcl_stock_csv=>number( p_stale ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( p_legacy ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_overdue_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_dead ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_deadf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_deadt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dagef ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_daget ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_age_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_urgency_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cov ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_spct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_durmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cdurmx ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cdurmn ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_csucc ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cstrk ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cfail ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_lcov ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_ccov ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_ccvmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cspct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_avgmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_maxdur ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_durcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_runcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dcmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dmmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_pmix ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_umix ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_succ ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_sucnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_errmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_prtmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_flmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_ulmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_plmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_flcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_rmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_shmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_lshmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_lspct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_lage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cdag ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_odmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cdmmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_fdmmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cshmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_camin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_crqmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_crqmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_caqmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cflmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cflmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_culmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cplmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cflcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cacnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cacmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_culcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cplcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cshcnt ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cavmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cavmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cdmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_cdmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_avmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_avmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-total_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-preview_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-operational_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-preview_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-operational_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-success_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-completion_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-success_rate_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_rate_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-error_rate_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-demand_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-full_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-unallocated_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-full_line_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_line_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-unallocated_line_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-deadline_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-deadline_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-overdue_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      ls_health-current_deadline_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-future_deadline_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-overdue_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      ls_health-current_deadline_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number(
      ls_health-future_deadline_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_requested_on_from ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_requested_on_to ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-earliest_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-latest_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-last_deadline_age_days ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_deadline_urgency ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-oldest_deadline_age_days ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-oldest_deadline_urgency ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-newest_deadline_age_days ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-newest_deadline_urgency ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-deadline_age_reference_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-running_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-stale_running_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-error_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-priority_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-fifo_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-full_only_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-smallest_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-largest_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-best_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-fair_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-weighted_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_priority_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_fair_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-legacy_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-priority_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-fifo_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-full_only_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-smallest_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-largest_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-best_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-fair_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-weighted_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-adaptive_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-legacy_mix_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_run_available ) TO lt_csv_fields.
    IF ls_health-last_run_available = abap_true.
      APPEND zcl_stock_csv=>quote( ls_health-last_run_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_preview ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_available_stock_available ) TO lt_csv_fields.
      IF ls_health-last_available_stock_available = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_available_stock ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( ls_health-last_available_stock_unit ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>number( ls_health-last_requested_quantity ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_allocated_quantity ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_shortage_quantity ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_shortage_pct_available ) TO lt_csv_fields.
      IF ls_health-last_shortage_pct_available = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_shortage_pct ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>number( ls_health-last_coverage_pct ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_full_line_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_partial_line_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_unallocated_line_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_line_rates_available ) TO lt_csv_fields.
      IF ls_health-last_line_rates_available = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_full_line_pct ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_health-last_partial_line_pct ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_health-last_unallocated_line_pct ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_duration_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_run_message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_available ) TO lt_csv_fields.
      IF ls_health-last_age_available = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_age_seconds ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_reference_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_reference_time ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_reference_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_reference_time ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-last_completed_run_available ) TO lt_csv_fields.
    IF ls_health-last_completed_run_available = abap_true.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_run_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_preview ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_success_streak ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_non_success_streak ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_duration_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_policy_available ) TO lt_csv_fields.
      IF ls_health-last_comp_policy_available = abap_true.
        APPEND zcl_stock_csv=>quote( ls_health-last_completed_movement_type ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_health-last_completed_min_shelf_life ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_health-last_completed_safety_stock ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_horizon_available ) TO lt_csv_fields.
      IF ls_health-last_comp_horizon_available = abap_true.
        APPEND zcl_stock_csv=>quote( ls_health-last_comp_requested_on_from ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( ls_health-last_completed_requested_on_to ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( ls_health-last_comp_requested_deadline ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_deadline_age_avail ) TO lt_csv_fields.
      IF ls_health-last_comp_deadline_age_avail = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_comp_deadline_age_days ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_deadline_age_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_deadline_urgency ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_avail_stock_avail ) TO lt_csv_fields.
      IF ls_health-last_comp_avail_stock_avail = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_completed_available_stock ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( ls_health-last_comp_available_stock_unit ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_completed_strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_coverage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_demand ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_full ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_allocated_line_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_partial ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_completed_unalloc ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_shortage_pct_avail ) TO lt_csv_fields.
      IF ls_health-last_comp_shortage_pct_avail = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_completed_shortage_pct ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_line_rates_available ) TO lt_csv_fields.
      IF ls_health-last_comp_line_rates_available = abap_true.
        APPEND zcl_stock_csv=>number( ls_health-last_completed_full_line_pct ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_health-last_comp_partial_line_pct ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_health-last_comp_unalloc_line_pct ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ENDIF.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " run id
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " preview
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " status
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " success streak
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " non-success streak
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " message
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " start date
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " start time
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " finish date
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " finish time
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " duration
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " unit
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields. " policy available
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " movement type
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " shelf life
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " safety stock
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields. " horizon available
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " horizon from
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " horizon to
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " deadline
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields. " deadline age available
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " deadline age
      APPEND zcl_stock_csv=>quote( 'no_completed_run' ) TO lt_csv_fields. " age reason
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields. " stock available
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " stock
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " stock unit
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " strategy
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " requested
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " allocated
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " shortage
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " coverage
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " demand
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " full
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " allocated lines
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " partial
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " unallocated
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields. " shortage pct available
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " shortage pct
      APPEND zcl_stock_csv=>quote( 'false' ) TO lt_csv_fields. " line rates available
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " full line pct
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " partial line pct
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields. " unallocated line pct
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-duration_metrics_available ) TO lt_csv_fields.
    IF ls_health-duration_metrics_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-average_duration_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-minimum_duration_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-maximum_duration_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-completed_duration_runs ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>number( ls_health-oldest_running_age_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-oldest_running_run_id ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-newest_running_age_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-newest_running_run_id ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-policy_context_available ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_policies ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-movement_type_context ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-minimum_shelf_life_context ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-safety_stock_context ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_units ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-avail_stock_context_avail ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_available_stock ) TO lt_csv_fields.
    IF ls_health-avail_stock_context_avail = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-available_stock_context ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
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
    APPEND zcl_stock_csv=>quote( ls_health-priority_share_available ) TO lt_csv_fields.
    IF ls_health-priority_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-priority_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-priority_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-priority_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-priority_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-priority_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-fifo_share_available ) TO lt_csv_fields.
    IF ls_health-fifo_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-fifo_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-fifo_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-fifo_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-fifo_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-fifo_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-full_only_share_available ) TO lt_csv_fields.
    IF ls_health-full_only_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-full_only_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-full_only_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-full_only_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-full_only_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-full_only_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-smallest_share_available ) TO lt_csv_fields.
    IF ls_health-smallest_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-smallest_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-smallest_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-smallest_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-smallest_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-smallest_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-largest_share_available ) TO lt_csv_fields.
    IF ls_health-largest_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-largest_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-largest_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-largest_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-largest_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-largest_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( ls_health-best_share_available ) TO lt_csv_fields.
    IF ls_health-best_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-best_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-best_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-best_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-best_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-best_coverage ) TO lt_csv_fields.
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
    APPEND zcl_stock_csv=>quote( ls_health-legacy_share_available ) TO lt_csv_fields.
    IF ls_health-legacy_share_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-legacy_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-legacy_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-legacy_shortage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
    IF ls_health-legacy_coverage_available = abap_true.
      APPEND zcl_stock_csv=>number( ls_health-legacy_coverage ) TO lt_csv_fields.
    ELSE.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    ENDIF.
     APPEND zcl_stock_csv=>quote( ls_health-coverage_threshold_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-coverage_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-coverage_below_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_coverage_threshold_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_coverage_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_coverage_below_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-shortage_threshold_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-shortage_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-shortage_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_duration_available ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-duration_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-duration_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-duration_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_duration_limit_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-last_comp_duration_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_duration_above_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_dur_min_limit_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-last_comp_duration_min_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_duration_below_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_success_required_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_completed_success_breach ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_succ_streak_limit_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-last_comp_success_streak_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_cmp_succ_streak_below_lim ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_non_success_limit_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-last_comp_non_success_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-last_comp_non_succ_above_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-average_duration_limit_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-average_duration_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-average_duration_above_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-maximum_duration_limit_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-maximum_duration_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-maximum_duration_above_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-duration_count_limit_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-duration_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-duration_count_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-run_count_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-run_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-run_count_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-deadline_count_limit_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-deadline_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-deadline_count_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-deadline_mix_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-deadline_mix_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-deadline_mix_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-overdue_mix_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-overdue_mix_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-overdue_mix_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-current_deadline_mix_limit_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-current_deadline_mix_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-curr_deadline_mix_above_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-future_deadline_mix_limit_on ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-future_deadline_mix_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-fut_deadline_mix_below_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_policy_warning_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_policy_breach ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_unit_warning_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-mixed_unit_breach ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-completion_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-completion_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-completion_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-success_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-success_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-success_count_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-success_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-success_count_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-success_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-error_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-error_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-error_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-partial_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-partial_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-full_line_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-full_line_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-full_line_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-unallocated_line_limit_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-unallocated_line_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-unallocated_line_above_limit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-partial_line_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-partial_line_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-partial_line_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-full_count_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-full_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-full_count_below_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-demand_count_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-demand_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-demand_count_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-running_count_threshold_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-running_count_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-running_count_above_threshold ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-shortage_quantity_limit_active ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_health-shortage_quantity_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-shortage_quantity_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_shortage_qty_limit_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_shortage_qty_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_shortage_qty_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_shortage_pct_limit_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_shortage_pct_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_shortage_pct_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_coverage_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_coverage_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_coverage_below_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_cov_max_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_coverage_max_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_coverage_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_short_pct_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_shortage_pct_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_short_pct_above_lim ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_short_qty_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_shortage_qty_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_short_qty_above_lim ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_allocated_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_allocated_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_alloc_below_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_requested_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_requested_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_req_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_req_min_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_requested_min_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_req_below_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_alloc_max_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_allocated_max_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_alloc_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_avail_stk_min_lim_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_avail_stk_min_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_avail_stk_below_lim ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_avail_stk_max_lim_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_avail_stk_max_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_avail_stk_above_lim ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_full_line_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_full_line_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_full_ln_below_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_full_ln_max_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_full_line_max_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_full_ln_above_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_unalloc_ln_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_unalloc_line_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_unalloc_ln_above_lim ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_part_line_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_partial_line_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_part_ln_above_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_full_count_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_full_count_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_full_cnt_below_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_alloc_count_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_alloc_count_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_alloc_cnt_below_lim ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_alloc_cnt_max_lim_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_alloc_cnt_max_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_acnt_max_above_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_unalloc_cnt_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_unalloc_count_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_unalloc_cnt_over_lim ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_partial_cnt_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_partial_count_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_part_cnt_above_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_short_cnt_limit_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_health-last_comp_shortage_count_limit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_comp_short_cnt_above_lim ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_health-last_age_threshold_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_age_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_age_above_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_ddl_age_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_deadline_age_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_ddl_age_above_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_demand_cnt_limit_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_demand_count_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_demand_cnt_above_lim ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_cmp_demand_cnt_min_lim_on ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-last_comp_demand_cnt_min_limit ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-last_comp_demand_cnt_below_lim ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-avail_stock_min_limit_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-avail_stock_min_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-avail_stock_below_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-avail_stock_max_limit_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-avail_stock_max_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-avail_stock_above_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-stale_threshold_active ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-stale_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>quote( ls_health-stale_above_threshold ) TO lt_csv_fields.
     APPEND zcl_stock_csv=>number( ls_health-threshold_breach_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_health-threshold_breaches ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

    WRITE: / 'Generated date:', sy-datum,
         / 'Generated time:', sy-uzeit,
         / 'Allocation health:', ls_health-status,
         / 'Message:', ls_health-message,
         / 'Reason code:', ls_health-reason_code,
         / 'Material:', p_matnr,
         / 'Plant:', p_werks,
         / 'Storage location:', p_lgort,
         / 'Batch:', p_charg,
         / 'Run ID filter:', p_runid,
         / 'Run ID contains filter:', p_rid,
         / 'Movement type filter:', p_mvt,
         / 'Unit filter:', p_meins,
         / 'Minimum shelf life:', p_shelf, 'days',
         / 'Safety-stock filter:', p_safon,
         / 'Minimum safety stock:', p_saf,
         / 'Maximum safety stock:', p_safto,
         / 'Requested delivery from:', p_reqf,
         / 'Requested delivery to:', p_until,
         / 'Strategy filter:', p_strat,
         / 'Status filter:', p_stat,
         / 'Preview filter:', p_prev,
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
         / 'Maximum running count:', p_rmax,
         / 'Legacy strategy filter:', p_legacy,
         / 'Overdue only:', p_ovrd,
         / 'Requested overdue as-of:', lv_overdue_date,
         / 'Requested deadline only:', p_dead,
         / 'Requested deadline from:', p_deadf,
         / 'Requested deadline to:', p_deadt,
         / 'Minimum deadline age days:', p_dagef,
         / 'Maximum deadline age days:', p_daget,
         / 'Deadline age as-of:', lv_deadline_age_date,
         / 'Deadline urgency:', lv_deadline_urgency_filter,
         / 'Minimum coverage:', p_cov, '%',
         / 'Maximum shortage:', p_spct, '%',
         / 'Maximum latest duration:', p_durmax, 'seconds',
         / 'Maximum latest completed duration:', p_cdurmx, 'seconds',
         / 'Minimum latest completed duration:', p_cdurmn, 'seconds',
         / 'Require latest completed success:', p_csucc,
         / 'Minimum latest completed success streak:', p_cstrk,
         / 'Maximum latest completed non-success streak:', p_cfail,
         / 'Maximum latest completed age:', p_lage, 'seconds',
         / 'Maximum latest completed deadline age:', p_cdag, 'days',
         / 'Maximum overdue deadline mix:', p_odmax, '%',
         / 'Maximum current-day deadline mix:', p_cdmmax, '%',
         / 'Minimum future deadline mix:', p_fdmmin, '%',
         / 'Maximum latest completed shortage quantity:', p_cshmax,
         / 'Minimum latest completed coverage:', p_ccov, '%',
         / 'Maximum latest completed coverage:', p_ccvmax, '%',
         / 'Minimum latest completed allocated quantity:', p_camin,
         / 'Minimum latest completed requested quantity:', p_crqmin,
         / 'Maximum latest completed requested quantity:', p_crqmax,
         / 'Maximum latest completed allocated quantity:', p_caqmax,
         / 'Minimum latest completed full-line rate:', p_cflmin, '%',
         / 'Maximum latest completed full-line rate:', p_cflmax, '%',
          / 'Maximum latest completed unallocated-line rate:', p_culmax, '%',
          / 'Maximum latest completed partial-line rate:', p_cplmax, '%',
         / 'Minimum latest completed full-line count:', p_cflcnt,
         / 'Minimum latest completed allocated-line count:', p_cacnt,
         / 'Maximum latest completed unallocated-line count:', p_culcnt,
         / 'Maximum latest completed partial-line count:', p_cplcnt,
         / 'Maximum latest completed shortage-line count:', p_cshcnt,
         / 'Minimum latest completed demand count:', p_cdmin,
         / 'Maximum latest completed demand count:', p_cdmax,
         / 'Maximum average duration:', p_avgmax, 'seconds',
         / 'Maximum completed duration:', p_maxdur, 'seconds',
         / 'Minimum duration sample count:', p_durcnt,
         / 'Minimum total run count:', p_runcnt,
         / 'Minimum deadline-bearing run count:', p_dcmin,
         / 'Minimum deadline mix:', p_dmmin, '%',
         / 'Warn on mixed policies:', p_pmix,
         / 'Warn on mixed units:', p_umix,
         / 'Minimum completion rate:', p_cmin, '%',
         / 'Minimum success rate:', p_succ, '%',
         / 'Maximum error rate:', p_errmax, '%',
         / 'Maximum partial-run rate:', p_prtmax, '%',
         / 'Deadline count:', ls_health-deadline_count,
         'mix:', ls_health-deadline_mix_pct, '%',
         / 'Overdue deadline count:', ls_health-overdue_count,
         'mix:', ls_health-overdue_mix_pct, '%',
         / 'Current-day deadline count:', ls_health-current_deadline_count,
         'mix:', ls_health-current_deadline_mix_pct, '%',
         / 'Future deadline count:', ls_health-future_deadline_count,
         'mix:', ls_health-future_deadline_mix_pct, '%',
         / 'Last requested delivery from:', ls_health-last_requested_on_from,
         / 'Last requested delivery to:', ls_health-last_requested_on_to,
         / 'Last requested deadline:', ls_health-last_requested_deadline,
         / 'Earliest requested deadline:', ls_health-earliest_requested_deadline,
         / 'Latest requested deadline:', ls_health-latest_requested_deadline,
         / 'Last deadline age days:', ls_health-last_deadline_age_days,
         / 'Last deadline urgency:', ls_health-last_deadline_urgency,
         / 'Oldest deadline age days:', ls_health-oldest_deadline_age_days,
         / 'Oldest deadline urgency:', ls_health-oldest_deadline_urgency,
         / 'Newest deadline age days:', ls_health-newest_deadline_age_days,
         / 'Newest deadline urgency:', ls_health-newest_deadline_urgency,
         / 'Deadline age reference date:', ls_health-deadline_age_reference_date,
         / 'Runs:', ls_health-total_runs,
         / 'Preview runs:', ls_health-preview_runs,
         / 'Operational runs:', ls_health-operational_runs,
         / 'Preview mix:', ls_health-preview_mix_pct, '%',
         / 'Operational mix:', ls_health-operational_mix_pct, '%',
         / 'Successful:', ls_health-success_runs,
         / 'Completion:', ls_health-completion_pct, '%',
         / 'Success rate:', ls_health-success_rate_pct, '%',
         / 'Partial rate:', ls_health-partial_rate_pct, '%',
         / 'Error rate:', ls_health-error_rate_pct, '%',
         / 'Demand lines:', ls_health-demand_count,
         / 'Full lines:', ls_health-full_count,
         / 'Partial lines:', ls_health-partial_count,
         / 'Unallocated lines:', ls_health-unallocated_count,
         / 'Full-line percentage:', ls_health-full_line_pct, '%',
         / 'Partial-line percentage:', ls_health-partial_line_pct, '%',
         / 'Unallocated-line percentage:', ls_health-unallocated_line_pct, '%',
          / 'Running:', ls_health-running_runs,
          / 'Stale running:', ls_health-stale_running_runs,
          / 'Errors:', ls_health-error_runs,
         / 'Partial:', ls_health-partial_runs,
         / 'Priority runs:', ls_health-priority_runs,
         / 'FIFO runs:', ls_health-fifo_runs,
         / 'Full-only runs:', ls_health-full_only_runs,
         / 'Smallest-demand runs:', ls_health-smallest_runs,
         / 'Largest-demand runs:', ls_health-largest_runs,
         / 'Best-fit runs:', ls_health-best_runs,
         / 'Fair-share runs:', ls_health-fair_runs,
         / 'Weighted fair-share runs:', ls_health-weighted_runs,
         / 'Adaptive runs:', ls_health-adaptive_runs,
         / 'Adaptive priority branch runs:', ls_health-adaptive_priority_runs,
         / 'Adaptive fair-share branch runs:', ls_health-adaptive_fair_runs,
         / 'Legacy strategy runs:', ls_health-legacy_runs,
         / 'Priority mix:', ls_health-priority_mix_pct, '%',
         / 'FIFO mix:', ls_health-fifo_mix_pct, '%',
         / 'Full-only mix:', ls_health-full_only_mix_pct, '%',
         / 'Smallest-demand mix:', ls_health-smallest_mix_pct, '%',
         / 'Largest-demand mix:', ls_health-largest_mix_pct, '%',
         / 'Best-fit mix:', ls_health-best_mix_pct, '%',
         / 'Fair-share mix:', ls_health-fair_mix_pct, '%',
         / 'Weighted fair-share mix:', ls_health-weighted_mix_pct, '%',
         / 'Adaptive mix:', ls_health-adaptive_mix_pct, '%',
         / 'Legacy mix:', ls_health-legacy_mix_pct, '%',
         / 'Policy context available:', ls_health-policy_context_available,
         / 'Mixed policies:', ls_health-mixed_policies,
         / 'Movement type context:', ls_health-movement_type_context,
         / 'Minimum shelf-life context:', ls_health-minimum_shelf_life_context,
         / 'Safety-stock context:', ls_health-safety_stock_context,
         / 'Mixed units:', ls_health-mixed_units,
         / 'Unit:', ls_health-unit.
  WRITE: / 'Available-stock context available:',
           ls_health-avail_stock_context_avail,
         / 'Mixed available stock:', ls_health-mixed_available_stock.
  IF ls_health-avail_stock_context_avail = abap_true.
    WRITE: / 'Available-stock context:', ls_health-available_stock_context.
  ELSE.
    WRITE: / 'Available-stock context: n/a'.
  ENDIF.
  IF ls_health-last_run_available = abap_true.
    WRITE: / 'Last run ID:', ls_health-last_run_id,
           / 'Last available stock:', ls_health-last_available_stock,
           / 'Last available stock unit:', ls_health-last_available_stock_unit,
           / 'Last requested quantity:', ls_health-last_requested_quantity,
           / 'Last allocated quantity:', ls_health-last_allocated_quantity,
           / 'Last shortage quantity:', ls_health-last_shortage_quantity,
           / 'Last shortage rate available:', ls_health-last_shortage_pct_available,
           / 'Last coverage:', ls_health-last_coverage_pct, '%',
           / 'Last demand count:', ls_health-last_demand_count,
           / 'Last full-line count:', ls_health-last_full_line_count,
           / 'Last partial-line count:', ls_health-last_partial_line_count,
           / 'Last unallocated-line count:', ls_health-last_unallocated_line_count,
           / 'Last line rates available:', ls_health-last_line_rates_available,
           / 'Last strategy:', ls_health-last_strategy,
           / 'Last status:', ls_health-last_status,
           / 'Last preview:', ls_health-last_preview,
           / 'Last start:', ls_health-last_start_date, ls_health-last_start_time,
           / 'Last finish:', ls_health-last_finish_date, ls_health-last_finish_time,
           / 'Last duration seconds:', ls_health-last_duration_seconds,
           / 'Last run message:', ls_health-last_run_message.
  ELSE.
    WRITE: / 'Last run: n/a'.
  ENDIF.
  IF ls_health-last_shortage_pct_available = abap_true.
    WRITE: / 'Last shortage rate:', ls_health-last_shortage_pct, '%' .
  ELSE.
    WRITE: / 'Last shortage rate: n/a'.
  ENDIF.
  IF ls_health-last_age_available = abap_true.
    WRITE: / 'Last completed age seconds:', ls_health-last_age_seconds.
  ELSE.
    WRITE: / 'Last completed age: n/a'.
  ENDIF.
  WRITE: / 'Last completed age reason:', ls_health-last_age_reason.
  WRITE: / 'Last completed age reference:',
    ls_health-last_age_reference_date,
    ls_health-last_age_reference_time.
  IF ls_health-last_completed_run_available = abap_true.
    WRITE: / 'Last completed run ID:', ls_health-last_completed_run_id,
           / 'Last completed status:', ls_health-last_completed_status,
           / 'Last completed preview:', ls_health-last_completed_preview,
           / 'Last completed message:', ls_health-last_completed_message,
           / 'Last completed start:',
             ls_health-last_completed_start_date,
             ls_health-last_completed_start_time,
           / 'Last completed unit:', ls_health-last_completed_unit,
           / 'Last completed movement type:',
             ls_health-last_completed_movement_type,
           / 'Last completed minimum shelf-life:',
             ls_health-last_completed_min_shelf_life,
           / 'Last completed safety stock:',
             ls_health-last_completed_safety_stock,
           / 'Last completed requested horizon:',
             ls_health-last_comp_requested_on_from,
             ls_health-last_completed_requested_on_to,
           / 'Last completed requested deadline:',
             ls_health-last_comp_requested_deadline,
           / 'Last completed strategy:', ls_health-last_completed_strategy,
           / 'Last completed finish:',
             ls_health-last_completed_finish_date,
             ls_health-last_completed_finish_time,
           / 'Last completed duration seconds:',
             ls_health-last_comp_duration_seconds,
           / 'Last completed requested:', ls_health-last_completed_requested,
           / 'Last completed allocated:', ls_health-last_completed_allocated,
           / 'Last completed shortage:', ls_health-last_completed_shortage,
           / 'Last completed coverage:', ls_health-last_completed_coverage, '%',
           / 'Last completed demand count:', ls_health-last_completed_demand,
           / 'Last completed full-line count:', ls_health-last_completed_full,
           / 'Last completed partial-line count:', ls_health-last_completed_partial,
           / 'Last completed unallocated-line count:',
             ls_health-last_completed_unalloc.
    IF ls_health-last_comp_deadline_age_avail = abap_true.
      WRITE: / 'Last completed deadline age days:',
        ls_health-last_comp_deadline_age_days.
    ELSE.
      WRITE: / 'Last completed deadline age: n/a'.
    ENDIF.
    WRITE: / 'Last completed deadline age reason:',
      ls_health-last_comp_deadline_age_reason.
    WRITE: / 'Last completed deadline urgency:',
      ls_health-last_comp_deadline_urgency.
    IF ls_health-last_comp_avail_stock_avail = abap_true.
      WRITE: / 'Last completed available stock:',
        ls_health-last_completed_available_stock,
        / 'Last completed available stock unit:',
        ls_health-last_comp_available_stock_unit.
    ELSE.
      WRITE: / 'Last completed available stock: n/a'.
    ENDIF.
    IF ls_health-last_comp_shortage_pct_avail = abap_true.
      WRITE: / 'Last completed shortage rate:',
        ls_health-last_completed_shortage_pct, '%'.
    ELSE.
      WRITE: / 'Last completed shortage rate: n/a'.
    ENDIF.
    IF ls_health-last_comp_line_rates_available = abap_true.
      WRITE: / 'Last completed full-line rate:',
        ls_health-last_completed_full_line_pct, '%',
        / 'Last completed partial-line rate:',
        ls_health-last_comp_partial_line_pct, '%',
        / 'Last completed unallocated-line rate:',
        ls_health-last_comp_unalloc_line_pct, '%'.
    ELSE.
      WRITE: / 'Last completed line rates: n/a'.
    ENDIF.
  ELSE.
    WRITE: / 'Last completed run: n/a'.
  ENDIF.
  IF ls_health-last_line_rates_available = abap_true.
    WRITE: / 'Last full-line rate:', ls_health-last_full_line_pct, '%',
           / 'Last partial-line rate:', ls_health-last_partial_line_pct, '%',
           / 'Last unallocated-line rate:', ls_health-last_unallocated_line_pct, '%'.
  ELSE.
    WRITE: / 'Last line rates: n/a'.
  ENDIF.
  IF ls_health-duration_metrics_available = abap_true.
    WRITE: / 'Average duration seconds:', ls_health-average_duration_seconds,
           / 'Minimum duration seconds:', ls_health-minimum_duration_seconds,
           / 'Maximum duration seconds:', ls_health-maximum_duration_seconds,
           / 'Completed duration runs:', ls_health-completed_duration_runs.
  ELSE.
    WRITE: / 'Duration metrics: n/a'.
  ENDIF.
  WRITE: / 'Oldest running age seconds:', ls_health-oldest_running_age_seconds,
         / 'Oldest running run ID:', ls_health-oldest_running_run_id,
         / 'Newest running age seconds:', ls_health-newest_running_age_seconds,
         / 'Newest running run ID:', ls_health-newest_running_run_id.
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
  IF ls_health-priority_share_available = abap_true.
    WRITE: / 'Priority totals (', ls_health-unit, '): requested',
      ls_health-priority_requested, 'allocated', ls_health-priority_allocated,
      'shortage', ls_health-priority_shortage.
  ELSE.
    WRITE: / 'Priority totals: n/a'.
  ENDIF.
  IF ls_health-priority_coverage_available = abap_true.
    WRITE: / 'Priority coverage:', ls_health-priority_coverage, '%' .
  ELSE.
    WRITE: / 'Priority coverage: n/a'.
  ENDIF.
  IF ls_health-fifo_share_available = abap_true.
    WRITE: / 'FIFO totals (', ls_health-unit, '): requested',
      ls_health-fifo_requested, 'allocated', ls_health-fifo_allocated,
      'shortage', ls_health-fifo_shortage.
  ELSE.
    WRITE: / 'FIFO totals: n/a'.
  ENDIF.
  IF ls_health-fifo_coverage_available = abap_true.
    WRITE: / 'FIFO coverage:', ls_health-fifo_coverage, '%' .
  ELSE.
    WRITE: / 'FIFO coverage: n/a'.
  ENDIF.
  IF ls_health-full_only_share_available = abap_true.
    WRITE: / 'Full-only totals (', ls_health-unit, '): requested',
      ls_health-full_only_requested, 'allocated', ls_health-full_only_allocated,
      'shortage', ls_health-full_only_shortage.
  ELSE.
    WRITE: / 'Full-only totals: n/a'.
  ENDIF.
  IF ls_health-full_only_coverage_available = abap_true.
    WRITE: / 'Full-only coverage:', ls_health-full_only_coverage, '%' .
  ELSE.
    WRITE: / 'Full-only coverage: n/a'.
  ENDIF.
  IF ls_health-smallest_share_available = abap_true.
    WRITE: / 'Smallest-demand totals (', ls_health-unit, '): requested',
      ls_health-smallest_requested, 'allocated', ls_health-smallest_allocated,
      'shortage', ls_health-smallest_shortage.
  ELSE.
    WRITE: / 'Smallest-demand totals: n/a'.
  ENDIF.
  IF ls_health-smallest_coverage_available = abap_true.
    WRITE: / 'Smallest-demand coverage:', ls_health-smallest_coverage, '%' .
  ELSE.
    WRITE: / 'Smallest-demand coverage: n/a'.
  ENDIF.
  IF ls_health-largest_share_available = abap_true.
    WRITE: / 'Largest-demand totals (', ls_health-unit, '): requested',
      ls_health-largest_requested, 'allocated', ls_health-largest_allocated,
      'shortage', ls_health-largest_shortage.
  ELSE.
    WRITE: / 'Largest-demand totals: n/a'.
  ENDIF.
  IF ls_health-largest_coverage_available = abap_true.
    WRITE: / 'Largest-demand coverage:', ls_health-largest_coverage, '%' .
  ELSE.
    WRITE: / 'Largest-demand coverage: n/a'.
  ENDIF.
  IF ls_health-best_share_available = abap_true.
    WRITE: / 'Best-fit totals (', ls_health-unit, '): requested',
      ls_health-best_requested, 'allocated', ls_health-best_allocated,
      'shortage', ls_health-best_shortage.
  ELSE.
    WRITE: / 'Best-fit totals: n/a'.
  ENDIF.
  IF ls_health-best_coverage_available = abap_true.
    WRITE: / 'Best-fit coverage:', ls_health-best_coverage, '%' .
  ELSE.
    WRITE: / 'Best-fit coverage: n/a'.
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
  IF ls_health-legacy_share_available = abap_true.
    WRITE: / 'Legacy totals (', ls_health-unit, '): requested',
      ls_health-legacy_requested, 'allocated', ls_health-legacy_allocated,
      'shortage', ls_health-legacy_shortage.
  ELSE.
    WRITE: / 'Legacy totals: n/a'.
  ENDIF.
  IF ls_health-legacy_coverage_available = abap_true.
    WRITE: / 'Legacy coverage:', ls_health-legacy_coverage, '%' .
  ELSE.
    WRITE: / 'Legacy coverage: n/a'.
  ENDIF.
  WRITE: / 'Coverage threshold active:', ls_health-coverage_threshold_active,
         / 'Coverage threshold:', ls_health-coverage_threshold, '%',
         / 'Coverage threshold breached:', ls_health-coverage_below_threshold,
         / 'Latest coverage threshold active:', ls_health-last_coverage_threshold_active,
         / 'Latest coverage threshold:', ls_health-last_coverage_threshold, '%',
         / 'Latest coverage threshold breached:', ls_health-last_coverage_below_threshold,
         / 'Shortage threshold active:', ls_health-shortage_threshold_active,
         / 'Shortage threshold:', ls_health-shortage_threshold, '%',
         / 'Shortage threshold breached:', ls_health-shortage_above_threshold,
         / 'Last duration available:', ls_health-last_duration_available,
         / 'Duration threshold active:', ls_health-duration_threshold_active,
         / 'Duration threshold:', ls_health-duration_threshold,
         / 'Duration threshold breached:', ls_health-duration_above_threshold,
         / 'Latest completed duration threshold active:',
           ls_health-last_comp_duration_limit_on,
         / 'Latest completed duration threshold:',
           ls_health-last_comp_duration_limit, 'seconds',
         / 'Latest completed duration threshold breached:',
           ls_health-last_comp_duration_above_limit,
         / 'Latest completed duration minimum threshold active:',
           ls_health-last_comp_dur_min_limit_on,
         / 'Latest completed duration minimum threshold:',
           ls_health-last_comp_duration_min_limit, 'seconds',
         / 'Latest completed duration minimum threshold breached:',
           ls_health-last_comp_duration_below_limit,
         / 'Latest completed success requirement active:',
           ls_health-last_comp_success_required_on,
         / 'Latest completed success requirement breached:',
           ls_health-last_completed_success_breach,
         / 'Latest completed success streak:',
           ls_health-last_completed_success_streak,
         / 'Latest completed success streak threshold active:',
           ls_health-last_comp_succ_streak_limit_on,
         / 'Latest completed success streak threshold:',
           ls_health-last_comp_success_streak_limit,
         / 'Latest completed success streak threshold breached:',
           ls_health-last_cmp_succ_streak_below_lim,
         / 'Latest completed non-success streak:',
           ls_health-last_comp_non_success_streak,
         / 'Latest completed non-success streak threshold active:',
           ls_health-last_comp_non_success_limit_on,
         / 'Latest completed non-success streak threshold:',
           ls_health-last_comp_non_success_limit,
         / 'Latest completed non-success streak threshold breached:',
           ls_health-last_comp_non_succ_above_limit,
         / 'Average duration threshold active:', ls_health-average_duration_limit_active,
         / 'Average duration threshold:', ls_health-average_duration_threshold,
           'seconds',
         / 'Average duration threshold breached:', ls_health-average_duration_above_limit,
         / 'Maximum duration threshold active:', ls_health-maximum_duration_limit_active,
         / 'Maximum duration threshold:', ls_health-maximum_duration_threshold,
           'seconds',
         / 'Maximum duration threshold breached:', ls_health-maximum_duration_above_limit,
         / 'Duration-count threshold active:', ls_health-duration_count_limit_active,
         / 'Duration-count threshold:', ls_health-duration_count_threshold,
         / 'Duration-count threshold breached:', ls_health-duration_count_below_threshold,
         / 'Run-count threshold active:', ls_health-run_count_threshold_active,
         / 'Run-count threshold:', ls_health-run_count_threshold,
         / 'Run-count threshold breached:', ls_health-run_count_below_threshold,
         / 'Deadline-count threshold active:', ls_health-deadline_count_limit_active,
         / 'Deadline-count threshold:', ls_health-deadline_count_threshold,
         / 'Deadline-count threshold breached:', ls_health-deadline_count_below_threshold,
         / 'Deadline-mix threshold active:', ls_health-deadline_mix_threshold_active,
         / 'Deadline-mix threshold:', ls_health-deadline_mix_threshold, '%',
         / 'Deadline-mix threshold breached:', ls_health-deadline_mix_below_threshold,
         / 'Overdue-mix threshold active:', ls_health-overdue_mix_threshold_active,
         / 'Overdue-mix threshold:', ls_health-overdue_mix_threshold, '%',
         / 'Overdue-mix threshold breached:', ls_health-overdue_mix_above_threshold,
         / 'Current-day deadline-mix threshold active:', ls_health-current_deadline_mix_limit_on,
         / 'Current-day deadline-mix threshold:', ls_health-current_deadline_mix_threshold, '%',
         / 'Current-day deadline-mix threshold breached:', ls_health-curr_deadline_mix_above_limit,
         / 'Future deadline-mix threshold active:', ls_health-future_deadline_mix_limit_on,
         / 'Future deadline-mix threshold:', ls_health-future_deadline_mix_threshold, '%',
         / 'Future deadline-mix threshold breached:', ls_health-fut_deadline_mix_below_limit,
         / 'Mixed-policy warning active:', ls_health-mixed_policy_warning_active,
         / 'Mixed-policy warning breached:', ls_health-mixed_policy_breach,
         / 'Mixed-unit warning active:', ls_health-mixed_unit_warning_active,
         / 'Mixed-unit warning breached:', ls_health-mixed_unit_breach,
         / 'Completion threshold active:', ls_health-completion_threshold_active,
         / 'Completion threshold:', ls_health-completion_threshold, '%',
         / 'Completion threshold breached:', ls_health-completion_below_threshold,
         / 'Success threshold active:', ls_health-success_threshold_active,
         / 'Success threshold:', ls_health-success_threshold, '%',
         / 'Success threshold breached:', ls_health-success_below_threshold,
         / 'Success-count threshold active:', ls_health-success_count_threshold_active,
         / 'Success-count threshold:', ls_health-success_count_threshold,
         / 'Success-count threshold breached:', ls_health-success_count_below_threshold,
         / 'Error threshold active:', ls_health-error_threshold_active,
         / 'Error threshold:', ls_health-error_threshold, '%',
         / 'Error threshold breached:', ls_health-error_above_threshold,
         / 'Partial threshold active:', ls_health-partial_threshold_active,
         / 'Partial threshold:', ls_health-partial_threshold, '%',
         / 'Partial threshold breached:', ls_health-partial_above_threshold,
         / 'Full-line threshold active:', ls_health-full_line_threshold_active,
         / 'Full-line threshold:', ls_health-full_line_threshold, '%',
         / 'Full-line threshold breached:', ls_health-full_line_below_threshold,
         / 'Unallocated-line threshold active:', ls_health-unallocated_line_limit_active,
         / 'Unallocated-line threshold:', ls_health-unallocated_line_threshold, '%',
         / 'Unallocated-line threshold breached:', ls_health-unallocated_line_above_limit,
         / 'Partial-line threshold active:', ls_health-partial_line_threshold_active,
         / 'Partial-line threshold:', ls_health-partial_line_threshold, '%',
         / 'Partial-line threshold breached:', ls_health-partial_line_above_threshold,
         / 'Full-count threshold active:', ls_health-full_count_threshold_active,
         / 'Full-count threshold:', ls_health-full_count_threshold,
         / 'Full-count threshold breached:', ls_health-full_count_below_threshold,
         / 'Demand-count threshold active:', ls_health-demand_count_threshold_active,
         / 'Demand-count threshold:', ls_health-demand_count_threshold,
         / 'Demand-count threshold breached:', ls_health-demand_count_above_threshold,
         / 'Running-count threshold active:', ls_health-running_count_threshold_active,
         / 'Running-count threshold:', ls_health-running_count_threshold,
         / 'Running-count threshold breached:', ls_health-running_count_above_threshold,
         / 'Shortage-quantity threshold active:', ls_health-shortage_quantity_limit_active,
          / 'Shortage-quantity threshold:', ls_health-shortage_quantity_threshold,
          / 'Shortage-quantity threshold breached:', ls_health-shortage_quantity_above_limit,
          / 'Latest shortage-quantity threshold active:', ls_health-last_shortage_qty_limit_active,
          / 'Latest shortage-quantity threshold:', ls_health-last_shortage_qty_threshold,
          / 'Latest shortage-quantity threshold breached:', ls_health-last_shortage_qty_above_limit,
         / 'Latest shortage-percentage threshold active:', ls_health-last_shortage_pct_limit_active,
         / 'Latest shortage-percentage threshold:', ls_health-last_shortage_pct_threshold, '%',
         / 'Latest shortage-percentage threshold breached:', ls_health-last_shortage_pct_above_limit,
          / 'Latest completed coverage threshold active:', ls_health-last_comp_coverage_limit_on,
          / 'Latest completed coverage threshold:', ls_health-last_comp_coverage_limit, '%',
          / 'Latest completed coverage threshold breached:', ls_health-last_comp_coverage_below_limit,
          / 'Latest completed coverage maximum threshold active:',
            ls_health-last_comp_cov_max_limit_on,
          / 'Latest completed coverage maximum threshold:',
            ls_health-last_comp_coverage_max_limit, '%',
          / 'Latest completed coverage maximum threshold breached:',
            ls_health-last_comp_coverage_above_limit,
          / 'Latest completed shortage-percentage threshold active:',
            ls_health-last_comp_short_pct_limit_on,
          / 'Latest completed shortage-percentage threshold:', ls_health-last_comp_shortage_pct_limit, '%',
          / 'Latest completed shortage-percentage threshold breached:',
            ls_health-last_comp_short_pct_above_lim,
          / 'Latest completed shortage-quantity threshold active:',
            ls_health-last_comp_short_qty_limit_on,
          / 'Latest completed shortage-quantity threshold:',
            ls_health-last_comp_shortage_qty_limit,
          / 'Latest completed shortage-quantity threshold breached:',
            ls_health-last_comp_short_qty_above_lim,
          / 'Latest completed allocated-quantity threshold active:',
            ls_health-last_comp_allocated_limit_on,
          / 'Latest completed allocated-quantity threshold:',
            ls_health-last_comp_allocated_limit,
          / 'Latest completed allocated-quantity threshold breached:',
            ls_health-last_comp_alloc_below_limit,
          / 'Latest completed requested-quantity threshold active:',
            ls_health-last_comp_requested_limit_on,
          / 'Latest completed requested-quantity threshold:',
            ls_health-last_comp_requested_limit,
          / 'Latest completed requested-quantity threshold breached:',
            ls_health-last_comp_req_above_limit,
          / 'Latest completed requested-quantity minimum threshold active:',
            ls_health-last_comp_req_min_limit_on,
          / 'Latest completed requested-quantity minimum threshold:',
            ls_health-last_comp_requested_min_limit,
          / 'Latest completed requested-quantity minimum threshold breached:',
            ls_health-last_comp_req_below_limit,
          / 'Latest completed allocated-quantity maximum threshold active:',
            ls_health-last_comp_alloc_max_limit_on,
          / 'Latest completed allocated-quantity maximum threshold:',
            ls_health-last_comp_allocated_max_limit,
          / 'Latest completed allocated-quantity maximum threshold breached:',
            ls_health-last_comp_alloc_above_limit,
          / 'Latest completed available-stock minimum threshold active:',
            ls_health-last_comp_avail_stk_min_lim_on,
          / 'Latest completed available-stock minimum threshold:',
            ls_health-last_comp_avail_stk_min_limit,
          / 'Latest completed available-stock minimum threshold breached:',
            ls_health-last_comp_avail_stk_below_lim,
          / 'Latest completed available-stock maximum threshold active:',
            ls_health-last_comp_avail_stk_max_lim_on,
          / 'Latest completed available-stock maximum threshold:',
            ls_health-last_comp_avail_stk_max_limit,
          / 'Latest completed available-stock maximum threshold breached:',
            ls_health-last_comp_avail_stk_above_lim,
          / 'Latest completed full-line threshold active:',
            ls_health-last_comp_full_line_limit_on,
          / 'Latest completed full-line threshold:',
            ls_health-last_comp_full_line_limit, '%',
          / 'Latest completed full-line threshold breached:',
            ls_health-last_comp_full_ln_below_limit,
          / 'Latest completed full-line maximum threshold active:',
            ls_health-last_comp_full_ln_max_limit_on,
          / 'Latest completed full-line maximum threshold:',
            ls_health-last_comp_full_line_max_limit, '%',
          / 'Latest completed full-line maximum threshold breached:',
            ls_health-last_comp_full_ln_above_limit,
          / 'Latest completed unallocated-line threshold active:',
            ls_health-last_comp_unalloc_ln_limit_on,
          / 'Latest completed unallocated-line threshold:',
            ls_health-last_comp_unalloc_line_limit, '%',
          / 'Latest completed unallocated-line threshold breached:',
            ls_health-last_comp_unalloc_ln_above_lim,
          / 'Latest completed partial-line threshold active:',
            ls_health-last_comp_part_line_limit_on,
          / 'Latest completed partial-line threshold:',
            ls_health-last_comp_partial_line_limit, '%',
          / 'Latest completed partial-line threshold breached:',
            ls_health-last_comp_part_ln_above_limit,
          / 'Latest completed full-count threshold active:',
            ls_health-last_comp_full_count_limit_on,
          / 'Latest completed full-count threshold:',
            ls_health-last_comp_full_count_limit,
          / 'Latest completed full-count threshold breached:',
            ls_health-last_comp_full_cnt_below_limit,
          / 'Latest completed allocated-line-count threshold active:',
            ls_health-last_comp_alloc_count_limit_on,
          / 'Latest completed allocated-line-count threshold:',
            ls_health-last_comp_alloc_count_limit,
          / 'Latest completed allocated-line-count threshold breached:',
            ls_health-last_comp_alloc_cnt_below_lim,
          / 'Latest completed allocated-line-count maximum threshold active:',
            ls_health-last_comp_alloc_cnt_max_lim_on,
          / 'Latest completed allocated-line-count maximum threshold:',
            ls_health-last_comp_alloc_cnt_max_limit,
          / 'Latest completed allocated-line-count maximum threshold breached:',
            ls_health-last_comp_acnt_max_above_limit,
          / 'Latest completed unallocated-count threshold active:',
            ls_health-last_comp_unalloc_cnt_limit_on,
          / 'Latest completed unallocated-count threshold:',
            ls_health-last_comp_unalloc_count_limit,
          / 'Latest completed unallocated-count threshold breached:',
            ls_health-last_comp_unalloc_cnt_over_lim,
          / 'Latest completed partial-count threshold active:',
            ls_health-last_comp_partial_cnt_limit_on,
          / 'Latest completed partial-count threshold:',
            ls_health-last_comp_partial_count_limit,
          / 'Latest completed partial-count threshold breached:',
            ls_health-last_comp_part_cnt_above_limit,
          / 'Latest completed shortage-count threshold active:',
            ls_health-last_comp_short_cnt_limit_on,
          / 'Latest completed shortage-count threshold:',
            ls_health-last_comp_shortage_count_limit,
          / 'Latest completed shortage-count threshold breached:',
            ls_health-last_comp_short_cnt_above_lim,
          / 'Latest completed-age threshold active:', ls_health-last_age_threshold_active,
          / 'Latest completed-age threshold:', ls_health-last_age_threshold, 'seconds',
          / 'Latest completed-age threshold breached:', ls_health-last_age_above_threshold,
          / 'Latest completed-deadline-age threshold active:',
            ls_health-last_comp_ddl_age_limit_on,
          / 'Latest completed-deadline-age threshold:',
            ls_health-last_comp_deadline_age_limit, 'days',
          / 'Latest completed-deadline-age threshold breached:',
            ls_health-last_comp_ddl_age_above_limit,
          / 'Latest completed-demand-count threshold active:',
            ls_health-last_comp_demand_cnt_limit_on,
          / 'Latest completed-demand-count threshold:',
            ls_health-last_comp_demand_count_limit,
          / 'Latest completed-demand-count threshold breached:',
            ls_health-last_comp_demand_cnt_above_lim,
          / 'Latest completed-demand-count minimum threshold active:',
            ls_health-last_cmp_demand_cnt_min_lim_on,
          / 'Latest completed-demand-count minimum threshold:',
            ls_health-last_comp_demand_cnt_min_limit,
          / 'Latest completed-demand-count minimum threshold breached:',
            ls_health-last_comp_demand_cnt_below_lim,
          / 'Available-stock minimum threshold active:', ls_health-avail_stock_min_limit_active,
          / 'Available-stock minimum threshold:', ls_health-avail_stock_min_threshold,
          / 'Available-stock minimum threshold breached:', ls_health-avail_stock_below_threshold,
          / 'Available-stock maximum threshold active:', ls_health-avail_stock_max_limit_active,
          / 'Available-stock maximum threshold:', ls_health-avail_stock_max_threshold,
          / 'Available-stock maximum threshold breached:', ls_health-avail_stock_above_threshold,
          / 'Stale threshold active:', ls_health-stale_threshold_active,
          / 'Stale threshold seconds:', ls_health-stale_threshold,
          / 'Stale threshold breached:', ls_health-stale_above_threshold,
         / 'Threshold breach count:', ls_health-threshold_breach_count,
         / 'Threshold breaches:', ls_health-threshold_breaches.
