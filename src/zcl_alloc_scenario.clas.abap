CLASS zcl_alloc_scenario DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_adjustment,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             delta_qty      TYPE menge_d,
           END OF ty_adjustment.
    TYPES ty_adjustment_tt TYPE STANDARD TABLE OF ty_adjustment
                           WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_scenario,
             scenario_id TYPE string,
             note        TYPE string,
             adjustments TYPE ty_adjustment_tt,
           END OF ty_scenario.

    METHODS define
      IMPORTING
        iv_scenario_id     TYPE string
        iv_note            TYPE string
        it_adjustments     TYPE ty_adjustment_tt
      RETURNING
        VALUE(rs_scenario) TYPE ty_scenario.

    METHODS apply
      IMPORTING
        is_scenario      TYPE ty_scenario
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

ENDCLASS.


CLASS zcl_alloc_scenario IMPLEMENTATION.

  METHOD define.
    rs_scenario-scenario_id = iv_scenario_id.
    rs_scenario-note = iv_note.
    rs_scenario-adjustments = it_adjustments.
  ENDMETHOD.

  METHOD apply.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    LOOP AT it_result INTO DATA(ls_base).
      ls_result = ls_base.

      READ TABLE is_scenario-adjustments INTO DATA(ls_adjustment)
        WITH KEY requirement_id = ls_base-requirement_id.
      IF sy-subrc = 0.
        ls_result-allocated_qty = ls_base-allocated_qty + ls_adjustment-delta_qty.

        IF ls_result-allocated_qty < 0.
          ls_result-allocated_qty = 0.
        ENDIF.
      ENDIF.

      APPEND ls_result TO rt_result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
