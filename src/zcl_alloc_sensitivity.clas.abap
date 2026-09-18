CLASS zcl_alloc_sensitivity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             base_stock TYPE menge_d,
             demand     TYPE menge_d,
             steps      TYPE i,
             step_pct   TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_reading,
             delta_pct TYPE i,
             stock     TYPE menge_d,
             allocated TYPE menge_d,
             delta_qty TYPE menge_d,
           END OF ty_reading.
    TYPES ty_reading_tt TYPE STANDARD TABLE OF ty_reading WITH DEFAULT KEY.

    METHODS analyze
      IMPORTING
        is_input           TYPE ty_input
      RETURNING
        VALUE(rt_readings) TYPE ty_reading_tt.

ENDCLASS.


CLASS zcl_alloc_sensitivity IMPLEMENTATION.

  METHOD analyze.
    DATA lv_steps   TYPE i.
    DATA lv_offset  TYPE i.
    DATA lv_delta   TYPE i.
    DATA lv_stock   TYPE menge_d.
    DATA lv_base    TYPE menge_d.
    DATA ls_reading TYPE ty_reading.

    lv_base = is_input-base_stock.
    IF lv_base > is_input-demand.
      lv_base = is_input-demand.
    ENDIF.

    lv_steps = is_input-steps.
    IF lv_steps < 0.
      lv_steps = 0.
    ENDIF.

    lv_offset = 0 - lv_steps.
    WHILE lv_offset <= lv_steps.
      lv_delta = lv_offset * is_input-step_pct.

      lv_stock = is_input-base_stock * ( 100 + lv_delta ) DIV 100.
      IF lv_stock < 0.
        lv_stock = 0.
      ENDIF.

      CLEAR ls_reading.
      ls_reading-delta_pct = lv_delta.
      ls_reading-stock = lv_stock.

      IF lv_stock > is_input-demand.
        ls_reading-allocated = is_input-demand.
      ELSE.
        ls_reading-allocated = lv_stock.
      ENDIF.

      ls_reading-delta_qty = ls_reading-allocated - lv_base.
      APPEND ls_reading TO rt_readings.

      lv_offset = lv_offset + 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
