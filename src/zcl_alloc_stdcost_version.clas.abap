CLASS zcl_alloc_stdcost_version DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS version
      IMPORTING
        iv_current     TYPE i
      RETURNING
        VALUE(rv_next) TYPE i.

    METHODS is_newer
      IMPORTING
        iv_left      TYPE i
        iv_right     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_left         TYPE i
        iv_right        TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_version IMPLEMENTATION.

  METHOD version.
    " The next standard cost version follows the current one.
    rv_next = iv_current + 1.
  ENDMETHOD.

  METHOD is_newer.
    " The left version is newer once it is higher.
    rv_ok = xsdbool( iv_left > iv_right ).
  ENDMETHOD.

  METHOD delta.
    " The version delta is the left version less the right one.
    rv_delta = iv_left - iv_right.
  ENDMETHOD.

ENDCLASS.
