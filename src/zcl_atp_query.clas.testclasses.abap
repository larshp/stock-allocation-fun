"! Answers with a fixed timeline, whatever it is asked.
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


"! Refuses every plant it is asked about.
CLASS lcl_authority_refusing DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

ENDCLASS.


CLASS lcl_authority_refusing IMPLEMENTATION.

  METHOD zif_allocation_authority~check_plant.

    RAISE EXCEPTION NEW zcx_allocation(
      textid   = zcx_allocation=>not_authorised
      mv_werks = |{ iv_werks }| ).

  ENDMETHOD.

ENDCLASS.


"! Allows every plant it is asked about.
CLASS lcl_authority_allowing DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS get_plant
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mv_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_authority_allowing IMPLEMENTATION.

  METHOD get_plant.
    rv_werks = mv_werks.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.
    mv_werks = iv_werks.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_atp_query DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'ATP-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_authority TYPE REF TO lcl_authority_allowing.

    METHODS setup.

    "! On the shelf 10, another 5 on 1 March, another 20 on 10 March.
    METHODS query
      RETURNING
        VALUE(ro_query) TYPE REF TO zif_atp_query.

    METHODS promise
      IMPORTING
        iv_quantity       TYPE zif_allocation=>ty_quantity
        iv_by_date        TYPE d OPTIONAL
      RETURNING
        VALUE(rs_promise) TYPE zif_atp_query=>ty_promise
      RAISING
        zcx_allocation.

    METHODS what_is_there_is_promised_now FOR TESTING RAISING cx_static_check.
    METHODS a_receipt_carries_its_day FOR TESTING RAISING cx_static_check.
    METHODS the_last_day_is_the_answer FOR TESTING RAISING cx_static_check.
    METHODS more_than_there_is_is_partial FOR TESTING RAISING cx_static_check.
    METHODS a_date_cuts_the_timeline FOR TESTING RAISING cx_static_check.
    METHODS a_date_that_covers_it_is_full FOR TESTING RAISING cx_static_check.
    METHODS nothing_by_then_is_no_promise FOR TESTING RAISING cx_static_check.
    METHODS asking_for_nothing_is_nothing FOR TESTING RAISING cx_static_check.
    METHODS an_empty_plant_promises_none FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_checked FOR TESTING RAISING cx_static_check.
    METHODS a_refused_plant_raises FOR TESTING.
    METHODS shipping_time_moves_the_day FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_atp_query IMPLEMENTATION.

  METHOD setup.
    mo_authority = NEW lcl_authority_allowing( ).
  ENDMETHOD.

  METHOD query.

    ro_query = NEW zcl_atp_query(
      io_supply    = NEW lcl_supply_double( VALUE #(
        ( avail_date = '20260310' quantity = '20' )
        ( avail_date = '00000000' quantity = '10' )
        ( avail_date = '20260301' quantity = '5' ) ) )
      io_authority = mo_authority ).

  ENDMETHOD.

  METHOD promise.

    rs_promise = query( )->promise(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = iv_quantity
      iv_by_date  = iv_by_date ).

  ENDMETHOD.

  METHOD what_is_there_is_promised_now.

    DATA(ls_promise) = promise( '8' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-quantity
      exp = '8' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-complete
      exp = abap_true ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_promise-date
      msg = 'what is on the shelf can be promised for today' ).

  ENDMETHOD.

  METHOD a_receipt_carries_its_day.

    DATA(ls_promise) = promise( '13' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-quantity
      exp = '13' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-date
      exp = '20260301'
      msg = 'ten off the shelf and three of the five that land on the first' ).

  ENDMETHOD.

  METHOD the_last_day_is_the_answer.

    DATA(ls_promise) = promise( '30' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-complete
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-date
      exp = '20260310'
      msg = 'a promise is kept on the day the last of it arrives, not the first' ).

  ENDMETHOD.

  METHOD more_than_there_is_is_partial.

    DATA(ls_promise) = promise( '100' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-quantity
      exp = '35'
      msg = 'everything there is, and no more' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-complete
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-date
      exp = '20260310' ).

  ENDMETHOD.

  METHOD a_date_cuts_the_timeline.

    DATA(ls_promise) = promise(
      iv_quantity = '30'
      iv_by_date  = '20260305' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-quantity
      exp = '15'
      msg = 'the twenty landing on the tenth are no use to a customer wanting the fifth' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-complete
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-date
      exp = '20260301' ).

  ENDMETHOD.

  METHOD a_date_that_covers_it_is_full.

    DATA(ls_promise) = promise(
      iv_quantity = '12'
      iv_by_date  = '20260301' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-complete
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_promise-date
      exp = '20260301' ).

  ENDMETHOD.

  METHOD nothing_by_then_is_no_promise.

    DATA(lo_query) = CAST zif_atp_query( NEW zcl_atp_query(
      io_supply    = NEW lcl_supply_double( VALUE #(
        ( avail_date = '20260310' quantity = '20' ) ) )
      io_authority = mo_authority ) ).

    DATA(ls_promise) = lo_query->promise(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = '5'
      iv_by_date  = '20260301' ).

    cl_abap_unit_assert=>assert_initial(
      act = ls_promise
      msg = 'none, and no date: a day for goods nobody is offering says nothing' ).

  ENDMETHOD.

  METHOD asking_for_nothing_is_nothing.

    cl_abap_unit_assert=>assert_initial(
      act = promise( 0 )
      msg = 'a question about no quantity has no answer worth giving' ).

  ENDMETHOD.

  METHOD an_empty_plant_promises_none.

    DATA(lo_query) = CAST zif_atp_query( NEW zcl_atp_query(
      io_supply    = NEW lcl_supply_double( VALUE #( ) )
      io_authority = mo_authority ) ).

    cl_abap_unit_assert=>assert_initial( lo_query->promise(
      iv_matnr    = c_matnr
      iv_werks    = c_werks
      iv_quantity = '5' ) ).

  ENDMETHOD.

  METHOD the_plant_is_checked.

    promise( '1' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_authority->get_plant( )
      exp = c_werks
      msg = 'a promise is an answer about a plant, so the plant is checked' ).

  ENDMETHOD.

  METHOD shipping_time_moves_the_day.

    " two days to get the goods out of the door, so a promise for the third of
    " March may only count what is there on the first
    DATA(lo_query) = CAST zif_atp_query( NEW zcl_atp_query(
      io_supply    = NEW lcl_supply_double( VALUE #(
        ( avail_date = '20260302' quantity = '10' ) ) )
      io_authority = mo_authority
      iv_ship_days = 2 ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lo_query->promise(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = '5'
        iv_by_date  = '20260303' )
      msg = 'a promise the plant cannot ship in time is not a promise' ).

  ENDMETHOD.

  METHOD a_refused_plant_raises.

    DATA(lo_query) = CAST zif_atp_query( NEW zcl_atp_query(
      io_supply    = NEW lcl_supply_double( VALUE #(
        ( avail_date = '00000000' quantity = '10' ) ) )
      io_authority = NEW lcl_authority_refusing( ) ) ).

    TRY.
        lo_query->promise(
          iv_matnr    = c_matnr
          iv_werks    = c_werks
          iv_quantity = '5' ).
        cl_abap_unit_assert=>fail( 'a user who may not see the plant is told nothing' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
