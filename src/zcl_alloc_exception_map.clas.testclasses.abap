CLASS ltcl_alloc_exception_map DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_exception_map.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_class      TYPE c
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_exception_map=>ty_input.

    METHODS system_is_retryable FOR TESTING.
    METHODS abap_is_terminal    FOR TESTING.
    METHODS unknown_is_client   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_exception_map IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_exception_map( ).
  ENDMETHOD.

  METHOD input.
    rs_row-class = iv_class.
    rs_row-code = '001'.
  ENDMETHOD.

  METHOD system_is_retryable.
    DATA(rs_result) = mo_cut->map(
      input( iv_class = 'CX_SY_OPEN_SQL_DB' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-category
                                        exp = 'SYSTEM' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-retryable
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-http_status
                                        exp = 500 ).
  ENDMETHOD.

  METHOD abap_is_terminal.
    DATA(rs_result) = mo_cut->map(
      input( iv_class = 'CX_ABAP_CONV_ERROR' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-category
                                        exp = 'ABAP' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-retryable
                                        exp = abap_false ).
  ENDMETHOD.

  METHOD unknown_is_client.
    DATA(rs_result) = mo_cut->map(
      input( iv_class = 'ZCX_ALLOC_CUSTOM' ) ).

    cl_abap_unit_assert=>assert_equals( act = rs_result-category
                                        exp = 'UNKNOWN' ).
    cl_abap_unit_assert=>assert_equals( act = rs_result-http_status
                                        exp = 400 ).
  ENDMETHOD.

ENDCLASS.
