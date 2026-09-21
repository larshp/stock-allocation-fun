INTERFACE zif_allocation_read_authority PUBLIC.
  METHODS check_audit
    RAISING
      zcx_stock_allocation.
  METHODS check_results
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
