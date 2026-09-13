CLASS zcl_alloc_note_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_notes        TYPE zcl_alloc_annotation=>ty_note_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_note_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'RUN_ID' TO lt_fields.
    APPEND 'MATNR' TO lt_fields.
    APPEND 'TEXT' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_notes INTO DATA(ls_note).
      CLEAR lt_fields.
      APPEND |{ ls_note-run_id }| TO lt_fields.
      APPEND |{ ls_note-matnr }| TO lt_fields.
      APPEND |{ ls_note-text }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
