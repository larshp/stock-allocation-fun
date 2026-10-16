CLASS ltcl_alloc_val_signoff DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_signoff.

    METHODS setup.

    METHODS signed_rule FOR TESTING.
    METHODS reads_status FOR TESTING.
    METHODS reads_action FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_signoff IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_signoff( ).
  ENDMETHOD.

  METHOD signed_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_signed( 'LARS' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_signed( '' ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_line_count = 0 iv_is_signed = abap_false )
      exp = 'EMPTY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_line_count = 2 iv_is_signed = abap_false )
      exp = 'DRAFT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_line_count = 2 iv_is_signed = abap_true )
      exp = 'SIGNED' ).
  ENDMETHOD.

  METHOD reads_action.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->require( 'DRAFT' ) exp = 'awaiting sign-off' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->require( 'SIGNED' ) exp = 'complete' ).
  ENDMETHOD.

ENDCLASS.
