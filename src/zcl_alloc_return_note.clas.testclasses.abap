CLASS ltcl_alloc_return_note DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_note.
    DATA mt_not TYPE zcl_alloc_return_note=>ty_text_tt.

    METHODS setup.

    METHODS drops_blank   FOR TESTING.
    METHODS counts_lines  FOR TESTING.
    METHODS flags_text    FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_note IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_note( ).
  ENDMETHOD.

  METHOD drops_blank.
    DATA lt_lines TYPE zcl_alloc_return_note=>ty_text_tt.

    APPEND 'hello' TO mt_not.
    APPEND '' TO mt_not.
    APPEND 'world' TO mt_not.

    lt_lines = mo_cut->build( mt_not ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ] exp = 'hello' ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ] exp = 'world' ).
  ENDMETHOD.

  METHOD counts_lines.
    APPEND 'hello' TO mt_not.
    APPEND 'world' TO mt_not.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_not ) exp = 2 ).
  ENDMETHOD.

  METHOD flags_text.
    APPEND 'hello' TO mt_not.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_text( mt_not ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->has_text( mt_not ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_not ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
