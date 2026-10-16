CLASS ltcl_alloc_holding_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_holding_cost.

    METHODS setup.

    METHODS annual_cost   FOR TESTING.
    METHODS per_unit      FOR TESTING.
    METHODS average_stock FOR TESTING.
    METHODS guards_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_holding_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_holding_cost( ).
  ENDMETHOD.

  METHOD annual_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->annual_cost( iv_average_stock = 100 iv_cost_per_unit = 3 )
      exp = 300 ).
  ENDMETHOD.

  METHOD per_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total_cost = 300 iv_average_stock = 100 )
      exp = 3 ).
  ENDMETHOD.

  METHOD average_stock.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average_stock( 50 ) exp = 25 ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->annual_cost( iv_average_stock = 0 iv_cost_per_unit = 3 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_total_cost = 300 iv_average_stock = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
