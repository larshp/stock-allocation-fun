CLASS zcl_alloc_consistency DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_issue,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             message        TYPE c LENGTH 80,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

ENDCLASS.


CLASS zcl_alloc_consistency IMPLEMENTATION.

  METHOD check.
    DATA ls_issue TYPE ty_issue.

    LOOP AT it_result INTO DATA(ls_result).
      IF ls_result-requested_qty < 0.
        CLEAR ls_issue.
        ls_issue-requirement_id = ls_result-requirement_id.
        ls_issue-message = 'Requested quantity is negative'.
        APPEND ls_issue TO rt_issues.
      ENDIF.

      IF ls_result-allocated_qty < 0.
        CLEAR ls_issue.
        ls_issue-requirement_id = ls_result-requirement_id.
        ls_issue-message = 'Allocated quantity is negative'.
        APPEND ls_issue TO rt_issues.
      ENDIF.

      IF ls_result-allocated_qty > ls_result-requested_qty.
        CLEAR ls_issue.
        ls_issue-requirement_id = ls_result-requirement_id.
        ls_issue-message = 'Allocated quantity exceeds requested'.
        APPEND ls_issue TO rt_issues.
      ENDIF.

      IF ls_result-shortage_qty
          <> ls_result-requested_qty - ls_result-allocated_qty.
        CLEAR ls_issue.
        ls_issue-requirement_id = ls_result-requirement_id.
        ls_issue-message = 'Shortage does not match requested minus allocated'.
        APPEND ls_issue TO rt_issues.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
