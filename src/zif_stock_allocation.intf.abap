INTERFACE zif_stock_allocation PUBLIC.
  TYPES ty_material TYPE c LENGTH 40.
  TYPES ty_plant TYPE c LENGTH 4.
  TYPES ty_storage_location TYPE c LENGTH 4.
  TYPES ty_batch TYPE c LENGTH 10.
  TYPES ty_order_id TYPE c LENGTH 20.
  TYPES ty_run_id TYPE c LENGTH 32.
  TYPES ty_sales_document TYPE c LENGTH 10.
  CONSTANTS c_sap_document_length TYPE i VALUE 10.
  TYPES ty_sales_document_type TYPE c LENGTH 4.
  CONSTANTS c_fiscal_year_length TYPE i VALUE 4.
  TYPES ty_sales_item TYPE n LENGTH 6.
  TYPES ty_schedule_line TYPE n LENGTH 4.
  TYPES ty_quantity TYPE p LENGTH 8 DECIMALS 3.
  TYPES ty_unit TYPE c LENGTH 3.
  TYPES ty_movement_type TYPE c LENGTH 3.
  CONSTANTS c_movement_type_length TYPE i VALUE 3.
  TYPES ty_priority TYPE i.
  CONSTANTS c_max_priority TYPE ty_priority VALUE 99.
  TYPES ty_allocation_status TYPE c LENGTH 1.
  TYPES:
    BEGIN OF ty_available,
      quantity              TYPE ty_quantity,
      unit                  TYPE ty_unit,
      material_found        TYPE abap_bool,
      batch_managed         TYPE abap_bool,
      batch_found           TYPE abap_bool,
      batch_expiration_date TYPE d,
      batch_restricted      TYPE abap_bool,
    END OF ty_available.

  TYPES:
    BEGIN OF ty_demand,
      allocation_run_id         TYPE ty_run_id,
      allocation_strategy       TYPE c LENGTH 1,
      allocation_unit           TYPE ty_unit,
      sales_document            TYPE ty_sales_document,
      sales_document_type       TYPE ty_sales_document_type,
      sales_item                TYPE ty_sales_item,
      schedule_line             TYPE ty_schedule_line,
      order_unit                TYPE ty_unit,
      order_id                  TYPE ty_order_id,
      priority                  TYPE ty_priority,
      requested_on              TYPE d,
      requested                 TYPE ty_quantity,
      allocated                 TYPE ty_quantity,
      shortage                  TYPE ty_quantity,
      allocation_status         TYPE ty_allocation_status,
      reservation_id            TYPE ty_order_id,
      reservation_date          TYPE d,
      reservation_movement_type TYPE ty_movement_type,
      reservation_unit          TYPE ty_unit,
    END OF ty_demand.
  TYPES tt_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.

  METHODS allocate
    IMPORTING
      iv_available        TYPE ty_quantity
    CHANGING
      ct_demands          TYPE tt_demands
    RETURNING
      VALUE(rv_remaining) TYPE ty_quantity
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
