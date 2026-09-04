"! Answers with a fixed demand.
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
    rt_matnr = VALUE #( ( 'SHIP-MAT-01' ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_ship_time DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'SHIP-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS demand
      IMPORTING
        iv_req_date      TYPE d
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab.

    METHODS read
      IMPORTING
        it_demand        TYPE zif_allocation=>ty_demand_tab
        iv_days          TYPE i
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab
      RAISING
        zcx_allocation.

    METHODS the_stock_is_wanted_earlier FOR TESTING RAISING cx_static_check.
    METHODS no_time_changes_nothing FOR TESTING RAISING cx_static_check.
    METHODS a_negative_time_is_none FOR TESTING RAISING cx_static_check.
    METHODS an_undated_line_is_left FOR TESTING RAISING cx_static_check.
    METHODS the_wanted_date_is_kept FOR TESTING RAISING cx_static_check.
    METHODS the_material_list_is_passed_on FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_ship_time IMPLEMENTATION.

  METHOD demand.

    rt_demand = VALUE #(
      ( demand_id = 'D1'
        matnr     = c_matnr
        werks     = c_werks
        quantity  = '10'
        req_date  = iv_req_date
        priority  = '01' ) ).

  ENDMETHOD.

  METHOD read.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_ship_time(
      io_demand = NEW lcl_demand_double( it_demand )
      iv_days   = iv_days ) ).

    rt_demand = lo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD the_stock_is_wanted_earlier.

    DATA(lt_demand) = read(
      it_demand = demand( '20260310' )
      iv_days   = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-ready_by
      exp = '20260308'
      msg = 'a receipt landing on the ninth cannot be on a trailer on the eighth' ).

  ENDMETHOD.

  METHOD no_time_changes_nothing.

    DATA(lt_demand) = read(
      it_demand = demand( '20260310' )
      iv_days   = 0 ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_demand[ 1 ]-ready_by
      msg = 'a plant that ships the day it picks wants the stock on the day' ).

  ENDMETHOD.

  METHOD a_negative_time_is_none.

    DATA(lt_demand) = read(
      it_demand = demand( '20260310' )
      iv_days   = -3 ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_demand[ 1 ]-ready_by
      msg = 'goods leaving before they are picked is not a setting to obey' ).

  ENDMETHOD.

  METHOD an_undated_line_is_left.

    DATA(lt_demand) = read(
      it_demand = demand( '00000000' )
      iv_days   = 2 ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_demand[ 1 ]-ready_by
      msg = 'a line wanted now cannot be wanted two days before now' ).

  ENDMETHOD.

  METHOD the_wanted_date_is_kept.

    DATA(lt_demand) = read(
      it_demand = demand( '20260310' )
      iv_days   = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-req_date
      exp = '20260310'
      msg = 'the customer still wants them on the tenth, and the answer says so' ).

  ENDMETHOD.

  METHOD the_material_list_is_passed_on.

    DATA(lo_cut) = CAST zif_demand_reader( NEW zcl_demand_ship_time(
      io_demand = NEW lcl_demand_double( VALUE #( ) )
      iv_days   = 2 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_matnr ) )
      msg = 'how long shipping takes does not change which materials are waiting' ).

  ENDMETHOD.

ENDCLASS.
