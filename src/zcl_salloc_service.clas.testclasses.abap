CLASS ltcl_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reserves_and_saves FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS no_stock_has_no_writes FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS rejects_missing_context FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS rolls_back_save_failure FOR TESTING
      RAISING zcx_salloc_invalid.
    METHODS rolls_back_invalid_stock FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS simulation_has_no_side_effects FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
ENDCLASS.

CLASS ltcl_service IMPLEMENTATION.
  METHOD reserves_and_saves.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 4 )
      ( order_id = '200' requested = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 5 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction ).

    DATA(allocations) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).
    DATA(saved) = orders->get_saved( ).

    cl_abap_unit_assert=>assert_equals( act = stock->get_reserved( ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = allocations[ 2 ]-allocated exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = allocations[ 2 ]-shortage exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = saved[ 2 ]-allocated exp = 1 ).
    cl_abap_unit_assert=>assert_true( transaction->was_begun( ) ).
    cl_abap_unit_assert=>assert_true( transaction->was_committed( ) ).
    cl_abap_unit_assert=>assert_false( transaction->was_rolled_back( ) ).
  ENDMETHOD.

  METHOD no_stock_has_no_writes.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 0 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction ).

    DATA(allocations) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = allocations[ 1 ]-allocated exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = allocations[ 1 ]-shortage exp = 4 ).
    cl_abap_unit_assert=>assert_initial( orders->get_saved( ) ).
    cl_abap_unit_assert=>assert_true( transaction->was_committed( ) ).
  ENDMETHOD.

  METHOD rejects_missing_context.
    DATA demands TYPE zif_salloc_types=>tt_demands.
    DATA(stock) = NEW zcl_salloc_stock_stub( 1 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction ).
    TRY.
        service->run( iv_material = 'MAT-1' iv_plant = '' ).
        cl_abap_unit_assert=>fail( `Expected invalid context exception` ).
      CATCH zcx_salloc_invalid.
        cl_abap_unit_assert=>assert_false( transaction->was_begun( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rolls_back_save_failure.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 1 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 1 ).
    DATA(orders) = NEW zcl_salloc_orders_stub(
      it_demands = demands
      iv_fail_on_save = abap_true ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction ).

    TRY.
        service->run( iv_material = 'MAT-1' iv_plant = '1000' ).
        cl_abap_unit_assert=>fail( `Expected save failure` ).
      CATCH zcx_salloc_integration INTO DATA(error).
        cl_abap_unit_assert=>assert_equals(
          act = error->operation
          exp = `SAVE_ALLOCATIONS` ).
        cl_abap_unit_assert=>assert_true( transaction->was_begun( ) ).
        cl_abap_unit_assert=>assert_false( transaction->was_committed( ) ).
        cl_abap_unit_assert=>assert_true( transaction->was_rolled_back( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rolls_back_invalid_stock.
    DATA demands TYPE zif_salloc_types=>tt_demands.
    DATA(stock) = NEW zcl_salloc_stock_stub( -1 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction ).

    TRY.
        service->run( iv_material = 'MAT-1' iv_plant = '1000' ).
        cl_abap_unit_assert=>fail( `Expected invalid stock exception` ).
      CATCH zcx_salloc_invalid.
        cl_abap_unit_assert=>assert_false( transaction->was_committed( ) ).
        cl_abap_unit_assert=>assert_true( transaction->was_rolled_back( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD simulation_has_no_side_effects.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 4 )
      ( order_id = '200' requested = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 5 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction ).

    DATA(allocations) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = allocations[ 2 ]-allocated exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = allocations[ 2 ]-shortage exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = stock->get_reserved( ) exp = 0 ).
    cl_abap_unit_assert=>assert_initial( orders->get_saved( ) ).
    cl_abap_unit_assert=>assert_false( transaction->was_begun( ) ).
    cl_abap_unit_assert=>assert_false( transaction->was_committed( ) ).
    cl_abap_unit_assert=>assert_false( transaction->was_rolled_back( ) ).
  ENDMETHOD.
ENDCLASS.
