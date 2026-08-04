INTERFACE zif_source_read_authority PUBLIC.
  METHODS check_stock
    IMPORTING
      iv_batch TYPE zif_stock_allocation=>ty_batch OPTIONAL
    RAISING
      zcx_stock_allocation.
  METHODS check_orders
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
