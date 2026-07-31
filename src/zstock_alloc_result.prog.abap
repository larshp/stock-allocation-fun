REPORT zstock_alloc_result.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
  FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
  TRY.
      lt_demands = lo_sink->get_allocations(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins ).
    CATCH zcx_stock_allocation.
      WRITE: / 'Allocation results are unavailable for the requested scope.'.
      RETURN.
  ENDTRY.

  IF lines( lt_demands ) = 0.
    WRITE: / 'No allocation results found.'.
    RETURN.
  ENDIF.

  WRITE: / 'Run', 34 'Sales document', 50 'Type', 56 'Item', 64 'Schedule',
           74 'Unit', 80 'Requested', 94 'Allocated', 108 'Shortage',
           122 'Status', 130 'Reservation'.
  LOOP AT lt_demands ASSIGNING <ls_demand>.
    WRITE: / <ls_demand>-allocation_run_id,
             34 <ls_demand>-sales_document,
             50 <ls_demand>-sales_document_type,
             56 <ls_demand>-sales_item,
             64 <ls_demand>-schedule_line,
             74 <ls_demand>-order_unit,
             80 <ls_demand>-requested,
             94 <ls_demand>-allocated,
             108 <ls_demand>-shortage,
             122 <ls_demand>-allocation_status,
             130 <ls_demand>-reservation_id.
  ENDLOOP.
