INTERFACE zif_allocation_source PUBLIC.

  METHODS get_saved
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      iv_version_no       TYPE i OPTIONAL
    RETURNING
      VALUE(rs_saved)     TYPE zif_stock_allocation=>ty_saved_plan
    RAISING
      zcx_stock_allocation.

  METHODS list_versions
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      iv_max_versions     TYPE i
      iv_before_version   TYPE i OPTIONAL
    RETURNING
      VALUE(rt_versions)  TYPE zif_stock_allocation=>tt_plan_versions
    RAISING
      zcx_stock_allocation.

ENDINTERFACE.
