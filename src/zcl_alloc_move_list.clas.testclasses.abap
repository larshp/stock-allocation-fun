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


"! Allows the plants it was told to allow, and refuses the rest.
CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    TYPES ty_werks_tab TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_allowed TYPE ty_werks_tab.

    METHODS asked
      RETURNING
        VALUE(rv_asked) TYPE i.

  PRIVATE SECTION.
    DATA mt_allowed TYPE ty_werks_tab.
    DATA mv_asked   TYPE i.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mt_allowed = it_allowed.
  ENDMETHOD.

  METHOD asked.
    rv_asked = mv_asked.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    mv_asked = mv_asked + 1.

    IF NOT line_exists( mt_allowed[ table_line = iv_werks ] ).
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>not_authorised
        mv_message = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


"! Counts the commits.
CLASS lcl_commit_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_unit_of_work.

    METHODS commits
      RETURNING
        VALUE(rv_commits) TYPE i.

  PRIVATE SECTION.
    DATA mv_commits TYPE i.
    DATA mv_rolled  TYPE abap_bool.

ENDCLASS.


CLASS lcl_commit_double IMPLEMENTATION.

  METHOD commits.
    rv_commits = mv_commits.
  ENDMETHOD.

  METHOD zif_unit_of_work~commit.
    mv_commits = mv_commits + 1.
  ENDMETHOD.

  METHOD zif_unit_of_work~rollback.
    " nothing here rolls back: an answer is given or it is not
    CLEAR mv_rolled.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_move_list DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'MOVE-LIST-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'MOVE-LIST-02'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.
    CONSTANTS c_far   TYPE mard-werks VALUE '3000'.

    DATA mo_transfer TYPE REF TO zcl_alloc_transfer.
    DATA mo_display  TYPE REF TO lcl_authority_double.
    DATA mo_change   TYPE REF TO lcl_authority_double.
    DATA mo_commit   TYPE REF TO lcl_commit_double.
    DATA mo_cut      TYPE REF TO zcl_alloc_move_list.

    METHODS setup.
    METHODS teardown.

    METHODS wire
      IMPORTING
        it_display  TYPE lcl_authority_double=>ty_werks_tab
        it_change   TYPE lcl_authority_double=>ty_werks_tab
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab OPTIONAL.

    METHODS given_proposal
      IMPORTING
        iv_matnr           TYPE mard-matnr DEFAULT c_matnr
        iv_from            TYPE mard-werks DEFAULT c_there
        iv_needed_by       TYPE d DEFAULT '20260401'
        iv_note            TYPE zstock_alloc_trf-note OPTIONAL
      RETURNING
        VALUE(rv_proposal) TYPE zstock_alloc_trf-proposal
      RAISING
        zcx_allocation.

    METHODS found
      IMPORTING
        it_line         TYPE zcl_alloc_move_list=>ty_line_tab
        iv_pattern      TYPE string
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

    METHODS nothing_waiting_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_proposal_is_listed FOR TESTING RAISING cx_static_check.
    METHODS the_note_and_who_made_it FOR TESTING RAISING cx_static_check.
    METHODS the_material_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS a_raised_one_is_answered FOR TESTING RAISING cx_static_check.
    METHODS a_dropped_one_is_answered FOR TESTING RAISING cx_static_check.
    METHODS the_answer_is_committed FOR TESTING RAISING cx_static_check.
    METHODS another_plants_one_is_refused FOR TESTING RAISING cx_static_check.
    METHODS reading_needs_only_display FOR TESTING RAISING cx_static_check.
    METHODS answering_needs_the_change FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked_first FOR TESTING RAISING cx_static_check.
    METHODS no_day_reads_as_now FOR TESTING RAISING cx_static_check.
    METHODS a_shortage_that_has_gone FOR TESTING RAISING cx_static_check.
    METHODS a_material_nobody_ran FOR TESTING RAISING cx_static_check.
    METHODS a_live_one_says_nothing FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_move_list IMPLEMENTATION.

  METHOD setup.

    mo_transfer = NEW zcl_alloc_transfer( ).

    " every material this test class proposes for is short by default, which
    " is the state a proposal is made in
    wire(
      it_display  = VALUE #( ( c_here ) ( c_there ) ( c_far ) )
      it_change   = VALUE #( ( c_here ) ( c_there ) ( c_far ) )
      it_recorded = VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '40'
          confirmed = 0 shortfall = '40' reason = 'S' )
        ( matnr = c_other demand_id = 'D2' requested = '10'
          confirmed = 0 shortfall = '10' reason = 'S' ) ) ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_trf WHERE matnr IN ( @c_matnr, @c_other ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD wire.

    mo_display = NEW lcl_authority_double( it_display ).
    mo_change  = NEW lcl_authority_double( it_change ).
    mo_commit  = NEW lcl_commit_double( ).

    mo_cut = NEW zcl_alloc_move_list(
      io_transfer = mo_transfer
      io_store    = NEW lcl_store_double( it_recorded )
      io_display  = mo_display
      io_change   = mo_change
      io_commit   = mo_commit ).

  ENDMETHOD.

  METHOD given_proposal.

    rv_proposal = mo_transfer->propose(
      iv_matnr      = iv_matnr
      iv_to_werks   = c_here
      iv_from_werks = iv_from
      iv_quantity   = '40'
      iv_needed_by  = iv_needed_by
      iv_note       = iv_note ).

  ENDMETHOD.

  METHOD found.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CP iv_pattern.
        rv_found = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD nothing_waiting_says_so.

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*Nothing is waiting for an answer*'
      msg = 'a morning with nothing to answer should say so in one line' ).

  ENDMETHOD.

  METHOD a_proposal_is_listed.

    DATA(lv_proposal) = given_proposal( ).

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = |*{ lv_proposal }*{ c_matnr }*2000*40.000*2026-04-01*| )
      msg = 'the id is on the line because it is what answering one needs' ).
    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*1 waiting*' ) ).

  ENDMETHOD.

  METHOD the_note_and_who_made_it.

    " a proposal the night made and one a person made are the same row in the
    " table and a different thing to answer, and the note is what says which
    given_proposal( iv_note = 'agreed with the plant manager' ).

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_true( found(
      it_line    = lt_line
      iv_pattern = |*{ sy-uname }*agreed with the plant manager*| ) ).

  ENDMETHOD.

  METHOD the_material_can_be_asked.

    given_proposal( ).
    given_proposal( iv_matnr = c_other ).

    DATA(lt_line) = mo_cut->run(
      iv_werks = c_here
      iv_matnr = c_other ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = |*{ c_other }*| ) ).
    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = |*{ c_matnr }*| ) ).

  ENDMETHOD.

  METHOD a_raised_one_is_answered.

    DATA(lv_proposal) = given_proposal( ).

    DATA(lt_line) = mo_cut->answer(
      iv_werks    = c_here
      iv_proposal = lv_proposal
      iv_raised   = abap_true ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*is raised*' ) ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_transfer->open_for( c_here )
      msg = 'and it is off the worklist' ).

  ENDMETHOD.

  METHOD a_dropped_one_is_answered.

    " which of the two answers it was matters as much as that it was
    " answered: one that was raised is dealt with, one that was decided
    " against is worth thinking about again next month
    DATA(lv_proposal) = given_proposal( ).

    DATA(lt_line) = mo_cut->answer(
      iv_werks    = c_here
      iv_proposal = lv_proposal
      iv_raised   = abap_false ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*decided against*' ) ).
    cl_abap_unit_assert=>assert_initial( mo_transfer->open_for( c_here ) ).

  ENDMETHOD.

  METHOD the_answer_is_committed.

    DATA(lv_proposal) = given_proposal( ).

    mo_cut->answer(
      iv_werks    = c_here
      iv_proposal = lv_proposal
      iv_raised   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->commits( )
      exp = 1
      msg = 'a decision somebody typed has to survive them closing the window' ).

  ENDMETHOD.

  METHOD another_plants_one_is_refused.

    " a proposal id is a UUID, so guessing one is not the risk. Answering one
    " somebody happens to have the number for is.
    DATA(lv_proposal) = mo_transfer->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_far
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    TRY.
        mo_cut->answer(
          iv_werks    = c_here
          iv_proposal = lv_proposal
          iv_raised   = abap_true ).
        cl_abap_unit_assert=>fail( 'a proposal belongs to the plant that is short' ).
      CATCH zcx_allocation.
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial(
      act = mo_transfer->open_for( c_far )
      msg = 'and the other plant still has its proposal' ).

  ENDMETHOD.

  METHOD reading_needs_only_display.

    " somebody who may look at a plant may read what is waiting for an answer
    wire(
      it_display  = VALUE #( ( c_here ) )
      it_change   = VALUE #( )
      it_recorded = VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '40'
          confirmed = 0 shortfall = '40' reason = 'S' ) ) ).

    given_proposal( ).

    cl_abap_unit_assert=>assert_not_initial( mo_cut->run( c_here ) ).

  ENDMETHOD.

  METHOD answering_needs_the_change.

    DATA(lv_proposal) = given_proposal( ).

    wire(
      it_display  = VALUE #( ( c_here ) )
      it_change   = VALUE #( )
      it_recorded = VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '40'
          confirmed = 0 shortfall = '40' reason = 'S' ) ) ).

    TRY.
        mo_cut->answer(
          iv_werks    = c_here
          iv_proposal = lv_proposal
          iv_raised   = abap_true ).
        cl_abap_unit_assert=>fail( 'looking at a plant is not deciding for it' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD the_plant_is_checked_first.

    " nothing is read for a plant the user may not act in, so a refusal
    " cannot tell them what that plant is short of
    wire(
      it_display  = VALUE #( ( c_here ) )
      it_change   = VALUE #( )
      it_recorded = VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '40'
          confirmed = 0 shortfall = '40' reason = 'S' ) ) ).

    TRY.
        mo_cut->answer(
          iv_werks    = c_here
          iv_proposal = 'DOES-NOT-EXIST'
          iv_raised   = abap_true ).
        cl_abap_unit_assert=>fail( 'the plant is checked before anything is read' ).
      CATCH zcx_allocation.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act = mo_change->asked( )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->commits( )
      exp = 0 ).

  ENDMETHOD.

  METHOD no_day_reads_as_now.

    " a blank column where a date belongs reads as a date nobody filled in,
    " and this one means something: as soon as possible
    given_proposal( iv_needed_by = '00000000' ).

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*now*' ) ).

  ENDMETHOD.

  METHOD a_shortage_that_has_gone.

    " stock arrived, or a re-cut gave the line what it wanted. The note is
    " then one somebody would act on for no reason.
    DATA(lv_proposal) = given_proposal( ).

    wire(
      it_display  = VALUE #( ( c_here ) )
      it_change   = VALUE #( ( c_here ) )
      it_recorded = VALUE #(
        ( matnr = c_matnr demand_id = 'D1' requested = '40'
          confirmed = '40' shortfall = 0 ) ) ).

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*no longer short*' ) ).
    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = '*1 of them for a shortage that has gone*' )
      msg = 'the footer says how many, so a long list can be scanned for it' ).
    cl_abap_unit_assert=>assert_true(
      act = found( it_line    = lt_line
                   iv_pattern = |*{ lv_proposal }*| )
      msg = 'and the proposal stays on the list: it is a person who closes it' ).

  ENDMETHOD.

  METHOD a_material_nobody_ran.

    " a material the newest run has nothing to say about is one nothing is
    " waiting for, which is a shortage that has gone as surely as one served
    given_proposal( ).

    wire(
      it_display  = VALUE #( ( c_here ) )
      it_change   = VALUE #( ( c_here ) )
      it_recorded = VALUE #( ) ).

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_true( found( it_line    = lt_line
                                             iv_pattern = '*no longer short*' ) ).

  ENDMETHOD.

  METHOD a_live_one_says_nothing.

    given_proposal( ).

    DATA(lt_line) = mo_cut->run( c_here ).

    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*no longer short*' ) ).
    cl_abap_unit_assert=>assert_false( found( it_line    = lt_line
                                              iv_pattern = '*shortage that has gone*' ) ).

  ENDMETHOD.

ENDCLASS.
