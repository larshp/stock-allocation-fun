CLASS lcl_service_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_service.

    METHODS constructor
      IMPORTING
        is_run    TYPE zif_allocation_service=>ty_run OPTIONAL
        iv_reject TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA ms_run    TYPE zif_allocation_service=>ty_run.
    DATA mv_reject TYPE abap_bool.

ENDCLASS.


CLASS lcl_service_double IMPLEMENTATION.

  METHOD constructor.
    ms_run    = is_run.
    mv_reject = iv_reject.
  ENDMETHOD.

  METHOD zif_allocation_service~run.
    IF mv_reject = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>reserve_failed
        mv_message = `stock is blocked` ).
    ENDIF.
    rs_run = ms_run.
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
      RETURNING
        VALUE(rt_line) TYPE zcl_allocation_report=>ty_line_tab.

    METHODS heading_names_the_run FOR TESTING.
    METHODS one_line_per_demand FOR TESTING.
    METHODS quantities_are_totalled FOR TESTING.
    METHODS columns_line_up FOR TESTING.
    METHODS rejected_run_is_reported FOR TESTING.

ENDCLASS.


CLASS ltcl_allocation_report IMPLEMENTATION.

  METHOD report_of.

    DATA lo_service TYPE REF TO zif_allocation_service.

    lo_service = NEW lcl_service_double( is_run = is_run ).

    rt_line = NEW zcl_allocation_report( lo_service )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD heading_names_the_run.

    DATA(lt_line) = report_of( VALUE #(
      run_id      = 'RUN-0001'
      reservation = '0000004711' ) ).

    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = |*{ c_matnr }*| ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 2 ]
      exp = '*RUN-0001*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 3 ]
      exp = '*0000004711*' ).

  ENDMETHOD.

  METHOD one_line_per_demand.

    DATA(lt_line) = report_of( VALUE #(
      run_id     = 'RUN-0001'
      allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) ) ).

    " 3 heading lines, a blank, a column heading, 2 demand lines and a total
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 8 ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 6 ]
      exp = 'D1*' ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 7 ]
      exp = 'D2*' ).

  ENDMETHOD.

  METHOD quantities_are_totalled.

    DATA(lt_line) = report_of( VALUE #(
      run_id     = 'RUN-0001'
      allocation = VALUE #(
        ( demand_id = 'D1' requested = '10' confirmed = '4' shortfall = '6' )
        ( demand_id = 'D2' requested = '5'  confirmed = '5' shortfall = 0 ) ) ) ).

    DATA(lv_total) = lt_line[ lines( lt_line ) ].

    cl_abap_unit_assert=>assert_char_cp(
      act = lv_total
      exp = 'Total*15.000*9.000*6.000*' ).

  ENDMETHOD.

  METHOD columns_line_up.

    DATA(lt_line) = report_of( VALUE #(
      run_id     = 'RUN-0001'
      allocation = VALUE #(
        ( demand_id = '0000004711000010' requested = '1000' confirmed = '1' shortfall = '999' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = strlen( lt_line[ 5 ] )
      exp = strlen( lt_line[ 6 ] )
      msg = 'the column heading and the rows must be the same width' ).

  ENDMETHOD.

  METHOD rejected_run_is_reported.

    DATA lo_service TYPE REF TO zif_allocation_service.

    lo_service = NEW lcl_service_double( iv_reject = abap_true ).

    DATA(lt_line) = NEW zcl_allocation_report( lo_service )->run(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_line )
      exp = 1 ).
    cl_abap_unit_assert=>assert_char_cp(
      act = lt_line[ 1 ]
      exp = 'Allocation failed:*'
      msg = 'the user must be told the run did not happen' ).

  ENDMETHOD.

ENDCLASS.
