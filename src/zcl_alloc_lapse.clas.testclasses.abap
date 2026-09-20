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

    LOOP AT mt_recorded INTO DATA(ls_recorded).
      IF iv_matnr IS NOT INITIAL AND ls_recorded-matnr <> iv_matnr.
        CONTINUE.
      ENDIF.
      APPEND ls_recorded TO rt_recorded.
    ENDLOOP.

  ENDMETHOD.

  METHOD zif_allocation_store~save.
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


CLASS ltcl_alloc_lapse DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'LAPSE-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'LAPSE-02'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.

    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.

    METHODS setup.
    METHODS teardown.

    METHODS cut_with
      IMPORTING
        it_recorded   TYPE zif_allocation_store=>ty_recorded_tab
      RETURNING
        VALUE(ro_cut) TYPE REF TO zcl_alloc_lapse.

    METHODS given_proposal
      IMPORTING
        iv_matnr TYPE mard-matnr DEFAULT c_matnr
      RAISING
        zcx_allocation.

    METHODS a_served_material_lapses FOR TESTING RAISING cx_static_check.
    METHODS an_unrun_material_lapses FOR TESTING RAISING cx_static_check.
    METHODS a_short_material_stays FOR TESTING RAISING cx_static_check.
    METHODS a_test_run_closes_nothing FOR TESTING RAISING cx_static_check.
    METHODS the_closed_ones_are_named FOR TESTING RAISING cx_static_check.
    METHODS still_short_answers_both_ways FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_left_alone FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_lapse IMPLEMENTATION.

  METHOD setup.
    mo_transfer = NEW zcl_alloc_transfer( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_trf WHERE matnr IN ( @c_matnr, @c_other ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD cut_with.

    ro_cut = NEW zcl_alloc_lapse(
      io_transfer = mo_transfer
      io_store    = NEW lcl_store_double( it_recorded ) ).

  ENDMETHOD.

  METHOD given_proposal.

    mo_transfer->propose(
      iv_matnr      = iv_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

  ENDMETHOD.

  METHOD a_served_material_lapses.

    given_proposal( ).

    DATA(ls_outcome) = cut_with( VALUE #(
      ( matnr = c_matnr demand_id = 'D1' requested = '40'
        confirmed = '40' shortfall = 0 ) ) )->run(
      iv_werks = c_here
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-closed
      exp = 1 ).
    cl_abap_unit_assert=>assert_initial( mo_transfer->open_for( c_here ) ).

  ENDMETHOD.

  METHOD an_unrun_material_lapses.

    " a material the newest run has nothing to say about is one nothing is
    " waiting for, which is a shortage that has gone as surely as one served
    given_proposal( ).

    DATA(ls_outcome) = cut_with( VALUE #( ) )->run(
      iv_werks = c_here
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-closed
      exp = 1 ).

  ENDMETHOD.

  METHOD a_short_material_stays.

    given_proposal( ).

    DATA(ls_outcome) = cut_with( VALUE #(
      ( matnr = c_matnr demand_id = 'D1' requested = '40'
        confirmed = 0 shortfall = '40' reason = 'S' ) ) )->run(
      iv_werks = c_here
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-closed
      exp = 0 ).
    cl_abap_unit_assert=>assert_not_initial(
      act = mo_transfer->open_for( c_here )
      msg = 'a proposal with a shortage behind it is not housekeeping' ).

  ENDMETHOD.

  METHOD a_test_run_closes_nothing.

    given_proposal( ).

    DATA(ls_outcome) = cut_with( VALUE #( ) )->run( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-closed
      exp = 1
      msg = 'a test run still says how many it would close' ).
    cl_abap_unit_assert=>assert_not_initial( mo_transfer->open_for( c_here ) ).

  ENDMETHOD.

  METHOD the_closed_ones_are_named.

    " the caller puts these on its own page, so the class has to say which
    " they were rather than only how many
    given_proposal( ).

    DATA(ls_outcome) = cut_with( VALUE #( ) )->run( c_here ).

    cl_abap_unit_assert=>assert_char_cp(
      act = ls_outcome-line[ 1 ]
      exp = |*{ c_matnr }*2000*| ).

  ENDMETHOD.

  METHOD still_short_answers_both_ways.

    DATA(lo_cut) = cut_with( VALUE #(
      ( matnr = c_matnr demand_id = 'D1' requested = '40'
        confirmed = 0 shortfall = '40' reason = 'S' ) ) ).

    cl_abap_unit_assert=>assert_true( lo_cut->still_short(
      iv_werks = c_here
      iv_matnr = c_matnr ) ).
    cl_abap_unit_assert=>assert_false(
      act = lo_cut->still_short( iv_werks = c_here
                                 iv_matnr = c_other )
      msg = 'the worklist marks with this and the closing acts on it, so it is one answer' ).

  ENDMETHOD.

  METHOD another_plant_is_left_alone.

    given_proposal( ).

    DATA(ls_outcome) = cut_with( VALUE #( ) )->run(
      iv_werks = c_there
      iv_test  = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_outcome-closed
      exp = 0 ).
    cl_abap_unit_assert=>assert_not_initial(
      act = mo_transfer->open_for( c_here )
      msg = 'closing one plant s notes is not closing everybody s' ).

  ENDMETHOD.

ENDCLASS.
