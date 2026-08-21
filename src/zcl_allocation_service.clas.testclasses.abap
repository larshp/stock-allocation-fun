CLASS lcl_stock_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS constructor
      IMPORTING
        iv_available TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mv_available TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_stock_reader_double IMPLEMENTATION.

  METHOD constructor.
    mv_available = iv_available.
  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.
    rt_stock = VALUE #(
      ( matnr = iv_matnr werks = iv_werks lgort = '0001' available = mv_available ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_demand_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.

ENDCLASS.


CLASS lcl_demand_reader_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    LOOP AT mt_demand INTO DATA(ls_demand).
      IF NOT line_exists( rt_matnr[ table_line = ls_demand-matnr ] ).
        APPEND ls_demand-matnr TO rt_matnr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_run_id_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_run_id_supplier.

    METHODS constructor
      IMPORTING
        iv_run_id TYPE zstock_alloc_res-run_id.

  PRIVATE SECTION.
    DATA mv_run_id TYPE zstock_alloc_res-run_id.

ENDCLASS.


CLASS lcl_run_id_double IMPLEMENTATION.

  METHOD constructor.
    mv_run_id = iv_run_id.
  ENDMETHOD.

  METHOD zif_run_id_supplier~next.
    rv_run_id = mv_run_id.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_reservation_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_reservation_writer.

    METHODS constructor
      IMPORTING
        iv_reservation TYPE rkpf-rsnum
        iv_fail        TYPE abap_bool DEFAULT abap_false.

    METHODS get_last_allocation
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS get_cancelled
      RETURNING
        VALUE(rt_reservation) TYPE ty_reservation_tab.

    TYPES ty_reservation_tab TYPE STANDARD TABLE OF rkpf-rsnum WITH EMPTY KEY.

  PRIVATE SECTION.
    DATA mv_reservation TYPE rkpf-rsnum.
    DATA mv_fail        TYPE abap_bool.
    DATA mt_last        TYPE zif_allocation=>ty_allocation_tab.
    DATA mt_cancelled   TYPE ty_reservation_tab.

ENDCLASS.


CLASS lcl_reservation_double IMPLEMENTATION.

  METHOD constructor.
    mv_reservation = iv_reservation.
    mv_fail        = iv_fail.
  ENDMETHOD.

  METHOD zif_reservation_writer~reserve.
    IF mv_fail = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = `stock is blocked` ).
    ENDIF.
    mt_last = it_allocation.
    rv_reservation = mv_reservation.
  ENDMETHOD.

  METHOD get_last_allocation.
    rt_allocation = mt_last.
  ENDMETHOD.

  METHOD zif_reservation_writer~cancel.
    APPEND iv_reservation TO mt_cancelled.
  ENDMETHOD.

  METHOD get_cancelled.
    rt_reservation = mt_cancelled.
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


CLASS lcl_lock_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_lock.

    METHODS get_held
      RETURNING
        VALUE(rv_held) TYPE i.

  PRIVATE SECTION.
    DATA mv_held TYPE i.

ENDCLASS.


CLASS lcl_lock_double IMPLEMENTATION.

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


CLASS lcl_commit_double DEFINITION FINAL.

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


CLASS lcl_commit_double IMPLEMENTATION.

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

"! Remembers what the service told it about giving stock back.
CLASS lcl_log_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log.

    TYPES ty_reservation_tab TYPE STANDARD TABLE OF rkpf-rsnum WITH EMPTY KEY.

    METHODS get_released
      RETURNING
        VALUE(rt_reservation) TYPE ty_reservation_tab.

    METHODS get_other
      RETURNING
        VALUE(rv_other) TYPE i.

  PRIVATE SECTION.
    DATA mt_released TYPE ty_reservation_tab.
    DATA mv_other    TYPE i.

ENDCLASS.


