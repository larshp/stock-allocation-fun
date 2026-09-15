CLASS zcl_alloc_slot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             index TYPE i,
             slot  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             count TYPE i,
             slots TYPE i,
           END OF ty_input.

    METHODS assign
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_slot IMPLEMENTATION.

  METHOD assign.
    DATA ls_line  TYPE ty_line.
    DATA lv_index TYPE i.
    DATA lv_slot  TYPE i.

    IF is_input-count <= 0.
      RETURN.
    ENDIF.

    WHILE lv_index < is_input-count.
      lv_index = lv_index + 1.

      IF is_input-slots > 0.
        lv_slot = ( lv_index - 1 ) MOD is_input-slots + 1.
      ELSE.
        lv_slot = 0.
      ENDIF.

      CLEAR ls_line.
      ls_line-index = lv_index.
      ls_line-slot = lv_slot.
      APPEND ls_line TO rt_lines.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
