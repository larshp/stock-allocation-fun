CLASS ltcl_uom_converter DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_marm_tt TYPE STANDARD TABLE OF marm WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zif_uom_converter.

    METHODS setup.
    METHODS teardown.

    METHODS given_uom
      IMPORTING
        iv_meinh TYPE marm-meinh
        iv_umrez TYPE marm-umrez
        iv_umren TYPE marm-umren
        iv_matnr TYPE matnr DEFAULT 'MAT-1'.

    METHODS converts_to_base          FOR TESTING.
    METHODS keeps_qty_without_uom     FOR TESTING.
    METHODS keeps_qty_for_base_uom    FOR TESTING.
    METHODS keeps_qty_denom_zero      FOR TESTING.
    METHODS supports_fractional_ratio FOR TESTING.
    METHODS ignores_other_material    FOR TESTING.
ENDCLASS.


CLASS ltcl_uom_converter IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARM' ) ) ).
    mo_cut = NEW zcl_uom_converter( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_uom.
    DATA ls_marm TYPE marm.

    ls_marm-mandt = sy-mandt.
    ls_marm-matnr = iv_matnr.
    ls_marm-meinh = iv_meinh.
    ls_marm-umrez = iv_umrez.
    ls_marm-umren = iv_umren.

    mo_environment->insert_test_data( VALUE ty_marm_tt( ( ls_marm ) ) ).
  ENDMETHOD.

  METHOD converts_to_base.
    given_uom( iv_meinh = 'CS'
               iv_umrez = 12
               iv_umren = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base_qty( iv_matnr = 'MAT-1'
                                 iv_meinh = 'CS'
                                 iv_qty   = '4' )
      exp = '48' ).
  ENDMETHOD.

  METHOD keeps_qty_without_uom.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base_qty( iv_matnr = 'MAT-1'
                                 iv_meinh = 'CS'
                                 iv_qty   = '4' )
      exp = '4' ).
  ENDMETHOD.

  METHOD keeps_qty_for_base_uom.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base_qty( iv_matnr = 'MAT-1'
                                 iv_meinh = ''
                                 iv_qty   = '5' )
      exp = '5' ).
  ENDMETHOD.

  METHOD keeps_qty_denom_zero.
    given_uom( iv_meinh = 'CS'
               iv_umrez = 12
               iv_umren = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base_qty( iv_matnr = 'MAT-1'
                                 iv_meinh = 'CS'
                                 iv_qty   = '4' )
      exp = '4' ).
  ENDMETHOD.

  METHOD supports_fractional_ratio.
    given_uom( iv_meinh = 'CS'
               iv_umrez = 3
               iv_umren = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base_qty( iv_matnr = 'MAT-1'
                                 iv_meinh = 'CS'
                                 iv_qty   = '5' )
      exp = '7.5' ).
  ENDMETHOD.

  METHOD ignores_other_material.
    given_uom( iv_meinh = 'CS'
               iv_umrez = 12
               iv_umren = 1
               iv_matnr = 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_base_qty( iv_matnr = 'MAT-1'
                                 iv_meinh = 'CS'
                                 iv_qty   = '4' )
      exp = '4' ).
  ENDMETHOD.

ENDCLASS.
