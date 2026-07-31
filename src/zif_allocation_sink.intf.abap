INTERFACE zif_allocation_sink PUBLIC.
  METHODS get_allocations
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
    RETURNING
      VALUE(rt_demands)   TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
  METHODS save_allocations
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      it_demands          TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
