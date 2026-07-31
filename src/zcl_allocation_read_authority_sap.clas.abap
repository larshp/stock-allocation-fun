CLASS zcl_allocation_read_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_allocation_read_authority.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_allocation_read_authority_sap IMPLEMENTATION.
  METHOD zif_allocation_read_authority~check_audit.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC_RUN'
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit history read authorization failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_read_authority~check_results.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD 'ZSTOCKALLOC'
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Allocation result read authorization failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
