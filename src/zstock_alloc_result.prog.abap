REPORT zstock_alloc_result.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location OBLIGATORY.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit OBLIGATORY.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
  FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

  CREATE OBJECT lo_authority TYPE zcl_allocation_read_authority_sap.
  TRY.
      lo_authority->check_results( ).
    CATCH zcx_stock_allocation INTO DATA(lo_auth_error).
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
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_batch            = p_charg
        iv_unit             = p_meins ).
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      IF lo_error->message IS INITIAL.
        WRITE: / 'Allocation results are unavailable for the requested scope.'.
      ELSE.
        WRITE: / 'Allocation results are unavailable:', lo_error->message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF lines( lt_demands ) = 0.
    WRITE: / 'No allocation results found.'.
    RETURN.
  ENDIF.

  WRITE: / 'Run', 34 'Sales document', 50 'Type', 56 'Item', 64 'Schedule',
           70 'Requested on',
           84 'Alloc.unit', 96 'Order.unit', 108 'Requested', 122 'Allocated',
           136 'Shortage', 148 'Status', 156 'Reservation', 178 'Res.date',
           190 'Res.move', 200 'Res.unit'.
  LOOP AT lt_demands ASSIGNING <ls_demand>.
    WRITE: / <ls_demand>-allocation_run_id,
             34 <ls_demand>-sales_document,
             50 <ls_demand>-sales_document_type,
             56 <ls_demand>-sales_item,
             64 <ls_demand>-schedule_line,
             70 <ls_demand>-requested_on,
             84 <ls_demand>-allocation_unit,
             96 <ls_demand>-order_unit,
             108 <ls_demand>-requested,
             122 <ls_demand>-allocated,
             136 <ls_demand>-shortage,
             148 <ls_demand>-allocation_status,
             156 <ls_demand>-reservation_id,
             178 <ls_demand>-reservation_date,
             190 <ls_demand>-reservation_movement_type,
             200 <ls_demand>-reservation_unit.
  ENDLOOP.
