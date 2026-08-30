INTERFACE zif_allocation_logger PUBLIC.
  TYPES ty_run_id TYPE c LENGTH 32.

  METHODS write
    IMPORTING
      it_allocations        TYPE zcl_stock_allocator=>ty_allocations
      iv_simulation         TYPE abap_bool
      iv_run_id             TYPE ty_run_id
      iv_strategy           TYPE zcl_stock_allocator=>ty_strategy
      iv_horizon_date       TYPE d OPTIONAL
      iv_require_full_batch TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rv_saved)       TYPE abap_bool.
ENDINTERFACE.
