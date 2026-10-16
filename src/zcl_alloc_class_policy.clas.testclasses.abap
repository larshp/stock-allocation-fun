CLASS ltcl_alloc_class_policy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_class_policy.

    METHODS setup.

    METHODS policies    FOR TESTING.
    METHODS strict_rule FOR TESTING.
    METHODS services    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_class_policy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_class_policy( ).
  ENDMETHOD.

  METHOD policies.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->policy_of( 'A' ) exp = 'DAILY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->policy_of( 'C' ) exp = 'MONTHLY' ).
  ENDMETHOD.

  METHOD strict_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_strict( 'A' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_strict( 'C' ) exp = abap_false ).
  ENDMETHOD.

  METHOD services.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->service_of( 'A' ) exp = 98 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->service_of( 'C' ) exp = 90 ).
  ENDMETHOD.

ENDCLASS.
