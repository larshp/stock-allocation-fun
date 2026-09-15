CLASS zcl_alloc_running_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             index    TYPE i,
             quantity TYPE menge_d,
             total    TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS calculate
      IMPORTING
        it_quantities   TYPE ty_qty_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_running_total IMPLEMENTATION.

  METHOD calculate.
    DATA ls_line TYPE ty_line.
    DATA lv_sum  TYPE menge_d.

    LOOP AT it_quantities INTO DATA(lv_qty).
      lv_sum = lv_sum + lv_qty.

      CLEAR ls_line.
      ls_line-index = sy-tabix.
      ls_line-quantity = lv_qty.
      ls_line-total = lv_sum.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
