CLASS zcl_alloc_colwidth DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_width,
             field_name TYPE string,
             width      TYPE i,
           END OF ty_width.
    TYPES ty_width_tt TYPE STANDARD TABLE OF ty_width WITH DEFAULT KEY.

    METHODS fit
      IMPORTING
        it_rows          TYPE zcl_alloc_csv_export=>ty_row_tt
        it_columns       TYPE zcl_alloc_columns=>ty_column_tt
        iv_max_width     TYPE i
      RETURNING
        VALUE(rt_widths) TYPE ty_width_tt.

  PRIVATE SECTION.
    CONSTANTS c_min_width TYPE i VALUE 1.

ENDCLASS.


CLASS zcl_alloc_colwidth IMPLEMENTATION.

  METHOD fit.
    DATA ls_width TYPE ty_width.
    DATA lv_len   TYPE i.

    LOOP AT it_columns INTO DATA(ls_column).
      CLEAR ls_width.
      ls_width-field_name = ls_column-field_name.
      ls_width-width = strlen( ls_column-title ).

      LOOP AT it_rows INTO DATA(ls_row).
        READ TABLE ls_row-values INTO DATA(ls_value)
          WITH KEY field_name = ls_column-field_name.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        lv_len = strlen( ls_value-text ).
        IF lv_len > ls_width-width.
          ls_width-width = lv_len.
        ENDIF.
      ENDLOOP.

      " An explicit maximum wins, but a column always stays at least one wide.
      IF iv_max_width > 0 AND ls_width-width > iv_max_width.
        ls_width-width = iv_max_width.
      ENDIF.

      IF ls_width-width < c_min_width.
        ls_width-width = c_min_width.
      ENDIF.

      APPEND ls_width TO rt_widths.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
