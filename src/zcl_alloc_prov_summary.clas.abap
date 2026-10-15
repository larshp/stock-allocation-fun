CLASS zcl_alloc_prov_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material  TYPE matnr,
             provision TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             line_count TYPE i,
             total      TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS total
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


CLASS zcl_alloc_prov_summary IMPLEMENTATION.

  METHOD total.
    " The summary carries the sum of every provision.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-provision.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD build.
    " The result counts the lines and totals their provisions.
    rs_summary-line_count = line_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
