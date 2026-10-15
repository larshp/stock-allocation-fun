CLASS ltcl_alloc_unit_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_unit_cost.

    METHODS setup.

    METHODS computes_basis FOR TESTING.
    METHODS computes_total FOR TESTING.
    METHODS zero_rule      FOR TESTING.
    METHODS guards_zero    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_unit_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_unit_cost( ).
  ENDMETHOD.

  METHOD computes_basis.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->basis( iv_total_cost = 1000 iv_quantity = 100 )
      exp = 10 ).
  ENDMETHOD.

  METHOD computes_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_of( iv_unit_cost = 10 iv_quantity = 100 )
      exp = 1000 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 10 ) exp = abap_false ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->basis( iv_total_cost = 1000 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
