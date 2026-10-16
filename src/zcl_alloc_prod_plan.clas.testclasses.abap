CLASS ltcl_alloc_prod_plan DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prod_plan.

    METHODS setup.

    METHODS computes_planned  FOR TESTING.
    METHODS within_rule       FOR TESTING.
    METHODS computes_variance FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prod_plan IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prod_plan( ).
  ENDMETHOD.

  METHOD computes_planned.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->planned( iv_qty = 5 iv_std_unit_cost = 20 )
      exp = 100 ).
  ENDMETHOD.

  METHOD within_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_within( iv_actual = 90 iv_planned = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_within( iv_actual = 110 iv_planned = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_actual = 110 iv_planned = 100 )
      exp = 10 ).
  ENDMETHOD.

ENDCLASS.
