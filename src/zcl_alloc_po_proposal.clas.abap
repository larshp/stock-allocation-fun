CLASS zcl_alloc_po_proposal DEFINITION
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

    TYPES: BEGIN OF ty_proposal,
             line_count  TYPE i,
             total_value TYPE i,
           END OF ty_proposal.

    METHODS build
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rs_proposal) TYPE ty_proposal.

    METHODS total_value
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_po_proposal IMPLEMENTATION.

  METHOD total_value.
    " The total value is the quantity times the price of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_value = rv_value + ls_line-quantity * ls_line-price.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD build.
    rs_proposal-line_count = line_count( it_lines ).
    rs_proposal-total_value = total_value( it_lines ).
  ENDMETHOD.

ENDCLASS.
