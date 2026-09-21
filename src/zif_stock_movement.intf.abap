INTERFACE zif_stock_movement PUBLIC.
  TYPES:
    BEGIN OF ty_document,
      number TYPE c LENGTH 10,
      year   TYPE n LENGTH 4,
    END OF ty_document.

  METHODS post_goods_issue
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_movement_type    TYPE zif_stock_allocation=>ty_movement_type
      iv_quantity         TYPE zif_stock_allocation=>ty_quantity
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
    RETURNING
      VALUE(rs_document)  TYPE ty_document
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
