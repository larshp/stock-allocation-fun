CLASS zcl_alloc_gov_release DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key    TYPE string,
             locked TYPE abap_bool,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS release
      IMPORTING
        iv_locked        TYPE i
        iv_count         TYPE i
      RETURNING
        VALUE(rv_remain) TYPE i.

    METHODS is_released
      IMPORTING
        iv_remaining TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        it_locks        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_gov_release IMPLEMENTATION.

  METHOD release.
    " Releasing a number of locks leaves the rest in place.
    rv_remain = iv_locked - iv_count.
    IF rv_remain < 0 OR iv_count < 0.
      rv_remain = 0.
    ENDIF.
  ENDMETHOD.

  METHOD is_released.
    " The allocation is released once no locks remain.
    rv_ok = xsdbool( iv_remaining = 0 ).
  ENDMETHOD.

  METHOD remaining.
    " The remaining count gathers the items still locked.
    LOOP AT it_locks INTO DATA(ls_line).
      IF ls_line-locked = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
