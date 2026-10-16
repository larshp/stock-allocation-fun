CLASS zcl_alloc_val_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material  TYPE matnr,
             quantity  TYPE i,
             unit_cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS row_count
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_value
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_report IMPLEMENTATION.

  METHOD build.
    DATA ls_row TYPE ty_row.

    " Every report line values its quantity at its unit cost.
    LOOP AT it_lines INTO DATA(ls_line).
      ls_row-material = ls_line-material.
      ls_row-value = ls_line-quantity * ls_line-unit_cost.
      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD row_count.
    rv_count = lines( it_rows ).
  ENDMETHOD.

  METHOD total_value.
    " The report total adds the value of every row.
    LOOP AT it_rows INTO DATA(ls_row).
      rv_total = rv_total + ls_row-value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
