CLASS ltcl_alloc_diff3_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_diff3_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_diff3_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_diff3_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_lines TYPE zcl_alloc_diff3=>ty_line_tt.

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]
      exp = 'ID;BASE_QTY;LEFT_QTY;RIGHT_QTY;STATUS' ).
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

    DATA(lt_result) = mo_cut->build( lt_lines ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]
                                        exp = 'REQ-1;10.000;6.000;4.000;C' ).
  ENDMETHOD.

ENDCLASS.
