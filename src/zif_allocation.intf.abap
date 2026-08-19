INTERFACE zif_allocation PUBLIC.

  "! Quantity in the base unit of measure. Same ABAP representation as the
  "! stock quantity fields of MARD, so quantities can be moved between the
  "! database and the allocation logic without conversion.
  TYPES ty_quantity TYPE p LENGTH 7 DECIMALS 3.

  "! Identifies the requirement a demand line originates from, for sales order
  "! demand this is the document number followed by the item number.
  TYPES ty_demand_id TYPE c LENGTH 16.

  "! Order in which demand is served, 01 first.
  TYPES ty_priority TYPE n LENGTH 2.

  "! A single requirement competing for stock. COMPLETE means the line is only
  "! worth serving in full: a part of it ships nothing, so confirming a part of
  "! it would tie up stock that cannot leave.
  TYPES:
    BEGIN OF ty_demand,
      demand_id TYPE ty_demand_id,
      matnr     TYPE mard-matnr,
      werks     TYPE mard-werks,
      quantity  TYPE ty_quantity,
      req_date  TYPE d,
      priority  TYPE ty_priority,
      complete  TYPE abap_bool,
    END OF ty_demand.
  TYPES ty_demand_tab TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.

  "! What a single demand line was awarded. SHORTFALL is REQUESTED minus
  "! CONFIRMED and is never negative. REQ_DATE is carried over from the demand
  "! so the answer says not only how much was confirmed but when it is needed.
  TYPES:
    BEGIN OF ty_allocation,
      demand_id TYPE ty_demand_id,
      req_date  TYPE d,
      requested TYPE ty_quantity,
      confirmed TYPE ty_quantity,
      shortfall TYPE ty_quantity,
    END OF ty_allocation.
  TYPES ty_allocation_tab TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

ENDINTERFACE.
