CLASS ltcl_alloc_bapi_plant DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bapi_plant.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_werks      TYPE werks_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bapi_plant=>ty_input.

    METHODS reads_known   FOR TESTING.
    METHODS rejects_empty FOR TESTING.
    METHODS returns_country FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bapi_plant IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bapi_plant( ).
  ENDMETHOD.

  METHOD input.
    rs_row-werks = iv_werks.
  ENDMETHOD.

  METHOD reads_known.
    DATA(rs_result) = mo_cut->read( input( iv_werks = '1000' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-found
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-werks
                                        exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-name
                                        exp = 'Allocation plant' ).
  ENDMETHOD.

  METHOD rejects_empty.
    DATA(rs_result) = mo_cut->read( input( iv_werks = '' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-found
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD returns_country.
    DATA(rs_result) = mo_cut->read( input( iv_werks = '1000' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-country
                                        exp = 'DE' ).
  ENDMETHOD.

ENDCLASS.
