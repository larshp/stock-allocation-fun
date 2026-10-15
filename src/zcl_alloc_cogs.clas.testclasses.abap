CLASS ltcl_alloc_cogs DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cogs.

    METHODS setup.

    METHODS computes_cogs    FOR TESTING.
    METHODS reads_unit_cost  FOR TESTING.
    METHODS zero_rule        FOR TESTING.
    METHODS guards_quantity  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cogs IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cogs( ).
  ENDMETHOD.

  METHOD computes_cogs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cogs( iv_quantity = 100 iv_unit_cost = 10 )
      exp = 1000 ).
  ENDMETHOD.

  METHOD reads_unit_cost.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_cost( iv_cogs = 1000 iv_quantity = 100 )
      exp = 10 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 1000 ) exp = abap_false ).
  ENDMETHOD.

  METHOD guards_quantity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_cost( iv_cogs = 1000 iv_quantity = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
