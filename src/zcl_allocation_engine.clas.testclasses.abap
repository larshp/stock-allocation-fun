CLASS lcl_supply_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab.

    METHODS get_last_matnr
      RETURNING
        VALUE(rv_matnr) TYPE mard-matnr.

    METHODS get_last_werks
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mt_supply     TYPE zif_supply_reader=>ty_supply_tab.
    DATA mv_last_matnr TYPE mard-matnr.
    DATA mv_last_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_supply_reader_double IMPLEMENTATION.

  METHOD constructor.
    mt_supply = it_supply.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    mv_last_matnr = iv_matnr.
    mv_last_werks = iv_werks.
    rt_supply = mt_supply.
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

    DATA mo_supply TYPE REF TO lcl_supply_reader_double.
    DATA mo_demand TYPE REF TO lcl_demand_reader_double.
    DATA mo_cut    TYPE REF TO zcl_allocation_engine.

    METHODS given
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab
        it_demand TYPE zif_allocation=>ty_demand_tab.

    METHODS on_hand
      IMPORTING
        iv_quantity      TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab.

    METHODS confirmed_for
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS what_is_there_is_one_pool FOR TESTING RAISING cx_static_check.
    METHODS passes_selection_to_reader FOR TESTING RAISING cx_static_check.
    METHODS no_stock_confirms_nothing FOR TESTING RAISING cx_static_check.
    METHODS open_demand_comes_from_reader FOR TESTING RAISING cx_static_check.
    METHODS explicit_demand_skips_reader FOR TESTING RAISING cx_static_check.
    METHODS receipt_serves_later_demand FOR TESTING RAISING cx_static_check.
    METHODS receipt_is_too_late_for_today FOR TESTING RAISING cx_static_check.
    METHODS a_line_is_served_over_days FOR TESTING RAISING cx_static_check.
    METHODS undated_line_waits_for_nothing FOR TESTING RAISING cx_static_check.
    METHODS every_line_answered_once FOR TESTING RAISING cx_static_check.
    METHODS receipt_left_over_serves_later FOR TESTING RAISING cx_static_check.
    METHODS stock_is_available_at_once FOR TESTING RAISING cx_static_check.
    METHODS receipt_dates_the_line FOR TESTING RAISING cx_static_check.
    METHODS the_last_day_dates_the_line FOR TESTING RAISING cx_static_check.
    METHODS nothing_confirmed_has_no_date FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_engine IMPLEMENTATION.

  METHOD given.

    mo_supply = NEW #( it_supply ).
    mo_demand = NEW #( it_demand ).
    mo_cut    = NEW #(
      io_supply_reader = mo_supply
      io_demand_reader = mo_demand
      io_strategy      = NEW zcl_alloc_strategy_priority( ) ).

  ENDMETHOD.

  METHOD on_hand.
    rt_supply = VALUE #( ( quantity = iv_quantity ) ).
  ENDMETHOD.

  METHOD confirmed_for.

    LOOP AT it_allocation INTO DATA(ls_allocation)
        WHERE demand_id = iv_demand_id.
      rv_quantity = rv_quantity + ls_allocation-confirmed.
    ENDLOOP.

  ENDMETHOD.

  METHOD what_is_there_is_one_pool.

    given(
      it_supply = VALUE #(
        ( quantity = '4' )
        ( quantity = '6' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks quantity = '10' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '10'
      msg = 'supply available on the same day must be pooled' ).

  ENDMETHOD.

  METHOD passes_selection_to_reader.

    given(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    mo_cut->allocate(
      iv_matnr  = 'MAT-2'
      iv_werks  = '2000'
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_supply->get_last_matnr( )
      exp = 'MAT-2' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_supply->get_last_werks( )
      exp = '2000' ).

  ENDMETHOD.

  METHOD no_stock_confirms_nothing.

    given(
      it_supply = VALUE #( )
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
      it_supply = on_hand( '8' )
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
      it_supply = on_hand( '8' )
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

  METHOD receipt_serves_later_demand.

    given(
      it_supply = VALUE #(
        ( avail_date = '20260301' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260315' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '10'
      msg = 'a line wanted after the receipt arrives can be served from it' ).

  ENDMETHOD.

  METHOD receipt_is_too_late_for_today.

    given(
      it_supply = VALUE #(
        ( avail_date = '20260301' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260201' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = 0
      msg = 'stock that arrives after the day it is wanted cannot be promised' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall
      exp = '10' ).

  ENDMETHOD.

  METHOD a_line_is_served_over_days.

    given(
      it_supply = VALUE #(
        ( quantity = '4' )
        ( avail_date = '20260301' quantity = '6' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260315' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 1
      msg = 'a line served from two days is still answered once' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '10'
      msg = 'what is on the shelf and what arrives before the date both count' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-requested
      exp = '10'
      msg = 'the answer says what was asked for, not what was left of it' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall
      exp = 0 ).

  ENDMETHOD.

  METHOD undated_line_waits_for_nothing.

    given(
      it_supply = VALUE #(
        ( avail_date = '20260301' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = 0
      msg = 'a requirement without a date is wanted now, not whenever stock turns up' ).

  ENDMETHOD.

  METHOD every_line_answered_once.

    given(
      it_supply = VALUE #(
        ( quantity = '5' )
        ( avail_date = '20260301' quantity = '5' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '8' req_date = '20260315' priority = '01' )
        ( demand_id = 'D2' matnr = c_matnr werks = c_werks
          quantity = '8' req_date = '20260315' priority = '02' )
        ( demand_id = 'D3' matnr = c_matnr werks = c_werks
          quantity = '8' req_date = '20260101' priority = '03' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        it_allocation = lt_result
        iv_demand_id  = 'D1' )
      exp = '8'
      msg = 'the most urgent line is served first, from both days' ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        it_allocation = lt_result
        iv_demand_id  = 'D2' )
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        it_allocation = lt_result
        iv_demand_id  = 'D3' )
      exp = 0
      msg = 'the overdue line could only have had the stock on the shelf' ).

  ENDMETHOD.

  METHOD receipt_left_over_serves_later.

    given(
      it_supply = VALUE #(
        ( avail_date = '20260301' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260305' priority = '01' )
        ( demand_id = 'D2' matnr = c_matnr werks = c_werks
          quantity = '4' req_date = '20260401' priority = '02' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        it_allocation = lt_result
        iv_demand_id  = 'D1' )
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_for(
        it_allocation = lt_result
        iv_demand_id  = 'D2' )
      exp = '4'
      msg = 'one receipt covers everything wanted after it arrives' ).

  ENDMETHOD.

  METHOD stock_is_available_at_once.

    given(
      it_supply = on_hand( '10' )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260315' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_result[ 1 ]-avail_date
      msg = 'a line served off the shelf is there already, it waits for nothing' ).

  ENDMETHOD.

  METHOD receipt_dates_the_line.

    given(
      it_supply = VALUE #(
        ( avail_date = '20260301' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260315' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-avail_date
      exp = '20260301'
      msg = 'a line confirmed from a receipt is only there once the receipt is' ).

  ENDMETHOD.

  METHOD the_last_day_dates_the_line.

    given(
      it_supply = VALUE #(
        ( quantity = '4' )
        ( avail_date = '20260301' quantity = '3' )
        ( avail_date = '20260310' quantity = '3' ) )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260315' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-avail_date
      exp = '20260310'
      msg = 'the line is only complete when the last of its supply has arrived' ).

  ENDMETHOD.

  METHOD nothing_confirmed_has_no_date.

    given(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    DATA(lt_result) = mo_cut->allocate(
      iv_matnr  = c_matnr
      iv_werks  = c_werks
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260315' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_initial( lt_result[ 1 ]-avail_date ).

  ENDMETHOD.

ENDCLASS.
