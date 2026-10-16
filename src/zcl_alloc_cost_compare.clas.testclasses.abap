CLASS ltcl_alloc_cost_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_compare.

    METHODS setup.

    METHODS cheaper_rule   FOR TESTING.
    METHODS difference     FOR TESTING.
    METHODS best_option    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_compare( ).
  ENDMETHOD.

  METHOD cheaper_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_cost_a = 100 iv_cost_b = 150 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_cost_a = 200 iv_cost_b = 150 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD difference.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_cost_a = 100 iv_cost_b = 150 )
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_cost_a = 200 iv_cost_b = 150 )
      exp = 50 ).
  ENDMETHOD.

  METHOD best_option.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_option( iv_cost_a = 100 iv_cost_b = 150 )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_option( iv_cost_a = 200 iv_cost_b = 150 )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
