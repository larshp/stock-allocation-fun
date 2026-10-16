CLASS ltcl_alloc_bapi_mat DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bapi_mat.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_matnr      TYPE matnr
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_bapi_mat=>ty_input.

    METHODS reads_known      FOR TESTING.
    METHODS rejects_empty    FOR TESTING.
    METHODS returns_base_unit FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_bapi_mat IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bapi_mat( ).
  ENDMETHOD.

  METHOD input.
    rs_row-matnr = iv_matnr.
  ENDMETHOD.

  METHOD reads_known.
    DATA(rs_result) = mo_cut->read( input( iv_matnr = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-found
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-matnr
                                        exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-description
                                        exp = 'Allocation material' ).
  ENDMETHOD.

  METHOD rejects_empty.
    DATA(rs_result) = mo_cut->read( input( iv_matnr = '' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-found
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD returns_base_unit.
    DATA(rs_result) = mo_cut->read( input( iv_matnr = 'MAT-1' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-base_unit
                                        exp = 'ST' ).
  ENDMETHOD.

ENDCLASS.
