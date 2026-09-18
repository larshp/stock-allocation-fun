CLASS zcl_alloc_bin_replenish DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             lgort    TYPE lgort_d,
             quantity TYPE menge_d,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             lgort     TYPE lgort_d,
             quantity  TYPE menge_d,
             shortfall TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             bins          TYPE ty_bin_tt,
             reorder_point TYPE menge_d,
           END OF ty_input.

    METHODS propose
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_bin_replenish IMPLEMENTATION.

  METHOD propose.
    DATA ls_line TYPE ty_line.

    LOOP AT is_input-bins INTO DATA(ls_bin).
      IF ls_bin-quantity >= is_input-reorder_point.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-lgort = ls_bin-lgort.
      ls_line-quantity = ls_bin-quantity.
      ls_line-shortfall = is_input-reorder_point - ls_bin-quantity.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
