CLASS zcl_alloc_abc_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             activity TYPE string,
             cost     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_line_tt.

    METHODS total_cost
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_abc_report IMPLEMENTATION.

  METHOD build.
    " Every activity is carried into the report with its cost.
    LOOP AT it_lines INTO DATA(ls_line).
      APPEND ls_line TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_cost.
    " The report total adds the cost of every activity.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
