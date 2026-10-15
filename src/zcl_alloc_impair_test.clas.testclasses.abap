CLASS ltcl_alloc_impair_test DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_impair_test.

    METHODS setup.

    METHODS impaired_rule   FOR TESTING.
    METHODS computes_gap    FOR TESTING.
    METHODS reads_severity  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_impair_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_impair_test( ).
  ENDMETHOD.

  METHOD impaired_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_impaired( iv_book_value = 110 iv_recoverable = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_impaired( iv_book_value = 90 iv_recoverable = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_book_value = 110 iv_recoverable = 100 )
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gap( iv_book_value = 90 iv_recoverable = 100 )
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_severity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->severity( iv_book_value = 1000 iv_recoverable = 400 )
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->severity( iv_book_value = 1000 iv_recoverable = 900 )
      exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->severity( iv_book_value = 1000 iv_recoverable = 1000 )
      exp = 'NONE' ).
  ENDMETHOD.

ENDCLASS.
