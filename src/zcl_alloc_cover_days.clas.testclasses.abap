CLASS ltcl_alloc_cover_days DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cover_days.

    METHODS setup.

    METHODS computes_days FOR TESTING.
    METHODS covered_rule  FOR TESTING.
    METHODS computes_gap  FOR TESTING.
    METHODS guards_zero   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cover_days IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cover_days( ).
  ENDMETHOD.

  METHOD computes_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days( iv_stock = 100 iv_daily_demand = 10 )
      exp = 10 ).
  ENDMETHOD.

  METHOD covered_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_days = 10 iv_required_days = 7 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_covered( iv_days = 5 iv_required_days = 7 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap_days( iv_days = 5 iv_required_days = 7 )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap_days( iv_days = 10 iv_required_days = 7 )
      exp = 0 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days( iv_stock = 100 iv_daily_demand = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
