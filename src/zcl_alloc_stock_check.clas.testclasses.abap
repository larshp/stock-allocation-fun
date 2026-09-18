CLASS ltcl_alloc_stock_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stock_check.

    METHODS setup.

    METHODS stock
      IMPORTING
        iv_matnr        TYPE matnr
        iv_werks        TYPE werks_d
        iv_lgort        TYPE lgort_d
        iv_unrestricted TYPE menge_d
      RETURNING
        VALUE(rs_row)   TYPE zif_stock_reader=>ty_stock.

    METHODS valid_stock       FOR TESTING.
    METHODS empty_list        FOR TESTING.
    METHODS empty_material    FOR TESTING.
    METHODS empty_location    FOR TESTING.
    METHODS negative_stock    FOR TESTING.
    METHODS multiple_issues   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_stock_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stock_check( ).
  ENDMETHOD.

  METHOD stock.
    rs_row-matnr = iv_matnr.
    rs_row-werks = iv_werks.
    rs_row-lgort = iv_lgort.
    rs_row-unrestricted_qty = iv_unrestricted.
  ENDMETHOD.

  METHOD valid_stock.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.

    APPEND stock( iv_matnr        = 'MAT-1'
                  iv_werks        = '1000'
                  iv_lgort        = '0001'
                  iv_unrestricted = '10' ) TO lt_stock.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->check( lt_stock ) ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.

    cl_abap_unit_assert=>assert_initial( act = mo_cut->check( lt_stock ) ).
  ENDMETHOD.

  METHOD empty_material.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.

    APPEND stock( iv_matnr        = ''
                  iv_werks        = '1000'
                  iv_lgort        = '0001'
                  iv_unrestricted = '10' ) TO lt_stock.

    DATA(lt_issues) = mo_cut->check( lt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-matnr exp = '' ).
  ENDMETHOD.

  METHOD empty_location.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.

    APPEND stock( iv_matnr        = 'MAT-1'
                  iv_werks        = '1000'
                  iv_lgort        = ''
                  iv_unrestricted = '10' ) TO lt_stock.

    DATA(lt_issues) = mo_cut->check( lt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-lgort exp = '' ).
  ENDMETHOD.

  METHOD negative_stock.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.

    APPEND stock( iv_matnr        = 'MAT-1'
                  iv_werks        = '1000'
                  iv_lgort        = '0001'
                  iv_unrestricted = '-1' ) TO lt_stock.

    DATA(lt_issues) = mo_cut->check( lt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_issues[ 1 ]-message
                                        exp = 'Unrestricted quantity is negative' ).
  ENDMETHOD.

  METHOD multiple_issues.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.

    APPEND stock( iv_matnr        = ''
                  iv_werks        = ''
                  iv_lgort        = ''
                  iv_unrestricted = '-1' ) TO lt_stock.

    DATA(lt_issues) = mo_cut->check( lt_stock ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_issues ) exp = 4 ).
  ENDMETHOD.

ENDCLASS.
