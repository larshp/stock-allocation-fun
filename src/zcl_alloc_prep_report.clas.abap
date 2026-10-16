CLASS zcl_alloc_prep_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_report,
             order_count TYPE i,
             total       TYPE i,
           END OF ty_report.

    METHODS build
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rs_report) TYPE ty_report.

    METHODS order_count
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


CLASS zcl_alloc_prep_report IMPLEMENTATION.

  METHOD order_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total.
    " The report adds the cost of every order.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The report counts the orders and totals their cost.
    rs_report-order_count = order_count( it_lines ).
    rs_report-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
