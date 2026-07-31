INTERFACE zif_stock_allocation PUBLIC.
  TYPES ty_material TYPE c LENGTH 40.
  TYPES ty_plant TYPE c LENGTH 4.
  TYPES ty_storage_location TYPE c LENGTH 4.
  TYPES ty_order_id TYPE c LENGTH 20.
  TYPES ty_quantity TYPE p LENGTH 8 DECIMALS 3.
  TYPES ty_unit TYPE c LENGTH 3.
  TYPES ty_movement_type TYPE c LENGTH 3.
  TYPES ty_priority TYPE i.

  TYPES:
    BEGIN OF ty_demand,
      order_id       TYPE ty_order_id,
      priority       TYPE ty_priority,
      requested_on   TYPE d,
      requested      TYPE ty_quantity,
      allocated      TYPE ty_quantity,
      shortage       TYPE ty_quantity,
      reservation_id TYPE ty_order_id,
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
