REPORT zstock_alloc_purge.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_rid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_strat TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_legacy AS CHECKBOX.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_dead AS CHECKBOX.
PARAMETERS p_deadf TYPE d.
PARAMETERS p_deadt TYPE d.
PARAMETERS p_dagef TYPE i.
PARAMETERS p_daget TYPE i.
PARAMETERS p_daged TYPE d.
PARAMETERS p_tfrom TYPE i.
PARAMETERS p_tto TYPE i.
PARAMETERS p_ovrd AS CHECKBOX.
PARAMETERS p_odate TYPE d.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_from TYPE d.
PARAMETERS p_ffrom TYPE d.
PARAMETERS p_fto TYPE d.
PARAMETERS p_date TYPE d OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_stat TO UPPER CASE.
  TRANSLATE p_strat TO UPPER CASE.
  TRANSLATE p_meins TO UPPER CASE.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_alloc_retention_auth.
  DATA lv_deleted TYPE i.
  DATA lv_deleted_snapshots TYPE i.
  DATA lv_deleted_success TYPE i.
  DATA lv_deleted_partial TYPE i.
  DATA lv_deleted_error TYPE i.
  DATA lv_protected_running TYPE i.
  DATA lv_protected_unknown TYPE i.
  DATA lv_protected_reservation TYPE i.
  DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.
  DATA lv_json_line TYPE string.
  DATA lv_json_schema TYPE i.
  DATA lv_csv_schema TYPE i.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE c LENGTH 1024.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_movement_filter TYPE string.
  DATA lv_run_filter TYPE string.
  DATA lv_run_contains_filter TYPE string.
  DATA lv_min_shelf_filter TYPE string.
  DATA lv_status_filter TYPE string.
  DATA lv_strategy_filter TYPE string.
  DATA lv_legacy_strategy_filter TYPE string.
  DATA lv_message_filter TYPE string.
  DATA lv_message_only_text TYPE string.
  DATA lv_overdue_as_of_filter TYPE c LENGTH 10.
  DATA lv_requested_from_filter TYPE c LENGTH 10.
  DATA lv_requested_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_from_filter TYPE c LENGTH 10.
  DATA lv_deadline_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_age_from_filter TYPE string.
  DATA lv_deadline_age_to_filter TYPE string.
  DATA lv_deadline_age_date_filter TYPE c LENGTH 10.
  DATA lv_start_date_from_filter TYPE c LENGTH 10.
  DATA lv_finish_date_from_filter TYPE c LENGTH 10.
  DATA lv_finish_date_to_filter TYPE c LENGTH 10.
  DATA lv_duration_from_filter TYPE string.
  DATA lv_duration_to_filter TYPE string.
  DATA lv_filters_applied TYPE abap_bool.
  DATA lt_filter_names TYPE zcl_stock_json=>tt_strings.
  DATA lv_filter_names_text TYPE string.
  DATA lt_filter_value_fields TYPE zcl_stock_json=>tt_strings.

  IF p_exec = abap_true.
    lv_json_schema = 23.
    lv_csv_schema = 21.
  ELSE.
    lv_json_schema = 22.
    lv_csv_schema = 20.
  ENDIF.

  lv_movement_filter = p_mvt.
  IF lv_movement_filter IS INITIAL.
    lv_movement_filter = 'n/a'.
  ENDIF.
  lv_run_filter = p_runid.
  IF lv_run_filter IS INITIAL.
    lv_run_filter = 'n/a'.
  ENDIF.
  lv_run_contains_filter = p_rid.
  IF lv_run_contains_filter IS INITIAL.
    lv_run_contains_filter = 'n/a'.
  ENDIF.
  IF p_shelf IS INITIAL.
    lv_min_shelf_filter = 'n/a'.
  ELSE.
    lv_min_shelf_filter = zcl_stock_csv=>number( p_shelf ).
  ENDIF.
  lv_status_filter = p_stat.
  IF lv_status_filter IS INITIAL.
    lv_status_filter = 'n/a'.
  ENDIF.
  lv_strategy_filter = p_strat.
  IF lv_strategy_filter IS INITIAL.
    lv_strategy_filter = 'n/a'.
  ENDIF.
  IF p_legacy = abap_true.
    lv_legacy_strategy_filter = 'true'.
  ELSE.
    lv_legacy_strategy_filter = 'false'.
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
  IF p_odate IS INITIAL.
    lv_overdue_as_of_filter = 'n/a'.
  ELSE.
    lv_overdue_as_of_filter = p_odate.
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
  ENDIF.
  IF p_from IS INITIAL.
    lv_start_date_from_filter = 'n/a'.
  ELSE.
    lv_start_date_from_filter = p_from.
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
  IF p_tfrom IS INITIAL.
    lv_duration_from_filter = 'n/a'.
  ELSE.
    lv_duration_from_filter = zcl_stock_csv=>number( p_tfrom ).
  ENDIF.
  IF p_tto IS INITIAL.
    lv_duration_to_filter = 'n/a'.
  ELSE.
    lv_duration_to_filter = zcl_stock_csv=>number( p_tto ).
  ENDIF.

  lv_filters_applied = abap_false.
  CLEAR lt_filter_names.
  IF p_charg IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'batch' TO lt_filter_names.
  ENDIF.
  IF p_runid IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'run_id' TO lt_filter_names.
  ENDIF.
  IF p_rid IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'run_id_contains' TO lt_filter_names.
  ENDIF.
  IF p_meins IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'unit' TO lt_filter_names.
  ENDIF.
  IF p_mvt IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'movement_type' TO lt_filter_names.
  ENDIF.
  IF p_shelf IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'minimum_shelf_life' TO lt_filter_names.
  ENDIF.
  IF p_stat IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'status' TO lt_filter_names.
  ENDIF.
  IF p_strat IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'strategy' TO lt_filter_names.
  ENDIF.
  IF p_legacy = abap_true.
    lv_filters_applied = abap_true.
    APPEND 'legacy_strategy' TO lt_filter_names.
  ENDIF.
  IF p_msg IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'message' TO lt_filter_names.
  ENDIF.
  IF p_monly = abap_true.
    lv_filters_applied = abap_true.
    APPEND 'message_only' TO lt_filter_names.
  ENDIF.
  IF p_dead = abap_true.
    lv_filters_applied = abap_true.
    APPEND 'requested_deadline_only' TO lt_filter_names.
  ENDIF.
  IF p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'requested_deadline_range' TO lt_filter_names.
  ENDIF.
  IF p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'deadline_age_range' TO lt_filter_names.
  ENDIF.
  IF p_ovrd = abap_true.
    lv_filters_applied = abap_true.
    APPEND 'overdue_only' TO lt_filter_names.
  ENDIF.
  IF p_odate IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'requested_overdue_as_of' TO lt_filter_names.
  ENDIF.
  IF p_reqf IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'requested_on_from' TO lt_filter_names.
  ENDIF.
  IF p_until IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'requested_on_to' TO lt_filter_names.
  ENDIF.
  IF p_from IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'start_date_from' TO lt_filter_names.
  ENDIF.
  IF p_ffrom IS NOT INITIAL OR p_fto IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'finish_date_range' TO lt_filter_names.
  ENDIF.
  IF p_tfrom IS NOT INITIAL OR p_tto IS NOT INITIAL.
    lv_filters_applied = abap_true.
    APPEND 'audit_duration_range' TO lt_filter_names.
  ENDIF.
  CONCATENATE LINES OF lt_filter_names INTO lv_filter_names_text
    SEPARATED BY '|'.
  CLEAR lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'movement_type'
    iv_value = p_mvt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'run_id'
    iv_value = p_runid ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'run_id_contains'
    iv_value = p_rid ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shelf_life'
    iv_value   = p_shelf
    iv_text    = lv_min_shelf_filter
    iv_present = xsdbool( p_shelf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'status'
    iv_value = p_stat ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'strategy'
    iv_value = p_strat ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'legacy_strategy'
    iv_value = p_legacy ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'message'
    iv_value = lv_message_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'message_only'
    iv_value = p_monly ) TO lt_filter_value_fields.
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
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'overdue_only'
    iv_value = p_ovrd ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_overdue_as_of'
    iv_value = lv_overdue_as_of_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_on_from'
    iv_value = lv_requested_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_on_to'
    iv_value = lv_requested_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'start_date_from'
    iv_value = lv_start_date_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'finish_date_from'
    iv_value = lv_finish_date_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'finish_date_to'
    iv_value = lv_finish_date_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'audit_duration_from'
    iv_value   = p_tfrom
    iv_text    = lv_duration_from_filter
    iv_present = xsdbool( p_tfrom IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'audit_duration_to'
    iv_value   = p_tto
    iv_text    = lv_duration_to_filter
    iv_present = xsdbool( p_tto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.

  IF p_csv = abap_true AND p_json = abap_true.
    lv_json_line = zcl_stock_json=>error_with_schema(
      iv_message = 'Select only one export mode: CSV or JSON'
      iv_schema  = lv_json_schema ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    lv_json_line = zcl_stock_json=>error_with_schema(
      iv_message = 'Typed output requires JSON mode.'
      iv_schema  = lv_json_schema ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  IF p_shelf < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Minimum shelf-life filter must not be negative'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'Minimum shelf-life filter must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. Minimum shelf-life filter must not be negative.'.
    RETURN.
  ENDIF.

  IF p_stat IS NOT INITIAL
      AND p_stat <> 'S'
      AND p_stat <> 'P'
      AND p_stat <> 'E'.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Status filter must be S, P, or E'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'Status filter must be S, P, or E' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. Status filter must be S, P, or E.'.
    RETURN.
  ENDIF.
  IF p_strat IS NOT INITIAL
      AND p_strat <> 'P'
      AND p_strat <> 'F'
      AND p_strat <> 'N'
      AND p_strat <> 'S'
      AND p_strat <> 'L'
      AND p_strat <> 'B'
      AND p_strat <> 'E'
      AND p_strat <> 'A'
      AND p_strat <> 'W'.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Strategy filter must be P, F, N, S, L, B, E, A, or W'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'Strategy filter must be P, F, N, S, L, B, E, A, or W' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. Strategy filter must be P, F, N, S, L, B, E, A, or W.'.
    RETURN.
  ENDIF.
  IF p_legacy = abap_true AND p_strat IS NOT INITIAL.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Strategy filters cannot be combined'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'Strategy filters cannot be combined' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. Strategy filters cannot be combined.'.
    RETURN.
  ENDIF.

  IF p_date > sy-datum.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'P_DATE cannot be in the future'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'P_DATE cannot be in the future' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. P_DATE cannot be in the future.'.
    RETURN.
  ENDIF.
  IF p_odate IS NOT INITIAL AND p_ovrd = abap_false.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'P_ODATE requires overdue-only filtering'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'P_ODATE requires overdue-only filtering' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. P_ODATE requires overdue-only filtering.'.
    RETURN.
  ENDIF.
  IF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL AND p_reqf > p_until.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'The requested horizon start must not be after the end date'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'The requested horizon start must not be after the end date' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. The requested horizon start must not be after the end date.'.
    RETURN.
  ENDIF.
  IF p_deadf IS NOT INITIAL AND p_deadt IS NOT INITIAL
      AND p_deadf > p_deadt.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'The requested deadline start must not be after the end date'
        iv_schema  = lv_json_schema ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'The requested deadline start must not be after the end date' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. The requested deadline start must not be after the end date.'.
    RETURN.
  ENDIF.
  IF p_dagef IS NOT INITIAL AND p_daget IS NOT INITIAL
      AND p_dagef > p_daget.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'The deadline age start must not be after the end age'
        iv_schema  = lv_json_schema ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'The deadline age start must not be after the end age' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. The deadline age start must not be after the end age.'.
    RETURN.
  ENDIF.
  IF p_daged IS NOT INITIAL
      AND p_dagef IS INITIAL
      AND p_daget IS INITIAL.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'A deadline age as-of date requires a deadline age range'
        iv_schema  = lv_json_schema ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'A deadline age as-of date requires a deadline age range' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. A deadline age as-of date requires a deadline age range.'.
    RETURN.
  ENDIF.
  IF p_ffrom IS NOT INITIAL AND p_fto IS NOT INITIAL
      AND p_ffrom > p_fto.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error_with_schema(
        iv_message = 'The finish date start must not be after the end date'
        iv_schema  = lv_json_schema ).
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'The finish date start must not be after the end date' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. The finish date start must not be after the end date.'
      .
    RETURN.
  ENDIF.
  IF p_tfrom < 0 OR p_tto < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Duration bounds must not be negative'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'Duration bounds must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. Duration bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_tfrom IS NOT INITIAL AND p_tto IS NOT INITIAL
      AND p_tfrom > p_tto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'The duration start must not be after the end value'
        iv_schema  = lv_json_schema ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_alloc_purge'
        iv_schema  = lv_csv_schema
        iv_message = 'The duration start must not be after the end value' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. The duration start must not be after the end value.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_alloc_retention_auth_sap.
  TRY.
      lo_authority->check( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
      IF p_json = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = 'Retention authorization is missing'
            iv_schema  = lv_json_schema ).
        ELSE.
          lv_error_message = lo_auth_error->message.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = lv_error_message
            iv_schema  = lv_json_schema ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_alloc_purge'
            iv_schema  = lv_csv_schema
            iv_message = 'Retention authorization is missing' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_alloc_purge'
            iv_schema  = lv_csv_schema
            iv_message = lo_auth_error->message ).
        ENDIF.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_auth_error->message IS INITIAL.
        WRITE: / 'No rows deleted. Retention authorization is missing.'.
      ELSE.
        WRITE: / 'No rows deleted. Retention authorization failed:',
                 lo_auth_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_retention_authority = lo_authority.
  IF p_exec <> abap_true.
    TRY.
        ls_preview = lo_audit->get_purge_preview(
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_run_id            = p_runid
          iv_run_id_contains   = p_rid
          iv_unit              = p_meins
          iv_movement_type     = p_mvt
          iv_min_shelf_life    = p_shelf
          iv_status            = p_stat
          iv_strategy          = p_strat
          iv_legacy_strategy   = p_legacy
          iv_message_contains  = p_msg
          iv_message_only      = p_monly
          iv_deadline_only     = p_dead
          iv_deadline_from     = p_deadf
          iv_deadline_to       = p_deadt
          iv_deadline_age_from = p_dagef
          iv_deadline_age_to   = p_daget
          iv_deadline_age_date = p_daged
          iv_overdue_only      = p_ovrd
          iv_overdue_date      = p_odate
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until
          iv_start_date_from   = p_from
          iv_finish_date_from  = p_ffrom
          iv_finish_date_to    = p_fto
          iv_duration_from     = p_tfrom
          iv_duration_to       = p_tto
          iv_before_date       = p_date ).
      CATCH zcx_stock_allocation INTO DATA(lo_preview_error).
        IF p_json = abap_true.
          IF lo_preview_error->message IS INITIAL.
            lv_json_line = zcl_stock_json=>error_with_schema(
              iv_message = 'Retention preview failed'
              iv_schema  = lv_json_schema ).
          ELSE.
            lv_error_message = lo_preview_error->message.
            lv_json_line = zcl_stock_json=>error_with_schema(
              iv_message = lv_error_message
              iv_schema  = lv_json_schema ).
          ENDIF.
          WRITE: / lv_json_line.
          RETURN.
        ENDIF.
        IF p_csv = abap_true.
          IF lo_preview_error->message IS INITIAL.
            lv_csv_line = zcl_stock_csv=>error_with_schema(
              iv_mode    = 'zstock_alloc_purge'
              iv_schema  = lv_csv_schema
              iv_message = 'Retention preview failed' ).
          ELSE.
            lv_csv_line = zcl_stock_csv=>error_with_schema(
              iv_mode    = 'zstock_alloc_purge'
              iv_schema  = lv_csv_schema
              iv_message = lo_preview_error->message ).
          ENDIF.
          WRITE: / 'mode;status;schema_version;message'.
          WRITE: / lv_csv_line.
          RETURN.
        ENDIF.
        IF lo_preview_error->message IS INITIAL.
          WRITE: / 'Preview unavailable. No rows deleted.'.
        ELSE.
          WRITE: / 'Preview unavailable. No rows deleted:',
                   lo_preview_error->message.
        ENDIF.
        RETURN.
    ENDTRY.
    IF p_json = abap_true.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 22 ) TO lt_json_fields.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = abap_true ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_date'
          iv_value = sy-datum ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_time'
          iv_value = sy-uzeit ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_false.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'schema_version'
          iv_value = 22 ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_date'
          iv_value = sy-datum ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'generated_time'
          iv_value = sy-uzeit ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'preview' ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'filters_applied'
        iv_value = lv_filters_applied ) TO lt_json_fields.
      APPEND zcl_stock_json=>string_array_property(
        iv_name   = 'filters'
        it_values = lt_filter_names ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>object_property(
          iv_name   = 'filter_values'
          it_fields = lt_filter_value_fields ) TO lt_json_fields.
      ENDIF.
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
        iv_value = lv_run_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id_contains_filter'
        iv_value = lv_run_contains_filter ) TO lt_json_fields.
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
      APPEND zcl_stock_json=>property(
        iv_name  = 'status_filter'
        iv_value = lv_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'strategy_filter'
        iv_value = lv_strategy_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'legacy_strategy_filter'
        iv_value = p_legacy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'message_filter'
        iv_value = lv_message_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'message_only'
        iv_value = p_monly ) TO lt_json_fields.
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
        iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'deadline_age_to_filter'
        iv_value   = p_daget
        iv_text    = lv_deadline_age_to_filter
        iv_present = xsdbool( p_daget IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_date_filter'
        iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'overdue_only'
        iv_value = p_ovrd ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_overdue_as_of'
        iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from_filter'
        iv_value = lv_requested_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to_filter'
        iv_value = lv_requested_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'start_date_from_filter'
        iv_value = lv_start_date_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'finish_date_from_filter'
        iv_value = lv_finish_date_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'finish_date_to_filter'
        iv_value = lv_finish_date_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'audit_duration_from_filter'
        iv_value   = p_tfrom
        iv_text    = lv_duration_from_filter
        iv_present = xsdbool( p_tfrom IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'audit_duration_to_filter'
        iv_value   = p_tto
        iv_text    = lv_duration_to_filter
        iv_present = xsdbool( p_tto IS NOT INITIAL )
        iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = p_meins ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'before_date'
        iv_value = p_date ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'eligible_audit_runs'
          iv_value = ls_preview-audit_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'eligible_success_runs'
          iv_value = ls_preview-success_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'eligible_partial_runs'
          iv_value = ls_preview-partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'eligible_error_runs'
          iv_value = ls_preview-error_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'linked_result_snapshots'
          iv_value = ls_preview-snapshot_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'protected_running_runs'
          iv_value = ls_preview-running_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'protected_unknown_runs'
          iv_value = ls_preview-unknown_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'protected_reservation_runs'
          iv_value = ls_preview-reserved_count ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'eligible_audit_runs'
          iv_value = ls_preview-audit_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'eligible_success_runs'
          iv_value = ls_preview-success_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'eligible_partial_runs'
          iv_value = ls_preview-partial_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'eligible_error_runs'
          iv_value = ls_preview-error_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'linked_result_snapshots'
          iv_value = ls_preview-snapshot_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'protected_running_runs'
          iv_value = ls_preview-running_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'protected_unknown_runs'
          iv_value = ls_preview-unknown_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'protected_reservation_runs'
          iv_value = ls_preview-reserved_count ) TO lt_json_fields.
      ENDIF.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
      CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'preview' ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 20 ) TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND lv_filter_names_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_run_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_run_contains_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_status_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_strategy_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_legacy_strategy_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_message_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_message_only_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_dead ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_date_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_overdue_as_of_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_start_date_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_finish_date_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_finish_date_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_duration_to_filter ) TO lt_csv_fields.
      WRITE p_date TO lv_csv_field.
      APPEND zcl_stock_csv=>quote( lv_csv_field ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-audit_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-success_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-error_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-snapshot_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-running_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-unknown_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_preview-reserved_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / 'mode;generated_date;generated_time;schema_version;filters_applied;filters;'
        && 'material;plant;storage_location;batch;run_id_filter;run_id_contains_filter;movement_type_filter;'
        && 'minimum_shelf_life_filter;status_filter;strategy_filter;'
        && 'legacy_strategy_filter;message_filter;message_only;unit;'
        && 'requested_deadline_only;requested_deadline_from_filter;requested_deadline_to_filter;'
        && 'deadline_age_from_filter;deadline_age_to_filter;deadline_age_date_filter;'
        && 'overdue_only;requested_overdue_as_of;requested_on_from_filter;'
        && 'requested_on_to_filter;start_date_from_filter;finish_date_from_filter;'
        && 'finish_date_to_filter;audit_duration_from_filter;audit_duration_to_filter;'
        && 'before_date;eligible_audit_runs;eligible_success_runs;eligible_partial_runs;'
        && 'eligible_error_runs;linked_result_snapshots;protected_running_runs;'
        && 'protected_unknown_runs;protected_reservation_runs;deleted_audit_runs'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'Filters applied:', lv_filters_applied,
           / 'Filter names:', lv_filter_names_text,
           / 'Run ID filter:', lv_run_filter,
           / 'Run ID contains filter:', lv_run_contains_filter,
           / 'Policy filters:', lv_movement_filter, lv_min_shelf_filter,
           / 'Status filter:', lv_status_filter,
           / 'Strategy filter:', lv_strategy_filter,
           / 'Legacy strategy filter:', lv_legacy_strategy_filter,
           / 'Message filter:', lv_message_filter,
           / 'Message only:', lv_message_only_text,
           / 'Requested-deadline-only filter:', p_dead,
           / 'Requested deadline from:', lv_deadline_from_filter,
           / 'Requested deadline to:', lv_deadline_to_filter,
           / 'Deadline age from:', lv_deadline_age_from_filter,
           / 'Deadline age to:', lv_deadline_age_to_filter,
           / 'Deadline age as-of date:', lv_deadline_age_date_filter,
           / 'Overdue-only filter:', p_ovrd,
           / 'Overdue as-of date:', lv_overdue_as_of_filter,
           / 'Requested horizon from:', lv_requested_from_filter,
           / 'Requested horizon to:', lv_requested_to_filter,
           / 'Start date from:', lv_start_date_from_filter,
           / 'Finish date from:', lv_finish_date_from_filter,
           / 'Finish date to:', lv_finish_date_to_filter,
           / 'Audit duration from:', lv_duration_from_filter,
           / 'Audit duration to:', lv_duration_to_filter,
           / 'Preview only. No rows deleted.',
           / 'Eligible audit runs:', ls_preview-audit_count,
           / 'Eligible successful runs:', ls_preview-success_count,
           / 'Eligible partial runs:', ls_preview-partial_count,
           / 'Eligible error runs:', ls_preview-error_count,
           / 'Linked result snapshots:', ls_preview-snapshot_count,
           / 'Protected running runs:', ls_preview-running_count,
           / 'Protected unknown-status runs:', ls_preview-unknown_count,
           / 'Protected reservation runs:', ls_preview-reserved_count,
           / 'Select P_EXEC to execute retention.'.
    RETURN.
  ENDIF.
  TRY.
      lv_deleted = lo_audit->purge_runs_before(
        EXPORTING
          iv_material          = p_matnr
          iv_plant             = p_werks
          iv_storage_location  = p_lgort
          iv_batch             = p_charg
          iv_run_id            = p_runid
          iv_run_id_contains   = p_rid
          iv_unit              = p_meins
          iv_movement_type     = p_mvt
          iv_min_shelf_life    = p_shelf
          iv_status            = p_stat
          iv_strategy          = p_strat
          iv_legacy_strategy   = p_legacy
          iv_message_contains  = p_msg
          iv_message_only      = p_monly
          iv_deadline_only     = p_dead
          iv_deadline_from     = p_deadf
          iv_deadline_to       = p_deadt
          iv_deadline_age_from = p_dagef
          iv_deadline_age_to   = p_daget
          iv_deadline_age_date = p_daged
          iv_overdue_only      = p_ovrd
          iv_overdue_date      = p_odate
          iv_requested_on_from = p_reqf
          iv_requested_on_to   = p_until
          iv_start_date_from   = p_from
          iv_finish_date_from  = p_ffrom
          iv_finish_date_to    = p_fto
          iv_duration_from     = p_tfrom
          iv_duration_to       = p_tto
          iv_before_date       = p_date
        IMPORTING
          ev_deleted_snapshots = lv_deleted_snapshots
          ev_deleted_success   = lv_deleted_success
          ev_deleted_partial   = lv_deleted_partial
          ev_deleted_error     = lv_deleted_error
          ev_protected_running = lv_protected_running
          ev_protected_unknown = lv_protected_unknown
          ev_reserved_runs     = lv_protected_reservation
        ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = 'Retention execution failed'
            iv_schema  = lv_json_schema ).
        ELSE.
          lv_error_message = lo_error->message.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = lv_error_message
            iv_schema  = lv_json_schema ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_alloc_purge'
            iv_schema  = lv_csv_schema
            iv_message = 'Retention execution failed' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_alloc_purge'
            iv_schema  = lv_csv_schema
            iv_message = lo_error->message ).
        ENDIF.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_error->message IS INITIAL.
        WRITE: / 'No rows deleted. Retention execution failed.'.
      ELSE.
        WRITE: / 'No rows deleted. Retention execution failed:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_json = abap_true.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 23 ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'typed'
        iv_value = abap_true ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
    ENDIF.
    IF p_typed = abap_false.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 23 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'mode'
      iv_value = 'execute' ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'filters_applied'
      iv_value = lv_filters_applied ) TO lt_json_fields.
    APPEND zcl_stock_json=>string_array_property(
      iv_name   = 'filters'
      it_values = lt_filter_names ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_filter_value_fields ) TO lt_json_fields.
    ENDIF.
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
      iv_value = lv_run_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'run_id_contains_filter'
      iv_value = lv_run_contains_filter ) TO lt_json_fields.
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
    APPEND zcl_stock_json=>property(
      iv_name  = 'status_filter'
      iv_value = lv_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
      iv_name  = 'strategy_filter'
      iv_value = lv_strategy_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'legacy_strategy_filter'
      iv_value = p_legacy ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'message_filter'
      iv_value = lv_message_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'message_only'
      iv_value = p_monly ) TO lt_json_fields.
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
      iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'deadline_age_to_filter'
      iv_value   = p_daget
      iv_text    = lv_deadline_age_to_filter
      iv_present = xsdbool( p_daget IS NOT INITIAL )
      iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_age_date_filter'
      iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>boolean_property(
      iv_name  = 'overdue_only'
      iv_value = p_ovrd ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_overdue_as_of'
      iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_from_filter'
      iv_value = lv_requested_from_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_to_filter'
      iv_value = lv_requested_to_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'start_date_from_filter'
      iv_value = lv_start_date_from_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'finish_date_from_filter'
      iv_value = lv_finish_date_from_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'finish_date_to_filter'
      iv_value = lv_finish_date_to_filter ) TO lt_json_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'audit_duration_from_filter'
      iv_value   = p_tfrom
      iv_text    = lv_duration_from_filter
      iv_present = xsdbool( p_tfrom IS NOT INITIAL )
      iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'audit_duration_to_filter'
      iv_value   = p_tto
      iv_text    = lv_duration_to_filter
      iv_present = xsdbool( p_tto IS NOT INITIAL )
      iv_typed   = xsdbool( p_typed = abap_true ) ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'unit'
      iv_value = p_meins ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'before_date'
      iv_value = p_date ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'deleted_audit_runs'
        iv_value = lv_deleted ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'deleted_success_runs'
        iv_value = lv_deleted_success ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'deleted_partial_runs'
        iv_value = lv_deleted_partial ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'deleted_error_runs'
        iv_value = lv_deleted_error ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'deleted_result_snapshots'
        iv_value = lv_deleted_snapshots ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'protected_running_runs'
        iv_value = lv_protected_running ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'protected_unknown_runs'
        iv_value = lv_protected_unknown ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'protected_reservation_runs'
        iv_value = lv_protected_reservation ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_audit_runs'
        iv_value = lv_deleted ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_success_runs'
        iv_value = lv_deleted_success ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_partial_runs'
        iv_value = lv_deleted_partial ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_error_runs'
        iv_value = lv_deleted_error ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_result_snapshots'
        iv_value = lv_deleted_snapshots ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'protected_running_runs'
        iv_value = lv_protected_running ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'protected_unknown_runs'
        iv_value = lv_protected_unknown ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'protected_reservation_runs'
        iv_value = lv_protected_reservation ) TO lt_json_fields.
    ENDIF.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( 21 ) TO lt_csv_fields.
    IF lv_filters_applied = abap_true.
      APPEND 'true' TO lt_csv_fields.
    ELSE.
      APPEND 'false' TO lt_csv_fields.
    ENDIF.
    APPEND lv_filter_names_text TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_run_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_run_contains_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_status_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_strategy_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_legacy_strategy_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_message_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_message_only_text ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_dead ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_from_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_to_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_age_from_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_age_to_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_deadline_age_date_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_overdue_as_of_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_requested_from_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_requested_to_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_start_date_from_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_finish_date_from_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_finish_date_to_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_duration_from_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_duration_to_filter ) TO lt_csv_fields.
    WRITE p_date TO lv_csv_field.
    APPEND zcl_stock_csv=>quote( lv_csv_field ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted_success ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted_partial ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted_error ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted_snapshots ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_protected_running ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_protected_unknown ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_protected_reservation ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;filters_applied;filters;'
      && 'material;plant;storage_location;batch;run_id_filter;run_id_contains_filter;movement_type_filter;'
      && 'minimum_shelf_life_filter;status_filter;strategy_filter;'
      && 'legacy_strategy_filter;message_filter;message_only;unit;'
      && 'requested_deadline_only;requested_deadline_from_filter;requested_deadline_to_filter;'
      && 'deadline_age_from_filter;deadline_age_to_filter;deadline_age_date_filter;'
      && 'overdue_only;requested_overdue_as_of;requested_on_from_filter;'
      && 'requested_on_to_filter;start_date_from_filter;finish_date_from_filter;'
      && 'finish_date_to_filter;audit_duration_from_filter;audit_duration_to_filter;'
      && 'before_date;eligible_audit_runs;linked_result_snapshots;protected_running_runs;'
      && 'protected_unknown_runs;protected_reservation_runs;deleted_audit_runs;'
      && 'deleted_success_runs;deleted_partial_runs;'
      && 'deleted_error_runs;deleted_result_snapshots'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

  WRITE: / 'Filters applied:', lv_filters_applied,
         / 'Filter names:', lv_filter_names_text,
         / 'Run ID filter:', lv_run_filter,
         / 'Run ID contains filter:', lv_run_contains_filter,
         / 'Policy filters:', lv_movement_filter, lv_min_shelf_filter,
         / 'Status filter:', lv_status_filter,
         / 'Strategy filter:', lv_strategy_filter,
         / 'Legacy strategy filter:', lv_legacy_strategy_filter,
         / 'Message filter:', lv_message_filter,
         / 'Message only:', lv_message_only_text,
         / 'Requested-deadline-only filter:', p_dead,
         / 'Requested deadline from:', lv_deadline_from_filter,
         / 'Requested deadline to:', lv_deadline_to_filter,
         / 'Deadline age from:', lv_deadline_age_from_filter,
         / 'Deadline age to:', lv_deadline_age_to_filter,
         / 'Deadline age as-of date:', lv_deadline_age_date_filter,
         / 'Overdue-only filter:', p_ovrd,
         / 'Overdue as-of date:', lv_overdue_as_of_filter,
         / 'Requested horizon from:', lv_requested_from_filter,
         / 'Requested horizon to:', lv_requested_to_filter,
         / 'Start date from:', lv_start_date_from_filter,
         / 'Finish date from:', lv_finish_date_from_filter,
         / 'Finish date to:', lv_finish_date_to_filter,
         / 'Audit duration from:', lv_duration_from_filter,
         / 'Audit duration to:', lv_duration_to_filter,
         / 'Deleted audit runs:', lv_deleted,
         / 'Deleted successful runs:', lv_deleted_success,
         / 'Deleted partial runs:', lv_deleted_partial,
         / 'Deleted error runs:', lv_deleted_error,
         / 'Deleted result snapshots:', lv_deleted_snapshots,
         / 'Protected running runs:', lv_protected_running,
         / 'Protected unknown-status runs:', lv_protected_unknown.
  WRITE: / 'Protected reservation runs:', lv_protected_reservation.
