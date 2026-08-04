INTERFACE zif_allocation_audit PUBLIC.
  TYPES ty_run_id TYPE zif_stock_allocation=>ty_run_id.
  TYPES ty_run_status TYPE c LENGTH 1.
  TYPES ty_strategy TYPE c LENGTH 1.
  TYPES ty_message TYPE c LENGTH 220.
  TYPES ty_coverage TYPE p LENGTH 8 DECIMALS 2.
  TYPES ty_duration TYPE p LENGTH 8 DECIMALS 2.
  TYPES:
    BEGIN OF ty_running_age,
      available TYPE abap_bool,
      seconds   TYPE i,
    END OF ty_running_age.
  TYPES:
    BEGIN OF ty_purge_preview,
      audit_count    TYPE i,
      snapshot_count TYPE i,
      running_count  TYPE i,
      success_count  TYPE i,
      partial_count  TYPE i,
      error_count    TYPE i,
      unknown_count  TYPE i,
    END OF ty_purge_preview.
  TYPES:
    BEGIN OF ty_run,
      run_id             TYPE ty_run_id,
      material           TYPE zif_stock_allocation=>ty_material,
      plant              TYPE zif_stock_allocation=>ty_plant,
      storage_location   TYPE zif_stock_allocation=>ty_storage_location,
      batch              TYPE zif_stock_allocation=>ty_batch,
      movement_type      TYPE zif_stock_allocation=>ty_movement_type,
      min_shelf_life     TYPE i,
      requested_on_from  TYPE d,
      requested_on_to    TYPE d,
      requested_deadline TYPE d,
      unit               TYPE zif_stock_allocation=>ty_unit,
      strategy           TYPE ty_strategy,
      start_date         TYPE d,
      start_time         TYPE t,
      finish_date        TYPE d,
      finish_time        TYPE t,
      status             TYPE ty_run_status,
      available          TYPE zif_stock_allocation=>ty_quantity,
      demand_count       TYPE i,
      full_count         TYPE i,
      partial_count      TYPE i,
      unallocated_count  TYPE i,
      allocated          TYPE zif_stock_allocation=>ty_quantity,
      shortage           TYPE zif_stock_allocation=>ty_quantity,
      requested          TYPE zif_stock_allocation=>ty_quantity,
      message            TYPE ty_message,
  END OF ty_run.
  TYPES tt_runs TYPE STANDARD TABLE OF ty_run WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_summary,
      total_runs                  TYPE i,
      priority_runs               TYPE i,
      fifo_runs                   TYPE i,
      full_only_runs              TYPE i,
      smallest_runs               TYPE i,
      largest_runs                TYPE i,
      best_runs                   TYPE i,
      legacy_strategy_runs        TYPE i,
      running_runs                TYPE i,
      success_runs                TYPE i,
      error_runs                  TYPE i,
      partial_runs                TYPE i,
      completion_pct              TYPE ty_coverage,
      success_rate_pct            TYPE ty_coverage,
      partial_rate_pct            TYPE ty_coverage,
      error_rate_pct              TYPE ty_coverage,
      allocated                   TYPE zif_stock_allocation=>ty_quantity,
      shortage                    TYPE zif_stock_allocation=>ty_quantity,
      requested                   TYPE zif_stock_allocation=>ty_quantity,
      demand_count                TYPE i,
      deadline_count              TYPE i,
      coverage                    TYPE ty_coverage,
      shortage_pct                TYPE ty_coverage,
      priority_allocated          TYPE zif_stock_allocation=>ty_quantity,
      priority_shortage           TYPE zif_stock_allocation=>ty_quantity,
      priority_requested          TYPE zif_stock_allocation=>ty_quantity,
      priority_coverage           TYPE ty_coverage,
      fifo_allocated              TYPE zif_stock_allocation=>ty_quantity,
      fifo_shortage               TYPE zif_stock_allocation=>ty_quantity,
      fifo_requested              TYPE zif_stock_allocation=>ty_quantity,
      fifo_coverage               TYPE ty_coverage,
      full_only_allocated         TYPE zif_stock_allocation=>ty_quantity,
      full_only_shortage          TYPE zif_stock_allocation=>ty_quantity,
      full_only_requested         TYPE zif_stock_allocation=>ty_quantity,
      full_only_coverage          TYPE ty_coverage,
      smallest_allocated          TYPE zif_stock_allocation=>ty_quantity,
      smallest_shortage           TYPE zif_stock_allocation=>ty_quantity,
      smallest_requested          TYPE zif_stock_allocation=>ty_quantity,
      smallest_coverage           TYPE ty_coverage,
      largest_allocated           TYPE zif_stock_allocation=>ty_quantity,
      largest_shortage            TYPE zif_stock_allocation=>ty_quantity,
      largest_requested           TYPE zif_stock_allocation=>ty_quantity,
      largest_coverage            TYPE ty_coverage,
      best_allocated              TYPE zif_stock_allocation=>ty_quantity,
      best_shortage               TYPE zif_stock_allocation=>ty_quantity,
      best_requested              TYPE zif_stock_allocation=>ty_quantity,
      best_coverage               TYPE ty_coverage,
      legacy_allocated            TYPE zif_stock_allocation=>ty_quantity,
      legacy_shortage             TYPE zif_stock_allocation=>ty_quantity,
      legacy_requested            TYPE zif_stock_allocation=>ty_quantity,
      legacy_coverage             TYPE ty_coverage,
      full_count                  TYPE i,
      partial_count               TYPE i,
      unallocated_count           TYPE i,
      last_run_id                 TYPE ty_run_id,
      last_start_date             TYPE d,
      last_start_time             TYPE t,
      last_requested_on_from      TYPE d,
      last_requested_on_to        TYPE d,
      last_requested_deadline     TYPE d,
      earliest_requested_deadline TYPE d,
      latest_requested_deadline   TYPE d,
      last_deadline_age_days      TYPE i,
      oldest_deadline_age_days    TYPE i,
      newest_deadline_age_days    TYPE i,
      deadline_age_reference_date TYPE d,
      last_strategy               TYPE ty_strategy,
      last_finish_date            TYPE d,
      last_finish_time            TYPE t,
      last_duration_seconds       TYPE i,
      average_duration_seconds    TYPE ty_duration,
      minimum_duration_seconds    TYPE i,
      maximum_duration_seconds    TYPE i,
      completed_duration_runs     TYPE i,
      oldest_running_age_seconds  TYPE i,
      oldest_running_run_id       TYPE ty_run_id,
      newest_running_age_seconds  TYPE i,
      newest_running_run_id       TYPE ty_run_id,
      unit                        TYPE zif_stock_allocation=>ty_unit,
      mixed_units                 TYPE abap_bool,
      movement_type_context       TYPE string,
      min_shelf_life_context      TYPE i,
      policy_context_available    TYPE abap_bool,
      mixed_policies              TYPE abap_bool,
      last_status                 TYPE ty_run_status,
      last_message                TYPE ty_message,
    END OF ty_summary.

  METHODS get_runs
    IMPORTING
      iv_material             TYPE zif_stock_allocation=>ty_material
      iv_plant                TYPE zif_stock_allocation=>ty_plant
      iv_storage_location     TYPE zif_stock_allocation=>ty_storage_location
      iv_batch                TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_movement_type        TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life       TYPE i OPTIONAL
      iv_requested_on_from    TYPE d OPTIONAL
      iv_requested_on_to      TYPE d OPTIONAL
      iv_requested_overdue    TYPE abap_bool OPTIONAL
      iv_overdue_date         TYPE d OPTIONAL
      iv_deadline_only        TYPE abap_bool OPTIONAL
      iv_deadline_from        TYPE d OPTIONAL
      iv_deadline_to          TYPE d OPTIONAL
      iv_deadline_age_from    TYPE i OPTIONAL
      iv_deadline_age_to      TYPE i OPTIONAL
      iv_deadline_age_date    TYPE d OPTIONAL
      iv_run_id               TYPE ty_run_id OPTIONAL
      iv_run_id_contains      TYPE ty_run_id OPTIONAL
      iv_unit                 TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_start_date_from      TYPE d OPTIONAL
      iv_start_date_to        TYPE d OPTIONAL
      iv_finish_date_from     TYPE d OPTIONAL
      iv_finish_date_to       TYPE d OPTIONAL
      iv_shortage_from        TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_shortage_to          TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_allocated_from       TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_allocated_to         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_available_from       TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_available_to         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_requested_from       TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_requested_to         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_demand_from          TYPE i OPTIONAL
      iv_demand_to            TYPE i OPTIONAL
      iv_duration_from        TYPE i OPTIONAL
      iv_duration_to          TYPE i OPTIONAL
      iv_stale_seconds        TYPE i OPTIONAL
      iv_running_age_to       TYPE i OPTIONAL
      iv_coverage_from        TYPE ty_coverage OPTIONAL
      iv_coverage_to          TYPE ty_coverage OPTIONAL
      iv_shortage_pct_from    TYPE ty_coverage OPTIONAL
      iv_shortage_pct_to      TYPE ty_coverage OPTIONAL
      iv_sort_by_shortage     TYPE abap_bool OPTIONAL
      iv_sort_by_coverage     TYPE abap_bool OPTIONAL
      iv_sort_by_shrt_pct     TYPE abap_bool OPTIONAL
      iv_sort_by_demand_count TYPE abap_bool OPTIONAL
      iv_sort_by_deadline_age TYPE abap_bool OPTIONAL
      iv_sort_by_due          TYPE abap_bool OPTIONAL
      iv_sort_by_status       TYPE abap_bool OPTIONAL
      iv_sort_by_duration     TYPE abap_bool OPTIONAL
      iv_max_rows             TYPE i OPTIONAL
      iv_status               TYPE ty_run_status OPTIONAL
      iv_strategy             TYPE ty_strategy OPTIONAL
      iv_legacy_strategy      TYPE abap_bool OPTIONAL
      iv_message_contains     TYPE ty_message OPTIONAL
      iv_message_only         TYPE abap_bool OPTIONAL
      iv_offset               TYPE i OPTIONAL
    EXPORTING
      ev_total_rows           TYPE i
    RETURNING
      VALUE(rt_runs)          TYPE tt_runs
    RAISING
      zcx_stock_allocation.
  METHODS get_summary
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_location
      iv_batch             TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_run_id            TYPE ty_run_id OPTIONAL
      iv_run_id_contains   TYPE ty_run_id OPTIONAL
      iv_unit              TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_movement_type     TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life    TYPE i OPTIONAL
      iv_requested_on_from TYPE d OPTIONAL
      iv_requested_on_to   TYPE d OPTIONAL
      iv_requested_overdue TYPE abap_bool OPTIONAL
      iv_overdue_date      TYPE d OPTIONAL
      iv_deadline_only     TYPE abap_bool OPTIONAL
      iv_deadline_from     TYPE d OPTIONAL
      iv_deadline_to       TYPE d OPTIONAL
      iv_deadline_age_from TYPE i OPTIONAL
      iv_deadline_age_to   TYPE i OPTIONAL
      iv_deadline_age_date TYPE d OPTIONAL
      iv_start_date_from   TYPE d OPTIONAL
      iv_start_date_to     TYPE d OPTIONAL
      iv_finish_date_from  TYPE d OPTIONAL
      iv_finish_date_to    TYPE d OPTIONAL
      iv_duration_from     TYPE i OPTIONAL
      iv_duration_to       TYPE i OPTIONAL
      iv_coverage_from     TYPE ty_coverage OPTIONAL
      iv_coverage_to       TYPE ty_coverage OPTIONAL
      iv_shortage_pct_from TYPE ty_coverage OPTIONAL
      iv_shortage_pct_to   TYPE ty_coverage OPTIONAL
      iv_shortage_from     TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_shortage_to       TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_allocated_from    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_allocated_to      TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_available_from    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_available_to      TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_requested_from    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_requested_to      TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_demand_from       TYPE i OPTIONAL
      iv_demand_to         TYPE i OPTIONAL
      iv_stale_seconds     TYPE i OPTIONAL
      iv_running_age_to    TYPE i OPTIONAL
      iv_status            TYPE ty_run_status OPTIONAL
      iv_strategy          TYPE ty_strategy OPTIONAL
      iv_legacy_strategy   TYPE abap_bool OPTIONAL
      iv_message_contains  TYPE ty_message OPTIONAL
      iv_message_only      TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(rs_summary)    TYPE ty_summary
    RAISING
      zcx_stock_allocation.

  METHODS get_running_age
    IMPORTING
      is_run        TYPE ty_run
      iv_now_date   TYPE d OPTIONAL
      iv_now_time   TYPE t OPTIONAL
    RETURNING
      VALUE(rs_age) TYPE ty_running_age.

  METHODS purge_runs_before
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_location
      iv_batch             TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_run_id            TYPE ty_run_id OPTIONAL
      iv_run_id_contains   TYPE ty_run_id OPTIONAL
      iv_unit              TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_movement_type     TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life    TYPE i OPTIONAL
      iv_status            TYPE ty_run_status OPTIONAL
      iv_strategy          TYPE ty_strategy OPTIONAL
      iv_legacy_strategy   TYPE abap_bool OPTIONAL
      iv_message_contains  TYPE ty_message OPTIONAL
      iv_message_only      TYPE abap_bool OPTIONAL
      iv_deadline_only     TYPE abap_bool OPTIONAL
      iv_deadline_from     TYPE d OPTIONAL
      iv_deadline_to       TYPE d OPTIONAL
      iv_deadline_age_from TYPE i OPTIONAL
      iv_deadline_age_to   TYPE i OPTIONAL
      iv_deadline_age_date TYPE d OPTIONAL
      iv_overdue_only      TYPE abap_bool OPTIONAL
      iv_overdue_date      TYPE d OPTIONAL
      iv_requested_on_from TYPE d OPTIONAL
      iv_requested_on_to   TYPE d OPTIONAL
      iv_start_date_from   TYPE d OPTIONAL
      iv_finish_date_from  TYPE d OPTIONAL
      iv_finish_date_to    TYPE d OPTIONAL
      iv_before_date       TYPE d
    EXPORTING
      ev_deleted_snapshots TYPE i
      ev_deleted_success   TYPE i
      ev_deleted_partial   TYPE i
      ev_deleted_error     TYPE i
      ev_protected_running TYPE i
      ev_protected_unknown TYPE i
    RETURNING
      VALUE(rv_deleted)    TYPE i
      RAISING
      zcx_stock_allocation.
  METHODS get_purge_preview
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_location
      iv_batch             TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_run_id            TYPE ty_run_id OPTIONAL
      iv_run_id_contains   TYPE ty_run_id OPTIONAL
      iv_unit              TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_movement_type     TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life    TYPE i OPTIONAL
      iv_status            TYPE ty_run_status OPTIONAL
      iv_strategy          TYPE ty_strategy OPTIONAL
      iv_legacy_strategy   TYPE abap_bool OPTIONAL
      iv_message_contains  TYPE ty_message OPTIONAL
      iv_message_only      TYPE abap_bool OPTIONAL
      iv_deadline_only     TYPE abap_bool OPTIONAL
      iv_deadline_from     TYPE d OPTIONAL
      iv_deadline_to       TYPE d OPTIONAL
      iv_deadline_age_from TYPE i OPTIONAL
      iv_deadline_age_to   TYPE i OPTIONAL
      iv_deadline_age_date TYPE d OPTIONAL
      iv_overdue_only      TYPE abap_bool OPTIONAL
      iv_overdue_date      TYPE d OPTIONAL
      iv_requested_on_from TYPE d OPTIONAL
      iv_requested_on_to   TYPE d OPTIONAL
      iv_start_date_from   TYPE d OPTIONAL
      iv_finish_date_from  TYPE d OPTIONAL
      iv_finish_date_to    TYPE d OPTIONAL
      iv_before_date       TYPE d
    RETURNING
      VALUE(rs_preview)    TYPE ty_purge_preview
    RAISING
      zcx_stock_allocation.

  METHODS record_rejection
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_location
      iv_batch             TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_movement_type     TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life    TYPE i OPTIONAL
      iv_unit              TYPE zif_stock_allocation=>ty_unit
      iv_requested_on_from TYPE d OPTIONAL
      iv_requested_on_to   TYPE d OPTIONAL
      iv_available         TYPE zif_stock_allocation=>ty_quantity
      iv_message           TYPE ty_message
    RETURNING
      VALUE(rv_run_id)     TYPE ty_run_id
    RAISING
      zcx_stock_allocation.

  METHODS start_run
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_location
      iv_batch             TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_movement_type     TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life    TYPE i OPTIONAL
      iv_unit              TYPE zif_stock_allocation=>ty_unit
      iv_requested_on_from TYPE d OPTIONAL
      iv_requested_on_to   TYPE d OPTIONAL
      iv_available         TYPE zif_stock_allocation=>ty_quantity
      iv_demand_count      TYPE i
      iv_strategy          TYPE ty_strategy OPTIONAL
    RETURNING
      VALUE(rv_run_id)     TYPE ty_run_id
    RAISING
      zcx_stock_allocation.
  METHODS finish_run
    IMPORTING
      iv_run_id            TYPE ty_run_id
      iv_status            TYPE ty_run_status
      iv_available         TYPE zif_stock_allocation=>ty_quantity
      iv_allocated         TYPE zif_stock_allocation=>ty_quantity
      iv_shortage          TYPE zif_stock_allocation=>ty_quantity
      iv_full_count        TYPE i OPTIONAL
      iv_partial_count     TYPE i OPTIONAL
      iv_unallocated_count TYPE i OPTIONAL
      iv_message           TYPE ty_message
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
