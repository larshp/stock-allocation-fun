CLASS ltcl_alloc_promised DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'FIX-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9251'.
    CONSTANTS c_first TYPE zif_allocation=>ty_demand_id VALUE 'FIX-D1'.
    CONSTANTS c_secnd TYPE zif_allocation=>ty_demand_id VALUE 'FIX-D2'.

    DATA mo_cut TYPE REF TO zif_allocation_strategy.

    METHODS setup.
    METHODS teardown.

    METHODS given_promise
      IMPORTING
        iv_id       TYPE zstock_alloc_fix-demand_id
        iv_quantity TYPE zif_allocation=>ty_quantity
        iv_valid_to TYPE d DEFAULT '00000000'.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_priority      TYPE zif_allocation=>ty_priority
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS confirmed_of
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_id              TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS no_promise_changes_nothing FOR TESTING.
    METHODS a_promise_is_served_first FOR TESTING.
    METHODS the_rest_is_distributed FOR TESTING.
    METHODS more_than_the_line_is_capped FOR TESTING.
    METHODS more_than_there_is_is_capped FOR TESTING.
    METHODS every_line_is_answered_once FOR TESTING.
    METHODS what_was_asked_for_is_kept FOR TESTING.
    METHODS a_promise_is_given_once FOR TESTING.
    METHODS a_promise_can_run_out FOR TESTING.
    METHODS a_promise_of_today_holds FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_promised IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_promised( NEW zcl_alloc_strategy_priority( ) ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_fix WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_promise.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_fix WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = c_matnr
        demand_id = iv_id
        quantity  = iv_quantity
        valid_to  = iv_valid_to
        reason    = 'Promised by the sales director' ) ).

    INSERT zstock_alloc_fix FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = '20260601'
      priority  = iv_priority
      customer  = 'FIXCUST' ).

  ENDMETHOD.

  METHOD confirmed_of.

    READ TABLE it_allocation INTO DATA(ls_line)
      WITH KEY demand_id = iv_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_line-confirmed.

  ENDMETHOD.

  METHOD no_promise_changes_nothing.

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = c_first
                                        iv_quantity = 20
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_first )
      exp = CONV zif_allocation=>ty_quantity( 10 )
      msg = 'a material nobody has promised anything of is distributed as before' ).

  ENDMETHOD.

  METHOD a_promise_is_served_first.

    given_promise( iv_id       = c_secnd
                   iv_quantity = 6 ).

    " the promised line is at the back of the queue and gets its six anyway
    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = c_first
                  iv_quantity = 10
                  iv_priority = '01' ) )
        ( demand( iv_id       = c_secnd
                  iv_quantity = 10
                  iv_priority = '99' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_secnd )
      exp = CONV zif_allocation=>ty_quantity( 6 ) ).

  ENDMETHOD.

  METHOD the_rest_is_distributed.

    given_promise( iv_id       = c_secnd
                   iv_quantity = 6 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = c_first
                  iv_quantity = 10
                  iv_priority = '01' ) )
        ( demand( iv_id       = c_secnd
                  iv_quantity = 10
                  iv_priority = '99' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_first )
      exp = CONV zif_allocation=>ty_quantity( 4 )
      msg = 'what a promise did not take is still distributed by the rules' ).

  ENDMETHOD.

  METHOD more_than_the_line_is_capped.

    given_promise( iv_id       = c_first
                   iv_quantity = 50 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id       = c_first
                                        iv_quantity = 8
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_first )
      exp = CONV zif_allocation=>ty_quantity( 8 )
      msg = 'a promise about a line cannot be bigger than the line' ).

  ENDMETHOD.

  METHOD more_than_there_is_is_capped.

    given_promise( iv_id       = c_first
                   iv_quantity = 50 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 7
      it_demand    = VALUE #( ( demand( iv_id       = c_first
                                        iv_quantity = 50
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_first )
      exp = CONV zif_allocation=>ty_quantity( 7 )
      msg = 'a promise decides who gets the stock, not how much of it there is' ).

  ENDMETHOD.

  METHOD every_line_is_answered_once.

    given_promise( iv_id       = c_secnd
                   iv_quantity = 10 ).

    " the promise takes everything, so the rules answer a line asking for
    " nothing and the other line not at all
    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = c_first
                  iv_quantity = 10
                  iv_priority = '01' ) )
        ( demand( iv_id       = c_secnd
                  iv_quantity = 10
                  iv_priority = '99' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_answer )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_first )
      exp = CONV zif_allocation=>ty_quantity( 0 ) ).

  ENDMETHOD.

  METHOD what_was_asked_for_is_kept.

    given_promise( iv_id       = c_first
                   iv_quantity = 3 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 3
      it_demand    = VALUE #( ( demand( iv_id       = c_first
                                        iv_quantity = 10
                                        iv_priority = '01' ) ) ) ).

    READ TABLE lt_answer INTO DATA(ls_line) WITH KEY demand_id = c_first.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-requested
      exp = CONV zif_allocation=>ty_quantity( 10 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-shortfall
      exp = CONV zif_allocation=>ty_quantity( 7 )
      msg = 'the answer is about the order, not about what was promised of it' ).

  ENDMETHOD.

  METHOD a_promise_is_given_once.

    given_promise( iv_id       = c_first
                   iv_quantity = 6 ).

    " the engine walks the days of supply and asks once per day: a promise
    " handed over again every morning would hand over eighteen of a six
    mo_cut->allocate(
      iv_available = 4
      it_demand    = VALUE #( ( demand( iv_id       = c_first
                                        iv_quantity = 10
                                        iv_priority = '01' ) ) ) ).

    DATA(lt_later) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = c_first
                                        iv_quantity = 6
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_later
                          iv_id         = c_first )
      exp = CONV zif_allocation=>ty_quantity( 6 )
      msg = 'two of the promise were left, and the rest of the line competes as usual' ).

  ENDMETHOD.

  METHOD a_promise_can_run_out.

    " typed rather than worked out in the call: a date expression handed to a
    " parameter is not a date to the transpiler, see ANOMALIES.md
    DATA lv_yesterday TYPE d.

    lv_yesterday = sy-datum - 1.

    given_promise( iv_id       = c_secnd
                   iv_quantity = 6
                   iv_valid_to = lv_yesterday ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = c_first
                  iv_quantity = 10
                  iv_priority = '01' ) )
        ( demand( iv_id       = c_secnd
                  iv_quantity = 10
                  iv_priority = '99' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_secnd )
      exp = CONV zif_allocation=>ty_quantity( 0 )
      msg = 'a promise nobody removed goes on outranking the rules for ever' ).

  ENDMETHOD.

  METHOD a_promise_of_today_holds.

    given_promise( iv_id       = c_secnd
                   iv_quantity = 6
                   iv_valid_to = sy-datum ).

    " the last day it is kept is a day it is kept
    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = c_first
                  iv_quantity = 10
                  iv_priority = '01' ) )
        ( demand( iv_id       = c_secnd
                  iv_quantity = 10
                  iv_priority = '99' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = c_secnd )
      exp = CONV zif_allocation=>ty_quantity( 6 ) ).

  ENDMETHOD.

ENDCLASS.
