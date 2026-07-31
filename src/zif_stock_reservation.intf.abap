INTERFACE zif_stock_reservation PUBLIC.
  METHODS reserve
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_movement_type    TYPE zif_stock_allocation=>ty_movement_type
      iv_quantity         TYPE zif_stock_allocation=>ty_quantity
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      iv_required_date    TYPE d
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
    RETURNING
      VALUE(rv_document)  TYPE zif_stock_allocation=>ty_order_id
    RAISING
      zcx_stock_allocation.
  METHODS cancel
    IMPORTING
      iv_document      TYPE zif_stock_allocation=>ty_order_id
      iv_plant         TYPE zif_stock_allocation=>ty_plant
      iv_movement_type TYPE zif_stock_allocation=>ty_movement_type
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
