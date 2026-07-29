REPORT zstock_plan_view.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_loc OBLIGATORY.
PARAMETERS p_maxage TYPE i DEFAULT 1.

START-OF-SELECTION.
  DATA(lo_service) = NEW zcl_allocation_query_service(
    io_source        = NEW zcl_allocation_source_sap( )
    io_authorization = NEW zcl_allocation_auth_sap( ) ).

  TRY.
      DATA(ls_saved) = lo_service->get_saved(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_max_age_days     = p_maxage ).
      IF ls_saved-found = abap_false.
        WRITE / 'No persisted allocation plan exists for this scope'.
        RETURN.
      ENDIF.

      DATA(ls_summary) = zcl_stock_alloc_summary=>summarize(
        it_allocations     = ls_saved-plan-allocations
        iv_stock_qty       = ls_saved-plan-stock_qty
        iv_allocatable_qty = ls_saved-plan-allocatable_qty
        iv_reserve         = ls_saved-plan-reserve_qty
        iv_unit            = ls_saved-plan-unit ).
      WRITE: / 'Persisted scope', p_matnr, p_werks, p_lgort.
      WRITE: / 'Created', ls_saved-created_on, ls_saved-created_at,
               'By', ls_saved-created_by, 'Age days', ls_saved-age_days.
      IF ls_saved-stale = abap_true.
        WRITE / 'Warning: persisted allocation plan exceeds the maximum age'.
      ENDIF.
      WRITE: / 'Strategy', ls_saved-plan-strategy,
               'Window', ls_saved-plan-start_date, ls_saved-plan-cutoff_date.
      WRITE: / 'Demands', ls_summary-demand_count,
               'Stock', ls_summary-stock_qty,
               'Allocatable', ls_summary-allocatable_qty,
               'Requested', ls_summary-requested_qty,
               'Allocated', ls_summary-allocated_qty,
               'Shortage', ls_summary-shortage_qty,
               'Reserve', ls_summary-reserve_qty,
               ls_summary-unit.
      WRITE: / 'Full', ls_summary-full_count,
               'Partial', ls_summary-partial_count,
               'None', ls_summary-none_count,
               'Fill %', ls_summary-quantity_fill_pct,
               'Service %', ls_summary-service_level_pct,
               'Utilization %', ls_summary-stock_utilization_pct,
               'Fairness %', ls_summary-fairness_pct.
      LOOP AT ls_saved-plan-allocations INTO DATA(ls_allocation).
        WRITE: / ls_allocation-sales_order,
                 ls_allocation-sales_item,
                 ls_allocation-schedule_line,
                 ls_allocation-delivery_date,
                 ls_allocation-priority,
                 ls_allocation-requested_qty,
                 ls_allocation-allocated_qty,
                 ls_allocation-shortage_qty,
                 ls_allocation-unit,
                 ls_allocation-status.
      ENDLOOP.
    CATCH zcx_stock_allocation INTO DATA(lo_error).
      MESSAGE lo_error TYPE 'E'.
  ENDTRY.
