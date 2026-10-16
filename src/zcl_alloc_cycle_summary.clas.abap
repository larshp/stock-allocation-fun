CLASS zcl_alloc_cycle_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name   TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             step_count TYPE i,
             total      TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS step_count
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


CLASS zcl_alloc_cycle_summary IMPLEMENTATION.

  METHOD step_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total.
    " The summary total adds the amount carried by every step.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-amount.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the steps and totals their amounts.
    rs_summary-step_count = step_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
