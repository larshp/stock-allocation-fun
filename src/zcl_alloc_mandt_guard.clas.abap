CLASS zcl_alloc_mandt_guard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_mandt TYPE c LENGTH 3.

    METHODS constructor
      IMPORTING
        iv_client  TYPE ty_mandt DEFAULT '000'
        iv_allowed TYPE ty_mandt DEFAULT '000'.

    METHODS is_current_allowed
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

    METHODS check
      IMPORTING
        iv_client         TYPE ty_mandt
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

    METHODS describe
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    DATA mv_allowed TYPE ty_mandt.
    DATA mv_client  TYPE ty_mandt.

ENDCLASS.


CLASS zcl_alloc_mandt_guard IMPLEMENTATION.

  METHOD constructor.
    mv_client = iv_client.
    mv_allowed = iv_allowed.
  ENDMETHOD.

  METHOD is_current_allowed.
    IF mv_client = mv_allowed.
      rv_allowed = abap_true.
    ELSE.
      rv_allowed = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD check.
    IF iv_client = mv_allowed.
      rv_allowed = abap_true.
    ELSE.
      rv_allowed = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD describe.
    rv_text = |Client { mv_client }, allowed { mv_allowed }|.
  ENDMETHOD.

ENDCLASS.
