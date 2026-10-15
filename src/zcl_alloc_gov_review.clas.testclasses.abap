CLASS ltcl_alloc_gov_review DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_review.

    METHODS setup.

    METHODS due_rule        FOR TESTING.
    METHODS computes_days   FOR TESTING.
    METHODS reads_priority  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_review IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_review( ).
  ENDMETHOD.

  METHOD due_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_due( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_due( 5 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_until( iv_last = 20 iv_interval = 30 )
      exp = 10 ).
  ENDMETHOD.

  METHOD reads_priority.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority( -1 ) exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority( 5 ) exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority( 20 ) exp = 'LOW' ).
  ENDMETHOD.

ENDCLASS.
