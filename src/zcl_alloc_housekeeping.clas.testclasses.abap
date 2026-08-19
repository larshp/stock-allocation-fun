CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mv_refuse TYPE abap_bool.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.
    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_housekeeping DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr     TYPE mard-matnr VALUE 'HOUSEKEEP-01'.
    CONSTANTS c_werks     TYPE mard-werks VALUE '1000'.
    CONSTANTS c_werks_2   TYPE mard-werks VALUE '2000'.
    CONSTANTS c_keep_days TYPE i VALUE 30.

    "! Well before any cut-off the tests work with.
    CONSTANTS c_long_ago TYPE zstock_alloc_res-created_at VALUE '20200101120000'.

    DATA mo_cut TYPE REF TO zcl_alloc_housekeeping.

    METHODS setup.
    METHODS teardown.

    "! A recorded run, and the reservation it produced if it produced one.
    METHODS given_run
      IMPORTING
        iv_run_id     TYPE zstock_alloc_res-run_id
        iv_rsnum      TYPE rkpf-rsnum DEFAULT '0000000000'
        iv_werks      TYPE mard-werks DEFAULT c_werks
        iv_created_at TYPE zstock_alloc_res-created_at DEFAULT c_long_ago
        iv_lines      TYPE i DEFAULT 1
        iv_deleted    TYPE abap_bool DEFAULT abap_false.

    METHODS rows_of
      IMPORTING
        iv_run_id      TYPE zstock_alloc_res-run_id
      RETURNING
        VALUE(rv_rows) TYPE i.

    METHODS remove
      IMPORTING
        iv_test           TYPE abap_bool DEFAULT abap_false
        iv_werks          TYPE mard-werks DEFAULT c_werks
      RETURNING
        VALUE(rs_outcome) TYPE zcl_alloc_housekeeping=>ty_outcome
      RAISING
        cx_static_check.

    METHODS live_reservation_is_kept FOR TESTING RAISING cx_static_check.
    METHODS deleted_reservation_run_goes FOR TESTING RAISING cx_static_check.
    METHODS vanished_reservation_goes FOR TESTING RAISING cx_static_check.
    METHODS unreserved_run_goes FOR TESTING RAISING cx_static_check.
    METHODS a_recent_run_is_left_alone FOR TESTING RAISING cx_static_check.
    METHODS a_run_counts_once FOR TESTING RAISING cx_static_check.
    METHODS test_run_deletes_nothing FOR TESTING RAISING cx_static_check.
    METHODS other_plant_is_untouched FOR TESTING RAISING cx_static_check.
    METHODS refused_run_deletes_nothing FOR TESTING.

ENDCLASS.


