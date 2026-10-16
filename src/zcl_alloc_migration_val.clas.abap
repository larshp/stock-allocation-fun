CLASS zcl_alloc_migration_val DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             field_name  TYPE string,
             is_required TYPE abap_bool,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_issue,
             record_index TYPE i,
             field_name   TYPE string,
             issue        TYPE string,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS validate
      IMPORTING
        it_rules         TYPE ty_rule_tt
        it_rows          TYPE zcl_alloc_migration_map=>ty_record_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

    METHODS is_valid
      IMPORTING
        it_issues       TYPE ty_issue_tt
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_migration_val IMPLEMENTATION.

  METHOD validate.
    DATA ls_issue TYPE ty_issue.
    DATA lv_index TYPE i.
    DATA lv_value TYPE string.

    LOOP AT it_rules INTO DATA(ls_rule).
      CLEAR ls_issue.
      CLEAR lv_value.
      lv_index = 0.

      LOOP AT it_rows INTO DATA(ls_row).
        IF ls_row-field_name = ls_rule-field_name.
          lv_index = sy-tabix.
          lv_value = ls_row-field_value.
          EXIT.
        ENDIF.
      ENDLOOP.

      ls_issue-field_name = ls_rule-field_name.

      IF lv_index = 0.
        IF ls_rule-is_required = abap_true.
          ls_issue-issue = 'missing'.
          APPEND ls_issue TO rt_issues.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_value IS INITIAL.
        ls_issue-record_index = lv_index.
        ls_issue-issue = 'empty'.
        APPEND ls_issue TO rt_issues.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_valid.
    IF lines( it_issues ) = 0.
      rv_valid = abap_true.
    ELSE.
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
