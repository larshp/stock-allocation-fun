CLASS zcl_alloc_wave DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             wave     TYPE i,
             index    TYPE i,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             items     TYPE ty_qty_tt,
             wave_size TYPE i,
           END OF ty_input.

    METHODS plan
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_wave IMPLEMENTATION.

  METHOD plan.
    DATA ls_line  TYPE ty_line.
    DATA lv_index TYPE i.
    DATA lv_wave  TYPE i.

    LOOP AT is_input-items INTO DATA(lv_quantity).
      lv_index = sy-tabix.

      IF is_input-wave_size <= 0.
        lv_wave = 0.
      ELSE.
        lv_wave = ( lv_index - 1 ) DIV is_input-wave_size + 1.
      ENDIF.

      CLEAR ls_line.
      ls_line-wave = lv_wave.
      ls_line-index = lv_index.
      ls_line-quantity = lv_quantity.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
