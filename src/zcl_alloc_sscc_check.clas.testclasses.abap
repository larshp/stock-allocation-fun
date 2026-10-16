CLASS ltcl_alloc_sscc_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    CONSTANTS c_sscc TYPE string VALUE '003401234500000017'.

    DATA mo_cut TYPE REF TO zcl_alloc_sscc_check.

    METHODS setup.

    METHODS digits_ok      FOR TESTING.
    METHODS digits_bad     FOR TESTING.
    METHODS length_ok      FOR TESTING.
    METHODS check_ok       FOR TESTING.
    METHODS check_bad      FOR TESTING.
    METHODS full_valid     FOR TESTING.
    METHODS full_invalid   FOR TESTING.
    METHODS non_digits     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sscc_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sscc_check( ).
  ENDMETHOD.

  METHOD digits_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_digit_string( c_sscc ) exp = abap_true ).
  ENDMETHOD.

  METHOD digits_bad.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_digit_string( '0034012345X0000019' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_digit_string( '' ) exp = abap_false ).
  ENDMETHOD.

  METHOD length_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_length( iv_sscc = c_sscc iv_length = 18 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_length( iv_sscc = c_sscc iv_length = 17 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD check_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->check_digit_ok( c_sscc ) exp = abap_true ).
  ENDMETHOD.

  METHOD check_bad.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->check_digit_ok( '003401234500000019' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD full_valid.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_sscc = c_sscc iv_length = 18 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD full_invalid.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_sscc = '123' iv_length = 18 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD non_digits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->check_digit_ok( '00340123450000001X' )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_sscc   = '00340123450000001X'
                              iv_length = 18 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
