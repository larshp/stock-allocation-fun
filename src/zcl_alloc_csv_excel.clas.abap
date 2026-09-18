CLASS zcl_alloc_csv_excel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS separator
      RETURNING
        VALUE(rv_separator) TYPE string.

    METHODS hint
      RETURNING
        VALUE(rv_hint) TYPE string.

    METHODS render
      IMPORTING
        it_rows         TYPE zcl_alloc_csv_export=>ty_row_tt
        it_columns      TYPE zcl_alloc_columns=>ty_column_tt
      RETURNING
        VALUE(rt_lines) TYPE zcl_alloc_csv_export=>ty_text_tt.

  PRIVATE SECTION.
    CONSTANTS c_separator TYPE string VALUE ';'.
    CONSTANTS c_hint      TYPE string VALUE 'sep=;'.

ENDCLASS.


CLASS zcl_alloc_csv_excel IMPLEMENTATION.

  METHOD separator.
    rv_separator = c_separator.
  ENDMETHOD.

  METHOD hint.
    rv_hint = c_hint.
  ENDMETHOD.

  METHOD render.
    DATA lo_csv   TYPE REF TO zcl_alloc_csv_export.
    DATA lt_lines TYPE zcl_alloc_csv_export=>ty_text_tt.
    DATA lv_line  TYPE string.

    " Spreadsheet programs that expect a semicolon look for this hint line.
    APPEND c_hint TO rt_lines.

    lo_csv = NEW zcl_alloc_csv_export( ).
    lt_lines = lo_csv->render( it_rows      = it_rows
                               it_columns   = it_columns
                               iv_separator = c_separator ).

    LOOP AT lt_lines INTO lv_line.
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
