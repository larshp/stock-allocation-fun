CLASS zcl_alloc_core_overdue DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_core,
             material   TYPE matnr,
             due_day    TYPE d,
             return_day TYPE d,
           END OF ty_core.
    TYPES ty_core_tt TYPE STANDARD TABLE OF ty_core WITH DEFAULT KEY.

    METHODS overdue
      IMPORTING
        is_core      TYPE ty_core
        iv_today     TYPE d
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS overdue_days
      IMPORTING
        is_core        TYPE ty_core
        iv_today       TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS is_overdue
      IMPORTING
        it_cores     TYPE ty_core_tt
        iv_today     TYPE d
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_core_overdue IMPLEMENTATION.

  METHOD overdue.
    " A core that has come back is never overdue; only an open one past its due
    " day is.
    IF is_core-due_day IS INITIAL OR iv_today IS INITIAL
        OR is_core-return_day IS NOT INITIAL.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_today > is_core-due_day ).
  ENDMETHOD.

  METHOD overdue_days.
    IF overdue( is_core  = is_core
                iv_today = iv_today ) = abap_false.
      RETURN.
    ENDIF.

    rv_days = iv_today - is_core-due_day.
  ENDMETHOD.

  METHOD is_overdue.
    LOOP AT it_cores INTO DATA(ls_core).
      IF overdue( is_core  = ls_core
                  iv_today = iv_today ) = abap_true.
        rv_ok = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
