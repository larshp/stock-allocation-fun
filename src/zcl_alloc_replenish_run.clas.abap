CLASS zcl_alloc_replenish_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_run,
             line_count     TYPE i,
             total_quantity TYPE i,
           END OF ty_run.

    METHODS build
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rs_run) TYPE ty_run.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_quantity
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_run IMPLEMENTATION.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total_quantity.
    " The run quantity sums the proposal lines.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    rs_run-line_count = line_count( it_lines ).
    rs_run-total_quantity = total_quantity( it_lines ).
  ENDMETHOD.

ENDCLASS.
