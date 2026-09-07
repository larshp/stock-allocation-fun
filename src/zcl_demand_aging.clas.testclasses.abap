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
    rt_matnr = VALUE #( ( 'PASSED-THROUGH' ) ).
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_demand_aging DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'AGE-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9801'.
    CONSTANTS c_id    TYPE zif_allocation=>ty_demand_id VALUE 'AGE-DEMAND-01'.
    CONSTANTS c_week  TYPE i VALUE 7.

    METHODS teardown.

    METHODS given_run
      IMPORTING
        iv_days_ago  TYPE i
        iv_shortfall TYPE zif_allocation=>ty_quantity
        iv_id        TYPE zif_allocation=>ty_demand_id DEFAULT c_id.

    METHODS cut
      IMPORTING
        iv_days       TYPE i DEFAULT c_week
        iv_priority   TYPE zif_allocation=>ty_priority DEFAULT '50'
      RETURNING
        VALUE(ro_cut) TYPE REF TO zif_demand_reader.

    METHODS priority_of
      IMPORTING
        io_cut             TYPE REF TO zif_demand_reader
      RETURNING
        VALUE(rv_priority) TYPE zif_allocation=>ty_priority
      RAISING
        zcx_allocation.

    METHODS a_short_wait_changes_nothing FOR TESTING RAISING cx_static_check.
    METHODS a_long_wait_moves_up FOR TESTING RAISING cx_static_check.
    METHODS every_wait_moves_up_again FOR TESTING RAISING cx_static_check.
    METHODS nobody_passes_the_front FOR TESTING RAISING cx_static_check.
    METHODS a_line_served_starts_over FOR TESTING RAISING cx_static_check.
    METHODS switched_off_changes_nothing FOR TESTING RAISING cx_static_check.
    METHODS another_line_is_not_touched FOR TESTING RAISING cx_static_check.
    METHODS the_list_is_passed_through FOR TESTING.

ENDCLASS.


CLASS ltcl_demand_aging IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_run.

    DATA lt_row  TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_date TYPE d.
    DATA lv_when TYPE zstock_alloc_res-created_at.
    DATA lv_run  TYPE zstock_alloc_res-run_id.

    lv_date = sy-datum - iv_days_ago.
    CONVERT DATE lv_date TIME '120000'
      INTO TIME STAMP lv_when TIME ZONE 'UTC'.

    lv_run = |RUN-{ iv_days_ago }-{ iv_id }|.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = lv_run
        demand_id  = iv_id
        matnr      = c_matnr
        werks      = c_werks
        requested  = 100
        confirmed  = 100 - iv_shortfall
        shortfall  = iv_shortfall
        created_at = lv_when ) ).

    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD cut.

    ro_cut = NEW zcl_demand_aging(
      io_demand = NEW lcl_demand_double( VALUE #(
        ( demand_id = c_id
          matnr     = c_matnr
          werks     = c_werks
          quantity  = 100
          priority  = iv_priority ) ) )
      iv_days   = iv_days ).

  ENDMETHOD.

  METHOD priority_of.

    DATA(lt_demand) = io_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    READ TABLE lt_demand INTO DATA(ls_demand)
      WITH KEY demand_id = c_id.
    cl_abap_unit_assert=>assert_subrc( ).

    rv_priority = ls_demand-priority.

  ENDMETHOD.

  METHOD a_short_wait_changes_nothing.

    given_run(
      iv_days_ago  = 3
      iv_shortfall = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( ) )
      exp = CONV zif_allocation=>ty_priority( '50' )
      msg = 'a line short since Tuesday has not been waiting' ).

  ENDMETHOD.

  METHOD a_long_wait_moves_up.

    given_run(
      iv_days_ago  = 8
      iv_shortfall = 40 ).
    given_run(
      iv_days_ago  = 1
      iv_shortfall = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( ) )
      exp = CONV zif_allocation=>ty_priority( '49' )
      msg = 'a line short in every run for a week moves up a place' ).

  ENDMETHOD.

  METHOD every_wait_moves_up_again.

    given_run(
      iv_days_ago  = 22
      iv_shortfall = 40 ).
    given_run(
      iv_days_ago  = 8
      iv_shortfall = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( ) )
      exp = CONV zif_allocation=>ty_priority( '47' )
      msg = 'three weeks of waiting is three places, not one' ).

  ENDMETHOD.

  METHOD nobody_passes_the_front.

    given_run(
      iv_days_ago  = 700
      iv_shortfall = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( iv_priority = '05' ) )
      exp = zcl_demand_aging=>c_first
      msg = 'the front of the queue is as far forward as there is' ).

  ENDMETHOD.

  METHOD a_line_served_starts_over.

    given_run(
      iv_days_ago  = 30
      iv_shortfall = 40 ).
    given_run(
      iv_days_ago  = 20
      iv_shortfall = 0 ).
    given_run(
      iv_days_ago  = 3
      iv_shortfall = 40 ).

    " the run that served it in full ended that wait: what the line has been
    " waiting is three days, not a month
    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( ) )
      exp = CONV zif_allocation=>ty_priority( '50' )
      msg = 'a wait that was answered is over' ).

  ENDMETHOD.

  METHOD switched_off_changes_nothing.

    given_run(
      iv_days_ago  = 700
      iv_shortfall = 40 ).

    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( iv_days = zcl_demand_aging=>c_never ) )
      exp = CONV zif_allocation=>ty_priority( '50' )
      msg = 'a plant that has not asked for this gets the order it typed' ).

  ENDMETHOD.

  METHOD another_line_is_not_touched.

    given_run(
      iv_days_ago  = 700
      iv_shortfall = 40
      iv_id        = 'AGE-DEMAND-02' ).

    cl_abap_unit_assert=>assert_equals(
      act = priority_of( cut( ) )
      exp = CONV zif_allocation=>ty_priority( '50' )
      msg = 'somebody else having waited is not this line waiting' ).

  ENDMETHOD.

  METHOD the_list_is_passed_through.

    DATA(lt_matnr) = cut( )->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_matnr )
      exp = 1
      msg = 'which materials a run covers is not changed by this' ).

  ENDMETHOD.

ENDCLASS.
