CLASS ltcl_alloc_note_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_note_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_note_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_note_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_notes )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_note  TYPE zcl_alloc_annotation=>ty_note.

    ls_note-run_id = 'R1'.
    ls_note-matnr = 'MAT-1'.
    ls_note-text = 'Check first'.
    APPEND ls_note TO lt_notes.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_notes )
      exp = '[{"run_id":"R1","matnr":"MAT-1","text":"Check first"}]' ).
  ENDMETHOD.

ENDCLASS.
