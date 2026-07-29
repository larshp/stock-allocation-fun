INTERFACE zif_allocation_source PUBLIC.

  METHODS get_saved
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
    RETURNING
      VALUE(rs_saved)     TYPE zif_stock_allocation=>ty_saved_plan
    RAISING
      zcx_stock_allocation.

ENDINTERFACE.
