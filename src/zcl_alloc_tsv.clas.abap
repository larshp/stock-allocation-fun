CLASS zcl_alloc_tsv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS separator
      RETURNING
        VALUE(rv_separator) TYPE string.

    METHODS join
      IMPORTING
        it_cells       TYPE zcl_alloc_csv_export=>ty_text_tt
      RETURNING
        VALUE(rv_line) TYPE string.

    METHODS split
      IMPORTING
        iv_line         TYPE string
      RETURNING
        VALUE(rt_cells) TYPE zcl_alloc_csv_export=>ty_text_tt.

    METHODS cell_count
      IMPORTING
        iv_line         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_tsv IMPLEMENTATION.

  METHOD separator.
    " A tab, taken from the character utilities so no literal is needed.
    rv_separator = cl_abap_char_utilities=>horizontal_tab.
  ENDMETHOD.

  METHOD join.
    DATA lv_sep   TYPE string.
    DATA lv_first TYPE abap_bool.

    lv_sep = separator( ).
    lv_first = abap_true.

    LOOP AT it_cells INTO DATA(lv_cell).
      IF lv_first = abap_true.
        rv_line = lv_cell.
        lv_first = abap_false.
      ELSE.
        rv_line = rv_line && lv_sep.
        rv_line = rv_line && lv_cell.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD split.
    DATA lv_sep  TYPE string.
    DATA lv_len  TYPE i.
    DATA lv_pos  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.
    DATA lv_cell TYPE string.

    IF iv_line IS INITIAL.
      RETURN.
    ENDIF.

    lv_sep = separator( ).
    lv_len = strlen( iv_line ).

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_line off = lv_off len = 1 ).

      IF lv_char = lv_sep.
        APPEND lv_cell TO rt_cells.
        CLEAR lv_cell.
        CONTINUE.
      ENDIF.

      lv_cell = lv_cell && lv_char.
    ENDWHILE.

    APPEND lv_cell TO rt_cells.
  ENDMETHOD.

  METHOD cell_count.
    DATA lt_cells TYPE zcl_alloc_csv_export=>ty_text_tt.

    IF iv_line IS INITIAL.
      RETURN.
    ENDIF.

    lt_cells = split( iv_line ).
    rv_count = lines( lt_cells ).
  ENDMETHOD.

ENDCLASS.
