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
    DATA(lo_stock_xfer_order_service) =
      zcl_stock_allocation_factory=>create_sto_order_service( ).
    DATA lv_services_bound TYPE abap_bool.

    IF lo_stock_service IS BOUND
        AND lo_goods_movement_service IS BOUND
        AND lo_stock_xfer_order_service IS BOUND.
      lv_services_bound = abap_true.
    ENDIF.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_services_bound ).
  ENDMETHOD.
ENDCLASS.
