CLASS ltcl_alloc_stdcost_var DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_var.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS over_rule         FOR TESTING.
    METHODS reads_percent     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_var IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_var( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_standard = 100 iv_actual = 110 )
      exp = 10 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 110 iv_standard = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_actual = 90 iv_standard = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_variance = 10 iv_standard = 100 )
      exp = 10 ).
  ENDMETHOD.

ENDCLASS.
