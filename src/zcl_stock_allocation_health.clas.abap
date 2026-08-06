CLASS zcl_stock_allocation_health DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES ty_status TYPE c LENGTH 8.
    TYPES:
      BEGIN OF ty_health,
        status                    TYPE ty_status,
        message                   TYPE zif_allocation_audit=>ty_message,
        reason_code               TYPE c LENGTH 16,
        total_runs                TYPE i,
        running_runs              TYPE i,
        stale_running_runs        TYPE i,
        error_runs                TYPE i,
        partial_runs              TYPE i,
        fair_runs                 TYPE i,
        weighted_runs             TYPE i,
        adaptive_runs             TYPE i,
        adaptive_priority_runs    TYPE i,
        adaptive_fair_runs        TYPE i,
        unit                      TYPE string,
        shortage_available        TYPE abap_bool,
        requested                 TYPE zif_stock_allocation=>ty_quantity,
        allocated                 TYPE zif_stock_allocation=>ty_quantity,
        shortage                  TYPE zif_stock_allocation=>ty_quantity,
        coverage_available        TYPE abap_bool,
        coverage                  TYPE zif_allocation_audit=>ty_coverage,
        coverage_threshold_active TYPE abap_bool,
        coverage_threshold        TYPE zif_allocation_audit=>ty_coverage,
        coverage_below_threshold  TYPE abap_bool,
        shortage_threshold_active TYPE abap_bool,
        shortage_threshold        TYPE zif_allocation_audit=>ty_coverage,
        shortage_above_threshold  TYPE abap_bool,
        fair_share_available      TYPE abap_bool,
        fair_requested            TYPE zif_stock_allocation=>ty_quantity,
        fair_allocated            TYPE zif_stock_allocation=>ty_quantity,
        fair_shortage             TYPE zif_stock_allocation=>ty_quantity,
        fair_coverage_available   TYPE abap_bool,
        fair_coverage             TYPE zif_allocation_audit=>ty_coverage,
        weighted_share_available  TYPE abap_bool,
        weighted_requested        TYPE zif_stock_allocation=>ty_quantity,
        weighted_allocated        TYPE zif_stock_allocation=>ty_quantity,
        weighted_shortage         TYPE zif_stock_allocation=>ty_quantity,
        weighted_coverage_ok      TYPE abap_bool,
        weighted_coverage         TYPE zif_allocation_audit=>ty_coverage,
        adaptive_share_available  TYPE abap_bool,
        adaptive_requested        TYPE zif_stock_allocation=>ty_quantity,
        adaptive_allocated        TYPE zif_stock_allocation=>ty_quantity,
        adaptive_shortage         TYPE zif_stock_allocation=>ty_quantity,
        adaptive_coverage_ok      TYPE abap_bool,
        adaptive_coverage         TYPE zif_allocation_audit=>ty_coverage,
      END OF ty_health.

    CLASS-METHODS evaluate
      IMPORTING
        is_summary            TYPE zif_allocation_audit=>ty_summary
        iv_stale_running_runs TYPE i OPTIONAL
        iv_stale_threshold    TYPE i DEFAULT 3600
        iv_min_coverage       TYPE zif_allocation_audit=>ty_coverage OPTIONAL
        iv_max_shortage_pct   TYPE zif_allocation_audit=>ty_coverage OPTIONAL
      RETURNING
      VALUE(rs_health)        TYPE ty_health.
ENDCLASS.

