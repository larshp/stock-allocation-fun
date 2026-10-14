CLASS zcl_stock_allocation_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS create_stock_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_stock_service.

    CLASS-METHODS create_goods_movement_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_goods_movement_service.

    CLASS-METHODS create_sto_order_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_stock_xfer_order_svc.
ENDCLASS.

CLASS zcl_stock_allocation_factory IMPLEMENTATION.
  METHOD create_stock_service.
    DATA(lo_uom_repository) = NEW zcl_material_uom_repository( ).
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).

    ro_service = NEW zcl_stock_service(
      io_stock_repository          = NEW zcl_mard_stock_repository( )
      io_uom_converter             = lo_uom_converter
      io_material_availability_api = NEW zcl_bapi_mat_avail_api( ) ).
  ENDMETHOD.

  METHOD create_goods_movement_service.
    ro_service = NEW zcl_goods_movement_service(
      io_api            = NEW zcl_bapi_goods_movement_api( )
      io_uom_repository = NEW zcl_material_uom_repository( ) ).
  ENDMETHOD.

  METHOD create_sto_order_service.
    ro_service = NEW zcl_stock_xfer_order_svc(
      io_api = NEW zcl_bapi_stock_xfer_api( ) ).
  ENDMETHOD.
ENDCLASS.
