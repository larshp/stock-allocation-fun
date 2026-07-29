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
    rs_summary-stock_qty = iv_stock_qty.
    rs_summary-allocatable_qty = iv_allocatable_qty.
    rs_summary-reserve_qty = iv_reserve.
    rs_summary-unit = iv_unit.
    LOOP AT it_allocations INTO DATA(ls_allocation).
      rs_summary-demand_count = rs_summary-demand_count + 1.
      rs_summary-requested_qty = rs_summary-requested_qty + ls_allocation-requested_qty.
      rs_summary-allocated_qty = rs_summary-allocated_qty + ls_allocation-allocated_qty.
      rs_summary-shortage_qty = rs_summary-shortage_qty + ls_allocation-shortage_qty.
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
  ENDMETHOD.
ENDCLASS.
