CLASS ltcl_stock_alloc_run DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS multi_material_run FOR TESTING.
    METHODS simulation_no_posting FOR TESTING.
    METHODS priority_before_fifo FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_alloc_run IMPLEMENTATION.


  METHOD setup.
    zcl_stub_mard=>clear( ).
    zcl_stub_sales_order=>clear( ).
  ENDMETHOD.


  METHOD multi_material_run.
    " two materials, both fully allocated in one run
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATA' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATB' werks = '1000' lgort = '0001' labst = '4' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000011' posnr = '000010' matnr = 'MATA'
        kwmeng = '3' werks = '1000' lgort = '0001' lprio = '2' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000012' posnr = '000010' matnr = 'MATB'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(lt_materials) = VALUE zcl_stock_alloc_run=>tt_materials(
        ( matnr = 'MATA' )
        ( matnr = 'MATB' ) ).

    DATA(ls_result) = zcl_stock_alloc_run=>run(
        it_materials = lt_materials
        iv_werks     = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations )
      msg = 'two allocations expected' ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).

    " posting happened: stock reduced for both materials
    DATA(ls_mard_a) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATA' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_mard_a-labst }|
      msg = 'MATA stock reduced from 5 to 2' ).
    DATA(ls_mard_b) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATB' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0.000'
      act = |{ ls_mard_b-labst }|
      msg = 'MATB stock reduced from 4 to 0' ).
  ENDMETHOD.


  METHOD simulation_no_posting.
    " simulate mode: allocations calculated but nothing posted
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATC' werks = '1000' lgort = '0001' labst = '8' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000021' posnr = '000010' matnr = 'MATC'
        kwmeng = '6' werks = '1000' lgort = '0001' lprio = '1' ) ).

    DATA(lt_materials) = VALUE zcl_stock_alloc_run=>tt_materials(
        ( matnr = 'MATC' ) ).

    DATA(ls_result) = zcl_stock_alloc_run=>run(
        it_materials = lt_materials
        iv_werks     = '1000'
        iv_simulate  = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocations )
      msg = 'allocation calculated in simulation' ).

    " stock unchanged after simulated run
    DATA(ls_mard) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATC' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '8.000'
      act = |{ ls_mard-labst }|
      msg = 'stock unchanged in simulation mode' ).

    " order item still open with full quantity
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = zcl_stub_sales_order=>count_items( )
      msg = 'order item still open after simulation' ).
  ENDMETHOD.


  METHOD priority_before_fifo.
    " urgent order (lprio 1, higher vbeln) must be served before the
    " older standard order (lprio 2), despite FIFO by document number
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATD' werks = '1000' lgort = '0001' labst = '5' ) ).
    " older document, standard priority
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000031' posnr = '000010' matnr = 'MATD'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2' ) ).
    " newer document, urgent priority
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000032' posnr = '000010' matnr = 'MATD'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '1' ) ).

    DATA(lt_materials) = VALUE zcl_stock_alloc_run=>tt_materials(
        ( matnr = 'MATD' ) ).

    DATA(ls_result) = zcl_stock_alloc_run=>run(
        it_materials = lt_materials
        iv_werks     = '1000'
        iv_simulate  = abap_true ).

    SORT ls_result-allocations BY vbeln.
    " older standard order 31 only gets the remaining 1 piece
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'standard priority order partially allocated' ).
    " urgent order 32 fully served first
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = |{ ls_result-allocations[ 2 ]-qty_alloc }|
      msg = 'urgent priority order fully allocated' ).
  ENDMETHOD.


ENDCLASS.
