REPORT zstock_allocate.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_loc OBLIGATORY.
PARAMETERS p_resrv TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_strat TYPE zif_stock_allocation=>ty_strategy DEFAULT 'F'.
PARAMETERS p_cutof TYPE zif_stock_allocation=>ty_cutoff_date.
PARAMETERS p_sim AS CHECKBOX DEFAULT 'X'.
PARAMETERS p_comp AS CHECKBOX DEFAULT ''.

START-OF-SELECTION.
  DATA(lo_service) = NEW zcl_stock_allocation_service(
    io_stock_source = NEW zcl_stock_source_sap( )
    io_demand_source = NEW zcl_demand_source_sap( )
    io_allocation_sink = NEW zcl_allocation_sink_sap( )
    io_allocation_lock = NEW zcl_allocation_lock_sap( )
    io_authorization = NEW zcl_allocation_auth_sap( )
    io_allocation_log = NEW zcl_allocation_log_sap( ) ).

  TRY.
      IF p_comp = abap_true.
        DATA(lt_plans) = lo_service->preview_all_strategies(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_reserve = p_resrv
          iv_cutoff_date = p_cutof ).
        WRITE: / 'Strategy comparison (simulation only)'.
        WRITE: / 'Scope', p_matnr, p_werks, p_lgort, 'Cutoff', p_cutof.
        LOOP AT lt_plans INTO DATA(ls_compared_plan).
          DATA(ls_compared_summary) = zcl_stock_alloc_summary=>summarize(
            it_allocations = ls_compared_plan-allocations
            iv_stock_qty = ls_compared_plan-stock_qty
            iv_allocatable_qty = ls_compared_plan-allocatable_qty
            iv_reserve = ls_compared_plan-reserve_qty
            iv_unit = ls_compared_plan-unit ).
          WRITE: / 'Strategy', ls_compared_plan-strategy,
                   'Full', ls_compared_summary-full_count,
                   'Partial', ls_compared_summary-partial_count,
                   'None', ls_compared_summary-none_count,
                   'Fill %', ls_compared_summary-quantity_fill_pct,
                   'Service %', ls_compared_summary-service_level_pct,
                   'Allocated', ls_compared_summary-allocated_qty,
                   'Shortage', ls_compared_summary-shortage_qty,
                   ls_compared_summary-unit.
        ENDLOOP.
        RETURN.
      ENDIF.

      DATA ls_plan TYPE zif_stock_allocation=>ty_plan.
      IF p_sim = abap_true.
        ls_plan = lo_service->preview_plan(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_reserve = p_resrv
          iv_strategy = p_strat
          iv_cutoff_date = p_cutof ).
        WRITE / 'Simulation: no allocations were persisted'.
      ELSE.
        ls_plan = lo_service->run_plan(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_reserve = p_resrv
          iv_strategy = p_strat
          iv_cutoff_date = p_cutof ).
        COMMIT WORK AND WAIT.
        IF sy-subrc <> 0.
          RAISE EXCEPTION NEW zcx_stock_allocation(
            'Synchronous allocation commit failed' ).
        ENDIF.
      ENDIF.

      DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
        it_allocations = ls_plan-allocations
        iv_stock_qty = ls_plan-stock_qty
        iv_allocatable_qty = ls_plan-allocatable_qty
        iv_reserve = ls_plan-reserve_qty
        iv_unit = ls_plan-unit ).
      WRITE: / 'Scope', p_matnr, p_werks, p_lgort,
               'Strategy', ls_plan-strategy,
               'Cutoff', ls_plan-cutoff_date.
      WRITE: / 'Demands', ls_summary-demand_count,
               'Stock', ls_summary-stock_qty,
               'Allocatable', ls_summary-allocatable_qty,
               'Requested', ls_summary-requested_qty,
               'Allocated', ls_summary-allocated_qty,
               'Shortage', ls_summary-shortage_qty,
               'Fill %', ls_summary-quantity_fill_pct,
               'Service %', ls_summary-service_level_pct,
               'Reserve', ls_summary-reserve_qty,
               ls_summary-unit.
      WRITE: / 'Full', ls_summary-full_count,
               'Partial', ls_summary-partial_count,
               'None', ls_summary-none_count.

      LOOP AT ls_plan-allocations INTO DATA(ls_allocation).
        WRITE: / ls_allocation-sales_order,
                 ls_allocation-sales_item,
                 ls_allocation-schedule_line,
                 ls_allocation-delivery_date,
                 ls_allocation-priority,
                 ls_allocation-requested_qty,
                 ls_allocation-allocated_qty,
                 ls_allocation-shortage_qty,
                 ls_allocation-reserve_qty,
                 ls_allocation-unit,
                 ls_allocation-strategy,
                 ls_allocation-status.
      ENDLOOP.
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      ROLLBACK WORK.
      MESSAGE lo_error TYPE 'E'.
  ENDTRY.
