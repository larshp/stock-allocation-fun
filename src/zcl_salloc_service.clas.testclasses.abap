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
    METHODS sap_adapters_run_end_to_end FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS rejects_unauthorized_run FOR TESTING
      RAISING zcx_salloc_invalid.
    METHODS logging_failure_rolls_back FOR TESTING
      RAISING zcx_salloc_invalid.
ENDCLASS.

CLASS ltcl_service IMPLEMENTATION.
  METHOD reserves_and_saves.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 4 )
      ( order_id = '200' requested = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_stub( 5 ).
    DATA(orders) = NEW zcl_salloc_orders_stub( demands ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(logger) = NEW zcl_salloc_logger_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = stock
      io_orders = orders
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = logger ).

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
    cl_abap_unit_assert=>assert_equals( act = logger->get_count( ) exp = 2 ).
    DATA(log_entries) = logger->get_entries( ).
    cl_abap_unit_assert=>assert_equals(
      act = log_entries[ order_id = '100' ]-quantity
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = log_entries[ order_id = '200' ]-quantity
      exp = 1 ).
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
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

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
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).
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
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

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
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

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
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

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

  METHOD sap_adapters_run_end_to_end.
    DELETE FROM mard.
    DELETE FROM vbak.
    DELETE FROM vbap.
    DELETE FROM vbep.
    DELETE FROM zsalloc_stock.
    DELETE FROM zsalloc_order.

    DELETE FROM marc.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 5 ) ).
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' audat = '20260701' ) ).
    DATA sales_items TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    sales_items = VALUE #(
      ( mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
        matnr = 'MAT-1' werks = '1000' )
      ( mandt = sy-mandt vbeln = '5000000001' posnr = '000020'
        matnr = 'MAT-1' werks = '1000' ) ).
    INSERT vbap FROM TABLE @sales_items.
    DATA schedule_lines TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.
    schedule_lines = VALUE #(
      ( mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
        etenr = '0001' edatu = '20260701' wmeng = 2 lmeng = 4 )
      ( mandt = sy-mandt vbeln = '5000000001' posnr = '000020'
        etenr = '0001' edatu = '20260701' wmeng = 2 lmeng = 4 ) ).
    INSERT vbep FROM TABLE @schedule_lines.

    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

    DATA(first_run) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = first_run[ 1 ]-allocated exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = first_run[ 2 ]-allocated exp = 1 ).
    cl_abap_unit_assert=>assert_true( transaction->was_committed( ) ).

    SELECT SINGLE reserved
      FROM zsalloc_stock
      WHERE matnr = 'MAT-1' AND werks = '1000'
      INTO @DATA(reserved).
    cl_abap_unit_assert=>assert_equals( act = reserved exp = 5 ).

    service->release(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_order_id = '50000000010000100001'
      iv_quantity = 2 ).
    SELECT SINGLE reserved
      FROM zsalloc_stock
      WHERE matnr = 'MAT-1' AND werks = '1000'
      INTO @reserved.
    cl_abap_unit_assert=>assert_equals( act = reserved exp = 3 ).
    SELECT SINGLE allocated, shortage
      FROM zsalloc_order
      WHERE order_id = '50000000010000100001'
      INTO @DATA(released_order).
    cl_abap_unit_assert=>assert_equals( act = released_order-allocated exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = released_order-shortage exp = 2 ).

    DATA(second_run) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lines( second_run ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = second_run[ 1 ]-requested exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = second_run[ 1 ]-allocated exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = second_run[ 2 ]-shortage exp = 3 ).

    DATA(third_run) = service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lines( third_run ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = third_run[ 1 ]-requested exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = third_run[ 1 ]-allocated exp = 0 ).
  ENDMETHOD.

  METHOD rejects_unauthorized_run.
    DATA demands TYPE zif_salloc_types=>tt_demands.
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_stub( 1 )
      io_orders = NEW zcl_salloc_orders_stub( demands )
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( abap_true )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

    TRY.
        service->run( iv_material = 'MAT-1' iv_plant = '1000' ).
        cl_abap_unit_assert=>fail( `Expected authorization failure` ).
      CATCH zcx_salloc_integration INTO DATA(error).
        cl_abap_unit_assert=>assert_equals(
          act = error->operation
          exp = `AUTHORIZATION` ).
        cl_abap_unit_assert=>assert_false( transaction->was_begun( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD logging_failure_rolls_back.
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '100' requested = 1 ) ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_stub( 1 )
      io_orders = NEW zcl_salloc_orders_stub( demands )
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( abap_true ) ).
    TRY.
        service->run( iv_material = 'MAT-1' iv_plant = '1000' ).
        cl_abap_unit_assert=>fail( `Expected logging failure` ).
      CATCH zcx_salloc_integration INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->operation exp = `LOG` ).
        cl_abap_unit_assert=>assert_false( transaction->was_committed( ) ).
        cl_abap_unit_assert=>assert_true( transaction->was_rolled_back( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
