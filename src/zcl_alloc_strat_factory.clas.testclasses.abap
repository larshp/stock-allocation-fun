CLASS ltcl_alloc_strat_factory DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS create_by_name FOR TESTING.
    METHODS largest_orders_by_stock FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_strat_factory IMPLEMENTATION.


  METHOD create_by_name.
    " known names return the matching strategies, unknown names fall back
    " to FIFO
    DATA(lo_largest) = zcl_alloc_strat_factory=>create(
        iv_name = zcl_alloc_strat_factory=>gc_strategy-largest ).
    cl_abap_unit_assert=>assert_bound( lo_largest ).

    DATA(lo_fifo) = zcl_alloc_strat_factory=>create(
        iv_name = zcl_alloc_strat_factory=>gc_strategy-fifo ).
    cl_abap_unit_assert=>assert_bound( lo_fifo ).

    DATA(lo_unknown) = zcl_alloc_strat_factory=>create( iv_name = 'WHATEVER' ).
    cl_abap_unit_assert=>assert_bound( lo_unknown ).
  ENDMETHOD.


  METHOD largest_orders_by_stock.
    " the LARGEST strategy consumes the location with the most stock first
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATLG' werks = '1000' lgort = '0001' labst = '2' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATLG' werks = '1000' lgort = '0002' labst = '8' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000260' posnr = '000010' matnr = 'MATLG'
        kwmeng = '9' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(lo_strategy) = zcl_alloc_strat_factory=>create(
        iv_name = zcl_alloc_strat_factory=>gc_strategy-largest ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material_by_strategy(
        iv_matnr    = 'MATLG'
        iv_werks    = '1000'
        io_strategy = lo_strategy ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations )
      msg = 'two allocation rows expected' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocations[ 1 ]-lgort
      msg = 'largest stock location consumed first' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '8.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'largest location fully consumed' ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).
  ENDMETHOD.


ENDCLASS.
