INTERFACE zif_order_sink PUBLIC.
  TYPES ty_sales_document TYPE c LENGTH 10.
  TYPES ty_sales_item TYPE n LENGTH 6.
  TYPES ty_schedule_line TYPE n LENGTH 4.

  METHODS change_schedule_quantity
    IMPORTING
      iv_sales_document TYPE ty_sales_document
      iv_sales_item     TYPE ty_sales_item
      iv_schedule_line  TYPE ty_schedule_line
      iv_quantity       TYPE zif_stock_allocation=>ty_quantity
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
