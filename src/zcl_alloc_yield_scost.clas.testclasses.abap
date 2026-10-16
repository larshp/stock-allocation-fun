CLASS ltcl_alloc_yield_scost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_scost.

    METHODS setup.

    METHODS computes_cost FOR TESTING.
    METHODS costly_rule   FOR TESTING.
    METHODS computes_unit FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_scost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_scost( ).
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scrap_cost( iv_scrap_qty = 10 iv_unit_cost = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD costly_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_costly( iv_cost = 50 iv_limit = 40 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_costly( iv_cost = 30 iv_limit = 40 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_cost = 50 iv_qty = 10 ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
