CLASS ltcl_alloc_bapi_atp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bapi_atp.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_quantity   TYPE menge_d
        iv_stock      TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bapi_atp=>ty_input.

    METHODS covers_request FOR TESTING.
    METHODS exact_match    FOR TESTING.
    METHODS partial        FOR TESTING.
    METHODS no_stock       FOR TESTING.
    METHODS zero_request   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bapi_atp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bapi_atp( ).
  ENDMETHOD.

  METHOD input.
    rs_row-matnr = 'MAT-1'.
    rs_row-werks = '1000'.
    rs_row-quantity = iv_quantity.
    rs_row-stock = iv_stock.
  ENDMETHOD.

  METHOD covers_request.
    DATA(rs_result) = mo_cut->check( input( iv_quantity = '5'
                                            iv_stock    = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-available
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-confirmed
                                        exp = '5' ).
  ENDMETHOD.

  METHOD exact_match.
    DATA(rs_result) = mo_cut->check( input( iv_quantity = '10'
                                            iv_stock    = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-available
                                        exp = abap_true ).
  ENDMETHOD.

  METHOD partial.
    DATA(rs_result) = mo_cut->check( input( iv_quantity = '10'
                                            iv_stock    = '4' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-available
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-confirmed
                                        exp = '4' ).
  ENDMETHOD.

  METHOD no_stock.
    DATA(rs_result) = mo_cut->check( input( iv_quantity = '10'
                                            iv_stock    = '0' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-confirmed
                                        exp = '0' ).
  ENDMETHOD.

  METHOD zero_request.
    DATA(rs_result) = mo_cut->check( input( iv_quantity = '0'
                                            iv_stock    = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-available
                                        exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
