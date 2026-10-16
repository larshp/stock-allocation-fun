CLASS ltcl_alloc_settle_diff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_diff.

    METHODS setup.

    METHODS computes_difference FOR TESTING.
    METHODS balanced_rule       FOR TESTING.
    METHODS computes_magnitude  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_diff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_diff( ).
  ENDMETHOD.

  METHOD computes_difference.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( iv_target = 100 iv_actual = 90 ) exp = 10 ).
  ENDMETHOD.

  METHOD balanced_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_balanced( 10 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_magnitude.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->magnitude( -10 ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
