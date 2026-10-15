CLASS ltcl_alloc_code128_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_code128_check.
    DATA mt_val TYPE zcl_alloc_code128_check=>ty_int_tt.

    METHODS setup.

    METHODS checksum_read  FOR TESTING.
    METHODS start_only     FOR TESTING.
    METHODS empty_values   FOR TESTING.
    METHODS matches        FOR TESTING.
    METHODS mismatches     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_code128_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_code128_check( ).
  ENDMETHOD.

  METHOD checksum_read.
    APPEND 33 TO mt_val.
    APPEND 34 TO mt_val.

    " 104 + 33 * 1 + 34 * 2 = 205, and 205 MOD 103 = 102.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->checksum( iv_start = 104 it_values = mt_val )
      exp = 102 ).
  ENDMETHOD.

  METHOD start_only.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->checksum( iv_start = 104 it_values = mt_val )
      exp = 1 ).
  ENDMETHOD.

  METHOD empty_values.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->checksum( iv_start = 0 it_values = mt_val ) exp = 0 ).
  ENDMETHOD.

  METHOD matches.
    APPEND 33 TO mt_val.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_start = 104 it_values = mt_val
                              iv_expected = 34 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD mismatches.
    APPEND 33 TO mt_val.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( iv_start = 104 it_values = mt_val
                              iv_expected = 33 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
