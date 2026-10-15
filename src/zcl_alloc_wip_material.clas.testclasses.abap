CLASS ltcl_alloc_wip_material DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_material.

    METHODS setup.

    METHODS computes_cost  FOR TESTING.
    METHODS issued_rule    FOR TESTING.
    METHODS reads_balance  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_material IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_material( ).
  ENDMETHOD.

  METHOD computes_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->material_cost( iv_issued = 100 iv_unit_cost = 2 )
      exp = 200 ).
  ENDMETHOD.

  METHOD issued_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_issued( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_issued( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_balance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_issued = 100 iv_consumed = 80 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_issued = 100 iv_consumed = 120 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
