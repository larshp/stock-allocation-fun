CLASS zcl_allocation_retention_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_retention_authority.
ENDCLASS.

CLASS zcl_allocation_retention_authority_sap IMPLEMENTATION.
  METHOD zif_allocation_retention_authority~check.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC_RUN'
      ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Audit retention authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
