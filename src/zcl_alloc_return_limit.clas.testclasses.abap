CLASS ltcl_alloc_return_limit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_limit.

    METHODS setup.

    METHODS within_rule   FOR TESTING.
    METHODS manager_rule  FOR TESTING.
    METHODS tier_limits   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_limit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_limit( ).
  ENDMETHOD.

  METHOD within_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_limit( iv_value = 500 iv_limit = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_limit( iv_value = 1500 iv_limit = 1000 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_limit( iv_value = 100 iv_limit = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD manager_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_manager( iv_value = 500 iv_clerk_limit = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_manager( iv_value = 50 iv_clerk_limit = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD tier_limits.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->limit_of( 'MANAGER' ) exp = 1000 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->limit_of( 'DIRECTOR' ) exp = 10000 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->limit_of( 'UNKNOWN' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
