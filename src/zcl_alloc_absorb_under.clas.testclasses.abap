CLASS ltcl_alloc_absorb_under DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_absorb_under.

    METHODS setup.

    METHODS under_rule     FOR TESTING.
    METHODS computes_gap   FOR TESTING.
    METHODS reads_percent  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_absorb_under IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_absorb_under( ).
  ENDMETHOD.

  METHOD under_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_under( iv_absorbed = 400 iv_actual = 500 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_under( iv_absorbed = 600 iv_actual = 500 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_absorbed = 400 iv_actual = 500 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_absorbed = 600 iv_actual = 500 )
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_absorbed = 400 iv_actual = 500 )
      exp = 20 ).
  ENDMETHOD.

ENDCLASS.
