INTERFACE zif_allocation_authority PUBLIC.
  METHODS is_authorized
    IMPORTING
      iv_plant             TYPE zcl_stock_allocator=>ty_plant
    RETURNING
      VALUE(rv_authorized) TYPE abap_bool.
ENDINTERFACE.
