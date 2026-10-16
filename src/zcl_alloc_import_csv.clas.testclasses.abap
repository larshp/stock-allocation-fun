CLASS ltcl_alloc_import_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_import_csv.

    METHODS setup.

    METHODS splits_plain        FOR TESTING.
    METHODS keeps_quoted_sep    FOR TESTING.
    METHODS unescapes_quotes    FOR TESTING.
    METHODS empty_line_one_field FOR TESTING.
    METHODS counts_fields       FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_import_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_import_csv( ).
  ENDMETHOD.

  METHOD splits_plain.
    DATA lt_fields TYPE zcl_alloc_import_csv=>ty_fields_tt.

    lt_fields = mo_cut->parse_line( 'A;B;C' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fields ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 3 ] exp = 'C' ).
  ENDMETHOD.

  METHOD keeps_quoted_sep.
    DATA lt_fields TYPE zcl_alloc_import_csv=>ty_fields_tt.

    lt_fields = mo_cut->parse_line( 'A;"B;C";D' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fields ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 2 ] exp = 'B;C' ).
  ENDMETHOD.

  METHOD unescapes_quotes.
    DATA lt_fields TYPE zcl_alloc_import_csv=>ty_fields_tt.

    lt_fields = mo_cut->parse_line( '"say ""hi""";X' ).

    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 1 ] exp = 'say "hi"' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 2 ] exp = 'X' ).
  ENDMETHOD.

  METHOD empty_line_one_field.
    DATA lt_fields TYPE zcl_alloc_import_csv=>ty_fields_tt.

    lt_fields = mo_cut->parse_line( '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fields ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 1 ] exp = '' ).
  ENDMETHOD.

  METHOD counts_fields.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count_of( 'A;;C' ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
