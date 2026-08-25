"! Stock allocation run - processes several materials at once.
"! Supports simulation mode (what-if, no posting) and delivery priority
"! handling: items are allocated by ascending LPRIO first, then FIFO.
CLASS zcl_stock_alloc_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_material,
             matnr TYPE matnr,
           END OF ty_material.
    TYPES tt_materials TYPE STANDARD TABLE OF ty_material WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_run_result,
             allocations  TYPE zcl_stock_allocator=>tt_allocations,
             qty_shortage TYPE kwmeng,
             messages     TYPE zcl_stub_message=>tt_message,
             stats        TYPE zcl_stock_allocator=>ty_stats,
             runnr        TYPE n LENGTH 10,  " audit trail run number
           END OF ty_run_result.

    "! Run allocation for a list of materials at one plant.
    "! iv_simulate = abap_true: allocations are calculated but NOT posted.
    CLASS-METHODS run
      IMPORTING
        it_materials     TYPE tt_materials
        iv_werks         TYPE werks_d
        iv_simulate      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_run_result.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_stock_alloc_run IMPLEMENTATION.


  METHOD run.
    DATA lt_allocations TYPE zcl_stock_allocator=>tt_allocations.

    LOOP AT it_materials INTO DATA(ls_material).
      DATA(ls_mat_result) = zcl_stock_allocator=>allocate_material(
          iv_matnr = ls_material-matnr
          iv_werks = iv_werks ).
      APPEND LINES OF ls_mat_result-allocations TO lt_allocations.
      APPEND LINES OF ls_mat_result-messages TO rs_result-messages.
      rs_result-qty_shortage = rs_result-qty_shortage + ls_mat_result-qty_shortage.
      " aggregate run statistics over all materials
      rs_result-stats-items_total   = rs_result-stats-items_total
                                      + ls_mat_result-stats-items_total.
      rs_result-stats-items_full    = rs_result-stats-items_full
                                      + ls_mat_result-stats-items_full.
      rs_result-stats-items_partial = rs_result-stats-items_partial
                                      + ls_mat_result-stats-items_partial.
      rs_result-stats-items_none    = rs_result-stats-items_none
                                      + ls_mat_result-stats-items_none.
      rs_result-stats-qty_requested = rs_result-stats-qty_requested
                                      + ls_mat_result-stats-qty_requested.
      rs_result-stats-qty_allocated = rs_result-stats-qty_allocated
                                      + ls_mat_result-stats-qty_allocated.
    ENDLOOP.

    " sort by delivery priority (ascending, 1 = highest), then FIFO
    SORT lt_allocations BY lprio ASCENDING vbeln ASCENDING posnr ASCENDING.

    IF iv_simulate = abap_false.
      DATA(lv_ok) = zcl_stock_allocator=>post_allocations(
          it_allocations = lt_allocations ).
      IF lv_ok = abap_false.
        APPEND zcl_stub_message=>build(
            iv_msgty = 'E'
            iv_msgno = zcl_stub_message=>gc_msgno-posting_failed )
            TO rs_result-messages.
      ENDIF.
    ELSE.
      APPEND zcl_stub_message=>build(
          iv_msgty = 'I'
          iv_msgno = zcl_stub_message=>gc_msgno-partial_alloc
          iv_msgv1 = 'SIMULATION' )
          TO rs_result-messages.
    ENDIF.

    " record the run in the audit trail
    rs_result-runnr = zcl_alloc_audit=>record(
        iv_simulate = iv_simulate
        is_stats    = rs_result-stats ).

    rs_result-allocations = lt_allocations.
  ENDMETHOD.


ENDCLASS.
