CLASS ltcl_alloc_copro_value DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_copro_value.

    METHODS setup.

    METHODS computes_value FOR TESTING.
    METHODS zero_rule      FOR TESTING.
    METHODS computes_unit  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_copro_value IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_copro_value( ).
  ENDMETHOD.

  METHOD computes_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value_of( iv_qty = 10 iv_unit_value = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 50 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_value = 50 iv_qty = 10 ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