CLASS lcl_log_spy IMPLEMENTATION.

  METHOD get_released.
    rt_reservation = mt_released.
  ENDMETHOD.

  METHOD get_other.
    rv_other = mv_other.
  ENDMETHOD.

  METHOD zif_allocation_log~released.
    APPEND iv_reservation TO mt_released.
  ENDMETHOD.

  METHOD zif_allocation_log~start.
    mv_other = mv_other + 1.
  ENDMETHOD.

  METHOD zif_allocation_log~allocated.
    " a service writes none of these; the run above it does
    mv_other = mv_other + 1.
  ENDMETHOD.

  METHOD zif_allocation_log~failed.
    mv_other = mv_other + 1.
  ENDMETHOD.

  METHOD zif_allocation_log~finished.
    mv_other = mv_other + 1.
  ENDMETHOD.

  METHOD zif_allocation_log~removed.
    mv_other = mv_other + 1.
  ENDMETHOD.

  METHOD zif_allocation_log~save.
    mv_other = mv_other + 1.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_run_id TYPE zstock_alloc_res-run_id VALUE 'SERVICE-TEST-RUN-0001'.
    CONSTANTS c_matnr  TYPE mard-matnr VALUE 'SERVICE-TEST-01'.
    CONSTANTS c_werks  TYPE mard-werks VALUE '1000'.

    CONSTANTS c_reservation TYPE rkpf-rsnum VALUE '0000009001'.
    CONSTANTS c_earlier_run TYPE zstock_alloc_res-run_id VALUE 'SERVICE-TEST-RUN-0000'.
    CONSTANTS c_earlier_res TYPE rkpf-rsnum VALUE '0000008001'.
    CONSTANTS c_demand_id   TYPE zstock_alloc_res-demand_id VALUE 'D1'.

    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_reservation TYPE REF TO lcl_reservation_double.
    DATA mo_lock        TYPE REF TO lcl_lock_double.
    DATA mo_commit      TYPE REF TO lcl_commit_double.
    DATA mo_log         TYPE REF TO lcl_log_spy.

    METHODS teardown.

    METHODS service_with
      IMPORTING
        iv_available      TYPE zif_allocation=>ty_quantity
        it_demand         TYPE zif_allocation=>ty_demand_tab
        iv_refuse         TYPE abap_bool DEFAULT abap_false
        iv_fail_reserve   TYPE abap_bool DEFAULT abap_false
        iv_recut          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_service) TYPE REF TO zif_allocation_service.

    "! A run of the same material recorded earlier, holding IV_RESERVATION.
    METHODS given_earlier_run
      IMPORTING
        iv_reservation TYPE rkpf-rsnum DEFAULT c_earlier_res
      RAISING
        zcx_allocation.

    METHODS run_returns_the_allocation FOR TESTING RAISING cx_static_check.
    METHODS run_is_recorded FOR TESTING RAISING cx_static_check.
    METHODS confirmed_stock_is_reserved FOR TESTING RAISING cx_static_check.
    METHODS reservation_is_linked_to_run FOR TESTING RAISING cx_static_check.
    METHODS default_wiring_is_usable FOR TESTING.
    METHODS unauthorised_plant_refused FOR TESTING.
    METHODS simulation_records_nothing FOR TESTING RAISING cx_static_check.
    METHODS simulation_checks_authority FOR TESTING.
    METHODS lock_is_given_back FOR TESTING RAISING cx_static_check.
    METHODS lock_is_given_back_on_error FOR TESTING.
    METHODS a_run_is_committed FOR TESTING RAISING cx_static_check.
    METHODS the_record_survives_a_refusal FOR TESTING.
    METHODS a_simulation_commits_nothing FOR TESTING RAISING cx_static_check.
    METHODS a_recut_gives_the_stock_back FOR TESTING RAISING cx_static_check.
    METHODS without_recut_nothing_is_given FOR TESTING RAISING cx_static_check.
    METHODS a_recut_commits_the_release FOR TESTING RAISING cx_static_check.
    METHODS an_unreserved_run_is_skipped FOR TESTING RAISING cx_static_check.
    METHODS releasing_nothing_commits_none FOR TESTING RAISING cx_static_check.
    METHODS nothing_waiting_is_not_a_run FOR TESTING RAISING cx_static_check.
    METHODS nothing_waiting_commits_none FOR TESTING RAISING cx_static_check.
    METHODS what_was_given_back_is_noted FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_service IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE run_id = @c_run_id.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM zstock_alloc_res WHERE run_id = @c_earlier_run.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_earlier_run.

    mo_store->save(
      iv_run_id     = c_earlier_run
      iv_matnr      = c_matnr
      iv_werks      = c_werks
      it_allocation = VALUE #(
        ( demand_id = c_demand_id requested = '5' confirmed = '5' shortfall = 0 ) ) ).

    IF iv_reservation IS INITIAL.
      RETURN.
    ENDIF.

    mo_store->record_reservation(
      iv_run_id      = c_earlier_run
      iv_reservation = iv_reservation ).

  ENDMETHOD.

  METHOD service_with.

    mo_store       = NEW zcl_allocation_store( ).
    mo_reservation = NEW #(
      iv_reservation = c_reservation
      iv_fail        = iv_fail_reserve ).
    mo_lock        = NEW #( ).
    mo_commit      = NEW #( ).
    mo_log         = NEW #( ).

    ro_service = NEW zcl_allocation_service(
      io_engine      = NEW zcl_allocation_engine(
        io_supply_reader = NEW zcl_supply_on_hand( NEW lcl_stock_reader_double( iv_available ) )
        io_demand_reader = NEW lcl_demand_reader_double( it_demand )
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_store       = mo_store
      io_run_id      = NEW lcl_run_id_double( c_run_id )
      io_reservation = mo_reservation
      io_authority   = NEW lcl_authority_double( iv_refuse )
      io_lock        = mo_lock
      io_commit      = mo_commit
      iv_recut       = iv_recut
      io_log         = mo_log ).

  ENDMETHOD.

  METHOD run_returns_the_allocation.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' )
        ( demand_id = 'D2' matnr = c_matnr werks = c_werks quantity = '5' priority = '02' ) ) ).

    DATA(ls_run) = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_run-run_id
      exp = c_run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_run-allocation
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' requested = '5' confirmed = '5' shortfall = 0 )
        ( demand_id = 'D2' requested = '5' confirmed = '2' shortfall = '3'
          reason = zif_allocation=>c_reason-no_stock ) ) ).

  ENDMETHOD.

  METHOD run_is_recorded.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' )
        ( demand_id = 'D2' matnr = c_matnr werks = c_werks quantity = '5' priority = '02' ) ) ).

    DATA(ls_run) = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_store->read( ls_run-run_id )
      exp = ls_run-allocation
      msg = 'what the caller is handed must be what was written down' ).

  ENDMETHOD.

  METHOD confirmed_stock_is_reserved.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) ) ).

    DATA(ls_run) = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_run-reservation
      exp = c_reservation ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation->get_last_allocation( )
      exp = ls_run-allocation
      msg = 'what was confirmed must be what gets earmarked' ).

  ENDMETHOD.

  METHOD reservation_is_linked_to_run.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) ) ).

    DATA(ls_run) = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    SELECT SINGLE reservation
      FROM zstock_alloc_res
      WHERE run_id = @ls_run-run_id
        AND demand_id = @c_demand_id
      INTO @DATA(lv_stored).
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_stored
      exp = c_reservation
      msg = 'the recorded run must say which reservation earmarked the stock' ).

  ENDMETHOD.

  METHOD unauthorised_plant_refused.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) )
      iv_refuse    = abap_true ).

    TRY.
        lo_cut->run(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'allocating without authorization must not be possible' ).
      CATCH zcx_allocation.
    ENDTRY.

    cl_abap_unit_assert=>assert_initial(
      act = mo_store->read( c_run_id )
      msg = 'a refused run must not have written anything' ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_reservation->get_last_allocation( )
      msg = 'a refused run must not have reserved anything' ).

  ENDMETHOD.

  METHOD simulation_records_nothing.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) ) ).

    DATA(ls_run) = lo_cut->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_run-allocation[ 1 ]-confirmed
      exp = '5'
      msg = 'a simulation must still work out who would get what' ).
    cl_abap_unit_assert=>assert_initial( ls_run-run_id ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_store->read( c_run_id )
      msg = 'a simulation must not write anything down' ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_reservation->get_last_allocation( )
      msg = 'a simulation must not earmark any stock' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->get_held( )
      exp = 0
      msg = 'a simulation must not block the real run' ).

  ENDMETHOD.

  METHOD simulation_checks_authority.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) )
      iv_refuse    = abap_true ).

    TRY.
        lo_cut->simulate(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'a simulation needs the same authorization' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD lock_is_given_back.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) ) ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->get_held( )
      exp = 0
      msg = 'a finished run must not keep the material to itself' ).

  ENDMETHOD.

  METHOD a_run_is_committed.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) ) ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 2
      msg = 'the decision and the reservation are two units of work, both durable' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_rollbacks( )
      exp = 0 ).

  ENDMETHOD.

  METHOD the_record_survives_a_refusal.

    DATA(lo_cut) = service_with(
      iv_available    = '7'
      it_demand       = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) )
      iv_fail_reserve = abap_true ).

    TRY.
        lo_cut->run(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'a rejected reservation is an error' ).
      CATCH zcx_allocation.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 1
      msg = 'the decision was committed before the reservation was attempted' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_rollbacks( )
      exp = 1
      msg = 'and what the failed half wrote is thrown away' ).

  ENDMETHOD.

  METHOD a_simulation_commits_nothing.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) ) ).

    lo_cut->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 0
      msg = 'a simulation has nothing to commit, and must not commit anything else either' ).

  ENDMETHOD.

  METHOD lock_is_given_back_on_error.

    DATA(lo_cut) = service_with(
      iv_available    = '7'
      it_demand       = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '5' priority = '01' ) )
      iv_fail_reserve = abap_true ).

    TRY.
        lo_cut->run(
          iv_matnr = c_matnr
          iv_werks = c_werks ).
        cl_abap_unit_assert=>fail( 'the rejected reservation should have come through' ).
      CATCH zcx_allocation.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->get_held( )
      exp = 0
      msg = 'a run that failed halfway must still let go of the material' ).

  ENDMETHOD.

  METHOD default_wiring_is_usable.

    cl_abap_unit_assert=>assert_bound(
      act = zcl_allocation_service=>create_default( )
      msg = 'a plain system must get a working service without wiring it itself' ).

    cl_abap_unit_assert=>assert_bound(
      act = zcl_allocation_service=>create_default(
        io_strategy = NEW zcl_alloc_strategy_fairshare( ) )
      msg = 'the strategy must be exchangeable from outside' ).

    cl_abap_unit_assert=>assert_bound(
      act = zcl_allocation_service=>create_default( is_settings = VALUE #( horizon_days = 30 ) )
      msg = 'the horizon must be settable from outside' ).

  ENDMETHOD.

  METHOD a_recut_gives_the_stock_back.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) )
      iv_recut     = abap_true ).

    given_earlier_run( ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_reservation->get_cancelled( )
      exp = VALUE lcl_reservation_double=>ty_reservation_tab( ( c_earlier_res ) )
      msg = 'what an earlier run set aside goes back into the pool first' ).

  ENDMETHOD.

  METHOD without_recut_nothing_is_given.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) ) ).

    given_earlier_run( ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_reservation->get_cancelled( )
      msg = 'an ordinary run adds to what was decided, it does not undo it' ).

  ENDMETHOD.

  METHOD a_recut_commits_the_release.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) )
      iv_recut     = abap_true ).

    given_earlier_run( ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 3
      msg = 'the release is committed before the readers run, then the two of the run' ).

  ENDMETHOD.

  METHOD nothing_waiting_is_not_a_run.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #( ) ).

    DATA(ls_run) = lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_initial(
      act = ls_run-run_id
      msg = 'a run id for a material nothing was waiting for leads to an empty page' ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_run-reservation
      msg = 'and there is nothing to reserve either' ).

  ENDMETHOD.

  METHOD nothing_waiting_commits_none.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #( ) ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 0
      msg = 'most materials of a plant wide run are these, and each is two round trips' ).

  ENDMETHOD.

  METHOD what_was_given_back_is_noted.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) )
      iv_recut     = abap_true ).

    given_earlier_run( ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_log->get_released( )
      exp = VALUE lcl_log_spy=>ty_reservation_tab( ( c_earlier_res ) )
      msg = 'taking stock off a customer is the last thing to do silently' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_log->get_other( )
      exp = 0
      msg = 'and the service writes nothing else: the run above it does that' ).

  ENDMETHOD.

  METHOD releasing_nothing_commits_none.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) )
      iv_recut     = abap_true ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 2
      msg = 'a run that had nothing to give back must not commit for the sake of it' ).

  ENDMETHOD.

  METHOD an_unreserved_run_is_skipped.

    DATA(lo_cut) = service_with(
      iv_available = '7'
      it_demand    = VALUE #(
        ( demand_id = c_demand_id matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) )
      iv_recut     = abap_true ).

    given_earlier_run( '0000000000' ).

    lo_cut->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_reservation->get_cancelled( )
      msg = 'a run whose reservation was rejected holds nothing to give back' ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_default_sources DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'WIRED-STO-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_ebeln TYPE ekko-ebeln VALUE 'STOWIRE001'.

    METHODS setup.
    METHODS teardown.
    METHODS a_transfer_gets_the_stock FOR TESTING RAISING cx_static_check.
    METHODS a_transfer_is_covered FOR TESTING.
    METHODS the_rule_comes_wrapped FOR TESTING.
    METHODS whole_units_only_if_asked FOR TESTING.
    METHODS only_named_location_counts FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_default_sources IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_mard = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks lgort = '0001' labst = '10' ) ).
    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_ekko = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln bsart = 'UB' reswk = c_werks ) ).
    INSERT ekko FROM TABLE @lt_ekko.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_ekpo = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln ebelp = '00010' matnr = c_matnr
        werks = '2000' menge = '4' meins = 'PC' ) ).
    INSERT ekpo FROM TABLE @lt_ekpo.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_eket = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln ebelp = '00010' etenr = '0001'
        eindt = '20260201' menge = '4' wamng = 0 ) ).
    INSERT eket FROM TABLE @lt_eket.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM eket WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekpo WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekko WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mard WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD a_transfer_gets_the_stock.

    " nothing is a sales order here: without the transport order source the
    " whole run would find no demand at all
    DATA(ls_run) = zcl_allocation_service=>create_default( )->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_run-allocation[ demand_id = 'PSTOWIRE001000100001' ]-confirmed
      exp = '4'
      msg = 'a stock transport order must reach the allocation as demand' ).

  ENDMETHOD.

  METHOD only_named_location_counts.

    " the stock sits in 0001, and the run is told to use 0002 only
    DATA(ls_elsewhere) = zcl_allocation_service=>create_default( is_settings = VALUE #( lgort = '0002' ) )->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_elsewhere-allocation[ 1 ]-confirmed
      exp = 0
      msg = 'stock outside the named location may not be given away' ).

    DATA(ls_here) = zcl_allocation_service=>create_default( is_settings = VALUE #( lgort = '0001' ) )->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_here-allocation[ 1 ]-confirmed
      exp = '4'
      msg = 'and the stock in it still is' ).

  ENDMETHOD.

  METHOD the_rule_comes_wrapped.

    " a complete delivery line that cannot be filled is dropped, which only
    " happens if the rule came back wrapped in the complete delivery rule
    DATA(lo_strategy) = zcl_allocation_service=>create_default_strategy( ).

    DATA(lt_result) = lo_strategy->allocate(
      iv_available = '5'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260301' priority = '01'
          complete = abap_true ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = 0
      msg = 'anything that shows what a run would decide must decide it the same way' ).

  ENDMETHOD.

  METHOD whole_units_only_if_asked.

    DATA(lo_plain) = zcl_allocation_service=>create_default_strategy( ).

    DATA(lt_result) = lo_plain->allocate(
      iv_available = '5'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260301' priority = '01'
          unit_size = 4 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '5'
      msg = 'a plant that has not asked for whole units gets what there is' ).

    DATA(lo_whole) = zcl_allocation_service=>create_default_strategy( iv_whole_units = abap_true ).

    lt_result = lo_whole->allocate(
      iv_available = '5'
      it_demand    = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260301' priority = '01'
          unit_size = 4 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '4'
      msg = 'and one that has asked gets whole units' ).

  ENDMETHOD.

  METHOD a_transfer_is_covered.

    DATA(lo_demand) = zcl_allocation_service=>create_default_demand( ).
    DATA(lt_matnr)  = lo_demand->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_matnr ] ) )
      msg = 'a plant wide run must cover a material only a transfer is waiting for' ).

  ENDMETHOD.

