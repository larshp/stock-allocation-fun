CLASS ltcl_alloc_note_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_note_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_note_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_note_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.

    DATA(lt_lines) = mo_cut->build( lt_notes ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'RUN_ID;MATNR;TEXT' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_note  TYPE zcl_alloc_annotation=>ty_note.

    ls_note-run_id = 'R1'.
    ls_note-matnr = 'MAT-1'.
    ls_note-text = 'Check first'.
    APPEND ls_note TO lt_notes.

    DATA(lt_lines) = mo_cut->build( lt_notes ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'R1;MAT-1;Check first' ).
  ENDMETHOD.

ENDCLASS.
