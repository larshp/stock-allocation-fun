REPORT zstock_alloc_purge.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_date TYPE d OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_stat TO UPPER CASE.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_alloc_retention_auth.
  DATA lv_deleted TYPE i.
  DATA lv_deleted_snapshots TYPE i.
  DATA lv_deleted_success TYPE i.
  DATA lv_deleted_partial TYPE i.
  DATA lv_deleted_error TYPE i.
  DATA lv_protected_running TYPE i.
  DATA lv_protected_unknown TYPE i.
  DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE c LENGTH 1024.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_movement_filter TYPE string.
  DATA lv_run_filter TYPE string.
  DATA lv_min_shelf_filter TYPE string.
  DATA lv_status_filter TYPE string.
  DATA lv_filters_applied TYPE abap_bool.
  DATA lt_filter_names TYPE zcl_stock_json=>tt_strings.
  DATA lv_filter_names_text TYPE string.
  DATA lt_filter_value_fields TYPE zcl_stock_json=>tt_strings.

  lv_movement_filter = p_mvt.
  IF lv_movement_filter IS INITIAL.
    lv_movement_filter = 'n/a'.
  ENDIF.
  lv_run_filter = p_runid.
  IF lv_run_filter IS INITIAL.
    lv_run_filter = 'n/a'.
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
  CONCATENATE LINES OF lt_filter_names INTO lv_filter_names_text
    SEPARATED BY '|'.
  CLEAR lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'movement_type'
    iv_value = p_mvt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'run_id'
    iv_value = p_runid ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shelf_life'
    iv_value   = p_shelf
    iv_text    = lv_min_shelf_filter
    iv_present = xsdbool( p_shelf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'status'
    iv_value = p_stat ) TO lt_filter_value_fields.

  IF p_csv = abap_true AND p_json = abap_true.
    lv_json_line = zcl_stock_json=>error(
      'Select only one export mode: CSV or JSON' ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_purge'
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    lv_json_line = zcl_stock_json=>error(
      'Typed output requires JSON mode.' ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.

  IF p_shelf < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Minimum shelf-life filter must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_purge'
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
      lv_json_line = zcl_stock_json=>error(
        'Status filter must be S, P, or E' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_purge'
        iv_message = 'Status filter must be S, P, or E' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. Status filter must be S, P, or E.'.
    RETURN.
  ENDIF.

  IF p_date > sy-datum.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'P_DATE cannot be in the future' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_purge'
        iv_message = 'P_DATE cannot be in the future' ).
      RETURN.
    ENDIF.
    WRITE: / 'No rows deleted. P_DATE cannot be in the future.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_alloc_retention_auth_sap.
  TRY.
      lo_authority->check( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
      IF p_json = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Retention authorization is missing' ).
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
            iv_mode    = 'zstock_alloc_purge'
            iv_message = 'Retention authorization is missing' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_purge'
            iv_message = lo_auth_error->message ).
        ENDIF.
        WRITE: / 'mode;status;message'.
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
          iv_material         = p_matnr
          iv_plant            = p_werks
          iv_storage_location = p_lgort
          iv_batch            = p_charg
          iv_run_id           = p_runid
          iv_unit             = p_meins
          iv_movement_type    = p_mvt
          iv_min_shelf_life   = p_shelf
          iv_status           = p_stat
          iv_before_date      = p_date ).
      CATCH zcx_stock_allocation INTO DATA(lo_preview_error).
        IF p_json = abap_true.
          IF lo_preview_error->message IS INITIAL.
            lv_json_line = zcl_stock_json=>error(
              'Retention preview failed' ).
          ELSE.
            lv_error_message = lo_preview_error->message.
            lv_json_line = zcl_stock_json=>error(
              lv_error_message ).
          ENDIF.
          WRITE: / lv_json_line.
          RETURN.
        ENDIF.
        IF p_csv = abap_true.
          IF lo_preview_error->message IS INITIAL.
            lv_csv_line = zcl_stock_csv=>error(
              iv_mode    = 'zstock_alloc_purge'
              iv_message = 'Retention preview failed' ).
          ELSE.
            lv_csv_line = zcl_stock_csv=>error(
              iv_mode    = 'zstock_alloc_purge'
              iv_message = lo_preview_error->message ).
          ENDIF.
          WRITE: / 'mode;status;message'.
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
      ENDIF.
      IF p_typed = abap_false.
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
      APPEND zcl_stock_csv=>number( 8 ) TO lt_csv_fields.
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
      APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_status_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      WRITE p_date TO lv_csv_field.
      APPEND zcl_stock_csv=>quote( lv_csv_field ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-audit_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-success_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-error_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-snapshot_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-running_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-unknown_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / 'mode;generated_date;generated_time;schema_version;filters_applied;filters;'
        && 'material;plant;storage_location;batch;run_id_filter;movement_type_filter;'
        && 'minimum_shelf_life_filter;status_filter;unit;'
        && 'before_date;eligible_audit_runs;eligible_success_runs;eligible_partial_runs;'
        && 'eligible_error_runs;linked_result_snapshots;protected_running_runs;'
        && 'protected_unknown_runs;deleted_audit_runs'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'Filters applied:', lv_filters_applied,
           / 'Filter names:', lv_filter_names_text,
           / 'Run ID filter:', lv_run_filter,
           / 'Policy filters:', lv_movement_filter, lv_min_shelf_filter,
           / 'Status filter:', lv_status_filter,
           / 'Preview only. No rows deleted.',
           / 'Eligible audit runs:', ls_preview-audit_count,
           / 'Eligible successful runs:', ls_preview-success_count,
           / 'Eligible partial runs:', ls_preview-partial_count,
           / 'Eligible error runs:', ls_preview-error_count,
           / 'Linked result snapshots:', ls_preview-snapshot_count,
           / 'Protected running runs:', ls_preview-running_count,
           / 'Protected unknown-status runs:', ls_preview-unknown_count,
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
          iv_unit              = p_meins
          iv_movement_type     = p_mvt
          iv_min_shelf_life    = p_shelf
          iv_status            = p_stat
          iv_before_date       = p_date
        IMPORTING
          ev_deleted_snapshots = lv_deleted_snapshots
          ev_deleted_success   = lv_deleted_success
          ev_deleted_partial   = lv_deleted_partial
          ev_deleted_error     = lv_deleted_error
          ev_protected_running = lv_protected_running
          ev_protected_unknown = lv_protected_unknown
        ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Retention execution failed' ).
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
            iv_mode    = 'zstock_alloc_purge'
            iv_message = 'Retention execution failed' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error(
            iv_mode    = 'zstock_alloc_purge'
            iv_message = lo_error->message ).
        ENDIF.
        WRITE: / 'mode;status;message'.
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
        iv_value = 10 ) TO lt_json_fields.
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
    APPEND zcl_stock_csv=>number( 9 ) TO lt_csv_fields.
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
    APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_status_filter ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
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
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;filters_applied;filters;'
      && 'material;plant;storage_location;batch;run_id_filter;movement_type_filter;'
      && 'minimum_shelf_life_filter;status_filter;unit;'
      && 'before_date;eligible_audit_runs;linked_result_snapshots;protected_running_runs;'
      && 'protected_unknown_runs;deleted_audit_runs;deleted_success_runs;deleted_partial_runs;'
      && 'deleted_error_runs;deleted_result_snapshots'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

  WRITE: / 'Filters applied:', lv_filters_applied,
         / 'Filter names:', lv_filter_names_text,
         / 'Run ID filter:', lv_run_filter,
         / 'Policy filters:', lv_movement_filter, lv_min_shelf_filter,
         / 'Status filter:', lv_status_filter,
         / 'Deleted audit runs:', lv_deleted,
         / 'Deleted successful runs:', lv_deleted_success,
         / 'Deleted partial runs:', lv_deleted_partial,
         / 'Deleted error runs:', lv_deleted_error,
         / 'Deleted result snapshots:', lv_deleted_snapshots,
         / 'Protected running runs:', lv_protected_running,
         / 'Protected unknown-status runs:', lv_protected_unknown.
