CLASS zcl_alloc_po_create DEFINITION
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

    TYPES: BEGIN OF ty_po,
             doc_no      TYPE string,
             line_count  TYPE i,
             total_value TYPE i,
           END OF ty_po.

    METHODS build
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_doc_no    TYPE string
      RETURNING
        VALUE(rs_po) TYPE ty_po.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_value
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_value) TYPE i.

ENDCLASS.


CLASS zcl_alloc_po_create IMPLEMENTATION.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total_value.
    " The order value is the quantity times the price of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_value = rv_value + ls_line-quantity * ls_line-price.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    rs_po-doc_no = iv_doc_no.
    rs_po-line_count = line_count( it_lines ).
    rs_po-total_value = total_value( it_lines ).
  ENDMETHOD.

ENDCLASS.
