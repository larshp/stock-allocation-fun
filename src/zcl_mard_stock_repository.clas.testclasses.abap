CLASS ltcl_mard_stock_repository DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_bulk_safety_stock FOR TESTING RAISING cx_static_check.
    METHODS reads_plant_stock_status FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_stock_status_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS nets_unrestricted_stock_safely FOR TESTING
      RAISING cx_static_check.
    METHODS reads_scalar_location_stock FOR TESTING
      RAISING cx_static_check.
    METHODS reads_open_reservations FOR TESTING RAISING cx_static_check.
    METHODS reads_sales_order_reservations FOR TESTING
      RAISING cx_static_check.
    METHODS keeps_large_resv_rows FOR TESTING
      RAISING cx_static_check.
    METHODS reads_so_resv_candidates FOR TESTING
      RAISING cx_static_check.
    METHODS reads_batch_stock FOR TESTING RAISING cx_static_check.
    METHODS reads_bulk_po_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_sched_agreements FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_sto_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_po_confirmations FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_pr_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_receipt_uom_limits FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_prod_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_outgoing_sto FOR TESTING
      RAISING cx_static_check.
    METHODS reads_bulk_planned_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS reads_scalar_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS reads_available_date_supply FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_date_stock_overflow FOR TESTING
      RAISING cx_static_check.
    METHODS reads_date_prod_receipts FOR TESTING
      RAISING cx_static_check.
    METHODS nets_location_reservations FOR TESTING
      RAISING cx_static_check.
    METHODS nets_large_bulk_reservations FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_mard_stock_repository IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'MARC' TO lt_tables.
    APPEND 'MARD' TO lt_tables.
    APPEND 'MCHB' TO lt_tables.
    APPEND 'MCHA' TO lt_tables.
    APPEND 'MCH1' TO lt_tables.
    APPEND 'RESB' TO lt_tables.
    APPEND 'EKET' TO lt_tables.
    APPEND 'EKPO' TO lt_tables.
    APPEND 'EKKO' TO lt_tables.
    APPEND 'EKES' TO lt_tables.
    APPEND 'MARA' TO lt_tables.
    APPEND 'MARM' TO lt_tables.
    APPEND 'EBAN' TO lt_tables.
    APPEND 'AFPO' TO lt_tables.
    APPEND 'AFKO' TO lt_tables.
    APPEND 'AUFK' TO lt_tables.
    APPEND 'PLAF' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_bulk_safety_stock.
    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      eisbe = '3.000' ) TO lt_marc.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '2000'
      eisbe = '7.000' ) TO lt_marc.
    mo_environment->insert_test_data( lt_marc ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_statuses) = lo_repository->zif_stock_repository~get_safety_stock_bulk(
      it_requests = VALUE #(
        ( request_id = 'SAFE-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'SAFE-2' material = 'MAT-1' plant = '1000' )
        ( request_id = 'SAFE-3' material = 'MAT-1' plant = '3000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_statuses ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '3.000' )
      act = lt_statuses[ request_id = 'SAFE-1' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '3.000' )
      act = lt_statuses[ request_id = 'SAFE-2' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '0.000' )
      act = lt_statuses[ request_id = 'SAFE-3' ]-quantity ).
  ENDMETHOD.

  METHOD rejects_stock_status_overflow.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_stock_overflow_rejected TYPE abap_bool.
    DATA lv_res_overflow_rejected TYPE abap_bool.
    DATA lv_scalar_overflow_rejected TYPE abap_bool.

    lt_mard = VALUE #(
      ( matnr = 'MAT-STOCK-RANGE' werks = '1000' lgort = '0001'
        labst = '9999999999.999' )
      ( matnr = 'MAT-STOCK-RANGE' werks = '1000' lgort = '0002'
        labst = '9999999999.999' ) ).
    lt_resb = VALUE #(
      ( rsnum = '0000000801' rspos = '0001' matnr = 'MAT-RES-RANGE'
        werks = '1000' bdmng = '9999999999.999' )
      ( rsnum = '0000000802' rspos = '0001' matnr = 'MAT-RES-RANGE'
        werks = '1000' bdmng = '9999999999.999' ) ).
    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    TRY.
        lo_repository->zif_stock_repository~get_stock_status_bulk(
          it_requests = VALUE #( (
            request_id = 'STOCK-RANGE'
            material   = 'MAT-STOCK-RANGE'
            plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_stock_overflow_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_repository->zif_stock_repository~get_stock_status_bulk(
          it_requests = VALUE #( (
            request_id = 'RES-RANGE'
            material   = 'MAT-RES-RANGE'
            plant      = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_res_overflow_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_repository->zif_stock_repository~get_stock_status(
          iv_material = 'MAT-STOCK-RANGE'
          iv_plant    = '1000' ).
      CATCH zcx_invalid_stock_request.
        lv_scalar_overflow_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_stock_overflow_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_res_overflow_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_scalar_overflow_rejected ).
  ENDMETHOD.

  METHOD nets_unrestricted_stock_safely.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_overflow_rejected TYPE abap_bool.

    lt_mard = VALUE #(
      ( matnr = 'MAT-UNRESTRICTED-RANGE' werks = '1000' lgort = '0001'
        labst = '9999999999.999' )
      ( matnr = 'MAT-UNRESTRICTED-RANGE' werks = '1000' lgort = '0002'
        labst = '9999999999.999' )
      ( matnr = 'MAT-RESERVATION-RANGE' werks = '1000' lgort = '0001'
        labst = '10.000' ) ).
    lt_resb = VALUE #(
      ( rsnum = '0000000811' rspos = '0001' matnr = 'MAT-RESERVATION-RANGE'
        werks = '1000' bdmng = '9999999999.999' )
      ( rsnum = '0000000812' rspos = '0001' matnr = 'MAT-RESERVATION-RANGE'
        werks = '1000' bdmng = '9999999999.999' ) ).
    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    TRY.
        lo_repository->zif_stock_repository~get_unrestricted_stock(
          iv_material = CONV mard-matnr( 'MAT-UNRESTRICTED-RANGE' )
          iv_plant    = CONV mard-werks( '1000' ) ).
      CATCH zcx_invalid_stock_request.
        lv_overflow_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_overflow_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lo_repository->zif_stock_repository~get_unrestricted_stock(
        iv_material = CONV mard-matnr( 'MAT-RESERVATION-RANGE' )
        iv_plant    = CONV mard-werks( '1000' ) ) ).
  ENDMETHOD.

  METHOD reads_plant_stock_status.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    lt_mard = VALUE #(
      ( matnr = 'MAT-1' werks = '1000' lgort = '0001'
        labst = '10.000' insme = '2.000' speme = '1.000' )
      ( matnr = 'MAT-1' werks = '1000' lgort = '0002'
        labst = '5.000' speme = '3.000' )
      ( matnr = 'MAT-2' werks = '1000' lgort = '0001'
        labst = '50.000' )
      ( matnr = 'MAT-4' werks = '1000' lgort = '0001'
        labst = '2.000' ) ).
    mo_environment->insert_test_data( lt_mard ).

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    lt_resb = VALUE #(
      ( rsnum = '0000000301' rspos = '0001' matnr = 'MAT-1'
        werks = '1000' bdmng = '5.000' enmng = '2.000' )
      ( rsnum = '0000000302' rspos = '0001' matnr = 'MAT-1'
        werks = '1000' bdmng = '3.000' enmng = '1.000' )
      ( rsnum = '0000000303' rspos = '0001' matnr = 'MAT-1'
        werks = '1000' bdmng = '20.000' kzear = 'X' )
      ( rsnum = '0000000304' rspos = '0001' matnr = 'MAT-1'
        werks = '1000' bdmng = '20.000' xloek = 'X' )
      ( rsnum = '0000000305' rspos = '0001' matnr = 'MAT-1'
        werks = '1000' sobkz = 'E' bdmng = '20.000' )
      ( rsnum = '0000000306' rspos = '0001' matnr = 'MAT-2'
        werks = '1000' bdmng = '20.000' )
      ( rsnum = '0000000307' rspos = '0001' matnr = 'MAT-4'
        werks = '1000' bdmng = '5.000' )
      ( rsnum = '0000000308' rspos = '0001' matnr = 'MAT-1'
        werks = '1000' bdmng = '2.000' enmng = '4.000' ) ).
    mo_environment->insert_test_data( lt_resb ).

    DATA lt_marc TYPE STANDARD TABLE OF marc WITH EMPTY KEY.
    lt_marc = VALUE #(
      ( matnr = 'MAT-1' werks = '1000' eisbe = '4.000' )
      ( matnr = 'MAT-1' werks = '2000' eisbe = '7.000' )
      ( matnr = 'MAT-2' werks = '1000' eisbe = '9.000' ) ).
    mo_environment->insert_test_data( lt_marc ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lv_scalar_safety_stock) =
      lo_repository->zif_stock_repository~get_safety_stock(
        iv_material = CONV mard-matnr( 'MAT-1' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '4.000' )
      act = lv_scalar_safety_stock ).
    DATA(lv_other_plant_safety_stock) =
      lo_repository->zif_stock_repository~get_safety_stock(
        iv_material = CONV mard-matnr( 'MAT-1' )
        iv_plant    = CONV mard-werks( '2000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '7.000' )
      act = lv_other_plant_safety_stock ).
    DATA(lv_missing_safety_stock) =
      lo_repository->zif_stock_repository~get_safety_stock(
        iv_material = CONV mard-matnr( 'MAT-3' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '0.000' )
      act = lv_missing_safety_stock ).

    DATA(ls_status) = lo_repository->zif_stock_repository~get_stock_status(
      iv_material = CONV mard-matnr( 'MAT-1' )
      iv_plant    = CONV mard-werks( '1000' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = ls_status-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '2.000' )
      act = ls_status-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '4.000' )
      act = ls_status-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '5.000' )
      act = ls_status-reserved_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marc-eisbe( '4.000' )
      act = ls_status-safety_stock_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_status-available_after_safety_qty ).

    DATA(lv_unrestricted_available) =
      lo_repository->zif_stock_repository~get_unrestricted_stock(
        iv_material = CONV mard-matnr( 'MAT-1' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lv_unrestricted_available ).
    DATA(lv_over_reserved_available) =
      lo_repository->zif_stock_repository~get_unrestricted_stock(
        iv_material = CONV mard-matnr( 'MAT-4' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lv_over_reserved_available ).

    DATA(lt_bulk_statuses) =
      lo_repository->zif_stock_repository~get_stock_status_bulk(
        it_requests = VALUE #(
          ( request_id = 'MAT-2' material = 'MAT-2' plant = '1000' )
          ( request_id = 'MAT-1' material = 'MAT-1' plant = '1000' )
          ( request_id = 'MISSING' material = 'MAT-3' plant = '1000' )
          ( request_id = 'MAT-1-DUP' material = 'MAT-1' plant = '1000' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_bulk_statuses ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-2'
      act = lt_bulk_statuses[ 1 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '30.000' )
      act = lt_bulk_statuses[ 1 ]-stock_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '21.000' )
      act = lt_bulk_statuses[ 1 ]-stock_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_bulk_statuses[ 2 ]-stock_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_bulk_statuses[ 2 ]-stock_status-available_after_safety_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MISSING'
      act = lt_bulk_statuses[ 3 ]-request_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_bulk_statuses[ 3 ]-stock_status-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_bulk_statuses[ 4 ]-stock_status-available_unrestricted_qty ).
  ENDMETHOD.

  METHOD reads_scalar_location_stock.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    lt_mard = VALUE #(
      ( matnr = 'MAT-L' werks = '1000' lgort = '0001'
        labst = '10.000' insme = '2.000' speme = '1.000' )
      ( matnr = 'MAT-L' werks = '1000' lgort = '0002'
        labst = '5.000' insme = '1.000' ) ).
    mo_environment->insert_test_data( lt_mard ).

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    lt_resb = VALUE #(
      ( rsnum = '0000000401' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0001' bdmng = '6.000' enmng = '2.000' )
      ( rsnum = '0000000402' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0002' bdmng = '1.000' )
      ( rsnum = '0000000403' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' bdmng = '3.000' enmng = '1.000' )
      ( rsnum = '0000000404' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0001' bdmng = '10.000' enmng = '10.000' )
      ( rsnum = '0000000405' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0002' bdmng = '20.000' xloek = 'X' )
      ( rsnum = '0000000406' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0002' bdmng = '20.000' kzear = 'X' )
      ( rsnum = '0000000407' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0002' sobkz = 'E' bdmng = '20.000' )
      ( rsnum = '0000000408' rspos = '0001' matnr = 'MAT-L'
        werks = '1000' lgort = '0002' bdmng = '1.000' enmng = '3.000' ) ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_location_stock) =
      lo_repository->zif_stock_repository~get_stock_by_location(
        iv_material = CONV mard-matnr( 'MAT-L' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_location_stock ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_location_stock[ storage_location = '0001' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_location_stock[ storage_location = '0002' ]-available_quantity ).

    DATA(lt_status) =
      lo_repository->zif_stock_repository~get_stock_status_by_location(
        iv_material = CONV mard-matnr( 'MAT-L' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_status[ storage_location = '0001' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '2.000' )
      act = lt_status[ storage_location = '0001' ]-quality_inspection_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '1.000' )
      act = lt_status[ storage_location = '0001' ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_status[ storage_location = '0001' ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_status[ storage_location = '0002' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-insme( '1.000' )
      act = lt_status[ storage_location = '0002' ]-quality_inspection_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_status[ storage_location = '0002' ]-available_unrestricted_qty ).
  ENDMETHOD.

  METHOD reads_open_reservations.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #(
      rsnum = '0000000101'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-1'
      bdter = '20261020'
      bdmng = '5.000'
      enmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000102'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      bdmng = '8.000'
      enmng = '1.000'
      kzear = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000103'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      bdmng = '9.000'
      enmng = '1.000'
      xloek = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000104'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      bdmng = '10.000'
      enmng = '1.000'
      sobkz = 'E' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000105'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      bdmng = '2.000'
      enmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000201'
      rspos = '0020'
      matnr = 'MAT-1'
      werks = '2000'
      bdter = '20261021'
      bdmng = '7.000'
      enmng = '1.000' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_statuses) = lo_repository->zif_stock_repository~get_open_stock_res_bulk(
      it_requests = VALUE #(
        ( request_id = 'RES-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'RES-2' material = 'MAT-1' plant = '1000' )
        ( request_id = 'RES-3' material = 'MAT-1' plant = '2000' ) ) ).

    DATA(lt_scalar_reservations) =
      lo_repository->zif_stock_repository~get_open_stock_reservations(
        iv_material = CONV mard-matnr( 'MAT-1' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_scalar_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000101'
      act = lt_scalar_reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_scalar_reservations[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_scalar_reservations[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scalar_reservations[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_scalar_reservations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = lt_scalar_reservations[ 1 ]-open_quantity ).
    DATA(lt_missing_reservations) =
      lo_repository->zif_stock_repository~get_open_stock_reservations(
        iv_material = CONV mard-matnr( 'MAT-3' )
        iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_initial( lt_missing_reservations ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_statuses ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_statuses[ request_id = 'RES-1' ]-reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = lt_statuses[ request_id = 'RES-1' ]-reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_statuses[ request_id = 'RES-2' ]-reservations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '6.000' )
      act = lt_statuses[ request_id = 'RES-3' ]-reservations[ 1 ]-open_quantity ).
  ENDMETHOD.

  METHOD reads_batch_stock.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      labst = '13.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      labst = '4.000' ) TO lt_mard.
    mo_environment->insert_test_data( lt_mard ).

    DATA lt_mchb TYPE STANDARD TABLE OF mchb WITH EMPTY KEY.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-9'
      clabs = '-2.000' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-1'
      clabs = '10.000'
      cinsm = '1.000'
      cspem = '0.500' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      charg = 'B-1'
      clabs = '4.000' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-2'
      clabs = '5.000' ) TO lt_mchb.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      lgort = '0003'
      charg = 'B-3'
      clabs = '8.000' ) TO lt_mchb.
    mo_environment->insert_test_data( lt_mchb ).

    DATA lt_mcha TYPE STANDARD TABLE OF mcha WITH EMPTY KEY.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      charg = 'B-1'
      vfdat = '20271231' ) TO lt_mcha.
    mo_environment->insert_test_data( lt_mcha ).

    DATA lt_mch1 TYPE STANDARD TABLE OF mch1 WITH EMPTY KEY.
    APPEND VALUE #(
      matnr = 'MAT-1'
      charg = 'B-1'
      vfdat = '20261130' ) TO lt_mch1.
    APPEND VALUE #(
      matnr = 'MAT-2'
      charg = 'B-3'
      vfdat = '20261215' ) TO lt_mch1.
    mo_environment->insert_test_data( lt_mch1 ).

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #(
      rsnum = '0000000401'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-1'
      bdmng = '5.000'
      enmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000402'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      bdmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000403'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-1'
      bdmng = '50.000'
      xloek = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000404'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      charg = 'B-1'
      bdmng = '4.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000405'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-2'
      bdmng = '5.000'
      kzear = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000406'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-2'
      bdmng = '5.000'
      sobkz = 'E' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000407'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      charg = 'B-1'
      bdmng = '4.000'
      enmng = '6.000' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(ls_plant_status) = lo_repository->zif_stock_repository~get_stock_status(
      iv_material = CONV mard-matnr( 'MAT-1' )
      iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = ls_plant_status-available_unrestricted_qty ).

    DATA(lt_scalar_status) =
      lo_repository->zif_stock_repository~get_stock_status_by_batch(
        iv_material = CONV mard-matnr( 'MAT-1' )
        iv_plant    = CONV mard-werks( '1000' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_scalar_status ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '-2.000' )
      act = lt_scalar_status[
        storage_location = '0001' batch = 'B-9' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_scalar_status[
        storage_location = '0001' batch = 'B-9' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = lt_scalar_status[
        storage_location = '0001' batch = 'B-1' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20271231'
      act = lt_scalar_status[
        storage_location = '0001' batch = 'B-1' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_scalar_status[
        storage_location = '0002' batch = 'B-1' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '5.000' )
      act = lt_scalar_status[
        storage_location = '0001' batch = 'B-2' ]-available_quantity ).

    DATA(lt_scalar_stock) = lo_repository->zif_stock_repository~get_stock_by_batch(
      iv_material = CONV mard-matnr( 'MAT-1' )
      iv_plant    = CONV mard-werks( '1000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_scalar_stock ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_scalar_stock[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-1'
      act = lt_scalar_stock[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-2'
      act = lt_scalar_stock[ 2 ]-batch ).

    DATA(lt_statuses) = lo_repository->zif_stock_repository~get_batch_stock_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'BATCH-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'BATCH-2' material = 'MAT-1' plant = '1000' )
        ( request_id = 'BATCH-3' material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_statuses ) ).
    DATA(lt_batch1_summaries) = lt_statuses[
      request_id = 'BATCH-1' ]-resv_allocation_summaries.
    DATA(lv_full_open_quantity) = CONV resb-bdmng( 0 ).
    DATA(lv_partial_open_quantity) = CONV resb-bdmng( 0 ).
    DATA(lv_unallocated_open_quantity) = CONV resb-bdmng( 0 ).
    LOOP AT lt_batch1_summaries INTO DATA(ls_resv_summary).
      CASE ls_resv_summary-allocation_outcome.
        WHEN zif_stock_repository=>c_allocation_outcome_full.
          lv_full_open_quantity += ls_resv_summary-open_quantity.
        WHEN zif_stock_repository=>c_allocation_outcome_partial.
          lv_partial_open_quantity += ls_resv_summary-open_quantity.
        WHEN zif_stock_repository=>c_allocation_outcome_none.
          lv_unallocated_open_quantity += ls_resv_summary-open_quantity.
      ENDCASE.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = lv_full_open_quantity
      act = lt_statuses[ request_id = 'BATCH-1' ]-fully_alloc_resv_open_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_partial_open_quantity
      act = lt_statuses[ request_id = 'BATCH-1' ]-part_alloc_resv_open_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_unallocated_open_quantity
      act = lt_statuses[ request_id = 'BATCH-1' ]-unalloc_resv_open_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = lt_statuses[ request_id = 'BATCH-1' ]-open_reservation_quantity
      act = lv_full_open_quantity + lv_partial_open_quantity
        + lv_unallocated_open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20271231'
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20271231'
      act = lt_statuses[ request_id = 'BATCH-2' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '10.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '-2.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-9' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-9' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '3.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cinsm( '1.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-quality_inspection_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-cspem( '0.500' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0002' batch = 'B-1' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '5.000' )
      act = lt_statuses[ request_id = 'BATCH-1' ]-batches[
        storage_location = '0001' batch = 'B-2' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261215'
      act = lt_statuses[ request_id = 'BATCH-3' ]-batches[
        storage_location = '0003' batch = 'B-3' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '8.000' )
      act = lt_statuses[ request_id = 'BATCH-3' ]-batches[
        storage_location = '0003' batch = 'B-3' ]-available_quantity ).

    DATA(ls_batch_status) = lt_statuses[ request_id = 'BATCH-1' ].
    DATA(lv_batch_available) = CONV mchb-clabs( '0.000' ).
    LOOP AT ls_batch_status-batches INTO DATA(ls_batch_row).
      lv_batch_available = lv_batch_available
        + ls_batch_row-available_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = ls_plant_status-available_unrestricted_qty
      act = lv_batch_available ).
  ENDMETHOD.

  METHOD reads_bulk_po_receipts.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    APPEND VALUE #(
      matnr = 'MAT-1'
      meins = 'EA' ) TO lt_mara.
    APPEND VALUE #(
      ebeln = 'PO-1'
      bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'PO-2'
      bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'PO-3'
      bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'PO-4'
      bstyp = 'F' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'PO-1'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      lgort = '0001' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'PO-2'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      lgort = '0002' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'PO-3'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      elikz = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'PO-4'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      loekz = 'X' ) TO lt_ekpo.

    APPEND VALUE #(
      ebeln = 'PO-1'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261005'
      menge = '10.000'
      wemng = '2.000'
      wamng = '3.000'
      charg = 'B-PO1' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'PO-1'
      ebelp = '00010'
      etenr = '0002'
      eindt = '20261020'
      menge = '5.000'
      charg = 'B-PO2' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'PO-1'
      ebelp = '00010'
      etenr = '0003'
      eindt = '20261201'
      menge = '8.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'PO-3'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '4.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'PO-4'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261009'
      menge = '6.000' ) TO lt_eket.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_projected_receipts_bulk(
      it_requests            = VALUE #(
        ( request_id   = 'PO-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261010' )
        ( request_id   = 'PO-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261101' ) )
      iv_include_po_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ request_id = 'PO-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ request_id = 'PO-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '16.000' )
      act = lt_results[ request_id = 'PO-EARLY' ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = lt_results[ request_id = 'PO-EARLY' ]-receipts[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO-1'
      act = lt_results[ request_id = 'PO-EARLY' ]-receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ request_id = 'PO-EARLY' ]-receipts[ 1 ]-source_schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_results[ request_id = 'PO-LATE' ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_results[ request_id = 'PO-LATE' ]-receipts[ 2 ]-receipt_date ).
  ENDMETHOD.

  METHOD reads_bulk_sched_agreements.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #( ebeln = 'SA-1' bstyp = 'L' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'SA-2' bstyp = 'L' reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'SA-3' bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'SA-4' bstyp = 'L' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'SA-5' bstyp = 'L' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'SA-1'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      lgort = '0010' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'SA-2'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'SA-3'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'SA-4'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      stapo = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'SA-5'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      insmk = 'Q' ) TO lt_ekpo.

    APPEND VALUE #(
      ebeln = 'SA-1'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261005'
      menge = '6.000'
      wemng = '1.000'
      charg = 'SA-B1' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'SA-1'
      ebelp = '00010'
      etenr = '0002'
      eindt = '20261020'
      menge = '5.000'
      charg = 'SA-B2' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'SA-2'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261006'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'SA-3'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261006'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'SA-4'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261006'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'SA-5'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261006'
      menge = '20.000' ) TO lt_eket.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_projected_receipts_bulk(
      it_requests                    = VALUE #(
        ( request_id   = 'SA-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261010' )
        ( request_id   = 'SA-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261101' ) )
      iv_include_sched_agmt_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ request_id = 'SA-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ request_id = 'SA-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_results[ request_id = 'SA-EARLY' ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SCHED_AGREEMENT'
      act = lt_results[ request_id = 'SA-EARLY' ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SA-1'
      act = lt_results[ request_id = 'SA-EARLY' ]-receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_results[ request_id = 'SA-EARLY' ]-receipts[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_results[ request_id = 'SA-LATE' ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_results[ request_id = 'SA-LATE' ]-receipts[ 2 ]-receipt_date ).
  ENDMETHOD.

  METHOD reads_bulk_sto_receipts.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #( ebeln = 'STO-1' bstyp = 'F' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-2' bstyp = 'L' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-3' bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'STO-4'
      bstyp = 'F'
      reswk = '2000'
      bsakz = 'T' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-5' bstyp = 'K' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-6' bstyp = 'F' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-7' bstyp = 'F' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-8' bstyp = 'F' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-9' bstyp = 'F' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-10' bstyp = 'F' reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'STO-11' bstyp = 'F' reswk = '2000' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'STO-1' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' lgort = '0010' )
      TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-2' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-3' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-4' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-5' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-6' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '0' umrez = 2 umren = 1 wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-7' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' loekz = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-8' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' stapo = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-9' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' knttp = 'K' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-10' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' retpo = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'STO-11' ebelp = '00010' matnr = 'MAT-1' werks = '1000'
      pstyp = '7' umrez = 2 umren = 1 wepos = 'X' insmk = 'Q' ) TO lt_ekpo.

    APPEND VALUE #(
      ebeln = 'STO-1' ebelp = '00010' etenr = '0001' eindt = '20261005'
      menge = '10.000' wamng = '6.000' wemng = '2.000' charg = 'T-1A' )
      TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-1' ebelp = '00010' etenr = '0002' eindt = '20261020'
      menge = '5.000' wamng = '2.000' charg = 'T-1B' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-2' ebelp = '00010' etenr = '0001' eindt = '20261007'
      menge = '4.000' wamng = '3.000' charg = 'T-2A' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-3' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-4' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-5' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-6' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-7' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-8' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-9' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-10' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'STO-11' ebelp = '00010' etenr = '0001' eindt = '20261006'
      menge = '40.000' wamng = '20.000' ) TO lt_eket.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_projected_receipts_bulk(
      it_requests               = VALUE #(
        ( request_id   = 'STO-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261010' )
        ( request_id   = 'STO-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261021' ) )
      iv_include_sto_in_transit = abap_true
      iv_include_unissued_sto   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_results[ request_id = 'STO-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lines( lt_results[ request_id = 'STO-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO-1'
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 1 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO_IN_TRANSIT'
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO-2'
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 3 ]-source_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO_IN_TRANSIT'
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 3 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ request_id = 'STO-EARLY' ]-receipts[ 4 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_results[ request_id = 'STO-LATE' ]-receipts[ 5 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_results[ request_id = 'STO-LATE' ]-receipts[ 6 ]-quantity ).
  ENDMETHOD.

  METHOD reads_bulk_po_confirmations.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.
    DATA lt_ekes TYPE STANDARD TABLE OF ekes WITH EMPTY KEY.

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #( ebeln = 'CONF-1' bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'CONF-2' bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #( ebeln = 'CONF-3' bstyp = 'L' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      lgort = '0001' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'CONF-2'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X'
      elikz = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'CONF-3'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.

    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261005'
      menge = '12.000'
      wemng = '3.000'
      dabmg = '5.000'
      charg = 'SCHED-1' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      etenr = '0002'
      eindt = '20261020'
      menge = '10.000'
      wemng = '1.000'
      dabmg = '4.000'
      charg = 'SCHED-2' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'CONF-2'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261006'
      menge = '30.000'
      dabmg = '0.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'CONF-3'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261006'
      menge = '30.000'
      dabmg = '0.000' ) TO lt_eket.

    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      etens = '0001'
      eindt = '20261007'
      menge = '8.000'
      dabmg = '3.000'
      kzdis = 'X'
      charg = 'CONF-1A' ) TO lt_ekes.
    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      etens = '0002'
      eindt = '20261022'
      menge = '6.000'
      dabmg = '1.000'
      kzdis = 'X'
      charg = 'CONF-1B' ) TO lt_ekes.
    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      etens = '0003'
      eindt = '20261008'
      menge = '50.000'
      kzdis = space ) TO lt_ekes.
    APPEND VALUE #(
      ebeln = 'CONF-1'
      ebelp = '00010'
      etens = '0004'
      eindt = '20261009'
      menge = '50.000'
      kzdis = 'X'
      loekz = 'X' ) TO lt_ekes.
    APPEND VALUE #(
      ebeln = 'CONF-2'
      ebelp = '00010'
      etens = '0001'
      eindt = '20261008'
      menge = '50.000'
      kzdis = 'X' ) TO lt_ekes.
    APPEND VALUE #(
      ebeln = 'CONF-3'
      ebelp = '00010'
      etens = '0001'
      eindt = '20261008'
      menge = '50.000'
      kzdis = 'X' ) TO lt_ekes.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).
    mo_environment->insert_test_data( lt_ekes ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_po_confirmed_receipts_bulk(
      it_requests = VALUE #(
        ( request_id = 'CONF-EARLY' material = 'MAT-1' plant = '1000'
          through_date = '20261010' )
        ( request_id = 'CONF-LATE' material = 'MAT-1' plant = '1000'
          through_date = '20261030' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ request_id = 'CONF-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_results[ request_id = 'CONF-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO'
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 1 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 1 ]-source_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 1 ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 2 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-1A'
      act = lt_results[ request_id = 'CONF-EARLY' ]-receipts[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_results[ request_id = 'CONF-LATE' ]-receipts[ 2 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_results[ request_id = 'CONF-LATE' ]-receipts[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PO_CONFIRMATION'
      act = lt_results[ request_id = 'CONF-LATE' ]-receipts[ 3 ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-1A'
      act = lt_results[ request_id = 'CONF-LATE' ]-receipts[ 3 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_results[ request_id = 'CONF-LATE' ]-receipts[ 4 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CONF-1B'
      act = lt_results[ request_id = 'CONF-LATE' ]-receipts[ 4 ]-batch ).

    DATA(lt_scalar_receipts) =
      lo_repository->zif_stock_repository~get_po_confirmed_receipts(
        iv_material     = 'MAT-1'
        iv_plant        = '1000'
        iv_through_date = '20261030' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_scalar_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = lt_scalar_receipts[
        source_type = 'PO' source_schedule_line = '0001' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_scalar_receipts[
        source_type = 'PO_CONFIRMATION' batch = 'CONF-1A' ]-quantity ).
  ENDMETHOD.

  METHOD reads_bulk_pr_receipts.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.
    DATA lt_eban TYPE STANDARD TABLE OF eban WITH EMPTY KEY.

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meinh = 'BOX'
      umrez = 4
      umren = 1 ) TO lt_marm.

    APPEND VALUE #(
      banfn = 'PR-1'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261005'
      menge = '10.000'
      bsmng = '2.000'
      meins = 'BOX'
      pstyp = '0'
      lgort = '0001' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-2'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261020'
      menge = '5.000'
      bsmng = '1.000'
      meins = 'EA'
      pstyp = '0'
      lgort = '0002' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'STO-PR'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      reswk = '2000'
      lfdat = '20261008'
      menge = '3.000'
      bsmng = '1.000'
      meins = 'BOX'
      pstyp = '7'
      lgort = '0010' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-NO-UOM'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261009'
      menge = '3.000'
      bsmng = '1.000'
      meins = 'PAL'
      pstyp = '0' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-NO-MARA'
      bnfpo = '00010'
      matnr = 'MAT-2'
      werks = '1000'
      lfdat = '20261009'
      menge = '3.000'
      bsmng = '1.000'
      meins = 'EA'
      pstyp = '0' ) TO lt_eban.

    APPEND VALUE #(
      banfn = 'PR-DEL'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '0'
      loekz = 'X' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-DONE'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '0'
      ebakz = 'X' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-BLOCK'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '0'
      blckd = '1' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-ASSIGN'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '0'
      knttp = 'K' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-SPECIAL'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '0'
      sobkz = 'E' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'PR-FULL'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '5.000'
      bsmng = '5.000'
      meins = 'BOX'
      pstyp = '0' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'STO-SAME'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      reswk = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '7' ) TO lt_eban.
    APPEND VALUE #(
      banfn = 'STO-NONE'
      bnfpo = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      lfdat = '20261006'
      menge = '20.000'
      meins = 'BOX'
      pstyp = '7' ) TO lt_eban.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_marm ).
    mo_environment->insert_test_data( lt_eban ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_projected_receipts_bulk(
      it_requests                = VALUE #(
        ( request_id = 'PR-EARLY' material = 'MAT-1' plant = '1000'
          through_date = '20261010' )
        ( request_id = 'PR-LATE' material = 'MAT-1' plant = '1000'
          through_date = '20261030' )
        ( request_id = 'PR-NO-MARA' material = 'MAT-2' plant = '1000'
          through_date = '20261030' ) )
      iv_include_pr_receipts     = abap_true
      iv_include_sto_pr_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ request_id = 'PR-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results[ request_id = 'PR-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_results[ request_id = 'PR-NO-MARA' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '32.000' )
      act = lt_results[ request_id = 'PR-EARLY' ]-receipts[
        source_document = 'PR-1' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PR'
      act = lt_results[ request_id = 'PR-EARLY' ]-receipts[
        source_document = 'PR-1' ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_results[ request_id = 'PR-EARLY' ]-receipts[
        source_document = 'PR-1' ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_results[ request_id = 'PR-EARLY' ]-receipts[
        source_document = 'STO-PR' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'STO_PR'
      act = lt_results[ request_id = 'PR-EARLY' ]-receipts[
        source_document = 'STO-PR' ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_results[ request_id = 'PR-EARLY' ]-receipts[
        source_document = 'STO-PR' ]-source_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_results[ request_id = 'PR-LATE' ]-receipts[
        source_document = 'PR-2' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_results[ request_id = 'PR-LATE' ]-receipts[
        source_document = 'PR-2' ]-receipt_date ).
  ENDMETHOD.

  METHOD reads_bulk_prod_receipts.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.
    DATA lt_afko TYPE STANDARD TABLE OF afko WITH EMPTY KEY.
    DATA lt_aufk TYPE STANDARD TABLE OF aufk WITH EMPTY KEY.

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.

    APPEND VALUE #(
      aufnr = 'PROD-1'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '10.000'
      wemng = '2.000'
      umrez = 2
      umren = 1
      wepos = 'X'
      lgort = '0010'
      charg = 'PROD-B1' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROC-2'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '5.000'
      wemng = '1.000'
      umrez = 1
      umren = 1
      wepos = 'X'
      lgort = '0020'
      charg = 'PROC-B1' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROD-NO-GR'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '20.000'
      umrez = 1
      umren = 1 ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROD-DEL'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '20.000'
      umrez = 1
      umren = 1
      wepos = 'X'
      xloek = 'X' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROD-COMP'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '20.000'
      umrez = 1
      umren = 1
      wepos = 'X'
      elikz = 'X' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROD-SALES'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '20.000'
      umrez = 1
      umren = 1
      wepos = 'X'
      kdauf = 'SALES-1' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROD-ASSIGN'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '20.000'
      umrez = 1
      umren = 1
      wepos = 'X'
      knttp = 'K' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'PROD-UNREL'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '20.000'
      umrez = 1
      umren = 1
      wepos = 'X' ) TO lt_afpo.

    APPEND VALUE #( aufnr = 'PROD-1' gltrp = '20261005' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROC-2' gltrp = '20261020' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROD-NO-GR' gltrp = '20261005' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROD-DEL' gltrp = '20261005' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROD-COMP' gltrp = '20261005' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROD-SALES' gltrp = '20261005' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROD-ASSIGN' gltrp = '20261005' ) TO lt_afko.
    APPEND VALUE #( aufnr = 'PROD-UNREL' gltrp = '20261005' ) TO lt_afko.

    APPEND VALUE #(
      aufnr = 'PROD-1'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROC-2'
      autyp = '40'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROD-NO-GR'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROD-DEL'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROD-COMP'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROD-SALES'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROD-ASSIGN'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'PROD-UNREL'
      autyp = '10' ) TO lt_aufk.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_afpo ).
    mo_environment->insert_test_data( lt_afko ).
    mo_environment->insert_test_data( lt_aufk ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_projected_receipts_bulk(
      it_requests              = VALUE #(
        ( request_id   = 'PROD-EARLY'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261010' )
        ( request_id   = 'PROD-LATE'
          material     = 'MAT-1'
          plant        = '1000'
          through_date = '20261030' ) )
      iv_include_prod_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_results[ request_id = 'PROD-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ request_id = 'PROD-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '16.000' )
      act = lt_results[ request_id = 'PROD-EARLY' ]-receipts[
        source_document = 'PROD-1' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRODUCTION'
      act = lt_results[ request_id = 'PROD-EARLY' ]-receipts[
        source_document = 'PROD-1' ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_results[ request_id = 'PROD-EARLY' ]-receipts[
        source_document = 'PROD-1' ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PROD-B1'
      act = lt_results[ request_id = 'PROD-EARLY' ]-receipts[
        source_document = 'PROD-1' ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_results[ request_id = 'PROD-LATE' ]-receipts[
        source_document = 'PROC-2' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PROCESS_ORDER'
      act = lt_results[ request_id = 'PROD-LATE' ]-receipts[
        source_document = 'PROC-2' ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261020'
      act = lt_results[ request_id = 'PROD-LATE' ]-receipts[
        source_document = 'PROC-2' ]-receipt_date ).
  ENDMETHOD.

  METHOD reads_bulk_outgoing_sto.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      labst = '30.000' ) TO lt_mard.

    APPEND VALUE #(
      ebeln = 'OUT-1'
      bstyp = 'F'
      reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'OUT-2'
      bstyp = 'L'
      reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'OUT-CAT'
      bstyp = 'A'
      reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'OUT-SPEC'
      bstyp = 'F'
      bsakz = 'T'
      reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'OUT-SAME'
      bstyp = 'F'
      reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'OUT-ITEM'
      bstyp = 'F'
      reswk = '1000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'OUT-DEL'
      bstyp = 'F'
      reswk = '1000' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'OUT-1'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '2000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'OUT-2'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '2000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'OUT-CAT'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '2000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'OUT-SPEC'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '2000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'OUT-SAME'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'OUT-ITEM'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '2000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'OUT-DEL'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '2000'
      pstyp = '7'
      umrez = 2
      umren = 1
      loekz = 'X'
      wepos = 'X' ) TO lt_ekpo.

    APPEND VALUE #(
      ebeln = 'OUT-1'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '10.000'
      wamng = '4.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'OUT-2'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261020'
      menge = '4.000'
      wamng = '1.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'OUT-CAT'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'OUT-SPEC'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'OUT-SAME'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'OUT-ITEM'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '20.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'OUT-DEL'
      ebelp = '00010'
      etenr = '0001'
      eindt = '20261008'
      menge = '20.000' ) TO lt_eket.

    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_available_stock_date_bulk(
      it_requests              = VALUE #(
        ( request_id = 'OUT-EARLY' material = 'MAT-1' plant = '1000'
          required_date = '20261010' )
        ( request_id = 'OUT-LATE' material = 'MAT-1' plant = '1000'
          required_date = '20261030' ) )
      iv_subtract_unissued_sto = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '18.000' )
      act = lt_results[ request_id = 'OUT-EARLY' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '12.000' )
      act = lt_results[ request_id = 'OUT-LATE' ]-available_quantity ).
  ENDMETHOD.

  METHOD reads_bulk_planned_receipts.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.
    DATA lt_plaf TYPE STANDARD TABLE OF plaf WITH EMPTY KEY.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.
    DATA lv_start_date TYPE d.

    lv_start_date = sy-datum + 2.
    lv_early_date = sy-datum + 10.
    lv_late_date = sy-datum + 30.

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meinh = 'BOX'
      umrez = 4
      umren = 1 ) TO lt_marm.

    APPEND VALUE #(
      plnum = 'PLAN-1'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_early_date
      gsmng = '10.000'
      meins = 'BOX'
      lgort = '0010' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = 'PLAN-2'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_late_date
      gsmng = '5.000'
      meins = 'EA' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = 'FIX-1'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_early_date
      gsmng = '2.000'
      meins = 'EA'
      auffx = 'X' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = 'PLAN-NOUOM'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_early_date
      gsmng = '3.000'
      meins = 'PAL' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = 'PLAN-SALES'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_early_date
      gsmng = '20.000'
      meins = 'EA'
      kdauf = 'SALES-1' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = 'PLAN-SCENARIO'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_early_date
      gsmng = '20.000'
      meins = 'EA'
      plscn = '001' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = 'PLAN-SPECIAL'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = lv_start_date
      pedtr = lv_early_date
      gsmng = '20.000'
      meins = 'EA'
      sobkz = 'E' ) TO lt_plaf.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_marm ).
    mo_environment->insert_test_data( lt_plaf ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_projected_receipts_bulk(
      it_requests                 = VALUE #(
        ( request_id = 'PLAN-EARLY' material = 'MAT-1' plant = '1000'
          through_date = lv_early_date )
        ( request_id = 'PLAN-LATE' material = 'MAT-1' plant = '1000'
          through_date = lv_late_date ) )
      iv_include_planned_receipts = abap_true
      iv_include_fixed_planned    = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_results[ request_id = 'PLAN-EARLY' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_results[ request_id = 'PLAN-LATE' ]-receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '40.000' )
      act = lt_results[ request_id = 'PLAN-EARLY' ]-receipts[
        source_document = 'PLAN-1' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PLANNED_ORDER'
      act = lt_results[ request_id = 'PLAN-EARLY' ]-receipts[
        source_document = 'PLAN-1' ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_results[ request_id = 'PLAN-EARLY' ]-receipts[
        source_document = 'PLAN-1' ]-storage_location ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_results[ request_id = 'PLAN-EARLY' ]-receipts[
        source_document = 'FIX-1' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'FIXED_PLAN_ORDER'
      act = lt_results[ request_id = 'PLAN-EARLY' ]-receipts[
        source_document = 'FIX-1' ]-source_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_results[ request_id = 'PLAN-LATE' ]-receipts[
        source_document = 'PLAN-2' ]-quantity ).

    DATA(lt_planned_only) =
      lo_repository->zif_stock_repository~get_projected_receipts_bulk(
        it_requests                 = VALUE #( (
          request_id = 'PLAN-ONLY' material = 'MAT-1' plant = '1000'
          through_date = lv_early_date ) )
        iv_include_planned_receipts = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_only[ request_id = 'PLAN-ONLY' ]-receipts ) ).

    DATA(lt_fixed_only) =
      lo_repository->zif_stock_repository~get_projected_receipts_bulk(
        it_requests              = VALUE #( (
          request_id = 'FIXED-ONLY' material = 'MAT-1' plant = '1000'
          through_date = lv_early_date ) )
        iv_include_fixed_planned = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_fixed_only[ request_id = 'FIXED-ONLY' ]-receipts ) ).
  ENDMETHOD.

  METHOD rejects_receipt_uom_limits.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.
    DATA lt_eban TYPE STANDARD TABLE OF eban WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( matnr = 'MAT-OVER' meins = 'EA' )
      ( matnr = 'MAT-ROUND' meins = 'EA' ) ).
    lt_marm = VALUE #(
      ( matnr = 'MAT-OVER' meinh = 'BOX' umrez = 2 umren = 1 )
      ( matnr = 'MAT-ROUND' meinh = 'BOX' umrez = 1 umren = 99999 ) ).
    lt_eban = VALUE #(
      ( banfn = 'PR-OVER' bnfpo = '00010' matnr = 'MAT-OVER'
        werks = '1000' lfdat = '20261015' menge = '9999999999.999'
        meins = 'BOX' pstyp = '0' )
      ( banfn = 'PR-ROUND' bnfpo = '00010' matnr = 'MAT-ROUND'
        werks = '1000' lfdat = '20261015' menge = '0.001'
        meins = 'BOX' pstyp = '0' ) ).
    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_marm ).
    mo_environment->insert_test_data( lt_eban ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA lv_overflow_rejected TYPE abap_bool.
    DATA lv_zero_round_rejected TYPE abap_bool.

    TRY.
        lo_repository->zif_stock_repository~get_projected_receipts_bulk(
          it_requests            = VALUE #( (
            request_id   = 'PR-OVER'
            material     = 'MAT-OVER'
            plant        = '1000'
            through_date = '20261020' ) )
          iv_include_pr_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_overflow_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_repository->zif_stock_repository~get_projected_receipts_bulk(
          it_requests            = VALUE #( (
            request_id   = 'PR-ROUND'
            material     = 'MAT-ROUND'
            plant        = '1000'
            through_date = '20261020' ) )
          iv_include_pr_receipts = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_zero_round_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_overflow_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_zero_round_rejected ).
  ENDMETHOD.

  METHOD reads_scalar_receipts.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.
    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.
    DATA lt_afko TYPE STANDARD TABLE OF afko WITH EMPTY KEY.
    DATA lt_aufk TYPE STANDARD TABLE OF aufk WITH EMPTY KEY.
    DATA lv_receipt_date TYPE d.

    lv_receipt_date = sy-datum + 5.
    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #( ebeln = 'SCALAR-PO' bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'SCALAR-PO'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      wepos = 'X'
      umrez = 2
      umren = 1
      lgort = '0001' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'SCALAR-PO'
      ebelp = '00010'
      etenr = '0001'
      eindt = lv_receipt_date
      menge = '10.000'
      wemng = '2.000'
      charg = 'BATCH-PO' ) TO lt_eket.
    APPEND VALUE #(
      aufnr = 'SCALAR-PROD'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '5.000'
      wemng = '1.000'
      umrez = 2
      umren = 1
      wepos = 'X'
      lgort = '0002'
      charg = 'BATCH-PROD' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'SCALAR-MTO'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '10.000'
      umrez = 1
      umren = 1
      wepos = 'X'
      kdauf = 'SO-1' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'SCALAR-PROD'
      gltrp = lv_receipt_date ) TO lt_afko.
    APPEND VALUE #(
      aufnr = 'SCALAR-MTO'
      gltrp = lv_receipt_date ) TO lt_afko.
    APPEND VALUE #(
      aufnr = 'SCALAR-PROD'
      autyp = '40'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'SCALAR-MTO'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).
    mo_environment->insert_test_data( lt_afpo ).
    mo_environment->insert_test_data( lt_afko ).
    mo_environment->insert_test_data( lt_aufk ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_receipts) =
      lo_repository->zif_stock_repository~get_projected_receipts(
        iv_material              = 'MAT-1'
        iv_plant                 = '1000'
        iv_through_date          = lv_receipt_date
        iv_include_po_receipts   = abap_true
        iv_include_prod_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_receipts ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '16.000' )
      act = lt_receipts[ source_type = 'PO' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_receipts[ source_type = 'PROCESS_ORDER' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-PO'
      act = lt_receipts[ source_type = 'PO' ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_receipts[ source_type = 'PROCESS_ORDER' ]-storage_location ).
  ENDMETHOD.

  METHOD reads_available_date_supply.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.
    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.
    DATA lv_receipt_date TYPE d.
    DATA lv_late_receipt_date TYPE d.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.

    lv_receipt_date = sy-datum + 5.
    lv_late_receipt_date = sy-datum + 20.
    lv_early_date = sy-datum + 10.
    lv_late_date = sy-datum + 30.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      labst = '30.000' ) TO lt_mard.
    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.

    APPEND VALUE #( ebeln = 'DATE-PO' bstyp = 'F' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'DATE-STO-1'
      bstyp = 'F'
      reswk = '2000' ) TO lt_ekko.
    APPEND VALUE #(
      ebeln = 'DATE-STO-2'
      bstyp = 'L'
      reswk = '2000' ) TO lt_ekko.

    APPEND VALUE #(
      ebeln = 'DATE-PO'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '0'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'DATE-STO-1'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.
    APPEND VALUE #(
      ebeln = 'DATE-STO-2'
      ebelp = '00010'
      matnr = 'MAT-1'
      werks = '1000'
      pstyp = '7'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_ekpo.

    APPEND VALUE #(
      ebeln = 'DATE-PO'
      ebelp = '00010'
      etenr = '0001'
      eindt = lv_receipt_date
      menge = '10.000'
      wemng = '2.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'DATE-STO-1'
      ebelp = '00010'
      etenr = '0001'
      eindt = lv_receipt_date
      menge = '12.000'
      wamng = '7.000'
      wemng = '3.000' ) TO lt_eket.
    APPEND VALUE #(
      ebeln = 'DATE-STO-2'
      ebelp = '00010'
      etenr = '0001'
      eindt = lv_late_receipt_date
      menge = '4.000'
      wamng = '2.000'
      wemng = '1.000' ) TO lt_eket.

    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_ekko ).
    mo_environment->insert_test_data( lt_ekpo ).
    mo_environment->insert_test_data( lt_eket ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_available_stock_date_bulk(
      it_requests               = VALUE #(
        ( request_id = 'DATE-EARLY' material = 'MAT-1' plant = '1000'
          required_date = lv_early_date )
        ( request_id = 'DATE-LATE' material = 'MAT-1' plant = '1000'
          required_date = lv_late_date ) )
      iv_include_po_receipts    = abap_true
      iv_include_sto_in_transit = abap_true
      iv_include_unissued_sto   = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '64.000' )
      act = lt_results[ request_id = 'DATE-EARLY' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '70.000' )
      act = lt_results[ request_id = 'DATE-LATE' ]-available_quantity ).
  ENDMETHOD.

  METHOD rejects_date_stock_overflow.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lv_overflow_rejected TYPE abap_bool.

    lt_mard = VALUE #(
      ( matnr = 'MAT-RANGE' werks = '1000' lgort = '0001'
        labst = '9999999999.999' )
      ( matnr = 'MAT-RANGE' werks = '1000' lgort = '0002'
        labst = '9999999999.999' ) ).
    mo_environment->insert_test_data( lt_mard ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    TRY.
        lo_repository->zif_stock_repository~get_available_stock_date_bulk(
          it_requests = VALUE #( (
            request_id    = 'DATE-RANGE'
            material      = 'MAT-RANGE'
            plant         = '1000'
            required_date = '20261020' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_overflow_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_overflow_rejected ).
  ENDMETHOD.

  METHOD reads_date_prod_receipts.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.
    DATA lt_afko TYPE STANDARD TABLE OF afko WITH EMPTY KEY.
    DATA lt_aufk TYPE STANDARD TABLE OF aufk WITH EMPTY KEY.
    DATA lv_early_receipt_date TYPE d.
    DATA lv_late_receipt_date TYPE d.
    DATA lv_early_date TYPE d.
    DATA lv_late_date TYPE d.

    lv_early_receipt_date = sy-datum + 5.
    lv_late_receipt_date = sy-datum + 20.
    lv_early_date = sy-datum + 10.
    lv_late_date = sy-datum + 30.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      labst = '10.000' ) TO lt_mard.
    APPEND VALUE #(
      rsnum = '0000000901'
      rspos = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = lv_early_date
      bdmng = '2.000'
      enmng = '0.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000902'
      rspos = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = lv_early_date
      bdmng = '1.000'
      enmng = '3.000' ) TO lt_resb.

    APPEND VALUE #(
      aufnr = 'DATE-PROD-1'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '10.000'
      wemng = '2.000'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-2'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '5.000'
      wemng = '1.000'
      umrez = 2
      umren = 1
      wepos = 'X'
      kdauf = 'SO-1' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-3'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '5.000'
      wemng = '1.000'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-4'
      posnr = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '3.000'
      wemng = '1.000'
      umrez = 2
      umren = 1
      wepos = 'X' ) TO lt_afpo.

    APPEND VALUE #(
      aufnr = 'DATE-PROD-1'
      gltrp = lv_early_receipt_date ) TO lt_afko.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-2'
      gltrp = lv_early_receipt_date ) TO lt_afko.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-3'
      gltrp = lv_late_receipt_date ) TO lt_afko.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-4'
      gltrp = lv_late_receipt_date ) TO lt_afko.

    APPEND VALUE #(
      aufnr = 'DATE-PROD-1'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-2'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-3'
      autyp = '10'
      phas1 = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = 'DATE-PROD-4'
      autyp = '40'
      phas1 = 'X' ) TO lt_aufk.

    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_resb ).
    mo_environment->insert_test_data( lt_afpo ).
    mo_environment->insert_test_data( lt_afko ).
    mo_environment->insert_test_data( lt_aufk ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_results) = lo_repository->zif_stock_repository~get_available_stock_date_bulk(
      it_requests              = VALUE #(
        ( request_id = 'DATE-PROD-EARLY' material = 'MAT-1'
          plant = '1000' required_date = lv_early_date )
        ( request_id = 'DATE-PROD-LATE' material = 'MAT-1'
          plant = '1000' required_date = lv_late_date ) )
      iv_include_prod_receipts = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '24.000' )
      act = lt_results[ request_id = 'DATE-PROD-EARLY' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '36.000' )
      act = lt_results[ request_id = 'DATE-PROD-LATE' ]-available_quantity ).

    DATA(lv_scalar_quantity) =
      lo_repository->zif_stock_repository~get_available_stock_by_date(
        iv_material              = 'MAT-1'
        iv_plant                 = '1000'
        iv_required_date         = lv_late_date
        it_excluded_reservations = VALUE #( (
          reservation_number = '0000000901'
          reservation_item   = '0001' ) )
        iv_include_prod_receipts = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '38.000' )
      act = lv_scalar_quantity ).
  ENDMETHOD.

  METHOD reads_sales_order_reservations.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #(
      rsnum = '0000005101'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000010'
      kdein = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = '20261020'
      bwart = '231'
      bdmng = '5.000'
      enmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005102'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000010'
      kdein = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = '20261020'
      bwart = '231'
      bdmng = '3.000'
      enmng = '1.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005110'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000010'
      kdein = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = '20261020'
      bwart = '231'
      bdmng = '1.000'
      enmng = '3.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005109'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000010'
      kdein = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = '20261021'
      bwart = '231'
      bdmng = '2.000'
      enmng = '0.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005103'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000010'
      kdein = '0002'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = '20261021'
      bwart = '231'
      bdmng = '4.000'
      enmng = '1.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005104'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000020'
      kdein = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      bdter = '20261020'
      bwart = '231'
      bdmng = '3.000'
      enmng = '3.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005105'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000030'
      bwart = '231'
      bdmng = '20.000'
      kzear = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005106'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000040'
      bwart = '231'
      bdmng = '20.000'
      xloek = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005107'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000050'
      bwart = '231'
      sobkz = 'E'
      bdmng = '20.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005108'
      rspos = '0001'
      kdauf = '0000005001'
      kdpos = '000060'
      bwart = '201'
      bdmng = '20.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000005201'
      rspos = '0001'
      kdauf = '0000005002'
      kdpos = '000010'
      kdein = '0001'
      matnr = 'MAT-2'
      werks = '2000'
      bdter = '20261022'
      bwart = '231'
      bdmng = '12.000'
      enmng = '0.000' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_empty_reservations) =
      lo_repository->zif_stock_repository~get_order_reservations_bulk(
        it_sales_documents = VALUE #( ) ).
    cl_abap_unit_assert=>assert_initial( lt_empty_reservations ).

    DATA(lt_reservations) =
      lo_repository->zif_stock_repository~get_order_reservations_bulk(
        it_sales_documents = VALUE #( ( '0000005001' ) ( '0000005002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005001'
      act = lt_reservations[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000010'
      act = lt_reservations[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_reservations[ 1 ]-schedule_line ).
    DATA lv_same_day_open_quantity TYPE decfloat34.
    LOOP AT lt_reservations INTO DATA(ls_same_day_reservation)
      WHERE sales_document = '0000005001'
        AND item_number = '000010'
        AND schedule_line = '0001'
        AND requirement_date = '20261020'.
      lv_same_day_open_quantity += CONV decfloat34(
        ls_same_day_reservation-open_quantity ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '5.000' )
      act = lv_same_day_open_quantity ).
    READ TABLE lt_reservations INTO DATA(ls_later_reservation)
      WITH KEY sales_document = '0000005001'
               item_number = '000010'
               schedule_line = '0001'
               requirement_date = '20261021'.
    cl_abap_unit_assert=>assert_equals(
      exp = '20261021'
      act = ls_later_reservation-requirement_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '2.000' )
      act = ls_later_reservation-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_reservations[ 4 ]-schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '3.000' )
      act = lt_reservations[ 4 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005002'
      act = lt_reservations[ 5 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '12.000' )
      act = lt_reservations[ 5 ]-open_quantity ).
  ENDMETHOD.

  METHOD keeps_large_resv_rows.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    lt_resb = VALUE #(
      ( rsnum = '0000005301' rspos = '0001' kdauf = '0000005003'
        kdpos = '000010' kdein = '0001' matnr = 'MAT-3' werks = '1000'
        bdter = '20261020' bwart = '231' bdmng = '9999999999.999'
        enmng = '0.000' )
      ( rsnum = '0000005302' rspos = '0001' kdauf = '0000005003'
        kdpos = '000010' kdein = '0001' matnr = 'MAT-3' werks = '1000'
        bdter = '20261020' bwart = '231' bdmng = '9999999999.999'
        enmng = '0.000' ) ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_reservations) =
      lo_repository->zif_stock_repository~get_order_reservations_bulk(
        it_sales_documents = VALUE #( ( '0000005003' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '9999999999.999' )
      act = lt_reservations[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '9999999999.999' )
      act = lt_reservations[ 2 ]-open_quantity ).
  ENDMETHOD.

  METHOD reads_so_resv_candidates.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    lt_resb = VALUE #(
      ( rsnum = '0000006101' rspos = '0001' kdauf = '0000005001'
        kdpos = '000010' bwart = '231' bdmng = '5.000' enmng = '1.000' )
      ( rsnum = '0000006101' rspos = '0002' kdauf = '0000005001'
        kdpos = '000020' bwart = '231' bdmng = '2.000' )
      ( rsnum = '0000006102' rspos = '0001' kdauf = '0000005001'
        kdpos = '000030' bwart = '231' bdmng = '5.000' )
      ( rsnum = '0000006102' rspos = '0002' kdauf = '0000005002'
        kdpos = '000030' bwart = '231' bdmng = '5.000' )
      ( rsnum = '0000006103' rspos = '0001' kdauf = '0000005001'
        kdpos = '000040' bwart = '231' bdmng = '5.000' )
      ( rsnum = '0000006103' rspos = '0002' kdauf = '0000005001'
        kdpos = '000041' bwart = '201' bdmng = '1.000' )
      ( rsnum = '0000006104' rspos = '0001' kdauf = '0000005001'
        kdpos = '000050' bwart = '231' bdmng = '5.000' )
      ( rsnum = '0000006104' rspos = '0002' kdauf = '0000005001'
        kdpos = '000050' bwart = '231' sobkz = 'E' bdmng = '1.000' )
      ( rsnum = '0000006105' rspos = '0001' kdauf = '0000005001'
        kdpos = '000060' bwart = '231' bdmng = '5.000' enmng = '5.000' )
      ( rsnum = '0000006106' rspos = '0001' kdauf = '0000005001'
        kdpos = '000070' bwart = '231' bdmng = '5.000' kzear = 'X' )
      ( rsnum = '0000006107' rspos = '0001' kdauf = '0000005001'
        kdpos = '000080' bwart = '231' bdmng = '5.000' xloek = 'X' )
      ( rsnum = '0000006111' rspos = '0001' kdauf = '0000005001'
        kdpos = '000010' bwart = '231' bdmng = '3.000' )
      ( rsnum = '0000006201' rspos = '0001' kdauf = '0000005002'
        kdpos = '000010' bwart = '231' bdmng = '4.000' ) ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_empty_order_reservations) =
      lo_repository->zif_so_reservation_finder~get_open_reservations_bulk(
        it_sales_documents = VALUE #( ) ).
    DATA(lt_empty_item_reservations) =
      lo_repository->zif_so_reservation_finder~get_open_item_reservations(
        it_sales_order_items = VALUE #( ) ).
    cl_abap_unit_assert=>assert_initial( lt_empty_order_reservations ).
    cl_abap_unit_assert=>assert_initial( lt_empty_item_reservations ).

    DATA(lt_order_reservations) =
      lo_repository->zif_so_reservation_finder~get_open_reservations_bulk(
        it_sales_documents = VALUE #( ( '0000005002' ) ( '0000005001' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_order_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000006101'
      act = lt_order_reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000006111'
      act = lt_order_reservations[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005002'
      act = lt_order_reservations[ 3 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000006201'
      act = lt_order_reservations[ 3 ]-reservation_number ).

    DATA(lt_item_reservations) =
      lo_repository->zif_so_reservation_finder~get_open_item_reservations(
        it_sales_order_items = VALUE #(
          ( sales_document = '0000005002' item_number = '000010' )
          ( sales_document = '0000005001' item_number = '000010' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_item_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005001'
      act = lt_item_reservations[ 1 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000006111'
      act = lt_item_reservations[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000005002'
      act = lt_item_reservations[ 2 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000006201'
      act = lt_item_reservations[ 2 ]-reservation_number ).

    DATA(lt_scoped_order_reservations) =
      lo_repository->zif_so_reservation_finder~get_open_reservations_bulk(
        it_sales_documents = VALUE #( ( '0000005001' ) )
        iv_item_number     = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_scoped_order_reservations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000006111'
      act = lt_scoped_order_reservations[ 1 ]-reservation_number ).
  ENDMETHOD.

  METHOD nets_large_bulk_reservations.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_mchb TYPE STANDARD TABLE OF mchb WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    lt_mard = VALUE #(
      ( matnr = 'MAT-LOC-RES-RANGE' werks = '1000' lgort = '0001'
        labst = '10.000' ) ).
    lt_mchb = VALUE #(
      ( matnr = 'MAT-BATCH-RES-RANGE' werks = '1000' lgort = '0001'
        charg = 'B-1' clabs = '10.000' ) ).
    lt_resb = VALUE #(
      ( rsnum = '0000000991' rspos = '0001' matnr = 'MAT-LOC-RES-RANGE'
        werks = '1000' lgort = '0001' bdmng = '4999999999.999' )
      ( rsnum = '0000000992' rspos = '0001' matnr = 'MAT-LOC-RES-RANGE'
        werks = '1000' lgort = '0001' bdmng = '4999999999.999' )
      ( rsnum = '0000000993' rspos = '0001' matnr = 'MAT-BATCH-RES-RANGE'
        werks = '1000' lgort = '0001' charg = 'B-1'
        bdmng = '4999999999.999' )
      ( rsnum = '0000000994' rspos = '0001' matnr = 'MAT-BATCH-RES-RANGE'
        werks = '1000' lgort = '0001' charg = 'B-1'
        bdmng = '4999999999.999' ) ).

    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_mchb ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_location_statuses) =
      lo_repository->zif_stock_repository~get_location_stock_status_bulk(
        it_requests = VALUE #(
          ( request_id = 'LOC-RANGE'
            material   = 'MAT-LOC-RES-RANGE'
            plant      = '1000' ) ) ).
    DATA(lt_batch_statuses) =
      lo_repository->zif_stock_repository~get_batch_stock_status_bulk(
        it_requests = VALUE #(
          ( request_id = 'BATCH-RANGE'
            material   = 'MAT-BATCH-RES-RANGE'
            plant      = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '0.000' )
      act = lt_location_statuses[ request_id = 'LOC-RANGE' ]-locations[
        storage_location = '0001' ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mchb-clabs( '0.000' )
      act = lt_batch_statuses[ request_id = 'BATCH-RANGE' ]-batches[
        storage_location = '0001' batch = 'B-1' ]-available_quantity ).
  ENDMETHOD.

  METHOD nets_location_reservations.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      labst = '10.000'
      insme = '2.000'
      speme = '1.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      labst = '5.000'
      insme = '1.000' ) TO lt_mard.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      lgort = '0001'
      labst = '30.000' ) TO lt_mard.
    mo_environment->insert_test_data( lt_mard ).

    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #(
      rsnum = '0000000301'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      bdmng = '5.000'
      enmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000302'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      bdmng = '2.000'
      enmng = '0.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000303'
      rspos = '0020'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      bdmng = '1.000'
      enmng = '0.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000308'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0003'
      bdmng = '2.000'
      enmng = '0.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000304'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      bdmng = '20.000'
      enmng = '0.000'
      kzear = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000305'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      bdmng = '20.000'
      enmng = '0.000'
      xloek = 'X' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000306'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      bdmng = '20.000'
      enmng = '0.000'
      sobkz = 'E' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000307'
      rspos = '0010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      bdmng = '1.000'
      enmng = '3.000' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_repository) = NEW zcl_mard_stock_repository( ).
    DATA(lt_statuses) = lo_repository->zif_stock_repository~get_location_stock_status_bulk(
      it_requests = VALUE #(
        ( request_id = 'LOC-1' material = 'MAT-1' plant = '1000' )
        ( request_id = 'LOC-2' material = 'MAT-2' plant = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_statuses ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_statuses[ request_id = 'LOC-1' ]-locations[
        storage_location = '0001' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_statuses[ request_id = 'LOC-1' ]-locations[
        storage_location = '0001' ]-quality_inspection_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-speme( '1.000' )
      act = lt_statuses[ request_id = 'LOC-1' ]-locations[
        storage_location = '0001' ]-blocked_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lt_statuses[ request_id = 'LOC-1' ]-locations[
        storage_location = '0001' ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_statuses[ request_id = 'LOC-1' ]-locations[
        storage_location = '0002' ]-available_unrestricted_qty ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '30.000' )
      act = lt_statuses[ request_id = 'LOC-2' ]-locations[
        storage_location = '0001' ]-available_unrestricted_qty ).

    DATA(lt_excluded_statuses) =
      lo_repository->zif_stock_repository~get_location_stock_status_bulk(
        it_requests              = VALUE #(
          ( request_id = 'LOC-1-EXCLUDED'
            material   = 'MAT-1'
            plant      = '1000' ) )
        it_excluded_reservations = VALUE #( (
          reservation_number = '0000000301'
          reservation_item   = '0010' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_excluded_statuses[
        request_id = 'LOC-1-EXCLUDED' ]-locations[
          storage_location = '0001' ]-available_unrestricted_qty ).
  ENDMETHOD.
ENDCLASS.
