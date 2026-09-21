CLASS ltcl_stock_json DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS escapes_json_string FOR TESTING.
    METHODS escapes_control_chars FOR TESTING.
    METHODS escapes_all_json_control_chars FOR TESTING.
    METHODS escapes_property_names FOR TESTING.
    METHODS preserves_long_property_values FOR TESTING.
    METHODS formats_property FOR TESTING.
    METHODS formats_number_property FOR TESTING.
    METHODS formats_filter_number_property FOR TESTING.
    METHODS formats_decimal_number FOR TESTING.
    METHODS formats_negative_number FOR TESTING.
    METHODS formats_boolean_property FOR TESTING.
    METHODS formats_null_property FOR TESTING.
    METHODS formats_string_array_property FOR TESTING.
    METHODS formats_object_property FOR TESTING.
    METHODS formats_error_envelope FOR TESTING.
    METHODS formats_schema_error_envelope FOR TESTING.
    METHODS formats_schema_runid_error FOR TESTING.
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
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>quote(
        |ORDER{ cl_abap_char_utilities=>cr_lf }42| )
      exp = '"ORDER\n42"' ).
  ENDMETHOD.

  METHOD escapes_all_json_control_chars.
    DATA lv_value TYPE string.
    DATA lv_expected TYPE string.
    DATA lv_control_pair TYPE cl_abap_conv_in_ce=>ty_char2.
    DATA lv_control TYPE c LENGTH 1.
    DATA lv_code TYPE i.

    DO 32 TIMES.
      lv_code = sy-index - 1.
      lv_control_pair = cl_abap_conv_in_ce=>uccpi( lv_code ).
      lv_control = lv_control_pair(1).
      CONCATENATE lv_value lv_control INTO lv_value.
    ENDDO.
    CONCATENATE
      '\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\b\t\n\u000b\f\r\u000e\u000f'
      '\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f'
      INTO lv_expected.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>quote( lv_value )
      exp = |"{ lv_expected }"| ).
  ENDMETHOD.

  METHOD escapes_property_names.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>property(
        iv_name  = 'bad"name'
        iv_value = 'value' )
      exp = '"bad\"name":"value"' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>number_property(
        iv_name  = 'bad"name'
        iv_value = 12 )
      exp = '"bad\"name":12' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>boolean_property(
        iv_name  = 'bad"name'
        iv_value = abap_true )
      exp = '"bad\"name":true' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>null_property( 'bad"name' )
      exp = '"bad\"name":null' ).
  ENDMETHOD.

  METHOD preserves_long_property_values.
    DATA lv_value TYPE string.
    DATA lv_expected TYPE string.
    DATA lv_fixed_value TYPE c LENGTH 1500.

    DO 1200 TIMES.
      CONCATENATE lv_value 'x' INTO lv_value.
    ENDDO.
    lv_fixed_value = lv_value.
    CONCATENATE '"message":"' lv_value '"' INTO lv_expected.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>property(
        iv_name  = 'message'
        iv_value = lv_value )
      exp = lv_expected ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>property(
        iv_name  = 'message'
        iv_value = lv_fixed_value )
      exp = lv_expected ).
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

  METHOD formats_filter_number_property.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage'
        iv_value   = 12
        iv_text    = '12'
        iv_present = abap_true
        iv_typed   = abap_true )
      exp = '"minimum_shortage":12' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage'
        iv_value   = 12
        iv_text    = 'n/a'
        iv_present = abap_false
        iv_typed   = abap_true )
      exp = '"minimum_shortage":null' ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage'
        iv_value   = 12
        iv_text    = 'n/a'
        iv_present = abap_false
        iv_typed   = abap_false )
      exp = '"minimum_shortage":"n/a"' ).
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

    APPEND 'material' TO lt_values.
    APPEND 'message "locked"' TO lt_values.
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

  METHOD formats_object_property.
    DATA lt_fields TYPE zcl_stock_json=>tt_strings.

    APPEND zcl_stock_json=>number_property(
      iv_name  = 'minimum_shortage'
      iv_value = 12 ) TO lt_fields.
    APPEND zcl_stock_json=>null_property(
      iv_name = 'maximum_shortage' ) TO lt_fields.

    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_fields )
      exp = '"filter_values":{"minimum_shortage":12,"maximum_shortage":null}' ).
  ENDMETHOD.

  METHOD formats_error_envelope.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error( 'Retention failed: "locked"' )
      exp = '{"mode":"error","message":"Retention failed: \"locked\""}' ).
  ENDMETHOD.

  METHOD formats_schema_error_envelope.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error_with_schema(
        iv_message = 'Stock read failed: "locked"'
        iv_schema  = 1 )
      exp = '{"mode":"error","schema_version":1,"message":"Stock read failed: \"locked\""}' ).
  ENDMETHOD.

  METHOD formats_schema_runid_error.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error_with_schema_run_id(
        iv_message = 'Allocation failed: "locked"'
        iv_schema  = 34
        iv_run_id  = 'RUN-1' )
      exp = '{"mode":"error","schema_version":34,"message":"Allocation failed: \"locked\"","run_id":"RUN-1"}' ).
  ENDMETHOD.

  METHOD formats_correlated_error.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_json=>error_with_run_id(
        iv_message = 'Allocation failed'
        iv_run_id  = 'RUN-123' )
      exp = '{"mode":"error","message":"Allocation failed","run_id":"RUN-123"}' ).
  ENDMETHOD.
ENDCLASS.
