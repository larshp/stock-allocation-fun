CLASS ltcl_alloc_cobj_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_cost.

    METHODS setup.

    METHODS computes_cost     FOR TESTING.
    METHODS computes_per_unit FOR TESTING.
    METHODS zero_rule         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_cost( ).
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost( iv_material = 600 iv_labour = 200 iv_overhead = 100 )
      exp = 900 ).
  ENDMETHOD.

  METHOD computes_per_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_unit( iv_cost = 900 iv_quantity = 300 )
      exp = 3 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 900 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
