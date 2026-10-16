CLASS zcl_alloc_settle_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             item   TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS worst
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_worst) TYPE i.

    METHODS best
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_best) TYPE i.

ENDCLASS.


CLASS zcl_alloc_settle_rank IMPLEMENTATION.

  METHOD rank.
    " The largest difference comes first, the smallest last.
    rt_lines = it_lines.
    SORT rt_lines BY amount DESCENDING.
  ENDMETHOD.

  METHOD worst.
    " The worst difference is the largest one.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-amount > rv_worst.
        rv_worst = ls_line-amount.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD best.
    DATA lv_seen TYPE abap_bool.

    " The best difference is the smallest one.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_false OR ls_line-amount < rv_best.
        rv_best = ls_line-amount.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
