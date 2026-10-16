CLASS zcl_alloc_prep_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS filter
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_min_cost     TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS is_over
      IMPORTING
        iv_cost      TYPE i
        iv_min_cost  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_min_cost     TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prep_filter IMPLEMENTATION.

  METHOD filter.
    " The filter keeps the orders at or above the minimum cost.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-cost >= iv_min_cost.
        APPEND ls_line TO rt_lines.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_over.
    " The cost is over once it reaches the minimum.
    rv_ok = xsdbool( iv_cost >= iv_min_cost ).
  ENDMETHOD.

  METHOD count.
    DATA lt_lines TYPE ty_line_tt.

    " The count gathers the orders the filter keeps.
    lt_lines = filter( it_lines = it_lines iv_min_cost = iv_min_cost ).
    rv_count = lines( lt_lines ).
  ENDMETHOD.

ENDCLASS.
