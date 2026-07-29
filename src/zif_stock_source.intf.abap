INTERFACE zif_stock_source PUBLIC.

  METHODS get_available
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
    RETURNING
      VALUE(rs_stock)     TYPE zif_stock_allocation=>ty_stock.

ENDINTERFACE.
