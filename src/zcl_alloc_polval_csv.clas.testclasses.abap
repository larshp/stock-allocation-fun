CLASS ltcl_alloc_polval_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_polval_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_issue   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_polval_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_polval_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_issues TYPE zcl_alloc_policy_validator=>ty_issue_tt.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'FIELD_NAME;MESSAGE' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_policy_validator=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_policy_validator=>ty_issue.

    ls_issue-field_name = 'MAX_PICKS'.
    ls_issue-message = 'Max picks is negative'.
    APPEND ls_issue TO lt_issues.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = 'MAX_PICKS;Max picks is negative' ).
  ENDMETHOD.

ENDCLASS.
