CLASS ltcl_alloc_yield_rework DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_rework.

    METHODS setup.

    METHODS computes_rework FOR TESTING.
    METHODS reworked_rule   FOR TESTING.
    METHODS reads_percent   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_rework IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_rework( ).
  ENDMETHOD.

  METHOD computes_rework.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rework( iv_total = 100 iv_rework_percent = 20 )
      exp = 20 ).
  ENDMETHOD.

  METHOD reworked_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reworked( 20 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reworked( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rework_percent( iv_rework = 20 iv_total = 100 )
      exp = 20 ).
  ENDMETHOD.

ENDCLASS.
