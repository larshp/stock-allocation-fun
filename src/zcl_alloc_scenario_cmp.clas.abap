CLASS zcl_alloc_scenario_cmp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             base_qty       TYPE menge_d,
             scenario_qty   TYPE menge_d,
             delta_qty      TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             lines       TYPE ty_line_tt,
             changed     TYPE i,
             total_delta TYPE menge_d,
           END OF ty_result.

    METHODS compare
      IMPORTING
        it_base          TYPE zcl_stock_allocator=>ty_result_tt
        it_scenario      TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_scenario_cmp IMPLEMENTATION.

  METHOD compare.
    DATA ls_line TYPE ty_line.

    LOOP AT it_scenario INTO DATA(ls_new).
      READ TABLE it_base INTO DATA(ls_old)
        WITH KEY requirement_id = ls_new-requirement_id.

      CLEAR ls_line.
      ls_line-requirement_id = ls_new-requirement_id.
      IF sy-subrc = 0.
        ls_line-base_qty = ls_old-allocated_qty.
      ENDIF.

      ls_line-scenario_qty = ls_new-allocated_qty.
      ls_line-delta_qty = ls_line-scenario_qty - ls_line-base_qty.

      IF ls_line-delta_qty <> 0.
        APPEND ls_line TO rs_result-lines.
        rs_result-changed = rs_result-changed + 1.
        rs_result-total_delta = rs_result-total_delta + ls_line-delta_qty.
      ENDIF.
    ENDLOOP.

    LOOP AT it_base INTO ls_old.
      READ TABLE it_scenario INTO ls_new
        WITH KEY requirement_id = ls_old-requirement_id.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      IF ls_old-allocated_qty = 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_line.
      ls_line-requirement_id = ls_old-requirement_id.
      ls_line-base_qty = ls_old-allocated_qty.
      ls_line-delta_qty = 0 - ls_old-allocated_qty.

      APPEND ls_line TO rs_result-lines.
      rs_result-changed = rs_result-changed + 1.
      rs_result-total_delta = rs_result-total_delta + ls_line-delta_qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
