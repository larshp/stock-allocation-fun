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
    METHODS post_reduces_stock FOR TESTING.
    METHODS post_confirms_order_qty FOR TESTING.
    METHODS allocation_messages_logged FOR TESTING.

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
      exp = '5.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'full allocation expected' ).
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
      exp = '3.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'partial allocation expected' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = |{ ls_result-qty_shortage }|
      msg = 'shortage of 5 expected' ).
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
      exp = '4.000'
      act = |{ ls_result-qty_shortage }|
      msg = 'full shortage expected' ).
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
      exp = '7.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'combined allocation across locations expected' ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).
  ENDMETHOD.


  METHOD fifo_order_respected.
    " first order gets served first, stock is limited to 5
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT5' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000060' posnr = '000010' matnr = 'MAT5'
        kwmeng = '4' werks = '1000' lgort = '0001' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000050' posnr = '000010' matnr = 'MAT5'
        kwmeng = '3' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT5' iv_werks = '1000' ).

    SORT ls_result-allocations BY vbeln.
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'second FIFO order partially allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_result-allocations[ 2 ]-qty_alloc }|
      msg = 'first FIFO order fully allocated' ).
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


  METHOD post_reduces_stock.
    " allocate then post: stock must be reduced by the allocated quantity
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT7' werks = '1000' lgort = '0001' labst = '10' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000070' posnr = '000010' matnr = 'MAT7'
        kwmeng = '4' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT7' iv_werks = '1000' ).

    DATA(lv_ok) = zcl_stock_allocator=>post_allocations(
        it_allocations = ls_result-allocations ).

    cl_abap_unit_assert=>assert_true( lv_ok ).

    DATA(ls_mard) = zcl_stub_mard=>read_single(
        iv_matnr = 'MAT7' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '6.000'
      act = |{ ls_mard-labst }|
      msg = 'stock reduced from 10 to 6 after posting' ).
  ENDMETHOD.


  METHOD post_confirms_order_qty.
    " posting confirms the quantity on the order item; fully confirmed
    " items disappear from the open items list
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT8' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000080' posnr = '000010' matnr = 'MAT8'
        kwmeng = '5' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT8' iv_werks = '1000' ).

    DATA(lv_ok) = zcl_stock_allocator=>post_allocations(
        it_allocations = ls_result-allocations ).

    cl_abap_unit_assert=>assert_true( lv_ok ).

    " item was fully allocated and posted, so no open items remain
    DATA(lt_items) = zcl_stub_sales_order=>read_open_items(
        iv_matnr = 'MAT8' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_initial( lt_items ).
  ENDMETHOD.


  METHOD allocation_messages_logged.
    " one fully covered order (S) and one without stock (E) must be logged
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MAT9' werks = '1000' lgort = '0001' labst = '2' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000090' posnr = '000010' matnr = 'MAT9'
        kwmeng = '2' werks = '1000' lgort = '0001' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000100' posnr = '000010' matnr = 'MAT9'
        kwmeng = '5' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT9' iv_werks = '1000' ).

    " both items produce a message
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-messages )
      msg = 'two messages expected' ).

    READ TABLE ls_result-messages INDEX 1 INTO DATA(ls_msg1).
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'S'
      act = ls_msg1-msgty
      msg = 'fully allocated item logs success message' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_stub_message=>gc_msgno-full_alloc
      act = ls_msg1-msgno ).

    READ TABLE ls_result-messages INDEX 2 INTO DATA(ls_msg2).
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_msg2-msgty
      msg = 'item without stock logs error message' ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_stub_message=>gc_msgno-no_stock
      act = ls_msg2-msgno ).
  ENDMETHOD.


ENDCLASS.
