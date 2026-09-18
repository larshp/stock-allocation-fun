CLASS zcl_alloc_config_val DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_key   TYPE c LENGTH 30.
    TYPES ty_value TYPE c LENGTH 60.

    TYPES: BEGIN OF ty_entry,
             key   TYPE ty_key,
             value TYPE ty_value,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_issue,
             key    TYPE ty_key,
             reason TYPE c LENGTH 40,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS validate
      IMPORTING
        it_entries       TYPE ty_entry_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

    METHODS is_valid
      IMPORTING
        it_entries      TYPE ty_entry_tt
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_config_val IMPLEMENTATION.

  METHOD validate.
    DATA ls_entry   TYPE ty_entry.
    DATA ls_issue   TYPE ty_issue.
    DATA lv_index   TYPE i.
    DATA lv_back    TYPE i.
    DATA ls_compare TYPE ty_entry.

    LOOP AT it_entries INTO ls_entry.
      lv_index = lv_index + 1.

      IF ls_entry-key IS INITIAL.
        ls_issue-key = ls_entry-key.
        ls_issue-reason = 'Key is empty'.
        APPEND ls_issue TO rt_issues.
      ELSE.
        IF ls_entry-value IS INITIAL.
          ls_issue-key = ls_entry-key.
          ls_issue-reason = 'Value is empty'.
          APPEND ls_issue TO rt_issues.
        ENDIF.

        lv_back = 0.
        LOOP AT it_entries INTO ls_compare.
          lv_back = lv_back + 1.
          IF lv_back >= lv_index.
            EXIT.
          ENDIF.

          IF ls_compare-key = ls_entry-key.
            ls_issue-key = ls_entry-key.
            ls_issue-reason = 'Duplicate key'.
            APPEND ls_issue TO rt_issues.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_valid.
    DATA lt_issues TYPE ty_issue_tt.

    lt_issues = validate( it_entries ).

    IF lines( lt_issues ) = 0.
      rv_valid = abap_true.
    ELSE.
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
