CLASS ltcl_alloc_settle_rule DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_settle_rule.

    METHODS setup.

    METHODS reads_rule  FOR TESTING.
    METHODS full_rule   FOR TESTING.
    METHODS reads_reason FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_settle_rule IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_settle_rule( ).
  ENDMETHOD.

  METHOD reads_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rule_of( 100 ) exp = 'FULL' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rule_of( 0 ) exp = 'NONE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rule_of( 50 ) exp = 'PARTIAL' ).
  ENDMETHOD.

  METHOD full_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( 50 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'FULL' ) exp = 'settles in full' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'NONE' ) exp = 'does not settle' ).
  ENDMETHOD.

ENDCLASS.
