"! Answers with fixed runs and fixed recorded lines.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_run       TYPE zif_allocation_store=>ty_run_head_tab
        iv_confirmed TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mt_run       TYPE zif_allocation_store=>ty_run_head_tab.
    DATA mv_confirmed TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_run       = it_run.
    mv_confirmed = iv_confirmed.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    rt_run = mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    rt_allocation = VALUE #(
      ( demand_id = 'D1'
        requested = mv_confirmed
        confirmed = mv_confirmed
        shortfall = 0 ) ).
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    CLEAR mv_confirmed.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mv_confirmed.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mv_confirmed.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    CLEAR rt_recorded.
  ENDMETHOD.

ENDCLASS.


"! Says the same thing about every reservation it is asked about.
CLASS lcl_reservation_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_reservation_reader.

    METHODS constructor
      IMPORTING
        iv_held TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mv_held TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_reservation_double IMPLEMENTATION.

  METHOD constructor.
    mv_held = iv_held.
  ENDMETHOD.

  METHOD zif_reservation_reader~held_quantity.
    rv_quantity = mv_held.
  ENDMETHOD.

  METHOD zif_reservation_reader~live_reservations.
    CLEAR rt_reservation.
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


CLASS ltcl_alloc_consistency DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_matnr  TYPE mard-matnr VALUE 'CHECK-MAT-01'.
    CONSTANTS c_run_id TYPE zstock_alloc_res-run_id VALUE 'CHECK-RUN-000001'.
    CONSTANTS c_res    TYPE zstock_alloc_res-reservation VALUE '0000005001'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS checked
      IMPORTING
        iv_confirmed   TYPE zif_allocation=>ty_quantity
        iv_held        TYPE zif_allocation=>ty_quantity
        iv_reservation TYPE zstock_alloc_res-reservation DEFAULT c_res
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_consistency=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS agreement_says_nothing FOR TESTING RAISING cx_static_check.
    METHODS a_gone_reservation_shows FOR TESTING RAISING cx_static_check.
    METHODS holding_less_shows FOR TESTING RAISING cx_static_check.
    METHODS holding_more_shows FOR TESTING RAISING cx_static_check.
    METHODS never_reserved_shows FOR TESTING RAISING cx_static_check.
    METHODS an_empty_run_is_not_wrong FOR TESTING RAISING cx_static_check.
    METHODS the_count_is_in_the_footer FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_consistency IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD checked.

    DATA(lo_cut) = NEW zcl_alloc_consistency(
      io_store       = NEW lcl_store_double(
        it_run       = VALUE #(
          ( run_id      = c_run_id
            matnr       = c_matnr
            werks       = c_werks
            reservation = iv_reservation ) )
        iv_confirmed = iv_confirmed )
      io_reservation = NEW lcl_reservation_double( iv_held )
      io_authority   = mo_authority ).

    rt_line = lo_cut->run( c_werks ).

  ENDMETHOD.

  METHOD agreement_says_nothing.

    DATA(lt_line) = checked(
      iv_confirmed = '10'
      iv_held      = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 3
      msg = 'a heading, a blank and the footer: nothing to look at' ).

  ENDMETHOD.

  METHOD a_gone_reservation_shows.

    DATA(lt_line) = checked(
      iv_confirmed = '10'
      iv_held      = 0 ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*reservation is gone*'
      msg = 'the netting stopped counting it, and the run still says it holds' ).

  ENDMETHOD.

  METHOD holding_less_shows.

    DATA(lt_line) = checked(
      iv_confirmed = '10'
      iv_held      = '4' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*holds less than the run promised*'
      msg = 'somebody with MB22 can do this, and the run will not notice' ).

  ENDMETHOD.

  METHOD holding_more_shows.

    DATA(lt_line) = checked(
      iv_confirmed = '10'
      iv_held      = '14' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*holds more than the run promised*'
      msg = 'stock held back that no run admits to holding is the worse case' ).

  ENDMETHOD.

  METHOD never_reserved_shows.

    DATA(lt_line) = checked(
      iv_confirmed   = '10'
      iv_held        = 0
      iv_reservation = '0000000000' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*never reserved*'
      msg = 'the state a rejected reservation leaves, which is there to retry' ).

  ENDMETHOD.

  METHOD an_empty_run_is_not_wrong.

    DATA(lt_line) = checked(
      iv_confirmed = 0
      iv_held      = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 3
      msg = 'a run that confirmed nothing has nothing to hold back' ).

  ENDMETHOD.

  METHOD the_count_is_in_the_footer.

    DATA(lt_line) = checked(
      iv_confirmed = '10'
      iv_held      = '4' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '1 run(s) checked, 1 to look at' ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    checked(
      iv_confirmed = '10'
      iv_held      = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks ).

  ENDMETHOD.

ENDCLASS.
