CLASS zcl_alloc_var_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             variance TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS worst
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rv_variance) TYPE i.

    METHODS best
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rv_variance) TYPE i.

ENDCLASS.


CLASS zcl_alloc_var_rank IMPLEMENTATION.

  METHOD rank.
    " The worst overspend comes first, the best saving last.
    rt_lines = it_lines.
    SORT rt_lines BY variance DESCENDING.
  ENDMETHOD.

  METHOD worst.
    " The worst variance is the largest one.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-variance > rv_variance.
        rv_variance = ls_line-variance.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD best.
    DATA lv_first TYPE abap_bool.

    " The best variance is the smallest one, which may be a saving.
    lv_first = abap_true.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_first = abap_true OR ls_line-variance < rv_variance.
        rv_variance = ls_line-variance.
        lv_first = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
