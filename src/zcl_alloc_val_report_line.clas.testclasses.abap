CLASS ltcl_alloc_val_report_line DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_report_line.

    METHODS setup.

    METHODS formats_line FOR TESTING.
    METHODS valuable_rule FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_report_line IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_report_line( ).
  ENDMETHOD.

  METHOD formats_line.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->format( iv_material = 'M1' iv_value = 1000 )
      exp = 'M1: 1000' ).
  ENDMETHOD.

  METHOD valuable_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valuable( 1000 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valuable( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 1000 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
