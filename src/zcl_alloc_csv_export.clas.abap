CLASS zcl_alloc_csv_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_value,
             field_name TYPE string,
             text       TYPE string,
           END OF ty_value.
    TYPES ty_value_tt TYPE STANDARD TABLE OF ty_value WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             values TYPE ty_value_tt,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS render
      IMPORTING
        it_rows         TYPE ty_row_tt
        it_columns      TYPE zcl_alloc_columns=>ty_column_tt
        iv_separator    TYPE string
      RETURNING
        VALUE(rt_lines) TYPE ty_text_tt.

    METHODS escape
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    CONSTANTS c_quote TYPE string VALUE '"'.

ENDCLASS.


CLASS zcl_alloc_csv_export IMPLEMENTATION.

  METHOD escape.
    DATA lv_len   TYPE i.
    DATA lv_pos   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_char  TYPE string.
    DATA lv_found TYPE abap_bool.

    rv_text = iv_text.
    lv_len = strlen( iv_text ).

    " A value only needs quoting when it contains a quote itself.
    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char = c_quote.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDWHILE.

    IF lv_found = abap_false.
      RETURN.
    ENDIF.

    " Quote the value and double every inner quote.
    CLEAR rv_text.
    rv_text = c_quote.
    lv_pos = 0.

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      rv_text = rv_text && lv_char.

      IF lv_char = c_quote.
        rv_text = rv_text && c_quote.
      ENDIF.
    ENDWHILE.

    rv_text = rv_text && c_quote.
  ENDMETHOD.

  METHOD render.
    DATA lv_line  TYPE string.
    DATA lv_cell  TYPE string.
    DATA lv_first TYPE abap_bool.

    " The first line holds the column titles.
    lv_first = abap_true.
    LOOP AT it_columns INTO DATA(ls_column).
      lv_cell = escape( iv_text = ls_column-title ).

      IF lv_first = abap_true.
        lv_line = lv_cell.
        lv_first = abap_false.
      ELSE.
        lv_line = lv_line && iv_separator.
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
          lv_cell = escape( iv_text = ls_value-text ).
        ENDIF.

        IF lv_first = abap_true.
          lv_line = lv_cell.
          lv_first = abap_false.
        ELSE.
          lv_line = lv_line && iv_separator.
          lv_line = lv_line && lv_cell.
        ENDIF.
      ENDLOOP.

      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
