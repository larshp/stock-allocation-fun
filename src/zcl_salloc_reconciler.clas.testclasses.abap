CLASS ltcl_reconciler DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS releases_confirmed_quantity FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS releases_deleted_schedule FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS simulation_does_not_release FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS releases_rejected_item FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS releases_changed_item_context FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
ENDCLASS.

CLASS ltcl_reconciler IMPLEMENTATION.
  METHOD setup.
    DELETE FROM vbak.
    DELETE FROM vbap.
    DELETE FROM vbep.
    DELETE FROM zsalloc_order.
    DELETE FROM zsalloc_stock.
  ENDMETHOD.

  METHOD releases_confirmed_quantity.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' edatu = '20260701'
      wmeng = 1 lmeng = 10 bmeng = 8 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 8 allocated = 5 shortage = 3 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 5 ) ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = NEW zcl_salloc_transaction_stub( )
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).
    DATA(reconciler) = NEW zcl_salloc_reconciler( service ).

    DATA(released) = reconciler->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = released exp = 3 ).
    SELECT SINGLE reserved FROM zsalloc_stock
      WHERE matnr = 'MAT-1' AND werks = '1000' INTO @DATA(reserved).
    cl_abap_unit_assert=>assert_equals( act = reserved exp = 2 ).
  ENDMETHOD.

  METHOD releases_deleted_schedule.
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 4 allocated = 4 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 4 ) ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = NEW zcl_salloc_transaction_stub( )
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).
    DATA(reconciler) = NEW zcl_salloc_reconciler( service ).

    DATA(released) = reconciler->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = released exp = 4 ).
  ENDMETHOD.

  METHOD simulation_does_not_release.
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 4 allocated = 4 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 4 ) ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = NEW zcl_salloc_transaction_stub( )
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).
    DATA(reconciler) = NEW zcl_salloc_reconciler( service ).

    DATA(released) = reconciler->run(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_simulate = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = released exp = 4 ).
    SELECT SINGLE reserved FROM zsalloc_stock
      WHERE matnr = 'MAT-1' AND werks = '1000' INTO @DATA(reserved).
    cl_abap_unit_assert=>assert_equals( act = reserved exp = 4 ).
  ENDMETHOD.

  METHOD releases_rejected_item.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' abgru = '01' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' edatu = '20260701' lmeng = 4 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 4 allocated = 4 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 4 ) ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = NEW zcl_salloc_transaction_stub( )
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).
    DATA(reconciler) = NEW zcl_salloc_reconciler( service ).

    DATA(released) = reconciler->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = released exp = 4 ).
  ENDMETHOD.

  METHOD releases_changed_item_context.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-2' werks = '1000' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' edatu = '20260701' lmeng = 4 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 4 allocated = 4 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 4 ) ).
    DATA(service) = NEW zcl_salloc_service(
      io_stock = NEW zcl_salloc_stock_sap( )
      io_orders = NEW zcl_salloc_orders_sap( )
      io_transaction = NEW zcl_salloc_transaction_stub( )
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).
    DATA(reconciler) = NEW zcl_salloc_reconciler( service ).

    DATA(released) = reconciler->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = released exp = 4 ).
  ENDMETHOD.
ENDCLASS.
