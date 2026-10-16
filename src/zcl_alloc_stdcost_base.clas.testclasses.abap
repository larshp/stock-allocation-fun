CLASS ltcl_alloc_stdcost_base DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_base.

    METHODS setup.

    METHODS computes_cost FOR TESTING.
    METHODS zero_rule     FOR TESTING.
    METHODS computes_unit FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_base IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_base( ).
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->standard_cost( iv_qty = 5 iv_unit_cost = 20 )
      exp = 100 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 100 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_cost = 100 iv_qty = 5 ) exp = 20 ).
  ENDMETHOD.

ENDCLASS.
