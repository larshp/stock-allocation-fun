CLASS ltcl_alloc_idoc_reader DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_idoc_reader.

    METHODS setup.

    METHODS empty_input   FOR TESTING.
    METHODS reads_segments FOR TESTING.
    METHODS missing_header FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_idoc_reader IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_idoc_reader( ).
  ENDMETHOD.

  METHOD empty_input.
    DATA ls_input TYPE zcl_alloc_idoc_reader=>ty_input.

    DATA(rs_result) = mo_cut->read( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-valid
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-messages[ 1 ]
                                        exp = 'Header segment missing' ).
  ENDMETHOD.

  METHOD reads_segments.
    DATA ls_input TYPE zcl_alloc_idoc_reader=>ty_input.

    APPEND 'EDI_DC40' TO ls_input-segments.
    APPEND 'E1EDP19:MAT-1' TO ls_input-segments.
    APPEND 'E1EDP26:5' TO ls_input-segments.

    DATA(rs_result) = mo_cut->read( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-valid
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-matnr
                                        exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-quantity
                                        exp = '5' ).
  ENDMETHOD.

  METHOD missing_header.
    DATA ls_input TYPE zcl_alloc_idoc_reader=>ty_input.

    APPEND 'E1EDP19:MAT-1' TO ls_input-segments.

    DATA(rs_result) = mo_cut->read( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-valid
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-matnr
                                        exp = 'MAT-1' ).
  ENDMETHOD.

ENDCLASS.
