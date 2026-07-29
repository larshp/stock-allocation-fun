INTERFACE zif_salloc_logger PUBLIC.
  METHODS log
    IMPORTING
      iv_event TYPE zif_salloc_types=>ty_log_event
      iv_material TYPE zif_salloc_types=>ty_material
      iv_plant TYPE zif_salloc_types=>ty_plant
      iv_order_id TYPE zif_salloc_types=>ty_order_id OPTIONAL
      iv_quantity TYPE zif_salloc_types=>ty_quantity
    RAISING zcx_salloc_integration.
ENDINTERFACE.
