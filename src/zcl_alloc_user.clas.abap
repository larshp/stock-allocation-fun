CLASS zcl_alloc_user DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_user TYPE c LENGTH 12.

    CONSTANTS c_system TYPE ty_user VALUE 'SYSTEM'.

    METHODS constructor
      IMPORTING
        iv_user TYPE ty_user DEFAULT 'SYSTEM'.

    METHODS get_user
      RETURNING
        VALUE(rv_user) TYPE ty_user.

    METHODS is_system
      RETURNING
        VALUE(rv_system) TYPE abap_bool.

    METHODS describe
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    DATA mv_user TYPE ty_user.

ENDCLASS.


CLASS zcl_alloc_user IMPLEMENTATION.

  METHOD constructor.
    IF iv_user IS INITIAL.
      mv_user = c_system.
    ELSE.
      mv_user = iv_user.
    ENDIF.
  ENDMETHOD.

  METHOD get_user.
    rv_user = mv_user.
  ENDMETHOD.

  METHOD is_system.
    IF mv_user = c_system OR mv_user = 'SAP*'.
      rv_system = abap_true.
    ELSE.
      rv_system = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD describe.
    rv_text = |User { mv_user }|.
  ENDMETHOD.

ENDCLASS.
