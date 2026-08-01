REPORT zstock_alloc_history.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_runid TYPE zif_allocation_audit=>ty_run_id.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_stat TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_from TYPE d.
PARAMETERS p_to TYPE d.
PARAMETERS p_ffrom TYPE d.
PARAMETERS p_fto TYPE d.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_dfrom TYPE i.
PARAMETERS p_dto TYPE i.
PARAMETERS p_tfrom TYPE i.
PARAMETERS p_tto TYPE i.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_cov AS CHECKBOX.
PARAMETERS p_tdur AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_max TYPE i.
PARAMETERS p_msg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_monly AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.
  DATA lv_running_runs TYPE i.
  DATA lv_success_runs TYPE i.
  DATA lv_partial_runs TYPE i.
  DATA lv_error_runs TYPE i.
  DATA lv_full_count TYPE i.
  DATA lv_partial_count TYPE i.
  DATA lv_unallocated_count TYPE i.
  DATA lv_available_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_allocated_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_shortage_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_coverage TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_run_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_run_coverage_text TYPE c LENGTH 8.
  DATA lv_duration_seconds TYPE i.
  DATA lv_duration_text TYPE string.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_summary_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_mixed_units TYPE abap_bool.
  FIELD-SYMBOLS <lv_csv_field> TYPE string.

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

  IF p_stat IS NOT INITIAL
      AND p_stat <> 'R'
      AND p_stat <> 'S'
      AND p_stat <> 'P'
      AND p_stat <> 'E'.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Status must be R, S, P, or E' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Status must be R, S, P, or E.'.
    RETURN.
  ENDIF.
  IF p_from IS NOT INITIAL AND p_to IS NOT INITIAL AND p_from > p_to.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The start date must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'The start date must not be after the end date.'.
    RETURN.
  ENDIF.
  IF p_ffrom IS NOT INITIAL AND p_fto IS NOT INITIAL AND p_ffrom > p_fto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The finish date must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'The finish date must not be after the end date.'.
    RETURN.
  ENDIF.
  IF ( p_shf IS NOT INITIAL AND p_shf < 0 )
      OR ( p_sht IS NOT INITIAL AND p_sht < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Shortage quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Shortage quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_shf IS NOT INITIAL AND p_sht IS NOT INITIAL AND p_shf > p_sht.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Shortage quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Shortage quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_af IS NOT INITIAL AND p_af < 0 )
      OR ( p_at IS NOT INITIAL AND p_at < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Allocated quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Allocated quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_af IS NOT INITIAL AND p_at IS NOT INITIAL AND p_af > p_at.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Allocated quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Allocated quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_avf IS NOT INITIAL AND p_avf < 0 )
      OR ( p_avt IS NOT INITIAL AND p_avt < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Available quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Available quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_avf IS NOT INITIAL AND p_avt IS NOT INITIAL AND p_avf > p_avt.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Available quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Available quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_qf IS NOT INITIAL AND p_qf < 0 )
      OR ( p_qt IS NOT INITIAL AND p_qt < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Requested quantity bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Requested quantity bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_qf IS NOT INITIAL AND p_qt IS NOT INITIAL AND p_qf > p_qt.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Requested quantity start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Requested quantity start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_dfrom IS NOT INITIAL AND p_dfrom < 0 )
      OR ( p_dto IS NOT INITIAL AND p_dto < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Demand-count bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Demand-count bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_dfrom IS NOT INITIAL AND p_dto IS NOT INITIAL AND p_dfrom > p_dto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Demand-count start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Demand-count start must not be after the end value.'.
    RETURN.
  ENDIF.
  IF ( p_tfrom IS NOT INITIAL AND p_tfrom < 0 )
      OR ( p_tto IS NOT INITIAL AND p_tto < 0 ).
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Duration bounds must not be negative' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Duration bounds must not be negative.'.
    RETURN.
  ENDIF.
  IF p_tfrom IS NOT INITIAL AND p_tto IS NOT INITIAL AND p_tfrom > p_tto.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'Duration start must not be after the end value' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'Duration start must not be after the end value.'.
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
  IF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL AND p_reqf > p_until.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error(
        'The requested horizon start must not be after the end date' ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / 'The requested horizon start must not be after the end date.'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_authority TYPE zcl_allocation_read_auth_sap.
  TRY.
      lo_authority->check_audit( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
      IF p_json = abap_true.
        IF lo_auth_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'Audit read authorization is missing' ).
        ELSE.
          lv_error_message = lo_auth_error->message.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF lo_auth_error->message IS INITIAL.
        WRITE: / 'History is unavailable; read authorization is missing.'.
      ELSE.
        WRITE: / 'History is unavailable:', lo_auth_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_read_authority = lo_authority.
  TRY.
      lt_runs = lo_audit->get_runs(
        iv_material          = p_matnr
        iv_plant             = p_werks
        iv_storage_location  = p_lgort
        iv_batch             = p_charg
        iv_requested_on_from = p_reqf
        iv_requested_on_to   = p_until
        iv_run_id            = p_runid
        iv_unit              = p_meins
        iv_start_date_from   = p_from
        iv_start_date_to     = p_to
        iv_finish_date_from  = p_ffrom
        iv_finish_date_to    = p_fto
        iv_shortage_from     = p_shf
        iv_shortage_to       = p_sht
        iv_allocated_from    = p_af
        iv_allocated_to      = p_at
        iv_available_from    = p_avf
        iv_available_to      = p_avt
        iv_requested_from    = p_qf
        iv_requested_to      = p_qt
        iv_demand_from       = p_dfrom
        iv_demand_to         = p_dto
        iv_duration_from     = p_tfrom
        iv_duration_to       = p_tto
        iv_sort_by_shortage  = p_shrt
        iv_coverage_from     = p_covf
        iv_coverage_to       = p_covt
        iv_sort_by_coverage  = p_cov
        iv_sort_by_duration  = p_tdur
        iv_max_rows          = p_max
        iv_status            = p_stat
        iv_message_contains  = p_msg
        iv_message_only      = p_monly ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF p_json = abap_true.
        IF lo_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error(
            'History is unavailable for the requested scope' ).
        ELSE.
          lv_error_message = lo_error->message.
          lv_json_line = zcl_stock_json=>error( lv_error_message ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF lo_error->message IS INITIAL.
        WRITE: / 'History is unavailable for the requested scope.'.
      ELSE.
        WRITE: / 'History is unavailable:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF lines( lt_runs ) = 0.
    IF p_json = abap_true.
      WRITE: / '[]'.
      RETURN.
    ENDIF.
    WRITE: / 'No allocation runs found.'.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    lv_csv_line = 'run_id;material;plant;storage_location;batch;unit;requested_on_from;requested_on_to;available;allocated;shortage;coverage_pct;status;message;demand_count;full_count;partial_count;unallocated_count;start_date;start_time;finish_date;finish_time;duration_seconds'.
    WRITE: / lv_csv_line.
    LOOP AT lt_runs ASSIGNING <ls_run>.
      CLEAR: lv_run_coverage,
             lv_run_coverage_text,
             lv_duration_seconds,
             lv_duration_text,
             lv_csv_line,
             lv_csv_field,
             lt_csv_fields.
      IF <ls_run>-allocated + <ls_run>-shortage > 0.
        lv_run_coverage = <ls_run>-allocated * 100
          / ( <ls_run>-allocated + <ls_run>-shortage ).
        lv_run_coverage_text = lv_run_coverage.
      ELSE.
        lv_run_coverage_text = 'n/a'.
      ENDIF.
      WRITE <ls_run>-run_id TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-material TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-plant TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-storage_location TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-batch TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-requested_on_from TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-requested_on_to TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-available TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-allocated TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-shortage TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_run_coverage_text TO lt_csv_fields.
      WRITE <ls_run>-status TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-message TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-demand_count TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-full_count TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-partial_count TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-unallocated_count TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-start_date TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-start_time TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-finish_date TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_run>-finish_time TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      IF <ls_run>-finish_date IS INITIAL.
        lv_duration_text = 'n/a'.
      ELSE.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = <ls_run>-finish_date
            time1    = <ls_run>-finish_time
            date2    = <ls_run>-start_date
            time2    = <ls_run>-start_time
          IMPORTING
            res_secs = lv_duration_seconds ).
        lv_duration_text = lv_duration_seconds.
      ENDIF.
      APPEND lv_duration_text TO lt_csv_fields.
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
      CLEAR: lv_running_runs,
             lv_success_runs,
             lv_partial_runs,
             lv_error_runs,
             lv_full_count,
             lv_partial_count,
             lv_unallocated_count,
             lv_available_total,
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_summary_unit,
             lv_mixed_units,
             lv_coverage,
             lv_run_coverage_text,
             lt_json_fields.
      LOOP AT lt_runs ASSIGNING <ls_run>.
        IF lv_summary_unit IS INITIAL.
          lv_summary_unit = <ls_run>-unit.
        ELSEIF lv_summary_unit <> <ls_run>-unit.
          lv_mixed_units = abap_true.
          CLEAR: lv_available_total,
                 lv_requested_total,
                 lv_allocated_total,
                 lv_shortage_total.
        ENDIF.
        CASE <ls_run>-status.
          WHEN 'R'.
            lv_running_runs = lv_running_runs + 1.
          WHEN 'S'.
            lv_success_runs = lv_success_runs + 1.
          WHEN 'P'.
            lv_partial_runs = lv_partial_runs + 1.
          WHEN 'E'.
            lv_error_runs = lv_error_runs + 1.
        ENDCASE.
        lv_full_count = lv_full_count + <ls_run>-full_count.
        lv_partial_count = lv_partial_count + <ls_run>-partial_count.
        lv_unallocated_count = lv_unallocated_count
          + <ls_run>-unallocated_count.
        IF lv_mixed_units = abap_false.
          lv_available_total = lv_available_total + <ls_run>-available.
          lv_requested_total = lv_requested_total + <ls_run>-allocated
            + <ls_run>-shortage.
          lv_allocated_total = lv_allocated_total + <ls_run>-allocated.
          lv_shortage_total = lv_shortage_total + <ls_run>-shortage.
        ENDIF.
      ENDLOOP.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'summary' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_count'
        iv_value = lines( lt_runs ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'running_count'
        iv_value = lv_running_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'success_count'
        iv_value = lv_success_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_run_count'
        iv_value = lv_partial_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'error_count'
        iv_value = lv_error_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_count'
        iv_value = lv_full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_count'
        iv_value = lv_partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unallocated_count'
        iv_value = lv_unallocated_count ) TO lt_json_fields.
      IF lv_mixed_units = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = 'mixed' ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'available'
          iv_value = 'n/a' ) TO lt_json_fields.
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
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = lv_summary_unit ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'available'
          iv_value = lv_available_total ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'requested'
          iv_value = lv_requested_total ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'allocated'
          iv_value = lv_allocated_total ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'shortage'
          iv_value = lv_shortage_total ) TO lt_json_fields.
        IF lv_requested_total > 0.
          lv_coverage = lv_allocated_total * 100 / lv_requested_total.
          lv_run_coverage_text = lv_coverage.
        ELSE.
          lv_run_coverage_text = 'n/a'.
        ENDIF.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = lv_run_coverage_text ) TO lt_json_fields.
      ENDIF.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
      CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / '['.
    LOOP AT lt_runs ASSIGNING <ls_run>.
      CLEAR: lv_run_coverage,
             lv_run_coverage_text,
             lv_duration_seconds,
             lv_duration_text,
             lv_json_line,
             lt_json_fields.
      IF <ls_run>-allocated + <ls_run>-shortage > 0.
        lv_run_coverage = <ls_run>-allocated * 100
          / ( <ls_run>-allocated + <ls_run>-shortage ).
        lv_run_coverage_text = lv_run_coverage.
      ELSE.
        lv_run_coverage_text = 'n/a'.
      ENDIF.
      IF <ls_run>-finish_date IS INITIAL.
        lv_duration_text = 'n/a'.
      ELSE.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = <ls_run>-finish_date
            time1    = <ls_run>-finish_time
            date2    = <ls_run>-start_date
            time2    = <ls_run>-start_time
          IMPORTING
            res_secs = lv_duration_seconds ).
        lv_duration_text = lv_duration_seconds.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'run_id'
        iv_value = <ls_run>-run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = <ls_run>-material ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = <ls_run>-plant ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = <ls_run>-storage_location ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = <ls_run>-batch ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = <ls_run>-unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from'
        iv_value = <ls_run>-requested_on_from ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to'
        iv_value = <ls_run>-requested_on_to ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'available'
        iv_value = <ls_run>-available ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocated'
        iv_value = <ls_run>-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shortage'
        iv_value = <ls_run>-shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'coverage_pct'
        iv_value = lv_run_coverage_text ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'status'
        iv_value = <ls_run>-status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'message'
        iv_value = <ls_run>-message ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'demand_count'
        iv_value = <ls_run>-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_count'
        iv_value = <ls_run>-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_count'
        iv_value = <ls_run>-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unallocated_count'
        iv_value = <ls_run>-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'start_date'
        iv_value = <ls_run>-start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'start_time'
        iv_value = <ls_run>-start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'finish_date'
        iv_value = <ls_run>-finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'finish_time'
        iv_value = <ls_run>-finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'duration_seconds'
        iv_value = lv_duration_text ) TO lt_json_fields.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
      CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      IF sy-tabix < lines( lt_runs ).
        CONCATENATE lv_json_line ',' INTO lv_json_line.
      ENDIF.
      WRITE: / lv_json_line.
    ENDLOOP.
    WRITE: / ']'.
    RETURN.
  ENDIF.

  LOOP AT lt_runs ASSIGNING <ls_run>.
    IF lv_summary_unit IS INITIAL.
      lv_summary_unit = <ls_run>-unit.
    ELSEIF lv_summary_unit <> <ls_run>-unit.
      lv_mixed_units = abap_true.
      CLEAR: lv_available_total,
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total.
    ENDIF.
    CASE <ls_run>-status.
      WHEN 'R'.
        lv_running_runs = lv_running_runs + 1.
      WHEN 'S'.
        lv_success_runs = lv_success_runs + 1.
      WHEN 'P'.
        lv_partial_runs = lv_partial_runs + 1.
      WHEN 'E'.
        lv_error_runs = lv_error_runs + 1.
    ENDCASE.
    lv_full_count = lv_full_count + <ls_run>-full_count.
    lv_partial_count = lv_partial_count + <ls_run>-partial_count.
    lv_unallocated_count = lv_unallocated_count + <ls_run>-unallocated_count.
    IF lv_mixed_units = abap_false.
      lv_available_total = lv_available_total + <ls_run>-available.
      lv_requested_total = lv_requested_total + <ls_run>-allocated
        + <ls_run>-shortage.
      lv_allocated_total = lv_allocated_total + <ls_run>-allocated.
      lv_shortage_total = lv_shortage_total + <ls_run>-shortage.
    ENDIF.
  ENDLOOP.

  WRITE: / 'Filtered runs:', lines( lt_runs ),
           'Running:', lv_running_runs,
           'Success:', lv_success_runs,
           'Partial:', lv_partial_runs,
           'Errors:', lv_error_runs.
  WRITE: / 'Demand outcomes - full:', lv_full_count,
           'partial:', lv_partial_count,
           'unallocated:', lv_unallocated_count.
  IF lv_mixed_units = abap_true.
    WRITE: / 'Quantity totals omitted: mixed allocation units.'.
  ELSE.
    WRITE: / 'Quantity totals (', lv_summary_unit, ') available:',
             lv_available_total,
           / 'Allocated:', lv_allocated_total,
             'Shortage:', lv_shortage_total.
    IF lv_requested_total > 0.
      lv_coverage = lv_allocated_total * 100 / lv_requested_total.
      WRITE: / 'Allocation coverage:', lv_coverage, '%'.
    ELSE.
      WRITE: / 'Allocation coverage: n/a (no requested quantity).'.
    ENDIF.
  ENDIF.

  IF p_sum = abap_true.
    WRITE: / 'Summary-only mode: detail rows suppressed.'.
    RETURN.
  ENDIF.

  WRITE: / 'Run ID', 34 'Status', 42 'Unit', 48 'Requested from',
           68 'Requested through', 88 'Available',
           102 'Allocated', 116 'Shortage', 130 'Coverage', 142 'Demand',
           150 'Full', 158 'Partial', 168 'Unalloc.', 180 'Started',
           200 'Finished', 220 'Duration seconds'.
  LOOP AT lt_runs ASSIGNING <ls_run>.
    CLEAR: lv_run_coverage,
           lv_run_coverage_text,
           lv_duration_seconds,
           lv_duration_text.
    IF <ls_run>-allocated + <ls_run>-shortage > 0.
      lv_run_coverage = <ls_run>-allocated * 100
        / ( <ls_run>-allocated + <ls_run>-shortage ).
      lv_run_coverage_text = lv_run_coverage.
    ELSE.
      lv_run_coverage_text = 'n/a'.
    ENDIF.
    IF <ls_run>-finish_date IS INITIAL.
      lv_duration_text = 'n/a'.
    ELSE.
      cl_abap_tstmp=>td_subtract(
        EXPORTING
          date1    = <ls_run>-finish_date
          time1    = <ls_run>-finish_time
          date2    = <ls_run>-start_date
          time2    = <ls_run>-start_time
        IMPORTING
          res_secs = lv_duration_seconds ).
      lv_duration_text = lv_duration_seconds.
    ENDIF.
    WRITE: / <ls_run>-run_id,
             34 <ls_run>-status,
             42 <ls_run>-unit,
             48 <ls_run>-requested_on_from,
             68 <ls_run>-requested_on_to,
             88 <ls_run>-available,
             102 <ls_run>-allocated,
             116 <ls_run>-shortage,
             130 lv_run_coverage_text,
             142 <ls_run>-demand_count,
             150 <ls_run>-full_count,
             158 <ls_run>-partial_count,
             168 <ls_run>-unallocated_count,
             180 <ls_run>-start_date,
             <ls_run>-start_time,
             200 <ls_run>-finish_date,
             <ls_run>-finish_time,
             220 lv_duration_text.
    WRITE: / 'Message:', <ls_run>-message.
  ENDLOOP.