ENDCLASS.

"! The newest rules through the wiring CREATE_DEFAULT builds, rather than
"! against the classes that carry them: what is being tested here is that the
"! settings reach the readers at all, which is the mistake features 73, 74, 92
"! and 99 were all versions of.
CLASS ltcl_wired_rules DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'WIRED-RULE-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9001'.
    CONSTANTS c_vbeln TYPE vbak-vbeln VALUE '0000091001'.
    CONSTANTS c_other TYPE vbak-vbeln VALUE '0000091002'.
    CONSTANTS c_ebeln TYPE ekko-ebeln VALUE 'WIREDRULE1'.
    CONSTANTS c_kunnr TYPE vbak-kunnr VALUE 'WIREDCUST1'.
    CONSTANTS c_kunn2 TYPE vbak-kunnr VALUE 'WIREDCUST2'.

    "! Monday the 8th of June 2026, the Saturday before it, and the Friday
    "! before that.
    CONSTANTS c_monday   TYPE d VALUE '20260608'.
    CONSTANTS c_saturday TYPE d VALUE '20260606'.

    CONSTANTS c_demand_1 TYPE zif_allocation=>ty_demand_id VALUE '00000910010000100001'.

    METHODS setup.
    METHODS teardown.

    METHODS given_order
      IMPORTING
        iv_vbeln    TYPE vbak-vbeln
        iv_kunnr    TYPE vbak-kunnr
        iv_quantity TYPE vbap-kwmeng
        iv_priority TYPE vbap-lprio
        iv_edatu    TYPE vbep-edatu DEFAULT c_monday.

    METHODS given_shelf_stock
      IMPORTING
        iv_quantity TYPE mard-labst.

    METHODS given_receipt_on_saturday.

    METHODS given_short_history
      IMPORTING
        iv_days_ago TYPE i.

    METHODS confirmed_for
      IMPORTING
        iv_id              TYPE zif_allocation=>ty_demand_id
        io_service         TYPE REF TO zif_allocation_service
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity
      RAISING
        zcx_allocation.

    METHODS plain_days_take_the_receipt FOR TESTING RAISING cx_static_check.
    METHODS working_days_leave_it FOR TESTING RAISING cx_static_check.
    METHODS a_quota_reaches_the_run FOR TESTING RAISING cx_static_check.
    METHODS waiting_reaches_the_run FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_wired_rules IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara  TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_t001w TYPE STANDARD TABLE OF t001w WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).
    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_t001w = VALUE #(
      ( mandt = sy-mandt werks = c_werks name1 = 'Wired plant' fabkl = '01' ) ).
    INSERT t001w FROM TABLE @lt_t001w.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM mard WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM t001w WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM vbak WHERE vbeln = @c_vbeln OR vbeln = @c_other.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM vbap WHERE vbeln = @c_vbeln OR vbeln = @c_other.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM vbep WHERE vbeln = @c_vbeln OR vbeln = @c_other.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM ekko WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM ekpo WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM eket WHERE ebeln = @c_ebeln.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM zstock_alloc_qta WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
    DELETE FROM zstock_alloc_res WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_order.

    DATA lt_vbak TYPE STANDARD TABLE OF vbak WITH EMPTY KEY.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    DATA lt_vbep TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.

    lt_vbak = VALUE #(
      ( mandt = sy-mandt vbeln = iv_vbeln auart = 'TA' vkorg = '1000'
        kunnr = iv_kunnr vdatu = iv_edatu ) ).
    INSERT vbak FROM TABLE @lt_vbak.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_vbap = VALUE #(
      ( mandt = sy-mandt vbeln = iv_vbeln posnr = '000010'
        matnr = c_matnr werks = c_werks vrkme = 'PC'
        kwmeng = iv_quantity lprio = iv_priority ) ).
    INSERT vbap FROM TABLE @lt_vbap.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_vbep = VALUE #(
      ( mandt = sy-mandt vbeln = iv_vbeln posnr = '000010' etenr = '0001'
        edatu = iv_edatu wmeng = iv_quantity bmeng = 0 ) ).
    INSERT vbep FROM TABLE @lt_vbep.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD given_shelf_stock.

    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.

    lt_mard = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr werks = c_werks
        lgort = '0001' labst = iv_quantity ) ).
    INSERT mard FROM TABLE @lt_mard.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD given_receipt_on_saturday.

    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    lt_ekko = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln bsart = 'NB' ) ).
    INSERT ekko FROM TABLE @lt_ekko.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_ekpo = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln ebelp = '00010' matnr = c_matnr
        werks = c_werks menge = '10' meins = 'PC' ) ).
    INSERT ekpo FROM TABLE @lt_ekpo.
    cl_abap_unit_assert=>assert_subrc( ).

    lt_eket = VALUE #(
      ( mandt = sy-mandt ebeln = c_ebeln ebelp = '00010' etenr = '0001'
        eindt = c_saturday menge = '10' wamng = 0 ) ).
    INSERT eket FROM TABLE @lt_eket.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD given_short_history.

    DATA lt_row  TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_date TYPE d.
    DATA lv_when TYPE zstock_alloc_res-created_at.

    lv_date = sy-datum - iv_days_ago.
    CONVERT DATE lv_date TIME '120000'
      INTO TIME STAMP lv_when TIME ZONE 'UTC'.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = |WIRED-{ iv_days_ago }|
        demand_id  = c_demand_1
        matnr      = c_matnr
        werks      = c_werks
        requested  = 10
        confirmed  = 0
        shortfall  = 10
        customer   = c_kunnr
        created_at = lv_when ) ).

    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD confirmed_for.

    DATA(ls_run) = io_service->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    READ TABLE ls_run-allocation INTO DATA(ls_line)
      WITH KEY demand_id = iv_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_line-confirmed.

  ENDMETHOD.

  METHOD plain_days_take_the_receipt.

    given_order(
      iv_vbeln    = c_vbeln
      iv_kunnr    = c_kunnr
      iv_quantity = 10
      iv_priority = '02' ).
    given_receipt_on_saturday( ).

    " goods wanted on the Monday, one day to get them out of the door: on
    " plain days that is the Sunday, and a receipt landing on the Saturday is
    " in time for it
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        iv_id      = c_demand_1
        io_service = zcl_allocation_service=>create_default( is_settings = VALUE #( ship_days = 1 ) ) )
      exp = CONV zif_allocation=>ty_quantity( 10 ) ).

  ENDMETHOD.

  METHOD working_days_leave_it.

    given_order(
      iv_vbeln    = c_vbeln
      iv_kunnr    = c_kunnr
      iv_quantity = 10
      iv_priority = '02' ).
    given_receipt_on_saturday( ).

    " the same question of a plant that does not work at the weekend: it has
    " to start on the Friday, and stock landing on the Saturday is too late
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        iv_id      = c_demand_1
        io_service = zcl_allocation_service=>create_default( is_settings = VALUE #(
          ship_days = 1
          work_days = abap_true ) ) )
      exp = CONV zif_allocation=>ty_quantity( 0 )
      msg = 'the working day calendar has to reach the demand reader of a real run' ).

  ENDMETHOD.

  METHOD a_quota_reaches_the_run.

    DATA lt_quota TYPE STANDARD TABLE OF zstock_alloc_qta WITH EMPTY KEY.

    given_order(
      iv_vbeln    = c_vbeln
      iv_kunnr    = c_kunnr
      iv_quantity = 10
      iv_priority = '02' ).
    given_shelf_stock( 100 ).

    lt_quota = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = c_matnr
        kunnr     = c_kunnr
        date_from = '20260101'
        date_to   = '20261231'
        quantity  = 4 ) ).
    INSERT zstock_alloc_qta FROM TABLE @lt_quota.
    cl_abap_unit_assert=>assert_subrc( ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        iv_id      = c_demand_1
        io_service = zcl_allocation_service=>create_default( ) )
      exp = CONV zif_allocation=>ty_quantity( 10 )
      msg = 'a plant that has not asked for quotas is not held to them' ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        iv_id      = c_demand_1
        io_service = zcl_allocation_service=>create_default( is_settings = VALUE #( quota = abap_true ) ) )
      exp = CONV zif_allocation=>ty_quantity( 4 )
      msg = 'and one that has, is' ).

  ENDMETHOD.

  METHOD waiting_reaches_the_run.

    " two customers and five pieces: the one at the back of the queue has been
    " short in every run for ten weeks, which is ten places
    given_order(
      iv_vbeln    = c_vbeln
      iv_kunnr    = c_kunnr
      iv_quantity = 5
      iv_priority = '09' ).
    given_order(
      iv_vbeln    = c_other
      iv_kunnr    = c_kunn2
      iv_quantity = 5
      iv_priority = '02' ).
    given_shelf_stock( 5 ).
    given_short_history( 70 ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        iv_id      = c_demand_1
        io_service = zcl_allocation_service=>create_default( ) )
      exp = CONV zif_allocation=>ty_quantity( 0 )
      msg = 'without the escalation the same customer loses again' ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        iv_id      = c_demand_1
        io_service = zcl_allocation_service=>create_default( is_settings = VALUE #( age_days = 7 ) ) )
      exp = CONV zif_allocation=>ty_quantity( 5 )
      msg = 'with it, ten weeks of waiting is worth more than seven places of priority' ).

  ENDMETHOD.

ENDCLASS.
