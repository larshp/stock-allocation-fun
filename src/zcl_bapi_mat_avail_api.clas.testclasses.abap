CLASS ltcl_bapi_mat_avail_api DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_multiple_confirmations FOR TESTING.
    METHODS returns_no_confirmations FOR TESTING.
ENDCLASS.

CLASS ltcl_bapi_mat_avail_api IMPLEMENTATION.

  METHOD maps_multiple_confirmations.
    DATA(lt_result) = zcl_bapi_mat_avail_api=>map_confirmation_lines(
      it_bapi_confirmations = VALUE #(
        ( req_date = '20261001'
          req_qty  = '10.000'
          com_date = '20261001'
          com_qty  = '6.000' )
        ( req_date = '20261008'
          req_qty  = '4.000'
          com_date = '20261012'
          com_qty  = '4.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_result ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = lt_result[ 1 ]-requested_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_result[ 1 ]-requested_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261001'
      act = lt_result[ 1 ]-confirmed_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = lt_result[ 1 ]-confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261008'
      act = lt_result[ 2 ]-requested_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261012'
      act = lt_result[ 2 ]-confirmed_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = lt_result[ 2 ]-confirmed_quantity ).
  ENDMETHOD.

  METHOD returns_no_confirmations.
    DATA(lt_result) = zcl_bapi_mat_avail_api=>map_confirmation_lines(
      it_bapi_confirmations = VALUE
        zcl_bapi_mat_avail_api=>ty_bapi_confirmations( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_result ) ).
  ENDMETHOD.

ENDCLASS.
