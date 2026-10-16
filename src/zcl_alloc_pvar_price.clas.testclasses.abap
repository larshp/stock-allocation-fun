CLASS ltcl_alloc_pvar_price DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pvar_price.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS adverse_rule      FOR TESTING.
    METHODS reads_sign        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pvar_price IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pvar_price( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->price_variance( iv_actual_price = 6 iv_standard_price = 5 iv_actual_qty = 110 )
      exp = 110 ).
  ENDMETHOD.

  METHOD adverse_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( 110 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( -1 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_sign.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sign_of( 110 ) exp = 'ADVERSE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sign_of( -1 ) exp = 'FAVOURABLE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sign_of( 0 ) exp = 'NONE' ).
  ENDMETHOD.

ENDCLASS.
