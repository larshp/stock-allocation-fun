CLASS ltcl_alloc_wip_valuation DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_valuation.

    METHODS setup.

    METHODS computes_value      FOR TESTING.
    METHODS computes_completion FOR TESTING.
    METHODS partial_rule        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_valuation IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_valuation( ).
  ENDMETHOD.

  METHOD computes_value.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->valued_at( iv_full_value = 1000 iv_percent = 75 )
      exp = 750 ).
  ENDMETHOD.

  METHOD computes_completion.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->completion( iv_done = 3 iv_total = 4 )
      exp = 75 ).
  ENDMETHOD.

  METHOD partial_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_partial( 75 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_partial( 100 ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_partial( 0 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
