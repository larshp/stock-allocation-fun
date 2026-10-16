CLASS zcl_alloc_drv_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name  TYPE string,
             value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS top
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_top) TYPE i.

    METHODS bottom
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rv_bottom) TYPE i.

ENDCLASS.


CLASS zcl_alloc_drv_rank IMPLEMENTATION.

  METHOD rank.
    " The biggest driver comes first, the smallest last.
    rt_lines = it_lines.
    SORT rt_lines BY value DESCENDING.
  ENDMETHOD.

  METHOD top.
    " The top driver carries the most quantity.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-value > rv_top.
        rv_top = ls_line-value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD bottom.
    DATA lv_first TYPE abap_bool.

    " The bottom driver carries the least quantity.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_first = abap_true OR ls_line-value < rv_bottom.
        rv_bottom = ls_line-value.
        lv_first = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
