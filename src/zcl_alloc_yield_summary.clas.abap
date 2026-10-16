CLASS zcl_alloc_yield_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             percent  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             order_count TYPE i,
             average     TYPE i,
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

    METHODS average
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rv_average) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_summary IMPLEMENTATION.

  METHOD order_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD average.
    DATA lv_total TYPE i.
    DATA lv_sum TYPE i.

    " The average yield across the orders.
    lv_total = lines( it_lines ).
    IF lv_total = 0.
      RETURN.
    ENDIF.

    LOOP AT it_lines INTO DATA(ls_line).
      lv_sum = lv_sum + ls_line-percent.
    ENDLOOP.

    rv_average = lv_sum DIV lv_total.
  ENDMETHOD.

  METHOD build.
    " The summary counts the orders and averages their yield.
    rs_summary-order_count = order_count( it_lines ).
    rs_summary-average = average( it_lines ).
  ENDMETHOD.

ENDCLASS.
