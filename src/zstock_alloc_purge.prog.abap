REPORT zstock_alloc_purge.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_date TYPE d OBLIGATORY.
PARAMETERS p_exec AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_alloc_retention_auth.
  DATA lv_deleted TYPE i.
  DATA lv_deleted_snapshots TYPE i.
  DATA ls_preview TYPE zif_allocation_audit=>ty_purge_preview.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

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
          iv_unit             = p_meins
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
          iv_value = 1 ) TO lt_json_fields.
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
          iv_name  = 'linked_result_snapshots'
          iv_value = ls_preview-snapshot_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'protected_running_runs'
          iv_value = ls_preview-running_count ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'eligible_audit_runs'
          iv_value = ls_preview-audit_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'linked_result_snapshots'
          iv_value = ls_preview-snapshot_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'protected_running_runs'
          iv_value = ls_preview-running_count ) TO lt_json_fields.
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
      APPEND zcl_stock_csv=>number( 1 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      WRITE p_date TO lv_csv_field.
      APPEND zcl_stock_csv=>quote( lv_csv_field ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-audit_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-snapshot_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_preview-running_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;storage_location;batch;unit;before_date;eligible_audit_runs;linked_result_snapshots;protected_running_runs;deleted_audit_runs'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.
    WRITE: / 'Preview only. No rows deleted.',
           / 'Eligible audit runs:', ls_preview-audit_count,
           / 'Linked result snapshots:', ls_preview-snapshot_count,
           / 'Protected running runs:', ls_preview-running_count,
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
          iv_unit              = p_meins
          iv_before_date       = p_date
        IMPORTING
          ev_deleted_snapshots = lv_deleted_snapshots
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
        iv_value = 2 ) TO lt_json_fields.
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
        iv_name  = 'deleted_result_snapshots'
        iv_value = lv_deleted_snapshots ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_audit_runs'
        iv_value = lv_deleted ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deleted_result_snapshots'
        iv_value = lv_deleted_snapshots ) TO lt_json_fields.
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
    APPEND zcl_stock_csv=>number( 2 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
    WRITE p_date TO lv_csv_field.
    APPEND zcl_stock_csv=>quote( lv_csv_field ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_deleted_snapshots ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;generated_date;generated_time;schema_version;material;plant;storage_location;batch;unit;before_date;eligible_audit_runs;linked_result_snapshots;protected_running_runs;deleted_audit_runs;deleted_result_snapshots'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.

  WRITE: / 'Deleted audit runs:', lv_deleted,
         / 'Deleted result snapshots:', lv_deleted_snapshots.
