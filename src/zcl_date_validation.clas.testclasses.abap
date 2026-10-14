CLASS ltcl_date_validation DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS validates_gregorian_dates FOR TESTING.
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

ENDCLASS.
