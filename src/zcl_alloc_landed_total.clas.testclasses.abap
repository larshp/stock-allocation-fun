CLASS ltcl_alloc_landed_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_total.

    METHODS setup.

    METHODS totals_cost      FOR TESTING.
    METHODS computes_markup  FOR TESTING.
    METHODS custom_rule      FOR TESTING.
    METHODS guards_zero      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_total( ).
  ENDMETHOD.

  METHOD totals_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( iv_base_cost = 1000 iv_add_on = 200 )
      exp = 1200 ).
  ENDMETHOD.

  METHOD computes_markup.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->markup_percent( iv_base_cost = 1000 iv_landed = 1200 )
      exp = 20 ).
  ENDMETHOD.

  METHOD custom_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_custom( 2 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_custom( 1 ) exp = abap_false ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->markup_percent( iv_base_cost = 0 iv_landed = 200 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
