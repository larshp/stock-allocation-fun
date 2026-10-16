CLASS zcl_alloc_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             werks     TYPE werks_d,
             available TYPE menge_d,
             unit_cost TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             werks TYPE werks_d,
             taken TYPE menge_d,
             cost  TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             lines      TYPE ty_line_tt,
             total_cost TYPE menge_d,
             remaining  TYPE menge_d,
           END OF ty_result.

    TYPES: BEGIN OF ty_input,
             items    TYPE ty_item_tt,
             required TYPE menge_d,
           END OF ty_input.

    METHODS select
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_cost IMPLEMENTATION.

  METHOD select.
    DATA lt_items TYPE ty_item_tt.
    DATA ls_line  TYPE ty_line.
    DATA lv_left  TYPE menge_d.
    DATA lv_take  TYPE menge_d.

    lt_items = is_input-items.
    SORT lt_items BY unit_cost ASCENDING
                    werks ASCENDING.

    lv_left = is_input-required.

    LOOP AT lt_items INTO DATA(ls_item).
      IF lv_left <= 0.
        EXIT.
      ENDIF.
      IF ls_item-available <= 0.
        CONTINUE.
      ENDIF.

      lv_take = ls_item-available.
      IF lv_take > lv_left.
        lv_take = lv_left.
      ENDIF.

      CLEAR ls_line.
      ls_line-werks = ls_item-werks.
      ls_line-taken = lv_take.
      ls_line-cost = lv_take * ls_item-unit_cost.
      APPEND ls_line TO rs_result-lines.

      rs_result-total_cost = rs_result-total_cost + ls_line-cost.
      lv_left = lv_left - lv_take.
    ENDLOOP.

    rs_result-remaining = lv_left.
  ENDMETHOD.

ENDCLASS.
