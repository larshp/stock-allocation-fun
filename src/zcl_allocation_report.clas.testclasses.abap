CLASS lcl_service_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    METHODS constructor
      IMPORTING
        is_run       TYPE zif_allocation_service=>ty_run OPTIONAL
        iv_fails_for TYPE mard-matnr OPTIONAL.

  PRIVATE SECTION.
    DATA ms_run       TYPE zif_allocation_service=>ty_run.
    DATA mv_fails_for TYPE mard-matnr.

ENDCLASS.


CLASS lcl_service_double IMPLEMENTATION.

  METHOD constructor.
    ms_run       = is_run.
    mv_fails_for = iv_fails_for.
  ENDMETHOD.

  METHOD zif_allocation_service~simulate.
    rs_run = zif_allocation_service~run(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    CLEAR rs_run-run_id.
    CLEAR rs_run-reservation.
  ENDMETHOD.

  METHOD zif_allocation_service~run.
    IF iv_matnr = mv_fails_for.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = `stock is blocked` ).
    ENDIF.
    rs_run = ms_run.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_matnr TYPE zif_demand_reader=>ty_matnr_tab.

  PRIVATE SECTION.
    DATA mt_matnr TYPE zif_demand_reader=>ty_matnr_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_matnr = it_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    rt_matnr = mt_matnr.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    " the report never reads demand itself, the service does
    CLEAR rt_demand.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_allocation_report DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'REPORT-TEST-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS report_of
      IMPORTING
        is_run         TYPE zif_allocation_service=>ty_run
        it_matnr       TYPE zif_demand_reader=>ty_matnr_tab
        iv_fails_for   TYPE mard-matnr OPTIONAL
        iv_simulate    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_allocation_report=>ty_line_tab.

    METHODS one_material_run FOR TESTING.
    METHODS heading_names_the_run FOR TESTING.
    METHODS one_line_per_demand FOR TESTING.
    METHODS quantities_are_totalled FOR TESTING.
    METHODS columns_line_up FOR TESTING.
    METHODS every_material_gets_a_block FOR TESTING.
    METHODS rejected_material_shows_reason FOR TESTING.
    METHODS footer_counts_the_failures FOR TESTING.
    METHODS simulation_is_labelled FOR TESTING.
    METHODS the_day_it_is_there_is_shown FOR TESTING.
    METHODS why_a_line_is_short_is_shown FOR TESTING.
    METHODS the_settings_head_the_list FOR TESTING.

ENDCLASS.


