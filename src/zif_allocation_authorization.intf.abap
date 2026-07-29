INTERFACE zif_allocation_authorization PUBLIC.
  TYPES ty_activity TYPE c LENGTH 2.
  METHODS is_authorized
    IMPORTING
      iv_activity          TYPE ty_activity
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_storage_location  TYPE zif_stock_allocation=>ty_storage_loc
    RETURNING
      VALUE(rv_authorized) TYPE abap_bool.
ENDINTERFACE.
