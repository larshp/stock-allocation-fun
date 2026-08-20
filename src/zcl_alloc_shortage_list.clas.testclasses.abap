"! Answers with a fixed set of recorded lines.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mv_written  TYPE abap_bool.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " a worklist only reads
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    CLEAR rt_allocation.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mv_written.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mv_written.
  ENDMETHOD.

ENDCLASS.


"! Allows every plant.
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


CLASS ltcl_shortage_list DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS recorded
      IMPORTING
        iv_matnr           TYPE mard-matnr
        iv_demand_id       TYPE zif_allocation=>ty_demand_id
        iv_short           TYPE zif_allocation=>ty_quantity
        iv_req_date        TYPE d DEFAULT '20260301'
        iv_reason          TYPE zif_allocation=>ty_reason DEFAULT 'S'
        iv_customer        TYPE vbak-kunnr DEFAULT '0000040001'
      RETURNING
        VALUE(rs_recorded) TYPE zif_allocation_store=>ty_recorded.

    METHODS list_of
      IMPORTING
        it_recorded    TYPE zif_allocation_store=>ty_recorded_tab
        iv_until       TYPE d OPTIONAL
        iv_top         TYPE i DEFAULT 0
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_shortage_list=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS nothing_short_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_full_line_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS the_soonest_comes_first FOR TESTING RAISING cx_static_check.
    METHODS the_biggest_hole_first FOR TESTING RAISING cx_static_check.
    METHODS a_date_cuts_the_list FOR TESTING RAISING cx_static_check.
    METHODS the_top_is_a_top FOR TESTING RAISING cx_static_check.
    METHODS what_is_cut_off_is_counted FOR TESTING RAISING cx_static_check.
    METHODS the_reason_is_in_the_line FOR TESTING RAISING cx_static_check.
    METHODS the_customer_is_shown FOR TESTING RAISING cx_static_check.
    METHODS one_customer_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_shortage_list IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD recorded.

    rs_recorded = VALUE #(
      matnr     = iv_matnr
      run_id    = 'RUN-0001'
      demand_id = iv_demand_id
      req_date  = iv_req_date
      requested = iv_short
      confirmed = 0
      shortfall = iv_short
      reason    = iv_reason
      customer  = iv_customer ).

  ENDMETHOD.

  METHOD list_of.

    DATA(lo_cut) = NEW zcl_alloc_shortage_list(
      io_store     = NEW lcl_store_double( it_recorded )
      io_authority = mo_authority ).

    rt_line = lo_cut->run(
      iv_werks = c_werks
      iv_until = iv_until
      iv_top   = iv_top
      iv_kunnr = iv_kunnr ).

  ENDMETHOD.

  METHOD nothing_short_says_so.

    DATA(lt_line) = list_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nothing is short*'
      msg = 'a morning with nothing to do should say so in one line' ).

  ENDMETHOD.

  METHOD a_full_line_is_left_out.

    DATA(lt_line) = list_of( VALUE #(
      ( matnr = 'MAT-1' demand_id = 'D1' req_date = '20260301'
        requested = '10' confirmed = '10' shortfall = 0 ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nothing is short*'
      msg = 'this list is about what did not work out' ).

  ENDMETHOD.

  METHOD the_soonest_comes_first.

    DATA(lt_line) = list_of( VALUE #(
      ( recorded(
          iv_matnr     = 'MAT-2'
          iv_demand_id = 'D2'
          iv_short     = '5'
          iv_req_date  = '20260401' ) )
      ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '1'
          iv_req_date  = '20260301' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*2026-03-01*MAT-1*'
      msg = 'the day it is wanted is what makes one shortage more urgent' ).

  ENDMETHOD.

  METHOD the_biggest_hole_first.

    DATA(lt_line) = list_of( VALUE #(
      ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '1' ) )
      ( recorded(
          iv_matnr     = 'MAT-2'
          iv_demand_id = 'D2'
          iv_short     = '9' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*MAT-2*'
      msg = 'on one day the biggest hole is the one to look at first' ).

  ENDMETHOD.

  METHOD a_date_cuts_the_list.

    DATA(lt_line) = list_of(
      it_recorded = VALUE #(
        ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '1'
          iv_req_date  = '20260301' ) )
        ( recorded(
          iv_matnr     = 'MAT-2'
          iv_demand_id = 'D2'
          iv_short     = '9'
          iv_req_date  = '20260401' ) ) )
      iv_until    = '20260315' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 5
      msg = 'heading, columns, one line, a blank and the footer' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*MAT-1*' ).

  ENDMETHOD.

  METHOD the_top_is_a_top.

    DATA(lt_line) = list_of(
      it_recorded = VALUE #(
        ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '9' ) )
        ( recorded(
          iv_matnr     = 'MAT-2'
          iv_demand_id = 'D2'
          iv_short     = '5' ) )
        ( recorded(
          iv_matnr     = 'MAT-3'
          iv_demand_id = 'D3'
          iv_short     = '1' ) ) )
      iv_top      = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 6
      msg = 'heading, columns, two lines, a blank and the footer' ).

  ENDMETHOD.

  METHOD what_is_cut_off_is_counted.

    DATA(lt_line) = list_of(
      it_recorded = VALUE #(
        ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '9' ) )
        ( recorded(
          iv_matnr     = 'MAT-2'
          iv_demand_id = 'D2'
          iv_short     = '5' ) )
        ( recorded(
          iv_matnr     = 'MAT-3'
          iv_demand_id = 'D3'
          iv_short     = '1' ) ) )
      iv_top      = 2 ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 6 ]
      exp = '2 of 3 short lines shown*'
      msg = 'a list that was cut short must say so rather than look complete' ).

  ENDMETHOD.

  METHOD the_reason_is_in_the_line.

    DATA(lt_line) = list_of( VALUE #(
      ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '5'
          iv_reason    = zif_allocation=>c_reason-supply_late ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*stock comes too late*'
      msg = 'the worklist is only useful if it says what to do about each line' ).

  ENDMETHOD.

  METHOD the_customer_is_shown.

    DATA(lt_line) = list_of( VALUE #(
      ( recorded(
          iv_matnr     = 'MAT-1'
          iv_demand_id = 'D1'
          iv_short     = '5'
          iv_customer  = '0000040007' ) ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*0000040007*'
      msg = 'the first question about a shortage is who is waiting for it' ).

  ENDMETHOD.

  METHOD one_customer_can_be_asked.

    DATA(lt_line) = list_of(
      it_recorded = VALUE #(
        ( recorded(
            iv_matnr     = 'MAT-1'
            iv_demand_id = 'D1'
            iv_short     = '5'
            iv_customer  = '0000040007' ) )
        ( recorded(
            iv_matnr     = 'MAT-2'
            iv_demand_id = 'D2'
            iv_short     = '9'
            iv_customer  = '0000040008' ) ) )
      iv_kunnr    = '0000040007' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 5
      msg = 'heading, columns, one line, a blank and the footer' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*MAT-1*'
      msg = 'somebody about to ring a customer wants that customer only' ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    list_of( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks
      msg = 'this is a plant stock situation, and not everybody may see it' ).

  ENDMETHOD.

ENDCLASS.
