CLASS zcl_alloc_prep_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
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


CLASS zcl_alloc_prep_rank IMPLEMENTATION.

  METHOD rank.
    " The most costly order comes first, the cheapest last.
    rt_lines = it_lines.
    SORT rt_lines BY cost DESCENDING.
  ENDMETHOD.

  METHOD worst.
    " The worst order costs the most.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-cost > rv_worst.
        rv_worst = ls_line-cost.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD best.
    DATA lv_seen TYPE abap_bool.

    " The best order costs the least.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_false OR ls_line-cost < rv_best.
        rv_best = ls_line-cost.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