CLASS zcl_stock_allocation_health IMPLEMENTATION.
  METHOD evaluate.
    DATA lv_stale TYPE abap_bool.

    rs_health-total_runs = is_summary-total_runs.
    rs_health-running_runs = is_summary-running_runs.
    rs_health-error_runs = is_summary-error_runs.
    rs_health-partial_runs = is_summary-partial_runs.
    rs_health-fair_runs = is_summary-fair_runs.
    rs_health-weighted_runs = is_summary-weighted_runs.
    rs_health-adaptive_runs = is_summary-adaptive_runs.
    rs_health-adaptive_priority_runs = is_summary-adaptive_priority_runs.
    rs_health-adaptive_fair_runs = is_summary-adaptive_fair_runs.
    rs_health-unit = is_summary-unit.
    rs_health-shortage_available = xsdbool(
      is_summary-mixed_units = abap_false ).
    rs_health-coverage_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-requested > 0 ).
    rs_health-fair_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-fair_requested > 0 ).
    rs_health-fair_coverage_available = rs_health-fair_share_available.
    rs_health-adaptive_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-adaptive_requested > 0 ).
    rs_health-adaptive_coverage_ok = rs_health-adaptive_share_available.
    rs_health-weighted_share_available = xsdbool(
      is_summary-mixed_units = abap_false
      AND is_summary-weighted_requested > 0 ).
    rs_health-weighted_coverage_ok = rs_health-weighted_share_available.
    rs_health-coverage_threshold_active = xsdbool(
      iv_min_coverage > 0 ).
    rs_health-coverage_threshold = iv_min_coverage.
    rs_health-shortage_threshold_active = xsdbool(
      iv_max_shortage_pct > 0 ).
    rs_health-shortage_threshold = iv_max_shortage_pct.

    IF rs_health-shortage_available = abap_true.
      rs_health-requested = is_summary-requested.
      rs_health-allocated = is_summary-allocated.
      rs_health-shortage = is_summary-shortage.
    ENDIF.
    IF rs_health-coverage_available = abap_true.
      rs_health-coverage = is_summary-coverage.
    ENDIF.
    IF rs_health-fair_share_available = abap_true.
      rs_health-fair_requested = is_summary-fair_requested.
      rs_health-fair_allocated = is_summary-fair_allocated.
      rs_health-fair_shortage = is_summary-fair_shortage.
    ENDIF.
    IF rs_health-fair_coverage_available = abap_true.
      rs_health-fair_coverage = is_summary-fair_coverage.
    ENDIF.
    IF rs_health-weighted_share_available = abap_true.
      rs_health-weighted_requested = is_summary-weighted_requested.
      rs_health-weighted_allocated = is_summary-weighted_allocated.
      rs_health-weighted_shortage = is_summary-weighted_shortage.
    ENDIF.
    IF rs_health-weighted_coverage_ok = abap_true.
      rs_health-weighted_coverage = is_summary-weighted_coverage.
    ENDIF.
    IF rs_health-adaptive_share_available = abap_true.
      rs_health-adaptive_requested = is_summary-adaptive_requested.
      rs_health-adaptive_allocated = is_summary-adaptive_allocated.
      rs_health-adaptive_shortage = is_summary-adaptive_shortage.
    ENDIF.
    IF rs_health-adaptive_coverage_ok = abap_true.
      rs_health-adaptive_coverage = is_summary-adaptive_coverage.
    ENDIF.
    rs_health-coverage_below_threshold = xsdbool(
      rs_health-coverage_threshold_active = abap_true
      AND rs_health-coverage_available = abap_true
      AND is_summary-coverage < iv_min_coverage ).
    rs_health-shortage_above_threshold = xsdbool(
      rs_health-shortage_threshold_active = abap_true
      AND rs_health-shortage_available = abap_true
      AND is_summary-shortage_pct > iv_max_shortage_pct ).

    IF iv_stale_running_runs IS NOT INITIAL.
      rs_health-stale_running_runs = iv_stale_running_runs.
      lv_stale = xsdbool( iv_stale_running_runs > 0 ).
    ELSEIF iv_stale_threshold > 0
        AND is_summary-running_runs > 0
        AND is_summary-oldest_running_age_seconds >= iv_stale_threshold.
      lv_stale = abap_true.
      rs_health-stale_running_runs = 1.
    ENDIF.

    IF is_summary-total_runs = 0.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'NO_RUNS'.
      rs_health-message = 'No allocation runs found for the selected scope'.
    ELSEIF is_summary-error_runs > 0 OR lv_stale = abap_true.
      rs_health-status = 'CRITICAL'.
      rs_health-reason_code = 'ERROR_OR_STALE'.
      IF is_summary-error_runs > 0 AND lv_stale = abap_true.
        rs_health-message = 'Allocation errors and stale running work detected'.
      ELSEIF is_summary-error_runs > 0.
        rs_health-message = 'Allocation errors detected'.
      ELSE.
        rs_health-message = 'Stale running allocation work detected'.
      ENDIF.
    ELSEIF rs_health-coverage_below_threshold = abap_true
        AND rs_health-shortage_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Coverage is below minimum and shortage is above maximum'.
    ELSEIF rs_health-coverage_below_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation coverage is below the configured minimum'.
    ELSEIF rs_health-shortage_above_threshold = abap_true.
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'THRESHOLD_BREACH'.
      rs_health-message = 'Allocation shortage is above the configured maximum'.
    ELSEIF is_summary-partial_runs > 0
        OR ( rs_health-shortage_available = abap_true
          AND is_summary-shortage > 0 ).
      rs_health-status = 'WARNING'.
      rs_health-reason_code = 'BACKLOG'.
      rs_health-message = 'Allocation backlog or partial runs detected'.
    ELSE.
      rs_health-status = 'HEALTHY'.
      rs_health-reason_code = 'HEALTHY'.
      rs_health-message = 'Allocation scope is healthy'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
