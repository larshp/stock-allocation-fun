INTERFACE zif_stock_alloc_types PUBLIC.
  TYPES ty_quantity TYPE p LENGTH 7 DECIMALS 3.
  TYPES ty_reason TYPE c LENGTH 20.
  TYPES: BEGIN OF ty_origin,
           order_id         TYPE c LENGTH 12,
           reservation      TYPE n LENGTH 10,
           reservation_item TYPE n LENGTH 4,
           reservation_type TYPE c LENGTH 1,
         END OF ty_origin.
  TYPES: BEGIN OF ty_stock,
           material     TYPE c LENGTH 18,
           plant        TYPE c LENGTH 4,
           storage      TYPE c LENGTH 4,
           unit         TYPE c LENGTH 3,
           quantity     TYPE ty_quantity,
           safety_stock TYPE ty_quantity,
           committed    TYPE ty_quantity,
         END OF ty_stock.
  TYPES ty_stocks TYPE STANDARD TABLE OF ty_stock WITH DEFAULT KEY.
  TYPES: BEGIN OF ty_request,
           request_id     TYPE c LENGTH 32,
           material       TYPE c LENGTH 18,
           plant          TYPE c LENGTH 4,
           storage        TYPE c LENGTH 4,
           unit           TYPE c LENGTH 3,
           quantity       TYPE ty_quantity,
           priority       TYPE i,
           required_date  TYPE d,
           allow_partial  TYPE abap_bool,
           lot_size       TYPE ty_quantity,
           min_allocation TYPE ty_quantity,
           origin         TYPE ty_origin,
         END OF ty_request.
  TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH DEFAULT KEY.
  TYPES: BEGIN OF ty_allocation,
           request_id       TYPE c LENGTH 32,
           material         TYPE c LENGTH 18,
           plant            TYPE c LENGTH 4,
           storage          TYPE c LENGTH 4,
           unit             TYPE c LENGTH 3,
           required_date    TYPE d,
           requested        TYPE ty_quantity,
           allocated        TYPE ty_quantity,
           shortage         TYPE ty_quantity,
           status           TYPE c LENGTH 10,
           reason           TYPE ty_reason,
           available_before TYPE ty_quantity,
           available_after  TYPE ty_quantity,
           origin           TYPE ty_origin,
         END OF ty_allocation.
  TYPES ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH DEFAULT KEY.
  CONSTANTS: status_full    TYPE c LENGTH 10 VALUE 'FULL',
             status_partial TYPE c LENGTH 10 VALUE 'PARTIAL',
             status_short   TYPE c LENGTH 10 VALUE 'SHORTAGE'.
  CONSTANTS: reason_full TYPE ty_reason VALUE 'FULLY_ALLOCATED',
             reason_missing TYPE ty_reason VALUE 'MISSING_STOCK',
             reason_empty TYPE ty_reason VALUE 'NO_AVAILABLE_STOCK',
             reason_insufficient TYPE ty_reason VALUE 'INSUFFICIENT_STOCK',
             reason_complete TYPE ty_reason VALUE 'COMPLETE_ONLY',
             reason_lot TYPE ty_reason VALUE 'LOT_ROUNDED',
             reason_minimum TYPE ty_reason VALUE 'BELOW_MINIMUM'.
ENDINTERFACE.
