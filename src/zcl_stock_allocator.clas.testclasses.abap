CLASS ltcl_stock_allocator DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS allocates_fifo FOR TESTING.
    METHODS handles_shortage FOR TESTING.
    METHODS ignores_invalid_demand FOR TESTING.
    METHODS clamps_negative_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD allocates_fifo.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '4' )
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '3' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '10'
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-sales_order exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-status exp = zif_stock_allocation=>c_status_full ).
  ENDMETHOD.

  METHOD handles_shortage.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '3' )
      ( sales_order = '2' sales_item = '000010' delivery_date = '20250102' requested_qty = '4' )
      ( sales_order = '3' sales_item = '000010' delivery_date = '20250103' requested_qty = '2' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '5'
      it_demands = lt_demands ).

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
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_initial( lt_result ).
  ENDMETHOD.

  METHOD clamps_negative_stock.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1' sales_item = '000010' delivery_date = '20250101' requested_qty = '3' ) ).

    DATA(lt_result) = NEW zcl_stock_allocator( )->allocate(
      iv_available = '-1'
      it_demands = lt_demands ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty exp = '3' ).
  ENDMETHOD.
ENDCLASS.

