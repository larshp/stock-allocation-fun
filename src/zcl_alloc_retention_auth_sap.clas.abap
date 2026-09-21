CLASS zcl_alloc_retention_auth_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_alloc_retention_auth.
ENDCLASS.

CLASS zcl_alloc_retention_auth_sap IMPLEMENTATION.
  METHOD zif_alloc_retention_auth~check.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC_RUN'
      ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Audit retention authorization failed for ZSTOCKALLOC_RUN'.
      RAISE EXCEPTION lo_error.
    ENDIF.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC'
      ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      DATA lo_snapshot_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_snapshot_error.
      lo_snapshot_error->message = 'Audit retention authorization failed for ZSTOCKALLOC'.
      RAISE EXCEPTION lo_snapshot_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
