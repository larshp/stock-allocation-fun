CLASS ltcl_alloc_reorder_review DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_reorder_review.

    METHODS setup.

    METHODS computes_days FOR TESTING.
    METHODS due_rule      FOR TESTING.
    METHODS review_text   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_reorder_review IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reorder_review( ).
  ENDMETHOD.

  METHOD computes_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_until( iv_last_review_day = '20260101'
                                iv_today = '20260105' iv_cycle_days = 7 )
      exp = 3 ).
  ENDMETHOD.

  METHOD due_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_due( 3 ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_due( 0 ) exp = abap_true ).
  ENDMETHOD.

  METHOD review_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->review( iv_last_review_day = '20260101'
                            iv_today = '20260105' iv_cycle_days = 7 )
      exp = 'SCHEDULED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->review( iv_last_review_day = '20260101'
                            iv_today = '20260110' iv_cycle_days = 7 )
      exp = 'DUE' ).
  ENDMETHOD.

ENDCLASS.
