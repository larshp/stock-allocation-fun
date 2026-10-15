CLASS zcl_alloc_cycle_state DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS state
      IMPORTING
        iv_done         TYPE i
        iv_total        TYPE i
      RETURNING
        VALUE(rv_state) TYPE string.

    METHODS is_terminal
      IMPORTING
        iv_state     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_active
      IMPORTING
        iv_state     TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cycle_state IMPLEMENTATION.

  METHOD state.
    " The cycle reads new, running or done from where it has got to.
    IF iv_done >= iv_total AND iv_total > 0.
      rv_state = 'DONE'.
    ELSEIF iv_done > 0.
      rv_state = 'RUNNING'.
    ELSE.
      rv_state = 'NEW'.
    ENDIF.
  ENDMETHOD.

  METHOD is_terminal.
    " A terminal state is one the cycle does not leave.
    rv_ok = xsdbool( iv_state = 'DONE' ).
  ENDMETHOD.

  METHOD is_active.
    " An active state is one the cycle is still running in.
    rv_ok = xsdbool( iv_state = 'RUNNING' ).
  ENDMETHOD.

ENDCLASS.
