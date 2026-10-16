CLASS ltcl_alloc_ean_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_ean_check.

    METHODS setup.

    METHODS check_digit_read FOR TESTING.
    METHODS valid_code       FOR TESTING.
    METHODS invalid_code     FOR TESTING.
    METHODS completes_code   FOR TESTING.
    METHODS empty_code       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_ean_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_ean_check( ).
  ENDMETHOD.

  METHOD check_digit_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->check_digit( iv_code = '590123412345' ) exp = 7 ).
  ENDMETHOD.

  METHOD valid_code.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_code = '5901234123457' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD invalid_code.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_code = '5901234123450' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD completes_code.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->complete( iv_code = '590123412345' )
      exp = '5901234123457' ).
  ENDMETHOD.

  METHOD empty_code.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->check_digit( iv_code = '' ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_code = '' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
