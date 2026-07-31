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
  ENDMETHOD.

  METHOD zif_allocation_audit~get_summary.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
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
        rs_summary-last_status = <ls_run>-status.
        rs_summary-last_message = <ls_run>-message.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_allocation_audit~record_rejection.
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
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_runs.
    DATA lt_filtered TYPE zif_allocation_audit=>tt_runs.
    FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

    IF iv_start_date_from IS NOT INITIAL
        AND iv_start_date_to IS NOT INITIAL
        AND iv_start_date_from > iv_start_date_to.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_status IS NOT INITIAL
        AND iv_status <> 'R'
        AND iv_status <> 'S'
        AND iv_status <> 'P'
        AND iv_status <> 'E'.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
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
    ls_run-batch = iv_batch.
    ls_run-unit = iv_unit.
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
