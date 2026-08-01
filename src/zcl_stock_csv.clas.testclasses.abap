CLASS ltcl_stock_csv DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS quotes_delimiter_values FOR TESTING.
    METHODS escapes_embedded_quotes FOR TESTING.
    METHODS preserves_line_breaks FOR TESTING.
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
ENDCLASS.
