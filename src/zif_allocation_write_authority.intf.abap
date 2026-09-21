INTERFACE zif_allocation_write_authority PUBLIC.
  METHODS check_audit_write
    RAISING
      zcx_stock_allocation.
  METHODS check_result_write
    RAISING
      zcx_stock_allocation.
  METHODS check_result_delete
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
