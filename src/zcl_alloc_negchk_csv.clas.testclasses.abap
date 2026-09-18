CLASS ltcl_alloc_negchk_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_negchk_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_row     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_negchk_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_negchk_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.

    DATA(lt_lines) = mo_cut->build( lt_rows ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'ID;QUANTITY' ).
  ENDMETHOD.

  METHOD one_row.
    DATA lt_rows TYPE zcl_alloc_negative_check=>ty_row_tt.
    DATA ls_row  TYPE zcl_alloc_negative_check=>ty_row.

    ls_row-id = 'REQ-1'.
    ls_row-quantity = '-3'.
    APPEND ls_row TO lt_rows.

    DATA(lt_lines) = mo_cut->build( lt_rows ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'REQ-1;-3.000' ).
  ENDMETHOD.

ENDCLASS.
