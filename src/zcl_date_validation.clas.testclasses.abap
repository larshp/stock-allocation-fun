CLASS ltcl_date_validation DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS validates_gregorian_dates FOR TESTING.
    METHODS adds_calendar_days FOR TESTING.
    METHODS validates_times FOR TESTING.
ENDCLASS.

CLASS ltcl_date_validation IMPLEMENTATION.

  METHOD validates_gregorian_dates.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '20261014' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '20240229' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '20000229' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '20230229' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '21000229' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '20261301' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '20260230' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '2026ABCD' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_gregorian_date(
        iv_date = '00000000' ) ).
  ENDMETHOD.

  METHOD adds_calendar_days.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261102' )
      act = zcl_date_validation=>add_days(
        iv_date = '20261030'
        iv_days = 3 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20240301' )
      act = zcl_date_validation=>add_days(
        iv_date = '20240228'
        iv_days = 2 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20240228' )
      act = zcl_date_validation=>add_days(
        iv_date = '20240301'
        iv_days = -2 ) ).
    cl_abap_unit_assert=>assert_initial(
      act = zcl_date_validation=>add_days(
        iv_date = '99991231'
        iv_days = 1 ) ).
    cl_abap_unit_assert=>assert_initial(
      act = zcl_date_validation=>add_days(
        iv_date = '00010101'
        iv_days = -1 ) ).
    cl_abap_unit_assert=>assert_initial(
      act = zcl_date_validation=>add_days(
        iv_date = '20260230'
        iv_days = 1 ) ).
  ENDMETHOD.

  METHOD validates_times.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_date_validation=>is_valid_time( iv_time = '000000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_date_validation=>is_valid_time( iv_time = '235959' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = zcl_date_validation=>is_valid_time( iv_time = '123456' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_time( iv_time = '240000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_time( iv_time = '126000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_time( iv_time = '125960' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = zcl_date_validation=>is_valid_time( iv_time = 'AB0000' ) ).
  ENDMETHOD.

ENDCLASS.
