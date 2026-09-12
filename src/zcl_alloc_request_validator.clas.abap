CLASS zcl_alloc_request_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_request,
             matnr    TYPE matnr,
             werks    TYPE werks_d,
             quantity TYPE menge_d,
           END OF ty_request.
    TYPES ty_request_tt TYPE STANDARD TABLE OF ty_request WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_issue,
             index      TYPE i,
             field_name TYPE c LENGTH 20,
             message    TYPE c LENGTH 80,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS validate
      IMPORTING
        it_requests      TYPE ty_request_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

ENDCLASS.


CLASS zcl_alloc_request_validator IMPLEMENTATION.

  METHOD validate.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-matnr IS INITIAL.
        APPEND VALUE #( index      = sy-tabix
                        field_name = 'MATNR'
                        message    = 'Material is empty' ) TO rt_issues.
      ENDIF.

      IF ls_request-werks IS INITIAL.
        APPEND VALUE #( index      = sy-tabix
                        field_name = 'WERKS'
                        message    = 'Plant is empty' ) TO rt_issues.
      ENDIF.

      IF ls_request-quantity <= 0.
        APPEND VALUE #( index      = sy-tabix
                        field_name = 'QUANTITY'
                        message    = 'Quantity is not positive' ) TO rt_issues.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
