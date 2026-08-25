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
    METHODS post_min_qty_threshold FOR TESTING.
    METHODS preferred_sloc_first FOR TESTING.
    METHODS fefo_oldest_batch_first FOR TESTING.
    METHODS fefo_undated_last FOR TESTING.
    METHODS stats_collected FOR TESTING.
    METHODS uom_conversion_applied FOR TESTING.
    METHODS blocked_order_type_skipped FOR TESTING.
    METHODS reservation_reduces_available FOR TESTING.
    METHODS strategy_reverses_order FOR TESTING.
    METHODS date_horizon_filters_items FOR TESTING.
    METHODS full_delivery_only_skipped FOR TESTING.
    METHODS max_partial_deliveries FOR TESTING.
    METHODS substitution_serves_shortage FOR TESTING.
    METHODS multi_plant_with_safety_stock FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_allocator IMPLEMENTATION.


  METHOD setup.
    zcl_stub_mard=>clear( ).
    zcl_stub_uom=>clear( ).
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
    " no stock at all -> no allocation rows, full shortage
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000030' posnr = '000010' matnr = 'MAT3'
        kwmeng = '4' werks = '1000' lgort = '0001' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MAT3' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( ls_result-allocations ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = |{ ls_result-qty_shortage }|
      msg = 'full shortage expected' ).
  ENDMETHOD.


  METHOD multi_location_allocation.
    " stock spread over two storage locations must be combined;
    " now one allocation row per storage location is created
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
      exp = 2
      act = lines( ls_result-allocations )
      msg = 'two allocation rows expected (one per SLoc)' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'first location contributes 2 pieces' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = |{ ls_result-allocations[ 2 ]-qty_alloc }|
      msg = 'second location covers the remaining 5 pieces' ).
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


  METHOD post_min_qty_threshold.
    " allocations below the minimum quantity stay open (not posted)
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATA1' werks = '1000' lgort = '0001' labst = '10' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000110' posnr = '000010' matnr = 'MATA1'
        kwmeng = '8' werks = '1000' lgort = '0001' lprio = '2' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000111' posnr = '000010' matnr = 'MATA1'
        kwmeng = '5' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATA1' iv_werks = '1000' ).

    " stock 10: order 110 gets 8, order 111 gets only 2
    DATA(lv_ok) = zcl_stock_allocator=>post_allocations(
        it_allocations = ls_result-allocations
        iv_min_qty     = '3' ).

    cl_abap_unit_assert=>assert_true( lv_ok ).

    " order 111 allocation of 2 is below threshold -> still open with 5
    DATA(lt_items) = zcl_stub_sales_order=>read_open_items(
        iv_matnr = 'MATA1' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_items )
      msg = 'only the below-threshold item stays open' ).
    IF lines( lt_items ) >= 1.
      cl_abap_unit_assert=>assert_equals(
        exp = '5.000'
        act = |{ lt_items[ 1 ]-kwmeng }|
        msg = 'open item keeps its full remaining quantity' ).
    ENDIF.

    " stock was reduced only by the posted 8 pieces
    DATA(ls_mard) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATA1' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_mard-labst }|
      msg = 'stock reduced only by posted allocations' ).
  ENDMETHOD.


  METHOD preferred_sloc_first.
    " stock spread over two locations; preferred one must be emptied first
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATB1' werks = '1000' lgort = '0001' labst = '4' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATB1' werks = '1000' lgort = '0002' labst = '6' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000120' posnr = '000010' matnr = 'MATB1'
        kwmeng = '5' werks = '1000' lgort = '0002' lprio = '2' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material_with_sloc(
        iv_matnr = 'MATB1'
        iv_werks = '1000'
        iv_lgort = '0002' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'full allocation across locations expected' ).
    " everything taken from the preferred location 0002
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocations[ 1 ]-lgort
      msg = 'preferred storage location used first' ).

    " post the allocation: stock in 0002 drops from 6 to 1
    DATA(lv_ok) = zcl_stock_allocator=>post_allocations(
        it_allocations = ls_result-allocations ).
    cl_abap_unit_assert=>assert_true( lv_ok ).

    DATA(ls_mard_pref) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATB1' iv_werks = '1000' iv_lgort = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = |{ ls_mard_pref-labst }|
      msg = 'preferred location stock reduced by posting' ).
    DATA(ls_mard_other) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATB1' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = |{ ls_mard_other-labst }|
      msg = 'other location untouched by preferred run' ).
  ENDMETHOD.


  METHOD fefo_oldest_batch_first.
    " three dated batches: FEFO must consume the oldest batch first
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATF1' werks = '1000' lgort = '0001'
        labst = '3' bdatr = '20260601' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATF1' werks = '1000' lgort = '0002'
        labst = '5' bdatr = '20260101' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATF1' werks = '1000' lgort = '0003'
        labst = '7' bdatr = '20261201' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000130' posnr = '000010' matnr = 'MATF1'
        kwmeng = '6' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material_fefo(
        iv_matnr = 'MATF1' iv_werks = '1000' ).

    " demand 6 split over two rows: oldest batch (0002) gives 5,
    " second oldest (0001) covers the remaining 1
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations )
      msg = 'two allocation rows expected' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocations[ 1 ]-lgort
      msg = 'oldest batch location used first' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'oldest batch fully consumed' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-allocations[ 2 ]-lgort
      msg = 'second oldest batch covers remaining demand' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = |{ ls_result-allocations[ 2 ]-qty_alloc }|
      msg = 'remaining demand taken from second batch' ).

    " post and verify only the oldest batch was reduced
    DATA(lv_ok) = zcl_stock_allocator=>post_allocations(
        it_allocations = ls_result-allocations ).
    cl_abap_unit_assert=>assert_true( lv_ok ).

    DATA(ls_mard_oldest) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATF1' iv_werks = '1000' iv_lgort = '0002' ).
    " 5 in oldest batch, 6 allocated: 5 from 0002 + 1 from next batch
    cl_abap_unit_assert=>assert_equals(
      exp = '0.000'
      act = |{ ls_mard_oldest-labst }|
      msg = 'oldest batch fully consumed' ).
    DATA(ls_mard_next) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATF1' iv_werks = '1000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_mard_next-labst }|
      msg = 'second oldest batch covers remaining demand' ).
  ENDMETHOD.


  METHOD fefo_undated_last.
    " undated stock is used only after all dated batches
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATF2' werks = '1000' lgort = '0001'
        labst = '4' bdatr = '20991231' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATF2' werks = '1000' lgort = '0002'
        labst = '4' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000140' posnr = '000010' matnr = 'MATF2'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material_fefo(
        iv_matnr = 'MATF2' iv_werks = '1000' ).

    " demand of 4 is covered by the dated batch (even far future), not the
    " undated one
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-allocations[ 1 ]-lgort
      msg = 'dated batch used before undated stock' ).
  ENDMETHOD.


  METHOD stats_collected.
    " one full, one partial, one empty allocation -> statistics reflect it
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATS1' werks = '1000' lgort = '0001' labst = '6' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000150' posnr = '000010' matnr = 'MATS1'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000151' posnr = '000010' matnr = 'MATS1'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000152' posnr = '000010' matnr = 'MATS1'
        kwmeng = '3' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATS1' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = ls_result-stats-items_total
      msg = 'three items processed' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-stats-items_full
      msg = 'one item fully allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-stats-items_partial
      msg = 'one item partially allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-stats-items_none
      msg = 'one item without any allocation' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '11.000'
      act = |{ ls_result-stats-qty_requested }|
      msg = 'total requested quantity is 11' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '6.000'
      act = |{ ls_result-stats-qty_allocated }|
      msg = 'total allocated quantity equals stock' ).
  ENDMETHOD.


  METHOD uom_conversion_applied.
    " order item is in sales units (CS), stock in base units (PC)
    " 1 CS = 12 PC: demand of 2 CS becomes 24 PC against 30 PC stock
    zcl_stub_uom=>clear( ).
    zcl_stub_uom=>add_rule( VALUE zcl_stub_uom=>ty_uom_rule(
        matnr = 'MATU1' vrkme = 'CS' meins = 'PC'
        umrez = '12' umren = '1' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATU1' werks = '1000' lgort = '0001' labst = '30' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000160' posnr = '000010' matnr = 'MATU1'
        kwmeng = '2' vrkme = 'CS' werks = '1000' lgort = '0001'
        lprio = '2' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATU1' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '24.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = '2 CS converted to 24 PC and allocated' ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).

    " without a conversion rule quantities pass through unchanged
    zcl_stub_uom=>clear( ).
    DATA(ls_result_norule) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATU1' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_result_norule-allocations[ 1 ]-qty_alloc }|
      msg = 'no rule: quantity passes through unchanged' ).
  ENDMETHOD.


  METHOD blocked_order_type_skipped.
    " items of a blocked order type are excluded from allocation
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATZ1' werks = '1000' lgort = '0001' labst = '10' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000170' posnr = '000010' matnr = 'MATZ1'
        kwmeng = '3' werks = '1000' lgort = '0001' lprio = '2'
        auart = 'ZOR' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000171' posnr = '000010' matnr = 'MATZ1'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2'
        auart = 'ZBL' ) ).

    " block order type ZBL (e.g. credit block pending)
    zcl_stub_sales_order=>block_order_type( iv_auart = 'ZBL' ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATZ1' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocations )
      msg = 'only the unblocked order is allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000170'
      act = ls_result-allocations[ 1 ]-vbeln
      msg = 'the unblocked order got the allocation' ).

    " unblocking makes the item allocatable again; note that the first
    " allocation did not consume stock (only posting does), so now BOTH
    " open orders are allocated from the full stock of 10
    zcl_stub_sales_order=>unblock_order_type( iv_auart = 'ZBL' ).
    DATA(ls_result2) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATZ1' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result2-allocations )
      msg = 'both orders allocated after unblocking' ).
    SORT ls_result2-allocations BY vbeln.
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000170'
      act = ls_result2-allocations[ 1 ]-vbeln
      msg = 'first order still allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000171'
      act = ls_result2-allocations[ 2 ]-vbeln
      msg = 'unblocked order receives stock' ).
  ENDMETHOD.


  METHOD reservation_reduces_available.
    " reserved stock is not allocatable until released
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATR1' werks = '1000' lgort = '0001' labst = '10' ) ).

    " reserve 6 pieces for another purpose
    DATA(lv_ok) = zcl_stub_mard=>reserve_stock(
        iv_matnr = 'MATR1' iv_werks = '1000' iv_lgort = '0001'
        iv_qty   = '6' ).
    cl_abap_unit_assert=>assert_true( lv_ok ).

    " only 4 pieces remain allocatable
    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATR1' iv_werks = '1000' ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000190' posnr = '000010' matnr = 'MATR1'
        kwmeng = '7' werks = '1000' lgort = '0001' lprio = '2' ) ).

    ls_result = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATR1' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'only unreserved stock allocated' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ ls_result-qty_shortage }|
      msg = 'shortage covers the reserved quantity' ).

    " releasing the reservation makes the stock allocatable again
    zcl_stub_mard=>release_reservation(
        iv_matnr = 'MATR1' iv_werks = '1000' iv_lgort = '0001'
        iv_qty   = '6' ).
    ls_result = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATR1' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '7.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'full demand allocatable after release' ).

    " over-reserving fails
    DATA(lv_fail) = zcl_stub_mard=>reserve_stock(
        iv_matnr = 'MATR1' iv_werks = '1000' iv_lgort = '0001'
        iv_qty   = '99' ).
    cl_abap_unit_assert=>assert_false( lv_fail ).

    " availability check reflects reservations
    zcl_stub_mard=>reserve_stock(
        iv_matnr = 'MATR1' iv_werks = '1000' iv_lgort = '0001'
        iv_qty   = '2' ).
    cl_abap_unit_assert=>assert_false( zcl_stub_mard=>is_available(
        iv_matnr = 'MATR1' iv_werks = '1000' iv_lgort = '0001'
        iv_qty   = '10' ) ).
    cl_abap_unit_assert=>assert_true( zcl_stub_mard=>is_available(
        iv_matnr = 'MATR1' iv_werks = '1000' iv_lgort = '0001'
        iv_qty   = '8' ) ).
  ENDMETHOD.


  METHOD strategy_reverses_order.
    " the pluggable strategy reverses the consumption order
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATST' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATST' werks = '1000' lgort = '0002' labst = '5' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000200' posnr = '000010' matnr = 'MATST'
        kwmeng = '6' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(lo_strategy) = NEW lcl_reverse_strategy( ).
    DATA(ls_result) = zcl_stock_allocator=>allocate_material_by_strategy(
        iv_matnr    = 'MATST'
        iv_werks    = '1000'
        io_strategy = lo_strategy ).

    " reverse order: location 0002 is consumed first
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations )
      msg = 'two allocation rows expected' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = ls_result-allocations[ 1 ]-lgort
      msg = 'strategy reversed: 0002 first' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = |{ ls_result-allocations[ 1 ]-qty_alloc }|
      msg = 'location 0002 fully consumed' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_result-allocations[ 2 ]-lgort
      msg = 'remaining demand from 0001' ).

    " default strategy would use 0001 first - verify difference
    DATA(ls_default) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATST' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = ls_default-allocations[ 1 ]-lgort
      msg = 'default strategy uses insertion order' ).
  ENDMETHOD.


  METHOD date_horizon_filters_items.
    " only items due up to the horizon date are allocated
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATDT' werks = '1000' lgort = '0001' labst = '10' ) ).
    " urgent item: due tomorrow, no explicit date -> always included
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000210' posnr = '000010' matnr = 'MATDT'
        kwmeng = '3' werks = '1000' lgort = '0001' lprio = '2' ) ).
    " item due within horizon
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000211' posnr = '000010' matnr = 'MATDT'
        kwmeng = '4' werks = '1000' lgort = '0001' lprio = '2'
        edatu = '20260901' ) ).
    " item due far in the future - outside horizon
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000212' posnr = '000010' matnr = 'MATDT'
        kwmeng = '5' werks = '1000' lgort = '0001' lprio = '2'
        edatu = '20271231' ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material_until(
        iv_matnr = 'MATDT'
        iv_werks = '1000'
        iv_date  = '20261231' ).

    " undated + dated-within-horizon items are allocated; the far-future
    " item keeps its stock free
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocations )
      msg = 'only items within horizon allocated' ).
    SORT ls_result-allocations BY vbeln.
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000210'
      act = ls_result-allocations[ 1 ]-vbeln ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000211'
      act = ls_result-allocations[ 2 ]-vbeln ).
    cl_abap_unit_assert=>assert_initial( ls_result-qty_shortage ).

    " without a horizon all three items compete for the same stock
    DATA(ls_all) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATDT' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( ls_all-allocations )
      msg = 'no horizon: all items allocated' ).
  ENDMETHOD.


  METHOD full_delivery_only_skipped.
    " maxpw = 1: item needs the whole quantity from ONE storage location
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATPD' werks = '1000' lgort = '0001' labst = '3' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATPD' werks = '1000' lgort = '0002' labst = '4' ) ).
    " demand 5 cannot be covered by a single location -> skipped
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000220' posnr = '000010' matnr = 'MATPD'
        kwmeng = '5' werks = '1000' lgort = '0001' lprio = '2'
        maxpw = 1 ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATPD' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( ls_result-allocations ).
    cl_abap_unit_assert=>assert_equals(
      exp = '5.000'
      act = |{ ls_result-qty_shortage }|
      msg = 'full demand counted as shortage' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-stats-items_none
      msg = 'item counted as not allocated' ).

    " a smaller order CAN be served completely from one location
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000221' posnr = '000010' matnr = 'MATPD'
        kwmeng = '3' werks = '1000' lgort = '0001' lprio = '2'
        maxpw = 1 ) ).

    DATA(ls_result2) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATPD' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result2-allocations )
      msg = 'single-location delivery possible' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ ls_result2-allocations[ 1 ]-qty_alloc }|
      msg = 'full quantity from one location' ).
  ENDMETHOD.


  METHOD max_partial_deliveries.
    " maxpw = 1: full delivery from ONE storage location only. Demand 7
    " cannot be covered by any single location -> item skipped entirely
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATMP' werks = '1000' lgort = '0001' labst = '2' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATMP' werks = '1000' lgort = '0002' labst = '6' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000230' posnr = '000010' matnr = 'MATMP'
        kwmeng = '7' werks = '1000' lgort = '0001' lprio = '2'
        maxpw = 1 ) ).

    DATA(ls_result) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATMP' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( ls_result-allocations ).
    cl_abap_unit_assert=>assert_equals(
      exp = '7.000'
      act = |{ ls_result-qty_shortage }|
      msg = 'full demand is shortage: no single SLoc covers it' ).

    " a smaller order CAN be served completely from one location: 0001 has
    " exactly 2 pieces left (allocation works on a copy, stock unchanged)
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000231' posnr = '000010' matnr = 'MATMP'
        kwmeng = '2' werks = '1000' lgort = '0001' lprio = '2'
        maxpw = 1 ) ).

    DATA(ls_result2) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATMP' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result2-allocations )
      msg = 'single allocation row for the coverable order' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ ls_result2-allocations[ 1 ]-qty_alloc }|
      msg = 'location 0001 covers the whole demand' ).

    " without a limit multiple locations contribute
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000232' posnr = '000010' matnr = 'MATMP'
        kwmeng = '7' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(ls_unlimited) = zcl_stock_allocator=>allocate_material(
        iv_matnr = 'MATMP' iv_werks = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_unlimited-allocations )
      msg = 'no limit: multiple locations used' ).
  ENDMETHOD.


  METHOD substitution_serves_shortage.
    " requested material covers part of the demand, the substitute serves
    " the rest; result rows reference both materials
    zcl_stub_substitution=>clear( ).
    zcl_stub_substitution=>add_rule( VALUE zcl_stub_substitution=>ty_sub_rule(
        matnr = 'MATSB' sub_matnr = 'MATS1' priority = 1 ) ).

    " original material has 4 pieces, substitute has 5
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATSB' werks = '1000' lgort = '0001' labst = '4' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATS1' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000240' posnr = '000010' matnr = 'MATSB'
        kwmeng = '7' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(lt_alloc) = zcl_stock_allocator=>allocate_with_substitution(
        iv_matnr = 'MATSB' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_alloc )
      msg = 'two allocation rows: original + substitute' ).

    " find rows by material (order after SORT BY matnr_used is alphabetical:
    " MATS1 before MATSB)
    SORT lt_alloc BY matnr_used.
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ lt_alloc[ 1 ]-qty_alloc }|
      msg = 'substitute serves the remaining demand' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = |{ lt_alloc[ 2 ]-qty_alloc }|
      msg = 'original material fully consumed' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000240'
      act = lt_alloc[ 2 ]-vbeln
      msg = 'allocation mapped back to the original order' ).

    " no substitution needed when the original material suffices
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATSC' werks = '1000' lgort = '0001' labst = '9' ) ).
    zcl_stub_substitution=>add_rule( VALUE zcl_stub_substitution=>ty_sub_rule(
        matnr = 'MATSC' sub_matnr = 'MATS2' priority = 1 ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000241' posnr = '000010' matnr = 'MATSC'
        kwmeng = '5' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(lt_alloc2) = zcl_stock_allocator=>allocate_with_substitution(
        iv_matnr = 'MATSC' iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_alloc2 )
      msg = 'single row when no substitution needed' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MATSC'
      act = lt_alloc2[ 1 ]-matnr_used
      msg = 'only the original material used' ).
  ENDMETHOD.


  METHOD multi_plant_with_safety_stock.
    " demand is served across plants in priority order; each plant keeps
    " its safety stock untouched
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATPL' werks = '2000' lgort = '0001' labst = '3' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATPL' werks = '3000' lgort = '0001' labst = '8' ) ).

    " create demand at plant 2000 (the first plant in the list)
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000250' posnr = '000010' matnr = 'MATPL'
        kwmeng = '9' werks = '2000' lgort = '0001' lprio = '2' ) ).

    DATA(lt_plants) = VALUE zcl_stock_allocator=>tt_plants(
        ( werks = '2000' )
        ( werks = '3000' ) ).

    DATA(lt_alloc) = zcl_stock_allocator=>allocate_multi_plant(
        iv_matnr        = 'MATPL'
        it_plants       = lt_plants
        iv_safety_stock = '2' ).

    " three rows: MULTI (1 pc, plant 2000 usable after safety), the real
    " order 250 (2 pcs from plant 2000's safety stock), and MULTI again
    " (3 pcs from plant 3000). Total allocated = 6 of 9 demanded.
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_alloc )
      msg = 'three allocation rows expected' ).

    SORT lt_alloc BY werks qty_alloc.
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_alloc[ 1 ]-werks
      msg = 'first plant in list served first' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1.000'
      act = |{ lt_alloc[ 1 ]-qty_alloc }|
      msg = 'plant 2000 usable stock is 3 - 2 safety = 1' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3000'
      act = lt_alloc[ 3 ]-werks
      msg = 'second plant covers remaining demand' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ lt_alloc[ 3 ]-qty_alloc }|
      msg = 'plant 3000 serves up to its usable stock' ).

    " verify the stub stock state: allocation works on a copy, so without
    " posting the stock stays untouched (3 and 8)
    DATA(ls_mard_2000) = zcl_stub_mard=>read_single(
        iv_matnr = 'MATPL' iv_werks = '2000' iv_lgort = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ ls_mard_2000-labst }|
      msg = 'stock unchanged: only posting reduces stub stock' ).
  ENDMETHOD.


ENDCLASS.
