CLASS zcl_alloc_replenish_dash DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             label TYPE string,
             value TYPE i,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

    METHODS line_count
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS join
      IMPORTING
        it_lines       TYPE ty_lines_tt
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_replenish_dash IMPLEMENTATION.

  METHOD build.
    DATA lv_text TYPE string.

    " Each dashboard row becomes a labelled text line.
    LOOP AT it_rows INTO DATA(ls_row).
      lv_text = |{ ls_row-label }: { ls_row-value }|.
      APPEND lv_text TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_rows ).
  ENDMETHOD.

  METHOD join.
    DATA lv_text TYPE string.

    " The lines are joined with a semicolon and a blank between them.
    LOOP AT it_lines INTO DATA(lv_line).
      IF lv_text IS INITIAL.
        lv_text = lv_line.
      ELSE.
        lv_text = |{ lv_text }; { lv_line }|.
      ENDIF.
    ENDLOOP.

    rv_text = lv_text.
  ENDMETHOD.

ENDCLASS.
