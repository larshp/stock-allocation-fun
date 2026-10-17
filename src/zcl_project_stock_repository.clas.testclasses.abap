CLASS ltcl_project_stock_repository DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_project_stock_and_expiry FOR TESTING
      RAISING cx_static_check.
    METHODS reads_stock_by_wbs FOR TESTING
      RAISING cx_static_check.
    METHODS reads_open_reservations FOR TESTING
      RAISING cx_static_check.
    METHODS includes_final_issue_items FOR TESTING
      RAISING cx_static_check.
    METHODS skips_empty_requests FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_project_stock_repository IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_mspr TYPE STANDARD TABLE OF mspr WITH EMPTY KEY.
    DATA lt_prps TYPE STANDARD TABLE OF prps WITH EMPTY KEY.
    DATA lt_mcha TYPE STANDARD TABLE OF mcha WITH EMPTY KEY.
    DATA lt_mch1 TYPE STANDARD TABLE OF mch1 WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    APPEND 'MSPR' TO lt_tables.
    APPEND 'PRPS' TO lt_tables.
    APPEND 'MCHA' TO lt_tables.
    APPEND 'MCH1' TO lt_tables.
    APPEND 'RESB' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #( pspnr = '00000001' posid = 'PRJ-100-A' ) TO lt_prps.
    APPEND VALUE #( pspnr = '00000002' posid = 'PRJ-100-B' ) TO lt_prps.
    APPEND VALUE #( pspnr = '00000003' posid = 'PRJ-200-A' ) TO lt_prps.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-PLANT'
      sobkz = 'Q'
      pspnr = '00000001'
      prlab = '10.000' ) TO lt_mspr.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      charg = 'B-GLOBAL'
      sobkz = 'Q'
      pspnr = '00000001'
      prlab = '5.000' ) TO lt_mspr.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0003'
      charg = 'B-UNKNOWN'
      sobkz = 'Q'
      pspnr = '00000001'
      prlab = '2.000' ) TO lt_mspr.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0004'
      charg = 'B-ZERO'
      sobkz = 'Q'
      pspnr = '00000001'
      prlab = '0.000' ) TO lt_mspr.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0005'
      charg = 'B-SPECIAL'
      sobkz = 'E'
      pspnr = '00000001'
      prlab = '4.000' ) TO lt_mspr.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      lgort = '0001'
      charg = 'B-MAT2'
      sobkz = 'Q'
      pspnr = '00000002'
      prlab = '7.000' ) TO lt_mspr.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-OTHER-WBS'
      sobkz = 'Q'
      pspnr = '00000003'
      prlab = '9.000' ) TO lt_mspr.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      charg = 'B-PLANT'
      vfdat = '20261130' ) TO lt_mcha.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      charg = 'B-GLOBAL' ) TO lt_mcha.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      charg = 'B-MAT2'
      vfdat = '20261115' ) TO lt_mcha.
    APPEND VALUE #(
      matnr = 'MAT-1'
      charg = 'B-PLANT'
      vfdat = '20250101' ) TO lt_mch1.
    APPEND VALUE #(
      matnr = 'MAT-1'
      charg = 'B-GLOBAL'
      vfdat = '20261201' ) TO lt_mch1.
    APPEND VALUE #(
      matnr = 'MAT-2'
      charg = 'B-MAT2'
      vfdat = '20261110' ) TO lt_mch1.

    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-PLANT'
      pspel = '00000001'
      sobkz = 'Q'
      bdter = '20261020'
      meins = 'EA'
      erfme = 'EA'
      bdmng = '10.000'
      enmng = '4.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0002'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      pspel = '00000001'
      sobkz = 'Q'
      kzear = 'X'
      bdmng = '5.000'
      enmng = '1.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0003'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      pspel = '00000001'
      sobkz = 'Q'
      xloek = 'X'
      bdmng = '5.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0004'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      pspel = '00000001'
      sobkz = 'Q'
      bdmng = '4.000'
      enmng = '4.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0006'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      pspel = '00000001'
      sobkz = 'Q'
      bdmng = '2.000'
      enmng = '4.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0005'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      pspel = '00000001'
      sobkz = 'E'
      bdmng = '5.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000002'
      rspos = '0001'
      matnr = 'MAT-2'
      werks = '2000'
      lgort = '0002'
      charg = 'B-MAT2'
      pspel = '00000002'
      sobkz = 'Q'
      bdter = '20261025'
      meins = 'KG'
      erfme = 'KG'
      bdmng = '7.000'
      enmng = '2.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000003'
      rspos = '0001'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0003'
      pspel = '00000003'
      sobkz = 'Q'
      bdmng = '9.000'
      enmng = '1.000' ) TO lt_resb.

    mo_environment->insert_test_data( lt_prps ).
    mo_environment->insert_test_data( lt_mspr ).
    mo_environment->insert_test_data( lt_mcha ).
    mo_environment->insert_test_data( lt_mch1 ).
    mo_environment->insert_test_data( lt_resb ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_project_stock_and_expiry.
    DATA(lo_cut) = NEW zcl_project_stock_repository( ).
    DATA(lt_stocks) = lo_cut->zif_project_stock_repository~read_project_stocks(
      it_keys = VALUE #(
        ( material = 'MAT-1' plant = '1000' wbs_element = 'PRJ-100-A' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_stocks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mcha-vfdat( '20261130' )
      act = lt_stocks[ batch = 'B-PLANT' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mch1-vfdat( '20261201' )
      act = lt_stocks[ batch = 'B-GLOBAL' ]-expiration_date ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_stocks[ batch = 'B-UNKNOWN' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '10.000' )
      act = lt_stocks[ batch = 'B-PLANT' ]-unrestricted_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-100-A'
      act = lt_stocks[ batch = 'B-PLANT' ]-wbs_element ).
  ENDMETHOD.

  METHOD reads_stock_by_wbs.
    DATA(lo_cut) = NEW zcl_project_stock_repository( ).
    DATA(lt_stocks) = lo_cut->zif_project_stock_repository~read_project_stocks_wbs(
      it_wbs_elements = VALUE #( ( 'PRJ-100-A' ) ( 'PRJ-100-B' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_stocks ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = REDUCE i( INIT count = 0
        FOR ls_stock IN lt_stocks
        WHERE ( wbs_element = 'PRJ-100-A' )
        NEXT count = count + 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mspr-prlab( '7.000' )
      act = lt_stocks[ wbs_element = 'PRJ-100-B' ]-unrestricted_quantity ).
  ENDMETHOD.

  METHOD reads_open_reservations.
    DATA(lo_cut) = NEW zcl_project_stock_repository( ).
    DATA(lt_by_key) = lo_cut->zif_project_stock_repository~read_project_reservations(
      it_keys = VALUE #(
        ( material = 'MAT-1' plant = '1000' wbs_element = 'PRJ-100-A' )
        ( material = 'MAT-2' plant = '2000' wbs_element = 'PRJ-100-B' ) ) ).
    DATA(lt_by_wbs) = lo_cut->zif_project_stock_repository~read_project_reservations_wbs(
      it_wbs_elements = VALUE #( ( 'PRJ-100-A' ) ( 'PRJ-100-B' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_by_key ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '6.000' )
      act = lt_by_key[ reservation_number = '0000000001' ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '5.000' )
      act = lt_by_key[ reservation_number = '0000000002' ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_by_wbs ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-100-B'
      act = lt_by_wbs[ reservation_number = '0000000002' ]-wbs_element ).
  ENDMETHOD.

  METHOD includes_final_issue_items.
    DATA(lo_cut) = NEW zcl_project_stock_repository( ).
    DATA(lt_items) = lo_cut->zif_project_stock_repository~read_project_resv_items_wbs(
      it_wbs_elements = VALUE #( ( 'PRJ-100-A' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_items[ reservation_item = '0002' ]-is_final_issue ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_items[ reservation_item = '0004' ]-is_final_issue ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_items[ reservation_item = '0004' ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '2.000' )
      act = lt_items[ reservation_item = '0006' ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '4.000' )
      act = lt_items[ reservation_item = '0006' ]-withdrawn_quantity ).
  ENDMETHOD.

  METHOD skips_empty_requests.
    DATA(lo_cut) = NEW zcl_project_stock_repository( ).
    DATA(lt_stocks) = lo_cut->zif_project_stock_repository~read_project_stocks(
      it_keys = VALUE #( ) ).
    DATA(lt_wbs_stocks) = lo_cut->zif_project_stock_repository~read_project_stocks_wbs(
      it_wbs_elements = VALUE #( ) ).
    DATA(lt_reservations) = lo_cut->zif_project_stock_repository~read_project_reservations(
      it_keys = VALUE #( ) ).
    DATA(lt_wbs_reservations) = lo_cut->zif_project_stock_repository~read_project_reservations_wbs(
      it_wbs_elements = VALUE #( ) ).
    DATA(lt_reservation_items) = lo_cut->zif_project_stock_repository~read_project_resv_items_wbs(
      it_wbs_elements = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_stocks ).
    cl_abap_unit_assert=>assert_initial( act = lt_wbs_stocks ).
    cl_abap_unit_assert=>assert_initial( act = lt_reservations ).
    cl_abap_unit_assert=>assert_initial( act = lt_wbs_reservations ).
    cl_abap_unit_assert=>assert_initial( act = lt_reservation_items ).
  ENDMETHOD.
ENDCLASS.
