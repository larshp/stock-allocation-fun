CLASS zcl_alloc_cobj_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             object TYPE string,
             margin TYPE i,
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


CLASS zcl_alloc_cobj_rank IMPLEMENTATION.

  METHOD rank.
    " The best margin comes first, the worst last.
    rt_lines = it_lines.
    SORT rt_lines BY margin DESCENDING.
  ENDMETHOD.

  METHOD best.
    " The best object carries the biggest margin.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-margin > rv_best.
        rv_best = ls_line-margin.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD worst.
    DATA lv_seen TYPE abap_bool.

    " The worst object carries the smallest margin.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_false OR ls_line-margin < rv_worst.
        rv_worst = ls_line-margin.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
