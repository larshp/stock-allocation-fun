CLASS ltcl_alloc_recall_effect DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recall_effect.

    METHODS setup.

    METHODS rate_value    FOR TESTING.
    METHODS rate_guard    FOR TESTING.
    METHODS effective     FOR TESTING.
    METHODS outstanding_qty FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recall_effect IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recall_effect( ).
  ENDMETHOD.

  METHOD rate_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_expected = 100 iv_recovered = 90 )
      exp = 90 ).
  ENDMETHOD.

  METHOD rate_guard.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_expected = 0 iv_recovered = 90 )
      exp = 0 ).
  ENDMETHOD.

  METHOD effective.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_effective( iv_pct = 90 iv_target = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_effective( iv_pct = 90 iv_target = 95 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD outstanding_qty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( iv_expected = 100 iv_recovered = 90 )
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( iv_expected = 100 iv_recovered = 150 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
