CLASS ltcl_alloc_prod_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prod_rate.

    METHODS setup.

    METHODS computes_rate FOR TESTING.
    METHODS applied_cost  FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prod_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prod_rate( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_cost = 100 iv_qty = 5 ) exp = 20 ).
  ENDMETHOD.

  METHOD applied_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->applied( iv_rate = 20 iv_qty = 5 ) exp = 100 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 20 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
