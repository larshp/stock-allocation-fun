REPORT zstock_allocate.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_bwart TYPE zif_stock_allocation=>ty_movement_type DEFAULT '201'.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit DEFAULT 'EA'.
PARAMETERS p_strat TYPE c LENGTH 1 DEFAULT 'P'.
PARAMETERS p_shelf TYPE i DEFAULT 0.
PARAMETERS p_safstk TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_shg AS CHECKBOX.
PARAMETERS p_shmax TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_spg AS CHECKBOX.
PARAMETERS p_spmax TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covg AS CHECKBOX.
PARAMETERS p_covmin TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_fullg AS CHECKBOX.
PARAMETERS p_fmin TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_flg AS CHECKBOX.
PARAMETERS p_flmin TYPE i.
PARAMETERS p_mflg AS CHECKBOX.
PARAMETERS p_mflmax TYPE i.
PARAMETERS p_dg AS CHECKBOX.
PARAMETERS p_dmax TYPE i.
PARAMETERS p_qg AS CHECKBOX.
PARAMETERS p_qmax TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_ag AS CHECKBOX.
PARAMETERS p_amax TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_mg AS CHECKBOX.
PARAMETERS p_mmin TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_ilg AS CHECKBOX.
PARAMETERS p_imin TYPE i.
PARAMETERS p_lg AS CHECKBOX.
PARAMETERS p_lmax TYPE i.
PARAMETERS p_ug AS CHECKBOX.
PARAMETERS p_umax TYPE i.
PARAMETERS p_pg AS CHECKBOX.
PARAMETERS p_pmax TYPE i.
PARAMETERS p_slg AS CHECKBOX.
PARAMETERS p_slmax TYPE i.
PARAMETERS p_from TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_test AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_stock_source TYPE REF TO zif_stock_source.
  DATA lo_order_source TYPE REF TO zif_order_source.
  DATA lo_source_read_authority TYPE REF TO zif_source_read_authority.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_allocator TYPE REF TO zif_stock_allocation.
  DATA lo_reservation TYPE REF TO zif_stock_reservation.
  DATA lo_unit_converter TYPE REF TO zif_unit_conversion.
  DATA lo_lock TYPE REF TO zif_stock_allocation_lock.
  DATA lo_authority TYPE REF TO zif_stock_allocation_authority.
  DATA lo_transaction TYPE REF TO zif_allocation_transaction.
  DATA lo_read_authority TYPE REF TO zif_allocation_read_authority.
  DATA lo_write_authority TYPE REF TO zif_allocation_write_authority.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_service TYPE REF TO zcl_stock_allocation_service.
  DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
  DATA lv_requested TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_strategy TYPE string.
  DATA ls_summary TYPE zif_allocation_audit=>ty_summary.
  DATA ls_run_context TYPE zif_allocation_audit=>ty_run.
  DATA lt_run_context TYPE zif_allocation_audit=>tt_runs.
  DATA lv_last_deadline_age_days TYPE i.
  DATA lv_oldest_deadline_age_days TYPE i.
  DATA lv_newest_deadline_age_days TYPE i.
  DATA lv_last_deadline_age_text TYPE string.
  DATA lv_oldest_deadline_age_text TYPE string.
  DATA lv_newest_deadline_age_text TYPE string.
  DATA lv_last_duration_seconds TYPE i.
  DATA lv_json_line TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_csv_line TYPE string.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  lv_unit = to_upper( p_meins ).

  IF p_csv = abap_true AND p_json = abap_true.
    lv_json_line = zcl_stock_json=>error_with_schema(
      iv_message = 'Select only one export mode: CSV or JSON'
      iv_schema  = 49 ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Typed output requires JSON mode.' ).
      RETURN.
    ENDIF.
    lv_json_line = zcl_stock_json=>error_with_schema(
      iv_message = 'Typed output requires JSON mode.'
      iv_schema  = 49 ).
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.
  IF p_shmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum shortage must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum shortage must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum shortage must not be negative'.
    RETURN.
  ENDIF.
  IF p_spmax < 0 OR p_spmax > 100.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum shortage percentage must be between 0 and 100'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum shortage percentage must be between 0 and 100' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum shortage percentage must be between 0 and 100'.
    RETURN.
  ENDIF.
  IF p_covmin < 0 OR p_covmin > 100.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Minimum coverage must be between 0 and 100'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Minimum coverage must be between 0 and 100' ).
      RETURN.
    ENDIF.
    WRITE: / 'Minimum coverage must be between 0 and 100'.
    RETURN.
  ENDIF.
  IF p_fmin < 0 OR p_fmin > 100.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Minimum full-line percentage must be between 0 and 100'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Minimum full-line percentage must be between 0 and 100' ).
      RETURN.
    ENDIF.
    WRITE: / 'Minimum full-line percentage must be between 0 and 100'.
    RETURN.
  ENDIF.
  IF p_flmin < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Minimum full lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Minimum full lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Minimum full lines must not be negative'.
    RETURN.
  ENDIF.
  IF p_mflmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum full lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum full lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum full lines must not be negative'.
    RETURN.
  ENDIF.
  IF p_dmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum demand count must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum demand count must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum demand count must not be negative'.
    RETURN.
  ENDIF.
  IF p_qmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum requested quantity must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum requested quantity must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum requested quantity must not be negative'.
    RETURN.
  ENDIF.
  IF p_amax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum allocated quantity must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum allocated quantity must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum allocated quantity must not be negative'.
    RETURN.
  ENDIF.
  IF p_mmin < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Minimum allocated quantity must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Minimum allocated quantity must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Minimum allocated quantity must not be negative'.
    RETURN.
  ENDIF.
  IF p_imin < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Minimum allocated lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Minimum allocated lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Minimum allocated lines must not be negative'.
    RETURN.
  ENDIF.
  IF p_lmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum allocated lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum allocated lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum allocated lines must not be negative'.
    RETURN.
  ENDIF.
  IF p_umax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum unallocated lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum unallocated lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum unallocated lines must not be negative'.
    RETURN.
  ENDIF.
  IF p_pmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum partial lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum partial lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum partial lines must not be negative'.
    RETURN.
  ENDIF.
  IF p_slmax < 0.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Maximum shortage lines must not be negative'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Maximum shortage lines must not be negative' ).
      RETURN.
    ENDIF.
    WRITE: / 'Maximum shortage lines must not be negative'.
    RETURN.
  ENDIF.
  TRANSLATE p_strat TO UPPER CASE.
  IF p_strat <> 'P' AND p_strat <> 'F' AND p_strat <> 'N'
      AND p_strat <> 'S' AND p_strat <> 'L' AND p_strat <> 'B'
      AND p_strat <> 'E' AND p_strat <> 'A' AND p_strat <> 'W'.
    IF p_json = abap_true.
      lv_json_line = zcl_stock_json=>error_with_schema(
        iv_message = 'Allocation strategy must be P (priority), F (FIFO), N (full-only), S (smallest), L (largest),'
          && ' B (best-fit), E (fair-share), A (adaptive), or W (weighted).'
        iv_schema  = 49 ).
      WRITE: / lv_json_line.
      RETURN.
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;schema_version;message'.
      WRITE: / zcl_stock_csv=>error_with_schema(
        iv_mode    = 'zstock_allocate'
        iv_schema  = 49
        iv_message = 'Allocation strategy must be P (priority), F (FIFO), N (full-only), S (smallest), L (largest),'
          && ' B (best-fit), E (fair-share), A (adaptive), or W (weighted).' ).
      RETURN.
    ENDIF.
    WRITE: / 'Allocation strategy must be P (priority), F (FIFO), N (full-only), S (smallest), L (largest),'
      && ' B (best-fit), E (fair-share), A (adaptive), or W (weighted).'.
    RETURN.
  ENDIF.
  IF p_strat = 'F'.
    lv_strategy = 'fifo'.
  ELSEIF p_strat = 'N'.
    lv_strategy = 'full_only'.
  ELSEIF p_strat = 'S'.
    lv_strategy = 'smallest'.
  ELSEIF p_strat = 'L'.
    lv_strategy = 'largest'.
  ELSEIF p_strat = 'B'.
    lv_strategy = 'best_fit'.
  ELSEIF p_strat = 'E'.
    lv_strategy = 'fair_share'.
  ELSEIF p_strat = 'A'.
    lv_strategy = 'adaptive'.
  ELSEIF p_strat = 'W'.
    lv_strategy = 'weighted'.
  ELSE.
    lv_strategy = 'priority'.
  ENDIF.

  CREATE OBJECT lo_source_read_authority TYPE zcl_source_read_auth_sap.
  CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap
    EXPORTING
      io_authority = lo_source_read_authority.
  CREATE OBJECT lo_order_source TYPE zcl_order_source_sap
    EXPORTING
      io_authority = lo_source_read_authority.
  IF p_strat = 'F'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_fifo.
  ELSEIF p_strat = 'N'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_full.
  ELSEIF p_strat = 'S'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_small.
  ELSEIF p_strat = 'L'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_large.
  ELSEIF p_strat = 'B'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_best.
  ELSEIF p_strat = 'E'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_fair.
  ELSEIF p_strat = 'A'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_auto.
  ELSEIF p_strat = 'W'.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_weighted.
  ELSE.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
  ENDIF.
  CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
  CREATE OBJECT lo_unit_converter TYPE zcl_unit_conversion_sap.
  CREATE OBJECT lo_lock TYPE zcl_stock_allocation_lock_sap.
  CREATE OBJECT lo_authority TYPE zcl_stock_alloc_auth_sap.
  CREATE OBJECT lo_transaction TYPE zcl_allocation_transaction_sap.
  CREATE OBJECT lo_read_authority TYPE zcl_allocation_read_auth_sap.
  CREATE OBJECT lo_write_authority TYPE zcl_allocation_write_auth_sap.
  TRY.
      lo_read_authority->check_audit( ).
    CATCH zcx_stock_allocation INTO DATA(lo_read_error).
      IF p_json = abap_true.
        IF lo_read_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = 'Audit read authorization is missing'
            iv_schema  = 49 ).
        ELSE.
          lv_error_message = lo_read_error->message.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = lv_error_message
            iv_schema  = 49 ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_read_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_allocate'
            iv_schema  = 49
            iv_message = 'Audit read authorization is missing' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_allocate'
            iv_schema  = 49
            iv_message = lo_read_error->message ).
        ENDIF.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_read_error->message IS INITIAL.
        WRITE: / 'Allocation failed; audit read authorization is missing.'.
      ELSE.
        WRITE: / 'Allocation failed:', lo_read_error->message.
      ENDIF.
      RETURN.
  ENDTRY.
  TRY.
      lo_write_authority->check_audit_write( ).
      IF p_test <> abap_true.
        lo_write_authority->check_result_write( ).
        lo_write_authority->check_result_delete( ).
      ENDIF.
    CATCH zcx_stock_allocation INTO DATA(lo_write_error).
      IF p_json = abap_true.
        IF lo_write_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = 'Allocation write authorization is missing'
            iv_schema  = 49 ).
        ELSE.
          lv_error_message = lo_write_error->message.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = lv_error_message
            iv_schema  = 49 ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_write_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_allocate'
            iv_schema  = 49
            iv_message = 'Allocation write authorization is missing' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_allocate'
            iv_schema  = 49
            iv_message = lo_write_error->message ).
        ENDIF.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      IF lo_write_error->message IS INITIAL.
        WRITE: / 'Allocation failed; write authorization is missing.' .
      ELSE.
        WRITE: / 'Allocation failed:', lo_write_error->message.
      ENDIF.
      RETURN.
  ENDTRY.
  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
    EXPORTING
      io_read_authority  = lo_read_authority
      io_write_authority = lo_write_authority.
  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_read_authority  = lo_read_authority
      io_write_authority = lo_write_authority
      io_transaction     = lo_transaction.
  CREATE OBJECT lo_service
    EXPORTING
      io_stock_source    = lo_stock_source
      io_order_source    = lo_order_source
      io_sink            = lo_sink
      io_allocator       = lo_allocator
      io_reservation     = lo_reservation
      io_unit_converter  = lo_unit_converter
      io_lock            = lo_lock
      io_authority       = lo_authority
      io_write_authority = lo_write_authority
      io_transaction     = lo_transaction
      io_audit           = lo_audit.

  TRY.
      lv_remaining = lo_service->allocate(
        EXPORTING
          iv_material                    = p_matnr
          iv_plant                       = p_werks
          iv_storage_location            = p_lgort
          iv_movement_type               = p_bwart
          iv_unit                        = lv_unit
          iv_batch                       = p_charg
          iv_requested_on_from           = p_from
          iv_requested_on_to             = p_until
          iv_min_shelf_life              = p_shelf
          iv_safety_stock                = p_safstk
          iv_shortage_limit_active       = p_shg
          iv_max_shortage                = p_shmax
          iv_spct_limit_active           = p_spg
          iv_max_shortage_pct            = p_spmax
          iv_coverage_limit_active       = p_covg
          iv_min_coverage                = p_covmin
          iv_full_line_limit_active      = p_fullg
          iv_min_full_line_pct           = p_fmin
          iv_full_count_limit_active     = p_flg
          iv_min_full_lines              = p_flmin
          iv_max_full_count_limit_active = p_mflg
          iv_max_full_lines              = p_mflmax
          iv_demand_limit_active         = p_dg
          iv_max_demand_count            = p_dmax
          iv_quantity_limit_active       = p_qg
          iv_max_requested_quantity      = p_qmax
          iv_allocation_limit_active     = p_ag
          iv_max_allocated_quantity      = p_amax
          iv_min_alloc_limit_active      = p_mg
          iv_min_allocated_quantity      = p_mmin
          iv_min_line_limit_active       = p_ilg
          iv_min_alloc_lines             = p_imin
          iv_line_limit_active           = p_lg
          iv_max_alloc_lines             = p_lmax
          iv_unalloc_limit_active        = p_ug
          iv_max_unalloc_lines           = p_umax
          iv_partial_limit_active        = p_pg
          iv_max_partial_lines           = p_pmax
          iv_shline_limit_active         = p_slg
          iv_max_shortage_lines          = p_slmax
          iv_strategy                    = p_strat
          iv_preview                     = p_test
        IMPORTING
          ev_run_id                      = lv_run_id ).
    CATCH zcx_stock_allocation INTO DATA(lo_allocation_error).
      TRY.
          ls_summary = lo_audit->get_summary(
            iv_material         = p_matnr
            iv_plant            = p_werks
            iv_storage_location = p_lgort
            iv_batch            = p_charg
            iv_unit             = lv_unit ).
          IF p_json = abap_true.
            IF ls_summary-last_message IS INITIAL.
              IF lo_allocation_error->message IS INITIAL.
                lv_error_message = 'Allocation failed'.
              ELSE.
                lv_error_message = lo_allocation_error->message.
              ENDIF.
            ELSE.
              lv_error_message = ls_summary-last_message.
            ENDIF.
            IF lv_run_id IS INITIAL.
              lv_json_line = zcl_stock_json=>error_with_schema(
                iv_message = lv_error_message
                iv_schema  = 49 ).
            ELSE.
              lv_json_line = zcl_stock_json=>error_with_schema_run_id(
                iv_message = lv_error_message
                iv_schema  = 49
                iv_run_id  = lv_run_id ).
            ENDIF.
            WRITE: / lv_json_line.
            RETURN.
          ENDIF.
          IF p_csv = abap_true.
            IF ls_summary-last_message IS INITIAL.
              IF lo_allocation_error->message IS INITIAL.
                lv_error_message = 'Allocation failed'.
              ELSE.
                lv_error_message = lo_allocation_error->message.
              ENDIF.
            ELSE.
              lv_error_message = ls_summary-last_message.
            ENDIF.
            IF lv_run_id IS INITIAL.
              lv_csv_line = zcl_stock_csv=>error_with_schema(
                iv_mode    = 'zstock_allocate'
                iv_schema  = 49
                iv_message = lv_error_message ).
            ELSE.
              lv_csv_line = zcl_stock_csv=>error_with_schema_run_id(
                iv_mode    = 'zstock_allocate'
                iv_schema  = 49
                iv_message = lv_error_message
                iv_run_id  = lv_run_id ).
            ENDIF.
            IF lv_run_id IS INITIAL.
              WRITE: / 'mode;status;schema_version;message'.
            ELSE.
              WRITE: / 'mode;status;schema_version;message;run_id'.
            ENDIF.
            WRITE: / lv_csv_line.
            RETURN.
          ENDIF.
          WRITE: / 'Allocation failed.'
                 , / 'Run ID:', lv_run_id
                 , / 'Last status:', ls_summary-last_status
                 , / 'Last message:', ls_summary-last_message.
        CATCH zcx_stock_allocation INTO DATA(lo_summary_failure).
          CLEAR lv_error_message.
          IF lo_allocation_error->message IS INITIAL.
            lv_error_message = 'Allocation failed'.
          ELSE.
            lv_error_message = lo_allocation_error->message.
          ENDIF.
          IF lo_summary_failure->message IS NOT INITIAL.
            CONCATENATE lv_error_message
              'Audit status is unavailable:' lo_summary_failure->message
              INTO lv_error_message SEPARATED BY space.
          ENDIF.
          IF p_json = abap_true.
            IF lv_run_id IS INITIAL.
              lv_json_line = zcl_stock_json=>error_with_schema(
                iv_message = lv_error_message
                iv_schema  = 49 ).
            ELSE.
              lv_json_line = zcl_stock_json=>error_with_schema_run_id(
                iv_message = lv_error_message
                iv_schema  = 49
                iv_run_id  = lv_run_id ).
            ENDIF.
            WRITE: / lv_json_line.
            RETURN.
          ENDIF.
          IF p_csv = abap_true.
            IF lv_run_id IS INITIAL.
              lv_csv_line = zcl_stock_csv=>error_with_schema(
                iv_mode    = 'zstock_allocate'
                iv_schema  = 49
                iv_message = lv_error_message ).
            ELSE.
              lv_csv_line = zcl_stock_csv=>error_with_schema_run_id(
                iv_mode    = 'zstock_allocate'
                iv_schema  = 49
                iv_message = lv_error_message
                iv_run_id  = lv_run_id ).
            ENDIF.
            IF lv_run_id IS INITIAL.
              WRITE: / 'mode;status;schema_version;message'.
            ELSE.
              WRITE: / 'mode;status;schema_version;message;run_id'.
            ENDIF.
            WRITE: / lv_csv_line.
            RETURN.
          ENDIF.
          IF lv_run_id IS NOT INITIAL.
            WRITE: / 'Run ID:', lv_run_id.
          ENDIF.
          IF lo_allocation_error->message IS INITIAL.
            WRITE: / lv_error_message.
          ELSEIF lo_summary_failure->message IS INITIAL.
            WRITE: / 'Allocation failed:', lo_allocation_error->message.
          ELSE.
            WRITE: / 'Allocation failed:', lo_allocation_error->message,
                     / 'Audit status is unavailable:', lo_summary_failure->message.
          ENDIF.
      ENDTRY.
      RETURN.
  ENDTRY.
  TRY.
      ls_summary = lo_audit->get_summary(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = lv_unit ).
    CATCH zcx_stock_allocation INTO DATA(lo_summary_error).
      IF p_json = abap_true.
        IF lo_summary_error->message IS INITIAL.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = 'Run summary is unavailable'
            iv_schema  = 49 ).
        ELSE.
          lv_error_message = lo_summary_error->message.
          lv_json_line = zcl_stock_json=>error_with_schema(
            iv_message = lv_error_message
            iv_schema  = 49 ).
        ENDIF.
        WRITE: / lv_json_line.
        RETURN.
      ENDIF.
      IF p_csv = abap_true.
        IF lo_summary_error->message IS INITIAL.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_allocate'
            iv_schema  = 49
            iv_message = 'Run summary is unavailable' ).
        ELSE.
          lv_csv_line = zcl_stock_csv=>error_with_schema(
            iv_mode    = 'zstock_allocate'
            iv_schema  = 49
            iv_message = lo_summary_error->message ).
        ENDIF.
        WRITE: / 'mode;status;schema_version;message'.
        WRITE: / lv_csv_line.
        RETURN.
      ENDIF.
      WRITE: / 'Allocation completed. Remaining:', lv_remaining, lv_unit.
      IF lo_summary_error->message IS INITIAL.
        WRITE: / 'Run summary is unavailable.'.
      ELSE.
        WRITE: / 'Run summary is unavailable:', lo_summary_error->message.
      ENDIF.
      RETURN.
  ENDTRY.
  CLEAR lt_run_context.
  TRY.
      lt_run_context = lo_audit->get_runs(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_run_id           = lv_run_id ).
      READ TABLE lt_run_context INTO ls_run_context INDEX 1.
      IF sy-subrc = 0.
        ls_summary-last_requested_on_from = ls_run_context-requested_on_from.
        ls_summary-last_requested_on_to = ls_run_context-requested_on_to.
        ls_summary-last_requested_deadline = ls_run_context-requested_deadline.
        ls_summary-last_start_date = ls_run_context-start_date.
        ls_summary-last_start_time = ls_run_context-start_time.
        ls_summary-last_finish_date = ls_run_context-finish_date.
        ls_summary-last_finish_time = ls_run_context-finish_time.
        CLEAR lv_last_duration_seconds.
        IF ls_run_context-finish_date IS NOT INITIAL.
          cl_abap_tstmp=>td_subtract(
            EXPORTING
              date1    = ls_run_context-finish_date
              time1    = ls_run_context-finish_time
              date2    = ls_run_context-start_date
              time2    = ls_run_context-start_time
            IMPORTING
              res_secs = lv_last_duration_seconds ).
        ENDIF.
        ls_summary-last_duration_seconds = lv_last_duration_seconds.
        ls_summary-last_status = ls_run_context-status.
        ls_summary-last_message = ls_run_context-message.
      ENDIF.
    CATCH zcx_stock_allocation.
      CLEAR ls_run_context.
  ENDTRY.
  lv_last_deadline_age_days = ls_summary-last_deadline_age_days.
  lv_oldest_deadline_age_days = ls_summary-oldest_deadline_age_days.
  lv_newest_deadline_age_days = ls_summary-newest_deadline_age_days.
  IF ls_summary-last_requested_deadline IS INITIAL.
    lv_last_deadline_age_text = 'n/a'.
  ELSE.
    lv_last_deadline_age_text = zcl_stock_csv=>number(
      lv_last_deadline_age_days ).
  ENDIF.
  IF ls_summary-earliest_requested_deadline IS INITIAL.
    lv_oldest_deadline_age_text = 'n/a'.
  ELSE.
    lv_oldest_deadline_age_text = zcl_stock_csv=>number(
      lv_oldest_deadline_age_days ).
  ENDIF.
  IF ls_summary-latest_requested_deadline IS INITIAL.
    lv_newest_deadline_age_text = 'n/a'.
  ELSE.
    lv_newest_deadline_age_text = zcl_stock_csv=>number(
      lv_newest_deadline_age_days ).
  ENDIF.
  lv_requested = ls_summary-requested.
  IF p_csv = abap_true.
    CLEAR lt_csv_fields.
    IF p_test = abap_true.
      APPEND zcl_stock_csv=>quote( 'preview' ) TO lt_csv_fields.
    ELSE.
    APPEND zcl_stock_csv=>quote( 'execute' ) TO lt_csv_fields.
    ENDIF.
    APPEND zcl_stock_csv=>quote( lv_strategy ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( 49 ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_unit ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_bwart ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_shelf ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_safstk ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_shg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_shmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_spg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_spmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_covg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_covmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_fullg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_fmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_flg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_flmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_mflg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_mflmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_dg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_dmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_qg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_qmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ag ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_amax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_mg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_mmin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ilg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_imin ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_lg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_lmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_ug ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_umax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_pg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_pmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_slg ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( p_slmax ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_from ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( p_until ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_remaining ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( lv_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-total_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-success_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-partial_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-error_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-priority_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fifo_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-full_only_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-smallest_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-largest_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-best_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fair_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-weighted_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_priority_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_fair_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-legacy_strategy_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-completion_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-success_rate_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-partial_rate_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-error_rate_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-priority_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-priority_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-priority_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-priority_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fifo_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fifo_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fifo_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fifo_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-full_only_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-full_only_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-full_only_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-full_only_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-smallest_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-smallest_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-smallest_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-smallest_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-largest_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-largest_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-largest_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-largest_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-best_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-best_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-best_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-best_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fair_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fair_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fair_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-fair_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-weighted_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-weighted_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-weighted_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-weighted_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-adaptive_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-legacy_requested ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-legacy_allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-legacy_shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-legacy_coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-allocated ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-shortage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-coverage ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-shortage_pct ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-full_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-partial_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-unallocated_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-demand_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-deadline_count ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_requested_on_from ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_requested_on_to ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      ls_summary-earliest_requested_deadline ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      ls_summary-latest_requested_deadline ) TO lt_csv_fields.
    APPEND lv_last_deadline_age_text TO lt_csv_fields.
    APPEND lv_oldest_deadline_age_text TO lt_csv_fields.
    APPEND lv_newest_deadline_age_text TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote(
      ls_summary-deadline_age_reference_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( lv_run_id ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_run_id ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_strategy ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_start_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_start_time ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_finish_date ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_finish_time ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-last_duration_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-average_duration_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-minimum_duration_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-maximum_duration_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-completed_duration_runs ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-oldest_running_age_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-oldest_running_run_id ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>number( ls_summary-newest_running_age_seconds ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-newest_running_run_id ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_status ) TO lt_csv_fields.
    APPEND zcl_stock_csv=>quote( ls_summary-last_message ) TO lt_csv_fields.
    CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
    WRITE: / 'mode;strategy;generated_date;generated_time;schema_version;material;plant;storage_location;batch;unit;'
      && 'movement_type;minimum_shelf_life_days;safety_stock;shortage_guard_active;maximum_shortage;'
      && 'shortage_pct_guard_active;maximum_shortage_pct;'
      && 'coverage_guard_active;minimum_coverage_pct;'
      && 'full_line_guard_active;minimum_full_line_pct;'
      && 'full_line_count_guard_active;minimum_full_lines;'
      && 'maximum_full_line_count_guard_active;maximum_full_lines;'
      && 'demand_guard_active;maximum_demand_count;'
      && 'quantity_guard_active;maximum_requested_quantity;'
      && 'allocation_guard_active;maximum_allocated_quantity;'
      && 'minimum_allocation_guard_active;minimum_allocated_quantity;'
      && 'minimum_allocation_line_guard_active;minimum_allocated_lines;'
      && 'allocation_line_guard_active;maximum_allocated_lines;'
      && 'unallocated_line_guard_active;maximum_unallocated_lines;'
      && 'partial_line_guard_active;maximum_partial_lines;'
      && 'shortage_line_guard_active;maximum_shortage_lines;'
      && 'requested_on_filter_from;requested_on_filter_to;'
      && 'remaining;requested;runs;successful_runs;partial_runs;error_runs;priority_runs;fifo_runs;full_only_runs;'
      && 'smallest_runs;largest_runs;best_runs;fair_runs;weighted_runs;adaptive_runs;adaptive_priority_runs;'
      && 'adaptive_fair_runs;'
      && 'legacy_strategy_runs;completion_pct;success_rate_pct;'
      && 'partial_rate_pct;error_rate_pct;priority_requested;priority_allocated;priority_shortage;'
      && 'priority_coverage_pct;fifo_requested;fifo_allocated;fifo_shortage;fifo_coverage_pct;full_only_requested;'
      && 'full_only_allocated;full_only_shortage;full_only_coverage_pct;smallest_requested;smallest_allocated;'
      && 'smallest_shortage;smallest_coverage_pct;largest_requested;largest_allocated;largest_shortage;'
      && 'largest_coverage_pct;best_requested;best_allocated;best_shortage;best_coverage_pct;fair_requested;'
      && 'fair_allocated;fair_shortage;fair_coverage_pct;weighted_requested;weighted_allocated;'
      && 'weighted_shortage;weighted_coverage_pct;adaptive_requested;adaptive_allocated;'
      && 'adaptive_shortage;adaptive_coverage_pct;legacy_requested;'
      && 'legacy_allocated;legacy_shortage;legacy_coverage_pct;allocated;shortage;coverage_pct;shortage_pct;'
      && 'full_count;partial_count;unallocated_count;demand_count;deadline_count;requested_on_from;requested_on_to;'
      && 'requested_deadline;earliest_requested_deadline;latest_requested_deadline;'
      && 'last_deadline_age_days;oldest_deadline_age_days;newest_deadline_age_days;'
      && 'deadline_age_reference_date;run_id;last_run_id;'
      && 'last_strategy;last_start_date;last_start_time;last_finish_date;last_finish_time;last_duration_seconds;'
      && 'average_duration_seconds;minimum_duration_seconds;maximum_duration_seconds;completed_duration_runs;'
      && 'oldest_running_age_seconds;oldest_running_run_id;newest_running_age_seconds;newest_running_run_id;'
      && 'last_status;last_message'.
    WRITE: / lv_csv_line.
    RETURN.
  ENDIF.
  IF p_json = abap_true.
    IF p_test = abap_true.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'preview' ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'mode'
        iv_value = 'execute' ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'strategy'
      iv_value = lv_strategy ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 49 ) TO lt_json_fields.
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
      iv_value = lv_unit ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'movement_type'
      iv_value = p_bwart ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_shelf_life_days'
        iv_value = p_shelf ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_shelf_life_days'
        iv_value = p_shelf ) TO lt_json_fields.
    ENDIF.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'safety_stock'
        iv_value = p_safstk ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'safety_stock'
        iv_value = p_safstk ) TO lt_json_fields.
    ENDIF.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'shortage_guard_active'
        iv_value = p_shg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_shortage'
        iv_value = p_shmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'shortage_pct_guard_active'
        iv_value = p_spg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_shortage_pct'
        iv_value = p_spmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'coverage_guard_active'
        iv_value = p_covg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_coverage_pct'
        iv_value = p_covmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'full_line_guard_active'
        iv_value = p_fullg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_full_line_pct'
        iv_value = p_fmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'full_line_count_guard_active'
        iv_value = p_flg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_full_lines'
        iv_value = p_flmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'maximum_full_line_count_guard_active'
        iv_value = p_mflg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_full_lines'
        iv_value = p_mflmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'demand_guard_active'
        iv_value = p_dg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_demand_count'
        iv_value = p_dmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'quantity_guard_active'
        iv_value = p_qg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_requested_quantity'
        iv_value = p_qmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'allocation_guard_active'
        iv_value = p_ag ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_allocated_quantity'
        iv_value = p_amax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'minimum_allocation_guard_active'
        iv_value = p_mg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_allocated_quantity'
        iv_value = p_mmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'minimum_allocation_line_guard_active'
        iv_value = p_ilg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_allocated_lines'
        iv_value = p_imin ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'allocation_line_guard_active'
        iv_value = p_lg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_allocated_lines'
        iv_value = p_lmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'unallocated_line_guard_active'
        iv_value = p_ug ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_unallocated_lines'
        iv_value = p_umax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'partial_line_guard_active'
        iv_value = p_pg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_partial_lines'
        iv_value = p_pmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'shortage_line_guard_active'
        iv_value = p_slg ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_shortage_lines'
        iv_value = p_slmax ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shortage_guard_active'
        iv_value = p_shg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_shortage'
        iv_value = p_shmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shortage_pct_guard_active'
        iv_value = p_spg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_shortage_pct'
        iv_value = p_spmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'coverage_guard_active'
        iv_value = p_covg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_coverage_pct'
        iv_value = p_covmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_line_guard_active'
        iv_value = p_fullg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_full_line_pct'
        iv_value = p_fmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_line_count_guard_active'
        iv_value = p_flg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_full_lines'
        iv_value = p_flmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_full_line_count_guard_active'
        iv_value = p_mflg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_full_lines'
        iv_value = p_mflmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'demand_guard_active'
        iv_value = p_dg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_demand_count'
        iv_value = p_dmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'quantity_guard_active'
        iv_value = p_qg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_requested_quantity'
        iv_value = p_qmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_guard_active'
        iv_value = p_ag ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_allocated_quantity'
        iv_value = p_amax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocation_guard_active'
        iv_value = p_mg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocated_quantity'
        iv_value = p_mmin ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocation_line_guard_active'
        iv_value = p_ilg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_allocated_lines'
        iv_value = p_imin ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_line_guard_active'
        iv_value = p_lg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_allocated_lines'
        iv_value = p_lmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unallocated_line_guard_active'
        iv_value = p_ug ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_unallocated_lines'
        iv_value = p_umax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_line_guard_active'
        iv_value = p_pg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_partial_lines'
        iv_value = p_pmax ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shortage_line_guard_active'
        iv_value = p_slg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_shortage_lines'
        iv_value = p_slmax ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_filter_from'
      iv_value = p_from ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_filter_to'
      iv_value = p_until ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'remaining'
        iv_value = lv_remaining ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'requested'
        iv_value = lv_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'runs'
        iv_value = ls_summary-total_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'successful_runs'
        iv_value = ls_summary-success_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'partial_runs'
        iv_value = ls_summary-partial_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'error_runs'
        iv_value = ls_summary-error_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_runs'
        iv_value = ls_summary-priority_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_runs'
        iv_value = ls_summary-fifo_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_runs'
        iv_value = ls_summary-full_only_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_runs'
        iv_value = ls_summary-smallest_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_runs'
        iv_value = ls_summary-largest_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_runs'
        iv_value = ls_summary-best_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fair_runs'
          iv_value = ls_summary-fair_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'weighted_runs'
          iv_value = ls_summary-weighted_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_runs'
          iv_value = ls_summary-adaptive_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_priority_runs'
          iv_value = ls_summary-adaptive_priority_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_fair_runs'
          iv_value = ls_summary-adaptive_fair_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_strategy_runs'
        iv_value = ls_summary-legacy_strategy_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'completion_pct'
        iv_value = ls_summary-completion_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'success_rate_pct'
        iv_value = ls_summary-success_rate_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'partial_rate_pct'
        iv_value = ls_summary-partial_rate_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'error_rate_pct'
        iv_value = ls_summary-error_rate_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_requested'
        iv_value = ls_summary-priority_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_allocated'
        iv_value = ls_summary-priority_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_shortage'
        iv_value = ls_summary-priority_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'priority_coverage_pct'
        iv_value = ls_summary-priority_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_requested'
        iv_value = ls_summary-fifo_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_allocated'
        iv_value = ls_summary-fifo_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_shortage'
        iv_value = ls_summary-fifo_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fifo_coverage_pct'
        iv_value = ls_summary-fifo_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_requested'
        iv_value = ls_summary-full_only_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_allocated'
        iv_value = ls_summary-full_only_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_shortage'
        iv_value = ls_summary-full_only_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_only_coverage_pct'
        iv_value = ls_summary-full_only_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_requested'
        iv_value = ls_summary-smallest_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_allocated'
        iv_value = ls_summary-smallest_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_shortage'
        iv_value = ls_summary-smallest_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'smallest_coverage_pct'
        iv_value = ls_summary-smallest_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_requested'
        iv_value = ls_summary-largest_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_allocated'
        iv_value = ls_summary-largest_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_shortage'
        iv_value = ls_summary-largest_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'largest_coverage_pct'
        iv_value = ls_summary-largest_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_requested'
        iv_value = ls_summary-best_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_allocated'
        iv_value = ls_summary-best_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_shortage'
        iv_value = ls_summary-best_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'best_coverage_pct'
        iv_value = ls_summary-best_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_requested'
        iv_value = ls_summary-fair_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_allocated'
        iv_value = ls_summary-fair_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'fair_shortage'
        iv_value = ls_summary-fair_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'fair_coverage_pct'
          iv_value = ls_summary-fair_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'weighted_requested'
          iv_value = ls_summary-weighted_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'weighted_allocated'
          iv_value = ls_summary-weighted_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'weighted_shortage'
          iv_value = ls_summary-weighted_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'weighted_coverage_pct'
          iv_value = ls_summary-weighted_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_requested'
          iv_value = ls_summary-adaptive_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_allocated'
          iv_value = ls_summary-adaptive_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_shortage'
          iv_value = ls_summary-adaptive_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'adaptive_coverage_pct'
          iv_value = ls_summary-adaptive_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_requested'
        iv_value = ls_summary-legacy_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_allocated'
        iv_value = ls_summary-legacy_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_shortage'
        iv_value = ls_summary-legacy_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'legacy_coverage_pct'
        iv_value = ls_summary-legacy_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'allocated'
        iv_value = ls_summary-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'shortage'
        iv_value = ls_summary-shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'coverage_pct'
        iv_value = ls_summary-coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'shortage_pct'
        iv_value = ls_summary-shortage_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'full_count'
        iv_value = ls_summary-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'partial_count'
        iv_value = ls_summary-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'unallocated_count'
        iv_value = ls_summary-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'demand_count'
        iv_value = ls_summary-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'deadline_count'
        iv_value = ls_summary-deadline_count ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 49 ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'remaining'
        iv_value = lv_remaining ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested'
        iv_value = lv_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'runs'
        iv_value = ls_summary-total_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'successful_runs'
        iv_value = ls_summary-success_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_runs'
        iv_value = ls_summary-partial_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'error_runs'
        iv_value = ls_summary-error_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'priority_runs'
        iv_value = ls_summary-priority_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fifo_runs'
        iv_value = ls_summary-fifo_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_only_runs'
        iv_value = ls_summary-full_only_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'smallest_runs'
        iv_value = ls_summary-smallest_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'largest_runs'
        iv_value = ls_summary-largest_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'best_runs'
        iv_value = ls_summary-best_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fair_runs'
          iv_value = ls_summary-fair_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'weighted_runs'
          iv_value = ls_summary-weighted_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_runs'
          iv_value = ls_summary-adaptive_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_priority_runs'
          iv_value = ls_summary-adaptive_priority_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_fair_runs'
          iv_value = ls_summary-adaptive_fair_runs ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
        iv_name  = 'legacy_strategy_runs'
        iv_value = ls_summary-legacy_strategy_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'completion_pct'
        iv_value = ls_summary-completion_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'success_rate_pct'
        iv_value = ls_summary-success_rate_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_rate_pct'
        iv_value = ls_summary-partial_rate_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'error_rate_pct'
        iv_value = ls_summary-error_rate_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'priority_requested'
        iv_value = ls_summary-priority_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'priority_allocated'
        iv_value = ls_summary-priority_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'priority_shortage'
        iv_value = ls_summary-priority_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'priority_coverage_pct'
        iv_value = ls_summary-priority_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fifo_requested'
        iv_value = ls_summary-fifo_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fifo_allocated'
        iv_value = ls_summary-fifo_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fifo_shortage'
        iv_value = ls_summary-fifo_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fifo_coverage_pct'
        iv_value = ls_summary-fifo_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_only_requested'
        iv_value = ls_summary-full_only_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_only_allocated'
        iv_value = ls_summary-full_only_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_only_shortage'
        iv_value = ls_summary-full_only_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_only_coverage_pct'
        iv_value = ls_summary-full_only_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'smallest_requested'
        iv_value = ls_summary-smallest_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'smallest_allocated'
        iv_value = ls_summary-smallest_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'smallest_shortage'
        iv_value = ls_summary-smallest_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'smallest_coverage_pct'
        iv_value = ls_summary-smallest_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'largest_requested'
        iv_value = ls_summary-largest_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'largest_allocated'
        iv_value = ls_summary-largest_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'largest_shortage'
        iv_value = ls_summary-largest_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'largest_coverage_pct'
        iv_value = ls_summary-largest_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'best_requested'
        iv_value = ls_summary-best_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'best_allocated'
        iv_value = ls_summary-best_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'best_shortage'
        iv_value = ls_summary-best_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'best_coverage_pct'
        iv_value = ls_summary-best_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fair_requested'
        iv_value = ls_summary-fair_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fair_allocated'
        iv_value = ls_summary-fair_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'fair_shortage'
        iv_value = ls_summary-fair_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'fair_coverage_pct'
          iv_value = ls_summary-fair_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'weighted_requested'
          iv_value = ls_summary-weighted_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'weighted_allocated'
          iv_value = ls_summary-weighted_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'weighted_shortage'
          iv_value = ls_summary-weighted_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'weighted_coverage_pct'
          iv_value = ls_summary-weighted_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_requested'
          iv_value = ls_summary-adaptive_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_allocated'
          iv_value = ls_summary-adaptive_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_shortage'
          iv_value = ls_summary-adaptive_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'adaptive_coverage_pct'
          iv_value = ls_summary-adaptive_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
        iv_name  = 'legacy_requested'
        iv_value = ls_summary-legacy_requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'legacy_allocated'
        iv_value = ls_summary-legacy_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'legacy_shortage'
        iv_value = ls_summary-legacy_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'legacy_coverage_pct'
        iv_value = ls_summary-legacy_coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocated'
        iv_value = ls_summary-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shortage'
        iv_value = ls_summary-shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'coverage_pct'
        iv_value = ls_summary-coverage ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'shortage_pct'
        iv_value = ls_summary-shortage_pct ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'full_count'
        iv_value = ls_summary-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'partial_count'
        iv_value = ls_summary-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unallocated_count'
        iv_value = ls_summary-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'demand_count'
        iv_value = ls_summary-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_count'
        iv_value = ls_summary-deadline_count ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_from'
      iv_value = ls_summary-last_requested_on_from ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_on_to'
      iv_value = ls_summary-last_requested_on_to ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'requested_deadline'
      iv_value = ls_summary-last_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'earliest_requested_deadline'
      iv_value = ls_summary-earliest_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'latest_requested_deadline'
      iv_value = ls_summary-latest_requested_deadline ) TO lt_json_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'last_deadline_age_days'
      iv_value   = lv_last_deadline_age_days
      iv_text    = lv_last_deadline_age_text
      iv_present = xsdbool( ls_summary-last_requested_deadline IS NOT INITIAL )
      iv_typed   = p_typed ) TO lt_json_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'oldest_deadline_age_days'
      iv_value   = lv_oldest_deadline_age_days
      iv_text    = lv_oldest_deadline_age_text
      iv_present = xsdbool( ls_summary-earliest_requested_deadline IS NOT INITIAL )
      iv_typed   = p_typed ) TO lt_json_fields.
    APPEND zcl_stock_json=>filter_number_property(
      iv_name    = 'newest_deadline_age_days'
      iv_value   = lv_newest_deadline_age_days
      iv_text    = lv_newest_deadline_age_text
      iv_present = xsdbool( ls_summary-latest_requested_deadline IS NOT INITIAL )
      iv_typed   = p_typed ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'deadline_age_reference_date'
      iv_value = ls_summary-deadline_age_reference_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'run_id'
      iv_value = lv_run_id ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_run_id'
      iv_value = ls_summary-last_run_id ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_strategy'
      iv_value = ls_summary-last_strategy ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_start_date'
      iv_value = ls_summary-last_start_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_start_time'
      iv_value = ls_summary-last_start_time ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_finish_date'
      iv_value = ls_summary-last_finish_date ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_finish_time'
      iv_value = ls_summary-last_finish_time ) TO lt_json_fields.
    IF p_typed = abap_true.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'last_duration_seconds'
        iv_value = ls_summary-last_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'average_duration_seconds'
        iv_value = ls_summary-average_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'minimum_duration_seconds'
        iv_value = ls_summary-minimum_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'maximum_duration_seconds'
        iv_value = ls_summary-maximum_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'completed_duration_runs'
        iv_value = ls_summary-completed_duration_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'oldest_running_age_seconds'
        iv_value = ls_summary-oldest_running_age_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'oldest_running_run_id'
        iv_value = ls_summary-oldest_running_run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'newest_running_age_seconds'
        iv_value = ls_summary-newest_running_age_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'newest_running_run_id'
        iv_value = ls_summary-newest_running_run_id ) TO lt_json_fields.
    ELSE.
      APPEND zcl_stock_json=>property(
        iv_name  = 'last_duration_seconds'
        iv_value = ls_summary-last_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'average_duration_seconds'
        iv_value = ls_summary-average_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'minimum_duration_seconds'
        iv_value = ls_summary-minimum_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'maximum_duration_seconds'
        iv_value = ls_summary-maximum_duration_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'completed_duration_runs'
        iv_value = ls_summary-completed_duration_runs ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'oldest_running_age_seconds'
        iv_value = ls_summary-oldest_running_age_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'oldest_running_run_id'
        iv_value = ls_summary-oldest_running_run_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'newest_running_age_seconds'
        iv_value = ls_summary-newest_running_age_seconds ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'newest_running_run_id'
        iv_value = ls_summary-newest_running_run_id ) TO lt_json_fields.
    ENDIF.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_status'
      iv_value = ls_summary-last_status ) TO lt_json_fields.
    APPEND zcl_stock_json=>property(
      iv_name  = 'last_message'
      iv_value = ls_summary-last_message ) TO lt_json_fields.
    CONCATENATE LINES OF lt_json_fields INTO lv_json_line SEPARATED BY ','.
    CONCATENATE '{' lv_json_line '}' INTO lv_json_line.
    WRITE: / lv_json_line.
    RETURN.
  ENDIF.
  WRITE: / 'Strategy:', lv_strategy,
         / 'Movement type:', p_bwart,
         / 'Minimum shelf-life days:', p_shelf,
         / 'Safety stock:', p_safstk, lv_unit,
         / 'Shortage guard active:', p_shg,
         / 'Maximum shortage:', p_shmax, lv_unit,
         / 'Shortage-percentage guard active:', p_spg,
         / 'Maximum shortage percentage:', p_spmax, '%',
         / 'Coverage guard active:', p_covg,
         / 'Minimum coverage:', p_covmin, '%',
         / 'Full-line guard active:', p_fullg,
         / 'Minimum full-line percentage:', p_fmin, '%',
         / 'Full-line-count guard active:', p_flg,
         / 'Minimum full lines:', p_flmin,
         / 'Maximum full-line-count guard active:', p_mflg,
         / 'Maximum full lines:', p_mflmax,
         / 'Demand guard active:', p_dg,
         / 'Maximum demand count:', p_dmax,
         / 'Quantity guard active:', p_qg,
         / 'Maximum requested quantity:', p_qmax, lv_unit,
         / 'Allocation guard active:', p_ag,
         / 'Maximum allocated quantity:', p_amax, lv_unit,
         / 'Minimum-allocation guard active:', p_mg,
         / 'Minimum allocated quantity:', p_mmin, lv_unit,
         / 'Minimum-allocation-line guard active:', p_ilg,
         / 'Minimum allocated lines:', p_imin,
         / 'Allocation-line guard active:', p_lg,
         / 'Maximum allocated lines:', p_lmax,
         / 'Unallocated-line guard active:', p_ug,
         / 'Maximum unallocated lines:', p_umax,
         / 'Partial-line guard active:', p_pg,
         / 'Maximum partial lines:', p_pmax,
         / 'Shortage-line guard active:', p_slg,
         / 'Maximum shortage lines:', p_slmax,
         / 'Requested filter from:', p_from,
         / 'Requested filter through:', p_until,
         / 'Remaining:', lv_remaining, lv_unit,
         / 'Requested:', lv_requested, lv_unit,
         / 'Runs:', ls_summary-total_runs,
         / 'Successful:', ls_summary-success_runs,
         / 'Partial:', ls_summary-partial_runs,
         / 'Errors:', ls_summary-error_runs,
         / 'Priority runs:', ls_summary-priority_runs,
         / 'FIFO runs:', ls_summary-fifo_runs,
         / 'Full-only runs:', ls_summary-full_only_runs,
          / 'Smallest runs:', ls_summary-smallest_runs,
          / 'Largest runs:', ls_summary-largest_runs,
          / 'Best-fit runs:', ls_summary-best_runs,
          / 'Fair-share runs:', ls_summary-fair_runs,
          / 'Weighted fair-share runs:', ls_summary-weighted_runs,
          / 'Adaptive runs:', ls_summary-adaptive_runs,
          / 'Adaptive priority branch runs:', ls_summary-adaptive_priority_runs,
          / 'Adaptive fair-share branch runs:', ls_summary-adaptive_fair_runs,
          / 'Legacy strategy runs:', ls_summary-legacy_strategy_runs,
         / 'Priority totals (', ls_summary-unit, '): requested',
           ls_summary-priority_requested, 'allocated',
           ls_summary-priority_allocated, 'shortage',
           ls_summary-priority_shortage, 'coverage',
           ls_summary-priority_coverage, '%',
         / 'FIFO totals (', ls_summary-unit, '): requested',
           ls_summary-fifo_requested, 'allocated',
           ls_summary-fifo_allocated, 'shortage',
           ls_summary-fifo_shortage, 'coverage',
           ls_summary-fifo_coverage, '%',
         / 'Full-only totals (', ls_summary-unit, '): requested',
           ls_summary-full_only_requested, 'allocated',
           ls_summary-full_only_allocated, 'shortage',
           ls_summary-full_only_shortage, 'coverage',
           ls_summary-full_only_coverage, '%',
         / 'Smallest totals (', ls_summary-unit, '): requested',
           ls_summary-smallest_requested, 'allocated',
           ls_summary-smallest_allocated, 'shortage',
           ls_summary-smallest_shortage, 'coverage',
           ls_summary-smallest_coverage, '%',
         / 'Largest totals (', ls_summary-unit, '): requested',
           ls_summary-largest_requested, 'allocated',
           ls_summary-largest_allocated, 'shortage',
           ls_summary-largest_shortage, 'coverage',
           ls_summary-largest_coverage, '%',
         / 'Best-fit totals (', ls_summary-unit, '): requested',
           ls_summary-best_requested, 'allocated',
           ls_summary-best_allocated, 'shortage',
           ls_summary-best_shortage, 'coverage',
           ls_summary-best_coverage, '%',
         / 'Fair-share totals (', ls_summary-unit, '): requested',
           ls_summary-fair_requested, 'allocated',
           ls_summary-fair_allocated, 'shortage',
           ls_summary-fair_shortage, 'coverage',
           ls_summary-fair_coverage, '%',
         / 'Weighted totals (', ls_summary-unit, '): requested',
           ls_summary-weighted_requested, 'allocated',
           ls_summary-weighted_allocated, 'shortage',
           ls_summary-weighted_shortage, 'coverage',
           ls_summary-weighted_coverage, '%',
         / 'Adaptive totals (', ls_summary-unit, '): requested',
           ls_summary-adaptive_requested, 'allocated',
           ls_summary-adaptive_allocated, 'shortage',
           ls_summary-adaptive_shortage, 'coverage',
           ls_summary-adaptive_coverage, '%',
         / 'Legacy totals (', ls_summary-unit, '): requested',
           ls_summary-legacy_requested, 'allocated',
           ls_summary-legacy_allocated, 'shortage',
           ls_summary-legacy_shortage, 'coverage',
           ls_summary-legacy_coverage, '%',
         / 'Allocated:', ls_summary-allocated, ls_summary-unit,
         / 'Shortage:', ls_summary-shortage, ls_summary-unit,
         / 'Coverage:', ls_summary-coverage, '%',
         / 'Shortage:', ls_summary-shortage_pct, '%',
         / 'Fully allocated lines:', ls_summary-full_count,
         / 'Partially allocated lines:', ls_summary-partial_count,
         / 'Unallocated lines:', ls_summary-unallocated_count,
         / 'Demand lines:', ls_summary-demand_count,
         / 'Alerts with requested deadline:', ls_summary-deadline_count,
         / 'Completion:', ls_summary-completion_pct, '%',
         / 'Success rate:', ls_summary-success_rate_pct, '%',
         / 'Partial rate:', ls_summary-partial_rate_pct, '%',
         / 'Error rate:', ls_summary-error_rate_pct, '%',
         / 'Requested from:', ls_summary-last_requested_on_from,
         / 'Requested through:', ls_summary-last_requested_on_to,
         / 'Requested deadline:', ls_summary-last_requested_deadline,
         / 'Earliest requested deadline:',
           ls_summary-earliest_requested_deadline,
         / 'Latest requested deadline:',
           ls_summary-latest_requested_deadline,
         / 'Last deadline age days:', lv_last_deadline_age_text,
         / 'Oldest deadline age days:', lv_oldest_deadline_age_text,
         / 'Newest deadline age days:', lv_newest_deadline_age_text,
         / 'Deadline age reference date:',
           ls_summary-deadline_age_reference_date,
         / 'Run ID:', lv_run_id,
         / 'Last run:', ls_summary-last_run_id,
         / 'Last strategy:', ls_summary-last_strategy,
         / 'Last started:', ls_summary-last_start_date,
           ls_summary-last_start_time,
         / 'Last finished:', ls_summary-last_finish_date,
           ls_summary-last_finish_time,
         / 'Last duration seconds:', ls_summary-last_duration_seconds,
         / 'Average duration seconds:', ls_summary-average_duration_seconds,
         / 'Minimum duration seconds:', ls_summary-minimum_duration_seconds,
         / 'Maximum duration seconds:', ls_summary-maximum_duration_seconds,
         / 'Completed duration runs:', ls_summary-completed_duration_runs,
         / 'Oldest running age seconds:', ls_summary-oldest_running_age_seconds,
         / 'Oldest running run ID:', ls_summary-oldest_running_run_id,
         / 'Newest running age seconds:', ls_summary-newest_running_age_seconds,
         / 'Newest running run ID:', ls_summary-newest_running_run_id,
         / 'Last status:', ls_summary-last_status,
         / 'Last message:', ls_summary-last_message.
