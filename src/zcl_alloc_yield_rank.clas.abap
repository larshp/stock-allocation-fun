CLASS zcl_alloc_yield_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             percent  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS best
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_best) TYPE i.

    METHODS worst
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_worst) TYPE i.

ENDCLASS.


CLASS zcl_alloc_yield_rank IMPLEMENTATION.

  METHOD rank.
    " The best yield comes first, the worst last.
    rt_lines = it_lines.
    SORT rt_lines BY percent DESCENDING.
  ENDMETHOD.

  METHOD best.
    " The best yield out of the orders.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-percent > rv_best.
        rv_best = ls_line-percent.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD worst.
    DATA lv_seen TYPE abap_bool.

    " The worst yield out of the orders.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_false OR ls_line-percent < rv_worst.
        rv_worst = ls_line-percent.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
