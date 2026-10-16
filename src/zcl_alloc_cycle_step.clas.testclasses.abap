CLASS ltcl_alloc_cycle_step DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_step.

    METHODS setup.

    METHODS reads_step    FOR TESTING.
    METHODS reads_next    FOR TESTING.
    METHODS last_rule     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_step IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_step( ).
  ENDMETHOD.

  METHOD reads_step.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->step( iv_position = 5 iv_size = 2 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->step( iv_position = 1 iv_size = 2 ) exp = 1 ).
  ENDMETHOD.

  METHOD reads_next.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_step( iv_current = 2 iv_total = 3 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_step( iv_current = 3 iv_total = 3 ) exp = 3 ).
  ENDMETHOD.

  METHOD last_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_last( iv_current = 3 iv_total = 3 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_last( iv_current = 2 iv_total = 3 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
