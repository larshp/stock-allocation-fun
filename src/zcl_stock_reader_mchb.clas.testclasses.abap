CLASS ltcl_stock_reader_mchb DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mchb_tt TYPE STANDARD TABLE OF mchb WITH DEFAULT KEY.
    TYPES ty_mcha_tt TYPE STANDARD TABLE OF mcha WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zif_stock_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_batch
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_charg TYPE mcha-charg
        iv_clabs TYPE menge_d DEFAULT 0
        iv_cinsm TYPE menge_d DEFAULT 0
        iv_cspem TYPE menge_d DEFAULT 0
        iv_ceinm TYPE menge_d DEFAULT 0
        iv_vfdat TYPE d OPTIONAL
        iv_matnr TYPE matnr DEFAULT 'MAT-1'
        iv_werks TYPE werks_d DEFAULT '1000'.

    METHODS read
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_tt.

    METHODS reads_batch_with_expiry    FOR TESTING.
    METHODS maps_quantity_fields       FOR TESTING.
    METHODS ignores_other_plant        FOR TESTING.
    METHODS no_data_returns_empty      FOR TESTING.
    METHODS missing_master_no_expiry   FOR TESTING.
    METHODS returns_one_row_per_batch  FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_reader_mchb IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MCHB' ) ( 'MCHA' ) ) ).
    mo_cut = NEW zcl_stock_reader_mchb( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_batch.
    DATA ls_mchb TYPE mchb.
    DATA ls_mcha TYPE mcha.

    ls_mchb-mandt = sy-mandt.
    ls_mchb-matnr = iv_matnr.
    ls_mchb-werks = iv_werks.
    ls_mchb-lgort = iv_lgort.
    ls_mchb-charg = iv_charg.
    ls_mchb-clabs = iv_clabs.
    ls_mchb-cinsm = iv_cinsm.
    ls_mchb-cspem = iv_cspem.
    ls_mchb-ceinm = iv_ceinm.

    mo_environment->insert_test_data( VALUE ty_mchb_tt( ( ls_mchb ) ) ).

    IF iv_vfdat IS NOT INITIAL.
      ls_mcha-mandt = sy-mandt.
      ls_mcha-matnr = iv_matnr.
      ls_mcha-charg = iv_charg.
      ls_mcha-vfdat = iv_vfdat.

      mo_environment->insert_test_data( VALUE ty_mcha_tt( ( ls_mcha ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD read.
    rt_stock = mo_cut->read_stock( iv_matnr = 'MAT-1'
                                   iv_werks = '1000' ).
  ENDMETHOD.

  METHOD reads_batch_with_expiry.
    given_batch( iv_lgort = '0001'
                 iv_charg = 'BATCH-A'
                 iv_clabs = '7'
                 iv_vfdat = '20260630' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-charg
                                        exp = 'BATCH-A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-expiry_date
                                        exp = '20260630' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-lgort
                                        exp = '0001' ).
  ENDMETHOD.

  METHOD maps_quantity_fields.
    given_batch( iv_lgort = '0001'
                 iv_charg = 'BATCH-A'
                 iv_clabs = '1'
                 iv_cinsm = '2'
                 iv_cspem = '3'
                 iv_ceinm = '4' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-unrestricted_qty
                                        exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-quality_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-blocked_qty
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_stock[ 1 ]-restricted_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD ignores_other_plant.
    given_batch( iv_lgort = '0001'
                 iv_charg = 'BATCH-A'
                 iv_clabs = '7'
                 iv_werks = '2000' ).

    cl_abap_unit_assert=>assert_initial( act = read( ) ).
  ENDMETHOD.

  METHOD no_data_returns_empty.
    cl_abap_unit_assert=>assert_initial( act = read( ) ).
  ENDMETHOD.

  METHOD missing_master_no_expiry.
    given_batch( iv_lgort = '0001'
                 iv_charg = 'BATCH-B'
                 iv_clabs = '3' ).

    DATA(lt_stock) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_stock )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_initial( act = lt_stock[ 1 ]-expiry_date ).
  ENDMETHOD.

  METHOD returns_one_row_per_batch.
    given_batch( iv_lgort = '0001'
                 iv_charg = 'BATCH-A'
                 iv_clabs = '2' ).
    given_batch( iv_lgort = '0001'
                 iv_charg = 'BATCH-B'
                 iv_clabs = '3' ).

    cl_abap_unit_assert=>assert_equals( act = lines( read( ) )
                                        exp = 2 ).
  ENDMETHOD.

ENDCLASS.
