CLASS lcl_stock_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS constructor
      IMPORTING
        it_stock TYPE zif_stock_reader=>ty_stock_line_tab.

    METHODS get_last_matnr
      RETURNING
        VALUE(rv_matnr) TYPE mard-matnr.

    METHODS get_last_werks
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mt_stock      TYPE zif_stock_reader=>ty_stock_line_tab.
    DATA mv_last_matnr TYPE mard-matnr.
    DATA mv_last_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_stock_reader_double IMPLEMENTATION.

  METHOD constructor.
    mt_stock = it_stock.
  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.
    mv_last_matnr = iv_matnr.
    mv_last_werks = iv_werks.
    rt_stock = mt_stock.
  ENDMETHOD.

  METHOD get_last_matnr.
    rv_matnr = mv_last_matnr.
  ENDMETHOD.

  METHOD get_last_werks.
    rv_werks = mv_last_werks.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_demand_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

    METHODS get_call_count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_demand   TYPE zif_allocation=>ty_demand_tab.
    DATA mv_call_cnt TYPE i.

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
    mv_call_cnt = mv_call_cnt + 1.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD get_call_count.
    rv_count = mv_call_cnt.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_engine DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'MAT-1'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_stock  TYPE REF TO lcl_stock_reader_double.
    DATA mo_demand TYPE REF TO lcl_demand_reader_double.
    DATA mo_cut    TYPE REF TO zcl_allocation_engine.

    METHODS given
      IMPORTING
        it_stock  TYPE zif_stock_reader=>ty_stock_line_tab
        it_demand TYPE zif_allocation=>ty_demand_tab.

    METHODS pools_stock_of_all_lgort FOR TESTING.
    METHODS passes_selection_to_reader FOR TESTING.
    METHODS no_stock_confirms_nothing FOR TESTING.
    METHODS open_demand_comes_from_reader FOR TESTING.
    METHODS explicit_demand_skips_reader FOR TESTING.

ENDCLASS.


CLASS ltcl_engine IMPLEMENTATION.

  METHOD given.

    mo_stock  = NEW #( it_stock ).
    mo_demand = NEW #( it_demand ).
    mo_cut    = NEW #(
      io_stock_reader  = mo_stock
      io_demand_reader = mo_demand
      io_strategy      = NEW zcl_alloc_strategy_priority( ) ).

  ENDMETHOD.

  METHOD pools_stock_of_all_lgort.

    given(
      it_stock  = VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '4' )
        ( matnr = c_matnr werks = c_werks lgort = '0002' available = '6' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '10' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '10'
      msg = 'stock of both storage locations must be pooled' ).

  ENDMETHOD.

  METHOD passes_selection_to_reader.

    given(
      it_stock  = VALUE #( )
      it_demand = VALUE #( ) ).

    mo_cut->allocate(
      iv_matnr  = 'MAT-2'
      iv_werks  = '2000'
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_stock->get_last_matnr( )
      exp = 'MAT-2' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_stock->get_last_werks( )
      exp = '2000' ).

  ENDMETHOD.

  METHOD no_stock_confirms_nothing.

    given(
      it_stock  = VALUE #( )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '3' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall
      exp = '3' ).

  ENDMETHOD.

  METHOD open_demand_comes_from_reader.

    given(
      it_stock  = VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '8' ) )
      it_demand = VALUE #(
        ( demand_id = 'FROM-READER' matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) ) ).

    DATA(lt_result) = mo_cut->allocate_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-demand_id
      exp = 'FROM-READER' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_demand->get_call_count( )
      exp = 1 ).

  ENDMETHOD.

  METHOD explicit_demand_skips_reader.

    given(
      it_stock  = VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '8' ) )
      it_demand = VALUE #(
        ( demand_id = 'FROM-READER' matnr = c_matnr werks = c_werks
          quantity = '5' priority = '01' ) ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'SIMULATED' matnr = c_matnr werks = c_werks
          quantity = '2' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-demand_id
      exp = 'SIMULATED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_demand->get_call_count( )
      exp = 0
      msg = 'a simulation must not go looking for the real demand' ).

  ENDMETHOD.

ENDCLASS.
