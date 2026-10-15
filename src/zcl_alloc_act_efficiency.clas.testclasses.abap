CLASS ltcl_alloc_act_efficiency DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_act_efficiency.

    METHODS setup.

    METHODS reads_efficiency FOR TESTING.
    METHODS efficient_rule   FOR TESTING.
    METHODS computes_variance FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_act_efficiency IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_act_efficiency( ).
  ENDMETHOD.

  METHOD reads_efficiency.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->efficiency_percent( iv_standard = 100 iv_actual = 80 )
      exp = 125 ).
  ENDMETHOD.

  METHOD efficient_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_efficient( iv_standard = 100 iv_actual = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_efficient( iv_standard = 100 iv_actual = 120 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_standard = 100 iv_actual = 80 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_standard = 100 iv_actual = 120 )
      exp = -20 ).
  ENDMETHOD.

ENDCLASS.
