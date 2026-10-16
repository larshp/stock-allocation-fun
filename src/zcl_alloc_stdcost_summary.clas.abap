CLASS zcl_alloc_stdcost_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             item TYPE string,
             cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             item_count TYPE i,
             total      TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS item_count
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


CLASS zcl_alloc_stdcost_summary IMPLEMENTATION.

  METHOD item_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total.
    " The summary adds the standard cost of every item.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the items and totals their standard cost.
    rs_summary-item_count = item_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
