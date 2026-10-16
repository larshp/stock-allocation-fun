CLASS ltcl_alloc_mastchk_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mastchk_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_issue  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_mastchk_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mastchk_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_issues TYPE zcl_alloc_master_check=>ty_issue_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_issues )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_master_check=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_master_check=>ty_issue.

    ls_issue-matnr = 'MAT-1'.
    ls_issue-werks = '1000'.
    ls_issue-message = 'Plant is missing'.
    APPEND ls_issue TO lt_issues.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_issues )
      exp = '[{"matnr":"MAT-1","werks":"1000",' &&
            '"message":"Plant is missing"}]' ).
  ENDMETHOD.

ENDCLASS.
