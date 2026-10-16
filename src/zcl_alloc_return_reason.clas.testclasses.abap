CLASS ltcl_alloc_return_reason DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_reason.

    METHODS setup.

    METHODS quality_family   FOR TESTING.
    METHODS logistics_family FOR TESTING.
    METHODS commercial_family FOR TESTING.
    METHODS unknown_reason   FOR TESTING.
    METHODS recognises       FOR TESTING.
    METHODS representative   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_reason IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_reason( ).
  ENDMETHOD.

  METHOD quality_family.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'DEFECTIVE' ) exp = 'QUALITY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'QUALITY_ISSUE' ) exp = 'QUALITY' ).
  ENDMETHOD.

  METHOD logistics_family.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'WRONG_QUANTITY' ) exp = 'LOGISTICS' ).
  ENDMETHOD.

  METHOD commercial_family.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'NOT_ORDERED' ) exp = 'COMMERCIAL' ).
  ENDMETHOD.

  METHOD unknown_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( 'SOMETHING_ELSE' ) exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->classify( '' ) exp = '' ).
  ENDMETHOD.

  METHOD recognises.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reason( 'DAMAGED' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_reason( 'NOPE' ) exp = abap_false ).
  ENDMETHOD.

  METHOD representative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code_of( 'QUALITY' ) exp = 'DAMAGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->code_of( 'UNKNOWN' ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
