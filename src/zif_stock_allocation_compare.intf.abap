INTERFACE zif_stock_allocation_compare PUBLIC.
  TYPES ty_change_type TYPE c LENGTH 1.
  TYPES ty_change_reason TYPE c LENGTH 32.
  TYPES ty_reconciliation_status TYPE c LENGTH 8.
  TYPES ty_reconciliation_transition TYPE c LENGTH 16.
  TYPES ty_running_age_trend TYPE c LENGTH 11.
  TYPES:
    BEGIN OF ty_running_age,
      available TYPE abap_bool,
      seconds   TYPE i,
    END OF ty_running_age.
  TYPES:
    BEGIN OF ty_change,
      change_type                   TYPE ty_change_type,
      change_reasons                TYPE string,
      allocation_unit               TYPE zif_stock_allocation=>ty_unit,
      order_id                      TYPE zif_stock_allocation=>ty_order_id,
      old_allocation_strategy       TYPE zif_allocation_audit=>ty_strategy,
      new_allocation_strategy       TYPE zif_allocation_audit=>ty_strategy,
      old_sales_document            TYPE zif_stock_allocation=>ty_sales_document,
      new_sales_document            TYPE zif_stock_allocation=>ty_sales_document,
      old_sales_document_type       TYPE zif_stock_allocation=>ty_sales_document_type,
      new_sales_document_type       TYPE zif_stock_allocation=>ty_sales_document_type,
      old_sales_item                TYPE zif_stock_allocation=>ty_sales_item,
      new_sales_item                TYPE zif_stock_allocation=>ty_sales_item,
      old_schedule_line             TYPE zif_stock_allocation=>ty_schedule_line,
      new_schedule_line             TYPE zif_stock_allocation=>ty_schedule_line,
      old_order_unit                TYPE zif_stock_allocation=>ty_unit,
      new_order_unit                TYPE zif_stock_allocation=>ty_unit,
      old_requested_on              TYPE d,
      new_requested_on              TYPE d,
      old_priority                  TYPE zif_stock_allocation=>ty_priority,
      new_priority                  TYPE zif_stock_allocation=>ty_priority,
      old_status                    TYPE zif_stock_allocation=>ty_allocation_status,
      new_status                    TYPE zif_stock_allocation=>ty_allocation_status,
      old_requested                 TYPE zif_stock_allocation=>ty_quantity,
      new_requested                 TYPE zif_stock_allocation=>ty_quantity,
      delta_requested               TYPE zif_stock_allocation=>ty_quantity,
      old_allocated                 TYPE zif_stock_allocation=>ty_quantity,
      new_allocated                 TYPE zif_stock_allocation=>ty_quantity,
      delta_allocated               TYPE zif_stock_allocation=>ty_quantity,
      old_shortage                  TYPE zif_stock_allocation=>ty_quantity,
      new_shortage                  TYPE zif_stock_allocation=>ty_quantity,
      delta_shortage                TYPE zif_stock_allocation=>ty_quantity,
      old_coverage_available        TYPE abap_bool,
      new_coverage_available        TYPE abap_bool,
      old_coverage                  TYPE zif_allocation_audit=>ty_coverage,
      new_coverage                  TYPE zif_allocation_audit=>ty_coverage,
      old_shortage_pct_available    TYPE abap_bool,
      new_shortage_pct_available    TYPE abap_bool,
      old_shortage_pct              TYPE zif_allocation_audit=>ty_coverage,
      new_shortage_pct              TYPE zif_allocation_audit=>ty_coverage,
      coverage_delta_available      TYPE abap_bool,
      coverage_delta                TYPE zif_allocation_audit=>ty_coverage,
      shortage_pct_delta_available  TYPE abap_bool,
      shortage_pct_delta            TYPE zif_allocation_audit=>ty_coverage,
      old_reservation_id            TYPE zif_stock_allocation=>ty_order_id,
      new_reservation_id            TYPE zif_stock_allocation=>ty_order_id,
      old_reservation_date          TYPE d,
      new_reservation_date          TYPE d,
      old_reservation_movement_type TYPE zif_stock_allocation=>ty_movement_type,
      new_reservation_movement_type TYPE zif_stock_allocation=>ty_movement_type,
      old_reservation_unit          TYPE zif_stock_allocation=>ty_unit,
      new_reservation_unit          TYPE zif_stock_allocation=>ty_unit,
    END OF ty_change.
  TYPES tt_changes TYPE STANDARD TABLE OF ty_change WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_reconciliation,
      status                     TYPE ty_reconciliation_status,
      snapshot_rows              TYPE i,
      snapshot_full_count        TYPE i,
      snapshot_partial_count     TYPE i,
      snapshot_unallocated_count TYPE i,
      snapshot_requested         TYPE zif_stock_allocation=>ty_quantity,
      snapshot_allocated         TYPE zif_stock_allocation=>ty_quantity,
      snapshot_shortage          TYPE zif_stock_allocation=>ty_quantity,
      mismatch_fields            TYPE string,
    END OF ty_reconciliation.
  TYPES:
    BEGIN OF ty_summary,
      total_rows                   TYPE i,
      added_rows                   TYPE i,
      removed_rows                 TYPE i,
      changed_rows                 TYPE i,
      unchanged_rows               TYPE i,
      unit                         TYPE zif_stock_allocation=>ty_unit,
      mixed_units                  TYPE abap_bool,
      old_requested                TYPE zif_stock_allocation=>ty_quantity,
      new_requested                TYPE zif_stock_allocation=>ty_quantity,
      delta_requested              TYPE zif_stock_allocation=>ty_quantity,
      old_allocated                TYPE zif_stock_allocation=>ty_quantity,
      new_allocated                TYPE zif_stock_allocation=>ty_quantity,
      delta_allocated              TYPE zif_stock_allocation=>ty_quantity,
      old_shortage                 TYPE zif_stock_allocation=>ty_quantity,
      new_shortage                 TYPE zif_stock_allocation=>ty_quantity,
      delta_shortage               TYPE zif_stock_allocation=>ty_quantity,
      old_coverage_available       TYPE abap_bool,
      new_coverage_available       TYPE abap_bool,
      old_coverage                 TYPE zif_allocation_audit=>ty_coverage,
      new_coverage                 TYPE zif_allocation_audit=>ty_coverage,
      coverage_delta_available     TYPE abap_bool,
      coverage_delta               TYPE zif_allocation_audit=>ty_coverage,
      old_shortage_pct_available   TYPE abap_bool,
      new_shortage_pct_available   TYPE abap_bool,
      old_shortage_pct             TYPE zif_allocation_audit=>ty_coverage,
      new_shortage_pct             TYPE zif_allocation_audit=>ty_coverage,
      shortage_pct_delta_available TYPE abap_bool,
      shortage_pct_delta           TYPE zif_allocation_audit=>ty_coverage,
    END OF ty_summary.

  METHODS compare
    IMPORTING
      it_old               TYPE zif_stock_allocation=>tt_demands
      it_new               TYPE zif_stock_allocation=>tt_demands
      iv_change_type       TYPE ty_change_type OPTIONAL
      iv_reason            TYPE ty_change_reason OPTIONAL
      iv_old_status        TYPE zif_stock_allocation=>ty_allocation_status OPTIONAL
      iv_new_status        TYPE zif_stock_allocation=>ty_allocation_status OPTIONAL
      iv_include_unchanged TYPE abap_bool OPTIONAL
      iv_offset            TYPE i OPTIONAL
      iv_max_rows          TYPE i OPTIONAL
    EXPORTING
      es_summary           TYPE ty_summary
      ev_total_rows        TYPE i
    RETURNING
      VALUE(rt_changes)    TYPE tt_changes
    RAISING
      zcx_stock_allocation.

  METHODS sort_by_shortage
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_shortage_worsening
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_requested_delta
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_requested_date
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_coverage
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_coverage_worsening
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_spct_worsening
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_status_regression
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS sort_by_shortage_percentage
    IMPORTING
      it_changes        TYPE tt_changes
    RETURNING
      VALUE(rt_changes) TYPE tt_changes.

  METHODS reconcile
    IMPORTING
      it_snapshot              TYPE zif_stock_allocation=>tt_demands
      is_audit                 TYPE zif_allocation_audit=>ty_run
    RETURNING
      VALUE(rs_reconciliation) TYPE ty_reconciliation.

  METHODS get_reconciliation_transition
    IMPORTING
      iv_old_status        TYPE ty_reconciliation_status
      iv_new_status        TYPE ty_reconciliation_status
    RETURNING
      VALUE(rv_transition) TYPE ty_reconciliation_transition.

  METHODS get_running_age
    IMPORTING
      is_run        TYPE zif_allocation_audit=>ty_run
    RETURNING
      VALUE(rs_age) TYPE ty_running_age.

  METHODS get_running_age_trend
    IMPORTING
      is_old_age      TYPE ty_running_age
      is_new_age      TYPE ty_running_age
    RETURNING
      VALUE(rv_trend) TYPE ty_running_age_trend.

  METHODS get_audit_metadata_reasons
    IMPORTING
      iv_old_run        TYPE zif_allocation_audit=>ty_run
      iv_new_run        TYPE zif_allocation_audit=>ty_run
    RETURNING
      VALUE(rv_reasons) TYPE string.
ENDINTERFACE.
