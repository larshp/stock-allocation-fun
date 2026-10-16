CLASS zcl_alloc_wip_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             order_count TYPE i,
             total       TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

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


CLASS zcl_alloc_wip_summary IMPLEMENTATION.

  METHOD order_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total.
    " The summary adds the value of every order.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the orders and totals their value.
    rs_summary-order_count = order_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
