CLASS ltcl_alloc_eoq_calc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_eoq_calc.

    METHODS setup.

    METHODS computes_eoq     FOR TESTING.
    METHODS validity_rule    FOR TESTING.
    METHODS counts_orders    FOR TESTING.
    METHODS guards_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_eoq_calc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_eoq_calc( ).
  ENDMETHOD.

  METHOD computes_eoq.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->eoq( iv_annual_demand = 1000 iv_order_cost = 50
                         iv_holding_cost = 2 )
      exp = 223 ).
  ENDMETHOD.

  METHOD validity_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 223 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_orders.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_count( iv_annual_demand = 1000 iv_order_quantity = 223 )
      exp = 4 ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->eoq( iv_annual_demand = 1000 iv_order_cost = 50
                         iv_holding_cost = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_count( iv_annual_demand = 1000 iv_order_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
