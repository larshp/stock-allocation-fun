CLASS ltcl_alloc_stockout_prob DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stockout_prob.

    METHODS setup.

    METHODS computes_probability FOR TESTING.
    METHODS likely_rule        FOR TESTING.
    METHODS buckets            FOR TESTING.
    METHODS guards_zero        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stockout_prob IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stockout_prob( ).
  ENDMETHOD.

  METHOD computes_probability.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->probability( iv_stockouts = 2 iv_periods = 10 )
      exp = 20 ).
  ENDMETHOD.

  METHOD likely_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_likely( iv_probability = 20 iv_threshold = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_likely( iv_probability = 5 iv_threshold = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD buckets.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 60 ) exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 20 ) exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bucket( 5 ) exp = 'LOW' ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->probability( iv_stockouts = 2 iv_periods = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
