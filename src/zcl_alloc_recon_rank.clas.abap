CLASS zcl_alloc_recon_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key  TYPE string,
             diff TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_rank,
             key       TYPE string,
             diff      TYPE i,
             magnitude TYPE i,
           END OF ty_rank.
    TYPES ty_rank_tt TYPE STANDARD TABLE OF ty_rank WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_ranks) TYPE ty_rank_tt.

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


CLASS zcl_alloc_recon_rank IMPLEMENTATION.

  METHOD rank.
    DATA ls_rank TYPE ty_rank.

    " Differences are ranked by their size, the biggest first.
    LOOP AT it_lines INTO DATA(ls_line).
      CLEAR ls_rank.
      ls_rank-key = ls_line-key.
      ls_rank-diff = ls_line-diff.
      ls_rank-magnitude = ls_line-diff.
      IF ls_rank-magnitude < 0.
        ls_rank-magnitude = -1 * ls_rank-magnitude.
      ENDIF.
      APPEND ls_rank TO rt_ranks.
    ENDLOOP.

    SORT rt_ranks BY magnitude DESCENDING.
  ENDMETHOD.

  METHOD worst.
    DATA lv_size TYPE i.

    " The worst difference is the biggest one, whichever way it goes.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_size = ls_line-diff.
      IF lv_size < 0.
        lv_size = -1 * lv_size.
      ENDIF.
      IF lv_size > rv_worst.
        rv_worst = lv_size.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD best.
    DATA lv_size TYPE i.
    DATA lv_seen TYPE abap_bool.

    " The best difference is the smallest one, whichever way it goes.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_size = ls_line-diff.
      IF lv_size < 0.
        lv_size = -1 * lv_size.
      ENDIF.
      IF lv_seen = abap_false OR lv_size < rv_best.
        rv_best = lv_size.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
