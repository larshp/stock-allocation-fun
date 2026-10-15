CLASS ltcl_alloc_schedule DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_schedule.

    METHODS setup.

    METHODS builds_dates  FOR TESTING.
    METHODS counts_dates  FOR TESTING.
    METHODS on_time_rule  FOR TESTING.
    METHODS guards_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_schedule IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_schedule( ).
  ENDMETHOD.

  METHOD builds_dates.
    DATA lt_dates TYPE zcl_alloc_schedule=>ty_dates_tt.

    lt_dates = mo_cut->build( iv_start_date = '20260101' iv_count = 3
                              iv_interval_days = 7 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_dates ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_dates[ 1 ] exp = '20260101' ).
    cl_abap_unit_assert=>assert_equals( act = lt_dates[ 2 ] exp = '20260108' ).
    cl_abap_unit_assert=>assert_equals( act = lt_dates[ 3 ] exp = '20260115' ).
  ENDMETHOD.

  METHOD counts_dates.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->dates( iv_start_date = '20260101' iv_count = 3
                           iv_interval_days = 7 )
      exp = 3 ).
  ENDMETHOD.

  METHOD on_time_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_time( iv_actual_date  = '20260108'
                                iv_planned_date = '20260110' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_time( iv_actual_date  = '20260112'
                                iv_planned_date = '20260110' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    DATA lt_dates TYPE zcl_alloc_schedule=>ty_dates_tt.

    lt_dates = mo_cut->build( iv_start_date = '20260101' iv_count = 0
                              iv_interval_days = 7 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_dates ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
