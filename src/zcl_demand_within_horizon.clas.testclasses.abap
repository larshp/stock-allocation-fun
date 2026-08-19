CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab
        it_matnr  TYPE zif_demand_reader=>ty_matnr_tab OPTIONAL.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.
    DATA mt_matnr  TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
    mt_matnr  = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_within_horizon DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'HORIZON-TEST-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS within
      IMPORTING
        iv_days          TYPE i
        it_demand        TYPE zif_allocation=>ty_demand_tab
      RETURNING
        VALUE(rt_demand) TYPE zif_allocation=>ty_demand_tab
      RAISING
        cx_static_check.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_in_days       TYPE i
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS no_horizon_keeps_everything FOR TESTING RAISING cx_static_check.
    METHODS demand_inside_is_kept FOR TESTING RAISING cx_static_check.
    METHODS demand_on_the_day_is_kept FOR TESTING RAISING cx_static_check.
    METHODS demand_beyond_is_dropped FOR TESTING RAISING cx_static_check.
    METHODS demand_in_the_past_is_kept FOR TESTING RAISING cx_static_check.
    METHODS demand_without_a_date_is_kept FOR TESTING RAISING cx_static_check.
    METHODS materials_are_passed_through FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_within_horizon IMPLEMENTATION.

  METHOD demand.

    DATA lv_date TYPE d.

    lv_date = sy-datum + iv_in_days.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = '10'
      req_date  = lv_date
      priority  = '01' ).

  ENDMETHOD.

  METHOD within.

    DATA lo_inner TYPE REF TO zif_demand_reader.

    lo_inner = NEW lcl_demand_double( it_demand = it_demand ).

    rt_demand = NEW zcl_demand_within_horizon(
      io_demand = lo_inner
      iv_days   = iv_days )->zif_demand_reader~read_open_demand(
        iv_matnr = c_matnr
        iv_werks = c_werks ).

  ENDMETHOD.

  METHOD no_horizon_keeps_everything.

    cl_abap_unit_assert=>assert_equals(
      act = lines( within(
        iv_days   = 0
        it_demand = VALUE #(
          ( demand( iv_id = 'SOON' iv_in_days = 1 ) )
          ( demand( iv_id = 'FAR'  iv_in_days = 999 ) ) ) ) )
      exp = 2 ).

  ENDMETHOD.

  METHOD demand_inside_is_kept.

    DATA(lt_demand) = within(
      iv_days   = 30
      it_demand = VALUE #( ( demand( iv_id = 'SOON' iv_in_days = 10 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1 ).

  ENDMETHOD.

  METHOD demand_on_the_day_is_kept.

    DATA(lt_demand) = within(
      iv_days   = 30
      it_demand = VALUE #( ( demand( iv_id = 'EDGE' iv_in_days = 30 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1
      msg = 'the last day of the horizon is inside it' ).

  ENDMETHOD.

  METHOD demand_beyond_is_dropped.

    DATA(lt_demand) = within(
      iv_days   = 30
      it_demand = VALUE #(
        ( demand( iv_id = 'SOON' iv_in_days = 10 ) )
        ( demand( iv_id = 'FAR'  iv_in_days = 31 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-demand_id
      exp = 'SOON'
      msg = 'stock must not be committed to an order beyond the horizon' ).

  ENDMETHOD.

  METHOD demand_in_the_past_is_kept.

    DATA(lt_demand) = within(
      iv_days   = 30
      it_demand = VALUE #( ( demand( iv_id = 'LATE' iv_in_days = -10 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1
      msg = 'an overdue requirement is the most urgent one there is' ).

  ENDMETHOD.

  METHOD demand_without_a_date_is_kept.

    DATA(lt_demand) = within(
      iv_days   = 30
      it_demand = VALUE #(
        ( demand_id = 'ASAP' matnr = c_matnr werks = c_werks
          quantity = '10' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1
      msg = 'a requirement without a date is wanted now, not never' ).

  ENDMETHOD.

  METHOD materials_are_passed_through.

    DATA lo_inner TYPE REF TO zif_demand_reader.

    lo_inner = NEW lcl_demand_double(
      it_demand = VALUE #( )
      it_matnr  = VALUE #( ( 'MAT-1' ) ) ).

    DATA(lo_cut) = NEW zcl_demand_within_horizon(
      io_demand = lo_inner
      iv_days   = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_cut->zif_demand_reader~materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( 'MAT-1' ) ) ).

  ENDMETHOD.

ENDCLASS.
