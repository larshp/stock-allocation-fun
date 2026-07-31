INTERFACE zif_stock_movement_authority PUBLIC.
  METHODS check
    IMPORTING
      iv_movement_type TYPE zif_stock_allocation=>ty_movement_type
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
