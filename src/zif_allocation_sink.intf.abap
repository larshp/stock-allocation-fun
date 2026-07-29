INTERFACE zif_allocation_sink PUBLIC.

  METHODS prepare_save
    IMPORTING
      iv_material            TYPE zif_stock_allocation=>ty_material
      iv_plant               TYPE zif_stock_allocation=>ty_plant
      iv_storage_location    TYPE zif_stock_allocation=>ty_storage_loc
      iv_expected_version    TYPE i OPTIONAL
      iv_require_new         TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(rv_next_version) TYPE i
    RAISING
      zcx_stock_allocation.

  METHODS save
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_loc
      is_plan              TYPE zif_stock_allocation=>ty_plan
      iv_expected_version  TYPE i OPTIONAL
      iv_require_new       TYPE abap_bool OPTIONAL
      iv_run_note          TYPE zif_stock_allocation=>ty_run_note OPTIONAL
    RETURNING
      VALUE(rv_version_no) TYPE i
    RAISING
      zcx_stock_allocation.

ENDINTERFACE.
