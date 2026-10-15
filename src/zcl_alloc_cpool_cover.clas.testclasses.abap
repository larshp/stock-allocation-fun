CLASS ltcl_alloc_cpool_cover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_cover.

    METHODS setup.

    METHODS reads_coverage FOR TESTING.
    METHODS covered_rule   FOR TESTING.
    METHODS computes_shortfall FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_cover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_cover( ).
  ENDMETHOD.

  METHOD reads_coverage.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->coverage_percent( iv_assigned = 800 iv_pool = 1000 )
      exp = 80 ).
  ENDMETHOD.

  METHOD covered_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_assigned = 1000 iv_pool = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_assigned = 800 iv_pool = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_assigned = 800 iv_pool = 1000 )
      exp = 200 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_assigned = 1200 iv_pool = 1000 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
