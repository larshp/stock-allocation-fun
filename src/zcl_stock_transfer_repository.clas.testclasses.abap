CLASS ltcl_stock_transfer_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_transfer_quantities FOR TESTING RAISING cx_static_check.
    METHODS rejects_location_sum_overflow FOR TESTING RAISING cx_static_check.
    METHODS reads_locations_and_batches FOR TESTING RAISING cx_static_check.
    METHODS skips_empty_bulk_requests FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_stock_transfer_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_mchb TYPE STANDARD TABLE OF mchb WITH EMPTY KEY.

    APPEND 'MARC' TO lt_tables.
    APPEND 'MARD' TO lt_tables.
    APPEND 'MCHB' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      umlmc = '25.000' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-NORMAL'
      werks = '1000'
      umlmc = '0.000' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      lgort = '0001'
      umlme = '3.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      lgort = '0002'
      umlme = '4.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      lgort = '0003'
      umlme = '0.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '2000'
      lgort = '0001'
      umlme = '6.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-NORMAL'
      werks = '1000'
      lgort = '0004'
      umlme = '9999999999.999' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-NORMAL'
      werks = '1000'
      lgort = '0005'
      umlme = '9999999999.999' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      lgort = '0001'
      charg = 'B001'
      cumlm = '1.000' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      lgort = '0002'
      charg = 'B002'
      cumlm = '2.000' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '1000'
      lgort = '0002'
      charg = 'B000'
      cumlm = '0.000' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-OK'
      werks = '2000'
      lgort = '0001'
      charg = 'B003'
      cumlm = '5.000' ) TO lt_mchb.

    mo_environment->insert_test_data( lt_marc ).
    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_mchb ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_transfer_quantities.
    DATA lv_material TYPE marc-matnr VALUE 'MAT-OK'.
    DATA lv_plant TYPE marc-werks VALUE '1000'.
    DATA lv_storage_location TYPE mard-lgort VALUE '0002'.
    DATA(lo_cut) = NEW zcl_stock_transfer_repository( ).
    DATA(lt_results) = lo_cut->zif_stock_transfer_repository~get_stock_in_transfer_bulk(
      it_requests = VALUE #(
        ( request_id = 'ALL' material = 'MAT-OK' plant = '1000' )
        ( request_id = 'ALL-REPEAT' material = 'MAT-OK' plant = '1000' )
        ( request_id = 'SLOC' material = 'MAT-OK' plant = '1000'
          storage_location = '0002' )
        ( request_id = 'MISSING' material = 'MAT-OK' plant = '3000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-umlmc( '25.000' )
      act = lt_results[ request_id = 'ALL' ]-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '7.000' )
      act = lt_results[ request_id = 'ALL' ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '7.000' )
      act = lt_results[ request_id = 'ALL-REPEAT' ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '4.000' )
      act = lt_results[ request_id = 'SLOC' ]-sloc_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-umlmc( 0 )
      act = lt_results[ request_id = 'MISSING' ]-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( 0 )
      act = lt_results[ request_id = 'MISSING' ]-sloc_transfer_quantity ).

    DATA(ls_all_locations) = lo_cut->zif_stock_transfer_repository~get_stock_in_transfer(
      iv_material = lv_material
      iv_plant    = lv_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-umlmc( '25.000' )
      act = ls_all_locations-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '7.000' )
      act = ls_all_locations-sloc_transfer_quantity ).

    DATA(ls_single) = lo_cut->zif_stock_transfer_repository~get_stock_in_transfer(
      iv_material         = lv_material
      iv_plant            = lv_plant
      iv_storage_location = lv_storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-umlmc( '25.000' )
      act = ls_single-plant_transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '4.000' )
      act = ls_single-sloc_transfer_quantity ).
  ENDMETHOD.


  METHOD rejects_location_sum_overflow.
    DATA(lo_cut) = NEW zcl_stock_transfer_repository( ).
    DATA lv_scalar_rejected TYPE abap_bool.
    DATA lv_bulk_rejected TYPE abap_bool.
    DATA lv_material TYPE marc-matnr VALUE 'MAT-NORMAL'.
    DATA lv_plant TYPE marc-werks VALUE '1000'.
    TRY.
        lo_cut->zif_stock_transfer_repository~get_stock_in_transfer(
          iv_material = lv_material
          iv_plant    = lv_plant ).
      CATCH zcx_invalid_stock_request.
        lv_scalar_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->zif_stock_transfer_repository~get_stock_in_transfer_bulk(
          it_requests = VALUE #(
            ( request_id = 'OVERFLOW'
              material   = lv_material
              plant      = lv_plant ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bulk_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_scalar_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bulk_rejected ).
  ENDMETHOD.

  METHOD reads_locations_and_batches.
    DATA lv_material TYPE mchb-matnr VALUE 'MAT-OK'.
    DATA lv_plant TYPE mchb-werks VALUE '1000'.
    DATA(lo_cut) = NEW zcl_stock_transfer_repository( ).
    DATA(lt_locations) = lo_cut->zif_stock_transfer_repository~get_transfer_locations_bulk(
      it_requests = VALUE #(
        ( request_id = 'L1' material = 'MAT-OK' plant = '1000' )
        ( request_id = 'L1-REPEAT' material = 'MAT-OK' plant = '1000' )
        ( request_id = 'L2' material = 'MAT-OK' plant = '2000' ) ) ).
    DATA(lt_batches) = lo_cut->zif_stock_transfer_repository~get_transfer_batches_bulk(
      it_requests = VALUE #(
        ( request_id = 'B1' material = 'MAT-OK' plant = '1000' )
        ( request_id = 'B1-REPEAT' material = 'MAT-OK' plant = '1000' )
        ( request_id = 'B2' material = 'MAT-OK' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_locations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-lgort( '0001' )
      act = lt_locations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-lgort( '0002' )
      act = lt_locations[ 2 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '4.000' )
      act = lt_locations[ 2 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-umlme( '6.000' )
      act = lt_locations[ 5 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'L1-REPEAT'
      act = lt_locations[ 3 ]-request_id ).

    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-charg( 'B001' )
      act = lt_batches[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cumlm( '2.000' )
      act = lt_batches[ 2 ]-transfer_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B1-REPEAT'
      act = lt_batches[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-charg( 'B003' )
      act = lt_batches[ 5 ]-batch ).

    DATA(lt_single_batches) =
      lo_cut->zif_stock_transfer_repository~get_stock_in_transfer_by_batch(
        iv_material = lv_material
        iv_plant    = lv_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_single_batches ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-charg( 'B001' )
      act = lt_single_batches[ 1 ]-batch ).
  ENDMETHOD.

  METHOD skips_empty_bulk_requests.
    DATA(lo_cut) = NEW zcl_stock_transfer_repository( ).
    DATA(lt_balances) = lo_cut->zif_stock_transfer_repository~get_stock_in_transfer_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_locations) = lo_cut->zif_stock_transfer_repository~get_transfer_locations_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_batches) = lo_cut->zif_stock_transfer_repository~get_transfer_batches_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_balances ).
    cl_abap_unit_assert=>assert_initial( act = lt_locations ).
    cl_abap_unit_assert=>assert_initial( act = lt_batches ).
  ENDMETHOD.
ENDCLASS.

