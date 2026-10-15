CLASS zcl_alloc_margin_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             revenue  TYPE i,
             cogs     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             line_count   TYPE i,
             total_margin TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS total_margin
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


CLASS zcl_alloc_margin_summary IMPLEMENTATION.

  METHOD total_margin.
    " Every line adds its revenue less its cost of goods to the margin.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-revenue - ls_line-cogs.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD build.
    " The summary counts the lines and totals their margin.
    rs_summary-line_count = line_count( it_lines ).
    rs_summary-total_margin = total_margin( it_lines ).
  ENDMETHOD.

ENDCLASS.
