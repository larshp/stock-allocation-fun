CLASS ltcl_alloc_cycle_run DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cycle_run.

    METHODS setup.

    METHODS runs_batch    FOR TESTING.
    METHODS finished_rule FOR TESTING.
    METHODS counts_passes FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cycle_run IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cycle_run( ).
  ENDMETHOD.

  METHOD runs_batch.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->run( iv_done = 2 iv_batch = 3 iv_total = 6 )
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->run( iv_done = 5 iv_batch = 3 iv_total = 6 )
      exp = 6 ).
  ENDMETHOD.

  METHOD finished_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_finished( iv_done = 6 iv_total = 6 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_finished( iv_done = 5 iv_total = 6 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_passes.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->steps_done( iv_total = 6 iv_batch = 3 ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
