CLASS zcl_alloc_rout_rank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             operation TYPE string,
             time      TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS rank
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS longest
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rv_longest) TYPE i.

    METHODS shortest
      IMPORTING
        it_lines           TYPE ty_line_tt
      RETURNING
        VALUE(rv_shortest) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rout_rank IMPLEMENTATION.

  METHOD rank.
    " The longest operation comes first, the shortest last.
    rt_lines = it_lines.
    SORT rt_lines BY time DESCENDING.
  ENDMETHOD.

  METHOD longest.
    " The longest operation takes the most time.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-time > rv_longest.
        rv_longest = ls_line-time.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD shortest.
    DATA lv_seen TYPE abap_bool.

    " The shortest operation takes the least time.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_false OR ls_line-time < rv_shortest.
        rv_shortest = ls_line-time.
        lv_seen = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
