CLASS ltcl_alloc_rout_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_rate.

    METHODS setup.

    METHODS computes_rate FOR TESTING.
    METHODS from_cost     FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_rate( ).
  ENDMETHOD.

  METHOD computes_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_cost = 60 iv_time = 30 ) exp = 2 ).
  ENDMETHOD.

  METHOD from_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->from_cost( iv_rate = 2 iv_time = 30 ) exp = 60 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 2 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
