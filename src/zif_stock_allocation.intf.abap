INTERFACE zif_stock_allocation PUBLIC.

  TYPES ty_material      TYPE c LENGTH 40.
  TYPES ty_plant         TYPE c LENGTH 4.
  TYPES ty_storage_loc   TYPE c LENGTH 4.
  TYPES ty_sales_order   TYPE c LENGTH 10.
  TYPES ty_sales_item    TYPE n LENGTH 6.
  TYPES ty_schedule_line TYPE n LENGTH 4.
  TYPES ty_quantity      TYPE p LENGTH 8 DECIMALS 3.
  TYPES ty_status        TYPE c LENGTH 1.

  CONSTANTS c_status_full    TYPE ty_status VALUE 'F'.
  CONSTANTS c_status_partial TYPE ty_status VALUE 'P'.
  CONSTANTS c_status_none    TYPE ty_status VALUE 'N'.

  TYPES:
    BEGIN OF ty_demand,
      sales_order   TYPE ty_sales_order,
      sales_item    TYPE ty_sales_item,
      schedule_line TYPE ty_schedule_line,
      delivery_date TYPE d,
      requested_qty TYPE ty_quantity,
    END OF ty_demand.
  TYPES tt_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_allocation,
      sales_order   TYPE ty_sales_order,
      sales_item    TYPE ty_sales_item,
      schedule_line TYPE ty_schedule_line,
      delivery_date TYPE d,
      requested_qty TYPE ty_quantity,
      allocated_qty TYPE ty_quantity,
      shortage_qty  TYPE ty_quantity,
      status        TYPE ty_status,
    END OF ty_allocation.
  TYPES tt_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

ENDINTERFACE.
