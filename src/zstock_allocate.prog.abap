REPORT zstock_allocate.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_loc OBLIGATORY.

START-OF-SELECTION.
  DATA(lo_service) = NEW zcl_stock_allocation_service(
    io_stock_source = NEW zcl_stock_source_sap( )
    io_demand_source = NEW zcl_demand_source_sap( )
    io_allocation_sink = NEW zcl_allocation_sink_sap( ) ).

  DATA(lt_allocations) = lo_service->run(
    iv_material = p_matnr
    iv_plant = p_werks
    iv_storage_location = p_lgort ).
  COMMIT WORK AND WAIT.

  LOOP AT lt_allocations INTO DATA(ls_allocation).
    WRITE: / ls_allocation-sales_order,
             ls_allocation-sales_item,
             ls_allocation-schedule_line,
             ls_allocation-requested_qty,
             ls_allocation-allocated_qty,
             ls_allocation-shortage_qty,
             ls_allocation-status.
  ENDLOOP.
