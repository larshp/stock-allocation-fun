CLASS ltcl_stock_allocator DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS full_allocation FOR TESTING.
    METHODS partial_allocation FOR TESTING.
    METHODS no_stock_shortage FOR TESTING.
    METHODS multi_location_allocation FOR TESTING.
    METHODS fifo_order_respected FOR TESTING.
    METHODS empty_orders_no_result FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_allocator IMPLEMENTATION.


  METHOD setup.
    zcl_stub_mard=>clear( ).
    zcl_stub_sales_order=>clear( ).
  ENDMETHOD.


  METHOD full_allocation.
    " one order item, enough stock in one location
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT1' werks = '1000' lgort = '0001' labst = '10' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000010' posnr = '000010' matnr = 'MAT1'
        kwmeng = '5' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT1' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '5'
      act  = ls_result-allocations[ 1 ]-qty_alloc
      msg  = 'full allocation expected' ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).
  ENDMETHOD.


  METHOD partial_allocation.
    " demand exceeds stock -> shortage recorded
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT2' werks = '1000' lgort = '0001' labst = '3' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000020' posnr = '000010' matnr = 'MAT2'
        kwmeng = '8' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT2' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp  = '3'
      act  = ls_result-allocations[ 1 ]-qty_alloc
      msg  = 'partial allocation expected' ).
    cl_abap_unit_assert=>assert_equals(
      exp  = '5'
      act  = ls_result-qty_shortage
      msg  = 'shortage of 5 expected' ).
  ENDMETHOD.


  METHOD no_stock_shortage.
    " no stock at all -> nothing allocated, full shortage
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000030' posnr = '000010' matnr = 'MAT3'
        kwmeng = '4' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT3' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( ls_result-allocations[ 1 ]-qty_alloc ).
    cl_abap_unit_assert=>assert_equals(
      exp  = '4'
      act  = ls_result-qty_shortage
      msg  = 'full shortage expected' ).
  ENDMETHOD.


  METHOD multi_location_allocation.
    " stock spread over two storage locations must be combined
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT4' werks = '1000' lgort = '0001' labst = '2' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT4' werks = '1000' lgort = '0002' labst = '6' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000040' posnr = '000010' matnr = 'MAT4'
        kwmeng = '7' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT4' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp  = '7'
      act  = ls_result-allocations[ 1 ]-qty_alloc
      msg  = 'combined allocation across locations expected' ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).
  ENDMETHOD.


  METHOD fifo_order_respected.
    " first order gets served first
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT5' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000060' posnr = '000010' matnr = 'MAT5'
        kwmeng = '3' werks = '1000' lgort = '0001' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000050' posnr = '000010' matnr = 'MAT5'
        kwmeng = '3' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT5' iv_werks = '1000' ).

    SORT ls_result-allocations BY vbeln.
    cl_abap_unit_assert=>assert_equals(
      exp  = '3'
      act  = ls_result-allocations[ 1 ]-qty_alloc
      msg  = 'first FIFO order fully allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp  = '2'
      act  = ls_result-allocations[ 2 ]-qty_alloc
      msg  = 'second FIFO order partially allocated' ).
  ENDMETHOD.


  METHOD empty_orders_no_result.
    " no open orders -> empty result
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT6' werks = '1000' lgort = '0001' labst = '9' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT6' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( ls_result-allocations ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).
  ENDMETHOD.


ENDCLASS.
