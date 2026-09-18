CLASS ltcl_alloc_idoc_writer DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_idoc_writer.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_matnr      TYPE matnr
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_idoc_writer=>ty_input.

    METHODS creates_segments FOR TESTING.
    METHODS rejects_matnr    FOR TESTING.
    METHODS rejects_qty      FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_idoc_writer IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_idoc_writer( ).
  ENDMETHOD.

  METHOD input.
    rs_row-idoc_type = 'ZALLOC'.
    rs_row-message_type = 'ZALLOC_RUN'.
    rs_row-matnr = iv_matnr.
    rs_row-quantity = iv_quantity.
  ENDMETHOD.

  METHOD creates_segments.
    DATA(rs_result) = mo_cut->create( input( iv_matnr    = 'MAT-1'
                                             iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-segments )
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-segments[ 1 ]
                                        exp = 'EDI_DC40' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-segments[ 2 ]
                                        exp = 'E1EDP19:MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-idoc_number
                                        exp = '0000000000000001' ).
  ENDMETHOD.

  METHOD rejects_matnr.
    DATA(rs_result) = mo_cut->create( input( iv_matnr    = ''
                                             iv_quantity = '5' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( rs_result-segments )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-segments[ 1 ]
                                        exp = 'IDoc not created' ).
  ENDMETHOD.

  METHOD rejects_qty.
    DATA(rs_result) = mo_cut->create( input( iv_matnr    = 'MAT-1'
                                             iv_quantity = '0' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-idoc_number
                                        exp = '' ).
  ENDMETHOD.

ENDCLASS.
