CLASS ltcl_alloc_enqueue DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_enqueue.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_object     TYPE c
        iv_key        TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_enqueue=>ty_input.

    METHODS accepts   FOR TESTING.
    METHODS no_object FOR TESTING.
    METHODS no_key    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_enqueue IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_enqueue( ).
  ENDMETHOD.

  METHOD input.
    rs_row-object = iv_object.
    rs_row-key = iv_key.
  ENDMETHOD.

  METHOD accepts.
    DATA(rs_result) = mo_cut->enqueue( input( iv_object = 'ZSTOCKRUN'
                                              iv_key    = 'R1' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-accepted
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Locked' ).
  ENDMETHOD.

  METHOD no_object.
    DATA(rs_result) = mo_cut->enqueue( input( iv_object = ''
                                              iv_key    = 'R1' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-accepted
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD no_key.
    DATA(rs_result) = mo_cut->enqueue( input( iv_object = 'ZSTOCKRUN'
                                              iv_key    = '' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Key is empty' ).
  ENDMETHOD.

ENDCLASS.
