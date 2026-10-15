CLASS ltcl_alloc_sscc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    CONSTANTS c_sscc TYPE string VALUE '003401234500000017'.

    DATA mo_cut TYPE REF TO zcl_alloc_sscc.

    METHODS setup.

    METHODS builds_from_body FOR TESTING.
    METHODS pads_short_body FOR TESTING.
    METHODS strips_check    FOR TESTING.
    METHODS valid_sscc      FOR TESTING.
    METHODS invalid_sscc    FOR TESTING.
    METHODS bad_length      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sscc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sscc( ).
  ENDMETHOD.

  METHOD builds_from_body.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_body = '00340123450000001' iv_length = 18 )
      exp = c_sscc ).
  ENDMETHOD.

  METHOD pads_short_body.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_body = '340123450000001' iv_length = 18 )
      exp = c_sscc ).
  ENDMETHOD.

  METHOD strips_check.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->body( c_sscc )
      exp = '00340123450000001' ).
  ENDMETHOD.

  METHOD valid_sscc.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( c_sscc ) exp = abap_true ).
  ENDMETHOD.

  METHOD invalid_sscc.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( '003401234500000019' ) exp = abap_false ).
  ENDMETHOD.

  METHOD bad_length.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( iv_body = '123' iv_length = 1 ) exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->body( '1' ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
