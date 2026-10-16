CLASS ltcl_alloc_std_variance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_std_variance.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS favourable_rule   FOR TESTING.
    METHODS computes_percent  FOR TESTING.
    METHODS guards_zero       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_std_variance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_std_variance( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_actual = 120 iv_standard = 100 )
      exp = 20 ).
  ENDMETHOD.

  METHOD favourable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( iv_actual = 90 iv_standard = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_favourable( iv_actual = 120 iv_standard = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_actual = 120 iv_standard = 100 )
      exp = 20 ).
  ENDMETHOD.

  METHOD guards_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_actual = 120 iv_standard = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
