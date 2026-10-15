CLASS ltcl_alloc_return_tolerance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_tolerance.

    METHODS setup.

    METHODS deviation_signed FOR TESTING.
    METHODS deviation_zero   FOR TESTING.
    METHODS over_within      FOR TESTING.
    METHODS over_beyond      FOR TESTING.
    METHODS under_within     FOR TESTING.
    METHODS under_beyond     FOR TESTING.
    METHODS exact_match      FOR TESTING.
    METHODS bad_limits       FOR TESTING.
    METHODS credit_capped    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_tolerance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_tolerance( ).
  ENDMETHOD.

  METHOD deviation_signed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->deviation_percent( iv_authorised = 100
                                       iv_received   = 105 )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->deviation_percent( iv_authorised = 100
                                       iv_received   = 95 )
      exp = -5 ).
  ENDMETHOD.

  METHOD deviation_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->deviation_percent( iv_authorised = 0 iv_received = 5 )
      exp = 0 ).
  ENDMETHOD.

  METHOD over_within.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 100 iv_received = 105
                                      iv_under_percent = 3
                                      iv_over_percent = 5 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD over_beyond.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 100 iv_received = 106
                                      iv_under_percent = 3
                                      iv_over_percent = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD under_within.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 100 iv_received = 95
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD under_beyond.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 100 iv_received = 94
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD exact_match.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 100 iv_received = 100
                                      iv_under_percent = 3
                                      iv_over_percent = 5 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD bad_limits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 0 iv_received = 1
                                      iv_under_percent = 3
                                      iv_over_percent = 5 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_authorised = 100 iv_received = 101
                                      iv_under_percent = -1
                                      iv_over_percent = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD credit_capped.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit_quantity( iv_authorised = 100 iv_received = 105 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit_quantity( iv_authorised = 100 iv_received = 95 )
      exp = 95 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit_quantity( iv_authorised = 100 iv_received = -3 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->credit_quantity( iv_authorised = 0 iv_received = 5 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
