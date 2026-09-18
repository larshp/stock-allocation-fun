CLASS zcl_alloc_footer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             caption TYPE string,
             total   TYPE menge_d,
             lines   TYPE i,
           END OF ty_result.

    METHODS build
      IMPORTING
        it_lines         TYPE zcl_stock_allocator=>ty_result_tt
        iv_caption       TYPE string
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_footer IMPLEMENTATION.

  METHOD build.
    rs_result-caption = iv_caption.

    LOOP AT it_lines INTO DATA(ls_line).
      rs_result-total = rs_result-total + ls_line-allocated_qty.
    ENDLOOP.

    rs_result-lines = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
