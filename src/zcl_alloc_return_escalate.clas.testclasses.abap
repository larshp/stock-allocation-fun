CLASS ltcl_alloc_return_escalate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_escalate.

    METHODS setup.

    METHODS case_at
      IMPORTING
        iv_level       TYPE i
      RETURNING
        VALUE(rs_case) TYPE zcl_alloc_return_escalate=>ty_case.

    METHODS moves_up      FOR TESTING.
    METHODS caps_level    FOR TESTING.
    METHODS escalated_rule FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_escalate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_escalate( ).
  ENDMETHOD.

  METHOD case_at.
    rs_case-case_id = 'C1'.
    rs_case-level = iv_level.
  ENDMETHOD.

  METHOD moves_up.
    DATA ls_case TYPE zcl_alloc_return_escalate=>ty_case.

    ls_case = mo_cut->escalate( case_at( 0 ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_case-level exp = 1 ).
  ENDMETHOD.

  METHOD caps_level.
    DATA ls_case TYPE zcl_alloc_return_escalate=>ty_case.

    ls_case = mo_cut->escalate( case_at( 3 ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_case-level exp = 3 ).
  ENDMETHOD.

  METHOD escalated_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_escalated( case_at( 1 ) ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_escalated( case_at( 0 ) ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( case_at( 2 ) ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
