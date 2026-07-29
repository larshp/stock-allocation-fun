INTERFACE zif_priority_log PUBLIC.
  METHODS record_change
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      iv_sales_order      TYPE zif_stock_allocation=>ty_sales_order
      iv_sales_item       TYPE zif_stock_allocation=>ty_sales_item
      iv_priority         TYPE zif_stock_allocation=>ty_priority
      iv_activity         TYPE zif_priority_authorization=>ty_activity
    RETURNING
      VALUE(rv_recorded)  TYPE abap_bool.
ENDINTERFACE.
