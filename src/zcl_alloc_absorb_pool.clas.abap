CLASS zcl_alloc_absorb_pool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name TYPE string,
             cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS pool_total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS absorbed
      IMPORTING
        iv_pool            TYPE i
        iv_percent         TYPE i
      RETURNING
        VALUE(rv_absorbed) TYPE i.

    METHODS unabsorbed
      IMPORTING
        iv_pool              TYPE i
        iv_percent           TYPE i
      RETURNING
        VALUE(rv_unabsorbed) TYPE i.

ENDCLASS.


CLASS zcl_alloc_absorb_pool IMPLEMENTATION.

  METHOD pool_total.
    " The pool total adds up the overhead of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

  METHOD absorbed.
    " The absorbed part is the pool at its absorption percentage.
    rv_absorbed = iv_pool * iv_percent DIV 100.
  ENDMETHOD.

  METHOD unabsorbed.
    DATA lv_absorbed TYPE i.

    " What is left over once the absorbed part is taken off the pool.
    lv_absorbed = absorbed( iv_pool = iv_pool iv_percent = iv_percent ).
    rv_unabsorbed = iv_pool - lv_absorbed.
  ENDMETHOD.

ENDCLASS.
