CLASS ltcl_alloc_forecast_error DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast_error.

    METHODS setup.

    METHODS signed_error   FOR TESTING.
    METHODS percent_error  FOR TESTING.
    METHODS tolerance_rule FOR TESTING.
    METHODS guards_zero    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_forecast_error IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast_error( ).
  ENDMETHOD.

  METHOD signed_error.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->error( iv_actual = 100 iv_forecast = 90 )
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->error( iv_actual = 100 iv_forecast = 120 )
      exp = -20 ).
  ENDMETHOD.

  METHOD percent_error.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->error_percent( iv_actual = 100 iv_forecast = 90 )
      exp = 10 ).
  ENDMETHOD.

  METHOD tolerance_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_actual = 100 iv_forecast = 90
                                      iv_tolerance = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_actual = 100 iv_forecast = 90
                                      iv_tolerance = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->error_percent( iv_actual = 0 iv_forecast = 90 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
