CLASS zcl_alloc_cycle_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name  TYPE string,
             order TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS step_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS first_step
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_first) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cycle_build IMPLEMENTATION.

  METHOD build.
    " The steps are laid out in the order they run.
    rt_lines = it_lines.
    SORT rt_lines BY order ASCENDING.
  ENDMETHOD.

  METHOD step_count.
    " The count is how many steps the cycle holds.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD first_step.
    DATA lv_seen TYPE abap_bool.

    " The first step is the one with the lowest order.
    lv_seen = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_true OR ls_line-order < rv_first.
        rv_first = ls_line-order.
        lv_seen = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
