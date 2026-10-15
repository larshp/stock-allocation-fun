CLASS zcl_alloc_recon_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key  TYPE string,
             diff TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             key       TYPE string,
             diff      TYPE i,
             magnitude TYPE i,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS diff_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_diff
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recon_report IMPLEMENTATION.

  METHOD build.
    DATA ls_row TYPE ty_row.

    " Every difference is carried into the report with its size.
    LOOP AT it_lines INTO DATA(ls_line).
      CLEAR ls_row.
      ls_row-key = ls_line-key.
      ls_row-diff = ls_line-diff.
      ls_row-magnitude = ls_line-diff.
      IF ls_row-magnitude < 0.
        ls_row-magnitude = -1 * ls_row-magnitude.
      ENDIF.
      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD diff_count.
    " The count gathers the differences that are not zero.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-diff <> 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_diff.
    DATA lv_size TYPE i.

    " The total adds the size of every difference.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_size = ls_line-diff.
      IF lv_size < 0.
        lv_size = -1 * lv_size.
      ENDIF.
      rv_total = rv_total + lv_size.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
