CLASS ltcl_alloc_consist_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_consist_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_issue   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_consist_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_consist_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_issues TYPE zcl_alloc_consistency=>ty_issue_tt.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = 'REQUIREMENT_ID;MESSAGE' ).
  ENDMETHOD.

  METHOD one_issue.
    DATA lt_issues TYPE zcl_alloc_consistency=>ty_issue_tt.
    DATA ls_issue  TYPE zcl_alloc_consistency=>ty_issue.

    ls_issue-requirement_id = 'REQ-1'.
    ls_issue-message = 'Allocated exceeds requested'.
    APPEND ls_issue TO lt_issues.

    DATA(lt_lines) = mo_cut->build( lt_issues ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 2 ]
      exp = 'REQ-1;Allocated exceeds requested' ).
  ENDMETHOD.

ENDCLASS.
