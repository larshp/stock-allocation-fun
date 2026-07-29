INTERFACE zif_salloc_orders PUBLIC.
  METHODS get_open_demands
    IMPORTING
      iv_material TYPE zif_salloc_types=>ty_material
      iv_plant TYPE zif_salloc_types=>ty_plant
    RETURNING
      VALUE(rt_demands) TYPE zif_salloc_types=>tt_demands
    RAISING
      zcx_salloc_integration.

  METHODS save_allocations
    IMPORTING
      it_demands TYPE zif_salloc_types=>tt_demands
    RAISING
      zcx_salloc_integration.
ENDINTERFACE.
