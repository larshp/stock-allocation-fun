CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_run TYPE zif_allocation_store=>ty_run_head_tab.

  PRIVATE SECTION.
    DATA mt_run TYPE zif_allocation_store=>ty_run_head_tab.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_run = it_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    rt_run = mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " a release records nothing: what was decided stays as it was decided
    CLEAR mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    CLEAR rt_allocation.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    CLEAR rt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mt_run.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_writer_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_reservation_writer.

    TYPES ty_rsnum_tab TYPE STANDARD TABLE OF rkpf-rsnum WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

    METHODS get_cancelled
      RETURNING
        VALUE(rt_rsnum) TYPE ty_rsnum_tab.

  PRIVATE SECTION.
    DATA mt_cancelled TYPE ty_rsnum_tab.
    DATA mv_refuse    TYPE abap_bool.

ENDCLASS.


CLASS lcl_writer_spy IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_reservation_writer~reserve.
    CLEAR rv_reservation.
  ENDMETHOD.

  METHOD zif_reservation_writer~cancel.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = |{ iv_reservation }| ).
    ENDIF.

    APPEND iv_reservation TO mt_cancelled.

  ENDMETHOD.

  METHOD get_cancelled.
    rt_rsnum = mt_cancelled.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_reservation_reader.

    METHODS constructor
      IMPORTING
        iv_held TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mv_held TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_reader_double IMPLEMENTATION.

  METHOD constructor.
    mv_held = iv_held.
  ENDMETHOD.

  METHOD zif_reservation_reader~live_reservations.
    CLEAR rt_reservation.
  ENDMETHOD.

  METHOD zif_reservation_reader~held_quantity.
    rv_quantity = mv_held.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_lock_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_lock.

    METHODS get_held
      RETURNING
        VALUE(rv_held) TYPE i.

  PRIVATE SECTION.
    DATA mv_held TYPE i.

ENDCLASS.


CLASS lcl_lock_spy IMPLEMENTATION.

  METHOD zif_allocation_lock~acquire.
    mv_held = mv_held + 1.
  ENDMETHOD.

  METHOD zif_allocation_lock~release.
    mv_held = mv_held - 1.
  ENDMETHOD.

  METHOD get_held.
    rv_held = mv_held.
  ENDMETHOD.

ENDCLASS.


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


CLASS lcl_commit_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_unit_of_work.

    METHODS get_commits
      RETURNING
        VALUE(rv_commits) TYPE i.

    METHODS get_rollbacks
      RETURNING
        VALUE(rv_rollbacks) TYPE i.

  PRIVATE SECTION.
    DATA mv_commits   TYPE i.
    DATA mv_rollbacks TYPE i.

ENDCLASS.


CLASS lcl_commit_spy IMPLEMENTATION.

  METHOD zif_unit_of_work~commit.
    mv_commits = mv_commits + 1.
  ENDMETHOD.

  METHOD zif_unit_of_work~rollback.
    mv_rollbacks = mv_rollbacks + 1.
  ENDMETHOD.

  METHOD get_commits.
    rv_commits = mv_commits.
  ENDMETHOD.

  METHOD get_rollbacks.
    rv_rollbacks = mv_rollbacks.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_log_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log.

    TYPES ty_rsnum_tab TYPE STANDARD TABLE OF rkpf-rsnum WITH EMPTY KEY.

    METHODS get_released
      RETURNING
        VALUE(rt_rsnum) TYPE ty_rsnum_tab.

    METHODS get_starts
      RETURNING
        VALUE(rv_starts) TYPE i.

    METHODS get_saves
      RETURNING
        VALUE(rv_saves) TYPE i.

  PRIVATE SECTION.
    DATA mt_released TYPE ty_rsnum_tab.
    DATA mv_starts   TYPE i.
    DATA mv_saves    TYPE i.

ENDCLASS.


