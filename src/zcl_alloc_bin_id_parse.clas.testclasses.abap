CLASS ltcl_alloc_bin_id_parse DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_id_parse.

    METHODS setup.

    METHODS valid_three    FOR TESTING.
    METHODS invalid_count  FOR TESTING.
    METHODS zero_expected  FOR TESTING.
    METHODS parse_parts    FOR TESTING.
    METHODS parse_invalid  FOR TESTING.
    METHODS counts_parts   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_id_parse IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_id_parse( ).
  ENDMETHOD.

  METHOD valid_three.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_bin_id = 'A-01-03' iv_expected_parts = 3 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD invalid_count.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_bin_id = 'A-01' iv_expected_parts = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD zero_expected.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_bin_id = 'A-01' iv_expected_parts = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD parse_parts.
    DATA ls_res TYPE zcl_alloc_bin_id_parse=>ty_result.

    ls_res = mo_cut->parse( iv_bin_id         = 'A-01-03'
                            iv_expected_parts = 3 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-valid exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_res-parts ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-parts[ 2 ] exp = '01' ).
  ENDMETHOD.

  METHOD parse_invalid.
    DATA ls_res TYPE zcl_alloc_bin_id_parse=>ty_result.

    ls_res = mo_cut->parse( iv_bin_id         = 'A-01-03'
                            iv_expected_parts = 4 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-valid exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_res-parts ) exp = 3 ).
  ENDMETHOD.

  METHOD counts_parts.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->segment_count( 'A-01-03-04' ) exp = 4 ).
  ENDMETHOD.

ENDCLASS.
