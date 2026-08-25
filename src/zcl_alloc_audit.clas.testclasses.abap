CLASS ltcl_alloc_audit DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS record_and_read FOR TESTING.
    METHODS run_integration FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_audit IMPLEMENTATION.


  METHOD setup.
    zcl_alloc_audit=>clear( ).
    zcl_stub_mard=>clear( ).
    zcl_stub_sales_order=>clear( ).
  ENDMETHOD.


  METHOD record_and_read.
    " record two runs and read them back in order
    DATA ls_stats TYPE zcl_stock_allocator=>ty_stats.
    ls_stats-items_total = 3.
    ls_stats-items_full = 2.
    ls_stats-items_partial = 1.
    ls_stats-items_none = 0.
    ls_stats-qty_requested = '10'.
    ls_stats-qty_allocated = '8'.

    DATA(lv_run1) = zcl_alloc_audit=>record(
        iv_simulate = abap_false
        is_stats    = ls_stats ).

    DATA(lv_run2) = zcl_alloc_audit=>record(
        iv_simulate = abap_true
        is_stats    = ls_stats ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lv_run1 ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lv_run2 ).

    DATA(lt_log) = zcl_alloc_audit=>read_log( ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_log ) ).

    " first entry is a real run, second a simulation
    DATA(ls_entry) = zcl_alloc_audit=>read_entry( iv_runnr = lv_run1 ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_entry-simulate ).
    cl_abap_unit_assert=>assert_equals(
      exp = '10.000'
      act = |{ ls_entry-qty_requested }| ).

    ls_entry = zcl_alloc_audit=>read_entry( iv_runnr = lv_run2 ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_entry-simulate ).

    " unknown run number returns an initial entry
    DATA(ls_unknown) = zcl_alloc_audit=>read_entry( iv_runnr = '0000000099' ).
    cl_abap_unit_assert=>assert_initial( ls_unknown-runnr ).
  ENDMETHOD.


  METHOD run_integration.
    " a real allocation run through zcl_stock_alloc_run lands in the audit log
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATAU' werks = '1000' lgort = '0001' labst = '5' ) ).
    zcl_stub_sales_order=>add_item( VALUE zcl_stub_sales_order=>ty_order_item(
        vbeln = '0000000180' posnr = '000010' matnr = 'MATAU'
        kwmeng = '3' werks = '1000' lgort = '0001' lprio = '2' ) ).

    DATA(lt_materials) = VALUE zcl_stock_alloc_run=>tt_materials(
        ( matnr = 'MATAU' ) ).

    DATA(ls_result) = zcl_stock_alloc_run=>run(
        it_materials = lt_materials
        iv_werks     = '1000'
        iv_simulate  = abap_true ).

    cl_abap_unit_assert=>assert_not_initial( ls_result-runnr ).

    DATA(ls_entry) = zcl_alloc_audit=>read_entry(
        iv_runnr = ls_result-runnr ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_entry-simulate
      msg = 'run recorded as simulation' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_entry-items_total
      msg = 'one item processed' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '3.000'
      act = |{ ls_entry-qty_allocated }|
      msg = 'allocated quantity recorded' ).
  ENDMETHOD.


ENDCLASS.
