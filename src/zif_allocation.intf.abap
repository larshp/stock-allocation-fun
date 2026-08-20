INTERFACE zif_allocation PUBLIC.

  "! Quantity in the base unit of measure. Same ABAP representation as the
  "! stock quantity fields of MARD, so quantities can be moved between the
  "! database and the allocation logic without conversion.
  TYPES ty_quantity TYPE p LENGTH 7 DECIMALS 3.

  "! Identifies the requirement a demand line originates from, down to the
  "! schedule line, because that is the level a quantity is wanted on a date.
  "!
  "! Sales order demand is document (10), item (6), schedule line (4). Stock
  "! transport order demand is marked with a leading letter, then document (10),
  "! item (5), schedule line (4), so that two documents from different number
  "! ranges carrying the same number cannot be taken for each other.
  TYPES ty_demand_id TYPE c LENGTH 24.

  "! Order in which demand is served, 01 first.
  TYPES ty_priority TYPE n LENGTH 2.

  "! Why a line did not get everything it asked for. Initial when it did.
  TYPES ty_reason TYPE c LENGTH 1.

  "! The reasons a line can fall short of what it asked for. There is one per
  "! rule that can hold stock back, because "short" on its own tells a planner
  "! nothing about what to do next: stock that is not there is a purchasing
  "! problem, stock that arrives too late is a scheduling one, and a line held
  "! back by a rule of the plant's own making is neither.
  CONSTANTS:
    BEGIN OF c_reason,
      no_stock      TYPE ty_reason VALUE 'S',
      supply_late   TYPE ty_reason VALUE 'L',
      customer_cap  TYPE ty_reason VALUE 'C',
      whole_units   TYPE ty_reason VALUE 'U',
      complete_only TYPE ty_reason VALUE 'D',
    END OF c_reason.

  "! A single requirement competing for stock. COMPLETE means the line is only
  "! worth serving in full: a part of it ships nothing, so confirming a part of
  "! it would tie up stock that cannot leave. CUSTOMER is who is waiting, where
  "! there is one: a stock transport order has none.
  "!
  "! UNIT_SIZE is how many base units one unit of the document is: 12 for a
  "! line ordered in cartons of twelve pieces, 1 where the document is in the
  "! base unit already. It is what makes a confirmation shippable as ordered,
  "! and only ZCL_ALLOC_WHOLE_UNITS reads it.
  TYPES:
    BEGIN OF ty_demand,
      demand_id TYPE ty_demand_id,
      matnr     TYPE mard-matnr,
      werks     TYPE mard-werks,
      quantity  TYPE ty_quantity,
      req_date  TYPE d,
      priority  TYPE ty_priority,
      complete  TYPE abap_bool,
      customer  TYPE vbak-kunnr,
      unit_size TYPE ty_quantity,
    END OF ty_demand.
  TYPES ty_demand_tab TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY.

  "! What a single demand line was awarded. SHORTFALL is REQUESTED minus
  "! CONFIRMED and is never negative. REQ_DATE is carried over from the demand
  "! so the answer says not only how much was confirmed but when it is needed.
  "!
  "! AVAIL_DATE is the day the confirmed quantity is there in full: the last of
  "! the supply that had to arrive for it. It is initial when the whole line
  "! comes off stock that is on the shelf already, and never later than
  "! REQ_DATE, because a requirement is not served from stock that arrives
  "! after it is wanted.
  "!
  "! REASON says what stopped a line that is short, one of C_REASON, and is
  "! initial for a line that got everything.
  TYPES:
    BEGIN OF ty_allocation,
      demand_id  TYPE ty_demand_id,
      req_date   TYPE d,
      avail_date TYPE d,
      requested  TYPE ty_quantity,
      confirmed  TYPE ty_quantity,
      shortfall  TYPE ty_quantity,
      reason     TYPE ty_reason,
    END OF ty_allocation.
  TYPES ty_allocation_tab TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

ENDINTERFACE.
