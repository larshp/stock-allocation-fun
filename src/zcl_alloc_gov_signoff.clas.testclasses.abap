CLASS ltcl_alloc_gov_signoff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_signoff.

    METHODS setup.

    METHODS signed_rule  FOR TESTING.
    METHODS reads_status FOR TESTING.
    METHODS reads_require FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_signoff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_signoff( ).
  ENDMETHOD.

  METHOD signed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_signed( iv_signed = 2 iv_required = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_signed( iv_signed = 1 iv_required = 2 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_signed = 2 iv_required = 2 )
      exp = 'COMPLETE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_signed = 1 iv_required = 2 )
      exp = 'PARTIAL' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_signed = 0 iv_required = 2 )
      exp = 'OPEN' ).
  ENDMETHOD.

  METHOD reads_require.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->require( iv_signed = 1 iv_required = 2 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->require( iv_signed = 2 iv_required = 2 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
