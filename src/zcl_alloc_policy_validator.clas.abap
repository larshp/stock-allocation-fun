CLASS zcl_alloc_policy_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_issue,
             field_name TYPE c LENGTH 20,
             message    TYPE c LENGTH 80,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS validate
      IMPORTING
        is_policy        TYPE zcl_stock_allocator=>ty_policy
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

ENDCLASS.


CLASS zcl_alloc_policy_validator IMPLEMENTATION.

  METHOD validate.
    IF is_policy-under_tolerance < 0 OR is_policy-under_tolerance > 100.
      APPEND VALUE #( field_name = 'UNDER_TOLERANCE'
                      message    = 'Tolerance must be between 0 and 100' )
        TO rt_issues.
    ENDIF.

    IF is_policy-max_picks < 0.
      APPEND VALUE #( field_name = 'MAX_PICKS'
                      message    = 'Maximum picks must not be negative' )
        TO rt_issues.
    ENDIF.

    IF is_policy-safety_stock < 0.
      APPEND VALUE #( field_name = 'SAFETY_STOCK'
                      message    = 'Safety stock must not be negative' )
        TO rt_issues.
    ENDIF.

    IF is_policy-min_remaining_days < 0.
      APPEND VALUE #( field_name = 'MIN_REMAINING_DAYS'
                      message    = 'Minimum remaining days must not be negative' )
        TO rt_issues.
    ENDIF.

    IF is_policy-min_remaining_days > 0
        AND is_policy-reference_date IS INITIAL.
      APPEND VALUE #( field_name = 'REFERENCE_DATE'
                      message    = 'Reference date required for shelf life' )
        TO rt_issues.
    ENDIF.

    IF lines( is_policy-allowed_lgorts ) > 0
        AND lines( is_policy-excluded_lgorts ) > 0.
      APPEND VALUE #( field_name = 'LGORTS'
                      message    = 'Allow list and exclude list are both set' )
        TO rt_issues.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
