INTERFACE zif_salloc_transaction PUBLIC.
  METHODS begin
    RAISING zcx_salloc_integration.
  METHODS commit
    RAISING zcx_salloc_integration.
  METHODS rollback.
ENDINTERFACE.
