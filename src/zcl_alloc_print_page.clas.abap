CLASS zcl_alloc_print_page DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             line_count   TYPE i,
             page_size    TYPE i,
             header_lines TYPE i,
             footer_lines TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_page,
             page_no   TYPE i,
             from_line TYPE i,
             to_line   TYPE i,
             lines     TYPE i,
           END OF ty_page.
    TYPES ty_page_tt TYPE STANDARD TABLE OF ty_page WITH DEFAULT KEY.

    METHODS capacity_of
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rv_lines) TYPE i.

    METHODS paginate
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_pages) TYPE ty_page_tt.

ENDCLASS.


CLASS zcl_alloc_print_page IMPLEMENTATION.

  METHOD capacity_of.
    DATA lv_cap TYPE i.

    " Without a page size the whole list is printed on one page.
    IF is_input-page_size <= 0.
      rv_lines = is_input-line_count.
      IF rv_lines < 1.
        rv_lines = 1.
      ENDIF.
      RETURN.
    ENDIF.

    lv_cap = is_input-page_size - is_input-header_lines - is_input-footer_lines.

    " A page always holds at least one line, even when the furniture is huge.
    IF lv_cap < 1.
      lv_cap = 1.
    ENDIF.

    rv_lines = lv_cap.
  ENDMETHOD.

  METHOD paginate.
    DATA lv_cap   TYPE i.
    DATA lv_total TYPE i.
    DATA lv_from  TYPE i.
    DATA lv_to    TYPE i.
    DATA lv_no    TYPE i.
    DATA ls_page  TYPE ty_page.

    lv_total = is_input-line_count.
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    lv_cap = capacity_of( is_input ).
    lv_from = 1.

    WHILE lv_from <= lv_total.
      lv_to = lv_from + lv_cap - 1.
      IF lv_to > lv_total.
        lv_to = lv_total.
      ENDIF.

      lv_no = lv_no + 1.

      CLEAR ls_page.
      ls_page-page_no = lv_no.
      ls_page-from_line = lv_from.
      ls_page-to_line = lv_to.
      ls_page-lines = lv_to - lv_from + 1.
      APPEND ls_page TO rt_pages.

      lv_from = lv_to + 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
