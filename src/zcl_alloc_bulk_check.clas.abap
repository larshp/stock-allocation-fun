CLASS zcl_alloc_bulk_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_id    TYPE c LENGTH 20.
    TYPES ty_id_tt TYPE STANDARD TABLE OF ty_id WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_issue,
             row_no TYPE i,
             reason TYPE c LENGTH 40,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        it_ids           TYPE ty_id_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

    METHODS is_loadable
      IMPORTING
        it_ids       TYPE ty_id_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_bulk_check IMPLEMENTATION.

  METHOD check.
    DATA lv_id    TYPE ty_id.
    DATA lv_index TYPE i.
    DATA lv_back  TYPE i.
    DATA lv_other TYPE ty_id.
    DATA ls_issue TYPE ty_issue.

    LOOP AT it_ids INTO lv_id.
      lv_index = lv_index + 1.

      IF lv_id IS INITIAL.
        ls_issue-row_no = lv_index.
        ls_issue-reason = 'Empty id'.
        APPEND ls_issue TO rt_issues.
      ELSEIF strlen( lv_id ) < 3.
        ls_issue-row_no = lv_index.
        ls_issue-reason = 'Id too short'.
        APPEND ls_issue TO rt_issues.
      ENDIF.

      lv_back = 0.

      LOOP AT it_ids INTO lv_other.
        lv_back = lv_back + 1.

        IF lv_back >= lv_index.
          EXIT.
        ENDIF.

        IF lv_other = lv_id AND lv_id IS NOT INITIAL.
          ls_issue-row_no = lv_index.
          ls_issue-reason = 'Duplicate id'.
          APPEND ls_issue TO rt_issues.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_loadable.
    DATA lt_issues TYPE ty_issue_tt.

    lt_issues = check( it_ids ).

    IF lines( lt_issues ) = 0.
      rv_ok = abap_true.
    ELSE.
      rv_ok = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
