CLASS ltcl_alloc_prep_row DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_row.

    METHODS setup.

    METHODS formats_row FOR TESTING.
    METHODS costly_rule FOR TESTING.
    METHODS zero_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_row IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_row( ).
  ENDMETHOD.

  METHOD formats_row.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->format( iv_order = 'O1' iv_cost = 100 ) exp = 'O1=100' ).
  ENDMETHOD.

  METHOD costly_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_costly( iv_cost = 100 iv_limit = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_costly( iv_cost = 50 iv_limit = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 100 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
