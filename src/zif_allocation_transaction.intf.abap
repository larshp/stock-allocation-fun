INTERFACE zif_allocation_transaction PUBLIC.
  METHODS commit
    RAISING
      zcx_stock_allocation.
  METHODS rollback
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
