CLASS zcl_alloc_tsv_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS separator
      RETURNING
        VALUE(rv_separator) TYPE string.

    METHODS clean
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS render
      IMPORTING
        it_rows         TYPE zcl_alloc_csv_export=>ty_row_tt
        it_columns      TYPE zcl_alloc_columns=>ty_column_tt
      RETURNING
        VALUE(rt_lines) TYPE zcl_alloc_csv_export=>ty_text_tt.

  PRIVATE SECTION.
    CONSTANTS c_quote TYPE string VALUE '"'.
    CONSTANTS c_apos  TYPE string VALUE `'`.

ENDCLASS.


CLASS zcl_alloc_tsv_export IMPLEMENTATION.

  METHOD separator.
    " A tab, taken from the character utilities so no literal is needed.
    rv_separator = cl_abap_char_utilities=>horizontal_tab.
  ENDMETHOD.

  METHOD clean.
    DATA lv_tab  TYPE string.
    DATA lv_blank TYPE string.
    DATA lv_len  TYPE i.
    DATA lv_pos  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.

    " TSV has no quoting convention, so anything that could break the
    " structure is replaced: a tab becomes a blank, a quote an apostrophe.
    lv_tab = separator( ).
    lv_blank = ` `.
    lv_len = strlen( iv_text ).

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char = lv_tab.
        rv_text = rv_text && lv_blank.
      ELSEIF lv_char = c_quote.
        rv_text = rv_text && c_apos.
      ELSE.
        rv_text = rv_text && lv_char.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD render.
    DATA lv_sep   TYPE string.
    DATA lv_line  TYPE string.
    DATA lv_cell  TYPE string.
    DATA lv_first TYPE abap_bool.

    lv_sep = separator( ).

    lv_first = abap_true.
    LOOP AT it_columns INTO DATA(ls_column).
      lv_cell = clean( iv_text = ls_column-title ).

      IF lv_first = abap_true.
        lv_line = lv_cell.
        lv_first = abap_false.
      ELSE.
        lv_line = lv_line && lv_sep.
        lv_line = lv_line && lv_cell.
      ENDIF.
    ENDLOOP.

    IF strlen( lv_line ) > 0.
      APPEND lv_line TO rt_lines.
    ENDIF.

    LOOP AT it_rows INTO DATA(ls_row).
      CLEAR lv_line.
      lv_first = abap_true.

      LOOP AT it_columns INTO ls_column.
        READ TABLE ls_row-values INTO DATA(ls_value)
          WITH KEY field_name = ls_column-field_name.

        CLEAR lv_cell.
        IF sy-subrc = 0.
          lv_cell = clean( iv_text = ls_value-text ).
        ENDIF.

        IF lv_first = abap_true.
          lv_line = lv_cell.
          lv_first = abap_false.
        ELSE.
          lv_line = lv_line && lv_sep.
          lv_line = lv_line && lv_cell.
        ENDIF.
      ENDLOOP.

      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
