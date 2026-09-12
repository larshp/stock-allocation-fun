CLASS ltcl_alloc_annotation DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_annotation.

    METHODS setup.

    METHODS note
      IMPORTING
        iv_run_id     TYPE zstock_run_id
        iv_matnr      TYPE matnr
        iv_text       TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_annotation=>ty_note.

    METHODS add_new            FOR TESTING.
    METHODS replace_existing   FOR TESTING.
    METHODS read_existing      FOR TESTING.
    METHODS read_missing_empty FOR TESTING.
    METHODS key_includes_run_id FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_annotation IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_annotation( ).
  ENDMETHOD.

  METHOD note.
    rs_row-run_id = iv_run_id.
    rs_row-matnr = iv_matnr.
    rs_row-text = iv_text.
  ENDMETHOD.

  METHOD add_new.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_input TYPE zcl_alloc_annotation=>ty_add_input.

    ls_input-notes = lt_notes.
    ls_input-note = note( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                          iv_text = 'CHECK FIRST' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
  ENDMETHOD.

  METHOD replace_existing.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_input TYPE zcl_alloc_annotation=>ty_add_input.

    APPEND note( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                 iv_text = 'OLD' ) TO lt_notes.

    ls_input-notes = lt_notes.
    ls_input-note = note( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                          iv_text = 'NEW' ).

    DATA(lt_new) = mo_cut->add( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_new ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_new[ 1 ]-text exp = 'NEW' ).
  ENDMETHOD.

  METHOD read_existing.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_query TYPE zcl_alloc_annotation=>ty_query.

    APPEND note( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                 iv_text = 'HELLO' ) TO lt_notes.

    ls_query-notes = lt_notes.
    ls_query-run_id = 'R1'.
    ls_query-matnr = 'MAT-1'.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->read( ls_query )
                                        exp = 'HELLO' ).
  ENDMETHOD.

  METHOD read_missing_empty.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_query TYPE zcl_alloc_annotation=>ty_query.

    ls_query-notes = lt_notes.
    ls_query-run_id = 'R1'.
    ls_query-matnr = 'MAT-1'.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->read( ls_query )
                                        exp = '' ).
  ENDMETHOD.

  METHOD key_includes_run_id.
    DATA lt_notes TYPE zcl_alloc_annotation=>ty_note_tt.
    DATA ls_query TYPE zcl_alloc_annotation=>ty_query.

    APPEND note( iv_run_id = 'R1' iv_matnr = 'MAT-1'
                 iv_text = 'FIRST' ) TO lt_notes.
    APPEND note( iv_run_id = 'R2' iv_matnr = 'MAT-1'
                 iv_text = 'SECOND' ) TO lt_notes.

    ls_query-notes = lt_notes.
    ls_query-run_id = 'R2'.
    ls_query-matnr = 'MAT-1'.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->read( ls_query )
                                        exp = 'SECOND' ).
  ENDMETHOD.

ENDCLASS.
