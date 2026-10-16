CLASS zcl_alloc_change_request DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_request,
             request_id TYPE string,
             status     TYPE string,
             priority   TYPE i,
             owner      TYPE string,
           END OF ty_request.
    TYPES ty_request_tt TYPE STANDARD TABLE OF ty_request WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             rank       TYPE i,
             request_id TYPE string,
             status     TYPE string,
             priority   TYPE i,
             owner      TYPE string,
             is_open    TYPE abap_bool,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    METHODS is_open_status
      IMPORTING
        iv_status      TYPE string
      RETURNING
        VALUE(rv_open) TYPE abap_bool.

    METHODS build
      IMPORTING
        it_requests    TYPE ty_request_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_row_tt.

    METHODS open_count
      IMPORTING
        it_rows         TYPE ty_row_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    CONSTANTS c_closed TYPE string VALUE 'closed'.

ENDCLASS.


CLASS zcl_alloc_change_request IMPLEMENTATION.

  METHOD is_open_status.
    " Everything that is not explicitly closed still needs work.
    IF iv_status <> c_closed.
      rv_open = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD build.
    DATA lt_sorted TYPE ty_request_tt.
    DATA ls_row    TYPE ty_row.

    lt_sorted = it_requests.

    " Lower priority numbers are more urgent, ties are broken by the id.
    SORT lt_sorted BY priority ASCENDING request_id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_request).
      CLEAR ls_row.
      ls_row-rank = lines( rt_rows ) + 1.
      ls_row-request_id = ls_request-request_id.
      ls_row-status = ls_request-status.
      ls_row-priority = ls_request-priority.
      ls_row-owner = ls_request-owner.
      ls_row-is_open = is_open_status( iv_status = ls_request-status ).
      APPEND ls_row TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD open_count.
    LOOP AT it_rows INTO DATA(ls_row).
      IF ls_row-is_open = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
