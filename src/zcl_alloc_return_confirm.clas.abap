CLASS zcl_alloc_return_confirm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
        iv_rma         TYPE string
      RETURNING
        VALUE(rt_text) TYPE ty_text_tt.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_confirm IMPLEMENTATION.

  METHOD build.
    DATA lv_no TYPE i.
    DATA lv_qt TYPE i.

    " The confirmation opens with the RMA reference and then lists each item
    " with its position and quantity.
    APPEND |Return { iv_rma } confirmation| TO rt_text.

    LOOP AT it_lines INTO DATA(ls_line).
      lv_no = lv_no + 1.
      lv_qt = ls_line-quantity.
      APPEND |{ lv_no }: { lv_qt } units| TO rt_text.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
