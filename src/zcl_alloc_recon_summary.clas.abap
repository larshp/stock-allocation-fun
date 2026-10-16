CLASS zcl_alloc_recon_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key     TYPE string,
             matched TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             item_count    TYPE i,
             matched_count TYPE i,
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

    METHODS matched_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recon_summary IMPLEMENTATION.

  METHOD item_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD matched_count.
    " The matched count gathers the items that agreed.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-matched = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the items and how many of them matched.
    rs_summary-item_count = item_count( it_lines ).
    rs_summary-matched_count = matched_count( it_lines ).
  ENDMETHOD.

ENDCLASS.
