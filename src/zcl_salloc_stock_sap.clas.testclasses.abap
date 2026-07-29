CLASS ltcl_stock_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS subtracts_ledger_reservation FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS reserve_accumulates FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS rejects_over_reservation FOR TESTING.
    METHODS rejects_missing_plant_data FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_sap IMPLEMENTATION.
  METHOD setup.
    DELETE FROM marc.
    DELETE FROM mard.
    DELETE FROM zsalloc_stock.
  ENDMETHOD.

  METHOD subtracts_ledger_reservation.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    DATA storage_locations TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    storage_locations = VALUE #(
      ( mandt = sy-mandt matnr = 'MAT-1' werks = '1000' lgort = '0001' labst = 5 )
      ( mandt = sy-mandt matnr = 'MAT-1' werks = '1000' lgort = '0002' labst = 4 )
      ( mandt = sy-mandt matnr = 'MAT-1' werks = '2000' lgort = '0001' labst = 7 ) ).
    INSERT mard FROM TABLE @storage_locations.
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 3 ) ).

    DATA(stock) = NEW zcl_salloc_stock_sap( ).
    DATA(available) = stock->zif_salloc_stock~get_available(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = available exp = 6 ).
  ENDMETHOD.

  METHOD reserve_accumulates.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 10 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 2 ) ).
    DATA(stock) = NEW zcl_salloc_stock_sap( ).

    stock->zif_salloc_stock~reserve(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_quantity = 3 ).

    SELECT SINGLE reserved
      FROM zsalloc_stock
      WHERE matnr = 'MAT-1'
        AND werks = '1000'
      INTO @DATA(reserved).
    cl_abap_unit_assert=>assert_equals( act = reserved exp = 5 ).
  ENDMETHOD.

  METHOD rejects_over_reservation.
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 4 ) ).
    DATA(stock) = NEW zcl_salloc_stock_sap( ).

    TRY.
        stock->zif_salloc_stock~reserve(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_quantity = 5 ).
        cl_abap_unit_assert=>fail( `Expected stale availability failure` ).
      CATCH zcx_salloc_integration INTO DATA(error).
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = `Available stock changed before reservation` ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_missing_plant_data.
    DATA(stock) = NEW zcl_salloc_stock_sap( ).
    TRY.
        stock->zif_salloc_stock~get_available(
          iv_material = 'MAT-1'
          iv_plant = '1000' ).
        cl_abap_unit_assert=>fail( `Expected missing plant extension failure` ).
      CATCH zcx_salloc_integration INTO DATA(error).
        cl_abap_unit_assert=>assert_equals(
          act = error->reason
          exp = `Material is not extended to plant` ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
