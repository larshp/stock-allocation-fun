CLASS ltcl_alloc_safety_stock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_safety_stock.

    METHODS setup.

    METHODS computes_stock FOR TESTING.
    METHODS validity_rule  FOR TESTING.
    METHODS recommendation FOR TESTING.
    METHODS guards_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_safety_stock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_safety_stock( ).
  ENDMETHOD.

  METHOD computes_stock.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stock( iv_service_factor = 200 iv_lead_days = 4
                           iv_demand_std_dev = 10 )
      exp = 40 ).
  ENDMETHOD.

  METHOD validity_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 40 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD recommendation.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recommended( iv_current_stock = 25 iv_required_stock = 40 )
      exp = 15 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->recommended( iv_current_stock = 50 iv_required_stock = 40 )
      exp = 0 ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->stock( iv_service_factor = 200 iv_lead_days = 0
                           iv_demand_std_dev = 10 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
