INTERFACE zif_allocation_writer PUBLIC.
  METHODS save_allocations
    CHANGING
      ct_allocations TYPE zcl_stock_allocator=>ty_allocations.
ENDINTERFACE.
