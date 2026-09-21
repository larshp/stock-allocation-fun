CLASS zcl_stock_preview_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_summary,
        remaining_quantity TYPE zif_stock_allocation=>ty_quantity,
        requested_quantity TYPE zif_stock_allocation=>ty_quantity,
        allocated_quantity TYPE zif_stock_allocation=>ty_quantity,
        shortage_quantity  TYPE zif_stock_allocation=>ty_quantity,
        coverage_pct       TYPE zif_allocation_audit=>ty_coverage,
        demand_count       TYPE i,
        full_count         TYPE i,
        partial_count      TYPE i,
        unallocated_count  TYPE i,
      END OF ty_summary.
    CLASS-METHODS calculate
      IMPORTING
        it_demands            TYPE zif_stock_allocation=>tt_demands
        iv_remaining_quantity TYPE zif_stock_allocation=>ty_quantity
      RETURNING
        VALUE(rs_summary)     TYPE ty_summary.
ENDCLASS.

CLASS zcl_stock_preview_summary IMPLEMENTATION.
  METHOD calculate.
    rs_summary-remaining_quantity = iv_remaining_quantity.
    LOOP AT it_demands INTO DATA(ls_demand).
      rs_summary-demand_count = rs_summary-demand_count + 1.
      rs_summary-requested_quantity = rs_summary-requested_quantity
        + ls_demand-requested.
      rs_summary-allocated_quantity = rs_summary-allocated_quantity
        + ls_demand-allocated.
      rs_summary-shortage_quantity = rs_summary-shortage_quantity
        + ls_demand-shortage.
      CASE ls_demand-allocation_status.
        WHEN 'F'.
          rs_summary-full_count = rs_summary-full_count + 1.
        WHEN 'P'.
          rs_summary-partial_count = rs_summary-partial_count + 1.
        WHEN 'U'.
          rs_summary-unallocated_count = rs_summary-unallocated_count + 1.
      ENDCASE.
    ENDLOOP.
    IF rs_summary-requested_quantity > 0.
      rs_summary-coverage_pct = rs_summary-allocated_quantity * 100
        / rs_summary-requested_quantity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
