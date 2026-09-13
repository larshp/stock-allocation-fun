CLASS ltcl_alloc_negchk_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_negchk_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_row    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_negchk_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_negchk_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_rows )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_row.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.
    DATA ls_row  TYPE zcl_alloc_negative_check=>ty_row.

    ls_row-id = 'REQ-1'.
    ls_row-quantity = '-3'.
    APPEND ls_row TO lt_rows.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_rows )
      exp = '[{"id":"REQ-1","quantity":-3.000}]' ).
  ENDMETHOD.

ENDCLASS.
