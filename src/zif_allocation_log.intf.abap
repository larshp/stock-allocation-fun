INTERFACE zif_allocation_log PUBLIC.
  METHODS record_run
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      iv_stock_qty        TYPE zif_stock_allocation=>ty_quantity
      iv_allocatable_qty  TYPE zif_stock_allocation=>ty_quantity
      iv_reserve          TYPE zif_stock_allocation=>ty_quantity
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      it_allocations      TYPE zif_stock_allocation=>tt_allocations
    RETURNING
      VALUE(rv_recorded)  TYPE abap_bool.
ENDINTERFACE.
