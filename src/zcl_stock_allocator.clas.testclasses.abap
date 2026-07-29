CLASS ltcl_stock_allocator DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS allocates_fifo FOR TESTING RAISING zcx_stock_allocation.
    METHODS handles_shortage FOR TESTING RAISING zcx_stock_allocation.
    METHODS ignores_invalid_demand FOR TESTING RAISING zcx_stock_allocation.
    METHODS clamps_negative_stock FOR TESTING RAISING zcx_stock_allocation.
    METHODS honors_priority_before_fifo FOR TESTING RAISING zcx_stock_allocation.
    METHODS allocates_proportionally FOR TESTING RAISING zcx_stock_allocation.
    METHODS allocates_max_min_fairly FOR TESTING RAISING zcx_stock_allocation.
    METHODS preserves_priority_tiers FOR TESTING RAISING zcx_stock_allocation.
    METHODS conserves_rounded_stock FOR TESTING RAISING zcx_stock_allocation.
    METHODS maximizes_full_demands FOR TESTING RAISING zcx_stock_allocation.
    METHODS all_strategies_keep_priorities FOR TESTING RAISING zcx_stock_allocation.
    METHODS avoids_partial_shipments FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_unknown_strategy FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD allocates_fifo.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '4' )
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '3' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '10'
      it_demands   = lt_demands
      iv_unit      = 'EA' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-sales_order exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-status exp = zif_stock_allocation=>c_status_full ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-unit exp = 'EA' ).
  ENDMETHOD.

  METHOD handles_shortage.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '3' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '4' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103' requested_qty = '2' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '5'
      it_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-shortage_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-status exp = zif_stock_allocation=>c_status_partial ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-status exp = zif_stock_allocation=>c_status_none ).
  ENDMETHOD.

  METHOD ignores_invalid_demand.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '0' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '-1' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '5'
      it_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_initial( lt_result ).
  ENDMETHOD.

  METHOD clamps_negative_stock.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '3' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '-1'
      it_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty exp = '3' ).
  ENDMETHOD.

  METHOD honors_priority_before_fifo.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order   = '1'
        sales_item    = '000010'
        delivery_date = '20250101'
        priority      = 0
        requested_qty = '4' )
      ( sales_order   = '2'
        sales_item    = '000010'
        delivery_date = '20250110'
        priority      = 10
        requested_qty = '3' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '3'
      it_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-sales_order exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-status exp = zif_stock_allocation=>c_status_none ).
  ENDMETHOD.

  METHOD allocates_proportionally.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '2' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '6' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '4'
      it_demands   = lt_demands
      iv_strategy  = zif_stock_allocation=>c_strategy_proportional ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-strategy
      exp = zif_stock_allocation=>c_strategy_proportional ).
  ENDMETHOD.

  METHOD allocates_max_min_fairly.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '10' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '1' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103' requested_qty = '10' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '6'
      it_demands   = lt_demands
      iv_strategy  = zif_stock_allocation=>c_strategy_fair_share ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '2.5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-allocated_qty exp = '2.5' ).
  ENDMETHOD.

  METHOD preserves_priority_tiers.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' priority = 0 requested_qty = '10' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' priority = 5 requested_qty = '2' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103' priority = 5 requested_qty = '6' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '4'
      it_demands   = lt_demands
      iv_strategy  = zif_stock_allocation=>c_strategy_proportional ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-allocated_qty exp = '0' ).
  ENDMETHOD.

  METHOD conserves_rounded_stock.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '1' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '1' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103' requested_qty = '1' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '1'
      it_demands   = lt_demands
      iv_strategy  = zif_stock_allocation=>c_strategy_proportional ).
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    LOOP AT lt_result INTO DATA(ls_result).
      lv_allocated = lv_allocated + ls_result-allocated_qty.
      cl_abap_unit_assert=>assert_equals(
        act = ls_result-requested_qty
        exp = ls_result-allocated_qty + ls_result-shortage_qty ).
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = lv_allocated exp = '1' ).
  ENDMETHOD.

  METHOD maximizes_full_demands.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '5' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '2' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103' requested_qty = '3' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '5'
      it_demands   = lt_demands
      iv_strategy  = zif_stock_allocation=>c_strategy_smallest_first ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-status exp = zif_stock_allocation=>c_status_none ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-status exp = zif_stock_allocation=>c_status_full ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-status exp = zif_stock_allocation=>c_status_full ).
  ENDMETHOD.

  METHOD all_strategies_keep_priorities.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101'
        priority = 9 requested_qty = '2' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102'
        priority = 0 requested_qty = '1' ) ).
    DATA lt_strategies TYPE STANDARD TABLE OF zif_stock_allocation=>ty_strategy
      WITH EMPTY KEY.
    lt_strategies = VALUE #(
      ( zif_stock_allocation=>c_strategy_fifo )
      ( zif_stock_allocation=>c_strategy_proportional )
      ( zif_stock_allocation=>c_strategy_fair_share )
      ( zif_stock_allocation=>c_strategy_smallest_first )
      ( zif_stock_allocation=>c_strategy_complete_only ) ).

    LOOP AT lt_strategies INTO DATA(lv_strategy).
      DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
        iv_available = '1'
        it_demands   = lt_demands
        iv_strategy  = lv_strategy ).

      cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-priority exp = 9 ).
      cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '0' ).
      IF lv_strategy = zif_stock_allocation=>c_strategy_complete_only.
        cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '0' ).
      ELSE.
        cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '1' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD avoids_partial_shipments.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101'
        priority = 5 requested_qty = '6' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102'
        priority = 5 requested_qty = '3' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103'
        priority = 0 requested_qty = '2' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '5'
      it_demands   = lt_demands
      iv_strategy  = zif_stock_allocation=>c_strategy_complete_only ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-status exp = zif_stock_allocation=>c_status_full ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-allocated_qty exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 3 ]-status exp = zif_stock_allocation=>c_status_none ).
  ENDMETHOD.

  METHOD rejects_unknown_strategy.
    TRY.
        NEW zcl_stock_allocator( )->allocate(
          iv_available = '1'
          it_demands   = VALUE #( )
          iv_strategy  = 'X' ).
        cl_abap_unit_assert=>fail( 'Unknown allocation strategy must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
