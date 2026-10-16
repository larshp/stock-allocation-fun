CLASS ltcl_alloc_bin_capacity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_capacity.

    METHODS setup.

    METHODS over_when_above  FOR TESTING.
    METHODS not_over         FOR TESTING.
    METHODS over_zero_cap    FOR TESTING.
    METHODS overflow_amount  FOR TESTING.
    METHODS overflow_none    FOR TESTING.
    METHODS utilisation_read FOR TESTING.
    METHODS utilisation_zero FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_capacity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_capacity( ).
  ENDMETHOD.

  METHOD over_when_above.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overloaded( iv_used = 120 iv_capacity = 100 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD not_over.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overloaded( iv_used = 100 iv_capacity = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD over_zero_cap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overloaded( iv_used = 10 iv_capacity = 0 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD overflow_amount.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overflow( iv_used = 120 iv_capacity = 100 ) exp = 20 ).
  ENDMETHOD.

  METHOD overflow_none.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overflow( iv_used = 90 iv_capacity = 100 ) exp = 0 ).
  ENDMETHOD.

  METHOD utilisation_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->utilisation( iv_used = 60 iv_capacity = 200 ) exp = 30 ).
  ENDMETHOD.

  METHOD utilisation_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->utilisation( iv_used = 60 iv_capacity = 0 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
