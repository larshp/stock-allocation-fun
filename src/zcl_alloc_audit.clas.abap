"! Allocation run audit trail - records every allocation run with its
"! parameters, statistics and outcome for traceability.
CLASS zcl_alloc_audit DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_runnr TYPE n LENGTH 10.

    TYPES: BEGIN OF ty_audit_entry,
             runnr         TYPE ty_runnr,     " sequential run number
             run_date      TYPE d,            " date of the run
             run_time      TYPE t,            " time of the run
             simulate      TYPE abap_bool,    " simulation only?
             items_total   TYPE i,
             items_full    TYPE i,
             items_partial TYPE i,
             items_none    TYPE i,
             qty_requested TYPE kwmeng,
             qty_allocated TYPE kwmeng,
           END OF ty_audit_entry.
    TYPES tt_audit_log TYPE STANDARD TABLE OF ty_audit_entry WITH DEFAULT KEY.

    "! Record a finished allocation run
    CLASS-METHODS record
      IMPORTING
        iv_simulate     TYPE abap_bool
        is_stats        TYPE zcl_stock_allocator=>ty_stats
      RETURNING
        VALUE(rv_runnr) TYPE ty_runnr.

    "! Read the full audit log (oldest first)
    CLASS-METHODS read_log
      RETURNING
        VALUE(rt_log) TYPE tt_audit_log.

    "! Read a single audit entry by run number; initial if not found
    CLASS-METHODS read_entry
      IMPORTING
        iv_runnr        TYPE ty_runnr
      RETURNING
        VALUE(rs_entry) TYPE ty_audit_entry.

    "! Test helper: clear the audit log
    CLASS-METHODS clear.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA gt_log TYPE tt_audit_log.

ENDCLASS.



CLASS zcl_alloc_audit IMPLEMENTATION.


  METHOD record.
    DATA ls_entry TYPE ty_audit_entry.

    " derive the next run number from the current log size
    ls_entry-runnr = lines( gt_log ) + 1.
    ls_entry-run_date = sy-datum.
    ls_entry-run_time = sy-uzeit.
    ls_entry-simulate = iv_simulate.
    ls_entry-items_total = is_stats-items_total.
    ls_entry-items_full = is_stats-items_full.
    ls_entry-items_partial = is_stats-items_partial.
    ls_entry-items_none = is_stats-items_none.
    ls_entry-qty_requested = is_stats-qty_requested.
    ls_entry-qty_allocated = is_stats-qty_allocated.

    APPEND ls_entry TO gt_log.
    rv_runnr = ls_entry-runnr.
  ENDMETHOD.


  METHOD read_log.
    rt_log = gt_log.
  ENDMETHOD.


  METHOD read_entry.
    READ TABLE gt_log INTO rs_entry WITH KEY runnr = iv_runnr.
    IF sy-subrc <> 0.
      CLEAR rs_entry.
    ENDIF.
  ENDMETHOD.


  METHOD clear.
    CLEAR gt_log.
  ENDMETHOD.


ENDCLASS.
