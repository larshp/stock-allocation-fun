CLASS ltcl_alloc_prov_cover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_cover.

    METHODS setup.

    METHODS reads_coverage FOR TESTING.
    METHODS covered_rule   FOR TESTING.
    METHODS computes_shortfall FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_cover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_cover( ).
  ENDMETHOD.

  METHOD reads_coverage.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->coverage_percent( iv_provision = 300 iv_requirement = 400 )
      exp = 75 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->coverage_percent( iv_provision = 300 iv_requirement = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD covered_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_provision = 400 iv_requirement = 400 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_provision = 300 iv_requirement = 400 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_provision = 300 iv_requirement = 400 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_provision = 500 iv_requirement = 400 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
