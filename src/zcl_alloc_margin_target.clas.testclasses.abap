CLASS ltcl_alloc_margin_target DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_margin_target.

    METHODS setup.

    METHODS meets_rule       FOR TESTING.
    METHODS computes_shortfall FOR TESTING.
    METHODS prices_for_target FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_margin_target IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_margin_target( ).
  ENDMETHOD.

  METHOD meets_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->meets( iv_margin_percent = 33 iv_target_percent = 30 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->meets( iv_margin_percent = 25 iv_target_percent = 30 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_shortfall.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_margin_percent = 25 iv_target_percent = 30 )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->shortfall( iv_margin_percent = 33 iv_target_percent = 30 )
      exp = 0 ).
  ENDMETHOD.

  METHOD prices_for_target.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->price_for_target( iv_cost = 800 iv_target_percent = 20 )
      exp = 1000 ).
  ENDMETHOD.

ENDCLASS.
