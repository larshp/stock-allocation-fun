INTERFACE zif_salloc_authorization PUBLIC.
  METHODS check_authorization
    IMPORTING
      iv_plant TYPE zif_salloc_types=>ty_plant
      iv_activity TYPE zif_salloc_types=>ty_activity
    RAISING zcx_salloc_integration.
ENDINTERFACE.
