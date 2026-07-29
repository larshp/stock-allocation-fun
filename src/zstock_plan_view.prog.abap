REPORT zstock_plan_view.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material OBLIGATORY.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant OBLIGATORY.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_loc OBLIGATORY.
PARAMETERS p_maxage TYPE i DEFAULT 1.
PARAMETERS p_versn TYPE i DEFAULT 0.
PARAMETERS p_list AS CHECKBOX DEFAULT ''.
PARAMETERS p_limit TYPE i DEFAULT 20.
PARAMETERS p_before TYPE i DEFAULT 0.
PARAMETERS p_live AS CHECKBOX DEFAULT ''.
PARAMETERS p_agnst TYPE i DEFAULT 0.

START-OF-SELECTION.
  DATA(lo_query_service) = NEW zcl_allocation_query_service(
    io_source        = NEW zcl_allocation_source_sap( )
    io_authorization = NEW zcl_allocation_auth_sap( ) ).

  TRY.
      IF p_list = abap_true.
        DATA(lt_versions) = lo_query_service->list_versions(
          iv_material         = p_matnr
          iv_plant            = p_werks
          iv_storage_location = p_lgort
          iv_max_versions     = p_limit
          iv_before_version   = p_before ).
        IF lt_versions IS INITIAL.
          WRITE / 'No persisted allocation plan history exists for this scope'.
          RETURN.
        ENDIF.
        WRITE: / 'Historical versions for scope', p_matnr, p_werks, p_lgort.
        LOOP AT lt_versions INTO DATA(ls_version).
          WRITE: / 'Version', ls_version-version_no,
                   'Created', ls_version-created_on, ls_version-created_at,
                   'By', ls_version-created_by,
                   'Demands', ls_version-demand_count,
                   'Stock', ls_version-stock_qty,
                   'Allocatable', ls_version-allocatable_qty,
                   'Reserve', ls_version-reserve_qty,
                   ls_version-unit,
                   'Strategy', ls_version-strategy.
        ENDLOOP.
        RETURN.
      ENDIF.
      DATA(ls_saved) = lo_query_service->get_saved(
        iv_material         = p_matnr
        iv_plant            = p_werks
        iv_storage_location = p_lgort
        iv_max_age_days     = p_maxage
        iv_version_no       = p_versn ).
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
      WRITE: / 'Persisted scope', p_matnr, p_werks, p_lgort,
               'Version', ls_saved-version_no.
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
      IF p_agnst < 0.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Comparison plan version cannot be negative' ).
      ENDIF.
      IF p_live = abap_true AND p_agnst > 0.
        RAISE EXCEPTION NEW zcx_stock_allocation(
          'Choose either live or saved-version comparison' ).
      ENDIF.
      IF p_live = abap_true OR p_agnst > 0.
        DATA ls_current TYPE zif_stock_allocation=>ty_plan.
        IF p_agnst > 0.
          DATA(ls_comparison) = lo_query_service->get_saved(
            iv_material         = p_matnr
            iv_plant            = p_werks
            iv_storage_location = p_lgort
            iv_max_age_days     = p_maxage
            iv_version_no       = p_agnst ).
          IF ls_comparison-found = abap_false.
            WRITE: / 'Comparison plan version does not exist', p_agnst.
            RETURN.
          ENDIF.
          ls_current = ls_comparison-plan.
          WRITE: / 'Comparing saved versions', ls_saved-version_no,
                   'to', ls_comparison-version_no.
        ELSE.
          DATA(lo_allocation_service) = NEW zcl_stock_allocation_service(
            io_stock_source    = NEW zcl_stock_source_sap( )
            io_demand_source   = NEW zcl_demand_source_sap( )
            io_allocation_sink = NEW zcl_allocation_sink_sap( )
            io_allocation_lock = NEW zcl_allocation_lock_sap( )
            io_authorization   = NEW zcl_allocation_auth_sap( )
            io_allocation_log  = NEW zcl_allocation_log_sap( ) ).
          ls_current = lo_allocation_service->preview_plan(
            iv_material         = p_matnr
            iv_plant            = p_werks
            iv_storage_location = p_lgort
            iv_reserve          = ls_saved-plan-reserve_qty
            iv_strategy         = ls_saved-plan-strategy
            iv_start_date       = ls_saved-plan-start_date
            iv_cutoff_date      = ls_saved-plan-cutoff_date ).
          WRITE / 'Comparing saved version to live planning data'.
        ENDIF.
        DATA(ls_drift) = zcl_allocation_plan_drift=>compare(
          is_saved   = ls_saved-plan
          is_current = ls_current ).
        WRITE: / 'Drift', ls_drift-has_drift,
                 'Severity', ls_drift-severity,
                 'Stock delta', ls_drift-stock_delta,
                 'Allocated delta', ls_drift-allocated_delta,
                 'Shortage delta', ls_drift-shortage_delta,
                 'Added', ls_drift-added_count,
                 'Removed', ls_drift-removed_count,
                 'Demand changed', ls_drift-demand_changed_count,
                 'Outcome changed', ls_drift-outcome_changed_count.
        LOOP AT ls_drift-items INTO DATA(ls_drift_item).
          WRITE: / 'Drift item', ls_drift_item-change_type,
                   ls_drift_item-sales_order,
                   ls_drift_item-sales_item,
                   ls_drift_item-schedule_line,
                   'Demand changed', ls_drift_item-demand_changed,
                   'Outcome changed', ls_drift_item-outcome_changed,
                   'Requested', ls_drift_item-saved_requested_qty,
                   ls_drift_item-current_requested_qty,
                   'Allocated', ls_drift_item-saved_allocated_qty,
                   ls_drift_item-current_allocated_qty,
                   'Status', ls_drift_item-saved_status,
                   ls_drift_item-current_status.
        ENDLOOP.
      ENDIF.
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
