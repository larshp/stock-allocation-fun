INTERFACE zif_stock_allocation PUBLIC.

  TYPES ty_material      TYPE mard-matnr.
  TYPES ty_plant         TYPE mard-werks.
  TYPES ty_storage_loc   TYPE mard-lgort.
  TYPES ty_sales_order   TYPE vbbe-vbeln.
  TYPES ty_sales_item    TYPE vbbe-posnr.
  TYPES ty_schedule_line TYPE vbbe-etenr.
  TYPES ty_delivery_date TYPE vbbe-mbdat.
  TYPES ty_quantity      TYPE p LENGTH 8 DECIMALS 3.
  TYPES ty_status        TYPE c LENGTH 1.
  TYPES ty_priority      TYPE i.
  TYPES ty_unit          TYPE mara-meins.

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
      status        TYPE ty_status,
    END OF ty_allocation.
  TYPES tt_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_plan,
      stock_qty       TYPE ty_quantity,
      allocatable_qty TYPE ty_quantity,
      reserve_qty     TYPE ty_quantity,
      unit            TYPE ty_unit,
      allocations     TYPE tt_allocations,
    END OF ty_plan.

  TYPES:
    BEGIN OF ty_summary,
      demand_count    TYPE i,
      full_count      TYPE i,
      partial_count   TYPE i,
      none_count      TYPE i,
      requested_qty   TYPE ty_quantity,
      allocated_qty   TYPE ty_quantity,
      shortage_qty    TYPE ty_quantity,
      stock_qty       TYPE ty_quantity,
      allocatable_qty TYPE ty_quantity,
      reserve_qty     TYPE ty_quantity,
      unit            TYPE ty_unit,
    END OF ty_summary.

ENDINTERFACE.
