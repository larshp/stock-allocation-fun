CLASS ltcl_stock_allocation_factory DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_production_services FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_factory IMPLEMENTATION.
  METHOD creates_production_services.
    DATA(lo_stock_service) =
      zcl_stock_allocation_factory=>create_stock_service( ).
    DATA(lo_goods_movement_service) =
      zcl_stock_allocation_factory=>create_goods_movement_service( ).
    DATA(lo_reservation_issue_service) =
      zcl_stock_allocation_factory=>create_res_issue_service( ).
    DATA(lo_stock_xfer_order_service) =
      zcl_stock_allocation_factory=>create_sto_order_service( ).
    DATA(lo_sales_alloc_service) =
      zcl_stock_allocation_factory=>create_sales_order_alloc( ).
    DATA(lo_sales_order_service) =
      zcl_stock_allocation_factory=>create_sales_order_service( ).
    DATA(lo_sales_stock_service) =
      zcl_stock_allocation_factory=>create_sales_stock_service( ).
    DATA(lo_so_fefo_issue_service) =
      zcl_stock_allocation_factory=>create_so_fefo_issue_service( ).
    DATA(lo_project_stock_service) =
      zcl_stock_allocation_factory=>create_project_stock_service( ).
    DATA(lo_project_resv_service) =
      zcl_stock_allocation_factory=>create_project_resv_service( ).
    DATA(lo_stock_transfer_service) =
      zcl_stock_allocation_factory=>create_stock_transfer_service( ).
    DATA(lo_purchase_order_service) =
      zcl_stock_allocation_factory=>create_purchase_order_service( ).
    DATA(lo_planned_order_service) =
      zcl_stock_allocation_factory=>create_planned_order_service( ).
    DATA(lo_prod_order_service) =
      zcl_stock_allocation_factory=>create_prod_order_service( ).
    DATA(lo_preq_service) =
      zcl_stock_allocation_factory=>create_preq_service( ).
    DATA(lo_cc_reservation_service) =
      zcl_stock_allocation_factory=>create_cc_reservation_service( ).
    DATA(lo_repl_source_service) =
      zcl_stock_allocation_factory=>create_repl_source_service( ).
    DATA lv_services_bound TYPE abap_bool.

    IF lo_stock_service IS BOUND
        AND lo_goods_movement_service IS BOUND
        AND lo_reservation_issue_service IS BOUND
        AND lo_stock_xfer_order_service IS BOUND
        AND lo_sales_alloc_service IS BOUND
        AND lo_sales_order_service IS BOUND
        AND lo_sales_stock_service IS BOUND
        AND lo_so_fefo_issue_service IS BOUND
        AND lo_project_stock_service IS BOUND
        AND lo_project_resv_service IS BOUND
        AND lo_stock_transfer_service IS BOUND
        AND lo_purchase_order_service IS BOUND
        AND lo_planned_order_service IS BOUND
        AND lo_prod_order_service IS BOUND
        AND lo_preq_service IS BOUND
        AND lo_cc_reservation_service IS BOUND
        AND lo_repl_source_service IS BOUND.
      lv_services_bound = abap_true.
    ENDIF.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_services_bound ).
  ENDMETHOD.
ENDCLASS.
