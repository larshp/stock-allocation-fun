INTERFACE zif_allocation_sink PUBLIC.
  METHODS get_allocations
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit             TYPE zif_stock_allocation=>ty_unit OPTIONAL
    RETURNING
      VALUE(rt_demands)   TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
  METHODS save_allocations
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_run_id           TYPE zif_stock_allocation=>ty_run_id
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      it_demands          TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
