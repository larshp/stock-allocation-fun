CLASS ltcl_alloc_val_select DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_select.

    METHODS setup.

    METHODS selects_method   FOR TESTING.
    METHODS standard_rule    FOR TESTING.
    METHODS explains_reason  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_select IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_select( ).
  ENDMETHOD.

  METHOD selects_method.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( 'STANDARD' ) exp = 'STANDARD' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( 'LOWEST' ) exp = 'LOWEST' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( 'OTHER' ) exp = 'AVERAGE' ).
  ENDMETHOD.

  METHOD standard_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_standard( 'STANDARD' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_standard( 'AVERAGE' ) exp = abap_false ).
  ENDMETHOD.

  METHOD explains_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'LOWEST' ) exp = 'lower of cost and market' ).
  ENDMETHOD.

ENDCLASS.
