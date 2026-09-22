INTERFACE zif_stock_source PUBLIC.
  METHODS read
    IMPORTING requests      TYPE zif_stock_alloc_types=>ty_requests
    RETURNING VALUE(stocks) TYPE zif_stock_alloc_types=>ty_stocks
    RAISING   zcx_stock_alloc.
ENDINTERFACE.
