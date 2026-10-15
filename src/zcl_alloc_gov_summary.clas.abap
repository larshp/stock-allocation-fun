CLASS zcl_alloc_gov_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key      TYPE string,
             approved TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             item_count     TYPE i,
             approved_count TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS item_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS approved_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_summary IMPLEMENTATION.

  METHOD item_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD approved_count.
    " The approved count gathers the items that carry the flag.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-approved = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the items and how many of them are approved.
    rs_summary-item_count = item_count( it_lines ).
    rs_summary-approved_count = approved_count( it_lines ).
  ENDMETHOD.

ENDCLASS.
