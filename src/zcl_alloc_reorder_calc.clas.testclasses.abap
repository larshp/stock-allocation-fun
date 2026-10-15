CLASS ltcl_alloc_reorder_calc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_reorder_calc.

    METHODS setup.

    METHODS computes_point FOR TESTING.
    METHODS below_rule     FOR TESTING.
    METHODS computes_gap   FOR TESTING.
    METHODS guards_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_reorder_calc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reorder_calc( ).
  ENDMETHOD.

  METHOD computes_point.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->point( iv_daily_demand = 10 iv_lead_days = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD below_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_below( iv_stock = 40 iv_point = 50 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_below( iv_stock = 60 iv_point = 50 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_stock = 40 iv_point = 50 )
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_stock = 60 iv_point = 50 )
      exp = 0 ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->point( iv_daily_demand = 0 iv_lead_days = 5 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
