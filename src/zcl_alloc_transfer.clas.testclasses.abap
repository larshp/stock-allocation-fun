"! Hands out the ids it was told to, in order.
CLASS lcl_run_id_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_run_id_supplier.

    TYPES ty_id_tab TYPE STANDARD TABLE OF zstock_alloc_res-run_id WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        it_id TYPE ty_id_tab.

  PRIVATE SECTION.
    DATA mt_id  TYPE ty_id_tab.
    DATA mv_out TYPE i.

ENDCLASS.


CLASS lcl_run_id_double IMPLEMENTATION.

  METHOD constructor.
    mt_id = it_id.
  ENDMETHOD.

  METHOD zif_run_id_supplier~next.

    mv_out = mv_out + 1.

    READ TABLE mt_id INTO rv_run_id INDEX mv_out.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>save_failed
        mv_message = `the test asked for more ids than it provided` ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_transfer DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'TRANSFER-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'TRANSFER-02'.
    CONSTANTS c_here  TYPE mard-werks VALUE '1000'.
    CONSTANTS c_there TYPE mard-werks VALUE '2000'.
    CONSTANTS c_far   TYPE mard-werks VALUE '3000'.

    DATA mo_cut TYPE REF TO zcl_alloc_transfer.

    METHODS setup.
    METHODS teardown.

    METHODS a_proposal_is_written_down FOR TESTING RAISING cx_static_check.
    METHODS an_open_one_is_found FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_another_one FOR TESTING RAISING cx_static_check.
    METHODS the_material_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS a_done_one_is_no_longer_open FOR TESTING RAISING cx_static_check.
    METHODS a_dropped_one_is_not_open FOR TESTING RAISING cx_static_check.
    METHODS answering_twice_is_refused FOR TESTING RAISING cx_static_check.
    METHODS reopening_is_refused FOR TESTING RAISING cx_static_check.
    METHODS another_plant_sees_nothing FOR TESTING RAISING cx_static_check.
    METHODS the_newest_comes_first FOR TESTING RAISING cx_static_check.
    METHODS the_note_is_kept FOR TESTING RAISING cx_static_check.
    METHODS the_soonest_comes_first FOR TESTING RAISING cx_static_check.
    METHODS no_day_is_wanted_now FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_alloc_transfer IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW zcl_alloc_transfer( NEW lcl_run_id_double( VALUE #(
      ( 'PROPOSAL-0000000001' )
      ( 'PROPOSAL-0000000002' )
      ( 'PROPOSAL-0000000003' ) ) ) ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_trf WHERE matnr IN ( @c_matnr, @c_other ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD a_proposal_is_written_down.

    DATA(lv_proposal) = mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40'
      iv_needed_by  = '20260401' ).

    DATA(lt_open) = mo_cut->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_open
      exp = VALUE zcl_alloc_transfer=>ty_proposal_tab(
        ( proposal   = lv_proposal
          matnr      = c_matnr
          to_werks   = c_here
          from_werks = c_there
          quantity   = '40'
          needed_by  = '20260401'
          status     = zcl_alloc_transfer=>c_status-open
          created_by = sy-uname
          created_at = lt_open[ 1 ]-created_at ) )
      msg = 'what was proposed is what comes back, down to who proposed it' ).

  ENDMETHOD.

  METHOD an_open_one_is_found.

    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    cl_abap_unit_assert=>assert_true(
      act = mo_cut->is_open( iv_matnr      = c_matnr
                             iv_to_werks   = c_here
                             iv_from_werks = c_there )
      msg = 'what stops the same proposal being written down every morning' ).

  ENDMETHOD.

  METHOD another_plant_is_another_one.

    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    " two plants can both be able to help, and a planner may want to ask both
    cl_abap_unit_assert=>assert_false(
      act = mo_cut->is_open( iv_matnr      = c_matnr
                             iv_to_werks   = c_here
                             iv_from_werks = c_far )
      msg = 'a proposal is about a pair of plants, not about a material' ).

  ENDMETHOD.

  METHOD the_material_can_be_asked.

    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).
    mo_cut->propose(
      iv_matnr      = c_other
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '10' ).

    DATA(lt_open) = mo_cut->open_for(
      iv_werks = c_here
      iv_matnr = c_other ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_open )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-matnr
      exp = c_other ).

  ENDMETHOD.

  METHOD a_done_one_is_no_longer_open.

    DATA(lv_proposal) = mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    mo_cut->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->open_for( c_here )
      msg = 'a transfer somebody has raised is off the list' ).
    cl_abap_unit_assert=>assert_false(
      mo_cut->is_open( iv_matnr      = c_matnr
                       iv_to_werks   = c_here
                       iv_from_werks = c_there ) ).

  ENDMETHOD.

  METHOD a_dropped_one_is_not_open.

    " a proposal somebody decided against must not come back tomorrow looking
    " like a fresh idea, which is the whole reason this table exists
    DATA(lv_proposal) = mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    mo_cut->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-dropped ).

    cl_abap_unit_assert=>assert_false(
      mo_cut->is_open( iv_matnr      = c_matnr
                       iv_to_werks   = c_here
                       iv_from_werks = c_there ) ).

  ENDMETHOD.

  METHOD answering_twice_is_refused.

    DATA(lv_proposal) = mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    mo_cut->answer(
      iv_proposal = lv_proposal
      iv_status   = zcl_alloc_transfer=>c_status-done ).

    " the first answer is the one that was acted on, and two people answering
    " at once must end with one answer rather than with the later one winning
    TRY.
        mo_cut->answer(
          iv_proposal = lv_proposal
          iv_status   = zcl_alloc_transfer=>c_status-dropped ).
        cl_abap_unit_assert=>fail( 'an answered proposal must not be answered again' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

  METHOD reopening_is_refused.

    DATA(lv_proposal) = mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    TRY.
        mo_cut->answer(
          iv_proposal = lv_proposal
          iv_status   = zcl_alloc_transfer=>c_status-open ).
        cl_abap_unit_assert=>fail( 'open is not an answer to a question' ).
      CATCH zcx_allocation.
    ENDTRY.

    cl_abap_unit_assert=>assert_not_initial(
      act = mo_cut->open_for( c_here )
      msg = 'and the proposal is still waiting for a real one' ).

  ENDMETHOD.

  METHOD another_plant_sees_nothing.

    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    " the list belongs to the plant that is short, because that is who is
    " waiting for the answer
    cl_abap_unit_assert=>assert_initial( mo_cut->open_for( c_far ) ).

  ENDMETHOD.

  METHOD the_newest_comes_first.

    " typed explicitly: arithmetic on SY-DATUM gives a number, not a date
    DATA lv_last_month TYPE d.

    lv_last_month = sy-datum - 30.

    " a proposal from last month, written straight to the table because that
    " is the only way a short test can be a month old: a time stamp counts
    " whole seconds, so two proposals made by the same test are the same age
    INSERT zstock_alloc_trf FROM @( VALUE #(
      mandt      = sy-mandt
      proposal   = 'PROPOSAL-OLD'
      matnr      = c_matnr
      to_werks   = c_here
      from_werks = c_far
      quantity   = '10'
      status     = zcl_alloc_transfer=>c_status-open
      created_at = zcl_alloc_clock=>stamp_of( lv_last_month ) ) ).
    cl_abap_unit_assert=>assert_subrc( ).

    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40' ).

    DATA(lt_open) = mo_cut->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_open )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-from_werks
      exp = c_there
      msg = 'a proposal made this morning is the one somebody is talking about' ).

  ENDMETHOD.

  METHOD the_note_is_kept.

    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40'
      iv_note       = 'agreed with the plant manager' ).

    DATA(lt_open) = mo_cut->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-note
      exp = 'agreed with the plant manager' ).

  ENDMETHOD.

  METHOD the_soonest_comes_first.

    " what makes one shortage more urgent than another is the day it is
    " wanted, not the morning somebody wrote the note
    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40'
      iv_needed_by  = '20260601' ).
    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_far
      iv_quantity   = '10'
      iv_needed_by  = '20260401' ).

    DATA(lt_open) = mo_cut->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-from_werks
      exp = c_far
      msg = 'the transfer wanted in April comes before the one wanted in June' ).

  ENDMETHOD.

  METHOD no_day_is_wanted_now.

    " a proposal somebody typed in without a day is one they are talking
    " about this morning, and an initial date already sorts as first
    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_there
      iv_quantity   = '40'
      iv_needed_by  = '20260401' ).
    mo_cut->propose(
      iv_matnr      = c_matnr
      iv_to_werks   = c_here
      iv_from_werks = c_far
      iv_quantity   = '10' ).

    DATA(lt_open) = mo_cut->open_for( c_here ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_open[ 1 ]-from_werks
      exp = c_far ).

  ENDMETHOD.

ENDCLASS.
