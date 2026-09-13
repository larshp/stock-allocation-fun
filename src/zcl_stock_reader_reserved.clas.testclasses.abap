CLASS ltcl_stock_reader_reserved DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    TYPES ty_resv_tt TYPE STANDARD TABLE OF zstockresv WITH DEFAULT KEY.

    CLASS-DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut TYPE REF TO zif_stock_reader.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS given_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0.

    METHODS given_reservation
      IMPORTING
        iv_matnr TYPE matnr
        iv_lgort TYPE lgort_d
        iv_qty   TYPE menge_d DEFAULT 0.

    METHODS read
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_tt.

    METHODS subtracts_reservation     FOR TESTING.
    METHODS clamps_at_zero            FOR TESTING.
    METHODS leaves_other_locations    FOR TESTING.
    METHODS no_reservation_unchanged  FOR TESTING.
    METHODS ignores_other_material    FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_reader_reserved IMPLEMENTATION.

  METHOD class_setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARD' ) ( 'ZSTOCKRESV' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    mo_environment->clear_doubles( ).
    mo_cut = NEW zcl_stock_reader_reserved(
      io_reader = NEW zcl_stock_reader_mard( ) ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = 'MAT-1'.
    ls_mard-werks = '1000'.
    ls_mard-lgort = iv_lgort.
    ls_mard-labst = iv_labst.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD given_reservation.
    DATA ls_resv TYPE zstockresv.

    ls_resv-mandt = sy-mandt.
    ls_resv-matnr = iv_matnr.
    ls_resv-werks = '1000'.
    ls_resv-lgort = iv_lgort.
    ls_resv-run_id = 'RUN-1'.
    ls_resv-req_id = 'REQ-1'.
    ls_resv-qty = iv_qty.

    mo_environment->insert_test_data( VALUE ty_resv_tt( ( ls_resv ) ) ).
  ENDMETHOD.

  METHOD read.
    rt_stock = mo_cut->read_stock( iv_matnr = 'MAT-1'
                                   iv_werks = '1000' ).
  ENDMETHOD.

  METHOD subtracts_reservation.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_reservation( iv_matnr = 'MAT-1' iv_lgort = '0001' iv_qty = '4' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD clamps_at_zero.
    given_stock( iv_lgort = '0001' iv_labst = '3' ).
    given_reservation( iv_matnr = 'MAT-1' iv_lgort = '0001' iv_qty = '5' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD leaves_other_locations.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_stock( iv_lgort = '0002' iv_labst = '10' ).
    given_reservation( iv_matnr = 'MAT-1' iv_lgort = '0002' iv_qty = '4' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 2 ]-unrestricted_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD no_reservation_unchanged.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '10' ).
  ENDMETHOD.

  METHOD ignores_other_material.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_reservation( iv_matnr = 'MAT-2' iv_lgort = '0001' iv_qty = '4' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '10' ).
  ENDMETHOD.

ENDCLASS.
