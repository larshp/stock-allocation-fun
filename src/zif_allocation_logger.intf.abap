INTERFACE zif_allocation_logger PUBLIC.
  METHODS write
    IMPORTING
      it_allocations  TYPE zcl_stock_allocator=>ty_allocations
      iv_simulation   TYPE abap_bool
    RETURNING
      VALUE(rv_saved) TYPE abap_bool.
ENDINTERFACE.
