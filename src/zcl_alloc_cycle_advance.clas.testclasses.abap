CLASS ltcl_alloc_cycle_advance DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_advance.

    METHODS setup.

    METHODS advances_step FOR TESTING.
    METHODS complete_rule FOR TESTING.
    METHODS reads_remaining FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_advance IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_advance( ).
  ENDMETHOD.

  METHOD advances_step.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->advance( iv_current = 2 iv_total = 3 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->advance( iv_current = 3 iv_total = 3 ) exp = 3 ).
  ENDMETHOD.

  METHOD complete_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( iv_current = 3 iv_total = 3 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( iv_current = 2 iv_total = 3 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_remaining.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( iv_current = 2 iv_total = 3 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( iv_current = 3 iv_total = 3 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
