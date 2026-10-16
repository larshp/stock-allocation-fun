CLASS ltcl_alloc_pvar_yield DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pvar_yield.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS adverse_rule      FOR TESTING.
    METHODS reads_percent     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pvar_yield IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pvar_yield( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->yield_variance( iv_standard_qty = 105 iv_actual_qty = 100 iv_standard_price = 5 )
      exp = 25 ).
  ENDMETHOD.

  METHOD adverse_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( 25 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( -25 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_variance = 25 iv_standard_cost = 500 )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
