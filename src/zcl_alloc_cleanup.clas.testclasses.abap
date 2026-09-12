CLASS ltcl_alloc_cleanup DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_alloc_cleanup.

    METHODS setup.
    METHODS teardown.

    METHODS given_reservation
      IMPORTING
        iv_matnr       TYPE matnr
        iv_lgort       TYPE lgort_d
        iv_qty         TYPE menge_d DEFAULT 0
        iv_created_dat TYPE d DEFAULT '20260101'.

    METHODS rows_in_table
      RETURNING
        VALUE(rv_rows) TYPE i.

    METHODS simulation_keeps_rows FOR TESTING.
    METHODS execute_removes_rows FOR TESTING.
    METHODS keeps_newer_rows     FOR TESTING.
    METHODS retention_days_apply FOR TESTING.
    METHODS nothing_to_do        FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_cleanup IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKRESV' ) ) ).
    mo_cut = NEW zcl_alloc_cleanup( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_reservation.
    DATA ls_resv TYPE zstockresv.

    ls_resv-mandt = sy-mandt.
    ls_resv-matnr = iv_matnr.
    ls_resv-werks = '1000'.
    ls_resv-lgort = iv_lgort.
    ls_resv-run_id = 'RUN-OLD'.
    ls_resv-req_id = 'REQ-OLD'.
    ls_resv-qty = iv_qty.
    ls_resv-created_dat = iv_created_dat.

    mo_environment->insert_test_data(
      VALUE zcl_stock_commitment=>ty_resv_tt( ( ls_resv ) ) ).
  ENDMETHOD.

  METHOD rows_in_table.
    SELECT SINGLE COUNT( * ) FROM zstockresv INTO @rv_rows.
  ENDMETHOD.

  METHOD simulation_keeps_rows.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '20260101' ).
    given_reservation( iv_matnr       = 'MAT-2'
                       iv_lgort       = '0001'
                       iv_qty         = '2'
                       iv_created_dat = '20260105' ).

    DATA(ls_outcome) = mo_cut->run_before( iv_cutoff     = '20260201'
                                           iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = ls_outcome-simulation
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_outcome-cutoff
                                        exp = '20260201' ).
    cl_abap_unit_assert=>assert_equals( act = ls_outcome-candidates
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_outcome-rows )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_outcome-removed
                                        exp = 0 ).

    " a dry run does not delete anything
    cl_abap_unit_assert=>assert_equals( act = rows_in_table( )
                                        exp = 2 ).
  ENDMETHOD.

  METHOD execute_removes_rows.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '20260101' ).
    given_reservation( iv_matnr       = 'MAT-2'
                       iv_lgort       = '0001'
                       iv_qty         = '2'
                       iv_created_dat = '20260105' ).

    DATA(ls_outcome) = mo_cut->run_before( iv_cutoff     = '20260201'
                                           iv_simulation = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_outcome-candidates
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_outcome-removed
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows_in_table( )
                                        exp = 0 ).
  ENDMETHOD.

  METHOD keeps_newer_rows.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '20260101' ).
    given_reservation( iv_matnr       = 'MAT-2'
                       iv_lgort       = '0001'
                       iv_qty         = '2'
                       iv_created_dat = '20260301' ).

    DATA(ls_outcome) = mo_cut->run_before( iv_cutoff     = '20260201'
                                           iv_simulation = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_outcome-candidates
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_outcome-removed
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows_in_table( )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-rows[ 1 ]-matnr exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD retention_days_apply.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '19000101' ).

    DATA(ls_outcome) = mo_cut->run( iv_retention_days = 30
                                    iv_simulation     = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_outcome-removed
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows_in_table( )
                                        exp = 0 ).
  ENDMETHOD.

  METHOD nothing_to_do.
    DATA(ls_outcome) = mo_cut->run_before( iv_cutoff     = '20260201'
                                           iv_simulation = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_outcome-candidates
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_outcome-removed
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_initial( act = ls_outcome-rows ).
  ENDMETHOD.

ENDCLASS.
