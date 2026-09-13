CLASS ltcl_alloc_bapi_gm DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bapi_gm.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_matnr      TYPE matnr
        iv_werks      TYPE werks_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bapi_gm=>ty_input.

    METHODS posts_document FOR TESTING.
    METHODS rejects_matnr  FOR TESTING.
    METHODS rejects_werks  FOR TESTING.
    METHODS rejects_qty    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bapi_gm IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bapi_gm( ).
  ENDMETHOD.

  METHOD input.
    rs_row-matnr = iv_matnr.
    rs_row-werks = iv_werks.
    rs_row-lgort = '0001'.
    rs_row-quantity = iv_quantity.
    rs_row-move_type = '311'.
  ENDMETHOD.

  METHOD posts_document.
    DATA(rs_result) = mo_cut->post( input( iv_matnr    = 'MAT-1'
                                           iv_werks    = '1000'
                                           iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-executed
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-doc_number
                                        exp = '4900000001' ).
  ENDMETHOD.

  METHOD rejects_matnr.
    DATA(rs_result) = mo_cut->post( input( iv_matnr    = ''
                                           iv_werks    = '1000'
                                           iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-executed
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-messages[ 1 ]
                                        exp = 'Material is missing' ).
  ENDMETHOD.

  METHOD rejects_werks.
    DATA(rs_result) = mo_cut->post( input( iv_matnr    = 'MAT-1'
                                           iv_werks    = ''
                                           iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-messages[ 1 ]
                                        exp = 'Plant is missing' ).
  ENDMETHOD.

  METHOD rejects_qty.
    DATA(rs_result) = mo_cut->post( input( iv_matnr    = 'MAT-1'
                                           iv_werks    = '1000'
                                           iv_quantity = '0' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-messages[ 1 ]
                                        exp = 'Quantity must be positive' ).
  ENDMETHOD.

ENDCLASS.
