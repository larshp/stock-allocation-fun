CLASS zcl_alloc_batch_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_known
      IMPORTING
        iv_status       TYPE string
      RETURNING
        VALUE(rv_known) TYPE abap_bool.

    METHODS can_use
      IMPORTING
        iv_status    TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_blocked
      IMPORTING
        iv_status         TYPE string
      RETURNING
        VALUE(rv_blocked) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_batch_status IMPLEMENTATION.

  METHOD is_known.
    rv_known = xsdbool( iv_status = 'ACTIVE'
                     OR iv_status = 'RESTRICTED'
                     OR iv_status = 'BLOCKED'
                     OR iv_status = 'EXPIRED' ).
  ENDMETHOD.

  METHOD can_use.
    " A restricted batch is still usable, only blocked or expired stock is not.
    " An unknown status is never usable.
    rv_ok = xsdbool( iv_status = 'ACTIVE' OR iv_status = 'RESTRICTED' ).
  ENDMETHOD.

  METHOD is_blocked.
    rv_blocked = xsdbool( iv_status = 'BLOCKED' OR iv_status = 'EXPIRED' ).
  ENDMETHOD.

ENDCLASS.
