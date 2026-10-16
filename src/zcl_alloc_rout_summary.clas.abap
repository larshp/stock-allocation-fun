CLASS zcl_alloc_rout_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             operation TYPE string,
             time      TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             operation_count TYPE i,
             total_time      TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS operation_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_time
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_time) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_summary IMPLEMENTATION.

  METHOD operation_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total_time.
    " The summary adds the time of every operation.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_time = rv_time + ls_line-time.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the operations and totals their time.
    rs_summary-operation_count = operation_count( it_lines ).
    rs_summary-total_time = total_time( it_lines ).
  ENDMETHOD.

ENDCLASS.
