"! Answers with a fixed timeline.
CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab.

  PRIVATE SECTION.
    DATA mt_supply TYPE zif_supply_reader=>ty_supply_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_supply = it_supply.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    rt_supply = mt_supply.
  ENDMETHOD.

ENDCLASS.


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
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


"! Allows every plant, and remembers which one it was asked about.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS get_plant
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mv_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD get_plant.
    rv_werks = mv_werks.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.
    mv_werks = iv_werks.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_projection DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PROJECT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_today TYPE d VALUE '20260302'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_req_date      TYPE d
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS projected
      IMPORTING
        it_supply        TYPE zif_supply_reader=>ty_supply_tab
        it_demand        TYPE zif_allocation=>ty_demand_tab
        iv_buckets       TYPE i DEFAULT 2
      RETURNING
        VALUE(rt_bucket) TYPE zcl_alloc_projection=>ty_bucket_tab
      RAISING
        zcx_allocation.

    METHODS the_periods_are_a_week FOR TESTING RAISING cx_static_check.
    METHODS stock_on_hand_is_there_now FOR TESTING RAISING cx_static_check.
    METHODS a_receipt_lands_in_its_week FOR TESTING RAISING cx_static_check.
    METHODS demand_lands_in_its_week FOR TESTING RAISING cx_static_check.
    METHODS an_overdue_line_is_wanted_now FOR TESTING RAISING cx_static_check.
    METHODS the_balance_is_carried_over FOR TESTING RAISING cx_static_check.
    METHODS the_rest_lands_in_the_last FOR TESTING RAISING cx_static_check.
    METHODS running_out_is_said_in_words FOR TESTING RAISING cx_static_check.
    METHODS enough_is_said_too FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_projection IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = iv_req_date
      priority  = '01' ).

  ENDMETHOD.

  METHOD projected.

    DATA(lo_cut) = NEW zcl_alloc_projection(
      io_supply    = NEW lcl_supply_double( it_supply )
      io_demand    = NEW lcl_demand_double( it_demand )
      io_authority = mo_authority
      iv_today     = c_today ).

    rt_bucket = lo_cut->periods(
      iv_matnr   = c_matnr
      iv_werks   = c_werks
      iv_buckets = iv_buckets ).

  ENDMETHOD.

  METHOD the_periods_are_a_week.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_bucket )
      exp = 3
      msg = 'two weeks asked for, and one more for everything after them' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 1 ]-from
      exp = c_today ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 1 ]-to
      exp = '20260308'
      msg = 'a week is seven days counting today' ).

  ENDMETHOD.

  METHOD stock_on_hand_is_there_now.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 1 ]-supply
      exp = '10'
      msg = 'stock on the shelf carries no date and is there in the first period' ).

  ENDMETHOD.

  METHOD a_receipt_lands_in_its_week.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( ( avail_date = '20260310' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 1 ]-supply
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 2 ]-supply
      exp = '10'
      msg = 'the tenth is in the second week, not the first' ).

  ENDMETHOD.

  METHOD demand_lands_in_its_week.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( )
      it_demand = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '4'
                  iv_req_date = '20260310' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 2 ]-demand
      exp = '4' ).

  ENDMETHOD.

  METHOD an_overdue_line_is_wanted_now.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( )
      it_demand = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '4'
                  iv_req_date = '20260101' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 1 ]-demand
      exp = '4'
      msg = 'a line that was wanted in January is wanted now, not never' ).

  ENDMETHOD.

  METHOD the_balance_is_carried_over.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( ( avail_date = '00000000' quantity = '10' ) )
      it_demand = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '4'
                  iv_req_date = '20260310' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 1 ]-balance
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 2 ]-balance
      exp = '6'
      msg = 'what is left at the end of a week is what the next one starts with' ).

  ENDMETHOD.

  METHOD the_rest_lands_in_the_last.

    DATA(lt_bucket) = projected(
      it_supply = VALUE #( ( avail_date = '20270101' quantity = '10' ) )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_bucket[ 3 ]-supply
      exp = '10'
      msg = 'the columns must add up to what the material has, not to what fitted' ).

  ENDMETHOD.

  METHOD running_out_is_said_in_words.

    DATA(lo_cut) = NEW zcl_alloc_projection(
      io_supply    = NEW lcl_supply_double( VALUE #(
        ( avail_date = '00000000' quantity = '3' ) ) )
      io_demand    = NEW lcl_demand_double( VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_req_date = '20260310' ) ) ) )
      io_authority = mo_authority
      iv_today     = c_today ).

    DATA(lt_line) = lo_cut->run(
      iv_matnr   = c_matnr
      iv_werks   = c_werks
      iv_buckets = 2 ).

    DATA lv_said TYPE abap_bool.

    LOOP AT lt_line INTO DATA(lv_line).
      IF lv_line CS `short from 2026-03-09`.
        lv_said = abap_true.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_true(
      act = lv_said
      msg = 'the week it runs out is what somebody came to the report for' ).

  ENDMETHOD.

  METHOD enough_is_said_too.

    DATA(lo_cut) = NEW zcl_alloc_projection(
      io_supply    = NEW lcl_supply_double( VALUE #(
        ( avail_date = '00000000' quantity = '30' ) ) )
      io_demand    = NEW lcl_demand_double( VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_req_date = '20260310' ) ) ) )
      io_authority = mo_authority
      iv_today     = c_today ).

    DATA(lt_line) = lo_cut->run(
      iv_matnr   = c_matnr
      iv_werks   = c_werks
      iv_buckets = 2 ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = 'Enough for every period shown'
      msg = 'a projection that ends well should say so rather than trail off' ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    projected(
      it_supply = VALUE #( )
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks ).

  ENDMETHOD.

ENDCLASS.
