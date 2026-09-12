CLASS ltcl_stock_substitution DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_sub_tt TYPE STANDARD TABLE OF zsubstitute WITH DEFAULT KEY.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    TYPES ty_safety_tt TYPE STANDARD TABLE OF zsafetystk WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_stock_substitution.

    METHODS setup.
    METHODS teardown.

    METHODS given_rule
      IMPORTING
        iv_matnr    TYPE matnr
        iv_submatnr TYPE matnr
        iv_prio     TYPE zsubstitute-prio DEFAULT '01'.

    METHODS given_stock
      IMPORTING
        iv_matnr TYPE matnr
        iv_labst TYPE menge_d DEFAULT 0.

    METHODS given_safety_stock
      IMPORTING
        iv_matnr TYPE matnr
        iv_lgort TYPE lgort_d
        iv_qty   TYPE menge_d.

    METHODS reads_rules_by_priority FOR TESTING.
    METHODS no_rules_returns_empty  FOR TESTING.
    METHODS sums_own_and_subs       FOR TESTING.
    METHODS details_start_with_own  FOR TESTING.
    METHODS ignores_other_material  FOR TESTING.
    METHODS safety_stock_reduces_own FOR TESTING.
    METHODS safety_stock_for_substitute FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_substitution IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSUBSTITUTE' ) ( 'MARD' )
                                   ( 'ZSAFETYSTK' ) ) ).
    mo_cut = NEW zcl_stock_substitution( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_rule.
    DATA ls_rule TYPE zsubstitute.

    ls_rule-mandt = sy-mandt.
    ls_rule-matnr = iv_matnr.
    ls_rule-submatnr = iv_submatnr.
    ls_rule-prio = iv_prio.

    mo_environment->insert_test_data( VALUE ty_sub_tt( ( ls_rule ) ) ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = iv_matnr.
    ls_mard-werks = '1000'.
    ls_mard-lgort = '0001'.
    ls_mard-labst = iv_labst.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD given_safety_stock.
    DATA ls_config TYPE zsafetystk.

    ls_config-mandt = sy-mandt.
    ls_config-matnr = iv_matnr.
    ls_config-werks = '1000'.
    ls_config-lgort = iv_lgort.
    ls_config-qty = iv_qty.

    mo_environment->insert_test_data( VALUE ty_safety_tt( ( ls_config ) ) ).
  ENDMETHOD.

  METHOD reads_rules_by_priority.
    given_rule( iv_matnr    = 'MAT-1'
                iv_submatnr = 'MAT-B'
                iv_prio     = '02' ).
    given_rule( iv_matnr    = 'MAT-1'
                iv_submatnr = 'MAT-A'
                iv_prio     = '01' ).

    DATA(lt_subs) = mo_cut->read_substitutes( 'MAT-1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_subs )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_subs[ 1 ]-submatnr
                                        exp = 'MAT-A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_subs[ 1 ]-priority
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_subs[ 2 ]-submatnr
                                        exp = 'MAT-B' ).
  ENDMETHOD.

  METHOD no_rules_returns_empty.
    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_substitutes( 'MAT-1' ) ).
  ENDMETHOD.

  METHOD sums_own_and_subs.
    given_rule( iv_matnr    = 'MAT-1'
                iv_submatnr = 'MAT-A'
                iv_prio     = '01' ).
    given_rule( iv_matnr    = 'MAT-1'
                iv_submatnr = 'MAT-B'
                iv_prio     = '02' ).
    given_stock( iv_matnr = 'MAT-1' iv_labst = '5' ).
    given_stock( iv_matnr = 'MAT-A' iv_labst = '3' ).
    given_stock( iv_matnr = 'MAT-B' iv_labst = '2' ).

    DATA(ls_avail) = mo_cut->availability( iv_matnr = 'MAT-1'
                                           iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = ls_avail-own_available
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-sub_available
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-total_available
                                        exp = '10' ).
  ENDMETHOD.

  METHOD details_start_with_own.
    given_rule( iv_matnr    = 'MAT-1'
                iv_submatnr = 'MAT-A'
                iv_prio     = '01' ).
    given_stock( iv_matnr = 'MAT-1' iv_labst = '5' ).
    given_stock( iv_matnr = 'MAT-A' iv_labst = '3' ).

    DATA(ls_avail) = mo_cut->availability( iv_matnr = 'MAT-1'
                                           iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_avail-details )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-details[ 1 ]-matnr
                                        exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_avail-details[ 1 ]-available exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-details[ 2 ]-matnr
                                        exp = 'MAT-A' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-requested_matnr
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD ignores_other_material.
    given_rule( iv_matnr    = 'MAT-2'
                iv_submatnr = 'MAT-A'
                iv_prio     = '01' ).
    given_stock( iv_matnr = 'MAT-A' iv_labst = '3' ).

    DATA(ls_avail) = mo_cut->availability( iv_matnr = 'MAT-1'
                                           iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_substitutes( 'MAT-1' ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-sub_available
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-total_available
                                        exp = '0' ).
  ENDMETHOD.

  METHOD safety_stock_reduces_own.
    given_stock( iv_matnr = 'MAT-1' iv_labst = '10' ).
    given_safety_stock( iv_matnr = 'MAT-1'
                        iv_lgort = '0001'
                        iv_qty   = '4' ).

    DATA(ls_avail) = mo_cut->availability( iv_matnr = 'MAT-1'
                                           iv_werks = '1000' ).

    " the safety stock is not available, it is not part of the report
    cl_abap_unit_assert=>assert_equals( act = ls_avail-own_available
                                        exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-total_available
                                        exp = '6' ).
  ENDMETHOD.

  METHOD safety_stock_for_substitute.
    given_rule( iv_matnr    = 'MAT-1'
                iv_submatnr = 'MAT-A'
                iv_prio     = '01' ).
    given_stock( iv_matnr = 'MAT-1' iv_labst = '10' ).
    given_stock( iv_matnr = 'MAT-A' iv_labst = '5' ).
    given_safety_stock( iv_matnr = 'MAT-A'
                        iv_lgort = '0001'
                        iv_qty   = '2' ).

    DATA(ls_avail) = mo_cut->availability( iv_matnr = 'MAT-1'
                                           iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = ls_avail-own_available
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-sub_available
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = ls_avail-total_available
                                        exp = '13' ).
  ENDMETHOD.

ENDCLASS.
