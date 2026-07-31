CLASS zcl_stock_allocation_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_authority.
ENDCLASS.

CLASS zcl_stock_allocation_authority_sap IMPLEMENTATION.
  METHOD zif_stock_allocation_authority~check.
    AUTHORITY-CHECK OBJECT 'M_RES_BWA'
      ID 'BWART' FIELD iv_movement_type
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Reservation authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
