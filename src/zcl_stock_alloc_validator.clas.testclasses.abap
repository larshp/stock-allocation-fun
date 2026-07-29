CLASS ltcl_stock_alloc_validator DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS rejects_incomplete_demand FOR TESTING.
    METHODS allows_ignored_nonpositive FOR TESTING RAISING zcx_stock_allocation.
    METHODS accepts_known_strategies FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_unknown_strategy FOR TESTING.
    METHODS validates_planning_window FOR TESTING.
    METHODS validates_plan_invariants FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_alloc_validator IMPLEMENTATION.
  METHOD rejects_incomplete_demand.
    TRY.
        zcl_stock_alloc_validator=>validate_demands( VALUE #(
          ( sales_order   = '1'
            sales_item    = '000010'
            schedule_line = '0000'
            delivery_date = '20250101'
            requested_qty = '1' ) ) ).
        cl_abap_unit_assert=>fail( 'Incomplete positive demand must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD allows_ignored_nonpositive.
    zcl_stock_alloc_validator=>validate_demands( VALUE #(
      ( sales_order   = ''
        sales_item    = '000000'
        schedule_line = '0000'
        delivery_date = '00000000'
        requested_qty = '0' ) ) ).
  ENDMETHOD.

  METHOD accepts_known_strategies.
    zcl_stock_alloc_validator=>validate_strategy(
      zif_stock_allocation=>c_strategy_fifo ).
    zcl_stock_alloc_validator=>validate_strategy(
      zif_stock_allocation=>c_strategy_proportional ).
    zcl_stock_alloc_validator=>validate_strategy(
      zif_stock_allocation=>c_strategy_fair_share ).
    zcl_stock_alloc_validator=>validate_strategy(
      zif_stock_allocation=>c_strategy_smallest_first ).
    zcl_stock_alloc_validator=>validate_strategy(
      zif_stock_allocation=>c_strategy_complete_only ).
  ENDMETHOD.

  METHOD rejects_unknown_strategy.
    TRY.
        zcl_stock_alloc_validator=>validate_strategy( 'X' ).
        cl_abap_unit_assert=>fail( 'Unknown strategy must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD validates_planning_window.
    TRY.
        zcl_stock_alloc_validator=>validate_window(
          iv_start_date  = '20260802'
          iv_cutoff_date = '20260801' ).
        cl_abap_unit_assert=>fail( 'Reversed planning window must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    TRY.
        zcl_stock_alloc_validator=>validate_window(
          iv_start_date  = '20260801'
          iv_cutoff_date = '20260802' ).
      CATCH zcx_stock_allocation.
        cl_abap_unit_assert=>fail( 'Ordered planning window must pass' ).
    ENDTRY.
  ENDMETHOD.

  METHOD validates_plan_invariants.
    DATA(ls_valid) = VALUE zif_stock_allocation=>ty_plan(
      stock_qty       = '3'
      allocatable_qty = '2'
      reserve_qty     = '1'
      unit            = 'EA'
      strategy        = zif_stock_allocation=>c_strategy_fifo
      start_date      = '20260801'
      cutoff_date     = '20260831'
      allocations     = VALUE #(
        ( sales_order   = '1'
          sales_item    = '000010'
          schedule_line = '0001'
          delivery_date = '20260815'
          requested_qty = '3'
          allocated_qty = '2'
          shortage_qty  = '1'
          reserve_qty   = '1'
          unit          = 'EA'
          strategy      = zif_stock_allocation=>c_strategy_fifo
          start_date    = '20260801'
          cutoff_date   = '20260831'
          status        = zif_stock_allocation=>c_status_partial ) ) ).
    TRY.
        zcl_stock_alloc_validator=>validate_plan( ls_valid ).
      CATCH zcx_stock_allocation.
        cl_abap_unit_assert=>fail( 'Consistent allocation plan must pass' ).
    ENDTRY.

    DATA(ls_invalid_row) = ls_valid.
    ls_invalid_row-allocations[ 1 ]-shortage_qty = '2'.
    TRY.
        zcl_stock_alloc_validator=>validate_plan( ls_invalid_row ).
        cl_abap_unit_assert=>fail( 'Inconsistent row arithmetic must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_row_error).
        cl_abap_unit_assert=>assert_not_initial( lo_row_error->get_text( ) ).
    ENDTRY.

    DATA(ls_excess_total) = ls_valid.
    ls_excess_total-allocatable_qty = '1'.
    TRY.
        zcl_stock_alloc_validator=>validate_plan( ls_excess_total ).
        cl_abap_unit_assert=>fail( 'Excess total allocation must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_total_error).
        cl_abap_unit_assert=>assert_not_initial( lo_total_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
