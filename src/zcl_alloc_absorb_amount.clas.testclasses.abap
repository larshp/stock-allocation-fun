CLASS ltcl_alloc_absorb_amount DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_amount.

    METHODS setup.

    METHODS absorbs_overhead FOR TESTING.
    METHODS computes_variance FOR TESTING.
    METHODS over_rule       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_amount IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_amount( ).
  ENDMETHOD.

  METHOD absorbs_overhead.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->absorbed( iv_rate = 2 iv_actual_base = 300 )
      exp = 600 ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_absorbed = 600 iv_actual = 500 )
      exp = 100 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_absorbed = 600 iv_actual = 500 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_absorbed = 400 iv_actual = 500 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
