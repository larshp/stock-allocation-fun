CLASS zcl_alloc_wip_move DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS move_by
      IMPORTING
        iv_current    TYPE i
        iv_delta      TYPE i
      RETURNING
        VALUE(rv_new) TYPE i.

    METHODS is_increased
      IMPORTING
        iv_current   TYPE i
        iv_new       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_current      TYPE i
        iv_new          TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_wip_move IMPLEMENTATION.

  METHOD move_by.
    " The new value is the current one moved by the delta.
    rv_new = iv_current + iv_delta.
  ENDMETHOD.

  METHOD is_increased.
    " The value has increased once the new one is higher.
    rv_ok = xsdbool( iv_new > iv_current ).
  ENDMETHOD.

  METHOD delta.
    " The move is the new value less the current one.
    rv_delta = iv_new - iv_current.
  ENDMETHOD.

ENDCLASS.
