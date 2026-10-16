CLASS ltcl_alloc_turnover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_turnover.

    METHODS setup.

    METHODS computes_turns FOR TESTING.
    METHODS days_supply    FOR TESTING.
    METHODS healthy_rule   FOR TESTING.
    METHODS guards_zero    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_turnover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_turnover( ).
  ENDMETHOD.

  METHOD computes_turns.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->turns( iv_annual_demand = 1200 iv_average_stock = 100 )
      exp = 12 ).
  ENDMETHOD.

  METHOD days_supply.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_of_supply( iv_average_stock = 100
                                    iv_annual_demand = 1200 )
      exp = 30 ).
  ENDMETHOD.

  METHOD healthy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_turns = 12 iv_min_turns = 6 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_healthy( iv_turns = 4 iv_min_turns = 6 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->turns( iv_annual_demand = 1200 iv_average_stock = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_of_supply( iv_average_stock = 100
                                    iv_annual_demand = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
