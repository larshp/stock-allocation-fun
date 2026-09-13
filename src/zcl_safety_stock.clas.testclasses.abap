CLASS ltcl_safety_stock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_config_tt TYPE STANDARD TABLE OF zsafetystk WITH DEFAULT KEY.

    CLASS-DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut TYPE REF TO zif_safety_stock.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS given_config
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_qty   TYPE menge_d
        iv_matnr TYPE matnr DEFAULT 'MAT-1'
        iv_werks TYPE werks_d DEFAULT '1000'.

    METHODS reads_config_rows    FOR TESTING.
    METHODS reads_all_locations  FOR TESTING.
    METHODS ignores_other_plant  FOR TESTING.
    METHODS ignores_other_matnr  FOR TESTING.
    METHODS no_config_is_empty   FOR TESTING.
ENDCLASS.


CLASS ltcl_safety_stock IMPLEMENTATION.

  METHOD class_setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSAFETYSTK' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    mo_environment->clear_doubles( ).
    mo_cut = NEW zcl_safety_stock( ).
  ENDMETHOD.

  METHOD given_config.
    DATA ls_config TYPE zsafetystk.

    ls_config-mandt = sy-mandt.
    ls_config-matnr = iv_matnr.
    ls_config-werks = iv_werks.
    ls_config-lgort = iv_lgort.
    ls_config-qty = iv_qty.

    mo_environment->insert_test_data( VALUE ty_config_tt( ( ls_config ) ) ).
  ENDMETHOD.

  METHOD reads_config_rows.
    given_config( iv_lgort = '0001' iv_qty = '4' ).

    DATA(lt_config) = mo_cut->read( iv_matnr = 'MAT-1'
                                    iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_config )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_config[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_config[ 1 ]-qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD reads_all_locations.
    given_config( iv_lgort = '0002' iv_qty = '2' ).
    given_config( iv_lgort = '0001' iv_qty = '4' ).

    DATA(lt_config) = mo_cut->read( iv_matnr = 'MAT-1'
                                    iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_config )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_config[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_config[ 2 ]-lgort
                                        exp = '0002' ).
  ENDMETHOD.

  METHOD ignores_other_plant.
    given_config( iv_lgort = '0001' iv_qty = '4' iv_werks = '2000' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read( iv_matnr = 'MAT-1' iv_werks = '1000' ) ).
  ENDMETHOD.

  METHOD ignores_other_matnr.
    given_config( iv_lgort = '0001' iv_qty = '4' iv_matnr = 'MAT-2' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read( iv_matnr = 'MAT-1' iv_werks = '1000' ) ).
  ENDMETHOD.

  METHOD no_config_is_empty.
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read( iv_matnr = 'MAT-1' iv_werks = '1000' ) ).
  ENDMETHOD.

ENDCLASS.
