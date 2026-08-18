INTERFACE zif_order_source PUBLIC.
  METHODS get_open_demands
    IMPORTING
      iv_material          TYPE zif_stock_allocation=>ty_material
      iv_plant             TYPE zif_stock_allocation=>ty_plant
      iv_requested_on_from TYPE d OPTIONAL
      iv_requested_on_to   TYPE d OPTIONAL
    RETURNING
      VALUE(rt_demands)    TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
