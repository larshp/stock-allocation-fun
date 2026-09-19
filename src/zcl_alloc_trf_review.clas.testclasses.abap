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
    " a review only reads
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


"! Refuses every plant but the one it was told.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_allowed TYPE mard-werks.

  PRIVATE SECTION.
    DATA mv_allowed TYPE mard-werks.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_allowed = iv_allowed.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF iv_werks <> mv_allowed.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_trf_review DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'REVIEW-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'REVIEW-02'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.

    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.

    METHODS setup.
    METHODS teardown.

    METHODS given_proposal
      IMPORTING
        iv_matnr           TYPE mard-matnr DEFAULT c_matnr
        iv_quantity        TYPE zif_allocation=>ty_quantity DEFAULT '40'
      RETURNING
        VALUE(rv_proposal) TYPE zstock_alloc_trf-proposal
      RAISING
        zcx_allocation.

    METHODS review_of
      IMPORTING
        it_recorded    TYPE zif_allocation_store=>ty_recorded_tab OPTIONAL
        iv_werks       TYPE mard-werks DEFAULT c_here
        iv_since       TYPE d OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_trf_review=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS found
      IMPORTING
        it_line         TYPE zcl_alloc_trf_review=>ty_line_tab
        iv_pattern      TYPE string
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

    METHODS nothing_proposed_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_waiting_one_is_counted FOR TESTING RAISING cx_static_check.
    METHODS a_raised_one_is_counted FOR TESTING RAISING cx_static_check.
    METHODS the_raised_quantity_is_shown FOR TESTING RAISING cx_static_check.
    METHODS a_dropped_one_is_its_own_row FOR TESTING RAISING cx_static_check.
    METHODS a_lapsed_one_is_its_own_row FOR TESTING RAISING cx_static_check.
    METHODS the_material_no_longer_short FOR TESTING RAISING cx_static_check.
    METHODS one_still_short_is_not_counted FOR TESTING RAISING cx_static_check.
    METHODS two_notes_one_material FOR TESTING RAISING cx_static_check.
    METHODS nothing_raised_says_so FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_trf_review IMPLEMENTATION.

  METHOD setup.

    mo_transfer = NEW zcl_alloc_transfer( ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_trf WHERE matnr IN ( @c_matnr, @c_other ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_proposal.

    rv_proposal = mo_transfer->propose(
      iv_matnr      = iv_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = iv_quantity ).

  ENDMETHOD.

  METHOD review_of.

    DATA(lo_cut) = NEW zcl_alloc_trf_review(
      io_transfer  = mo_transfer
      io_lapse     = NEW zcl_alloc_lapse(
        io_transfer = mo_transfer
        io_store    = NEW lcl_store_double( it_recorded ) )
      io_authority = NEW lcl_authority_double( c_here ) ).

    rt_line = lo_cut->run(
      iv_werks = iv_werks
      iv_since = iv_since ).

  ENDMETHOD.

  METHOD found.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CP iv_pattern.
        rv_found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD nothing_proposed_says_so.

    DATA(lt_line) = review_of( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nobody has proposed a transfer*' ).

  ENDMETHOD.

  METHOD a_waiting_one_is_counted.

    given_proposal( ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*Waiting for an answer*1*40.000*' ) ).

  ENDMETHOD.

  METHOD a_raised_one_is_counted.

    DATA(lv_proposal) = given_proposal( ).

    mo_transfer->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*Raised*1*40.000*40.000*' ) ).

  ENDMETHOD.

  METHOD the_raised_quantity_is_shown.

    " what was asked for and what was agreed are the two numbers this page
    " exists to put next to each other
    DATA(lv_proposal) = given_proposal( ).

    mo_transfer->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-done
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*Raised*1*40.000*10.000*' ) ).

  ENDMETHOD.

  METHOD a_dropped_one_is_its_own_row.

    " "we said no" and "it stopped mattering" are different answers, which is
    " the distinction feature 164 went to the trouble of keeping
    DATA(lv_proposal) = given_proposal( ).

    mo_transfer->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-dropped ).

    DATA(lt_line) = review_of( ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*Decided against*1*' ) ).
    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*Shortage went away*1*' ) ).

  ENDMETHOD.

  METHOD a_lapsed_one_is_its_own_row.

    DATA(lv_proposal) = given_proposal( ).

    mo_transfer->lapse( lv_proposal ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*Shortage went away*1*' ) ).

  ENDMETHOD.

  METHOD the_material_no_longer_short.

    " the number the page exists for: a transfer was raised and the material
    " is not on the short list any more
    DATA(lv_proposal) = given_proposal( ).

    mo_transfer->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*1 material(s) a transfer was raised for, 1 no longer short*' ) ).

  ENDMETHOD.

  METHOD one_still_short_is_not_counted.

    DATA(lv_proposal) = given_proposal( ).

    mo_transfer->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( it_recorded = VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '40'
          confirmed = 0 shortfall = '40' reason = 'S' ) ) )
      iv_pattern = '*1 material(s) a transfer was raised for, 0 no longer short*' ) ).

  ENDMETHOD.

  METHOD two_notes_one_material.

    " two plants were asked for part of it each, and the question the count
    " answers is about the material rather than about the notes
    DATA(lv_first) = given_proposal( iv_quantity = '25' ).

    mo_transfer->answer(
      iv_proposal = lv_first
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    DATA(lv_next) = mo_transfer->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = '3000'
      iv_quantity   = '15' ).

    mo_transfer->answer(
      iv_proposal = lv_next
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*2 proposal(s); of the 1 material(s)*' ) ).

  ENDMETHOD.

  METHOD nothing_raised_says_so.

    " a period where every note was decided against or lapsed has nothing to
    " say about whether transfers help, and must not say nought as though it
    " had measured something
    given_proposal( ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = review_of( )
      iv_pattern = '*none of them raised*' ) ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    given_proposal( ).

    TRY.
        review_of( iv_werks = c_there ).
        cl_abap_unit_assert=>fail( 'what a plant decided is that plant s business' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
