CLASS zcl_salloc_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS create_sap_service
      RETURNING VALUE(ro_service) TYPE REF TO zcl_salloc_service.
    CLASS-METHODS create_sap_reconciler
      RETURNING VALUE(ro_reconciler) TYPE REF TO zcl_salloc_reconciler.
ENDCLASS.

CLASS zcl_salloc_factory IMPLEMENTATION.
  METHOD create_sap_service.
    ro_service = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = NEW zcl_salloc_transaction_sap( )
      io_authorization = NEW zcl_salloc_authorization_sap( )
      io_logger = NEW zcl_salloc_logger_sap( ) ).
  ENDMETHOD.

  METHOD create_sap_reconciler.
    ro_reconciler = NEW zcl_salloc_reconciler( create_sap_service( ) ).
  ENDMETHOD.
ENDCLASS.
