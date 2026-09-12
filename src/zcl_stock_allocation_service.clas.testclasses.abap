CLASS ltcl_stock_allocation_service DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    TYPES ty_resb_tt TYPE STANDARD TABLE OF resb WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_stock_allocation_service.

    METHODS setup.
    METHODS teardown.

    METHODS given_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0.

    METHODS given_requirement
      IMPORTING
        iv_rsnum TYPE resb-rsnum
        iv_rspos TYPE resb-rspos DEFAULT '0001'
        iv_bdmng TYPE menge_d DEFAULT 0
        iv_bdter TYPE d DEFAULT '20260101'.

    METHODS allocates_stock_to_open_resb   FOR TESTING.
    METHODS reports_shortage_end_to_end    FOR TESTING.
    METHODS spills_over_two_bins           FOR TESTING.
    METHODS available_quantity_sums_bins   FOR TESTING.
    METHODS total_shortage_sums_results    FOR TESTING.
    METHODS no_requirements_no_result      FOR TESTING.
    METHODS records_allocation_run         FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_allocation_service IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARD' ) ( 'RESB' ) ( 'ZSTOCKALLOC' ) ) ).
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = 'MAT-1'.
    ls_mard-werks = '1000'.
    ls_mard-lgort = iv_lgort.
    ls_mard-labst = iv_labst.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD given_requirement.
    DATA ls_resb TYPE resb.

    ls_resb-mandt = sy-mandt.
    ls_resb-rsnum = iv_rsnum.
    ls_resb-rspos = iv_rspos.
    ls_resb-rsart = '1'.
    ls_resb-matnr = 'MAT-1'.
    ls_resb-werks = '1000'.
    ls_resb-lgort = '0001'.
    ls_resb-bdmng = iv_bdmng.
    ls_resb-bdter = iv_bdter.

    mo_environment->insert_test_data( VALUE ty_resb_tt( ( ls_resb ) ) ).
  ENDMETHOD.

  METHOD allocates_stock_to_open_resb.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocations[ 1 ]-lgort exp = '0001' ).
  ENDMETHOD.

  METHOD reports_shortage_end_to_end.
    given_stock( iv_lgort = '0001' iv_labst = '2' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '10' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '8' ).
  ENDMETHOD.

  METHOD spills_over_two_bins.
    given_stock( iv_lgort = '0001' iv_labst = '4' ).
    given_stock( iv_lgort = '0002' iv_labst = '4' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result[ 1 ]-allocations ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD available_quantity_sums_bins.
    given_stock( iv_lgort = '0001' iv_labst = '3' ).
    given_stock( iv_lgort = '0002' iv_labst = '5' ).
    given_stock( iv_lgort = '0003' iv_labst = '7' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->available_quantity( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' )
      exp = '15' ).
  ENDMETHOD.

  METHOD total_shortage_sums_results.
    given_stock( iv_lgort = '0001' iv_labst = '1' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '4' ).
    given_requirement( iv_rsnum = '0000000002' iv_bdmng = '5' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_shortage( lt_result ) exp = '8' ).
  ENDMETHOD.

  METHOD no_requirements_no_result.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( act = lt_result ).
  ENDMETHOD.

  METHOD records_allocation_run.
    given_stock( iv_lgort = '0001' iv_labst = '4' ).
    given_stock( iv_lgort = '0002' iv_labst = '4' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lt_result) = mo_cut->allocate_and_record( iv_run_id = 'RUN-1'
                                                   iv_matnr  = 'MAT-1'
                                                   iv_werks  = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).

    SELECT * FROM zstockalloc INTO TABLE @DATA(lt_log).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_log )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-alloc_qty
                                        exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 2 ]-lgort
                                        exp = '0002' ).
  ENDMETHOD.

ENDCLASS.
