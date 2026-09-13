CLASS zcl_alloc_stock_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_issue,
             matnr   TYPE matnr,
             lgort   TYPE lgort_d,
             message TYPE c LENGTH 80,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        it_stock         TYPE zif_stock_reader=>ty_stock_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

  PRIVATE SECTION.
    METHODS add_issue
      IMPORTING
        is_stock         TYPE zif_stock_reader=>ty_stock
        iv_message       TYPE string
        it_issues        TYPE ty_issue_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

ENDCLASS.


CLASS zcl_alloc_stock_check IMPLEMENTATION.

  METHOD add_issue.
    DATA ls_issue TYPE ty_issue.

    rt_issues = it_issues.

    ls_issue-matnr = is_stock-matnr.
    ls_issue-lgort = is_stock-lgort.
    ls_issue-message = iv_message.
    APPEND ls_issue TO rt_issues.
  ENDMETHOD.

  METHOD check.
    LOOP AT it_stock INTO DATA(ls_stock).
      IF ls_stock-matnr IS INITIAL.
        rt_issues = add_issue( is_stock   = ls_stock
                               iv_message = 'Material is empty'
                               it_issues  = rt_issues ).
      ENDIF.

      IF ls_stock-werks IS INITIAL.
        rt_issues = add_issue( is_stock   = ls_stock
                               iv_message = 'Plant is empty'
                               it_issues  = rt_issues ).
      ENDIF.

      IF ls_stock-lgort IS INITIAL.
        rt_issues = add_issue( is_stock   = ls_stock
                               iv_message = 'Storage location is empty'
                               it_issues  = rt_issues ).
      ENDIF.

      IF ls_stock-unrestricted_qty < 0.
        rt_issues = add_issue( is_stock   = ls_stock
                               iv_message = 'Unrestricted quantity is negative'
                               it_issues  = rt_issues ).
      ENDIF.

      IF ls_stock-quality_qty < 0
          OR ls_stock-blocked_qty < 0
          OR ls_stock-restricted_qty < 0
          OR ls_stock-in_transit_qty < 0.
        rt_issues = add_issue( is_stock   = ls_stock
                               iv_message = 'A stock quantity is negative'
                               it_issues  = rt_issues ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
