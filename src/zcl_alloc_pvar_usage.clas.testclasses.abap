CLASS ltcl_alloc_pvar_usage DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pvar_usage.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS adverse_rule      FOR TESTING.
    METHODS reads_sign        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pvar_usage IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pvar_usage( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->usage_variance( iv_actual_qty = 110 iv_standard_qty = 100 iv_standard_price = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD adverse_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( 50 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( -50 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_sign.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sign_of( 50 ) exp = 'ADVERSE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sign_of( -50 ) exp = 'FAVOURABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sign_of( 0 ) exp = 'NONE' ).
  ENDMETHOD.

ENDCLASS.
