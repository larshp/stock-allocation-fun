CLASS zcl_alloc_shortage_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             requirement_id TYPE c LENGTH 20,
             requested_qty  TYPE menge_d,
             allocated_qty  TYPE menge_d,
             shortage_qty   TYPE menge_d,
             coverage_pct   TYPE i,
             covered        TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             requested_qty TYPE menge_d,
             allocated_qty TYPE menge_d,
             shortage_qty  TYPE menge_d,
             coverage_pct  TYPE i,
             lines         TYPE i,
             short_lines   TYPE i,
             covered_lines TYPE i,
           END OF ty_summary.

    TYPES: BEGIN OF ty_report,
             lines    TYPE ty_line_tt,
             summary  TYPE ty_summary,
             critical TYPE ty_line_tt,
           END OF ty_report.

    METHODS build
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_min_coverage  TYPE i DEFAULT 100
      RETURNING
        VALUE(rs_report) TYPE ty_report.

  PRIVATE SECTION.
    METHODS coverage_of
      IMPORTING
        iv_requested  TYPE menge_d
        iv_allocated  TYPE menge_d
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_shortage_report IMPLEMENTATION.

  METHOD build.
    DATA ls_line TYPE ty_line.

    LOOP AT it_result INTO DATA(ls_result).
      CLEAR ls_line.
      ls_line-requirement_id = ls_result-requirement_id.
      ls_line-requested_qty = ls_result-requested_qty.
      ls_line-allocated_qty = ls_result-allocated_qty.
      ls_line-shortage_qty = ls_result-shortage_qty.
      ls_line-coverage_pct = coverage_of( iv_requested = ls_result-requested_qty
                                          iv_allocated = ls_result-allocated_qty ).

      IF ls_result-requested_qty <= 0
          OR ls_result-shortage_qty <= 0
          OR ls_result-within_tolerance = abap_true
          OR ls_result-deferred = abap_true.
        ls_line-covered = abap_true.
      ENDIF.

      APPEND ls_line TO rs_report-lines.

      rs_report-summary-requested_qty = rs_report-summary-requested_qty
        + ls_result-requested_qty.
      rs_report-summary-allocated_qty = rs_report-summary-allocated_qty
        + ls_result-allocated_qty.
      rs_report-summary-shortage_qty = rs_report-summary-shortage_qty
        + ls_result-shortage_qty.
      rs_report-summary-lines = rs_report-summary-lines + 1.

      IF ls_line-shortage_qty > 0.
        rs_report-summary-short_lines = rs_report-summary-short_lines + 1.
      ENDIF.

      IF ls_line-covered = abap_true.
        rs_report-summary-covered_lines = rs_report-summary-covered_lines + 1.
      ENDIF.

      IF ls_line-covered = abap_false
          AND ls_line-coverage_pct < iv_min_coverage.
        APPEND ls_line TO rs_report-critical.
      ENDIF.
    ENDLOOP.

    rs_report-summary-coverage_pct =
      coverage_of( iv_requested = rs_report-summary-requested_qty
                   iv_allocated = rs_report-summary-allocated_qty ).
  ENDMETHOD.

  METHOD coverage_of.
    IF iv_requested <= 0.
      rv_pct = 100.
      RETURN.
    ENDIF.

    rv_pct = iv_allocated * 100 DIV iv_requested.
  ENDMETHOD.

ENDCLASS.
