CLASS zcl_allocation_plan_drift DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS compare
      IMPORTING
        is_saved        TYPE zif_stock_allocation=>ty_plan
        is_current      TYPE zif_stock_allocation=>ty_plan
      RETURNING
        VALUE(rs_drift) TYPE zif_stock_allocation=>ty_plan_drift
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    TYPES tt_allocations_by_key TYPE HASHED TABLE OF zif_stock_allocation=>ty_allocation
      WITH UNIQUE KEY sales_order sales_item schedule_line.
ENDCLASS.

CLASS zcl_allocation_plan_drift IMPLEMENTATION.
  METHOD compare.
    zcl_stock_alloc_validator=>validate_plan( is_saved ).
    zcl_stock_alloc_validator=>validate_plan( is_current ).

    rs_drift-severity = zif_stock_allocation=>c_drift_severity_none.
    rs_drift-stock_delta = is_current-stock_qty - is_saved-stock_qty.
    DATA(ls_saved_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = is_saved-allocations ).
    DATA(ls_current_summary) = zcl_stock_alloc_summary=>summarize(
      it_allocations = is_current-allocations ).
    rs_drift-allocated_delta = ls_current_summary-allocated_qty
                             - ls_saved_summary-allocated_qty.
    rs_drift-shortage_delta = ls_current_summary-shortage_qty
                            - ls_saved_summary-shortage_qty.
    rs_drift-context_changed = xsdbool(
      is_current-reserve_qty <> is_saved-reserve_qty
      OR is_current-unit <> is_saved-unit
      OR is_current-strategy <> is_saved-strategy
      OR is_current-start_date <> is_saved-start_date
      OR is_current-cutoff_date <> is_saved-cutoff_date ).

    DATA lt_saved TYPE tt_allocations_by_key.
    DATA lt_current TYPE tt_allocations_by_key.
    lt_saved = is_saved-allocations.
    lt_current = is_current-allocations.
    LOOP AT lt_current INTO DATA(ls_current).
      READ TABLE lt_saved INTO DATA(ls_saved)
        WITH TABLE KEY sales_order = ls_current-sales_order
                       sales_item = ls_current-sales_item
                       schedule_line = ls_current-schedule_line.
      IF sy-subrc <> 0.
        rs_drift-added_count = rs_drift-added_count + 1.
        APPEND VALUE #(
          sales_order           = ls_current-sales_order
          sales_item            = ls_current-sales_item
          schedule_line         = ls_current-schedule_line
          change_type           = zif_stock_allocation=>c_drift_added
          current_requested_qty = ls_current-requested_qty
          current_allocated_qty = ls_current-allocated_qty
          current_status        = ls_current-status ) TO rs_drift-items.
        CONTINUE.
      ENDIF.
      DATA lv_demand_changed TYPE abap_bool.
      DATA lv_outcome_changed TYPE abap_bool.
      IF ls_current-delivery_date <> ls_saved-delivery_date
          OR ls_current-priority <> ls_saved-priority
          OR ls_current-requested_qty <> ls_saved-requested_qty.
        rs_drift-demand_changed_count = rs_drift-demand_changed_count + 1.
        lv_demand_changed = abap_true.
      ENDIF.
      IF ls_current-allocated_qty <> ls_saved-allocated_qty
          OR ls_current-shortage_qty <> ls_saved-shortage_qty
          OR ls_current-status <> ls_saved-status.
        rs_drift-outcome_changed_count = rs_drift-outcome_changed_count + 1.
        lv_outcome_changed = abap_true.
      ENDIF.
      IF lv_demand_changed = abap_true OR lv_outcome_changed = abap_true.
        APPEND VALUE #(
          sales_order           = ls_current-sales_order
          sales_item            = ls_current-sales_item
          schedule_line         = ls_current-schedule_line
          change_type           = zif_stock_allocation=>c_drift_changed
          demand_changed        = lv_demand_changed
          outcome_changed       = lv_outcome_changed
          saved_requested_qty   = ls_saved-requested_qty
          current_requested_qty = ls_current-requested_qty
          saved_allocated_qty   = ls_saved-allocated_qty
          current_allocated_qty = ls_current-allocated_qty
          saved_status          = ls_saved-status
          current_status        = ls_current-status ) TO rs_drift-items.
      ENDIF.
    ENDLOOP.
    LOOP AT lt_saved INTO ls_saved.
      READ TABLE lt_current TRANSPORTING NO FIELDS
        WITH TABLE KEY sales_order = ls_saved-sales_order
                       sales_item = ls_saved-sales_item
                       schedule_line = ls_saved-schedule_line.
      IF sy-subrc <> 0.
        rs_drift-removed_count = rs_drift-removed_count + 1.
        APPEND VALUE #(
          sales_order         = ls_saved-sales_order
          sales_item          = ls_saved-sales_item
          schedule_line       = ls_saved-schedule_line
          change_type         = zif_stock_allocation=>c_drift_removed
          saved_requested_qty = ls_saved-requested_qty
          saved_allocated_qty = ls_saved-allocated_qty
          saved_status        = ls_saved-status ) TO rs_drift-items.
      ENDIF.
    ENDLOOP.
    SORT rs_drift-items BY sales_order sales_item schedule_line change_type.
    rs_drift-has_drift = xsdbool(
      rs_drift-stock_delta <> 0
      OR rs_drift-context_changed = abap_true
      OR rs_drift-added_count > 0
      OR rs_drift-removed_count > 0
      OR rs_drift-demand_changed_count > 0
      OR rs_drift-outcome_changed_count > 0 ).
    IF rs_drift-outcome_changed_count > 0.
      rs_drift-severity = zif_stock_allocation=>c_drift_severity_outcome.
    ELSEIF rs_drift-added_count > 0
        OR rs_drift-removed_count > 0
        OR rs_drift-demand_changed_count > 0.
      rs_drift-severity = zif_stock_allocation=>c_drift_severity_demand.
    ELSEIF rs_drift-has_drift = abap_true.
      rs_drift-severity = zif_stock_allocation=>c_drift_severity_stock.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
