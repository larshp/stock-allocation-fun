CLASS zcl_alloc_moving_average DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_line,
             index    TYPE i,
             quantity TYPE menge_d,
             average  TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS calculate
      IMPORTING
        it_quantities   TYPE ty_qty_tt
        iv_window       TYPE i DEFAULT 3
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_moving_average IMPLEMENTATION.

  METHOD calculate.
    DATA ls_line  TYPE ty_line.
    DATA lv_sum   TYPE menge_d.
    DATA lv_old   TYPE menge_d.
    DATA lv_index TYPE i.
    DATA lv_count TYPE i.
    DATA lv_drop  TYPE i.
    DATA lv_window TYPE i.

    lv_window = iv_window.
    IF lv_window < 1.
      lv_window = 1.
    ENDIF.

    LOOP AT it_quantities INTO DATA(lv_qty).
      lv_index = lv_index + 1.
      lv_sum = lv_sum + lv_qty.

      IF lv_index > lv_window.
        lv_drop = lv_index - lv_window.
        READ TABLE it_quantities INTO lv_old INDEX lv_drop.
        IF sy-subrc = 0.
          lv_sum = lv_sum - lv_old.
        ENDIF.
      ENDIF.

      lv_count = lv_index.
      IF lv_count > lv_window.
        lv_count = lv_window.
      ENDIF.

      CLEAR ls_line.
      ls_line-index = lv_index.
      ls_line-quantity = lv_qty.
      ls_line-average = lv_sum / lv_count.
      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
