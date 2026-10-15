CLASS ltcl_alloc_cost_basis_cmp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_basis_cmp.

    METHODS setup.

    METHODS compares_costs FOR TESTING.
    METHODS picks_cheaper  FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_basis_cmp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_basis_cmp( ).
  ENDMETHOD.

  METHOD compares_costs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_cost_a = 10 iv_cost_b = 20 ) exp = -1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_cost_a = 20 iv_cost_b = 10 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_cost_a = 10 iv_cost_b = 10 ) exp = 0 ).
  ENDMETHOD.

  METHOD picks_cheaper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_cost_a = 10 iv_cost_b = 20 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_cost_a = 30 iv_cost_b = 20 ) exp = 20 ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_cost_a = 10 iv_cost_b = 20 ) exp = -10 ).
  ENDMETHOD.

ENDCLASS.
