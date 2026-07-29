CLASS ltcl_checker DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS reports_healthy_invariants FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS detects_split_ledger FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS detects_excess_commitments FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
    METHODS denies_before_read FOR TESTING
      RAISING zcx_salloc_invalid.
    METHODS detects_invalid_order_row FOR TESTING
      RAISING zcx_salloc_invalid zcx_salloc_integration.
ENDCLASS.

CLASS ltcl_checker IMPLEMENTATION.
  METHOD setup.
    DELETE FROM marc.
    DELETE FROM mard.
    DELETE FROM vbak.
    DELETE FROM vbap.
    DELETE FROM vbep.
    DELETE FROM zsalloc_stock.
    DELETE FROM zsalloc_order.
  ENDMETHOD.

  METHOD reports_healthy_invariants.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 10 ) ).
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' lmeng = 4 bmeng = 2 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 3 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 3 allocated = 3 ) ).
    DATA(checker) = NEW zcl_salloc_checker(
      NEW zcl_salloc_authorization_stub( ) ).

    DATA(result) = checker->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_true( result-ledgers_match ).
    cl_abap_unit_assert=>assert_true( result-commitments_fit ).
    cl_abap_unit_assert=>assert_true( result-quantities_valid ).
    cl_abap_unit_assert=>assert_equals( act = result-confirmed exp = 2 ).
  ENDMETHOD.

  METHOD detects_split_ledger.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 10 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 4 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 3 allocated = 3 ) ).
    DATA(checker) = NEW zcl_salloc_checker(
      NEW zcl_salloc_authorization_stub( ) ).

    DATA(result) = checker->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_false( result-ledgers_match ).
  ENDMETHOD.

  METHOD detects_excess_commitments.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 5 ) ).
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' lmeng = 4 bmeng = 4 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 2 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 2 allocated = 2 ) ).
    DATA(checker) = NEW zcl_salloc_checker(
      NEW zcl_salloc_authorization_stub( ) ).

    DATA(result) = checker->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_true( result-ledgers_match ).
    cl_abap_unit_assert=>assert_false( result-commitments_fit ).
  ENDMETHOD.

  METHOD denies_before_read.
    DATA(checker) = NEW zcl_salloc_checker(
      NEW zcl_salloc_authorization_stub( abap_true ) ).
    TRY.
        checker->run(
          iv_material = 'MAT-1'
          iv_plant = '1000' ).
        cl_abap_unit_assert=>fail( `Expected authorization failure` ).
      CATCH zcx_salloc_integration INTO DATA(error).
        cl_abap_unit_assert=>assert_equals(
          act = error->operation
          exp = `AUTHORIZATION` ).
    ENDTRY.
  ENDMETHOD.

  METHOD detects_invalid_order_row.
    INSERT marc FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' ) ).
    INSERT mard FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000'
      lgort = '0001' labst = 10 ) ).
    INSERT zsalloc_stock FROM @( VALUE #(
      mandt = sy-mandt matnr = 'MAT-1' werks = '1000' reserved = 2 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000'
      requested = 3 allocated = 2 shortage = 2 ) ).
    DATA(checker) = NEW zcl_salloc_checker(
      NEW zcl_salloc_authorization_stub( ) ).

    DATA(result) = checker->run(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_true( result-ledgers_match ).
    cl_abap_unit_assert=>assert_false( result-quantities_valid ).
  ENDMETHOD.
ENDCLASS.
