CLASS lcl_store_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_store.

    METHODS constructor
      IMPORTING
        it_recorded TYPE zif_allocation_store=>ty_recorded_tab.

  PRIVATE SECTION.
    DATA mt_recorded TYPE zif_allocation_store=>ty_recorded_tab.

ENDCLASS.


CLASS lcl_store_double IMPLEMENTATION.

  METHOD constructor.
    mt_recorded = it_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~latest_per_material.
    rt_recorded = mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~save.
    " the list writes nothing
    CLEAR mt_recorded.
  ENDMETHOD.

  METHOD zif_allocation_store~record_reservation.
    CLEAR mt_recorded.
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

  METHOD zif_allocation_store~delete_run.
    CLEAR mt_recorded.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mv_refuse TYPE abap_bool.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_promise_list DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9261'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'PROM-MAT-01'.
    CONSTANTS c_id    TYPE zstock_alloc_fix-demand_id VALUE 'PROM-D1'.

    METHODS teardown.

    METHODS given_promise
      IMPORTING
        iv_quantity TYPE zif_allocation=>ty_quantity
        iv_valid_to TYPE d DEFAULT '00000000'
        iv_id       TYPE zstock_alloc_fix-demand_id DEFAULT c_id.

    METHODS lines_of
      IMPORTING
        it_recorded    TYPE zif_allocation_store=>ty_recorded_tab OPTIONAL
        iv_all         TYPE abap_bool DEFAULT abap_false
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_promise_list=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_promise_list=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS a_plant_without_promises FOR TESTING RAISING cx_static_check.
    METHODS a_promise_is_listed FOR TESTING RAISING cx_static_check.
    METHODS what_it_got_is_shown FOR TESTING RAISING cx_static_check.
    METHODS one_that_ran_out_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS but_can_be_asked_for FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_promise_list IMPLEMENTATION.

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
        reason    = 'Sales director, trade fair' ) ).

    INSERT zstock_alloc_fix FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD lines_of.

    rt_line = NEW zcl_alloc_promise_list(
      io_store     = NEW lcl_store_double( it_recorded )
      io_authority = NEW lcl_authority_double( iv_refuse ) )->run(
        iv_werks = c_werks
        iv_all   = iv_all ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD a_plant_without_promises.

    cl_abap_unit_assert=>assert_true( says(
      it_line = lines_of( )
      iv_text = `Nothing is promised here` ) ).

  ENDMETHOD.

  METHOD a_promise_is_listed.

    given_promise( 40 ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `40.000` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `no end` ) ).
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `Sales director` )
      msg = 'a promise nobody signed is one nobody can question' ).

  ENDMETHOD.

  METHOD what_it_got_is_shown.

    given_promise( 40 ).

    DATA(lt_line) = lines_of( it_recorded = VALUE #(
      ( matnr     = c_matnr
        run_id    = 'R1'
        demand_id = c_id
        requested = 40
        confirmed = 25 ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `25.000` )
      msg = 'a promise that was not kept is the one worth looking at' ).

  ENDMETHOD.

  METHOD one_that_ran_out_is_left_out.

    DATA lv_yesterday TYPE d.

    lv_yesterday = sy-datum - 1.

    given_promise( iv_quantity = 40
                   iv_valid_to = lv_yesterday ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_false( says( it_line = lt_line
                                             iv_text = `40.000` ) ).
    cl_abap_unit_assert=>assert_true( says(
      it_line = lt_line
      iv_text = `1 promise(s) have run out` ) ).

  ENDMETHOD.

  METHOD but_can_be_asked_for.

    DATA lv_yesterday TYPE d.

    lv_yesterday = sy-datum - 1.

    given_promise( iv_quantity = 40
                   iv_valid_to = lv_yesterday ).

    " a promise that has run out is still a row somebody has to remove, and
    " the only way to find it is to ask for it
    cl_abap_unit_assert=>assert_true( says(
      it_line = lines_of( iv_all = abap_true )
      iv_text = `40.000` ) ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        lines_of( iv_refuse = abap_true ).
        cl_abap_unit_assert=>fail( 'what a plant has promised is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
