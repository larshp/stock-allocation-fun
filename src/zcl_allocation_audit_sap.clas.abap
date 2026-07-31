CLASS zcl_allocation_audit_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_audit.
ENDCLASS.

CLASS zcl_allocation_audit_sap IMPLEMENTATION.
  METHOD zif_allocation_audit~purge_runs_before.
    IF iv_before_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    DELETE FROM zstockalloc_run
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND start_date < @iv_before_date
        AND status <> 'R'.
    rv_deleted = sy-dbcnt.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_summary.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

    lt_runs = zif_allocation_audit~get_runs(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    LOOP AT lt_runs ASSIGNING <ls_run>.
      rs_summary-total_runs = rs_summary-total_runs + 1.
      rs_summary-allocated = rs_summary-allocated + <ls_run>-allocated.
      rs_summary-shortage = rs_summary-shortage + <ls_run>-shortage.
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
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_runs.
    SELECT run_id,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
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
        AND lgort = @iv_storage_location.
    IF sy-subrc <> 0.
      CLEAR rt_runs.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~start_run.
    DATA ls_run TYPE zstockalloc_run.

    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDTRY.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = rv_run_id.
    ls_run-matnr = iv_material.
    ls_run-werks = iv_plant.
    ls_run-lgort = iv_storage_location.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = iv_available.
    ls_run-demand_count = iv_demand_count.
    MODIFY zstockalloc_run FROM @ls_run.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~finish_run.
    DATA ls_run TYPE zstockalloc_run.

    SELECT SINGLE *
      FROM zstockalloc_run
      INTO @ls_run
      WHERE mandt = @sy-mandt
        AND run_id = @iv_run_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = iv_status.
    ls_run-available = iv_available.
    ls_run-allocated = iv_allocated.
    ls_run-shortage = iv_shortage.
    ls_run-message = iv_message.
    MODIFY zstockalloc_run FROM @ls_run.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
