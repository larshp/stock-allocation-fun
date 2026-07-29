CLASS zcl_stock_alloc_summary DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS summarize
      IMPORTING
        it_allocations     TYPE zif_stock_allocation=>tt_allocations
        iv_stock_qty       TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_allocatable_qty TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_reserve         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_unit            TYPE zif_stock_allocation=>ty_unit OPTIONAL
      RETURNING
        VALUE(rs_summary)  TYPE zif_stock_allocation=>ty_summary.
ENDCLASS.

CLASS zcl_stock_alloc_summary IMPLEMENTATION.
  METHOD summarize.
    DATA lv_ratio_sum TYPE decfloat34.
    DATA lv_ratio_square_sum TYPE decfloat34.
    DATA lv_fairness_count TYPE i.
    rs_summary-stock_qty = iv_stock_qty.
    rs_summary-allocatable_qty = iv_allocatable_qty.
    rs_summary-reserve_qty = iv_reserve.
    rs_summary-unit = iv_unit.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      rs_summary-demand_count = rs_summary-demand_count + 1.
      rs_summary-requested_qty = rs_summary-requested_qty + ls_allocation-requested_qty.
      rs_summary-allocated_qty = rs_summary-allocated_qty + ls_allocation-allocated_qty.
      rs_summary-shortage_qty = rs_summary-shortage_qty + ls_allocation-shortage_qty.
      IF ls_allocation-shortage_qty > 0.
        rs_summary-shortage_count = rs_summary-shortage_count + 1.
        IF rs_summary-earliest_shortage_date IS INITIAL
            OR ls_allocation-delivery_date < rs_summary-earliest_shortage_date.
          rs_summary-earliest_shortage_date = ls_allocation-delivery_date.
        ENDIF.
      ENDIF.
      IF ls_allocation-requested_qty > 0.
        DATA lv_allocated TYPE zif_stock_allocation=>ty_total_quantity.
        DATA lv_requested TYPE zif_stock_allocation=>ty_total_quantity.
        lv_allocated = ls_allocation-allocated_qty.
        lv_requested = ls_allocation-requested_qty.
        DATA(lv_ratio) = lv_allocated / lv_requested.
        lv_ratio_sum = lv_ratio_sum + lv_ratio.
        lv_ratio_square_sum = lv_ratio_square_sum + lv_ratio * lv_ratio.
        lv_fairness_count = lv_fairness_count + 1.
      ENDIF.
      IF rs_summary-unit IS INITIAL.
        rs_summary-unit = ls_allocation-unit.
      ENDIF.

      CASE ls_allocation-status.
        WHEN zif_stock_allocation=>c_status_full.
          rs_summary-full_count = rs_summary-full_count + 1.
        WHEN zif_stock_allocation=>c_status_partial.
          rs_summary-partial_count = rs_summary-partial_count + 1.
        WHEN OTHERS.
          rs_summary-none_count = rs_summary-none_count + 1.
      ENDCASE.
    ENDLOOP.
    IF rs_summary-requested_qty > 0.
      rs_summary-quantity_fill_pct = rs_summary-allocated_qty * 100
                                   / rs_summary-requested_qty.
    ENDIF.
    IF rs_summary-demand_count > 0.
      rs_summary-service_level_pct = rs_summary-full_count * 100
                                   / rs_summary-demand_count.
    ENDIF.
    rs_summary-unused_qty = rs_summary-allocatable_qty
                          - rs_summary-allocated_qty.
    IF rs_summary-unused_qty < 0.
      CLEAR rs_summary-unused_qty.
    ENDIF.
    IF rs_summary-allocatable_qty > 0.
      rs_summary-stock_utilization_pct = rs_summary-allocated_qty * 100
                                       / rs_summary-allocatable_qty.
    ENDIF.
    IF lv_ratio_square_sum > 0.
      rs_summary-fairness_pct = lv_ratio_sum * lv_ratio_sum * 100
                              / ( lv_fairness_count * lv_ratio_square_sum ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
