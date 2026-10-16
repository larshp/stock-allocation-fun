CLASS ltcl_alloc_gov_policy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_policy.

    METHODS setup.

    METHODS reads_policy  FOR TESTING.
    METHODS strict_rule   FOR TESTING.
    METHODS reads_reason  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_policy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_policy( ).
  ENDMETHOD.

  METHOD reads_policy.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->policy_of( 1 ) exp = 'STRICT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->policy_of( 2 ) exp = 'STANDARD' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->policy_of( 9 ) exp = 'UNKNOWN' ).
  ENDMETHOD.

  METHOD strict_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_strict( 'STRICT' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_strict( 'RELAXED' ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'STRICT' ) exp = 'audit required' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'RELAXED' ) exp = 'no review' ).
  ENDMETHOD.

ENDCLASS.
