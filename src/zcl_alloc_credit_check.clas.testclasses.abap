CLASS ltcl_alloc_credit_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_credit_check.

    METHODS setup.

    METHODS signed_diff   FOR TESTING.
    METHODS within        FOR TESTING.
    METHODS outside       FOR TESTING.
    METHODS reasons       FOR TESTING.
    METHODS bad_tolerance FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_credit_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_credit_check( ).
  ENDMETHOD.

  METHOD signed_diff.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_credit = 105 iv_expected = 100 )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_credit = 95 iv_expected = 100 )
      exp = -5 ).
  ENDMETHOD.

  METHOD within.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_credit = 105 iv_expected = 100
                              iv_tolerance = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_credit = 95 iv_expected = 100
                              iv_tolerance = 5 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD outside.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_credit = 106 iv_expected = 100
                              iv_tolerance = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reasons.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_credit = 105 iv_expected = 100
                            iv_tolerance = 5 )
      exp = 'OK' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_credit = 110 iv_expected = 100
                            iv_tolerance = 5 )
      exp = 'OVER_CREDIT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_credit = 90 iv_expected = 100
                            iv_tolerance = 5 )
      exp = 'UNDER_CREDIT' ).
  ENDMETHOD.

  METHOD bad_tolerance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_credit = 100 iv_expected = 100
                              iv_tolerance = -1 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( iv_credit = 100 iv_expected = 100
                            iv_tolerance = -1 )
      exp = 'BAD_TOLERANCE' ).
  ENDMETHOD.

ENDCLASS.
