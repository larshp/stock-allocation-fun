CLASS ltcl_alloc_stockchk_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stockchk_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_issue  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_stockchk_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stockchk_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_issues TYPE zcl_alloc_stock_check=>ty_issue_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_issues )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_stock_check=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_stock_check=>ty_issue.

    ls_issue-matnr = 'MAT-1'.
    ls_issue-lgort = '0001'.
    ls_issue-message = 'Storage location is empty'.
    APPEND ls_issue TO lt_issues.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_issues )
      exp = '[{"matnr":"MAT-1","lgort":"0001",' &&
            '"message":"Storage location is empty"}]' ).
  ENDMETHOD.

ENDCLASS.
