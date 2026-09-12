CLASS zcl_alloc_annotation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text TYPE c LENGTH 60.

    TYPES: BEGIN OF ty_note,
             run_id TYPE zstock_run_id,
             matnr  TYPE matnr,
             text   TYPE ty_text,
           END OF ty_note.
    TYPES ty_note_tt TYPE STANDARD TABLE OF ty_note WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_add_input,
             notes TYPE ty_note_tt,
             note  TYPE ty_note,
           END OF ty_add_input.

    TYPES: BEGIN OF ty_query,
             notes  TYPE ty_note_tt,
             run_id TYPE zstock_run_id,
             matnr  TYPE matnr,
           END OF ty_query.

    METHODS add
      IMPORTING
        is_add          TYPE ty_add_input
      RETURNING
        VALUE(rt_notes) TYPE ty_note_tt.

    METHODS read
      IMPORTING
        is_query       TYPE ty_query
      RETURNING
        VALUE(rv_text) TYPE ty_text.

ENDCLASS.


CLASS zcl_alloc_annotation IMPLEMENTATION.

  METHOD add.
    rt_notes = is_add-notes.

    READ TABLE rt_notes ASSIGNING FIELD-SYMBOL(<ls_note>)
      WITH KEY run_id = is_add-note-run_id
               matnr = is_add-note-matnr.
    IF sy-subrc = 0.
      <ls_note>-text = is_add-note-text.
    ELSE.
      APPEND is_add-note TO rt_notes.
    ENDIF.
  ENDMETHOD.

  METHOD read.
    READ TABLE is_query-notes INTO DATA(ls_note)
      WITH KEY run_id = is_query-run_id
               matnr = is_query-matnr.
    IF sy-subrc = 0.
      rv_text = ls_note-text.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
