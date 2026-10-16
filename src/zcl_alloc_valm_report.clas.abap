CLASS zcl_alloc_valm_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_rows,
             total        TYPE i,
             breach_count TYPE i,
           END OF ty_rows.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
        iv_threshold   TYPE i
      RETURNING
        VALUE(rs_rows) TYPE ty_rows.

    METHODS breach_count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_valm_report IMPLEMENTATION.

  METHOD total.
    " The monitoring total adds the value of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD breach_count.
    " A breach is a line whose value has grown past the threshold.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-value <= iv_threshold.
        CONTINUE.
      ENDIF.

      rv_count = rv_count + 1.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The report carries the total and how many lines breached it.
    rs_rows-total = total( it_lines ).
    rs_rows-breach_count = breach_count( it_lines     = it_lines
                                         iv_threshold = iv_threshold ).
  ENDMETHOD.

ENDCLASS.
