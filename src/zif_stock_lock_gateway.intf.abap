INTERFACE zif_stock_lock_gateway PUBLIC.
  METHODS acquire
    IMPORTING
      iv_material      TYPE zcl_stock_allocator=>ty_material
      iv_plant         TYPE zcl_stock_allocator=>ty_plant
      iv_wait_for_lock TYPE abap_bool
    RETURNING
      VALUE(rs_result) TYPE zif_stock_lock=>ty_result.

  METHODS release
    IMPORTING
      iv_material TYPE zcl_stock_allocator=>ty_material
      iv_plant    TYPE zcl_stock_allocator=>ty_plant.
ENDINTERFACE.
