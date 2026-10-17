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

    CLASS-METHODS create_quality_stock_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_quality_stock_service.

    CLASS-METHODS create_so_fefo_issue_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_so_fefo_issue_service.

    CLASS-METHODS create_res_issue_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_reservation_issue_service.

    CLASS-METHODS create_sto_order_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_stock_xfer_order_svc.

    CLASS-METHODS create_sales_order_alloc
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_sales_order_alloc_service.

    CLASS-METHODS create_sales_order_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_sales_order_service.

    CLASS-METHODS create_sales_stock_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_so_stock_service.

    CLASS-METHODS create_so_res_read_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_so_res_read_service.

    CLASS-METHODS create_so_reservation_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_so_reservation_service.

    CLASS-METHODS create_project_stock_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_project_stock_service.

    CLASS-METHODS create_project_resv_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_project_resv_service.

    CLASS-METHODS create_stock_transfer_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_stock_transfer_service.

    CLASS-METHODS create_purchase_order_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_purchase_order_service.

    CLASS-METHODS create_planned_order_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_planned_order_service.

    CLASS-METHODS create_planned_read_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_planned_order_read_service.

    CLASS-METHODS create_prod_order_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_prod_order_service.

    CLASS-METHODS create_prod_comp_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_prod_comp_service.

    CLASS-METHODS create_prod_order_read_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_prod_order_read_service.

    CLASS-METHODS create_preq_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_replenishment_req_service.

    CLASS-METHODS create_cc_reservation_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_cc_reservation_service.

    CLASS-METHODS create_repl_source_service
      RETURNING
        VALUE(ro_service) TYPE REF TO zcl_repl_source_service.
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

  METHOD create_quality_stock_service.
    ro_service = NEW zcl_quality_stock_service(
      io_stock_service          = create_stock_service( )
      io_goods_movement_service = create_goods_movement_service( ) ).
  ENDMETHOD.

  METHOD create_so_fefo_issue_service.
    ro_service = NEW zcl_so_fefo_issue_service(
      io_stock_service          = create_sales_stock_service( )
      io_goods_movement_service = create_goods_movement_service( ) ).
  ENDMETHOD.

  METHOD create_res_issue_service.
    ro_service = NEW zcl_reservation_issue_service(
      io_reservation_reader    = NEW zcl_bapi_so_reservation_api( )
      io_goods_movement_api    = NEW zcl_bapi_goods_movement_api( )
      io_uom_repository        = NEW zcl_material_uom_repository( )
      io_cc_reservation_reader = NEW zcl_cc_reservation_read_repo( ) ).
  ENDMETHOD.

  METHOD create_sto_order_service.
    ro_service = NEW zcl_stock_xfer_order_svc(
      io_api = NEW zcl_bapi_stock_xfer_api( ) ).
  ENDMETHOD.

  METHOD create_sales_order_alloc.
    ro_service = NEW zcl_sales_order_alloc_service(
      io_sales_order_api           = NEW zcl_bapi_sales_order_api( )
      io_stock_repository          = NEW zcl_mard_stock_repository( )
      io_material_availability_api = NEW zcl_bapi_mat_avail_api( )
      io_reservation_api           = NEW zcl_bapi_so_reservation_api( )
      io_sales_stock_service       =
        zcl_stock_allocation_factory=>create_sales_stock_service( ) ).
  ENDMETHOD.

  METHOD create_sales_order_service.
    ro_service = NEW zcl_sales_order_service(
      io_api = NEW zcl_bapi_sales_order_api( ) ).
  ENDMETHOD.

  METHOD create_sales_stock_service.
    ro_service = NEW zcl_so_stock_service(
      io_repository = NEW zcl_so_stock_repository( ) ).
  ENDMETHOD.

  METHOD create_so_res_read_service.
    ro_service = NEW zcl_so_res_read_service(
      io_reader = NEW zcl_bapi_so_reservation_api( ) ).
  ENDMETHOD.

  METHOD create_so_reservation_service.
    ro_service = NEW zcl_so_reservation_service(
      io_api                = NEW zcl_bapi_so_reservation_api( )
      io_reservation_finder = NEW zcl_mard_stock_repository( ) ).
  ENDMETHOD.

  METHOD create_project_stock_service.
    DATA(lo_uom_repository) = NEW zcl_material_uom_repository( ).
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).

    ro_service = NEW zcl_project_stock_service(
      io_repository    = NEW zcl_project_stock_repository( )
      io_uom_converter = lo_uom_converter ).
  ENDMETHOD.

  METHOD create_project_resv_service.
    DATA(lo_uom_repository) = NEW zcl_material_uom_repository( ).
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).
    DATA(lo_project_stock_service) = NEW zcl_project_stock_service(
      io_repository    = NEW zcl_project_stock_repository( )
      io_uom_converter = lo_uom_converter ).
    DATA(lo_issue_service) = NEW zcl_reservation_issue_service(
      io_goods_movement_api = NEW zcl_bapi_goods_movement_api( )
      io_uom_repository     = lo_uom_repository ).

    ro_service = NEW zcl_project_resv_service(
      io_api                   = NEW zcl_bapi_project_reservation( )
      io_project_stock_service = lo_project_stock_service
      io_issue_service         = lo_issue_service
      io_uom_converter         = lo_uom_converter
      io_uom_repository        = lo_uom_repository ).
  ENDMETHOD.

  METHOD create_stock_transfer_service.
    DATA(lo_uom_repository) = NEW zcl_material_uom_repository( ).
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).

    ro_service = NEW zcl_stock_transfer_service(
      io_repository    = NEW zcl_stock_transfer_repository( )
      io_uom_converter = lo_uom_converter ).
  ENDMETHOD.

  METHOD create_purchase_order_service.
    DATA(lo_uom_repository) = NEW zcl_material_uom_repository( ).
    DATA(lo_uom_converter) = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).

    ro_service = NEW zcl_purchase_order_service(
      io_api           = NEW zcl_bapi_purchase_order_api( )
      io_uom_converter = lo_uom_converter ).
  ENDMETHOD.

  METHOD create_planned_order_service.
    ro_service = NEW zcl_planned_order_service(
      io_api = NEW zcl_bapi_planned_order_api( ) ).
  ENDMETHOD.

  METHOD create_planned_read_service.
    ro_service = NEW zcl_planned_order_read_service(
      io_repository = NEW zcl_plaf_order_read_repo( ) ).
  ENDMETHOD.

  METHOD create_prod_order_service.
    DATA(lo_component_service) = create_prod_comp_service( ).
    DATA(lo_atp_checker) = NEW zcl_prod_order_atp_checker(
      io_component_service = lo_component_service ).

    ro_service = NEW zcl_prod_order_service(
      io_api         = NEW zcl_bapi_prod_order_api( )
      io_atp_checker = lo_atp_checker ).
  ENDMETHOD.

  METHOD create_prod_comp_service.
    ro_service = NEW zcl_prod_comp_service( ).
  ENDMETHOD.

  METHOD create_prod_order_read_service.
    ro_service = NEW zcl_prod_order_read_service(
      io_repository = NEW zcl_prod_order_read_repo( ) ).
  ENDMETHOD.

  METHOD create_preq_service.
    ro_service = NEW zcl_replenishment_req_service(
      io_api = NEW zcl_bapi_preq_api( ) ).
  ENDMETHOD.

  METHOD create_cc_reservation_service.
    ro_service = NEW zcl_cc_reservation_service(
      io_stock_repository          = NEW zcl_mard_stock_repository( )
      io_reservation_api           = NEW zcl_bapi_cc_reservation( )
      io_uom_repository            = NEW zcl_material_uom_repository( )
      io_material_availability_api = NEW zcl_bapi_mat_avail_api( )
      io_reservation_reader        = NEW zcl_cc_reservation_read_repo( ) ).
  ENDMETHOD.

  METHOD create_repl_source_service.
    ro_service = NEW zcl_repl_source_service(
      io_repository = NEW zcl_repl_source_repo( ) ).
  ENDMETHOD.
ENDCLASS.
