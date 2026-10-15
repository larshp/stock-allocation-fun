CLASS zcl_alloc_wip_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             value    TYPE i,
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

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_wip_rank IMPLEMENTATION.

  METHOD rank.
    " The biggest work in progress comes first.
    rt_lines = it_lines.
    SORT rt_lines BY value DESCENDING.
  ENDMETHOD.

  METHOD largest.
    " The largest work in progress carries the most value.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-value > rv_largest.
        rv_largest = ls_line-value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
