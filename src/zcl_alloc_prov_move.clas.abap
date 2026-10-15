CLASS zcl_alloc_prov_move DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS movement
      IMPORTING
        iv_old_provision   TYPE i
        iv_new_provision   TYPE i
      RETURNING
        VALUE(rv_movement) TYPE i.

    METHODS is_increase
      IMPORTING
        iv_old_provision TYPE i
        iv_new_provision TYPE i
      RETURNING
        VALUE(rv_ok)     TYPE abap_bool.

    METHODS delta
      IMPORTING
        iv_old_provision TYPE i
        iv_new_provision TYPE i
      RETURNING
        VALUE(rv_delta)  TYPE i.

ENDCLASS.


CLASS zcl_alloc_prov_move IMPLEMENTATION.

  METHOD movement.
    " The movement is signed: a rise is positive, a release is negative.
    rv_movement = iv_new_provision - iv_old_provision.
  ENDMETHOD.

  METHOD is_increase.
    " The provision rose once the new one is the higher.
    rv_ok = xsdbool( iv_new_provision > iv_old_provision ).
  ENDMETHOD.

  METHOD delta.
    " The delta is the size of the move, whichever way it went.
    IF iv_new_provision >= iv_old_provision.
      rv_delta = iv_new_provision - iv_old_provision.
    ELSE.
      rv_delta = iv_old_provision - iv_new_provision.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
