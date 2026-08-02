CLASS ltcl_stock_csv DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS quotes_delimiter_values FOR TESTING.
    METHODS escapes_embedded_quotes FOR TESTING.
    METHODS preserves_line_breaks FOR TESTING.
    METHODS formats_decimal_number FOR TESTING.
    METHODS formats_negative_number FOR TESTING.
    METHODS quotes_typed_text FOR TESTING.
    METHODS formats_error_row FOR TESTING.
    METHODS formats_correlated_error FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_csv IMPLEMENTATION.
  METHOD quotes_delimiter_values.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>quote( 'ORDER;42' )
      exp = '"ORDER;42"' ).
  ENDMETHOD.

  METHOD escapes_embedded_quotes.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>quote( 'ORDER "SPECIAL"' )
      exp = '"ORDER ""SPECIAL"""' ).
  ENDMETHOD.

  METHOD preserves_line_breaks.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>quote( |ORDER{ cl_abap_char_utilities=>newline }42| )
      exp = |"ORDER{ cl_abap_char_utilities=>newline }42"| ).
  ENDMETHOD.

  METHOD formats_decimal_number.
    DATA lv_quantity TYPE p LENGTH 8 DECIMALS 2.

    lv_quantity = '1234.50'.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>number( lv_quantity )
      exp = '1234.50' ).
  ENDMETHOD.

  METHOD formats_negative_number.
    DATA lv_quantity TYPE p LENGTH 8 DECIMALS 2.

    lv_quantity = '-12.50'.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>number( lv_quantity )
      exp = '-12.50' ).
  ENDMETHOD.

  METHOD quotes_typed_text.
    DATA lv_material TYPE c LENGTH 6.

    lv_material = 'MAT-01'.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>quote( lv_material )
      exp = '"MAT-01"' ).
  ENDMETHOD.

  METHOD formats_error_row.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>error(
        iv_mode    = 'zstock_allocate'
        iv_message = 'Allocation failed: "locked"; retry' )
      exp = '"zstock_allocate";"error";"Allocation failed: ""locked""; retry"' ).
  ENDMETHOD.

  METHOD formats_correlated_error.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_csv=>error_with_run_id(
        iv_mode    = 'zstock_allocate'
        iv_message = 'Allocation failed'
        iv_run_id  = 'RUN-123' )
      exp = '"zstock_allocate";"error";"Allocation failed";"RUN-123"' ).
  ENDMETHOD.
ENDCLASS.
