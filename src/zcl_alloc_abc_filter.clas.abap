CLASS zcl_alloc_abc_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             activity TYPE string,
             cost     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS filter
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_limit        TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_over
      IMPORTING
        iv_cost      TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_limit        TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_abc_filter IMPLEMENTATION.

  METHOD filter.
    " Only the activities whose cost passes the limit are kept.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-cost > iv_limit.
        APPEND ls_line TO rt_lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_over.
    " An activity is over the limit once its cost passes it.
    rv_ok = xsdbool( iv_cost > iv_limit ).
  ENDMETHOD.

  METHOD count.
    DATA lt_lines TYPE ty_line_tt.

    lt_lines = filter( it_lines = it_lines iv_limit = iv_limit ).
    rv_count = lines( lt_lines ).
  ENDMETHOD.

ENDCLASS.
