INTERFACE zif_stock_allocation_authority PUBLIC.
  METHODS check
    IMPORTING
      iv_plant         TYPE zif_stock_allocation=>ty_plant
      iv_movement_type TYPE zif_stock_allocation=>ty_movement_type
    RAISING
      zcx_stock_allocation.
  METHODS check_cancel
    IMPORTING
      iv_plant         TYPE zif_stock_allocation=>ty_plant
      iv_movement_type TYPE zif_stock_allocation=>ty_movement_type
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
