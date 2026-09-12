CLASS ltcl_stock_commitment DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_stock_commitment.

    METHODS setup.
    METHODS teardown.

    METHODS result_with
      IMPORTING
        iv_matnr         TYPE matnr
        iv_lgort         TYPE lgort_d
        iv_qty           TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS given_reservation
      IMPORTING
        iv_matnr       TYPE matnr
        iv_lgort       TYPE lgort_d
        iv_qty         TYPE menge_d DEFAULT 0
        iv_created_dat TYPE d DEFAULT '20260101'.

    METHODS commit_writes_rows         FOR TESTING.
    METHODS open_sums_per_location     FOR TESTING.
    METHODS commit_uses_row_material   FOR TESTING.
    METHODS commit_defaults_material   FOR TESTING.
    METHODS release_removes_rows       FOR TESTING.
    METHODS empty_result_writes_nothing FOR TESTING.
    METHODS commit_stamps_creation_date FOR TESTING.
    METHODS purge_removes_older_rows   FOR TESTING.
    METHODS purge_keeps_cutoff_day     FOR TESTING.
    METHODS purge_counts_all_removed   FOR TESTING.
    METHODS purge_older_than_drops_old FOR TESTING.
    METHODS read_expired_does_not_delete FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_commitment IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKRESV' ) ) ).
    mo_cut = NEW zcl_stock_commitment( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD result_with.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.
    DATA ls_alloc  TYPE zcl_stock_allocator=>ty_allocation.

    ls_result-requirement_id = 'REQ-1'.
    ls_result-requested_qty = iv_qty.
    ls_result-allocated_qty = iv_qty.

    ls_alloc-matnr = iv_matnr.
    ls_alloc-requirement_id = 'REQ-1'.
    ls_alloc-lgort = iv_lgort.
    ls_alloc-quantity = iv_qty.

    APPEND ls_alloc TO ls_result-allocations.
    APPEND ls_result TO rt_result.
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

  METHOD commit_writes_rows.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-1'
                               iv_lgort = '0001'
                               iv_qty   = '4' ) ).

    cl_abap_unit_assert=>assert_equals( act = lv_written
                                        exp = 1 ).

    DATA(lt_open) = mo_cut->read_open( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_open )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 1 ]-qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD open_sums_per_location.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-1'
                               iv_lgort = '0001'
                               iv_qty   = '4' ) ).
    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-2'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-1'
                               iv_lgort = '0001'
                               iv_qty   = '3' ) ).
    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-2'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-1'
                               iv_lgort = '0002'
                               iv_qty   = '2' ) ).

    DATA(lt_open) = mo_cut->read_open( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_open )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 1 ]-qty
                                        exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 2 ]-qty
                                        exp = '2' ).
  ENDMETHOD.

  METHOD commit_uses_row_material.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-SUB'
                               iv_lgort = '0001'
                               iv_qty   = '4' ) ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open( iv_matnr = 'MAT-1'
                               iv_werks = '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->read_open( iv_matnr = 'MAT-SUB'
                                      iv_werks = '1000' ) )
      exp = 1 ).
  ENDMETHOD.

  METHOD commit_defaults_material.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = ''
                               iv_lgort = '0001'
                               iv_qty   = '4' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->read_open( iv_matnr = 'MAT-1'
                                      iv_werks = '1000' ) )
      exp = 1 ).
  ENDMETHOD.

  METHOD release_removes_rows.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-1'
                               iv_lgort = '0001'
                               iv_qty   = '4' ) ).

    mo_cut->release_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open( iv_matnr = 'MAT-1'
                               iv_werks = '1000' ) ).
  ENDMETHOD.

  METHOD empty_result_writes_nothing.
    DATA lt_empty   TYPE zcl_stock_allocator=>ty_result_tt.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = lt_empty ).

    cl_abap_unit_assert=>assert_equals( act = lv_written
                                        exp = 0 ).
  ENDMETHOD.

  METHOD commit_stamps_creation_date.
    DATA lv_written TYPE i.

    lv_written = mo_cut->commit(
      iv_run_id = 'RUN-1'
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_result = result_with( iv_matnr = 'MAT-1'
                               iv_lgort = '0001'
                               iv_qty   = '4' ) ).

    SELECT SINGLE created_dat FROM zstockresv INTO @DATA(lv_created)
      WHERE run_id = 'RUN-1'.

    cl_abap_unit_assert=>assert_equals( act = lv_created
                                        exp = sy-datum ).
  ENDMETHOD.

  METHOD purge_removes_older_rows.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '20260101' ).
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0002'
                       iv_qty         = '2'
                       iv_created_dat = '20260301' ).

    DATA(lv_deleted) = mo_cut->purge_before( '20260201' ).

    cl_abap_unit_assert=>assert_equals( act = lv_deleted
                                        exp = 1 ).

    DATA(lt_open) = mo_cut->read_open( iv_matnr = 'MAT-1'
                                       iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_open )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 1 ]-lgort
                                        exp = '0002' ).
  ENDMETHOD.

  METHOD purge_keeps_cutoff_day.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '20260201' ).

    DATA(lv_deleted) = mo_cut->purge_before( '20260201' ).

    cl_abap_unit_assert=>assert_equals( act = lv_deleted
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->read_open( iv_matnr = 'MAT-1'
                                      iv_werks = '1000' ) )
      exp = 1 ).
  ENDMETHOD.

  METHOD purge_counts_all_removed.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '1'
                       iv_created_dat = '20260101' ).
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0002'
                       iv_qty         = '1'
                       iv_created_dat = '20260102' ).

    DATA(lv_deleted) = mo_cut->purge_before( '20260201' ).

    cl_abap_unit_assert=>assert_equals( act = lv_deleted
                                        exp = 2 ).
  ENDMETHOD.

  METHOD purge_older_than_drops_old.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '19000101' ).

    DATA(lv_deleted) = mo_cut->purge_older_than( 30 ).

    cl_abap_unit_assert=>assert_equals( act = lv_deleted
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open( iv_matnr = 'MAT-1'
                               iv_werks = '1000' ) ).
  ENDMETHOD.

  METHOD read_expired_does_not_delete.
    given_reservation( iv_matnr       = 'MAT-1'
                       iv_lgort       = '0001'
                       iv_qty         = '4'
                       iv_created_dat = '20260101' ).
    given_reservation( iv_matnr       = 'MAT-2'
                       iv_lgort       = '0001'
                       iv_qty         = '2'
                       iv_created_dat = '20260301' ).

    DATA(lt_resv) = mo_cut->read_expired( '20260201' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_resv )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_resv[ 1 ]-matnr
                                        exp = 'MAT-1' ).

    " a dry run must not remove anything
    SELECT SINGLE COUNT( * ) FROM zstockresv INTO @DATA(lv_rows).

    cl_abap_unit_assert=>assert_equals( act = lv_rows
                                        exp = 2 ).
  ENDMETHOD.

ENDCLASS.
