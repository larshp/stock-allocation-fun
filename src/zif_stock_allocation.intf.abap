INTERFACE zif_stock_allocation PUBLIC.

  TYPES ty_material      TYPE mard-matnr.
  TYPES ty_plant         TYPE mard-werks.
  TYPES ty_storage_loc   TYPE mard-lgort.
  TYPES ty_sales_order   TYPE vbbe-vbeln.
  TYPES ty_sales_item    TYPE vbbe-posnr.
  TYPES ty_schedule_line TYPE vbbe-etenr.
  TYPES ty_delivery_date TYPE vbbe-mbdat.
  TYPES ty_start_date    TYPE vbbe-mbdat.
  TYPES ty_cutoff_date   TYPE vbbe-mbdat.
  TYPES ty_quantity      TYPE p LENGTH 8 DECIMALS 3.
  TYPES ty_total_quantity TYPE decfloat34.
  TYPES ty_percentage     TYPE decfloat34.
  TYPES ty_status        TYPE c LENGTH 1.
  TYPES ty_priority      TYPE i.
  TYPES ty_unit          TYPE mara-meins.
  TYPES ty_strategy      TYPE c LENGTH 1.
  TYPES tt_strategies TYPE STANDARD TABLE OF ty_strategy WITH EMPTY KEY.
  TYPES ty_objective     TYPE c LENGTH 1.

  CONSTANTS c_strategy_fifo        TYPE ty_strategy VALUE 'F'.
  CONSTANTS c_strategy_proportional TYPE ty_strategy VALUE 'P'.
  CONSTANTS c_strategy_fair_share  TYPE ty_strategy VALUE 'E'.
  CONSTANTS c_strategy_smallest_first TYPE ty_strategy VALUE 'S'.
  CONSTANTS c_strategy_complete_only TYPE ty_strategy VALUE 'C'.
  CONSTANTS c_objective_service TYPE ty_objective VALUE 'S'.
  CONSTANTS c_objective_fill    TYPE ty_objective VALUE 'Q'.
  CONSTANTS c_objective_fairness TYPE ty_objective VALUE 'F'.
  CONSTANTS c_objective_urgency  TYPE ty_objective VALUE 'D'.

  TYPES:
    BEGIN OF ty_stock,
      quantity TYPE ty_quantity,
      unit     TYPE ty_unit,
    END OF ty_stock.

  CONSTANTS c_status_full    TYPE ty_status VALUE 'F'.
  CONSTANTS c_status_partial TYPE ty_status VALUE 'P'.
  CONSTANTS c_status_none    TYPE ty_status VALUE 'N'.

  TYPES:
    BEGIN OF ty_demand,
      sales_order   TYPE ty_sales_order,
      sales_item    TYPE ty_sales_item,
      schedule_line TYPE ty_schedule_line,
      delivery_date TYPE ty_delivery_date,
      priority      TYPE ty_priority,
      requested_qty TYPE ty_quantity,
    END OF ty_demand.
  TYPES tt_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_allocation,
      sales_order   TYPE ty_sales_order,
      sales_item    TYPE ty_sales_item,
      schedule_line TYPE ty_schedule_line,
      delivery_date TYPE ty_delivery_date,
      priority      TYPE ty_priority,
      requested_qty TYPE ty_quantity,
      allocated_qty TYPE ty_quantity,
      shortage_qty  TYPE ty_quantity,
      reserve_qty   TYPE ty_quantity,
      unit          TYPE ty_unit,
      strategy      TYPE ty_strategy,
      start_date    TYPE ty_start_date,
      cutoff_date   TYPE ty_cutoff_date,
      status        TYPE ty_status,
    END OF ty_allocation.
  TYPES tt_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_plan,
      stock_qty       TYPE ty_quantity,
      allocatable_qty TYPE ty_quantity,
      reserve_qty     TYPE ty_quantity,
      unit            TYPE ty_unit,
      strategy        TYPE ty_strategy,
      start_date      TYPE ty_start_date,
      cutoff_date     TYPE ty_cutoff_date,
      allocations     TYPE tt_allocations,
    END OF ty_plan.
  TYPES tt_plans TYPE STANDARD TABLE OF ty_plan WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_saved_plan,
      found      TYPE abap_bool,
      version_no TYPE i,
      plan       TYPE ty_plan,
      created_on TYPE d,
      created_at TYPE t,
      created_by TYPE c LENGTH 12,
      age_days   TYPE i,
      stale      TYPE abap_bool,
    END OF ty_saved_plan.

  TYPES:
    BEGIN OF ty_drift_item,
      sales_order           TYPE ty_sales_order,
      sales_item            TYPE ty_sales_item,
      schedule_line         TYPE ty_schedule_line,
      change_type           TYPE c LENGTH 1,
      demand_changed        TYPE abap_bool,
      outcome_changed       TYPE abap_bool,
      saved_requested_qty   TYPE ty_quantity,
      current_requested_qty TYPE ty_quantity,
      saved_allocated_qty   TYPE ty_quantity,
      current_allocated_qty TYPE ty_quantity,
      saved_status          TYPE ty_status,
      current_status        TYPE ty_status,
    END OF ty_drift_item.
  TYPES tt_drift_items TYPE STANDARD TABLE OF ty_drift_item WITH EMPTY KEY.

  CONSTANTS c_drift_added   TYPE c LENGTH 1 VALUE 'A'.
  CONSTANTS c_drift_removed TYPE c LENGTH 1 VALUE 'R'.
  CONSTANTS c_drift_changed TYPE c LENGTH 1 VALUE 'C'.
  CONSTANTS c_drift_severity_none    TYPE c LENGTH 1 VALUE 'N'.
  CONSTANTS c_drift_severity_stock   TYPE c LENGTH 1 VALUE 'S'.
  CONSTANTS c_drift_severity_demand  TYPE c LENGTH 1 VALUE 'D'.
  CONSTANTS c_drift_severity_outcome TYPE c LENGTH 1 VALUE 'O'.

  TYPES:
    BEGIN OF ty_plan_drift,
      has_drift             TYPE abap_bool,
      severity              TYPE c LENGTH 1,
      context_changed       TYPE abap_bool,
      stock_delta           TYPE ty_total_quantity,
      allocated_delta       TYPE ty_total_quantity,
      shortage_delta        TYPE ty_total_quantity,
      added_count           TYPE i,
      removed_count         TYPE i,
      demand_changed_count  TYPE i,
      outcome_changed_count TYPE i,
      items                 TYPE tt_drift_items,
    END OF ty_plan_drift.

  TYPES:
    BEGIN OF ty_summary,
      demand_count           TYPE i,
      full_count             TYPE i,
      partial_count          TYPE i,
      none_count             TYPE i,
      shortage_count         TYPE i,
      earliest_shortage_date TYPE ty_delivery_date,
      requested_qty          TYPE ty_total_quantity,
      allocated_qty          TYPE ty_total_quantity,
      shortage_qty           TYPE ty_total_quantity,
      stock_qty              TYPE ty_total_quantity,
      allocatable_qty        TYPE ty_total_quantity,
      reserve_qty            TYPE ty_total_quantity,
      unused_qty             TYPE ty_total_quantity,
      quantity_fill_pct      TYPE ty_percentage,
      service_level_pct      TYPE ty_percentage,
      stock_utilization_pct  TYPE ty_percentage,
      fairness_pct           TYPE ty_percentage,
      unit                   TYPE ty_unit,
    END OF ty_summary.

ENDINTERFACE.
