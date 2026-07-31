CLASS zcl_allocation_audit_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_read_authority      TYPE REF TO zif_allocation_read_authority OPTIONAL
        io_write_authority     TYPE REF TO zif_allocation_write_authority OPTIONAL
        io_retention_authority TYPE REF TO zif_allocation_retention_authority OPTIONAL
        io_transaction         TYPE REF TO zif_allocation_transaction OPTIONAL.
    INTERFACES zif_allocation_audit.
  PRIVATE SECTION.
    DATA mo_read_authority TYPE REF TO zif_allocation_read_authority.
    DATA mo_write_authority TYPE REF TO zif_allocation_write_authority.
    DATA mo_retention_authority TYPE REF TO zif_allocation_retention_authority.
    DATA mo_transaction TYPE REF TO zif_allocation_transaction.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
    METHODS validate_run
      IMPORTING
        is_run TYPE zif_allocation_audit=>ty_run
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_allocation_audit_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_read_authority IS BOUND.
      mo_read_authority = io_read_authority.
    ELSE.
      CREATE OBJECT mo_read_authority TYPE zcl_allocation_read_authority_sap.
    ENDIF.
    IF io_write_authority IS BOUND.
      mo_write_authority = io_write_authority.
    ELSE.
      CREATE OBJECT mo_write_authority TYPE zcl_allocation_write_authority_sap.
    ENDIF.
    IF io_retention_authority IS BOUND.
      mo_retention_authority = io_retention_authority.
    ELSE.
      CREATE OBJECT mo_retention_authority TYPE zcl_allocation_retention_authority_sap.
    ENDIF.
    IF io_transaction IS BOUND.
      mo_transaction = io_transaction.
    ELSE.
      CREATE OBJECT mo_transaction TYPE zcl_allocation_transaction_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~purge_runs_before.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Audit purge scope is incomplete' ).
    ENDIF.
    IF iv_before_date IS INITIAL.
      raise_error( iv_message = 'Audit purge date is required' ).
    ENDIF.
    IF iv_before_date > sy-datum.
      raise_error( iv_message = 'Audit purge date cannot be in the future' ).
    ENDIF.
    IF mo_retention_authority IS BOUND.
      TRY.
          mo_retention_authority->check( ).
        CATCH zcx_stock_allocation INTO DATA(lo_retention_error).
          IF lo_retention_error->message IS INITIAL.
            lo_retention_error->message = 'Audit retention authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_retention_error.
      ENDTRY.
    ENDIF.
    DATA lt_run_ids TYPE SORTED TABLE OF zif_allocation_audit=>ty_run_id
      WITH UNIQUE KEY table_line.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    IF iv_unit IS INITIAL.
      SELECT run_id
        FROM zstockalloc_run
        INTO TABLE @lt_run_ids
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND start_date < @iv_before_date
          AND status <> 'R'.
    ELSE.
      SELECT run_id
        FROM zstockalloc_run
        INTO TABLE @lt_run_ids
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND unit = @iv_unit
          AND start_date < @iv_before_date
          AND status <> 'R'.
    ENDIF.
    LOOP AT lt_run_ids INTO lv_run_id.
      IF iv_unit IS INITIAL.
        DELETE FROM zstockalloc
          WHERE mandt = @sy-mandt
            AND matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND run_id = @lv_run_id.
      ELSE.
        DELETE FROM zstockalloc
          WHERE mandt = @sy-mandt
            AND matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND allocation_unit = @iv_unit
            AND run_id = @lv_run_id.
      ENDIF.
    ENDLOOP.
    IF iv_unit IS INITIAL.
      DELETE FROM zstockalloc_run
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND start_date < @iv_before_date
          AND status <> 'R'.
    ELSE.
      DELETE FROM zstockalloc_run
        WHERE mandt = @sy-mandt
          AND matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND unit = @iv_unit
          AND start_date < @iv_before_date
          AND status <> 'R'.
    ENDIF.
    rv_deleted = sy-dbcnt.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_transaction_error).
          IF lo_transaction_error->message IS INITIAL.
            lo_transaction_error->message = 'Audit purge commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_transaction_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_summary.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lv_summary_unit TYPE zif_stock_allocation=>ty_unit.
    FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

    lt_runs = zif_allocation_audit~get_runs(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_batch            = iv_batch
      iv_unit             = iv_unit ).
    IF iv_unit IS NOT INITIAL.
      rs_summary-unit = iv_unit.
    ENDIF.
    LOOP AT lt_runs ASSIGNING <ls_run>.
      rs_summary-total_runs = rs_summary-total_runs + 1.
      IF lv_summary_unit IS INITIAL.
        lv_summary_unit = <ls_run>-unit.
      ELSEIF lv_summary_unit <> <ls_run>-unit.
        rs_summary-mixed_units = abap_true.
      ENDIF.
      IF rs_summary-mixed_units <> abap_true.
        rs_summary-allocated = rs_summary-allocated + <ls_run>-allocated.
        rs_summary-shortage = rs_summary-shortage + <ls_run>-shortage.
      ENDIF.
      IF <ls_run>-status = 'R'.
        rs_summary-running_runs = rs_summary-running_runs + 1.
      ELSEIF <ls_run>-status = 'S'.
        rs_summary-success_runs = rs_summary-success_runs + 1.
      ELSEIF <ls_run>-status = 'P'.
        rs_summary-partial_runs = rs_summary-partial_runs + 1.
      ELSEIF <ls_run>-status = 'E'.
        rs_summary-error_runs = rs_summary-error_runs + 1.
      ENDIF.
      IF <ls_run>-start_date > rs_summary-last_start_date
          OR ( <ls_run>-start_date = rs_summary-last_start_date
            AND <ls_run>-start_time > rs_summary-last_start_time ).
        rs_summary-last_run_id = <ls_run>-run_id.
        rs_summary-last_start_date = <ls_run>-start_date.
        rs_summary-last_start_time = <ls_run>-start_time.
        rs_summary-last_finish_date = <ls_run>-finish_date.
        rs_summary-last_finish_time = <ls_run>-finish_time.
        rs_summary-last_status = <ls_run>-status.
        rs_summary-last_message = <ls_run>-message.
      ENDIF.
    ENDLOOP.
    IF rs_summary-mixed_units = abap_true.
      CLEAR: rs_summary-allocated,
             rs_summary-shortage,
             rs_summary-unit.
    ELSEIF iv_unit IS INITIAL.
      rs_summary-unit = lv_summary_unit.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~record_rejection.
    DATA ls_run TYPE zstockalloc_run.

    IF iv_message IS INITIAL.
      raise_error( iv_message = 'Audit rejection message is required' ).
    ENDIF.
    IF iv_available < 0.
      raise_error( iv_message = 'Audit rejection metrics are invalid' ).
    ENDIF.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_audit_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Audit write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
    ENDIF.
    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        raise_error( iv_message = 'Audit run ID generation failed' ).
    ENDTRY.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = rv_run_id.
    ls_run-matnr = iv_material.
    ls_run-werks = iv_plant.
    ls_run-lgort = iv_storage_location.
    ls_run-batch = iv_batch.
    ls_run-unit = iv_unit.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = 'E'.
    ls_run-available = iv_available.
    ls_run-message = iv_message.
    MODIFY zstockalloc_run FROM @ls_run.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit rejection persistence failed' ).
    ENDIF.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_transaction_error).
          IF lo_transaction_error->message IS INITIAL.
            lo_transaction_error->message = 'Audit rejection commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_transaction_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_runs.
    DATA lt_filtered TYPE zif_allocation_audit=>tt_runs.
    FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Audit read scope is incomplete' ).
    ENDIF.
    IF iv_start_date_from IS NOT INITIAL
        AND iv_start_date_to IS NOT INITIAL
        AND iv_start_date_from > iv_start_date_to.
      raise_error( iv_message = 'Audit date range is invalid' ).
    ENDIF.
    IF iv_status IS NOT INITIAL
        AND iv_status <> 'R'
        AND iv_status <> 'S'
        AND iv_status <> 'P'
        AND iv_status <> 'E'.
      raise_error( iv_message = 'Audit status is invalid' ).
    ENDIF.
    IF mo_read_authority IS BOUND.
      TRY.
          mo_read_authority->check_audit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_read_error).
          IF lo_read_error->message IS INITIAL.
            lo_read_error->message = 'Audit read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_read_error.
      ENDTRY.
    ENDIF.

    SELECT run_id,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           batch,
           unit,
           start_date,
           start_time,
           finish_date,
           finish_time,
           status,
           available,
           demand_count,
           allocated,
           shortage,
           message
      FROM zstockalloc_run
      INTO TABLE @rt_runs
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND batch = @iv_batch.
    IF sy-subrc <> 0.
      CLEAR rt_runs.
    ENDIF.
    LOOP AT rt_runs ASSIGNING <ls_run>.
      validate_run( is_run = <ls_run> ).
    ENDLOOP.
    IF iv_unit IS NOT INITIAL
        OR iv_start_date_from IS NOT INITIAL
        OR iv_start_date_to IS NOT INITIAL
        OR iv_status IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF iv_status IS INITIAL OR <ls_run>-status = iv_status.
          IF iv_unit IS INITIAL OR <ls_run>-unit = iv_unit.
            IF iv_start_date_from IS INITIAL
                OR <ls_run>-start_date >= iv_start_date_from.
              IF iv_start_date_to IS INITIAL
                  OR <ls_run>-start_date <= iv_start_date_to.
                APPEND <ls_run> TO lt_filtered.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      rt_runs = lt_filtered.
    ENDIF.
    SORT rt_runs BY start_date DESCENDING
                    start_time DESCENDING
                    run_id DESCENDING.
  ENDMETHOD.

  METHOD zif_allocation_audit~start_run.
    DATA ls_run TYPE zstockalloc_run.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_unit IS INITIAL.
      raise_error( iv_message = 'Audit run scope is incomplete' ).
    ENDIF.
    IF iv_available < 0 OR iv_demand_count < 0.
      raise_error( iv_message = 'Audit run inputs are invalid' ).
    ENDIF.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_audit_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Audit write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
    ENDIF.
    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        raise_error( iv_message = 'Audit run ID generation failed' ).
    ENDTRY.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = rv_run_id.
    ls_run-matnr = iv_material.
    ls_run-werks = iv_plant.
    ls_run-lgort = iv_storage_location.
    ls_run-batch = iv_batch.
    ls_run-unit = iv_unit.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = iv_available.
    ls_run-demand_count = iv_demand_count.
    MODIFY zstockalloc_run FROM @ls_run.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit run persistence failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~finish_run.
    DATA lv_current_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_current_available TYPE zif_stock_allocation=>ty_quantity.

    IF iv_run_id IS INITIAL.
      raise_error( iv_message = 'Audit run ID is required' ).
    ENDIF.
    IF iv_status <> 'S'
        AND iv_status <> 'P'
        AND iv_status <> 'E'.
      raise_error( iv_message = 'Audit final status is invalid' ).
    ENDIF.
    IF ( iv_status = 'P' OR iv_status = 'E' )
        AND iv_message IS INITIAL.
      raise_error( iv_message = 'Audit final message is required' ).
    ENDIF.
    IF iv_available < 0
        OR iv_allocated < 0
        OR iv_shortage < 0.
      raise_error( iv_message = 'Audit final metrics are invalid' ).
    ENDIF.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_audit_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Audit write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
    ENDIF.
    SELECT SINGLE status, available
      FROM zstockalloc_run
      INTO (@lv_current_status, @lv_current_available)
      WHERE mandt = @sy-mandt
        AND run_id = @iv_run_id.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit run was not found' ).
    ENDIF.
    IF lv_current_status <> 'R'.
      raise_error( iv_message = 'Audit run is already finalized' ).
    ENDIF.
    IF iv_available <> lv_current_available
        OR iv_allocated > lv_current_available
        OR ( iv_status = 'S' AND iv_shortage <> 0 ).
      raise_error( iv_message = 'Audit final metrics are invalid' ).
    ENDIF.
    UPDATE zstockalloc_run
      SET finish_date = @sy-datum,
          finish_time = @sy-uzeit,
          status      = @iv_status,
          available   = @iv_available,
          allocated   = @iv_allocated,
          shortage    = @iv_shortage,
          message     = @iv_message
      WHERE mandt = @sy-mandt
        AND run_id = @iv_run_id
        AND status = 'R'.
    IF sy-subrc <> 0 OR sy-dbcnt <> 1.
      raise_error( iv_message = 'Audit finalization persistence failed' ).
    ENDIF.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_transaction_error).
          IF lo_transaction_error->message IS INITIAL.
            lo_transaction_error->message = 'Audit finalization commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_transaction_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD validate_run.
    IF is_run-run_id IS INITIAL
        OR is_run-material IS INITIAL
        OR is_run-plant IS INITIAL
        OR is_run-storage_location IS INITIAL
        OR is_run-unit IS INITIAL
        OR is_run-start_date IS INITIAL
        OR is_run-start_time IS INITIAL
        OR is_run-available < 0
        OR is_run-demand_count < 0
        OR is_run-allocated < 0
        OR is_run-shortage < 0
        OR is_run-allocated > is_run-available.
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
    IF is_run-status <> 'R'
        AND is_run-status <> 'S'
        AND is_run-status <> 'P'
        AND is_run-status <> 'E'.
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
    IF ( is_run-status = 'R'
          AND ( is_run-finish_date IS NOT INITIAL
            OR is_run-finish_time IS NOT INITIAL
            OR is_run-allocated <> 0
            OR is_run-shortage <> 0
            OR is_run-message IS NOT INITIAL ) )
        OR ( is_run-status <> 'R'
          AND ( is_run-finish_date IS INITIAL
            OR is_run-finish_time IS INITIAL ) )
        OR ( is_run-status = 'S'
          AND ( is_run-shortage <> 0
            OR is_run-message IS NOT INITIAL ) )
        OR ( ( is_run-status = 'P' OR is_run-status = 'E' )
          AND is_run-message IS INITIAL )
        OR ( is_run-status <> 'R'
          AND ( is_run-finish_date < is_run-start_date
            OR ( is_run-finish_date = is_run-start_date
              AND is_run-finish_time < is_run-start_time ) ) ).
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
