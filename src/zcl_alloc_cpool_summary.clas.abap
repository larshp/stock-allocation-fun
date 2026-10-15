CLASS zcl_alloc_cpool_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             pool TYPE string,
             cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             pool_count TYPE i,
             total      TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS pool_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_summary IMPLEMENTATION.

  METHOD pool_count.
    DATA lt_line TYPE SORTED TABLE OF ty_line WITH UNIQUE KEY pool.
    DATA ls_line TYPE ty_line.

    " The count is the number of distinct cost pools.
    LOOP AT it_lines INTO DATA(ls_in).
      CLEAR ls_line.
      ls_line-pool = ls_in-pool.
      INSERT ls_line INTO TABLE lt_line.
    ENDLOOP.

    rv_count = lines( lt_line ).
  ENDMETHOD.

  METHOD total.
    " The summary total adds the cost of every pool line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the pools and totals their cost.
    rs_summary-pool_count = pool_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
