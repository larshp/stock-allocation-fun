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

  PRIVATE SECTION.
    DATA mv_reservation TYPE rkpf-rsnum.
    DATA mv_fail        TYPE abap_bool.
    DATA mt_last        TYPE zif_allocation=>ty_allocation_tab.

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


CLASS ltcl_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_run_id TYPE zstock_alloc_res-run_id VALUE 'SERVICE-TEST-RUN-0001'.
    CONSTANTS c_matnr  TYPE mard-matnr VALUE 'SERVICE-TEST-01'.
    CONSTANTS c_werks  TYPE mard-werks VALUE '1000'.

    CONSTANTS c_reservation TYPE rkpf-rsnum VALUE '0000009001'.
    CONSTANTS c_demand_id   TYPE zstock_alloc_res-demand_id VALUE 'D1'.

    DATA mo_store       TYPE REF TO zif_allocation_store.
    DATA mo_reservation TYPE REF TO lcl_reservation_double.
    DATA mo_lock        TYPE REF TO lcl_lock_double.

    METHODS teardown.

    METHODS service_with
      IMPORTING
        iv_available      TYPE zif_allocation=>ty_quantity
        it_demand         TYPE zif_allocation=>ty_demand_tab
        iv_refuse         TYPE abap_bool DEFAULT abap_false
        iv_fail_reserve   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_service) TYPE REF TO zif_allocation_service.

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

ENDCLASS.


CLASS ltcl_service IMPLEMENTATION.

  METHOD teardown.
    DELETE FROM zstock_alloc_res WHERE run_id = @c_run_id.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
  ENDMETHOD.

  METHOD service_with.

    mo_store       = NEW zcl_allocation_store( ).
    mo_reservation = NEW #(
      iv_reservation = c_reservation
      iv_fail        = iv_fail_reserve ).
    mo_lock        = NEW #( ).

    ro_service = NEW zcl_allocation_service(
      io_engine      = NEW zcl_allocation_engine(
        io_supply_reader = NEW zcl_supply_on_hand( NEW lcl_stock_reader_double( iv_available ) )
        io_demand_reader = NEW lcl_demand_reader_double( it_demand )
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_store       = mo_store
      io_run_id      = NEW lcl_run_id_double( c_run_id )
      io_reservation = mo_reservation
      io_authority   = NEW lcl_authority_double( iv_refuse )
      io_lock        = mo_lock ).

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
        ( demand_id = 'D2' requested = '5' confirmed = '2' shortfall = '3' ) ) ).

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
      act = zcl_allocation_service=>create_default( iv_horizon_days = 30 )
      msg = 'the horizon must be settable from outside' ).

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
    DATA(ls_elsewhere) = zcl_allocation_service=>create_default( iv_lgort = '0002' )->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_elsewhere-allocation[ 1 ]-confirmed
      exp = 0
      msg = 'stock outside the named location may not be given away' ).

    DATA(ls_here) = zcl_allocation_service=>create_default( iv_lgort = '0001' )->simulate(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_here-allocation[ 1 ]-confirmed
      exp = '4'
      msg = 'and the stock in it still is' ).

  ENDMETHOD.

  METHOD a_transfer_is_covered.

    DATA(lo_demand) = zcl_allocation_service=>create_default_demand( ).
    DATA(lt_matnr)  = lo_demand->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_matnr ] ) )
      msg = 'a plant wide run must cover a material only a transfer is waiting for' ).

  ENDMETHOD.

ENDCLASS.
