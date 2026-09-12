CLASS ltcl_alloc_log_reader DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_alloc_log_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_log_row
      IMPORTING
        iv_run_id TYPE zstock_run_id
        iv_matnr  TYPE matnr
        iv_req_id TYPE zstockalloc-req_id
        iv_lgort  TYPE lgort_d
        iv_qty    TYPE menge_d DEFAULT 0.

    METHODS reads_only_its_run        FOR TESTING.
    METHODS summarizes_positions      FOR TESTING.
    METHODS counts_distinct_materials FOR TESTING.
    METHODS summarize_all_groups_runs FOR TESTING.
    METHODS empty_run_is_zero         FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_log_reader IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKALLOC' ) ) ).
    mo_cut = NEW zcl_alloc_log_reader( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_log_row.
    DATA ls_log TYPE zstockalloc.

    ls_log-mandt     = sy-mandt.
    ls_log-run_id    = iv_run_id.
    ls_log-req_id    = iv_req_id.
    ls_log-lgort     = iv_lgort.
    ls_log-matnr     = iv_matnr.
    ls_log-werks     = '1000'.
    ls_log-alloc_dat = '20260101'.
    ls_log-alloc_tim = '120000'.
    ls_log-uname     = 'TESTER'.
    ls_log-alloc_qty = iv_qty.

    mo_environment->insert_test_data(
      VALUE zcl_alloc_log_reader=>ty_log_tt( ( ls_log ) ) ).
  ENDMETHOD.

  METHOD reads_only_its_run.
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
                   iv_req_id = 'REQ-1' iv_lgort = '0001' iv_qty = '4' ).
    given_log_row( iv_run_id = 'RUN-2' iv_matnr = 'MAT-2'
                   iv_req_id = 'REQ-2' iv_lgort = '0001' iv_qty = '5' ).

    DATA(lt_log) = mo_cut->read_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_log )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-matnr
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD summarizes_positions.
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
                   iv_req_id = 'REQ-1' iv_lgort = '0001' iv_qty = '3' ).
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-2'
                   iv_req_id = 'REQ-2' iv_lgort = '0001' iv_qty = '4' ).

    DATA(ls_summary) = mo_cut->summarize_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-positions
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocated_qty
                                        exp = '7' ).
  ENDMETHOD.

  METHOD counts_distinct_materials.
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
                   iv_req_id = 'REQ-1' iv_lgort = '0001' iv_qty = '1' ).
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
                   iv_req_id = 'REQ-2' iv_lgort = '0002' iv_qty = '2' ).
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-2'
                   iv_req_id = 'REQ-3' iv_lgort = '0001' iv_qty = '3' ).

    DATA(ls_summary) = mo_cut->summarize_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-materials
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-positions
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocated_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD summarize_all_groups_runs.
    given_log_row( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
                   iv_req_id = 'REQ-1' iv_lgort = '0001' iv_qty = '2' ).
    given_log_row( iv_run_id = 'RUN-2' iv_matnr = 'MAT-2'
                   iv_req_id = 'REQ-2' iv_lgort = '0001' iv_qty = '5' ).
    given_log_row( iv_run_id = 'RUN-2' iv_matnr = 'MAT-2'
                   iv_req_id = 'REQ-3' iv_lgort = '0002' iv_qty = '5' ).

    DATA(lt_summary) = mo_cut->summarize_all( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_summary )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 1 ]-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 1 ]-allocated_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 2 ]-run_id
                                        exp = 'RUN-2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 2 ]-materials
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_summary[ 2 ]-allocated_qty
                                        exp = '10' ).
  ENDMETHOD.

  METHOD empty_run_is_zero.
    DATA(ls_summary) = mo_cut->summarize_run( 'RUN-X' ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-run_id
                                        exp = 'RUN-X' ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-materials
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-positions
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-allocated_qty
                                        exp = '0' ).
  ENDMETHOD.

ENDCLASS.
