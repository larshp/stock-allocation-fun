CLASS ltcl_alloc_cycle_count DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_count.

    METHODS setup.

    METHODS counts_cycles FOR TESTING.
    METHODS reads_after   FOR TESTING.
    METHODS zero_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_count IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_count( ).
  ENDMETHOD.

  METHOD counts_cycles.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( iv_total = 10 iv_per_cycle = 3 ) exp = 4 ).
  ENDMETHOD.

  METHOD reads_after.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->after( iv_cycles = 4 iv_per_cycle = 3 ) exp = 12 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 4 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
