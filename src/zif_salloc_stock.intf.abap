INTERFACE zif_salloc_stock PUBLIC.
  METHODS get_available
    IMPORTING
      iv_material TYPE zif_salloc_types=>ty_material
      iv_plant TYPE zif_salloc_types=>ty_plant
    RETURNING
      VALUE(rv_quantity) TYPE zif_salloc_types=>ty_quantity
    RAISING
      zcx_salloc_integration.

  METHODS reserve
    IMPORTING
      iv_material TYPE zif_salloc_types=>ty_material
      iv_plant TYPE zif_salloc_types=>ty_plant
      iv_quantity TYPE zif_salloc_types=>ty_quantity
    RAISING
      zcx_salloc_integration.

  METHODS release
    IMPORTING
      iv_material TYPE zif_salloc_types=>ty_material
      iv_plant TYPE zif_salloc_types=>ty_plant
      iv_quantity TYPE zif_salloc_types=>ty_quantity
    RAISING
      zcx_salloc_integration.
ENDINTERFACE.
