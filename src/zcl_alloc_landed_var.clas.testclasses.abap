CLASS ltcl_alloc_landed_var DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_var.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS over_rule         FOR TESTING.
    METHODS computes_percent  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_var IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_var( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_actual = 1200 iv_planned = 1000 )
      exp = 200 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 1200 iv_planned = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 900 iv_planned = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_actual = 1200 iv_planned = 1000 )
      exp = 20 ).
  ENDMETHOD.

ENDCLASS.
