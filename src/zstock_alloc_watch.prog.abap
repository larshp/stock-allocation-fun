REPORT zstock_alloc_watch.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_stale TYPE i DEFAULT 3600.
PARAMETERS p_max TYPE i.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.

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
  DATA lv_strategy_filter TYPE string.
  DATA lv_run_filter TYPE string.
  DATA lv_message_filter TYPE string.
  DATA lv_message_only_text TYPE string.
  DATA lv_shortage_filter TYPE string.
  DATA lv_coverage_filter TYPE string.
  DATA lv_run_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_sort_mode TYPE string.
  DATA lv_total_available TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_allocated TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_shortage TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_total_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_oldest_age TYPE i.
  DATA lv_newest_age TYPE i.
  DATA lv_total_coverage_text TYPE string.
  DATA lv_oldest_age_text TYPE string.
  DATA lv_newest_age_text TYPE string.
  DATA lv_candidate_count TYPE i.
  DATA lv_limited TYPE abap_bool.
  DATA lv_limited_text TYPE string.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

  DATA lt_alerts TYPE zcl_stock_allocation_watch=>tt_alerts.
  FIELD-SYMBOLS <ls_alert> TYPE zcl_stock_allocation_watch=>ty_alert.

  TRANSLATE p_strat TO UPPER CASE.
  lv_strategy_filter = p_strat.
  IF lv_strategy_filter IS INITIAL.
    lv_strategy_filter = 'n/a'.
  ENDIF.
  lv_run_filter = p_runid.
  IF lv_run_filter IS INITIAL.
    lv_run_filter = 'n/a'.
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
  IF p_shf IS INITIAL.
    lv_shortage_filter = 'n/a'.
  ELSE.
    lv_shortage_filter = zcl_stock_csv=>number( p_shf ).
  ENDIF.
  IF p_covt IS INITIAL.
    lv_coverage_filter = 'n/a'.
  ELSE.
    lv_coverage_filter = zcl_stock_csv=>number( p_covt ).
  ENDIF.
  IF p_shrt = abap_true.
    lv_sort_mode = 'shortage'.
  ELSE.
    lv_sort_mode = 'age'.
  ENDIF.
  IF p_csv = abap_true AND p_json = abap_true.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error(
        'Select only one export mode: CSV or JSON' ).
    ELSE.
      WRITE: / 'Select only one export mode: CSV or JSON.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_stale < 0.
    lv_error_message = 'Stale-running threshold must not be negative'.
  ELSEIF p_max < 0.
    lv_error_message = 'Maximum rows must not be negative'.
  ELSEIF p_shf < 0.
    lv_error_message = 'Minimum shortage must not be negative'.
  ELSEIF p_covt < 0 OR p_covt > 100.
    lv_error_message = 'Maximum coverage must be between 0 and 100'.
  ELSEIF p_strat IS NOT INITIAL
      AND p_strat <> 'P'
      AND p_strat <> 'F'
      AND p_strat <> 'N'
      AND p_strat <> 'S'
      AND p_strat <> 'L'
      AND p_strat <> 'B'.
    lv_error_message = 'Watch strategy is invalid'.
  ENDIF.
  IF lv_error_message IS NOT INITIAL.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_watch'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
  TRY.
      lt_runs = lo_audit->get_runs(
        EXPORTING
          iv_material         = p_matnr
          iv_plant            = p_werks
          iv_storage_location = p_lgort
          iv_batch            = p_charg
          iv_unit             = p_meins
          iv_strategy         = p_strat
          iv_run_id           = p_runid
          iv_message_contains = p_msg
          iv_message_only     = p_monly
          iv_status           = 'R'
        IMPORTING
          ev_total_rows       = lv_total_rows ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      lv_error_message = lo_error->message.
      IF lv_error_message IS INITIAL.
        lv_error_message = 'Audit run read failed'.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_watch'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  LOOP AT lt_runs ASSIGNING <ls_run>.
    lv_run_age = lo_audit->get_running_age( is_run = <ls_run> ).
    CLEAR lv_run_coverage.
    IF <ls_run>-requested > 0.
      lv_run_coverage = <ls_run>-allocated * 100 / <ls_run>-requested.
    ENDIF.
    IF lv_run_age-available = abap_true
        AND lv_run_age-seconds >= p_stale
        AND ( p_shf IS INITIAL OR <ls_run>-shortage >= p_shf )
        AND ( p_covt IS INITIAL
          OR ( <ls_run>-requested > 0 AND lv_run_coverage <= p_covt ) ).
      APPEND VALUE #(
        run_id       = <ls_run>-run_id
        strategy     = <ls_run>-strategy
        unit         = <ls_run>-unit
        start_date   = <ls_run>-start_date
        start_time   = <ls_run>-start_time
        age_seconds  = lv_run_age-seconds
        available    = <ls_run>-available
        requested    = <ls_run>-requested
        allocated    = <ls_run>-allocated
        shortage     = <ls_run>-shortage
        demand_count = <ls_run>-demand_count
        message      = <ls_run>-message ) TO lt_alerts.
    ENDIF.
  ENDLOOP.

  lv_candidate_count = lines( lt_alerts ).
  IF p_max > 0 AND lv_candidate_count > p_max.
    lv_limited = abap_true.
    lv_limited_text = 'true'.
  ELSE.
    lv_limited = abap_false.
    lv_limited_text = 'false'.
  ENDIF.

  zcl_stock_allocation_watch=>sort_and_limit(
    EXPORTING
      iv_sort_by_shortage = p_shrt
      iv_max              = p_max
    CHANGING
      ct_alerts           = lt_alerts ).

  LOOP AT lt_alerts ASSIGNING <ls_alert>.
    lv_total_available = lv_total_available + <ls_alert>-available.
    lv_total_requested = lv_total_requested + <ls_alert>-requested.
    lv_total_allocated = lv_total_allocated + <ls_alert>-allocated.
    lv_total_shortage = lv_total_shortage + <ls_alert>-shortage.
    IF sy-tabix = 1 OR <ls_alert>-age_seconds > lv_oldest_age.
      lv_oldest_age = <ls_alert>-age_seconds.
    ENDIF.
    IF sy-tabix = 1 OR <ls_alert>-age_seconds < lv_newest_age.
      lv_newest_age = <ls_alert>-age_seconds.
    ENDIF.
  ENDLOOP.
  IF lv_total_requested > 0.
    lv_total_coverage = lv_total_allocated * 100 / lv_total_requested.
    lv_total_coverage_text = zcl_stock_csv=>number( lv_total_coverage ).
  ELSE.
    lv_total_coverage_text = 'n/a'.
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
      WRITE: / 'schema_version;sort_mode;strategy_filter;run_id_filter;message_filter;message_only;minimum_shortage;maximum_coverage;stale_threshold_seconds;candidate_count;limited;alert_count;available;requested;allocated;shortage;coverage_pct;oldest_age_seconds;newest_age_seconds'.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>number( 11 ) TO lt_csv_fields.
      APPEND lv_sort_mode TO lt_csv_fields.
      APPEND lv_strategy_filter TO lt_csv_fields.
      APPEND lv_run_filter TO lt_csv_fields.
      APPEND lv_message_filter TO lt_csv_fields.
      APPEND lv_message_only_text TO lt_csv_fields.
      APPEND lv_shortage_filter TO lt_csv_fields.
      APPEND lv_coverage_filter TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_stale ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_candidate_count ) TO lt_csv_fields.
      APPEND lv_limited_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_alerts ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_shortage ) TO lt_csv_fields.
      APPEND lv_total_coverage_text TO lt_csv_fields.
      APPEND lv_oldest_age_text TO lt_csv_fields.
      APPEND lv_newest_age_text TO lt_csv_fields.
      LOOP AT lt_csv_fields ASSIGNING FIELD-SYMBOL(<lv_csv_field>).
        <lv_csv_field> = zcl_stock_csv=>quote( <lv_csv_field> ).
      ENDLOOP.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'schema_version;sort_mode;strategy_filter;run_id_filter;message_filter;message_only;minimum_shortage;maximum_coverage;candidate_count;limited;rank;run_id;strategy;unit;start_date;start_time;age_seconds;available;requested;allocated;shortage;demand_count;message'.
    LOOP AT lt_alerts ASSIGNING <ls_alert>.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>number( 11 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_sort_mode ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_strategy_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_run_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_message_filter ) TO lt_csv_fields.
      APPEND lv_message_only_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_coverage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_candidate_count ) TO lt_csv_fields.
      APPEND lv_limited_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( sy-tabix ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-run_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-age_seconds ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_alert>-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_alert>-message ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
    ENDLOOP.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    LOOP AT lt_alerts ASSIGNING <ls_alert>.
      lv_item = zcl_stock_json=>property(
        iv_name  = 'run_id'
        iv_value = <ls_alert>-run_id ).
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'rank'
        iv_value = sy-tabix ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'strategy'
        iv_value = <ls_alert>-strategy ).
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
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'demand_count'
        iv_value = <ls_alert>-demand_count ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      lv_field = zcl_stock_json=>property(
        iv_name  = 'message'
        iv_value = <ls_alert>-message ).
      CONCATENATE lv_item lv_field INTO lv_item SEPARATED BY ','.
      IF lv_items IS INITIAL.
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
      iv_value = 11 ).
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
      iv_name  = 'run_id_filter'
      iv_value = lv_run_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'message_filter'
      iv_value = lv_message_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>boolean_property(
      iv_name  = 'message_only'
      iv_value = p_monly ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'minimum_shortage'
      iv_value = lv_shortage_filter ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>property(
      iv_name  = 'maximum_coverage'
      iv_value = lv_coverage_filter ).
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
    lv_json_count = zcl_stock_json=>number_property(
      iv_name  = 'alert_count'
      iv_value = lines( lt_alerts ) ).
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'available'
      iv_value = lv_total_available ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'requested'
      iv_value = lv_total_requested ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'allocated'
      iv_value = lv_total_allocated ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    lv_field = zcl_stock_json=>number_property(
      iv_name  = 'shortage'
      iv_value = lv_total_shortage ).
    CONCATENATE lv_json_header lv_field INTO lv_json_header SEPARATED BY ','.
    IF lv_total_requested > 0.
      lv_field = zcl_stock_json=>number_property(
        iv_name  = 'coverage_pct'
        iv_value = lv_total_coverage ).
    ELSE.
      lv_field = zcl_stock_json=>null_property( iv_name = 'coverage_pct' ).
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
    lv_json_runs = zcl_stock_json=>property(
      iv_name  = 'scope'
      iv_value = |{ p_matnr }/{ p_werks }/{ p_lgort }| ).
    IF p_sum = abap_true.
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
         / 'Candidate alerts:', lv_candidate_count,
         / 'Limited:', lv_limited_text,
         / 'Threshold (seconds):', p_stale,
         / 'Sort mode:', lv_sort_mode,
         / 'Strategy filter:', lv_strategy_filter,
         / 'Run ID filter:', lv_run_filter,
         / 'Message filter:', lv_message_filter,
         / 'Message only:', lv_message_only_text,
         / 'Minimum shortage:', lv_shortage_filter,
         / 'Maximum coverage:', lv_coverage_filter,
         / 'Available:', lv_total_available,
         / 'Requested:', lv_total_requested,
         / 'Allocated:', lv_total_allocated,
         / 'Shortage:', lv_total_shortage,
         / 'Coverage:', lv_total_coverage_text,
         / 'Scope:', p_matnr, p_werks, p_lgort.
  IF p_sum = abap_true.
    RETURN.
  ENDIF.
  LOOP AT lt_alerts ASSIGNING <ls_alert>.
    WRITE: / 'rank', sy-tabix,
             <ls_alert>-run_id,
             'age', <ls_alert>-age_seconds,
             'strategy', <ls_alert>-strategy,
             'unit', <ls_alert>-unit,
             'shortage', <ls_alert>-shortage.
  ENDLOOP.
