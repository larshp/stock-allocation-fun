CLASS zcl_alloc_negative_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_row,
             id       TYPE zcl_stock_allocator=>ty_result-requirement_id,
             quantity TYPE menge_d,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS find
      IMPORTING
        it_rows        TYPE ty_row_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

ENDCLASS.


CLASS zcl_alloc_negative_check IMPLEMENTATION.

  METHOD find.
    LOOP AT it_rows INTO DATA(ls_row).
      IF ls_row-quantity < 0.
        APPEND ls_row TO rt_rows.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
