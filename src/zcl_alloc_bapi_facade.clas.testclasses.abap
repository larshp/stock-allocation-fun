CLASS ltcl_alloc_bapi_facade DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bapi_facade.

    METHODS setup.

    METHODS call
      IMPORTING
        iv_name       TYPE c
        iv_matnr      TYPE matnr
        iv_werks      TYPE werks_d
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bapi_facade=>ty_call.

    METHODS goods_movement FOR TESTING.
    METHODS availability   FOR TESTING.
    METHODS unknown_bapi   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bapi_facade IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bapi_facade( ).
  ENDMETHOD.

  METHOD call.
    rs_row-name = iv_name.
    rs_row-matnr = iv_matnr.
    rs_row-werks = iv_werks.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD goods_movement.
    DATA(rs_result) = mo_cut->call( call( iv_name     = 'GOODS_MOVEMENT'
                                          iv_matnr    = 'MAT-1'
                                          iv_werks    = '1000'
                                          iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-success
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = '4900000001' ).
  ENDMETHOD.

  METHOD availability.
    DATA(rs_result) = mo_cut->call( call( iv_name     = 'AVAILABILITY'
                                          iv_matnr    = 'MAT-1'
                                          iv_werks    = '1000'
                                          iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-success
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Available' ).
  ENDMETHOD.

  METHOD unknown_bapi.
    DATA(rs_result) = mo_cut->call( call( iv_name     = 'NOPE'
                                          iv_matnr    = 'MAT-1'
                                          iv_werks    = '1000'
                                          iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-success
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Unknown BAPI' ).
  ENDMETHOD.

ENDCLASS.
