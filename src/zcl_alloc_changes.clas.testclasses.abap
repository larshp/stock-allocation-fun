"! Answers with fixed runs and fixed lines per run.
CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    TYPES:
      BEGIN OF ty_run_lines,
        run_id     TYPE zstock_alloc_res-run_id,
        allocation TYPE zif_allocation=>ty_allocation_tab,
      END OF ty_run_lines.
    TYPES ty_run_lines_tab TYPE STANDARD TABLE OF ty_run_lines WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab
        it_run      TYPE zif_allocation_store=>ty_run_head_tab
        it_lines    TYPE ty_run_lines_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.
    DATA mt_run      TYPE zif_allocation_store=>ty_run_head_tab.
    DATA mt_lines    TYPE ty_run_lines_tab.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
    mt_run      = it_run.
    mt_lines    = it_lines.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_of_material.
    rt_run = mt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~read.
    READ TABLE mt_lines INTO DATA(ls_lines) WITH KEY run_id = iv_run_id.
    IF sy-subrc = 0.
      rt_allocation = ls_lines-allocation.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_store~runs_recorded_before.
    CLEAR rt_run.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    CLEAR mt_lines.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mt_lines.
  ENDMETHOD.

  METHOD zif_allocation_store~delete_run.
    CLEAR mt_lines.
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


CLASS ltcl_alloc_changes DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'DIFF-MAT-01'.
    CONSTANTS c_now   TYPE zstock_alloc_res-run_id VALUE 'DIFF-RUN-000002'.
    CONSTANTS c_then  TYPE zstock_alloc_res-run_id VALUE 'DIFF-RUN-000001'.
    CONSTANTS c_kunnr TYPE vbak-kunnr VALUE '0000060001'.

    DATA mo_authority TYPE REF TO lcl_authority_double.

    METHODS setup.

    METHODS changes
      IMPORTING
        iv_now         TYPE zif_allocation=>ty_quantity
        iv_then        TYPE zif_allocation=>ty_quantity
        iv_worse_only  TYPE abap_bool DEFAULT abap_false
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
        iv_had_a_run   TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_changes=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS a_line_that_lost_shows FOR TESTING RAISING cx_static_check.
    METHODS a_line_that_gained_shows FOR TESTING RAISING cx_static_check.
    METHODS an_unchanged_line_is_quiet FOR TESTING RAISING cx_static_check.
    METHODS worse_only_drops_the_gains FOR TESTING RAISING cx_static_check.
    METHODS a_first_run_is_all_new FOR TESTING RAISING cx_static_check.
    METHODS another_customer_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS the_footer_counts_the_losses FOR TESTING RAISING cx_static_check.
    METHODS a_preview_says_what_it_is FOR TESTING RAISING cx_static_check.
    METHODS no_simulator_is_no_preview FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_changes IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_double( ).
  ENDMETHOD.

  METHOD changes.

    DATA lt_run TYPE zif_allocation_store=>ty_run_head_tab.

    lt_run = VALUE #(
      ( run_id = c_now matnr = c_matnr werks = c_werks ) ).

    IF iv_had_a_run = abap_true.
      APPEND VALUE #(
        run_id = c_then
        matnr  = c_matnr
        werks  = c_werks ) TO lt_run.
    ENDIF.

    DATA(lo_cut) = NEW zcl_alloc_changes(
      io_store     = NEW lcl_store_double(
        it_recorded = VALUE #(
          ( matnr     = c_matnr
            run_id    = c_now
            demand_id = 'D1'
            requested = '10'
            confirmed = iv_now
            shortfall = 0
            customer  = c_kunnr ) )
        it_run      = lt_run
        it_lines    = VALUE #(
          ( run_id     = c_then
            allocation = VALUE #(
              ( demand_id = 'D1'
                requested = '10'
                confirmed = iv_then
                shortfall = 0 ) ) ) ) )
      io_authority = mo_authority ).

    rt_line = lo_cut->run(
      iv_werks      = c_werks
      iv_kunnr      = iv_kunnr
      iv_worse_only = iv_worse_only ).

  ENDMETHOD.

  METHOD a_line_that_lost_shows.

    DATA(lt_line) = changes(
      iv_then = '10'
      iv_now  = '4' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*D1*10.000*4.000*'
      msg = 'somebody has to ring the customer who lost six' ).

  ENDMETHOD.

  METHOD a_line_that_gained_shows.

    DATA(lt_line) = changes(
      iv_then = '4'
      iv_now  = '10' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*4.000*10.000*'
      msg = 'and the good news is worth a call as well' ).

  ENDMETHOD.

  METHOD an_unchanged_line_is_quiet.

    DATA(lt_line) = changes(
      iv_then = '10'
      iv_now  = '10' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = 'Nothing changed'
      msg = 'a line exactly where it was is not news' ).

  ENDMETHOD.

  METHOD worse_only_drops_the_gains.

    DATA(lt_line) = changes(
      iv_then       = '4'
      iv_now        = '10'
      iv_worse_only = abap_true ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = 'Nothing changed'
      msg = 'somebody with calls to make wants the losses only' ).

  ENDMETHOD.

  METHOD a_first_run_is_all_new.

    DATA(lt_line) = changes(
      iv_then      = '0'
      iv_now       = '10'
      iv_had_a_run = abap_false ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*0.000*10.000*'
      msg = 'a material allocated for the first time gained all of it' ).

  ENDMETHOD.

  METHOD another_customer_is_left_out.

    DATA(lt_line) = changes(
      iv_then  = '10'
      iv_now   = '4'
      iv_kunnr = '0000060009' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = 'Nothing changed' ).

  ENDMETHOD.

  METHOD the_footer_counts_the_losses.

    DATA(lt_line) = changes(
      iv_then = '10'
      iv_now  = '4' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = '1 line(s) changed, 1 of them for the worse' ).

  ENDMETHOD.

  METHOD a_preview_says_what_it_is.

    " no simulator wired in, so the run now confirms nothing and every
    " recorded line reads as a line about to lose everything: which is what a
    " preview of a plant with no stock left would say
    DATA(lo_cut) = NEW zcl_alloc_changes(
      io_store     = NEW lcl_store_double(
        it_recorded = VALUE #(
          ( matnr     = c_matnr
            run_id    = c_now
            demand_id = 'D1'
            requested = '10'
            confirmed = '10'
            shortfall = 0
            customer  = c_kunnr ) )
        it_run      = VALUE #( ( run_id = c_now matnr = c_matnr werks = c_werks ) )
        it_lines    = VALUE #( ) )
      io_authority = mo_authority ).

    DATA(lt_line) = lo_cut->run(
      iv_werks   = c_werks
      iv_preview = abap_true ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = '*what a run now would change*'
      msg = 'a preview and a look back must not read the same' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*10.000*0.000*'
      msg = 'what the line has now, against what it would have' ).

  ENDMETHOD.

  METHOD no_simulator_is_no_preview.

    " the same numbers the other way round: without the preview flag the
    " comparison is with the run before, which this material does not have
    DATA(lt_line) = changes(
      iv_then      = '0'
      iv_now       = '10'
      iv_had_a_run = abap_false ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = '*what the last run changed*' ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    changes(
      iv_then = '10'
      iv_now  = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks ).

  ENDMETHOD.

ENDCLASS.
