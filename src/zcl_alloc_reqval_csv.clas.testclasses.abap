CLASS ltcl_alloc_reqval_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_reqval_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_issue   FOR TESTING.
    METHODS two_issues  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_reqval_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_reqval_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_issues TYPE zcl_alloc_request_validator=>ty_issue_tt.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'INDEX;FIELD_NAME;MESSAGE' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_request_validator=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_request_validator=>ty_issue.

    ls_issue-index = 1.
    ls_issue-field_name = 'MATNR'.
    ls_issue-message = 'Material missing'.
    APPEND ls_issue TO lt_issues.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;MATNR;Material missing' ).
  ENDMETHOD.

  METHOD two_issues.
    DATA lt_issues TYPE zcl_alloc_request_validator=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_request_validator=>ty_issue.

    ls_issue-index = 1.
    ls_issue-field_name = 'MATNR'.
    ls_issue-message = 'Material missing'.
    APPEND ls_issue TO lt_issues.

    ls_issue-index = 2.
    ls_issue-field_name = 'QUANTITY'.
    ls_issue-message = 'Quantity too small'.
    APPEND ls_issue TO lt_issues.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 3 ]
                                        exp = '2;QUANTITY;Quantity too small' ).
  ENDMETHOD.

ENDCLASS.
