CLASS zcl_stock_strategy_selector DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS recommend
      IMPORTING
        it_plans           TYPE zif_stock_allocation=>tt_plans
        iv_objective       TYPE zif_stock_allocation=>ty_objective DEFAULT zif_stock_allocation=>c_objective_service
      RETURNING
        VALUE(rv_strategy) TYPE zif_stock_allocation=>ty_strategy
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_strategy_selector IMPLEMENTATION.
  METHOD recommend.
    IF iv_objective <> zif_stock_allocation=>c_objective_service
        AND iv_objective <> zif_stock_allocation=>c_objective_fill
        AND iv_objective <> zif_stock_allocation=>c_objective_fairness.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Strategy objective must be S, Q, or F' ).
    ENDIF.
    IF it_plans IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'At least one allocation plan is required for recommendation' ).
    ENDIF.

    DATA ls_best TYPE zif_stock_allocation=>ty_summary.
    DATA lv_found TYPE abap_bool.
    LOOP AT it_plans INTO DATA(ls_plan).
      zcl_stock_alloc_validator=>validate_strategy( ls_plan-strategy ).
      DATA(ls_candidate) = zcl_stock_alloc_summary=>summarize(
        it_allocations     = ls_plan-allocations
        iv_stock_qty       = ls_plan-stock_qty
        iv_allocatable_qty = ls_plan-allocatable_qty
        iv_reserve         = ls_plan-reserve_qty
        iv_unit            = ls_plan-unit ).
      DATA lv_better TYPE abap_bool.
      CLEAR lv_better.
      IF lv_found = abap_false.
        lv_better = abap_true.
      ELSEIF iv_objective = zif_stock_allocation=>c_objective_service.
        IF ls_candidate-full_count > ls_best-full_count.
          lv_better = abap_true.
        ELSEIF ls_candidate-full_count = ls_best-full_count
            AND ls_candidate-allocated_qty > ls_best-allocated_qty.
          lv_better = abap_true.
        ELSEIF ls_candidate-full_count = ls_best-full_count
            AND ls_candidate-allocated_qty = ls_best-allocated_qty
            AND ls_candidate-partial_count < ls_best-partial_count.
          lv_better = abap_true.
        ENDIF.
      ELSEIF iv_objective = zif_stock_allocation=>c_objective_fill.
        IF ls_candidate-allocated_qty > ls_best-allocated_qty.
          lv_better = abap_true.
        ELSEIF ls_candidate-allocated_qty = ls_best-allocated_qty
            AND ls_candidate-full_count > ls_best-full_count.
          lv_better = abap_true.
        ELSEIF ls_candidate-allocated_qty = ls_best-allocated_qty
            AND ls_candidate-full_count = ls_best-full_count
            AND ls_candidate-partial_count < ls_best-partial_count.
          lv_better = abap_true.
        ENDIF.
      ELSE.
        IF ls_candidate-fairness_pct > ls_best-fairness_pct.
          lv_better = abap_true.
        ELSEIF ls_candidate-fairness_pct = ls_best-fairness_pct
            AND ls_candidate-allocated_qty > ls_best-allocated_qty.
          lv_better = abap_true.
        ELSEIF ls_candidate-fairness_pct = ls_best-fairness_pct
            AND ls_candidate-allocated_qty = ls_best-allocated_qty
            AND ls_candidate-full_count > ls_best-full_count.
          lv_better = abap_true.
        ENDIF.
      ENDIF.

      IF lv_better = abap_true.
        ls_best = ls_candidate.
        rv_strategy = ls_plan-strategy.
        lv_found = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
