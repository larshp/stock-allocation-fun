CLASS ltcl_alloc_cost_round DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cost_round.

    METHODS setup.

    METHODS rounds_up     FOR TESTING.
    METHODS rounds_down   FOR TESTING.
    METHODS rounded_rule  FOR TESTING.
    METHODS computes_diff FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cost_round IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cost_round( ).
  ENDMETHOD.

  METHOD rounds_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round( iv_value = 103 iv_nearest = 5 ) exp = 105 ).
  ENDMETHOD.

  METHOD rounds_down.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->round( iv_value = 102 iv_nearest = 5 ) exp = 100 ).
  ENDMETHOD.

  METHOD rounded_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rounded( iv_value = 100 iv_nearest = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rounded( iv_value = 103 iv_nearest = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_diff.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_value = 103 iv_rounded = 105 )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
