INTERFACE zif_stock_order_source PUBLIC.
  TYPES: BEGIN OF ty_order,
           order_id      TYPE c LENGTH 12,
           priority      TYPE i,
           allow_partial TYPE abap_bool,
         END OF ty_order.
  TYPES ty_orders TYPE STANDARD TABLE OF ty_order WITH DEFAULT KEY.
  METHODS read
    IMPORTING orders          TYPE ty_orders
              through_date    TYPE d DEFAULT '99991231'
    RETURNING VALUE(requests) TYPE zif_stock_alloc_types=>ty_requests
    RAISING   zcx_stock_alloc.
ENDINTERFACE.
