CLASS zcl_alloc_return_note DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_notes        TYPE ty_text_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_text_tt.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_text_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS has_text
      IMPORTING
        it_lines     TYPE ty_text_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_note IMPLEMENTATION.

  METHOD build.
    " Blank note lines carry nothing and are dropped from the note text.
    LOOP AT it_notes INTO DATA(lv_note).
      IF lv_note IS INITIAL.
        CONTINUE.
      ENDIF.

      APPEND lv_note TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD has_text.
    rv_ok = xsdbool( lines( it_lines ) > 0 ).
  ENDMETHOD.

ENDCLASS.
