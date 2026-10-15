CLASS zcl_alloc_val_browse DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS browse
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_page         TYPE i
        iv_page_size    TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS page_count
      IMPORTING
        iv_total_lines  TYPE i
        iv_page_size    TYPE i
      RETURNING
        VALUE(rv_pages) TYPE i.

    METHODS has_more
      IMPORTING
        iv_page        TYPE i
        iv_page_size   TYPE i
        iv_total_lines TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_val_browse IMPLEMENTATION.

  METHOD browse.
    DATA lv_from TYPE i.
    DATA lv_to   TYPE i.
    DATA lv_idx  TYPE i.

    " The page holds the lines between its first and last position.
    IF iv_page < 1 OR iv_page_size < 1.
      RETURN.
    ENDIF.

    lv_from = ( iv_page - 1 ) * iv_page_size + 1.
    lv_to = iv_page * iv_page_size.

    LOOP AT it_lines INTO DATA(ls_line).
      lv_idx = lv_idx + 1.
      IF lv_idx < lv_from.
        CONTINUE.
      ENDIF.
      IF lv_idx > lv_to.
        EXIT.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD page_count.
    " The pages are the lines divided by the page size, rounded up.
    IF iv_page_size < 1.
      RETURN.
    ENDIF.

    rv_pages = ( iv_total_lines + iv_page_size - 1 ) DIV iv_page_size.
  ENDMETHOD.

  METHOD has_more.
    " Later lines remain while the page end stays before the last line.
    rv_ok = xsdbool( iv_page * iv_page_size < iv_total_lines ).
  ENDMETHOD.

ENDCLASS.
