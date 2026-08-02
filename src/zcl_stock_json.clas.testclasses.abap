CLASS ltcl_stock_json DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS escapes_json_string FOR TESTING.
    METHODS escapes_control_chars FOR TESTING.
    METHODS formats_property FOR TESTING.
    METHODS formats_number_property FOR TESTING.
    METHODS formats_decimal_number FOR TESTING.
    METHODS formats_negative_number FOR TESTING.
    METHODS formats_boolean_property FOR TESTING.
    METHODS formats_null_property FOR TESTING.
    METHODS formats_string_array_property FOR TESTING.
    METHODS formats_error_envelope FOR TESTING.
    METHODS formats_correlated_error FOR TESTING.
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

  METHOD formats_number_property.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>number_property(
        iv_name  = 'row_count'
        iv_value = 12 )
      exp = '"row_count":12' ).
  ENDMETHOD.

  METHOD formats_decimal_number.
    DATA lv_quantity TYPE p LENGTH 8 DECIMALS 2.

    lv_quantity = '1234.50'.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>number_property(
        iv_name  = 'allocated'
        iv_value = lv_quantity )
      exp = '"allocated":1234.50' ).
  ENDMETHOD.

  METHOD formats_negative_number.
    DATA lv_quantity TYPE p LENGTH 8 DECIMALS 2.

    lv_quantity = '-12.50'.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>number_property(
        iv_name  = 'shortage'
        iv_value = lv_quantity )
      exp = '"shortage":-12.50' ).
  ENDMETHOD.

  METHOD formats_boolean_property.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>boolean_property(
        iv_name  = 'has_more'
        iv_value = abap_true )
      exp = '"has_more":true' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>boolean_property(
        iv_name  = 'has_more'
        iv_value = abap_false )
      exp = '"has_more":false' ).
  ENDMETHOD.

  METHOD formats_null_property.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>null_property( 'coverage_pct' )
      exp = '"coverage_pct":null' ).
  ENDMETHOD.

  METHOD formats_string_array_property.
    DATA lt_values TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    lt_values = VALUE #( ( 'material' ) ( 'message "locked"' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>string_array_property(
        iv_name   = 'filters'
        it_values = lt_values )
      exp = '"filters":["material","message \"locked\""]' ).
    CLEAR lt_values.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>string_array_property(
        iv_name   = 'filters'
        it_values = lt_values )
      exp = '"filters":[]' ).
  ENDMETHOD.

  METHOD formats_error_envelope.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error( 'Retention failed: "locked"' )
      exp = '{"mode":"error","message":"Retention failed: \"locked\""}' ).
  ENDMETHOD.

  METHOD formats_correlated_error.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error_with_run_id(
        iv_message = 'Allocation failed'
        iv_run_id  = 'RUN-123' )
      exp = '{"mode":"error","message":"Allocation failed","run_id":"RUN-123"}' ).
  ENDMETHOD.
ENDCLASS.
