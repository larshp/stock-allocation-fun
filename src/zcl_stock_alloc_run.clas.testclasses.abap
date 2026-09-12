CLASS ltcl_stock_alloc_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    TYPES ty_resb_tt TYPE STANDARD TABLE OF resb WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_stock_alloc_run.

    METHODS setup.
    METHODS teardown.

    METHODS given_stock
      IMPORTING
        iv_matnr TYPE matnr
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0.

    METHODS given_requirement
      IMPORTING
        iv_matnr TYPE matnr
        iv_rsnum TYPE resb-rsnum
        iv_bdmng TYPE menge_d DEFAULT 0.

    METHODS all_requests
      RETURNING
        VALUE(rt_requests) TYPE zcl_stock_alloc_run=>ty_request_tt.

    METHODS runs_two_materials         FOR TESTING.
    METHODS aggregates_shortages       FOR TESTING.
    METHODS counts_short_materials     FOR TESTING.
    METHODS totals_across_materials    FOR TESTING.
    METHODS empty_requests_empty_stats FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_alloc_run IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARD' ) ( 'RESB' ) ) ).
    mo_cut = NEW zcl_stock_alloc_run( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = iv_matnr.
    ls_mard-werks = '1000'.
    ls_mard-lgort = iv_lgort.
    ls_mard-labst = iv_labst.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD given_requirement.
    DATA ls_resb TYPE resb.

    ls_resb-mandt = sy-mandt.
    ls_resb-rsnum = iv_rsnum.
    ls_resb-rspos = '0001'.
    ls_resb-rsart = '1'.
    ls_resb-matnr = iv_matnr.
    ls_resb-werks = '1000'.
    ls_resb-lgort = '0001'.
    ls_resb-bdmng = iv_bdmng.
    ls_resb-bdter = '20260101'.

    mo_environment->insert_test_data( VALUE ty_resb_tt( ( ls_resb ) ) ).
  ENDMETHOD.

  METHOD all_requests.
    APPEND VALUE #( matnr = 'MAT-1' werks = '1000' ) TO rt_requests.
    APPEND VALUE #( matnr = 'MAT-2' werks = '1000' ) TO rt_requests.
  ENDMETHOD.

  METHOD runs_two_materials.
    given_stock( iv_matnr = 'MAT-1' iv_lgort = '0001' iv_labst = '10' ).
    given_stock( iv_matnr = 'MAT-2' iv_lgort = '0001' iv_labst = '10' ).
    given_requirement( iv_matnr = 'MAT-1'
                       iv_rsnum = '0000000001'
                       iv_bdmng = '4' ).
    given_requirement( iv_matnr = 'MAT-2'
                       iv_rsnum = '0000000002'
                       iv_bdmng = '6' ).

    DATA(ls_run) = mo_cut->run( all_requests( ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-materials
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-requirements
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_run-materials )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-materials[ 1 ]-matnr
                                        exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-materials[ 2 ]-matnr
                                        exp = 'MAT-2' ).
  ENDMETHOD.

  METHOD aggregates_shortages.
    given_stock( iv_matnr = 'MAT-1' iv_lgort = '0001' iv_labst = '2' ).
    given_stock( iv_matnr = 'MAT-2' iv_lgort = '0001' iv_labst = '1' ).
    given_requirement( iv_matnr = 'MAT-1'
                       iv_rsnum = '0000000001'
                       iv_bdmng = '5' ).
    given_requirement( iv_matnr = 'MAT-2'
                       iv_rsnum = '0000000002'
                       iv_bdmng = '4' ).

    DATA(ls_run) = mo_cut->run( all_requests( ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_run-shortages )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-shortages[ 1 ]-matnr
                                        exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_run-shortages[ 1 ]-shortage_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-shortages[ 2 ]-matnr
                                        exp = 'MAT-2' ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-shortage_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD counts_short_materials.
    given_stock( iv_matnr = 'MAT-1' iv_lgort = '0001' iv_labst = '10' ).
    given_stock( iv_matnr = 'MAT-2' iv_lgort = '0001' iv_labst = '1' ).
    given_requirement( iv_matnr = 'MAT-1'
                       iv_rsnum = '0000000001'
                       iv_bdmng = '4' ).
    given_requirement( iv_matnr = 'MAT-2'
                       iv_rsnum = '0000000002'
                       iv_bdmng = '4' ).

    DATA(ls_run) = mo_cut->run( all_requests( ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-materials_shortage
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_run-shortages )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD totals_across_materials.
    given_stock( iv_matnr = 'MAT-1' iv_lgort = '0001' iv_labst = '10' ).
    given_stock( iv_matnr = 'MAT-2' iv_lgort = '0001' iv_labst = '10' ).
    given_requirement( iv_matnr = 'MAT-1'
                       iv_rsnum = '0000000001'
                       iv_bdmng = '4' ).
    given_requirement( iv_matnr = 'MAT-2'
                       iv_rsnum = '0000000002'
                       iv_bdmng = '6' ).

    DATA(ls_run) = mo_cut->run( all_requests( ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-requested_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-allocated_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD empty_requests_empty_stats.
    DATA(lt_requests) = VALUE zcl_stock_alloc_run=>ty_request_tt( ).

    DATA(ls_run) = mo_cut->run( lt_requests ).

    cl_abap_unit_assert=>assert_equals( act = ls_run-stats-materials
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_initial( act = ls_run-materials ).
    cl_abap_unit_assert=>assert_initial( act = ls_run-shortages ).
  ENDMETHOD.

ENDCLASS.
