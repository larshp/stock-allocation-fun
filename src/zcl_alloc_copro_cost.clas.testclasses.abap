CLASS ltcl_alloc_copro_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_cost.

    METHODS setup.

    METHODS computes_cost FOR TESTING.
    METHODS computes_unit FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_cost( ).
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost( iv_joint_cost = 1000 iv_share_percent = 30 )
      exp = 300 ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_cost = 300 iv_qty = 30 ) exp = 10 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 300 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
