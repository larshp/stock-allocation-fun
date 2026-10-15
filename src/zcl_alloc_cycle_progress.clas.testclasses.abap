CLASS ltcl_alloc_cycle_progress DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_progress.

    METHODS setup.

    METHODS reads_progress FOR TESTING.
    METHODS done_rule      FOR TESTING.
    METHODS reads_remaining FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_progress IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_progress( ).
  ENDMETHOD.

  METHOD reads_progress.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->progress_percent( iv_done = 3 iv_total = 4 )
      exp = 75 ).
  ENDMETHOD.

  METHOD done_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_done( iv_done = 4 iv_total = 4 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_done( iv_done = 3 iv_total = 4 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_remaining.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( iv_done = 3 iv_total = 4 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remaining( iv_done = 4 iv_total = 4 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
