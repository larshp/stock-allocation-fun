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


CLASS ltcl_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_run_id TYPE zstock_alloc_res-run_id VALUE 'SERVICE-TEST-RUN-0001'.
    CONSTANTS c_matnr  TYPE mard-matnr VALUE 'SERVICE-TEST-01'.
    CONSTANTS c_werks  TYPE mard-werks VALUE '1000'.

    DATA mo_store TYPE REF TO zif_allocation_store.

    METHODS teardown.

    METHODS service_with
      IMPORTING
        iv_available      TYPE zif_allocation=>ty_quantity
        it_demand         TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_allocation_service.

    METHODS run_returns_the_allocation FOR TESTING RAISING cx_static_check.
    METHODS run_is_recorded FOR TESTING RAISING cx_static_check.
    METHODS default_wiring_is_usable FOR TESTING.

ENDCLASS.


CLASS ltcl_service IMPLEMENTATION.

  METHOD teardown.
    DELETE FROM zstock_alloc_res WHERE run_id = @c_run_id.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
  ENDMETHOD.

  METHOD service_with.

    mo_store = NEW zcl_allocation_store( ).

    ro_service = NEW #(
      io_engine = NEW zcl_allocation_engine(
        io_stock_reader  = NEW lcl_stock_reader_double( iv_available )
        io_demand_reader = NEW lcl_demand_reader_double( it_demand )
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_store  = mo_store
      io_run_id = NEW lcl_run_id_double( c_run_id ) ).

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

  METHOD default_wiring_is_usable.

    cl_abap_unit_assert=>assert_bound(
      act = zcl_allocation_service=>create_default( )
      msg = 'a plain system must get a working service without wiring it itself' ).

    cl_abap_unit_assert=>assert_bound(
      act = zcl_allocation_service=>create_default( NEW zcl_alloc_strategy_fairshare( ) )
      msg = 'the strategy must be exchangeable from outside' ).

  ENDMETHOD.

ENDCLASS.
