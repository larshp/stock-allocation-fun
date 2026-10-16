CLASS ltcl_alloc_prod_actual DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prod_actual.

    METHODS setup.

    METHODS computes_actual FOR TESTING.
    METHODS over_rule       FOR TESTING.
    METHODS reads_variance  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prod_actual IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prod_actual( ).
  ENDMETHOD.

  METHOD computes_actual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->actual( iv_qty = 5 iv_actual_unit_cost = 22 )
      exp = 110 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 110 iv_planned = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 90 iv_planned = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance_percent( iv_actual = 110 iv_planned = 100 )
      exp = 10 ).
  ENDMETHOD.

ENDCLASS.
