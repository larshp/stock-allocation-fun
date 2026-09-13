CLASS ltcl_alloc_rfc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rfc.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_destination TYPE c
        iv_function    TYPE c
      RETURNING
        VALUE(rs_row)  TYPE zcl_alloc_rfc=>ty_input.

    METHODS connects         FOR TESTING.
    METHODS rejects_empty    FOR TESTING.
    METHODS describes_target FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_rfc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rfc( ).
  ENDMETHOD.

  METHOD input.
    rs_row-destination = iv_destination.
    rs_row-function = iv_function.
  ENDMETHOD.

  METHOD connects.
    DATA(rs_result) = mo_cut->ping( input( iv_destination = 'SAP_ERP'
                                           iv_function    = 'Z_ALLOC_RUN' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-connected
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-message
                                        exp = 'Connected' ).
  ENDMETHOD.

  METHOD rejects_empty.
    DATA(rs_result) = mo_cut->ping( input( iv_destination = ''
                                           iv_function    = 'Z_ALLOC_RUN' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-connected
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD describes_target.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->describe( input( iv_destination = 'SAP_ERP'
                                     iv_function    = 'Z_ALLOC_RUN' ) )
      exp = 'SAP_ERP:Z_ALLOC_RUN' ).
  ENDMETHOD.

ENDCLASS.
