CLASS ltcl_alloc_rout_seq DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_seq.

    METHODS setup.

    METHODS reads_sequence FOR TESTING.
    METHODS reads_next     FOR TESTING.
    METHODS last_rule      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_seq IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_seq( ).
  ENDMETHOD.

  METHOD reads_sequence.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sequence( iv_position = 5 iv_step = 2 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->sequence( iv_position = 1 iv_step = 2 ) exp = 1 ).
  ENDMETHOD.

  METHOD reads_next.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_op( iv_current = 2 iv_total = 3 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_op( iv_current = 3 iv_total = 3 ) exp = 3 ).
  ENDMETHOD.

  METHOD last_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_last( iv_current = 3 iv_total = 3 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_last( iv_current = 2 iv_total = 3 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
