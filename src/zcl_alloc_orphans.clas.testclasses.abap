CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_run      TYPE zif_allocation_store=>ty_run_head_tab
        it_recorded TYPE zif_allocation=>ty_allocation_tab.

  PRIVATE SECTION.
    DATA mt_run      TYPE zif_allocation_store=>ty_run_head_tab.
    DATA mt_recorded TYPE zif_allocation=>ty_allocation_tab.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_run      = it_run.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    rt_run = mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    rt_allocation = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    CLEAR mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    CLEAR rt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mt_run.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_writer_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_reservation_writer.

    TYPES ty_rsnum_tab TYPE STANDARD TABLE OF rkpf-rsnum WITH EMPTY KEY.

    METHODS get_cancelled
      RETURNING
        VALUE(rt_rsnum) TYPE ty_rsnum_tab.

  PRIVATE SECTION.
    DATA mt_cancelled TYPE ty_rsnum_tab.

ENDCLASS.


CLASS lcl_writer_spy IMPLEMENTATION.

  METHOD zif_reservation_writer~reserve.
    CLEAR rv_reservation.
  ENDMETHOD.

  METHOD zif_reservation_writer~cancel.
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

  PRIVATE SECTION.
    DATA mv_commits TYPE i.

ENDCLASS.


CLASS lcl_commit_spy IMPLEMENTATION.

  METHOD zif_unit_of_work~commit.
    mv_commits = mv_commits + 1.
  ENDMETHOD.

  METHOD zif_unit_of_work~rollback.
    CLEAR mv_commits.
  ENDMETHOD.

  METHOD get_commits.
    rv_commits = mv_commits.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_log_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log.

    METHODS get_saves
      RETURNING
        VALUE(rv_saves) TYPE i.

  PRIVATE SECTION.
    DATA mv_saves TYPE i.

ENDCLASS.


CLASS lcl_log_spy IMPLEMENTATION.

  METHOD zif_allocation_log~start.
    CLEAR mv_saves.
  ENDMETHOD.

  METHOD zif_allocation_log~allocated.
    CLEAR mv_saves.
  ENDMETHOD.

  METHOD zif_allocation_log~failed.
    CLEAR mv_saves.
  ENDMETHOD.

  METHOD zif_allocation_log~released.
    CLEAR mv_saves.
  ENDMETHOD.

  METHOD zif_allocation_log~removed.
    CLEAR mv_saves.
  ENDMETHOD.

  METHOD zif_allocation_log~finished.
    CLEAR mv_saves.
  ENDMETHOD.

  METHOD zif_allocation_log~save.
    mv_saves = mv_saves + 1.
  ENDMETHOD.

  METHOD get_saves.
    rv_saves = mv_saves.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_orphans DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9631'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'ORPH-MAT-01'.
    CONSTANTS c_rsnum TYPE rkpf-rsnum VALUE '0000005511'.

    DATA mo_writer TYPE REF TO lcl_writer_spy.
    DATA mo_lock   TYPE REF TO lcl_lock_spy.

    METHODS sweep
      IMPORTING
        it_demand      TYPE zif_allocation=>ty_demand_tab
        iv_held        TYPE zif_allocation=>ty_quantity DEFAULT 20
        iv_test        TYPE abap_bool DEFAULT abap_false
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_orphans=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_orphans=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS a_line_that_is_gone_frees_it FOR TESTING RAISING cx_static_check.
    METHODS a_line_still_there_keeps_it FOR TESTING RAISING cx_static_check.
    METHODS an_empty_reservation_is_left FOR TESTING RAISING cx_static_check.
    METHODS a_test_run_frees_nothing FOR TESTING RAISING cx_static_check.
    METHODS the_lock_is_given_back FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_orphans IMPLEMENTATION.

  METHOD sweep.

    mo_writer = NEW lcl_writer_spy( ).
    mo_lock   = NEW lcl_lock_spy( ).

    rt_line = NEW zcl_alloc_orphans(
      io_store     = NEW lcl_store_double(
        it_run      = VALUE #( ( run_id      = 'ORPH-RUN-1'
                                 matnr       = c_matnr
                                 werks       = c_werks
                                 reservation = c_rsnum ) )
        it_recorded = VALUE #( ( demand_id = 'GONE-D1'
                                 requested = 20
                                 confirmed = 20 ) ) )
      io_demand    = NEW lcl_demand_double( it_demand )
      io_writer    = mo_writer
      io_reader    = NEW lcl_reader_double( iv_held )
      io_authority = NEW lcl_authority_double( iv_refuse )
      io_lock      = mo_lock
      io_commit    = NEW lcl_commit_spy( )
      io_log       = NEW lcl_log_spy( ) )->run(
        iv_werks = c_werks
        iv_test  = iv_test ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD a_line_that_is_gone_frees_it.

    " the run reserved for GONE-D1 and the documents no longer have it
    sweep( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_writer->get_cancelled( ) )
      exp = 1
      msg = 'stock held for a line nobody has any more is stock nobody can use' ).

  ENDMETHOD.

  METHOD a_line_still_there_keeps_it.

    sweep( VALUE #( ( demand_id = 'GONE-D1'
                      matnr     = c_matnr
                      werks     = c_werks
                      quantity  = 20 ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_writer->get_cancelled( )
      msg = 'a reservation whose line is still on the books is doing its job' ).

  ENDMETHOD.

  METHOD an_empty_reservation_is_left.

    " already issued or already cancelled: there is nothing to give back and
    " nothing to say about it
    DATA(lt_line) = sweep( it_demand = VALUE #( )
                           iv_held   = 0 ).

    cl_abap_unit_assert=>assert_initial( mo_writer->get_cancelled( ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `0 reservation(s) looked at` ) ).

  ENDMETHOD.

  METHOD a_test_run_frees_nothing.

    DATA(lt_line) = sweep( it_demand = VALUE #( )
                           iv_test   = abap_true ).

    cl_abap_unit_assert=>assert_initial( mo_writer->get_cancelled( ) ).
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `1 would be given back` )
      msg = 'a sweep says what it would do before anybody lets it do it' ).

  ENDMETHOD.

  METHOD the_lock_is_given_back.

    sweep( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->get_held( )
      exp = 0 ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        sweep( it_demand = VALUE #( )
               iv_refuse = abap_true ).
        cl_abap_unit_assert=>fail( 'giving stock back is a change like any other' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
