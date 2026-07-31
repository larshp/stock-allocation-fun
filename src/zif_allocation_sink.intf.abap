INTERFACE zif_allocation_sink PUBLIC.
  METHODS save_allocations
    IMPORTING
      iv_material TYPE zif_stock_allocation=>ty_material
      iv_plant    TYPE zif_stock_allocation=>ty_plant
      it_demands  TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