CLASS lcl_log_spy IMPLEMENTATION.

  METHOD zif_allocation_log~start.
    mv_starts = mv_starts + 1.
  ENDMETHOD.

  METHOD zif_allocation_log~allocated.
    " a release allocates nothing
    CLEAR mv_starts.
  ENDMETHOD.

  METHOD zif_allocation_log~failed.
    CLEAR mv_starts.
  ENDMETHOD.

  METHOD zif_allocation_log~released.
    APPEND iv_reservation TO mt_released.
  ENDMETHOD.

  METHOD zif_allocation_log~removed.
    " and removes no record
    CLEAR mv_starts.
  ENDMETHOD.

  METHOD zif_allocation_log~finished.
    " a release covers one material and gives its stock back: there is no
    " count of its own worth keeping
    CLEAR mv_starts.
  ENDMETHOD.

  METHOD zif_allocation_log~save.
    mv_saves = mv_saves + 1.
  ENDMETHOD.

  METHOD get_released.
    rt_rsnum = mt_released.
  ENDMETHOD.

  METHOD get_starts.
    rv_starts = mv_starts.
  ENDMETHOD.

  METHOD get_saves.
    rv_saves = mv_saves.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_release DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'FREE-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9401'.
    CONSTANTS c_rsnum TYPE rkpf-rsnum VALUE '0000004711'.
    CONSTANTS c_other TYPE rkpf-rsnum VALUE '0000004712'.
    CONSTANTS c_none  TYPE rkpf-rsnum VALUE '0000000000'.

    DATA mo_writer TYPE REF TO lcl_writer_spy.
    DATA mo_lock   TYPE REF TO lcl_lock_spy.
    DATA mo_commit TYPE REF TO lcl_commit_spy.
    DATA mo_log    TYPE REF TO lcl_log_spy.

    METHODS cut
      IMPORTING
        it_run        TYPE zif_allocation_store=>ty_run_head_tab
        iv_held       TYPE zif_allocation=>ty_quantity DEFAULT 40
        iv_refuse     TYPE abap_bool DEFAULT abap_false
        iv_no_cancel  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_cut) TYPE REF TO zcl_alloc_release.

    METHODS run_of
      IMPORTING
        iv_rsnum      TYPE rkpf-rsnum
      RETURNING
        VALUE(rs_run) TYPE zif_allocation_store=>ty_run_head.

    METHODS the_reservation_is_cancelled FOR TESTING RAISING cx_static_check.
    METHODS every_reservation_goes_back FOR TESTING RAISING cx_static_check.
    METHODS a_run_without_one_is_skipped FOR TESTING RAISING cx_static_check.
    METHODS an_empty_reservation_is_left FOR TESTING RAISING cx_static_check.
    METHODS a_test_run_changes_nothing FOR TESTING RAISING cx_static_check.
    METHODS what_came_back_is_counted FOR TESTING RAISING cx_static_check.
    METHODS the_release_is_written_down FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.
    METHODS the_lock_is_given_back FOR TESTING RAISING cx_static_check.
    METHODS a_refused_cancel_rolls_back FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_release IMPLEMENTATION.

  METHOD cut.

    mo_writer = NEW lcl_writer_spy( iv_no_cancel ).
    mo_lock   = NEW lcl_lock_spy( ).
    mo_commit = NEW lcl_commit_spy( ).
    mo_log    = NEW lcl_log_spy( ).

    ro_cut = NEW zcl_alloc_release(
      io_store     = NEW lcl_store_double( it_run )
      io_writer    = mo_writer
      io_reader    = NEW lcl_reader_double( iv_held )
      io_authority = NEW lcl_authority_double( iv_refuse )
      io_lock      = mo_lock
      io_commit    = mo_commit
      io_log       = mo_log ).

  ENDMETHOD.

  METHOD run_of.

    rs_run = VALUE #(
      run_id      = |RUN-{ iv_rsnum }|
      matnr       = c_matnr
      werks       = c_werks
      reservation = iv_rsnum ).

  ENDMETHOD.

  METHOD the_reservation_is_cancelled.

    cut( VALUE #( ( run_of( c_rsnum ) ) ) )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->get_cancelled( )
      exp = VALUE lcl_writer_spy=>ty_rsnum_tab( ( c_rsnum ) )
      msg = 'the stock a planner asked for back is the stock that comes back' ).

  ENDMETHOD.

  METHOD every_reservation_goes_back.

    cut( VALUE #( ( run_of( c_rsnum ) )
                  ( run_of( c_other ) ) ) )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks
      iv_test  = abap_false ).

    " a material re-cut a few times has a reservation per run, and half of
    " them given back is stock nobody can account for
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_writer->get_cancelled( ) )
      exp = 2 ).

  ENDMETHOD.

  METHOD a_run_without_one_is_skipped.

    cut( VALUE #( ( run_of( c_none ) ) ) )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_writer->get_cancelled( )
      msg = 'a run that never reserved anything holds nothing back' ).

  ENDMETHOD.

  METHOD an_empty_reservation_is_left.

    cut( it_run  = VALUE #( ( run_of( c_rsnum ) ) )
         iv_held = 0 )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks
      iv_test  = abap_false ).

    " a reservation that has been issued or deleted already is not holding
    " anything, and cancelling it would tell the log a lie
    cl_abap_unit_assert=>assert_initial( mo_writer->get_cancelled( ) ).

  ENDMETHOD.

  METHOD a_test_run_changes_nothing.

    DATA(ls_outcome) = cut( VALUE #( ( run_of( c_rsnum ) ) ) )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-freed
      exp = 1
      msg = 'a test run says what it would give back' ).
    cl_abap_unit_assert=>assert_initial( mo_writer->get_cancelled( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 0
      msg = 'and commits nothing while saying it' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_log->get_starts( )
      exp = 0 ).

  ENDMETHOD.

  METHOD what_came_back_is_counted.

    DATA(ls_outcome) = cut(
      it_run  = VALUE #( ( run_of( c_rsnum ) )
                         ( run_of( c_other ) ) )
      iv_held = 25 )->run(
        iv_matnr = c_matnr
        iv_werks = c_werks
        iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-quantity
      exp = CONV zif_allocation=>ty_quantity( 50 )
      msg = 'what came back into the pool is what the reservations held' ).

  ENDMETHOD.

  METHOD the_release_is_written_down.

    cut( VALUE #( ( run_of( c_rsnum ) ) ) )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_log->get_released( )
      exp = VALUE lcl_log_spy=>ty_rsnum_tab( ( c_rsnum ) )
      msg = 'stock that came back with nobody named is stock nobody can account for' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_log->get_saves( )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 1 ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        cut( it_run    = VALUE #( ( run_of( c_rsnum ) ) )
             iv_refuse = abap_true )->run(
          iv_matnr = c_matnr
          iv_werks = c_werks
          iv_test  = abap_false ).
        cl_abap_unit_assert=>fail( 'giving stock back is a change like any other' ).
      CATCH zcx_allocation.
        cl_abap_unit_assert=>assert_initial( mo_writer->get_cancelled( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD the_lock_is_given_back.

    cut( VALUE #( ( run_of( c_rsnum ) ) ) )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->get_held( )
      exp = 0
      msg = 'a material nobody can allocate afterwards is worse than one that was not released' ).

  ENDMETHOD.

  METHOD a_refused_cancel_rolls_back.

    TRY.
        cut( it_run       = VALUE #( ( run_of( c_rsnum ) ) )
             iv_no_cancel = abap_true )->run(
          iv_matnr = c_matnr
          iv_werks = c_werks
          iv_test  = abap_false ).
        cl_abap_unit_assert=>fail( 'a cancellation the system refused is not a release' ).
      CATCH zcx_allocation.
        cl_abap_unit_assert=>assert_equals(
          act = mo_commit->get_rollbacks( )
          exp = 1 ).
        cl_abap_unit_assert=>assert_equals(
          act = mo_lock->get_held( )
          exp = 0 ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
