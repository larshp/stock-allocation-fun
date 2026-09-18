CLASS ltcl_alloc_sql_escape DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sql_escape.

    METHODS setup.

    METHODS plain_unchanged FOR TESTING.
    METHODS doubles_quotes  FOR TESTING.
    METHODS doubles_several FOR TESTING.
    METHODS quote_only      FOR TESTING.
    METHODS empty_text      FOR TESTING.
    METHODS flag_is_set     FOR TESTING.
    METHODS literal_wrapped FOR TESTING.
    METHODS literal_escapes FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sql_escape IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sql_escape( ).
  ENDMETHOD.

  METHOD plain_unchanged.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( 'PLANT_1000' ) exp = 'PLANT_1000' ).
  ENDMETHOD.

  METHOD doubles_quotes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( `O'Brien` ) exp = `O''Brien` ).
  ENDMETHOD.

  METHOD doubles_several.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( `a'b'c` ) exp = `a''b''c` ).
  ENDMETHOD.

  METHOD quote_only.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( `'` ) exp = `''` ).
  ENDMETHOD.

  METHOD empty_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->escape( '' ) exp = '' ).
  ENDMETHOD.

  METHOD flag_is_set.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_escape( 'abc' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_escape( '' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needs_escape( `a'b` ) exp = abap_true ).
  ENDMETHOD.

  METHOD literal_wrapped.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->literal( 'PLANT_1000' ) exp = `'PLANT_1000'` ).
  ENDMETHOD.

  METHOD literal_escapes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->literal( `O'Brien` ) exp = `'O''Brien'` ).
  ENDMETHOD.

ENDCLASS.
