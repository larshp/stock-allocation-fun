CLASS zcl_alloc_tenant DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_tenant TYPE c LENGTH 10.

    CONSTANTS c_default TYPE ty_tenant VALUE 'DEFAULT'.

    METHODS constructor
      IMPORTING
        iv_tenant TYPE ty_tenant DEFAULT 'DEFAULT'.

    METHODS get_tenant
      RETURNING
        VALUE(rv_tenant) TYPE ty_tenant.

    METHODS belongs_to
      IMPORTING
        iv_tenant       TYPE ty_tenant
      RETURNING
        VALUE(rv_match) TYPE abap_bool.

    METHODS is_default
      RETURNING
        VALUE(rv_default) TYPE abap_bool.

    METHODS qualify
      IMPORTING
        iv_key        TYPE string
      RETURNING
        VALUE(rv_key) TYPE string.

  PRIVATE SECTION.
    DATA mv_tenant TYPE ty_tenant.

ENDCLASS.


CLASS zcl_alloc_tenant IMPLEMENTATION.

  METHOD constructor.
    IF iv_tenant IS INITIAL.
      mv_tenant = c_default.
    ELSE.
      mv_tenant = iv_tenant.
    ENDIF.
  ENDMETHOD.

  METHOD get_tenant.
    rv_tenant = mv_tenant.
  ENDMETHOD.

  METHOD belongs_to.
    IF mv_tenant = iv_tenant.
      rv_match = abap_true.
    ELSE.
      rv_match = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD is_default.
    IF mv_tenant = c_default.
      rv_default = abap_true.
    ELSE.
      rv_default = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD qualify.
    rv_key = |{ mv_tenant }::{ iv_key }|.
  ENDMETHOD.

ENDCLASS.
