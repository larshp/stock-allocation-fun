CLASS ltcl_alloc_replenish_urgency DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_urgency.

    METHODS setup.

    METHODS levels        FOR TESTING.
    METHODS urgent_rule   FOR TESTING.
    METHODS priority_text FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_urgency IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_urgency( ).
  ENDMETHOD.

  METHOD levels.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->urgency( 0 ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->urgency( 5 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->urgency( 30 ) exp = 0 ).
  ENDMETHOD.

  METHOD urgent_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_urgent( 2 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_urgent( 1 ) exp = abap_false ).
  ENDMETHOD.

  METHOD priority_text.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority_of( 3 ) exp = 'CRITICAL' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority_of( 0 ) exp = 'LOW' ).
  ENDMETHOD.

ENDCLASS.
