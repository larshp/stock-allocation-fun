CLASS ltcl_alloc_yield_target DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_target.

    METHODS setup.

    METHODS computes_target FOR TESTING.
    METHODS met_rule        FOR TESTING.
    METHODS computes_gap    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_target IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_target( ).
  ENDMETHOD.

  METHOD computes_target.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target( iv_total = 100 iv_target_percent = 95 )
      exp = 95 ).
  ENDMETHOD.

  METHOD met_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_good = 95 iv_target = 95 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_met( iv_good = 90 iv_target = 95 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_good = 90 iv_target = 95 ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
