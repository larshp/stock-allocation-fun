CLASS zcl_alloc_row_number DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             row_no  TYPE i,
             line_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             amount  TYPE menge_d,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS apply
      IMPORTING
        it_lines       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS count_of
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_row_number IMPLEMENTATION.

  METHOD apply.
    DATA ls_row TYPE ty_row.
    DATA lv_no  TYPE i.

    LOOP AT it_lines INTO DATA(ls_line).
      lv_no = lv_no + 1.

      CLEAR ls_row.
      ls_row-row_no = lv_no.
      ls_row-line_id = ls_line-requirement_id.
      ls_row-amount = ls_line-allocated_qty.
      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_of.
    rv_count = lines( it_rows ).
  ENDMETHOD.

ENDCLASS.
