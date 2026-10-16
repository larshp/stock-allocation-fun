CLASS ltcl_alloc_cpool_var DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_var.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS over_rule       FOR TESTING.
    METHODS reads_percent   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_var IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_var( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_actual = 900 iv_plan = 800 )
      exp = 100 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 900 iv_plan = 800 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 700 iv_plan = 800 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_actual = 900 iv_plan = 800 )
      exp = 12 ).
  ENDMETHOD.

ENDCLASS.
