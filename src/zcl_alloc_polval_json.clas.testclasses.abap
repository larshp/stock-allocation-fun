CLASS ltcl_alloc_polval_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_polval_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_issue  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_polval_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_polval_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_issues TYPE zcl_alloc_policy_validator=>ty_issue_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_issues )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_policy_validator=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_policy_validator=>ty_issue.

    ls_issue-field_name = 'MAX_PICKS'.
    ls_issue-message = 'Max picks is negative'.
    APPEND ls_issue TO lt_issues.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_issues )
      exp = '[{"field_name":"MAX_PICKS",' &&
            '"message":"Max picks is negative"}]' ).
  ENDMETHOD.

ENDCLASS.
