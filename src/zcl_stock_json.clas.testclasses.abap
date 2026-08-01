CLASS ltcl_stock_json DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS escapes_json_string FOR TESTING.
    METHODS escapes_control_chars FOR TESTING.
    METHODS formats_property FOR TESTING.
    METHODS formats_error_envelope FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_json IMPLEMENTATION.
  METHOD escapes_json_string.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>quote( 'ORDER "SPECIAL"' )
      exp = '"ORDER \"SPECIAL\""' ).
  ENDMETHOD.

  METHOD escapes_control_chars.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>quote(
        |ORDER{ cl_abap_char_utilities=>newline }42| )
      exp = '"ORDER\n42"' ).
  ENDMETHOD.

  METHOD formats_property.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>property(
        iv_name  = 'allocated'
        iv_value = 12 )
      exp = '"allocated":"12"' ).
  ENDMETHOD.

  METHOD formats_error_envelope.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error( 'Retention failed: "locked"' )
      exp = '{"mode":"error","message":"Retention failed: \"locked\""}' ).
  ENDMETHOD.
ENDCLASS.
