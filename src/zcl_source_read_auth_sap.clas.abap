CLASS zcl_source_read_auth_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_source_read_authority.
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

CLASS zcl_source_read_auth_sap IMPLEMENTATION.
  METHOD zif_source_read_authority~check_stock.
    verify_table(
      iv_table   = 'MARA'
      iv_message = 'Material read authorization failed' ).
    verify_table(
      iv_table   = 'MARD'
      iv_message = 'Stock read authorization failed' ).
    IF iv_batch IS NOT INITIAL.
      verify_table(
        iv_table   = 'MCHB'
        iv_message = 'Batch stock read authorization failed' ).
      verify_table(
        iv_table   = 'MCHA'
        iv_message = 'Batch master read authorization failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_source_read_authority~check_orders.
    verify_table(
      iv_table   = 'VBAK'
      iv_message = 'Sales-order header read authorization failed' ).
    verify_table(
      iv_table   = 'VBAP'
      iv_message = 'Sales-order item read authorization failed' ).
    verify_table(
      iv_table   = 'VBEP'
      iv_message = 'Sales-order schedule read authorization failed' ).
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
