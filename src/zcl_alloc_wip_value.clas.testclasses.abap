CLASS ltcl_alloc_wip_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_value.

    METHODS setup.

    METHODS computes_value FOR TESTING.
    METHODS zero_rule      FOR TESTING.
    METHODS computes_unit  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_value( ).
  ENDMETHOD.

  METHOD computes_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_of( iv_material = 500 iv_labour = 300 iv_overhead = 100 )
      exp = 900 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 900 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_value = 900 iv_qty = 300 ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
