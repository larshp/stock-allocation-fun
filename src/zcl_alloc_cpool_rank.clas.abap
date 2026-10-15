CLASS zcl_alloc_cpool_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             pool TYPE string,
             cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS largest
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rv_largest) TYPE i.

    METHODS smallest
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rv_smallest) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_rank IMPLEMENTATION.

  METHOD rank.
    " The biggest pool comes first, the smallest last.
    rt_lines = it_lines.
    SORT rt_lines BY cost DESCENDING.
  ENDMETHOD.

  METHOD largest.
    " The largest pool carries the most cost.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-cost > rv_largest.
        rv_largest = ls_line-cost.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD smallest.
    DATA lv_first TYPE abap_bool.

    " The smallest pool carries the least cost.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_first = abap_true OR ls_line-cost < rv_smallest.
        rv_smallest = ls_line-cost.
        lv_first = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
