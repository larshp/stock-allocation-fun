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


CLASS ltcl_alloc_history DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9501'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'HIST-MAT-01'.
    CONSTANTS c_vbeln TYPE vbap-vbeln VALUE '0000090001'.
    CONSTANTS c_other TYPE vbap-vbeln VALUE '0000090002'.
    CONSTANTS c_posnr TYPE vbap-posnr VALUE '000010'.
    CONSTANTS c_item2 TYPE vbap-posnr VALUE '000020'.

    METHODS teardown.

    METHODS given_run
      IMPORTING
        iv_days_ago  TYPE i
        iv_confirmed TYPE zif_allocation=>ty_quantity
        iv_vbeln     TYPE vbap-vbeln DEFAULT c_vbeln
        iv_posnr     TYPE vbap-posnr DEFAULT c_posnr
        iv_reason    TYPE zif_allocation=>ty_reason DEFAULT zif_allocation=>c_reason-no_stock.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_history=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS history
      IMPORTING
        iv_posnr       TYPE vbap-posnr OPTIONAL
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_history=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS an_order_nobody_ran_says_so FOR TESTING RAISING cx_static_check.
    METHODS every_run_is_a_row FOR TESTING RAISING cx_static_check.
    METHODS the_reason_is_in_words FOR TESTING RAISING cx_static_check.
    METHODS an_unbroken_wait_is_counted FOR TESTING RAISING cx_static_check.
    METHODS a_run_that_served_ends_it FOR TESTING RAISING cx_static_check.
    METHODS another_order_is_not_shown FOR TESTING RAISING cx_static_check.
    METHODS one_item_can_be_asked_for FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_history IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_run.

    DATA lt_row     TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_date    TYPE d.
    DATA lv_when    TYPE zstock_alloc_res-created_at.
    DATA lv_id      TYPE zif_allocation=>ty_demand_id.
    DATA lv_short   TYPE zif_allocation=>ty_quantity.
    DATA lv_reason  TYPE zif_allocation=>ty_reason.

    lv_date = sy-datum - iv_days_ago.
    CONVERT DATE lv_date TIME '120000'
      INTO TIME STAMP lv_when TIME ZONE 'UTC'.

    " the demand id of a sales order line, as ZCL_SO_DEMAND_READER builds it
    lv_id+0(10) = iv_vbeln.
    lv_id+10(6) = iv_posnr.
    lv_id+16(4) = '0001'.

    lv_short = 100 - iv_confirmed.
    IF lv_short > 0.
      lv_reason = iv_reason.
    ENDIF.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = |RUN-{ iv_days_ago }-{ iv_vbeln }-{ iv_posnr }|
        demand_id  = lv_id
        matnr      = c_matnr
        werks      = c_werks
        requested  = 100
        confirmed  = iv_confirmed
        shortfall  = lv_short
        reason     = lv_reason
        created_at = lv_when ) ).

    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD history.

    rt_line = NEW zcl_alloc_history( NEW lcl_authority_double( iv_refuse ) )->run(
      iv_werks = c_werks
      iv_vbeln = c_vbeln
      iv_posnr = iv_posnr ).

  ENDMETHOD.

  METHOD an_order_nobody_ran_says_so.

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = history( )
                  iv_text = `No run has ever decided anything` )
      msg = 'an order no run has seen is not an empty page' ).

  ENDMETHOD.

  METHOD every_run_is_a_row.

    given_run(
      iv_days_ago  = 14
      iv_confirmed = 20 ).
    given_run(
      iv_days_ago  = 7
      iv_confirmed = 30 ).
    given_run(
      iv_days_ago  = 1
      iv_confirmed = 40 ).

    DATA(lt_line) = history( ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `20.000` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `30.000` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `40.000` ) ).

  ENDMETHOD.

  METHOD the_reason_is_in_words.

    given_run(
      iv_days_ago  = 2
      iv_confirmed = 10
      iv_reason    = zif_allocation=>c_reason-quota ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = history( )
                  iv_text = `customer quota` )
      msg = 'the same wording the other lists use, because it is the same reason' ).

  ENDMETHOD.

  METHOD an_unbroken_wait_is_counted.

    given_run(
      iv_days_ago  = 21
      iv_confirmed = 0 ).
    given_run(
      iv_days_ago  = 14
      iv_confirmed = 10 ).
    given_run(
      iv_days_ago  = 7
      iv_confirmed = 20 ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = history( )
                  iv_text = `Short in the last 3 of 3 run(s)` )
      msg = 'what a customer is asking is how long this has been going on' ).

  ENDMETHOD.

  METHOD a_run_that_served_ends_it.

    given_run(
      iv_days_ago  = 21
      iv_confirmed = 0 ).
    given_run(
      iv_days_ago  = 14
      iv_confirmed = 100 ).
    given_run(
      iv_days_ago  = 7
      iv_confirmed = 60 ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = history( )
                  iv_text = `Short in the last 1 of 3 run(s)` )
      msg = 'a wait that was answered is over, as it is for the escalation' ).

  ENDMETHOD.

  METHOD another_order_is_not_shown.

    given_run(
      iv_days_ago  = 3
      iv_confirmed = 10
      iv_vbeln     = c_other ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = history( )
                  iv_text = `No run has ever decided anything` )
      msg = 'somebody else''s order is somebody else''s business' ).

  ENDMETHOD.

  METHOD one_item_can_be_asked_for.

    given_run(
      iv_days_ago  = 3
      iv_confirmed = 10 ).
    given_run(
      iv_days_ago  = 3
      iv_confirmed = 90
      iv_posnr     = c_item2 ).

    DATA(lt_line) = history( iv_posnr = c_item2 ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `90.000` ) ).
    cl_abap_unit_assert=>assert_false( says( it_line = lt_line
                                             iv_text = `10.000` ) ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        history( iv_refuse = abap_true ).
        cl_abap_unit_assert=>fail( 'what a plant decided is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
