CLASS ltcl_alloc_gtin_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gtin_build.

    METHODS setup.

    METHODS pads_body      FOR TESTING.
    METHODS keeps_longer   FOR TESTING.
    METHODS builds_gtin    FOR TESTING.
    METHODS pads_then_build FOR TESTING.
    METHODS bad_length     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gtin_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gtin_build( ).
  ENDMETHOD.

  METHOD pads_body.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pad_body( iv_body = '12345' iv_length = 8 )
      exp = '00012345' ).
  ENDMETHOD.

  METHOD keeps_longer.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pad_body( iv_body = '123456789' iv_length = 4 )
      exp = '123456789' ).
  ENDMETHOD.

  METHOD builds_gtin.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_body = '590123412345' iv_length = 13 )
      exp = '5901234123457' ).
  ENDMETHOD.

  METHOD pads_then_build.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_body = '12345' iv_length = 13 )
      exp = '0000000123457' ).
  ENDMETHOD.

  METHOD bad_length.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_body = '12345' iv_length = 1 )
      exp = '' ).
  ENDMETHOD.

ENDCLASS.
