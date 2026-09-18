CLASS zcl_alloc_release_notes DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             version TYPE string,
             kind    TYPE string,
             text    TYPE string,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_note,
             seq     TYPE i,
             version TYPE string,
             kind    TYPE string,
             text    TYPE string,
           END OF ty_note.
    TYPES ty_note_tt TYPE STANDARD TABLE OF ty_note WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_count,
             kind   TYPE string,
             amount TYPE i,
           END OF ty_count.
    TYPES ty_count_tt TYPE STANDARD TABLE OF ty_count WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_entries      TYPE ty_entry_tt
      RETURNING
        VALUE(rt_notes) TYPE ty_note_tt.

    METHODS count_of
      IMPORTING
        it_notes        TYPE ty_note_tt
        iv_kind         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS titles_of
      IMPORTING
        it_notes         TYPE ty_note_tt
      RETURNING
        VALUE(rt_titles) TYPE zcl_alloc_csv_export=>ty_text_tt.

  PRIVATE SECTION.
    METHODS has_title
      IMPORTING
        it_titles     TYPE zcl_alloc_csv_export=>ty_text_tt
        iv_title      TYPE string
      RETURNING
        VALUE(rv_hit) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_release_notes IMPLEMENTATION.

  METHOD has_title.
    LOOP AT it_titles INTO DATA(lv_title).
      IF lv_title = iv_title.
        rv_hit = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    DATA ls_note TYPE ty_note.

    LOOP AT it_entries INTO DATA(ls_entry).
      " An entry without text carries no information for the reader.
      IF ls_entry-text IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR ls_note.
      ls_note-seq = lines( rt_notes ) + 1.
      ls_note-version = ls_entry-version.
      ls_note-kind = ls_entry-kind.
      ls_note-text = ls_entry-text.
      APPEND ls_note TO rt_notes.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_of.
    LOOP AT it_notes INTO DATA(ls_note).
      IF ls_note-kind = iv_kind.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD titles_of.
    LOOP AT it_notes INTO DATA(ls_note).
      IF has_title( it_titles = rt_titles iv_title = ls_note-version ) = abap_true.
        CONTINUE.
      ENDIF.

      APPEND ls_note-version TO rt_titles.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
