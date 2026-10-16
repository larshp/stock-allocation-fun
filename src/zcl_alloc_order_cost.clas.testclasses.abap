CLASS ltcl_alloc_order_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_order_cost.

    METHODS setup.

    METHODS annual_cost  FOR TESTING.
    METHODS per_order    FOR TESTING.
    METHODS counts_orders FOR TESTING.
    METHODS guards_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_order_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_order_cost( ).
  ENDMETHOD.

  METHOD annual_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->annual_cost( iv_order_count = 10 iv_cost_per_order = 50 )
      exp = 500 ).
  ENDMETHOD.

  METHOD per_order.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_order( iv_total_cost = 500 iv_order_count = 10 )
      exp = 50 ).
  ENDMETHOD.

  METHOD counts_orders.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->order_count( iv_annual_demand = 1000 iv_order_quantity = 250 )
      exp = 4 ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->annual_cost( iv_order_count = 10 iv_cost_per_order = 0 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_order( iv_total_cost = 500 iv_order_count = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
