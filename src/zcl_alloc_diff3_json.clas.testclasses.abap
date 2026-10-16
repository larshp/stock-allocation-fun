CLASS ltcl_alloc_diff3_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_diff3_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_diff3_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_diff3_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_lines TYPE zcl_alloc_diff3=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_lines )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_lines TYPE zcl_alloc_diff3=>ty_line_tt.
    DATA ls_line  TYPE zcl_alloc_diff3=>ty_line.

    ls_line-id = 'REQ-1'.
    ls_line-base_qty = '10'.
    ls_line-left_qty = '6'.
    ls_line-right_qty = '4'.
    ls_line-status = 'C'.
    APPEND ls_line TO lt_lines.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_lines )
      exp = '[{"id":"REQ-1","base_qty":10.000,"left_qty":6.000,' &&
            '"right_qty":4.000,"status":"C"}]' ).
  ENDMETHOD.

ENDCLASS.
