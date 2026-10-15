CLASS ltcl_alloc_tolerance_check DEFINITION
  FOR TESTING
    DURATION SHORT
    RISK LEVEL HARMLESS
    FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_tolerance_check.

    METHODS setup.

    METHODS under_ok        FOR TESTING.
    METHODS under_too_much  FOR TESTING.
    METHODS over_ok         FOR TESTING.
    METHODS over_too_much   FOR TESTING.
    METHODS exact_ok        FOR TESTING.
    METHODS deviation_sign  FOR TESTING.
    METHODS bad_ordered     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_tolerance_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_tolerance_check( ).
  ENDMETHOD.

  METHOD under_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_ordered = 100 iv_delivered = 95
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD under_too_much.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_ordered = 100 iv_delivered = 90
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD over_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_ordered = 100 iv_delivered = 102
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD over_too_much.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_ordered = 100 iv_delivered = 110
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD exact_ok.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_ordered = 100 iv_delivered = 100
                                      iv_under_percent = 0
                                      iv_over_percent = 0 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD deviation_sign.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->deviation_percent( iv_ordered = 100 iv_delivered = 90 )
      exp = -10 ).
  ENDMETHOD.

  METHOD bad_ordered.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_ordered = 0 iv_delivered = 10
                                      iv_under_percent = 5
                                      iv_over_percent = 3 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
