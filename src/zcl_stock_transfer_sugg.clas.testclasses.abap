CLASS ltcl_stock_transfer_sugg DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS setup.
    METHODS no_transfer_when_enough FOR TESTING.
    METHODS transfer_from_largest FOR TESTING.
    METHODS transfer_multiple_sources FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_transfer_sugg IMPLEMENTATION.


  METHOD setup.
    zcl_stub_mard=>clear( ).
  ENDMETHOD.


  METHOD no_transfer_when_enough.
    " preferred location covers the demand: no transfer suggested
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT1' werks = '1000' lgort = '0001' labst = '10' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT1' werks = '1000' lgort = '0002' labst = '5' ) ).

    DATA(lt_transfers) = zcl_stock_transfer_sugg=>suggest(
        iv_matnr      = 'MATT1'
        iv_werks      = '1000'
        iv_lgort_pref = '0001'
        iv_qty        = '8' ).

    cl_abap_unit_assert=>assert_initial( lt_transfers ).
  ENDMETHOD.


  METHOD transfer_from_largest.
    " preferred location short by 4; location 0002 has the most stock and
    " is chosen as the source
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT2' werks = '1000' lgort = '0001' labst = '6' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT2' werks = '1000' lgort = '0002' labst = '9' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT2' werks = '1000' lgort = '0003' labst = '3' ) ).

    DATA(lt_transfers) = zcl_stock_transfer_sugg=>suggest(
        iv_matnr      = 'MATT2'
        iv_werks      = '1000'
        iv_lgort_pref = '0001'
        iv_qty        = '10' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_transfers )
      msg = 'one transfer covers the shortfall' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_transfers[ 1 ]-lgort_from
      msg = 'largest stock location chosen as source' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_transfers[ 1 ]-lgort_to
      msg = 'destination is the preferred location' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4.000'
      act = |{ lt_transfers[ 1 ]-qty }|
      msg = 'exactly the shortfall is transferred' ).
  ENDMETHOD.


  METHOD transfer_multiple_sources.
    " shortfall larger than any single source: multiple transfers, largest
    " source first
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT3' werks = '1000' lgort = '0001' labst = '2' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT3' werks = '1000' lgort = '0002' labst = '3' ) ).
    zcl_stub_mard=>insert_row( VALUE mard(
        matnr = 'MATT3' werks = '1000' lgort = '0003' labst = '8' ) ).

    DATA(lt_transfers) = zcl_stock_transfer_sugg=>suggest(
        iv_matnr      = 'MATT3'
        iv_werks      = '1000'
        iv_lgort_pref = '0001'
        iv_qty        = '10' ).

    " shortfall of 8: take 8 from 0003 (largest), nothing more needed
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_transfers ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0003'
      act = lt_transfers[ 1 ]-lgort_from ).
    cl_abap_unit_assert=>assert_equals(
      exp = '8.000'
      act = |{ lt_transfers[ 1 ]-qty }| ).
  ENDMETHOD.


ENDCLASS.
