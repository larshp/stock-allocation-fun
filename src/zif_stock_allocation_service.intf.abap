INTERFACE zif_stock_allocation_service PUBLIC.
  METHODS execute
    IMPORTING
      it_requests           TYPE zcl_stock_allocator=>ty_requests
      iv_simulation         TYPE abap_bool DEFAULT abap_false
      iv_horizon_date       TYPE d OPTIONAL
      iv_require_full_batch TYPE abap_bool DEFAULT abap_false
      iv_strategy           TYPE zcl_stock_allocator=>ty_strategy
        DEFAULT zcl_stock_allocator=>gc_strategy_priority_due
    RETURNING
      VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.
ENDINTERFACE.
