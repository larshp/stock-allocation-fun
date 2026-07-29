INTERFACE zif_demand_source PUBLIC.

  METHODS get_open_demands
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      iv_start_date       TYPE zif_stock_allocation=>ty_start_date OPTIONAL
      iv_cutoff_date      TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
    RETURNING
      VALUE(rt_demands)   TYPE zif_stock_allocation=>tt_demands.

ENDINTERFACE.
