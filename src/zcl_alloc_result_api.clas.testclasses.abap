CLASS ltcl_alloc_result_api DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9281'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'API-MAT-01'.
    CONSTANTS c_vbeln TYPE vbap-vbeln VALUE '0000092001'.
    CONSTANTS c_other TYPE vbap-vbeln VALUE '0000092002'.
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

    METHODS an_order_nobody_ran_is_empty FOR TESTING.
    METHODS the_newest_run_is_the_answer FOR TESTING.
    METHODS the_reason_is_in_words FOR TESTING.
    METHODS one_item_can_be_asked_for FOR TESTING.
    METHODS another_order_is_not_answered FOR TESTING.
    METHODS a_transfer_can_be_asked_for FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_result_api IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_run.

    DATA lt_row    TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_date   TYPE d.
    DATA lv_when   TYPE zstock_alloc_res-created_at.
    DATA lv_id     TYPE zif_allocation=>ty_demand_id.
    DATA lv_short  TYPE zif_allocation=>ty_quantity.
    DATA lv_reason TYPE zif_allocation=>ty_reason.

    lv_date = sy-datum - iv_days_ago.
    CONVERT DATE lv_date TIME '120000'
      INTO TIME STAMP lv_when TIME ZONE 'UTC'.

    lv_id+0(10) = iv_vbeln.
    lv_id+10(6) = iv_posnr.
    lv_id+16(4) = '0001'.

    lv_short = 100 - iv_confirmed.
    IF lv_short > 0.
      lv_reason = iv_reason.
    ENDIF.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = |API-{ iv_days_ago }-{ iv_vbeln }-{ iv_posnr }|
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

  METHOD an_order_nobody_ran_is_empty.

    DATA(ls_answer) = zcl_alloc_result_api=>result(
      iv_werks = c_werks
      iv_vbeln = c_vbeln ).

    cl_abap_unit_assert=>assert_initial( ls_answer-line ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_answer-message
      msg = 'an order no run has seen is an empty answer, not an error' ).

  ENDMETHOD.

  METHOD the_newest_run_is_the_answer.

    given_run(
      iv_days_ago  = 8
      iv_confirmed = 20 ).
    given_run(
      iv_days_ago  = 1
      iv_confirmed = 60 ).

    DATA(ls_answer) = zcl_alloc_result_api=>result(
      iv_werks = c_werks
      iv_vbeln = c_vbeln ).

    " a re-cut replaces what the run before it decided, so what stands is the
    " newest and there is one line per schedule line, not one per run
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_answer-line )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-line[ 1 ]-confirmed
      exp = CONV zif_allocation=>ty_quantity( 60 ) ).

  ENDMETHOD.

  METHOD the_reason_is_in_words.

    given_run(
      iv_days_ago  = 1
      iv_confirmed = 10
      iv_reason    = zif_allocation=>c_reason-supply_late ).

    DATA(ls_answer) = zcl_alloc_result_api=>result(
      iv_werks = c_werks
      iv_vbeln = c_vbeln ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-line[ 1 ]-reason_text
      exp = `stock comes too late`
      msg = 'a caller outside ABAP cannot look a one letter code up anywhere' ).

  ENDMETHOD.

  METHOD one_item_can_be_asked_for.

    given_run(
      iv_days_ago  = 1
      iv_confirmed = 10 ).
    given_run(
      iv_days_ago  = 1
      iv_confirmed = 90
      iv_posnr     = c_item2 ).

    DATA(ls_answer) = zcl_alloc_result_api=>result(
      iv_werks = c_werks
      iv_vbeln = c_vbeln
      iv_posnr = c_item2 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_answer-line )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-line[ 1 ]-confirmed
      exp = CONV zif_allocation=>ty_quantity( 90 ) ).

  ENDMETHOD.

  METHOD another_order_is_not_answered.

    given_run(
      iv_days_ago  = 1
      iv_confirmed = 10
      iv_vbeln     = c_other ).

    DATA(ls_answer) = zcl_alloc_result_api=>result(
      iv_werks = c_werks
      iv_vbeln = c_vbeln ).

    cl_abap_unit_assert=>assert_initial(
      act = ls_answer-line
      msg = 'somebody else''s order is somebody else''s business' ).

  ENDMETHOD.

  METHOD a_transfer_can_be_asked_for.

    DATA lt_row  TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.
    DATA lv_id   TYPE zif_allocation=>ty_demand_id.
    DATA lv_when TYPE zstock_alloc_res-created_at.

    lv_when = zcl_alloc_clock=>stamp_of(
      iv_date = sy-datum
      iv_time = '120000' ).

    lv_id+0(1)  = zcl_sto_demand_reader=>c_source_marker.
    lv_id+1(10) = '4500009999'.
    lv_id+11(5) = '00010'.
    lv_id+16(4) = '0001'.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        run_id     = 'API-STO-1'
        demand_id  = lv_id
        matnr      = c_matnr
        werks      = c_werks
        requested  = 100
        confirmed  = 70
        shortfall  = 30
        created_at = lv_when ) ).
    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(ls_answer) = zcl_alloc_result_api=>result(
      iv_werks = c_werks
      iv_ebeln = '4500009999' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_answer-line )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_answer-line[ 1 ]-confirmed
      exp = CONV zif_allocation=>ty_quantity( 70 )
      msg = 'the plant on the other end of a transfer is a caller like any other' ).

  ENDMETHOD.

ENDCLASS.
