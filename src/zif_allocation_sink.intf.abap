INTERFACE zif_allocation_sink PUBLIC.

  METHODS save
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      it_allocations      TYPE zif_stock_allocation=>tt_allocations.

ENDINTERFACE.