CLASS ltcl_allocation_report IMPLEMENTATION.

  METHOD report_of.

    DATA lo_service TYPE REF TO zif_allocation_service.
    DATA lo_demand  TYPE REF TO zif_demand_reader.

    lo_service = NEW lcl_service_double(
      is_run       = is_run
      iv_fails_for = iv_fails_for ).
    lo_demand  = NEW lcl_demand_double( it_matnr ).

    rt_line = NEW zcl_allocation_report(
      NEW zcl_allocation_mass_run(
        io_service = lo_service
        io_demand  = lo_demand
        io_log     = NEW zcl_alloc_log_none( ) ) )->run(
          iv_werks    = c_werks
          iv_simulate = iv_simulate ).

  ENDMETHOD.

  METHOD one_material_run.

    DATA(lt_line) = report_of(
      is_run   = VALUE #( run_id = 'RUN-0001' )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = |*{ c_werks }*| ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = |*{ c_matnr }*| ).

  ENDMETHOD.

  METHOD the_settings_head_the_list.

    DATA(lo_report) = NEW zcl_allocation_report(
      NEW zcl_allocation_mass_run(
        io_service  = NEW lcl_service_double( )
        io_demand   = NEW lcl_demand_double( VALUE #( ) )
        io_log      = NEW zcl_alloc_log_none( )
        iv_settings = `fair share, horizon 30 day(s)` ) ).

    DATA(lt_line) = lo_report->run( c_werks ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*fair share, horizon 30 day(s)*'
      msg = 'a spool that does not say what the run was set to do is a guess' ).

  ENDMETHOD.

  METHOD why_a_line_is_short_is_shown.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6'
            reason = zif_allocation=>c_reason-customer_cap )
          ( demand_id = 'D2' requested = '5' confirmed = '5' shortfall = 0 ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*D1*customer share*'
      msg = 'short on its own tells a planner nothing about what to do next' ).
    cl_abap_unit_assert=>assert_char_np(
      act = lt_line[ 8 ]
      exp = '*customer share*'
      msg = 'a line that got everything has nothing to explain' ).

  ENDMETHOD.

  METHOD the_day_it_is_there_is_shown.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0
            avail_date = '20260301' )
          ( demand_id = 'D2' requested = '5' confirmed = '5' shortfall = 0 )
          ( demand_id = 'D3' requested = '5' confirmed = 0 shortfall = '5' ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = '*D1*2026-03-01*'
      msg = 'a line waiting for a receipt says the day it is covered' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = '*D2*now*'
      msg = 'a line off the shelf is there now' ).
    cl_abap_unit_assert=>assert_false(
      act = xsdbool( lt_line[ 9 ] CS 'now' )
      msg = 'a line that got nothing is there on no day at all' ).

  ENDMETHOD.

  METHOD heading_names_the_run.

    DATA(lt_line) = report_of(
      is_run   = VALUE #( run_id = 'RUN-0001' reservation = '0000004711' )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = '*RUN-0001*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 5 ]
      exp = '*0000004711*' ).

  ENDMETHOD.

  METHOD one_line_per_demand.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
          ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = 'D1*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 8 ]
      exp = 'D2*' ).

  ENDMETHOD.

  METHOD quantities_are_totalled.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10'  confirmed = '4'   shortfall = '6' )
          ( demand_id = 'D2' requested = '5.5' confirmed = '5.5' shortfall = 0 ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 9 ]
      exp = 'Total*15.500*9.500*6.000*' ).

  ENDMETHOD.

  METHOD columns_line_up.

    DATA(lt_line) = report_of(
      is_run   = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = '00000047110000100001' requested = '1000' confirmed = '1' shortfall = '999' ) ) )
      it_matnr = VALUE #( ( c_matnr ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = strlen( lt_line[ 6 ] )
      exp = strlen( lt_line[ 7 ] )
      msg = 'the column heading and the rows must be the same width' ).

  ENDMETHOD.

  METHOD every_material_gets_a_block.

    DATA(lt_line) = report_of(
      is_run   = VALUE #( run_id = 'RUN-0001' )
      it_matnr = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*MAT-1*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 9 ]
      exp = '*MAT-2*' ).

  ENDMETHOD.

  METHOD rejected_material_shows_reason.

    DATA(lt_line) = report_of(
      is_run       = VALUE #( run_id = 'RUN-0001' )
      it_matnr     = VALUE #( ( 'MAT-1' ) )
      iv_fails_for = 'MAT-1' ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 4 ]
      exp = 'Allocation failed:*stock is blocked*'
      msg = 'the user must be told why a material got nothing' ).

  ENDMETHOD.

  METHOD simulation_is_labelled.

    DATA(lt_line) = report_of(
      is_run      = VALUE #(
        run_id     = 'RUN-0001'
        allocation = VALUE #(
          ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' ) ) )
      it_matnr    = VALUE #( ( c_matnr ) )
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = 'Simulation*'
      msg = 'a reader must not mistake a test run for a real one' ).
    LOOP AT lt_line INTO DATA(lv_line).
      cl_abap_unit_assert=>assert_char_np(
        act = lv_line
        exp = '*RUN-0001*'
        msg = 'a simulation has no run id, nothing was recorded' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD footer_counts_the_failures.

    DATA(lt_line) = report_of(
      is_run       = VALUE #( run_id = 'RUN-0001' )
      it_matnr     = VALUE #( ( 'MAT-1' ) ( 'MAT-2' ) ( 'MAT-3' ) )
      iv_fails_for = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_line[ lines( lt_line ) ]
      exp = `3 materials, 1 failed` ).

  ENDMETHOD.

ENDCLASS.