CLASS ltcl_housekeeping IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW zcl_alloc_housekeeping(
      io_store       = NEW zcl_allocation_store( )
      io_reservation = NEW zcl_reservation_reader( )
      io_authority   = NEW lcl_authority_double( ) ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM resb WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_run.

    DATA lt_result TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lt_resb   TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_posnr  TYPE n LENGTH 6.

    DO iv_lines TIMES.
      lv_posnr = sy-index.
      APPEND VALUE #(
        mandt       = sy-mandt
        run_id      = iv_run_id
        demand_id   = |0000004711{ lv_posnr }|
        matnr       = c_matnr
        werks       = iv_werks
        confirmed   = '5'
        reservation = iv_rsnum
        created_at  = iv_created_at ) TO lt_result.
    ENDDO.

    INSERT zstock_alloc_res FROM TABLE @lt_result.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'recorded run fixture could not be inserted' ).

    IF iv_rsnum = '0000000000'.
      RETURN.
    ENDIF.

    lt_resb = VALUE #(
      ( mandt = sy-mandt
        rsnum = iv_rsnum
        rspos = '0001'
        matnr = c_matnr
        werks = iv_werks
        bdmng = '5'
        xloek = COND #( WHEN iv_deleted = abap_true THEN 'X' ) ) ).

    INSERT resb FROM TABLE @lt_resb.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'reservation fixture could not be inserted' ).

  ENDMETHOD.

  METHOD rows_of.

    SELECT COUNT( * )
      FROM zstock_alloc_res
      WHERE run_id = @iv_run_id
      INTO @rv_rows.

  ENDMETHOD.

  METHOD remove.

    rs_outcome = mo_cut->run(
      iv_werks     = iv_werks
      iv_keep_days = c_keep_days
      iv_test      = iv_test ).

  ENDMETHOD.

  METHOD live_reservation_is_kept.

    given_run(
      iv_run_id = 'HOUSEKEEP-RUN-000001'
      iv_rsnum  = '0000006001' ).

    DATA(ls_outcome) = remove( ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-kept
      exp = 1
      msg = 'the demand netting still reads this run, so it has to stay' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-deleted
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000001' )
      exp = 1 ).

  ENDMETHOD.

  METHOD deleted_reservation_run_goes.

    given_run(
      iv_run_id  = 'HOUSEKEEP-RUN-000002'
      iv_rsnum   = '0000006002'
      iv_deleted = abap_true ).

    DATA(ls_outcome) = remove( ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-deleted
      exp = 1
      msg = 'a reservation flagged for deletion holds nothing, nor does the record' ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000002' )
      exp = 0 ).

  ENDMETHOD.

  METHOD vanished_reservation_goes.

    " recorded with a reservation number that is not in RESB at all
    given_run(
      iv_run_id = 'HOUSEKEEP-RUN-000003'
      iv_rsnum  = '0000006003' ).

    DELETE FROM resb WHERE rsnum = '0000006003'.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = remove( )-deleted
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000003' )
      exp = 0 ).

  ENDMETHOD.

  METHOD unreserved_run_goes.

    " the result was written down but the reservation was rejected
    given_run( 'HOUSEKEEP-RUN-000004' ).

    cl_abap_unit_assert=>assert_equals(
      act = remove( )-deleted
      exp = 1
      msg = 'a run that never earmarked anything is only worth keeping for a while' ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000004' )
      exp = 0 ).

  ENDMETHOD.

  METHOD a_recent_run_is_left_alone.

    DATA lv_now TYPE zstock_alloc_res-created_at.

    GET TIME STAMP FIELD lv_now.

    given_run(
      iv_run_id     = 'HOUSEKEEP-RUN-000005'
      iv_created_at = lv_now ).

    DATA(ls_outcome) = remove( ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-deleted
      exp = 0
      msg = 'a rejected reservation must still be there to be looked up and retried' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-kept
      exp = 0
      msg = 'a run inside the retention time is not even a candidate' ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000005' )
      exp = 1 ).

  ENDMETHOD.

  METHOD a_run_counts_once.

    given_run(
      iv_run_id = 'HOUSEKEEP-RUN-000006'
      iv_lines  = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = remove( )-deleted
      exp = 1
      msg = 'three demand lines of one run are one run' ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000006' )
      exp = 0
      msg = 'and all of its lines go' ).

  ENDMETHOD.

  METHOD test_run_deletes_nothing.

    given_run( 'HOUSEKEEP-RUN-000007' ).

    cl_abap_unit_assert=>assert_equals(
      act = remove( iv_test = abap_true )-deleted
      exp = 1
      msg = 'a test run says what it would remove' ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000007' )
      exp = 1
      msg = 'and removes none of it' ).

  ENDMETHOD.

  METHOD other_plant_is_untouched.

    given_run(
      iv_run_id = 'HOUSEKEEP-RUN-000008'
      iv_werks  = c_werks_2 ).

    cl_abap_unit_assert=>assert_equals(
      act = remove( )-deleted
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = rows_of( 'HOUSEKEEP-RUN-000008' )
      exp = 1
      msg = 'housekeeping covers the plant it was asked about' ).

  ENDMETHOD.

  METHOD refused_run_deletes_nothing.

    given_run( 'HOUSEKEEP-RUN-000009' ).

    DATA(lo_cut) = NEW zcl_alloc_housekeeping(
      io_store       = NEW zcl_allocation_store( )
      io_reservation = NEW zcl_reservation_reader( )
      io_authority   = NEW lcl_authority_double( abap_true ) ).

    TRY.
        lo_cut->run(
          iv_werks     = c_werks
          iv_keep_days = c_keep_days
          iv_test      = abap_false ).
        cl_abap_unit_assert=>fail( 'a refused user must not get past the check' ).
      CATCH zcx_allocation.
        cl_abap_unit_assert=>assert_equals(
          act = rows_of( 'HOUSEKEEP-RUN-000009' )
          exp = 1
          msg = 'nothing may be deleted for a plant the user may not touch' ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
