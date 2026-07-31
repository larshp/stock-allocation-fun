CLASS zcl_allocation_write_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_write_authority.
ENDCLASS.

CLASS zcl_allocation_write_authority_sap IMPLEMENTATION.
  METHOD zif_allocation_write_authority~check_audit_write.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC_RUN'
      ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Audit write authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_write.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC'
      ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Allocation result write authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_write_authority~check_result_delete.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC'
      ID 'ACTVT' FIELD '06'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Allocation result delete authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
