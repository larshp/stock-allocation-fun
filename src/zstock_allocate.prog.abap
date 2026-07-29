REPORT zstock_allocate.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_loc OBLIGATORY.
PARAMETERS p_resrv TYPE zif_stock_allocation=>ty_quantity DEFAULT 0.
PARAMETERS p_sim AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.
  DATA(lo_service) = NEW zcl_stock_allocation_service(
    io_stock_source = NEW zcl_stock_source_sap( )
    io_demand_source = NEW zcl_demand_source_sap( )
    io_allocation_sink = NEW zcl_allocation_sink_sap( )
    io_allocation_lock = NEW zcl_allocation_lock_sap( )
    io_authorization = NEW zcl_allocation_auth_sap( )
    io_allocation_log = NEW zcl_allocation_log_sap( ) ).

  TRY.
      DATA lt_allocations TYPE zif_stock_allocation=>tt_allocations.
      IF p_sim = abap_true.
        lt_allocations = lo_service->preview(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_reserve = p_resrv ).
        WRITE / 'Simulation: no allocations were persisted'.
      ELSE.
        lt_allocations = lo_service->run(
          iv_material = p_matnr
          iv_plant = p_werks
          iv_storage_location = p_lgort
          iv_reserve = p_resrv ).
        COMMIT WORK AND WAIT.
      ENDIF.

      DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
        it_allocations = lt_allocations
        iv_reserve = p_resrv ).
      WRITE: / 'Demands', ls_summary-demand_count,
               'Requested', ls_summary-requested_qty,
               'Allocated', ls_summary-allocated_qty,
               'Shortage', ls_summary-shortage_qty,
               'Reserve', ls_summary-reserve_qty,
               ls_summary-unit.
      WRITE: / 'Full', ls_summary-full_count,
               'Partial', ls_summary-partial_count,
               'None', ls_summary-none_count.

      LOOP AT lt_allocations INTO DATA(ls_allocation).
        WRITE: / ls_allocation-sales_order,
                 ls_allocation-sales_item,
                 ls_allocation-schedule_line,
                 ls_allocation-priority,
                 ls_allocation-requested_qty,
                 ls_allocation-allocated_qty,
                 ls_allocation-shortage_qty,
                 ls_allocation-reserve_qty,
                 ls_allocation-unit,
                 ls_allocation-status.
      ENDLOOP.
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      ROLLBACK WORK.
      WRITE / lo_error->get_text( ).
  ENDTRY.
