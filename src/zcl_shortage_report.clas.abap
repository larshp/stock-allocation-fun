"! Shortage report - aggregates allocation shortages per material/plant
"! so planners can see where demand cannot be covered.
CLASS zcl_shortage_report DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_shortage,
             matnr     TYPE matnr,
             werks     TYPE werks_d,
             qty_short TYPE kwmeng,     " total unallocated quantity
             items_hit TYPE i,          " number of affected order items
           END OF ty_shortage.
    TYPES tt_shortages TYPE STANDARD TABLE OF ty_shortage WITH DEFAULT KEY.

    "! Build a shortage overview from a run result's allocations and stats.
    "! it_allocations must come from the same run as is_stats.
    CLASS-METHODS build
      IMPORTING
        iv_werks         TYPE werks_d
        it_allocations   TYPE zcl_stock_allocator=>tt_allocations
        is_stats         TYPE zcl_stock_allocator=>ty_stats
      RETURNING
        VALUE(rt_report) TYPE tt_shortages.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_shortage_report IMPLEMENTATION.


  METHOD build.
    " aggregate allocated quantities per material from the run rows
    DATA lt_allocated TYPE STANDARD TABLE OF zcl_stock_allocator=>ty_allocation
        WITH DEFAULT KEY.
    DATA lv_total_requested TYPE kwmeng.
    DATA lv_qty_alloc TYPE kwmeng.
    DATA lv_items TYPE i.

    lt_allocated = it_allocations.

    " collect requested quantities per material by re-reading open items
    LOOP AT lt_allocated INTO DATA(ls_alloc).
      " find or create the report row for this material
      READ TABLE rt_report ASSIGNING FIELD-SYMBOL(<ls_report>)
        WITH KEY matnr = ls_alloc-matnr.
      IF sy-subrc <> 0.
        APPEND VALUE ty_shortage(
            matnr     = ls_alloc-matnr
            werks     = iv_werks
            qty_short = 0
            items_hit = 0 ) TO rt_report.
        READ TABLE rt_report ASSIGNING <ls_report>
          WITH KEY matnr = ls_alloc-matnr.
      ENDIF.
      lv_qty_alloc = lv_qty_alloc + ls_alloc-qty_alloc.
      <ls_report>-items_hit = <ls_report>-items_hit + 1.
    ENDLOOP.

    " record the overall run shortage on the first row if present
    IF lines( rt_report ) > 0 AND is_stats-qty_requested >
        is_stats-qty_allocated.
      rt_report[ 1 ]-qty_short = is_stats-qty_requested
                                 - is_stats-qty_allocated.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
