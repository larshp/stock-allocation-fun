INTERFACE zif_allocation_audit PUBLIC.
  TYPES ty_run_id TYPE zif_stock_allocation=>ty_run_id.
  TYPES ty_run_status TYPE c LENGTH 1.
  TYPES ty_message TYPE c LENGTH 220.
  TYPES:
    BEGIN OF ty_run,
      run_id           TYPE ty_run_id,
      material         TYPE zif_stock_allocation=>ty_material,
      plant            TYPE zif_stock_allocation=>ty_plant,
      storage_location TYPE zif_stock_allocation=>ty_storage_location,
      batch            TYPE zif_stock_allocation=>ty_batch,
      unit             TYPE zif_stock_allocation=>ty_unit,
      start_date       TYPE d,
      start_time       TYPE t,
      finish_date      TYPE d,
      finish_time      TYPE t,
      status           TYPE ty_run_status,
      available        TYPE zif_stock_allocation=>ty_quantity,
      demand_count     TYPE i,
      allocated        TYPE zif_stock_allocation=>ty_quantity,
      shortage         TYPE zif_stock_allocation=>ty_quantity,
      message          TYPE ty_message,
  END OF ty_run.
  TYPES tt_runs TYPE STANDARD TABLE OF ty_run WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_summary,
      total_runs      TYPE i,
      running_runs    TYPE i,
      success_runs    TYPE i,
      error_runs      TYPE i,
      partial_runs    TYPE i,
      allocated       TYPE zif_stock_allocation=>ty_quantity,
      shortage        TYPE zif_stock_allocation=>ty_quantity,
      last_run_id     TYPE ty_run_id,
      last_start_date TYPE d,
      last_start_time TYPE t,
      unit            TYPE zif_stock_allocation=>ty_unit,
      last_status     TYPE ty_run_status,
      last_message    TYPE ty_message,
    END OF ty_summary.

  METHODS get_runs
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit             TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_start_date_from  TYPE d OPTIONAL
      iv_start_date_to    TYPE d OPTIONAL
      iv_status           TYPE ty_run_status OPTIONAL
    RETURNING
      VALUE(rt_runs)      TYPE tt_runs
    RAISING
      zcx_stock_allocation.
  METHODS get_summary
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit             TYPE zif_stock_allocation=>ty_unit OPTIONAL
    RETURNING
      VALUE(rs_summary)   TYPE ty_summary
    RAISING
      zcx_stock_allocation.
  METHODS purge_runs_before
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit             TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_before_date      TYPE d
    RETURNING
      VALUE(rv_deleted)   TYPE i
      RAISING
      zcx_stock_allocation.

  METHODS record_rejection
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      iv_available        TYPE zif_stock_allocation=>ty_quantity
      iv_message          TYPE ty_message
    RETURNING
      VALUE(rv_run_id)    TYPE ty_run_id
    RAISING
      zcx_stock_allocation.

  METHODS start_run
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      iv_available        TYPE zif_stock_allocation=>ty_quantity
      iv_demand_count     TYPE i
    RETURNING
      VALUE(rv_run_id)    TYPE ty_run_id
    RAISING
      zcx_stock_allocation.
  METHODS finish_run
    IMPORTING
      iv_run_id    TYPE ty_run_id
      iv_status    TYPE ty_run_status
      iv_available TYPE zif_stock_allocation=>ty_quantity
      iv_allocated TYPE zif_stock_allocation=>ty_quantity
      iv_shortage  TYPE zif_stock_allocation=>ty_quantity
      iv_message   TYPE ty_message
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
