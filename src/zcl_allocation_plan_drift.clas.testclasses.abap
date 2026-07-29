CLASS ltcl_allocation_plan_drift DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS detects_live_changes FOR TESTING RAISING zcx_stock_allocation.
    METHODS accepts_identical_plans FOR TESTING RAISING zcx_stock_allocation.
    METHODS classifies_stock_only FOR TESTING RAISING zcx_stock_allocation.
    METHODS classifies_demand_only FOR TESTING RAISING zcx_stock_allocation.
    METHODS build_saved
      RETURNING
        VALUE(rs_plan) TYPE zif_stock_allocation=>ty_plan.
ENDCLASS.

CLASS ltcl_allocation_plan_drift IMPLEMENTATION.
  METHOD build_saved.
    rs_plan = VALUE #(
      stock_qty       = '10'
      allocatable_qty = '10'
      unit            = 'EA'
      strategy        = zif_stock_allocation=>c_strategy_fifo
      allocations     = VALUE #(
        ( sales_order   = '1'
          sales_item    = '000010'
          schedule_line = '0001'
          delivery_date = '20260801'
          requested_qty = '5'
          allocated_qty = '5'
          shortage_qty  = '0'
          unit          = 'EA'
          strategy      = zif_stock_allocation=>c_strategy_fifo
          status        = zif_stock_allocation=>c_status_full )
        ( sales_order   = '2'
          sales_item    = '000010'
          schedule_line = '0001'
          delivery_date = '20260802'
          requested_qty = '3'
          allocated_qty = '0'
          shortage_qty  = '3'
          unit          = 'EA'
          strategy      = zif_stock_allocation=>c_strategy_fifo
          status        = zif_stock_allocation=>c_status_none ) ) ).
  ENDMETHOD.

  METHOD detects_live_changes.
    DATA(ls_current) = VALUE zif_stock_allocation=>ty_plan(
      stock_qty       = '9'
      allocatable_qty = '9'
      unit            = 'EA'
      strategy        = zif_stock_allocation=>c_strategy_fifo
      allocations     = VALUE #(
        ( sales_order   = '1'
          sales_item    = '000010'
          schedule_line = '0001'
          delivery_date = '20260801'
          requested_qty = '6'
          allocated_qty = '4'
          shortage_qty  = '2'
          unit          = 'EA'
          strategy      = zif_stock_allocation=>c_strategy_fifo
          status        = zif_stock_allocation=>c_status_partial )
        ( sales_order   = '3'
          sales_item    = '000010'
          schedule_line = '0001'
          delivery_date = '20260803'
          requested_qty = '2'
          allocated_qty = '2'
          shortage_qty  = '0'
          unit          = 'EA'
          strategy      = zif_stock_allocation=>c_strategy_fifo
          status        = zif_stock_allocation=>c_status_full ) ) ).

    DATA(ls_drift) = zcl_allocation_plan_drift=>compare(
      is_saved   = build_saved( )
      is_current = ls_current ).

    cl_abap_unit_assert=>assert_true( ls_drift-has_drift ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-severity
      exp = zif_stock_allocation=>c_drift_severity_outcome ).
    cl_abap_unit_assert=>assert_false( ls_drift-context_changed ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-stock_delta exp = '-1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-allocated_delta exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-shortage_delta exp = '-1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-added_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-removed_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-demand_changed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-outcome_changed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_drift-items ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 1 ]-change_type
      exp = zif_stock_allocation=>c_drift_changed ).
    cl_abap_unit_assert=>assert_true( ls_drift-items[ 1 ]-demand_changed ).
    cl_abap_unit_assert=>assert_true( ls_drift-items[ 1 ]-outcome_changed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 1 ]-saved_requested_qty
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 1 ]-current_requested_qty
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 1 ]-saved_allocated_qty
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 1 ]-current_allocated_qty
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 2 ]-change_type
      exp = zif_stock_allocation=>c_drift_removed ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-items[ 3 ]-change_type
      exp = zif_stock_allocation=>c_drift_added ).
  ENDMETHOD.

  METHOD accepts_identical_plans.
    DATA(ls_plan) = build_saved( ).
    DATA(ls_drift) = zcl_allocation_plan_drift=>compare(
      is_saved   = ls_plan
      is_current = ls_plan ).

    cl_abap_unit_assert=>assert_false( ls_drift-has_drift ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-severity
      exp = zif_stock_allocation=>c_drift_severity_none ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-stock_delta exp = 0 ).
    cl_abap_unit_assert=>assert_initial( ls_drift-items ).
  ENDMETHOD.

  METHOD classifies_stock_only.
    DATA(ls_saved) = build_saved( ).
    DATA(ls_current) = ls_saved.
    ls_current-stock_qty = '9'.
    ls_current-allocatable_qty = '9'.

    DATA(ls_drift) = zcl_allocation_plan_drift=>compare(
      is_saved   = ls_saved
      is_current = ls_current ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-severity
      exp = zif_stock_allocation=>c_drift_severity_stock ).
  ENDMETHOD.

  METHOD classifies_demand_only.
    DATA(ls_saved) = build_saved( ).
    DATA(ls_current) = ls_saved.
    ls_current-allocations[ 1 ]-delivery_date = '20260803'.

    DATA(ls_drift) = zcl_allocation_plan_drift=>compare(
      is_saved   = ls_saved
      is_current = ls_current ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-severity
      exp = zif_stock_allocation=>c_drift_severity_demand ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-demand_changed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_drift-outcome_changed_count
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
