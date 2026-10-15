CLASS zcl_alloc_cobj_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             object TYPE string,
             cost   TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             object_count TYPE i,
             total        TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS object_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cobj_summary IMPLEMENTATION.

  METHOD object_count.
    DATA lt_object TYPE SORTED TABLE OF ty_line WITH UNIQUE KEY object.
    DATA ls_object TYPE ty_line.

    " The count is the number of distinct cost objects.
    LOOP AT it_lines INTO DATA(ls_in).
      CLEAR ls_object.
      ls_object-object = ls_in-object.
      INSERT ls_object INTO TABLE lt_object.
    ENDLOOP.

    rv_count = lines( lt_object ).
  ENDMETHOD.

  METHOD total.
    " The summary total adds the cost of every object line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the objects and totals their cost.
    rs_summary-object_count = object_count( it_lines ).
    rs_summary-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
