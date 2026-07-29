CLASS ltcl_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reserves_and_saves FOR TESTING RAISING zcx_salloc_invalid.
    METHODS no_stock_has_no_writes FOR TESTING RAISING zcx_salloc_invalid.
    METHODS rejects_missing_context FOR TESTING.
ENDCLASS.

CLASS ltcl_service IMPLEMENTATION.
  METHOD reserves_and_saves.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 4 )
      ( order_id = '200' requested = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 5 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders ).

    DATA(allocations) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).
    DATA(saved) = orders->get_saved( ).

    cl_abap_unit_assert=>assert_equals( act = stock->get_reserved( ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = allocations[ 2 ]-allocated exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = saved[ 2 ]-allocated exp = 1 ).
  ENDMETHOD.

  METHOD no_stock_has_no_writes.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 0 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders ).

    DATA(allocations) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = allocations[ 1 ]-allocated exp = 0 ).
    cl_abap_unit_assert=>assert_initial( orders->get_saved( ) ).
  ENDMETHOD.

  METHOD rejects_missing_context.
    DATA demands TYPE zif_salloc_types=>tt_demands.
    DATA(stock) = NEW zcl_salloc_stock_stub( 1 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders ).
    TRY.
        service->run( iv_material = 'MAT-1' iv_plant = '' ).
        cl_abap_unit_assert=>fail( `Expected invalid context exception` ).
      CATCH zcx_salloc_invalid.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
