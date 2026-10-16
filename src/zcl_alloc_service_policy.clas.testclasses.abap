CLASS ltcl_alloc_service_policy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_service_policy.

    METHODS setup.

    METHODS levels       FOR TESTING.
    METHODS strict_rule  FOR TESTING.
    METHODS policy_names FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_service_policy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_service_policy( ).
  ENDMETHOD.

  METHOD levels.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 'A' ) exp = 98 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 'C' ) exp = 90 ).
  ENDMETHOD.

  METHOD strict_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_strict( 'A' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_strict( 'C' ) exp = abap_false ).
  ENDMETHOD.

  METHOD policy_names.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_of( 'A' ) exp = 'STRICT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_of( 'C' ) exp = 'RELAXED' ).
  ENDMETHOD.

ENDCLASS.
