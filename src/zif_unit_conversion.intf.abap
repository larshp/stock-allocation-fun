INTERFACE zif_unit_conversion PUBLIC.
  METHODS convert
    IMPORTING
      iv_material        TYPE zif_stock_allocation=>ty_material
      iv_quantity        TYPE zif_stock_allocation=>ty_quantity
      iv_unit_from       TYPE zif_stock_allocation=>ty_unit
      iv_unit_to         TYPE zif_stock_allocation=>ty_unit
    RETURNING
      VALUE(rv_quantity) TYPE zif_stock_allocation=>ty_quantity
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
