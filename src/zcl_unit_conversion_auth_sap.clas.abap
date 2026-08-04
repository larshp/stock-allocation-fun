CLASS zcl_unit_conversion_auth_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_unit_conversion_authority.
  PRIVATE SECTION.
    TYPES ty_table TYPE c LENGTH 30.
    METHODS verify_table
      IMPORTING
        iv_table   TYPE ty_table
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_unit_conversion_auth_sap IMPLEMENTATION.
  METHOD zif_unit_conversion_authority~check.
    verify_table(
      iv_table   = 'MARA'
      iv_message = 'Material conversion read authorization failed' ).
    verify_table(
      iv_table   = 'MARM'
      iv_message = 'Material unit read authorization failed' ).
  ENDMETHOD.

  METHOD verify_table.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
      ID 'TABLE' FIELD iv_table
      ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
      raise_error( iv_message = iv_message ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
