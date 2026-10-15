CLASS ltcl_alloc_rout_eff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_eff.

    METHODS setup.

    METHODS reads_efficiency FOR TESTING.
    METHODS efficient_rule   FOR TESTING.
    METHODS computes_variance FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_eff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_eff( ).
  ENDMETHOD.

  METHOD reads_efficiency.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->efficiency_percent( iv_standard = 100 iv_actual = 125 )
      exp = 80 ).
  ENDMETHOD.

  METHOD efficient_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_efficient( iv_standard = 100 iv_actual = 125 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_efficient( iv_standard = 100 iv_actual = 80 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_actual = 125 iv_standard = 100 )
      exp = 25 ).
  ENDMETHOD.

ENDCLASS.
