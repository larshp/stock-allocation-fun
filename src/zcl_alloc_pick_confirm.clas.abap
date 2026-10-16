CLASS zcl_alloc_pick_confirm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             index      TYPE i,
             planned    TYPE menge_d,
             confirmed  TYPE menge_d,
             difference TYPE menge_d,
             complete   TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             planned   TYPE ty_qty_tt,
             confirmed TYPE ty_qty_tt,
           END OF ty_input.

    METHODS confirm
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_pick_confirm IMPLEMENTATION.

  METHOD confirm.
    DATA ls_line      TYPE ty_line.
    DATA lv_index     TYPE i.
    DATA lv_planned   TYPE menge_d.
    DATA lv_confirmed TYPE menge_d.

    LOOP AT is_input-planned INTO DATA(lv_value).
      lv_index = sy-tabix.
      lv_planned = lv_value.

      READ TABLE is_input-confirmed INTO lv_confirmed INDEX lv_index.
      IF sy-subrc <> 0.
        lv_confirmed = 0.
      ENDIF.

      CLEAR ls_line.
      ls_line-index = lv_index.
      ls_line-planned = lv_planned.
      ls_line-confirmed = lv_confirmed.
      ls_line-difference = lv_confirmed - lv_planned.
      IF lv_confirmed >= lv_planned.
        ls_line-complete = abap_true.
      ENDIF.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
