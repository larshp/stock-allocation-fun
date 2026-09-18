CLASS ltcl_alloc_format_default DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_format_default.

    METHODS setup.

    METHODS alv_is_csv      FOR TESTING.
    METHODS email_is_html   FOR TESTING.
    METHODS api_is_json     FOR TESTING.
    METHODS print_is_fw     FOR TESTING.
    METHODS unknown_is_csv  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_format_default IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_format_default( ).
  ENDMETHOD.

  METHOD alv_is_csv.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->default_for( 'ALV' ) exp = 'CSV' ).
  ENDMETHOD.

  METHOD email_is_html.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->default_for( 'EMAIL' ) exp = 'HTML' ).
  ENDMETHOD.

  METHOD api_is_json.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->default_for( 'API' ) exp = 'JSON' ).
  ENDMETHOD.

  METHOD print_is_fw.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->default_for( 'PRINT' ) exp = 'FW' ).
  ENDMETHOD.

  METHOD unknown_is_csv.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->default_for( 'WHATEVER' ) exp = 'CSV' ).
  ENDMETHOD.

ENDCLASS.
