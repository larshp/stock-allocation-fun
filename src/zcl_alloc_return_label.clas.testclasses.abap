CLASS ltcl_alloc_return_label DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_label.

    METHODS setup.

    METHODS all_fields  FOR TESTING.
    METHODS skips_blank FOR TESTING.
    METHODS empty_input FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_label IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_label( ).
  ENDMETHOD.

  METHOD all_fields.
    DATA lt_lines TYPE zcl_alloc_return_label=>ty_lines_tt.

    lt_lines = mo_cut->build( iv_rma = 'R-1' iv_material = 'M1'
                              iv_quantity = '5' iv_reason = 'DAMAGED' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ] exp = 'RMA: R-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ] exp = 'MATERIAL: M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 3 ] exp = 'QUANTITY: 5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 4 ] exp = 'REASON: DAMAGED' ).
  ENDMETHOD.

  METHOD skips_blank.
    DATA lt_lines TYPE zcl_alloc_return_label=>ty_lines_tt.

    lt_lines = mo_cut->build( iv_rma = 'R-2' iv_material = 'M1'
                              iv_quantity = '5' iv_reason = '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 3 ] exp = 'QUANTITY: 5' ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_lines TYPE zcl_alloc_return_label=>ty_lines_tt.

    lt_lines = mo_cut->build( iv_rma = '' iv_material = ''
                              iv_quantity = '' iv_reason = '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
