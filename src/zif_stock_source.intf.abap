INTERFACE zif_stock_source PUBLIC.
  METHODS get_available
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
    RETURNING
      VALUE(rv_available) TYPE zif_stock_allocation=>ty_quantity
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
