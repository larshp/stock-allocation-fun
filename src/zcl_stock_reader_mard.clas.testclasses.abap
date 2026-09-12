CLASS ltcl_stock_reader_mard DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zif_stock_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0
        iv_insme TYPE menge_d DEFAULT 0
        iv_speme TYPE menge_d DEFAULT 0
        iv_einme TYPE menge_d DEFAULT 0
        iv_umlme TYPE menge_d DEFAULT 0
        iv_werks TYPE werks_d DEFAULT '1000'.

    METHODS returns_all_locations FOR TESTING.
    METHODS maps_quantity_fields     FOR TESTING.
    METHODS ignores_other_plant      FOR TESTING.
    METHODS no_data_returns_empty    FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_reader_mard IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARD' ) ) ).
    mo_cut = NEW zcl_stock_reader_mard( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = 'MAT-1'.
    ls_mard-werks = iv_werks.
    ls_mard-lgort = iv_lgort.
    ls_mard-labst = iv_labst.
    ls_mard-insme = iv_insme.
    ls_mard-speme = iv_speme.
    ls_mard-einme = iv_einme.
    ls_mard-umlme = iv_umlme.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD returns_all_locations.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_stock( iv_lgort = '0002' iv_labst = '5' ).

    DATA(lt_stock) = mo_cut->read_stock( iv_matnr = 'MAT-1'
                                         iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 2 ]-lgort
                                        exp = '0002' ).
  ENDMETHOD.

  METHOD maps_quantity_fields.
    given_stock( iv_lgort = '0001'
                 iv_labst = '10'
                 iv_insme = '3'
                 iv_speme = '2'
                 iv_einme = '1'
                 iv_umlme = '4' ).

    DATA(lt_stock) = mo_cut->read_stock( iv_matnr = 'MAT-1'
                                         iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-quality_qty
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-blocked_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-restricted_qty
                                        exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-in_transit_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD ignores_other_plant.
    given_stock( iv_lgort = '0001' iv_labst = '10' iv_werks = '1000' ).
    given_stock( iv_lgort = '0001' iv_labst = '7' iv_werks = '2000' ).

    DATA(lt_stock) = mo_cut->read_stock( iv_matnr = 'MAT-1'
                                         iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '10' ).
  ENDMETHOD.

  METHOD no_data_returns_empty.
    DATA(lt_stock) = mo_cut->read_stock( iv_matnr = 'MAT-1'
                                         iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( act = lt_stock ).
  ENDMETHOD.

ENDCLASS.
