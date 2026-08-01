REPORT zstock_alloc_result.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_runid TYPE zif_stock_allocation=>ty_run_id.
PARAMETERS p_stat TYPE zif_stock_allocation=>ty_allocation_status.
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
PARAMETERS p_rfrom TYPE d.
PARAMETERS p_rto TYPE d.
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
PARAMETERS p_pri AS CHECKBOX.
PARAMETERS p_date AS CHECKBOX.
PARAMETERS p_rdate AS CHECKBOX.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_cov AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_max TYPE i.
PARAMETERS p_big AS CHECKBOX.
PARAMETERS p_done AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
  DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
  DATA lv_full_count TYPE i.
  DATA lv_partial_count TYPE i.
  DATA lv_unallocated_count TYPE i.
  DATA lv_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_allocated_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_shortage_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_coverage TYPE p LENGTH 8 DECIMALS 2.
  DATA lv_line_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_line_coverage_text TYPE c LENGTH 8.
  DATA lv_csv_line TYPE string.
  DATA lv_csv_field TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_summary_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_mixed_units TYPE abap_bool.
  DATA lv_reconcile_possible TYPE abap_bool.
  DATA lv_reconcile_ok TYPE abap_bool.
  FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
  FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.
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
      IF lo_auth_error->message IS INITIAL.
        WRITE: / 'Allocation results are unavailable; read authorization is missing.'.
      ELSE.
        WRITE: / 'Allocation results are unavailable:', lo_auth_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
    EXPORTING
      io_read_authority = lo_authority.
  TRY.
      lt_demands = lo_sink->get_allocations(
        iv_material                   = p_matnr
        iv_plant                      = p_werks
        iv_storage_location           = p_lgort
        iv_batch                      = p_charg
        iv_unit                       = p_meins
        iv_run_id                     = p_runid
        iv_status                     = p_stat
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
        iv_reservation_date_from      = p_rfrom
        iv_reservation_date_to        = p_rto
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
        iv_max_rows                   = p_max
        iv_sort_by_priority           = p_pri
        iv_sort_by_requested_date     = p_date
        iv_sort_by_reservation_date   = p_rdate
        iv_sort_by_shortage           = p_shrt
        iv_sort_by_coverage           = p_cov
        iv_sort_by_requested_quantity = p_big
        iv_sort_by_allocated_quantity = p_done ).
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
      IF lo_error->message IS INITIAL.
        WRITE: / 'Allocation results are unavailable for the requested scope.'.
      ELSE.
        WRITE: / 'Allocation results are unavailable:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF lines( lt_demands ) = 0 AND p_runid IS INITIAL.
    IF p_json = abap_true.
      WRITE: / '[]'.
      RETURN.
    ENDIF.
    WRITE: / 'No allocation results found.'.
    RETURN.
  ENDIF.

  IF p_csv = abap_true.
    lv_csv_line = 'allocation_run_id;sales_document;sales_document_type;sales_item;schedule_line;requested_on;priority;allocation_unit;order_unit;requested;allocated;shortage;coverage_pct;allocation_status;reservation_id;reservation_date;reservation_movement_type;reservation_unit;order_id'.
    WRITE: / lv_csv_line.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      CLEAR: lv_line_coverage,
             lv_line_coverage_text,
             lv_csv_line,
             lv_csv_field,
             lt_csv_fields.
      IF <ls_demand>-requested > 0.
        lv_line_coverage = <ls_demand>-allocated * 100
          / <ls_demand>-requested.
        lv_line_coverage_text = lv_line_coverage.
      ELSE.
        lv_line_coverage_text = 'n/a'.
      ENDIF.
      WRITE <ls_demand>-allocation_run_id TO lv_csv_field.
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
      WRITE <ls_demand>-priority TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-allocation_unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-order_unit TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-requested TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-allocated TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      WRITE <ls_demand>-shortage TO lv_csv_field.
      APPEND lv_csv_field TO lt_csv_fields.
      APPEND lv_line_coverage_text TO lt_csv_fields.
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
             lv_requested_total,
             lv_allocated_total,
             lv_shortage_total,
             lv_summary_unit,
             lv_mixed_units,
             lv_coverage,
             lv_line_coverage_text,
             lt_json_fields.
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
        IF lv_mixed_units = abap_false.
          lv_requested_total = lv_requested_total + <ls_demand>-requested.
          lv_allocated_total = lv_allocated_total + <ls_demand>-allocated.
          lv_shortage_total = lv_shortage_total + <ls_demand>-shortage.
        ENDIF.
      ENDLOOP.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'summary' ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'result_lines'
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
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = lv_summary_unit ) TO lt_json_fields.
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
          lv_line_coverage_text = lv_coverage.
        ELSE.
          lv_line_coverage_text = 'n/a'.
        ENDIF.
        APPEND zcl_stock_json=>property(
          iv_name  = 'coverage_pct'
          iv_value = lv_line_coverage_text ) TO lt_json_fields.
      ENDIF.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
      CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    WRITE: / '['.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      CLEAR: lv_line_coverage,
             lv_line_coverage_text,
             lv_json_line,
             lt_json_fields.
      IF <ls_demand>-requested > 0.
        lv_line_coverage = <ls_demand>-allocated * 100
          / <ls_demand>-requested.
        lv_line_coverage_text = lv_line_coverage.
      ELSE.
        lv_line_coverage_text = 'n/a'.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_run_id'
        iv_value = <ls_demand>-allocation_run_id ) TO lt_json_fields.
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
      CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
      CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
      IF sy-tabix < lines( lt_demands ).
        CONCATENATE lv_json_line ',' INTO lv_json_line.
      ENDIF.
      WRITE: / lv_json_line.
    ENDLOOP.
    WRITE: / ']'.
    RETURN.
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
    IF lv_mixed_units = abap_false.
      lv_requested_total = lv_requested_total + <ls_demand>-requested.
      lv_allocated_total = lv_allocated_total + <ls_demand>-allocated.
      lv_shortage_total = lv_shortage_total + <ls_demand>-shortage.
    ENDIF.
  ENDLOOP.
  WRITE: / 'Result lines:', lines( lt_demands ),
         / 'Fully allocated:', lv_full_count,
         / 'Partially allocated:', lv_partial_count,
         / 'Unallocated:', lv_unallocated_count.
  IF lv_mixed_units = abap_true.
    WRITE: / 'Quantity totals omitted: mixed allocation units.'.
  ELSE.
    WRITE: / 'Quantity totals (', lv_summary_unit, ') requested:',
             lv_requested_total,
           / 'Allocated:', lv_allocated_total,
           'Shortage:', lv_shortage_total.
    IF lv_requested_total > 0.
      lv_coverage = lv_allocated_total * 100 / lv_requested_total.
      WRITE: / 'Allocation coverage:', lv_coverage, '%'.
    ELSE.
      WRITE: / 'Allocation coverage: n/a (no requested quantity).'.
    ENDIF.
  ENDIF.

  IF p_runid IS NOT INITIAL
      AND p_meins IS INITIAL
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
      AND p_max IS INITIAL.
    lv_reconcile_possible = abap_true.
  ENDIF.

  IF p_runid IS NOT INITIAL.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
      EXPORTING
        io_read_authority = lo_authority.
    TRY.
        lt_runs = lo_audit->get_runs(
          iv_material         = p_matnr
          iv_plant            = p_werks
          iv_storage_location = p_lgort
          iv_batch            = p_charg
          iv_run_id           = p_runid ).
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
      WRITE: / 'Run context:', <ls_run>-run_id,
               'Status:', <ls_run>-status.
      WRITE: / 'Requested from:', <ls_run>-requested_on_from,
               'through:', <ls_run>-requested_on_to,
               'Started:', <ls_run>-start_date, <ls_run>-start_time,
               'Finished:', <ls_run>-finish_date, <ls_run>-finish_time.
      WRITE: / 'Audit demand:', <ls_run>-demand_count,
               'full:', <ls_run>-full_count,
               'partial:', <ls_run>-partial_count,
               'unallocated:', <ls_run>-unallocated_count.
      WRITE: / 'Audit allocated:', <ls_run>-allocated,
               'shortage:', <ls_run>-shortage,
               'message:', <ls_run>-message.
      IF lv_reconcile_possible = abap_true.
        IF lines( lt_demands ) = <ls_run>-demand_count
            AND lv_full_count = <ls_run>-full_count
            AND lv_partial_count = <ls_run>-partial_count
            AND lv_unallocated_count = <ls_run>-unallocated_count
            AND lv_allocated_total = <ls_run>-allocated
            AND lv_shortage_total = <ls_run>-shortage.
          lv_reconcile_ok = abap_true.
        ENDIF.
        IF lv_reconcile_ok = abap_true.
          WRITE: / 'Reconciliation: OK (snapshot counts match audit).'.
        ELSE.
          WRITE: / 'Reconciliation: MISMATCH (snapshot metrics differ from audit).'.
        ENDIF.
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

  WRITE: / 'Run', 34 'Sales document', 50 'Type', 56 'Item', 64 'Schedule',
           70 'Requested on',
           84 'Priority', 94 'Alloc.unit', 106 'Order.unit', 118 'Requested', 132 'Allocated',
           146 'Shortage', 156 'Coverage', 168 'Status', 178 'Reservation', 200 'Res.date',
           212 'Res.move', 224 'Res.unit', 238 'Order ID'.
  LOOP AT lt_demands ASSIGNING <ls_demand>.
    CLEAR: lv_line_coverage,
           lv_line_coverage_text.
    IF <ls_demand>-requested > 0.
      lv_line_coverage = <ls_demand>-allocated * 100
        / <ls_demand>-requested.
      lv_line_coverage_text = lv_line_coverage.
    ELSE.
      lv_line_coverage_text = 'n/a'.
    ENDIF.
    WRITE: / <ls_demand>-allocation_run_id,
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
             168 <ls_demand>-allocation_status,
             178 <ls_demand>-reservation_id,
             200 <ls_demand>-reservation_date,
             212 <ls_demand>-reservation_movement_type,
             224 <ls_demand>-reservation_unit,
             238 <ls_demand>-order_id.
  ENDLOOP.
