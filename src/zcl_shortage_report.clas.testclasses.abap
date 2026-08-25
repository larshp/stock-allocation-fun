CLASS ltcl_shortage_report DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS build_groups_by_material FOR TESTING.

ENDCLASS.


CLASS ltcl_shortage_report IMPLEMENTATION.


  METHOD build_groups_by_material.
    " allocations for two materials are grouped into one report row each
    DATA(lt_allocations) = VALUE zcl_stock_allocator=>tt_allocations(
        ( vbeln = '0000000300' posnr = '000010' matnr = 'MATRA'
          werks = '1000' lgort = '0001' qty_req = '5'
          qty_alloc = '5' )
        ( vbeln = '0000000301' posnr = '000010' matnr = 'MATRB'
          werks = '1000' lgort = '0001' qty_req = '4'
          qty_alloc = '2' ) ).

    DATA ls_stats TYPE zcl_stock_allocator=>ty_stats.
    ls_stats-items_total = 2.
    ls_stats-qty_requested = '9'.
    ls_stats-qty_allocated = '7'.

    DATA(lt_report) = zcl_shortage_report=>build(
        iv_werks       = '1000'
        it_allocations = lt_allocations
        is_stats       = ls_stats ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_report )
      msg = 'one row per material' ).

    SORT lt_report BY matnr.
    cl_abap_unit_assert=>assert_equals(
      exp = 'MATRA'
      act = lt_report[ 1 ]-matnr ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_report[ 1 ]-items_hit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MATRB'
      act = lt_report[ 2 ]-matnr ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_report[ 2 ]-items_hit ).

    " overall run shortage (9 requested - 7 allocated) on the first row
    cl_abap_unit_assert=>assert_equals(
      exp = '2.000'
      act = |{ lt_report[ 1 ]-qty_short }| ).
  ENDMETHOD.


ENDCLASS.
