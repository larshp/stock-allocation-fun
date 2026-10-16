CLASS ltcl_alloc_settle_tolerance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_tolerance.

    METHODS setup.

    METHODS within_rule    FOR TESTING.
    METHODS reads_tolerance FOR TESTING.
    METHODS tight_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_tolerance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_tolerance( ).
  ENDMETHOD.

  METHOD within_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_difference = 5 iv_tolerance = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->within_tolerance( iv_difference = 15 iv_tolerance = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_tolerance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->tolerance( iv_amount = 1000 iv_percent = 2 ) exp = 20 ).
  ENDMETHOD.

  METHOD tight_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_tight( iv_tolerance = 5 iv_limit = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_tight( iv_tolerance = 20 iv_limit = 10 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
