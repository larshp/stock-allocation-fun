CLASS ltcl_cc_reservation_read_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_open_cc_reservations FOR TESTING
      RAISING cx_static_check.
    METHODS reads_matching_item_scopes FOR TESTING
      RAISING cx_static_check.
    METHODS skips_empty_requests FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_cc_reservation_read_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lt_rkpf TYPE STANDARD TABLE OF rkpf WITH EMPTY KEY.

    APPEND 'RESB' TO lt_tables.
    APPEND 'RKPF' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #( rsnum = '0000000001' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000002' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000003' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000004' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000005' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000006' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000007' kostl = 'CC-1' ) TO lt_rkpf.
    APPEND VALUE #( rsnum = '0000000008' kostl = 'CC-2' ) TO lt_rkpf.

    APPEND VALUE #(
      rsnum = '0000000001'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      lgort = '0001'
      charg = 'B-1'
      bwart = '201'
      bdter = '20261022'
      meins = 'EA'
      bdmng = '10.000'
      enmng = '4.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000002'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      lgort = '0002'
      charg = 'B-2'
      bwart = '201'
      bdter = '20261010'
      meins = 'EA'
      bdmng = '5.000'
      enmng = '1.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000003'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      bwart = '202'
      bdmng = '10.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000004'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      bwart = '201'
      sobkz = 'E'
      bdmng = '10.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000005'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      bwart = '201'
      xloek = 'X'
      bdmng = '10.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000006'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      bwart = '201'
      kzear = 'X'
      bdmng = '10.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000007'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      bwart = '201'
      bdmng = '3.000'
      enmng = '3.000' ) TO lt_resb.
    APPEND VALUE #(
      rsnum = '0000000008'
      rspos = '0001'
      matnr = 'MAT-A'
      werks = '1000'
      bwart = '201'
      bdter = '20261015'
      meins = 'EA'
      bdmng = '8.000'
      enmng = '2.000' ) TO lt_resb.

    mo_environment->insert_test_data( lt_rkpf ).
    mo_environment->insert_test_data( lt_resb ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_open_cc_reservations.
    DATA(lo_cut) = NEW zcl_cc_reservation_read_repo( ).
    DATA(lt_bulk) = lo_cut->zif_cc_reservation_read_repo~get_open_reservations_bulk(
      it_cost_centers = VALUE #( ( 'CC-1' ) ( 'CC-2' ) ) ).
    DATA(lt_single) = lo_cut->zif_cc_reservation_read_repo~get_open_reservations(
      iv_cost_center = 'CC-1' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_bulk ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_bulk[ 1 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '4.000' )
      act = lt_bulk[ 1 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-1'
      act = lt_bulk[ 1 ]-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000008'
      act = lt_bulk[ 2 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '6.000' )
      act = lt_bulk[ 2 ]-open_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-2'
      act = lt_bulk[ 2 ]-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_bulk[ 3 ]-reservation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-1'
      act = lt_bulk[ 3 ]-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_single ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_single[ 1 ]-reservation_number ).
  ENDMETHOD.

  METHOD reads_matching_item_scopes.
    DATA(lo_cut) = NEW zcl_cc_reservation_read_repo( ).
    DATA(lt_scopes) = lo_cut->zif_cc_reservation_read_repo~get_reservation_item_scopes(
      iv_cost_center = 'CC-1'
      it_item_keys   = VALUE #(
        ( reservation_number = '0000000001' reservation_item = '0001' )
        ( reservation_number = '0000000003' reservation_item = '0001' )
        ( reservation_number = '0000000004' reservation_item = '0001' )
        ( reservation_number = '0000000008' reservation_item = '0001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_scopes ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CC-1'
      act = lt_scopes[ 1 ]-cost_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_scopes[ 1 ]-reservation_number ).
  ENDMETHOD.

  METHOD skips_empty_requests.
    DATA(lo_cut) = NEW zcl_cc_reservation_read_repo( ).
    DATA(lt_reservations) = lo_cut->zif_cc_reservation_read_repo~get_open_reservations_bulk(
      it_cost_centers = VALUE #( ) ).
    DATA(lt_scopes) = lo_cut->zif_cc_reservation_read_repo~get_reservation_item_scopes(
      iv_cost_center = 'CC-1'
      it_item_keys   = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_reservations ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_scopes ).
  ENDMETHOD.
ENDCLASS.
