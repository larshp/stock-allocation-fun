CLASS ltcl_alloc_replenish_status DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_status.

    METHODS setup.

    METHODS reads_status   FOR TESTING.
    METHODS done_rule      FOR TESTING.
    METHODS counts_pending FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_status IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_status( ).
  ENDMETHOD.

  METHOD reads_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_done = 2 iv_total = 2 ) exp = 'DONE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_done = 1 iv_total = 2 ) exp = 'PARTIAL' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_done = 0 iv_total = 2 ) exp = 'OPEN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_done = 0 iv_total = 0 ) exp = 'EMPTY' ).
  ENDMETHOD.

  METHOD done_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_done( iv_done = 2 iv_total = 2 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_done( iv_done = 0 iv_total = 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pending.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( iv_done = 1 iv_total = 2 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( iv_done = 3 iv_total = 2 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
