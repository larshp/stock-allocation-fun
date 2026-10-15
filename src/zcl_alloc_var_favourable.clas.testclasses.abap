CLASS ltcl_alloc_var_favourable DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_favourable.

    METHODS setup.

    METHODS classifies_variance FOR TESTING.
    METHODS favourable_rule    FOR TESTING.
    METHODS adverse_rule       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_favourable IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_favourable( ).
  ENDMETHOD.

  METHOD classifies_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( -100 ) exp = 'FAVOURABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 100 ) exp = 'ADVERSE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 0 ) exp = 'ZERO' ).
  ENDMETHOD.

  METHOD favourable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( -100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( 100 ) exp = abap_false ).
  ENDMETHOD.

  METHOD adverse_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( -100 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
