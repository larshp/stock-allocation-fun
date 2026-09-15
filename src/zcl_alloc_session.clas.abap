CLASS zcl_alloc_session DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_id      TYPE c LENGTH 20.
    TYPES ty_user_id TYPE c LENGTH 12.
    TYPES ty_client  TYPE c LENGTH 3.

    TYPES: BEGIN OF ty_context,
             session_id TYPE ty_id,
             user_id    TYPE ty_user_id,
             client     TYPE ty_client,
             created_at TYPE d,
           END OF ty_context.

    METHODS open
      IMPORTING
        iv_session_id     TYPE ty_id
        iv_user_id        TYPE ty_user_id
        iv_client         TYPE ty_client
      RETURNING
        VALUE(rs_context) TYPE ty_context.

    METHODS close
      RETURNING
        VALUE(rs_context) TYPE ty_context.

    METHODS is_open
      RETURNING
        VALUE(rv_open) TYPE abap_bool.

    METHODS context
      RETURNING
        VALUE(rs_context) TYPE ty_context.

  PRIVATE SECTION.
    DATA mv_open    TYPE abap_bool.
    DATA ms_context TYPE ty_context.

ENDCLASS.


CLASS zcl_alloc_session IMPLEMENTATION.

  METHOD open.
    CLEAR ms_context.

    ms_context-session_id = iv_session_id.
    ms_context-user_id = iv_user_id.
    ms_context-client = iv_client.
    ms_context-created_at = sy-datum.

    mv_open = abap_true.

    rs_context = ms_context.
  ENDMETHOD.

  METHOD close.
    mv_open = abap_false.

    rs_context = ms_context.
  ENDMETHOD.

  METHOD is_open.
    rv_open = mv_open.
  ENDMETHOD.

  METHOD context.
    rs_context = ms_context.
  ENDMETHOD.

ENDCLASS.
