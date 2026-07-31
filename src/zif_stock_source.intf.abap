INTERFACE zif_stock_source PUBLIC.
  METHODS get_available
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
    RETURNING
      VALUE(rs_available) TYPE zif_stock_allocation=>ty_available
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
