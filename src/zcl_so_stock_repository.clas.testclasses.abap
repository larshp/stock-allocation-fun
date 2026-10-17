CLASS ltcl_so_stock_repository DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS resolves_items_and_units FOR TESTING RAISING cx_static_check.
    METHODS reads_stock_with_expiry FOR TESTING RAISING cx_static_check.
    METHODS reads_open_reservations FOR TESTING RAISING cx_static_check.
    METHODS skips_empty_requests FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_so_stock_repository IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    DATA lt_mska TYPE STANDARD TABLE OF mska WITH EMPTY KEY.
    DATA lt_mcha TYPE STANDARD TABLE OF mcha WITH EMPTY KEY.
    DATA lt_mch1 TYPE STANDARD TABLE OF mch1 WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    APPEND 'MARA' TO lt_tables.
    APPEND 'VBAP' TO lt_tables.
    APPEND 'MSKA' TO lt_tables.
    APPEND 'MCHA' TO lt_tables.
    APPEND 'MCH1' TO lt_tables.
    APPEND 'RESB' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #( matnr = 'MAT-2' meins = 'KG' ) TO lt_mara.
    APPEND VALUE #(
      vbeln = 'SO-1'
      posnr = '000010'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_vbap.
    APPEND VALUE #(
      vbeln = 'SO-1'
      posnr = '000020'
      matnr = 'MAT-2'
      werks = '2000' ) TO lt_vbap.
    APPEND VALUE #(
      vbeln = 'SO-2'
      posnr = '000010'
      matnr = 'MAT-1'
      werks = '1000' ) TO lt_vbap.

    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-PLANT'
      sobkz = 'E'
      kalab = '5.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0002'
      charg = 'B-GLOBAL'
      sobkz = 'E'
      kalab = '3.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0003'
      sobkz = 'E'
      kalab = '2.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0004'
      charg = 'B-UNKNOWN'
      sobkz = 'E'
      kalab = '1.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000020'
      matnr = 'MAT-2'
      werks = '2000'
      lgort = '0001'
      charg = 'B-MAT2'
      sobkz = 'E'
      kalab = '7.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-3'
      werks = '1000'
      lgort = '0005'
      charg = 'B-NO-MARA'
      sobkz = 'E'
      kalab = '9.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0006'
      charg = 'B-WRONG-SOBKZ'
      sobkz = 'Q'
      kalab = '11.000' ) TO lt_mska.
    APPEND VALUE #(
      kdauf = 'SO-9'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0007'
      charg = 'B-OTHER-SO'
      sobkz = 'E'
      kalab = '13.000' ) TO lt_mska.

    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      charg = 'B-PLANT'
      vfdat = '20261231' ) TO lt_mcha.
    APPEND VALUE #(
      matnr = 'MAT-1'
      werks = '1000'
      charg = 'B-GLOBAL' ) TO lt_mcha.
    APPEND VALUE #(
      matnr = 'MAT-2'
      werks = '2000'
      charg = 'B-MAT2'
      vfdat = '20261010' ) TO lt_mcha.
    APPEND VALUE #(
      matnr = 'MAT-1'
      charg = 'B-PLANT'
      vfdat = '20250101' ) TO lt_mch1.
    APPEND VALUE #(
      matnr = 'MAT-1'
      charg = 'B-GLOBAL'
      vfdat = '20261130' ) TO lt_mch1.
    APPEND VALUE #(
      matnr = 'MAT-2'
      charg = 'B-MAT2'
      vfdat = '20261012' ) TO lt_mch1.

    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      lgort = '0001'
      charg = 'B-PLANT'
      sobkz = 'E'
      rsnum = '0000000001'
      rspos = '0001'
      bdter = '20261020'
      bdmng = '10.000'
      enmng = '4.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      sobkz = 'E'
      xloek = 'X'
      rsnum = '0000000001'
      rspos = '0002' ) TO lt_resb.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000010'
      matnr = 'MAT-1'
      werks = '1000'
      sobkz = 'E'
      kzear = 'X'
      rsnum = '0000000001'
      rspos = '0003' ) TO lt_resb.
    APPEND VALUE #(
      kdauf = 'SO-1'
      kdpos = '000020'
      matnr = 'MAT-2'
      werks = '2000'
      sobkz = 'E'
      rsnum = '0000000002'
      rspos = '0001' ) TO lt_resb.

    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_vbap ).
    mo_environment->insert_test_data( lt_mska ).
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

  METHOD resolves_items_and_units.
    DATA(lo_cut) = NEW zcl_so_stock_repository( ).
    DATA(lt_items) = lo_cut->zif_so_stock_repository~read_order_items_bulk(
      it_item_requests = VALUE #(
        ( sales_document = 'SO-1' item_number = '000010' )
        ( sales_document = 'SO-1' item_number = '000020' )
        ( sales_document = 'SO-9' item_number = '000010' ) ) ).
    DATA(lt_units) = lo_cut->zif_so_stock_repository~read_base_units_bulk(
      it_requests = VALUE #(
        ( material = 'MAT-1' )
        ( material = 'MAT-2' )
        ( material = 'MAT-3' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV vbap-matnr( 'MAT-1' )
      act = lt_items[ item_number = '000010' ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV vbap-werks( '2000' )
      act = lt_items[ item_number = '000020' ]-plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_units ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lt_units[ material = 'MAT-1' ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'KG' )
      act = lt_units[ material = 'MAT-2' ]-base_unit ).
  ENDMETHOD.

  METHOD reads_stock_with_expiry.
    DATA(lo_cut) = NEW zcl_so_stock_repository( ).
    DATA(lt_rows) = lo_cut->zif_so_stock_repository~read_stock_bulk(
      it_requests = VALUE #(
        ( sales_document = 'SO-1'
          item_number    = '000010'
          material       = 'MAT-1'
          plant          = '1000' )
        ( sales_document = 'SO-1'
          item_number    = '000020'
          material       = 'MAT-2'
          plant          = '2000' )
        ( sales_document = 'SO-1'
          item_number    = '000010'
          material       = 'MAT-3'
          plant          = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_rows ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mska-kalab( '5.000' )
      act = lt_rows[ batch = 'B-PLANT' ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lt_rows[ batch = 'B-PLANT' ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mcha-vfdat( '20261231' )
      act = lt_rows[ batch = 'B-PLANT' ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mch1-vfdat( '20261130' )
      act = lt_rows[ batch = 'B-GLOBAL' ]-expiration_date ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_rows[ batch = 'B-UNKNOWN' ]-expiration_date ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_rows[ batch = space ]-expiration_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mcha-vfdat( '20261010' )
      act = lt_rows[ batch = 'B-MAT2' ]-expiration_date ).
  ENDMETHOD.

  METHOD reads_open_reservations.
    DATA(lo_cut) = NEW zcl_so_stock_repository( ).
    DATA(lt_rows) = lo_cut->zif_so_stock_repository~read_reservations_bulk(
      it_requests = VALUE #(
        ( sales_document = 'SO-1'
          item_number    = '000010'
          material       = 'MAT-1'
          plant          = '1000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_rows ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-rsnum( '0000000001' )
      act = lt_rows[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '10.000' )
      act = lt_rows[ 1 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '4.000' )
      act = lt_rows[ 1 ]-withdrawn_quantity ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_rows[ 1 ]-open_quantity ).
  ENDMETHOD.

  METHOD skips_empty_requests.
    DATA(lo_cut) = NEW zcl_so_stock_repository( ).
    DATA(lt_units) = lo_cut->zif_so_stock_repository~read_base_units_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_items) = lo_cut->zif_so_stock_repository~read_order_items_bulk(
      it_item_requests = VALUE #( ) ).
    DATA(lt_stocks) = lo_cut->zif_so_stock_repository~read_stock_bulk(
      it_requests = VALUE #( ) ).
    DATA(lt_reservations) = lo_cut->zif_so_stock_repository~read_reservations_bulk(
      it_requests = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_units ).
    cl_abap_unit_assert=>assert_initial( act = lt_items ).
    cl_abap_unit_assert=>assert_initial( act = lt_stocks ).
    cl_abap_unit_assert=>assert_initial( act = lt_reservations ).
  ENDMETHOD.
ENDCLASS.
