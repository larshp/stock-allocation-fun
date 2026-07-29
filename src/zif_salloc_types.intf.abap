INTERFACE zif_salloc_types PUBLIC.
  TYPES ty_order_id TYPE c LENGTH 16.
  TYPES ty_material TYPE c LENGTH 18.
  TYPES ty_plant TYPE c LENGTH 4.
  TYPES ty_quantity TYPE p LENGTH 8 DECIMALS 3.

  TYPES:
    BEGIN OF ty_demand,
      order_id     TYPE ty_order_id,
      priority     TYPE i,
      requested_on TYPE d,
      requested    TYPE ty_quantity,
      allocated    TYPE ty_quantity,
      shortage     TYPE ty_quantity,
    END OF ty_demand.
  TYPES tt_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.
ENDINTERFACE.
