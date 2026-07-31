CLASS zcl_order_sink_authority_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_order_sink_authority.
ENDCLASS.

CLASS zcl_order_sink_authority_sap IMPLEMENTATION.
  METHOD zif_order_sink_authority~check.
    AUTHORITY-CHECK OBJECT 'V_VBAK_AAT'
      ID 'AUART' FIELD iv_sales_document_type
      ID 'ACTVT' FIELD '02'.
    IF sy-subrc <> 0.
      DATA lo_error TYPE REF TO zcx_stock_allocation.
      CREATE OBJECT lo_error.
      lo_error->message = 'Sales-order authorization failed'.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
