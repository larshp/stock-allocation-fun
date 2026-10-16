CLASS ltcl_alloc_cycle_state DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_state.

    METHODS setup.

    METHODS reads_state    FOR TESTING.
    METHODS terminal_rule  FOR TESTING.
    METHODS active_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_state IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_state( ).
  ENDMETHOD.

  METHOD reads_state.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_done = 0 iv_total = 6 ) exp = 'NEW' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_done = 3 iv_total = 6 ) exp = 'RUNNING' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->state( iv_done = 6 iv_total = 6 ) exp = 'DONE' ).
  ENDMETHOD.

  METHOD terminal_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_terminal( 'DONE' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_terminal( 'RUNNING' ) exp = abap_false ).
  ENDMETHOD.

  METHOD active_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_active( 'RUNNING' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_active( 'NEW' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
