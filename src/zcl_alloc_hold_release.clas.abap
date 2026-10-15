CLASS zcl_alloc_hold_release DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_hold,
             code     TYPE string,
             blocking TYPE abap_bool,
           END OF ty_hold.
    TYPES ty_hold_tt TYPE STANDARD TABLE OF ty_hold WITH DEFAULT KEY.

    METHODS can_release
      IMPORTING
        it_holds     TYPE ty_hold_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        it_holds         TYPE ty_hold_tt
      RETURNING
        VALUE(rv_reason) TYPE string.

    METHODS blocking_holds
      IMPORTING
        it_holds           TYPE ty_hold_tt
      RETURNING
        VALUE(rt_blocking) TYPE ty_hold_tt.

ENDCLASS.


CLASS zcl_alloc_hold_release IMPLEMENTATION.

  METHOD blocking_holds.
    LOOP AT it_holds INTO DATA(ls_hold).
      IF ls_hold-blocking = abap_true.
        APPEND ls_hold TO rt_blocking.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD can_release.
    " Stock can be released once no blocking hold is left.
    DATA lt_blocking TYPE ty_hold_tt.

    lt_blocking = blocking_holds( it_holds ).

    rv_ok = xsdbool( lines( lt_blocking ) = 0 ).
  ENDMETHOD.

  METHOD reason.
    DATA lt_blocking TYPE ty_hold_tt.

    lt_blocking = blocking_holds( it_holds ).

    IF lines( lt_blocking ) = 0.
      rv_reason = 'OK'.
    ELSE.
      rv_reason = lt_blocking[ 1 ]-code.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
