CLASS ltcl_alloc_reqval_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_reqval_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_issue  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_reqval_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reqval_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_issues TYPE zcl_alloc_request_validator=>ty_issue_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_issues )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_request_validator=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_request_validator=>ty_issue.

    ls_issue-index = 1.
    ls_issue-field_name = 'MATNR'.
    ls_issue-message = 'Material missing'.
    APPEND ls_issue TO lt_issues.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_issues )
      exp = '[{"index":1,"field_name":"MATNR",' &&
            '"message":"Material missing"}]' ).
  ENDMETHOD.

ENDCLASS.
