CLASS ltcl_alloc_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_csv.

    METHODS setup.

    METHODS plain_field_unchanged  FOR TESTING.
    METHODS separator_is_quoted    FOR TESTING.
    METHODS quote_is_doubled       FOR TESTING.
    METHODS comma_is_quoted        FOR TESTING.
    METHODS line_joins_fields      FOR TESTING.
    METHODS custom_separator       FOR TESTING.
    METHODS empty_list_empty_line  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD plain_field_unchanged.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->quote( 'MAT-1' )
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD separator_is_quoted.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->quote( 'A;B' )
                                        exp = '"A;B"' ).
  ENDMETHOD.

  METHOD quote_is_doubled.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->quote( 'A"B' )
                                        exp = '"A""B"' ).
  ENDMETHOD.

  METHOD comma_is_quoted.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->quote( 'A,B' )
                                        exp = '"A,B"' ).
  ENDMETHOD.

  METHOD line_joins_fields.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.

    APPEND 'MAT-1' TO lt_fields.
    APPEND 'A;B' TO lt_fields.
    APPEND '10' TO lt_fields.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build_line( lt_fields ) exp = 'MAT-1;"A;B";10' ).
  ENDMETHOD.

  METHOD custom_separator.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.

    APPEND 'MAT-1' TO lt_fields.
    APPEND 'WERKS-1' TO lt_fields.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build_line( it_fields    = lt_fields
                                iv_separator = ',' )
      exp = 'MAT-1,WERKS-1' ).
  ENDMETHOD.

  METHOD empty_list_empty_line.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build_line( lt_fields )
                                        exp = '' ).
  ENDMETHOD.

ENDCLASS.
