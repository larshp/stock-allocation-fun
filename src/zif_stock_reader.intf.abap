INTERFACE zif_stock_reader PUBLIC.
  METHODS read_stock
    IMPORTING
      it_requests     TYPE zcl_stock_allocator=>ty_requests
    RETURNING
      VALUE(rt_stock) TYPE zcl_stock_allocator=>ty_stock_balances.
ENDINTERFACE.
