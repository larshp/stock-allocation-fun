CLASS zcl_alloc_val_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
             price    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             line_count  TYPE i,
             total_value TYPE i,
           END OF ty_result.

    METHODS build
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_value
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_run IMPLEMENTATION.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total_value.
    DATA lv_value TYPE i.

    " The run values every line at its own price.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_value = ls_line-quantity * ls_line-price.
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The result carries how many lines were valued and what they are worth.
    rs_result-line_count = line_count( it_lines ).
    rs_result-total_value = total_value( it_lines ).
  ENDMETHOD.

ENDCLASS.
