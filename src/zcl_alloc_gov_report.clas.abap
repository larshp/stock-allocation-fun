CLASS zcl_alloc_gov_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key  TYPE string,
             open TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             key    TYPE string,
             open   TYPE abap_bool,
             status TYPE string,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS item_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS open_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_report IMPLEMENTATION.

  METHOD build.
    DATA ls_row TYPE ty_row.

    " Every item is carried into the report with its status.
    LOOP AT it_lines INTO DATA(ls_line).
      CLEAR ls_row.
      ls_row-key = ls_line-key.
      ls_row-open = ls_line-open.
      IF ls_line-open = abap_true.
        ls_row-status = 'OPEN'.
      ELSE.
        ls_row-status = 'CLOSED'.
      ENDIF.
      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD item_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD open_count.
    " The open count gathers the items still in flight.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-open = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
