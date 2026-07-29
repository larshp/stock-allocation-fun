INTERFACE zif_allocation_lock PUBLIC.

  METHODS acquire
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
    RETURNING
      VALUE(rv_acquired)  TYPE abap_bool.

  METHODS release
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc.

ENDINTERFACE.

