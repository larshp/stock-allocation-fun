CLASS ltcl_alloc_act_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_rate.

    METHODS setup.

    METHODS computes_rate FOR TESTING.
    METHODS back_to_cost  FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_rate( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_cost = 600 iv_driver_qty = 300 )
      exp = 2 ).
  ENDMETHOD.

  METHOD back_to_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_cost( iv_rate = 2 iv_driver_qty = 300 )
      exp = 600 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 2 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
