CLASS zcl_alloc_pick_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             lgort          TYPE lgort_d,
             charg          TYPE c LENGTH 10,
             quantity       TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_pick_list IMPLEMENTATION.

  METHOD build.
    DATA ls_line TYPE ty_line.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_line.
        ls_line-requirement_id = ls_result-requirement_id.
        ls_line-lgort = ls_allocation-lgort.
        ls_line-charg = ls_allocation-charg.
        ls_line-quantity = ls_allocation-quantity.
        APPEND ls_line TO rt_lines.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
