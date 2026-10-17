CLASS ltcl_t439i_cal_period_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS skips_empty_request FOR TESTING.
    METHODS reads_overlapping_periods FOR TESTING.
ENDCLASS.

CLASS ltcl_t439i_cal_period_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'T439I' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD skips_empty_request.
    DATA(lo_cut) = NEW zcl_t439i_cal_period_repo( ).
    DATA(lt_periods) = lo_cut->zif_planning_calendar_repo~get_periods_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_periods ).
  ENDMETHOD.

  METHOD reads_overlapping_periods.
    DATA lt_t439i TYPE STANDARD TABLE OF t439i WITH EMPTY KEY.
    APPEND VALUE #(
      werks = '1000'
      mrppp = 'PC1'
      ppvon = '20260101'
      ppbis = '20260107' ) TO lt_t439i.
    APPEND VALUE #(
      werks = '1000'
      mrppp = 'PC1'
      ppvon = '20260108'
      ppbis = '20260131' ) TO lt_t439i.
    APPEND VALUE #(
      werks = '1000'
      mrppp = 'PC1'
      ppvon = '20251201'
      ppbis = '20260104' ) TO lt_t439i.
    APPEND VALUE #(
      werks = '1000'
      mrppp = 'PC1'
      ppvon = '20260111'
      ppbis = '20260201' ) TO lt_t439i.
    APPEND VALUE #(
      werks = '1000'
      mrppp = 'PC2'
      ppvon = '20260105'
      ppbis = '20260110' ) TO lt_t439i.
    APPEND VALUE #(
      werks = '2000'
      mrppp = 'PC1'
      ppvon = '20260105'
      ppbis = '20260110' ) TO lt_t439i.
    mo_environment->insert_test_data( lt_t439i ).

    DATA(lo_cut) = NEW zcl_t439i_cal_period_repo( ).
    DATA(lt_periods) = lo_cut->zif_planning_calendar_repo~get_periods_bulk(
      it_requests = VALUE #(
        ( plant                = '1000'
          planning_calendar_id = 'PC1'
          from_date            = '20260105'
          through_date         = '20260110' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_periods ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV t439i-ppvon( '20260101' )
      act = lt_periods[ start_date = '20260101' ]-start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV t439i-ppbis( '20260131' )
      act = lt_periods[ end_date = '20260131' ]-end_date ).
  ENDMETHOD.
ENDCLASS.
