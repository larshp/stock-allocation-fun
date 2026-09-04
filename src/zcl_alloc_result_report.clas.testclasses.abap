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


CLASS ltcl_result_report DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr   TYPE mard-matnr VALUE 'RESULT-DISP-01'.
    CONSTANTS c_matnr_2 TYPE mard-matnr VALUE 'RESULT-DISP-02'.
    " a plant of its own: the display reads a whole plant, so sharing 1000
    " with the other test classes would make this depend on their fixtures
    CONSTANTS c_werks   TYPE mard-werks VALUE '9001'.

    DATA mo_cut TYPE REF TO zcl_alloc_result_report.

    METHODS setup.
    METHODS teardown.

    "! A recorded run of one demand line.
    METHODS given_run
      IMPORTING
        iv_run_id     TYPE zstock_alloc_res-run_id
        iv_matnr      TYPE mard-matnr DEFAULT c_matnr
        iv_demand_id  TYPE zstock_alloc_res-demand_id
        iv_requested  TYPE zstock_alloc_res-requested
        iv_confirmed  TYPE zstock_alloc_res-confirmed
        iv_created_at TYPE zstock_alloc_res-created_at
        iv_rsnum      TYPE zstock_alloc_res-reservation DEFAULT '0000004711'
        iv_avail_date TYPE zstock_alloc_res-avail_date OPTIONAL
        iv_customer   TYPE zstock_alloc_res-customer DEFAULT '0000050001'.

    METHODS lines_of
      IMPORTING
        iv_matnr       TYPE mard-matnr OPTIONAL
        iv_short_only  TYPE abap_bool DEFAULT abap_false
        iv_kunnr       TYPE vbak-kunnr OPTIONAL
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_result_report=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS recorded_lines_are_shown FOR TESTING RAISING cx_static_check.
    METHODS only_the_newest_run_counts FOR TESTING RAISING cx_static_check.
    METHODS one_block_per_material FOR TESTING RAISING cx_static_check.
    METHODS totals_add_the_lines_up FOR TESTING RAISING cx_static_check.
    METHODS short_only_drops_the_rest FOR TESTING RAISING cx_static_check.
    METHODS one_material_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS the_customer_is_shown FOR TESTING RAISING cx_static_check.
    METHODS one_customer_can_be_asked FOR TESTING RAISING cx_static_check.
    METHODS nothing_recorded_says_so FOR TESTING RAISING cx_static_check.
    METHODS refused_plant_shows_nothing FOR TESTING.
    METHODS stock_on_hand_reads_as_now FOR TESTING RAISING cx_static_check.
    METHODS a_dated_line_says_the_day FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_result_report IMPLEMENTATION.

  METHOD setup.

    mo_cut = NEW zcl_alloc_result_report(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW lcl_authority_double( ) ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_res WHERE matnr IN ( @c_matnr, @c_matnr_2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_run.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_res WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt       = sy-mandt
        run_id      = iv_run_id
        demand_id   = iv_demand_id
        matnr       = iv_matnr
        werks       = c_werks
        req_date    = '20260201'
        avail_date  = iv_avail_date
        requested   = iv_requested
        confirmed   = iv_confirmed
        shortfall   = iv_requested - iv_confirmed
        reservation = iv_rsnum
        customer    = iv_customer
        created_by  = sy-uname
        created_at  = iv_created_at ) ).

    INSERT zstock_alloc_res FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'recorded run fixture could not be inserted' ).

  ENDMETHOD.

  METHOD lines_of.

    rt_line = mo_cut->run(
      iv_werks      = c_werks
      iv_matnr      = iv_matnr
      iv_short_only = iv_short_only
      iv_kunnr      = iv_kunnr ).

  ENDMETHOD.

  METHOD the_customer_is_shown.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000021'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000'
      iv_customer   = '0000050009' ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*0000050009*'
      msg = 'reading an old run should not mean reading the order again' ).

  ENDMETHOD.

  METHOD one_customer_can_be_asked.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000022'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000'
      iv_customer   = '0000050009' ).
    given_run(
      iv_run_id     = 'DISPLAY-RUN-000023'
      iv_matnr      = c_matnr_2
      iv_demand_id  = 'D2'
      iv_requested  = '5'
      iv_confirmed  = '5'
      iv_created_at = '20260210120000'
      iv_customer   = '0000050010' ).

    DATA(lt_line) = lines_of( iv_kunnr = '0000050009' ).

    LOOP AT lt_line INTO DATA(lv_line).
      cl_abap_unit_assert=>assert_false(
        act = xsdbool( lv_line CS '0000050010' )
        msg = 'somebody about to ring a customer wants that customer only' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD recorded_lines_are_shown.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000001'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000' ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = |*{ c_werks }*| ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '*DISPLAY-RUN-000001*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*D1*10.000*4.000*6.000*' ).

  ENDMETHOD.

  METHOD stock_on_hand_reads_as_now.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000010'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '10'
      iv_created_at = '20260210120000' ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*D1*10.000*10.000*0.000*now*'
      msg = 'a line off the shelf is there now, and should say so' ).

  ENDMETHOD.

  METHOD a_dated_line_says_the_day.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000011'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '10'
      iv_created_at = '20260210120000'
      iv_avail_date = '20260301' ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*D1*10.000*10.000*0.000*2026-03-01*'
      msg = 'a line waiting for a receipt says the day it is covered' ).

  ENDMETHOD.

  METHOD only_the_newest_run_counts.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000002'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000' ).

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000003'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '9'
      iv_created_at = '20260211120000' ).

    DATA(lt_line) = lines_of( ).

    LOOP AT lt_line INTO DATA(lv_line).
      cl_abap_unit_assert=>assert_false(
        act = xsdbool( lv_line CS 'DISPLAY-RUN-000002' )
        msg = 'a material is allocated again and again, only the last answer stands' ).
    ENDLOOP.

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*D1*10.000*9.000*1.000*' ).

  ENDMETHOD.

  METHOD one_block_per_material.

    DATA lv_blocks TYPE i.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000004'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000' ).

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000005'
      iv_matnr      = c_matnr_2
      iv_demand_id  = 'D2'
      iv_requested  = '5'
      iv_confirmed  = '5'
      iv_created_at = '20260210120000' ).

    DATA(lt_line) = lines_of( ).

    " CS ignores case and trailing blanks, so the material has to be named
    LOOP AT lt_line INTO DATA(lv_line).
      IF lv_line CS 'Material RESULT-DISP-0'.
        lv_blocks = lv_blocks + 1.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lv_blocks
      exp = 2
      msg = 'each material gets its own block, with the run that decided it' ).

  ENDMETHOD.

  METHOD totals_add_the_lines_up.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000006'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000' ).

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000006'
      iv_demand_id  = 'D2'
      iv_requested  = '5.5'
      iv_confirmed  = '5.5'
      iv_created_at = '20260210120000' ).

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ lines( lt_line ) ]
      exp = '*Total*15.500*9.500*6.000*' ).

  ENDMETHOD.

  METHOD short_only_drops_the_rest.

    DATA lv_short_lines TYPE i.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000007'
      iv_demand_id  = 'SERVED'
      iv_requested  = '5'
      iv_confirmed  = '5'
      iv_created_at = '20260210120000' ).

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000007'
      iv_demand_id  = 'PARTLY'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000' ).

    DATA(lt_line) = lines_of( iv_short_only = abap_true ).

    LOOP AT lt_line INTO DATA(lv_line).
      cl_abap_unit_assert=>assert_false(
        act = xsdbool( lv_line CS 'SERVED' )
        msg = 'a line that got everything is not what a shortfall list is for' ).
    ENDLOOP.

    " not 'SHORT': CS ignores case, and the column heading is Shortfall
    LOOP AT lt_line INTO DATA(lv_kept).
      IF lv_kept CS 'PARTLY'.
        lv_short_lines = lv_short_lines + 1.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals(
      act = lv_short_lines
      exp = 1
      msg = 'the line that is short is the one that stays' ).

  ENDMETHOD.

  METHOD one_material_can_be_asked.

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000008'
      iv_demand_id  = 'D1'
      iv_requested  = '10'
      iv_confirmed  = '4'
      iv_created_at = '20260210120000' ).

    given_run(
      iv_run_id     = 'DISPLAY-RUN-000009'
      iv_matnr      = c_matnr_2
      iv_demand_id  = 'D2'
      iv_requested  = '5'
      iv_confirmed  = '5'
      iv_created_at = '20260210120000' ).

    DATA(lt_line) = lines_of( iv_matnr = c_matnr_2 ).

    LOOP AT lt_line INTO DATA(lv_line).
      cl_abap_unit_assert=>assert_false( xsdbool( lv_line CS c_matnr ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD nothing_recorded_says_so.

    DATA(lt_line) = lines_of( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 2
      msg = 'an empty plant is a sentence, not an empty screen' ).

  ENDMETHOD.

  METHOD refused_plant_shows_nothing.

    DATA(lo_cut) = NEW zcl_alloc_result_report(
      io_store     = NEW zcl_allocation_store( )
      io_authority = NEW lcl_authority_double( abap_true ) ).

    TRY.
        lo_cut->run( c_werks ).
        cl_abap_unit_assert=>fail( 'a plant the user may not see must not be displayed' ).
      CATCH zcx_allocation.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
