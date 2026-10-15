CLASS ltcl_alloc_margin_limit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_margin_limit.

    METHODS setup.

    METHODS below_rule    FOR TESTING.
    METHODS computes_gap  FOR TESTING.
    METHODS clamps_margin FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_margin_limit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_margin_limit( ).
  ENDMETHOD.

  METHOD below_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_below( iv_margin_percent = 20 iv_limit = 30 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_below( iv_margin_percent = 40 iv_limit = 30 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_margin_percent = 20 iv_limit = 30 ) exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_margin_percent = 40 iv_limit = 30 ) exp = 0 ).
  ENDMETHOD.

  METHOD clamps_margin.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->clamp( iv_margin_percent = 20 iv_limit = 30 ) exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->clamp( iv_margin_percent = 40 iv_limit = 30 ) exp = 40 ).
  ENDMETHOD.

ENDCLASS.
