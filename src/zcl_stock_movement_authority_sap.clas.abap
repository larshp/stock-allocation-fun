CLASS zcl_stock_movement_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_movement_authority.
ENDCLASS.

CLASS zcl_stock_movement_authority_sap IMPLEMENTATION.
  METHOD zif_stock_movement_authority~check.
    AUTHORITY-CHECK OBJECT 'M_MSEG_WMB'
      ID 'BWART' FIELD iv_movement_type
      ID 'ACTVT' FIELD '01'.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
