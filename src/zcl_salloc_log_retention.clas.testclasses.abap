CLASS ltcl_log_retention DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS simulation_only_counts FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS deletes_scoped_rows_and_logs FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS denial_has_no_side_effects FOR TESTING
      RAISING zcx_salloc_invalid.
ENDCLASS.

CLASS ltcl_log_retention IMPLEMENTATION.
  METHOD setup.
    DELETE FROM zsalloc_log.
  ENDMETHOD.

  METHOD simulation_only_counts.
    DATA logs TYPE STANDARD TABLE OF zsalloc_log WITH EMPTY KEY.
    logs = VALUE #(
      ( mandt = sy-mandt log_id = '00000000000000000000000000000001'
        created_at = '20260101000000' werks = '1000' event = 'ALLOCATE' )
      ( mandt = sy-mandt log_id = '00000000000000000000000000000002'
        created_at = '20260101000000' werks = '2000' event = 'ALLOCATE' ) ).
    INSERT zsalloc_log FROM TABLE @logs.
    DATA(retention) = NEW zcl_salloc_log_retention(
      io_transaction = NEW zcl_salloc_transaction_stub( )
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

    DATA(affected) = retention->run(
      iv_plant = '1000'
      iv_before = '20260201000000' ).

    cl_abap_unit_assert=>assert_equals( act = affected exp = 1 ).
    SELECT COUNT( * ) FROM zsalloc_log INTO @DATA(remaining).
    cl_abap_unit_assert=>assert_equals( act = remaining exp = 2 ).
  ENDMETHOD.

  METHOD deletes_scoped_rows_and_logs.
    DATA logs TYPE STANDARD TABLE OF zsalloc_log WITH EMPTY KEY.
    logs = VALUE #(
      ( mandt = sy-mandt log_id = '00000000000000000000000000000001'
        created_at = '20260101000000' werks = '1000' event = 'ALLOCATE' )
      ( mandt = sy-mandt log_id = '00000000000000000000000000000002'
        created_at = '20260301000000' werks = '1000' event = 'RELEASE' )
      ( mandt = sy-mandt log_id = '00000000000000000000000000000003'
        created_at = '20260101000000' werks = '2000' event = 'ALLOCATE' ) ).
    INSERT zsalloc_log FROM TABLE @logs.
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(retention) = NEW zcl_salloc_log_retention(
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( )
      io_logger = NEW zcl_salloc_logger_sap( ) ).

    DATA(affected) = retention->run(
      iv_plant = '1000'
      iv_before = '20260201000000'
      iv_simulate = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = affected exp = 1 ).
    cl_abap_unit_assert=>assert_true( transaction->was_committed( ) ).
    SELECT COUNT( * ) FROM zsalloc_log INTO @DATA(remaining).
    cl_abap_unit_assert=>assert_equals( act = remaining exp = 3 ).
    SELECT SINGLE quantity FROM zsalloc_log
      WHERE event = 'LOG_RETENTION' AND werks = '1000'
      INTO @DATA(logged_quantity).
    cl_abap_unit_assert=>assert_equals( act = logged_quantity exp = 1 ).
  ENDMETHOD.

  METHOD denial_has_no_side_effects.
    INSERT zsalloc_log FROM @( VALUE #(
      mandt = sy-mandt log_id = '00000000000000000000000000000001'
      created_at = '20260101000000' werks = '1000' event = 'ALLOCATE' ) ).
    DATA(transaction) = NEW zcl_salloc_transaction_stub( ).
    DATA(retention) = NEW zcl_salloc_log_retention(
      io_transaction = transaction
      io_authorization = NEW zcl_salloc_authorization_stub( abap_true )
      io_logger = NEW zcl_salloc_logger_stub( ) ).

    TRY.
        retention->run(
          iv_plant = '1000'
          iv_before = '20260201000000'
          iv_simulate = abap_false ).
        cl_abap_unit_assert=>fail( `Expected authorization failure` ).
      CATCH zcx_salloc_integration.
        cl_abap_unit_assert=>assert_false( transaction->was_begun( ) ).
        SELECT COUNT( * ) FROM zsalloc_log INTO @DATA(remaining).
        cl_abap_unit_assert=>assert_equals( act = remaining exp = 1 ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
