CLASS zcl_stock_alloc_validator DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate_scope
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      RAISING
        zcx_stock_allocation.
    CLASS-METHODS validate_priority_key
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
        iv_sales_order      TYPE zif_stock_allocation=>ty_sales_order
        iv_sales_item       TYPE zif_stock_allocation=>ty_sales_item
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_alloc_validator IMPLEMENTATION.
  METHOD validate_scope.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Material, plant, and storage location are required' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_priority_key.
    validate_scope(
      iv_material = iv_material
      iv_plant = iv_plant
      iv_storage_location = iv_storage_location ).
    IF iv_sales_order IS INITIAL OR iv_sales_item IS INITIAL.
      RAISE EXCEPTION NEW zcx_stock_allocation(
        'Sales order and item are required for a priority' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
